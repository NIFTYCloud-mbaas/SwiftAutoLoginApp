//
//  ViewController.swift
//  SwiftAutoLoginApp
//
//  Created by Natsumo Ikeda on 2016/10/26.
//  Copyright 2017 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
//

import UIKit
import NCMB

class ViewController: UIViewController {
    // label
    @IBOutlet weak var greetingMessage: UILabel!
    @IBOutlet weak var lastVisit: UILabel!
    @IBOutlet weak var dayAndTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // labelの初期化
        greetingMessage.text = ""
        lastVisit.text = ""
        dayAndTime.text = ""
        
        // UUID取得
        let uuid = UIDevice.current.identifierForVendor?.uuidString
        print("uuid:\(uuid)")
        
        /* mBaaSログイン */
        NCMBUser.logInWithUsername(inBackground: uuid, password: uuid) { (user, login_error) in
            if login_error != nil {
                // ログイン失敗時の処理
                let login_err : NSError = login_error as! NSError
                print("ログインに失敗しました。エラーコード：\(login_err.code)")
                
                // 初回利用（会員未登録）の場合
                if login_err.code == 401002 { // 401002：ID/Pass認証エラー
                    /* mBaaS会員登録 */
                    let new_user = NCMBUser()
                    new_user.userName = uuid
                    new_user.password = uuid
                    new_user.signUpInBackground({ (signUp_error) in
                        if signUp_error != nil {
                            // 会員登録失敗時の処理
                            let signUp_err = signUp_error as! NSError
                            print("会員登録に失敗しました。エラーコード：\(signUp_err.code)")
                        } else {
                            // 会員登録成功時の処理
                            print("会員登録に成功しました。")
                            
                            self.greetingMessage.text = "はじめまして！"
                            
                            /* mBaaSデータの保存 */
                            let lastLoginDate = new_user.updateDate
                            new_user.setObject(lastLoginDate, forKey: "lastLoginDate")
                            new_user.saveInBackground({ (save_error) in
                                if save_error != nil {
                                    // 保存失敗時の処理
                                    let save_err = save_error as! NSError
                                    print("最終ログイン日時の保存に失敗しました。エラーコード：\(save_err.code)")
                                    
                                } else {
                                    // 保存成功時の処理
                                    print("最終ログイン日時の保存に成功しました。")
                                    
                                }
                            })
                            
                        }
                    })
                }
                
            } else {
                // ログイン成功時の処理
                print("ログインに成功しました")
                
                self.greetingMessage.text = "おかえりなさい"
                self.lastVisit.text = "最終ログイン"
                
                // 最終ログイン日時取得
                
                let lastLoginDate = user?.object(forKey: "lastLoginDate") as! Date
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                let dateStr = formatter.string(from: lastLoginDate)
                self.dayAndTime.text = "\(dateStr)"
                
                // ログイン日時の上書き
                let updateDate = user?.updateDate
                user?.setObject(updateDate, forKey: "lastLoginDate")
                user?.saveInBackground({ (save_error) in
                    if save_error != nil {
                        // 保存失敗時の処理
                        let save_err = save_error as! NSError
                        print("最終ログイン日時の保存に失敗しました。エラーコード：\(save_err.code)")
                        
                    } else {
                        // 保存成功時の処理
                        print("最終ログイン日時の保存に成功しました。")
                    }
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
