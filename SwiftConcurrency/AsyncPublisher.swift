//
//  AsyncPublisher.swift
//  SwiftConcurrency
//
//  Created by Дмитрий Болучевских on 15.09.2022.
//

import SwiftUI
import Combine

class AsyncPublisherDataManager {
    
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        myData.append("Watermelon")
    }
}

class AsyncPublisherViewModel: ObservableObject {
    
    @MainActor
    @Published var dataArray: [String] = []
    let manager = AsyncPublisherDataManager()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        Task {
            await MainActor.run(body: {
                self.dataArray = ["One"]
            })
            
            for await value in manager.$myData.customValues {
                await MainActor.run(body: {
                    self.dataArray = value
                })
                
            }
            
            await MainActor.run(body: {
                self.dataArray = ["Two"]
            })
        }
//        manager.$myData.customValues
//        manager.$myData
//            .receive(on: DispatchQueue.main)
//            .sink { dataArray in
//                self.dataArray = dataArray
//            }
//            .store(in: &cancellables)
    }
    
    func start() async {
        await manager.addData()
    }
}

struct AsyncPublisher: View {
    
    @StateObject private var viewModel = AsyncPublisherViewModel()
    
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
            await viewModel.start()
        }
    }
}

struct AsyncPublisher_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublisher()
    }
}
