# Modal Webview

A very simple modal webview for display web pages inside your app.

https://github.com/ojoaomorais/modal_webview_ios/assets/15629444/6b095280-fb72-47f7-b0de-ede2b0ec7b35

## Requirements

## Installation

modal_webview is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'modal_webview'
```

## Usage

After import the library `import modal_webview`, instantiate the class and qual the `show` method:

```swift
class ViewController: UIViewController {

    let webview = ModalWebview()
    var url = URL(string: "https://developer.apple.com/")!

    func showBrowserAction(){
        webview.show(controller: self, url: url)
    }
}
```

## Delegate

You can easily track events ocurring on the webView by implementing the delegate:

```swift
class ViewController: UIViewController {

     override func viewDidLoad() {
         super.viewDidLoad()
         webview.delegate = self
     }
}
extension ViewController: ModalWebviewProtocol{
    func didClose() {
        print("Closed")
    }
    
    func didFailOpenUrl(){
        print("Did failed to open URL")
    }
}

```

## Author

João Morais, joaopedromorais.eu@gmail.com

## License

modal_webview is available under the MIT license. See the LICENSE file for more info.
