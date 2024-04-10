//
//  FFMpegSwresampleContext.swift
//  SauronPlayer
//
//  Created by sauron on 2023/8/3.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import Foundation

public class FFMpegSwresampleContext {
    private(set) var pointer: OpaquePointer?
    
    public init?() {
        let contextPointer = swr_alloc()
        
        guard contextPointer != nil else {
            return nil
        }
        self.pointer = contextPointer
    }
    
    deinit {
        swr_free(&pointer)
    }
    
    public func convert(frame: FFMpegAVFrame) {
        let framePointer = av_frame_alloc()
        
//        let resulitCode = swr_convert_frame(pointer, framePointer, frame.pointer)
    }
}
