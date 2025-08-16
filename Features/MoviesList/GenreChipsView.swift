//
//  GenreChipsView.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import SwiftUI

struct GenreChipsView: View {
    let genres: [Genre]
    @Binding var selected: Set<Int>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Chip(text: "All", isSelected: selected.isEmpty) { selected.removeAll() }
                ForEach(genres) { g in
                    Chip(text: g.name, isSelected: selected.contains(g.id)) {
                        if selected.contains(g.id) { selected.remove(g.id) } else { selected.insert(g.id) }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func Chip(text: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text).font(.caption)
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(isSelected ? Color("genreChipsColor") : .clear)
                .foregroundStyle(isSelected ? Theme.textSelection : Theme.textPrimary)
                .overlay(Capsule().stroke(isSelected ? .clear : Color("genreChipsColor"), lineWidth: 1.5))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GenreChipsView(genres: MockData.genres, selected: .constant([0,1,2]))
}
