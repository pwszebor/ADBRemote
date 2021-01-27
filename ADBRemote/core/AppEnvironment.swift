//
//  AppEnvironment.swift
//  ADBRemote
//
//  Created by Paweł Wszeborowski on 24/01/2021.
//

import Foundation
import ComposableArchitecture

struct AppEnvironment {
  let adb: ADB
  let mainQueue: AnySchedulerOf<DispatchQueue>
}
