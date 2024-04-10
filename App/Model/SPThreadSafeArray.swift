//
//  SPThreadSafeArray.swift
//  SauronPlayer
//
//  Created by sauron on 2023/8/21.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import Foundation

public class SPThreadSafeQueue<T> {
    public let queue: DispatchQueue
    private var array: [T] = []
    private var _totalDuration: TimeInterval = 0
    
    public init(label: String) {
        self.queue = DispatchQueue.init(label: label, attributes: .concurrent)
    }
    
    public func push(_ item: T) {
#if DEBUG
        print("\(Self.self) \(#function) \(queue.label)")
#endif
        queue.async(flags: .barrier) { [weak self] in
            self?.array.append(item)
        }
    }
    
    public func pop() -> T? {
#if DEBUG
        print("\(Self.self) \(#function) \(queue.label)")
#endif
        var result: T?
        queue.sync {
            guard let frame = self.array.first else {
                return
            }
            self.array.removeFirst()
            result = frame
        }
        return result
    }
}
