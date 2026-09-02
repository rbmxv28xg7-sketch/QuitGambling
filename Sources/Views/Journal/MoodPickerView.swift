import SwiftUI

struct MoodPickerView: View {
    @Binding var selectedMood: Int
    
    var body: some View {
        HStack {
            ForEach(Design.Mood.allCases) { mood in
                Button(action: {
                    withAnimation(Design.Anim.fast) {
                        selectedMood = mood.rawValue
                    }
                }) {
                    Text(mood.emoji)
                        .font(.system(size: 32))
                        .frame(minWidth: 52, minHeight: 52)
                        .background(
                            Circle()
                                .strokeBorder(
                                    selectedMood == mood.rawValue ? Design.Colors.accent : Color.clear,
                                    lineWidth: 3
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                if mood != Design.Mood.allCases.last {
                    Spacer()
                }
            }
        }
        .padding(.vertical, Design.Spacing.sm)
    }
}

#Preview {
    MoodPickerView(selectedMood: .constant(3))
}
