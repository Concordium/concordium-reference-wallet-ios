//
//  CryptoImage.swift
//  ConcordiumWallet
//
//  Created by Maksym Rachytskyy on 08.04.2024.
//  Copyright © 2024 concordium. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import SDWebImageSVGCoder

struct CIS2TokenImagePreview: View {
    enum Size {
        case small
        case medium
        case custom(width: CGFloat, height: CGFloat)
        
        var size: CGSize {
            switch self {
                case .small: return .init(width: 20, height: 20)
                case .medium: return .init(width: 45, height: 45)
                case let .custom(width, height): return .init(width: width, height: height)
            }
        }
    }
    
    let url: URL?
    let size: CIS2TokenImagePreview.Size
    
    var body: some View {
        if let url = url, url.absoluteString.contains(".svg") {
            WebImage(
                url: url,
                context: [.imageCoder: CustomSVGDecoder(fallbackDecoder: SDImageSVGCoder.shared)]
            )
            .resizable()
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .aspectRatio(contentMode: .fit)
            .frame(width: size.size.width, height: size.size.height)
        } else {
            AsyncImage(url: url, scale: 1.0) { image in
                image
                    .resizable()
                    .clipShape(Circle())
            } placeholder: {
                Color.gray.opacity(0.4).clipShape(Circle())
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: size.size.width, height: size.size.height)
        }
    }
}

/// https://stackoverflow.com/questions/74427783/download-svg-image-in-ios-swift
private class CustomSVGDecoder: NSObject, SDImageCoder {
    
    let fallbackDecoder: SDImageCoder?
    
    init(fallbackDecoder: SDImageCoder?) {
        self.fallbackDecoder =  fallbackDecoder
    }
    
    static var regex: NSRegularExpression = {
        let pattern = "<image.*xlink:href=\"data:image\\/(png|jpg);base64,(.*)\"\\/>"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        return regex
    }()
    
    func canDecode(from data: Data?) -> Bool {
        guard let data = data, let string = String(data: data, encoding: .utf8) else { return false }
        guard Self.regex.firstMatch(in: string, range: NSRange(location: 0, length: string.utf16.count)) == nil else {
            return true //It self should decode
        }
        guard let fallbackDecoder = fallbackDecoder else {
            return false
        }
        return fallbackDecoder.canDecode(from: data)
    }
    
    func decodedImage(with data: Data?, options: [SDImageCoderOption : Any]? = nil) -> UIImage? {
        guard let data = data,
              let string = String(data: data, encoding: .utf8) else { return nil }
        guard let match = Self.regex.firstMatch(in: string, range: NSRange(location: 0, length: string.utf16.count)) else {
            return fallbackDecoder?.decodedImage(with: data, options: options)
        }
        guard let rawBase64DataRange = Range(match.range(at: 2), in: string) else {
            return fallbackDecoder?.decodedImage(with: data, options: options)
        }
        let rawBase64Data = String(string[rawBase64DataRange])
        guard let imageData = Data(base64Encoded: Data(rawBase64Data.utf8), options: .ignoreUnknownCharacters) else {
            return fallbackDecoder?.decodedImage(with: data, options: options)
        }
        return UIImage(data: imageData)
    }
    
    //You might need to implement these methods, I didn't check their meaning yet
    func canEncode(to format: SDImageFormat) -> Bool {
        return true
    }
    
    func encodedData(with image: UIImage?, format: SDImageFormat, options: [SDImageCoderOption : Any]? = nil) -> Data? {
        return nil
    }
}
