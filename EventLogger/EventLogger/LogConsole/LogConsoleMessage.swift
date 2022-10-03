//
//  LogConsoleMessage.swift
//  EventLogger
//
//

import CocoaLumberjackSwift
import Foundation

final class LogConsoleMessage: Hashable {
    
    let uuid: UUID
    let message: String
    let logType: LogType
    let fileName: String
    let fileLine: UInt
    let functionName: String
    let timeStamp: Date
    let threadID: String
    let threadName: String
    var isExpanded: Bool = false
    private(set) var queueLabel: String = ""
    private(set) var fullMsg: String = ""
    
    private let longDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.formatterBehavior = .behavior10_4
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter
    }()
    
    var expandedMessage: String {
        return """
        #Loc    = \(fileName):\(UInt(fileLine))
        #Thread = \(queueLabel)
        #Date   = \(longDateFormatter.string(from: timeStamp))
        ―――――――――――――――――――――――――――――――――――――
        \(message)
        """
    }
    
    init(message: String, logType: LogType, fileName: String, fileLine: UInt, functionName: String) {
        self.uuid = UUID()
        self.message = message
        self.logType = logType
        self.fileName = URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
        self.fileLine = fileLine
        self.functionName = functionName
        self.timeStamp = Date()
        var tid = UInt64(0)
        pthread_threadid_np(nil, &tid)
        self.threadID = "\(tid)"
        
        self.threadName = Thread.current.name ?? "unknown"
        self.queueLabel = self.currentQueueName() ?? "unknown"
    }
    
    private func currentQueueName() -> String? {
        let name = __dispatch_queue_get_label(nil)
        return String(cString: name, encoding: .utf8)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
        hasher.combine(message)
    }
    
    static func == (lhs: LogConsoleMessage, rhs: LogConsoleMessage) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
