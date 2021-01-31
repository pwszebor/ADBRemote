//
//  MediaButtons.swift
//  ADBRemote
//
//  Created by Paweł Wszeborowski on 31/01/2021.
//

import SwiftUI

struct MediaButtons: View {
  let sendKeyEvent: (AndroidKeyEvent) -> Void

  var body: some View {
    HStack {
      Button(action: { sendKeyEvent(AndroidKeyEvent.KEYCODE_MEDIA_PREVIOUS) }) {
        Image(systemName: "backward")
      }
      .buttonStyle(WhiteCircularButton())

      Spacer()

      Button(action: { sendKeyEvent(AndroidKeyEvent.KEYCODE_MEDIA_SKIP_BACKWARD) }) {
        Image(systemName: "gobackward")
      }
      .buttonStyle(WhiteCircularButton())

      Spacer()

      Button(action: { sendKeyEvent(AndroidKeyEvent.KEYCODE_MEDIA_PLAY_PAUSE) }) {
        Image(systemName: "playpause")
      }
      .buttonStyle(WhiteCircularButton())

      Spacer()

      Button(action: { sendKeyEvent(AndroidKeyEvent.KEYCODE_MEDIA_SKIP_FORWARD) }) {
        Image(systemName: "goforward")
      }
      .buttonStyle(WhiteCircularButton())

      Spacer()

      Button(action: { sendKeyEvent(AndroidKeyEvent.KEYCODE_FORWARD) }) {
        Image(systemName: "forward")
      }
      .buttonStyle(WhiteCircularButton())
    }
  }
}
