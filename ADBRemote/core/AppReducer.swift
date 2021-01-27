//
//  AppReducer.swift
//  ADBRemote
//
//  Created by Paweł Wszeborowski on 24/01/2021.
//

import Foundation
import ComposableArchitecture

let appReducer: Reducer<AppState, AppAction, AppEnvironment>
  = .init { state, action, environment in
    switch action {
    case .refreshDevices:
      state.devices = .init()
      state.refreshing = true
      return environment.adb
        .refreshDevices()
        .replaceError(with: [])
        .receive(on: environment.mainQueue)
        .eraseToEffect()
        .map(AppAction.loadedDevices)

    case let .loadedDevices(devices):
      state.refreshing = false
      state.devices = IdentifiedArrayOf(devices)
      let selectDevice = { (device: Device) in
        Effect<AppAction, Never>(value: AppAction.selectDevice(device.id))
      }
      return state.currentDevice.map(selectDevice)
        ?? state.devices.first.map(selectDevice)
        ?? .none

    case let .selectDevice(id):
      if let id = id {
        state.currentDevice = state.devices[id: id]
      }
      return .none

    case let .sendKeyEvent(keyEvent):
      guard let id = state.currentDevice?.id else {
        return .none
      }
      return .fireAndForget {
        environment.adb
          .sendKeyEvent(id, keyEvent)
      }
    }
  }
