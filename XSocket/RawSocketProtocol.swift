//
//  RowSocketProtocol.swift
//  SFSocket
//
//  Created by 孔祥波 on 29/03/2017.
//  Copyright © 2017 Kong XiangBo. All rights reserved.
//

import Foundation

//Mark: -
/// The delegate protocol to handle the events from a raw TCP socket.
public protocol RawSocketDelegate: class {
    /**
     The socket did disconnect.
     
     This should only be called once in the entire lifetime of a socket. After this is called, the delegate will not receive any other events from that socket and the socket should be released.
     
     - parameter socket: The socket which did disconnect.
     */
    func didDisconnect(_ socket: RawSocketProtocol,  error:Error?)
    
    /**
     The socket did read some data.
     
     - parameter data:    The data read from the socket.
     - parameter withTag: The tag given when calling the `readData` method.
     - parameter from:    The socket where the data is read from.
     */
    func didReadData(_ data: Data, withTag: Int, from: RawSocketProtocol)
    
    /**
     The socket did send some data.
     
     - parameter data:    The data which have been sent to remote (acknowledged). Note this may not be available since the data may be released to save memory.
     - parameter withTag: The tag given when calling the `writeData` method.
     - parameter from:    The socket where the data is sent out.
     */
    func didWriteData(_ data: Data?, withTag: Int, from: RawSocketProtocol)
    
    /**
     The socket did connect to remote.
     
     - parameter socket: The connected socket.
     */
    func didConnect(_ socket: RawSocketProtocol)
    
    /**
     Disconnect the socket elegantly.
     */
    func disconnect(becauseOf error: Error?)
    
    /**
     Disconnect the socket immediately.
     */
    func forceDisconnect(becauseOf error: Error?)
    
}
public protocol RawSocketProtocol {
    weak var delegate: RawSocketDelegate? { get set }
    
    func forceDisconnect(_ sessionID:UInt32)
    /// Every delegate method should be called on this dispatch queue. And every method call and variable access will be called on this queue.
    var queue: DispatchQueue! { get set }
    /// If the socket is connected.
    var isConnected: Bool { get }
    
    var writePending:Bool {get }
    var readPending:Bool  {get}
    /// The source address.
    var sourceIPAddress: IPv4Address? { get }
    
    /// The source port.
    var sourcePort: XPort? { get }
    
    /// The destination address.
    var destinationIPAddress: IPv4Address? { get }
    
    /// The destination port.
    var destinationPort: XPort? { get }
    
    /// cell or wifi
    var useCell:Bool{get}
    var tcp:Bool {get}
    /**
     Connect to remote host.
     
     - parameter host:        Remote host.
     - parameter port:        Remote port.
     - parameter enableTLS:   Should TLS be enabled.
     - parameter tlsSettings: The settings of TLS.
     
     - throws: The error occured when connecting to host.
     */
    func connectTo(_ host: String, port: UInt16, enableTLS: Bool, tlsSettings: [NSObject : AnyObject]?) throws
    
    
   
    /**
     Disconnect the socket.
     
     The socket should disconnect elegantly after any queued writing data are successfully sent.
     
     - note: Usually, any concrete implemention should wait until any pending writing data are finished then call `forceDisconnect()`.
     */
    func disconnect(becauseOf error: Error? )
    
    /**
     Disconnect the socket immediately.
     
     - note: The socket should disconnect as soon as possible.
     */
    func forceDisconnect(becauseOf error: Error?)
    
    /**
     Send data to remote.
     
     - parameter data: Data to send.
     - parameter tag:  The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last write is finished, i.e., `delegate?.didWriteData()` is called.
     */
    func writeData(_ data: Data, withTag: Int)
    
    /**
     Read data from the socket.
     
     - parameter tag: The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    func readDataWithTag(_ tag: Int)
    
    /**
     Read specific length of data from the socket.
     
     - parameter length: The length of the data to read.
     - parameter tag:    The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    func readDataToLength(_ length: Int, withTag tag: Int)
    
    /**
     Read data until a specific pattern (including the pattern).
     
     - parameter data: The pattern.
     - parameter tag:  The tag identifying the data in the callback delegate method.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    func readDataToData(_ data: Data, withTag tag: Int)
    
    /**
     Read data until a specific pattern (including the pattern).
     
     - parameter data: The pattern.
     - parameter tag:  The tag identifying the data in the callback delegate method.
     - parameter maxLength: The max length of data to scan for the pattern.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    func readDataToData(_ data: Data, withTag tag: Int, maxLength: Int)
}
