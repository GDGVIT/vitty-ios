//
//  NotificationsSettingsModel.swift
//  VITTY
//
//  Created by Ananya George on 1/23/22.
//

import Foundation

struct NotificationsSettingsModel: Identifiable, Equatable, Hashable, Codable {
    var id: String?
    var enabled: Bool
    var day: Int
    // day: 1 - sunday
    var period: Int
    var location: String
}

struct NotificationsSettingsHashModel: Codable {
    var daysNotifications: [String:[NotificationsSettingsModel]] = [:]
}
