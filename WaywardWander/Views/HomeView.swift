import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    @ObservedObject var huntStore: HuntStore
    let onSelectHunt: (Hunt) -> Void

    @State private var showingFilePicker = false
    @State private var showingImportError = false

    var body: some View {
        VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.top, 60)
                    .padding(.bottom, 24)

                // Hunt list or empty state
                if huntStore.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else if huntStore.hunts.isEmpty {
                    emptyStateView
                } else {
                    huntListView
                }

                // Import button
                importButtonView
                    .padding(.bottom, 40)
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.json, .zip, UTType(filenameExtension: "wwh") ?? .data],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .alert("Import Failed", isPresented: $showingImportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The file couldn't be imported. Make sure it's a valid Wander file.")
        }
        .withAppBackground()
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "map.fill")
                    .font(.system(size: 36))
                    .foregroundColor(AppTheme.accent)

                Text("Wayward Wander")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }

            Text("Go on an adventure")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var huntListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(huntStore.hunts) { hunt in
                    HuntCardView(hunt: hunt) {
                        onSelectHunt(hunt)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "map")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.accent.opacity(0.5))

            Text("No Journeys Available")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Import a journey file to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
    }

    private var importButtonView: some View {
        Button(action: { showingFilePicker = true }) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                Text("Import Quest")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: 400)
            .background(AppTheme.accent)
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            if !huntStore.importHunt(from: url) {
                showingImportError = true
            }
        case .failure(let error):
            print("File import error: \(error)")
            showingImportError = true
        }
    }
}
