//
//  Actors.swift
//  SwiftConcurrency
//
//  Created by Дмитрий Болучевских on 15.09.2022.
//

import SwiftUI

class MyDataManager {
    
    static let instance = MyDataManager()
    private init() {}
    
    var data: [String] = []
    private let lock = DispatchQueue(label: "com.MyApp.MYDataManager")
    
    func getRandomData(completionHandler: @escaping (_ title: String?) -> ()){
        lock.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
        }
    }
    
}

actor MyActorDataManager {
    
    static let instance = MyActorDataManager ()
    private init() {}
    
    var data: [String] = []
    private let lock = DispatchQueue(label: "com.MyApp.MYDataManager")
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return data.randomElement()
    }
    
    nonisolated
    func getSavedData() -> String {
        return "New data"
    }
    
}

struct HomeView: View {
    
    let manager = MyDataManager.instance
    let actorManager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onAppear {
//            Task {
//                let newString = await actorManager.getSavedData()
//            }
            let newString = actorManager.getSavedData()
        }
        .onReceive(timer) { _ in
            Task {
                if let data = await actorManager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
        }
    }
}

struct BrowseView: View {
    
    let manager = MyDataManager.instance
    let actorManager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            Task {
                if let data = await actorManager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
        }
    }
}

struct Actors: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

struct Actors_Previews: PreviewProvider {
    static var previews: some View {
        Actors()
    }
}
