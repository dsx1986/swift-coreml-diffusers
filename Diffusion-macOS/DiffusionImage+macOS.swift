import SwiftUI
import UniformTypeIdentifiers

extension DiffusionImage {
    
    /// Instance func to place the generated image on the file system and return the `fileURL` where it is stored.
    func save(cgImage: CGImage, filename: String?) -> URL? {
        
        #if os(iOS)
        let uiImage = UIImage(cgImage: cgImage)  // Use UIImage for iOS
        #elseif os(macOS)
        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))  // Use NSImage for macOS
        #endif
        
        let appSupportURL = Settings.shared.tempStorageURL()
        let fn = filename ?? "diffusion_generated_image"
        let fileURL = appSupportURL
            .appendingPathComponent(fn)
            .appendingPathExtension("png")
        
        // Save the image as a temporary file
        #if os(iOS)
        if let pngData = uiImage.pngData() {
            do {
                try pngData.write(to: fileURL)
                return fileURL
            } catch {
                print("Error saving image to temporary file: \(error)")
            }
        }
        #elseif os(macOS)
        if let pngData = pngData(from: nsImage) {
            do {
                try pngData.write(to: fileURL)
                return fileURL
            } catch {
                print("Error saving image to temporary file: \(error)")
            }
        }
        #endif
        
        return nil
    }

    /// Returns a `Data` representation of this generated image in PNG format or nil if there is an error converting the image data.
    func pngRepresentation() -> Data? {
        #if os(iOS)
        let uiImage = UIImage(cgImage: cgImage)
        return uiImage.pngData()
        #elseif os(macOS)
        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        return pngData(from: nsImage)
        #endif
    }

    /// Converts NSImage to PNG data (for macOS)
     #if os(macOS)
     private func pngData(from nsImage: NSImage) -> Data? {
         guard let imageRep = nsImage.representations.first as? NSBitmapImageRep else { return nil }
         return imageRep.representation(using: .png, properties: [:])
     }
     #endif
}

extension DiffusionImage {
    // Function to save the image to the pasteboard
    func saveToPasteboard() {
        guard let pngData = pngRepresentation() else {
            print("Error: Failed to convert image to PNG data.")
            return
        }
        
        #if os(iOS)
        // Use UIPasteboard to copy the image data to the clipboard
        UIPasteboard.general.setData(pngData, forPasteboardType: UTType.png.identifier)
        #elseif os(macOS)
        // Use NSPasteboard for macOS
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setData(pngData, forType: .png)
        #endif
    }
}
