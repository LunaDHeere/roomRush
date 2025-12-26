import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var isSignUp = false
    @State private var showPassword = false
    
    var body: some View {
        NavigationStack{
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.97, blue: 1.0), .white]),
                               startPoint: .top,
                               endPoint: .bottom)
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        
                        // Logo/Brand Area
                        VStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.blue)
                                    .frame(width: 64, height: 64)
                                
                                Image(systemName: "bed.double.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 4) {
                                Text("roomRush")
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundColor(.gray.opacity(0.9))
                                
                                Text("Find your room, right now")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 60)
                        
                        // Form Fields
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Image(systemName: "envelope")
                                        .foregroundColor(.gray)
                                    TextField("your@email.com", text: $viewModel.email)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .foregroundColor(.black)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Image(systemName: "lock")
                                        .foregroundColor(.gray)
                                    Group{
                                        if showPassword {
                                            TextField("••••••••", text: $viewModel.password)
                                        } else {
                                            SecureField("••••••••", text: $viewModel.password)
                                        }
                                    }
                                    .foregroundColor(.black)
                                    .disableAutocorrection(true)
                                    
                                    Button(action: { showPassword.toggle() }) {
                                        Image(systemName: showPassword ? "eye.slash" : "eye")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            }
                            
                            if !isSignUp {
                                Button("Forgot password?") {
                                    // Action
                                }
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        
                        // Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                isSignUp ? viewModel.signUp() : viewModel.signIn()
                            }) {
                                Text(isSignUp ? "Create Account" : "Sign In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                            
                            Button(action: { /* Guest logic */ }) {
                                Text("Continue as Guest")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            }
                        }
                        
                        // Error Message
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        // Footer
                        Button(action: { isSignUp.toggle() }) {
                            HStack {
                                Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                Text(isSignUp ? "Sign In" : "Sign up")
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 24)
                }
                
            }
        }
    }
}
