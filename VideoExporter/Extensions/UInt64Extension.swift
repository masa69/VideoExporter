
extension UInt64 {
    var mb: String {
        get {
            let temp: UInt64 = self * 10 / 1024 / 1024
            let size: Double = Double(temp / 10)
            return "\(size)MB"
        }
    }
}
