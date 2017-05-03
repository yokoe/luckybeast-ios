# LuckyBeast
けものフレンズに出てくるラッキービストみたいな何かをiPhoneで作ってみるテスト

詳細

* https://twitter.com/croquette0212/status/848385807270289409
* https://twitter.com/croquette0212/status/853465013024980992
* [iPhoneのSFSpeechRecognizerとAVSpeechSynthesizerと発泡スチロールでボスっぽいなにかを作る](http://qiita.com/croquette0212/items/bf0e41ca1b65c6d320b4)

## 動作環境/必要なもの
* iOS 10以降
* Microsoft Translator APIのSubscription Key
* Google Cloud Vision APIのKey

## ビルド方法
### CoocaPods

CocoaPodsが必要です。

```
pod install
```

### キーの設定
Microsoft Translator APIとGoogle Cloud Vision APIの利用のため、キーの設定が必要です。

`Keys.plist`の`GOOGLE_CLOUD_VISION_API_KEY`と`MICROSOFT_TRANSLATOR_SUBSCRIPTION_KEY`をそれぞれ設定してください。

## ライセンス
MIT License
