//
//  EzCreateWebview.swift
//  EzShareExtension
//
//  Created by nocson on 2018. 8. 10..
//  Copyright © 2018년 nocson. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SafariServices
class EzCreateWebview :UIViewController, WKUIDelegate, WKNavigationDelegate, UIWebViewDelegate {
    
    var WebView: WKWebView!
    
    func CreateWebView() -> WKWebView{
        
        view.backgroundColor = UIColor.white
        WebView = WKWebView()
        
        WebView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(WebView)
        
        if #available(iOS 11.0, *){
            let safeArea = self.view.safeAreaLayoutGuide
            WebView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
            WebView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
            WebView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
            WebView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
            
        }
        else{
            WebView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            WebView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
            WebView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            WebView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor).isActive = true
        }
        
        WebView.uiDelegate = self
        WebView.allowsBackForwardNavigationGestures = true
        
        
        return WebView
    }
}
