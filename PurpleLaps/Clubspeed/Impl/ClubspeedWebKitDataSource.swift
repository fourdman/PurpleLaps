//
//  RawClubspeedDataSource.swift
//  PurpleLaps
//
//  Created by Mikhail Kalugin on 4/25/18.
//  Copyright © 2018 Mikhail Kalugin. All rights reserved.
//

import Foundation
import WebKit

public class ClubspeedWebKitDataSource: NSObject, ClubspeedWebKitDataSourceProtocol, WKNavigationDelegate, WKScriptMessageHandler {
  private let trackNumber: Int
  private let window: UIWindow
  private weak var receiver: ClubspeedWebKitDataSourceReceiver?
  
  private let webView: WKWebView
  private var started = false
  private var hasSelectedTrack = false
  
  public init(window: UIWindow, trackNumber: Int, receiver: ClubspeedWebKitDataSourceReceiver) {
    self.trackNumber = trackNumber
    self.window = window
    self.receiver = receiver
    
    let configuration = WKWebViewConfiguration()
    
    let contentController = WKUserContentController()
    configuration.userContentController = contentController
    
    webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), configuration: configuration)

    super.init()
    
    contentController.add(self, name: "selectedTrackHandler")
    contentController.add(self, name: "refreshGridHandler")
    
    webView.navigationDelegate = self
  }
  
  public func start() {
    guard !started else { return }
    started = true
    
    window.addSubview(webView)

    let request = URLRequest(url: URL(string: "http://lmkfremont.clubspeedtiming.com/sp_center/livescore.aspx")!)
    webView.load(request)
  }
  
  public func stop() {
    webView.removeFromSuperview()
    webView.loadHTMLString("", baseURL: nil)
  }
  
  private func selectTrack(index: Int) {
    let trackSelectionCode = """
      if (!document.getElementById("ddlTrack")) {
        throw "Can't find 'ddlTrack' element."
      }
      document.getElementById("ddlTrack").options.selectedIndex = \(index)
      document.getElementById("ddlTrack").dispatchEvent(new Event('change'))
      var trackName = document.getElementById("ddlTrack").options[document.getElementById("ddlTrack").options.selectedIndex].text
      webkit.messageHandlers.selectedTrackHandler.postMessage(trackName)
    """
    webView.evaluateJavaScript(trackSelectionCode) { (result, error) in
      if let error = error {
        self.receiver?.webKitClubspeedDataSource(self, error: ClubspeedWebKitDataSourceError.trackSelectionJSFailed(error))
      }
   }
  }
  
  private func hookToRefreshGrid() {
    let script = """
      (function() {
          $.connection.hub.stop()

          function refreshGrid(data) {
            webkit.messageHandlers.refreshGridHandler.postMessage(data);
          }

          var scoreboard = $.connection.ScoreBoardHub;
          scoreboard.refreshGrid = function (data) {
            refreshGrid(data)
          }

          $.connection.hub.start(function () {
            var trackNo = $.ddlTrack.find("option:selected").val();
            scoreboard.getDataByTrack(trackNo).done(function (data) {
              refreshGrid(data)
            });
          });
      })()
    """
    webView.evaluateJavaScript(script) { (result, error) in
      if let error = error {
        self.receiver?.webKitClubspeedDataSource(self, error: ClubspeedWebKitDataSourceError.dataSubscriptionFailed(error))
      }
    }
  }
  
  private func handleNewGridData(_ data: Any) {
    if let leaderboard = Leaderboard(clubspeedJSONObject: data) {
      receiver?.webKitClubspeedDataSource(self, newLeaderboard: leaderboard)
    } else {
      receiver?.webKitClubspeedDataSource(self, error: ClubspeedWebKitDataSourceError.cantParseLeaderboard)
    }
  }
  
  // MARK: WKNavigationDelegate
  
  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    if !hasSelectedTrack {
      selectTrack(index: trackNumber)
      hasSelectedTrack = true
    }
  }

  public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    receiver?.webKitClubspeedDataSource(self, error: ClubspeedWebKitDataSourceError.webKitError(error))
  }
  
  public func webView(
      _ webView: WKWebView,
      didFailProvisionalNavigation navigation: WKNavigation!,
      withError error: Error
  ) {
    receiver?.webKitClubspeedDataSource(self, error: ClubspeedWebKitDataSourceError.webKitError(error))
  }
      

  // MARK: WKScriptMessageHandler

  public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    switch message.name {
    case "selectedTrackHandler":
      receiver?.webKitClubspeedDataSource(self, selectedTrackName: "\(message.body)")
      self.hookToRefreshGrid()
    case "refreshGridHandler":
      handleNewGridData(message.body)
    default:
      break
    }
  }
}

public class ClubspeedWebKitDataSourceProviderImpl: ClubspeedWebKitDataSourceProvider {
  private let webKitHostWindow: UIWindow
  private let trackNumber: Int
  
  public init(webKitHostWindow: UIWindow, trackNumber: Int) {
    self.webKitHostWindow = webKitHostWindow
    self.trackNumber = trackNumber
  }
  
  public func make(receiver: ClubspeedWebKitDataSourceReceiver) -> ClubspeedWebKitDataSourceProtocol {
      let dataSource =  ClubspeedWebKitDataSource(
        window: self.webKitHostWindow,
        trackNumber: self.trackNumber,
        receiver: receiver)
      dataSource.start()
      return dataSource
  }
}

public enum ClubspeedWebKitDataSourceError: Error {
  case cantParseLeaderboard
  case webKitError(_ error: Error)
  case trackSelectionJSFailed(_ error: Error)
  case dataSubscriptionFailed(_ error: Error)
}

extension ClubspeedWebKitDataSourceError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .cantParseLeaderboard:
      return "Can't parse the leaderboard data."
    case let .webKitError(error):
      return "WebKit error: \(error)"
    case let .trackSelectionJSFailed(error):
      return "Track selection JS failed: \(error)"
    case let .dataSubscriptionFailed(error):
      return "Data subscription failed: \(error)"
    }
  }
}
