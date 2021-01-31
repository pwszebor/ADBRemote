//
//  Remote.swift
//  ADBRemote
//
//  Created by Paweł Wszeborowski on 24/01/2021.
//

import SwiftUI
import ComposableArchitecture

struct Remote: View {
  let store: Store<AppState, AppAction>

  @State var inputText = ""

  var body: some View {
    WithViewStore(store) { viewStore in
      HStack {
        VStack {
          DPad(store: store.scope(state: { _ in () }, action: { AppAction.sendKeyEvent($0) }))

          HStack {
            Button {
              viewStore.send(.sendKeyEvent(.KEYCODE_BACK))
            } label: {
              Image(systemName: "arrow.left")
            }
            .buttonStyle(WhiteCircularButton())
            
            Spacer()

            Button {
              viewStore.send(.sendKeyEvent(.KEYCODE_MENU))
            } label: {
              Image(systemName: "arrow.counterclockwise")
            }
            .buttonStyle(WhiteCircularButton())
          }

          MediaButtons {
            viewStore.send(.sendKeyEvent($0))
          }
          .padding(.vertical)

          HStack {
            TextField(
              "Send text",
              text: $inputText
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Send") {
              viewStore.send(.sendText(inputText))
            }
          }
          .padding(.vertical)
        }
        .frame(width: 300)
        .padding(.horizontal)

        KeyEventList(
          store: store.scope(
            state: { $0.keyEventList },
            action: { AppAction.keyEventList($0) }
          )
        )

        DevicesList(
          store: store.scope(
            state: { $0.devicesState },
            action: { AppAction.devices($0) }
          )
        )
      }
    }
  }
}
