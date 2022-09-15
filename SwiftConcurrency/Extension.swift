//
//  Extension.swift
//  SwiftConcurrency
//
//  Created by Дмитрий Болучевских on 14.09.2022.
//

import SwiftUI
import Combine

extension View {
    
    /// Modifier as .task in iOS 15
    func customTaskModifier(priority: TaskPriority = .utility, _ action: @escaping () async -> Void) -> some View {
        var task: Task<(), Never>? = nil
        return self
            .onAppear {
                task = Task {
                    await action()
                }
            }
            .onDisappear {
                task?.cancel()
            }
    }
}

extension Publisher where Failure == Never {
    
    /// get `AnyPublisher` from `Publisher` to work with `CustomAsyncPublisher`
    private var anyPublisher: AnyPublisher<Self.Output, Self.Failure> {
        self.eraseToAnyPublisher()
    }
    
    /// Should be work like .values in iOS 15+
    var customValues: CustomAsyncPublisher<AnyPublisher<Self.Output, Never>> {
        CustomAsyncPublisher<AnyPublisher>(anyPublisher)
    }
}
