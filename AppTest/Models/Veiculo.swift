import Foundation

struct Veiculo: Identifiable, Codable, Hashable {
    var id: UUID
    var nome: String
    var tanque: Int
    var consumoEtanol: Float
    var consumoGasolina: Float
    
    init(nome: String, tanque: Int, consumoEtanol: Float, consumoGasolina: Float) {
        self.id = UUID()
        self.nome = nome
        self.tanque = tanque
        self.consumoEtanol = consumoEtanol
        self.consumoGasolina = consumoGasolina
    }
} 