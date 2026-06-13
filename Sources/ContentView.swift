import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: ReminderStore
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if store.sortedReminders.isEmpty {
                    emptyState
                } else {
                    reminderList
                }
            }
            .navigationTitle("DailyBell")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add reminder")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddReminderView()
            }
        }
    }

    private var reminderList: some View {
        List {
            Section {
                ForEach(store.sortedReminders) { reminder in
                    ReminderRow(reminder: reminder)
                }
                .onDelete { offsets in
                    store.delete(at: offsets, in: store.sortedReminders)
                }
            } header: {
                Text(Date(), format: .dateTime.weekday(.wide).month().day())
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.badge")
                .font(.system(size: 52))
                .foregroundStyle(.tint)
            Text("No reminders yet")
                .font(.title3.weight(.semibold))
            Text("Tap + to add your first daily routine.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

/// A single row in the reminder list.
struct ReminderRow: View {
    @EnvironmentObject private var store: ReminderStore
    let reminder: Reminder

    var body: some View {
        HStack(spacing: 12) {
            Button {
                store.toggleDone(reminder)
            } label: {
                Image(systemName: reminder.isDoneToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(reminder.isDoneToday ? Color.green : Color.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(reminder.isDoneToday ? "Mark not done" : "Mark done")

            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(.body.weight(.medium))
                    .strikethrough(reminder.isDoneToday)
                    .foregroundStyle(reminder.isDoneToday ? Color.secondary : Color.primary)
                if !reminder.note.isEmpty {
                    Text(reminder.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                Text(reminder.time, format: .dateTime.hour().minute())
                    .font(.subheadline.weight(.medium))
                    .monospacedDigit()
                if reminder.notificationEnabled {
                    Image(systemName: "bell.fill")
                        .font(.caption2)
                        .foregroundStyle(.tint)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                store.delete(reminder)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ReminderStore())
}
