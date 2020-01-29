//
//  SystemSpeechSynthesizer.swift
//  PurpleLaps
//
//  Created by Mikhail Kalugin on 1/28/20.
//  Copyright © 2020 Mikhail Kalugin. All rights reserved.
//

import Foundation
import AVFoundation

public class SystemSpeechSynthesizer: SpeechSynthesizerProtocol {
  private let avSpeechSynthesizer: AVSpeechSynthesizer
  
  init() {
    self.avSpeechSynthesizer = AVSpeechSynthesizer()
    self.avSpeechSynthesizer.usesApplicationAudioSession = true
  }

  public func speak(string: String) {
    let utterance = AVSpeechUtterance(string: string)
    self.avSpeechSynthesizer.speak(utterance)
  }
  
  public func stopImmediately() {
    self.avSpeechSynthesizer.stopSpeaking(at: .immediate)
  }
}
