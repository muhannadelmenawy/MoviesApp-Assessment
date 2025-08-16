//
//  MoviesApp.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import SwiftUI

@main
struct MoviesApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MoviesListView()
                    .preferredColorScheme(.dark)
            }
        }
    }
}
