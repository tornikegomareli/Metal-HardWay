//
//  Scene.swift
//  Metal-hardway
//
//  Created by Tornike Gomareli on 08.01.25.
//

import Foundation

protocol MetalScene {
  var name: String { get }
  var vertexFunctionName: String { get }
  var fragmentFunctionName: String { get }
  var screenSize: (width: Int, height: Int) { get }
  func update()
  func handleTouch(_ position: CGPoint)
}
