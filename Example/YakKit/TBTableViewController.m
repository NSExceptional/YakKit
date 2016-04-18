//
//  TBTableViewController.m
//  Pods
//
//  Created by Tanner on 2/11/16.
//
//

#import "TBTableViewController.h"

#define RunBlock(block) if (block) block()
#define RunBlockP(block, ...) if (block) block(__VA_ARGS__)


#pragma mark - TBTableViewController -

@interface TBTableViewController ()
@property (nonatomic) NSDictionary<NSIndexPath*, NSString*> *_indexPathsToReuseIdentifiers;
@end

@implementation TBTableViewController

- (void)loadView {
    [super loadView];
    self.cellClass = [UITableViewCell class];
    _automaticallyDeselectsRows = YES;
}

- (NSString *)defaultCellReuseIdentifier { return @"__TBTableViewController_default_reuse_aBcDeFg"; }

#pragma mark Custom setters

- (void)setRowTitles:(NSArray *)rowTitles {
    _rowTitles = rowTitles;
    [self.tableView reloadData];
}

- (void)setSectionTitles:(NSArray<NSString *> *)sectionTitles {
    _sectionTitles = sectionTitles;
    [self.tableView reloadData];
}

- (void)setCellClass:(Class)cellClass {
    if (cellClass == nil) cellClass = [UITableViewCell class];
    _cellClass = cellClass;
    [self.tableView registerClass:cellClass forCellReuseIdentifier:self.defaultCellReuseIdentifier];
}

- (void)setClassesForReuseIdentifiers:(NSDictionary<NSString *,Class> *)classesForReuseIdentifiers {
    _classesForReuseIdentifiers = classesForReuseIdentifiers;
    
    [classesForReuseIdentifiers enumerateKeysAndObjectsUsingBlock:^(NSString *reuse, Class cls, BOOL *stop) {
        [self.tableView registerClass:cls forCellReuseIdentifier:reuse];
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_automaticallyDeselectsRows) [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RunBlock(self.selectionActionForRow[indexPath]);
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *ret = self.canSelectRow[indexPath];
    if (ret) {
        return ret.boolValue;
    }
    
    return self.defaultCanSelectRow;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.editActionsForRow[indexPath] ?: @[];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = self._indexPathsToReuseIdentifiers[indexPath] ?: self.defaultCellReuseIdentifier;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    cell.textLabel.text = self.rowTitles[indexPath.section][indexPath.row];
    RunBlockP(_configureCellBlock, cell, self.rowTitles[indexPath.section][indexPath.row], indexPath);
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.rowTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rowTitles[section].count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sectionTitles;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section < self.sectionHeaderTitles.count)
        return self.sectionHeaderTitles[section];
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section < self.sectionFooterTitles.count)
        return self.sectionFooterTitles[section];
    return nil;
}

@end
