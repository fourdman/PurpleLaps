//
//  PracticeView.swift
//  PurpleLaps
//
//  Created by Mikhail Kalugin on 4/30/19.
//  Copyright © 2019 Mikhail Kalugin. All rights reserved.
//

import Foundation
import UIKit

public class PracticeView: UIView {
  @IBOutlet var positionLabel: UILabel?
  @IBOutlet var lapNumberLabel: UILabel?
  @IBOutlet var timeLeftLabel: UILabel?
  @IBOutlet var deltaDotsLabel: UILabel?
  @IBOutlet var lastLapTimeLabel: UILabel?
  @IBOutlet var bestlapTimeLabel: UILabel?
  @IBOutlet var kartDriverLabel: UILabel?
  @IBOutlet var leadersBestTimeLabel: UILabel?
  @IBOutlet var frontsBestTimeLabel: UILabel?
  @IBOutlet var behindsBestTimeLabel: UILabel?
  
  public func updateFromViewModel(_ model: PracticeViewModel) {
    let shouldBlink = self.lapNumberLabel?.text != model.lapNumber
    
    self.positionLabel?.text = model.position
    self.lapNumberLabel?.text = model.lapNumber
    self.timeLeftLabel?.text = model.timeLeft
    self.deltaDotsLabel?.text = model.deltaDotsString
    self.deltaDotsLabel?.textColor = model.deltaDotsState.color
    self.lastLapTimeLabel?.text = model.lastLapTime
    self.bestlapTimeLabel?.text = model.bestLapTime
    self.kartDriverLabel?.text = model.kartDriverAndStatus
    
    self.leadersBestTimeLabel?.text = model.leadersBestTime
    self.frontsBestTimeLabel?.text = model.frontsBestTime
    self.behindsBestTimeLabel?.text = model.behindsBestTime
    
    if shouldBlink {
      self.backgroundColor = model.deltaDotsState.blinkColor
      Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
        self.backgroundColor = .systemBackground
      }
    }
  }
}

fileprivate extension PracticeViewModel.DeltaDotsState {
  var color: UIColor {
    switch self {
    case .faster:
      return .green
    case .slower:
      return .red
    case .same:
      return .gray
    }
  }
  
  var blinkColor: UIColor {
    switch self {
    case .faster:
      return UIColor.green.withAlphaComponent(0.2)
    case .slower:
      return UIColor.red.withAlphaComponent(0.2)
    case .same:
      return .systemBackground
    }
  }
}
