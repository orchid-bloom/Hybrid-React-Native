//
//  ViewController.swift
//  IOSDemo
//
//  Created by Tema.Tian on 2019/11/23.
//  Copyright © 2019 Tema.Tian. All rights reserved.
//

import UIKit
import React

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  @IBAction func present(_ sender: UIButton) {
    var jsCodeLocation: URL!
    #if DEBUG
    jsCodeLocation = URL(string: "http://10.30.10.155:8081/index.bundle?platform=ios")!
    #else
    jsCodeLocation = Bundle.main.url(forResource: "bundle/index.ios", withExtension: "jsbundle")
    #endif
    let rootView = RCTRootView(bundleURL: jsCodeLocation!, moduleName: "react_demo", initialProperties: nil, launchOptions: nil)
    let vc = UIViewController()
    vc.view = rootView
    present(vc, animated: true, completion: nil)
  }
}

