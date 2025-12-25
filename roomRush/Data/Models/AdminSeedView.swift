
import SwiftUI

struct AdminSeedView: View {

    @State private var isSeeding = false
    private let seeder = DatabaseSeeder()

    var body: some View {
        VStack(spacing: 20) {
            Text("Admin Tools")
                .font(.title)

            Button("Seed Database") {
                isSeeding = true
                Task {
                    await seeder.seedIfNeeded()
                    isSeeding = false
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isSeeding)

            if isSeeding {
                ProgressView()
            }
        }
        .padding()
    }
}
