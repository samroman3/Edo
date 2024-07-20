//
//  PurchaseView.swift
//  caloriecounter
//
//  Created by Sam Roman on 7/19/24.
//
import SwiftUI

struct PurchaseView: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Image(systemName: "nosign")
                .font(AppTheme.standardBookLargeTitle)
                .fontWeight(.bold).padding(.vertical)
                .foregroundStyle(.red)
            Divider().background(AppTheme.textColor)
            Button("Remove Ads for $8.99") {
                purchaseManager.purchaseRemoveAds()
            }
            .buttonStyle(PurchaseButtonStyle())
            .padding()
            Divider().background(AppTheme.textColor)
            Button("Restore Purchase") {
                purchaseManager.restorePurchases()
            }
            .buttonStyle(PurchaseButtonStyle())
            .padding()
            Divider().background(AppTheme.textColor)
            Spacer()
        }
        .padding()
        .onReceive(purchaseManager.$purchaseSuccessful) { success in
            if success {
                withAnimation(.easeInOut) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .alert(isPresented: $purchaseManager.purchaseSuccessful) {
            Alert(title: Text("Purchase Successful"), message: Text("Thank you for your purchase!"), dismissButton: .default(Text("OK")))
        }
    }
}

struct PurchaseButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.standardBookBody)
            .foregroundColor(.white)
            .padding()
            .background(AppTheme.carrot)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
    }
}
