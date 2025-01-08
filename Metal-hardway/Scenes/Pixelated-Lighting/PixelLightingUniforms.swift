//
//  Uniforms.swift
//  Metal-hardway
//
//  Created by Tornike Gomareli on 07.01.25.
//

import simd

struct PixelLightingUniforms {
  var lightPosition: SIMD2<Float>
  var time: Float
  var intensity: Float
  var range: Float
  var bounceRate: Float
  var flickerRate: Float
  var flickerAmplitude: Float
  var globalIllumination: Float
  var obstaclePosition: SIMD2<Float>
  var obstacleSize: SIMD2<Float>
}
