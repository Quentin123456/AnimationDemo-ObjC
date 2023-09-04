//
//  AppDelegate.swift
//  iOSCallFlutterModule
//
//  Created by Quentin Zang on 2023/9/4.
//

import UIKit
import Flutter
import flutter_boost

@main
class AppDelegate: UIResponder, UIApplicationDelegate, FlutterBoostDelegate {
    
    ///您用来push的导航栏
       var navigationController:UINavigationController?

       ///用来存返回flutter侧返回结果的表
       var resultTable:Dictionary<String,([AnyHashable:Any]?)->Void> = [:];
    
    func pushNativeRoute(_ pageName: String!, arguments: [AnyHashable : Any]!) {
        //可以用参数来控制是push还是pop
                let isPresent = arguments["isPresent"] as? Bool ?? false
                let isAnimated = arguments["isAnimated"] as? Bool ?? true
                //这里根据pageName来判断生成哪个vc，这里给个默认的了
                var targetViewController = UIViewController()

                if(isPresent){
                    self.navigationController?.present(targetViewController, animated: isAnimated, completion: nil)
                }else{
                    self.navigationController?.pushViewController(targetViewController, animated: isAnimated)
                }
    }
    
    func pushFlutterRoute(_ options: FlutterBoostRouteOptions!) {
        let vc:FBFlutterViewContainer = FBFlutterViewContainer()
                vc.setName(options.pageName, uniqueId: options.uniqueId, params: options.arguments,opaque: options.opaque)

                //用参数来控制是push还是pop
                let isPresent = (options.arguments?["isPresent"] as? Bool)  ?? false
                let isAnimated = (options.arguments?["isAnimated"] as? Bool) ?? true

                //对这个页面设置结果
                resultTable[options.pageName] = options.onPageFinished;

                //如果是present模式 ，或者要不透明模式，那么就需要以present模式打开页面
                if(isPresent || !options.opaque){
                    self.navigationController?.present(vc, animated: isAnimated, completion: nil)
                }else{
                    self.navigationController?.pushViewController(vc, animated: isAnimated)
                }
    }
    
    func popRoute(_ options: FlutterBoostRouteOptions!) {
        //如果当前被present的vc是container，那么就执行dismiss逻辑
        if let vc = self.navigationController?.presentedViewController as? FBFlutterViewContainer,vc.uniqueIDString() == options.uniqueId{

            //这里分为两种情况，由于UIModalPresentationOverFullScreen下，生命周期显示会有问题
            //所以需要手动调用的场景，从而使下面底部的vc调用viewAppear相关逻辑
            if vc.modalPresentationStyle == .overFullScreen {

                //这里手动beginAppearanceTransition触发页面生命周期
                self.navigationController?.topViewController?.beginAppearanceTransition(true, animated: false)

                vc.dismiss(animated: true) {
                    self.navigationController?.topViewController?.endAppearanceTransition()
                }
            }else{
                //正常场景，直接dismiss
                vc.dismiss(animated: true, completion: nil)
            }
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        //否则直接执行pop逻辑
        //这里在pop的时候将参数带出,并且从结果表中移除
        if let onPageFinshed = resultTable[options.pageName] {
            onPageFinshed(options.arguments)
            resultTable.removeValue(forKey: options.pageName)
        }
    }
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //创建代理，做初始化操作
        let delegate = AppDelegate()
        FlutterBoost.instance().setup(application, delegate: delegate) { engine in

        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

