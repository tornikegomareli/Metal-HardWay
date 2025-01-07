//
//  ContentView.swift
//  pixel-lighting-metal
//
//  Created by Tornike Gomareli on 07.01.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
      MetalViewRepresentable()
        .frame(
          width: CGFloat(Constants.screenWidth * Constants.scaleFactor),
          height: CGFloat(Constants.screenHeight * Constants.scaleFactor)
        )
    }
}
