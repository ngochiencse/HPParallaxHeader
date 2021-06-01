//
//  HPWebViewController.swift
//  HPParallaxHeader
//
//  Created by Hien Pham on 03/04/2021.
//  Copyright (c) 2021 Hien Pham. All rights reserved.
//

import UIKit
import WebKit
import HPParallaxHeader

class HPWebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = URLRequest(url: URL(string: "https://dribbble.com/search?q=spaceship")!)
        webView.load(request)
    }
}
