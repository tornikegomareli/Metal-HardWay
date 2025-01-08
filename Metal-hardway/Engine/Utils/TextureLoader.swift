//
//  TextureLoader.swift
//  Metal-hardway
//
//  Created by Tornike Gomareli on 08.01.25.
//

import MetalKit
import Metal

class TextureLoader {
  static func loadTexture(device: MTLDevice, imageName: String) -> MTLTexture? {
    guard let image = UIImage(named: imageName),
          let cgImage = image.cgImage else { return nil }
    
    let textureLoader = MTKTextureLoader(device: device)
    do {
      let texture = try textureLoader.newTexture(
        cgImage: cgImage,
        options: [.SRGB: false]
      )
      return texture
    } catch {
      print("Failed to load texture: \(error)")
      return nil
    }
  }
}
