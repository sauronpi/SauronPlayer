//
//  ShaderTypes.h
//  SauronPlayer
//
//  Created by sauron on 2023/5/28.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

typedef enum {
    SPVertexInputIndexVertices,
    SPVertexInputIndexViewport,
} SPVertexInputIndex;

typedef enum {
    SPTextureIndexInput,
    SPTextureIndexOutput,
} SPTextureIndex;

typedef enum {
    SPYUVTextureIndexY,
    SPYUVTextureIndexU,
    SPYUVTextureIndexV,
} SPYUVTextureIndex;

typedef struct {
    vector_float4 position;
    vector_float4 color;
} SPVertex;

typedef struct {
    vector_float4 position;
    vector_float2 textureCoordinate;
} SPTextureVertex;

#endif /* ShaderTypes_h */
