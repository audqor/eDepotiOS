//
//  EzDatabase.swift
//  edepotMobile
//
//  Created by nocson on 2018. 8. 9..
//  Copyright © 2018년 nocson. All rights reserved.
//


import Foundation


class EzDatabase{
    
    var databasePath = String()
    
    
    //DB Contact
    func ContactDB(){
        
        let fileMgr = FileManager.default
        //파일 찾기, 유저 홈 위치
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        //Document 경로
        let docsDir = dirPath[0]
        print(docsDir)
        
        //Document/tblSetting.db 경로
        databasePath = docsDir.appending("/tbl_Setting.db")
        
        if !fileMgr.fileExists(atPath: databasePath){
            
            let contactDB = FMDatabase(path: databasePath)
            
            if contactDB.open(){
                let createSql = "CREATE TABLE IF NOT EXISTS TBL_SETTING ( COL_URL STRING, COL_PROTOCOL)"
                if !contactDB.executeStatements(createSql){
                    print("contactDB execute Fail")
                }
                contactDB.close()
                
            }
            else{
                print("contactDB open Fail")
            }
        }
        else{
            print("contactDB is exist")
        }
    }
    
    //url 가져오는 메서드 urlProtocol 0: http, 1: https
    func GetURLInfo() -> [String : String]{
        
        var url:String = ""
        var urlProtocol:String = ""
        var dic = [String : String]()
        
        let contactDB = FMDatabase(path: databasePath)
        if contactDB.open(){
            //let selectSQL = "delete FROM TBL_SETTING"
            let selectSQL = "SELECT COL_URL, COL_PROTOCOL FROM TBL_SETTING"
            do{
                let result = try contactDB.executeQuery(selectSQL, values: [])
                if result.next(){
                    url = result.string(forColumn: "COL_URL")!
                    urlProtocol = result.string(forColumn: "COL_PROTOCOL")!
                    
                    print(url)
                    print(urlProtocol)
                    
                    dic = [urlProtocol : url]
                }
            }
            catch{
                
            }
        }
        return dic
    }
    
//    func GetTokenKey() -> String{
//
//        var url:String = ""
//        let contactDB = FMDatabase(path: databasePath)
//        if contactDB.open(){
//            //let selectSQL = "delete FROM TBL_SETTING"
//            let selectSQL = "SELECT COL_TOKENKEY FROM TBL_SETTING"
//            do{
//                let result = try contactDB.executeQuery(selectSQL, values: [])
//                if result.next(){
//                    url = result.string(forColumn: "COL_TOKENKEY")!
//
//                }
//            }
//            catch{
//
//            }
//        }
//        return url
//    }
    
    //url 저장: 최초 한번만 저장
    func SetURLInfo(url: String, _protocol: String){
        
        print(url)
        print(_protocol)
        
        let contactDB = FMDatabase(path: databasePath)
        if contactDB.open(){
            let selectSQL = "INSERT INTO TBL_SETTING (COL_URL, COL_PROTOCOL) VALUES('\(url)','\(_protocol)')"
            do{
                let result = try contactDB.executeQuery(selectSQL, values: [])
                if result.next(){
                    //txtURL.text = result.string(forColumn: "COL_URL")
                    
                }
                else{
                    //txtURL.text = ""
                }
            }
            catch{
                
            }
        }
    }
    
    func DeleteUrlInfo(){
        
        let contactDB = FMDatabase(path: databasePath)
        if contactDB.open(){
            //let selectSQL = "delete FROM TBL_SETTING"
            let deleteSQL = "DELETE FROM TBL_SETTING"
            do{
                let result = try contactDB.executeQuery(deleteSQL, values: [])
                if result.next(){
                    
                    print("success")
                }
            }
            catch{
                
            }
        }
    }
}

