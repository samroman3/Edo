//
//  DateCollectionViewWrapper.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/26/23.
//

import Foundation
import SwiftUI
// SwiftUI wrapper
struct DateCollectionView: UIViewControllerRepresentable {
    @Binding var selectedDate: Date
    var selectionManager: DateSelectionManager

    func makeUIViewController(context: Context) -> DateCollectionViewController {
        return DateCollectionViewController(selectionManager: selectionManager)
    }

    func updateUIViewController(_ uiViewController: DateCollectionViewController, context: Context) {
        uiViewController.selectedDate = selectedDate
    }
}

