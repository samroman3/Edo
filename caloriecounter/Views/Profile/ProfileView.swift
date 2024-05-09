//
//  ProfileView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/28/23.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var userSettingsManager: UserSettingsManager
    
    @State private var isEditMode = false
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var editingUserName: String = ""
    
    @State var showCaloricNeedsView = false
    
    private var profileImage: Image? {
        if let profileImage = userSettingsManager.profileImage{
            return Image(uiImage: profileImage)
        }
        return nil
    }
    
    var body: some View {
        NavigationView{
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            isEditMode.toggle()
                        }) {
                            Image(systemName: "pencil")
                                .foregroundStyle(AppTheme.textColor)
                        }
                    }
                    .padding()
                    VStack {
                        // Weight and Height section
                        Section() {
                            VStack {
                                if isEditMode {
                                    TextField("User Name", text: $userSettingsManager.userName)
                                    profileImageView
                                    Button("Select a profile picture") { showingImagePicker = true }
                                } else {
                                    HStack {
                                        profileImageView
                                            .padding()
                                    }
                                }
                                
                                VStack {
                                    HStack {
                                        Text("Weight:")
                                            .fontWeight(.light)
                                            .font(.title2)
                                        Spacer()
                                        Text("\(userSettingsManager.weight, specifier: "%.0f") kg")
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    
                                    HStack {
                                        Text("Height:")
                                            .fontWeight(.light)
                                            .font(.title2)
                                        Spacer()
                                        Text("\(userSettingsManager.height, specifier: "%.0f") cm")
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    HStack {
                                        Text("BMI:")
                                            .fontWeight(.light)
                                            .font(.title2)
                                        Spacer()
                                        Text("\(userSettingsManager.calculateBMI() ?? 0.0,specifier: "%.0f")")
                                    }
                                    
                                }
                            }
                        }
                        .padding()
                    }
                    Divider().background(AppTheme.textColor)
                    
                    // Menu options
                    if !isEditMode {
                        Group {
                            ProfileMenuItem(type: .goals).onTapGesture {
                                self.showCaloricNeedsView.toggle()
                            }
//                            Divider().background(AppTheme.textColor)
//                            NavigationLink(destination: WeightDynamicsView()) {
//                                ProfileMenuItem(type: .weightDynamics)
//                            }
                            Divider().background(AppTheme.textColor)
                            NavigationLink(destination: EmptyView()) {
                                ProfileMenuItem(type: .permissions)
                            }
                            
//                            Divider().background(AppTheme.textColor)
//                            NavigationLink(destination: EmptyView()) {
//                                ProfileMenuItem(type: .notifications)
//                            }
                            Divider().background(AppTheme.textColor)
                        }
                    }
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showCaloricNeedsView) {
            CaloricNeedsView(onboardEntry: false, onComplete: {})
        }
    }
    
    private var profileImageView: some View {
        Group {
            if let profileImage = profileImage {
                profileImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
            }
        }
    }
}



struct ProfileMenuItem: View {
    let type: ProfileItemType
    
    var icon: Image {
        switch type {
        case .notifications:
            Image(systemName: "bell")
        case .weightDynamics:
            Image(systemName:"chart.line.downtrend.xyaxis")
        case .permissions:
            Image(systemName: "heart.text.square")
        case .goals:
            Image(systemName: "flag")
        }
    }
    
    var tint: Color {
        switch type {
        case .notifications:
            AppTheme.skyBlue
        case .weightDynamics:
            AppTheme.lime
        case .permissions:
            AppTheme.coral
        case .goals:
            AppTheme.goldenrod
        }
    }
    
    var name: String {
        switch type {
        case .permissions:
            "Permissions"
        case .notifications:
            "Notifications"
        case .weightDynamics:
            "Dynamics"
        case .goals:
            "Goals"
        }
    }
    var body: some View {
        VStack() {
            HStack {
                Text(name)
                    .font(.largeTitle)
                    .fontWeight(.light)
                Spacer()
                icon
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(tint)
                    .padding(.vertical)
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
        }.foregroundStyle(AppTheme.textColor)
        
    }
}


enum ProfileItemType {
    case weightDynamics
    case notifications
    case permissions
    case goals
}
#Preview(body: {
    ProfileView().environmentObject(UserSettingsManager(context: PersistenceController.init(inMemory: false).container.viewContext))
})
