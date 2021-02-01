//
//  CircleButton.swift
//  ADBRemote
//
//  Created by Paweł Wszeborowski on 24/01/2021.
//

import SwiftUI

struct WhiteCircularButton: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(.accentColor)
      .frame(width: 50, height: 50)
      .background(Color.white.opacity(configuration.isPressed ? 0.7 : 1))
      .cornerRadius(25)
  }
}
