//
//  calc_aiApp.swift
//  calc ai
//
//  Created by Дмитрий Мухин on 12.05.2025.
//

import SwiftUI

@main
struct calc_aiApp: App {
    @StateObject var viewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            // TODO: Этот компонент бы переименовать и вынести к другим скринам
            // ContentView()
            // TODO: Заведено на перспективу для главного экрана, на котором будет открываться камера
            // MainCameraView()
            CalculatorView()
                 .environmentObject(viewModel)
        }
    }
}
