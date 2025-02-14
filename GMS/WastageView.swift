//
//  WastageView.swift
//  GMS
//
//  Created by Helly Prakashkumar Chauhan on 2025-02-14.
//

import SwiftUI

// Wastage Item Model
struct WastageItem: Identifiable {
    let id = UUID()
    let name: String
    let amount: String  // Example: "2 kg", "3 packs", etc.
}

// Sample Wastage Data
let sampleWastageItems = [
    WastageItem(name: "Rotten Apples", amount: "2 kg"),
    WastageItem(name: "Spoiled Milk", amount: "1 bottle"),
    WastageItem(name: "Moldy Bread", amount: "1 loaf"),
    WastageItem(name: "Expired Yogurt", amount: "3 packs")
]


struct WastageView: View {
    @State private var wastageItems = sampleWastageItems
    @State private var showingAddWastage = false
    
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
                    // Wastage Summary Card
                    WastageSummaryCard(items: wastageItems)
                        .padding(.horizontal)
                    
                    // Wastage List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(wastageItems) { item in
                                WastageItemCard(item: item)
                            }
                        }
                        .padding()
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
                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        showingAddWastage = true
//                    }) {
//                        Image(systemName: "plus.circle.fill")
//                            .foregroundColor(Color(hex: "DC3545"))
//                            .font(.title3)
//                    }
//                }
            }
        }
    }
}

struct WastageSummaryCard: View {
    let items: [WastageItem]
    
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
            
            HStack(spacing: 20) {
                StatCard(
                    title: "Total Items",
                    value: "\(items.count)",
                    icon: "number.circle.fill"
                )
                
                StatCard(
                    title: "This Month",
                    value: "4 items",
                    icon: "calendar.circle.fill"
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
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

struct WastageItemCard: View {
    let item: WastageItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Wastage Icon
            Image(systemName: "trash.circle.fill")
                .foregroundColor(Color(hex: "DC3545"))
                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                HStack {
                    Label {
                        Text(item.amount)
                            .foregroundColor(.gray)
                    } icon: {
                        Image(systemName: "scalemass.fill")
                            .foregroundColor(Color(hex: "DC3545"))
                    }
                    
                    Spacer()
//                    
//                    Label {
//                        Text(formattedDate(item.date))
//                            .foregroundColor(.gray)
//                    } icon: {
//                        Image(systemName: "calendar")
//                            .foregroundColor(Color(hex: "DC3545"))
//                    }
                }
                .font(.subheadline)
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
}

// Preview
struct WastageView_Previews: PreviewProvider {
    static var previews: some View {
        WastageView()
    }
}
