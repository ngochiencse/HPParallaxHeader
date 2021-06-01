# HPParallaxHeader

[![Travis (.com)](https://img.shields.io/travis/com/ngochiencse/HPParallaxHeader)](https://www.travis-ci.com/github/ngochiencse/HPParallaxHeader)
[![Version](https://img.shields.io/cocoapods/v/HPParallaxHeader.svg?style=flat)](http://cocoapods.org/pods/HPParallaxHeader)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/HPParallaxHeader.svg?style=flat)](http://cocoapods.org/pods/HPParallaxHeader)
[![Platform](https://img.shields.io/cocoapods/p/HPParallaxHeader.svg?style=flat)](http://cocoapods.org/pods/HPParallaxHeader)

:warning: This project is no longer maintained, see [#124](https://github.com/maxep/HPParallaxHeader/issues/124) :warning:

HPParallaxHeader is a simple header class for UIScrollView.

In addition, HPScrollView is a UIScrollView subclass with the ability to hook the vertical scroll from its subviews, this can be used to add a parallax header to complex view hierachy. Moreover, HPScrollViewController allows you to add a HPParallaxHeader to any kind of UIViewController.

|             UIScrollView        |           HPScrollViewController          |
|---------------------------------|-------------------------------------------|
|![Demo](Example/demo1.gif)|![Demo](Example/demo2.gif)|

## Usage

If you want to try it, simply run:

```
pod try HPParallaxHeader
```

+ Adding a parallax header to a UIScrollView is straightforward, e.g:

```swift
let headerView = UIImageView()
headerView.image = UIImage(named: "success-baby")
headerView.contentMode = .scaleAspectFit

let scrollView = UIScrollView()
scrollView.parallaxHeader.view = headerView
scrollView.parallaxHeader.height = 150
scrollView.parallaxHeader.mode = .fill
scrollView.parallaxHeader.minimumHeight = 20
```

+ The HPScrollViewController is a container with a child view controller that can be added programmatically or using the custom segue HPScrollViewControllerSegue.

+ Please check examples for **Swift** implementations.

## Installation

### Swift Package Manager 

You can use  [Swift Package Manager](https://swift.org/package-manager/)  directly within Xcode or add it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/mexp/HPParallaxHeader", .upToNextMajor(from: "1.1.0"))
]
```

### CocoaPods

HPParallaxHeader is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "HPParallaxHeader"
```

## Documentation

Documentation is available through [CocoaDocs](http://cocoadocs.org/docsets/HPParallaxHeader/).

## Author

[Hien Pham](https://github.com/ngochiencse)

![Twitter URL](https://img.shields.io/twitter/url?label=Hien%20Pham&url=https%3A%2F%2Ftwitter.com%2Fngochien91)

## License

HPParallaxHeader is available under the MIT license. See the LICENSE file for more info.
