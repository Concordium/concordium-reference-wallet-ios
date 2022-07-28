//
//  WordList.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 28/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct WordList: View {
    @Binding var selectedIndex: Int
    @Binding var isScrolling: Bool
    let selectedWords: [String]
    let cellHeight: CGFloat
    
    init(
        selectedIndex: Binding<Int>,
        isScrolling: Binding<Bool>,
        selectedWords: [String],
        cellHeight: CGFloat = 40
    ) {
        self._selectedIndex = selectedIndex
        self._isScrolling = isScrolling
        self.selectedWords = selectedWords
        self.cellHeight = cellHeight
    }
    
    var body: some View {
        WordListTable(
            selectedIndex: $selectedIndex,
            isScrolling: $isScrolling,
            selectedWords: selectedWords,
            cellHeight: cellHeight
        )
        .frame(height: cellHeight * 5)
        .frame(maxWidth: .infinity)
    }
}

private struct WordListTable: UIViewRepresentable {
    typealias UIViewType = UITableView
    @Binding var selectedIndex: Int
    @Binding var isScrolling: Bool
    let selectedWords: [String]
    let cellHeight: CGFloat
    
    func centerIndex(forOffset offset: CGFloat) -> CGFloat {
        (offset + cellHeight * 2.5) / cellHeight
    }
    
    class Coordinator: NSObject, UITableViewDelegate, UITableViewDataSource {
        var parent: WordListTable
        
        private var lastScrollIndex: Int?
        
        init(parent: WordListTable) {
            self.parent = parent
        }
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return parent.selectedWords.count
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return parent.cellHeight
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueWordListCell(at: indexPath)
            let selectedIndex = Int(parent.centerIndex(forOffset: tableView.contentOffset.y))
            
            let selectedWord = parent.selectedWords[indexPath.row]
            let isSelected = selectedIndex == indexPath.row
    
            cell.update(
                with: selectedWord,
                index: indexPath.row,
                numItems: parent.selectedWords.count,
                isSelected: isSelected,
                showSeparator: showSeparator(
                    forCellAt: indexPath.row,
                    selectedIndex: selectedIndex
                )
            )
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if indexPath.row != parent.selectedIndex {
                parent.isScrolling = true
                tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
        }
        
        func scrollViewWillEndDragging(
            _ scrollView: UIScrollView,
            withVelocity velocity: CGPoint,
            targetContentOffset: UnsafeMutablePointer<CGPoint>
        ) {
            var targetIndex = parent.centerIndex(forOffset: targetContentOffset.pointee.y)
            targetIndex = velocity.y > 0 ? ceil(targetIndex) : floor(targetIndex)
            targetIndex = max(0, min(CGFloat(parent.selectedWords.count - 1), targetIndex))
            targetContentOffset.pointee.y = targetIndex * parent.cellHeight - 2 * parent.cellHeight
            if Int(targetIndex) != parent.selectedIndex {
                parent.isScrolling = true
            }
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if let tableView = scrollView as? UITableView {
                let index = Int(parent.centerIndex(forOffset: tableView.contentOffset.y))
                
                if let lastScrollIndex = lastScrollIndex, lastScrollIndex != index {
                    for i in index - 2...index + 2 {
                        tableView
                            .getWordListCell(at: .init(row: i, section: 0))?
                            .updateSelection(i == index, showSeparator: showSeparator(forCellAt: i, selectedIndex: index))
                    }
                }
                lastScrollIndex = index
            }
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                onScrollCompleted(newOffset: scrollView.contentOffset.y)
            }
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            onScrollCompleted(newOffset: scrollView.contentOffset.y)
        }
        
        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            onScrollCompleted(newOffset: scrollView.contentOffset.y)
        }
        
        private func onScrollCompleted(newOffset: CGFloat) {
            lastScrollIndex = nil
            self.parent.selectedIndex = Int(parent.centerIndex(forOffset: newOffset))
            self.parent.isScrolling = false
        }
        
        private func showSeparator(forCellAt index: Int, selectedIndex: Int) -> Bool {
            return isNotSelectedOrEmpty(at: index, selectedIndex: selectedIndex) && isNotSelectedOrEmpty(at: index + 1, selectedIndex: selectedIndex)
        }
        
        private func isNotSelectedOrEmpty(at index: Int, selectedIndex: Int) -> Bool {
            let isNotSelected = index != selectedIndex
            let isNotEmpty = index < parent.selectedWords.count && !parent.selectedWords[index].isEmpty
            
            return isNotSelected && isNotEmpty
        }
    }
    
    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView()
        
        tableView.register(WordListCell.self, forCellReuseIdentifier: WordListCell.identifier)
        let inset: CGFloat = cellHeight * 2.5
        tableView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.reloadData()
        tableView.setContentOffset(
            .init(
                x: tableView.contentOffset.x,
                y: CGFloat(selectedIndex) * cellHeight - cellHeight * 2
            ),
            animated: false
        )
        
        return tableView
    }
    
    func updateUIView(_ uiView: UITableView, context: Context) {
        let oldIndex = context.coordinator.parent.selectedIndex
        context.coordinator.parent = self
        uiView.reloadData()
        if oldIndex != selectedIndex && !uiView.isDragging && !uiView.isTracking && !uiView.isDecelerating {
            uiView.scrollToRow(at: .init(row: selectedIndex, section: 0), at: .middle, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
}

private extension UITableView {
    func dequeueWordListCell(at indexPath: IndexPath) -> WordListCell {
        let cell = dequeueReusableCell(withIdentifier: WordListCell.identifier, for: indexPath) as? WordListCell
        
        return cell ?? WordListCell()
    }
    
    func getWordListCell(at indexPath: IndexPath) -> WordListCell? {
        return cellForRow(at: indexPath) as? WordListCell
    }
}

private class WordListCell: UITableViewCell {
    static let identifier = "WordCell"
    
    private let viewModel: WordListCellContent.ViewModel
    private let hostingController: UIHostingController<WordListCellContent>
    
    init() {
        viewModel = WordListCellContent.ViewModel()
        hostingController = UIHostingController(rootView: WordListCellContent(viewModel: viewModel))
        
        super.init(style: .default, reuseIdentifier: WordListCell.identifier)
        
        setup()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        viewModel = WordListCellContent.ViewModel()
        hostingController = UIHostingController(rootView: WordListCellContent(viewModel: viewModel))
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        viewModel = WordListCellContent.ViewModel()
        guard let hostingController = UIHostingController(coder: coder, rootView: WordListCellContent(viewModel: viewModel)) else {
            return nil
        }
        self.hostingController = hostingController
        
        super.init(coder: coder)
        
        setup()
    }
    
    private func setup() {
        selectionStyle = .none
        clipsToBounds = false
        backgroundColor = .clear
        contentView.clipsToBounds = false
        contentView.backgroundColor = .clear
        contentView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            contentView.trailingAnchor.constraint(equalTo: hostingController.view.trailingAnchor, constant: 8),
            contentView.bottomAnchor.constraint(equalTo: hostingController.view.bottomAnchor, constant: 8)
        ])
    }
    
    func update(
        with label: String,
        index: Int,
        numItems: Int,
        isSelected: Bool,
        showSeparator: Bool
    ) {
        viewModel.label = label
        viewModel.index = index
        viewModel.isSelected = isSelected
        viewModel.numItems = numItems
        viewModel.showSeparator = showSeparator
    }
    
    func updateSelection(_ isSelected: Bool, showSeparator: Bool) {
        viewModel.isSelected = isSelected
        viewModel.showSeparator = showSeparator
    }
}

private struct WordListCellContent: View {
    class ViewModel: ObservableObject {
        @Published var index: Int = 0
        @Published var label: String = ""
        @Published var isSelected: Bool = false
        @Published var numItems: Int = 0
        @Published var showSeparator: Bool = false
        @Published var cellHeight: CGFloat = 40
    }
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            WordListSeparator()
                .foregroundColor(Pallette.background)
                .opacity(viewModel.showSeparator ? 1 : 0)
            StyledLabel(text: "\(viewModel.index + 1).", style: .mono, color: textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading], 8)
            StyledLabel(text: viewModel.label, style: .mono, color: textColor)
        }
        .frame(height: viewModel.cellHeight)
        .frame(maxWidth: .infinity)
        .background(
            WordListBackgroundShape(location: .from(index: viewModel.index, numItems: viewModel.numItems), isSelected: viewModel.isSelected)
                .fillWithBorder(
                    fill: viewModel.label.isEmpty ? Pallette.background : Pallette.primary,
                    stroke: Pallette.primary
                )
        )
        .padding([.leading, .trailing], viewModel.isSelected ? 0 : 6)
        .shadow(color: .black.opacity(0.25), radius: viewModel.isSelected ? 4 : 0)
        .zIndex(viewModel.isSelected ? 1 : 0)
    }
    
    private var textColor: Color {
        if viewModel.label.isEmpty {
            return Pallette.text
        } else {
            return Pallette.buttonText
        }
    }
}

private struct WordListSeparator: Shape {
    func path(in rect: CGRect) -> Path {
        return Path(.init(x: 0, y: rect.maxY - 1, width: rect.width, height: 1))
    }
}

private struct WordListBackgroundShape: Shape {
    enum Location {
        case top, middle, bottom
        
        static func from(index: Int, numItems: Int) -> Location {
            switch index {
            case 0:
                return .top
            case numItems - 1:
                return .bottom
            default:
                return .middle
            }
        }
        
        func corners(isSelected: Bool) -> UIRectCorner {
            guard !isSelected else {
                return .allCorners
            }
            
            switch self {
            case .top:
                return [.topLeft, .topRight]
            case .middle:
                return []
            case .bottom:
                return [.bottomLeft, .bottomRight]
            }
        }
    }
    
    let location: Location
    let isSelected: Bool
    
    func path(in rect: CGRect) -> Path {
        let bezierPath = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: location.corners(isSelected: isSelected),
            cornerRadii: CGSize(width: 6, height: 6)
        )
        
        return Path(bezierPath.cgPath)
    }
}
