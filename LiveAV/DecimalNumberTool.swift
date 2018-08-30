//
//  DecimalNumberTool.swift
//
//  Created by lisilong on 2018/8/15.
//  Copyright © 2018 lisilong. All rights reserved.
//

import Foundation

/// NSDecimalNumber处理浮点型计算时存在精度计算误差的问题
class DecimalNumberTool {
    
    /// 处理浮点型计算时存在精度计算误差的问题
    ///
    /// - Parameter num: 浮点数
    /// - Returns: Float类型浮点数
    public class func float(num: Double) -> Float {
        return decimalNumber(num: num).floatValue
    }
    
    public class func float(num: String) -> Float {
        return decimalNumber(num: (num as NSString).doubleValue).floatValue
    }
    
    public class func double(num: Double) -> Double {
        return decimalNumber(num: num).doubleValue
    }
    
    public class func double(num: String) -> Double {
        return decimalNumber(num: (num as NSString).doubleValue).doubleValue
    }
    
    public class func string(num: Double) -> String {
        return decimalNumber(num: num).stringValue
    }
    
    public class func string(num: String) -> String {
        return decimalNumber(num: (num as NSString).doubleValue).stringValue
    }
    
    // 保留两位小数
    public class func decimalNumber(num: Double) -> NSDecimalNumber {
        return NSDecimalNumber.init(value: num)
    }
}
