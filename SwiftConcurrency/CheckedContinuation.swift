//
//  CheckedContinuation.swift
//  SwiftConcurrency
//
//  Created by Дмитрий Болучевских on 15.09.2022.
//

import SwiftUI

class CheckedContinuationNetworkManager {
    
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw error
        }
    }
    
    func getData2(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }
    
    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    func getHeartImageFromDataBase() async -> UIImage {
        return await withCheckedContinuation({ continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        })
    }
    
}

class CheckedContinuationViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let networkManager = CheckedContinuationNetworkManager()
    
    func getImage() async {
        guard let url = URL(string: "https://loremflickr.com/320/240") else { return }
        
        do {
            let data = try await networkManager.getData2(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run(body: {
                    self.image = image
                })
            }
        } catch {
            print(error)
        }
    }
    
    func getHeartImage() async {
        let image = await networkManager.getHeartImageFromDataBase()
        await MainActor.run(body: {
            self.image = image
        })
    }
    
}

struct CheckedContinuation: View {
    
    @StateObject private var viewModel = CheckedContinuationViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .customTaskModifier {
//            await viewModel.getImage()
            await viewModel.getHeartImage()
        }
    }
}

struct CheckedContinuation_Previews: PreviewProvider {
    static var previews: some View {
        CheckedContinuation()
    }
}
