//
//  ContentView.swift
//  AppTest
//
//  Created by Murilo on 03/05/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CombustivelView()
                .tabItem {
                    Image(systemName: "car.fill")
                    Text("Combustível")
                }
            
//            VeiculosView()
//                .tabItem {
//                    Image(systemName: "car.fill")
//                    Text("Veículos")
//                }
//            
            AbastecimentoView()
                .tabItem {
                    Image(systemName: "fuelpump.fill")
                    Text("Abastecimento")
                }
            
            RelatoriosView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Relatórios")
                }
            
            ConfiguracoesView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Configurações")
                }
        }
    }
}


#Preview {
    ContentView()
}
