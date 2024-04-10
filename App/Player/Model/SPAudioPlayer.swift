//
//  SPAudioPlayer.swift
//  SauronPlayer
//
//  Created by sauron on 2023/8/27.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import Foundation
import AVFoundation

public class SPAudioPlayer {
    public let audioFile: AVAudioFile
    public let audioEngine = AVAudioEngine()
    public let playerNode = AVAudioPlayerNode()
    
    public init(audioFile: AVAudioFile) {
        self.audioFile = audioFile
        // Attach the player node to the audio engine.
        audioEngine.attach(playerNode)

        // Connect the player node to the output node.
        audioEngine.connect(playerNode,
                            to: audioEngine.outputNode,
                            format: audioFile.processingFormat)
        playerNode.scheduleFile(audioFile,
                                at: nil,
                                completionCallbackType: .dataPlayedBack) { _ in
            /* Handle any work that's necessary after playback. */
        }
    }
    
    public func play() {
        do {
            try audioEngine.start()
            playerNode.play()
        } catch let error {
            /* Handle the error. */
            #if DEBUG
            print(error)
            #endif
        }
    }
}
