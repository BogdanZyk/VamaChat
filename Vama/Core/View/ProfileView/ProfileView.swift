//
//  ProfileView.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationViewModel
    @EnvironmentObject var userManager: UserManager
    var body: some View {
        VStack {
            
            Label {
                Text(userManager.user?.firstName ?? "Non")
            } icon: {
                Text("firstName")
               
            }
            
            Label {
                Text(userManager.user?.username ?? "Non")
            } icon: {
                Text("username")
               
            }

            Button("Sing Out") {
                authManager.singOut()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(UserManager())
    }
}
