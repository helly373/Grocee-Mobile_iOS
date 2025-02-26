import SwiftUI
import Charts

// Sample data models for demonstration
struct ExpiringItem: Identifiable {
    let id = UUID()
    let name: String
    let expirationDate: Date
    let icon: String // Added icon property for visual representation
    let color: Color // Added color property for visual distinction
}

struct CategoryWastage: Identifiable {
    let id = UUID()
    let category: String
    let wastageAmount: Double
    let icon: String // Added icon property
}

// Home page view that displays the top expiring items and wastage graph
struct HomePageView: View {
    // Sample data for expiring items and wastage with added visual properties
    let expiringItems: [ExpiringItem] = [
        ExpiringItem(name: "Yogurt", expirationDate: Date().addingTimeInterval(3600 * 24 * 1), icon: "cup.and.saucer.fill", color: .blue),
        ExpiringItem(name: "Milk", expirationDate: Date().addingTimeInterval(3600 * 24 * 2), icon: "drop.fill", color: .white),
        ExpiringItem(name: "Bread", expirationDate: Date().addingTimeInterval(3600 * 24 * 3), icon: "square.fill", color: .brown),
        ExpiringItem(name: "Cheese", expirationDate: Date().addingTimeInterval(3600 * 24 * 5), icon: "circle.fill", color: .yellow)
    ]
    
    let wastageData: [CategoryWastage] = [
        CategoryWastage(category: "Dairy", wastageAmount: 10, icon: "drop.fill"),
        CategoryWastage(category: "Bakery", wastageAmount: 5, icon: "birthday.cake.fill"),
        CategoryWastage(category: "Produce", wastageAmount: 8, icon: "leaf.fill")
    ]
    
    @State private var showProfile = false
    @State private var animateChart = false // For chart animation
    @State private var showItems = false // For item list animation

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    AnimatedHeroHeaderView()
                    
                    // Top 3 expiring items section with animation
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Expiring Soon")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(expiringItems.sorted(by: { $0.expirationDate < $1.expirationDate }).prefix(3).enumerated().map({ i, item in
                            (i, item)
                        }), id: \.1.id) { index, item in
                            HStack {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: item.icon)
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.subheadline)
                                        .bold()
                                    
                                    // Calculate days remaining
                                    let days = Calendar.current.dateComponents([.day], from: Date(), to: item.expirationDate).day ?? 0
                                    Text("\(days) day\(days == 1 ? "" : "s") remaining")
                                        .font(.caption)
                                        .foregroundColor(days <= 2 ? .red : .gray)
                                }
                                
                                Spacer()
                                
                                // Circular progress indicator
                                ZStack {
                                    // Calculate days remaining FIRST and store it in a local constant
                                    let days = Calendar.current.dateComponents([.day], from: Date(), to: item.expirationDate).day ?? 0
                                    
                                    Circle()
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                                        .frame(width: 40, height: 40)
                                    
                                    Circle()
                                        .trim(from: 0, to: min(1.0, Double(5 - days) / 5.0))
                                        .stroke(
                                            days <= 1 ? Color.red :
                                            days <= 3 ? Color.orange : Color.green,
                                            lineWidth: 4
                                        )
                                        .frame(width: 40, height: 40)
                                        .rotationEffect(.degrees(-90))
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            )
                            .padding(.horizontal)
                            .offset(x: showItems ? 0 : 300)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)
                                .delay(Double(index) * 0.1),
                                value: showItems
                            )
                        }
                    }
                    
                    // Graphical representation of wastage by category with animation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Food Waste Tracker")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(wastageData) { data in
                                BarMark(
                                    x: .value("Category", data.category),
                                    y: .value("Wastage", animateChart ? data.wastageAmount : 0)
                                )
                                .foregroundStyle(by: .value("Category", data.category))
                                .annotation(position: .top) {
                                    Image(systemName: data.icon)
                                        .foregroundColor(.gray)
                                        .scaleEffect(animateChart ? 1.0 : 0.5)
                                        .opacity(animateChart ? 1.0 : 0.0)
                                        .animation(.easeInOut(duration: 0.5).delay(0.5), value: animateChart)
                                }
                            }
                        }
                        .frame(height: 200)
                        .padding(.horizontal)
                        .animation(.easeOut(duration: 1.0), value: animateChart)
                    }
                    
                    // Food Savings Tips Section (New)
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Storage Tips")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                FoodTipCard(
                                    icon: "refrigerator.fill",
                                    title: "Fresh Longer",
                                    description: "Keep dairy on middle shelves, not in the door",
                                    color: Color.blue.opacity(0.2)
                                )
                                
                                FoodTipCard(
                                    icon: "thermometer.low",
                                    title: "Optimal Temp",
                                    description: "Set your fridge to 37°F (3°C) for optimal freshness",
                                    color: Color.green.opacity(0.2)
                                )
                                
                                FoodTipCard(
                                    icon: "freezer.fill",
                                    title: "Freeze Smart",
                                    description: "Freeze leftover bread to prevent mold",
                                    color: Color.purple.opacity(0.2)
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
                
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Leading toolbar with icon + title
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Image(systemName: "cart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color(hex: "4CAF50"))
                        Text("Grocee")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color(hex: "4CAF50"))
                    }
                }
                
                // Trailing toolbar for the profile button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(hex: "4CAF50"))
                    }
                }
            }
            .navigationDestination(isPresented: $showProfile) {
                ProfileView()
            }
            .onAppear {
                // Start animations when view appears
                withAnimation(.easeIn(duration: 0.6)) {
                    showItems = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        animateChart = true
                    }
                }
            }
        }
    }
}

// Enhanced Hero Header with animation
struct AnimatedHeroHeaderView: View {
    @State private var animateGradient = false
    @State private var animateIcon = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "4CAF50"),
                    animateGradient ? Color(hex: "8BC34A").opacity(0.8) : Color(hex: "2E7D32")
                ]),
                startPoint: animateGradient ? .topLeading : .topTrailing,
                endPoint: animateGradient ? .bottomTrailing : .bottomLeading
            )
            .cornerRadius(16)
            .padding()
            .onAppear {
                withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }

            // Decorative food items scattered in the background
            Group {
                Image(systemName: "apple.logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.white.opacity(0.3))
                    .offset(x: -100, y: -40)
                    .rotationEffect(.degrees(animateIcon ? 10 : -10))
                    .animation(.easeInOut(duration: 2).repeatForever(), value: animateIcon)
                
                Image(systemName: "carrot.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white.opacity(0.3))
                    .offset(x: 90, y: -60)
                    .rotationEffect(.degrees(animateIcon ? -15 : 15))
                    .animation(.easeInOut(duration: 2.5).repeatForever(), value: animateIcon)
                
                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.white.opacity(0.3))
                    .offset(x: -90, y: 40)
                    .rotationEffect(.degrees(animateIcon ? 15 : -15))
                    .animation(.easeInOut(duration: 3).repeatForever(), value: animateIcon)
                
                Image(systemName: "refrigerator.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white.opacity(0.3))
                    .offset(x: 80, y: 50)
                    .rotationEffect(.degrees(animateIcon ? -10 : 10))
                    .animation(.easeInOut(duration: 2.2).repeatForever(), value: animateIcon)
            }
            .onAppear {
                animateIcon = true
            }

            // Foreground content with animation
            VStack(spacing: 12) {
                Image(systemName: "leaf.arrow.circlepath")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.white)
                    .scaleEffect(animateIcon ? 1.1 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).repeatForever(autoreverses: true), value: animateIcon)
//                
//                Text("FreshKeeper")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                    .opacity(showTitle ? 1 : 0)
//                    .offset(y: showTitle ? 0 : 20)
//                
                Text("Reduce waste, save money")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(showSubtitle ? 1 : 0)
                    .offset(y: showSubtitle ? 0 : 10)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.7)) {
                    showTitle = true
                }
                
                withAnimation(.easeOut(duration: 0.7).delay(0.3)) {
                    showSubtitle = true
                }
            }
        }
        .frame(height: 220)
    }
}

// Component for food savings tips
struct FoodTipCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(color.opacity(0.8))
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(width: 180, height: 180)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .onHover { hovering in
            withAnimation(.spring()) {
                isHovered = hovering
            }
        }
    }
}


struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomePageView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // Use your existing AddGroceryView from another file
            AddGroceryView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
                .tag(1)
            
            // Use your existing GroceryListView from another file
            GroceryListView()
                .tabItem {
                    Label("Inventory", systemImage: "list.bullet.circle.fill")
                }
                .tag(2)
            
            // Use your existing WastageView from another file
            WastageView()
                .tabItem {
                    Label("Insights", systemImage: "chart.pie.fill")
                }
                .tag(3)
        }
        .onChange(of: selectedTab) { newValue in
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
    }
}

// Preview provider for the MainTabView
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
