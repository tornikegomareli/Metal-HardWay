//
//  AudioPlayer.swift
//  Metal-hardway
//
//  Created by Tornike Gomareli on 08.01.25.
//


import AVFoundation

class AudioPlayer {
  private var audioPlayer: AVAudioPlayer?
  private var isLooping: Bool = false
  
  func play(fileName: String, fileExtension: String = "mp3", shouldLoop: Bool = false) {
    guard let path = Bundle.main.path(forResource: fileName, ofType: fileExtension) else {
      print("Could not find audio file: \(fileName).\(fileExtension)")
      return
    }
    
    let url = URL(fileURLWithPath: path)
    
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: url)
      audioPlayer?.numberOfLoops = shouldLoop ? -1 : 0
      audioPlayer?.prepareToPlay()
      audioPlayer?.play()
    } catch {
      print("Could not create audio player: \(error)")
    }
  }
  
  func stop() {
    audioPlayer?.stop()
  }
  
  func pause() {
    audioPlayer?.pause()
  }
  
  func resume() {
    audioPlayer?.play()
  }
  
  func setVolume(_ volume: Float) {
    audioPlayer?.volume = volume
  }
}
