//
//  ViewController.swift
//  iOSCallFlutterModule
//
//  Created by Quentin Zang on 2023/9/4.
//

import UIKit
import flutter_boost

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let button: UIButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 30))
        button.addTarget(self, action: #selector(gotoNext), for: .touchUpInside)
        button.setTitle("点击测试", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .orange
        view.addSubview(button)
    }

    @objc
    func gotoNext(_ button: UIButton) -> Void {
        let options = FlutterBoostRouteOptions()
        options.pageName = "main"
        //页面是否透明（用于透明弹窗场景），若不设置，默认情况下为true
        options.opaque = true
        //这个是push操作完成的回调，而不是页面关闭的回调！！！！
        options.completion = { completion in
            print("open operation is completed")
        }
        //这个是页面关闭并且返回数据的回调，回调实际需要根据您的Delegate中的popRoute来调用
        options.onPageFinished = { dic in
            debugPrint(dic as Any)
        }
        FlutterBoost.instance().open(options)
    }

}

