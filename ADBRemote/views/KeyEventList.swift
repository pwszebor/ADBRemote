//
//  KeyEventList.swift
//  ADBRemote
//
//  Created by Paweł Wszeborowski on 30/01/2021.
//

import ComposableArchitecture
import SwiftUI

struct ListItem: View {
  let event: AndroidKeyEvent
  let onPress: () -> Void

  var body: some View {
    HStack {
      Text(event.rawValue)
      Spacer()
      Text("Code: \(event.keyCode)")
      Button("Send", action: onPress)
    }
  }
}

struct KeyEventList: View {
  let store: Store<AppState.KeyEventListState, KeyEventListAction>

  var body: some View {
    WithViewStore(store) { viewStore in
      List {
        Section(
          header: VStack(alignment: .leading) {
            Text("Send key event")
            TextField(
              "Search",
              text: viewStore.binding(
                get: { $0.filterText },
                send: KeyEventListAction.filterTextChanged
              )
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
          }
        ) {
          LazyVStack {
            ForEach(viewStore.events, id: \.self) { event in
              ListItem(event: event) {
                viewStore.send(.sendKeyEvent(event))
              }
            }
          }
        }
      }
    }
  }
}
