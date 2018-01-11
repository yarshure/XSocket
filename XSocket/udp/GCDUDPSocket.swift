//
//  GCDUDPSocket.swift
//  XSocket
//
//  Created by yarshure on 2018/1/6.
//  Copyright © 2018年 yarshure. All rights reserved.
//

import Foundation
import NetworkExtension
import CocoaAsyncSocket
class GCDUDPSocket:NSObject, RawSocketProtocol {
    var lastActive: Date = Date()
    
    
    var delegate: RawSocketDelegate?
    
    var socket:GCDAsyncUdpSocket?
    func forceDisconnect(_ sessionID: UInt32) {
        self.socket?.closeAfterSending()
    }
    
    var queue: DispatchQueue!
    
    var isConnected: Bool = false
    
    var writePending: Bool = false
    
    var readPending: Bool = false
    
    var sourceIPAddress: IPv4Address?
    
    var sourcePort: XPort?
    
    var remote: NWHostEndpoint?
    
    var local: NWHostEndpoint?
    
    var destinationIPAddress: IPv4Address?
    
    var destinationPort: XPort?
    
    var useCell: Bool = false
    
    var tcp: Bool = false
    
    func connectTo(_ host: String, port: UInt16, enableTLS: Bool, tlsSettings: [NSObject : AnyObject]?) throws {
        socket = GCDAsyncUdpSocket.init(delegate: self, delegateQueue: self.queue)
        try socket?.connect(toHost: host, onPort: port)
    }
    
    func disconnect(becauseOf error: Error?) {
        self.socket?.closeAfterSending()
       
    }
    
    func forceDisconnect(becauseOf error: Error?) {
        self.socket?.closeAfterSending()
    }
    
    func writeData(_ data: Data, withTag: Int) {
        self.socket?.send(data, withTimeout: 3, tag: withTag)
    }
    
    func readDataWithTag(_ tag: Int) {
        if readPending {
            return
        }
        do {
            try socket?.beginReceiving()
        }catch let e{
            self.delegate?.didDisconnect(self, error: e)
        }
        readPending = true
    }
    
    func readDataToLength(_ length: Int, withTag tag: Int) {
         fatalError("\(#file),\(#function), \(#line) and  \(#column)")
    }
    
    func readDataToData(_ data: Data, withTag tag: Int) {
         fatalError("\(#file),\(#function), \(#line) and  \(#column)")
    }
    
    func readDataToData(_ data: Data, withTag tag: Int, maxLength: Int) {
        fatalError("\(#file),\(#function), \(#line) and  \(#column)")
    }
    
    
}
extension GCDUDPSocket:GCDAsyncUdpSocketDelegate {
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        self.delegate?.didDisconnect(self, error: error)
    }
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        self.delegate?.didWriteData(nil, withTag: tag, from: self)
    }
    public func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        self.delegate?.didDisconnect(self, error: error)
    }
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        self.delegate?.didWriteData(Data(), withTag: tag, from: self)
    }
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        do {
             try sock.beginReceiving()
        }catch let e {
            Xsocket.log("recv error: " + e.localizedDescription, items: "", level: .Error)
            self.delegate?.didDisconnect(self, error: e)
            return
        }
       Xsocket.log("UDP connected \(address as NSData)" , items: "", level: .Error)
        self.delegate?.didConnect(self)
    }
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        self.delegate?.didReadData(data, withTag: 0, from: self)
    }
    

}
