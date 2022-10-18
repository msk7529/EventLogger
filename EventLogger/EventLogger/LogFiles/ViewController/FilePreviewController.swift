//
//  FilePreviewController.swift
//  EventLogger
//
//  Created on 2022/10/18.
//

import QuickLook
import UIKit

final class PreviewFileItem: NSObject, QLPreviewItem {
    var filePath: URL?
    private let fileName: String
    
    var previewItemURL: URL? {
        return filePath
    }
    
    var previewItemTitle: String? {
        return fileName
    }
    
    init(fileName: String, filePath: URL) {
        self.fileName = fileName
        self.filePath = filePath
    }
    
    var canPreview: Bool {
        QLPreviewController.canPreview(self)
    }
}

final class FilePreviewController: QLPreviewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    var showOriginalFileName: Bool = false {
        didSet {
            // 다운로드한 파일은(abcd.pdf) 파일의 서버 URL을 이용해서 별도의 이름으로 저장되는데
            // QLPreviewController를 띄워서 미리보는 경우
            // 타이틀에는 <QLPreviewItem> 의 fileName을 설정해주면 이 이름으로 표시된다.
            // 하지만 열 수 없는 파일인 경우(canPreviewItem을 통과했음에도..)에 QLPreviewController 의 view 중앙에 파일 이름이 표시되는데
            // 열려고 시도하는 파일명이 그대로 표시되어 이상한 이름이 표시된다.
            // 이를 막기 위해서는 결국 파일이름을 원래이름으로 바꿔서 복사해놓고 열어야 한다.
            // 미리보기가 끝나면 삭제해야 하고.
            guard showOriginalFileName else { return }
            guard let previewFile = previewFile, let downloadPath = previewFile.previewItemURL?.path else {
                fatalError("previewFile should not be nil")
            }
            
            if let tempPreviewFilePath = LogFileManager.filePreviewDirectoryPath(with: previewFile.previewItemTitle ?? "") {
                FileUtility.copyFile(from: downloadPath, to: tempPreviewFilePath)
                previewFile.filePath = URL(fileURLWithPath: tempPreviewFilePath)
            }
        }
    }
    
    var previewFile: PreviewFileItem!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        dataSource = self
        delegate = self
        currentPreviewItemIndex = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewFile
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        guard let directory = LogFileManager.logPreviewDirectory else { return }
        FileUtility.deleteAllFiles(in: directory)
    }
}

