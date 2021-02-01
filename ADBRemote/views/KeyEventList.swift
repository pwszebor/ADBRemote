//
//  KeyEventList.swift
//  ADBRemote
//
//  Created by Paweł Wszeborowski on 30/01/2021.
//

import ComposableArchitecture
import SwiftUI

struct KeyEventList: View {
  let store: Store<AppState.KeyEventListState, KeyEventListAction>
  let columns = [
    GridItem(.flexible(), alignment: .leading),
    GridItem(.fixed(50), alignment: .trailing)
  ]

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
          LazyVGrid(columns: columns) {
            ForEach(viewStore.events, id: \.self) { event in
              LazyVStack(alignment: .leading) {
                Text(event.rawValue)
                Text("Code: \(event.keyCode)")
                  .font(.caption)
              }

              Button("Send") {
                viewStore.send(.sendKeyEvent(event))
              }
            }
          }
        }
      }
    }
  }
}
