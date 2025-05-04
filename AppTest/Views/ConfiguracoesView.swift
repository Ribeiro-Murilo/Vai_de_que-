import SwiftUI

struct ConfiguracoesView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Preferências")) {
                    NavigationLink(destination: VeiculosView()) {
                        Text("Veículos")
                    }
                    Text("Outro").opacity(0.4)
                }

                Section(header: Text("Conta")) {
                    Text("Perfil").opacity(0.4)
                    Text("Segurança").opacity(0.4)
                }

                Section(header: Text("Sobre")) {
                    Text("Versão do App").opacity(0.4)
                    Text("Política de Privacidade").opacity(0.4)
                    Text("Termos de Uso").opacity(0.4)
                }
            }
            .navigationTitle("Configurações")
        }
    }
}


#Preview {
    ConfiguracoesView()
}
