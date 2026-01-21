import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    @ObservedObject var huntStore: HuntStore
    let onSelectHunt: (Hunt) -> Void
    let onCreateQuest: () -> Void
    let onEditQuest: (Hunt) -> Void

    @State private var showingFilePicker = false
    @State private var showingImportError = false
    @State private var huntToDelete: Hunt?
    @State private var showingDeleteConfirmation = false
    @State private var shareItem: ShareItem?

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

                // Action buttons
                actionButtonsView
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
        .alert("Delete Quest?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let hunt = huntToDelete {
                    huntStore.deleteHunt(hunt)
                }
                huntToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                huntToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete \"\(huntToDelete?.title ?? "this quest")\"? This cannot be undone.")
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: [item.url])
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
                    HuntCardView(
                        hunt: hunt,
                        isUserCreated: huntStore.isUserCreated(hunt.id),
                        onSelect: {
                            onSelectHunt(hunt)
                        },
                        onEdit: {
                            onEditQuest(hunt)
                        },
                        onDelete: {
                            huntToDelete = hunt
                            showingDeleteConfirmation = true
                        },
                        onShare: {
                            shareQuest(hunt)
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }

    private func shareQuest(_ hunt: Hunt) {
        if let url = huntStore.exportBundle(huntId: hunt.id) {
            shareItem = ShareItem(url: url)
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

    private var actionButtonsView: some View {
        HStack(spacing: 12) {
            // Create Quest button
            Button(action: onCreateQuest) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Quest")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppTheme.accent)
                .cornerRadius(12)
            }

            // Import Quest button
            Button(action: { showingFilePicker = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Import")
                }
                .font(.headline)
                .foregroundColor(AppTheme.accent)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.clear)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.accent, lineWidth: 2)
                )
            }
        }
        .frame(maxWidth: 500)
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

// MARK: - Share Item

struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
