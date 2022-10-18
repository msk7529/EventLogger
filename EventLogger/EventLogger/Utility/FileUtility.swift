//
//  FileUtility.swift
//  EventLogger
//
//  Created by lehends on 2022/10/18.
//

import Foundation

final class FileUtility {
    
    class func fileExists(at path: String) -> Bool {
        FileManager.default.fileExists(atPath: path)
    }
    
    class func isDirectory(atPath: String) -> Bool {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: atPath, isDirectory: &isDirectory) else {
            return false
        }
        return isDirectory.boolValue
    }
    
    @discardableResult
    class func directoryExists(at path: String, createIfNotExist: Bool = false) -> Bool {
        var isDirectory: ObjCBool = true
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        if !exists || (exists && !isDirectory.boolValue) {
            if createIfNotExist {
                return FileUtility.createDirectory(at: path)
            }
            return createIfNotExist
        }
        return true
    }
    
    class func createDirectory(at path: String) -> Bool {
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            Log.error("Error createDirectory:\(path) - \(error)")
            return false
        }
        return true
    }
    
    class func fileSize(at path: String) -> Int {
        guard FileUtility.fileExists(at: path), let fileAttributes = try? FileManager.default.attributesOfItem(atPath: path) else {
            return 0
        }
        return fileAttributes[FileAttributeKey.size] as? Int ?? 0
    }
    
    class func fileSizeString(with size: Int) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
    
    @discardableResult
    class func copyFile(from path: String, to toPath: String) -> Bool {
        var parts = toPath.components(separatedBy: "/")
        _ = parts.removeLast()
        let folderPath = parts.joined(separator: "/")
        guard FileUtility.directoryExists(at: folderPath, createIfNotExist: true) else {
            return false
        }

        FileUtility.deleteFile(at: toPath)
        do {
            try FileManager.default.copyItem(atPath: path, toPath: toPath)
        } catch let error as NSError {
            Log.warning("copy error: from [\(path)] to [\(toPath)] - \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    @discardableResult
    class func deleteFile(at path: String) -> Bool {
        // 해당 파일이 존재 하지 않는다면 그냥 삭제 된걸로 쳐준다.
        guard FileUtility.fileExists(at: path) else { return true }

        if FileManager.default.isDeletableFile(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
                return true
            } catch let error as NSError {
                Log.warning("[FILE] delete error at path: \(path) - \(error)")
                return false
            }
        }
        return false
    }
    
    class func deleteAllFiles(in folder: String) {
        guard let subpaths = try? FileManager.default.subpathsOfDirectory(atPath: folder) else { return }
        subpaths.forEach {
            try? FileManager.default.removeItem(atPath: folder.appending(pathComponent: $0))
        }
    }
}
