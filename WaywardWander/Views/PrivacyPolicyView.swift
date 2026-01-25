import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Privacy Policy")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Last updated: January 2025")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Group {
                        sectionHeader("Overview")
                        Text("Wayward Wander is a scavenger hunt app that helps you explore locations through GPS-guided quests. Your privacy is important to us, and we've designed the app to collect only what's necessary for it to function.")
                    }

                    Group {
                        sectionHeader("Location Data")
                        Text("The app uses your device's GPS location to:")
                        bulletPoint("Guide you to quest destinations")
                        bulletPoint("Calculate your distance from target locations")
                        bulletPoint("Detect when you've arrived at a clue location")

                        Text("Your location data is processed entirely on your device. We do not collect, store, or transmit your location to any server.")
                            .padding(.top, 4)
                    }

                    Group {
                        sectionHeader("Photos")
                        Text("When creating quests, you can add photos from your photo library. These photos are stored locally on your device within the app's documents folder. Photos are only shared when you explicitly export and share a quest bundle.")
                    }

                    Group {
                        sectionHeader("Quest Data")
                        Text("Quests you create or import are stored locally on your device. Quest progress is saved to your device's local storage (UserDefaults) so you can resume where you left off.")
                    }

                    Group {
                        sectionHeader("No Data Collection")
                        Text("Wayward Wander does not:")
                        bulletPoint("Collect any personal information")
                        bulletPoint("Use analytics or tracking")
                        bulletPoint("Send data to external servers")
                        bulletPoint("Display advertisements")
                    }

                    Group {
                        sectionHeader("Third-Party Services")
                        Text("This app does not integrate with any third-party services or APIs.")
                    }

                    Group {
                        sectionHeader("Contact")
                        Text("If you have questions about this privacy policy, you can reach us through the app's GitHub repository.")
                    }

                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .padding(.top, 8)
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
        }
        .padding(.leading, 8)
    }
}

#Preview {
    PrivacyPolicyView()
}
