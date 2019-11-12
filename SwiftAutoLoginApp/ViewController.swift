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
        NCMBUser.logInInBackground(userName: uuid!, password: uuid!, callback:{ result in
            
            switch result {
                case .success:
                    // ログイン成功時の処理
                    print("ログインに成功しました")
                    
                    // 最終ログイン日時取得
                    let user:NCMBUser = NCMBUser.currentUser!
                    let updateDate = user["updateDate"]! as Any
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-ddT07:12:02.127Z"//"yyyy/MM/dd HH:mm:ss"
                    let lastLoginDate = updateDate as! String
                    
                    
                    DispatchQueue.main.sync {
                        self.greetingMessage.text = "おかえりなさい"
                        self.lastVisit.text = "最終ログイン"
                        self.dayAndTime.text = "\(lastLoginDate)"
                    }

                    // ログイン日時の上書き
                    user["lastLoginDate"] = lastLoginDate
                    user.saveInBackground(callback: { updateResult in
                        switch updateResult {
                            case .success:
                                // 保存成功時の処理
                                print("最終ログイン日時の保存に成功しました。")
                                break
                            case let .failure(update_error):
                                // 保存失敗時の処理
                                print("最終ログイン日時の保存に失敗しました。エラーコード：\(update_error)")
                        }
                        
                    })
                    break
            case let .failure(login_error):
                    // ログイン失敗時の処理
                    print("ログインに失敗しました。エラーコード：\(login_error)")
                    // 初回利用（会員未登録）の場合
                    if (login_error as? NCMBApiError)?.errorCode == .authenticationErrorWithIdPassIncorrect { // 401002：ID/Pass認証エラー
                        /* mBaaS会員登録 */
                        let new_user = NCMBUser()
                        new_user.userName = uuid
                        new_user.password = uuid
                        new_user.signUpInBackground(callback: {signupResult in
                            switch signupResult {
                                case .success:
                                    // 会員登録成功時の処理
                                    print("会員登録に成功しました。")
                                    
                                    DispatchQueue.main.sync {
                                        self.greetingMessage.text = "はじめまして！"
                                    }
                                    
                                    /* mBaaSデータの保存 */
                                    let lastLoginDate = new_user["updateDate"]! as Date
                                    new_user["lastLoginDate"] = lastLoginDate
                                    new_user.saveInBackground(callback: { newUpdateResult in
                                        switch newUpdateResult {
                                            case .success:
                                                // 保存成功時の処理
                                                print("最終ログイン日時の保存に成功しました。")
                                                break
                                            case let .failure(newUpdate_error):
                                                // 保存失敗時の処理
                                                print("最終ログイン日時の保存に失敗しました。エラーコード：\(newUpdate_error)")
                                        }
                                    })
                                case let .failure(signup_error):
                                    // 会員登録失敗時の処理
                                    print("会員登録に失敗しました。エラーコード：\(signup_error)")
                            }
                    })
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
