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
        if let imageData = userSettingsManager.profileImage {
            if let image = UIImage(data: imageData) {
                return Image(uiImage: image)
            }
        }
        return nil
    }
    
    var body: some View {
        NavigationView {
            VStack {
                header
                profileInfoSection.background(.ultraThinMaterial).clipShape(.rect(cornerRadius: 30))
                if !isEditMode {
                    menuSection
                }
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
            .sheet(isPresented: $showCaloricNeedsView) {
                CaloricNeedsView(onboardEntry: false, onComplete: {})
            }
            .onAppear {
                self.editingUserName = self.userSettingsManager.userName
            }
        }
    }
    
    private var header: some View {
        HStack {
            Spacer()
            editButton
        }
    }
    
    private var profileInfoSection: some View {
        VStack {
            if isEditMode {
                TextField("User Name", text: $editingUserName)
                    .font(.title2)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.textColor, lineWidth: 1))
                profileImageView
                Button("Select a profile picture") {
                    showingImagePicker = true
                }
                .font(.headline)
                .padding(.top)
            } else {
                VStack {
                    Text(userSettingsManager.userName)
                        .font(.title2)
                        .fontWeight(.bold)
                    profileImageView
                        .padding()
                }
            }
            weightHeightSection
        }
        .padding()
    }
    
    private var weightHeightSection: some View {
        VStack(spacing: 8) {
            profileInfoRow(label: "Weight:", value: "\(String(format: "%.0f", userSettingsManager.weight)) kg")
            profileInfoRow(label: "Height:", value: "\(String(format: "%.0f", userSettingsManager.height)) cm")
            profileInfoRow(label: "BMI:", value: "\(String(format: "%.1f", userSettingsManager.calculateBMI() ?? 0.0))")
        }
    }
    
    private var menuSection: some View {
        Group {
            Divider().background(AppTheme.textColor)
            ProfileMenuItem(type: .goals).onTapGesture {
                self.showCaloricNeedsView.toggle()
            }
            Divider().background(AppTheme.textColor)
            NavigationLink(destination: EmptyView()) {
                ProfileMenuItem(type: .permissions)
            }
        }
    }
    
    private func profileInfoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .fontWeight(.light)
                .font(.title2)
            Spacer()
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
    }
    
    private var editButton: some View {
        Button(action: {
            if isEditMode {
                saveProfile()
                isEditMode.toggle()
            } else {
                isEditMode.toggle()
            }
        }) {
            Text(isEditMode ? "Save" : "Edit")
                .font(.headline)
                .foregroundStyle(AppTheme.textColor)
        }
    }
    
    private func saveProfile() {
        if let inputImage {
            userSettingsManager.uploadProfileImage(inputImage)
        }
        if editingUserName != userSettingsManager.userName {
            userSettingsManager.saveUserName(editingUserName)
        }
        userSettingsManager.loadUserSettings()
    }
    
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        userSettingsManager.profileImage = inputImage.jpegData(compressionQuality: 300)
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
        .padding()
    }
}

struct ProfileMenuItem: View {
    let type: ProfileItemType
    
    var icon: Image {
        switch type {
        case .notifications:
            return Image(systemName: "bell")
        case .weightDynamics:
            return Image(systemName: "chart.line.downtrend.xyaxis")
        case .permissions:
            return Image(systemName: "heart.text.square")
        case .goals:
            return Image(systemName: "flag")
        }
    }
    
    var tint: Color {
        switch type {
        case .notifications:
            return AppTheme.skyBlue
        case .weightDynamics:
            return AppTheme.lime
        case .permissions:
            return AppTheme.coral
        case .goals:
            return AppTheme.goldenrod
        }
    }
    
    var name: String {
        switch type {
        case .permissions:
            return "Permissions"
        case .notifications:
            return "Notifications"
        case .weightDynamics:
            return "Dynamics"
        case .goals:
            return "Goals"
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(name)
                    .font(.title3)
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
        }
        .foregroundStyle(AppTheme.textColor)
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
