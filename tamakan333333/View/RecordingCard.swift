//
//  RecordingCard.swift
//  tamakan333333
//
//  Created by nouransalah on 13/06/1447 AH.
//
import SwiftUI
struct RecordingCardView: View {
    let id: UUID
    let title: String
    let date: Date
    let duration: Double
    @Binding var progress: Double
    var isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {

            // Top part
            HStack {
                Text("\(duration, specifier: "%.1f")")
                    .foregroundColor(.primary.opacity(0.8))

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(title)
                        .foregroundColor(.primary)
                        .font(.title3)
                        .bold()

                    Text(date.formatted())
                        .foregroundColor(.primary.opacity(0.6))
                        .font(.caption)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { onTap() }

            // Expanded section
            if isExpanded {
                VStack(spacing: 12) {

                    Slider(value: $progress)
                        .tint(.primary)

                    HStack {
                        Text("-1:10")
                        Spacer()
                        Text("0:00")
                    }
                    .font(.caption2)
                    .foregroundColor(.primary.opacity(0.6))

                    // Action buttons
                    HStack(spacing: 28) {
                        Image(systemName: "text.bubble")
                        Image(systemName: "gobackward.15")
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 42))
                        Image(systemName: "goforward.15")
                        Image(systemName: "trash")
                    }
                    .foregroundColor(.primary)

                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(minHeight: isExpanded ? 200 : 80)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.primary.opacity(0.10))
        )
        .animation(.easeInOut, value: isExpanded)
    }
}
