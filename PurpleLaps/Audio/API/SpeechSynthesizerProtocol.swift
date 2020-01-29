//
//  SpeechSynthesizerProtocol.swift
//  PurpleLaps
//
//  Created by Mikhail Kalugin on 1/28/20.
//  Copyright © 2020 Mikhail Kalugin. All rights reserved.
//

import Foundation

public protocol SpeechSynthesizerProtocol {
  func speak(string: String)
  func stopImmediately()
}
