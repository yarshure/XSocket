//
//  Xsocket.swift
//  XSocket
//
//  Created by yarshure on 2017/11/22.
//  Copyright © 2017年 yarshure. All rights reserved.
//

import Foundation
import AxLogger
public final class Xsocket {
    static func log(_ msg:String,items: Any...,level:AxLoggerLevel , category:String="default",file:String=#file,line:Int=#line,ud:[String:String]=[:],tags:[String]=[],time:Date=Date()){
        
        if level != AxLoggerLevel.Debug {
            AxLogger.log(msg,level:level)
        }
        
    }
}
