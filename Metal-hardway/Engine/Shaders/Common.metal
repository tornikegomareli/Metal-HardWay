//
//  VertexOut.swift
//  Metal-hardway
//
//  Created by Tornike Gomareli on 08.01.25.
//


#include <metal_stdlib>
using namespace metal;

struct VertexOut {
  float4 position [[position]];
  float2 texCoords;
};
