//
//  Shaders.metal
//  pixel-lighting-metal
//
//  Created by Tornike Gomareli on 07.01.25.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
  float4 position [[position]];
  float2 texCoords;
};

struct Uniforms {
  float2 lightPosition;
  float time;
  float intensity;
  float range;
  float bounceRate;
  float flickerRate;
  float flickerAmplitude;
  float globalIllumination;
  float2 obstaclePosition;
  float2 obstacleSize;
};

bool withinRect(float2 point, float2 rectPos, float2 rectSize) {
  float2 bottomLeft = rectPos - rectSize/2;
  float2 topRight = rectPos + rectSize/2;
  return all(point > bottomLeft) && all(point < topRight);
}

float2 interpolatePoint(float2 from, float2 to, float ratio) {
  return from + (to - from) * ratio;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               constant Uniforms &uniforms [[buffer(0)]]) {
  float2 pixelPos = in.texCoords * float2(200, 200);
  
  float2 lightPos = uniforms.obstaclePosition;
  float dotRadius = 4.0;
  float lightDistance = length(pixelPos - lightPos);
  
  if (lightDistance < dotRadius) {
    return float4(1.0, 0.0, 0.0, 1.0);
  }
  
  if (lightDistance < dotRadius) {
    return float4(1.0, 0.0, 0.0, 1.0);
  }
  
  float deadZoneRadius = 8.0;
  if (lightDistance < deadZoneRadius) {
    return float4(0.0, 0.0, 0.0, 0.0); 
  }
  
  float flicker = uniforms.intensity + uniforms.flickerAmplitude * sin(uniforms.time * uniforms.flickerRate);
  
  float2 delta = pixelPos - uniforms.lightPosition;
  float distance = length(delta);
  
  float brightness = flicker - distance / (uniforms.range * 255.0);
  brightness = max(0.0, brightness);
  
  float emission = 1.0;
  const int SAMPLES = 100;
  
  for (int i = 0; i < SAMPLES; i++) {
    float2 testPoint = uniforms.lightPosition + (pixelPos - uniforms.lightPosition) * (float(i) / float(SAMPLES));
    
    float2 relativePos = testPoint - uniforms.obstaclePosition;
    if (abs(relativePos.x) < uniforms.obstacleSize.x/2.0 &&
        abs(relativePos.y) < uniforms.obstacleSize.y/2.0) {
      emission *= uniforms.bounceRate;
    }
  }
  
  float finalBrightness = uniforms.globalIllumination * brightness +
  (1.0 - uniforms.globalIllumination) * brightness * emission;
  
  finalBrightness = max(0.0, min(1.0, finalBrightness));
  
  return float4(finalBrightness, finalBrightness, finalBrightness, 1.0);
}

vertex VertexOut vertexShader(uint vertexID [[vertex_id]]) {
  float2 positions[6] = {
    float2(-1, 1), float2(1, 1), float2(-1, -1),
    float2(1, 1), float2(1, -1), float2(-1, -1)
  };
  
  float2 texCoords[6] = {
    float2(0, 0), float2(1, 0), float2(0, 1),
    float2(1, 0), float2(1, 1), float2(0, 1)
  };
  
  VertexOut out;
  out.position = float4(positions[vertexID], 0.0, 1.0);
  out.texCoords = texCoords[vertexID];
  return out;
}
