//
//  Xsocket.swift
//  XSocket
//
//  Created by yarshure on 2017/11/22.
//  Copyright © 2017年 yarshure. All rights reserved.
//

import Foundation

import os.log
import Logging
public enum LoggerLevel:Int,CustomStringConvertible{
    // 调整优先级
    case Error = 0
    case Warning = 1
    case Info = 2
    case Notify = 3
    case Trace = 4
    case Verbose = 5
    case Debug = 6
    public var description: String {
        switch self {
        case .Error: return "Error"
        case .Warning: return "Warning"
        case .Info: return "Info"
        case .Notify: return "Notify"
            
        case .Trace: return "Trace"
        case .Verbose: return "Verbose"
        case .Debug: return "Debug"
        }
    }
}
public final class Xsocket {
    public static var debugEnable = false
    static func log(_ msg:String,items: Any...,level:LoggerLevel , category:String="default",file:String=#file,line:Int=#line,ud:[String:String]=[:],tags:[String]=[],time:Date=Date()){
        
        if level != LoggerLevel.Debug {
            //AxLogger.log(msg,level:level)
        }
        if debugEnable {
            if #available(iOSApplicationExtension 10.0,OSXApplicationExtension 10.12, *) {
                os_log("XSocket: %@", log: .default, type: .debug, msg)
            } else {
                print(msg)
            }
            
        }
     
    }
}
