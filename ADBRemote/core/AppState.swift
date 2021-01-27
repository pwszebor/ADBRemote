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
  var refreshing = false
  var devices = IdentifiedArrayOf<Device>()
  var currentDevice: Device?
}
