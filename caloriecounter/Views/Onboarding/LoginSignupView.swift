//
//  LoginSignupView.swift
//  caloriecounter
//
//  Created by Sam Roman on 1/10/24.
//

import SwiftUI

import SwiftUI

struct LoginSignupView: View {
    @State private var isShowingLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
        
    var onLoginSuccess: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                Text(isShowingLogin ? "Login" : "Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                if !isShowingLogin {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }

                Button(action: {
                   onLoginSuccess()
                }) {
                    Text(isShowingLogin ? "Login" : "Create Account")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.carrot)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                Button(action: {
                    isShowingLogin.toggle()
                }) {
                    Text(isShowingLogin ? "Need an account? Sign up" : "Already have an account? Login")
                        .font(.footnote)
                        .foregroundColor(AppTheme.lime)
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding(.top, 50)
        }
    }
}

// Preview
//struct LoginSignupView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginSignupView()
//    }
//}
//
//
//#Preview {
//    LoginSignupView()
//}
