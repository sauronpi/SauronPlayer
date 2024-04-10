//
//  FFMpegAVPacket.swift
//  SauronPlayer
//
//  Created by sauron on 2023/8/1.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import Foundation

public class FFMpegAVPacket {
    private(set) var pointer: UnsafeMutablePointer<AVPacket>!
    public var packet: AVPacket { pointer.pointee }
    
    public var streamIndex:Int32 { packet.stream_index }
    
    public var timeBase: AVRational {
        set {
            pointer.pointee.time_base = newValue
        }
        
        get {
            packet.time_base
        }
    }
    
    public var duration: TimeInterval { Double(packet.duration) * av_q2d(packet.time_base)}

    public init(pointer: UnsafeMutablePointer<AVPacket>!) {
        self.pointer = pointer
    }
    
    deinit {
        av_packet_free(&pointer)
//#if DEBUG
//        print("\(Self.self) \(#function)")
//#endif
    }
}

extension FFMpegAVPacket: CustomStringConvertible {
    public var description: String { String(describing: packet) }
}
