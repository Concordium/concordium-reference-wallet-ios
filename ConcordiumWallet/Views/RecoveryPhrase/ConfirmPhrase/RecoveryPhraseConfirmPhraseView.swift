//
//  RecoveryPhraseConfirmPhraseView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 25/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct RecoveryPhraseConfirmPhraseView: Page {
    @ObservedObject var viewModel: RecoveryPhraseConfirmPhraseViewModel
    
    var pageBody: some View {
        VStack {
            PageIndicator(numberOfPages: 4, currentPage: 1)
            Text(verbatim: viewModel.title)
                .labelStyle(.body)
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing], 20)
            WordSelection(selectedWords: viewModel.selectedWords, suggestions: viewModel.suggestions) { index, word in
                viewModel.send(.selectWord(index: index, word: word))
            }.padding([.top], 95)
            viewModel.error.map {
                Text(verbatim: $0)
                    .labelStyle(.body, color: Pallette.error)
                    .multilineTextAlignment(.center)
                    .padding(.init(top: 16, leading: 20, bottom: 0, trailing: 20))
            }
            Spacer()
        }
        .padding(.init(top: 10, leading: 16, bottom: 30, trailing: 16))
    }
}

private struct WordSelection: View {
    let selectedWords: [String]
    let suggestions: [[String]]
    let action: (Int, String) -> Void
    
    @State private var selectedIndex = 0
    
    var body: some View {
        HStack {
            WordList(selectedIndex: $selectedIndex, selectedWords: selectedWords)
                .frame(height: 30 * 5)
                .frame(maxWidth: .infinity)
            Image("select_arrow")
            VStack(spacing: 10) {
                ForEach(suggestions[selectedIndex], id: \.self) { suggestion in
                    Text(verbatim: suggestion)
                        .frame(maxWidth: .infinity)
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder()
                                .foregroundColor(Pallette.primary)
                        )
                        .onTapGesture {
                            action(selectedIndex, suggestion)
                            moveToNextIndex()
                        }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.init(top: 0, leading: 4, bottom: 0, trailing: 12))
    }
    
    private func moveToNextIndex() {
        for index in selectedIndex+1..<selectedWords.count {
            if selectedWords[index].isEmpty {
                selectedIndex = index
                return
            }
        }
    }
}

private struct WordList: UIViewRepresentable {
    typealias UIViewType = UITableView
    @Binding var selectedIndex: Int
    let selectedWords: [String]
    
    class Coordinator: NSObject, UITableViewDelegate, UITableViewDataSource {
        var parent: WordList
        
        init(parent: WordList) {
            self.parent = parent
        }
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return parent.selectedWords.count
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 30
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueWordListCell(at: indexPath)
            
            let selectedWord = parent.selectedWords[indexPath.row]
            let isSelected = parent.selectedIndex == indexPath.row
            
            let showSeparator = !isSelected && !selectedWord.isEmpty &&
            indexPath.row < parent.selectedWords.count - 1 &&
            !parent.selectedWords[indexPath.row + 1].isEmpty &&
            parent.selectedIndex != indexPath.row + 1
            
            cell.update(
                with: selectedWord,
                index: indexPath.row,
                numItems: parent.selectedWords.count,
                isSelected: isSelected,
                showSeparator: showSeparator
            )
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            parent.selectedIndex = indexPath.row
        }
        
        func scrollViewWillEndDragging(
            _ scrollView: UIScrollView,
            withVelocity velocity: CGPoint,
            targetContentOffset: UnsafeMutablePointer<CGPoint>
        ) {
            var targetIndex = (targetContentOffset.pointee.y + 75) / 30
            targetIndex = velocity.y > 0 ? ceil(targetIndex) : floor(targetIndex)
            targetIndex = max(0, min(CGFloat(parent.selectedWords.count - 1), targetIndex))
            targetContentOffset.pointee.y = targetIndex * 30 - 60
            
            parent.selectedIndex = Int(targetIndex)
        }
    }
    
    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView()
        
        tableView.register(WordListCell.self, forCellReuseIdentifier: WordListCell.identifier)
        let inset: CGFloat = 30 * 2.5
        tableView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.reloadData()
        tableView.scrollToRow(at: .init(row: 0, section: 0), at: .middle, animated: false)
        
        return tableView
    }
    
    func updateUIView(_ uiView: UITableView, context: Context) {
        context.coordinator.parent = self
        uiView.reloadData()
        if !uiView.isDragging && !uiView.isTracking && !uiView.isDecelerating {
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
}

private struct WordListCellContent: View {
    class ViewModel: ObservableObject {
        @Published var index: Int = 0
        @Published var label: String = ""
        @Published var isSelected: Bool = false
        @Published var numItems: Int = 0
        @Published var showSeparator: Bool = false
    }
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            WordListSeparator()
                .foregroundColor(Pallette.background)
                .opacity(viewModel.showSeparator ? 1 : 0)
            Text(verbatim: "\(viewModel.index + 1).")
                .labelStyle(.mono)
                .foregroundColor(viewModel.label.isEmpty ? Pallette.text : Pallette.buttonText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading], 8)
            Text(verbatim: viewModel.label)
                .labelStyle(.mono)
                .foregroundColor(viewModel.label.isEmpty ? Pallette.text : Pallette.buttonText)
        }
        .frame(height: 30)
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

struct RecoveryPhraseConfirmPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryPhraseConfirmPhraseView(
            viewModel: .init(
                title: "Pick the correct suggestion on the right, for each index.",
                suggestions: [
                    ["ariel", "gossipy", "violently", "damage"]
                ] + Array(repeating: [], count: 23),
                selectedWords: ["Ariel"] + Array(repeating: "", count: 23),
                error: "Incorrect secret recovery phrase. Please verify that each index has the right word."
            )
        )
    }
}
