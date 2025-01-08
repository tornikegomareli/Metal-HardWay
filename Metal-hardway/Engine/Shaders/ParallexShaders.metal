//
//  ParallexShaders.metal
//  Metal-hardway
//
//  Created by Tornike Gomareli on 08.01.25.
//

#include <metal_stdlib>
#include "Common.metal"
using namespace metal;

struct ParallexUniforms {
  float scrollingBack;
  float scrollingMid;
  float scrollingFore;
  float time;
};

vertex VertexOut parallaxVertexShader(uint vertexID [[vertex_id]]) {
  const float2 vertices[] = {
    float2(-1, -1), float2(1, -1), float2(-1, 1),
    float2(1, -1), float2(1, 1), float2(-1, 1)
  };
  
  const float2 texCoords[] = {
    float2(0, 1), float2(1, 1), float2(0, 0),
    float2(1, 1), float2(1, 0), float2(0, 0)
  };
  
  VertexOut out;
  out.position = float4(vertices[vertexID], 0.0, 1.0);
  out.texCoords = texCoords[vertexID];
  return out;
}

fragment float4 parallaxFragmentShader(VertexOut in [[stage_in]],
                                       constant ParallexUniforms &uniforms [[buffer(0)]],
                                       texture2d<float> backgroundTex [[texture(0)]],
                                       texture2d<float> midgroundTex [[texture(1)]],
                                       texture2d<float> foregroundTex [[texture(2)]]) {
  
  constexpr sampler textureSampler(mag_filter::linear,
                                   min_filter::linear,
                                   address::repeat,
                                   s_address::repeat,
                                   t_address::clamp_to_edge);
  float scrollScale = 0.001;
  
  /// Calculate UVs with proper scaling and direction
  float2 bgUV = float2(fmod(in.texCoords.x + uniforms.scrollingBack * scrollScale, 1.0),
                       in.texCoords.y);
  
  float2 midUV = float2(fmod(in.texCoords.x + uniforms.scrollingMid * scrollScale, 1.0),
                        in.texCoords.y);
  
  float2 foreUV = float2(fmod(in.texCoords.x + uniforms.scrollingFore * scrollScale, 1.0),
                         in.texCoords.y);
  
  /// Sample textures with wrapped coordinates
  float4 bgColor = backgroundTex.sample(textureSampler, bgUV);
  float4 midColor = midgroundTex.sample(textureSampler, midUV);
  float4 foreColor = foregroundTex.sample(textureSampler, foreUV);
  
  /// Blend layers
  float4 finalColor = mix(bgColor, midColor, midColor.a);
  finalColor = mix(finalColor, foreColor, foreColor.a);
  
  return finalColor;
  
}
