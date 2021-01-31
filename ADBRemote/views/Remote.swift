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

        List(selection: viewStore.binding(
          get: { $0.currentDevice?.id },
          send: { AppAction.selectDevice($0) }
        )) {
          Section(
            header: HStack {
              Text("Devices")
              if viewStore.refreshing {
                ProgressView()
                  .progressViewStyle(LinearProgressViewStyle())
              } else {
                Spacer()
                Button(action: { viewStore.send(.refreshDevices) }) {
                  Image(systemName: "arrow.clockwise")
                }
              }
            }
          ) {
            ForEach(viewStore.devices) { device in
              HStack {
                Image(systemName: "checkmark")
                  .opacity(viewStore.currentDevice?.id == device.id
                    ? 1
                    : 0
                  )
                VStack(alignment: .leading) {
                  Text(device.name)
                    .lineLimit(1)
                  Text(device.id)
                    .font(.caption)
                    .lineLimit(1)
                }
              }
            }
          }
        }
        .onAppear {
          viewStore.send(.refreshDevices)
        }
      }
    }
  }
}
