//
//  ProfileView.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 13/07/25.
//

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    
    private let authManager = AuthenticationManager.shared
    private let firebaseService = FirebaseService.shared
    
    var body: some View {
        NavigationView {
            List {
                // User Info Section
                Section {
                    HStack {
                        // Profile Image
                        Group {
                            if let imageData = authManager.currentUser?.profileImageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(authManager.currentUser?.name ?? "Usuário")
                                .font(.headline)
                            
                            Text(authManager.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Editar") {
                            showingEditProfile = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 8)
                }
                
                // Menu Options
                Section {
                    NavigationLink(destination: SettingsView()) {
                        Label("Configurações", systemImage: "gearshape.fill")
                    }
                    
                    NavigationLink(destination: Text("Relatórios em breve")) {
                        Label("Relatórios", systemImage: "chart.bar.fill")
                    }
                    
                    NavigationLink(destination: Text("Ajuda em breve")) {
                        Label("Ajuda", systemImage: "questionmark.circle.fill")
                    }
                }
                
                // Sign Out
                Section {
                    Button(action: signOut) {
                        Label("Sair", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Perfil")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
        }
    }
    
    private func signOut() {
        authManager.signOut()
    }
}
