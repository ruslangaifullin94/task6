//
//  ContentView.swift
//  task6
//
//  Created by Руслан Гайфуллин on 16.10.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var layoutType: LayoutType = .horizontal
    @State private var numberOfItems = 7
    @State private var spacing: CGFloat = 5
    
    var body: some View {
        GeometryReader { proxy in
            let itemSize = CustomLayout.getItemSize(
                layoutType: layoutType,
                screenSize: proxy.size,
                numberOfItems: numberOfItems,
                spacing: spacing
            )
            
            CustomLayout(layoutType: layoutType, spacing: spacing) {
                ForEach(0..<numberOfItems, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.blue)
                        .frame(width: itemSize, height: itemSize)
                        .onTapGesture {
                            withAnimation {
                                switch layoutType {
                                case .horizontal: layoutType = .diagonal
                                case .diagonal: layoutType = .horizontal
                                }
                            }
                        }
                }
            }
        }
    }
}

struct CustomLayout: Layout {
    @State private var layoutType: LayoutType
    @State private var spacing: CGFloat
    
    init(layoutType: LayoutType, spacing: CGFloat) {
        self.layoutType = layoutType
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count > 1 else {
            let point = CGPoint(x: bounds.midX, y: bounds.midY)
            subviews.first?.place(at: point, anchor: .center, proposal: .unspecified)
            
            return
        }
        
        subviews.enumerated().forEach { index, subview in
            var point = CGPoint(x: 0, y: bounds.maxY)
            
            switch layoutType {
            case .horizontal:
                let itemSize = Self.getItemSize(
                    layoutType: layoutType,
                    screenSize: bounds.size,
                    numberOfItems: subviews.count,
                    spacing: spacing
                )
                point.x += CGFloat(index) * (itemSize + spacing)
                point.y = bounds.midY
            case .diagonal:
                let itemSize = Self.getItemSize(
                    layoutType: layoutType,
                    screenSize: bounds.size,
                    numberOfItems: subviews.count,
                    spacing: spacing
                )
                point.x += (CGFloat(index) * ((bounds.width - itemSize) / CGFloat(subviews.count - 1)))
                point.y -= itemSize * CGFloat(index)
            }
            
            subview.place(at: point, anchor: .bottomLeading, proposal: .unspecified)
        }
    }
    
    static func getItemSize(
        layoutType: LayoutType,
        screenSize: CGSize,
        numberOfItems: Int,
        spacing: CGFloat
    ) -> CGFloat {
        let itemSize: CGFloat
        switch layoutType {
        case .horizontal:
            let sideSize = screenSize.width
            itemSize = (sideSize - (spacing * CGFloat(numberOfItems - 1))) / CGFloat(numberOfItems)
        case .diagonal:
            let sideSize = screenSize.height
            itemSize = sideSize / CGFloat(numberOfItems)
        }
        
        return min(itemSize, screenSize.width, screenSize.height)
    }
}

enum LayoutType {
    case horizontal
    case diagonal
}

#Preview {
    ContentView()
}
