import Foundation

/// A single daily routine item.
///
/// Only the *time of day* of `time` is meaningful — DailyBell treats every
/// reminder as a daily routine that repeats every day at that time.
struct Reminder: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var time: Date
    var note: String = ""
    var notificationEnabled: Bool = true

    /// The last time the user marked this reminder done. Used to derive
    /// `isDoneToday`, which automatically resets every day at midnight.
    var lastCompletedDate: Date? = nil

    /// True if the reminder was completed at some point today.
    var isDoneToday: Bool {
        guard let date = lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(date)
    }
}
