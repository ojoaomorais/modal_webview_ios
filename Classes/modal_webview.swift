//
//  modal_webview.swift
//  modal_webview
//
//  Created by Joao Morais on 17/06/24.
//

import UIKit
import WebKit
import Foundation

public protocol ModalWebviewProtocol{
    func didClose()
    func didFailOpenUrl()
}

public extension ModalWebviewProtocol{
    func didClose(){}
    func didFailOpenUrl(){}
}

public class ModalWebview{
    
    lazy var webview: CustomWebBrowser = {
        var webview = CustomWebBrowser(frame: UIScreen.main.bounds)
        return webview
    }()
    public var delegate: ModalWebviewProtocol?{
        didSet{
            webview.delegate = delegate
        }
    }
    
    public init(){}

    public func show(controller: UIViewController,url: URL) {
        controller.view.addSubview(webview)
        if UIApplication.shared.canOpenURL(url) {
            webview.show(url: url)
        }
    }
}

enum DragState{
    case moving
    case ended
}

class CustomWebBrowser: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var browserView: UIView!
    @IBOutlet weak var blurImageView: UIImageView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint?
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var goForwardButton: UIButton!
    @IBOutlet weak var secondRightButton: UIButton!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var originalConstraintValue: CGFloat = 0.0
    var translation: CGPoint!
    var startPosition: CGPoint! // Start position for the gesture transition
    var webView: WKWebView!
    var firstUrl: URL?
    var navigation : UINavigationController?
    var webviewScrollOffset = 0.0
    var delegate: ModalWebviewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        contentView = loadViewFromNib()
        contentView.frame = bounds
        contentView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,
                                        UIView.AutoresizingMask.flexibleHeight]
        configureInitialWebView()
        generateGestureRecognizers()
        addSubview(contentView)
    }
    
    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }

    private func configureInitialWebView() {
        self.topView.layer.cornerRadius = 5.0
        self.originalConstraintValue = topConstraint?.constant ?? 0.0
        self.topConstraint?.constant = self.contentView.frame.height
        self.blurImageView.alpha = 0.0
        self.contentView.layoutIfNeeded()
    }
    
    private func generateGestureRecognizers() {
        let infoViewGR = UIPanGestureRecognizer(target: self, action: #selector(viewDragged(_:)))
        let topViewGR = UIPanGestureRecognizer(target: self, action: #selector(viewDragged(_:)))
        self.infoStackView.addGestureRecognizer(infoViewGR)
        self.topView.addGestureRecognizer(topViewGR)
    }
    
    private func swipeDownBrowserView() {
        self.topConstraint?.constant = self.contentView.frame.height
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            self.contentView.layoutIfNeeded()
            self.blurImageView.alpha = 0.0
        }, completion: { (success) in
            if success {
                self.webView.load(URLRequest(url: URL(string:"about:blank")!))
                self.browserView.isHidden = true
                self.removeFromSuperview()
                if let delegate = self.delegate{
                    delegate.didClose()
                }
            }
        })
    }
    
    public func show(url: URL) {
        self.browserView.isHidden = false
        self.webViewToOriginalPosition()
        insertWebView(url:url)
    }
    
    private func insertWebView(url:URL) {
        DispatchQueue.main.async {
            let height = self.browserView.frame.height - 47
            let frame = CGRect(x: 0, y: 47, width: self.browserView.frame.width, height: height)
            self.webView = WKWebView(frame: frame, configuration: WKWebViewConfiguration())
            self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.webView.uiDelegate = self
            self.webView.navigationDelegate = self
            self.browserView.addSubview(self.webView)
            self.openUrl(url: url)
        }
    }
    
    private func openUrl(url: URL) {
        let myRequest = URLRequest(url: url)
        self.urlLabel.text = url.absoluteString
        self.firstUrl = url
        
        if let _webView = self.webView {
            showLoading()
            _webView.load(myRequest)
        }
    }
    
    private func webViewToOriginalPosition() {
        self.topConstraint?.constant = self.originalConstraintValue
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 10,
                       options: .curveEaseInOut,
                       animations: {
            self.contentView.layoutIfNeeded()
            self.blurImageView.alpha = 0.7
        })
    }
    
    @objc func viewDragged(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.browserView)
        switch sender.state {
        case .changed:
            updateModalPosition(translation: translation.y, state: .moving)
        case .ended:
            updateModalPosition(translation: translation.y, state: .ended)
        default: break
        }
    }
    
    func updateModalPosition(translation:Double,state:DragState){
        let newValue = self.originalConstraintValue + translation
        switch state {
        case .moving:
            if newValue >= self.originalConstraintValue {
                self.topConstraint?.constant = newValue
                self.blurImageView.alpha = (0.7 - translation / self.browserView.frame.size.height)
            }
        case .ended:
            if newValue <= ((self.contentView.bounds.height / 2) - self.originalConstraintValue) {
                self.webViewToOriginalPosition()
            } else {
                self.swipeDownBrowserView()
            }
        }
    }
    
    @IBAction func close_action() {
        self.swipeDownBrowserView()
    }
    
    @IBAction func refresh_action() {
        showLoading()
        self.webView.reload()
    }
    
    @IBAction func goBack_action() {
        if webView.canGoBack {
            showLoading()
            webView.goBack()
        }
    }
    
    @IBAction func goForward_action(){
        if webView.canGoForward{
            showLoading()
            webView.goForward()
        }
    }
    
    private func showLoading() {
        loading.startAnimating()
    }
}

    //MARK: - WKNavigationDelegate
extension CustomWebBrowser: WKNavigationDelegate, WKUIDelegate {
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if let url = webView.url{
            print("Error displaying url page: \(url). Error: \(error.localizedDescription)")
        }
        if let delegate = self.delegate{
            delegate.didFailOpenUrl()
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let urlStr = navigationAction.request.url{
            self.urlLabel.text = urlStr.absoluteString
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        debugPrint(error)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.loading.stopAnimating()
        self.goBackButton.isEnabled = webView.canGoBack
        self.goForwardButton.isEnabled = webView.canGoForward
    }
}
