import SwiftUI
import CoreData

struct AddGroceryView: View {
    @State private var itemName = ""
    @State private var quantity = ""
    @State private var price = ""
    @State private var unit = ""
    @State private var purchasedDate = Date() // Defaults to today
    @State private var expiryDate = Date() // Defaults to today
    @State private var category = "" // State variable for category
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject private var coreDataManager = CoreDataManager.shared
    
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
                    CustomInputField(
                        title: "Item Name",
                        icon: "cart.fill", text: $itemName
                    )
                    
                    CustomInputField(
                        title: "Quantity",
                        icon: "number.circle.fill", text: $quantity,
                        keyboardType: .numberPad
                    )
                    
                    CustomInputField(
                        title: "Price",
                        icon: "dollarsign.circle.fill", text: $price,
                        keyboardType: .decimalPad
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unit")
                            .foregroundColor(Color(hex: "495057"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        UnitInputView(unit: $unit)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .foregroundColor(Color(hex: "495057"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        CategoryInputView(category: $category)
                    }
                    
                    CustomDatePicker(
                        title: "Purchased Date",
                        icon: "calendar.circle.fill",
                        date: $purchasedDate,
                        range: Date.distantPast...Date()
                    )
                    
                    CustomDatePicker(
                        title: "Expiry Date",
                        icon: "calendar.badge.exclamationmark",
                        date: $expiryDate,
                        range: Date()...Date.distantFuture
                    )
                    
                    VStack(spacing: 16) {
                        Button(action: saveGrocery) {
                            HStack {
                                Image(systemName: "square.and.arrow.down.fill")
                                Text("Save Grocery")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "198754"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color(hex: "198754").opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Add Grocery")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color(hex: "198754"))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(Color(hex: "DC3545"))
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func saveGrocery() {
        guard let currentUser = coreDataManager.fetchCurrentUser() else {
            print("No logged-in user found!")
            return
        }
        
        guard let quantityValue = Double(quantity), let priceValue = Float(price) else {
            print("Invalid quantity or price input")
            return
        }
        
        coreDataManager.addGrocery(
            for: currentUser,
            name: itemName,
            expiryDate: expiryDate,
            price: priceValue,
            purchasedDate: purchasedDate,
            quantity: quantityValue,
            unit: unit,
            category: category
        )
        
        resetFields()
        dismiss() // Dismiss the view after saving
    }
    
    private func resetFields() {
        itemName = ""
        quantity = ""
        price = ""
        unit = ""
        category = ""
        purchasedDate = Date()
        expiryDate = Date()
    }
}

// MARK: - Category Input with Suggestions

// MARK: - Custom Input Field
struct CustomInputField: View {
    let title: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(Color(hex: "495057"))
                .font(.subheadline)
                .fontWeight(.medium)

            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "198754"))
                    .font(.system(size: 20))
                TextField(title, text: $text)
                    .keyboardType(keyboardType)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "198754").opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Custom Date Picker with Range Support
struct CustomDatePicker: View {
    let title: String
    let icon: String
    @Binding var date: Date
    var range: ClosedRange<Date>? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(Color(hex: "495057"))
                .font(.subheadline)
                .fontWeight(.medium)

            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "198754"))
                    .font(.system(size: 20))
                if let range = range {
                    DatePicker(
                        "",
                        selection: $date,
                        in: range,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                } else {
                    DatePicker(
                        "",
                        selection: $date,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "198754").opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Improved Category Input with Real-time Filtering
struct CategoryInputView: View {
    @Binding var category: String
    @State private var isFocused = false
    
    // List of common grocery categories
    let allCategories = [
        "Dairy", "Produce", "Bakery", "Meat", "Frozen",
        "Canned Goods", "Beverages", "Snacks", "Condiments",
        "Grains", "Baking", "Breakfast", "Pasta", "Seafood",
        "Deli",  "Household", "Baby", "PConet"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Styled text field
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(Color(hex: "198754"))
                    .font(.system(size: 20))
                TextField("Category", text: $category, onEditingChanged: { editing in
                    isFocused = editing
                })
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "198754").opacity(0.2), lineWidth: 1)
            )
            
            // Only show suggestions when field is focused and we have text or suggestions
            if isFocused {
                // Improved filtering logic
                let suggestions = category.isEmpty
                    ? allCategories
                    : allCategories.filter { $0.lowercased().contains(category.lowercased()) }
                
                if !suggestions.isEmpty {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(suggestions.prefix(5), id: \.self) { suggestion in
                                Text(suggestion)
                                    .foregroundColor(Color(hex: "198754"))
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        category == suggestion ?
                                            Color(hex: "E8F5E9") :
                                            Color.white
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        category = suggestion
                                        isFocused = false
                                        // Dismiss keyboard
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                
                                if suggestion != suggestions.last {
                                    Divider()
                                        .padding(.leading, 12)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 250)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    .transition(.opacity)
                }
            }
        }
    }
}

// MARK: - Improved Unit Input with Real-time Filtering
struct UnitInputView: View {
    @Binding var unit: String
    @State private var isFocused = false
    
    let allUnits = ["ml", "liter", "kg", "pound", "box", "block", "dozen", "strip", "g", "oz", "cup", "tbsp", "tsp", "carton", "bottle"]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Styled text field
            HStack {
                Image(systemName: "ruler")
                    .foregroundColor(Color(hex: "198754"))
                    .font(.system(size: 20))
                TextField("Unit", text: $unit, onEditingChanged: { editing in
                    isFocused = editing
                })
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "198754").opacity(0.2), lineWidth: 1)
            )
            
            // Only show suggestions when field is focused and we have text or suggestions
            if isFocused {
                // Improved filtering logic
                let suggestions = unit.isEmpty
                    ? allUnits
                    : allUnits.filter { $0.lowercased().contains(unit.lowercased()) }
                
                if !suggestions.isEmpty {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(suggestions.prefix(5), id: \.self) { suggestion in
                                Text(suggestion)
                                    .foregroundColor(Color(hex: "198754"))
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        unit == suggestion ?
                                            Color(hex: "E8F5E9") :
                                            Color.white
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        unit = suggestion
                                        isFocused = false
                                        // Dismiss keyboard
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                
                                if suggestion != suggestions.last {
                                    Divider()
                                        .padding(.leading, 12)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 250)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    .transition(.opacity)
                }
            }
        }
    }
}

struct AddGroceryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddGroceryView()
        }
    }
}
