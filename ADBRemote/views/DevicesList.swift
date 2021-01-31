//
//  DevicesList.swift
//  ADBRemote
//
//  Created by Paweł Wszeborowski on 31/01/2021.
//

import SwiftUI
import ComposableArchitecture

struct DevicesList: View {
  let store: Store<AppState.DevicesState, DevicesAction>

  var body: some View {
    WithViewStore(store) { viewStore in
      List(selection: viewStore.binding(
        get: { $0.currentDevice?.id },
        send: { DevicesAction.select($0) }
      )) {
        Section(
          header: HStack {
            Text("Devices")
            if viewStore.refreshing {
              ProgressView()
                .progressViewStyle(LinearProgressViewStyle())
            } else {
              Spacer()
              Button(action: { viewStore.send(.refresh) }) {
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
        viewStore.send(.refresh)
      }
    }
  }
}
