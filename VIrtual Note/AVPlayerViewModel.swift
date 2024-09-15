//
//  AVPlayerViewModel.swift
//  ObjectQuickNote
//
//  Created by Pierre Rougeot on 15/09/2024.
//

import AVKit

@MainActor
@Observable
class AVPlayerViewModel: NSObject {

    enum Video: String {
        case step1 = "step1"
        case step2 = "step2"
        case step3 = "step3"
    }

    var isPlaying: Bool = false
    private var avPlayerViewController: AVPlayerViewController?
    private var avPlayer = AVPlayer()

    func makePlayerViewController() -> AVPlayerViewController {
        let avPlayerViewController = AVPlayerViewController()
        avPlayerViewController.player = avPlayer
        avPlayerViewController.delegate = self
        self.avPlayerViewController = avPlayerViewController
        return avPlayerViewController
    }

    func play(_ video: Video) {
        guard let videoURL = URL(string:"http://pierre.rougeot.free.fr/VisionNote/\(video.rawValue).mov") else { return }

        let item = AVPlayerItem(url: videoURL)
        avPlayer.replaceCurrentItem(with: item)
        avPlayer.play()
    }

    func reset() {
        guard isPlaying else { return }
        isPlaying = false
        avPlayer.replaceCurrentItem(with: nil)
        avPlayerViewController?.delegate = nil
    }
}

extension AVPlayerViewModel: AVPlayerViewControllerDelegate {
    nonisolated func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        Task { @MainActor in
            reset()
        }
    }
}
