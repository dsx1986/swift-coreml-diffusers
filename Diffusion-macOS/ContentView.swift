import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// Shared logic for both iOS and macOS
struct ShareButtons: View {
    var image: CGImage
    var name: String
    
    var filename: String {
        name.replacingOccurrences(of: " ", with: "_")
    }

    // iOS-specific code for saving to Photos
    #if os(iOS)
    func saveImageToPhotos() {
        let uiImage = UIImage(cgImage: image)
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil) // Save to photo library
    }

    func showSavePanel() {
        let uiImage = UIImage(cgImage: image)
        let activityViewController = UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
    }
    #elseif os(macOS)
    func showSavePanel() {
        let nsImage = NSImage(cgImage: image, size: NSSize(width: CGFloat(image.width), height: CGFloat(image.height)))
        let panel = NSSavePanel()
        panel.nameFieldStringValue = filename + ".png"
        if panel.runModal() == .OK, let url = panel.url {
            if let data = nsImage.tiffRepresentation, let bitmap = NSBitmapImageRep(data: data) {
                let pngData = bitmap.representation(using: .png, properties: [:])
                try? pngData?.write(to: url)
            }
        }
    }
    #endif

    var body: some View {
        #if os(iOS)
        let uiImage = UIImage(cgImage: image) // Convert CGImage to UIImage
        HStack {
//            ShareLink(item: uiImage, preview: SharePreview(name, image: Image(uiImage: uiImage)))
            Button(action: {
                showSavePanel() // Using iOS save dialog
            }) {
                Label("Save…", systemImage: "square.and.arrow.down")
            }
        }
        #elseif os(macOS)
        // On macOS, ShareLink doesn't support NSImage directly
        let nsImage = NSImage(cgImage: image, size: NSSize(width: CGFloat(image.width), height: CGFloat(image.height)))
        HStack {
            Button(action: {
                showSavePanel() // macOS save dialog
            }) {
                Label("Save…", systemImage: "square.and.arrow.down")
            }
        }
        #endif
    }
}

struct ContentView: View {
    @StateObject var generation = GenerationContext()

    func toolbar() -> some View {
        if case .complete(let prompt, let cgImage, _, _) = generation.state, let cgImage = cgImage {
            return ShareButtons(image: cgImage, name: prompt)
        } else {
            let prompt = DEFAULT_PROMPT
            #if os(iOS)
            let cgImage = UIImage(systemName: "photo")?.cgImage ?? UIImage().cgImage!
            #elseif os(macOS)
            let cgImage = NSImage(imageLiteralResourceName: "placeholder").cgImage(forProposedRect: nil, context: nil, hints: nil)!
            #endif
            return ShareButtons(image: cgImage, name: prompt)
        }
    }
    
    var body: some View {
        NavigationView {
            ControlsView()
            GeneratedImageView()
                .aspectRatio(contentMode: .fit)
                .frame(width: 512, height: 512)
                .cornerRadius(15)
                .toolbar {
                    toolbar()
                }
        }
        .environmentObject(generation)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
