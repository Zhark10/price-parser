//
//  CalculatorView.swift
//  calc ai
//
//  Created by Дмитрий Мухин on 12.05.2025.
//

import SwiftUI

struct CalculatorView: View {
    // MARK: Property
    @EnvironmentObject var viewModel: ViewModel
    

    var body: some View {
        ZStack {
            Color.backgroundCalc
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                // MARK: Display
                HStack {
                    Spacer()
                    Text(viewModel.value)
                        .foregroundColor(.white)
                        .font(.system(size: 90))
                        .fontWeight(.light)
                        .padding(.horizontal)
                }
                
                
                // MARK: Buttons
                ForEach(viewModel.buttonsArray, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { item in
                            Button {
                                viewModel.didTap(button: item)
                            } label: {
                                Text(item.rawValue)
                                    .frame(width: viewModel.buttonWidth(item: item), height: viewModel.buttonHeight())
                                    .foregroundColor(item.buttonFontColor)
                                    .background(item.buttonColor)
                                    .font(.system(size: 35))
                                    .cornerRadius(40)
                            }
                        }
                    }
                }
            }.padding(.bottom)
        }
    }
}


// MARK: Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView()
            .environmentObject(ViewModel())
    }
}
