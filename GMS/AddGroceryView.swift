import SwiftUI

struct AddGroceryView: View {
    @State private var itemName = ""
    @State private var quantity = ""
    @State private var price = ""
    @State private var unit = "" // New state variable for unit
    @State private var purchasedDate = Date() // Defaults to today
    @State private var expiryDate = Date() // Defaults to today
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "F8F9FA"), Color(hex: "E9ECEF")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Custom input fields
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
                    
                    // New Unit input field with suggestions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unit")
                            .foregroundColor(Color(hex: "495057"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        UnitInputView(unit: $unit)
                    }
                    
                    // Custom date pickers with constrained ranges
                    // Purchased Date: no future dates (range: ...today)
                    CustomDatePicker(
                        title: "Purchased Date",
                        icon: "calendar.circle.fill",
                        date: $purchasedDate,
                        range: Date.distantPast...Date()
                    )

                    // Expiry Date: no dates before today (range: today...)
                    CustomDatePicker(
                        title: "Expiry Date",
                        icon: "calendar.badge.exclamationmark",
                        date: $expiryDate,
                        range: Date()...Date.distantFuture
                    )

                    // Action buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            // Save action: perform saving logic then dismiss
                            dismiss()
                        }) {
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
            // Navigation bar title
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Add Grocery")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color(hex: "198754"))
            }
            // Cancel button to dismiss view without saving
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(Color(hex: "DC3545"))
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

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

// MARK: - Unit Input with Suggestions
struct UnitInputView: View {
    @Binding var unit: String
    let allUnits = ["ml", "liter", "kg", "pound", "box", "block", "dozen", "strip", "g", "oz", "cup", "tbsp", "tsp","carton","bottle"]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Styled text field similar to CustomInputField:
            HStack {
                Image(systemName: "ruler")  // you can choose an appropriate icon
                    .foregroundColor(Color(hex: "198754"))
                    .font(.system(size: 20))
                TextField("Unit", text: $unit)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "198754").opacity(0.2), lineWidth: 1)
            )
            
            // Suggestions list:
            let suggestions = allUnits.filter { suggestion in
                suggestion.lowercased().contains(unit.lowercased()) && !unit.isEmpty
            }
            if !suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Text(suggestion)
                            .padding(8)
                            .onTapGesture {
                                unit = suggestion
                            }
                            .background(Color.white)
                    }
                }
                .cornerRadius(8)
                .shadow(radius: 3)
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
