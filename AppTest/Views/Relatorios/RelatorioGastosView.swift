import SwiftUI
import Charts

struct RelatorioGastosView: View {
    @State private var veiculos: [Veiculo] = []
    @State private var abastecimentos: [Abastecimento] = []
    @State private var veiculoSelecionado: Veiculo?
    
    let storageKeyVeiculo = "veiculos_salvos"
    let storageKeyAbastecimento = "abastecimentos_salvos"
    
    struct DadosGrafico: Identifiable {
        let id = UUID()
        let data: Date
        let valor: Float
        let litros: Float
        let tipo: String
    }
    
    var dadosFiltrados: [DadosGrafico] {
        guard let veiculoId = veiculoSelecionado?.id else { return [] }
        return abastecimentos
            .filter { $0.veiculoId == veiculoId }
            .map { abastecimento in
                DadosGrafico(
                    data: abastecimento.data,
                    valor: abastecimento.valorLitro * abastecimento.litros,
                    litros: abastecimento.litros,
                    tipo: abastecimento.tipoCombustivelAtual.rawValue
                )
            }
            .sorted { $0.data < $1.data }
    }
    
    var totalGasto: Float {
        dadosFiltrados.reduce(0) { $0 + $1.valor }
    }
    
    var mediaGastosPorAbastecimento: Float {
        guard !dadosFiltrados.isEmpty else { return 0 }
        return totalGasto / Float(dadosFiltrados.count)
    }
    
    var totalLitros: Float {
        dadosFiltrados.reduce(0) { $0 + $1.litros }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Seletor de Veículo
                    Picker("Veículo", selection: $veiculoSelecionado) {
                        Text("Selecione um veículo").tag(Optional<Veiculo>.none)
                        ForEach(veiculos, id: \.self) { veiculo in
                            Text(veiculo.nome).tag(Optional(veiculo))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    
                    if let _ = veiculoSelecionado {
                        // Cartões de Resumo
                        HStack {
                            EstatisticaCard(
                                titulo: "Total Gasto",
                                valor: String(format: "R$ %.2f", totalGasto),
                                icone: "dollarsign.circle.fill"
                            )
                            
                            EstatisticaCard(
                                titulo: "Média/Abast.",
                                valor: String(format: "R$ %.2f", mediaGastosPorAbastecimento),
                                icone: "chart.bar.fill"
                            )
                            
                            EstatisticaCard(
                                titulo: "Total Litros",
                                valor: String(format: "%.1f L", totalLitros),
                                icone: "drop.fill"
                            )
                        }
                        .padding(.horizontal)
                        
                        // Gráfico de Gastos
                        VStack(alignment: .leading) {
                            Text("Evolução dos Gastos")
                                .font(.headline)
                                .padding(.leading)
                            
                            Chart(dadosFiltrados) { dado in
                                LineMark(
                                    x: .value("Data", dado.data),
                                    y: .value("Valor", dado.valor)
                                )
                                .foregroundStyle(by: .value("Tipo", dado.tipo))
                                
                                PointMark(
                                    x: .value("Data", dado.data),
                                    y: .value("Valor", dado.valor)
                                )
                                .foregroundStyle(by: .value("Tipo", dado.tipo))
                            }
                            .frame(height: 200)
                            .padding()
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .padding()
                        
                        // Gráfico de Consumo
                        VStack(alignment: .leading) {
                            Text("Consumo por Tipo")
                                .font(.headline)
                                .padding(.leading)
                            
                            Chart(dadosFiltrados) { dado in
                                BarMark(
                                    x: .value("Tipo", dado.tipo),
                                    y: .value("Litros", dado.litros)
                                )
                                .foregroundStyle(by: .value("Tipo", dado.tipo))
                            }
                            .frame(height: 200)
                            .padding()
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .padding()
                    } else {
                        Text("Selecione um veículo para ver as estatísticas")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .navigationTitle("Relatório de Gastos")
            .onAppear {
                carregarDados()
            }
        }
    }
    
    private func carregarDados() {
        // Carregar veículos
        if let data = UserDefaults.standard.data(forKey: storageKeyVeiculo) {
            do {
                veiculos = try JSONDecoder().decode([Veiculo].self, from: data)
            } catch {
                print("Erro ao carregar veículos:", error)
            }
        }
        
        // Carregar abastecimentos
        if let data = UserDefaults.standard.data(forKey: storageKeyAbastecimento) {
            do {
                abastecimentos = try JSONDecoder().decode([Abastecimento].self, from: data)
            } catch {
                print("Erro ao carregar abastecimentos:", error)
            }
        }
    }
}

struct EstatisticaCard: View {
    let titulo: String
    let valor: String
    let icone: String
    
    var body: some View {
        VStack {
            Image(systemName: icone)
                .font(.title)
                .foregroundColor(.blue)
            Text(titulo)
                .font(.caption)
                .foregroundColor(.gray)
            Text(valor)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    RelatorioGastosView()
}
