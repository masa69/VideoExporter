
import UIKit

class DefaultButton: UIButton {
    
    var touchDown: (() -> Void)?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.afterInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.afterInit()
    }
    
    
    private func afterInit() {
        self.titleLabel?.font = UIFont.systemFont(ofSize: 12.0, weight: .semibold)
        self.tintColor = UIColor.black
        self.addTarget(self, action: #selector(self.onTouchDown(_:)), for: .touchDown)
    }
    
    
    @objc func onTouchDown(_ sender: UIButton) {
        self.touchDown?()
    }
    
}
