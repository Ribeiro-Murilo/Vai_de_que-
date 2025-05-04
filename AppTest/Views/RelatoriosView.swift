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
                    Text("Relatório de Consumo")
                    Text("Relatório de Gastos")
                    Text("Histórico de Abastecimento")
                }
            }
            .navigationTitle("Relatórios")
        }
    }
}

#Preview {
    ContentView()
} 
