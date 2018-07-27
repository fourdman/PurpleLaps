//
//  Leaderboard+JSON.swift
//  ClubspeedLapTimer
//
//  Created by Mikhail Kalugin on 1/19/20.
//  Copyright © 2020 Mikhail Kalugin. All rights reserved.
//

import Foundation

extension Leaderboard {
  init?(clubspeedJSONObject: Any) {
    guard let dataDict = clubspeedJSONObject as? [String: Any?] else { return nil }

    guard let scoreboardData = dataDict["ScoreboardData"] else { return nil }
    guard let scoreboardDataArray = scoreboardData as? [Any?] else { return nil }
    
    self.lapsLeft = dataDict["LapsLeft"] as? String
    self.positions = scoreboardDataArray.enumerated().map { (index, item) -> Leaderboard.Position in
      let boardItemDict = (item as? [String: Any?]) ?? [:]
      return Leaderboard.Position(boardItemDict, index: index)
    }
  }
}

extension Leaderboard.Position {
  fileprivate init(_ boardItemDict: [String : Any?], index: Int) {
    self.index = index
    
    kartNumber = boardItemDict["AutoNo"] as? String ?? "n/a"
    lastLapTime = boardItemDict["LTime"] as? String ?? "n/a"
    position = boardItemDict["Position"] as? String ?? "n/a"
    bestLapTime =  boardItemDict["BestLTime"] as? String ?? "n/a"
    racerName = boardItemDict["RacerName"] as? String ?? "n/a"
    gap = boardItemDict["GapToLeader"] as? String ?? "n/a"
    lapNumber = boardItemDict["LapNum"] as? String ?? "n/a"
  }
}
