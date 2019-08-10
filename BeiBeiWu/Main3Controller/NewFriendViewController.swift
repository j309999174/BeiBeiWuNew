//
//  NewFriendViewController.swift
//  BeiBeiWu
//
//  Created by 江东 on 2019/8/10.
//  Copyright © 2019 江东. All rights reserved.
//

import UIKit
import Alamofire


struct NewFriendStruct: Codable {
    let yourid: String
    let yournickname: String
    let yourportrait: String
    let yourleavewords: String
    let agree: String
}

class NewFriendViewController: UIViewController {

    
    @IBOutlet weak var newFriendTableView: UITableView!
    
    let userInfo = UserDefaults()
    var userID:String?
    var userNickName:String?
    var userPortrait:String?
    var dataList:[NewFriendData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        userID = userInfo.string(forKey: "userID")
        userNickName = userInfo.string(forKey: "userNickName")
        userPortrait = userInfo.string(forKey: "userPortrait")
        let parameters: Parameters = ["myid": userID!]
        Alamofire.request("https://applet.banghua.xin/app/index.php?i=99999&c=entry&a=webapp&do=friendsapply&m=socialchat", method: .post, parameters: parameters).response { response in
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))")
            print("Error: \(String(describing: response.error))")

            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
                let decoder = JSONDecoder()
                do {
                    let jsonModel = try decoder.decode([NewFriendStruct].self, from: data)
                    for index in 0..<jsonModel.count{
                        let cell = NewFriendData(userID:jsonModel[index].yourid,userNickName: jsonModel[index].yournickname,userPortrait: jsonModel[index].yourportrait,userLeaveWords: jsonModel[index].yourleavewords,agree: jsonModel[index].agree)
                        self.dataList.append(cell)
                    }
                   self.newFriendTableView.reloadData()
                } catch {
                    print("解析 JSON 失败")
                }
            }
            
        }
        // Do any additional setup after loading the view.
    }
    
}


extension NewFriendViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let oneOfList = dataList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newFriendCell") as! NewFriendTableViewCell
        
        cell.setData(data: oneOfList)
        cell.delegate = self
        return cell
    }
    
}


extension NewFriendViewController:NewFriendTableViewCellDelegate{
    func didAgree(yourid: String, yournickname: String, yourportrait: String,agreebtn:UIButton) {
        print("userid:\(userID!);yourid\(yourid);yournickname:\(yournickname);yourportrait:\(yourportrait)")
        let parameters: Parameters = ["myid": userID!,"mynickname":userNickName!,"myportrait":userPortrait!,"yourid":yourid,"yournickname":yournickname,"yourportrait":yourportrait]
        Alamofire.request("https://applet.banghua.xin/app/index.php?i=99999&c=entry&a=webapp&do=agreefriend&m=socialchat", method: .post, parameters: parameters).response { response in
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))")
            print("Error: \(String(describing: response.error))")
            agreebtn.setTitle("已同意", for: UIControl.State.normal)
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
            }
        }
    }
    
}


