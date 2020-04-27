//
//  Notifications.swift
//  Rise
//
//  Created by Domonique Dixon on 3/27/20.
//  Copyright © 2020 Domonique Dixon. All rights reserved.
//

import Foundation
import UserNotifications

class Notifications: NSObject {
    static let shared = Notifications()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private var count: Int = 0
    
    private override init() {}
    
    func registerNotification() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }
    
    func cancelNotification() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func createNotification(date: Date?) {
        guard let date = date else { return }
        
        let calendar = Calendar.current
        let content = UNMutableNotificationContent()
        var message = ""

        if count == 0 {
            message = "Keep up the great work!"
        } else if count > 0 {
            message = "You have people who need recognition"
        }
        
        content.title = message
        content.badge = 1
        content.categoryIdentifier = "customIdentifier"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = calendar.component(.hour, from: date)
        dateComponents.minute = calendar.component(.minute, from: date)
        dateComponents.second = 0
                
        let notificationCenter = UNUserNotificationCenter.current()
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    func getNotificationTextCount(members: [Member]) {
        var calendar = Calendar.current
        
        calendar.timeZone = NSTimeZone.local

        let dateFrom = calendar.startOfDay(for: Date())
        let dateTo = calendar.date(byAdding: .day, value: -UserDefaults.reminderStartDays - 1, to: dateFrom)
        var counter = 0
        
        for member in members {
            if member.comments.count == 0 {
                counter += 1
            }
            
            if let latest = member.latest {
                if latest <= dateTo! {
                    counter += 1
                }
            }
        }
        
        count = counter
    }
}
