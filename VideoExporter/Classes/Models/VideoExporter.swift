
import UIKit
import AVFoundation
import Photos

/*
 https://qiita.com/edo_m18/items/cf3a183ad73bb711b195
 https://qiita.com/masapp/items/dd0589d2a894a2a32b82
 
 1. 合成を実行するAVMutableCompositionオブジェクトを作る
 2. AVAssetオブジェクトの生成と、オブジェクトから動画部分と音声部分のトラック情報をそれぞれ取得する
 3. トラック合成用のAVMutableCompositionTrackを、AVMutableCompositionから生成する
 4. (3)で生成したトラックに動画・音声を登録する
 5. 動画の合成命令用オブジェクトを生成（AVMutableVideoCompositionInstructionとAVMutableVideoCompositionLayerInstruction）
 6. 動画合成オブジェクト（AVMutableVideoComposition）を生成
 7. 音声合成用パラメータオブジェクトの生成（AVMutableAudioMixInputParameters）
 8. 音声合成用オブジェクトを生成（AVMutableAudioMix）
 9. 動画情報（AVAssetTrack）から回転状態を判別する
 10. 回転情報を元に、合成、生成する動画のサイズを決定する
 11. 合成動画の情報を設定する
 12. 動画出力用オブジェクトを生成する
 13. 保存設定を行い、Exportを実行
*/

class VideoExporter {
    
    static var sharedInstance: VideoExporter = VideoExporter()
    
    
    public func export(videoUrl: URL, views: [UIView], volume: Float, completion: @escaping (_ error: Bool, _ message: String) -> Void) {
        
        // 1. 合成を実行するAVMutableCompositionオブジェクトを作る
        let mutableComposition: AVMutableComposition = AVMutableComposition()
        
        // 2. AVAssetオブジェクトの生成と、オブジェクトから動画部分と音声部分のトラック情報をそれぞれ取得する
        let videoAsset: AVURLAsset = AVURLAsset(url: videoUrl, options: nil)
        let videoTrack: AVAssetTrack = videoAsset.tracks(withMediaType: .video)[0]
        let audioTrack: AVAssetTrack = videoAsset.tracks(withMediaType: .audio)[0]
        
        // 3. トラック合成用のAVMutableCompositionTrackを、AVMutableCompositionから生成する
        guard let compositionVideoTrack: AVMutableCompositionTrack = mutableComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(true, "failed: addMutableTrack(.video)")
            return
        }
        guard let compositionAudioTrack: AVMutableCompositionTrack = mutableComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(true, "failed: addMutableTrack(.audio)")
            return
        }
        
        // 4. (3)で生成したトラックに動画・音声を登録する
        try? compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration), of: videoTrack, at: kCMTimeZero)
        try? compositionAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, audioTrack.timeRange.duration), of: audioTrack, at: kCMTimeZero)
        
        // 9. 動画情報（AVAssetTrack）から回転状態を判別する
        // 動画の回転情報を取得する
        let tf: CGAffineTransform = videoTrack.preferredTransform
        
        // Portrait = 縦向き
        let isPortrait: Bool = (tf.a == 0 && tf.d == 0 && (tf.b == 1.0 || tf.b == -1.0) && (tf.c == 1.0 || tf.c == -1.0))
            ? true : false
        
        // 10. 回転情報を元に、合成、生成する動画のサイズを決定する
        let originVideoSize: CGSize = videoTrack.naturalSize
        let videoSize: CGSize = (isPortrait)
            ? CGSize(width: originVideoSize.height, height: originVideoSize.width)
            : originVideoSize
        
        /*let originVideoSize: CGSize = videoTrack.naturalSize
        
        let size: CGSize = videoTrack.naturalSize
        let tf: CGAffineTransform = videoTrack.preferredTransform
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        let maxSize: CGFloat = (size.width > size.height) ? size.width : size.height
        let minSize: CGFloat = (size.width > size.height) ? size.height : size.width
        
        if tf.tx == size.width && tf.ty == size.height {
            width = maxSize
            height = minSize
        } else if tf.tx == 0 && tf.ty == 0  {
            width = maxSize
            height = minSize
        } else {
            width = minSize
            height = maxSize
        }
        
        let videoSize: CGSize = CGSize(width: width, height: height)*/
//        let videoSize: CGSize = videoTrack.naturalSize
        
        // 5. 動画の合成命令用オブジェクトを生成（AVMutableVideoCompositionInstructionとAVMutableVideoCompositionLayerInstruction）
        let instruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration)
        let layerInstruction: AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        
        // 動画が縦向きだったら90度回転させる
        if isPortrait {
            let tf1: CGAffineTransform = CGAffineTransform(translationX: originVideoSize.height, y: 0)
            let tf2: CGAffineTransform = tf1.rotated(by: CGFloat(Double.pi / 2))
            // setTransform(CGAffineTransform, at: CMTime)
            layerInstruction.setTransform(tf2, at: kCMTimeZero)
        }
        
        instruction.layerInstructions = [layerInstruction]
        
        // 6. 動画合成オブジェクト（AVMutableVideoComposition）を生成
        let videoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        videoComposition.instructions = [instruction]
        
        // 7. 音声合成用パラメータオブジェクトの生成（AVMutableAudioMixInputParameters）
        let audioMixInputParameters: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: compositionAudioTrack)
        audioMixInputParameters.setVolumeRamp(fromStartVolume: volume, toEndVolume: volume, timeRange: CMTimeRangeMake(kCMTimeZero, mutableComposition.duration))
        
        // 8. 音声合成用オブジェクトを生成（AVMutableAudioMix）
        let audioMix: AVMutableAudioMix = AVMutableAudioMix()
        audioMix.inputParameters = [audioMixInputParameters]
        
        // xx. 途中追加処理 (画像を合成するための準備)
        // 親レイヤーを作成
        let parentLayer: CALayer = CALayer()
        let videoLayer: CALayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
        videoLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
        parentLayer.addSublayer(videoLayer)
        
        // 動画に重ねる画像を追加
        for view in views {
            if let image: UIImage = view.toImage() {
                let imageLayer: CALayer = CALayer()
                imageLayer.contents = image.cgImage
                imageLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
//                imageLayer.frame = view.frame
                // Ratina対応
                imageLayer.contentsScale = UIScreen.main.scale
                parentLayer.addSublayer(imageLayer)
            }
        }
        
        // 11. 合成動画の情報を設定する
        videoComposition.renderSize = videoSize
        videoComposition.frameDuration = CMTimeMake(1, 30)
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        // 12. 動画出力用オブジェクトを生成する
        // 動画削除
        FileManager.sharedInstance.remove(atPath: FileManager.videoExportPath)
        // 画質 (AVAssetExportPreset)
//        let quality: String = AVAssetExportPresetHighestQuality
//        let quality: String = AVAssetExportPresetMediumQuality
        let quality: String = AVAssetExportPreset640x480
        guard let exportSession: AVAssetExportSession = AVAssetExportSession(asset: mutableComposition, presetName: quality) else {
            completion(true, "failed: AVAssetExportSession.init")
            return
        }
        /*guard let exportSession: AVAssetExportSession = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetMediumQuality) else {
            completion(true, "failed: AVAssetExportSession.init")
            return
        }*/
        // 13. 保存設定を行い、Exportを実行
        exportSession.videoComposition = videoComposition
        exportSession.audioMix = audioMix
        exportSession.outputFileType = AVFileType.mp4
        exportSession.outputURL = FileManager.videoExportURL
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously(completionHandler: {
            switch exportSession.status {
            case .completed:
                // 端末に保存
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: FileManager.videoExportURL)
                }, completionHandler: { (success: Bool, error: Error?) in
                    if success {
                        completion(false, "success")
                        return
                    }
                    guard let err: Error = error else {
                        completion(true, "failed: save to Library")
                        return
                    }
                    completion(true, err.localizedDescription)
                })
            default:
                completion(true, "failed: export")
            }
            
        })
    }
}
