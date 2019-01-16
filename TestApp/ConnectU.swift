//
//  ConnectU.swift
//  TestApp
//
//  Created by yarshure on 28/10/2018.
//  Copyright © 2018 yarshure. All rights reserved.
//
//UDP Test
import Foundation
import XSocket
class ConnectU:RawSocketDelegate {
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
        guard let socket = socket else {return}
        socket.writeData(d.data(using: .utf8)!, withTag: lineIndex)
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
    
    func start() {
        socket = RawSocketFactory.getRawSocket(type: nil, tcp: false)
        Xsocket.debugEnable = true
        socket!.queue = DispatchQueue.main
        socket!.delegate = self
        
        do {
            try socket!.connectTo("127.0.0.1", port: 12345, enableTLS: false, tlsSettings: [:])
        }catch let e {
            print(e)
        }
        
        // Do any additional setup after loading the view.
    }
    func stop(){
        if let s = socket {
            s.forceDisconnect(0)
        }
        socket?.delegate  = nil
        socket = nil
    }
    deinit {
        print("deinit")
    }
}
