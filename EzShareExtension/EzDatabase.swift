//
//  EzDatabase.swift
//  EzShareExtension
//
//  Created by nocson on 2018. 8. 10..
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
                let createSql = "CREATE TABLE IF NOT EXISTS TBL_SETTING ( COL_URL STRING, COL_TOKENKEY STRING)"
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
    
    func GetTokenKey() -> String{
        
        var tokenID:String = ""
        let contactDB = FMDatabase(path: databasePath)
        if contactDB.open(){
            //let selectSQL = "delete FROM TBL_SETTING"
            let selectSQL = "SELECT COL_TOKENKEY FROM TBL_SETTING"
            do{
                let result = try contactDB.executeQuery(selectSQL, values: [])
                if result.next(){
                    tokenID = result.string(forColumn: "COL_TOKENKEY")!
                    
                }
            }
            catch{
                
            }
        }
        return tokenID
    }
    
}

