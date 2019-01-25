import Foundation
import NetworkExtension

import AxLogger
var NWTCPSocketID:Int = 0
//import CocoaLumberjackSwift
var SFTCPSocketID:Int = 0
/// The TCP socket build upon `NWTCPConnection`.
///
/// - warning: This class is not thread-safe, it is expected that the instance is accessed on the `queue` only.
/// Make NEVPNStatus convertible to a string
extension NWTCPConnectionState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .cancelled: return "Cancelled"
        case .connected: return "Connected"
        case .connecting: return "Connecting"
        case .disconnected: return "Disconnected"
        case .invalid: return "Invalid"
        case .waiting: return "Waiting"
        @unknown default:
            return "unknown"
        }
    }
}

#if os(iOS)
let acceptableCipherSuites:Set<NSNumber> = [
    
    NSNumber(value: TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256),
    NSNumber(value: TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA),
    NSNumber(value: TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256),
    NSNumber(value: TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA),
    NSNumber(value: TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA),
    NSNumber(value: TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256),
    NSNumber(value: TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA),
    NSNumber(value: TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384),
    NSNumber(value: TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384),
    NSNumber(value: TLS_RSA_WITH_AES_256_GCM_SHA384),
    NSNumber(value: TLS_DHE_RSA_WITH_AES_256_GCM_SHA384),
    NSNumber(value: TLS_DH_RSA_WITH_AES_256_GCM_SHA384)
    
    
    
    
    //    public var TLS_RSA_WITH_AES_256_GCM_SHA384: SSLCipherSuite { get }
    //    public var TLS_DHE_RSA_WITH_AES_128_GCM_SHA256: SSLCipherSuite { get }
    //    public var TLS_DHE_RSA_WITH_AES_256_GCM_SHA384: SSLCipherSuite { get }
    //    public var TLS_DH_RSA_WITH_AES_128_GCM_SHA256: SSLCipherSuite { get }
    //    public var TLS_DH_RSA_WITH_AES_256_GCM_SHA384: SSLCipherSuite { get }
    
    
]
#else
let acceptableCipherSuites:Set<NSNumber> = [
    NSNumber(value: TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256),
    NSNumber(value: TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA),
    NSNumber(value: TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256),
    NSNumber(value: TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA),
    NSNumber(value: TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA),
    NSNumber(value: TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256),
    NSNumber(value: TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA)
    
]
#endif

//_ = NWHostEndpoint(hostname: host, port: "\(port)")
//let tlsParameters = NWTLSParameters()
//if let tlsSettings = tlsSettings as? [String: AnyObject] {
//    tlsParameters.setValuesForKeys(tlsSettings)
//}else {
//    tlsParameters.sslCipherSuites = acceptableCipherSuites
//
//}
//let v = SSLProtocol.tlsProtocol12
//tlsParameters.minimumSSLProtocolVersion = Int(v.rawValue)
//@nonobjc public func shouldEvaluateTrustForConnection(connection: NWTCPConnection) -> Bool{
//    return true
//}
//
//@nonobjc public func evaluateTrustForConnection(connection: NWTCPConnection, peerCertificateChain: [AnyObject], completionHandler completion: @escaping (SecTrust) -> Void){
//    
//    let myPolicy = SecPolicyCreateSSL(true, nil)//proxy.serverAddress
//    
//    var possibleTrust: SecTrust?
//    
//    let x = SecTrustCreateWithCertificates(peerCertificateChain.first!, myPolicy,
//                                           &possibleTrust)
//    guard let remoteAddress = connection.remoteAddress as? NWHostEndpoint else {
//        completion(possibleTrust!)
//        return
//    }
//    Xcon.log("debug :\(remoteAddress.hostname)", level: .Debug)
//    if x != 0 {
//        Xcon.log("debug :\(remoteAddress.hostname) \(x)", level: .Debug)
//    }
//    if let trust = possibleTrust {
//        //let's do test by ourself first
//        
//        var trustResult : SecTrustResultType = .invalid
//        let r = SecTrustEvaluate(trust, &trustResult)
//        if r != 0{
//            Xcon.log("debug :\(remoteAddress.hostname) error code:\(r)", level: .Debug)
//        }
//        if trustResult == .proceed {
//            Xcon.log("debug :\(remoteAddress.hostname) Proceed", level: .Debug)
//        }else {
//            Xcon.log("debug :\(remoteAddress.hostname) Proceed error", level: .Debug)
//        }
//        //print(trustResult)  // the result is 5, is it
//        //kSecTrustResultRecoverableTrustFailure?
//        
//        completion(trust)
//    }else {
//        Xcon.log("debug :\(remoteAddress.hostname) error", level: .Debug)
//    }
//}


open  class NWTCPSocket: NSObject, RawSocketProtocol {
    var tlsEvaluate:Bool = false
    public var lastActive: Date = Date()
    
    /**
     Disconnect the socket immediately.
     
     - note: The socket should disconnect as soon as possible.
     */
    public func forceDisconnect(becauseOf error: Error?) {
        
    }

     /**
     Disconnect the socket.
     
     The socket should disconnect elegantly after any queued writing data are successfully sent.
     
     - note: Usually, any concrete implemention should wait until any pending writing data are finished then call `forceDisconnect()`.
     */
    public func disconnect(becauseOf error: Error?) {
        
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
    public var remote: NWHostEndpoint?{
        get {
            return connection?.remoteAddress as? NWHostEndpoint
        }
    }
    
    public var local: NWHostEndpoint?{
        get {
            
            return connection?.localAddress as? NWHostEndpoint
        }
    }
    public  var connection: NWTCPConnection?
    public var writePending = false
    public var readPending = false
    private var closeAfterWriting = false
    
    public func forceDisconnect(_ sessionID: UInt32) {
        self.forceDisconnect()
    }

    static let ScannerReadTag = 10000
    
    private var scanner: StreamScanner!
    private var scannerTag: Int!
    private var readDataPrefix: Data?
    
    public var tcp: Bool{
        get {
            return true
        }
    }
    // MARK: RawSocketProtocol implemention

    /// The `RawSocketDelegate` instance.
    weak public var delegate: RawSocketDelegate?
    
    /// Every method call and variable access must operated on this queue. And all delegate methods will be called on this queue.
    ///
    /// - warning: This should be set as soon as the instance is initialized.
    public var queue: DispatchQueue!
    //don't need
    //public var socketQueue:dispatch_queue_t!
    /// If the socket is connected.
    public var isConnected: Bool {
        return connection != nil && connection!.state == .connected
    }

    open func start(){
        
    }
    public var  readBufferSize:Int{
        return   Opt.MAXNWTCPSocketReadDataSize
    }
    open var cID:Int = 0
    open var cIDString:String {
        get {
            
            return "RawTCPSocket-\(cID)"
            //return "[" + objectClassString(self) + "-\(cID)" + "]" //self.classSFName()
        }
    }
    public  override init() {
        
        cID = SFTCPSocketID
        SFTCPSocketID += 1
        super.init()
        
    }
    

    /// The source address.
    ///
    /// - note: Always returns `nil`.
    public var sourceIPAddress: IPv4Address? {
        guard let connection = connection else {return  nil}
        if let x = connection.localAddress {
            let addr = x as! NWHostEndpoint
            let host = addr.hostname.components(separatedBy: ":")
            if let ipv4 = IPv4Address.init(fromString: host.first!){
                return ipv4
            }
        }
        
        
        return nil
    }

    /// The source port.
    ///
    /// - note: Always returns `nil`.
    public var sourcePort: XPort? {
        return nil
    }

    public var useCell:Bool {
        get {
            if let path = connection!.connectedPath{
                return path.isExpensive
            }
            return false
        }
        
    }
    /// The destination address.
    ///
    /// - note: Always returns `nil`.
    public var destinationIPAddress: IPv4Address? {
        if  let x = connection!.remoteAddress {
            let addr = x as! NWHostEndpoint
            let host = addr.hostname.components(separatedBy: ":")
            if let ipv4 = IPv4Address.init(fromString: host.first!){
                return ipv4
            }
        }
        
        return nil
    }

    /// The destination port.
    ///
    /// - note: Always returns `nil`.
    public var destinationPort: XPort? {
        return nil
    }

    /**
     Connect to remote host.

     - parameter host:        Remote host.
     - parameter port:        Remote port.
     - parameter enableTLS:   Should TLS be enabled.
     - parameter tlsSettings: The settings of TLS.

     - throws: Never throws.
     */
    open  func connectTo(_ host: String, port: UInt16, enableTLS: Bool, tlsSettings: [NSObject : AnyObject]?) throws {
        let endpoint = NWHostEndpoint(hostname: host, port: "\(port)")
        if enableTLS {
            let tlsParameters = NWTLSParameters()
            if let tlsSettings = tlsSettings as? [String: AnyObject] {
                tlsParameters.setValuesForKeys(tlsSettings)
            }
            guard let c = RawSocketFactory.TunnelProvider?.createTCPConnection(to: endpoint, enableTLS: enableTLS, tlsParameters: tlsParameters, delegate: nil) else {
                
                return
            }
           
            connection = c
        }else {
            guard let c = RawSocketFactory.TunnelProvider?.createTCPConnection(to: endpoint, enableTLS: enableTLS, tlsParameters: nil, delegate: nil) else {
      
                return
            }
            
            connection = c

        }
        
        if let e = connection!.error {
           Xsocket.log("\(cIDString) \(e.localizedDescription) \(host):\(port)", level: .Debug)
           // throw e

            connection!.addObserver(self, forKeyPath: "state", options: [.initial, .new], context: nil)
        }else {
            connection!.addObserver(self, forKeyPath: "state", options: [.initial, .new], context: nil)
        }
       
    }

    /**
     Disconnect the socket.

     The socket will disconnect elegantly after any queued writing data are successfully sent.
     */
    public func disconnect() {
        if connection!.state == .cancelled {
            delegate?.didDisconnect(self, error: nil)
        } else {
            closeAfterWriting = true
            checkStatus()
        }
    }

    /**
     Disconnect the socket immediately.
     */
    public func forceDisconnect() {
        if connection!.state == .cancelled {
            delegate?.didDisconnect(self, error: nil)
        } else {
            cancel()
        }
    }

    /**
     Send data to remote.

     - parameter data: Data to send.
     - parameter tag:  The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last write is finished, i.e., `delegate?.didWriteData()` is called.
     */
    open func writeData(_ data: Data, withTag tag: Int) {
        sendData(data: data, withTag: tag)
    }

    /**
     Read data from the socket.

     - parameter tag: The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     - fix c.localAddress nil crash 
     */
    public func readDataWithTag(_ tag: Int) {
        if readPending {
            
            guard  let c = connection else {return }
            if let a = c.localAddress {
                let addr = a as! NWHostEndpoint
                Xsocket.log("\(cIDString)  readPending",items:addr, level: .Debug)
            }
            
                
            
            
            return
        }
        readPending = true
        if isConnected == false {
            Xsocket.log("\(cIDString) not connected ", level: .Debug)
            return
        }
        
       // dispatch_async(socketQueue) {[weak self] in
       //     if let strong = self {
                self.connection!.readMinimumLength(0, maximumLength: readBufferSize) { [weak self] data, error in
                    guard let  strong = self else {return}
                    strong.readPending = false
                    guard error == nil else {
                        if let s = self , let c = s.connection, c.state != .connected {
                            Xsocket.log("\(self!.cIDString) NWTCPSocket got an error when reading data: \(error!.localizedDescription) state:\(c.state.description) ",level: .Error)
                            s.disconnect()
                        }
                        
                        return
                    }
                    
                    strong.readCallback(data: data, tag: tag)
                }
           // }
           
        //}
       
    }

    /**
     Read specific length of data from the socket.

     - parameter length: The length of the data to read.
     - parameter tag:    The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    public func readDataToLength(_ length: Int, withTag tag: Int) {
        if isConnected {
            connection!.readLength(length) { data, error in
                guard error == nil else {
                    //DDLogError("NWTCPSocket got an error when reading data: \(error)")
                    return
                }
                
                self.readCallback(data: data, tag: tag)
            }
        }
        
    }

    /**
     Read data until a specific pattern (including the pattern).

     - parameter data: The pattern.
     - parameter tag:  The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    public func readDataToData(_ data: Data, withTag tag: Int) {
        readDataToData(data, withTag: tag, maxLength: 0)
    }

    // Actually, this method is available as `- (void)readToPattern:(id)arg1 maximumLength:(unsigned int)arg2 completionHandler:(id /* block */)arg3;`
    // which is sadly not available in public header for some reason I don't know.
    // I don't want to do it myself since This method is not trival to implement and I don't like reinventing the wheel.
    // Here is only the most naive version, which may not be the optimal if using with large data blocks.
    /**
     Read data until a specific pattern (including the pattern).

     - parameter data: The pattern.
     - parameter tag:  The tag identifying the data in the callback delegate method.
     - parameter maxLength: The max length of data to scan for the pattern.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    public func readDataToData(_ data: Data, withTag tag: Int, maxLength: Int) {
        var maxLength = maxLength
        if maxLength == 0 {
            maxLength = Opt.MAXNWTCPScanLength
        }
        scanner = StreamScanner(pattern: data, maximumLength: maxLength)
        scannerTag = tag
        readDataWithTag(NWTCPSocket.ScannerReadTag)
    }

    public func queueCall( block: @escaping  ()->()) {
        //dispatch_async(queue, block)
        queue.async(execute: block)
    }

    open func socketConnectd(){
        if let d = self.delegate {
            d.didConnect(self)
        }
        
    }
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard keyPath == "state" else {
            return
        }
        //crash
//        if let  e = connection.error {
//            Xsocket.log("\(cIDString) error:\(e.localizedDescription)", level: .Error)
//        }

        if object ==  nil  {
            Xsocket.log("\(cIDString) error:connection error", level: .Error)
            //return
        }
        
        //guard let connection = object as! NWTCPConnection else {return}
        //crash 
        guard let connection = connection else {return}
        if let error = connection.error {
            Xsocket.log("Socket-\(cIDString) Error: \(error.localizedDescription)", level: .Debug)
        }
        switch connection.state {
        case .connected:
            queueCall {[weak self] in
                if let strong = self {
                    strong.socketConnectd()
                }
                
            }
        case .disconnected:
           
            queueCall {[weak self] in
                if let strong = self {
                    strong.cancel()
                }
                
            }
        case .cancelled:
            if let delegate = self.delegate{
                queueCall { [weak self]  in
                    
                    delegate.didDisconnect(self!, error: nil)
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
        Xsocket.log("\(cIDString) state:",items:connection.state.description, level: .Debug)
    }

    open func readCallback(data: Data?, tag: Int) {
        guard let data = data else {
            Xsocket.log("\(cIDString) read nil", level: .Debug)
            return
        }
//        guard !cancelled else {
//            return
//        }
        queueCall { [weak self] in
            
            
            if let strong = self {
                if let delegate = strong.delegate{
                    autoreleasepool {
                        delegate.didReadData( data, withTag: tag, from: strong)
                    }
                    
                }else {
                    Xsocket.log("delegate nil", level: .Error)
                }
                
            }else {
                Xsocket.log("NWTCPSocket  nil", level: .Error)
            }
            
        }
    }

    open  func sendData(data: Data, withTag tag: Int) {
        if writePending {
            Xsocket.log("Socket-\(cID)  writePending error", level: .Debug)
            return
        }
        writePending = true
        if isConnected {
            self.connection!.write(data) { [weak self] error in
                guard let strong = self else { return }
                strong.writePending = false
                
                guard error == nil else {
                    //DDLogError("NWTCPSocket got an error when writing data: \(error)")
                    strong.disconnect()
                    return
                }
                
                strong.queueCall { autoreleasepool {
                    strong.delegate?.didWriteData(data, withTag: tag, from: strong)
                }}
                strong.checkStatus()
            }

        }else {
            Xsocket.log("\(cIDString) not connected", level: .Error)
        }
        //dispatch_async(socketQueue) {[weak self] in
         //   if let strong = self {
                           // }
            

        //}
        
    }

    private func consumeReadData(data: Data?) -> Data? {
        defer {
            readDataPrefix = nil
        }

        if readDataPrefix == nil {
            return data
        }

        if data == nil {
            return readDataPrefix
        }

        var wholeData = Data()
        wholeData.append(readDataPrefix!)
        wholeData.append(data!)
        return wholeData
    }

   open  func cancel() {
        if connection != nil {
            connection!.cancel()
        }
        
    }

    public func checkStatus() {
        if closeAfterWriting && !writePending {
            Xsocket.log("Socket-\(cID) cancle", level: .Debug)
            cancel()
        }
    }

    deinit {
        delegate = nil
        if connection != nil {
            Xsocket.log("\(cIDString) .", level: .Debug)
            connection!.removeObserver(self, forKeyPath: "state")
            if connection!.state != .cancelled  {
                connection!.cancel()
            }
            //connection.writeClose()
            Xsocket.log("\(cIDString) deiniting state:\(connection!.state.description)", level: .Debug)
            
            connection = nil

        }
        Xsocket.log("Socket-\(cID) clean", level: .Info)
        queue = nil
        //socketQueue = nil
    }
 
}
