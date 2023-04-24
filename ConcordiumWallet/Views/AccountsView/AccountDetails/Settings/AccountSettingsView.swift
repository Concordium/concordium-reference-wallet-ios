//
//  AccountSettingsView.swift
//  Mock
//
//  Created by Lars Christensen on 29/12/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct AccountSettingsMenuItem: Identifiable {
    let id: Int
    let text: String
    let action: AccountSettingsLogEvent
}

struct AccountSettingsView: Page {
    @ObservedObject var viewModel: AccountSettingsViewModel
    @State private var selectedMenuItemText: String?

    var pageBody: some View {
        List(getMenuItems()) { menuItem in
            HStack {
                Text(menuItem.text)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding([.top, .bottom], 8)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedMenuItemText = menuItem.text
                
                self.viewModel.send(menuItem.action)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedMenuItemText = nil
                }
            }
            .animation(.default)
            .listRowBackground(selectedMenuItemText == menuItem.text ? Color.init(white: 0.85) : .clear)
        }
        .listStyle(.plain)
    }
    
    private func getMenuItems() -> [AccountSettingsMenuItem] {
        var menuItems = [AccountSettingsMenuItem]()
        menuItems.append(AccountSettingsMenuItem(id: 0, text: "burgermenu.transferfilters".localized, action: .transferFilters))
        if viewModel.account.showsShieldedBalance {
            menuItems.append(AccountSettingsMenuItem(id: 1, text: "burgermenu.hideshieldedbalance".localized, action: .hideShielded))
        } else {
            menuItems.append(AccountSettingsMenuItem(id: 1, text: "burgermenu.showshieldedbalance".localized, action: .showShielded))
        }
        menuItems.append(AccountSettingsMenuItem(id: 2, text: "burgermenu.releaseschedule".localized, action: .releaseSchedule))
        menuItems.append(AccountSettingsMenuItem(id: 3, text: "burgermenu.exportprivatekey".localized, action: .exportPrivateKey))
        menuItems.append(AccountSettingsMenuItem(id: 4, text: "burgermenu.exporttransactionlog".localized, action: .exportTransactionLog))
        menuItems.append(AccountSettingsMenuItem(id: 5, text: "burgermenu.renameaccount".localized, action: .renameAccount))
        return menuItems
    }
}

struct AccountSettings_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsView(viewModel: .init(account: AccountDataTypeFactory.create()))
    }
}
