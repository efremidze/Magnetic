//
//  MagneticView+SwiftUI.swift
//  Magnetic
//
//  Created by Lasha Efremidze on 11/7/21.
//  Copyright © 2021 efremidze. All rights reserved.
//

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-wrap-a-custom-uiview-for-swiftui
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-integrate-spritekit-using-spriteview

import SwiftUI

public struct MagneticView_SwiftUI: UIViewRepresentable {
    public func makeUIView(context: Context) -> MagneticView {
        MagneticView()
    }
    public func updateUIView(_ uiView: MagneticView, context: Context) {}
}
