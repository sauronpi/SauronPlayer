//
//  SPAVBufferQueue.swift
//  SauronPlayer
//
//  Created by sauron on 2023/8/22.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import Foundation

public protocol SPAVBufferable {
    var duration: TimeInterval { get }
}

public struct SPAVBufferDuration {
    public let min: TimeInterval
    public let max: TimeInterval
}

extension SPAVBufferDuration {
    public static let packet: SPAVBufferDuration = SPAVBufferDuration(min: 2.0, max: 4.0)
    public static let localFrame: SPAVBufferDuration = SPAVBufferDuration(min: 0.2, max: 0.4)
    public static let networkFrame: SPAVBufferDuration = SPAVBufferDuration(min: 2.0, max: 4.0)
}

public class SPAVBufferQueue<Element: SPAVBufferable> {
    private let queue: DispatchQueue = DispatchQueue(label: "com.sauronpi.SPAVBufferQueue", attributes: .concurrent)
    private var bufferDuration: SPAVBufferDuration
    private var buffer: [Element] = []
    private var _totalDuration: TimeInterval = 0
    
    public init(bufferDuration: SPAVBufferDuration) {
        self.bufferDuration = bufferDuration
    }
    
    public var isNeedDecoding: Bool {
        var result: Bool = false
        queue.sync {
            result = _totalDuration < bufferDuration.min
        }
        return result
    }
    
    public var isNeedStopDecoding: Bool {
        var result: Bool = false
        queue.sync {
            result = _totalDuration > bufferDuration.max
        }
        return result
    }
    
    public var totalDuration: TimeInterval {
        var result: TimeInterval = 0
        queue.sync {
            result = _totalDuration
        }
        return result
    }
    
    public func enQueue(_ element: Element) {
//#if DEBUG
//        print("\(Self.self) \(#function) \(queue.label)")
//#endif
        queue.async(flags: .barrier) { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.buffer.append(element)
            weakSelf._totalDuration += element.duration
        }
    }
    
    public func deQueue() -> Element? {
//#if DEBUG
//        print("\(Self.self) \(#function)")
//#endif
        var result: Element?
        queue.sync {
            guard let element = buffer.first else {
                return
            }
            _totalDuration -= element.duration
            self.buffer.removeFirst()
            result = element
        }
        return result
    }
}

extension FFMpegAVPacket: SPAVBufferable { }

extension FFMpegAVFrame: SPAVBufferable { }
