//
//  CrossPlatformHelper.swift
//  SauronPlayer
//
//  Created by sauron on 2021/12/20.
//  Copyright © 2022 com.sauronpi. All rights reserved.
//

import SwiftUI

#if os(macOS)
import AppKit
public typealias CPColor = NSColor
public typealias CPImage = NSImage
public typealias CPFont = NSFont
public typealias CPScreen = NSScreen

public typealias CPHostingController = NSHostingController
public typealias CPView = NSView
public typealias CPViewController = NSViewController
public typealias CPViewRepresentable = NSViewRepresentable
public typealias CPViewControllerRepresentable = NSViewControllerRepresentable
#endif

#if os(iOS)
import UIKit
public typealias CPColor = UIColor
public typealias CPImage = UIImage
public typealias CPFont = UIFont
public typealias CPScreen = UIScreen

public typealias CPHostingController = UIHostingController
public typealias CPView = UIView
public typealias CPViewController = UIViewController
public typealias CPViewRepresentable = UIViewRepresentable
public typealias CPViewControllerRepresentable = UIViewControllerRepresentable
#endif

extension Image {
    public init(crossImage: CPImage) {
#if os(macOS)
        self.init(nsImage: crossImage)
#endif
#if os(iOS)
        self.init(uiImage: crossImage)
#endif
    }
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, *)
@available(watchOS, unavailable)
protocol CPViewRepresent: CPViewRepresentable {
#if os(macOS)
    associatedtype ViewType = Self.NSViewType
#endif
#if os(iOS)
    associatedtype ViewType = Self.UIViewType
#endif
    func makeView(context: Self.Context) -> ViewType
    func updateView(_ view: ViewType, context: Self.Context)
}

extension CPViewRepresent {
#if os(macOS)
    public func makeNSView(context: Context) -> Self.ViewType {
        makeView(context: context)
    }
    
    public func updateNSView(_ nsView: Self.ViewType, context: Context) {
        updateView(nsView, context: context)
    }
#endif
    
#if os(iOS)
    public func makeUIView(context: Context) -> Self.ViewType {
        makeView(context: context)
    }
    
    public func updateUIView(_ uiView: Self.ViewType, context: Context) {
        updateView(uiView, context: context)
    }
#endif
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, *)
@available(watchOS, unavailable)
public struct PlatformViewRepresent: CPViewRepresent {
    public let view: CPView
    
    public init(_ view: CPView) {
        self.view = view
    }
    
    func makeView(context: Context) -> CPView {
        return view
    }
    
    func updateView(_ view: CPView, context: Context) {
        
    }
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, *)
@available(watchOS, unavailable)
protocol CPViewControllerRepresent: CPViewControllerRepresentable {
#if os(macOS)
    associatedtype ViewControllerType = Self.NSViewControllerType
#endif
#if os(iOS)
    associatedtype ViewControllerType = Self.UIViewControllerType
#endif
    func makeViewController(context: Self.Context) -> ViewControllerType
    func updateViewController(_ viewController: Self.ViewControllerType, context: Self.Context)
}

extension CPViewControllerRepresent {
#if os(macOS)
    public func makeNSViewController(context: Context) -> Self.ViewControllerType {
        makeViewController(context: context)
    }
    
    public func updateNSViewController(_ nsViewController: Self.ViewControllerType, context: Context) {
        updateViewController(nsViewController, context: context)
    }
#endif
    
#if os(iOS)
    public func makeUIViewController(context: Context) -> Self.ViewControllerType {
        makeViewController(context: context)
    }
    
    public func updateUIViewController(_ uiViewController: Self.ViewControllerType, context: Context) {
        updateViewController(uiViewController, context: context)
    }
#endif
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, *)
@available(watchOS, unavailable)
public struct PlatformViewControllerRepresent: CPViewControllerRepresent {
    public let viewController: CPViewController
    
    public init(_ viewController: CPViewController) {
        self.viewController = viewController
    }
    
    func makeViewController(context: Context) -> CPViewController {
        return viewController
    }
    
    func updateViewController(_ viewController: CPViewController, context: Context) {
        
    }
}
