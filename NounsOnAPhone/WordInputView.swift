import SwiftUI

struct WordInputView: View {
    @ObservedObject var gameState: GameState
    @State private var newWord: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    @State private var showInfoSheet: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    // Extracted background gradient
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color(red: 0.22, green: 0.60, blue: 0.98), Color(red: 0.20, green: 0.98, blue: 0.98)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // Extracted card background style
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white.opacity(0.35))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header section
                VStack(spacing: 16) {
                    // Fish icon in rounded square
                    ZStack {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(0.4), lineWidth: 2)
                            .background(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(Color.white.opacity(0.12))
                            )
                            .frame(width: 80, height: 80)
                        Text("🐟")
                            .font(.system(size: 36))
                            .accessibilityLabel("Fishbowl app icon")
                    }
                    
                    // Title and subtitle
                    VStack(spacing: 8) {
                        Text("Add Your Nouns!")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        if gameState.words.count > 0 {
                            Text("Words added: \(gameState.words.count)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                // Main content area
                ScrollView {
                    VStack(spacing: 20) {
                        // Word input card
                        VStack(spacing: 16) {
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
                                        .foregroundColor(newWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .white.opacity(0.5) : .white)
                                        .scaleEffect(newWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 1.0 : 1.1)
                                        .animation(.spring(response: 0.3), value: newWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                }
                                .disabled(newWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            
                            Text("Press Enter or tap + to add a word")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(cardBackground)
                        .padding(.horizontal, 20)
                        
                        // Add 5 Words button
                        Button(action: {
                            withAnimation(.spring(response: 0.6)) {
                                gameState.addSampleWords(count: 5)
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "wand.and.stars")
                                    .font(.title2)
                                Text("Add 5 Words")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(Color(red: 0.22, green: 0.60, blue: 0.98))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        
                        // Start game button
                        if gameState.canStartGame() {
                            Button(action: {
                                withAnimation(.spring(response: 0.6)) {
                                    gameState.startGame()
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title2)
                                    Text("Start Game")
                                        .font(.system(size: 18, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 0.22, green: 0.60, blue: 0.98))
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 20)
                        } else {
                            HStack(spacing: 12) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                Text("Start Game")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(.white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationTitle("Add Words")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Add Words")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    withAnimation(.spring(response: 0.6)) {
                        gameState.goToSetupView()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showInfoSheet = true }) {
                    Image(systemName: "info.circle")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
                .accessibilityLabel("Game Info")
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showInfoSheet) {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Adding Words")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Enter nouns that everyone in your group will recognize")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Word Guidelines
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title3)
                                Text("What to include")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Common nouns (dog, car, pizza)")
                                Text("• Proper nouns (Disney, iPhone, Taylor Swift)")
                                Text("• Places, objects, animals, foods")
                                Text("• Things everyone in your group knows")
                            }
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        }
                        
                        // Recommendations
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                Text("Recommended amount")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            Text("Aim for **3-5 words per person** in your group. This ensures everyone gets a good variety of words to guess while keeping the game length manageable.")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        
                        // Tips
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.orange)
                                    .font(.title3)
                                Text("Tips")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Mix easy and challenging words")
                                Text("• Consider your group's interests")
                                Text("• Avoid words that might be offensive")
                                Text("• Use the 'Add 5 Words' button for quick testing")
                            }
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(20)
                }
                .navigationTitle("Word Guidelines")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showInfoSheet = false
                        }
                    }
                }
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
                    .fill(Color.white.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
            )
            .font(.body)
            .foregroundColor(.black)
    }
}

#Preview {
    NavigationStack {
        WordInputView(gameState: GameState())
    }
}


