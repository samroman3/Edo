//
//  PermissionsView.swift
//  caloriecounter
//
//  Created by Sam Roman on 5/10/24.
//

import SwiftUI

struct PermissionsView: View {
    @EnvironmentObject var userSettingsManager: UserSettingsManager

    var body: some View {
        VStack {
                Text("Health App Permissions")
                    .font(AppTheme.standardBookLargeTitle)
                    .fontWeight(.bold).padding(.vertical)
                Divider().background(AppTheme.textColor)
                Toggle("Write to Health App", isOn: $userSettingsManager.canWriteToHealthApp)
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.carrot))
                    .font(AppTheme.standardBookBody)
                    .onChange(of: userSettingsManager.canWriteToHealthApp) { newValue in
                        userSettingsManager.saveHealthAppPermissions(write: newValue, read: userSettingsManager.canReadFromHealthApp)
                    }
                    .padding()
                Divider().background(AppTheme.textColor)
                Toggle("Read from Health App", isOn: $userSettingsManager.canReadFromHealthApp)
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.carrot))
                    .font(AppTheme.standardBookBody)
                    .onChange(of: userSettingsManager.canReadFromHealthApp) { newValue in
                        userSettingsManager.saveHealthAppPermissions(write: userSettingsManager.canWriteToHealthApp, read: newValue)
                    }
                    .padding()
                Divider().background(AppTheme.textColor)
            Spacer()
        }.padding()
    }
}

#Preview {
    PermissionsView()
}
