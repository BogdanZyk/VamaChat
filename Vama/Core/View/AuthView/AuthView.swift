//
//  AuthView.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import SwiftUI

struct AuthView: View {
    @ObservedObject var authVM: AuthenticationViewModel
    @State private var showSingIn: Bool = true
    @State private var email: String = ""
    @State private var pass: String = ""
    @State private var nickname: String = ""

    var body: some View {
        
        VStack(spacing: 10){
            Text("Vama chat")
                .font(.largeTitle.bold())
            Text("\(showSingIn ? "Sign In" : "Sing Up") with Email")
                .font(.title3)
            LoginForm(email: $email, pass: $pass, nickname: $nickname, showSingIn: $showSingIn, showLoader: authVM.showLoader, isDisabledButton: !isValid, onTabButton: onTapButton)
                .padding(.top, 10)
        }
        .padding()
        .disabled(authVM.showLoader)
        .handle(error: $authVM.error)
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(authVM: AuthenticationViewModel())
    }
}

extension AuthView{
    
    
    private var isValid: Bool{
        showSingIn ? (
            !email.isEmpty && !pass.isEmpty
        ) : (!email.isEmpty && !pass.isEmpty && !nickname.isEmpty)
    }
    
    private func onTapButton(){
        
        guard isValid else {return}
        
        Task{
            if showSingIn{
                await authVM.singInWithEmail(email: email, pass: pass)
            }else{
                await authVM.singUpWithEmail(email: email, pass: pass, nickname: nickname)
            }
        }
    }
}



extension AuthView{
    
    
    struct LoginForm: View{
        @Binding var email: String
        @Binding var pass: String
        @Binding var nickname: String
        @Binding var showSingIn: Bool
        var showLoader: Bool
        var isDisabledButton: Bool
        let onTabButton: () -> Void
        var body: some View{
            
            VStack{
                Group{
                    if !showSingIn{
                        TextField("Nickname", text: $nickname)
                    }
                    TextField("Email", text: $email)
                    SecureField("Password", text: $pass)
                }
                .padding()
                .background(Color(nsColor: .darkGray), in: RoundedRectangle(cornerRadius: 10))
                .textFieldStyle(.plain)
                Button {
                    onTabButton()
                } label: {
                    Group{
                        if showLoader{
                            ProgressView()
                                .tint(.white)
                        }else{
                            Text(showSingIn ? "Sign In" : "Sign Up")
                        }
                    }
                    .hCenter()
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .background(.blue)
                    .cornerRadius(10)
                }
                .padding(.top, 20)
                .buttonStyle(.plain)
                .disabled(isDisabledButton)
                
                Button {
                    showSingIn.toggle()
                } label: {
                    Text(showSingIn ? "No account, Sign Up" : "Already have an account? Sign In")
                }
                .buttonStyle(.plain)
            }
            .frame(width: 400)
        }
    }
    
}
