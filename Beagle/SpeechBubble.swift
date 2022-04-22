//
//  SpeechBubbleView.swift
//  Beagle
//
//  Created by Scott Brown on 22/04/2022.
//
//  Adapted from https://stackoverflow.com/questions/68883032/swiftui-how-to-combine-two-shapes-to-create-a-speech-bubble-with-strokes
//

import Foundation
import SwiftUI

struct SpeechBubble: Shape {
    private let radius: CGFloat
    private let tailSize: CGFloat

    init(radius: CGFloat = 10) {
        self.radius = radius
        tailSize = 20
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            
            path.move(to: CGPoint(x: rect.maxX / 2, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX / 2, y: rect.maxY + radius))
            
            path.addCurve(
                to: CGPoint(x: rect.maxX / 2 - tailSize, y: rect.maxY),
                control1: CGPoint(x: rect.maxX / 2 - tailSize, y: rect.maxY),
                control2: CGPoint(x: rect.maxX / 2, y: rect.maxY)
            )
            
            path.addArc(
                center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                radius: radius,
                startAngle: Angle(degrees: 90),
                endAngle: Angle(degrees: 180),
                clockwise: false
            )
            path.addArc(
                center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                radius: radius,
                startAngle: Angle(degrees: 180),
                endAngle: Angle(degrees: 270),
                clockwise: false
            )
            path.addArc(
                center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                radius: radius,
                startAngle: Angle(degrees: 270),
                endAngle: Angle(degrees: 0),
                clockwise: false
            )
            path.addArc(
                center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                radius: radius,
                startAngle: Angle(degrees: 0),
                endAngle: Angle(degrees: 90),
                clockwise: false
            )
        }
    }
}
