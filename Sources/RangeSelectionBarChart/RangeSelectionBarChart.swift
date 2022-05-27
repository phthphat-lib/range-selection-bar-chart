import UIKit

public class RangeSelectionBarChart: UIView {
    public private(set) var text = "Hello, World!"
    public private(set) lazy var lowerView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBlue
        return v
    }()
    public private(set) lazy var upperView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemRed
        return v
    }()
    
    var activeColor = UIColor.systemOrange
    var inactiveColor = UIColor.systemGray

    
    private let buttonSize = CGSize(width: 30, height: 30)
    private let bottomLineHeight = 4.0
    
    private let bottomLine = UIView()
    
    private let activeBottomBar = UIView()
    
    private var data = [0, 0.2, 0.3, 0.8, 0.6, 0.5, 0.3, 0.1, 0]

    public init() {
        super.init(frame: .zero)
        constructView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        constructView()
    }
    func constructView() {
        self.addSubview(bottomLine)
        self.addSubview(lowerView)
        self.addSubview(upperView)
        bottomLine.backgroundColor = inactiveColor
        self.bottomLine.addSubview(activeBottomBar)
        activeBottomBar.backgroundColor = activeColor
        
        
        upperView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onPan(_:))))
        lowerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onPan(_:))))
    }
    public override func draw(_ rect: CGRect) {
        lowerView.frame = CGRect(origin: .init(x: 20, y: rect.height - buttonSize.height), size: buttonSize)
        upperView.frame = CGRect(origin: .init(x: rect.width / 2, y: rect.height - buttonSize.height), size: buttonSize)
        bottomLine.frame = CGRect(
            x: buttonSize.width / 2,
            y: rect.height - buttonSize.height / 2 - bottomLineHeight / 2,
            width: rect.width - buttonSize.width, height: bottomLineHeight
        )
        updateActiveBar()
        buildBarChart()
    }
    private func updateActiveBar() {
        activeBottomBar.frame = CGRect(
            x: lowerView.frame.minX,
            y: 0,
            width: upperView.center.x - lowerView.center.x,
            height: bottomLineHeight
        )
    }
    var initialPosition = CGPoint.zero
    @objc private func onPan(_ ges: UIPanGestureRecognizer) {
        guard let view = ges.view else { return }
        switch ges.state {
        case .began:
            initialPosition = view.center
        case .changed:
            let translation = ges.translation(in: self)
            var newX = initialPosition.x + translation.x
            newX = newX < buttonSize.width / 2 ? buttonSize.width / 2 : newX
            newX = newX > self.frame.width - buttonSize.width / 2 ? self.frame.width - buttonSize.width / 2 : newX
            view.center = CGPoint(x: newX, y: initialPosition.y)
        default: break
        }
        updateActiveBar()
        updateBarChartColor()
    }
    var bars = [UIView]()
    private func buildBarChart() {
        let barHeight = self.bottomLine.frame.minY
        let barWidth = self.bottomLine.frame.width / CGFloat(data.count)
        
        bars.forEach { view in
            view.removeFromSuperview()
        }
        
        for (index, item) in data.enumerated() {
            let bar = UIView()
            bar.backgroundColor = activeColor
            bar.layer.borderColor = self.backgroundColor?.cgColor
            bar.layer.borderWidth = 1
            bars.append(bar)
            self.insertSubview(bar, at: 0)
            bar.frame = CGRect(x: self.buttonSize.width / 2 + CGFloat(index) * barWidth, y: barHeight * (1 - item), width: barWidth, height: barHeight * item)
        }
        updateBarChartColor()
    }
    private func updateBarChartColor() {
        for barView in self.bars {
            barView.backgroundColor = barView.frame.minX >= lowerView.frame.minX && barView.center.x <= upperView.center.x ? activeColor : inactiveColor
        }
    }
}
