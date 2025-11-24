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

//
//  SlidingTabView.swift
//
//  Updated to support text, image, or both as tabs
//
//
//  SlidingTabView.swift
//
//  Copyright (c) …
import SwiftUI

@available(iOS 13.0, *)
public enum TabItem: Hashable {
    case text(String)
    case image(String)          // system image or asset image
    case textAndImage(String, String)

    // MARK: - Asset detection (cross-platform)
    private func assetExists(named name: String) -> Bool {
        #if canImport(UIKit)
        if UIImage(named: name) != nil { return true }
        #elseif canImport(AppKit)
        if NSImage(named: name) != nil { return true }
        #endif

        // Fallback: look for files in bundle that match this name
        let exts = ["png", "jpg", "jpeg", "pdf"]
        let bundle = Bundle.main

        return exts.contains { ext in
            bundle.url(forResource: name, withExtension: ext) != nil
        }
    }

    // MARK: - Label rendering
    @ViewBuilder
    var label: some View {
        switch self {

        case .text(let title):
            Text(title)

        case .image(let name):
            if assetExists(named: name) {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
            } else {
                Image(systemName: name)
            }

        case .textAndImage(let title, let name):
            HStack(spacing: 4) {
                if assetExists(named: name) {
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)
                } else {
                    Image(systemName: name)
                }
                Text(title)
            }
        }
    }

    // MARK: - SlidingTabView
    @available(iOS 13.0, *)
    public struct SlidingTabView: View {

        // MARK: Internal State
        @State private var selectionState: Int = 0 {
            didSet { selection = selectionState }
        }

        // MARK: Required Properties
        @Binding var selection: Int
        let tabs: [TabItem]

        // MARK: View Customization Properties
        let font: Font
        let animation: Animation
        let activeAccentColor: Color
        let inactiveAccentColor: Color
        let selectionBarColor: Color
        let inactiveTabColor: Color
        let activeTabColor: Color
        let selectionBarHeight: CGFloat
        let selectionBarBackgroundColor: Color
        let selectionBarBackgroundHeight: CGFloat
        let activeTextColor: Color
        let inactiveTextColor: Color

        // MARK: Init
        public init(
            selection: Binding<Int>,
            tabs: [TabItem],
            font: Font = .body,
            animation: Animation = .spring(),
            activeAccentColor: Color = .blue,
            inactiveAccentColor: Color = Color.black.opacity(0.4),
            selectionBarColor: Color = .blue,
            inactiveTabColor: Color = .clear,
            activeTabColor: Color = .clear,
            selectionBarHeight: CGFloat = 2,
            selectionBarBackgroundColor: Color = Color.gray.opacity(0.2),
            selectionBarBackgroundHeight: CGFloat = 1,
            activeTextColor: Color = .blue,
            inactiveTextColor: Color = .blue
        ) {
            self._selection = selection
            self.tabs = tabs
            self.font = font
            self.animation = animation
            self.activeAccentColor = activeAccentColor
            self.inactiveAccentColor = inactiveAccentColor
            self.selectionBarColor = selectionBarColor
            self.inactiveTabColor = inactiveTabColor
            self.activeTabColor = activeTabColor
            self.selectionBarHeight = selectionBarHeight
            self.selectionBarBackgroundColor = selectionBarBackgroundColor
            self.selectionBarBackgroundHeight = selectionBarBackgroundHeight
            self.activeTextColor = activeTextColor
            self.inactiveTextColor = inactiveTextColor
        }

        // MARK: Body
        public var body: some View {
            assert(tabs.count > 1, "Must have at least 2 tabs")

            return VStack(alignment: .leading, spacing: 0) {

                // Tabs Row
                HStack(spacing: 0) {
                    ForEach(tabs.indices, id: \.self) { index in
                        let tab = tabs[index]

                        Button(action: {
                            selectionState = index
                        }) {
                            HStack {
                                Spacer()
                                tab.label
                                    .foregroundColor(selectionState == index ? activeTextColor : inactiveTextColor)
                                    .font(font)
                                Spacer()
                            }
                        }
                        .padding(.vertical, 16)
                        .accentColor(isSelected(tabIdentifier: tab) ? activeAccentColor : inactiveAccentColor)
                        .background(isSelected(tabIdentifier: tab) ? activeTabColor : inactiveTabColor)
                    }
                }

                // Sliding Selection Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {

                        Rectangle()
                            .fill(selectionBarColor)
                            .frame(
                                width: tabWidth(from: geometry.size.width),
                                height: selectionBarHeight
                            )
                            .offset(x: selectionBarXOffset(from: geometry.size.width))
                            .animation(animation, value: selectionState)

                        Rectangle()
                            .fill(selectionBarBackgroundColor)
                            .frame(
                                width: geometry.size.width,
                                height: selectionBarBackgroundHeight
                            )
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }

        // MARK: Helpers
        private func isSelected(tabIdentifier: TabItem) -> Bool {
            tabs[selectionState] == tabIdentifier
        }

        private func selectionBarXOffset(from totalWidth: CGFloat) -> CGFloat {
            tabWidth(from: totalWidth) * CGFloat(selectionState)
        }

        private func tabWidth(from totalWidth: CGFloat) -> CGFloat {
            totalWidth / CGFloat(tabs.count)
        }
    }
}

#if DEBUG
@available(iOS 13.0, *)
struct SlidingTabConsumerView: View {
    @State private var selectedTabIndex = 0

    var body: some View {
        VStack(alignment: .leading) {
            TabItem.SlidingTabView(
                selection: $selectedTabIndex,
                tabs: [
                    .text("Home"),
                    .image("star"),
                    .textAndImage("Profile", "person.circle")
                ],
                font: .body,
                selectionBarColor: .purple,
                activeTextColor: .purple,
                inactiveTextColor: .gray
            )

            (selectedTabIndex == 0 ? Text("Home View") :
                selectedTabIndex == 1 ? Text("Star View") :
                Text("Profile View"))
            .padding()

            Spacer()
        }
        .padding(.top, 50)
        .animation(.none, value: selectedTabIndex)
    }
}

@available(iOS 13.0, *)
struct SlidingTabView_Previews: PreviewProvider {
    static var previews: some View {
        SlidingTabConsumerView()
    }
}
#endif
