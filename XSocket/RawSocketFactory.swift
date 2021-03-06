import Foundation
import NetworkExtension

/**
 Represents the type of the socket.

 - NW:  The socket based on `NWTCPConnection`.
 - GCD: The socket based on `GCDAsyncSocket`.
 */
public enum SocketBaseType {
    case NW, GCD,Network
}

/// Factory to create `RawTCPSocket` based on configuration.
public class RawSocketFactory {
    /// Current active `NETunnelProvider` which creates `NWTCPConnection` instance.
    ///
    /// - note: Must set before any connection is created if `NWTCPSocket` or `NWUDPSocket` is used.
    public static weak var TunnelProvider: NETunnelProvider?

    /**
     Return `RawSocketProtocol` instance.

     - parameter type: The type of the socket.

     - returns: The created socket instance.
     */
    // 
    public static func getRawSocket(type: SocketBaseType? = nil,tcp:Bool = true) -> RawSocketProtocol {
        
        if tcp {
            switch type {
            case .some(.NW):
                return NWTCPSocket()
            case .some(.GCD):
                return GCDTCPSocket()
            case nil:
                if #available(iOS 12.0,macOS 10.14, *){
                    return NetworkSocket()
                }else {
                    if RawSocketFactory.TunnelProvider == nil {
                        return GCDTCPSocket()
                    } else {
                        return NWTCPSocket()
                    }
                }
                
            case .some(.Network):
                if #available(iOSApplicationExtension 12.0,macOS 10.14, *) {
                    return NetworkSocket()
                } else {
                    if RawSocketFactory.TunnelProvider == nil {
                        return GCDTCPSocket()
                    } else {
                        return NWTCPSocket()
                    }
                }
            }
        }else {
            //udp support
            switch type {
            case .some(.NW):
                return NWUDPSocket()
            case .some(.GCD):
                return GCDUDPSocket()
            case nil:
                if #available(iOS 12.0,macOS 10.14, *) {
                     return  NetworkUDPSocket()
                }else {
                    if RawSocketFactory.TunnelProvider == nil {
                        return GCDUDPSocket()
                    } else {
                        return NWUDPSocket()
                    }
                }
                
            case .some(.Network):
                if #available(iOS 12.0,macOS 10.14, *) {
                    return  NetworkUDPSocket()
                }
                return NWUDPSocket()
            }
            
        }
        
    }
}
