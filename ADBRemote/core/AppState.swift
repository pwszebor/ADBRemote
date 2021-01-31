//
//  AppState.swift
//  ADBRemote
//
//  Created by Paweł Wszeborowski on 24/01/2021.
//

import Foundation
import ComposableArchitecture

struct Device: Identifiable, Equatable {
  let id: String
  let name: String
}

struct AppState: Equatable {
  struct DevicesState: Equatable {
    var refreshing = false
    var devices = IdentifiedArrayOf<Device>()
    var currentDevice: Device?
  }

  var devicesState = DevicesState()

  struct KeyEventListState: Equatable {
    var events = Array(AndroidKeyEvent.allCases)
    var filterText = ""
  }
  var keyEventList = KeyEventListState()
}
