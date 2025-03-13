import SwiftUI

struct SignUpView: View {
    @State private var username = ""
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var navigateToHome = false
    @State private var navigateToLogin = false
    @State private var navigateToForgotPassword = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "F8F9FA"), Color(hex: "E9ECEF")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Logo Section
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "198754").opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "cart.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color(hex: "198754"))
                    }
                    
                    Text("Grocee")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "198754"))
                    
                    Text("Create your account")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Sign Up Form
                VStack(spacing: 12) {
                    SignUpTextField(title: "Username", icon: "person.fill", text: $username)
                    SignUpTextField(title: "Full Name", icon: "person.text.rectangle.fill", text: $fullName)
                    SignUpTextField(title: "Email", icon: "envelope.fill", text: $email, keyboardType: .emailAddress)
                        .autocapitalization(.none) // Prevents auto-capitalization
                        .textInputAutocapitalization(.never) // Ensures the first letter isn't capitalized
                        .onChange(of: email) { newValue in
                            email = newValue.lowercased() // Ensures all input is in lowercase
                        }

                    SignUpPasswordField(title: "Password", text: $password, showPassword: $showPassword)
                    SignUpPasswordField(title: "Confirm Password", text: $confirmPassword, showPassword: $showConfirmPassword)

                    // Error Message Display
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }

                    
                    // Create Account Button
                    Button(action: createAccount) {
                        HStack {
                            Image(systemName: "person.badge.plus.fill")
                            Text("Create Account")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "198754"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color(hex: "198754").opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    
                    // Sign In Link
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.gray)
                        Button("Sign In") {
                            navigateToLogin = true
                        }
                        .foregroundColor(Color(hex: "198754"))
                        .fontWeight(.semibold)
                    }
                    .padding(.top, 4)
                    
                    // Navigation Links (Hidden)
                    NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true), isActive: $navigateToHome) { EmptyView() }
                    NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true), isActive: $navigateToLogin) { EmptyView() }
                    
                }
            }
            .padding(16)
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Save User to Core Data
    func createAccount() {
        guard !username.isEmpty, !fullName.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "All fields are required!"
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match!"
            return
        }

        // Check if email already exists in Core Data
        if CoreDataManager.shared.fetchUser(byEmail: email) != nil {
            errorMessage = "Email already exists. Try a different one."
            return
        }

        // Attempt to save the user
        let success = CoreDataManager.shared.saveUser(username: username, fullName: fullName, email: email, password: password)
        
        if success {
            navigateToHome = true
        } else {
            errorMessage = "Failed to create an account. Try again."
        }
    }
}

// Custom TextField for Sign Up
struct SignUpTextField: View {
    let title: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).foregroundColor(.gray).font(.subheadline)
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "198754"))
                    .frame(width: 24)
                
                TextField(title, text: $text)
                    .keyboardType(keyboardType)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "198754").opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// Custom Password Field for Sign Up
struct SignUpPasswordField: View {
    let title: String
    @Binding var text: String
    @Binding var showPassword: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.gray)
                .font(.subheadline)
            
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(Color(hex: "198754"))
                    .frame(width: 24)
                
                if showPassword {
                    TextField(title, text: $text)
                } else {
                    SecureField(title, text: $text)
                }
                
                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(Color(hex: "198754"))
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "198754").opacity(0.2), lineWidth: 1)
            )
        }
    }
}


// Preview
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignUpView()
        }
    }
}
