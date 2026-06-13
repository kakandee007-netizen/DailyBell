import SwiftUI

struct AddReminderView: View {
    @EnvironmentObject private var store: ReminderStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var time = Date()
    @State private var note = ""
    @State private var notificationEnabled = true

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title (e.g. Skincare, Study, Drink water)", text: $title)
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                }

                Section("Note (optional)") {
                    TextField("Add a note", text: $note, axis: .vertical)
                        .lineLimit(1...4)
                }

                Section {
                    Toggle("Notification", isOn: $notificationEnabled)
                } footer: {
                    Text("When on, DailyBell sends a notification every day at the chosen time.")
                }
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }
                        .disabled(trimmedTitle.isEmpty)
                }
            }
        }
    }

    private func save() {
        let reminder = Reminder(
            title: trimmedTitle,
            time: time,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            notificationEnabled: notificationEnabled
        )
        store.add(reminder)
        dismiss()
    }
}

#Preview {
    AddReminderView()
        .environmentObject(ReminderStore())
}
