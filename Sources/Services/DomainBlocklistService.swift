import Foundation
import os.log

/// High-performance service providing instantaneous O(log N) verification of URLs and domains
/// against the complete curated database of 524,916 gambling domains from HaGeZi.
/// Uses memory-mapped 64-bit FNV-1a binary hashes for near-zero RAM usage and microsecond latency.
final class DomainBlocklistService: @unchecked Sendable {

    static let shared = DomainBlocklistService()

    /// Total count of domains protected in the embedded database
    let totalBlockedDomainsCount: Int = 524_916

    private var mappedData: Data?
    private var hashBuffer: UnsafeBufferPointer<UInt64>?
    private let logger = Logger(subsystem: "com.lennertroehrig.freispiel", category: "DomainBlocklist")

    private init() {
        loadDatabase()
    }

    private func loadDatabase() {
        guard let url = Bundle.main.url(forResource: "gambling_hashes", withExtension: "bin") else {
            logger.warning("gambling_hashes.bin not found in main bundle.")
            return
        }

        do {
            // Memory-map the binary database directly from disk: 0 ms startup, no heap allocation
            let data = try Data(contentsOf: url, options: .alwaysMapped)
            self.mappedData = data

            data.withUnsafeBytes { rawBuffer in
                let bound = rawBuffer.bindMemory(to: UInt64.self)
                self.hashBuffer = bound
            }
            logger.info("Successfully mapped \(data.count / 8) domain hashes into memory.")
        } catch {
            logger.error("Failed to map gambling_hashes.bin: \(error.localizedDescription)")
        }
    }

    /// Fast 64-bit FNV-1a hash algorithm matching the generator
    private func fnv1a64(_ string: String) -> UInt64 {
        var hash: UInt64 = 0xcbf29ce484222325
        let prime: UInt64 = 0x100000001b3
        for byte in string.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* prime
        }
        return hash
    }

    /// Checks whether a given domain, URL, or any of its parent domains is in the gambling blocklist.
    /// Example: 'sports.tipico.de' -> checks 'sports.tipico.de' and 'tipico.de'
    func isGamblingDomain(_ rawInput: String) -> Bool {
        guard let buffer = hashBuffer, !buffer.isEmpty else {
            return false
        }

        // Clean input
        var domain = rawInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        domain = domain.replacingOccurrences(of: "https://", with: "")
        domain = domain.replacingOccurrences(of: "http://", with: "")
        if let slashIndex = domain.firstIndex(of: "/") {
            domain = String(domain[..<slashIndex])
        }
        if domain.hasPrefix("www.") {
            domain = String(domain.dropFirst(4))
        }

        guard !domain.isEmpty else { return false }

        // Generate domain suffix candidates
        let parts = domain.split(separator: ".")
        guard parts.count >= 2 else {
            return checkHash(fnv1a64(domain), in: buffer)
        }

        for i in 0..<(parts.count - 1) {
            let candidate = parts[i...].joined(separator: ".")
            let hash = fnv1a64(candidate)
            if checkHash(hash, in: buffer) {
                return true
            }
        }

        return false
    }

    /// Binary search in the sorted 64-bit hash table (typically ~19 comparisons)
    private func checkHash(_ target: UInt64, in buffer: UnsafeBufferPointer<UInt64>) -> Bool {
        var low = 0
        var high = buffer.count - 1

        while low <= high {
            let mid = (low + high) / 2
            let midVal = buffer[mid]
            if midVal < target {
                low = mid + 1
            } else if midVal > target {
                high = mid - 1
            } else {
                return true
            }
        }

        return false
    }
}
