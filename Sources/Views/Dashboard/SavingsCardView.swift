import SwiftUI

struct SavingsCardView: View {
    var moneySaved: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                Text(moneySaved, format: .currency(code: "EUR"))
                    .font(.title)
                    .fontWeight(.bold)
                    .contentTransition(.numericText())
                    .foregroundStyle(Design.Colors.primary)
                
                Text("Geld, das du nicht verspielt hast")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "banknote.fill")
                .font(.system(size: 32))
                .foregroundStyle(Design.Colors.gold)
        }
        .padding(Design.Spacing.md)
        .background(Design.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
    }
}

#Preview {
    SavingsCardView(moneySaved: 125.50)
}
