import SwiftUI

struct WordInputView: View {
    @ObservedObject var gameState: GameState
    @State private var newWord: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    @State private var showInfoSheet: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header at the top
                VStack(spacing: 4) {
                    HStack {
                        Spacer()
                        HStack(spacing: 10) {
                            Image(systemName: "fish.fill")
                                .foregroundColor(.accentColor)
                                .font(.system(size: 32))
                            Text("Fishbowl")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                        Button(action: { showInfoSheet = true }) {
                            Image(systemName: "info.circle")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .accessibilityLabel("Game Info")
                        .padding(.trailing, 16)
                    }
                    .padding(.top, 12)
                    Text("Add Your Nouns!")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    if gameState.words.count > 0 {
                        Text("Words added: \(gameState.words.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 12)
                // Spacer pushes controls to bottom
                Spacer()
                // Controls at the bottom or just above keyboard
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
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
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    .frame(maxWidth: 400)
                    // Add 5 Words button
                    GameButton.primary(
                        title: "Add 5 Words",
                        icon: "wand.and.stars"
                    ) {
                        withAnimation(.spring(response: 0.6)) {
                            gameState.addSampleWords(count: 5)
                        }
                    }
                    .animation(.spring(response: 0.3), value: gameState.words.count)
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
                    } else {
                        GameButton.disabled(
                            title: "Start Game",
                            icon: "play.circle.fill",
                            size: .large
                        ) {
                            // No action when disabled
                        }
                        .frame(maxWidth: 400)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, keyboardHeight > 0 ? 20 : geometry.safeAreaInsets.bottom + 12) // test this fixed the word input issue
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showInfoSheet) {
                VStack(spacing: 24) {
                    HStack {
                        Spacer()
                        Button(action: { showInfoSheet = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding([.top, .trailing])
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    Text("Enter any noun (including proper nouns). Just make sure it’s a word the whole group is likely to know!")
                        .font(.title3)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
                .presentationDetents([.medium, .large])
            }
            .onAppear {
                isTextFieldFocused = true
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
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


