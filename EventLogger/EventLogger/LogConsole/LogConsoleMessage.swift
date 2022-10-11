//
//  LogConsoleMessage.swift
//  EventLogger
//
//

import CocoaLumberjackSwift
import Foundation

final class LogConsoleMessage: Hashable {
    
    let uuid: UUID
    private(set) var message: String
    let fullMessage: String
    let logType: LogType
    let fileName: String
    let fileLine: UInt
    let functionName: String
    let timeStamp: Date
    let threadID: String
    let threadName: String
    private(set) var queueLabel: String = ""
    
    var isExpanded: Bool = false
    
    init(message: String, logType: LogType, fileName: String, fileLine: UInt, functionName: String) {
        self.uuid = UUID()
        self.message = message
        self.fullMessage = message
        self.logType = logType
        self.fileName = URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
        self.fileLine = fileLine
        self.functionName = functionName
        self.timeStamp = Date()
        var tid = UInt64(0)
        pthread_threadid_np(nil, &tid)
        self.threadID = "\(tid)"
        self.threadName = Thread.current.name ?? "unknown"
        self.queueLabel = currentQueueName ?? "unknown"
        
        if message.count > 20 * 1024 {
            self.message = String(message[..<message.index(message.startIndex, offsetBy: 20 * 1024)])
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    static func == (lhs: LogConsoleMessage, rhs: LogConsoleMessage) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension LogConsoleMessage {
    
    var currentQueueName: String? {
        let name = __dispatch_queue_get_label(nil)
        return String(cString: name, encoding: .utf8)
    }
    
    var expandedMessage: String {
        var formattedMessage = """
        #Loc    = \(fileName):\(UInt(fileLine))
        #Thread = \(queueLabel)
        #Date   = \(LogConsoleDateFormatterGenerator.dateFormatter(type: .long).string(from: timeStamp))
        ―――――――――――――――――――――――――――――――――――――
        """
        if !message.isEmpty {
            formattedMessage += "\n\(message)"
        }
        return formattedMessage
    }
}
