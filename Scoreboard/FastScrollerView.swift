import SwiftUI

struct FastScrollerView: View {
    let alphabet: [String] = (65...90).map { String(UnicodeScalar($0)!) }
    
    @Binding var scrollOffset: CGFloat
    @State private var isDragging: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(alphabet, id: \.self) { letter in
                Text(letter)
                    .font(.system(size: 12))
                    .frame(width: 20, height: 20)
                    .background(isDragging ? Color.gray.opacity(0.5) : Color.clear)
                    .cornerRadius(10)
                    .gesture(
                        DragGesture()
                            .onChanged { _ in
                                withAnimation {
                                    isDragging = true
                                    scrollOffset = calculateScrollOffset(letter: letter)
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    isDragging = false
                                }
                            }
                    )
            }
        }
    }
    
    private func calculateScrollOffset(letter: String) -> CGFloat {
        let index = alphabet.firstIndex(of: letter) ?? 0
        let offset = CGFloat(index) / CGFloat(alphabet.count - 1)
        return offset
    }
}

struct FastScrollerView_Previews: PreviewProvider {
    static var previews: some View {
        FastScrollerView(scrollOffset: .constant(0))
    }
}
