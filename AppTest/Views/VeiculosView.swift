import SwiftUI

struct VeiculosView: View {
    struct VeiculoRow: View {
        let veiculo: Veiculo
        let onDelete: () -> Void
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text("Nome: \(veiculo.nome)")
                    Text("Tanque: \(veiculo.tanque)L")
                    Text("Etanol: \(String(format: "%.1f", veiculo.consumoEtanol)) km/L, Gasolina: \(String(format: "%.1f", veiculo.consumoGasolina)) km/L")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .imageScale(.medium)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
    }
    
    struct CalculadoraMediaView: View {
        @Binding var kmRodadosTexto: String
        @Binding var litrosConsumidosTexto: String
        @Binding var resultadoMedia: String
        
        var body: some View {
            VStack(spacing: 20) {
                Text("Calcular Média de Consumo")
                    .font(.title2)
                    .padding(.top)
                
                TextField("Distância percorrida (km)", text: $kmRodadosTexto)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                
                TextField("Combustível consumido (litros)", text: $litrosConsumidosTexto)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                
                Button("Calcular") {
                    calcularMedia()
                }
                
                if !resultadoMedia.isEmpty {
                    Text("Média: \(resultadoMedia)").font(.headline).padding()
                }
                Spacer()
            }
            .padding()
        }
        
        private func calcularMedia() {
            if let km = Float(kmRodadosTexto),
               let litros = Float(litrosConsumidosTexto),
               litros != 0 {
                let media = km / litros
                resultadoMedia = String(format: "%.2f km/L", media)
            } else {
                resultadoMedia = "Valores inválidos"
            }
        }
    }
    
    @State private var nome: String = ""
    @State private var tanque_Txt: String = ""
    @State private var consumoE_Txt: String = ""
    @State private var consumoG_Txt: String = ""
    @State private var mostrarAjuda = false
    @State private var kmRodadosTexto: String = ""
    @State private var litrosConsumidosTexto: String = ""
    @State private var resultadoMedia: String = ""
    @State private var mostrarFormulario = false
    @State private var listaVeiculos: [Veiculo] = []
    
    let storageKey = "veiculos_salvos"
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: { mostrarFormulario.toggle() }) {
                        Label("Novo Veículo", systemImage: "plus")
                            .font(.headline)
                    }
                    
                    if mostrarFormulario {
                        VStack {
                            TextField("Nome do Veículo", text: $nome)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Quantidade do tanque (L)", text: $tanque_Txt)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                            
                            TextField("Consumo Etanol (km/L)", text: $consumoE_Txt)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            
                            TextField("Consumo Gasolina (km/L)", text: $consumoG_Txt)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            
                            Button(action: adicionarVeiculo) {
                                Label("Adicionar", systemImage: "plus.circle.fill")
                                    .foregroundColor(.green)
                            }
                            .disabled(nome.trimmingCharacters(in: .whitespaces).isEmpty || 
                                    tanque_Txt.isEmpty || 
                                    consumoE_Txt.isEmpty || 
                                    consumoG_Txt.isEmpty)
                        }
                    }
                }
                
                Section {
                    ForEach(listaVeiculos) { veiculo in
                        VeiculoRow(veiculo: veiculo) {
                            removerVeiculo(id: veiculo.id)
                        }
                    }
                }
            }
            .navigationTitle("Veículos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { mostrarAjuda = true }) {
                        Image(systemName: "questionmark.circle")
                            .imageScale(.large)
                    }
                }
            }
        }
        .sheet(isPresented: $mostrarAjuda) {
            CalculadoraMediaView(
                kmRodadosTexto: $kmRodadosTexto,
                litrosConsumidosTexto: $litrosConsumidosTexto,
                resultadoMedia: $resultadoMedia
            )
        }
        .onAppear(perform: carregarVeiculos)
    }
    
    func adicionarVeiculo() {
        let veiculoLimpo = nome.trimmingCharacters(in: .whitespaces)
        guard !veiculoLimpo.isEmpty else { return }
        
        if let tanque = Int(tanque_Txt),
           let consumoE = Float(consumoE_Txt),
           let consumoG = Float(consumoG_Txt) {
            let veiculo = Veiculo(nome: nome, tanque: tanque, consumoEtanol: consumoE, consumoGasolina: consumoG)
            listaVeiculos.append(veiculo)
            limparCampos()
            salvarVeiculos()
        }
    }
    
    private func limparCampos() {
        nome = ""
        tanque_Txt = ""
        consumoE_Txt = ""
        consumoG_Txt = ""
        mostrarFormulario = false
    }
    
    func removerVeiculo(id: UUID) {
        listaVeiculos.removeAll { $0.id == id }
        salvarVeiculos()
    }
    
    func salvarVeiculos() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(listaVeiculos)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Erro ao salvar veículos: \(error)")
        }
    }
    
    func carregarVeiculos() {
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            do {
                let decoder = JSONDecoder()
                listaVeiculos = try decoder.decode([Veiculo].self, from: data)
            } catch {
                print("Erro ao carregar veículos: \(error)")
            }
        }
    }
}

#Preview {
    VeiculosView()
}
