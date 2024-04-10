//
//  SPDispalyLink.swift
//  SauronPlayer
//
//  Created by sauron on 2023/8/16.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import Foundation
import Combine
import CoreVideo

extension CVTimeStamp {
    public var timeInterval: TimeInterval {
        return TimeInterval(videoTime) / TimeInterval(self.videoTimeScale)
    }
}

public protocol SPDispalyLinkDelegate: AnyObject {
    func displayLink(_ displayLink: SPDispalyLink, recived output: DisplayLinkOutput)
}

public struct DisplayLinkOutput {
    public var inNow: CVTimeStamp
    public var inOutputTime: CVTimeStamp
    public var flagsIn: CVOptionFlags
    public var flagsOut: CVOptionFlags

    public var timestamp: TimeInterval { inNow.timeInterval }
    public var duration: TimeInterval {inOutputTime.timeInterval - inNow.timeInterval }
}

public class SPDispalyLink {
    private var displayLink: CVDisplayLink?
    @Published var displayLinkOutput: DisplayLinkOutput?
    
    public weak var delegate: SPDispalyLinkDelegate?

    public init() {
        let result = CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        #if DEBUG
        print("CVDisplayLinkCreateWithActiveCGDisplays result: \(result)")
        #endif
        if let d = displayLink {
            CVDisplayLinkSetOutputHandler(d) {[weak self] displaylink, inNow, inOutputTime, flagsIn, flagsOut in
                let result = self?.displayLinkOutputHandler(displayLink: displaylink, inNow: inNow, inOutputTime: inOutputTime, flagsIn: flagsIn, flagsOut: flagsOut) ?? kCVReturnError
                return result
            }
        }
    }
    
    public func start() {
        guard let d = displayLink else {
            return
        }
        CVDisplayLinkStart(d)
    }
    
    public func stop() {
        guard let d = displayLink else {
            return
        }
        CVDisplayLinkStop(d)
    }
    
    private func displayLinkOutputHandler(displayLink: CVDisplayLink,
                                  inNow: UnsafePointer<CVTimeStamp>,
                                  inOutputTime: UnsafePointer<CVTimeStamp>,
                                  flagsIn: CVOptionFlags,
                                  flagsOut: UnsafeMutablePointer<CVOptionFlags>) -> CVReturn {
        let output = DisplayLinkOutput(inNow: inNow.pointee, inOutputTime: inOutputTime.pointee, flagsIn: flagsIn, flagsOut: flagsOut.pointee)
        self.displayLinkOutput = output
        self.delegate?.displayLink(self, recived: output)
        return kCVReturnSuccess
    }

}
