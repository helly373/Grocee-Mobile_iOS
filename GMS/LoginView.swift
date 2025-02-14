import SwiftUI

struct LoginView: View {
   @State private var email = ""
   @State private var password = ""
   @State private var showPassword = false
   
   var body: some View {
       NavigationStack {
           ZStack {
               // Background gradient
               LinearGradient(
                   gradient: Gradient(colors: [Color(hex: "F8F9FA"), Color(hex: "E9ECEF")]),
                   startPoint: .top,
                   endPoint: .bottom
               )
               .ignoresSafeArea()
               
               ScrollView {
                   VStack(spacing: 32) {
                       // Logo Section
                       VStack(spacing: 16) {
                           // Grocery Cart Logo
                           ZStack {
                               Circle()
                                   .fill(Color(hex: "198754").opacity(0.1))
                                   .frame(width: 120, height: 120)
                               
                               Image(systemName: "cart.circle.fill")
                                   .resizable()
                                   .scaledToFit()
                                   .frame(width: 80, height: 80)
                                   .foregroundColor(Color(hex: "198754"))
                           }
                           
                           Text("Grocee")
                               .font(.system(size: 32, weight: .bold))
                               .foregroundColor(Color(hex: "198754"))
                           
                           Text("Welcome Back")
                               .font(.title3)
                               .foregroundColor(.gray)
                       }
                       
                       // Login Form
                       VStack(spacing: 20) {
                           // Email Field
                           LoginTextField(
                               title: "Email",
                               icon: "envelope.fill", text: $email,
                               keyboardType: .emailAddress
                           )
                           
                           // Password Field
                           LoginPasswordField(
                               title: "Password",
                               text: $password,
                               showPassword: $showPassword
                           )
                           
                           // Forgot Password
                           HStack {
                               Spacer()
                               Button("Forgot Password?") {
                                   // Forgot password action
                               }
                               .foregroundColor(Color(hex: "198754"))
                               .font(.subheadline)
                           }
                           
                           // Login Button
                           Button(action: {
                               // Login action
                           }) {
                               HStack {
                                   Image(systemName: "arrow.right.circle.fill")
                                   Text("Login")
                                       .font(.title3)
                                       .fontWeight(.semibold)
                               }
                               .frame(maxWidth: .infinity)
                               .padding()
                               .background(Color(hex: "198754"))
                               .foregroundColor(.white)
                               .cornerRadius(12)
                               .shadow(color: Color(hex: "198754").opacity(0.3), radius: 5, x: 0, y: 3)
                           }
                           .padding(.top, 8)
                           
                           // Sign Up Link
                           HStack {
                               Text("Don't have an account?")
                                   .foregroundColor(.gray)
                               Button("Sign Up") {
                                   // Navigate to sign up
                               }
                               .foregroundColor(Color(hex: "198754"))
                               .fontWeight(.semibold)
                           }
                           .padding(.top, 8)
                       }
                   }
                   .padding(24)
               }
           }
       }
   }
}

// Custom TextField for Login
struct LoginTextField: View {
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

// Custom Password Field for Login
struct LoginPasswordField: View {
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

struct LoginView_Previews: PreviewProvider {
   static var previews: some View {
       LoginView()
   }
}
