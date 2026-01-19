import SwiftUI

struct PasscodeView: View {
    let expectedPasscode: String
    let onSuccess: () -> Void
    let onBackToIntro: () -> Void
    let onBackToReveal: () -> Void

    @State private var enteredPasscode: String = ""
    @State private var showError: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBackToIntro) {
                    HStack(spacing: 4) {
                        Image(systemName: "house")
                        Text("Start")
                    }
                    .font(.subheadline)
                    .foregroundColor(AppTheme.accent)
                }

                Spacer()

                Button(action: onBackToReveal) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppTheme.accent)

                Text("Enter Passcode")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Look around for a clue to unlock the next location")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 16) {
                TextField("Passcode", text: $enteredPasscode)
                    .textFieldStyle(.roundedBorder)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .padding(.horizontal, 40)

                if showError {
                    Text("Incorrect passcode, try again")
                        .font(.caption)
                        .foregroundColor(.red)
                }

                Button(action: checkPasscode) {
                    Text("Unlock")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(enteredPasscode.isEmpty ? Color.gray : AppTheme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(enteredPasscode.isEmpty)
                .padding(.horizontal, 40)
            }

                Spacer()
                Spacer()
            }
            .onAppear {
                isFocused = true
            }
        }
        .withAppBackground()
    }

    private func checkPasscode() {
        if enteredPasscode.lowercased().trimmingCharacters(in: .whitespaces) ==
           expectedPasscode.lowercased().trimmingCharacters(in: .whitespaces) {
            onSuccess()
        } else {
            withAnimation {
                showError = true
            }
            enteredPasscode = ""
        }
    }
}

#Preview {
    PasscodeView(
        expectedPasscode: "secret",
        onSuccess: { print("Success!") },
        onBackToIntro: { print("Back to intro") },
        onBackToReveal: { print("Back to reveal") }
    )
}
