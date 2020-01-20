//
//  Leaderboard.swift
//  PurpleLaps
//
//  Created by Mikhail Kalugin on 1/19/20.
//  Copyright © 2020 Mikhail Kalugin. All rights reserved.
//

import Foundation

public struct Leaderboard {
  public struct Position {
    public let index: Int
    public let kartNumber: String
    public let racerName: String
    public let lastLapTime: String
    public let bestLapTime: String
    public let position: String
    public let gap: String
    public let lapNumber: String
  }

  public let positions: [Leaderboard.Position]
  public let lapsLeft: String?

  public func position(kartNumber: Int) -> Leaderboard.Position? {
    return self.positions.first { (item) -> Bool in
      return item.kartNumber == "\(kartNumber)"
    }
  }
  
  public func positionInFront(of position: Leaderboard.Position) -> Leaderboard.Position? {
    if position.index > 0 {
      return self.positions[position.index - 1]
    }
    return nil
  }
  
  public func positionBehind(_ position: Leaderboard.Position) -> Leaderboard.Position? {
    if position.index < self.positions.count - 1 {
      return self.positions[position.index + 1]
    }
    return nil
  }
  
  public var pole: Leaderboard.Position? {
    return positions.first
  }
}
