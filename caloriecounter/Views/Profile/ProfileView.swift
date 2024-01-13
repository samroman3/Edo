//
//  ProfileView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/28/23.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var userSettingsManager: UserSettingsManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    if let profileImage = userSettingsManager.profileImage {
                        ProfileImageView(image: Image(uiImage: profileImage))
                    } else {
                        // Placeholder image if no profile image is available
                        ProfileImageView(image: Image(systemName: "person.circle.fill"))
                    }
                    
                    VStack(alignment: .leading) {
                        Text(userSettingsManager.userName)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(userSettingsManager.userEmail)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    EditButton()
                }
                .padding()
                
                UserStatsView(weight: userSettingsManager.weight, height: userSettingsManager.height)
                Divider()
                
                // NavigationLink(destination: PersonalDetailsView()) {
                //     Text("My Details")
                // }
                
                NavigationLink(destination: SettingsView()) {
                    Text("Settings")
                }
                                
                Spacer()
            }
            .navigationBarTitle("Account", displayMode: .inline)
        }
    }
}

// Ensure you have views like `ProfileImageView`, `UserStatsView`, `BMIView`, etc., defined in your code.
