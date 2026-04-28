//
//  BackgroundVideoView.swift
//  PiKa
//
//  Created by Naveen on 25/04/26.
//

import SwiftUI
import AVKit
import Combine

struct BackgroundVideoView: UIViewRepresentable {
    
    let player: AVPlayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = UIScreen.main.bounds
        
        view.layer.addSublayer(layer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}


final class VideoPlayerManager: ObservableObject {

    let player: AVPlayer
    
    init() {
        guard let url = Bundle.main.url(forResource: "Auth_Background_Video", withExtension: "mp4") else {
            fatalError("Video not found")
        }
        
        self.player = AVPlayer(url: url)
        self.player.isMuted = false
        self.player.actionAtItemEnd = .none
        player.automaticallyWaitsToMinimizeStalling = false
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loop),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
    }
    
    @objc private func loop() {
        player.seek(to: .zero)
        player.play()
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
}
