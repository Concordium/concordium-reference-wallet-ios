//
//  Shape+Extensions.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 30/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

extension Shape {
    func fillWithBorder<Fill: ShapeStyle, Stroke: ShapeStyle>(fill: Fill, stroke: Stroke, lineWidth: Double = 1) -> some View {
        self
            .stroke(stroke, lineWidth: lineWidth)
            .background(self.fill(fill))
    }
}

extension InsettableShape {
    func fillWithBorder<Fill: ShapeStyle, Stroke: ShapeStyle>(fill: Fill, stroke: Stroke, lineWidth: Double = 1) -> some View {
        self
            .strokeBorder(stroke, lineWidth: lineWidth)
            .background(self.fill(fill))
    }
}
