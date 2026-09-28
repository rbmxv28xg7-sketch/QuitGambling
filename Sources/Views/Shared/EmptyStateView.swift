import SwiftUI

/// Reusable empty state view wrapping ContentUnavailableView.
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            Text(subtitle)
        } actions: {
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(Design.Colors.primary)
            }
        }
    }
}

#Preview {
    EmptyStateView(
        icon: "book.fill",
        title: "No Entries Yet",
        subtitle: "Write your first journal entry.",
        actionTitle: "Create Entry"
    ) {
        // action
    }
}
