import SwiftUI

struct LandingView: View {
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
                
                VStack(spacing: 30) {
                    // App logo
                    Image(systemName: "cart.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(Color(hex: "198754"))
                    
                    // App Name
                    Text("Grocee")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color(hex: "198754"))
                    
                    // Team number
                    Text("Team 33")
                        .font(.title2)
                        .foregroundColor(Color(hex: "198754"))
                    
                    // Group Members
                    VStack(spacing: 4) {
                        Text("Members:")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Bhatti, Nisarg")
                        Text("Chauhan, Helly Prakashkumar")
                        Text("Chávez Solares, Fernando")
                        Text("Mavani, Kashyap")
                    }
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "495057"))
                    
                    Spacer()
                    
                    // Login and Sign Up buttons
                    VStack(spacing: 16) {
                        NavigationLink(destination: LoginView()) {
                            Text("Login")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "198754"))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        NavigationLink(destination: SignUpView()) {
                            Text("Sign Up")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "0D6EFD"))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}


struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
