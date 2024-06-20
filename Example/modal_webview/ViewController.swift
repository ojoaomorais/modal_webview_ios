//
//  ViewController.swift
//  modal_webview
//
//  Created by João Pedro on 06/17/2024.
//  Copyright (c) 2024 João Pedro. All rights reserved.
//

import UIKit
import modal_webview

class ViewController: UIViewController {

    let webview = ModalWebview()
    var url = URL(string: "https://developer.apple.com/")!

    override func viewDidLoad() {
        super.viewDidLoad()
        webview.delegate = self
        webview.show(controller: self, url: url)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showBrowserAction(){
        webview.show(controller: self, url: url)
    }
}

extension ViewController: ModalWebviewProtocol{
    func didClose() {
        print("Closed")
    }
}

