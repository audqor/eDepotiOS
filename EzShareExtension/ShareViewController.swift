//
//  ShareViewController.swift
//  EzShareExtension
//
//  Created by nocson on 2018. 8. 9..
//  Copyright © 2018년 nocson. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import Alamofire
import WebKit

//json 구조체

struct File : Codable {
    var StaticName : String
    var FileName : String
    var FileSize : String
    
}


class ShareViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIWebViewDelegate {
    
    var convertedString: String?
    var sendJsonData = String()
    var tokenKey = String()
    var database:EzDatabase = EzDatabase()
    var WebView: WKWebView!
    
    let encoder = JSONEncoder()
    
//    @IBOutlet weak var Webview: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shareDefaults = UserDefaults(suiteName: "group.edepot")
        self.tokenKey = (shareDefaults!.object(forKey: "tokenKey") as? String)!
       
        self.CreateWebView()
        self.GetImageURL()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done() {
        //        let returnProvider =
        //            NSItemProvider(item: convertedString as NSSecureCoding?,
        //                           typeIdentifier: kUTTypeText as String)
        //
        //        let returnItem = NSExtensionItem()
        //
        //        returnItem.attachments = [returnProvider]
        //        self.extensionContext!.completeRequest(
        //            returningItems: [returnItem], completionHandler: nil)
        
        self.GetImageURL()
    }
    
    func GetImageURL()
    {
        var itemCount:Int = 0
        var num:Int = 0
        var isSuccess = false
        
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                
                itemCount = (item.attachments?.count)!
                if provider.hasItemConformingToTypeIdentifier(kUTTypeData as String) {
                    
                    //                    provider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (imageURL, error) in
                    provider.loadItem(forTypeIdentifier: kUTTypeData as String, options: nil, completionHandler: { (fileURL, error) in
                        OperationQueue.main.addOperation {
                            
                            num += 1
                            if let fileURL = fileURL as? URL {
                                if itemCount == num {
                                    isSuccess = true
                                }
                                
                                DispatchQueue.main.async {
                                    self.uploadFile(url: fileURL, iscomplete: isSuccess)
                                }
                            
                            }
                        }
                    })
                    
                }
            }
        }
        
    }
    //파일 업로드
    func uploadFile(url: URL, iscomplete: Bool)
    {
        
        var staticName = String()
        var fileSize = Double()
        
        
        let apiUrl: URL = URL(string: "http://192.168.10.8:4931/EzService/EzMFileUploader.ashx")!
        let headers = [
            "Content-Type": "multipart/form-data"
        ]
        let fileName = url.lastPathComponent as String
        let params: Parameters = [ "FileName": fileName ] as [String : Any]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(url, withName: "file")
            
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
        }, usingThreshold: UInt64.init(), to: apiUrl, method: .post, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
//                upload.responseJSON(completionHandler: { response in
//
//                    if response.result.isSuccess{
//                        print(response)
//                    }
//
//                })
                
                upload.responseString(completionHandler: {response in
                    if response.result.isSuccess {
                        DispatchQueue.main.async {
                            staticName = (response.value as String?)!
                            fileSize = self.sizePerMB(url: url)
                            
                            let data = File(StaticName: staticName, FileName: fileName, FileSize: fileSize.description)
                            let strDadta = data
                            //let encodeData = try? JSONEncoder().encode(data)
                            

//                            self.sendJsonData += String(describing: self.ConvertJsonFormat(data: data))
//                            self.sendJsonData += ","
                            
                           let jsonData = try? self.encoder.encode(data)

                            if let jsonData = jsonData, let jsonString = String(data: jsonData, encoding: .utf8) {
                                
                                self.sendJsonData += jsonString
                               
                                
                            }
                            
                            if iscomplete {
                               
                                self.sendJsonData = "[" + self.sendJsonData + "]"
                                
                                print(self.sendJsonData)
                                self.webViewLoad()
                            }
                            else {
                                self.sendJsonData += ","
                            }
                            
                            
                        }
                    }
                })
                
            case .failure(let error):
                print(error)
                
            }//end switch
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
        WebView.allowsBackForwardNavigationGestures = true
        WebView.navigationDelegate = self
    }
    
    
//    //Json 변환해주는 코드
//    func ConvertJsonFormat(data: File) -> Any{
//
//        let encodedata = try? JSONEncoder().encode(data)
//
//        var json: Any?
//        if let _data = encodedata{
//            json = try? JSONSerialization.jsonObject(with: _data, options: .allowFragments)
//        }
//        return json as Any
//
//    }
    
    //file size get하는 코드
    func sizePerMB(url: URL?) -> Double {
        guard let filePath = url?.path else {
            return 0.0
        }
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                return size.doubleValue / 1000000.0
            }
        } catch {
            print("Error: \(error)")
        }
        return 0.0
    }
    
    //웹뷰 로드
    func webViewLoad() {
        
        let url = URL(string: "http://192.168.10.8:4931/mobile/ezmfileupload.aspx")
        let request = URLRequest(url: url!)
        WebView.load(request)
        WebView.navigationDelegate = self
        
        WebView.uiDelegate = self
        WebView.allowsBackForwardNavigationGestures = true
    }
    
    //reload되는 시점
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        let url = webView.url?.absoluteString
        
        if url?.range(of: "ezmfileupload.aspx") != nil{
            //webView.evaluateJavaScript("InitUpload('0', '\(self.sendJsonData)', '\(tokenKey)')", completionHandler: { result, error in
            
            print(self.sendJsonData)
            print(self.tokenKey)
            webView.evaluateJavaScript("InitUpload('0', '\(self.sendJsonData)', '\(self.tokenKey)')", completionHandler: { result, error in
            })
        }
        //else if url?.range(of: "ezmusersite.aspx") != nil{
        else if url?.range(of: "EzMUserSite.aspx") != nil{
            let returnProvider = NSItemProvider(item: convertedString as NSSecureCoding?, typeIdentifier: kUTTypeText as String)

            let returnItem = NSExtensionItem()
            returnItem.attachments = [returnProvider]

            self.extensionContext!.completeRequest( returningItems: [returnItem], completionHandler: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
    
    //    //byte배열로 변환하는 메서드
    //    func getArrayOfBytesFromImage(imageData:NSData) -> NSMutableArray
    //    {
    //
    //        // the number of elements:
    //        let count = imageData.length / MemoryLayout.size(ofValue: UInt8())
    //
    //        // create array of appropriate length:
    //        var bytes = [UInt8](repeating: 0, count: count)
    //
    //        // copy bytes into array
    //        imageData.getBytes(&bytes, length:count * MemoryLayout.size(ofValue: UInt8()))
    //
    //
    //        let byteArray:NSMutableArray = NSMutableArray()
    //
    //        //for i in 0..<count {
    //        //byteArray.addObject(NSNumber(unsignedChar: bytes[i]))
    //        byteArray.add(bytes)
    //        // }
    //
    //        return byteArray
    //    }
    
    
    
    
    
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

}
