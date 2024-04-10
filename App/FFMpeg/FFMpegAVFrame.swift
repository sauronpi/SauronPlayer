//
//  FFMpegAVFrame.swift
//  SauronPlayer
//
//  Created by sauron on 2023/8/3.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import Foundation

public class FFMpegAVFrame {
    public typealias LinesizeType = (Int32, Int32, Int32, Int32, Int32, Int32, Int32, Int32)
    public typealias DataType = (UnsafeMutablePointer<UInt8>?, UnsafeMutablePointer<UInt8>?, UnsafeMutablePointer<UInt8>?, UnsafeMutablePointer<UInt8>?, UnsafeMutablePointer<UInt8>?, UnsafeMutablePointer<UInt8>?, UnsafeMutablePointer<UInt8>?, UnsafeMutablePointer<UInt8>?)

    private(set) var pointer: UnsafeMutablePointer<AVFrame>!
    public var frame: AVFrame { pointer.pointee }
    public var data: DataType { frame.data }
    public var lineSize: LinesizeType { frame.linesize }
    public var extensionDataPointer: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?> { frame.extended_data }

    public var timeBase: AVRational {
        get { frame.time_base }
        set { pointer.pointee.time_base = newValue }
    }
    public var duration: TimeInterval { av_q2d(frame.time_base) }

    public init(pointer: UnsafeMutablePointer<AVFrame>!) {
        self.pointer = pointer
    }
    
    deinit {
        av_frame_free(&pointer)
        //#if DEBUG
        //        print("\(Self.self) \(#function)")
        //#endif
    }
}

extension FFMpegAVFrame: CustomStringConvertible {
    public var description: String { String(describing: frame) }
}

// MARK: audio
extension FFMpegAVFrame {
    public var audioFormat: AVSampleFormat { AVSampleFormat(frame.format) }
    public var numberOfAudioSamples: Int32 { frame.nb_samples }
    public var channelLayout: AVChannelLayout { frame.ch_layout }
    public var sampleRate: Int32 { frame.sample_rate }
}

// MARK: video
extension FFMpegAVFrame {
    public var videoFormat: AVPixelFormat { AVPixelFormat(frame.format) }
    public var width: Int32 { frame.width }
    public var height: Int32 { frame.height }
    public var isKeyFrame: Bool { frame.key_frame == 1 }
    public var sampleSspectRatio: AVRational { frame.sample_aspect_ratio }
    public var colorSpace: AVColorSpace { frame.colorspace }
}
