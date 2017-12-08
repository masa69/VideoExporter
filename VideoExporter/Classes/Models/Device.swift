
import Foundation
import AVFoundation

class Device {
    
    enum PrivacyAccess {
        case camera
        case audio
    }
    
    
    public static func request(usage: PrivacyAccess, callback: @escaping (_ isAuthorized: Bool) -> Void) {
        switch usage {
        case .camera:// カメラのアクセス許可チェック
            self.avCaptureDeviceRequestAccess(forMediaType: AVMediaType.video.rawValue) { (isAuthorized: Bool) in
                callback(isAuthorized)
            }
        case .audio:// マイクのアクセス許可チェック
            self.avCaptureDeviceRequestAccess(forMediaType: AVMediaType.audio.rawValue) { (isAuthorized: Bool) in
                callback(isAuthorized)
            }
        }
    }
    
    
    // private カメラ、音声のアクセス許可チェック
    private static func avCaptureDeviceRequestAccess(forMediaType: String, callback: @escaping (_ isAuthorized: Bool) -> Void) {
        
        let videoStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: forMediaType))
        
        switch videoStatus {
        case .authorized:// アクセスを許可している
            callback(true)
            return
        case .notDetermined:// 初回起動
            AVCaptureDevice.requestAccess(for: AVMediaType(rawValue: forMediaType), completionHandler: { (granted: Bool) -> Void in
                // granted = true 許可された時の処理
                if granted {
                    callback(true)
                    return
                }
                callback(false)
            })
            return
        case .restricted:
            callback(false)
            return
        case .denied:// アクセス拒否している
            callback(false)
            return
        }
    }
}
