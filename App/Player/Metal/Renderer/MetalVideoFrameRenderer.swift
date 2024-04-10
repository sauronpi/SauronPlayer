//
//  MetalVideoFrameRenderer.swift
//  SauronPlayer
//
//  Created by sauron on 2023/5/31.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import Foundation
import MetalKit

public class MetalVideoFrameRenderer: NSObject, MTKViewDelegate {
    private var device: MTLDevice
    private var drawableSize: CGSize
    private var viewPortSize: vector_uint2
    private var pipelineState: MTLRenderPipelineState
    private var yTexture: MTLTexture!
    private var uTexture: MTLTexture!
    private var vTexture: MTLTexture!
    
    private var commandQueue: MTLCommandQueue
    
    public init?(mtkView: MTKView) {
        guard let device = mtkView.device else {
            return nil
        }
        
        self.device = device
        self.drawableSize = .zero
        self.viewPortSize = vector_uint2(x: 0, y: 0)
        
        let metalLibrary = device.makeDefaultLibrary()
        guard let vertexFunction = metalLibrary?.makeFunction(name: "YUVTextureVertexShader") else {
            return nil
        }
        guard let fragmentFunction = metalLibrary?.makeFunction(name: "YUVTextureFragmentShader") else {
            return nil
        }
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = "Texture Pipeline"
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        do {
            self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        guard let commandQueue = device.makeCommandQueue() else {
            return nil
        }
        self.commandQueue = commandQueue
        super.init()
    }
    
    deinit {
#if DEBUG
        print("\(Self.self) deinit" )
#endif
    }
    
    public func setTexture(from frame: FFMpegAVFrame) {
        let yRegion = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0), size: MTLSize(width: Int(frame.width), height: Int(frame.height), depth: 1))
        let uvRegion = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0), size: MTLSize(width: Int(frame.width / 2), height: Int(frame.height / 2), depth: 1))
        
        let yTextureDescriptor: MTLTextureDescriptor = .texture2DDescriptor(pixelFormat: .r8Unorm, width: Int(frame.width), height: Int(frame.height), mipmapped: false)
        let uvTextureDescriptor: MTLTextureDescriptor = .texture2DDescriptor(pixelFormat: .r8Unorm, width: Int(frame.width / 2), height: Int(frame.height / 2), mipmapped: false)
        
        guard let yTexture = device.makeTexture(descriptor: yTextureDescriptor), let uTexture = device.makeTexture(descriptor: uvTextureDescriptor) , let vTexture = device.makeTexture(descriptor: uvTextureDescriptor) else {
            return
        }
        if let data0 = frame.data.0 {
            yTexture.replace(region: yRegion, mipmapLevel: 0, withBytes: data0, bytesPerRow: Int(frame.lineSize.0))
        }
        if let data1 = frame.data.1 {
            uTexture.replace(region: uvRegion, mipmapLevel: 0, withBytes: data1, bytesPerRow: Int(frame.lineSize.1))
        }
        if let data2 = frame.data.2 {
            vTexture.replace(region: uvRegion, mipmapLevel: 0, withBytes: data2, bytesPerRow: Int(frame.lineSize.2))
        }
        
        self.yTexture = yTexture
        self.uTexture = uTexture
        self.vTexture = vTexture
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
#if DEBUG
        print("\(Self.self) \(#function)" )
#endif
        viewPortSize.x = UInt32(size.width)
        viewPortSize.y = UInt32(size.height)
        drawableSize = size
    }
    
    public func draw(in view: MTKView) {
//#if DEBUG
//        print("\(Self.self) \(#function)")
//#endif
        let quadRangleVertices: [SPTextureVertex] = [
            SPTextureVertex(position: vector_float4(1.0, -1.0, 0, 1.0), textureCoordinate: vector_float2(1.0, 0.0)),
            SPTextureVertex(position: vector_float4(-1.0, -1.0, 0, 1.0), textureCoordinate: vector_float2(0, 0)),
            SPTextureVertex(position: vector_float4(-1.0, 1.0, 0, 1.0), textureCoordinate: vector_float2(0, 1.0)),

            SPTextureVertex(position: vector_float4(1.0, -1.0, 0, 1.0), textureCoordinate: vector_float2(1.0, 0.0)),
            SPTextureVertex(position: vector_float4(-1.0, 1.0, 0, 1.0), textureCoordinate: vector_float2(0, 1.0)),
            SPTextureVertex(position: vector_float4(1.0, 1.0, 0, 1.0), textureCoordinate: vector_float2(1.0, 1.0)),
        ]
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        commandBuffer.label = "\(Self.self) \(#function) commandBuffer"
        
        // 开始发送命令
        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        commandEncoder.label = "\(Self.self) \(#function) commandEncoder"
        
        // 编码渲染管线状态命令
        commandEncoder.setRenderPipelineState(pipelineState)
        
        // 编码视窗命令
        commandEncoder.setViewport(MTLViewport(originX: 0, originY: 0, width: Double(viewPortSize.x), height: Double(viewPortSize.y), znear: 0, zfar: 1))
        
        // 顶点函数参数
        commandEncoder.setVertexBytes(quadRangleVertices, length: MemoryLayout<SPTextureVertex>.size * quadRangleVertices.count, index: Int(SPVertexInputIndexVertices.rawValue))
        commandEncoder.setVertexBytes(&viewPortSize, length: MemoryLayout<vector_uint2>.size, index: Int(SPVertexInputIndexViewport.rawValue))
        // 片段着色器函数参数
        commandEncoder.setFragmentTexture(yTexture, index: Int(SPYUVTextureIndexY.rawValue))
        commandEncoder.setFragmentTexture(uTexture, index: Int(SPYUVTextureIndexU.rawValue))
        commandEncoder.setFragmentTexture(vTexture, index: Int(SPYUVTextureIndexV.rawValue))
        
        // 编码绘图命令
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: quadRangleVertices.count)
        // 结束编码命令
        commandEncoder.endEncoding()
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
