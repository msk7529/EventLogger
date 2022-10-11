//
// Copyright © 2017 Gavrilov Daniil
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

/// Linked list node. Represents frame timestamp.
fileprivate final class FrameNode {
    
    var next: FrameNode?
    weak var previous: FrameNode?
    
    private(set) var timestamp: TimeInterval
    
    /// Initializes linked list node with parameters.
    ///
    /// - Parameter timeInterval: Frame timestamp.
    init(timestamp: TimeInterval) {
        self.timestamp = timestamp
    }
}

/// Linked list. Each node represents frame timestamp.
/// The only function is append, which will add a new frame and remove all frames older than a second from the last timestamp.
/// As a result, the number of items in the list will represent the number of frames for the last second.
final class LinkedFramesList {
        
    private var head: FrameNode?
    private var tail: FrameNode?
        
    private(set) var count = 0
    
    /// Appends new frame with parameters.
    ///
    /// - Parameter timestamp: New frame timestamp.
    func append(frameWithTimestamp timestamp: TimeInterval) {
        let newNode = FrameNode(timestamp: timestamp)
        if let lastNode = self.tail {
            newNode.previous = lastNode
            lastNode.next = newNode
            self.tail = newNode
        } else {
            self.head = newNode
            self.tail = newNode
        }
        
        self.count += 1
        self.removeFrameNodes(olderThanTimestampMoreThanSecond: timestamp)
    }
    
    private func removeFrameNodes(olderThanTimestampMoreThanSecond timestamp: TimeInterval) {
        while let firstNode = self.head {
            guard timestamp - firstNode.timestamp > 1.0 else {
                break
            }
            
            let nextNode = firstNode.next
            nextNode?.previous = nil
            firstNode.next = nil
            self.head = nextNode
            
            self.count -= 1
        }
    }
}
