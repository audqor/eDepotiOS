//
//  ViewController.swift
//  edepotMobile
//
//  Created by nocson on 2018. 8. 9..
//  Copyright © 2018년 nocson. All rights reserved.
//

import UIKit
import UserNotifications
import PushKit
import CoreData

protocol SendDataDelegate{
    func sendData(url: String, tokenKey: String)
    func sendWebURL(url: String)
}

class EzUrlConnectView: UIViewController, sendBackDelegate {
    
    
    @IBOutlet weak var txtURL: UITextField!
    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var SelectOutlet: UIButton!
    @IBOutlet var ProtocolItemsOutlet: [UIButton]!
    
    static let database:EzDatabase = EzDatabase()
    static let alamo:EzAlamofire = EzAlamofire()
    static let mainView:MainView = MainView()
    
    var isExistUrl = false
    var delegate: SendDataDelegate?
    var databasePath = String()
    var txtProtocol = String()
    var fullUrl = String()
    
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    //프로토콜 선택하는 버튼
    @IBAction func SelectAction(_ sender: UIButton) {
        
        view.endEditing(true)
        
        ProtocolItemsOutlet.forEach{(button) in
  
            UIView.animate(withDuration: 0.25, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    //프로토콜 아이템들
    @IBAction func ProtocolItemsAction(_ sender: UIButton) {
        
        SelectOutlet.titleLabel?.text = sender.titleLabel?.text
        self.txtProtocol = (sender.titleLabel?.text)!
        
        ProtocolItemsOutlet.forEach{(button) in
            
            UIView.animate(withDuration: 0.25, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func webURLReceive(url: String) {
        
    }
    
    func dataReceive(url: String, tokenKey: String) {
        
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.Init()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func Init(){
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        //디비연결
        EzUrlConnectView.database.ContactDB()
        
        //url 정보
        let dicUrl = EzUrlConnectView.database.GetURLInfo()
        
        var proto = String()
        var url = String()
        
        for (key, value) in dicUrl {
            proto = key
            url = value
        }
        if (url != ""){
            
            //url정보가 있다면 뷰를 숨겨줌
            self.view.isHidden = true
            
            txtProtocol = proto
            SelectOutlet.titleLabel?.text = proto
            txtURL.text = url
            
            self.fullUrl = self.txtProtocol + "://" + txtURL.text!
            
            isExistUrl = true
            btnConnect.sendActions(for: .touchUpInside)
            
            
        }
    }
    
    //연결 버튼 클릭 이벤트
    @IBAction func nextPage(_ sender: Any) {
      
        print(self.txtURL.text!)
        print(self.txtProtocol)
        
        //url이 null 이라면
        if (self.txtURL.text! == ""){
            let alert = UIAlertController(title: "Error", message: "연결 주소를 입력해 주세요.", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: UIAlertActionStyle.default)
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
            
            //protocol 선택 안했다면
        else if (self.txtProtocol == ""){
            let alert = UIAlertController(title: "Error", message: "Protocol을 선택해 주세요.", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: UIAlertActionStyle.default)
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
            
            //연결
        else {
            self.fullUrl = self.txtProtocol + "://" + txtURL.text!
            print(self.fullUrl)
            _ = EzUrlConnectView.alamo.IsExistWebUrl(url: self.fullUrl, parent: self)
        }
    }
    
    func ConnectWebview(isConnect: Bool){
        
        //Connect Success
        if(isConnect){
            DispatchQueue.main.async {
                
                if (self.txtURL.text != nil){
                    
                    self.delegate?.sendData(url: self.fullUrl, tokenKey: String(self.appDel.tokenKey))
                    self.dismiss(animated: true, completion: nil)
                }
                
                self.performSegue(withIdentifier: "segNext", sender: self)
                
                if(self.isExistUrl == false){
                    EzUrlConnectView.database.SetURLInfo(url: self.txtURL.text!, _protocol: self.txtProtocol)
                }
            }
        }
            
        //Connect Fail
        else{
            let alert = UIAlertController(title: "Error", message: "유효하지 않은 주소입니다.", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: UIAlertActionStyle.default)
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
   
    
    // url연결 후 webView로 이동 하는 메서드
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segNext"{
            
            let webViewVC = segue.destination as! MainView
            webViewVC.webURL = self.fullUrl
            webViewVC.regID = appDel.tokenKey
            webViewVC.delegate = self
        }
        
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    
    //포커스 이동시 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
        ProtocolItemsOutlet.forEach{(button) in
            
            UIView.animate(withDuration: 0.25, animations: {
                button.isHidden = true
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    //푸시 테스트
    //    func PushTest(){
    //
    //        let content = UNMutableNotificationContent()
    //        content.title = "Title"
    //        content.subtitle = "SubTitle"
    //        content.body =  "Body"
    //        content.sound = UNNotificationSound.default()
    //
    //        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4, repeats: false)
    //        _ = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
    //
    //
    //        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow,Error in
    //
    //
    //        })
    //    }
    
    
}


