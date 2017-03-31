import UIKit
import PlaygroundSupport

class SVDViewController: UIViewController {
    let imageView = UIImageView()
    
    let progressLabel = UILabel()
    let progressIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func viewDidLoad() {
        view.addSubview(imageView)
        view.addSubview(progressIndicator)
        view.addSubview(progressLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.translatesAutoresizingMaskIntoConstraints = false

        imageView.topAnchor.constraint(equalTo: view.topAnchor,
                                       constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor,
                                        constant: 0).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor,
                                         constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: progressIndicator.topAnchor,
                                          constant: 0).isActive = true
        progressIndicator.leftAnchor.constraint(equalTo: view.leftAnchor,
                                                constant: 0).isActive = true
        progressIndicator.rightAnchor.constraint(equalTo: view.rightAnchor,
                                                 constant: 0).isActive = true
        progressIndicator.bottomAnchor.constraint(equalTo: progressLabel.topAnchor,
                                                  constant: 0).isActive = true
        progressLabel.leftAnchor.constraint(equalTo: view.leftAnchor,
                                            constant: 0).isActive = true
        progressLabel.rightAnchor.constraint(equalTo: view.rightAnchor,
                                             constant: 0).isActive = true
        progressLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                              constant: 0).isActive = true
        
        NSLayoutConstraint(item: progressIndicator,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .height,
                           multiplier: 0,
                           constant: 40).isActive = true
        NSLayoutConstraint(item: progressLabel,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .height,
                           multiplier: 0,
                           constant: 60).isActive = true
        
        imageView.contentMode = .scaleAspectFit

        view.backgroundColor = .white
        imageView.backgroundColor = .white
        progressIndicator.backgroundColor = .white
        progressLabel.backgroundColor = .white
        progressLabel.textColor = .black
        progressLabel.textAlignment = .center
        progressLabel.font = UIFont(name: "Menlo", size: 14)
        
        progressIndicator.isHidden = false
        progressIndicator.hidesWhenStopped = false
        progressIndicator.startAnimating()
    }
    
    func setProgressText(progressText: String?) {
        progressLabel.text = progressText
    }
    
    func setImage(image: UIImage?) {
        imageView.image = image
    }
    
    func showProgressIndicator() {
        progressIndicator.isHidden = false
    }
    
    func hideProgressIndicator() {
        progressIndicator.isHidden = true
    }
}

public struct UI {
    static private var viewController: SVDViewController?
    
    static private func fadeView(view: UIView) {
        CATransaction.begin()
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 0.3
        
        view.layer.add(transition, forKey: "fade")
        CATransaction.commit()
    }
    
    static public func setup() {
        viewController = SVDViewController()
        PlaygroundPage.current.liveView = viewController!
        
        viewController!.showProgressIndicator()
    }
    
    static public func setSideImage(image: UIImage?) {
        DispatchQueue.main.async {
            fadeView(view: viewController!.imageView)
            viewController!.setImage(image: image)
        }
    }
    
    static public func setSideText(text: String?) {
        DispatchQueue.main.async {
            fadeView(view: viewController!.progressLabel)
            viewController!.setProgressText(progressText: text)
        }
    }
    
    static public func done() {
        DispatchQueue.main.async {
            viewController!.hideProgressIndicator()
        }
    }
    
    static public func terminate() {
        PlaygroundPage.current.finishExecution()
    }
}


