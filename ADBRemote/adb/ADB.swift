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
  let sendKeyEvent: (String, AndroidKeyEvent) -> Void
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

    }
  )
}

import Parsing

let deviceParser = Parsers
  .PrefixUpTo<Substring>("\t")
  .skip(Parsers.PrefixThrough<Substring>("\t"))
  .take(Parsers.PrefixUpTo<Substring>("\n"))
  .map { ip, name in Device(id: String(ip), name: String(name)) }

let prefixParser = Parsers.PrefixThrough("List of devices attached\n")

let devicesParser = Parsers
  .Skip(prefixParser)
  .take(Parsers.Many(deviceParser, separator: Parsers.StartsWith("\n")))

extension ADB {
  static var live: ADB {
    return ADB(
      refreshDevices: {
        Future<[Device], ADB.Error> { promise in
          do {
            let adb = Process()
            adb.executableURL = URL(fileURLWithPath: "/usr/local/bin/adb")
            let pipe = Pipe()
            adb.standardOutput = pipe
            adb.standardError = pipe
            adb.arguments = ["devices"]
            try adb.run()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(decoding: data, as: UTF8.self)
            let devices = devicesParser.parse(output) ?? []
            promise(.success(devices))
          } catch {
            print(error)
            promise(.success([]))
          }
        }
        .eraseToAnyPublisher()
      },
      sendKeyEvent: { deviceId, keyEvent in
        do {
          let adb = Process()
          adb.executableURL = URL(fileURLWithPath: "/usr/local/bin/adb")
          let pipe = Pipe()
          adb.standardOutput = pipe
          adb.standardError = pipe
          adb.arguments = ["-s", "\(deviceId)", "shell", "input", "keyevent", "\(keyEvent.keyCode)"]
          try adb.run()

          let data = pipe.fileHandleForReading.readDataToEndOfFile()
          let output = String(decoding: data, as: UTF8.self)
          print(output)
        } catch {
          print(error)
        }
      }
    )
  }
}
