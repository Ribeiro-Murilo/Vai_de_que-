import SwiftUI

struct CombustivelView: View {
    @State private var valorEtanol: String = ""
    @State private var valorGasolina: String = ""
    @State private var veiculos: [Veiculo] = []
    @State private var veiculoSelecionado: Veiculo?
    @State private var resultadoCalculo: String = ""

    let storageKeyVeiculo = "veiculos_salvos"
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .center) {
                    Image(systemName: "fuelpump.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                        .padding(.top, 20)

                    Text("Informe os valores dos combustíveis")
                        .font(.subheadline)
                        .padding(.top, 5)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 30)

                if !veiculos.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Selecione o veículo")
                            .font(.headline)

                        Picker("Selecione o veículo", selection: $veiculoSelecionado) {
                            ForEach(veiculos, id: \.self) { veiculo in
                                Text(veiculo.nome).tag(Optional(veiculo))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                } else {
                    Text("Nenhum veículo cadastrado")
                        .foregroundColor(.red)
                        .padding()
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Valor do Etanol")
                        .font(.headline)
                    TextField("Digite o valor do etanol", text: $valorEtanol)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Valor da Gasolina")
                        .font(.headline)
                    TextField("Digite o valor da gasolina", text: $valorGasolina)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }

                Button(action: calcularMelhorCombustivel) {
                    Text("Calcular")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(veiculoSelecionado == nil || valorEtanol.isEmpty || valorGasolina.isEmpty)
                .padding(.top)
                .esconderTecladoAoTocar()

                if !resultadoCalculo.isEmpty {
                    Text(resultadoCalculo)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Combustível")
            .onAppear {
                carregarVeiculos()
            }
        }
    }

    private func calcularMelhorCombustivel() {
        dismissKeyboard();
        guard let veiculo = veiculoSelecionado,
              let precoEtanol = Float(valorEtanol.replacingOccurrences(of: ",", with: ".")),
              let precoGasolina = Float(valorGasolina.replacingOccurrences(of: ",", with: ".")) else {
            resultadoCalculo = "Valores inválidos"
            return
        }

        let relacao = precoEtanol / precoGasolina
        let eficiencia = veiculo.consumoEtanol / veiculo.consumoGasolina

        if relacao < eficiencia {
            resultadoCalculo = "Melhor abastecer com ETANOL"
        } else if relacao > eficiencia {
            resultadoCalculo = "Melhor abastecer com GASOLINA"
        } else{
            resultadoCalculo = "Não há diferença significativa no abastecimento"
        }

        // Adicionar detalhes do cálculo
        let detalhes = String(format: "\nRelação de preço: %.2f\nRelação de consumo: %.2f", relacao, eficiencia)
        resultadoCalculo += detalhes
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
    private func carregarVeiculos() {
        if let data = UserDefaults.standard.data(forKey: storageKeyVeiculo) {
            do {
                let decoded = try JSONDecoder().decode([Veiculo].self, from: data)
                self.veiculos = decoded
                self.veiculoSelecionado = decoded.first
            } catch {
                print("Erro ao decodificar veículos:", error)
            }
        }
    }
}

#Preview {
    CombustivelView()
}
