import Foundation

/// Holds the list of reminders, persists them locally with Codable +
/// UserDefaults, and keeps notifications in sync.
@MainActor
final class ReminderStore: ObservableObject {
    @Published private(set) var reminders: [Reminder] = []

    private let storageKey = "dailybell.reminders.v1"
    private let notifications = NotificationManager.shared

    init() {
        load()
    }

    /// All reminders sorted by time of day (earliest first).
    var sortedReminders: [Reminder] {
        reminders.sorted { minutesOfDay($0.time) < minutesOfDay($1.time) }
    }

    // MARK: - Mutations

    func add(_ reminder: Reminder) {
        reminders.append(reminder)
        save()
        if reminder.notificationEnabled {
            notifications.schedule(for: reminder)
        }
    }

    func toggleDone(_ reminder: Reminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        reminders[index].lastCompletedDate = reminders[index].isDoneToday ? nil : Date()
        save()
    }

    func delete(_ reminder: Reminder) {
        notifications.cancel(for: reminder)
        reminders.removeAll { $0.id == reminder.id }
        save()
    }

    /// Deletes the reminders at the given offsets within a displayed list
    /// (e.g. the sorted list shown on screen).
    func delete(at offsets: IndexSet, in displayed: [Reminder]) {
        let ids = offsets.map { displayed[$0].id }
        for reminder in reminders where ids.contains(reminder.id) {
            notifications.cancel(for: reminder)
        }
        reminders.removeAll { ids.contains($0.id) }
        save()
    }

    // MARK: - Helpers

    private func minutesOfDay(_ date: Date) -> Int {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(reminders)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("DailyBell: failed to save reminders — \(error)")
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            reminders = try JSONDecoder().decode([Reminder].self, from: data)
        } catch {
            print("DailyBell: failed to load reminders — \(error)")
        }
    }
}
