//
//  AlarmSchedulerDelegate.swift
//  PillBox
//
//  Created by Hannah Hoff on 5/20/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import Foundation
import UIKit

protocol AlarmSchedulerDelegate {
    func setNotificationWithDate(_ date: Date, onDaysForNotify: [Int], snoozeEnabled: Bool, onSnooze: Bool, soundName: String, index: Int)
    //helper
    func setNotificationForSnooze(snoozeMinute: Int, soundName: String, index: Int)
    func setUpNotificationSettings() -> UIUserNotificationSettings
    func reSchedule()
    func checkNotification()
}
