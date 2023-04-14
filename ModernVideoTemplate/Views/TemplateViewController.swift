//
//  TemplateViewController.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 3.4.2023.
//

import UIKit
import Combine
import AVKit

final class TemplateViewController: UIViewController {
    
    private var player: AVPlayer?
    private var videoProgressObserver: Any?
    
    private var interactor: TemplateMakable?
    private weak var presenter: TemplatePresentable?
    
    private var subscriptions = Set<AnyCancellable>()
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var videoContainerView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var replayVideoButton: UIButton!
    @IBOutlet private weak var videoProgressView: UIProgressView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    init(interactor: inout TemplateMakable, presenter: TemplatePresenter) {
        super.init(nibName: String(describing: Self.self), bundle: nil)
        setup(interactor: &interactor, presenter: presenter)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        if let videoProgressObserver = videoProgressObserver {
            player?.removeTimeObserver(videoProgressObserver)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlayer()
        
        replayVideoButton.isHidden = true
        
        videoProgressView.progress = 0.0
        videoProgressView.observedProgress?.totalUnitCount = 1
        
        presenter?.processedImagePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.imageView.image = $0
            })
            .store(in: &subscriptions)
        
        presenter?.convertVideoResultSubject
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion  {
                    print(error.localizedDescription)
                }
            }, receiveValue: { [weak self] isProcessingSuccess in
                guard
                    isProcessingSuccess == true
                else {
                    return
                }
                
                self?.playVideoWithFileName(Resources.outputMovieUrl)
            })
            .store(in: &subscriptions)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator.startAnimating()
        
        let outputMovieURL = Resources.outputMovieUrl
        
        if FileManager.default.fileExists(atPath: outputMovieURL.absoluteString) == true {
            playVideoWithFileName(outputMovieURL)
        } else {
            createVideoTemplate()
        }
    }
    
    private func createVideoTemplate() {
        replayVideoButton.isHidden = true
        activityIndicator.startAnimating()
        
        interactor?.makeTemplate()
    }
    
    private func setupPlayer() {
        player = AVPlayer()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoContainerView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        
        videoContainerView.layer.addSublayer(playerLayer)
        
        videoProgressObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(value: 1, timescale: 10),
            queue: .main,
            using: { [weak self] progressTime in
                self?.updateProgressView(progressTime: progressTime)
            })
    }
    
    private func playVideoWithFileName(_ fileName: URL) {
        let playerItem = AVPlayerItem(url: fileName)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(playerDidFinishPlaying),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        
        player?.replaceCurrentItem(with: playerItem)
        player?.play()
        
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
    
    @objc
    private func playerDidFinishPlaying() {
        replayVideoButton.isHidden = false
    }
    
    @IBAction private func replayButtonTapped(_ sender: UIButton) {
        replayVideoButton.isHidden = true
        
        player?.seek(to: .zero)
        player?.play()
    }
    
    private func updateProgressView(progressTime: CMTime) {
        guard
            let duration = player?.currentItem?.duration
        else {
            videoProgressView.progress = .zero
            
            return
        }
        
        let result = duration.seconds / 100.0 * Double(progressTime.seconds)
        
        videoProgressView.progress = Float(result)
        videoProgressView.setProgress(videoProgressView.progress, animated: true)
    }
}

private extension TemplateViewController {
    
    func setup(interactor: inout TemplateMakable, presenter: TemplatePresentable) {
        let viewController = self
        viewController.presenter = presenter
        viewController.interactor = interactor
        interactor.presenter = presenter
    }
}
