//
//  ShoppingListsView.swift
//  GMS
//
//  Created by Kashyap Mavani on 2025-04-04.
//

import SwiftUI
import CoreData

struct ShoppingListsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ShoppingList.creationDate, ascending: false)],
        animation: .default)
    private var shoppingLists: FetchedResults<ShoppingList>
    
    @State private var showingAddListSheet = false
    @State private var newListName = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(shoppingLists) { list in
                    NavigationLink(destination: ShoppingListItemsView(shoppingList: list)) {
                        VStack(alignment: .leading) {
                            Text(list.name ?? "Unnamed List")
                                .font(.headline)
                            
                            if let date = list.creationDate {
                                Text("Created: \(formattedDate(date))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("\(list.itemsArray.count) items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteShoppingLists)
            }
            .navigationTitle("Shopping Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddListSheet = true }) {
                        Label("Add List", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddListSheet) {
                NavigationView {
                    Form {
                        Section(header: Text("New Shopping List")) {
                            TextField("List Name", text: $newListName)
                        }
                    }
                    .navigationTitle("Add List")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingAddListSheet = false
                                newListName = ""
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                addShoppingList()
                                showingAddListSheet = false
                            }
                            .disabled(newListName.isEmpty)
                        }
                    }
                }
            }
        }
    }
    
    private func addShoppingList() {
        withAnimation {
            let newList = ShoppingList(context: viewContext)
            newList.name = newListName
            newList.id = UUID()
            newList.creationDate = Date()
            
            do {
                try viewContext.save()
                newListName = ""
            } catch {
                let nsError = error as NSError
                print("Error adding shopping list: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteShoppingLists(offsets: IndexSet) {
        withAnimation {
            offsets.map { shoppingLists[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting shopping list: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Extension to make accessing ShoppingListItems easier
extension ShoppingList {
    var itemsArray: [ShoppingListItem] {
        let set = items as? Set<ShoppingListItem> ?? []
        return set.sorted {
            $0.name ?? "" < $1.name ?? ""
        }
    }
}
