import Foundation
import CocoaAsyncSocket
import NetworkExtension
/// The TCP socket build upon `GCDAsyncSocket`.
///
/// - warning: This class is not thread-safe, it is expected that the instance is accessed on the `queue` only.
open class GCDTCPSocket: NSObject, GCDAsyncSocketDelegate, RawSocketProtocol {
    public var lastActive: Date = Date()
    
    public var remote: NWHostEndpoint?{
        get {
           
            let p = socket.connectedPort
            if  let h = socket.connectedHost {
                 return NWHostEndpoint.init(hostname: h, port: String(p))
            }
            return nil
        }
    }
    
    public var local: NWHostEndpoint?{
        get {
            
            let p = socket.localPort
            if let  h = socket.localHost {
                return NWHostEndpoint.init(hostname: h, port: String(p))
            }
            return nil
        }
    }
    
     /**
     Disconnect the socket immediately.
     
     - note: The socket should disconnect as soon as possible.
     */
    public func forceDisconnect(becauseOf error: Error?) {
        socket.disconnectAfterWriting()
    }

     /**
     Disconnect the socket.
     
     The socket should disconnect elegantly after any queued writing data are successfully sent.
     
     - note: Usually, any concrete implemention should wait until any pending writing data are finished then call `forceDisconnect()`.
     */
    public func disconnect(becauseOf error: Error?) {
        socket.disconnect()
    }

    public /**
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
    static func connectTo(_ host: String, port: UInt16, delegate: RawSocketDelegate, queue: DispatchQueue, enableTLS: Bool, tlsSettings: [NSObject : AnyObject]?) throws ->RawSocketProtocol {
        fatalError()
    }

    public func forceDisconnect(_ sessionID: UInt32) {
        self.forceDisconnect()
    }

    public var writePending: Bool = false
    public var readPending: Bool = false
    /// cell or wifi 
    public var useCell: Bool {
        get {
            return false
        }
    }
    public var tcp:Bool {
        return true
    }
    /**
     Connect to remote host.
     
     - parameter host:        Remote host.
     - parameter port:        Remote port.
     - parameter enableTLS:   Should TLS be enabled.
     - parameter tlsSettings: The settings of TLS.
     
     - throws: The error occured when connecting to host.
     */
    

    fileprivate let socket: GCDAsyncSocket
    fileprivate var enableTLS: Bool = false
    
    /**
     Initailize an instance with `GCDAsyncSocket`.
     
     - parameter socket: The socket object to work with. If this is `nil`, then a new `GCDAsyncSocket` instance is created.
     */
    public init(socket: GCDAsyncSocket? = nil) {
        if let socket = socket {
            self.socket = socket
        } else {
            self.socket = GCDAsyncSocket()
        }
        super.init()
    }
    
    // MARK: RawSocketProtocol implemention
    
    /// The `RawTCPSocketDelegate` instance.
    weak open var delegate: RawSocketDelegate?
    
    /// Every method call and variable access must operated on this queue. And all delegate methods will be called on this queue.
    ///
    /// - warning: This should be set as soon as the instance is initialized.
    open var queue: DispatchQueue! = nil {
        didSet {
            socket.setDelegate(self, delegateQueue: queue)
        }
    }
    
    /// If the socket is connected.
    open var isConnected: Bool {
        return !socket.isDisconnected
    }
    
    /// The source address.
    open var sourceIPAddress: IPv4Address? {
        guard let localHost = socket.localHost else {
            return nil
        }
        return IPv4Address(fromString: localHost)
    }
    
    /// The source port.
    open var sourcePort: XPort? {
        //fixme
        //return Port(port: socket.localPort)
        return nil
    }
    
    /// The destination address.
    ///
    /// - note: Always returns `nil`.
    open var destinationIPAddress: IPv4Address? {
        return nil
    }
    
    /// The destination port.
    ///
    /// - note: Always returns `nil`.
    open var destinationPort: XPort? {
        return nil
    }
    
    /**
     Connect to remote host.
     
     - parameter host:        Remote host.
     - parameter port:        Remote port.
     - parameter enableTLS:   Should TLS be enabled.
     - parameter tlsSettings: The settings of TLS.
     
     - throws: The error occured when connecting to host.
     */
    public func connectTo(_ host: String, port: UInt16, enableTLS: Bool, tlsSettings: [NSObject : AnyObject]?) throws {
        try connectToHost(host, withPort: Int(port))
        self.enableTLS = enableTLS
        if enableTLS {
            
            startTLS(tlsSettings)
        }
    }
    
    /**
     Disconnect the socket.
     
     The socket will disconnect elegantly after any queued writing data are successfully sent.
     */
    open func disconnect() {
        socket.disconnectAfterWriting()
    }
    
    /**
     Disconnect the socket immediately.
     */
    open func forceDisconnect() {
        socket.disconnect()
    }
    
    /**
     Send data to remote.
     
     - parameter data: Data to send.
     - parameter tag:  The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last write is finished, i.e., `delegate?.didWriteData()` is called.
     */
    open func writeData(_ data: Data, withTag tag: Int) {
        writeData(data, withTimeout: -1, withTag: tag)
    }
    
    /**
     Read data from the socket.
     
     - parameter tag: The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    open func readDataWithTag(_ tag: Int) {
        socket.readData(withTimeout: -1, buffer: nil, bufferOffset: 0, maxLength: 12288, tag: tag)
       // socket.readData(withTimeout: -1, tag: tag)
    }
    
    /**
     Read specific length of data from the socket.
     
     - parameter length: The length of the data to read.
     - parameter tag:    The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    open func readDataToLength(_ length: Int, withTag tag: Int) {
        readDataToLength(length, withTimeout: -1, withTag: tag)
    }
    
    /**
     Read data until a specific pattern (including the pattern).
     
     - parameter data: The pattern.
     - parameter tag:  The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    open func readDataToData(_ data: Data, withTag tag: Int) {
        readDataToData(data, withTag: tag, maxLength: 0)
    }
    
    /**
     Read data until a specific pattern (including the pattern).
     
     - parameter data: The pattern.
     - parameter tag:  The tag identifying the data in the callback delegate method.
     - parameter maxLength: Ignored since `GCDAsyncSocket` does not support this. The max length of data to scan for the pattern.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    open func readDataToData(_ data: Data, withTag tag: Int, maxLength: Int) {
        readDataToData(data, withTimeout: -1, withTag: tag)
    }
    
    // MARK: Other helper methods
    /**
     Send data to remote.
     
     - parameter data: Data to send.
     - parameter timeout: Operation timeout.
     - parameter tag:  The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last write is finished, i.e., `delegate?.didWriteData()` is called.
     */
    func writeData(_ data: Data, withTimeout timeout: Double, withTag tag: Int) {
        socket.write(data, withTimeout: timeout, tag: tag)
    }
    
    /**
     Read specific length of data from the socket.
     
     - parameter length: The length of the data to read.
     - parameter timeout: Operation timeout.
     - parameter tag:    The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    func readDataToLength(_ length: Int, withTimeout timeout: Double, withTag tag: Int) {
        socket.readData(toLength: UInt(length), withTimeout: timeout, tag: tag)
    }
    
    /**
     Read data until a specific pattern (including the pattern).
     
     - parameter data: The pattern.
     - parameter timeout: Operation timeout.
     - parameter tag:  The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    func readDataToData(_ data: Data, withTimeout timeout: Double, withTag tag: Int) {
        socket.readData(to: data, withTimeout: timeout, tag: tag)
    }
    
    /**
     Connect to remote host.
     
     - parameter host:        Remote host.
     - parameter port:        Remote port.
     
     - throws: The error occured when connecting to host.
     */
    func connectToHost(_ host: String, withPort port: Int) throws {
        try socket.connect(toHost: host, onPort: UInt16(port))
    }
    
    /**
     Secures the connection using SSL/TLS.
     
     - parameter tlsSettings: TLS settings, refer to documents of `GCDAsyncSocket` for detail.
     */
    func startTLS(_ tlsSettings: [AnyHashable: Any]!) {
        if let settings = tlsSettings as? [String: NSNumber] {
            socket.startTLS(settings)
        } else {
            var s:[String: NSObject] = [:]
            s[GCDAsyncSocketSSLProtocolVersionMin] = NSNumber.init(value: 7)
            s[GCDAsyncSocketSSLProtocolVersionMax] = NSNumber.init(value: 8)
            s[GCDAsyncSocketManuallyEvaluateTrust] = NSNumber.init(value: true)
            s[GCDAsyncSocketSSLCipherSuites] = [TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256,TLS_DH_anon_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_DH_DSS_WITH_AES_128_CBC_SHA,TLS_DH_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_DSS_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_DH_anon_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_DH_DSS_WITH_AES_256_CBC_SHA,TLS_DH_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_DSS_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA] as NSObject;
            //s[kCFStreamSocketSecurityLevelNegotiatedSSL as String] = kCFStreamSSLLevel;
            socket.startTLS(s)
        }
    }
    
    // MARK: Delegate methods for GCDAsyncSocket
    open func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        delegate?.didWriteData(nil, withTag: tag, from: self)
    }
    
    open func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        delegate?.didReadData(data, withTag: tag, from: self)
    }
    
    open func socketDidDisconnect(_ socket: GCDAsyncSocket, withError err: Error?) {
        delegate?.didDisconnect(self, error: err)
        delegate = nil
        socket.setDelegate(nil, delegateQueue: nil)
    }
    
    open func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        if !enableTLS {
            delegate?.didConnect(self)
        }
    }
    open func socket(_ sock: GCDAsyncSocket, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
    open func socketDidSecure(_ sock: GCDAsyncSocket) {
        if enableTLS {
            delegate?.didConnect(self)
        }
    }
    
}
