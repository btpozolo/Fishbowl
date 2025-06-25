import SwiftUI

struct WordInputView: View {
    @ObservedObject var gameState: GameState
    @State private var newWord: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                // Horizontal layout
                HStack(spacing: 24) {
                    // Left side - Title and timer
                    VStack(spacing: 20) {
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
                        
                        Spacer()
                    }
                    .frame(maxWidth: geometry.size.width * 0.4)
                    
                    // Right side - Word input and controls
                    VStack(spacing: 20) {
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
                                Button(action: {
                                    withAnimation(.spring(response: 0.6)) {
                                        gameState.addSampleWords()
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "wand.and.stars")
                                            .font(.title3)
                                        Text("Add Sample Words")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.accentColor, .accentColor.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: .accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .scaleEffect(1.0)
                                .animation(.spring(response: 0.3), value: gameState.words.count)
                            }
                        }
                        
                        Spacer()
                        
                        // Start game button with enhanced design
                        Button(action: {
                            withAnimation(.spring(response: 0.6)) {
                                gameState.startGame()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                Text("Start Game")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: gameState.canStartGame() ? 
                                        [.green, .green.opacity(0.8)] : 
                                        [.gray, .gray.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: gameState.canStartGame() ? .green.opacity(0.3) : .gray.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(!gameState.canStartGame())
                        .scaleEffect(gameState.canStartGame() ? 1.0 : 0.98)
                        .animation(.spring(response: 0.3), value: gameState.canStartGame())
                        .padding(.bottom, 20)
                    }
                    .frame(maxWidth: geometry.size.width * 0.6)
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
                            Button(action: {
                                withAnimation(.spring(response: 0.6)) {
                                    gameState.addSampleWords()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "wand.and.stars")
                                        .font(.title3)
                                    Text("Add Sample Words")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.accentColor, .accentColor.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: .accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .scaleEffect(1.0)
                            .animation(.spring(response: 0.3), value: gameState.words.count)
                        }
                    }
                    
                    Spacer()
                    
                    // Start game button with enhanced design
                    Button(action: {
                        withAnimation(.spring(response: 0.6)) {
                            gameState.startGame()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                            Text("Start Game")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: gameState.canStartGame() ? 
                                    [.green, .green.opacity(0.8)] : 
                                    [.gray, .gray.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: gameState.canStartGame() ? .green.opacity(0.3) : .gray.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(!gameState.canStartGame())
                    .scaleEffect(gameState.canStartGame() ? 1.0 : 0.98)
                    .animation(.spring(response: 0.3), value: gameState.canStartGame())
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            isTextFieldFocused = true
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