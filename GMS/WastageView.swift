import SwiftUI
import CoreData

struct WastageView: View {
    @State private var wastageItems: [WastageItem] = []
    @State private var isLoading = false
    @State private var selectedFilter: WastageTimePeriod = .allTime
    @Environment(\.dismiss) var dismiss
    
    // CoreDataManager reference
    private let dataManager = CoreDataManager.shared

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "F8F9FA"), Color(hex: "E9ECEF")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                // Wastage Summary Card
                WastageSummaryCard()
                    .padding(.horizontal)
                
                // Filter options
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "All Time",
                            isSelected: selectedFilter == .allTime,
                            action: {
                                selectedFilter = .allTime
                                loadWastageItems()
                            }
                        )
                        
                        FilterChip(
                            title: "This Year",
                            isSelected: selectedFilter == .thisYear,
                            action: {
                                selectedFilter = .thisYear
                                loadWastageItems()
                            }
                        )
                        
                        FilterChip(
                            title: "This Month",
                            isSelected: selectedFilter == .thisMonth,
                            action: {
                                selectedFilter = .thisMonth
                                loadWastageItems()
                            }
                        )
                        
                        FilterChip(
                            title: "This Week",
                            isSelected: selectedFilter == .thisWeek,
                            action: {
                                selectedFilter = .thisWeek
                                loadWastageItems()
                            }
                        )
                    }
                    .padding(.horizontal)
                }

                if isLoading {
                    // Loading indicator
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if wastageItems.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "trash.slash")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "DC3545").opacity(0.7))
                        
                        Text("No Wasted Items")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Expired items will automatically appear here")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            checkForExpiredItems()
                        }) {
                            Label("Check for Expired Items", systemImage: "arrow.clockwise")
                                .padding()
                                .background(Color(hex: "DC3545"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Wastage List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(wastageItems) { item in
                                WastageItemCard(item: item)
                                    .contextMenu {
                                        Button(action: {
                                            if let id = UUID(uuidString: item.id) {
                                                deleteWastageItem(id: id)
                                            }
                                        }) {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        loadWastageItems()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Wastage List")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color(hex: "DC3545"))
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    checkForExpiredItems()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color(hex: "DC3545"))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadWastageItems()
        }
    }
    
    // Load wasted items from Core Data
    private func loadWastageItems() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let currentUser = dataManager.fetchCurrentUser() else {
                isLoading = false
                return
            }
            
            // Get wasted groceries from CoreData
            let wastedGroceries = dataManager.fetchWastedGroceries(for: currentUser)
            
            // Create wastage items from the fetched groceries
            self.wastageItems = wastedGroceries.map { grocery in
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                
                let expiryDateString = grocery.expiryDate != nil ?
                    formatter.string(from: grocery.expiryDate!) : "Unknown"
                
                let quantityString = "\(grocery.quantity) \(grocery.unit ?? "")"
                
                return WastageItem(
                    id: grocery.groceryid?.uuidString ?? UUID().uuidString,
                    name: grocery.name ?? "Unknown Item",
                    amount: quantityString.trimmingCharacters(in: .whitespaces),
                    expiryDate: expiryDateString,
                    category: grocery.category ?? "Other",
                    price: grocery.price
                )
            }
            
            isLoading = false
        }
    }
    
    // Check for any newly expired items
    private func checkForExpiredItems() {
        isLoading = true
        
        guard let currentUser = dataManager.fetchCurrentUser() else {
            isLoading = false
            return
        }
        
        // Check for expired items and mark them as wasted
        let count = dataManager.checkForExpiredGroceries(for: currentUser)
        
        if count > 0 {
            // Show a message or alert that items were moved
            // This is just a placeholder for actual alert implementation
            print("\(count) items were moved to wastage")
        }
        
        // Reload the wastage list
        loadWastageItems()
    }
    
    // Delete a wastage item
    private func deleteWastageItem(id: UUID) {
        guard let currentUser = dataManager.fetchCurrentUser() else { return }
        
        let wastedGroceries = dataManager.fetchWastedGroceries(for: currentUser)
        
        if let matchingGrocery = wastedGroceries.first(where: { $0.groceryid == id }) {
            dataManager.deleteGrocery(matchingGrocery)
            loadWastageItems() // Reload the list
        }
    }
}

// Updated WastageItem model with additional fields
struct WastageItem: Identifiable {
    let id: String
    let name: String
    let amount: String
    let expiryDate: String
    let category: String
    let price: Float
}

// Updated WastageSummaryCard that fetches real data
struct WastageSummaryCard: View {
    @State private var stats: (total: Int, thisMonth: Int, thisWeek: Int) = (0, 0, 0)
    @State private var totalValue: Float = 0.0
    
    private let dataManager = CoreDataManager.shared

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(Color(hex: "DC3545"))
                    .font(.title2)
                Text("Wastage Summary")
                    .font(.headline)
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    StatCard(
                        title: "Total Items",
                        value: "\(stats.total)",
                        icon: "number.circle.fill"
                    )

                    StatCard(
                        title: "This Month",
                        value: "\(stats.thisMonth)",
                        icon: "calendar.circle.fill"
                    )
                    
                    StatCard(
                        title: "This Week",
                        value: "\(stats.thisWeek)",
                        icon: "clock.fill"
                    )
                    
                    StatCard(
                        title: "Total Value",
                        value: "$\(String(format: "%.2f", totalValue))",
                        icon: "dollarsign.circle.fill"
                    )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onAppear {
            loadStats()
        }
    }
    
    private func loadStats() {
        guard let currentUser = dataManager.fetchCurrentUser() else { return }
        
        // Get wastage statistics
        stats = dataManager.getWastageStatistics(for: currentUser)
        
        // Get total value of wasted items
        totalValue = dataManager.getWastageValue(for: currentUser)
    }
}

// Filter Chip Component
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color(hex: "DC3545") : Color.white)
                .foregroundColor(isSelected ? Color.white : Color(hex: "DC3545"))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "DC3545"), lineWidth: 1)
                )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "DC3545"))
                .font(.title2)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: "DC3545").opacity(0.1))
        .cornerRadius(8)
    }
}

// Updated WastageItemCard to show category and price
struct WastageItemCard: View {
    let item: WastageItem
    
    // Get category icon
    private func getCategoryIcon(_ category: String) -> String {
        switch category.lowercased() {
        case "dairy":
            return "cup.and.saucer.fill"
        case "produce":
            return "leaf.fill"
        case "bakery":
            return "birthday.cake.fill"
        case "meat":
            return "flame.fill"
        case "frozen":
            return "snowflake"
        default:
            return "cart.fill"
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header with name and category
            HStack {
                HStack {
                    Image(systemName: getCategoryIcon(item.category))
                        .foregroundColor(Color(hex: "DC3545"))
                    Text(item.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                Spacer()
                Text("$\(String(format: "%.2f", item.price))")
                    .font(.headline)
                    .foregroundColor(Color(hex: "DC3545"))
            }
            
            Divider()
            
            // Item details
            HStack {
                Label {
                    Text(item.amount)
                        .foregroundColor(.gray)
                } icon: {
                    Image(systemName: "scalemass.fill")
                        .foregroundColor(Color(hex: "DC3545"))
                }

                Spacer()
                
                Label {
                    Text(item.expiryDate)
                        .foregroundColor(.gray)
                } icon: {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(Color(hex: "DC3545"))
                }
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct WastageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WastageView()
        }
    }
}
