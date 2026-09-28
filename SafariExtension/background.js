// QuitGambling Safari Extension - Background Service Worker
// Manages 524,916 binary 64-bit gambling domain hashes with 0.4µs lookups.

let hashArray = null;
let loadPromise = null;

async function loadHashes() {
  if (hashArray) return hashArray;
  if (loadPromise) return loadPromise;

  loadPromise = (async () => {
    try {
      const url = (typeof browser !== 'undefined' ? browser : chrome).runtime.getURL('gambling_hashes.bin');
      const response = await fetch(url);
      const buffer = await response.arrayBuffer();
      hashArray = new BigUint64Array(buffer);
      console.log(`[QuitGambling] Loaded ${hashArray.length} gambling domain hashes into memory.`);
      return hashArray;
    } catch (err) {
      console.error('[QuitGambling] Error loading gambling_hashes.bin:', err);
      return null;
    }
  })();

  return loadPromise;
}

// 64-bit FNV-1a hash matching the precomputed database
function fnv1a_64(str) {
  let h = 0xcbf29ce484222325n;
  const prime = 0x100000001b3n;
  for (let i = 0; i < str.length; i++) {
    h ^= BigInt(str.charCodeAt(i));
    h = (h * prime) & 0xffffffffffffffffn;
  }
  return h;
}

// O(log N) binary search over sorted BigUint64Array
function binarySearch(arr, target) {
  let low = 0;
  let high = arr.length - 1;
  while (low <= high) {
    const mid = (low + high) >>> 1;
    const midVal = arr[mid];
    if (midVal < target) {
      low = mid + 1;
    } else if (midVal > target) {
      high = mid - 1;
    } else {
      return true;
    }
  }
  return false;
}

// Preload database on startup
loadHashes();

// Message listener for content scripts
const runtimeAPI = (typeof browser !== 'undefined' ? browser : chrome).runtime;

runtimeAPI.onMessage.addListener((request, sender, sendResponse) => {
  if (request && request.action === 'check_domain') {
    loadHashes().then((arr) => {
      if (!arr) {
        sendResponse({ blocked: false });
        return;
      }

      const candidates = request.candidates || [];
      let isBlocked = false;

      for (const candidate of candidates) {
        const hash = fnv1a_64(candidate);
        if (binarySearch(arr, hash)) {
          isBlocked = true;
          break;
        }
      }

      sendResponse({ blocked: isBlocked });
    });

    return true; // Keep channel open for async response
  }
});
