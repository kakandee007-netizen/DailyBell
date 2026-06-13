import Foundation
import UserNotifications

/// Wraps UNUserNotificationCenter for permission and daily-repeating
/// local notifications.
final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    /// Requests notification permission. Safe to call on every launch —
    /// the system only prompts the user once.
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, error in
            if let error = error {
                print("DailyBell: notification auth error — \(error)")
            }
        }
    }

    /// Schedules a notification that repeats every day at the reminder's time.
    func schedule(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.note.isEmpty ? "Time for your daily task." : reminder.note
        content.sound = .default

        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminder.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("DailyBell: failed to schedule notification — \(error)")
            }
        }
    }

    /// Cancels the pending notification for a reminder.
    func cancel(for reminder: Reminder) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
    }
}
