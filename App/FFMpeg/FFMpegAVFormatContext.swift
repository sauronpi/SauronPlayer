//
//  FFMpegAVFormatContext.swift
//  SauronPlayer
//
//  Created by sauron on 2023/7/31.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import Foundation

public enum FFMpegAVFormatContextError: Error {
    case readPacketOnErrorOrEndOfFile
}

public class FFMpegAVFormatContext {
    private(set) var pointer: UnsafeMutablePointer<AVFormatContext>!
    public var context: AVFormatContext { pointer.pointee }
    
    public var numberOfStreams: UInt32 { context.nb_streams }
    public var streamsPointer: [UnsafeMutablePointer<AVStream>] {
        (0..<numberOfStreams).compactMap { context.streams.advanced(by: Int($0)).pointee}
    }
    public var streams: [FFMpegAVStream] { streamsPointer.map({ FFMpegAVStream(pointer: $0) }) }
    public var videoStreams: [FFMpegVideoStream] {
        streams
        .filter({ $0.codecParameters.codec_type == AVMEDIA_TYPE_VIDEO })
        .map({ FFMpegVideoStream(pointer: $0.pointer) })
    }
    public var audioStreams: [FFMpegAudioStream] {
        streams
        .filter({ $0.codecParameters.codec_type == AVMEDIA_TYPE_AUDIO })
        .map({ FFMpegAudioStream(pointer: $0.pointer) })
    }
    
//    public var duration: TimeInterval { Double(context.duration) / Double(AV_TIME_BASE) }
    public var duration: TimeInterval { Double(context.duration) / Double(AV_TIME_BASE) }

    /// need  avformat_find_stream_info
    public var bitRate: Int64 { context.bit_rate }
    
    public var inputFormat: AVInputFormat { context.iformat.pointee }
    
    public init?(url: URL) {
        var formatContextPointer = avformat_alloc_context()
        let path = url.path
        var resultCode = avformat_open_input(&formatContextPointer, path, nil, nil)
        
        guard resultCode.isNonNegative else {
#if DEBUG
            print("\(Self.self) \(#function) error: avformat_open_input error with code \(resultCode)")
#endif
            avformat_close_input(&formatContextPointer)
            avformat_free_context(formatContextPointer)
            return nil
        }
        
        resultCode = avformat_find_stream_info(formatContextPointer, nil)
        guard resultCode.isNonNegative else {
#if DEBUG
            print("\(Self.self) \(#function) error: avformat_find_stream_info error with code \(resultCode)")
#endif
            avformat_close_input(&formatContextPointer)
            avformat_free_context(formatContextPointer)
            return nil
        }
        self.pointer = formatContextPointer
        #if DEBUG
        av_dump_format(formatContextPointer, 0, path, 0)
        #endif
    }
    
    deinit {
        avformat_close_input(&pointer)
        avformat_free_context(pointer)
//#if DEBUG
//        print("\(Self.self): \(#function)")
//#endif
    }
    
    public func readPacket() -> Result<FFMpegAVPacket, FFMpegAVFormatContextError> {
        var packetPointer = av_packet_alloc()
        let resultCode = av_read_frame(pointer, packetPointer)
        guard resultCode.isNonNegative else {
#if DEBUG
            print("\(Self.self) \(#function) error: \(resultCode). on error or end of file")
#endif
            av_packet_free(&packetPointer)
            return .failure(.readPacketOnErrorOrEndOfFile)
        }
        return .success(FFMpegAVPacket(pointer: packetPointer))
    }
    
    public func bestAudioStream() -> FFMpegAVStream? {
        findBestStream(of: AVMEDIA_TYPE_AUDIO)
    }
    
    public func bestVideoStream() -> FFMpegAVStream? {
        findBestStream(of: AVMEDIA_TYPE_VIDEO)
    }
    
    public func findBestStream(of mediaType: AVMediaType) -> FFMpegAVStream? {
        let resultCode = av_find_best_stream(pointer, mediaType, -1, -1, nil, 0)
        guard resultCode != averror_STREAM_NOT_FOUND() else {
            return nil
        }
        switch mediaType {
        case AVMEDIA_TYPE_UNKNOWN: return nil
        case AVMEDIA_TYPE_VIDEO: return FFMpegVideoStream(pointer: streamsPointer[Int(resultCode)])
        case AVMEDIA_TYPE_AUDIO: return FFMpegAudioStream(pointer: streamsPointer[Int(resultCode)])
        case AVMEDIA_TYPE_DATA: return nil
        case AVMEDIA_TYPE_SUBTITLE: return nil
        case AVMEDIA_TYPE_ATTACHMENT: return nil
        case AVMEDIA_TYPE_NB: return nil
        default: return nil
        }
    }
}

extension FFMpegAVFormatContext: CustomStringConvertible {
    public var description: String {
        "\(context)"
    }
}
