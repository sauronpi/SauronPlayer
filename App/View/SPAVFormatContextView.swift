//
//  SPAVFormatContextView.swift
//  SauronPlayer
//
//  Created by sauron on 2023/7/31.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import SwiftUI

struct SPAVFormatContextView: View {
    let context: FFMpegAVFormatContext
    
    var body: some View {
        Text("stream count: \(context.numberOfStreams)")
        Text("duration: \(DateComponentsFormatter().string(from: context.duration) ?? "0")")
        Text("bitRate: \(context.bitRate)")
        Text("format: \(String(cString: context.inputFormat.name))")
    }
}

//#if DEBUG
//struct SPAVFormatContextView_Previews: PreviewProvider {
//    static var previews: some View {
//        SPAVFormatContextView()
//    }
//}
//#endif
