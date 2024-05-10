//
//  iCloudRequiredView.swift
//  caloriecounter
//
//  Created by Sam Roman on 5/10/24.
//
import SwiftUI

struct iCloudRequiredView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "icloud.and.arrow.up")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("iCloud Account Required")
                .font(.title)
                .fontWeight(.bold)
            
            Text("This app requires an iCloud account. Please sign in or create one in your device's Settings to continue. If you have denied access you may accept it again in the App settings and permissions.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                // Attempt to open the Settings app
                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Open Settings")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

#Preview {
    iCloudRequiredView()
}
