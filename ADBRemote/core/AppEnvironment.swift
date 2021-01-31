//
//  AppEnvironment.swift
//  ADBRemote
//
//  Created by Paweł Wszeborowski on 24/01/2021.
//

import Foundation
import ComposableArchitecture
import Combine

struct AppEnvironment {
  let adb: ADB
  let mainQueue: AnySchedulerOf<DispatchQueue>
}

struct KeyEventListEnvironment {
  let mainQueue: AnySchedulerOf<DispatchQueue>
}

struct DevicesEnvironment {
  let mainQueue: AnySchedulerOf<DispatchQueue>
  let refreshDevices: () -> AnyPublisher<[Device], ADB.Error>
}

extension AppEnvironment {
  var keyEventList: KeyEventListEnvironment {
    .init(mainQueue: mainQueue)
  }

  var devices: DevicesEnvironment {
    .init(
      mainQueue: mainQueue,
      refreshDevices: adb.refreshDevices
    )
  }
}
