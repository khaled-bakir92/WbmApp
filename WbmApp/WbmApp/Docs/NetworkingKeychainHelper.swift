//
//  KeychainHelper.swift
//  WBM Bot Controller
//
//  Created on 2026-01-17.
//

import Foundation
import Security

/// Einfache Keychain-Hilfsklasse für sichere Speicherung sensibler Daten
final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}

    // MARK: - Public Convenience Defaults

    /// Standard-Service-Name (Bundle Identifier oder Fallback)
    static var defaultService: String {
        Bundle.main.bundleIdentifier ?? "WbmApp"
    }

    private static let bearerAccount = "api_bearer_token"

    /// Speichert den Bearer Token im Keychain (Service: Bundle ID, Account: "api_bearer_token")
    @discardableResult
    func saveBearerToken(_ token: String) -> Bool {
        save(token, service: Self.defaultService, account: Self.bearerAccount)
    }

    /// Liest den Bearer Token aus dem Keychain (Service: Bundle ID, Account: "api_bearer_token")
    func readBearerToken() -> String? {
        read(service: Self.defaultService, account: Self.bearerAccount)
    }

    /// Löscht den Bearer Token aus dem Keychain (Service: Bundle ID, Account: "api_bearer_token")
    @discardableResult
    func deleteBearerToken() -> Bool {
        delete(service: Self.defaultService, account: Self.bearerAccount)
    }

    // MARK: - Generic String APIs

    /// Speichert einen String im Keychain
    @discardableResult
    func save(_ value: String, service: String, account: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        return save(data, service: service, account: account)
    }

    /// Liest einen String aus dem Keychain
    func read(service: String, account: String) -> String? {
        guard let data: Data = readData(service: service, account: account) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Generic Data APIs

    /// Speichert Daten im Keychain (überschreibt vorhandene Einträge)
    @discardableResult
    func save(_ data: Data, service: String, account: String) -> Bool {
        // Vorhandenen Eintrag entfernen
        _ = delete(service: service, account: account)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Liest Daten aus dem Keychain
    func readData(service: String, account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return data
    }

    /// Löscht einen Eintrag aus dem Keychain
    @discardableResult
    func delete(service: String, account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

