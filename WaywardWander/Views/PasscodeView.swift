import SwiftUI

struct PasscodeView: View {
    let expectedPasscode: String
    let onSuccess: () -> Void

    @State private var enteredPasscode: String = ""
    @State private var showError: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)

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
                        .background(enteredPasscode.isEmpty ? Color.gray : Color.orange)
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
    PasscodeView(expectedPasscode: "secret") {
        print("Success!")
    }
}
