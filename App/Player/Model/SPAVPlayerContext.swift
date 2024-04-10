//
//  SPAVCodeDecodeContext.swift
//  SauronPlayer
//
//  Created by sauron on 2023/8/16.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import Foundation

public class SPAVPlayerContext {
    public enum CodeDecodeState {
        case decoding
        case stop
    }
    
    public enum ReadPacketState {
        case reading
        case stop
        case errorOfEndOfFile
    }
    
    private let queue: DispatchQueue = DispatchQueue(label: "com.sauronpi.SPAVCodeDecodeContext", attributes: .concurrent)
    private(set) var formatContext: FFMpegAVFormatContext
    
    private var audioDecoder: SPAVPacketDecoder?
    private var videoDecoder: SPAVPacketDecoder?
    
    private var audioStream: FFMpegAVStream?
    private var videoStream: FFMpegAVStream?
    
    private(set) var audioPacketQueue: SPAVBufferQueue = SPAVBufferQueue<FFMpegAVPacket>(bufferDuration: .packet)
    private(set) var videoPacketQueue: SPAVBufferQueue = SPAVBufferQueue<FFMpegAVPacket>(bufferDuration: .packet)
    
    private(set) var state: CodeDecodeState = .stop
    
    private var readPacketState: ReadPacketState = .stop
    
    public init(formatContext: FFMpegAVFormatContext) {
        self.formatContext = formatContext
        if let audioStream = formatContext.bestAudioStream() {
            setAudioStream(audioStream)
        }
        if let videoStream = formatContext.bestVideoStream() {
            setVideoStream(videoStream)
        }
    }
    
    public convenience init?(url: URL) {
        guard let context = FFMpegAVFormatContext(url: url) else {
            return nil
        }
        self.init(formatContext: context)
    }
}

// MARK: public
extension SPAVPlayerContext {
    public func startDecoding() {
        guard audioDecoder != nil || videoDecoder != nil else {
#if DEBUG
            print("\(Self.self) \(#function) codecContext not found")
#endif
            return
        }
        
        guard state != .decoding else {
            return
        }
        
        state = .decoding
        
        startReadPacket()
        audioDecoder?.startDecoding()
        videoDecoder?.startDecoding()
#if DEBUG
        print("\(Self.self) \(#function)")
#endif
    }
    
    public func stopDecoding() {
        guard state != .stop else {
            return
        }
#if DEBUG
        print("\(Self.self) \(#function)")
#endif
        state = .stop
        stopReadPacket()
        videoDecoder?.stopDecoding()
    }
    
    public func setAudioStream(_ stream: FFMpegAVStream) {
#if DEBUG
        print("audio stream time base: \(stream.stream.time_base)")
#endif
        self.audioStream = stream
        if let context = FFMpegAVCodecContext(codecParameters: stream.codecParameters) {
#if DEBUG
            print("audioCodecContext time base: \(context.timeBase)")
            print("audioCodecContext real time base: \(context.realTimeBase)")
#endif
            self.audioDecoder = SPAVPacketDecoder(context: context, packetQueue: audioPacketQueue, mediaType: AVMEDIA_TYPE_AUDIO)
        }
    }
    
    public func setVideoStream(_ stream: FFMpegAVStream) {
#if DEBUG
        print("video stream time base: \(stream.stream.time_base)")
#endif
        self.videoStream = stream
        if let context = FFMpegAVCodecContext(codecParameters: stream.codecParameters) {
#if DEBUG
            print("videoCodecContext time base: \(context.timeBase)")
            print("videoCodecContext real time base: \(context.realTimeBase)")
#endif
            self.videoDecoder = SPAVPacketDecoder(context: context, packetQueue: videoPacketQueue, mediaType: AVMEDIA_TYPE_VIDEO)
        }
    }
    
    public func nextVideoFrame() -> FFMpegAVFrame? {
        guard let decoder = videoDecoder else {
            return nil
        }
        let frame = decoder.frameQueue.deQueue()
        if videoPacketQueue.isNeedDecoding {
            startReadPacket()
        }
        if decoder.frameQueue.isNeedDecoding {
            decoder.startDecoding()
        }
        return frame
    }
    
}

// MARK: private
extension SPAVPlayerContext {
    private func packetMediaType(_ packet: FFMpegAVPacket) -> AVMediaType {
        if packet.streamIndex == self.videoStream?.index {
            return AVMEDIA_TYPE_VIDEO
        }
        
        if packet.streamIndex == self.audioStream?.index {
            return AVMEDIA_TYPE_AUDIO
        }
        return AVMEDIA_TYPE_UNKNOWN
    }
    
    private func readingPacket() {
        while readPacketState == .reading {
            let result = formatContext.readPacket()
            switch result {
            case .success(let packet):
                let mediaType = packetMediaType(packet)
                //                #if DEBUG
                //                print(packet)
                //                #endif
                if mediaType == AVMEDIA_TYPE_AUDIO {
                    packet.timeBase = audioStream?.timeBase ?? av_make_q(0, 1)
                    audioPacketQueue.enQueue(packet)
//                    print("audio packet: \(count)")
                }
                if mediaType == AVMEDIA_TYPE_VIDEO {
                    packet.timeBase = videoStream?.timeBase ?? av_make_q(0, 1)
                    videoPacketQueue.enQueue(packet)
                    if videoPacketQueue.isNeedStopDecoding {
                        stopReadPacket()
                    }
                    //                    print("video packet: \(count)")
                }
            case .failure(let failure):
#if DEBUG
                print("\(Self.self) \(#function) readPacket error: \(failure)")
#endif
                readPacketErrorOrEndOfFile()
            }
        }
    }
    
    private func startReadPacket() {
#if DEBUG
        print("\(Self.self) \(#function)")
#endif
        readPacketState = .reading
        queue.async { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.readingPacket()
        }
    }
    
    private func stopReadPacket() {
#if DEBUG
        print("\(Self.self) \(#function)")
#endif
        readPacketState = .stop
    }
    
    private func readPacketErrorOrEndOfFile() {
        readPacketState = .errorOfEndOfFile
    }
}
