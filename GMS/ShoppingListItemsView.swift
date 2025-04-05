//
//  ShoppingListItemsView.swift
//  GMS
//
//  Created by Kashyap Mavani on 2025-04-04.
//

import SwiftUI
import CoreData

struct ShoppingListItemsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var shoppingList: ShoppingList
    
    @State private var showingAddItemSheet = false
    @State private var showingGroceryConversionSheet = false
    @State private var selectedItem: ShoppingListItem?
    
    // Form states for new item
    @State private var itemName = ""
    @State private var itemQuantity = ""
    @State private var itemUnit = "pcs"
    
    // Additional states for grocery conversion
    @State private var groceryPrice = ""
    @State private var groceryCategory = ""
    @State private var groceryExpiryDate = Date()
    
    let unitOptions = ["pcs", "kg", "g", "L", "ml", "lb", "oz", "dozen"]
    let categoryOptions = ["Produce", "Meat", "Dairy", "Bakery", "Frozen", "Canned", "Dry Goods", "Beverages", "Snacks", "Other"]
    
    var body: some View {
        List {
            if shoppingList.itemsArray.isEmpty {
                Text("No items yet. Add your first item!")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(shoppingList.itemsArray) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name ?? "Unnamed Item")
                                .font(.headline)
                                .strikethrough(item.isBought)
                            
                            Text("\(formattedQuantity(item.quantity)) \(item.unit ?? "")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if !item.isBought {
                            Button(action: {
                                selectedItem = item
                                showingGroceryConversionSheet = true
                            }) {
                                Image(systemName: "cart")
                                    .foregroundColor(.green)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Populate edit fields with this item's data
                        selectedItem = item
                        itemName = item.name ?? ""
                        itemQuantity = String(item.quantity)
                        itemUnit = item.unit ?? "pcs"
                        showingAddItemSheet = true
                    }
                }
                .onDelete(perform: deleteItems)
            }
        }
        .navigationTitle(shoppingList.name ?? "Shopping List")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Clear form for new item
                    selectedItem = nil
                    itemName = ""
                    itemQuantity = ""
                    itemUnit = "pcs"
                    showingAddItemSheet = true
                }) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddItemSheet) {
            NavigationView {
                Form {
                    Section(header: Text(selectedItem == nil ? "New Item" : "Edit Item")) {
                        TextField("Item Name", text: $itemName)
                        
                        HStack {
                            TextField("Quantity", text: $itemQuantity)
                                .keyboardType(.decimalPad)
                            
                            Picker("Unit", selection: $itemUnit) {
                                ForEach(unitOptions, id: \.self) { unit in
                                    Text(unit).tag(unit)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 100)
                        }
                    }
                }
                .navigationTitle(selectedItem == nil ? "Add Item" : "Edit Item")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingAddItemSheet = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            saveItem()
                            showingAddItemSheet = false
                        }
                        .disabled(itemName.isEmpty || itemQuantity.isEmpty)
                    }
                }
            }
        }
        .sheet(isPresented: $showingGroceryConversionSheet) {
            NavigationView {
                Form {
                    Section(header: Text("Mark as Purchased")) {
                        Text("Item: \(selectedItem?.name ?? "")")
                            .font(.headline)
                        
                        Text("Quantity: \(formattedQuantity(selectedItem?.quantity ?? 0)) \(selectedItem?.unit ?? "")")
                            .font(.subheadline)
                    }
                    
                    Section(header: Text("Additional Information")) {
                        TextField("Price", text: $groceryPrice)
                            .keyboardType(.decimalPad)
                        
                        Picker("Category", selection: $groceryCategory) {
                            ForEach(categoryOptions, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        
                        DatePicker("Expiry Date", selection: $groceryExpiryDate, displayedComponents: .date)
                    }
                }
                .navigationTitle("Add to Groceries")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingGroceryConversionSheet = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add to Inventory") {
                            markItemAsBoughtAndAddToGrocery()
                            showingGroceryConversionSheet = false
                        }
                    }
                }
                .onAppear {
                    // Set default category
                    if groceryCategory.isEmpty {
                        groceryCategory = categoryOptions.first ?? ""
                    }
                }
            }
        }
    }
    
    private func saveItem() {
        withAnimation {
            let item: ShoppingListItem
            
            if let existingItem = selectedItem {
                // Edit existing item
                item = existingItem
            } else {
                // Create new item
                item = ShoppingListItem(context: viewContext)
                item.id = UUID()
                item.isBought = false
                item.shoppingList = shoppingList
            }
            
            // Update item properties
            item.name = itemName
            item.quantity = Double(itemQuantity) ?? 0
            item.unit = itemUnit
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error saving item: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { shoppingList.itemsArray[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting item: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func markItemAsBoughtAndAddToGrocery() {
        guard let item = selectedItem else { return }
        
        withAnimation {
            // Mark item as bought
            item.isBought = true
            
            // Create new grocery item
            let grocery = Grocery(context: viewContext)
            grocery.id = UUID()
            grocery.name = item.name
            grocery.quantity = item.quantity
            grocery.unit = item.unit
            grocery.price = Double(groceryPrice) ?? 0
            grocery.category = groceryCategory
            grocery.expiryDate = groceryExpiryDate
            grocery.purchaseDate = Date()
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error converting to grocery: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func formattedQuantity(_ quantity: Double) -> String {
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", quantity)
        } else {
            return String(format: "%.2f", quantity)
        }
    }
}

// Preview provider
struct ShoppingListItemsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleList = ShoppingList(context: context)
        sampleList.name = "Weekly Groceries"
        sampleList.id = UUID()
        sampleList.creationDate = Date()
        
        // Add some sample items
        let item1 = ShoppingListItem(context: context)
        item1.name = "Milk"
        item1.quantity = 2
        item1.unit = "L"
        item1.shoppingList = sampleList
        
        let item2 = ShoppingListItem(context: context)
        item2.name = "Apples"
        item2.quantity = 1
        item2.unit = "kg"
        item2.shoppingList = sampleList
        
        return ShoppingListItemsView(shoppingList: sampleList)
            .environment(\.managedObjectContext, context)
    }
}
