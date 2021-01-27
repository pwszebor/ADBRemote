//
//  Remote.swift
//  ADBRemote
//
//  Created by Paweł Wszeborowski on 24/01/2021.
//

import SwiftUI
import ComposableArchitecture

struct WhiteCircularButton: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(width: 50, height: 50)
      .background(Color.white.opacity(configuration.isPressed ? 0.7 : 1))
      .cornerRadius(25)
  }
}

struct Remote: View {
  let store: Store<AppState, AppAction>

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
        }
        .frame(width: 300)
        .padding(.horizontal)

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
        .onAppear {
          viewStore.send(.refreshDevices)
        }
      }
    }
  }
}
