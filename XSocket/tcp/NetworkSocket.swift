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
    var delegate: RawSocketDelegate?
    
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
            if connection != nil {
                //connection.
            }
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
            if connection != nil {
                switch connection.endpoint {
                case .hostPort(.ipv4(let host), let port):
                    return IPv4Address.init(fromString: "")
                default:
                    break
                }
              
            }
            return nil
        }
    }
    
    var destinationPort: XPort?{
        get  {
            if connection != nil {
                switch connection.endpoint {
                case .hostPort(.ipv4(_), let port):
                    return XPort.init(port: port.rawValue)
                case .hostPort(.ipv6(_), let port):
                    return XPort.init(port: port.rawValue)
                default:
                    break
                }
            }
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
        
        //var para:NWParameters
        if enableTLS  {
            //para = NWParameters.init(tls: NWProtocolTLS.Options.init(), tcp: <#T##NWProtocolTCP.Options#>)
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
                Xsocket.log(error.debugDescription, items: self.connection!.debugDescription, level: .Debug)
            case .failed(let error):
            // Handle fatal connection error
                Xsocket.log(error.debugDescription, items: self.connection!.debugDescription, level: .Debug)
                self.disconnect(becauseOf: error)
            case .cancelled:
                Xsocket.log(self.connection.debugDescription , items: "cancel", level: .Debug)
            default:
                break
            }
        }
        self.lastActive = Date()
        connection.start(queue: queue)
        
    }
    
    func disconnect(becauseOf error: Error?) {
        if let d = self.delegate {
            d.disconnect(becauseOf: error)
        }
    }
    
    func forceDisconnect(becauseOf error: Error?) {
        
    }
    
    func writeData(_ data: Data, withTag: Int) {
        connection.send(content: data, completion: .contentProcessed({[weak self] (sendError) in
            guard let self = self else {return}
            guard let delegate = self.delegate else {return}
            if let sendError = sendError {
                // Handle error in sending
                Xsocket.log(sendError.debugDescription, items: self.connection!.debugDescription, level: .Debug)
                 delegate.didDisconnect(self, error: error)
            }else {
                self.lastActive = Date()
                delegate.didWriteData(data, withTag: withTag, from: self)
            }
        }))
    }
    
    func readDataWithTag(_ tag: Int) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) {[weak self]  (data, ctx, yOrn, error) in
            guard let self = self else {return}
            guard let delegate = self.delegate else {return}
            if let error = error {
                // Handle error in reading
                delegate.didDisconnect(self, error: error)
            } else {
                // Parse out body length
                self.lastActive = Date()
                if let d = data {
                    delegate.didReadData(d, withTag: tag, from: self)
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
        if connection != nil {
            connection.cancel()
        }
        print("NetworkSocket deinit")
         Xsocket.log("NetworkSocket deinit ", level: .Trace)
    }
    
}
