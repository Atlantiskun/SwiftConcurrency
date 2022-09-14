//
//  TaskAW.swift
//  SwiftConcurrency
//
//  Created by Дмитрий Болучевских on 14.09.2022.
//

import SwiftUI

class TaskAWViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        do {
            // if lorem.space get trouble
//            guard let url = URL(string: "https://stickerly.pstatic.net/sticker_pack/PQEbA06NLcQ7reKUeFtK0g/9I87N5/2/08cebe44-befc-4883-b0a8-913d0225db72.png") else { return }
            guard let url = URL(string: "https://api.lorem.space/image/drink?w=200&h=200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run {
                self.image = UIImage(data: data)
                print("IMAGE RETURNED SUCCESSFULLY")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://api.lorem.space/image/drink?w=200&h=200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run {
                self.image2 = UIImage(data: data)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

struct TaskAWHomeView: View {
    
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink {
                    TaskAW()
                } label: {
                    Text("Click me")
                }

            }
        }
    }
}

struct TaskAW: View {
    
    @StateObject private var viewModel = TaskAWViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .customTaskModifier {
            await viewModel.fetchImage()
        }
//        .onDisappear {
//            fetchImageTask?.cancel()
//        }
//        .onAppear {
//            fetchImageTask = Task {
////                print(Thread.current)
////                print(Task.currentPriority)
//                await viewModel.fetchImage()
//            }
////
////            Task {
////                print(Thread.current)
////                print(Task.currentPriority)
////                await viewModel.fetchImage2()
////            }
//
////            Task(priority: .low) {
////                print("Low : \(Thread.current) : \(Task.currentPriority)")
////            }
////
////            Task(priority: .medium) {
////                print("Medium : \(Thread.current) : \(Task.currentPriority)")
////            }
////
////            Task(priority: .high) {
//////                try? await Task.sleep(nanoseconds: 2_000_000_000)
////                await Task.yield()
////                print("High : \(Thread.current) : \(Task.currentPriority)")
////            }
////
////            Task(priority: .background) {
////                print("Background : \(Thread.current) : \(Task.currentPriority)")
////            }
////
////            Task(priority: .utility) {
////                print("Utility : \(Thread.current) : \(Task.currentPriority)")
////            }
//
////            Task(priority: .userInitiated) {
////                print("UserInitiated : \(Thread.current) : \(Task.currentPriority)")
////
////                Task.detached {
////                    print("detached : \(Thread.current) : \(Task.currentPriority)")
////                }
////            }
//
//        }
    }
}

struct TaskAW_Previews: PreviewProvider {
    static var previews: some View {
        TaskAW()
    }
}
