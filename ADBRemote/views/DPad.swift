//
//  DPad.swift
//  ADBRemote
//
//  Created by Paweł Wszeborowski on 24/01/2021.
//

import ComposableArchitecture
import SwiftUI

struct RingPieceButton: ButtonStyle {
  let radius: CGFloat
  let ringWidth: CGFloat
  let offset: CGFloat
  let direction: Direction

  enum Direction {
    case up
    case right
    case down
    case left

    var angles: (start: Angle, end: Angle) {
      switch self {
      case .up: return (Angle.degrees(-45), Angle.degrees(-135))
      case .right: return (Angle.degrees(45), Angle.degrees(-45))
      case .down: return (Angle.degrees(135), Angle.degrees(45))
      case .left: return (Angle.degrees(225), Angle.degrees(135))
      }
    }

    func offset(value: CGFloat) -> CGPoint {
      switch self {
      case .up: return CGPoint(x: 0, y: -value)
      case .right: return CGPoint(x: value, y: 0)
      case .down: return CGPoint(x: 0, y: value)
      case .left: return CGPoint(x: -value, y: 0)
      }
    }
  }

  func drawPath() -> OffsetShape<Path> {
    Path { path in
      let center = CGPoint(x: radius, y: radius)
      let (start, end) = direction.angles
      path.addArc(center: center, radius: radius - offset, startAngle: start, endAngle: end, clockwise: true)
      path.addArc(center: center, radius: radius - ringWidth - offset, startAngle: end, endAngle: start, clockwise: false)
    }
    .offset(direction.offset(value: offset))
  }

  func makeBody(configuration: Configuration) -> some View {
    drawPath()
      .fill(Color.white.opacity(configuration.isPressed ? 0.7 : 1))
  }
}

fileprivate let radius: CGFloat = 150
fileprivate let ringWidth: CGFloat = 100
fileprivate let circleOffset: CGFloat = 3

struct DPad: View {
  let store: Store<Void, AndroidKeyEvent>

  var body: some View {
    WithViewStore(store) { viewStore in
      ZStack(alignment: .center) {
        Button(action: { viewStore.send(.KEYCODE_DPAD_UP) }, label: { EmptyView() })
          .buttonStyle(RingPieceButton(radius: radius, ringWidth: ringWidth, offset: circleOffset, direction: .up))
        Button(action: { viewStore.send(.KEYCODE_DPAD_RIGHT) }, label: { EmptyView() })
          .buttonStyle(RingPieceButton(radius: radius, ringWidth: ringWidth, offset: circleOffset, direction: .right))
        Button(action: { viewStore.send(.KEYCODE_DPAD_DOWN) }, label: { EmptyView() })
          .buttonStyle(RingPieceButton(radius: radius, ringWidth: ringWidth, offset: circleOffset, direction: .down))
        Button(action: { viewStore.send(.KEYCODE_DPAD_LEFT) }, label: { EmptyView() })
          .buttonStyle(RingPieceButton(radius: radius, ringWidth: ringWidth, offset: circleOffset, direction: .left))

        VStack {
          Image(systemName: "chevron.compact.up")
            .font(.largeTitle)
            .foregroundColor(.accentColor)
            .offset(y: -ringWidth)
          Image(systemName: "chevron.compact.down")
            .font(.largeTitle)
            .foregroundColor(.accentColor)
            .offset(y: ringWidth)
        }

        HStack {
          Image(systemName: "chevron.compact.left")
            .font(.largeTitle)
            .foregroundColor(.accentColor)
            .offset(x: -ringWidth)
          Image(systemName: "chevron.compact.right")
            .font(.largeTitle)
            .foregroundColor(.accentColor)
            .offset(x: ringWidth)
        }

        Button(action: { viewStore.send(.KEYCODE_DPAD_CENTER) }, label: { Color.clear })
          .buttonStyle(WhiteCircularButton())
      }
      .frame(width: 2 * radius, height: 2 * radius)
      .padding()
    }
  }
}
