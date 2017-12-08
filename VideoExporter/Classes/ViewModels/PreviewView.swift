
import UIKit
import AVKit
import AVFoundation

class PreviewView: UIView {
    
    var player: AVPlayer? {
        get {
            return self.playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    private var playerLayer: AVPlayerLayer {
        get {
            return self.layer as! AVPlayerLayer
        }
    }
    
    
    // UIView のサブクラスを作り layerClass をオーバーライドして AVPlayerLayer に差し替える
    override class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.afterInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.afterInit()
    }
    
    
    private func afterInit() {
        self.backgroundColor = UIColor.black
    }
    
    
    func setPlayer(url: URL) {
        var items: [AVPlayerItem] = [AVPlayerItem]()
        let item: AVPlayerItem = AVPlayerItem.init(url: url)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didPlay(_:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        items.append(item)
        let queue: AVQueuePlayer = AVQueuePlayer(items: items)
        self.player = queue
        self.player?.actionAtItemEnd = .none
        self.playerLayer.videoGravity = .resizeAspectFill
    }
    
    
    func stop() {
//        self.player?.pause()
        self.player = nil
    }
    
    
    @objc func didPlay(_ sender: Notification) {
        self.play()
    }
    
    func play() {
//        let seekTime: CMTime = CMTimeMake(0, 1)
        let seekTime: CMTime = kCMTimeZero
        self.player?.seek(to: seekTime)
        self.player?.play()
    }
    
    
    func removeLayer() {
        self.player = nil
    }
    
}
