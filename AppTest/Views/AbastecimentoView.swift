import SwiftUI

extension View {
    func esconderTecladoAoTocar() -> some View {
        return self.background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                  to: nil, from: nil, for: nil)
                }
        )
    }
}

struct SeletorVeiculoView: View {
    let veiculos: [Veiculo]
    @Binding var veiculoSelecionado: Veiculo?
    
    var body: some View {
        if !veiculos.isEmpty {
            Picker("Veículo", selection: $veiculoSelecionado) {
                ForEach(veiculos, id: \.self) { veiculo in
                    Text(veiculo.nome).tag(Optional(veiculo))
                }
            }
            .pickerStyle(MenuPickerStyle())
        } else {
            Text("Nenhum veículo cadastrado")
                .foregroundColor(.red)
        }
    }
}

struct FormularioAbastecimentoView: View {
    @Binding var tipoCombustivelAtual: TipoCombustivel
    @Binding var tipoCombustivelAntigo: TipoCombustivel
    @Binding var litros: String
    @Binding var valorLitro: String
    @Binding var quilometragem: String
    let onSubmit: () -> Void
    let isValid: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Combustível Atual")
                .font(.headline)
                .padding(.bottom, 5)
            
            Picker("Combustível Atual", selection: $tipoCombustivelAtual) {
                Text("Etanol").tag(TipoCombustivel.etanol)
                Text("Gasolina").tag(TipoCombustivel.gasolina)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Text("Combustível Anterior")
                .font(.headline)
                .padding(.bottom, 5)
            
            Picker("Combustível Anterior", selection: $tipoCombustivelAntigo) {
                Text("Etanol").tag(TipoCombustivel.etanol)
                Text("Gasolina").tag(TipoCombustivel.gasolina)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Quantidade abastecida")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    TextField("Litros", text: $litros)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Preço por litro")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    TextField("Valor por litro", text: $valorLitro)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Quilometragem atual")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    TextField("Quilometragem", text: $quilometragem)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
            }
            .padding(.vertical)
            .esconderTecladoAoTocar()
            
            Button(action: onSubmit) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Registrar Abastecimento")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isValid ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .esconderTecladoAoTocar()
            .disabled(!isValid)
        }
        .esconderTecladoAoTocar()
    }
}

struct HistoricoAbastecimentoView: View {
    let abastecimento: Abastecimento
    let veiculo: Veiculo?
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let veiculo = veiculo {
                Text("Veículo: \(veiculo.nome)")
                    .font(.headline)
            }
            Text("Data: \(formatarData(abastecimento.data))")
                .font(.subheadline)
            HStack {
                VStack(alignment: .leading) {
                    Text("Combustível:")
                    Text("Anterior: \(abastecimento.tipoCombustivelAntigo.rawValue)")
                    Text("Atual: \(abastecimento.tipoCombustivelAtual.rawValue)")
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(String(format: "%.2f", abastecimento.litros))L")
                    Text("R$ \(String(format: "%.2f", abastecimento.valorLitro))/L")
                    Text("\(String(format: "%.1f", abastecimento.quilometragem)) km")
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 15) {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .imageScale(.medium)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .shadow(radius: 1)
            }
        }
        .padding(.vertical, 5)
    }
    
    private func formatarData(_ data: Date) -> String {
        let formatador = DateFormatter()
        formatador.dateStyle = .short
        formatador.timeStyle = .short
        return formatador.string(from: data)
    }
}

struct AbastecimentoView: View {
    @State private var veiculos: [Veiculo] = []
    @State private var veiculoSelecionado: Veiculo?
    @State private var abastecimentos: [Abastecimento] = []
    
    @State private var tipoCombustivelAtual: TipoCombustivel = .etanol
    @State private var tipoCombustivelAntigo: TipoCombustivel = .etanol
    @State private var litros: String = ""
    @State private var valorLitro: String = ""
    @State private var quilometragem: String = ""
    @State private var mostrarFormulario: Bool = false
    
    let storageKeyVeiculo = "veiculos_salvos"
    let storageKeyAbastecimento = "abastecimentos_salvos"
    var body: some View {
        NavigationView {
            Form {
                // Seção para seleção do veículo
                Section(header: Text("Selecionar Veículo")) {
                    SeletorVeiculoView(
                        veiculos: veiculos,
                        veiculoSelecionado: $veiculoSelecionado
                    )
                }
                
                // Se o veículo for selecionado, mostra o botão e, opcionalmente, o formulário
                if veiculoSelecionado != nil {
                        Button(action: {
                            withAnimation {
                                mostrarFormulario.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: mostrarFormulario ? "xmark.circle.fill" : "plus.circle.fill")
                                Text(mostrarFormulario ? "Cancelar" : "Novo abastecimento")
                            }
                        }
                        .padding(.horizontal)
                        .foregroundColor(mostrarFormulario ? .red : .blue)
                    
                    
                    if mostrarFormulario {
                        Section(header: Text("Dados do Abastecimento")) {
                            FormularioAbastecimentoView(
                                tipoCombustivelAtual: $tipoCombustivelAtual,
                                tipoCombustivelAntigo: $tipoCombustivelAntigo,
                                litros: $litros,
                                valorLitro: $valorLitro,
                                quilometragem: $quilometragem,
                                onSubmit: {
                                    adicionarAbastecimento()
                                    withAnimation {
                                        mostrarFormulario = false
                                    }
                                },
                                isValid: camposValidos
                            )
                        }
                    }
                }
                if !abastecimentos.isEmpty {
                    Section(header: Text("Histórico")) {
                        ForEach(abastecimentosFiltrados) { abastecimento in
                            HistoricoAbastecimentoView(
                                abastecimento: abastecimento,
                                veiculo: veiculos.first { $0.id == abastecimento.veiculoId },
                                onDelete: { removerAbastecimento(abastecimento: abastecimento) }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Abastecimento")
            .esconderTecladoAoTocar()
        }
        .onAppear {
            carregarDados()
        }
    }

    
    private var camposValidos: Bool {
        guard let _ = Float(litros.replacingOccurrences(of: ",", with: ".")),
              let _ = Float(valorLitro.replacingOccurrences(of: ",", with: ".")),
              let _ = Float(quilometragem.replacingOccurrences(of: ",", with: ".")),
              veiculoSelecionado != nil else {
            return false
        }
        return true
    }
    
    private var abastecimentosFiltrados: [Abastecimento] {
        guard let veiculoId = veiculoSelecionado?.id else { return [] }
        return abastecimentos
            .filter { $0.veiculoId == veiculoId }
            .sorted { $0.data > $1.data }
    }
    
    private func adicionarAbastecimento() {
        guard let veiculo = veiculoSelecionado,
              let litrosFloat = Float(litros.replacingOccurrences(of: ",", with: ".")),
              let valorFloat = Float(valorLitro.replacingOccurrences(of: ",", with: ".")),
              let kmFloat = Float(quilometragem.replacingOccurrences(of: ",", with: ".")) else {
            return
        }
        
        let novoAbastecimento = Abastecimento(
            veiculoId: veiculo.id,
            tipoCombustivelAtual: tipoCombustivelAtual,
            tipoCombustivelAntigo: tipoCombustivelAntigo,
            litros: litrosFloat,
            valorLitro: valorFloat,
            quilometragem: kmFloat
        )
        
        abastecimentos.append(novoAbastecimento)
        salvarAbastecimentos()
        limparCampos()
    }
    
    private func limparCampos() {
        litros = ""
        valorLitro = ""
        quilometragem = ""
        dismissKeyboard()
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
    }
    
    private func carregarDados() {
        carregarVeiculos()
        carregarAbastecimentos()
    }
    
    private func carregarVeiculos() {
        if let data = UserDefaults.standard.data(forKey: storageKeyVeiculo) {
            do {
                let decoded = try JSONDecoder().decode([Veiculo].self, from: data)
                self.veiculos = decoded
                if veiculoSelecionado == nil {
                    self.veiculoSelecionado = decoded.first
                }
            } catch {
                print("Erro ao decodificar veículos:", error)
            }
        }
    }
    
    private func carregarAbastecimentos() {
        if let data = UserDefaults.standard.data(forKey: storageKeyAbastecimento) {
            do {
                let decoded = try JSONDecoder().decode([Abastecimento].self, from: data)
                self.abastecimentos = decoded
            } catch {
                print("Erro ao decodificar abastecimentos:", error)
            }
        }
    }
    
    private func salvarAbastecimentos() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(abastecimentos)
            UserDefaults.standard.set(data, forKey: storageKeyAbastecimento)
        } catch {
            print("Erro ao salvar abastecimentos:", error)
        }
    }
    
    private func removerAbastecimento(abastecimento: Abastecimento) {
        abastecimentos.removeAll { $0.id == abastecimento.id }
        salvarAbastecimentos()
    }
}

#Preview {
    AbastecimentoView()
}
