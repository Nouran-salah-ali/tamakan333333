//
//  AudioRecordingViewModel.swift
//  voiceTamakan
//
//  Created by Nouran Salah
//

import AVFoundation
import Combine
import WhisperKit
import SwiftData
import SwiftUI

class AudioRecordingViewModel: ObservableObject {

    // MARK: - Published UI variables
    @Published var finalText: String = ""

    // MARK: - Audio
    private let audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    private var player: AVAudioPlayer?
    private var lastRecordingURL: URL?

    private var bufferQueue: [AVAudioPCMBuffer] = []

    // MARK: - Whisper model (single instance)
    private var whisper: WhisperKit?

    
    
   // @Environment(\.presentationMode) var presentationMode
   // @Environment(\.modelContext) private var context
    var context: ModelContext?
    // MARK: - Init (load model only once)
    init() {
        Task {
            do {
                print("⏳ Loading Whisper model...")
                //whisper = try await WhisperKit(WhisperKitConfig(model: "large"))
                whisper = try await WhisperKit(WhisperKitConfig(model: "medium"))
                print("✅ Whisper model loaded successfully")
            } catch {
                print("❌ Whisper init error:", error.localizedDescription)
            }
        }
    }


    // MARK: - Start Recording
    func startRecording() {

        // Request microphone and start session
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            print("🎙️ Session READY")
        } catch {
            print("❌ Session error:", error)
        }

        let inputNode = audioEngine.inputNode
        let format = inputNode.inputFormat(forBus: 0)

        let timestamp = Date().timeIntervalSince1970
        let fileName = "recording_\(timestamp).caf"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        lastRecordingURL = url
        //i created func that create object object
        //save object in context
        addRecord(RcordName :fileName, duration: 0.0 ,date: Date(), finalText: finalText ,url: url)
        

        do {
            audioFile = try AVAudioFile(forWriting: url, settings: format.settings)
            print("📁 File created: \(fileName)")
        } catch {
            print("❌ File creation error:", error)
        }

        bufferQueue.removeAll()
        inputNode.removeTap(onBus: 0)

        // Install audio tap
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            guard let self = self else { return }

            

            // Write buffer to main recording file
            do {
                try self.audioFile?.write(from: buffer)
            } catch {
                print("❌ Write error:", error)
            }

            self.bufferQueue.append(buffer)
            print("🎧 Captured audio: \(buffer.frameLength)")

            // Every ~2–3 seconds → process chunk
            let requiredFrames = AVAudioFrameCount(format.sampleRate * 2.5)
            let totalFrames = self.bufferQueue.reduce(0) { $0 + $1.frameLength }

            if totalFrames >= requiredFrames {
                let chunk = self.mergeBuffers(self.bufferQueue, format: format)
                self.bufferQueue.removeAll()

                let tempURL = self.saveBufferToFile(chunk)
                self.transcribeChunk(at: tempURL)
            }
        }

        // Start engine
        do {
            try audioEngine.start()
            print("▶️ Engine started")
        } catch {
            print("❌ Engine start error:", error)
        }
    }


    // MARK: - Stop Recording
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        print("⏹️ Engine stopped")
    }


    // MARK: - Play last recording
    func playRecording() {
        guard let url = lastRecordingURL else {
            print("⚠️ No recording found")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            print("🔊 Playing recording")
        } catch {
            print("❌ Playback error:", error)
        }
    }


    // MARK: - Transcription
    private func transcribeChunk(at url: URL) {
        Task { [weak self] in
            guard let self = self, let whisper = self.whisper else {
                print("⚠️ Whisper model not ready")
                return
            }

            do {
                print("⏳ Transcribing chunk...")

                let results = try await whisper.transcribe(audioPath: url.path)
                let text = results.first?.text ?? ""
                let raw = results.first?.text ?? ""

                DispatchQueue.main.async {
//                    if !text.isEmpty {
//                        self.finalText += text + " "
                        
                        // 1️⃣ Detect blocking (before cleaning)
                        if self.detectBlocking(raw) {
                            print("⛔ BLOCKING DETECTED (silent gap)")
                        }

                        // 2️⃣ Clean text from Whisper metadata
                        let cleaned = self.removeWhisperMetadata(from: raw)

                        // 3️⃣ Add only real human speech to UI
                        if !cleaned.isEmpty {
                            self.finalText += cleaned + " "
                        }

                        // 4️⃣ Stutter detection using cleaned version (optional)
                        if self.analyzeStutter(cleaned) {
                            print("🟥 Stuttering detected")
                        }
                        print("🟢🟢 Transcribed RAW:" , text)
                        print("🟢 Transcribed:" , cleaned)
//                    } else {
//                        print("⚠️ Empty transcription")
//                    }
                }

            } catch {
                print("❌ Transcription error:", error.localizedDescription)
            }
        }
    }

    // MARK: - Buffer merge
    private func mergeBuffers(_ buffers: [AVAudioPCMBuffer], format: AVAudioFormat) -> AVAudioPCMBuffer {
        let totalFrames = buffers.reduce(0) { $0 + $1.frameLength }
        guard let merged = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrames) else {
            return buffers[0]
        }

        merged.frameLength = totalFrames

        var offset: AVAudioFrameCount = 0
        for buffer in buffers {
            for ch in 0..<Int(format.channelCount) {
                let src = buffer.floatChannelData![ch]
                let dst = merged.floatChannelData![ch]
                memcpy(dst.advanced(by: Int(offset)),
                       src,
                       Int(buffer.frameLength) * MemoryLayout<Float>.size)
            }
            offset += buffer.frameLength
        }
        return merged
    }


    // MARK: - Save buffer to temp file
    private func saveBufferToFile(_ buffer: AVAudioPCMBuffer) -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("chunk.caf")

        do {
            let file = try AVAudioFile(forWriting: url, settings: buffer.format.settings)
            try file.write(from: buffer)
            print("📦 Chunk saved:", url.path)
        } catch {
            print("❌ Error saving chunk:", error)
        }

        return url
    }
    
    
    // MARK: - func save record in object

//    func addRecord(RcordName :String, duration: Double ,date: Date, finalText: String ,url: URL) {
//        let newRecord = RecordingModel(recordname: RcordName, duration: 0.0, date: date, transcript: finalText, audiofile: url)
//        //add record to arr
//        context.insert(newRecord)
//        print("📦📦📦📦📦📦OBJECT CREATED")
//    }
    
    // MARK: - Save new record
    func addRecord(RcordName: String, duration: Double, date: Date, finalText: String, url: URL) {

        guard let context else {
            print("❌ ERROR: No ModelContext found.")
            return
        }

        let newRecord = RecordingModel(
            recordname: RcordName,
            duration: duration,
            date: date,
            transcript: finalText,
            audiofile: url
        )

        context.insert(newRecord)

        print("📦 Record saved:", RcordName)
    }
    
    
    
    
    func analyzeStutter(_ rawText: String) -> Bool {
        let t = rawText.lowercased()
        
        // --------------------------------
        // 1️⃣ Whisper explicit annotations
        // --------------------------------
        if t.contains("[stutter") || t.contains("(stutter") || t.contains("stuttering") ||
           t.range(of: #"\[[a-z]\]"#, options: .regularExpression) != nil {
            print("🟥 STUTTER DETECTED (Whisper tag) →", rawText)
            return true
        }

        // --------------------------------
        // 2️⃣ Clean text for regex detection
        // --------------------------------
        let text = t
            .replacingOccurrences(of: "\\.+", with: " ", options: .regularExpression)   // remove "..."
            .replacingOccurrences(of: "[^a-z0-9\\s-]", with: "", options: .regularExpression) // remove punctuation
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)  // collapse spaces

        // --------------------------------
        // 3️⃣ Regex patterns
        // --------------------------------
        // Repeated WORDS: talk talk talk
        let repeatedWord = #"\b(\w+)(?:\s+\1){1,}\b"#

        // Repeated SYLLABLES: ta ta, com com (2-6 letters)
        let repeatedSyllable = #"\b([a-z]{2,6})\s+\1\b"#

        // Repeated LETTERS: sss, ffff
        let longRepeat = #"\b([a-z])\1{2,}\b"#

        // Dash-style: b-b-b, D-D-D-D-D
        let dashRepeat = #"\b([a-z])-+\1(?:-+\1){2,}\b"#

        let patterns = [repeatedWord, repeatedSyllable, longRepeat, dashRepeat]

        for pattern in patterns {
            if text.range(of: pattern, options: .regularExpression) != nil {
                print("🟥 STUTTER DETECTED (pattern) →", rawText)
                return true
            }
        }

        return false
    }
    
    ////////////////////////////////////////////////////
    

    func removeWhisperMetadata(from text: String) -> String {
        let bracketPattern = #"[\(\[\{\<][^\)\]\}\>]*[\)\]\}\>]"#
        let wordPattern = #"\b(laughs|sigh|sighs|noise|sizzling|stuttering)\b"#

        return text
            .replacingOccurrences(of: bracketPattern, with: "", options: .regularExpression)
            .replacingOccurrences(of: wordPattern, with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func detectBlocking(_ text: String) -> Bool {
        let lower = text.lowercased()

        return lower.contains("[blank") ||
               lower.contains("[silence") ||
               lower.contains("[no_speech")
    }

}
