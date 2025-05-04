import Foundation

struct Abastecimento: Identifiable, Codable, Hashable {
    var id: UUID
    var veiculoId: UUID
    var data: Date
    var tipoCombustivelAntigo: TipoCombustivel
    var tipoCombustivelAtual: TipoCombustivel
    var litros: Float
    var valorLitro: Float
    var quilometragem: Float
    
    init(veiculoId: UUID, tipoCombustivelAtual: TipoCombustivel, tipoCombustivelAntigo: TipoCombustivel, litros: Float, valorLitro: Float, quilometragem: Float) {
        self.id = UUID()
        self.veiculoId = veiculoId
        self.data = Date()
        self.tipoCombustivelAntigo = tipoCombustivelAntigo
        self.tipoCombustivelAtual = tipoCombustivelAtual
        self.litros = litros
        self.valorLitro = valorLitro
        self.quilometragem = quilometragem
    }
}

enum TipoCombustivel: String, Codable {
    case etanol = "Etanol"
    case gasolina = "Gasolina"
    case diesel = "Diesel"
}
