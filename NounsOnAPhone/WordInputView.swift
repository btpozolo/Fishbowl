import SwiftUI

struct WordInputView: View {
    @ObservedObject var gameState: GameState
    @State private var newWord: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                // Horizontal layout
                VStack(spacing: 32) {
                    // Centered title
                    Text("Fishbowl")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                    
                    // Main content area
                    HStack(spacing: 24) {
                        // Left side - Timer configuration
                        VStack(spacing: 20) {
                            // Timer configuration with modern design
                            VStack(spacing: 20) {
                                HStack {
                                    Image(systemName: "timer")
                                        .font(.title2)
                                        .foregroundColor(.accentColor)
                                    
                                    Text("Timer Duration")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text("\(gameState.timerDuration)s")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.accentColor)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.accentColor.opacity(0.15))
                                        .cornerRadius(8)
                                }
                                
                                VStack(spacing: 8) {
                                    Slider(
                                        value: Binding(
                                            get: { Double(gameState.timerDuration) },
                                            set: { gameState.timerDuration = Int($0) }
                                        ),
                                        in: 10...120,
                                        step: 5
                                    )
                                    .accentColor(.accentColor)
                                    
                                    HStack {
                                        Text("10s")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Text("120s")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                            )
                            
                            Spacer()
                        }
                        .frame(maxWidth: geometry.size.width * 0.4)
                        
                        // Right side - Word input and controls
                        VStack(spacing: 20) {
                            // Word input section aligned with timer card
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
                                
                                // Sample words button with improved styling
                                if gameState.words.isEmpty {
                                    GameButton.primary(
                                        title: "Add Sample Words",
                                        icon: "wand.and.stars"
                                    ) {
                                        withAnimation(.spring(response: 0.6)) {
                                            gameState.addSampleWords()
                                        }
                                    }
                                    .animation(.spring(response: 0.3), value: gameState.words.count)
                                }
                            }
                            
                            Spacer()
                        }
                        .frame(maxWidth: geometry.size.width * 0.6)
                    }
                    
                    // Centered start game button
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
                        .frame(maxWidth: geometry.size.width * 0.6)
                        .padding(.bottom, 20)
                    } else {
                        GameButton.disabled(
                            title: "Start Game",
                            icon: "play.circle.fill",
                            size: .large
                        ) {
                            // No action when disabled
                        }
                        .frame(maxWidth: geometry.size.width * 0.6)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal, 20)
            } else {
                // Vertical layout (original)
                VStack(spacing: 24) {
                    // Header with improved styling
                    VStack(spacing: 12) {
                        Text("Fishbowl")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Add words to your game")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Timer configuration with modern design
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "timer")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                            
                            Text("Timer Duration")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(gameState.timerDuration)s")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.accentColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.accentColor.opacity(0.15))
                                .cornerRadius(8)
                        }
                        
                        VStack(spacing: 8) {
                            Slider(
                                value: Binding(
                                    get: { Double(gameState.timerDuration) },
                                    set: { gameState.timerDuration = Int($0) }
                                ),
                                in: 10...120,
                                step: 5
                            )
                            .accentColor(.accentColor)
                            
                            HStack {
                                Text("10s")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("120s")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    
                    // Word input section with enhanced design
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
                        
                        // Word count display and start game button (when keyboard is visible)
                        if gameState.words.count > 0 {
                            HStack(spacing: 12) {
                                // Word count card
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
                                
                                // Start game button (only show when keyboard is visible)
                                if keyboardHeight > 0 {
                                    if gameState.canStartGame() {
                                        GameButton.success(
                                            title: "Start",
                                            icon: "play.circle.fill"
                                        ) {
                                            withAnimation(.spring(response: 0.6)) {
                                                gameState.startGame()
                                            }
                                        }
                                    } else {
                                        GameButton.disabled(
                                            title: "Start",
                                            icon: "play.circle.fill"
                                        ) {
                                            // No action when disabled
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Sample words button with improved styling
                        if gameState.words.isEmpty {
                            GameButton.primary(
                                title: "Add Sample Words",
                                icon: "wand.and.stars"
                            ) {
                                withAnimation(.spring(response: 0.6)) {
                                    gameState.addSampleWords()
                                }
                            }
                            .animation(.spring(response: 0.3), value: gameState.words.count)
                        }
                    }
                    
                    Spacer()
                    
                    // Start game button with enhanced design (only show when keyboard is not visible)
                    if keyboardHeight == 0 {
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
                            .padding(.bottom, 20)
                        } else {
                            GameButton.disabled(
                                title: "Start Game",
                                icon: "play.circle.fill",
                                size: .large
                            ) {
                                // No action when disabled
                            }
                            .padding(.bottom, 20)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
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

#Preview("Landscape", traits: .landscapeLeft) {
    let sampleGameState = GameState()
    sampleGameState.addWord("Pizza")
    
    return WordInputView(gameState: sampleGameState)
}

#Preview("With Keyboard", traits: .portrait) {
    ZStack {
        // Main content with reduced height to simulate keyboard space
        WordInputView(gameState: GameState())
        
        // Mock keyboard at the bottom
        VStack {
            Spacer()
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 300)
                .overlay(
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            ForEach(0..<10, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray3))
                                    .frame(width: 30, height: 40)
                            }
                        }
                        HStack(spacing: 4) {
                            ForEach(0..<9, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray3))
                                    .frame(width: 30, height: 40)
                            }
                        }
                        HStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray3))
                                .frame(width: 50, height: 40)
                            ForEach(0..<7, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray3))
                                    .frame(width: 30, height: 40)
                            }
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray3))
                                .frame(width: 50, height: 40)
                        }
                    }
                        .padding()
                )
        }
    }
}
