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
@available(iOSApplicationExtension 12.0, macOS 10.14 ,*)
class NetworkSocket: RawSocketProtocol {
    weak var delegate: RawSocketDelegate?
    
    func forceDisconnect(_ sessionID: UInt32) {
        if connection != nil {
            connection.cancel()
        }
    }
    var connection:NWConnection!
    var queue: DispatchQueue!
    
    var isConnected: Bool = false
    
    var writePending: Bool = false
    
    var readPending: Bool = false
    
    var sourceIPAddress: IPv4Address? {
        get  {
            return nil
        }
    }
    
    var lastActive: Date = Date()
    
    var sourcePort: XPort?{
        get  {
            return nil
        }
    }
    
    var remote: NWHostEndpoint?{
        get  {
            return nil
        }
    }
    
    var local: NWHostEndpoint?{
        get  {
            return nil
        }
    }
    
    var destinationIPAddress: IPv4Address?{
        get  {
            return nil
        }
    }
    
    var destinationPort: XPort?{
        get  {
            return nil
        }
    }
    
    var useCell: Bool = false
    
    var tcp: Bool = true
    
    init() {
        
    }
    func connectTo(_ host: String, port: UInt16, enableTLS: Bool, tlsSettings: [NSObject : AnyObject]?) throws {
        let p =  NWEndpoint.Port.init(rawValue: port)
        let h = NWEndpoint.Host.init(host)
        if enableTLS  {
            let tlsParameters = NWTLSParameters()
            if let tlsSettings = tlsSettings as? [String: AnyObject] {
                tlsParameters.setValuesForKeys(tlsSettings)
            }
           
            let c =  NWConnection.init(host:  h  , port: p!, using: .tls)
            self.connection = c
        }else {
            let c =  NWConnection.init(host:  h  , port: p!, using: .tcp)
             self.connection = c 
        }
        connection.stateUpdateHandler = { (newState) in
            switch newState {
            case .ready:
            // Handle connection established
                print("")
                self.delegate!.didConnect(self)
            case .waiting(let error):
            // Handle connection waiting for network
                print(error)
            case .failed(let error):
            // Handle fatal connection error
                print(error)
            case .cancelled:
                print("cancle")
            default:
                break
            }
        }
    
        connection.start(queue: queue)
        
    }
    
    func disconnect(becauseOf error: Error?) {
        
    }
    
    func forceDisconnect(becauseOf error: Error?) {
        
    }
    
    func writeData(_ data: Data, withTag: Int) {
        connection.send(content: data, completion: .contentProcessed({ (sendError) in
            if let sendError = sendError {
                // Handle error in sending
                print(sendError)
            }else {
                self.delegate!.didWriteData(data, withTag: withTag, from: self)
            }
        }))
    }
    
    func readDataWithTag(_ tag: Int) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) { (data, ctx, yOrn, error) in
            if let error = error {
                // Handle error in reading
                self.delegate!.didDisconnect(self, error: error)
            } else {
                // Parse out body length
                if let d = data {
                    self.delegate!.didReadData(d, withTag: tag, from: self)
                }
                
            }
            
        }
    }
    
    func readDataToLength(_ length: Int, withTag tag: Int) {
        
    }
    
    func readDataToData(_ data: Data, withTag tag: Int) {
        
    }
    
    func readDataToData(_ data: Data, withTag tag: Int, maxLength: Int) {
        
    }
    deinit {
        
    }
    
}
