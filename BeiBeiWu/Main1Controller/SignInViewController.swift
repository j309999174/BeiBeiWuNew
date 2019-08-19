//
//  SignInViewController.swift
//  BeiBeiWu
//
//  Created by 江东 on 2019/7/25.
//  Copyright © 2019 江东. All rights reserved.
//

import UIKit
import Alamofire

struct UserInfo: Codable {
    let error: String
    let info: String
    let userID: String
    let userNickName:String
    let userPortrait:String
    let userAge: String
    let userGender: String
    let userProperty: String
    let userRegion: String
}

struct RongyunToken: Codable {
    let code: Int
    let userId: String
    let token: String
}


struct WXToken: Codable {
    let access_token:String?
    let expires_in:Int?
    let refresh_token:String?
    let openid:String?
    let scope:String?
    let unionid:String?
}

struct WXUserinfo: Codable {
    let openid:String?
    let nickname:String?
    let sex:Int?
    let province:String?
    let city:String?
    let country:String?
    let headimgurl:String?
    let privilege:[String]?
    let unionid:String?
}

class SignInViewController: UIViewController {

    @IBOutlet weak var userAccount_tf: UITextField!
    @IBOutlet weak var password_tf: UITextField!
    
    var userID:String?
    var userNickName:String?
    var userPortrait:String?
    
    @IBAction func weixinBtn(_ sender: Any) {
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "wechat_sdk_demo"
        WXApi.send(req)
    }
    @IBAction func signUp_btn(_ sender: Any) {
        let parameters: Parameters = ["userAccount": userAccount_tf.text!,"userPassword": password_tf.text!]
        Alamofire.request("https://applet.banghua.xin/app/index.php?i=99999&c=entry&a=webapp&do=signin&m=socialchat", method: .post, parameters: parameters).response { response in
            
            if let data = response.data {
                let decoder = JSONDecoder()
                do {
                    let jsonModel = try decoder.decode(UserInfo.self, from: data)
                    print(jsonModel.userNickName)
                    
                    
                    self.userID = jsonModel.userID
                    self.userNickName = jsonModel.userNickName
                    self.userPortrait = jsonModel.userPortrait
                    //保存用户ID，名字，头像
                    let userInfo = UserDefaults()
                    userInfo.setValue(self.userID, forKey: "userID")
                    userInfo.setValue(self.userNickName, forKey: "userNickName")
                    userInfo.setValue(self.userPortrait, forKey: "userPortrait")
                    
                    //调用融云，获取token
                    self.getRongyunToken(userid: self.userID!, nickname: self.userNickName!, portrait: self.userPortrait!)
                    
                } catch {
                    print("解析 JSON 失败")
                }
            }
            
            
            
//            print("Request: \(String(describing: response.request))")
//            print("Response: \(String(describing: response.response))")
//            print("Error: \(String(describing: response.error))")
//
//            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                print("Data: \(utf8Text)")
//            }
        }
        
    }
    
    
    @IBAction func signIn_btn(_ sender: Any) {
        let sb = UIStoryboard(name: "Main1", bundle:nil)
        let vc = sb.instantiateViewController(withIdentifier: "SignUp") as! SignUpViewController
        self.present(vc, animated: true, completion: nil)
    }
    //  微信成功通知
    @objc func WXLoginSuccess(notification:Notification) {
        let code = notification.object as! String
        let url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=wxc7ff179d403b7a51&secret=1cac4e740d7d91d2c8a76eaf00acad02&code=\(code)&grant_type=authorization_code"
        //获取access_token
        Alamofire.request(url, method: .post).response { response in
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))")
            print("Error: \(String(describing: response.error))")
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("微信token: \(utf8Text)")
                let decoder = JSONDecoder()
                do {
                    let jsonModel = try decoder.decode(WXToken.self, from: data)
                    self.getWXUserinfo(token: jsonModel.access_token!, openid: jsonModel.openid!)
                } catch {
                    print("解析 JSON 失败")
                }
            }
        }
        
    }
    
    func getWXUserinfo(token:String,openid:String){
        //调用token
        let url = "https://api.weixin.qq.com/sns/userinfo?access_token=\(token)&openid=\(openid)"
        Alamofire.request(url, method: .post).response { response in
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))")
            print("Error: \(String(describing: response.error))")
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("微信用户信息: \(utf8Text)")
                let decoder = JSONDecoder()
                do {
                    let jsonModel = try decoder.decode(WXUserinfo.self, from: data)
                    //http转为https
                    var portrait:String = jsonModel.headimgurl!
                    portrait.insert("s", at: (portrait.index(portrait.startIndex, offsetBy: 4)))
                    //微信已获取到用户信息，现在需要保存到数据库
                    self.uploadWXUserinfo(openid: jsonModel.openid!, nickname: jsonModel.nickname!, portrait: portrait)
                    
                    
                } catch {
                    print("解析 JSON 失败")
                }
            }
        }
    }
    
    func uploadWXUserinfo(openid:String,nickname:String,portrait:String){
        let parameters: Parameters = ["openid": openid,"nickname":nickname,"portrait":portrait]
        Alamofire.request("https://applet.banghua.xin/app/index.php?i=99999&c=entry&a=webapp&do=weinxinregister&m=socialchat", method: .post, parameters: parameters).response { response in
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))")
            print("Error: \(String(describing: response.error))")
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
                //保存用户信息
                let userInfo = UserDefaults()
                userInfo.setValue(utf8Text, forKey: "userID")
                userInfo.setValue(nickname, forKey: "userNickName")
                userInfo.setValue(portrait, forKey: "userPortrait")
                //调用融云，获取token
                self.getRongyunToken(userid: utf8Text, nickname: nickname, portrait: portrait)
                //跳转
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShenBian") as! Main1ViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        //通知调用
        NotificationCenter.default.addObserver(self,selector: #selector(WXLoginSuccess(notification:)),name: NSNotification.Name(rawValue: "WXLoginSuccessNotification"),object: nil)
        //删除文件
        let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                           .userDomainMask, true)[0] as String
        let filePath = "\(rootPath)/pickedimage.jpg"
        let fileManager = FileManager.default
        do{
            try fileManager.removeItem(atPath: filePath)
            print("Success to remove file.")
        }catch{
            print("Failed to remove file.")
        }
        // Do any additional setup after loading the view.
    }
    
    
    func getRongyunToken(userid:String,nickname:String,portrait:String){
        
        let parameters: Parameters = ["userID": userid,"userNickName":nickname,"userPortrait":portrait]
        Alamofire.request("https://rongyun.banghua.xin/RongCloud/example/User/userregister.php", method: .post, parameters: parameters).response { response in
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))")
            print("Error: \(String(describing: response.error))")
            
            if let data = response.data{
                let decoder = JSONDecoder()
                do {
                    let jsonModel = try decoder.decode(RongyunToken.self, from: data)
                    print(jsonModel.token)
                    
                    //保存用户ID，名字，头像
                    let userInfo = UserDefaults()
                    userInfo.setValue(jsonModel.token, forKey: "rongyunToken")
                    
                    //跳转首页
                    let sb = UIStoryboard(name: "Main", bundle:nil)
                    let vc = sb.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
                    self.present(vc, animated: true, completion: nil)
                } catch {
                    print("解析 JSON 失败")
                }
                if let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                }
            }
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
