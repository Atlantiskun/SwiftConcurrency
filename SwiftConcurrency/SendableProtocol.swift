//
//  SendableProtocol.swift
//  SwiftConcurrency
//
//  Created by Дмитрий Болучевских on 15.09.2022.
//

import SwiftUI

actor CurrentUserManager {
    
    func updateDatabase(userInfo: MyClassUserInfo) {
        
    }
    
}

struct MyUserInfo: Sendable {
    var name: String
}

final class MyClassUserInfo: @unchecked Sendable {
    private var name: String
    let lock = DispatchQueue(label: "com.MyApp.MyClassUserInfo")
    
    init(name: String) {
        self.name = name
    }
    
    func updateName(name: String) {
        lock.async {
            self.name = name
        }
    }
}

class SendableProtocolViewModel: ObservableObject {
    
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        let info = MyClassUserInfo(name: "info")
        await manager.updateDatabase(userInfo: info)
    }
    
}

struct SendableProtocol: View {
    
    @StateObject private var viewModel = SendableProtocolViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .customTaskModifier {
                await viewModel.updateCurrentUserInfo()
            }
    }
}

struct SendableProtocol_Previews: PreviewProvider {
    static var previews: some View {
        SendableProtocol()
    }
}
