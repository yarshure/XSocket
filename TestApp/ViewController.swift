//
//  ViewController.swift
//  TestApp
//
//  Created by yarshure on 2018/10/26.
//  Copyright © 2018 yarshure. All rights reserved.
//

import Cocoa
import XSocket
class ViewController: NSViewController ,RawSocketDelegate{
    func didDisconnect(_ socket: RawSocketProtocol, error: Error?) {
         print("didDisconnect ", socket,error as Any)
    }
    
    func didReadData(_ data: Data, withTag: Int, from: RawSocketProtocol) {
        print("didReadData ", withTag)
        print(data as NSData)
        readIndex += 1
        socket!.readDataWithTag(readIndex)
        
    }
    
    func didWriteData(_ data: Data?, withTag: Int, from: RawSocketProtocol) {
        print("didWrite ", withTag)
        self.write()
    }
    
    func didConnect(_ socket: RawSocketProtocol) {
        print(socket,"connected")
        
        self.write()
    }
    func write() {
        let d = "hello world " + String(self.lineIndex) + "\n"
        socket!.writeData(d.data(using: .utf8)!, withTag: lineIndex)
        lineIndex += 1
    }
    func disconnect(becauseOf error: Error?) {
        socket?.delegate = nil
        self.socket = nil
        print("didDisconnect ",error as Any)
    }
    
    func forceDisconnect(becauseOf error: Error?) {
        print("didDisconnect ",error as Any)
    }
    var readIndex:Int = 0
    var lineIndex:Int = 0
    var socket:RawSocketProtocol?
    override func viewDidLoad() {
        socket = RawSocketFactory.getRawSocket()
        Xsocket.debugEnable = true
        socket!.queue = DispatchQueue.main
        socket!.delegate = self
        super.viewDidLoad()
        do {
            try socket!.connectTo("127.0.0.1", port: 12345, enableTLS: false, tlsSettings: [:])
        }catch let e {
            print(e)
        }
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

