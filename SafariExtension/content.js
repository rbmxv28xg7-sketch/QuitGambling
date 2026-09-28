// Quit Gambling Impuls-Bremse Safari Content Script
// Automatically detects and filters across 524,916 gambling domains.
(function () {
  'use strict';

  if (document.getElementById('freispiel-impulse-gate')) {
    return;
  }

  const rawHost = window.location.hostname;
  if (!rawHost || rawHost === 'localhost' || rawHost === '127.0.0.1') {
    return;
  }

  const cleanHost = rawHost.toLowerCase().replace(/^www\./, '');

  // Extract all domain candidates (e.g., 'sports.tipico.de' -> ['sports.tipico.de', 'tipico.de'])
  function getCandidates(host) {
    const parts = host.split('.');
    const candidates = [];
    for (let i = 0; i < parts.length - 1; i++) {
      candidates.push(parts.slice(i).join('.'));
    }
    return candidates;
  }

  const candidates = getCandidates(cleanHost);

  // Fast synchronous cache of top German & international gambling domains
  const FAST_CACHE = new Set([
    'tipico.de', 'tipico.com', 'bwin.de', 'bwin.com', 'bet365.de', 'bet365.com',
    'betano.de', 'bet-at-home.com', 'bet-at-home.de', 'interwetten.de', 'pokerstars.de', 'pokerstars.com',
    'lotto.de', 'lotto-hessen.de', 'lotto-bw.de', 'lotto-bayern.de', 'westlotto.de',
    '888casino.de', 'hyperino.de', 'wunderino.de', 'platincasino.com', 'platincasino.de', 'stake.com',
    'roobet.com', 'unibet.de', 'gamblejoe.com', 'online-casino.de', 'betclic.com',
    'wildz.de', 'spintastic.com', 'drueckglueck.de', 'slotmagie.de', 'lapalingo.de',
    'rollbit.com', 'razed.com', 'razed2.com', 'shuffle.com', 'duelbits.com', 'gamdom.com', 'bc.game',
    'bitstarz.com', '500.casino', 'csgoroll.com', 'clash.gg', 'rainbet.com', 'packdraw.com',
    'rustclash.com', 'hellcase.com', 'key-drop.com', 'sportsbet.io', 'cloudbet.com', 'vave.com',
    'metaspins.com', 'jackpotpiraten.de', 'merkur-spiel.de', 'novoline.de', 'admiralbet.de', 'neo.bet'
  ]);

  let isFastMatch = false;
  for (const c of candidates) {
    if (FAST_CACHE.has(c)) {
      isFastMatch = true;
      break;
    }
  }

  if (isFastMatch) {
    createOverlay();
    return;
  }

  // Query background service worker for full 524,916 domain database
  const runtimeAPI = (typeof browser !== 'undefined' ? browser : chrome).runtime;
  if (runtimeAPI && runtimeAPI.sendMessage) {
    runtimeAPI.sendMessage({ action: 'check_domain', candidates: candidates }, function (response) {
      if (response && response.blocked) {
        createOverlay();
      }
    });
  }

  function createOverlay() {
    if (document.getElementById('freispiel-impulse-gate')) {
      return;
    }

    let secondsRemaining = 5;
    const totalSeconds = 5;
    const circumference = 276.46; // 2 * PI * 44

    const overlay = document.createElement('div');
    overlay.id = 'freispiel-impulse-gate';
    overlay.innerHTML = `
      <div class="freispiel-card">
        <div class="freispiel-shield-icon">
          <svg class="freispiel-shield-svg" viewBox="0 0 24 24">
            <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm0 10.99h7c-.53 4.12-3.28 7.79-7 8.94V12H5V6.3l7-3.11v8.8z"/>
          </svg>
        </div>

        <h1 class="freispiel-title">Kurz durchatmen.</h1>
        <div class="freispiel-badge">⚠️ ${cleanHost}</div>
        <p class="freispiel-subtitle">
          Ist es das wirklich wert? Nimm dir einen kurzen Moment Zeit für deine Entscheidung.
        </p>

        <div class="freispiel-timer-container">
          <svg class="freispiel-timer-svg" viewBox="0 0 100 100">
            <circle class="freispiel-timer-bg" cx="50" cy="50" r="44"/>
            <circle id="freispiel-progress-circle" class="freispiel-timer-progress" cx="50" cy="50" r="44"/>
          </svg>
          <span id="freispiel-timer-num" class="freispiel-timer-number">5</span>
        </div>

        <button id="freispiel-safe-btn" class="freispiel-btn-safe">
          <span>🛡️</span> Zurück in Sicherheit
        </button>

        <button id="freispiel-proceed-btn" class="freispiel-btn-proceed" disabled>
          Bedenkzeit läuft (5s)...
        </button>

        <div class="freispiel-brand-footer">
          <span>🌿</span> Quit Gambling Schutzschild • 524.916 Seiten geschützt
        </div>
      </div>
    `;

    function insert() {
      if (document.body) {
        document.body.appendChild(overlay);
        document.body.style.overflow = 'hidden';
      } else if (document.documentElement) {
        document.documentElement.appendChild(overlay);
        document.documentElement.style.overflow = 'hidden';
      }
    }

    if (document.body || document.documentElement) {
      insert();
    } else {
      document.addEventListener('DOMContentLoaded', insert);
    }

    const timerNum = overlay.querySelector('#freispiel-timer-num');
    const progressCircle = overlay.querySelector('#freispiel-progress-circle');
    const proceedBtn = overlay.querySelector('#freispiel-proceed-btn');
    const safeBtn = overlay.querySelector('#freispiel-safe-btn');

    // Safe button handler
    safeBtn.addEventListener('click', function () {
      if (window.history.length > 1) {
        window.history.back();
      } else {
        window.location.href = 'about:blank';
      }
      setTimeout(function () {
        window.location.href = 'about:blank';
      }, 300);
    });

    // Countdown interval
    const countdown = setInterval(function () {
      secondsRemaining--;

      if (secondsRemaining > 0) {
        timerNum.textContent = secondsRemaining;
        proceedBtn.textContent = `Bedenkzeit läuft (${secondsRemaining}s)...`;

        const offset = circumference * (1 - (secondsRemaining / totalSeconds));
        progressCircle.style.strokeDashoffset = offset;
      } else {
        clearInterval(countdown);
        timerNum.textContent = '✓';
        progressCircle.style.strokeDashoffset = circumference;
        proceedBtn.disabled = false;
        proceedBtn.classList.add('freispiel-unlocked');
        proceedBtn.textContent = 'Trotzdem fortfahren →';

        proceedBtn.addEventListener('click', function () {
          overlay.classList.add('freispiel-fade-out');
          setTimeout(function () {
            if (overlay.parentNode) {
              overlay.parentNode.removeChild(overlay);
            }
            document.documentElement.style.overflow = '';
            if (document.body) {
              document.body.style.overflow = '';
            }
          }, 400);
        });
      }
    }, 1000);
  }
})();
