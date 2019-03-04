import UIKit
import PlaygroundSupport


class MyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let subviews = [UIColor.gray, .darkGray, .black].map { (color) -> UIView in
            let v = UIView()
            v.backgroundColor = color
            return v
        }
        let topStackView = UIStackView(arrangedSubviews: subviews)
        topStackView.distribution = .fillEqually
        topStackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        let blueView = UIView()
        blueView.backgroundColor = .blue
        
        let bottomSubview = [UIColor.gray, .darkGray, .black, .red, .yellow].map { (color) -> UIView in
            let v = UIView()
            v.backgroundColor = color
            return v
        }
        let buttonsStackView = UIStackView(arrangedSubviews: bottomSubview)
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, blueView, buttonsStackView])
        
        view.addSubview(overallStackView)
    
        overallStackView.axis = .vertical
        overallStackView.translatesAutoresizingMaskIntoConstraints = false
        overallStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overallStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overallStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        overallStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
}


PlaygroundPage.current.liveView = MyViewController()
