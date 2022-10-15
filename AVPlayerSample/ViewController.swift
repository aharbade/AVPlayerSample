//
//  ViewController.swift
//  AVPlayerSample
//
//  Created by Anup Harbade on 10/15/22.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    private let playbackURLString = "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8"
    
    private var player: AVPlayer?
    private weak var playerView: PlayerView?
    private var timeObserverToken: Any?
    private var playerItemContext = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView = createPlayerView()
        do {
            try initiatePlayback(urlString: playbackURLString, playerLayer: playerView!.layer)
        } catch {
            print("Couldn't play the content from url - \(playbackURLString)")
        }
    }
    
    private func initiatePlayback(urlString: String, playerLayer: AVPlayerLayer) throws {
        guard let url = URL(string: urlString) else {
            throw PlaybackError(type: .invalidURL, message: "Invalid URL")
        }
        
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.status),
                               options: [.old, .new],
                               context: &playerItemContext)
        let player = AVPlayer(playerItem: playerItem)
        playerLayer.player = player
        self.player = player
        addPeriodicTimeObserver()
        player.play()
    }
    
    private func stopPlayback() {
        removePeriodicTimeObserver()
        player?.pause()
        player = nil
    }
    
    private func createPlayerView() -> PlayerView {
        let playerView = PlayerView()
        view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let playerLayer = playerView.layer
        playerLayer.videoGravity = .resizeAspect
        playerLayer.needsDisplayOnBoundsChange = true
        return playerView
    }
    
}

// MARK: Playback Observation
extension ViewController {
    
    private func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(1000)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: time,
                                                            queue: .main) {
            time in
            print("Playhead position: \(time.value)")
            
        }
    }
    
    private func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            switch status {
            case .readyToPlay:
                print("Player item is ready to play.")
            case .failed:
                print("Player item failed. See error.")
            case .unknown:
                print("Player item is not yet ready")
            default:
                print("Player item is \(status)")
            }
        }
    }
}

