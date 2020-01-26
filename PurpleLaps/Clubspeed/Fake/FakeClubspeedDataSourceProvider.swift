//
//  FakeClubspeedDataSourceProvider.swift
//  PurpleLaps
//
//  Created by Mikhail Kalugin on 1/21/20.
//  Copyright © 2020 Mikhail Kalugin. All rights reserved.
//

import Foundation

fileprivate let FAKE_TRACK_NAME = "Fake Track Name"
fileprivate let FAKE_FIRST_LAP_NUMBER = 14
fileprivate let FAKE_TOTAL_LAP_COUNT = 21
fileprivate let FAKE_UPDATE_INTERVAL: TimeInterval = 5
fileprivate let FAKE_KART_INFOS = [
  FakeKartInfo(
      kartNumber: "42",
      racerName: "Joe",
      positions: [1, 2, 2, 1],
      lapTimes: [32.998, 28.788, 28.345, 29.114],
      gapsToLeader: ["0", "10.5", "5.6", "0"]),
  FakeKartInfo(
      kartNumber: "12",
      racerName: "The Beast",
      positions: [2, 1, 1, 3],
      lapTimes: [33.001, 29.175, 29.714, 28.977],
      gapsToLeader: ["1.3", "0", "0", "12.5"]),
  FakeKartInfo(
      kartNumber: "34",
      racerName: "Elly",
      positions: [3, 3, 3, 2],
      lapTimes: [31.787, 28.645, 28.347, 28.999],
      gapsToLeader: ["2.1", "1L", "20.6", "4.2"])
]

public class FakeClubspeedDataSource: ClubspeedWebKitDataSourceProtocol {
  private weak var receiver: ClubspeedWebKitDataSourceReceiver?
  private let leaderboards: [Leaderboard]
  private var nextUpdateIndex = 0
  private var timer: Timer?
  
  public init(receiver: ClubspeedWebKitDataSourceReceiver) {
    self.receiver = receiver
    
    self.leaderboards = buildFakeLeaderboards(
        firstLapNumber: FAKE_FIRST_LAP_NUMBER,
        totalLapCount: FAKE_TOTAL_LAP_COUNT,
        kartInfos: FAKE_KART_INFOS)
    
    receiver.webKitClubspeedDataSource(self, selectedTrackName: FAKE_TRACK_NAME)
    
    self.scheduleNextUpdate()
  }
  
  public func stop() {
    timer?.invalidate()
    timer = nil
  }
  
  private func scheduleNextUpdate() {
    guard nextUpdateIndex <= self.leaderboards.count - 1 else {
      timer?.invalidate()
      timer = nil
      return
    }
    
    let timeInterval = (nextUpdateIndex == 0) ? 0 : FAKE_UPDATE_INTERVAL
    self.timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
      self?.sendUpdate()
      self?.scheduleNextUpdate()
    }
  }
  
  private func sendUpdate() {
    guard nextUpdateIndex <= leaderboards.count - 1 else { return }
    receiver?.webKitClubspeedDataSource( self, newLeaderboard: leaderboards[nextUpdateIndex])
    
    nextUpdateIndex += 1
  }
}


public class FakeClubspeedDataSourceProvider: ClubspeedWebKitDataSourceProvider {
  public func make(receiver: ClubspeedWebKitDataSourceReceiver) -> ClubspeedWebKitDataSourceProtocol {
    return FakeClubspeedDataSource(receiver: receiver)
  }
}

fileprivate struct FakeKartInfo {
  let kartNumber: String
  let racerName: String
  let positions: [Int]
  let lapTimes: [Float]
  let gapsToLeader: [String]
}

fileprivate func determineLapCount(_  kartInfos: [FakeKartInfo]) -> Int {
  guard kartInfos.count > 0 else { return 0 }
  
  let lapCount = kartInfos[0].positions.count
  
  // Verify that the lap count for all karts is consistent.
  for kartInfo in kartInfos {
    assert(kartInfo.positions.count == lapCount)
    assert(kartInfo.lapTimes.count == lapCount)
    assert(kartInfo.gapsToLeader.count == lapCount)
  }
  
  return lapCount
}

fileprivate func buildFakeLeaderboards(
    firstLapNumber: Int,
    totalLapCount: Int,
    kartInfos: [FakeKartInfo]
) -> [Leaderboard] {
  let lapCount = determineLapCount(kartInfos)
  guard lapCount > 0 else { return [] }
  
  var leaderboards = [Leaderboard]()
  var kartBestTimesByNumber = [String: Float]()

  for lapNum in 0..<lapCount {
    var positions = [Leaderboard.Position]()
    for kartInfo in kartInfos {
      let lapTime = kartInfo.lapTimes[lapNum]
      let bestLapTime: Float
      if let oldBestLapTime = kartBestTimesByNumber[kartInfo.kartNumber], oldBestLapTime < lapTime {
        bestLapTime = oldBestLapTime
      } else {
        kartBestTimesByNumber[kartInfo.kartNumber] = lapTime
        bestLapTime = lapTime
      }
      positions.append(Leaderboard.Position(
          index: kartInfo.positions[lapNum] - 1,
          kartNumber: kartInfo.kartNumber,
          racerName: kartInfo.racerName,
          lastLapTime: String(format: "%.3f", lapTime),
          bestLapTime: String(format: "%.3f", bestLapTime),
          position: "\(kartInfo.positions[lapNum])",
          gapToLeader: "\(kartInfo.gapsToLeader[lapNum])",
          lapNumber: "\(firstLapNumber + lapNum)"))
    }
    positions.sort() { a, b in a.index < b.index }
    leaderboards.append(Leaderboard(
        positions: positions,
        lapsLeft: "\(totalLapCount - firstLapNumber - lapNum) laps left"))
  }
    
  return leaderboards
}
