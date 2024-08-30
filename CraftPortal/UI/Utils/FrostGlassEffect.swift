//
//  FrostGlassEffect.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//

import SwiftUI

struct FrostGlassEffect: View {
    var material: NSVisualEffectView.Material?
    var blendingMode: NSVisualEffectView.BlendingMode

    var body: some View {
        if let material = material {
            Representable(material: material, blendingMode: blendingMode)
                .edgesIgnoringSafeArea(.all)
        }
    }

    struct Representable: NSViewRepresentable {
        var material: NSVisualEffectView.Material
        var blendingMode: NSVisualEffectView.BlendingMode

        func makeNSView(context _: Context) -> NSVisualEffectView {
            let view = NSVisualEffectView()
            view.material = material
            view.blendingMode = blendingMode
            view.state = .active
            return view
        }

        func updateNSView(_: NSVisualEffectView, context _: Context) {}
    }
}
