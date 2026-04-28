//
//  SpeechViewModel.swift
//  PiKa
//
//  Created by Naveen on 28/04/26.
//

import SwiftUI
import Combine
import AVFAudio

final class SpeechViewModel: ObservableObject {

    // MARK: - State
    enum SpeechState: Equatable {
        case idle
        case listening
        case completed
        case error(String)
    }

    // MARK: - Published
    @Published var highlightedText: AttributedString = ""
    @Published var progress: Double = 0.5
    @Published var state: SpeechState = .idle
    @Published var isPlaying: Bool = false
    @Published var currentIndex: Int = 0
    
    // MARK: - Data
    let targetText: String
    private var targetWords: [String] = []
    private var spokenWords: [String] = []
    private var wordTokens: [WordToken] = [] 

    // MARK: - Services
    private let speechService: SpeechRecognizerService
    private let recorder: AudioRecorderService
    private let player = AudioPlayerService()
    
    var isCompleted: Bool {
        state == .completed
    }

    // MARK: - Init
    init(
        text: String,
        speechService: SpeechRecognizerService = SpeechRecognizerService(),
        recorder: AudioRecorderService = AudioRecorderService()
    ) {
        self.targetText = text
        self.speechService = speechService
        self.recorder = recorder
        
        self.targetWords = text.components(separatedBy: " ")
        self.wordTokens = buildWordTokens(from: text)
        
        self.highlightedText = buildHighlightedText()
        
        player.onCompletion = { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false
            }
        }
    }

    // MARK: - Actions
    
    func checkMicPermissionsAndStartListning() {
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    self.startListening()
                } else {
                    self.state = .error("Microphone permission denied")
                }
            }
        }
    }

    func startListening() {
        configureAudioSession()

        state = .listening

        speechService.start { [weak self] text in
            print("spoked text : \(text)")
            DispatchQueue.main.async {
                self?.handleSpeech(text)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.recorder.startRecording()
        }
    }
    
    func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playAndRecord,
                                    mode: .measurement,
                                    options: [.defaultToSpeaker, .duckOthers])
            try session.setActive(true)
        } catch {
            print("Audio session error:", error)
        }
    }
    
    func stopListening() {
        speechService.stop()
        recorder.stopRecording()
        state = .idle
    }

    func reset() {
        spokenWords = []
        currentIndex = 0
        progress = 0.5
        state = .idle
        highlightedText = buildHighlightedText()
    }

    // MARK: - Core Flow

    private func handleSpeech(_ text: String) {
        guard !isCompleted else { return }

        spokenWords = normalize(text)
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }

        matchSequentially()
        updateHighlighting()
        updateProgress()

        if currentIndex >= targetWords.count {
            complete()
        }
    }

    private func updateHighlighting() {
        highlightedText = buildHighlightedText()
    }

    private func updateProgress() {
        let ratio = Double(currentIndex) / Double(targetWords.count)
        progress = 0.5 + (ratio * 0.5)
    }

    private func complete() {
        speechService.stop()
        recorder.stopRecording()
        state = .completed
    }

    private func buildHighlightedText() -> AttributedString {
        var result = AttributedString("")

        for (index, word) in targetWords.enumerated() {
            var attr = AttributedString(word + " ")

            if index < currentIndex {
                attr.foregroundColor = AppColors.themeColor
            } else {
                attr.foregroundColor = AppColors.themeColor.opacity(0.3)
            }

            result.append(attr)
        }

        return result
    }
    
    func togglePlayback() {
        if isPlaying {
            player.stop()
            isPlaying = false
        } else {
            configurePlaybackSession()
            player.play(url: recorder.recordedURL)
            isPlaying = true
        }
    }
    
    private func configurePlaybackSession() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Playback session error:", error)
        }
    }
}


extension SpeechViewModel {
    
    struct WordToken {
        let display: String
        let tokens: [String]
    }
    
    // MARK: - Build Tokens
    
    func buildWordTokens(from text: String) -> [WordToken] {
        let words = text.components(separatedBy: " ")
        
        return words.map { word in
            let normalized = normalize(word)
            let tokens = normalized
                .components(separatedBy: " ")
                .filter { !$0.isEmpty }
            
            return WordToken(display: word, tokens: tokens)
        }
    }
    
    // MARK: - Sequential Matching (FIXED)
    
    func matchSequentially() {
        var spokenIndex = 0
        var wordIndex = 0
        
        while wordIndex < wordTokens.count {
            
            let tokenGroup = wordTokens[wordIndex].tokens
            var matchedAll = true
            
            for token in tokenGroup {
                
                // ✅ Skip extra spoken words (like "all")
                while spokenIndex < spokenWords.count &&
                      !isFuzzyMatch(token, spokenWords[spokenIndex]) {
                    spokenIndex += 1
                }
                
                if spokenIndex >= spokenWords.count {
                    matchedAll = false
                    break
                }
                
                spokenIndex += 1
            }
            
            if matchedAll {
                wordIndex += 1
            } else {
                break
            }
        }
        
        currentIndex = wordIndex
    }
    
    // MARK: - Normalize
    
    func normalize(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: "i've", with: "i have")
            .replacingOccurrences(of: "i'm", with: "i am")
            .replacingOccurrences(of: "you're", with: "you are")
            .replacingOccurrences(of: "it's", with: "it is")
            .replacingOccurrences(of: "that's", with: "that is")
            .replacingOccurrences(of: "n't", with: " not")
            .replacingOccurrences(of: "'re", with: " are")
            .replacingOccurrences(of: "'ll", with: " will")
            .replacingOccurrences(of: "'ve", with: " have")
            .replacingOccurrences(of: "'d", with: " would")
            .replacingOccurrences(of: "[^a-zA-Z ]", with: " ", options: .regularExpression)
    }
    
    // MARK: - Fuzzy Match
    
    func isFuzzyMatch(_ a: String, _ b: String) -> Bool {
        if a == b { return true }
        
        if a.hasPrefix(b) || b.hasPrefix(a) {
            return true
        }
        
        return levenshtein(a, b) <= 1
    }
    
    // MARK: - Levenshtein
    
    func levenshtein(_ aStr: String, _ bStr: String) -> Int {
        let a = Array(aStr)
        let b = Array(bStr)

        var dist = Array(
            repeating: Array(repeating: 0, count: b.count + 1),
            count: a.count + 1
        )

        for i in 0...a.count { dist[i][0] = i }
        for j in 0...b.count { dist[0][j] = j }

        for i in 1...a.count {
            for j in 1...b.count {
                if a[i - 1] == b[j - 1] {
                    dist[i][j] = dist[i - 1][j - 1]
                } else {
                    dist[i][j] = min(
                        dist[i - 1][j] + 1,
                        dist[i][j - 1] + 1,
                        dist[i - 1][j - 1] + 1
                    )
                }
            }
        }

        return dist[a.count][b.count]
    }
}
