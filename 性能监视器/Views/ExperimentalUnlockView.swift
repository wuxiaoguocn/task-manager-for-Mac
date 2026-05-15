import SwiftUI

struct ExperimentalUnlockView: View {
    @Binding var isUnlocked: Bool
    @State private var password = ""
    @State private var showError = false
    @State private var showWarning = false
    @State private var isVerified = false
    
    // The secret password
    private let correctPassword = "26;5-15'13'"
    
    var body: some View {
        VStack(spacing: 20) {
            if !isVerified {
                // Password input
                VStack(spacing: 16) {
                    Image(systemName: "flask.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.purple)
                    
                    Text("实验性功能")
                        .font(.title2.bold())
                    
                    Text("此功能需要验证才能开启")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    SecureField("请输入验证码", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                        .multilineTextAlignment(.center)
                    
                    if showError {
                        Text("验证码错误")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    
                    Button(action: verifyPassword) {
                        Text("验证")
                            .font(.headline)
                            .frame(width: 120)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(password.isEmpty)
                }
                .padding(24)
            } else if showWarning {
                // Warning message
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.red)
                    
                    Text("你确定要启用这个功能吗？")
                        .font(.title3.bold())
                        .foregroundStyle(.red)
                    
                    Text("实验性功能可能会导致系统和软件崩溃")
                        .font(.body)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                    
                    Text("⚠️ 不建议刘海屏用户启用")
                        .font(.headline)
                        .foregroundStyle(.red)
                        .padding(.top, 4)
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            isUnlocked = false
                            isVerified = false
                            showWarning = false
                            password = ""
                        }) {
                            Text("取消")
                                .font(.headline)
                                .frame(width: 100)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: {
                            isUnlocked = true
                        }) {
                            Text("确认启用")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(width: 100)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
        }
        .frame(width: 320)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()
        )
    }
    
    private func verifyPassword() {
        if password == correctPassword {
            showError = false
            isVerified = true
            showWarning = true
        } else {
            showError = true
        }
    }
}

#Preview {
    ExperimentalUnlockView(isUnlocked: .constant(false))
}
