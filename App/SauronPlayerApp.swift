//
//  SauronPlayerApp.swift
//  SauronPlayer
//
//  Created by sauron on 2023/7/29.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import SwiftUI

@main
struct SauronPlayerApp: App {
#if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
    var body: some Scene {
        WindowGroup {
            ContentView()
#if os(macOS)
                .frame(width: 800, height: 600)
#endif
        }
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
#endif
    }
}

#if os(macOS)
class AppDelegate:NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
    }
    
}
#endif
