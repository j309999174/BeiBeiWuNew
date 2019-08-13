//
//  LuntanViewController.swift
//  BeiBeiWu
//
//  Created by 江东 on 2019/8/10.
//  Copyright © 2019 江东. All rights reserved.
//

import UIKit
import Alamofire
import FSPagerView
import MarqueeLabel


struct GonggaoStruct:Codable {
    let id:String
    let noticeinfo:String
}

struct LuntanStruct: Codable {
    let id:String
    let plateid:String
    let platename:String
    let authid: String
    let authnickname:String
    let authportrait:String
    let posttip:String?
    let posttitle:String
    let posttext:String?
    let postpicture:String?
    let like:String?
    let favorite:String?
    let time:String
}

class LuntanViewController: UIViewController {
    @IBAction func guangchangDongtai(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            //同一个StoryBoard下
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Dongtai") as! Main4ViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func plateMenu(_ sender: UISegmentedControl) {
        subNav = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        dataList.removeAll()
        imageArr.removeAll()
        imageNameArr.removeAll()
        initData()
    }
    @IBOutlet weak var luntanTableView: UITableView!
    @IBOutlet weak var marqueeLabel: MarqueeLabel!
    
    @IBOutlet weak var pagerView: FSPagerView!{
        didSet {
            pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            pagerView.itemSize = FSPagerView.automaticSize
            pagerView.isInfinite = true
            pagerView.alwaysBounceHorizontal = true
            pagerView.removesInfiniteLoopForSingleItem = true
            pagerView.automaticSlidingInterval = 3.0
        }
    }
    var imageArr = [UIImage]()
    var imageNameArr = [String]()
    var subNav = "首页"
    var dataList:[LuntanData] = []
    var gonggao = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        //删除文件
        let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                           .userDomainMask, true)[0] as String
        let filePath1 = "\(rootPath)/pickedimage1.jpg"
        let filePath2 = "\(rootPath)/pickedimage2.jpg"
        let filePath3 = "\(rootPath)/pickedimage3.jpg"
        let fileManager = FileManager.default
        do{
            try fileManager.removeItem(atPath: filePath1)
            try fileManager.removeItem(atPath: filePath2)
            try fileManager.removeItem(atPath: filePath3)
            print("Success to remove file.")
        }catch{
            print("Failed to remove file.")
        }
        //公告
        let parameters: Parameters = ["type": "getGonggao"]
        Alamofire.request("https://applet.banghua.xin/app/index.php?i=99999&c=entry&a=webapp&do=luntan&m=socialchat", method: .post, parameters: parameters).response { response in
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))")
            print("Error: \(String(describing: response.error))")
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
                let decoder = JSONDecoder()
                do {
                    let jsonModel = try decoder.decode([GonggaoStruct].self, from: data)
                    for index in 0..<jsonModel.count{
                        self.gonggao += jsonModel[index].noticeinfo
                    }
                    self.marqueeLabel.text = self.gonggao
                    self.marqueeLabel.reloadInputViews()
                } catch {
                    print("解析 JSON 失败")
                }
            }
        }
        
        
        initData()
        // Do any additional setup after loading the view.
    }
    
    
    
    func initData(){
        //获取幻灯片数据
        let getSlide: Parameters = ["type": "getSlide","slidesort":subNav]
        Alamofire.request("https://applet.banghua.xin/app/index.php?i=99999&c=entry&a=webapp&do=luntan&m=socialchat", method: .post, parameters: getSlide).response { response in
            if let data = response.data {
                let decoder = JSONDecoder()
                do {
                    let jsonModel = try decoder.decode([SliderImages].self, from: data)
                    for index in 0..<jsonModel.count{
                        let data = try Data(contentsOf: URL(string: jsonModel[index].slidepicture)!)
                        self.imageArr.append(UIImage(data: data)!)
                        self.imageNameArr.append(jsonModel[index].slidename)
                    }
                    self.pagerView.reloadData()
                } catch {
                    print("解析 JSON 失败")
                }
                print("Request: \(String(describing: response.request))")
                print("Response: \(String(describing: response.response))")
                print("Error: \(String(describing: response.error))")
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                }
            }
        }
        
        
        
        
        //获取帖子数据
        let getPost: Parameters = ["type": "getPostlist","platename":subNav]
        Alamofire.request("https://applet.banghua.xin/app/index.php?i=99999&c=entry&a=webapp&do=luntan&m=socialchat", method: .post, parameters: getPost).response { response in
            if let data = response.data {
                let decoder = JSONDecoder()
                do {
                    let jsonModel = try decoder.decode([LuntanStruct].self, from: data)
                    for index in 0..<jsonModel.count{
                        let cell = LuntanData(id: jsonModel[index].id, plateid: jsonModel[index].plateid, platename: jsonModel[index].platename, authid: jsonModel[index].authid, authnickname: jsonModel[index].authnickname, authportrait: jsonModel[index].authportrait, posttip: jsonModel[index].posttip ?? "", posttitle: jsonModel[index].posttitle, posttext: jsonModel[index].posttext ?? "", postpicture: jsonModel[index].postpicture ?? "", like: jsonModel[index].like ?? "", favorite: jsonModel[index].favorite ?? "", time: jsonModel[index].time)
                        self.dataList.append(cell)
                    }
                    self.luntanTableView.reloadData()
                } catch {
                    print("解析 JSON 失败")
                }
                print("Request: \(String(describing: response.request))")
                print("Response: \(String(describing: response.response))")
                print("Error: \(String(describing: response.error))")

                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
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



extension LuntanViewController:FSPagerViewDataSource,FSPagerViewDelegate{
    
    // MARK:- FSPagerViewDataSource
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.imageArr.count
    }
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.image = self.imageArr[index]
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.text = imageNameArr[index]
        return cell
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        
    }
}


extension LuntanViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let oneOfList = dataList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "luntanCell") as! LuntanTableViewCell
        
        cell.setData(data: oneOfList)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //同一个StoryBoard下
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PostlistView") as! PostlistViewController
        vc.id = dataList[indexPath.row].id
        vc.plateid = dataList[indexPath.row].plateid
        vc.platename = dataList[indexPath.row].platename
        vc.authid = dataList[indexPath.row].authid
        vc.authnickname = dataList[indexPath.row].authnickname
        vc.authportrait = dataList[indexPath.row].authportrait
        vc.posttip = dataList[indexPath.row].posttip
        vc.posttitle = dataList[indexPath.row].posttitle
        vc.posttext = dataList[indexPath.row].posttext
        vc.postpicture = dataList[indexPath.row].postpicture
        vc.like = dataList[indexPath.row].like
        vc.favorite = dataList[indexPath.row].favorite
        vc.time = dataList[indexPath.row].time
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
