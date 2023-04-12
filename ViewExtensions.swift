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
}

private struct ResponderEnablingView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
