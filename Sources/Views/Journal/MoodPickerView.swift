import SwiftUI

struct MoodPickerView: View {
    @Binding var selectedMood: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Design.Mood.allCases) { mood in
                let isSelected = selectedMood == mood.rawValue
                Button {
                    withAnimation(Design.Anim.spring) {
                        selectedMood = mood.rawValue
                        SensoryFeedbackService.shared.selectionClick()
                    }
                } label: {
                    ZStack {
                        // 1. Deep solid substrate - stops green or dark backgrounds from bleeding through and muddying red/other tones
                        Circle()
                            .fill(Color(red: 0.10, green: 0.12, blue: 0.11))
                            .frame(width: 48, height: 48)

                        // 2. Tinted mood circle
                        Circle()
                            .fill(isSelected ? mood.color : mood.color.opacity(0.24))
                            .frame(width: 48, height: 48)

                        // 3. Crisp boundary ring with high visibility
                        Circle()
                            .strokeBorder(
                                isSelected ? Color.white : mood.color.opacity(0.65),
                                lineWidth: isSelected ? 2.5 : 1.5
                            )
                            .frame(width: 48, height: 48)

                        // 4. Luminous Morphing Face in vibrant, high-contrast colors
                        MorphingMoodFace(
                            progress: CGFloat(mood.rawValue),
                            isSelected: isSelected,
                            colorOverride: isSelected ? Color.white : mood.luminousColor
                        )
                        .frame(width: 28, height: 28)
                    }
                    .shadow(
                        color: isSelected ? mood.color.opacity(0.55) : Color.black.opacity(0.35),
                        radius: isSelected ? 8 : 4,
                        y: 2
                    )
                    .scaleEffect(isSelected ? 1.08 : 1.0)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, Design.Spacing.xs)
    }
}

#Preview {
    MoodPickerView(selectedMood: .constant(3))
}
