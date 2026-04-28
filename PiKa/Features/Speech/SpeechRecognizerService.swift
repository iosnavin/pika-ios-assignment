//
//  SpeechRecognizerService.swift
//  PiKa
//
//  Created by Naveen on 28/04/26.
//

import Speech
import AVFoundation

final class SpeechRecognizerService {

    private let recognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()

    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func start(onResult: @escaping (String) -> Void) {
        if audioEngine.isRunning {
            stop()
        }
        request = SFSpeechAudioBufferRecognitionRequest()

        guard let request = request else {
            print("❌ Failed to create request")
            return
        }

        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)

        request.shouldReportPartialResults = true

        task = recognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                onResult(result.bestTranscription.formattedString)
            }

            if error != nil {
                self.stop()
            }
        }

        // use inputFormat (NOT outputFormat)
        let format = inputNode.inputFormat(forBus: 0)

        guard format.sampleRate > 0, format.channelCount > 0 else {
            print("❌ Invalid audio format:", format)
            return
        }

        inputNode.installTap(onBus: 0,
                             bufferSize: 1024,
                             format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print("❌ AudioEngine start failed:", error)
        }
    }

    func stop() {
        audioEngine.stop()
        request?.endAudio()
        task?.cancel()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}

final class AudioRecorderService {

    private var recorder: AVAudioRecorder?
    private(set) var recordedURL: URL?

    func startRecording() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("voice.m4a")

        recordedURL = url

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.record()
        } catch {
            print("❌ Recording failed:", error)
        }
    }

    func stopRecording() {
        recorder?.stop()
    }
}

import AVFoundation

final class AudioPlayerService: NSObject, AVAudioPlayerDelegate {

    private var player: AVAudioPlayer?
    var onCompletion: (() -> Void)?

    func play(url: URL?) {
        guard let url = url else {
            print("❌ No URL")
            return
        }

        let exists = FileManager.default.fileExists(atPath: url.path)
        let size = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0

        print("🎧 File exists:", exists, "size:", size)

        guard exists, size > 0 else {
            print("❌ Audio file invalid or empty")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("❌ Playback failed:", error)
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }

    var isPlaying: Bool {
        player?.isPlaying ?? false
    }

    // MARK: - Delegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onCompletion?()
    }
}
