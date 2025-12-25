import SwiftUI
import CoreLocation

struct OnboardingView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var step = 1
    @State private var location = ""
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.97, blue: 1.0), .white]),
                           startPoint: .top,
                           endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Progress Indicator
                HStack(spacing: 8) {
                    ForEach(1...2, id: \.self) { num in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(num <= step ? Color.blue : Color.gray.opacity(0.2))
                            .frame(width: num == step ? 32 : 32, height: 6)
                            .animation(.spring(), value: step)
                    }
                }
                .padding(.top, 20)
                
                // MARK: - Content Area
                VStack(alignment: .leading, spacing: 0) {
                    if step == 1 {
                        nameStep
                    } else {
                        locationStep
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                
                Spacer()
                
                // MARK: - Bottom Button
                Button(action: {
                    if step == 1 {
                        step = 2
                    } else {
                        completeOnboarding()
                    }
                }) {
                    Text(step == 1 ? "Continue" : "Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(isButtonDisabled ? Color.blue.opacity(0.5) : Color.blue)
                        .cornerRadius(16)
                }
                .disabled(isButtonDisabled)
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
    }
    
    // MARK: - Sub-Steps
    
    private var nameStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Let's get to know you")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.black)
            
            Text("Your name helps us personalize your experience.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 40)
            
            Text("Full Name")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "person")
                    .foregroundColor(.gray)
                TextField("Enter your full name", text: $viewModel.fullname)
                    .foregroundColor(.black)
            }
            .padding()
            .frame(height: 56)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        }
    }
    
    private var locationStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Where is home?")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.black)
            
            Text("Tell us your preferred city so we can find the best rooms near you.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 40)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search for a city", text: $location)
                    .foregroundColor(.black)
            }
            .padding()
            .frame(height: 56)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            
            Button(action: {
                self.location = "Current Location"
                // In a real app, you'd trigger CoreLocation here
            }) {
                HStack {
                    Image(systemName: "location.fill")
                    Text("Use Current Location")
                }
                .font(.headline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.white)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            }
            .padding(.top, 10)
        }
    }
    
    private var isButtonDisabled: Bool {
        if step == 1 { return viewModel.fullname.isEmpty }
        return location.isEmpty
    }
    
    private func completeOnboarding() {
        if var updatedUser = viewModel.currentUser {
                updatedUser.fullname = viewModel.fullname
                viewModel.currentUser = updatedUser
            }
        viewModel.saveUserToFirestore(viewModel.currentUser!)
        withAnimation {
            viewModel.completedOnboarding = true
        }
    }
}
