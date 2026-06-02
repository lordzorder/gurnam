import AppKit
import SwiftUI

struct MediaThumbnailView: View {
    let asset: MediaAsset

    var body: some View {
        ZStack {
            if let image = NSImage(contentsOf: asset.localURL) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(.quaternary)
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .clipped()
        .accessibilityLabel(asset.originalFileName)
    }
}
