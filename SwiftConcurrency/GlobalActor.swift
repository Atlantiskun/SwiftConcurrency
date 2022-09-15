//
//  GlobalActor.swift
//  SwiftConcurrency
//
//  Created by Дмитрий Болучевских on 15.09.2022.
//

import SwiftUI

@globalActor final class MyFirstGlobalActor {
    
    static var shared = MyNewDataManager()
    
}

actor MyNewDataManager {
    
    func getDataFromDatabase() -> [String] {
        return ["One", "Two", "Three", "Four", "Five"]
    }
}

@MainActor
class GlobalActorViewModel: ObservableObject {
    
    @MainActor
    @Published var dataArray: [String] = []
    
    let manager = MyFirstGlobalActor.shared
    
    @MyFirstGlobalActor
//    @MainActor
    func getData() {
        Task {
            let data = await manager.getDataFromDatabase()
            await MainActor.run(body: {
                self.dataArray = data
            })
            
        }
        
    }
}

struct GlobalActor: View {
    
    @StateObject private var viewModel = GlobalActorViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .customTaskModifier {
            await viewModel.getData()
        }
    }
}

struct GlobalActor_Previews: PreviewProvider {
    static var previews: some View {
        GlobalActor()
    }
}
