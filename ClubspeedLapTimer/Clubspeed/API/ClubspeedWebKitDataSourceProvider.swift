//
//  WebKitBasedClubspeedDataSourceProvider.swift
//  ClubspeedLapTimer
//
//  Created by Mikhail Kalugin on 1/19/20.
//  Copyright © 2020 Mikhail Kalugin. All rights reserved.
//

import Foundation
import UIKit

public protocol ClubspeedWebKitDataSourceProtocol {
  func stop()
}

public protocol ClubspeedWebKitDataSourceReceiver: class {
  func webKitClubspeedDataSource(_ dataSource: ClubspeedWebKitDataSourceProtocol, selectedTrackName: String)
  func webKitClubspeedDataSource(_ dataSource: ClubspeedWebKitDataSourceProtocol, newLeaderboard: Leaderboard)
  func webKitClubspeedDataSource(_ dataSource: ClubspeedWebKitDataSourceProtocol, error: Error)
}

public protocol ClubspeedWebKitDataSourceProvider {
  func make(receiver: ClubspeedWebKitDataSourceReceiver) -> ClubspeedWebKitDataSourceProtocol
}
