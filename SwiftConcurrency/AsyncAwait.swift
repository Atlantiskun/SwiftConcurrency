//
//  AsyncAwait.swift
//  SwiftConcurrency
//
//  Created by Дмитрий Болучевских on 14.09.2022.
//

import SwiftUI

class AsyncAwaitViewModel: ObservableObject {
    
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("Tittle1 : \(Thread.current)")
        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title = "Tittle2 : \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArray.append(title)
                
                let title3 = "Tittle3 : \(Thread.current)"
                self.dataArray.append(title3)
            }
        }
    }
    
    func addAuthor1() async {
        // async-функции могут быть выполнены на любом потоке, но, чтобы изменять данные в главном потоке, мы должны вызвать сначала MainActor
        await MainActor.run {
            let author1 = "Author1 : \(Thread.current)" // Всегда будет main
            self.dataArray.append(author1)
        }
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2 = "Author2 : \(Thread.current)" // Всегда будет случайным
        await MainActor.run(body: {
            self.dataArray.append(author2)
            
            let author3 = "Author3 : \(Thread.current)" // Всегда будет main
            self.dataArray.append(author3)
        })
        
        await addSomethind()
    }
    
    func addSomethind() async {
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let something1 = "Something 1 : \(Thread.current)" // Всегда будет случайным
        await MainActor.run(body: {
            self.dataArray.append(something1)
            
            let something2 = "Something 2 : \(Thread.current)" // Всегда будет main
            self.dataArray.append(something2)
        })
    }
}

struct AsyncAwait: View {
    
    @StateObject private var viewModel = AsyncAwaitViewModel()
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            Task {
                await viewModel.addAuthor1()
                await viewModel.addSomethind()
                
                let finalText = "FINAL TEXT : \(Thread.current)"
                viewModel.dataArray.append(finalText)
            }
        }
    }
}

struct AsyncAwait_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwait()
    }
}
