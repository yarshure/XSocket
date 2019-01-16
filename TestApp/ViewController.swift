//
//  ViewController.swift
//  TestApp
//
//  Created by yarshure on 2018/10/26.
//  Copyright © 2018 yarshure. All rights reserved.
//

import Cocoa

class ViewController: NSViewController{

    var c:ConnectU?
    override func viewDidLoad() {
        c =   ConnectU()
       
    }
    
    @IBAction func start(_ sender: Any) {
         c!.start()
    }
    @IBAction func stop(_ sender: Any) {
        c?.stop()
        c = nil
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

