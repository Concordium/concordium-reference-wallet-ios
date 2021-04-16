//
//  UIImage+Additions.swift
//  SFoundation
//
//  Created by Valentyn Kovalsky on 18/10/2018.
//  Copyright © 2018 Springfeed. All rights reserved.
//

import UIKit

extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

    /*
     @brief decode image base64
     */
    static func decodeBase64(toImage strEncodeData: String!) -> UIImage {

        if let decData = Data(base64Encoded: strEncodeData, options: .ignoreUnknownCharacters), strEncodeData.count > 0 {
            return UIImage(data: decData) ?? UIImage()
        }
        return UIImage()
    }

    func scaleTo(_ newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}
