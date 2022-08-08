//
//  OnboardingCarouselView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 04/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import SwiftUI

struct OnboardingCarouselView: UIViewControllerRepresentable {
    struct Page {
        let title: String
        let htmlFile: String
    }
    
    let title: String?
    let pages: [Page]
    let onCarouselFinished: () -> Void
    
    class Coordinator: OnboardingCarouselPresenterProtocol {
        private let parent: OnboardingCarouselView
        weak var view: OnboardingCarouselViewProtocol?
        
        private let viewModel: OnboardingCarouselViewModel
        
        init(parent: OnboardingCarouselView) {
            self.parent = parent
            self.viewModel = .init(
                title: parent.title,
                pages: parent.pages.map {
                    .init(
                        title: $0.title,
                        viewController: OnboardingCarouselWebContentViewController(htmlFilename: $0.htmlFile)
                    )
                })
        }
        
        func viewDidLoad() {
            view?.bind(to: viewModel)
        }
        
        func userTappedClose() {
            parent.onCarouselFinished()
        }
        
        func userTappedSkip() {
            parent.onCarouselFinished()
        }
        
        func userTappedContinue() {
            parent.onCarouselFinished()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        OnboardingCarouselFactory.create(with: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
