import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

struct CalculatorView: View {
    @State private var display = "0"
    @State private var fullExpression = ""
    @State private var animateDisplay = false
    @State private var currentOp: String? = nil
    @State private var firstNum: Double? = nil
    @State private var freshInput = false

    let buttons: [[String]] = [
        ["C", "+/-", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "−"],
        ["1", "2", "3", "+"],
        ["0", ".", "="]
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#0f0c29"), Color(hex: "#302b63"), Color(hex: "#24243e")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            VStack(spacing: 14) {
                Spacer()
                Text(fullExpression)
                    .font(.system(size: 22, weight: .light, design: .rounded))
                    .foregroundColor(.white.opacity(0.45))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 28)
                    .lineLimit(1)

                Text(display)
                    .font(.system(size: 90, weight: .thin, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.white, Color(hex: "#a855f7")],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)
                    .padding(.horizontal, 24)
                    .scaleEffect(animateDisplay ? 1.06 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.5), value: animateDisplay)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.bottom, 10)

                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.horizontal, 20)

                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 13) {
                        ForEach(row, id: \.self) { btn in
                            CalcButton(label: btn) { handleTap(btn) }
                        }
                    }
                }
                Spacer().frame(height: 10)
            }
            .padding(18)
        }
    }

    func handleTap(_ btn: String) {
        withAnimation { animateDisplay = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { animateDisplay = false }

        switch btn {
        case "C":
            display = "0"; fullExpression = ""; currentOp = nil; firstNum = nil; freshInput = false
        case "+/-":
            if let val = Double(display) { display = formatResult(-val) }
        case "%":
            if let val = Double(display) { display = formatResult(val / 100) }
        case "÷", "×", "−", "+":
            firstNum = Double(display); currentOp = btn
            fullExpression = "\(display) \(btn)"; freshInput = true
        case "=":
            guard let op = currentOp, let first = firstNum, let second = Double(display) else { return }
            let result: Double
            switch op {
            case "÷": result = second != 0 ? first / second : 0
            case "×": result = first * second
            case "−": result = first - second
            default:  result = first + second
            }
            fullExpression = "\(formatResult(first)) \(op) \(formatResult(second)) ="
            display = formatResult(result); currentOp = nil; firstNum = nil; freshInput = true
        case ".":
            if freshInput { display = "0."; freshInput = false; return }
            if !display.contains(".") { display += "." }
        default:
            if freshInput { display = btn; freshInput = false }
            else { display = display == "0" ? btn : display + btn }
        }
    }

    func formatResult(_ val: Double) -> String {
        val.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(val)) : String(val)
    }
}

struct CalcButton: View {
    let label: String
    let action: () -> Void
    var isOperator: Bool { ["÷","×","−","+","="].contains(label) }
    var isTopRow: Bool { ["C","+/-","%"].contains(label) }
    var isWide: Bool { label == "0" }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: isWide ? 168 : 78, height: 78)
                .background(
                    Group {
                        if isOperator {
                            LinearGradient(colors: [Color(hex: "#a855f7"), Color(hex: "#6366f1")],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        } else {
                            Color.white.opacity(isTopRow ? 0.18 : 0.10)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: isOperator ? Color(hex: "#a855f7").opacity(0.55) : .black.opacity(0.25),
                        radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }
}