//
//  TaskGroup.swift
//  SwiftConcurrency
//
//  Created by Дмитрий Болучевских on 14.09.2022.
//

import SwiftUI

class TaskGroupDataManager {
    
    func fetchImagesAsyncLet() async throws -> [UIImage] {
        async let fetchImage1 = fetchImage(urlString: "https://loremflickr.com/320/240")
        async let fetchImage2 = fetchImage(urlString: "https://loremflickr.com/320/240")
        async let fetchImage3 = fetchImage(urlString: "https://loremflickr.com/320/240")
        async let fetchImage4 = fetchImage(urlString: "https://loremflickr.com/320/240")
        
        let (image1, image2, image3, image4) = try await (fetchImage1, fetchImage2, fetchImage3, fetchImage4)
        return [image1, image2, image3, image4]
    }
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        
        let urlStrings = [
            "https://loremflickr.com/320/240",
            "https://loremflickr.com/320/240",
            "https://loremflickr.com/320/240",
            "https://loremflickr.com/320/240",
            "https://loremflickr.com/320/240",
            "https://loremflickr.com/320/240",
        ]
        
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = []
            images.reserveCapacity(urlStrings.count)
            
            for urlString in urlStrings {
                group.addTask {
                    try? await self.fetchImage(urlString: urlString)
                }
            }
            
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            
            return images
        }
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}

class TaskGroupViewModel: ObservableObject {
    
    @Published var images: [UIImage] = []
    let manager = TaskGroupDataManager()
    
    func getImages() async {
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            await MainActor.run(body: {
                self.images.append(contentsOf: images)
            })
            
        }
    }
}

struct TaskGroup: View {
    
    @StateObject private var viewModel = TaskGroupViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Async let 🥳")
            .customTaskModifier {
                await viewModel.getImages()
            }
        }
    }
}

struct TaskGroup_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroup()
    }
}
