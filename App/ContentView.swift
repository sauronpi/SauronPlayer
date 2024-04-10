//
//  ContentView.swift
//  SauronPlayer
//
//  Created by sauron on 2023/7/29.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject private var store = SPStore.shared
    @State private var fileURL: URL? = nil
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(LinearGradient(colors: [.red, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 100)
                .mask({
                    HStack(spacing: 5) {
                        ForEach(0..<50) { item in
                            Rectangle()
                                .frame(width: 10)
                        }
                    }
                })
                .mask(Text("SauronPlayer").font(.system(size: 80)))
            if let url = fileURL {
                let player = SPAVPlayer(url: url)
                SPAVPlayerView(player: player)
                if let context = player.context?.formatContext {
                    SPAVFormatContextView(context: context)
                }
            }
        }
        .padding()
        .onDrop(of: [.movie, .audio], delegate: self)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

extension ContentView: DropDelegate {
    func performDrop(info: DropInfo) -> Bool {
        
        func loadMovieItemDone(item: NSSecureCoding?, error: Error?) {
            guard let url = item as? URL else {
                return
            }
            DispatchQueue.main.async {
                self.fileURL = url
//                SPStore.shared.dispatch(.openFile(url))
            }
        }
        
        func loadAudioItemDone(item: NSSecureCoding?, error: Error?) {
            guard let url = item as? URL else {
                return
            }
            SPStore.shared.dispatch(.openFile(url))
        }
        
        let movieItemProviders = info.itemProviders(for: [.movie])
        for provider in movieItemProviders {
            provider.loadItem(forTypeIdentifier: UTType.movie.identifier, options: nil, completionHandler: loadMovieItemDone)
        }
        
        let audioItemProviders = info.itemProviders(for: [.audio])
        for provider in audioItemProviders {
            provider.loadItem(forTypeIdentifier: UTType.audio.identifier, options: nil, completionHandler: loadAudioItemDone)
        }
        
        return true
    }
}

