import SwiftUI

struct SignUpView: View {
    @State private var username = ""
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var navigateToHome = false  // For successful account creation
    @State private var navigateToLogin = false // For "Sign In" navigation
    
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
                     
                     // Create Account Button
                     Button(action: {
                         // Simulate a successful account creation
                         navigateToHome = true
                     }) {
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
                             // Instead of dismissing, navigate to LoginView
                             navigateToLogin = true
                         }
                         .foregroundColor(Color(hex: "198754"))
                         .fontWeight(.semibold)
                     }
                     .padding(.top, 4)
                 }
             }
             .padding(16)
         }
         .navigationTitle("Sign Up")
         .navigationBarTitleDisplayMode(.inline)
         // NavigationLink for programmatic navigation to HomePageView (after account creation)
         .background(
             NavigationLink(destination: HomePageView().navigationBarBackButtonHidden(true), isActive: $navigateToHome) {
                 EmptyView()
             }
         )
         // NavigationLink for programmatic navigation to LoginView (when "Sign In" tapped)
         .background(
             NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true), isActive: $navigateToLogin) {
                 EmptyView()
             }
         )
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

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignUpView()
        }
    }
}
