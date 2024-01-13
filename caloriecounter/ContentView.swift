//
//  ContentView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    

    var body: some View {
        MainView()       
    }
}






//#Preview {
//    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
//}
