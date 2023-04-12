import SwiftUI

extension UIView {
    func focus() {
        becomeFirstResponder()
    }
}

extension View {
    func focusable() -> some View {
        self.background(ResponderEnablingView())
    }
    func responsiveWidth(_ widthRatio: CGFloat) -> some View {
        self.modifier(ResponsiveViewModifier(widthRatio: widthRatio))
    }
}

private struct ResponderEnablingView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

private struct ResponsiveViewModifier: ViewModifier {
    let widthRatio: CGFloat

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .frame(width: geometry.size.width * widthRatio)
        }
    }
}
