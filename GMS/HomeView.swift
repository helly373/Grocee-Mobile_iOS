import SwiftUI

struct HomePageView: View {
    @State private var showProfile = false
    @State private var navigateToHome = false
    @State private var navigateToSignUp = false

    var body: some View {
        NavigationStack {  // ✅ Ensure everything is inside NavigationStack
            VStack(spacing: 32) {
                // Welcome image
                Image(systemName: "cart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color(hex: "198754"))
                    .padding(.top, 40)
                
                // Main navigation buttons
                VStack(spacing: 20) {
                    NavigationLink(destination: AddGroceryView()) {  // ✅ Updated for iOS 16
                        NavigationButton(
                            title: "Add Grocery",
                            icon: "plus.circle.fill",
                            color: Color(hex: "198754")
                        )
                    }
                    
                    NavigationLink(destination: GroceryListView()) {  // ✅ Updated
                        NavigationButton(
                            title: "View Grocery",
                            icon: "list.bullet.circle.fill",
                            color: Color(hex: "0D6EFD")
                        )
                    }
                    
                    NavigationLink(destination: WastageView()) {  // ✅ Updated
                        NavigationButton(
                            title: "Wastage",
                            icon: "trash.circle.fill",
                            color: Color(hex: "DC3545")
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Leading title
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Grocee")
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color(hex: "198754"))
                }

                // Profile button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showProfile = true
                    }) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(hex: "198754"))
                    }
                }
            }
            // ✅ Use `navigationDestination` instead of old `NavigationLink`
            .navigationDestination(isPresented: $showProfile) {
                ProfileView()
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomePageView()
            }
            .navigationDestination(isPresented: $navigateToSignUp) {
                SignUpView()
            }
        }
    }
}

// ✅ Button style component
struct NavigationButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
        )
    }
}

// ✅ Preview
struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomePageView()
        }
    }
}

