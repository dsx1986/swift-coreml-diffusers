import SwiftUI

extension CGImage {
    static func fromData(_ imageData: Data) -> CGImage? {
        #if os(iOS)
        if let uiImage = UIImage(data: imageData) {
            return uiImage.cgImage
        }
        #elseif os(macOS)
        if let nsImage = NSImage(data: imageData) {
            return nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
        }
        #endif
        return nil
    }
}
