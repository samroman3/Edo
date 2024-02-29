//
//  ProfileView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/28/23.
//


import SwiftUI

struct UserDetailsView: View {
    @EnvironmentObject var userSettingsManager: UserSettingsManager

    var body: some View {
        // Customize this view with the user's details
        Text("User details here")
    }
}

struct WeightDynamicsView: View {
    @EnvironmentObject var userSettingsManager: UserSettingsManager

    var body: some View {
        // Customize this view with the user's weight dynamics
        Text("Weight dynamics here")
    }
}

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var userSettingsManager: UserSettingsManager

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Text("Account").font(.headline).foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        // Action for settings
                    }) {
                        Image(systemName: "gear")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.black)
                VStack {
                    // Profile image
                    if let profileImage = userSettingsManager.profileImage {
                        ProfileImageView(image: Image(uiImage: profileImage))
                    } else {
                        // Placeholder image if no profile image is available
                        ProfileImageView(image: Image(systemName: "person.circle.fill"))
                    }
                ScrollView {
                        // User's name and email
                        Text(userSettingsManager.userName)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(userSettingsManager.userEmail)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 20)
                        
                        // Weight and Height section
                        HStack {
                            VStack {
                                Text("Weight")
                                    .fontWeight(.bold)
                                Text("\(userSettingsManager.weight, specifier: "%.0f") kg")
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)
                            
                            VStack {
                                Text("Height")
                                    .fontWeight(.bold)
                                Text("\(userSettingsManager.height, specifier: "%.0f") cm")
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        
                        // BMI Section
                        Text("Your BMI is \(userSettingsManager.calculateBMI() ?? 0.0)")
                            .font(.headline)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                        
                        // Menu options
                        Group {
                            NavigationLink(destination: UserDetailsView()) {
                                Text("My details")
                            }
                            NavigationLink(destination: WeightDynamicsView()) {
                                Text("Weight dynamics")
                            }
                            // Other menu options...
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

