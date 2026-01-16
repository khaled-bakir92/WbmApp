//
//  UserConfig.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation

/// Response/Request-Model für /api/config/user
struct UserConfig: Codable, Sendable, Equatable {
    var userData: UserData
    var notificationEmail: NotificationEmail?
    
    enum CodingKeys: String, CodingKey {
        case userData = "user_data"
        case notificationEmail = "notification_email"
    }
}

// MARK: - User Data

struct UserData: Codable, Sendable, Equatable {
    var anrede: String
    var name: String
    var vorname: String
    var strasse: String
    var plz: String
    var ort: String
    var email: String
    var telefon: String
}

// MARK: - Notification Email

struct NotificationEmail: Codable, Sendable, Equatable {
    var sender: String
    var recipient: String
    var password: String // Wird vom Server maskiert bei GET
    var smtpServer: String
    var smtpPort: Int
    
    enum CodingKeys: String, CodingKey {
        case sender
        case recipient
        case password
        case smtpServer = "smtp_server"
        case smtpPort = "smtp_port"
    }
}

// MARK: - Computed Properties

extension UserData {
    /// Vollständiger Name
    var fullName: String {
        "\(anrede) \(vorname) \(name)"
    }
    
    /// Vollständige Adresse
    var fullAddress: String {
        "\(strasse)\n\(plz) \(ort)"
    }
    
    /// Validierung
    var isValid: Bool {
        !name.isEmpty && 
        !vorname.isEmpty && 
        !email.isEmpty && 
        email.contains("@") &&
        !telefon.isEmpty
    }
}

extension NotificationEmail {
    /// Prüft ob das Passwort maskiert ist (vom Server)
    var isPasswordMasked: Bool {
        password.contains("*")
    }
}
