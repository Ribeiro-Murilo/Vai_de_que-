import SwiftUI

struct RelatoriosView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Relatórios e Estatísticas")
                    .font(.title)
                    .padding()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .imageScale(.large)
                    .foregroundStyle(.blue)
                    .padding()
                
                List {
                    NavigationLink(destination: VeiculosView()) {
                        Text("Veículos")
                    }
                    NavigationLink(destination: RelatorioGastosView()) {
                        Text("Relatório de Gastos")
                    }
                    NavigationLink(destination: RelatorioConsumoView()) {
                        Text("Relatório de Consumo")
                    }
                    Text("Histórico de Abastecimento").opacity(0.4)
                }
            }
            .navigationTitle("Relatórios")
        }
    }
}

#Preview {
    RelatoriosView()
}
