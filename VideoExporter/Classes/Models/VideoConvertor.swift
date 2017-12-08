
import UIKit
import AVFoundation

class VideoConvertor {
    
    static func mp4(url: URL, to: URL, callback: @escaping (_ error: Bool, _ message: String) -> Void) {
        let asset: AVURLAsset = AVURLAsset(url: url)
        self.mp4(asset: asset, to: to) { (error: Bool, message: String) in
            callback(error, message)
        }
    }
    
    
    static func mp4(asset: AVURLAsset, to: URL, callback: @escaping (_ error: Bool, _ message: String) -> Void) {
        // 60秒以上の動画はエラー
        if asset.duration.seconds > 60 {
//            print("duration is \(asset.duration.seconds)")
            callback(true, "error: within 59s")
            return
        }
//        let quality: String = AVAssetExportPresetHighestQuality
//        let quality: String = AVAssetExportPresetMediumQuality
//        let quality: String = AVAssetExportPreset640x480
        let quality: String = AVAssetExportPreset1280x720
        if let exportSession: AVAssetExportSession = AVAssetExportSession(asset: asset, presetName: quality) {
            exportSession.outputFileType = AVFileType.mp4
            exportSession.outputURL = to
            exportSession.exportAsynchronously(completionHandler: {
                switch exportSession.status {
                case .completed:
                    DispatchQueue.main.async {
                        callback(false, "")
                    }
                default:
                    DispatchQueue.main.async {
                        callback(true, "動画を変換することができませんでした")
                    }
                }
            })
            return
        }
        callback(true, "動画を読込むことができませんでした")
        
        
        /*FileManager().remove(atPath: FileManager.tempVideoUploadPath)
        
        let movie: GPUImageMovie = GPUImageMovie(url: videoURL)
        let tracks: [AVAssetTrack] = asset.tracks(withMediaType: AVMediaTypeVideo)
        let track: AVAssetTrack = tracks.first!
//            let writer: GPUImageMovieWriter = GPUImageMovieWriter(movieURL: FileManager.videoUploadURL, size: track.naturalSize, fileType: AVFileTypeMPEG4, outputSettings: nil)
        let writer: GPUImageMovieWriter = GPUImageMovieWriter(movieURL: FileManager.videoUploadURL, size: track.naturalSize)
        let filter: GPUImagePolkaDotFilter = GPUImagePolkaDotFilter()
        
        movie.addTarget(filter)
        filter.addTarget(writer)
        
        writer.assetWriter.movieFragmentInterval = kCMTimeInvalid
        writer.shouldPassthroughAudio = true
        writer.encodingLiveVideo = false
        
        movie.playAtActualSpeed = true
        movie.audioEncodingTarget = writer
        movie.enableSynchronizedEncoding(using: writer)
        
        writer.completionBlock = {
            print("completionBlock")
            writer.finishRecording(completionHandler: {
                movie.cancelProcessing()
                DispatchQueue.main.async {
                    picker.dismiss(animated: true, completion: {
                        /*if isError {
                            let alert: UIAlertController = UIAlertController.simple(title: "読込みエラー", message: message)
                            self.present(alert, animated: true, completion: nil)
                            return
                        }*/
                        self.gotoPreview(previewVideoUrl: FileManager.videoUploadURL, thumbnailUrl: FileManager.thumbnailUploadURL)
                    })
                }
            })
        }
        
        movie.startProcessing()
        writer.startRecording()*/
    }
}
