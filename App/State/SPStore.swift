//
//  SPStore.swift
//  SauronPlayer
//
//  Created by sauron on 2023/7/31.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import SwiftUI
import Combine

public protocol SPAppCommand {
    func execute(in store: SPStore)
}

public struct SPAVFormatContextCommand: SPAppCommand {
    let url: URL
    
    public func execute(in store: SPStore) {
        
    }
}

public enum SPAppAction {
    case openFile(_ url: URL)
    case openFileDone(_ context: FFMpegAVFormatContext?)
    case receiveVideoFrame(_ frame: FFMpegAVFrame?)
}

public struct SPAppState {
    public var avFormatContext: FFMpegAVFormatContext?
    public var videoFrame: FFMpegAVFrame?
    public var audioFrame: FFMpegAVFrame?
}

public class SPStore: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    public static let shared = SPStore()
    @Published var appState = SPAppState()
    
    public func dispatch(_ action: SPAppAction) {
        //        #if DEBUG
        //        print("[ACTION]: \(action)")
        //        #endif
        let result = reduce(state: appState, action: action)
        appState = result.0
        if let appCommand = result.1 {
            //            #if DEBUG
            //            print("[COMMAND]: \(appCommand)")
            //            #endif
            appCommand.execute(in: self)
        }
    }
    
    private func reduce(state: SPAppState, action: SPAppAction) -> (SPAppState, SPAppCommand?) {
        var appState = state
        var appCommand: SPAppCommand? = nil
        switch action {
        case .openFile(let url):
            appCommand = SPAVFormatContextCommand(url: url)
        case .openFileDone(let context):
            appState.avFormatContext = context
        case .receiveVideoFrame(let frame):
            appState.videoFrame = frame
            break;
        }
        
        return (appState, appCommand)
    }
}
