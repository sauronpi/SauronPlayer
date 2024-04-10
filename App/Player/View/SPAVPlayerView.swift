//
//  SPAVPlayerView.swift
//  SauronPlayer
//
//  Created by sauron on 2023/8/11.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import SwiftUI

struct SPAVPlayerView: View {
    @ObservedObject var player: SPAVPlayer

    var body: some View {
        ZStack {
            SPVideoFrameRendererView(frame: player.videoFrame)
            SPAVPlayerOSDView(player: player)
        }
    }
}
//
//struct SPAVPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        SPAVPlayerView()
//    }
//}
