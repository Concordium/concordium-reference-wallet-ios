//
//  PageList.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 29/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct PageList: View {
    private struct IndexedItem: Identifiable {
        let index: Int
        let value: String
        
        var id: Int { index }
    }
    
    let items: [String]
    @Binding var selectedIndex: Int
    let editable: Bool
    @Binding var currentInput: String
    
    fileprivate static let cellHeight: CGFloat = 40
    @GestureState private var dragOffset: CGFloat = 0
    
    private var indexedItems: [IndexedItem] {
        items.enumerated().map { (index, value) in
            IndexedItem(index: index, value: value)
        }
    }
    
    private var topOffset: CGFloat {
        let halfContentOffset = PageList.cellHeight * CGFloat(indexedItems.count) / 2 + PageList.cellHeight / 2
        let scrollOffset = (PageList.cellHeight + CGFloat(selectedIndex) * PageList.cellHeight)
        
        return halfContentOffset - scrollOffset + dragOffset
    }
    
    private var calculatedIndex: Int {
        let inversedOffset = dragOffset * -1
        let offsetIndex = Int(inversedOffset / PageList.cellHeight)
        
        return offsetIndex + selectedIndex
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(indexedItems) { item in
                PageListCell(
                    index: item.index,
                    label: item.value,
                    location: .from(index: item.index, itemCount: items.count),
                    isSelected: calculatedIndex == item.index,
                    showSeparator: showSeparator(forCellAt: item.index),
                    editable: editable,
                    input: $currentInput
                )
                .onTapGesture {
                    selectedIndex = item.index
                }
                
            }
            .offset(y: topOffset)
            .animation(.easeInOut, value: topOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        var index = value.translation.height * -1 / PageList.cellHeight
                        index = value.translation.height < 0 ? ceil(index) : floor(index)
                        
                        selectedIndex = max(
                            0,
                            min(
                                items.count - 1,
                                selectedIndex + Int(index)
                            )
                        )
                    }
            )
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(height: PageList.cellHeight * 5)
        .padding([.leading, .trailing], 8)
        .clipped()
        .contentShape(Rectangle())
    }
    
    private func showSeparator(forCellAt index: Int) -> Bool {
        return isNotSelectedOrEmpty(at: index) && isNotSelectedOrEmpty(at: index + 1)
    }
    
    private func isNotSelectedOrEmpty(at index: Int) -> Bool {
        let isNotSelected = index != calculatedIndex
        let isNotEmpty = index < items.count && !items[index].isEmpty
        
        return isNotSelected && isNotEmpty
    }
}

private struct PageListCell: View {
    enum Location {
        case top, middle, bottom
        
        static func from(index: Int, itemCount: Int) -> Location {
            if index == 0 {
                return .top
            } else if index < itemCount - 1 {
                return .middle
            } else {
                return .bottom
            }
        }
    }
    
    let index: Int
    let label: String
    let location: Location
    let isSelected: Bool
    let showSeparator: Bool
    let editable: Bool
    @Binding var input: String
    
    var body: some View {
        ZStack {
            PageListSeparator()
                .foregroundColor(Pallette.background)
                .opacity(showSeparator ? 1 : 0)
            if isSelected && editable {
                AutoFocusTextField(text: $input)
                    .onAppear {
                        input = label
                    }
            } else {
                StyledLabel(text: label, style: .mono, color: textColor)
            }
            
            StyledLabel(text: "\(index + 1).", style: .mono, color: textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading], 8)
        }
        .frame(height: PageList.cellHeight)
        .frame(maxWidth: .infinity)
        .background(
            PageListBackgroundShape(location: location, isSelected: isSelected)
                .fillWithBorder(
                    fill: label.isEmpty || (isSelected && editable) ? Pallette.background : Pallette.primary,
                    stroke: Pallette.primary
                )
        )
        .padding([.leading, .trailing], isSelected ? 0 : 6)
        .shadow(color: .black.opacity(0.25), radius: isSelected ? 4 : 0)
        .zIndex(isSelected ? 1 : 0)
    }
    
    private var textColor: Color {
        if label.isEmpty || (isSelected && editable) {
            return Pallette.text
        } else {
            return Pallette.buttonText
        }
    }
}

private struct PageListSeparator: Shape {
    func path(in rect: CGRect) -> Path {
        return Path(.init(x: 0, y: rect.maxY - 1, width: rect.width, height: 1))
    }
}

private struct PageListBackgroundShape: Shape {
    let location: PageListCell.Location
    let isSelected: Bool
    
    private var corners: UIRectCorner {
        if isSelected {
            return .allCorners
        }
        
        switch location {
        case .top:
            return [.topLeft, .topRight]
        case .middle:
            return []
        case .bottom:
            return [.bottomLeft, .bottomRight]
        }
    }
    
    func path(in rect: CGRect) -> Path {
        let bezierPath = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: 6, height: 6)
        )
        
        return Path(bezierPath.cgPath)
    }
}

struct PageList_Previews: PreviewProvider {
    static var previews: some View {
        Container(editable: false)
            .padding()
        Container(editable: true)
            .padding()
    }
    
    private struct Container: View {
        let editable: Bool
        
        @State var selectedIndex: Int = 3
        @State var currentInput: String = ""
        
        var body: some View {
            PageList(
                items: (0..<24).map { "\($0)." },
                selectedIndex: $selectedIndex,
                editable: editable,
                currentInput: $currentInput
            )
        }
    }
}
