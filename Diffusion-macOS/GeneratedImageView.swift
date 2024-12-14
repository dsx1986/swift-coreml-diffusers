import SwiftUI

struct GeneratedImageView: View {
    @EnvironmentObject var generation: GenerationContext

    var body: some View {
        switch generation.state {
        case .startup:
            return AnyView(Image("placeholder").resizable())
        case .running(let progress):
            guard let progress = progress, progress.stepCount > 0 else {
                // The first time it takes a little bit before generation starts
                return AnyView(ProgressView())
            }

            let step = Int(progress.step) + 1
            let fraction = Double(step) / Double(progress.stepCount)
            let label = "Step \(step) of \(progress.stepCount)"

            return AnyView(VStack {
                Group {
                    if let safeImage = generation.previewImage {
                        Image(safeImage, scale: 1, label: Text("generated"))
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                HStack {
                    ProgressView(label, value: fraction, total: 1).padding()
                    Button {
                        generation.cancelGeneration()
                    } label: {
                        Image(systemName: "x.circle.fill").foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
            })
        case .complete(_, let image, _, _):
            // Safely unwrapping the optional `CGImage?`
            if let theImage = image {
                return AnyView(
                    Image(theImage, scale: 1, label: Text("generated"))
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .contextMenu {
                            Button {
                                #if os(iOS)
                                // Using iOS compatible pasteboard (UIPasteboard)
                                UIPasteboard.general.image = UIImage(cgImage: theImage)
                                #elseif os(macOS)
                                // Using macOS compatible pasteboard (NSPasteboard)
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                // Convert the CGImage to data before copying to pasteboard
                                if let imageData = theImage.dataProvider?.data {
                                    pasteboard.setData(imageData as Data, forType: .tiff)
                                }
                                #endif
                            } label: {
                                Text("Copy Photo")
                            }
                        }
                )
            } else {
                return AnyView(Image(systemName: "exclamationmark.triangle").resizable())
            }
        case .failed(_):
            return AnyView(Image(systemName: "exclamationmark.triangle").resizable())
        case .userCanceled:
            return AnyView(Text("Generation canceled"))
        }
    }
}
