//
//  FFMpegResultCode.swift
//  SauronPlayer
//
//  Created by sauron on 2023/8/1.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import Foundation

typealias FFMpegResultCode = Int32

extension FFMpegResultCode {
    var isNonNegative: Bool {self >= 0}
    var isNonPositive: Bool {self <= 0}
    
    var isPositive: Bool {self > 0}
    var isNegative: Bool {self < 0}
    
    var isZero: Bool {self == 0}
    var isNonZero: Bool {self != 0}
}
