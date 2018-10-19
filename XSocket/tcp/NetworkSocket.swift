//
//  NetworkSocket.swift
//  XSocket
//
//  Created by yarshure on 10/12/18.
//  Copyright © 2018 yarshure. All rights reserved.
//

import Foundation
import Network
import NetworkExtension
class NetworkSocket: RawSocketProtocol {
    var delegate: RawSocketDelegate?
    
    func forceDisconnect(_ sessionID: UInt32) {
        
    }
    
    var queue: DispatchQueue!
    
    var isConnected: Bool = false
    
    var writePending: Bool = false
    
    var readPending: Bool = false
    
    var sourceIPAddress: IPv4Address?
    
    var lastActive: Date = Date()
    
    var sourcePort: XPort?
    
    var remote: NWHostEndpoint?
    
    var local: NWHostEndpoint?
    
    var destinationIPAddress: IPv4Address?
    
    var destinationPort: XPort?
    
    var useCell: Bool = false
    
    var tcp: Bool = true
    
    init() {
        
    }
    func connectTo(_ host: String, port: UInt16, enableTLS: Bool, tlsSettings: [NSObject : AnyObject]?) throws {
        
    }
    
    func disconnect(becauseOf error: Error?) {
        
    }
    
    func forceDisconnect(becauseOf error: Error?) {
        
    }
    
    func writeData(_ data: Data, withTag: Int) {
        
    }
    
    func readDataWithTag(_ tag: Int) {
        
    }
    
    func readDataToLength(_ length: Int, withTag tag: Int) {
        
    }
    
    func readDataToData(_ data: Data, withTag tag: Int) {
        
    }
    
    func readDataToData(_ data: Data, withTag tag: Int, maxLength: Int) {
        
    }
    
    
}
