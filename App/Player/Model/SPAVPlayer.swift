//
//  SPAVPlayer.swift
//  SauronPlayer
//
//  Created by sauron on 2023/8/10.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import Foundation
import Combine

public enum SPAVPlayerState {
    case playing
    case paused
    case stoped
}

public class SPAVPlayer: ObservableObject {
    private let displayLink: SPDispalyLink
    private(set) var context: SPAVPlayerContext?
    @Published var state: SPAVPlayerState = .stoped
    @Published var videoFrame: FFMpegAVFrame? = nil
    private var videoFrameTimestamp: TimeInterval = 0
    private var nextVideoFrame: FFMpegAVFrame? = nil

    public init(url: URL) {
        self.context = SPAVPlayerContext(url: url)
        self.displayLink = SPDispalyLink()
        self.displayLink.delegate = self
    }
}

// MARK: public func
extension SPAVPlayer {
    public func playOrPause() {
        switch state {
        case .playing: pause()
        case .paused: play()
        case .stoped: play()
        }
    }
    
    public func play() {
        guard let context = self.context else {
            return
        }
        
        guard state != .playing else {
            return
        }
        
        state = .playing

        context.startDecoding()
        // wait decoding
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.displayLink.start()
        }
    }
    
    public func pause() {
        guard state != .paused else {
            return
        }
        
        state = .paused
        displayLink.stop()
        context?.stopDecoding()
    }
    
    public func stop() {
        guard state != .stoped else {
            return
        }
        
        state = .stoped
        displayLink.stop()
        context?.stopDecoding()
    }
}

// MARK: private func
extension SPAVPlayer {
    private func refreshVideoFrame(displayLinkOutput: DisplayLinkOutput) {
//#if DEBUG
//        print("\(Self.self) \(#function)")
//#endif
        nextVideoFrame = context?.nextVideoFrame()
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.videoFrame = weakSelf.nextVideoFrame
            weakSelf.videoFrameTimestamp = displayLinkOutput.timestamp
        }
    }
}

// MARK: SPDispalyLinkDelegate
extension SPAVPlayer: SPDispalyLinkDelegate {
    public func displayLink(_ displayLink: SPDispalyLink, recived output: DisplayLinkOutput) {
        guard let f = videoFrame else {
            refreshVideoFrame(displayLinkOutput: output)
            return
        }
        if (output.timestamp - videoFrameTimestamp) > f.duration {
            refreshVideoFrame(displayLinkOutput: output)
        }
    }
}
