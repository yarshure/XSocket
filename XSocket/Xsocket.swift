//
//  Xsocket.swift
//  XSocket
//
//  Created by yarshure on 2017/11/22.
//  Copyright © 2017年 yarshure. All rights reserved.
//

import Foundation
import AxLogger
import os.log
public final class Xsocket {
    public static var debugEnable = false
    static func log(_ msg:String,items: Any...,level:AxLoggerLevel , category:String="default",file:String=#file,line:Int=#line,ud:[String:String]=[:],tags:[String]=[],time:Date=Date()){
        
        if level != AxLoggerLevel.Debug {
            AxLogger.log(msg,level:level)
        }
        if debugEnable {
            #if os(iOS)
                if #available(iOSApplicationExtension 10.0, *) {
                    os_log("XSocket: %@", log: .default, type: .debug, msg)
                } else {
                    print(msg)
                }
            #elseif os(OSX)
                if #available(OSXApplicationExtension 10.12, *) {
                    os_log("XSocket: %@", log: .default, type: .debug, msg)
                } else {
                     print(msg)
                }
            #endif
        }
     
    }
}
