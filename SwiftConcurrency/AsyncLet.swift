//
//  AsyncLet.swift
//  SwiftConcurrency
//
//  Created by Дмитрий Болучевских on 14.09.2022.
//

import SwiftUI

struct AsyncLet: View {
    
    @State private var images: [UIImage] = []
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://loremflickr.com/320/240")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Async let 🥳")
            .onAppear {
                Task {
                    do {
                        
                        async let fetchImage1 = fetchImage()
                        async let fetchImage2 = fetchImage()
                        async let fetchImage3 = fetchImage()
                        async let fetchImage4 = fetchImage()

                        let (image1, image2, image3, image4) = try await (fetchImage1, fetchImage2, fetchImage3, fetchImage4)
                        self.images.append(contentsOf: [image1, image2, image3, image4])
                        
//                        let image1 = try await fetchImage()
//                        self.images.append(image1)
//
//                        let image2 = try await fetchImage()
//                        self.images.append(image2)
//
//                        let image3 = try await fetchImage()
//                        self.images.append(image3)
//
//                        let image4 = try await fetchImage()
//                        self.images.append(image4)
                        
                    } catch {
                        
                    }
                }
            }
        }
    }
    
    func fetchTitle() async -> String {
        return "New tittle"
    }
    
    func fetchImage() async throws -> UIImage {
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

struct AsyncLet_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLet()
    }
}
