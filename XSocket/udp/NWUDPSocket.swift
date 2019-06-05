//
//  RAWUDPSocket.swift
//  SFSocket
//
//  Created by 孔祥波 on 29/03/2017.
//  Copyright © 2017 Kong XiangBo. All rights reserved.
//

import Foundation
import Foundation
import NetworkExtension


/// The wrapper for NWUDPSession.
///
/// - note: This class is thread-safe.
var SFUDPSocketID:Int = 0
extension NWUDPSessionState: CustomStringConvertible {
    public var description: String {
        switch self {
            /*! @constant NWUDPSessionStateInvalid The session is in an invalid or uninitialized state. */
        case .invalid: return "invalid"
            
            /*! @constant NWUDPSessionStateWaiting The session is waiting for better conditions before
             *		attempting to make the session ready.
             */
        case .waiting: return "waiting"
            
            /*! @constant NWUDPSessionStatePreparing The endpoint is being resolved */
        case .preparing:return "preparing"
            
            /*! @constant NWUDPSessionStateReady The session is ready for reading and writing data */
        case .ready: return "preparing"
            
            /*! @constant NWUDPSessionStateFailed None of the currently resolved endpoints can be used
             *		at this time, either due to problems with the path or the client rejecting the
             *		endpoints.
             */
        case .failed:return "failed"
            
            /*! @constant NWUDPSessionStateCancelled The session has been cancelled by the client */
        case .cancelled:
            return "cancelled"
        @unknown default:
            return "unknown"
        }
    }
}

//var SFUDPSocketID = 0
open class NWUDPSocket :NSObject,RawSocketProtocol{
    public var sourceIPAddress: IPv4Address?{
        get {
            return nil
        }
    }
    
    public var sourcePort: XPort? {
        get {
            return nil
        }
    }
    
    public var destinationIPAddress: IPv4Address?{
        get {
            return nil
        }
    }
    public var remote: NWHostEndpoint?{
        get {
            return session?.endpoint as? NWHostEndpoint
        }
    }
    
    public var local: NWHostEndpoint?{
        get {
            
            return nil
        }
    }
    
    public var destinationPort: XPort? {
        get {
            return nil
        }
    }
    
   
    
     /**
     Disconnect the socket.
     
     The socket should disconnect elegantly after any queued writing data are successfully sent.
     
     - note: Usually, any concrete implemention should wait until any pending writing data are finished then call `forceDisconnect()`.
     */
    public func disconnect(becauseOf error: Error?) {
        
    }

    /**
     Disconnect the socket immediately.
     
     - note: The socket should disconnect as soon as possible.
     */
    public func forceDisconnect(becauseOf error: Error?){
        
    }

     /**
     Connect to remote host.
     
     - parameter host:        Remote host.
     - parameter port:        Remote port.
     - parameter proxy:       proxy .
     - parameter delegate     callback delegate
     - parameter queue:       callback DispatchQueue
     - parameter enableTLS:   Should TLS be enabled.
     - parameter tlsSettings: The settings of TLS.
     
     - throws: The error occured when connecting to host.
     */
//    public func connectTo(_ host: String, port: Int, proxy: SFProxy, delegate: RawSocketDelegate, queue: DispatchQueue, enableTLS: Bool, tlsSettings: [NSObject : AnyObject]?) throws {
//        
//    }

    

    public weak var delegate: RawSocketDelegate?
    
    var session: NWUDPSession?
    var pendingWriteData: [Data] = []
    //fileprivate var writing = false
    public  var queue: DispatchQueue! = DispatchQueue(label: "NWUDPSocket.queue", attributes: [])
    
    
    /// The `RawSocketDelegate` instance.
    //weak public var delegate: RawSocketDelegate?
    /// The time when the last activity happens.
    ///
    /// Since UDP do not have a "close" semantic, this can be an indicator of timeout.
    open var lastActive: Date = Date()
    
    var cID:Int = 0
    var cIDString:String {
        get {
            
            return "RawUDPSocket-\(cID)"
            //return "[" + objectClassString(self) + "-\(cID)" + "]" //self.classSFName()
        }
    }
    override init() {
        
        cID = SFUDPSocketID
        SFUDPSocketID += 1
        super.init()
        
    }
    /**
     Create a new UDP socket connecting to remote.
     
     - parameter host: The host.
     - parameter port: The port.
     */


    
    /**
     Send data to remote.
     
     - parameter data: The data to send.
     */
    func writeData(_ data: Data) {
        queue.async {
            
            
            self.pendingWriteData.append(data)
            self.checkWrite()
        }
    }
    
    public func disconnect() {
        queue.async {
            self.session!.cancel()
        }
    }
    
    fileprivate func checkWrite() {
        queue.async {
            self.updateActivityTimer()
            
            guard !self.writePending else {
                return
            }
            
            guard self.pendingWriteData.count > 0 else {
                return
            }
            
            self.writePending = true
            self.session!.writeMultipleDatagrams(self.pendingWriteData) {_ in
                
                
                self.writePending = false
                self.checkWrite()
            }
            self.pendingWriteData.removeAll(keepingCapacity: true)
        }
    }
    
    func updateActivityTimer() {
        lastActive = Date()
    }
    
    //MARK: -
    // list
    
    /// If the socket is connected.
    public var isConnected: Bool = false
    
    public var writePending:Bool  = false
    public var readPending:Bool  = false
    /// The source address.
//    public var sourceIPAddress: IPv4Address?
//    
//    /// The source port.
//    public var sourcePort: Port?
//    
//    /// The destination address.
//    public var destinationIPAddress: IPv4Address?
//    
//    /// The destination port.
//    public var destinationPort: Port?
    
    /// cell or wifi
    public var useCell:Bool{
        get {
            return true
        }
    }
    public var tcp:Bool {
        get {
            return false
        }
    }
    /**
     Connect to remote host.
     
     - parameter host:        Remote host.
     - parameter port:        Remote port.
     - parameter enableTLS:   Should TLS be enabled.
     - parameter tlsSettings: The settings of TLS.
     
     - throws: The error occured when connecting to host.
     */
    public func connectTo(_ host: String, port: UInt16, enableTLS: Bool, tlsSettings: [NSObject : AnyObject]?) throws{
        guard let udpsession = RawSocketFactory.TunnelProvider?.createUDPSession(to: NWHostEndpoint(hostname: host, port: "\(port)"), from: nil) else {
            return
        }
        
        session = udpsession
        session!.addObserver(self, forKeyPath: "state", options: [.initial, .new], context: nil)
        session!.setReadHandler({ [ weak self ] dataArray, error in
            guard let sSelf = self else {
                return
            }
            
            sSelf.updateActivityTimer()
            
            guard error == nil else {
                Xsocket.log("Error when reading from remote server. \(String(describing: error))",level: .Error)
                return
            }
            
            for data in dataArray! {
                sSelf.delegate?.didReadData(data, withTag: 0, from: sSelf)
            }
            }, maxDatagrams: 32)
    }
    
    
    
    /**
     Disconnect the socket immediately.
     
     - note: The socket should disconnect as soon as possible.
     */
    public func forceDisconnect(){
        queueCall {[weak self] in
            if let strong = self {
                strong.cancel()
            }
            
        }
    }
    /**
     Disconnect the socket immediately with sessionID.
     
     - note: The socket should disconnect as soon as possible.
     */
    public func forceDisconnect(_ sessionID:UInt32){
        // Remote server need close event?
        //MARK: -- tod close channel
        //only for kcptun
        queueCall {[weak self] in
            if let strong = self {
                strong.cancel()
            }
            
        }
    }
    /**
     Send data to remote.
     
     - parameter data: Data to send.
     - parameter tag:  The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last write is finished, i.e., `delegate?.didWriteData()` is called.
     */
    public  func writeData(_ data: Data, withTag: Int){
        self.writeData(data)
    }
    
    /**
     Read data from the socket.
     
     - parameter tag: The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    public func readDataWithTag(_ tag: Int){
        fatalError("\(#file),\(#function), \(#line) and  \(#column)")
    }
    
    /**
     Read specific length of data from the socket.
     
     - parameter length: The length of the data to read.
     - parameter tag:    The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    public func readDataToLength(_ length: Int, withTag tag: Int) {
        fatalError("\(#file),\(#function), \(#line) and  \(#column)")
    }
    
    /**
     Read data until a specific pattern (including the pattern).
     
     - parameter data: The pattern.
     - parameter tag:  The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    public func readDataToData(_ data: Data, withTag tag: Int) {
        fatalError("\(#file),\(#function), \(#line) and  \(#column)")
    }
    
    /**
     Read data until a specific pattern (including the pattern).
     
     - parameter data: The pattern.
     - parameter tag:  The tag identifying the data in the callback delegate method.
     - parameter maxLength: The max length of data to scan for the pattern.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    public func readDataToData(_ data: Data, withTag tag: Int, maxLength: Int){
        fatalError("\(#file),\(#function), \(#line) and  \(#column)")
    }
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard keyPath == "state" else {
            return
        }
        //crash
        //        if let  e = connection.error {
        //            SKit.log("\(cIDString) error:\(e.localizedDescription)", level: .Error)
        //        }
        
        if object ==  nil  {
            Xsocket.log("\(cIDString) error:connection error", level: .Error)
            //return
        }
        
        //guard let connection = object as! NWTCPConnection else {return}
        //crash
        guard  let connection = session else {return}
        
        switch connection.state {
        case .ready:
            queueCall {[weak self] in
                if let strong = self {
                    strong.socketConnectd()
                }
                
            }
        case .failed:
            
            queueCall {[weak self] in
                if let strong = self {
                    strong.cancel()
                }
                
            }
        case .cancelled:
            queueCall {
                if let delegate = self.delegate{
                    delegate.didDisconnect(self, error: nil)
                }
                
                //self.delegate = nil
            }
        default:
            break
            //        case .Connecting:
            //            stateString = "Connecting"
            //        case .Waiting:
            //            stateString =  "Waiting"
            //        case .Invalid:
            //            stateString = "Invalid"
            
        }
        //        if let  x = connection.endpoint as! NWHostEndpoint {
        //
        //        }
        Xsocket.log("\(cIDString) state: \(connection.state.description)", level: .Debug)
    }
    func cancel() {
        if let s = session  {
            s.cancel()
        }
        
    }
    public func socketConnectd(){
        if let d = self.delegate {
            d.didConnect(self)
        }
        
    }
    public func queueCall( block: @escaping  ()->()) {
        //dispatch_async(queue, block)
        queue.async(execute: block)
    }
    //MARK:-
}
