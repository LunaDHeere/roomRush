import SwiftUI
import Combine

struct OnboardingView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject var locationManager = LocationManager()
    @State private var step = 1
    @State private var location = ""
    
    var body: some View {
        ZStack {
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
    
    private var nameStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Let's get to know you")
                .font(.system(size: 32, weight: .semibold))
            
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
                locationManager.requestLocation()
            }) {
                HStack {
                    // FIX: Removed $ from locationManager checks
                    if locationManager.city.isEmpty && !locationManager.isLoading {
                        Image(systemName: "location.fill")
                        Text("Use Current Location")
                    } else if !locationManager.city.isEmpty {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Found: \(locationManager.city)")
                    } else {
                        ProgressView()
                            .padding(.trailing, 5)
                        Text("Locating...")
                    }
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
        .onChange(of: locationManager.city) { oldValue, newCity in
            if !newCity.isEmpty {
                self.location = newCity
            }
        }
    }
    
    private var isButtonDisabled: Bool {
        if step == 1 { return viewModel.fullname.isEmpty }
        // Let them continue if they typed manually OR if GPS found something
        return location.isEmpty && locationManager.city.isEmpty
    }
    
    private func completeOnboarding() {
        if var updatedUser = viewModel.currentUser {
            updatedUser.fullname = viewModel.fullname
            updatedUser.city = self.location
            updatedUser.hasCompletedOnboarding = true
            viewModel.currentUser = updatedUser
            viewModel.saveUserToFirestore(updatedUser)
        }
        withAnimation {
            viewModel.completedOnboarding = true
        }
    }
}
