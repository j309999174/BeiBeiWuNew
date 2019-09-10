//
//  DongtaiTableViewCell.swift
//  BeiBeiWu
//
//  Created by 江东 on 2019/8/10.
//  Copyright © 2019 江东. All rights reserved.
//

import UIKit

protocol DongtaiTableViewCellDelegate{
    func like(circleid:String,likebtn:UIButton)
    func personpage(userID:String)
    func threepoints(circleid:String,userID:String)
}
class DongtaiTableViewCell: UITableViewCell {
    @IBOutlet weak var userID: UILabel!
    @IBOutlet weak var userPortrait: UIImageView!
    @IBOutlet weak var userNickName: UILabel!
    @IBOutlet weak var dongtaiWord: UILabel!
    @IBOutlet weak var dongtaiPicture: UIImageView!
    @IBOutlet weak var dongtaiTime: UILabel!

    @IBOutlet weak var dongtaiLike: UIButton!
    
    @IBOutlet weak var attributes: UILabel!
    
    @IBAction func threePoints(_ sender: UIButton) {
        print("朋友圈的菜单")
        delegate?.threepoints(circleid: circleid!, userID: userID.text!)
    }
    @IBAction func dongtaiLike(_ sender: UIButton) {
        print("朋友圈的like")
        delegate?.like(circleid: circleid!,likebtn: dongtaiLike)
    }
    
    var circleid:String?
    
    var delegate:DongtaiTableViewCellDelegate?
    
    func setData(data:DongtaiData){
        circleid = data.circleid
        var attributesString = data.age! + " | " + data.gender!
        attributesString = attributesString + " | " + data.region!
        attributesString = attributesString + " | " + data.property!
        attributes.text = attributesString
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
        userID.text = data.userID
        
        
        
        dongtaiWord.text = data.dongtaiWord
        dongtaiWord.numberOfLines = 0
        do {
            let data = try Data(contentsOf: URL(string: data.dongtaiPicture)!)
            dongtaiPicture.image = UIImage(data: data)
        }catch let err{
            print(err)
        }
        dongtaiTime.text = data.dongtaiTime
        dongtaiLike.setTitle("赞:\(data.dongtaiLike)", for: UIControl.State.normal)
        
        //头像点击
        let imgClick = UITapGestureRecognizer(target: self, action: #selector(imAction))
        userPortrait.addGestureRecognizer(imgClick)
        userPortrait.isUserInteractionEnabled = true

    }
    //点击事件方法
    @objc func imAction() -> Void {
        print("图片点击事件")
        delegate?.personpage(userID: userID.text!)
    }
    
    
    
}
