import SwiftUI

struct SignUpView: View {
    @State private var username = ""
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    var body: some View {
         NavigationStack {
             ZStack {
                 // Background gradient stays the same
                 LinearGradient(
                     gradient: Gradient(colors: [Color(hex: "F8F9FA"), Color(hex: "E9ECEF")]),
                     startPoint: .top,
                     endPoint: .bottom
                 )
                 .ignoresSafeArea()
                 
                 // Remove ScrollView since we want it to fit without scrolling
                 VStack(spacing: 20) { // Reduced from 32
                     // Logo Section with reduced spacing
                     VStack(spacing: 8) { // Reduced from 16
                         // Grocery Cart Logo with smaller size
                         ZStack {
                             Circle()
                                 .fill(Color(hex: "198754").opacity(0.1))
                                 .frame(width: 80, height: 80) // Reduced from 120
                             
                             Image(systemName: "cart.circle.fill")
                                 .resizable()
                                 .scaledToFit()
                                 .frame(width: 50, height: 50) // Reduced from 80
                                 .foregroundColor(Color(hex: "198754"))
                         }
                         
                         Text("Grocee")
                             .font(.system(size: 28, weight: .bold)) // Reduced from 32
                             .foregroundColor(Color(hex: "198754"))
                         
                         Text("Create your account")
                             .font(.subheadline) // Changed from title3
                             .foregroundColor(.gray)
                     }
                     
                     // Sign Up Form with reduced spacing
                     VStack(spacing: 12) { // Reduced from 20
                         SignUpTextField(
                             title: "Username",
                             icon: "person.fill", text: $username
                         )
                         
                         SignUpTextField(
                             title: "Full Name",
                             icon: "person.text.rectangle.fill", text: $fullName
                         )
                         
                         SignUpTextField(
                             title: "Email",
                             icon: "envelope.fill", text: $email,
                             keyboardType: .emailAddress
                         )
                         
                         SignUpPasswordField(
                             title: "Password",
                             text: $password,
                             showPassword: $showPassword
                         )
                         
                         SignUpPasswordField(
                             title: "Confirm Password",
                             text: $confirmPassword,
                             showPassword: $showConfirmPassword
                         )
                         
                         // Sign Up Button
                         Button(action: {
                             // Sign up action
                         }) {
                             HStack {
                                 Image(systemName: "person.badge.plus.fill")
                                 Text("Create Account")
                                     .font(.headline) // Changed from title3
                                     .fontWeight(.semibold)
                             }
                             .frame(maxWidth: .infinity)
                             .padding(.vertical, 12) // Reduced padding
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
                                 // Navigate to sign in
                             }
                             .foregroundColor(Color(hex: "198754"))
                             .fontWeight(.semibold)
                         }
                         .padding(.top, 4) // Reduced from 8
                     }
                 }
                 .padding(16) // Reduced from 24
             }
         }
     }
 }

// Renamed TextField component for SignUp
struct SignUpTextField: View {
    let title: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.gray)
                .font(.subheadline)
            
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

// Renamed PasswordField component for SignUp
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

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
