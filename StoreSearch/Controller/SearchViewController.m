//
//  SearchViewController.m
//  StoreSearch
//
//  Created by zhu yongxuan on 15/9/7.
//  Copyright (c) 2015年 zhu yongxuan. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResult.h"
#import "SearchResultCell.h"
#import <AFNetworking/AFNetworking.h>
#import "DetailViewController.h"
#import "LandscapeViewController.h"
#import "Search.h"

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";
static NSString * const LoadingCellIdentifier = @"LoadingCell";
@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation SearchViewController{
    Search *_search;
    LandscapeViewController *_landscapeViewController;
    UISearchBarStyle _searchBarStyle;
    __weak DetailViewController *_detailViewController;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.segmentedControl.frame = CGRectMake(16,8, [UIScreen mainScreen].bounds.size.width -32,29);

    //使tableview 上面留出64margin，第一行tableview不会被searchbar遮挡了
    self.tableView.contentInset = UIEdgeInsetsMake(108, 0, 0, 0);
    UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    cellNib = [UINib nibWithNibName:LoadingCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:LoadingCellIdentifier];
    self.tableView.rowHeight = 80;

    [self.searchBar becomeFirstResponder];

    _searchBarStyle = UISearchBarStyleDefault;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        [self hideLandscapeViewWithDuration:duration];
    } else {
        [self showLandscapeViewWithDuration:duration];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_search == nil) {
        return 0; // Not searched yet
    } else if (_search.isLoading) {
        return 1; // Loading...
    } else if ([_search.searchResults count] == 0) {
        return 1; // Nothing Found
    } else {
        return [_search.searchResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (_search.isLoading) {
        UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier forIndexPath:indexPath];
        
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];
        [spinner startAnimating];
        return cell;
    } else if ([_search.searchResults count] == 0) {
        return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier
                                               forIndexPath:indexPath];
    } else {
        SearchResultCell *cell = (SearchResultCell *) [tableView
                dequeueReusableCellWithIdentifier:SearchResultCellIdentifier
                                     forIndexPath:indexPath];
        SearchResult *searchResult = _search.searchResults[indexPath.row];
        [cell configureForSearchResult:searchResult];

        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchBar resignFirstResponder];

    DetailViewController *controller = [[DetailViewController alloc]
            initWithNibName:@"DetailViewController" bundle:nil];
    _detailViewController = controller;
    controller.searchResult = _search.searchResults[indexPath.row];
    [self.view addSubview:controller.view];

    [controller presentInParentViewController:self];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_search.searchResults count] == 0 || _search.isLoading) {
        return nil;
    } else {
        return indexPath;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self performSearch];
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return _searchBarStyle;
}

#pragma mark - UISegmentedController

- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
    if (_search != nil) {
        [self performSearch];
    }
}

#pragma mark - Action

- (void)performSearch {
    _search = [[Search alloc] init];
    NSLog(@"allocated %@", _search);
    [_search performSearchForText:self.searchBar.text
                         category:self.segmentedControl.selectedSegmentIndex
                       completion:^(BOOL sucess) {
                           if (!sucess) {
                               [self showNetworkError];
                           }

                           [self.tableView reloadData];

                       }];
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
}

#pragma mark - Landscape

- (void)showLandscapeViewWithDuration:(NSTimeInterval)duration
{
    if (_landscapeViewController == nil) {
        _landscapeViewController = [[LandscapeViewController alloc]
                initWithNibName:@"LandscapeViewController" bundle:nil];
        _landscapeViewController.search = _search;
        _landscapeViewController.view.frame = self.view.bounds;
        _landscapeViewController.view.alpha = 0.0f;

        [self.view addSubview:_landscapeViewController.view];
        [self addChildViewController:_landscapeViewController];
        [self.searchBar resignFirstResponder];
        [_detailViewController dismissFromParentViewControllerWithAnimationType:
                DetailViewControllerAnimationTypeFade];

        [UIView animateWithDuration:duration animations:^{
            _landscapeViewController.view.alpha = 1.0f;
            _searchBarStyle = UIStatusBarStyleLightContent;
            [self setNeedsStatusBarAppearanceUpdate];
        } completion:^(BOOL finished){
            [_landscapeViewController didMoveToParentViewController:self];
        }];
    }
}

- (void)hideLandscapeViewWithDuration:(NSTimeInterval)duration
{
    if (_landscapeViewController != nil) {
        [_landscapeViewController willMoveToParentViewController:nil];
        [UIView animateWithDuration:duration animations:^{
            _landscapeViewController.view.alpha = 0.0f;

            _searchBarStyle = UISearchBarStyleDefault;
            [self setNeedsStatusBarAppearanceUpdate];
        } completion:^(BOOL finished) {
            [_landscapeViewController.view removeFromSuperview];
            [_landscapeViewController removeFromParentViewController];
            _landscapeViewController = nil;
        }];
    }
}

#pragma mark -
- (void)showNetworkError
{
    UIAlertView *alertView = [[UIAlertView alloc]
            initWithTitle:@"Whoops..."
                  message:@"There is an error reading from the iTunes Store. Please try again"
                 delegate:nil
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil];
    [alertView show];
}











@end
