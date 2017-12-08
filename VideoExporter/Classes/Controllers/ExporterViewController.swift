
import UIKit

class ExporterViewController: UIViewController {
    
    @IBOutlet weak var previousButton: DefaultButton!
    @IBOutlet weak var exportButton: DefaultButton!
    
    @IBOutlet weak var previewView: PreviewView!
    
    @IBOutlet weak var sampleView: UIView!
    
    
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
    
    
    private func close() {
        self.dismiss(animated: true, completion: { () -> Void in
            self.previewView.removeLayer()
        })
    }
    
    
    private func export() {
        guard let url: URL = self.videoUrl else {
            self.close()
            return
        }
        VideoExporter.sharedInstance.export(videoUrl: url, views: [sampleView], volume: 1.0) { (error: Bool, message: String) in
//            previewView.stop()
            print(message)
            self.close()
        }
    }
    
}
