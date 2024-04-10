//
//  YUV420TextureShader.metal
//  SauronPlayer
//
//  Created by 林少龙 on 2023/8/4.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

#include <metal_stdlib>
#include "SPShaderTypes.h"
using namespace metal;

struct RasterizerData {
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];

    // Since this member does not have a special attribute, the rasterizer
    // interpolates its value with the values of the other triangle vertices
    // and then passes the interpolated value to the fragment shader for each
    // fragment in the triangle.
    float2 textureCoordinate;
};

vertex RasterizerData YUVTextureVertexShader(uint vertexID [[ vertex_id ]],
             constant SPTextureVertex *vertices [[ buffer(SPVertexInputIndexVertices) ]],
             constant vector_uint2 *viewportSizePointer  [[ buffer(SPVertexInputIndexViewport) ]]) {

    RasterizerData out;

    // To convert from positions in pixel space to positions in clip-space,
    //  divide the pixel coordinates by half the size of the viewport.
    out.position = vertices[vertexID].position;
    out.position.y = -vertices[vertexID].position.y;

    // Pass the input textureCoordinate straight to the output RasterizerData.  This value will be
    //   interpolated with the other textureCoordinate values in the vertices that make up the
    //   triangle.
    out.textureCoordinate = vertices[vertexID].textureCoordinate;

    return out;
}

float4x4 YUV420PToSRGBMatrix(void) {
    float4x4 matrix;
    matrix[0] = {1.164,    0.0000,    1.5960,     -0.87075};
    matrix[1] = {1.164,    -0.391,    -0.813,     0.529250};
    matrix[2] = {1.164,    2.0180,    0.0000,     -1.08175};
    matrix[3] = {0.000,    0.0000,    0.0000,     1.000000};

    return matrix;
}

fragment float4 YUVTextureFragmentShader(RasterizerData in [[stage_in]],
                              texture2d<half> yTexture [[ texture(SPYUVTextureIndexY) ]],
                              texture2d<half> uTexture [[ texture(SPYUVTextureIndexU) ]],
                              texture2d<half> vTexture [[ texture(SPYUVTextureIndexV) ]]) {
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);

    // Sample the texture and return the color to colorSample
    float4 out = {0, 0, 0, 1};
    float4x4 matrix = YUV420PToSRGBMatrix();
    out.x = yTexture.sample(textureSampler, in.textureCoordinate).r;// * 255;
    out.y = uTexture.sample(textureSampler, in.textureCoordinate).r;// * 255;
    out.z = vTexture.sample(textureSampler, in.textureCoordinate).r;// * 255;
    
    out = out * matrix;

    return float4(out);
}
