//
//  MainView.swift
//  edepotMobile
//
//  Created by nocson on 2018. 8. 9..
//  Copyright © 2018년 nocson. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SafariServices
import MobileCoreServices
import Alamofire

protocol sendBackDelegate {
    func dataReceive(url: String, tokenKey: String)
    func webURLReceive(url: String)
}


class MainView : UIViewController, WKUIDelegate, WKNavigationDelegate, UIWebViewDelegate, SendDataDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WKScriptMessageHandler {
   
    
    static let database:EzDatabase = EzDatabase()
    
    var delegate : sendBackDelegate?
    var webURL: String = String()
    var regID: String = String()
    var WebView: WKWebView!
    
    var newPic = Bool()
    var swipreGesture = UISwipeGestureRecognizer()
    
    let picker = UIImagePickerController()
    
    let messageHandlerName = "callbackHandler"
    
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        //WKWebview생성
        self.CreateWebView()
        
        self.Init()
        
        //SwipeGesture 세팅
        self.SetSwipeGesture()
       
        
    }
    func Init(){
        
        let strURL = webURL.appending("/mobile/EzMLogin.aspx")   // "http://192.168.10.8:4931/mobile/EzMLogin.aspx"
        let request = URLRequest(url: URL(string: strURL)!)
        
        WebView.load(request)
        WebView.navigationDelegate = self
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mainView = self
    }
    
    //SwipeGesture 세팅
    func SetSwipeGesture() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
    }
    
    @objc func swiped(gesture: UIGestureRecognizer)
    {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer
        {
            switch swipeGesture.direction
            {
                case UISwipeGestureRecognizerDirection.right:
                    
                    self.WebView.evaluateJavaScript("BackClick()", completionHandler: { result, error in
                        print(result)
                    })
                default:
                    break
                }
        }
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == messageHandlerName{
            
            
        }
    }
    
    //웹뷰를 코드로 직접 그려줌
    func CreateWebView(){
        
      
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
        
        //swipe로 뒤로가기
        WebView.uiDelegate = self
        //WebView.allowsBackForwardNavigationGestures = true
        WebView.navigationDelegate = self
        
    }
    
    func sendData(url: String, tokenKey: String) {
        webURL = url
        regID = tokenKey
        
    }
    
    
    //reload되는 시점
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        let url = webView.url?.absoluteString
        
        if url?.range(of:"EzMLogin") != nil{
            
            if url?.range(of:"reconnection") != nil{
                
                MainView.database.ContactDB()
                MainView.database.DeleteUrlInfo()
                
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let view = storyboard.instantiateViewController(withIdentifier: "UrlConnectView") as UIViewController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                //show window
                appDelegate.window?.rootViewController = view
                
            }
            else{
            
                webView.evaluateJavaScript("MLogin('\(self.regID)', '0')", completionHandler: { result, error in
                    
                })
            }
        }
        else if url?.range(of: "UserSite") != nil{
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            if(appDelegate.isAlert){
                webView.evaluateJavaScript("OnAlertPage()", completionHandler: { result, error in
                    
                })
                
                appDelegate.isAlert = false
            }
        }
        else if url?.range(of: "MFileUpload") != nil{
            
            webView.evaluateJavaScript("InitUpload('1', '', '', 'false')", completionHandler: { result, error in
            })
        }
        
    
        
    }
    
    
    
   
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if self.presentedViewController != nil {
            super.dismiss(animated: flag, completion: completion)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var newImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        // do something interesting here!
        print(newImage.size)
        
        dismiss(animated: true)
        
    }
    
    //Alert 눌렀을 때
    func sendWebURL(url: String) {
        
        WebView.evaluateJavaScript("OnAlertPage()", completionHandler: { result, error in })
    }
    
    
    // Alert을 띄우기 위한 코드 필수!!
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Alert을 띄우기 위한 코드 필수!!
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Alert을 띄우기 위한 코드 필수!!
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .actionSheet)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            
            completionHandler(nil)
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
       
        if(navigationAction.request.url?.absoluteString.lowercased().range(of: "download") != nil){
          
            DispatchQueue.main.async {
                                self.startDownload(audioUrl: (navigationAction.request.url?.absoluteString)!)
            }

            
            //self.createFolder(folderName: "testddd")
            decisionHandler(.cancel)
            
        }
        else{
            decisionHandler(.allow)
        }
    }
    
    
    func startDownload(audioUrl: String) -> Void {
        
        
        let tempPath = self.getSaveFileUrl()
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (tempPath, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(audioUrl, to:destination)
            .downloadProgress { (progress) in
                
                print((String)(progress.fractionCompleted))
                //self.progressLabel.text = (String)(progress.fractionCompleted)
            }
            .responseData { (data) in
                
                let fileManager = FileManager.default
                let parentPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let targetName = (data.response?.suggestedFilename) as String?
                let targetPath = parentPath.appendingPathComponent(targetName!)

                do {
                    try  fileManager.moveItem(at: tempPath, to: targetPath)
                    
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "다운로드", message: "다운로드를 완료하였습니다.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: UIAlertActionStyle.default)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                } catch {
                    
                    print(error.localizedDescription)
                    
                }
                
        }
    }
    
    func getSaveFileUrl() -> URL {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let uuid = NSUUID().uuidString
        let fileURL = documentsURL.appendingPathComponent(uuid  + ".tmp")
       
        return fileURL;
    }
    
    func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    
                    print(error.localizedDescription)
                    return nil
                }
            }
            
            return folderURL
        }
        
        return nil
    }
    
    func Logout(){
        
        let alert = UIAlertController(title: "로그아웃", message: "다른기기에서 로그인되어 강제로 로그아웃됩니다.", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) -> Void in
            
//            MainView.database.ContactDB()
//            MainView.database.DeleteUrlInfo()
//
//
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let view = storyboard.instantiateViewController(withIdentifier: "UrlConnectView") as UIViewController
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            //show window
//            appDelegate.window?.rootViewController = view
            
            self.WebView.evaluateJavaScript("LogoutClick()", completionHandler: { result, error in
                
            })
          
            
        })
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
