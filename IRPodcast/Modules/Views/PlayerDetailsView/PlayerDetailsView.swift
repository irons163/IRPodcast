//
//  PlayerDetailsView.swift
//  IRPodcast
//
//  Created by Phil on 2021/4/27.
//

import UIKit
import AVKit
import MediaPlayer
import SDWebImage
import IRHTTPCache

// FIXME: Fix spacing between title and author labels.
// FIXME: Extract mini player in its own class
// FIXME: Write MediaPlayerService and AVService

class PlayerDetailsView: UIView {

    // MARK: - Properties
    // MARK: Internal
    var episode: Episode! {
        didSet {
            miniTitleLabel.text = episode.title
            titleLabel.text = episode.title
            authorLabel.text = episode.author

            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)

            setupNowPlayingInfo()
            setupAudioSession()
            playEpisode()

            guard let url = URL(string: episode.imageUrl?.httpsUrlString ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
            miniEpisodeImageView.sd_setImage(with: url)

            miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
                let image = self.episodeImageView.image ?? UIImage()
                let artworkItem = MPMediaItemArtwork(boundsSize: .zero, requestHandler: { size -> UIImage in
                    return image
                })
                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artworkItem
            }
        }
    }

    var playlistEpisodes = [Episode]()
    var panGesture: UIPanGestureRecognizer!

    // MARK: Fileprivate
    private let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()

    private let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)

    // MARK: - Outlets
    @IBOutlet weak var maximizedStackView: UIStackView!

    @IBOutlet private weak var currentTimeSlider: UISlider!
    @IBOutlet private weak var currentTimeLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!

    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 2
        }
    }

    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(playPause), for: .touchUpInside)
        }
    }

    @IBOutlet private weak var volumeSlider: UISlider! {
        didSet {
            volumeSlider.value = AVAudioSession.sharedInstance().outputVolume
        }
    }

    @IBOutlet private weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.clipsToBounds = true
            episodeImageView.transform = shrunkenTransform
        }
    }

    // MARK: - Mini player outlets
    @IBOutlet weak var miniPlayerView: UIView!

    @IBOutlet private weak var miniEpisodeImageView: UIImageView!
    @IBOutlet private weak var miniTitleLabel: UILabel!

    @IBOutlet private weak var miniPlayPauseButton: UIButton! {
        didSet {
            miniPlayPauseButton.addTarget(self, action: #selector(playPause), for: .touchUpInside)
            miniPlayPauseButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }
    }

    @IBOutlet private weak var miniFastForwardButton: UIButton! {
        didSet {
            miniFastForwardButton.addTarget(self, action: #selector(fastForward(_:)), for: .touchUpInside)
            miniFastForwardButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
    }

    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()

        setupHTTPCache()
        setupGestures()
        setupRemoteControl()
        setupInterruptionObserver()

        observePlayerCurrentTime()
        observeBoundaryTime()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
    }

    func setupHTTPCache() {
        IRHTTPCache.logSetConsoleLogEnable(true)
        do {
            try IRHTTPCache.proxyStart()
            NSLog("Proxy Start Success");
        } catch {
            NSLog("Proxy Start Failure");
        }
        
        IRHTTPCache.encodeSetURLConverter { (URL) -> URL? in
            NSLog("URL Filter reviced URL")
            return URL
        }
        
        IRHTTPCache.downloadSetUnacceptableContentTypeDisposer { (URL, contentType) -> Bool in
            NSLog("Unsupport Content-Type Filter reviced URL")
            return false
        }
    }
}

// MARK: - Actions
extension PlayerDetailsView {

    @IBAction private func handleCurrentTimeSliderChange(_ sender: Any) {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)

        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
        player.seek(to: seekTime)
    }

    @IBAction private func dismiss(_ sender: Any) {
        let mainTabBarController = UIApplication.mainTabBarController
        mainTabBarController?.minimizePlayerDetails()
    }

    @objc private func playPause() {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
            setupElapsedTime(playbackRate: 1)
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
            setupElapsedTime(playbackRate: 0)
        }
    }

    @IBAction private func rewind(_ sender: Any) {
        seekToCurrentTime(delta: -15)
    }

    @IBAction private func fastForward(_ sender: Any) {
        seekToCurrentTime(delta: 15)

    }

    @IBAction private func changeVolume(_ sender: UISlider) {
        player.volume = sender.value
        // TODO: Set value when volume change by pressing hardware buttons
    }
}

extension PlayerDetailsView {

    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }

    private func seekToCurrentTime(delta: Int64) {
        let seconds = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), seconds)
        player.seek(to: seekTime)
    }

    private func setupElapsedTime(playbackRate: Float) {
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
    }

    private func setupNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionError {
            print("\n\t\tFailed to activate session:", sessionError)
        }
    }

    private func playEpisode() {
        if episode.fileUrl != nil {
            playEpisodeUsingFileUrl()
        } else {
            print("\n\t\tTrying to play episode at url:", episode.streamUrl.httpsUrlString)
            guard let url = IRHTTPCache.proxyURL(
                withOriginalURL: URL.init(string: episode.streamUrl.httpsUrlString)
            ) else { return }
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
            player.play()
        }
    }

    private func playEpisodeUsingFileUrl() {
        print("\n\t\tAttempt to play episode with file url:", episode.fileUrl ?? "")

        guard let fileUrl = URL(string: episode.fileUrl ?? "") else { return }
        let fileName = fileUrl.lastPathComponent

        guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        trueLocation.appendPathComponent(fileName)
        print("\n\t\tTrue Location of episode:", trueLocation.absoluteString)
        let playerItem = AVPlayerItem(url: trueLocation)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }

    private func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTimeLabel.text = time.toDisplayString()
            let durationTime = self?.player.currentItem?.duration
            self?.durationLabel.text = durationTime?.toDisplayString()

            self?.updateCurrentTimeSlider()
        }
    }

    private func observeBoundaryTime() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]

        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            print("\n\t\tEpisode started playing")
            self?.enlargeEpisodeImageView()
            self?.setupLockscreenDuration()
        }
    }

    private func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds

        self.currentTimeSlider.value = Float(percentage)
    }

    private func enlargeEpisodeImageView() {
        UIView.animate(
            withDuration: 0.75,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            options: .curveEaseOut
        ) {
            self.episodeImageView.transform = .identity
        }
    }

    private func shrinkEpisodeImageView() {
        UIView.animate(
            withDuration: 0.75,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            options: .curveEaseOut
        ) {
            self.episodeImageView.transform = self.shrunkenTransform
        }
    }
}

// MARK: - Gestures
extension PlayerDetailsView {

    // MARK: - Internal
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            handlePanChanged(gesture: gesture)
        } else if gesture.state == .ended {
            handlePanEnded(gesture: gesture)
        }
    }

    @objc func handleMaximize() {
        UIApplication.mainTabBarController?.maximizePlayerDetails(episode: nil)
    }

    // MARK: - Fileprivate
    private func setupGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMaximize)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        miniPlayerView.addGestureRecognizer(panGesture)

        maximizedStackView.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan(gesture:)))
        )
    }

    private func handlePanChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        self.miniPlayerView.alpha = 1 + translation.y / 200
        self.maximizedStackView.alpha = -translation.y / 200
    }

    private func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        print("\n\t\tEnded:", velocity.y)

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1,
            options: .curveEaseOut
        ) {
            self.transform = .identity
            if translation.y < -200 || velocity.y < -500 {
                self.handleMaximize()
            } else {
                self.miniPlayerView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
        }
    }

    @objc private func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            let translation = gesture.translation(in: superview)
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        } else if gesture.state == .ended {
            let translation = gesture.translation(in: superview)

            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 1,
                options: .curveEaseOut
            ) {
                self.maximizedStackView.transform = .identity

                if translation.y > 50 {
                    UIApplication.mainTabBarController?.minimizePlayerDetails()
                }
            }
        }
    }
}

// MARK: - Background playing and Remote control
extension PlayerDetailsView {

    private func setupRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()

        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { _ -> MPRemoteCommandHandlerStatus in
            self.player.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)

            self.setupElapsedTime(playbackRate: 1)
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { _ -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)

            self.setupElapsedTime(playbackRate: 0)
            return .success
        }

        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { _ -> MPRemoteCommandHandlerStatus in
            self.playPause()
            return .success
        }

        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePrevTrack))
    }

    @objc private func handleNextTrack() -> MPRemoteCommandHandlerStatus {
        if playlistEpisodes.isEmpty { return .commandFailed }

        let currentEpisodeIndex = playlistEpisodes.firstIndex { episode -> Bool in
            return self.episode.title == episode.title && self.episode.author == episode.author
        }

        guard let index = currentEpisodeIndex else { return .commandFailed }

        let nextEpisode: Episode
        if index == playlistEpisodes.count - 1 {
            nextEpisode = playlistEpisodes[0]
        } else {
            nextEpisode = playlistEpisodes[index + 1]
        }

        self.episode = nextEpisode
        
        return .success
    }

    @objc private func handlePrevTrack() -> MPRemoteCommandHandlerStatus {
        if playlistEpisodes.isEmpty { return .commandFailed }

        let currentEpisodeIndex = playlistEpisodes.firstIndex { episode -> Bool in
            return self.episode.title == episode.title && self.episode.author == episode.author
        }

        guard let index = currentEpisodeIndex else { return .commandFailed }

        let prevEpisode: Episode
        if index == 0 {
            let count = playlistEpisodes.count
            prevEpisode = playlistEpisodes[count - 1]
        } else {
            prevEpisode = playlistEpisodes[index - 1]
        }

        self.episode = prevEpisode
        
        return .success
    }

    private func setupInterruptionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }

    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }

        if type == AVAudioSession.InterruptionType.began.rawValue {
            print("\n\t\tInterruption began")
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        } else {
            print("\n\t\tInterruption ended")
            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                player.play()
                playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
        }
    }

    private func setupLockscreenDuration() {
        guard let duration = player.currentItem?.duration else { return }
        let durationSeconds = CMTimeGetSeconds(duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationSeconds
    }
}
