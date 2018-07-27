//
//  ViewModels.swift
//  ClubspeedLapTimer
//
//  Created by Mikhail Kalugin on 5/7/19.
//  Copyright © 2019 Mikhail Kalugin. All rights reserved.
//

import Foundation

public struct PracticeViewModel {
  public enum DeltaDotsState {
    case faster
    case slower
    case same
  }
  
  let position: String
  let lapNumber: String
  let timeLeft: String
  let deltaDotsString: String
  let deltaDotsState: DeltaDotsState
  let lastLapTime: String
  let bestLapTime: String
  
  // A string describing the kart number and data feed status.
  let kartDriverAndStatus: String
  
  // Lap time of the leader (in terms of leaderboard position).
  let leadersBestTime: String
  
  // Lap time of the driver in front (in terms of leaderboard position).
  let frontsBestTime: String
  
  // Lap time of the driver behind (in terms of leaderboard position).
  let behindsBestTime: String
}
