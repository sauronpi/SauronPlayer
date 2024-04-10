//
//  SPVideoFrameRendererView.swift
//  SauronPlayer
//
//  Created by sauron on 2023/8/11.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import SwiftUI
import MetalKit

/*
 Configuring the Drawing Behavior
 The MTKView class supports three drawing modes:
 Timed updates: The view redraws its contents based on an internal timer. In this case, which is the default behavior, both isPaused and enableSetNeedsDisplay are set to false. Use this mode for games and other animated content that’s regularly updated.
 Draw notifications: The view redraws itself when something invalidates its contents, usually because of a call to setNeedsDisplay() or some other view-related behavior. In this case, set isPaused and enableSetNeedsDisplay to true. Use this mode for apps with a more traditional workflow, where updates happen when data changes, but not on a regular timed interval.
 Explicit drawing: The view redraws its contents only when you explicitly call the draw() method. In this case, set isPaused to true and enableSetNeedsDisplay to false. Use this mode to create your own custom workflow.
 */

struct SPVideoFrameRendererView: CPViewRepresent {
    let frame: FFMpegAVFrame?
    
    func makeView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.isPaused = true
        mtkView.enableSetNeedsDisplay = false
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.clearColor = MTLClearColor(red: 1, green: 0, blue: 0, alpha: 1)
        context.coordinator.renderer = MetalVideoFrameRenderer(mtkView: mtkView)
        mtkView.delegate = context.coordinator.renderer
        
        return mtkView
    }
    
    func updateView(_ view: MTKView, context: Context) {
        guard let f = frame else {
            return
        }
        context.coordinator.renderer?.setTexture(from: f)
        view.draw()
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator {
        var renderer: MetalVideoFrameRenderer?
    }
}


//struct VideoFrameView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoFrameView()
//    }
//}
