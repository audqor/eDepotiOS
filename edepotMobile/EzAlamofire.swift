//
//  EzAlamofire.swift
//  edepotMobile
//
//  Created by nocson on 2018. 8. 9..
//  Copyright © 2018년 nocson. All rights reserved.
//


import Foundation
import Alamofire


class EzAlamofire {
    
    //var connectView:EzUrlConnectView = EzUrlConnectView()
    
    func IsExistWebUrl(url: String, parent:EzUrlConnectView)
    {
        //connectView = parent
        //let apiUrl: URL = URL(string: "http://192.168.10.8:4931/EzService/EzMioshandler.ashx")!
        let fullUrl = url.appending("/EzService/EzMioshandler.ashx")
        //        let apiUrl: URL = URL(string: fullUrl)!
        
        if let apiUrl = URL(string: fullUrl){
            
            
            let headers = [
                "Content-Type": "text/plain"
            ]
            let parameters: Parameters = [ "Method": "IsConnection" ] as [String : Any]
            
            Alamofire.request(apiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
                DispatchQueue.global().async {
                    switch(response.result) {
                        
                    case .success(_):
                        if response.result.value != nil{
                            print("true")
                            DispatchQueue.main.async {
                                
                                parent.ConnectWebview(isConnect: true)
                            }
                        }
                        break
                        
                    case .failure(_):
                        print("false")
                        DispatchQueue.main.async {
                            parent.ConnectWebview(isConnect: false)
                        }
                        break
                    }
                }
            }
        }
    }
    
    
    
}

