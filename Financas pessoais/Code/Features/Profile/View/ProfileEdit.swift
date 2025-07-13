//
//  ProfileEdit.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 13/07/25.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let authManager = AuthenticationManager.shared
    
    init() {
        _name = State(initialValue: AuthenticationManager.shared.currentUser?.name ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informações Pessoais") {
                    // Profile Image
                    HStack {
                        Spacer()
                        
                        Button(action: { showingImagePicker = true }) {
                            Group {
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else if let imageData = authManager.currentUser?.profileImageData,
                                          let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(.blue)
                                }
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    TextField("Nome", text: $name)
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        saveProfile()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .alert("Erro", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveProfile() {
        Task {
            do {
                let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                try await authManager.updateProfile(name: name, profileImageData: imageData)
                dismiss()
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
        }
    }
}
