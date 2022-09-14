//
//  Extension.swift
//  SwiftConcurrency
//
//  Created by Дмитрий Болучевских on 14.09.2022.
//

import SwiftUI

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
