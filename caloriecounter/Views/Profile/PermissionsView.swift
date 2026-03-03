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
                .fontWeight(.bold)
                .padding(.vertical)
            Text("These toggles keep your Edo sync preferences in step with your onboarding choices. Use the actions below to pull or push data when access is already granted in Health.")
                .font(AppTheme.standardBookCaption)
                .foregroundStyle(AppTheme.textColor.opacity(0.7))
                .multilineTextAlignment(.leading)
            Divider().background(AppTheme.textColor)
            Toggle("Write to Health App", isOn: $userSettingsManager.canWriteToHealthApp)
                .toggleStyle(SwitchToggleStyle(tint: AppTheme.carrot))
                .font(AppTheme.standardBookBody)
                .onChange(of: userSettingsManager.canWriteToHealthApp) { newValue in
                    userSettingsManager.saveHealthAppPermissions(write: newValue, read: userSettingsManager.canReadFromHealthApp)
                }
                .padding(.vertical, 8)
            Divider().background(AppTheme.textColor)
            Toggle("Read from Health App", isOn: $userSettingsManager.canReadFromHealthApp)
                .toggleStyle(SwitchToggleStyle(tint: AppTheme.carrot))
                .font(AppTheme.standardBookBody)
                .onChange(of: userSettingsManager.canReadFromHealthApp) { newValue in
                    userSettingsManager.saveHealthAppPermissions(write: userSettingsManager.canWriteToHealthApp, read: newValue)
                }
                .padding(.vertical, 8)
            Divider().background(AppTheme.textColor)
            Button("Sync Latest Health Data") {
                userSettingsManager.updateHealthInformation()
            }
            .font(AppTheme.standardBookBody)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.reverse)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .disabled(!userSettingsManager.canReadFromHealthApp)
            .opacity(userSettingsManager.canReadFromHealthApp ? 1.0 : 0.5)
            Button("Write Current Metrics to Health") {
                userSettingsManager.saveHealthDataToHealthKit()
            }
            .font(AppTheme.standardBookBody)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.reverse)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .disabled(!userSettingsManager.canWriteToHealthApp)
            .opacity(userSettingsManager.canWriteToHealthApp ? 1.0 : 0.5)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    PermissionsView()
}
