import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Design.Spacing.md) {
                    greetingView
                    
                    TimelineView(.periodic(from: .now, by: 1)) { _ in
                        LiveCounterView(viewModel: viewModel)
                            .onAppear {
                                viewModel.updateTimer()
                            }
                            .onChange(of: Date.now) { _, _ in
                                viewModel.updateTimer()
                            }
                    }
                    
                    SavingsCardView(moneySaved: viewModel.moneySaved)
                    
                    DailyPledgeView(
                        hasPledgedToday: viewModel.hasPledgedToday,
                        onPledge: {
                            viewModel.confirmPledge(context: modelContext)
                        }
                    )
                    
                    MilestonePreviewView(viewModel: viewModel)
                }
                .padding(.horizontal, Design.Spacing.md)
            }
            .background(Design.Colors.background)
            .navigationTitle("Übersicht")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: Text("Finanzen")) {
                        Image(systemName: "banknote")
                            .foregroundStyle(Design.Colors.primary)
                            .frame(width: 44, height: 44)
                    }
                }
            }
            .task {
                viewModel.loadProfile(context: modelContext)
            }
        }
    }
    
    private var greetingView: some View {
        let hour = Calendar.current.component(.hour, from: .now)
        let greeting = switch hour {
        case 5..<12: "Guten Morgen"
        case 12..<18: "Guten Tag"
        default: "Guten Abend"
        }
        
        return Text(greeting)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundStyle(Design.Colors.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, Design.Spacing.sm)
    }
}

#Preview {
    DashboardView()
}
