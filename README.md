# Changes I made to this project
The code example, [DateCell](https://developer.apple.com/library/ios/samplecode/datecell/introduction/intro.html) demonstrates how to display UIPickerViews inline, which is the suggested UIPickerView display method since iOS 7, instead of in modal views or in action sheets. The problem with this example is the code is poorly written and difficult to understand. This code looks it was written by an Apple engineer during a 30-minute lunch break (not joking).

Apple's DateCell example comes with support for iOS 6.1. I removed this feature because 1) my apps target iOS 7 and beyond, and 2) the fewer lines of code to read the easier it will be for you to understand.

I spent 3 hours editing this code:
- Removed unused variables and uneccessary logic,
- Renamed variables so they actually describe the values which they hold
- Added my own comments and removed comments which we unclear
- Removed unused conditions
- Removed support for iOS 6.1
- Converted `if` statements to `switch` statements wherever I could. I believe `switch` statements to be easier to read.
- Set XCode to hard-mode and compiled the project, resulting in 0 warnings and errors
- Added support for sizeclasses in Storyboard, because why not?

# Description
Demonstrates formatted display of date objects in table cells and use of UIDatePicker to edit those values.

Using a grouped style UITableViewController, the sample has two UITableViewCells to draw the primary title and NSDate values.  This is accomplished using the built-in cell type "UITableViewCellStyleValue1" which supports left and right text.

As a delegate to this table, the sample uses the method "didSelectRowAtIndexPath" to open the UIDatePicker control.

For iOS 6.x and earlier, UIViewAnimation is used for sliding the UIDatePicker up on-screen and down off-screen.

For iOS 7.x, the UIDatePicker is added in-line to the table view.

The action method of the UIDatePicker will directly set the NSDate property of the custom table cell.

In addition, this sample shows how to use NSDateFormatter class to achieve the custom cell's date-formatted appearance.

# Build requirements
Xcode 5.0, iOS SDK 7.0

# Runtime requirements 
iOS 6.0 or later

# Changes from previous versions

### 1.6
Fixed bug data source cell row detection in cellForRowAtIndexPath, now using CGRectGetHeight().

### 1.5
Editorial change

### 1.4
Added a screenshot for this sample.

### 1.3
Updated to use in-line UIDatePicker for iOS 7.

### 1.2
Upgraded for iOS 6.0, now using Automatic Reference Counting (ARC) and storyboards, updated to adopt current best practices for Objective-C.

### 1.1
Upgraded project to build with the iOS 4 SDK.

### 1.0
First release.

Copyright (C) 2009-2014 Apple Inc. All rights reserved.
