//
//  SPAVPacketDecoder.swift
//  SauronPlayer
//
//  Created by sauron on 2023/8/22.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import Foundation

public class SPAVPacketDecoder {
    public enum DecoderState {
        case decoding
        case stop
        case endOfFile
    }
    private let queue: DispatchQueue = DispatchQueue(label: "com.sauronpi.SPAVDecoder")
    private let context: FFMpegAVCodecContext
    private let packetQueue: SPAVBufferQueue<FFMpegAVPacket>
    public let frameQueue:  SPAVBufferQueue<FFMpegAVFrame> = SPAVBufferQueue<FFMpegAVFrame>(bufferDuration: .localFrame)
    
    private var state: DecoderState = .stop
    private(set) var mediaType: AVMediaType
    
    public init(context: FFMpegAVCodecContext, packetQueue: SPAVBufferQueue<FFMpegAVPacket>, mediaType: AVMediaType) {
        self.context = context
        self.packetQueue = packetQueue
        self.mediaType = mediaType
    }
}

// MARK: public
extension SPAVPacketDecoder {
    public func startDecoding() {
#if DEBUG
        print("\(Self.self) \(#function) \(mediaType)")
#endif
        state = .decoding
        queue.async { [weak self] in
            self?.decoding()
        }
    }
    
    public func stopDecoding() {
#if DEBUG
        print("\(Self.self) \(#function) \(mediaType)")
#endif
        state = .stop
    }
}

// MARK: private
extension SPAVPacketDecoder {
    
    private func endOfFile() {
#if DEBUG
        print("\(Self.self) \(#function)")
#endif
        state = .endOfFile
    }
    
    private func decoding() {
        var sendPacketError: FFMpegAVCodecSendPacketError? = nil
        
        while state == .decoding && sendPacketError == nil {
            guard let packet = packetQueue.deQueue() else {
                continue
            }
 
            do {
                try context.sendPacket(packet)
            } catch let error {
#if DEBUG
                print("\(Self.self) \(#function) sendPacket error: \(error)")
#endif
                let e = error as! FFMpegAVCodecSendPacketError
                sendPacketError = e
                switch e {
                case .mustReadOutput:
                    break
                case .endOfFile:
                    break
                case .codeContextNotOpenedOrItIsAnEncoder:
                    break
                case .failedRoAddPacketRoInternalQueue:
                    break
                case .legitimateDecodingErrors:
                    break
                }
            }
            
            var receiveFrameError: FFMpegAVCodecReceiveFrameError? = nil
            while receiveFrameError == nil || sendPacketError == .mustReadOutput {
                receiveFrameError = nil
                let result = context.receiveFrame()
                switch result {
                case .success(let frame):
                    if mediaType == AVMEDIA_TYPE_AUDIO {
                        
                    }
                    frame.timeBase = context.realTimeBase //?? av_make_q(0, 1)
                    frameQueue.enQueue(frame)
                    if frameQueue.isNeedStopDecoding {
                        stopDecoding()
                    }
                case .failure(let error):
#if DEBUG
                    if error != .mustSendInput {
                        print("\(Self.self) \(#function) receiveFrame error: \(error)")
                    }
#endif
                    receiveFrameError = error
                    //                                switch error {
                    //                                case .mustSendInput:
                    //                                    break
                    //                                case .endOfFile:
                    //                                    break
                    //                                case .codeContextNotOpenedOrItIsAnEncoder:
                    //                                    break
                    //                                case .inputChanged:
                    //                                    break
                    //                                case .legitimateDecodingErrors:
                    //                                    break
                    //                                }
                }
            }
        }
    }
}
