//
//  FFMpegAVStream.swift
//  SauronPlayer
//
//  Created by sauron on 2023/8/1.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import Foundation

public class FFMpegAVStream {
    public var pointer: UnsafeMutablePointer<AVStream>

    public init(pointer: UnsafeMutablePointer<AVStream>) {
        self.pointer = pointer
    }

}

extension FFMpegAVStream {
    public var stream: AVStream { pointer.pointee }
    public var index: Int32 { stream.index }
    public var codecParameters: AVCodecParameters { stream.codecpar.pointee }
    public var formatID: Int32 { codecParameters.format }
    public var timeBase: AVRational { stream.time_base }
}

public class FFMpegAudioStream: FFMpegAVStream { }

extension FFMpegAudioStream {
    public var format: AVSampleFormat { AVSampleFormat(formatID) }
}

extension FFMpegAudioStream: CustomStringConvertible {
    public var description: String {
        String(describing: stream)
    }
}

public class FFMpegVideoStream: FFMpegAVStream { }

extension FFMpegVideoStream {
    public var format: AVPixelFormat { AVPixelFormat(formatID) }
}

extension FFMpegVideoStream: CustomStringConvertible {
    public var description: String {
        String(describing: stream)
    }
}
