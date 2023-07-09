//
//  MediaPlayer.swift
//  WestNews
//
//  Created by Alex Westerlund on 4/17/23.
//

import SwiftUI
import AVFoundation

struct MediaPlayer: View {
    var autoPlay: Bool
    var todaysIsTrueLatestIsFalse: Bool
    let tap = UISelectionFeedbackGenerator()

    @State private var player: AVPlayer?
    
    @State private var selectedURL: String = ""
    @State private var URLList: [String] = []
    
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var totalTime: TimeInterval = 0
    @State private var playerItemStatusObserver: NSKeyValueObservation?
    @State private var progress: Double = 0
    @State private var audioFileDate: String = ""
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 50)
                    .cornerRadius(12)
                HStack {
                    Button(action: {
                        rewind15Seconds()
                        tap.selectionChanged()
                        tap.prepare()
                    }) {
                        Image(systemName: "gobackward.15")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 27, height: 27)
                    }
                    .foregroundColor(Color("AccentColorButDarker"))
                    .padding(.leading, 11)
                    .padding(.bottom, 2)
                    Button(action: {
                        togglePlayPause()
                        tap.selectionChanged()
                        tap.prepare()
                    }) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                    .foregroundColor(Color("AccentColorButDarker"))
                    .padding(.horizontal, 6)
                    ProgressView(value: progress, total: 1)
                        .tint(Color(.systemGray))
                    Text(totalTime > 0 ? timeString(from: totalTime - currentTime) : "   ")
                        .frame(width: 37, alignment: .leading)
                    Divider()
                        .frame(maxHeight: 36)
                    Text(audioFileDate)
                        .font(.footnote)
                        .fontWeight(.heavy)
                        .padding(.trailing, 12)
                }
            }
        }
        .onAppear {
            configureAudioSession()
            fetchAndPrepareAudioPlayer()
        }
        .onDisappear {
            // Clean up the player when the view disappears
            player?.pause()
            player = nil
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        }
    }
    
    //FUNCTIONS
    
    // Sets up the audio session for playback.
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    // Fetches the audio URL and prepares the audio player for streaming.
    private func fetchAndPrepareAudioPlayer() {
        fetchAudioURL { audioURLString in
            DispatchQueue.main.async {
                if let audioURLString = audioURLString, let audioURL = URL(string: audioURLString) {
                    let fileName = audioURL.deletingPathExtension().lastPathComponent
                    self.preparePlayer(url: audioURL, fileName: fileName)
                } else {
                    // Use the locally hosted audio file
                    if let localAudioURL = Bundle.main.url(forResource: "WeekendMusic", withExtension: "mp3") {
                        self.preparePlayer(url: localAudioURL, fileName: "WeekendMusic")
                    } else {
                        print("Failed to load the local audio file: WeekendMusic.mp3")
                    }
                }
            }
        }
    }

    // Fetches the audio URL from the API
    private func fetchAudioURL(completion: @escaping (String?) -> Void) {
        let HerokuURL = todaysIsTrueLatestIsFalse ? "https://vast-oasis-01920.herokuapp.com/todaysaudio" : "https://vast-oasis-01920.herokuapp.com/latestbroadcasts"
        guard let url = URL(string: HerokuURL) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    var audioURLString: String? = nil

                    if todaysIsTrueLatestIsFalse, let urlString = json?["url"] as? String {
                        audioURLString = urlString
                    } else if let urlArray = json?["urls"] as? [String], !urlArray.isEmpty {
                        audioURLString = urlArray[0] // Choose the first URL in the array
                        URLList = urlArray
                    }
                    completion(audioURLString)
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                print("Error fetching streaming link: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }.resume()
    }

    // Sets up the AVPlayer with the given URL and filename.
    private func preparePlayer(url: URL, fileName: String) {
        let playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: playerItem)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: .main) { _ in
            self.playerItemDidPlayToEndTime()
        }
        addPeriodicTimeObserver()
        self.audioFileDate = formatAudioFileDate(from: fileName)
        
        self.playerItemStatusObserver = playerItem.observe(\.status, changeHandler: { item, _ in
            if item.status == .readyToPlay {
                self.totalTime = CMTimeGetSeconds(item.duration)
            }
        })
        
        if autoPlay {
            player?.play()
            isPlaying = true
        }
    }
    
    // Extracts the date from the file name
    func formatAudioFileDate(from fileName: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if fileName.contains("backup") {
            return "Weekend\nMusic"
        } else if let date = dateFormatter.date(from: fileName) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
            
            let monthAbbreviations: [String] = ["Jan", "Feb", "March", "April", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"]
            
            if let month = components.month, let day = components.day {
                let monthString = monthAbbreviations[month - 1]
                let dateString = "\(monthString)\n\(day)"
                let suffix = getOrdinalSuffixFromDate(from: date)
                return "\(dateString)\(suffix)"
            } else {
                return "Invalid date"
            }
        } else {
            return "Weekend\nMusic"
        }
    }

    // Returns an ordinal suffix (from Date() format)
    func getOrdinalSuffixFromDate(from date: Date) -> String {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: date)

        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }

    // Plays/pauses current audio
    private func togglePlayPause() {
        isPlaying.toggle()
        isPlaying ? player?.play() : player?.pause()
    }

    // Rewinds 15 seconds
    private func rewind15Seconds() {
        if let currentTime = player?.currentTime() {
            let newTime = max(CMTimeGetSeconds(currentTime) - 15, 0)
            player?.seek(to: CMTimeMakeWithSeconds(newTime, preferredTimescale: 1))
        }
    }

    // Tracks playback progress for UI
    private func addPeriodicTimeObserver() {
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { time in
            self.currentTime = CMTimeGetSeconds(time)
            self.totalTime = CMTimeGetSeconds(player?.currentItem?.duration ?? .zero)
            if self.totalTime > 0 {
                self.progress = self.currentTime / self.totalTime
            }
        }
    }

    // Returns a human-readable timestamp
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Resets the player to the beginning when playback ends
    private func playerItemDidPlayToEndTime() {
        DispatchQueue.main.async {
            self.player?.seek(to: CMTime.zero)
            self.isPlaying = false
        }
    }
}



struct MediaPlayer_Previews: PreviewProvider {
    static var previews: some View {
        MediaPlayer(autoPlay: false, todaysIsTrueLatestIsFalse: false)
    }
}
