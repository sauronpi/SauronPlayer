//
//  SPAVPlayerOSDView.swift
//  SauronPlayer
//
//  Created by 林少龙 on 2023/8/11.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import SwiftUI

struct SPAVPlayerOSDView: View {
    @ObservedObject var player: SPAVPlayer

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Button {
                        player.playOrPause()
                    } label: {
                        Image(systemName: player.state == .playing ? "pause.fill" : "play.fill")
                    }

                    Button {
                        player.stop()
                    } label: {
                        Image(systemName: "stop.fill")
                    }
                }
                .backgroundStyle(.regularMaterial)
            }
        }
    }
}

//struct SPAVPlayerOSDView_Previews: PreviewProvider {
//    static var previews: some View {
//        SPAVPlayerOSDView()
//    }
//}
