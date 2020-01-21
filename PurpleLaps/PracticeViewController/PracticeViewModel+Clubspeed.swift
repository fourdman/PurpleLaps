//
//  PracticeViewModel+Clubspeed.swift
//  PurpleLaps
//
//  Created by Mikhail Kalugin on 1/19/20.
//  Copyright © 2020 Mikhail Kalugin. All rights reserved.
//

import Foundation

extension PracticeViewModel {
  public static func exception(title: String, subtitle: String = "") -> PracticeViewModel {
    return PracticeViewModel(
        position: "-",
        lapNumber: "-",
        timeLeft: "-",
        deltaDotsString: "-",
        deltaDotsState: .same,
        lastLapTime: title,
        bestLapTime: "-",
        kartDriverAndStatus: subtitle,
        leadersBestTime: "-",
        frontsBestTime: "-",
        behindsBestTime: "-")
  }
  
  public init(
    leaderboard: Leaderboard,
    position: Leaderboard.Position,
    trackName: String?
  ) {
    lapNumber = "L \(position.lapNumber)"
    timeLeft = leaderboard.lapsLeft ?? "n/a"

    self.position = "P \(position.position)"
    lastLapTime = position.lastLapTime
    bestLapTime = position.bestLapTime

    kartDriverAndStatus = "#\(position.kartNumber) - \(position.racerName) - \(trackName ?? "unknown track")"
    
    if
      let lapTimeF = Float(position.lastLapTime),
      let bestLapTimeF = Float(position.bestLapTime)
    {
      let delta = lapTimeF - bestLapTimeF
      if delta > 0 {
        deltaDotsState = .slower
      } else {
        deltaDotsState = .faster
      }
      deltaDotsString = formatDelta(delta)
    } else {
      deltaDotsState = .same
      deltaDotsString = ""
    }
  
    if let positionInFront = leaderboard.positionInFront(of: position) {
      frontsBestTime = "#\(positionInFront.kartNumber) - \(positionInFront.bestLapTime)"
    } else {
      frontsBestTime = "--"
    }
    
    if let positionBehind = leaderboard.positionBehind(position) {
      behindsBestTime = "#\(positionBehind.kartNumber) - \(positionBehind.bestLapTime)"
    } else {
      behindsBestTime = "--"
    }
    
    if let pole = leaderboard.pole {
      leadersBestTime = "#\(pole.kartNumber) - \(pole.bestLapTime)"
    } else {
      leadersBestTime = "--"
    }
  }
}

fileprivate func formatDelta(_ delta: Float) -> String {
  if delta == 0.0 {
    return "NEW BEST"
  }
  let numDots = Int((abs(delta) / 0.1).rounded())
  return String(repeating:"◉ ", count: numDots)
}
