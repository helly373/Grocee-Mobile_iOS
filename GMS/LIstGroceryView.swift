import SwiftUI

// Grocery Item Model
struct GroceryItem: Identifiable {
    let id = UUID()
    let name: String
    var quantity: String  // Changed to var for editing
    let price: String
    let purchasedDate: Date
    var expiryDate: Date  // Changed to var for editing
}

// Sample Grocery Data
let sampleGroceries = [
    GroceryItem(name: "Milk", quantity: "2", price: "$5.99", purchasedDate: Date(), expiryDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!),
    GroceryItem(name: "Eggs", quantity: "12", price: "$3.49", purchasedDate: Date(), expiryDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!),
    GroceryItem(name: "Bread", quantity: "1", price: "$2.99", purchasedDate: Date(), expiryDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!)
]

struct GroceryListView: View {
    @State private var groceries = sampleGroceries
    @State private var searchText = ""
    @State private var showingEditSheet = false
    @State private var selectedItem: GroceryItem?
    @State private var editedQuantity = ""
    @State private var editedExpiryDate = Date()
    
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
                
                VStack {
                    // Search bar
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
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach($groceries) { $item in
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
                            // Sort by name
                        }) {
                            Label("Sort by Name", systemImage: "arrow.up.arrow.down")
                        }
                        
                        Button(action: {
                            // Sort by expiry
                        }) {
                            Label("Sort by Expiry", systemImage: "calendar")
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
                leading: Button("Cancel") {
                    dismiss()
                },
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
                    Image(systemName: "cart.fill")
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
            
            // Quantity and dates
            VStack(spacing: 8) {
                HStack {
                    ItemInfoView(
                        icon: "number.circle.fill",
                        title: "Quantity",
                        value: item.quantity
                    )
                    
                    Spacer()
                    
                    ItemInfoView(
                        icon: "calendar.circle.fill",
                        title: "Purchased",
                        value: formattedDate(item.purchasedDate)
                    )
                }
                
                HStack {
                    Spacer()
                    ItemInfoView(
                        icon: "exclamationmark.circle.fill",
                        title: "Expires",
                        value: formattedDate(item.expiryDate),
                        valueColor: isNearExpiry(item.expiryDate) ? Color(hex: "0D6EFD") : .primary
                    )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
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

// Preview
struct GroceryListView_Previews: PreviewProvider {
    static var previews: some View {
        GroceryListView()
    }
}
