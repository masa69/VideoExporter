
import UIKit
import Photos

class VideoExporterViewController: UIViewController {
    
    @IBOutlet weak var previousButton: DefaultButton!
    @IBOutlet weak var exportButton: DefaultButton!
    
    @IBOutlet weak var previewView: PreviewView!
    
    @IBOutlet weak var sampleView: UIView!
    
    @IBOutlet weak var volumeSwitch: UISwitch!
    
    
    var videoUrl: URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FileManager.forbidBackupToiCloud()
        self.initView()
        self.initButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.videoUrl == nil {
            self.close()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let url: URL = self.videoUrl {
            previewView.setPlayer(url: url)
            previewView.play()
        }
    }
    
    
    private func initView() {
        self.sampleView.backgroundColor = UIColor.clear
    }
    
    
    private func initButton() {
        previousButton.touchDown = {
            self.close()
        }
        
        exportButton.touchDown = {
            self.export()
        }
    }
    
    
    private func export() {
        guard let url: URL = self.videoUrl else {
            self.close()
            return
        }
        
        let exporter: VideoExporter = VideoExporter(to: FileManager.videoExportURL, type: .mp4)
//        exporter.quality = .AVAssetExportPresetHighestQuality
//        exporter.quality = .AVAssetExportPresetMediumQuality
        exporter.quality = .AVAssetExportPreset640x480
//        exporter.quality = .AVAssetExportPreset1280x720
//        exporter.quality = .AVAssetExportPreset960x540
        exporter.volume = (volumeSwitch.isOn) ? 1.0 : 0.0
        exporter.views = [sampleView]
        exporter.export(url: url) { (error: Bool, message: String) in
            let res = FileManager().fileSize(atPath: FileManager.videoExportPath)
            print(res.size.mb)
            if error {
                let alert: UIAlertController = UIAlertController(title: "error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                    self.close()
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            // 端末に保存
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exporter.outputUrl)
            }, completionHandler: { (success: Bool, error: Error?) in
                if success {
                    self.close()
                    return
                }
                var message: String = "failed: save to Library"
                if let err: Error = error {
                    message = err.localizedDescription
                }
                let alert: UIAlertController = UIAlertController(title: "error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                    self.close()
                }))
                self.present(alert, animated: true, completion: nil)
            })
            
        }
    }
    
    
    private func close() {
        self.dismiss(animated: true, completion: { () -> Void in
            self.previewView.removeLayer()
        })
    }
    
}
