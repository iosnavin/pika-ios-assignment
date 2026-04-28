//
//  AppFonts.swift
//  PiKa
//
//  Created by Naveen on 25/04/26.
//

import SwiftUI

struct AppFonts {
    
    static func heavy(size: CGFloat) -> Font {
        .custom("Telka-ExtendedSuper", size: size)
    }
    
    static func bold(size: CGFloat) -> Font {
        .custom("Telka-ExtendedBold", size: size)
    }
    
    static func medium(size: CGFloat) -> Font {
        .custom("Telka-ExtendedMedium", size: size)
    }
    
    static func regular(size: CGFloat) -> Font {
        .custom("Telka-ExtendedRegular", size: size)
    }
    
    static func light(size: CGFloat) -> Font {
        .custom("Telka-ExtendedLight", size: size)
    }
}
