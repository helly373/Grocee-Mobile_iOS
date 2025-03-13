import SwiftUI
import CoreData

// Keep the original GroceryItem model as a view model
struct GroceryItem: Identifiable {
    let id = UUID()
    let name: String
    var quantity: String  // Editable quantity
    let price: String
    let category: String  // Added category property
    let purchasedDate: Date
    var expiryDate: Date  // Editable expiry date
}

// Extension to convert CoreData Grocery to GroceryItem view model
extension Grocery {
    func toGroceryItem() -> GroceryItem {
        return GroceryItem(
            name: self.name ?? "Unknown",
            quantity: "\(self.quantity)",
            price: "$\(String(format: "%.2f", self.price))",
            category: self.category ?? "Other", // Add a category property to CoreData model
            purchasedDate: self.purchasedDate ?? Date(),
            expiryDate: self.expiryDate ?? Date()
        )
    }
}

struct GroceryListView: View {
    @State private var groceries: [GroceryItem] = []
    @State private var searchText = ""
    @State private var showingEditSheet = false
    @State private var selectedItem: GroceryItem?
    @State private var editedQuantity = ""
    @State private var editedExpiryDate = Date()
    @State private var selectedCategory: String? = nil
    
    // Environment object to access CoreDataManager
    @Environment(\.managedObjectContext) private var viewContext
    
    // Initialize with observed object
    @ObservedObject private var dataManager = CoreDataManager.shared
    
    // Get unique categories from grocery items
    var categories: [String] {
        Array(Set(groceries.map { $0.category })).sorted()
    }
    
    // Filter groceries based on search text and selected category
    var filteredGroceries: [String: [GroceryItem]] {
        let filtered = groceries.filter {
            searchText.isEmpty ? true : $0.name.localizedCaseInsensitiveContains(searchText)
        }
        
        if let selectedCategory = selectedCategory {
            let categoryItems = filtered.filter { $0.category == selectedCategory }
            return [selectedCategory: categoryItems]
        } else {
            // Group by category
            return Dictionary(grouping: filtered, by: { $0.category })
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "F8F9FA"), Color(hex: "E9ECEF")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 8) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(hex: "0D6EFD"))
                    TextField("Search groceries...", text: $searchText)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Category filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(
                            title: "All",
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )
                        
                        ForEach(categories, id: \.self) { category in
                            CategoryChip(
                                title: category,
                                isSelected: selectedCategory == category,
                                action: {
                                    selectedCategory = (selectedCategory == category) ? nil : category
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                ScrollView {
                    LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
                        ForEach(filteredGroceries.keys.sorted(), id: \.self) { category in
                            if let items = filteredGroceries[category], !items.isEmpty {
                                Section(header: CategoryHeader(title: category)) {
                                    ForEach(items) { item in
                                        GroceryItemCard(item: item)
                                            .contextMenu {
                                                Button(action: {
                                                    selectedItem = item
                                                    editedQuantity = item.quantity
                                                    editedExpiryDate = item.expiryDate
                                                    showingEditSheet = true
                                                }) {
                                                    Label("Edit", systemImage: "pencil")
                                                }
                                                
                                                Button(role: .destructive, action: {
                                                    deleteGroceryItem(matching: item)
                                                }) {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Grocery List")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color(hex: "0D6EFD"))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        // Sort by name action
                    }) {
                        Label("Sort by Name", systemImage: "arrow.up.arrow.down")
                    }
                    Button(action: {
                        // Sort by expiry action
                    }) {
                        Label("Sort by Expiry", systemImage: "calendar")
                    }
                    Button(action: {
                        // Sort by category action
                    }) {
                        Label("Sort by Category", systemImage: "folder")
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(Color(hex: "0D6EFD"))
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditGrocerySheet(
                item: selectedItem,
                quantity: $editedQuantity,
                expiryDate: $editedExpiryDate,
                onSave: { quantity, expiryDate in
                    updateGroceryItem(
                        matching: selectedItem!,
                        newQuantity: quantity,
                        newExpiryDate: expiryDate
                    )
                    showingEditSheet = false
                }
            )
        }
        .onAppear {
            loadGroceries()
        }
    }
    
    // Function to load groceries from Core Data
    private func loadGroceries() {
        guard let currentUser = dataManager.fetchCurrentUser() else {
            print("No current user found")
            return
        }
        
        let coreDataGroceries = dataManager.fetchGroceries(for: currentUser)
        self.groceries = coreDataGroceries.map { $0.toGroceryItem() }
    }
    
    // Function to delete grocery item
    private func deleteGroceryItem(matching item: GroceryItem) {
        guard let currentUser = dataManager.fetchCurrentUser() else { return }
        
        let coreDataGroceries = dataManager.fetchGroceries(for: currentUser)
        
        // Find matching grocery in Core Data items by name and dates
        if let matchingGrocery = coreDataGroceries.first(where: {
            $0.name == item.name &&
            $0.purchasedDate == item.purchasedDate &&
            $0.expiryDate == item.expiryDate
        }) {
            dataManager.deleteGrocery(matchingGrocery)
            loadGroceries() // Reload the list
        }
    }
    
    // Function to update grocery item
    private func updateGroceryItem(matching item: GroceryItem, newQuantity: String, newExpiryDate: Date) {
        guard let currentUser = dataManager.fetchCurrentUser() else { return }
        
        let coreDataGroceries = dataManager.fetchGroceries(for: currentUser)
        
        // Find matching grocery in Core Data items
        if let matchingGrocery = coreDataGroceries.first(where: {
            $0.name == item.name &&
            $0.purchasedDate == item.purchasedDate
        }) {
            // Convert the string quantity to Double
            let quantityDouble = Double(newQuantity) ?? matchingGrocery.quantity
            
            dataManager.updateGrocery(
                grocery: matchingGrocery,
                name: matchingGrocery.name ?? "",
                expiryDate: newExpiryDate,
                price: matchingGrocery.price,
                purchasedDate: matchingGrocery.purchasedDate ?? Date(),
                quantity: quantityDouble,
                unit: matchingGrocery.unit ?? ""
            )
            
            loadGroceries() // Reload the list
        }
    }
}

// Keep the rest of the UI components unchanged
struct CategoryHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(Color(hex: "0D6EFD"))
                .padding(.vertical, 8)
            Spacer()
        }
        .padding(.horizontal, 4)
        .background(Color(hex: "F8F9FA").opacity(0.95))
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color(hex: "0D6EFD") : Color.white)
                .foregroundColor(isSelected ? Color.white : Color(hex: "0D6EFD"))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "0D6EFD"), lineWidth: 1)
                )
        }
    }
}

//struct EditGrocerySheet: View {
//    let item: GroceryItem?
//    @Binding var quantity: String
//    @Binding var expiryDate: Date
//    let onSave: (String, Date) -> Void
//    @Environment(\.dismiss) var dismiss
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Edit Details")) {
//                    TextField("Quantity", text: $quantity)
//                        .keyboardType(.numberPad)
//                    DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
//                }
//            }
//            .navigationTitle("Edit \(item?.name ?? "Item")")
//            .navigationBarItems(
//                leading: Button("Cancel") { dismiss() },
//                trailing: Button("Save") { onSave(quantity, expiryDate) }
//            )
//        }
//    }
//}
struct EditGrocerySheet: View {
    let item: GroceryItem?
    @Binding var quantity: String
    @Binding var expiryDate: Date
    let onSave: (String, Date) -> Void
    @Environment(\.dismiss) var dismiss
    
    // Convert the current quantity to Double
    var currentQuantity: Double {
        return Double(quantity) ?? 0.0
    }
    
    // Store the original quantity so that each decrement subtracts 25% of it.
    @State private var originalQuantity: Double? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Details")) {
                    // Display current quantity and a button to decrement it
                    HStack {
                        Text("Quantity:")
                        Spacer()
                        Text("\(currentQuantity, specifier: "%.2f")")
                        Button(action: {
                            // Set originalQuantity on first decrement if not already set
                            if originalQuantity == nil {
                                originalQuantity = currentQuantity
                            }
                            // Calculate 25% of the original quantity (or current if original isn't set)
                            let base = originalQuantity ?? currentQuantity
                            let decrement = base * 0.25
                            let newQuantity = currentQuantity - decrement
                            // Ensure quantity does not go below zero
                            quantity = String(format: "%.2f", max(newQuantity, 0))
                        }) {
                            Text("Decrease by 25%")
                        }
                    }
                    
                    // DatePicker for expiry date that only allows dates from today forward
                    DatePicker("Expiry Date", selection: $expiryDate, in: Date()..., displayedComponents: .date)
                }
            }
            .navigationTitle("Edit \(item?.name ?? "Item")")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    onSave(quantity, expiryDate)
                }
            )
        }
    }
}

struct GroceryItemCard: View {
    let item: GroceryItem
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with name and price
            HStack {
                HStack {
                    Image(systemName: getCategoryIcon(item.category))
                        .foregroundColor(Color(hex: "0D6EFD"))
                    Text(item.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                Spacer()
                Text(item.price)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "0D6EFD"))
            }
            Divider()
            // Quantity and date information
            VStack(spacing: 8) {
                HStack {
                    ItemInfoView(icon: "number.circle.fill", title: "Quantity", value: item.quantity)
                    Spacer()
                    ItemInfoView(icon: "calendar.circle.fill", title: "Purchased", value: formattedDate(item.purchasedDate))
                }
                HStack {
                    Spacer()
                    ItemInfoView(
                        icon: "exclamationmark.circle.fill",
                        title: "Expires",
                        value: formattedDate(item.expiryDate),
                        valueColor: isNearExpiry(item.expiryDate) ? Color.red : .primary
                    )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Return appropriate icon based on category
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
        case "canned goods":
            return "cylinder.fill"
        case "beverages":
            return "wineglass.fill"
        case "snacks":
            return "popcorn.fill"
        default:
            return "cart.fill"
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func isNearExpiry(_ date: Date) -> Bool {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return days <= 3
    }
}

struct ItemInfoView: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "0D6EFD"))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(valueColor)
            }
        }
    }
}



struct GroceryListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GroceryListView()
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
        }
    }
}
