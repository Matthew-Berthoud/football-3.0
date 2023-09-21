//
//  ButtonView.swift
//  FOOTBALL 3.0
//
//  Created by Matthew Berthoud on 7/30/23.
//

import SwiftUI

struct ButtonView: View {
    var title: String = ""
    var action: () -> Void
    var color: Color
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Rectangle()
                    .foregroundColor(self.color)
                Text(self.title)
                    .foregroundColor(Color.black)
            }
        }
        .frame(width: 60.0, height: 50.0)
        .padding(10)
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(title: "test", action: {
            print("test")
        }, color: .green)
    }
}
