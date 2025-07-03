import SwiftUI

struct WordInputView: View {
    @ObservedObject var gameState: GameState
    @State private var newWord: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack(spacing: 20) {
                    // Word input section
                    VStack(spacing: 20) {
                        HStack(spacing: 12) {
                            TextField("Enter a word...", text: $newWord)
                                .textFieldStyle(CustomTextFieldStyle())
                                .focused($isTextFieldFocused)
                                .onSubmit {
                                    addWord()
                                }
                            Button(action: addWord) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(newWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .accentColor)
                                    .scaleEffect(newWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 1.0 : 1.1)
                                    .animation(.spring(response: 0.3), value: newWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            .disabled(newWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        Text("Press Enter or tap + to add a word")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        // Word count display
                        if gameState.words.count > 0 {
                            HStack {
                                Text("Words added:")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(gameState.words.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.accentColor)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.accentColor.opacity(0.15))
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        // Add 10 Words button
                        GameButton.primary(
                            title: "Add 10 Words",
                            icon: "wand.and.stars"
                        ) {
                            withAnimation(.spring(response: 0.6)) {
                                gameState.addSampleWords(count: 10)
                            }
                        }
                        .animation(.spring(response: 0.3), value: gameState.words.count)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    .frame(maxWidth: 400)
                    // Start game button
                    if gameState.canStartGame() {
                        GameButton.success(
                            title: "Start Game",
                            icon: "play.circle.fill",
                            size: .large
                        ) {
                            withAnimation(.spring(response: 0.6)) {
                                gameState.startGame()
                            }
                        }
                        .frame(maxWidth: 400)
                        .padding(.bottom, 20)
                    } else {
                        GameButton.disabled(
                            title: "Start Game",
                            icon: "play.circle.fill",
                            size: .large
                        ) {
                            // No action when disabled
                        }
                        .frame(maxWidth: 400)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            // Header stays at the top
            .overlay(
                VStack {
                    Text("Fishbowl")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                    Spacer()
                }
            )
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            isTextFieldFocused = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
    }
    
    private func addWord() {
        let trimmedWord = newWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedWord.isEmpty else { return }
        withAnimation(.spring(response: 0.4)) {
            gameState.addWord(trimmedWord)
        }
        newWord = ""
        isTextFieldFocused = true
    }
}

// Custom text field style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            )
            .font(.body)
    }
}

#Preview {
    WordInputView(gameState: GameState())
}
