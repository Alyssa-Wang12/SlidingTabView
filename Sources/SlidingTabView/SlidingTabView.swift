//
//  SlidingTabView.swift
//
//  Copyright (c) 2019 Quynh Nguyen
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import SwiftUI

@available(iOS 13.0, *)
import SwiftUI

public struct SlidingTabView: View {
    
    @Binding var selection: Int
    let tabs: [TabItem]
    let animation: Animation
    let selectionBarColor: Color
    let activeTextColor: Color
    let inactiveTextColor: Color
    let font: Font
    let barHeight: CGFloat
    
    public init(
        selection: Binding<Int>,
        tabs: [TabItem],
        animation: Animation = .spring(response: 0.3, dampingFraction: 0.8),
        selectionBarColor: Color = .accentColor,
        activeTextColor: Color = .primary,
        inactiveTextColor: Color = .secondary,
        font: Font = .system(size: 15, weight: .semibold),
        barHeight: CGFloat = 3
    ) {
        self._selection = selection
        self.tabs = tabs
        self.animation = animation
        self.selectionBarColor = selectionBarColor
        self.activeTextColor = activeTextColor
        self.inactiveTextColor = inactiveTextColor
        self.font = font
        self.barHeight = barHeight
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(tabs.indices, id: \.self) { index in
                    Button(action: {
                        withAnimation(animation) {
                            selection = index
                        }
                    }) {
                        VStack(spacing: 6) {
                            tabs[index].label
                                .foregroundColor(selection == index ? activeTextColor : inactiveTextColor)
                                .font(font)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                }
            }
            
            // Sliding selection bar
            GeometryReader { geo in
                let tabWidth = geo.size.width / CGFloat(tabs.count)
                Rectangle()
                    .fill(selectionBarColor)
                    .frame(width: tabWidth, height: barHeight)
                    .offset(x: tabWidth * CGFloat(selection))
                    .animation(animation, value: selection)
            }
            .frame(height: barHeight)
        }
    }
}

public enum TabItem: Hashable {
    case text(String)
    case systemImage(String)
    case both(text: String, systemImage: String)
    
    @ViewBuilder
    var label: some View {
        switch self {
        case .text(let title):
            Text(title)
        case .systemImage(let name):
            Image(systemName: name)
        case .both(let title, let icon):
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
        }
    }
}

#if DEBUG

@available(iOS 13.0, *)
struct SlidingTabConsumerView : View {
    @State private var selectedTabIndex = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            SlidingTabView(selection: self.$selectedTabIndex,
                           tabs: ["First", "Second"],
                           font: .body,
                           activeAccentColor: Color.blue,
                           selectionBarColor: Color.blue)
            (selectedTabIndex == 0 ? Text("First View") : Text("Second View")).padding()
            Spacer()
        }
        .padding(.top, 50)
            .animation(.none)
    }
}

@available(iOS 13.0.0, *)
struct SlidingTabView_Previews : PreviewProvider {
    static var previews: some View {
        SlidingTabConsumerView()
    }
}
#endif
