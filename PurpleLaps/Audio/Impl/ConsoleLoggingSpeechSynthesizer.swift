//
//  ConsoleLoggingSpeechSynthesizer.swift
//  PurpleLaps
//
//  Created by Mikhail Kalugin on 1/28/20.
//  Copyright © 2020 Mikhail Kalugin. All rights reserved.
//

import Foundation

public class ConsoleLoggingSpeechSynthesizer: SpeechSynthesizerProtocol {
  public func speak(string: String) {
    print("\(self): speaking '\(string)'")
  }
  
  public func stopImmediately() {
    print("\(self): stopping speech immediately")
  }
}
