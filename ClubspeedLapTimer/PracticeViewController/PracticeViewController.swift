//
//  RaceViewController.swift
//  ClubspeedLapTimer
//
//  Created by Mikhail Kalugin on 4/26/18.
//  Copyright © 2018 Mikhail Kalugin. All rights reserved.
//

import Foundation
import UIKit

public class PracticeViewController: UIViewController, ClubspeedWebKitDataSourceReceiver {
  @IBOutlet var practiceView: PracticeView?

  private let kartNumber: Int
  private let clubspeedDataSourceProvider: ClubspeedWebKitDataSourceProvider
  private var clubspeedDataSource: ClubspeedWebKitDataSourceProtocol?
  private var trackName: String?
  private var lastLeaderboard: Leaderboard?
  private var lastError: Error?
  private var hasSeenKartNumber = false
  
  public init(clubspeedDataSourceProvider: ClubspeedWebKitDataSourceProvider, kartNumber: Int) {
    self.clubspeedDataSourceProvider = clubspeedDataSourceProvider
    self.kartNumber = kartNumber

    super.init(nibName: nil, bundle: nil)
  
    self.modalPresentationStyle = .fullScreen
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    refresh()
  }
  
  public override var shouldAutorotate: Bool {
    return true
  }
  
  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.landscapeRight, .landscapeLeft]
  }
  
  public override func viewSafeAreaInsetsDidChange() {
    practiceView?.frame = UIEdgeInsetsInsetRect(self.view.bounds, self.view.safeAreaInsets)
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.shared.isIdleTimerDisabled = true
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    hasSeenKartNumber = false
    
    if clubspeedDataSource == nil {
      clubspeedDataSource = clubspeedDataSourceProvider.make(receiver: self)
    }
  }
  
  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    UIApplication.shared.isIdleTimerDisabled = false
    
    clubspeedDataSource?.stop()
    clubspeedDataSource = nil
  }
  
  private func presentException(title: String, subtitle: String = "") {
    self.practiceView?.updateFromViewModel(PracticeViewModel.exception(title: title, subtitle: subtitle))
  }
  
  private func refresh() {
    if lastLeaderboard == nil && lastError == nil {
      presentException(title: "Waiting for data")
      return
    }

    if let lastError = lastError {
      presentException(
        title: "ERROR",
        subtitle: "Data source error: \(lastError) (kart: \(kartNumber) track: \(trackName ?? "nil"))"
      )
      return
    }

    let leaderboard = lastLeaderboard!

    guard let position = leaderboard.position(kartNumber: kartNumber) else {
      if hasSeenKartNumber {
        presentException(title: "Can't find kart #")
      } else {
        presentException(title: "Waiting for kart # to appear")
      }
      return
    }

    hasSeenKartNumber = true
    
    let viewModel = PracticeViewModel(leaderboard: leaderboard, position: position, trackName: trackName)
    self.practiceView?.updateFromViewModel(viewModel)
  }
  
  // MARK: ClubspeedWebKitDataSourceReceiver
  
  public func webKitClubspeedDataSource(_ dataSource: ClubspeedWebKitDataSourceProtocol, selectedTrackName name: String) {
    self.trackName = name
    refresh()
  }
  
  public func webKitClubspeedDataSource(_ dataSource: ClubspeedWebKitDataSourceProtocol, newLeaderboard: Leaderboard) {
    lastLeaderboard = newLeaderboard
    lastError = nil
    refresh()
  }
  
  public func webKitClubspeedDataSource(_ dataSource: ClubspeedWebKitDataSourceProtocol, error: Error) {
    lastError = error
    refresh()
  }
  
  // MARK: PracticeView actions
  
  @IBAction func practiceViewDidTapExit() {
    self.dismiss(animated: true, completion: nil)
  }
}

