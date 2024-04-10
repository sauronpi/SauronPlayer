//
//  FFMpegAVCodecContext.swift
//  SauronPlayer
//
//  Created by sauron on 2023/8/1.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import Foundation

public enum FFMpegAVCodecSendPacketError: Error {
    case mustReadOutput
    case endOfFile
    case codeContextNotOpenedOrItIsAnEncoder
    case failedRoAddPacketRoInternalQueue
    case legitimateDecodingErrors
}

public enum FFMpegAVCodecReceiveFrameError: Error {
    case mustSendInput
    case endOfFile
    case codeContextNotOpenedOrItIsAnEncoder
    case inputChanged
    case legitimateDecodingErrors
}

public class FFMpegAVCodecContext {
    private(set) var pointer: UnsafeMutablePointer<AVCodecContext>!
    public var context: AVCodecContext { pointer.pointee }
    private(set) var decoderPointer: UnsafePointer<AVCodec>!
    
    public var timeBase: AVRational { context.time_base }
    public var ticksPerFrame: Int32 { context.ticks_per_frame }
    public var realTimeBase: AVRational { av_make_q(timeBase.num, timeBase.den / ticksPerFrame)}

    public init?(codecParameters: AVCodecParameters) {
        guard let decoderPointer = avcodec_find_decoder(codecParameters.codec_id) else {
#if DEBUG
            print("\(Self.self) \(#function) error: decoder not found.")
#endif
            return nil
        }
        
        guard let avcodecContextPointer = avcodec_alloc_context3(decoderPointer) else {
#if DEBUG
            print("\(Self.self) \(#function) error: avcodec_alloc_context3 failed.")
#endif
            return nil
        }
        var avcodecContextPointerTemp: UnsafeMutablePointer<AVCodecContext>! = avcodecContextPointer
        var codecParametersTemp = codecParameters
        var resultCode = avcodec_parameters_to_context(avcodecContextPointer, &codecParametersTemp)
        guard resultCode.isNonNegative else {
#if DEBUG
            print("\(Self.self) \(#function) error: avcodec_parameters_to_context failed with code: \(resultCode).")
#endif
            avcodec_free_context(&avcodecContextPointerTemp)
            return nil
        }
        
        resultCode = avcodec_open2(avcodecContextPointer, decoderPointer, nil)
        guard resultCode.isNonNegative else {
#if DEBUG
            print("\(Self.self) \(#function) error: avcodec_open2 failed with code: \(resultCode).")
#endif
            avcodec_free_context(&avcodecContextPointerTemp)
            return nil
        }
        
        self.pointer = avcodecContextPointer
        self.decoderPointer = decoderPointer
    }
    
    deinit {
        avcodec_close(pointer);
        avcodec_free_context(&pointer)
    }
    
    public func sendPacket(_ packet: FFMpegAVPacket) throws {
        let resultCode = avcodec_send_packet(pointer, packet.pointer)

        if resultCode.isZero {
            return
        }

        if resultCode == averror_EAGAIN() {
            throw FFMpegAVCodecSendPacketError.mustReadOutput
        } else if resultCode == averror_EOF() {
            throw FFMpegAVCodecSendPacketError.endOfFile
        } else if resultCode == averror_EINVAL() {
            throw FFMpegAVCodecSendPacketError.codeContextNotOpenedOrItIsAnEncoder
        } else if resultCode == averror_ENOMEM() {
            throw FFMpegAVCodecSendPacketError.failedRoAddPacketRoInternalQueue
        } else {
            throw FFMpegAVCodecSendPacketError.legitimateDecodingErrors
        }
    }
    
    public func receiveFrame() -> Result<FFMpegAVFrame, FFMpegAVCodecReceiveFrameError> {
        let framePointer = av_frame_alloc()
        let resultCode = avcodec_receive_frame(pointer, framePointer)
        guard resultCode.isZero else {
            if resultCode == averror_EAGAIN() {
                return .failure(.mustSendInput)
            } else if resultCode == averror_EOF() {
                return .failure(.endOfFile)
            } else if resultCode == averror_EINVAL() {
                return .failure(.codeContextNotOpenedOrItIsAnEncoder)
            } else if resultCode == AVERROR_INPUT_CHANGED {
                return .failure(.inputChanged)
            } else {
                return .failure(.legitimateDecodingErrors)
            }
        }
        return .success(FFMpegAVFrame(pointer: framePointer))
    }
    
}

extension FFMpegAVCodecContext: CustomStringConvertible {
    public var description: String { String(describing: context) }
}
