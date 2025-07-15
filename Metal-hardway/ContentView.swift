//
//  ContentView.swift
//  Metal-hardway
//
//  Created by Tornike Gomareli on 07.01.25.
//

import SwiftUI

struct ContentView: View {
  @State private var currentScene: MetalScene = CellularSandScene()
  @State private var showMenu = false
  
  enum SceneType: String, CaseIterable {
    case sandSimulation = "Sand Simulation"
    case pixelLighting = "Pixel Lighting"
    case parallaxScroll = "Parallax Background"
    
    func createScene() -> MetalScene {
      switch self {
      case .sandSimulation:
        return CellularSandScene()
      case .pixelLighting:
        return PixelLightingScene()
      case .parallaxScroll:
        return ParallaxScene()
      }
    }
  }

  var body: some View {
    ZStack {
        MetalViewRepresentable(currentScene: $currentScene)
        .ignoresSafeArea(.all)
      
      VStack {
        HStack {
          Spacer()
          
          Button(action: {
            showMenu.toggle()
          }) {
            Image(systemName: "list.bullet")
              .font(.title)
              .foregroundColor(.white)
              .padding()
              .background(Color.black.opacity(0.5))
              .clipShape(Circle())
          }
          .padding()
        }
        
        Spacer()
      }
      
      if showMenu {
        VStack {
          HStack {
            VStack(alignment: .leading, spacing: 20) {
              Text("Select Scene")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 10)
              
              ForEach(SceneType.allCases, id: \.self) { sceneType in
                Button(action: {
                  currentScene = sceneType.createScene()
                  showMenu = false
                }) {
                  HStack {
                    Text(sceneType.rawValue)
                      .foregroundColor(.white)
                      .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                      .foregroundColor(.white.opacity(0.6))
                  }
                  .padding()
                  .background(Color.white.opacity(0.2))
                  .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
              }
            }
            .padding(30)
            .background(Color.black.opacity(0.8))
            .cornerRadius(20)
            .frame(maxWidth: 300)
            
            Spacer()
          }
          .padding(.top, 100)
          
          Spacer()
        }
        .background(Color.black.opacity(0.4))
        .onTapGesture {
          showMenu = false
        }
      }
    }
  }
}
