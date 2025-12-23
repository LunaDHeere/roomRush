import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Welcome!")
                .font(.largeTitle)
                .bold()
            
            Text("The sign up/login worked!")
                .font(.headline)
                .foregroundColor(.gray)
            
            Button("Sign Out") {
                viewModel.signOut()
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
    }
}
