import SwiftUI
import Charts

struct RelatorioConsumoView: View {
    @State private var veiculos: [Veiculo] = []
    @State private var abastecimentos: [Abastecimento] = []
    @State private var veiculoSelecionado: Veiculo?
    
    let storageKeyVeiculo = "veiculos_salvos"
    let storageKeyAbastecimento = "abastecimentos_salvos"
    
    struct DadosGrafico: Identifiable, Hashable {
        let id = UUID()
        let data: Date
        let valor: Float
        let litros: Float
        let tipo: String
        let consumoPL: Float
        let KmPL: Float
    }
    
    private var dadosFiltrados: [DadosGrafico] {
        guard let veiculoId = veiculoSelecionado?.id else { return [] }
        return abastecimentos
            .filter { $0.veiculoId == veiculoId }
            .map { abastecimento in
                DadosGrafico(
                    data: abastecimento.data,
                    valor: abastecimento.valorLitro * abastecimento.litros,
                    litros: abastecimento.litros,
                    tipo: abastecimento.tipoCombustivelAtual.rawValue,
                    consumoPL: abastecimento.quilometragem / abastecimento.litros,
                    KmPL: abastecimento.quilometragem / (abastecimento.litros * abastecimento.valorLitro)
                )
            }
            .sorted { $0.data < $1.data }
    }
    
    private var totalGasto: Float {
        dadosFiltrados.reduce(0) { $0 + $1.valor }
    }
    
    private var mediaGastosPorAbastecimento: Float {
        guard !dadosFiltrados.isEmpty else { return 0 }
        return totalGasto / Float(dadosFiltrados.count)
    }
    
    private var totalLitros: Float {
        dadosFiltrados.reduce(0) { $0 + $1.litros }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    seletorVeiculo
                    if veiculoSelecionado != nil {
                        cartoesResumo
                        graficoConsumo
                    } else {
                        Text("Selecione um veículo para ver as estatísticas")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .navigationTitle("Relatório de Consumo")
            .onAppear {
                carregarDados()
            }
        }
    }
    
    private var seletorVeiculo: some View {
        Picker("Veículo", selection: $veiculoSelecionado) {
            Text("Selecione um veículo").tag(Optional<Veiculo>.none)
            ForEach(veiculos, id: \.self) { veiculo in
                Text(veiculo.nome).tag(Optional(veiculo))
            }
        }
        .pickerStyle(MenuPickerStyle())
        .padding()
    }
    
    private var cartoesResumo: some View {
        HStack {
            EstatisticaCardConsumo(
                titulo: "Total Gasto",
                valor: String(format: "R$ %.2f", totalGasto),
                icone: "dollarsign.circle.fill"
            )
            
            EstatisticaCardConsumo(
                titulo: "Média/Abast.",
                valor: String(format: "R$ %.2f", mediaGastosPorAbastecimento),
                icone: "chart.bar.fill"
            )
            
            EstatisticaCardConsumo(
                titulo: "Total Litros",
                valor: String(format: "%.1f L", totalLitros),
                icone: "drop.fill"
            )
        }
        .padding(.horizontal)
    }
    
    private var graficoConsumo: some View {
        VStack(alignment: .leading) {
            Text("Consumo")
                .font(.headline)
                .padding(.leading)
            
            Chart {
                ForEach(dadosFiltrados) { dado in
                    BarMark(
                        x: .value("Data", dado.data),
                        y: .value("KM/L", dado.consumoPL)
                    )
                    .foregroundStyle(by: .value("Métrica", "Consumo (KM/L)"))
                    
                    LineMark(
                        x: .value("Data", dado.data),
                        y: .value("KM/R$", dado.KmPL)
                    )
                    .foregroundStyle(by: .value("Métrica", "Eficiência (KM/R$)"))
                }
            }
            .frame(height: 200)
            .chartForegroundStyleScale([
                "Consumo (KM/L)": Color.blue,
                "Eficiência (KM/R$)": Color.red
            ])
            .chartLegend(position: .top, alignment: .center)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(formatarData(date))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding()
    }
    
    private func formatarData(_ data: Date) -> String {
        let formatador = DateFormatter()
        formatador.dateFormat = "dd/MM"
        return formatador.string(from: data)
    }
    
    private func carregarDados() {
        if let data = UserDefaults.standard.data(forKey: storageKeyVeiculo) {
            do {
                veiculos = try JSONDecoder().decode([Veiculo].self, from: data)
            } catch {
                print("Erro ao carregar veículos:", error)
            }
        }
        
        if let data = UserDefaults.standard.data(forKey: storageKeyAbastecimento) {
            do {
                abastecimentos = try JSONDecoder().decode([Abastecimento].self, from: data)
            } catch {
                print("Erro ao carregar abastecimentos:", error)
            }
        }
    }
}

struct EstatisticaCardConsumo: View {
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
    RelatorioConsumoView()
}
