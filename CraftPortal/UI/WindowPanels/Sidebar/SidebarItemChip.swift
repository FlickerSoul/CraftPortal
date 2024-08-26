//
//  SidebarItemChip.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//
import SwiftUI

struct DynamicImageView: View {
    var imageSource: ImageSource

    var body: some View {
        Group {
            switch imageSource {
            case let .asset(name):
                Image(name)
                    .resizable()
            case let .file(path):
                if let nsImage = NSImage(contentsOfFile: path) {
                    Image(nsImage: nsImage)
                        .resizable()
                } else {
                    // Fallback to a default image or a placeholder if the file is not found
                    Image(systemName: "questionmark.circle")
                        .resizable()
                }
            case let .systemIcon(name):
                Image(systemName: name)
                    .resizable()
            }
        }
        .aspectRatio(contentMode: .fill)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

struct SidebarItemChip<Content: View>: View {
    var imageSource: ImageSource
    @ViewBuilder var content: () -> Content

    @State private var isHovered: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            DynamicImageView(imageSource: imageSource)
                .frame(width: 36, height: 36)

            content()

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(width: .infinity, height: 48)
        .padding(.vertical, 12)
        .background(
            isHovered ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1)
        )
        .shadow(radius: isHovered ? 4 : 2)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
            changeMouseHovering(hovering)
        }
    }
}

#Preview {
    SidebarItemChip(imageSource: .asset(name: "NoAccountDefaultFace")) {
        Text("no account")
    }
}

#Preview {
    SidebarItemChip(imageSource: .asset(name: "NoGameProfileDefaultIcon")) {
        Text("no account")
    }
}
