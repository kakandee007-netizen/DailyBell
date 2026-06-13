import SwiftUI

@main
struct DailyBellApp: App {
    @StateObject private var store = ReminderStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .task {
                    // Ask for notification permission on first launch.
                    NotificationManager.shared.requestAuthorization()
                }
        }
    }
}
