# TranslatorSwift

[![CI Status](http://img.shields.io/travis/git/TranslatorSwift.svg?style=flat)](https://travis-ci.org/git/TranslatorSwift)
[![Version](https://img.shields.io/cocoapods/v/TranslatorSwift.svg?style=flat)](http://cocoapods.org/pods/TranslatorSwift)
[![License](https://img.shields.io/cocoapods/l/TranslatorSwift.svg?style=flat)](http://cocoapods.org/pods/TranslatorSwift)
[![Platform](https://img.shields.io/cocoapods/p/TranslatorSwift.svg?style=flat)](http://cocoapods.org/pods/TranslatorSwift)

## Example

```
import TranslatorSwift

let translator = Translator(subscriptionKey: "YOUR_KEY")

@IBAction func onTranslateButton(_ sender: Any) {
    translator.translate(input: inputTextField.text!, to: "ja") { (result) in
        switch result {
        case .success(let translation):
            self.outputLabel.text = translation
        case .failure(let error):
            self.outputLabel.text = error.debugDescription
        }
    }
}
```

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

TranslatorSwift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "TranslatorSwift"
```

## Author

git, kreuz45@kreuz45.com

## License

TranslatorSwift is available under the MIT license. See the LICENSE file for more info.
