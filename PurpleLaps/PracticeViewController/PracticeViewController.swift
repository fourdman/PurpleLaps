//
//  RaceViewController.swift
//  PurpleLaps
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
  private let announcer: Announcer
  private var clubspeedDataSource: ClubspeedWebKitDataSourceProtocol?
  private var trackName: String?
  private var lastLeaderboard: Leaderboard?
  private var lastError: Error?
  private var hasSeenKartNumber = false
  
  public init(
    clubspeedDataSourceProvider: ClubspeedWebKitDataSourceProvider,
    kartNumber: Int,
    speechSynthesis: SpeechSynthesizerProtocol
  ) {
    self.clubspeedDataSourceProvider = clubspeedDataSourceProvider
    self.kartNumber = kartNumber
    self.announcer = Announcer(speechSynthesis: speechSynthesis)

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
    
    announcer.stop()
  }
  
  private func presentException(title: String, subtitle: String = "") {
    self.practiceView?.updateFromViewModel(PracticeViewModel.exception(title: title, subtitle: subtitle))
    
    announcer.announceText(title)
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
    
    announcer.announcePosition(position: position)
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

fileprivate class Announcer {
  private let speechSynthesis: SpeechSynthesizerProtocol
  private var lastPosition: Leaderboard.Position?
  private var lastSpokenText: String?
  
  init(speechSynthesis: SpeechSynthesizerProtocol) {
    self.speechSynthesis = speechSynthesis
  }
  
  func stop() {
    speechSynthesis.stopImmediately()
  }
  
  func announceText(_ text: String) {
    guard self.lastSpokenText == nil || text != lastSpokenText! else {
      return
    }
    
    speechSynthesis.stopImmediately()
    speechSynthesis.speak(string: text)
    
    self.lastSpokenText = text
  }
  
  func announcePosition(position: Leaderboard.Position) {
    if let textToSpeak = textToSpeakOnUpdate(position: position) {
      announceText(textToSpeak)
    }
  }
  
  private func textToSpeakOnUpdate(position: Leaderboard.Position) -> String? {
    guard let lapTimeF = Float(position.lastLapTime) else {
      return nil
    }
    
    var textToSpeak = ""
    
    if let previousBestLapTimeStr = lastPosition?.bestLapTime,
       let previousBestLapTimeF = Float(previousBestLapTimeStr) {
      let delta = lapTimeF - previousBestLapTimeF
      let deltaInTenth = self.deltaInTenth(delta)
      if deltaInTenth < 10 {
        textToSpeak = "\(deltaInTenth) tenth "
        if delta > 0 {
          textToSpeak += "slower"
        } else if delta < 0 {
          textToSpeak = "best lap, " + textToSpeak + " faster"
        } else {
          textToSpeak = "same time"
        }
      } else {
        textToSpeak += "\(String(format: "%.1f", lapTimeF)) seconds"
      }
    } else {
      textToSpeak += "\(String(format: "%.1f", lapTimeF)) seconds"
    }
    
    if lastPosition == nil || lastPosition!.position != position.position {
      textToSpeak += ", you are now P \(position.position)"
    }
    
    self.lastPosition = position
    
    return textToSpeak
  }
  
  private func deltaInTenth(_ delta: Float) -> Int {
    return Int((abs(delta) / 0.1).rounded())
  }
}
