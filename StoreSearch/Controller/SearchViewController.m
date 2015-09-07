//
//  SearchViewController.m
//  StoreSearch
//
//  Created by zhu yongxuan on 15/9/7.
//  Copyright (c) 2015年 zhu yongxuan. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResult.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

#pragma mark - LifeCycle

@implementation SearchViewController{
    NSMutableArray *_searchResult;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //使tableview 上面留出64margin，第一行tableview不会被searchbar遮挡了
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchResult == nil) {
        return 0;
    } else if ([_searchResult count] == 0) {
        return 1;
    } else {
        return [_searchResult count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SearchResultCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }

    if ([_searchResult count] == 0) {
        cell.textLabel.text = @"Nothing Found";
        cell.detailTextLabel.text = @"";
    } else {
        SearchResult *searchResult = _searchResult[indexPath.row];
        cell.textLabel.text = searchResult.name;
        cell.detailTextLabel.text = searchResult.artistName;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_searchResult count] == 0) {
        return nil;
    } else {
        return indexPath;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBar resignFirstResponder];
    _searchResult = [NSMutableArray arrayWithCapacity:10];

    if (![searchBar.text isEqualToString:@"justin bieber"]) {
        for (int i=0; i<3; i++) {
            SearchResult *searchResult = [[SearchResult alloc] init];
            searchResult.name = [NSString stringWithFormat:@"Fake Result %d for '%d'", i];
            searchResult.artistName = _searchBar.text;
            [_searchResult addObject:searchResult];
        }
    }


    [self.tableView reloadData];
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
