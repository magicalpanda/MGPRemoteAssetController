# MGPRemoteAssetController

A remote file download component for use in your iOS apps. Please fork and contribute for compatibility with Mac Apps.

## Project Goals

* Low Memory Usage
	- Typical sample code shows all downloading happening in a memory cache within a NSURLConnection wrapper. While this is functional, the limited resources on mobile devices make this undesirable. Instead, downloads should go straight to disk and avoid caching data in system memory as much as possible

* Unit Tested
	- Most projects, especially those requiring network connections, never have unit tests. This project aims to be an example to the Cocoa community in how to properly unit test apps, even those parts that require a network connection. All contributions will only be merged with an accompanying set of passing unit tests. The test project is already set up.
	
* Fewer Dependencies
	- While libraries like ASIHTTPRequest are really awesome, this library should use as few 3rd party libraries as possible. This component only relies on frameworks available out of the box as of iOS 4.3
	
## Required Frameworks

Once you include this code in your project, you'll need to include the following frameworks:

* CFNetwork
* SystemConfiguration
* ImageIO
* CoreGraphics
* Foundation

## Usage Examples


## iOS View Controller

Provided in this library is a ready to use iOS View Controller that watches a download controller, and adds rows when downloading, removes rows when download is complete, and shows download progress.

#Legal Stuff

## Copyright

> Copyright (c) 2011 Magical Panda Software, LLC
> Building apps built on Awesome!

## MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.