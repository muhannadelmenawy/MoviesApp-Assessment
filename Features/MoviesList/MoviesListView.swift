//
//  MoviesListView.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import SwiftUI

struct MoviesListView: View {
    @StateObject private var vm = MoviesListViewModel()
    @State private var toastConfig = ToastConfig()

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.primaryBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                SearchHeaderView(searchText: $vm.searchText)

                MoviesListHeaderView()

                GenreChipsView(
                    genres: vm.genres,
                    selected: $vm.selectedGenreIDs
                )
                .padding(.horizontal, 12)
                .padding(.top, 6)

                MoviesContentListView()
            }

            if toastConfig.show {
                ToastView(message: toastConfig.message, backgroundColor: toastConfig.backgroundColor, textColor: toastConfig.textColor)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onChange(of: vm.isOffline) { handleConnectionChange(isOffline: $0) }
    }
}

// MARK: - Subviews
private extension MoviesListView {

    @ViewBuilder
    func SearchHeaderView(searchText: Binding<String>) -> some View {
        SearchBar(
            text: searchText,
            placeholder: "Search TMDB"
        )
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

    @ViewBuilder
    func MoviesListHeaderView() -> some View {
        HStack {
            Text("Watch New Movies")
                .font(.title)
                .bold()
                .foregroundStyle(Color("genreChipsColor"))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    @ViewBuilder
    func MoviesContentListView() -> some View {
        Group {
            if vm.isLoading && vm.movies.isEmpty {
                LoadingStateView()
            } else if let error = vm.errorMessage, vm.movies.isEmpty {
                ErrorStateView(error: error)
            } else if vm.filtered.isEmpty {
                EmptyStateView()
            } else {
                MoviesGridView()
            }
        }
    }

    @ViewBuilder
    func LoadingStateView() -> some View {
        VStack {
            Spacer()
            LoadingView()
            Spacer()
        }
    }

    @ViewBuilder
    func ErrorStateView(error: String) -> some View {
        ErrorView(message: error, retry: vm.retry)
    }

    @ViewBuilder
    func EmptyStateView() -> some View {
        VStack {
            Spacer()
            Text("No movies match your filters.")
                .foregroundColor(Theme.textSecondary)
            Spacer()
        }
    }

    @ViewBuilder
    func MoviesGridView() -> some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(vm.filtered) { movie in
                    MovieGridItem(movie: movie)
                }

                PaginationIndicatorView()
            }
            .padding(.vertical, 12)
        }
        .onTapGesture { dismissKeyboard() }
    }

    @ViewBuilder
    func MovieGridItem(movie: Movie) -> some View {
        NavigationLink {
            MovieDetailsView(movieID: movie.id)
        } label: {
            MovieGridItemView(movie: movie)
        }
        .buttonStyle(.plain)
        .task {
            if movie.id == vm.filtered.last?.id {
                vm.loadNextPage()
            }
        }
    }

    @ViewBuilder
    func PaginationIndicatorView() -> some View {
        Group {
            if vm.isLoading {
                ProgressView()
                    .tint(Theme.accent)
                    .padding()
            } else if vm.canLoadMore {
                Color.clear
                    .frame(height: 1)
                    .onAppear { vm.loadNextPage() }
            }
        }
    }
}

// MARK: - Helper Types
private extension MoviesListView {
    struct ToastConfig {
        var show = false
        var message = ""
        var backgroundColor = Color.green
        var textColor = Color.white
    }

    func handleConnectionChange(isOffline: Bool) {
        withAnimation {
            if isOffline {
                showOfflineToast()
            } else {
                showOnlineToast()
            }
        }
    }

    func showOfflineToast() {
        triggerHapticFeedback()
        toastConfig = ToastConfig(
            show: true,
            message: "You are offline. Check your internet connection",
            backgroundColor: .red,
            textColor: .white
        )
    }

    func showOnlineToast() {
        triggerHapticFeedback()
        toastConfig = ToastConfig(
            show: true,
            message: "Connection restored. Back online",
            backgroundColor: .green,
            textColor: .white
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                toastConfig.show = false
            }
        }

        vm.resetAndLoad()
    }
}

// MARK: - Preview
struct MoviesListView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesListView()
    }
}

#Preview {
    MoviesListView()
}
