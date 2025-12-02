//
//  Untitled.swift
//  تمكّن
//
//  Created by Ghady Al Omar on 10/06/1447 AH.
//

import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct ShowText: View {
    @State private var text = ""
    @Environment(\.colorScheme) var colorScheme   // نعرف لايت أو دارك
    
    var todayDate: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ar_SA")
        f.dateFormat = "d MMMM yyyy"
        return f.string(from: Date())
    }
    
    // خلفية الشيت
    var sheetBackground: Color {
        if colorScheme == .dark {
            // نفس الدارك اللي حاطّته
            return Color(red: 0.13, green: 0.13, blue: 0.13)
        } else {
            // رمادي فاتح مره في اللايت
            return Color(.systemGray6) // أو Color(red: 0.95, green: 0.95, blue: 0.95)
        }
    }
    
    // لون النص
    var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    // لون الـ Divider
    var dividerColor: Color {
        if colorScheme == .dark {
            return Color.white.opacity(0.9)
        } else {
            return Color.black.opacity(0.15)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            ZStack {
                Text(todayDate)
                    .foregroundColor(textColor)
                
                HStack {
                    Text("انهاء")
                        .foregroundColor(textColor)
                    Spacer()
                }
            }
            .font(.system(size: 18, weight: .regular))
            .padding(.horizontal)
            
            Text("اليوم")
                .font(.title2.bold())
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            Divider()
                .background(dividerColor)
            
            TextEditor(text: $text)
                .font(.system(size: 18))
                .foregroundColor(textColor)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 150, alignment: .topTrailing)
            
            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity,
               maxHeight: .infinity,
               alignment: .top)
        .background(sheetBackground) // هنا التبديل بين الرمادي الغامق والفاتح
        .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    ShowText()
}
