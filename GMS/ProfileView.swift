import SwiftUI

struct ProfileView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var selectedDiet = "None"
    @State private var showingLogoutAlert = false
    @State private var navigateToLanding = false
    @State private var showingSaveConfirmation = false
    
    let dietOptions = ["None", "Vegetarian", "Vegan", "Keto", "Paleo", "Gluten-Free"]
    
    @StateObject private var coreDataManager = CoreDataManager.shared
    private var user: User?

    init() {
        if let fetchedUser = CoreDataManager.shared.fetchCurrentUser() {
            _username = State(initialValue: fetchedUser.username ?? "")
            _fullName = State(initialValue: fetchedUser.fullName ?? "")
            _email = State(initialValue: fetchedUser.email ?? "")
            _password = State(initialValue: fetchedUser.password ?? "")
            _selectedDiet = State(initialValue: fetchedUser.dietPreference ?? "None")
            user = fetchedUser
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "F8F9FA"), Color(hex: "E9ECEF")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    ProfileHeader(fullName: fullName, username: username)

                    VStack(spacing: 20) {
                        ProfileSection(title: "Personal Information") {
                            CustomTextField(title: "Username", icon: "person.circle.fill", text: $username)
                            CustomTextField(title: "Full Name", icon: "person.text.rectangle.fill", text: $fullName)
                            CustomTextField(title: "Email", icon: "envelope.fill", text: $email, keyboardType: .emailAddress)
                            CustomSecureField(title: "Password", icon: "lock.fill", text: $password)
                        }

                        ProfileSection(title: "Diet Preferences") {
                            CustomPicker(title: "Select Diet", selection: $selectedDiet, options: dietOptions, icon: "leaf.fill")
                        }

                        VStack(spacing: 16) {
                            Button(action: saveProfile) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down.fill")
                                    Text("Save Changes")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "198754"))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(color: Color(hex: "198754").opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                            .alert("Profile Updated", isPresented: $showingSaveConfirmation) {
                                Button("OK", role: .cancel) { }
                            } message: {
                                Text("Your profile has been successfully updated.")
                            }

                            Button(action: {
                                showingLogoutAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                    Text("Sign Out")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "DC3545"))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(color: Color(hex: "DC3545").opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                isLoggedIn = false
                navigateToLanding = true
                print("User logged out. isLoggedIn = \(isLoggedIn)")
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .background(
            NavigationLink(destination: LandingView().navigationBarBackButtonHidden(true), isActive: $navigateToLanding) {
                EmptyView()
            }
        )
        .navigationBarTitle("Profile", displayMode: .inline)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: { dismiss() }) {
//                    HStack {
//                        Image(systemName: "chevron.left")
//                        Text("Back")
//                    }
//                }
//            }
//        }
    }

    func saveProfile() {
        guard let user = user else { return }
        let success = coreDataManager.updateUserProfile(
            user: user,
            username: username,
            fullName: fullName,
            email: email,
            password: password,
            dietPreference: selectedDiet
        )

        if success {
            showingSaveConfirmation = true
        }
    }
}


// Subviews used in ProfileView remain unchanged
struct ProfileHeader: View {
    let fullName: String
    let username: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(Color(hex: "198754"))

            VStack(spacing: 4) {
                Text(fullName)
                    .font(.title2)
                    .fontWeight(.bold)

                Text("@\(username)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

struct ProfileSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color(hex: "198754"))
            content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct CustomTextField: View {
    let title: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "198754"))
                    .frame(width: 24)
                TextField(title, text: $text)
                    .keyboardType(keyboardType)
            }
            .padding()
            .background(Color(hex: "F8F9FA"))
            .cornerRadius(8)
        }
    }
}

struct CustomSecureField: View {
    let title: String
    let icon: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "198754"))
                    .frame(width: 24)
                SecureField(title, text: $text)
            }
            .padding()
            .background(Color(hex: "F8F9FA"))
            .cornerRadius(8)
        }
    }
}

struct CustomPicker: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "198754"))
                .frame(width: 24)
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
        .padding()
        .background(Color(hex: "F8F9FA"))
        .cornerRadius(8)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
        }
    }
}
