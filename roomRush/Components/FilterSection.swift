
import SwiftUI

struct FilterSection: View {
    @Binding var selectedFilter: String
    
    private let categories = ["All Deals", "Hotels", "Hostels", "Under $100"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { cat in
                    FilterChipView(title: cat, isActive: selectedFilter == cat)
                        .onTapGesture {
                            withAnimation {
                                selectedFilter = cat
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

struct FilterChipView: View {
    let title: String
    var isActive: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isActive ? Color.blue : Color.white)
            .foregroundColor(isActive ? .white : Color.gray)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.2), lineWidth: isActive ? 0 : 1)
            )
    }
}
