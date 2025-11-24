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
