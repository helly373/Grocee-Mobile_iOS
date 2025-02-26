import SwiftUI

// Grocery Item Model with Category
struct GroceryItem: Identifiable {
    let id = UUID()
    let name: String
    var quantity: String  // Editable quantity
    let price: String
    let category: String  // Added category property
    let purchasedDate: Date
    var expiryDate: Date  // Editable expiry date
}

// Sample Grocery Data with Categories
let sampleGroceries = [
    GroceryItem(name: "Milk", quantity: "2", price: "$5.99", category: "Dairy", purchasedDate: Date(), expiryDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!),
    GroceryItem(name: "Eggs", quantity: "12", price: "$3.49", category: "Dairy", purchasedDate: Date(), expiryDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!),
    GroceryItem(name: "Cheddar Cheese", quantity: "1", price: "$4.29", category: "Dairy", purchasedDate: Date(), expiryDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!),
    GroceryItem(name: "Bread", quantity: "1", price: "$2.99", category: "Bakery", purchasedDate: Date(), expiryDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!),
    GroceryItem(name: "Bagels", quantity: "6", price: "$3.99", category: "Bakery", purchasedDate: Date(), expiryDate: Calendar.current.date(byAdding: .day, value: 4, to: Date())!),
    GroceryItem(name: "Apples", quantity: "5", price: "$4.50", category: "Produce", purchasedDate: Date(), expiryDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!),
    GroceryItem(name: "Spinach", quantity: "1", price: "$2.99", category: "Produce", purchasedDate: Date(), expiryDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!)
]

struct GroceryListView: View {
    @State private var groceries = sampleGroceries
    @State private var searchText = ""
    @State private var showingEditSheet = false
    @State private var selectedItem: GroceryItem?
    @State private var editedQuantity = ""
    @State private var editedExpiryDate = Date()
    @State private var selectedCategory: String? = nil
    
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
                                                    if let index = groceries.firstIndex(where: { $0.id == item.id }) {
                                                        groceries.remove(at: index)
                                                    }
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
                    if let index = groceries.firstIndex(where: { $0.id == selectedItem?.id }) {
                        groceries[index].quantity = quantity
                        groceries[index].expiryDate = expiryDate
                    }
                    showingEditSheet = false
                }
            )
        }
    }
}

// New struct for Category Header
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

// New struct for Category Filter Chips
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

struct EditGrocerySheet: View {
    let item: GroceryItem?
    @Binding var quantity: String
    @Binding var expiryDate: Date
    let onSave: (String, Date) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Details")) {
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                    DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Edit \(item?.name ?? "Item")")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { onSave(quantity, expiryDate) }
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
        }
    }
}
