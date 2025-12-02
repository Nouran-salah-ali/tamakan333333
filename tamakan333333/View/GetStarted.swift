//
//  GetStarted.swift
//  تمكّن
//
//  Created by Yasmin Alhabib on 01/12/2025.
//
import SwiftUI

struct GetStarted: View {

    @State private var showFirst = false     // تحدّث
    @State private var showSecond = false    // تدرّب
    @State private var showThird = false     // تطوّر

    var body: some View {
        NavigationStack {
            ZStack {

                // خلفية تدعم Light/Dark
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    Image("effect")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(2.3)
                        .frame(height: 260)
                        .offset(y: 85)
                        .ignoresSafeArea()
                }


                // المحتوى (نصوص + زر)
                VStack(spacing: 32) {

                    Spacer()

                    VStack(spacing: 8) {
                        Text("تحدّث")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.primary)     // ← يتغير تلقائيًا
                            .opacity(showFirst ? 1 : 0)
                            .offset(y: showFirst ? 0 : 10)

                        Text("تدرّب")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.primary)
                            .opacity(showSecond ? 1 : 0)
                            .offset(y: showSecond ? 0 : 10)

                        Text("تطوّر")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.primary)
                            .opacity(showThird ? 1 : 0)
                            .offset(y: showThird ? 0 : 10)
                    }

                    Spacer().frame(height: 60)

                    // زر "ابدأ"
                    NavigationLink {
                        records()
                    } label: {
                        Text("إبدأ")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(
                                RoundedRectangle(cornerRadius: 32, style: .continuous)
                                    .fill(Color.primary.opacity(0.06))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                                            .stroke(Color.primary.opacity(0.15), lineWidth: 0.8)
                                    )
                            )
                    }
                    .padding(.horizontal, 40)

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .onAppear {
                startAnimation()
            }
        }
        .preferredColorScheme(.dark)
    }
        private func startAnimation() {

        showFirst = false
        showSecond = false
        showThird = false

        withAnimation(.easeOut(duration: 0.6)) {
            showFirst = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeOut(duration: 0.6)) {
                showSecond = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeOut(duration: 0.6)) {
                showThird = true
            }
        }
        
    }
}

#Preview {
    GetStarted()
        .environment(\.layoutDirection, .rightToLeft)
}
