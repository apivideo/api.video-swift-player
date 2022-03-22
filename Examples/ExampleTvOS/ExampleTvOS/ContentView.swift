//
//  ContentView.swift
//  ExampleTvOS
//
//  Created by Romain Petit on 16/03/2022.
//

import SwiftUI
import ApiVideoPlayer

struct ContentView: View {
    var body: some View {
        PlayerSwiftUIView()
            .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.5, alignment: .center)
            .cornerRadius(40)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
