//
//  UIColor+Additions.swift
//  Quiz
//
//  Created by Valentyn Kovalsky on 17/08/2018.
//  Copyright © 2018 Springfeed. All rights reserved.
//

import UIKit

extension UIColor {
    class var primary: UIColor {
        return UIColor(named: "primary") ?? UIColor.magenta
    }
    class var primarySelected: UIColor {
        return UIColor(named: "primarySelected") ?? UIColor.magenta
    }
    class var secondary: UIColor {
        return UIColor(named: "secondary") ?? UIColor.magenta
    }
    
    class var buttonText: UIColor {
        return UIColor(named: "buttonText") ??  UIColor.magenta
    }
    
    class var fadedText: UIColor {
        return UIColor(named: "fadedText") ??  UIColor.magenta
    }
    
    class var text: UIColor {
        return UIColor(named: "text") ?? UIColor.magenta
    }
    
    class var errorText: UIColor {
        return UIColor(named: "errorText") ?? UIColor.magenta
    }
    
    class var whiteText: UIColor {
        return UIColor(named: "whiteText") ?? UIColor.magenta
    }
    
    class var background: UIColor {
        return UIColor(named: "background") ?? UIColor.magenta
    }
    
    class var barBackground: UIColor {
        return UIColor(named: "barBackground") ?? UIColor.magenta
    }
    
    class var barButton: UIColor {
        return UIColor(named: "barButton") ?? UIColor.magenta
    }
    
    class var inactiveButton: UIColor {
        return UIColor(named: "inactiveButton") ?? UIColor.magenta
    }
    
    class var inactiveCard: UIColor {
        return UIColor(named: "inactiveCard") ?? UIColor.magenta
    }
    
    class var separator: UIColor {
        return UIColor(named: "separator") ?? UIColor.magenta
    }
    
    class var shadow: UIColor {
        return UIColor(named: "shadow") ?? UIColor.magenta
    }
    
    class var success: UIColor {
        return UIColor(named: "success") ?? UIColor.magenta
    }
    
    class var headerCellColor: UIColor {
        return UIColor(named: "headerCellColor") ?? UIColor.magenta
    }
}
