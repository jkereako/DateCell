/*
 File: MyTableViewController.m
 Abstract: The main table view controller of this app.
 Version: 1.6

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2014 Apple Inc. All Rights Reserved.

 */

#import "MyTableViewController.h"

#define kPickerAnimationDuration    0.40   // duration for the animation to slide the date picker into view
#define kDatePickerTag              99     // view tag identifying the date picker view

#define kTitleKey       @"title"   // key for obtaining the data source item's title
#define kDateKey        @"date"    // key for obtaining the data source item's date value

// keep track of which rows have date cells
#define kDateStartRow   1
#define kDateEndRow     2

static NSString *kDateCellID = @"dateCell";     // the cells with the start or end date
static NSString *kDatePickerID = @"datePicker"; // the cell containing the date picker
static NSString *kOtherCell = @"otherCell";     // the remaining cells at the end


#pragma mark - Class extension

NSUInteger DeviceSystemMajorVersion(void);

@interface MyTableViewController ()

@property (nonatomic, readwrite) NSArray *dataSource;
@property (nonatomic, readwrite) NSDateFormatter *dateFormatter;
@property (nonatomic, readwrite) NSIndexPath *datePickerIndexPath;
@property (nonatomic, readwrite) CGFloat datePickerRowHeight;

- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath;
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath;
- (void)updateDatePicker;
- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath;
- (IBAction)dateAction:(id)sender;

@end

#pragma mark - Implementation
@implementation MyTableViewController

/*! Primary view has been loaded for this view controller
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    // setup our data source
    NSMutableDictionary *itemOne = [@{ kTitleKey : @"Tap a cell to change its date:" } mutableCopy];
    NSMutableDictionary *itemTwo = [@{ kTitleKey : @"Start Date",
                                       kDateKey : [NSDate date] } mutableCopy];
    NSMutableDictionary *itemThree = [@{ kTitleKey : @"End Date",
                                         kDateKey : [NSDate date] } mutableCopy];
    NSMutableDictionary *itemFour = [@{ kTitleKey : @"(other item1)" } mutableCopy];
    NSMutableDictionary *itemFive = [@{ kTitleKey : @"(other item2)" } mutableCopy];

    self.dataSource = @[itemOne, itemTwo, itemThree, itemFour, itemFive];
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.dateFormatter.timeStyle = NSDateFormatterNoStyle;

    // Obtain the height of the table view cell containing the date picker
    UITableViewCell *datePickerCell = [self.tableView dequeueReusableCellWithIdentifier:kDatePickerID];
    self.datePickerRowHeight = CGRectGetHeight(datePickerCell.frame);

    // Notify this object if the user changes locale settings.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localeChanged:)
                                                 name:NSCurrentLocaleDidChangeNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSCurrentLocaleDidChangeNotification
                                                  object:nil];
}


#pragma mark - Locale

/*! Responds to region format or locale changes.
 */
- (void)localeChanged:(__unused NSNotification *)notif {
    [self.tableView reloadData];
}


#pragma mark - Utilities

/*! Returns the major version of iOS, (i.e. for iOS 6.1.3 it returns 6)
 */
NSUInteger DeviceSystemMajorVersion(void) {
    static NSUInteger _deviceSystemMajorVersion = 0;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        // Sending the message unsignedInterValue to an NSString raises an
        // an "unrecognized selector" exception. Instead, we must invoke
        // integerValue and cast the result as an NSUInteger.
        _deviceSystemMajorVersion =
        (NSUInteger)[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] integerValue];
    });

    return _deviceSystemMajorVersion;
}

#define EMBEDDED_DATE_PICKER (DeviceSystemMajorVersion() >= 7)

/*! Determines if the given indexPath points to a cell that contains the UIDatePicker.

 @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
 */
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath {
    BOOL result = NO;

    if (self.datePickerIndexPath) {
        if (self.datePickerIndexPath.row == indexPath.row) {
            result = YES;
        }
    }

    return result;
}

/*! Determines if the given indexPath points to a cell that contains the start/end dates.

 @param indexPath The indexPath to check if it represents start/end date cell.
 */
- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath {
    BOOL result = NO;

    switch (indexPath.row) {
        case kDateStartRow:
        case kDateEndRow:
            result = YES;
            break;
    }

    return result;
}


#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(__unused UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ([self indexPathHasPicker:indexPath]) ? self.datePickerRowHeight : self.tableView.rowHeight;
}

- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(__unused NSInteger)section {
    NSUInteger rowCount = self.dataSource.count;

    // If a datepicker is visible, then account for it by incrementing the row
    // count by 1
    if (self.datePickerIndexPath) {
        rowCount ++;
    }

    return (NSInteger)rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSString *reuseIdentifier = kOtherCell;
    NSInteger row = indexPath.row;
    NSDictionary *dataSource;

    // Does this index path have a date picker? If so, decrement the row.
    if ([self indexPathHasPicker:indexPath]) {
        reuseIdentifier = kDatePickerID;
        row --;
    }

    // Else, does this index path have a date string?
    else if ([self indexPathHasDate:indexPath]) {
        reuseIdentifier = kDateCellID;
    }

    cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

    // Remove selections from the first row since it's just a title.
    if (indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    dataSource = self.dataSource[(NSUInteger)row];

    //-- Table view cell configuration
    if ([reuseIdentifier isEqualToString:kDateCellID]) {
        cell.textLabel.text = dataSource[kTitleKey];
        cell.detailTextLabel.text = [self.dateFormatter stringFromDate:dataSource[kDateKey]];
    }

    else if ([reuseIdentifier isEqualToString:kOtherCell]) {
        cell.textLabel.text = dataSource[kTitleKey];
    }

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    // If the selected cell is a "date cell", then present a UIDatePicker below
    // it.
    if (cell.reuseIdentifier == kDateCellID) {
        if (EMBEDDED_DATE_PICKER) {
            [self displayInlineDatePickerForRowAtIndexPath:indexPath];
        }
    }

    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark -

/*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".

 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView beginUpdates];

    // Is a date picker already showing? If so, remove it from the table view.
    if (self.datePickerIndexPath) {
        [self.tableView deleteRowsAtIndexPaths:@[self.datePickerIndexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
    }

    // Otherwise, add a new date picker to the table view
    else {
        self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1
                                                      inSection:indexPath.section];

        [self.tableView insertRowsAtIndexPaths:@[self.datePickerIndexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self.tableView endUpdates];

    [self updateDatePicker];
}

/*! Updates the UIDatePicker's value to match with the date of the cell above it.
 */
- (void)updateDatePicker {
    if (!self.datePickerIndexPath) {
        return;
    }

    UITableViewCell *datePickerCell = [self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];
    UIDatePicker *datePicker = (UIDatePicker *)[datePickerCell viewWithTag:kDatePickerTag];

    if (datePicker) {
        NSDictionary *itemData = self.dataSource[(NSUInteger)self.datePickerIndexPath.row - 1];
        datePicker.date = itemData[kDateKey];
    }
    
}

#pragma mark - Actions

/*! User chose to change the date by changing the values inside the UIDatePicker.

 @param sender The sender for this action: UIDatePicker.
 */
- (IBAction)dateAction:(id)sender {
    NSIndexPath *indexPath;
    UITableViewCell *cell;
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    NSMutableDictionary *dataSource;

    // If the date picker is showing, update it's owner cell which will always
    // be 1 row above.
    if (self.datePickerIndexPath) {
        indexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1
                                       inSection:0];
    }

    cell = [self.tableView cellForRowAtIndexPath:indexPath];

    // update our data model
    dataSource = self.dataSource[(NSUInteger)indexPath.row];
    dataSource[kDateKey] = datePicker.date;

    // update the cell's date string
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:datePicker.date];
}

@end

