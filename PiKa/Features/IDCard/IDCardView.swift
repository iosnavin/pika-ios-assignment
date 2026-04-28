//
//  Untitled.swift
//  PiKa
//
//  Created by Naveen on 28/04/26.
//

import SwiftUI

struct IDCardView: View {

    let model: IDCardModel
    let barcode: UIImage?
    @State private var contentHeight: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {

            // TOP
            HStack(alignment: .top) {

                if let image = model.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Spacer()

                Image("rabbit_icon")
                    .resizable()
                    .frame(width: 32, height: 26)
            }

            // NAME
            Text(model.name.uppercased())
                .font(AppFonts.heavy(size: 24))

            Divider()
                .overlay(Color.black.opacity(0.5))

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    infoRow("BORN ON PIKA", model.date)
                    infoRow("LOCATION", model.location)
                    infoRow("STATUS", model.status)
                    infoRow("FIND ME ON", model.handle)
                }
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: HeightPreferenceKey.self, value: geo.size.height)
                    }
                )

                Spacer()

                if let barcode {
                    Image(uiImage: barcode)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFill()
                        .frame(width: 34)
                        .frame(height: contentHeight)
                        .rotationEffect(.degrees(90))
                        .clipped()
                }
            }
            .onPreferenceChange(HeightPreferenceKey.self) {
                contentHeight = $0
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(red: 0.98, green: 0.98, blue: 0.97)
        )
        .clipShape(RoundedRectangle(cornerRadius: 26))
    }
    
    private func infoRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(AppFonts.light(size: 10))
                .foregroundColor(.gray)

            Text(value)
                .font(AppFonts.medium(size: 15))
                .foregroundColor(.black)
        }
    }
}

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
