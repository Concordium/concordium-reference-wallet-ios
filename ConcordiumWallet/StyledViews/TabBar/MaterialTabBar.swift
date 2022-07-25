//
//  MaterialTabBar.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 28/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI
import Combine
import UIKit

struct MaterialTabBar: View {
    private struct OrderedTab: Identifiable {
        let index: Int
        let text: String
        
        var id: Int { index }
    }
    
    class ViewModel: ObservableObject {
        @Published var tabs: [String] = []
        @Published var selectedIndex: Int = 0
        @Published var activeColor: Color = Pallette.primary
        @Published var inactiveColor: Color = Pallette.text
    }
    
    @ObservedObject var viewModel: ViewModel
    
    private var orderedTabs: [OrderedTab] {
        viewModel.tabs.enumerated().map { (index, text) in
            OrderedTab(index: index, text: text)
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HStack(spacing: 0) {
                ForEach(orderedTabs) { tab in
                    Text(verbatim: tab.text)
                        .font(Font(Fonts.tabBar))
                        .foregroundColor(
                            viewModel.selectedIndex == tab.index ? viewModel.activeColor : viewModel.inactiveColor
                        )
                        .padding([.top, .bottom])
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            withAnimation {
                                self.viewModel.selectedIndex = tab.index
                            }
                        }
                }
            }
            TabBarIndicator(
                selectedIndex: CGFloat(viewModel.selectedIndex),
                numberOfTabs: CGFloat(viewModel.tabs.count)
            ).foregroundColor(viewModel.activeColor)
                .frame(height: 2)
        }
    }
}

private struct TabBarIndicator: Shape {
    var selectedIndex: CGFloat
    let numberOfTabs: CGFloat
    
    var animatableData: CGFloat {
        get { selectedIndex }
        set { selectedIndex = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let tabWidth = rect.width / numberOfTabs
        
        return Path(
            CGRect(
                x: tabWidth * selectedIndex,
                y: 0,
                width: tabWidth,
                height: 2
            )
        )
    }
}

struct MaterialTabBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MaterialTabBar(
                viewModel: {
                    let viewModel = MaterialTabBar.ViewModel()
                    viewModel.tabs = ["First", "Second", "Third"]
                    return viewModel
                }()
            )
            Text(verbatim: "Content goes here!")
            Spacer()
        }
    }
}
