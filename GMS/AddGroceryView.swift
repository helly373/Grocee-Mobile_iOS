import SwiftUI

struct AddGroceryView: View {
    @State private var itemName = ""
    @State private var quantity = ""
    @State private var price = ""
    @State private var purchasedDate = Date()
    @State private var expiryDate = Date()
    @Environment(\.dismiss) private var dismiss
    
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
                        
                        // Custom date pickers
                        CustomDatePicker(
                            title: "Purchased Date",
                            icon: "calendar.circle.fill", date: $purchasedDate
                        )
                        
                        CustomDatePicker(
                            title: "Expiry Date",
                            icon: "calendar.badge.exclamationmark", date: $expiryDate
                        )
                        
                        // Action buttons
                        VStack(spacing: 16) {
                            Button(action: {
                                // Save action
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
                            
//                            
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
            }
        }
    }
}

// Custom Input Field
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

// Custom Date Picker
struct CustomDatePicker: View {
    let title: String
    let icon: String
    @Binding var date: Date
    
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
                
                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
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

// Preview
struct AddGroceryView_Previews: PreviewProvider {
    static var previews: some View {
        AddGroceryView()
    }
}
