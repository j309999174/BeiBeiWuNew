//
//  SousuoTableViewCell.swift
//  BeiBeiWu
//
//  Created by 江东 on 2019/7/30.
//  Copyright © 2019 江东. All rights reserved.
//

import UIKit

class SousuoTableViewCell: UITableViewCell {
    @IBOutlet weak var userPortrait: UIImageView!
    @IBOutlet weak var userNickName: UILabel!
    @IBOutlet weak var userAge: UILabel!
    @IBOutlet weak var userGender: UILabel!
    @IBOutlet weak var userProperty: UILabel!
    @IBOutlet weak var userDistance: UILabel!
    @IBOutlet weak var userRegion: UILabel!
    @IBOutlet weak var userVIP: UILabel!
    @IBOutlet weak var userID: UILabel!
    
    func setData(data: ShenBianData){
        do {
            let data = try Data(contentsOf: URL(string: data.userPortrait)!)
            userPortrait.image = UIImage(data: data)
            userPortrait.contentMode = .scaleAspectFill
            //设置遮罩
            userPortrait.layer.masksToBounds = true
            //设置圆角半径(宽度的一半)，显示成圆形。
            userPortrait.layer.cornerRadius = userPortrait.frame.width/2
        }catch let err{
            print(err)
        }
        userNickName.text = data.userNickName
        userAge.text = data.userAge
        userGender.text = data.userGender
        userProperty.text = data.userProperty
        userDistance.text = data.userDistance+"km"
        userRegion.text = data.userRegion
        userVIP.text = data.userVIP
        userID.text = data.userID
    }
    

}