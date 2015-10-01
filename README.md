# MockingPlace

MockingPlace plays back GeoJSON tracks and coordinates because Xcode does not do this properly.

* Supports both the simulator and real devices.
* Generates speed and heading values from your coordinates.

[![Version](https://img.shields.io/cocoapods/v/MockingPlace.svg?style=flat)](http://cocoapods.org/pods/MockingPlace)
[![License](https://img.shields.io/cocoapods/l/MockingPlace.svg?style=flat)](http://cocoapods.org/pods/MockingPlace)
[![Platform](https://img.shields.io/cocoapods/p/MockingPlace.svg?style=flat)](http://cocoapods.org/pods/MockingPlace)

## Usage

* Include some .geojson files in your target.

* You can use http://mapbox.github.io/togeojson/ or http://converter.mygeodata.eu to convert your GPX files to GeoJSON

* `@import MockingPlace;` or `#import <MockingPlace/MockingPlace.h>` if your are not using modules.

* Add `[MockingPlace enable];` somewhere after app launch. You may want to wrap this in `#ifdef DEBUG` to avoid shipping you app with MockingPlace enabled (But you can!).

* Run your app and "double-long-tap" anywhere to bring up the track selection menu. That is a quick tap and then a long tap right after the quick tap.

To run the example project, clone the repo, and run `pod install` from the Example directory first. The example project contains two example GeoJSON files.

## Requirements

Xcode 7.x or later (for Lightweight Generics)
iOS 8.x or later

## Installation

MockingPlace is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MockingPlace"
```

## Author

Maciej Swic, maciej@swic.name

## License

MockingPlace is available under the MIT license. See the LICENSE file for more info.
