//
//  LogManager.swift
//  PulseBoard
//
//  Created by 권정근 on 12/18/25.
//
// ▶️ 디버그 로그 출력을 위한 LogManager ◀️

import Foundation


// MARK: - Log Type
enum LogType: String {
    case info = "ℹ️"
    case success = "✅"
    case warning = "⚠️"
    case error = "❌"
}


// MARK: - Log Manager
final class LogManager {
    static func print(
        _ type: LogType,
        _ message: String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        Swift.print("\(type.rawValue) [\(file) \(function):\(line)] - \(message)")
        #endif
    }
}
