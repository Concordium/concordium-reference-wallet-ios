//
// Created by Concordium on 15/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

enum LogLevel: Int {
    case trace, debug, info, warn, error
}

class Logger {
#if DEBUG
    static var logLevel = LogLevel.trace
#else
    static var logLevel = LogLevel.error
#endif

    static func shouldLog(on inputLevel: LogLevel) -> Bool {
        inputLevel.rawValue >= logLevel.rawValue
    }

    static func trace(_ items: String, fileName: String = #file, line: Int = #line) {
        logText(items, level: .trace, fileName: fileName, line: line)
    }

    static func debug(_ items: Any..., fileName: String = #file, line: Int = #line) {
        #if DEBUG
            logText(items, level: .debug, fileName: fileName, line: line)
        #endif
    }

    static func debug(_ items: String, fileName: String = #file, line: Int = #line) {
        #if DEBUG
            logText(items, level: .debug, fileName: fileName, line: line)
        #endif
    }

    static func info(_ items: Any..., fileName: String = #file, line: Int = #line) {
        logText(items, level: .info, fileName: fileName, line: line)
    }

    static func info(_ items: String, fileName: String = #file, line: Int = #line) {
        logText(items, level: .info, fileName: fileName, line: line)
    }

    static func warn(_ items: Any..., fileName: String = #file, line: Int = #line) {
        logText(items, level: .warn, fileName: fileName, line: line)
    }

    static func warn(_ items: String, fileName: String = #file, line: Int = #line) {
        logText(items, level: .warn, fileName: fileName, line: line)
    }

    static func error(_ items: Any..., fileName: String = #file, line: Int = #line) {
        logText(items, level: .error, fileName: fileName, line: line)
    }

    static func error(_ items: String, fileName: String = #file, line: Int = #line) {
        logText(items, level: .error, fileName: fileName, line: line)
    }

    private static func logText(_ items: Any..., level: LogLevel, fileName: String, line: Int) {
        if shouldLog(on: level) {
            let prefix = getPrefix(level: level)
            print("\(Date()) \(fileName):\(line) \(prefix)", items)
        }
    }

    private static func logText(_ items: String, level: LogLevel, fileName: String, line: Int) {
        if shouldLog(on: level) {
            let prefix = getPrefix(level: level)
            print("\(Date()) \(fileName):\(line) \(prefix)", items)
        }
    }

    private static func getPrefix(level: LogLevel) -> String {
        let prefix: String
        switch level {
        case .trace:
            prefix = "🦶 [TRACE]"
        case .debug:
            prefix = "🐛 [DEBUG]"
        case .info:
            prefix = "[INFO]"
        case .warn:
            prefix = "⚠️ [WARN]"
        case .error:
            prefix = "🛑 [ERROR]"
        }
        return prefix
    }
}
