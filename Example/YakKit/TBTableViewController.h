//
//  TBTableViewController.h
//  Pods
//
//  Created by Tanner on 2/11/16.
//
//

#import <UIKit/UIKit.h>

typedef void(^YYVoidBlock)();

NS_ASSUME_NONNULL_BEGIN
/// This class functions as its table view's delegate and data source. Changing either of those will
/// defeat the purpose of this class and render most of the interface useless.
@interface TBTableViewController : UITableViewController

/** The title for each row.
 @discussion For example, the title for the fifth row in the second section would be at rowTitles[1][4].
 This property is used to determine the number of rows and number of sections. For a row to appear,
 you must provide a title for every row, even if it is just an empty string. */
@property (nonatomic) NSArray<NSArray<NSString*>*> *rowTitles;
/// The titles for each section header. These are entirely optional. Provide empty strings to skip sections.
@property (nonatomic) NSArray<NSString*> *sectionTitles;
@property (nonatomic) NSArray<NSString*> *sectionHeaderTitles;
@property (nonatomic) NSArray<NSString*> *sectionFooterTitles;
/// The "swipe actions" for each row.
@property (nonatomic) NSDictionary<NSIndexPath*, NSArray<UITableViewRowAction*>*> *editActionsForRow;

/// Whether the view controller will automatically delselect each row after it has been selected. Defaults to `YES`.
@property (nonatomic) BOOL automaticallyDeselectsRows;
/// Whether or not the table view will default to allow selection of rows. Defaults to `NO`.
@property (nonatomic) BOOL defaultCanSelectRow;
/// The state of each value determines whether to allow selection at that particular index path. Defaults to `defaultCanSelectRow`.
@property (nonatomic) NSDictionary<NSIndexPath*, NSNumber*> *canSelectRow;
/// A block/closure to be executed when the given row is selected.
@property (nonatomic) NSDictionary<NSIndexPath*, YYVoidBlock> *selectionActionForRow;

/// The default cell class to be used for the table view. Defaults to `UITableViewCell`.
@property (nonatomic) Class cellClass;
/// The reuse identifier used for rows without a specified reuse identifier.
@property (nonatomic, readonly) NSString *defaultCellReuseIdentifier;
/// A pairing of each reuse identifier to a specific class. Missing rows will use the class `cellClass`.
@property (nonatomic) NSDictionary<NSString *, Class> *classesForReuseIdentifiers;
/// A pairing of reuse identifier to a row or a group of rows. Missing rows will use `defaultCellReuseIdentifier`.
@property (nonatomic) NSDictionary<NSString *, NSArray<NSIndexPath*>*> *indexPathsForReuseIdentifiers;

/// An optional block used to add additional customization to each cell before it is given back to the table view.
@property (nonatomic, copy) void (^configureCellBlock)(UITableViewCell *cell, NSString *rowTitle, NSIndexPath *indexPath);

@end
NS_ASSUME_NONNULL_END
