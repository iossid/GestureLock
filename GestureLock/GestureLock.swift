import UIKit

class GestureLock: UIView {
    
    let hilightedColor = UIColor.redColor()
    
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var view: UIView!
    @IBOutlet weak var rowStackView: UIStackView!
    @IBOutlet var columnStackViews: [UIStackView]!
    
    var selectedButtons: [UIButton]! = Array<UIButton>()
    var penddingLocation: CGPoint = CGPointZero
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSBundle.mainBundle().loadNibNamed(String(GestureLock), owner: self, options: nil)
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: .AlignAllCenterX, metrics: nil, views: ["view": view]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: .AlignAllCenterY, metrics: nil, views: ["view": view]))
        configureStackViewSpacing(30)
    }
    
    func configureStackViewSpacing(spacing: CGFloat) {
        rowStackView.spacing = spacing
        for stackView in columnStackViews {
            stackView.spacing = spacing
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        for button in buttons {
            button.layer.cornerRadius = button.frame.size.width / 2
            button.layer.masksToBounds = true
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.blueColor().CGColor
        }
        print(selectedButtons)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        onTouchesDetected(touches)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        onTouchesDetected(touches)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for button in selectedButtons {
            deselectButton(button)
        }
    }
    
    func onTouchesDetected(touches: Set<UITouch>) {
        let touch = touches.first
        if let location = touch?.locationInView(view) {
            penddingLocation = location
            for button in buttons {
                let frame = button.superview!.convertRect(button.frame, toView: view)
                if CGRectContainsPoint(frame, location) {
                    selectButton(button)
                }
            }
            setNeedsDisplay()
        }
    }
    
    func selectButton(button: UIButton!) {
        if selectedButtons.contains(button) {
            return
        }
        let width = button.frame.size.width
        let v = UIView(frame: CGRectMake(0, 0, width / 4, width / 4))
        v.backgroundColor = hilightedColor
        v.layer.cornerRadius = v.frame.size.width / 2
        v.layer.masksToBounds = true
        v.center = CGPointMake(width / 2, width / 2)
        button.addSubview(v)
        selectedButtons.append(button)
    }
    
    func deselectButton(button: UIButton!) {
        if !selectedButtons.contains(button) {
            return
        }
        for view in button.subviews {
            view.removeFromSuperview()
        }
        selectedButtons.removeAtIndex(selectedButtons.indexOf(button)!)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if selectedButtons.count == 0 {
            return
        }
        let path = UIBezierPath.init()
        path.lineWidth = 2
        hilightedColor.setStroke()
        for i in 0..<selectedButtons.count {
            let button = selectedButtons[i]
            if let location = button.superview?.convertPoint(button.center, toView: view) {
                if i == 0 {
                    print("move to \(location)")
                    path.moveToPoint(location)
                } else {
                    print("add line to \(location)")
                    path.addLineToPoint(location)
                }
            }
        }
        path.addLineToPoint(penddingLocation)
        path.stroke()
    }
}
