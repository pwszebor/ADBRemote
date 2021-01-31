//
//  AppReducer.swift
//  ADBRemote
//
//  Created by Paweł Wszeborowski on 24/01/2021.
//

import Foundation
import ComposableArchitecture

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer.combine(
  Reducer({ state, action, environment in
    switch action {
    case .devices:
      return .none

    case let .sendKeyEvent(keyEvent):
      guard let id = state.devicesState.currentDevice?.id else {
        return .none
      }
      return .fireAndForget {
        environment.adb
          .sendKeyEvent(id, keyEvent)
      }

    case let .sendText(text):
      guard let id = state.devicesState.currentDevice?.id else {
        return .none
      }
      return .fireAndForget {
        environment.adb
          .sendText(id, text)
      }

    case let .keyEventList(.sendKeyEvent(event)):
      return Effect(value: .sendKeyEvent(event))

    case .keyEventList:
      return .none
    }
  }),
  devicesReducer.pullback(
    state: \AppState.devicesState,
    action: /AppAction.devices,
    environment: { $0.devices }
  ),
  keyEventListReducer.pullback(
    state: \AppState.keyEventList,
    action: /AppAction.keyEventList,
    environment: { $0.keyEventList }
  )
)
//.debug()

let devicesReducer: Reducer<AppState.DevicesState, DevicesAction, DevicesEnvironment>
  = Reducer({ state, action, environment in
    switch action {
    case .refresh:
      if state.refreshing {
        return .none
      }
      state.devices = .init()
      state.refreshing = true
      return environment
        .refreshDevices()
        .replaceError(with: [])
        .receive(on: environment.mainQueue)
        .eraseToEffect()
        .map(DevicesAction.loaded)

    case let .loaded(devices):
      state.refreshing = false
      state.devices = IdentifiedArrayOf(devices)
      let selectDevice = { (device: Device) in
        Effect<DevicesAction, Never>(value: DevicesAction.select(device.id))
      }
      return state.currentDevice.map(selectDevice)
        ?? state.devices.first.map(selectDevice)
        ?? .none

    case let .select(id):
      if let id = id {
        state.currentDevice = state.devices[id: id]
      }
      return .none
    }
  })

let keyEventListReducer: Reducer<AppState.KeyEventListState, KeyEventListAction, KeyEventListEnvironment>
  = Reducer({ state, action, environment in
    switch action {
    case let .filterTextChanged(text):
      struct ApplyFilterId: Hashable { }
      state.filterText = text
      return Effect(value: KeyEventListAction.applyFilter)
        .debounce(id: ApplyFilterId(), for: .seconds(0.5), scheduler: environment.mainQueue)
        .eraseToEffect()

    case .applyFilter:
      if state.filterText.isEmpty {
        state.events = AndroidKeyEvent.allCases
        return .none
      }
      state.events = AndroidKeyEvent.allCases
        .filter { event in
          event.rawValue.localizedCaseInsensitiveContains(state.filterText)
        }
      return .none

    case let .sendKeyEvent(event):
      return .none
    }
  })
//  .debug()

