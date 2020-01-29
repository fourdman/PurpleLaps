//
//  ViewController.swift
//  PurpleLaps
//
//  Created by Mikhail Kalugin on 4/25/18.
//  Copyright © 2018 Mikhail Kalugin. All rights reserved.
//

import UIKit

fileprivate let TRACKS = [
    ("Indoor CW", 0),
    ("Mega", 2),
    ("Indoor (reverse)", 3),
    ("Winter Super Mega", 4),
    ("Summer Super Mega", 5)
]

public class MainViewController: UITableViewController {
  private var kartNumber: Int = 44
  private var trackNumber: Int = 2
  
  public init() {
    super.init(style: .plain)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("use .init()")
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Purple Laps for LMK Fremont"
  }
  
  public override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 4
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
    switch indexPath.row {
    case 0:
      cell.textLabel?.text = "Kart number"
      cell.detailTextLabel?.text = "\(kartNumber)"
    case 1:
      cell.textLabel?.text = "Track"
      cell.detailTextLabel?.text = "\(TRACKS.first(where: { t in t.1 == trackNumber })?.0 ?? "\(trackNumber)" )"
    case 2:
      cell.textLabel?.text = "Open live scores in the browser"
    case 3:
      cell.textLabel?.text = "Go! (practice view)"
    default:
      break
    }
    return cell
  }

  public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    switch indexPath.row {
    case 0:
      selectKartNumber()
    case 1:
      selectTrackNumber()
    case 2:
      UIApplication.shared.open(
        URL(string:"http://lmkfremont.clubspeedtiming.com/sp_center/livescore.aspx")!,
        options: [:],
        completionHandler: nil)
    case 3:
      presentPracticeViewController()
    default:
      break
    }
  }
  
  func presentPracticeViewController() {
#if USE_FAKE_DATA
    let clubspeedDataSourceProvider = FakeClubspeedDataSourceProvider()
#else
    let clubspeedDataSourceProvider = ClubspeedWebKitDataSourceProviderImpl(
        webKitHostWindow: self.view.window!,
        trackNumber: trackNumber)
#endif
    let speechSynthesis = ConsoleLoggingSpeechSynthesizer() // SystemSpeechSynthesizer()
    let vc = PracticeViewController(
        clubspeedDataSourceProvider: clubspeedDataSourceProvider,
        kartNumber: kartNumber,
        speechSynthesis: speechSynthesis)
    self.present(vc, animated: true)
  }

  func selectKartNumber() {
    alertWithNumber(title: "Select kart #") { kartNumber in
      self.kartNumber = kartNumber
      self.tableView.reloadData()
    }
  }
  
  func selectTrackNumber() {
    alertWithTrackSelection(title: "Select track", tracks: TRACKS) { trackNumber in
      self.trackNumber = trackNumber
      self.tableView.reloadData()
    }
  }

  func alertWithNumber(title: String, callback: @escaping (Int) -> ()) {
    let controller = UIAlertController(title: title, message: nil, preferredStyle: .alert)
    controller.addTextField() {
      $0.keyboardType = .numberPad
    }
    controller.addAction(UIAlertAction(title: "OK", style: .`default`, handler: { _ in
      guard let num = controller.textFields?.first?.text.flatMap({ Int($0) }) else { return }
      callback(num)
    }))
    controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    self.present(controller, animated: true)
  }
  
  func alertWithTrackSelection(title: String, tracks: [(String, Int)], callback: @escaping (Int) -> ()) {
    let controller = UIAlertController(title: title, message: nil, preferredStyle: .alert)
    for (trackName, index) in tracks {
      controller.addAction(UIAlertAction(title: trackName, style: .`default`, handler: { _ in
        callback(index)
      }))
    }
    controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    self.present(controller, animated: true)
  }
}

