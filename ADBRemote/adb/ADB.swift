//
//  ADB.swift
//  ADBRemote
//
//  Created by Paweł Wszeborowski on 24/01/2021.
//

import Combine
import Foundation

struct ADB {
  enum Error: Swift.Error {

  }

  let refreshDevices: () -> AnyPublisher<[Device], ADB.Error>
  let sendKeyEvent: (Device.ID, AndroidKeyEvent) -> Void
  let sendText: (Device.ID, String) -> Void
}

func randomName() -> String {
  let randomChar = { (int: Int) in Unicode.Scalar(int).map(Character.init) ?? "x" }
  let chars = (0...Int.random(in: 5...10)).map { _ in
    randomChar(Int.random(in: Int("a".unicodeScalars.first!.value)...Int("z".unicodeScalars.first!.value)))
  }
  return String(chars)
}

func randomDevice() -> Device {
  Device(
    id: UUID().uuidString,
    name: randomName()
  )
}

extension ADB {
  static let mock = ADB(
    refreshDevices: {
      Just((0...10).map { _ in randomDevice() })
        .delay(for: 1, scheduler: DispatchQueue.main)
        .setFailureType(to: ADB.Error.self)
        .eraseToAnyPublisher()
    },
    sendKeyEvent: { deviceId, event in

    },
    sendText: { deviceId, text in

    }
  )
}

import Parsing

let deviceParser = PrefixUpTo<Substring>("\t")
  .skip(PrefixThrough<Substring>("\t"))
  .take(PrefixUpTo<Substring>("\n"))
  .map { id, name in Device(id: String(id), name: String(name)) }

let devicesParser = Skip(PrefixThrough("List of devices attached\n"))
  .take(Many(deviceParser, separator: StartsWith("\n")))

extension ADB {
  static var live: ADB {
    enum ADBCommand {
      case devices
      case keyEvent(deviceId: String, event: AndroidKeyEvent)
      case text(deviceId: String, text: String)

      var arguments: [String] {
        switch self {
        case .devices:
          return ["devices"]

        case let .keyEvent(deviceId, event):
          return ["-s", "\(deviceId)", "shell", "input", "keyevent", "\(event.keyCode)"]

        case let .text(deviceId, text):
          return ["-s", "\(deviceId)", "shell", "input", "text", "'\(text)'"]
        }
      }
    }

    let queue = OperationQueue()
    queue.name = "adb"
    queue.maxConcurrentOperationCount = 1

    func runADB(_ command: ADBCommand, output: ((String) -> Void)? = nil) {
      queue.addOperation {
        let adb = Process()
        adb.executableURL = URL(fileURLWithPath: "/usr/local/bin/adb")
        let pipe = Pipe()
        adb.standardOutput = pipe
        adb.arguments = command.arguments

        do {
          try adb.run()
          let data = pipe.fileHandleForReading.readDataToEndOfFile()
          output?(String(decoding: data, as: UTF8.self))
        } catch {
          output?("")
        }
      }
    }

    return ADB(
      refreshDevices: {
        Future<[Device], ADB.Error> { promise in
          runADB(.devices) {
            promise(.success(
              devicesParser.parse($0) ?? []
            ))
          }
        }
        .eraseToAnyPublisher()
      },
      sendKeyEvent: { deviceId, keyEvent in
        runADB(.keyEvent(deviceId: deviceId, event: keyEvent))
      },
      sendText: { deviceId, text in
        runADB(.text(deviceId: deviceId, text: text))
      }
    )
  }
}
