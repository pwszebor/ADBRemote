//
//  ContentView.swift
//  ADBRemote
//
//  Created by Paweł Wszeborowski on 24/01/2021.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
  var body: some View {
    Remote(store: Store(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment(
        adb: .live,
        mainQueue: DispatchQueue.main.eraseToAnyScheduler()
      )
    ))
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
