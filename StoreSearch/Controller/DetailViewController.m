//
//  DetailViewController.m
//  StoreSearch
//
//  Created by zhu yongxuan on 15/9/8.
//  Copyright (c) 2015年 zhu yongxuan. All rights reserved.
//

#import "DetailViewController.h"
#import "SearchResult.h"
#import "GradientView.h"
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "MenuViewController.h"
#import "MessageUI/MessageUI.h"

@interface DetailViewController () <UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) UIPopoverController *menuPopoverController;

@end

@implementation DetailViewController{
    GradientView *_gradientView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.view.backgroundColor =
                [UIColor colorWithPatternImage:
                        [UIImage imageNamed:@"LandscapeBackground"]];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                     target:self action:@selector(menuButtonPressed:)];
        self.popupView.hidden = (self.searchResult == nil);
    } else {
        self.view.backgroundColor = [UIColor clearColor];

        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]
                initWithTarget:self action:@selector(close:)];
        gestureRecognizer.cancelsTouchesInView = NO;
        gestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:gestureRecognizer];
    }

    UIImage *image = [[UIImage imageNamed:@"PriceButton"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.priceButton setBackgroundImage:image
                                forState:UIControlStateNormal];
    self.view.tintColor = [UIColor colorWithRed:20/255.0f
                                          green:160/255.0f blue:160/255.0f alpha:1.0f];
    self.popupView.layer.cornerRadius = 10.0f;

    if (self.searchResult != nil) {
        [self updateUI];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"dealloc %@", self);

    [self.artworkImageView cancelImageRequestOperation];
}

#pragma mark - UpdateUI

- (void)updateUI
{
    self.nameLabel.text = self.searchResult.name;
    NSString *artistName = self.searchResult.artistName;
    if (artistName == nil) {
        artistName = @"Unknown";
    }
    self.artistNameLabel.text = artistName;
    self.kindLabel.text = [self.searchResult kindForDisplay];
    self.genreLabel.text = self.searchResult.genre;

    // update price label
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setCurrencyCode:self.searchResult.currency];

    NSString *priceText;
    if ([self.searchResult.price floatValue] == 0.0f) {
        priceText = @"Free";
    } else {
        priceText = [formatter stringFromNumber:self.searchResult.price];
    }

    [self.priceButton setTitle:priceText forState:UIControlStateNormal];

    // download image
    [self.artworkImageView setImageWithURL:[NSURL URLWithString:self.searchResult.artworkURL100]];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.popupView.hidden = NO;
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

#pragma - GestureRecognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return (touch.view == self.view);
}

#pragma mark - Action

- (IBAction)close:(id)sender
{
    [self dismissFromParentViewControllerWithAnimationType:DetailViewControllerAnimationTypeSlide];
}

- (IBAction)openInStore:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.searchResult.storeURL]];
}

- (void)menuButtonPressed:(UIBarButtonItem *)sender
{
    if ([self.menuPopoverController isPopoverVisible]) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    } else {
        [self.menuPopoverController presentPopoverFromBarButtonItem:sender
                                           permittedArrowDirections:UIPopoverArrowDirectionAny
                                                           animated:YES];
    }
}

#pragma mark - getter

- (UIPopoverController *)menuPopoverController
{
    if (_menuPopoverController == nil) {
        MenuViewController *menuViewController = [[MenuViewController alloc] initWithStyle:UITableViewStyleGrouped];

        menuViewController.detailViewController = self;

        _menuPopoverController = [[UIPopoverController alloc] initWithContentViewController:menuViewController];
    }
    return _menuPopoverController;
}

#pragma mark - Change view Controller

- (void)dismissFromParentViewControllerWithAnimationType:(DetailViewControllerAnimationType)animationType
{
    [self willMoveToParentViewController:nil];

    [UIView animateWithDuration:0.3 animations:^{
        if (animationType == DetailViewControllerAnimationTypeSlide) {
            CGRect rect = self.view.bounds;
            rect.origin.y += rect.size.height;
            self.view.frame = rect;
        } else {
            self.view.alpha = 0.0f;
        }
        _gradientView.alpha = 0.0f;
    } completion:^(BOOL finished){
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        [_gradientView removeFromSuperview];
    }];


}

- (void)presentInParentViewController:
        (UIViewController *)parentViewController
{
    _gradientView = [[GradientView alloc] initWithFrame:parentViewController.view.bounds];
    [parentViewController.view addSubview:_gradientView];

    self.view.frame = parentViewController.view.bounds;
    [parentViewController.view addSubview:self.view];
    [parentViewController addChildViewController:self];

    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];

    bounceAnimation.duration = 0.4;
    bounceAnimation.delegate = self;

    bounceAnimation.values = @[ @0.7, @1.2, @0.9, @1.0 ];
    bounceAnimation.keyTimes = @[ @0.0, @0.334, @0.666, @1.0 ];

    bounceAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

    [self.view.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];

    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = @0.0f;
    fadeAnimation.toValue = @1.0f;
    fadeAnimation.duration = 0.2;
    [_gradientView.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];

}

#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self didMoveToParentViewController:self.parentViewController];
}

#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Search";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)splitViewController:(UISplitViewController *)svc
          popoverController:(UIPopoverController *)pc
  willPresentViewController:(UIViewController *)aViewController
{
    if ([self.menuPopoverController isPopoverVisible]) {
        [self.menuPopoverController dismissPopoverAnimated:YES];
    }
}

#pragma mark -

- (void)setSearchResult:(SearchResult *)newSearchResult
{
    if (_searchResult != newSearchResult) {
        _searchResult = newSearchResult;
        if ([self isViewLoaded]) {
            [self updateUI];
        }
    }
}

#pragma mark - sendEmail

- (void)sendSupportEmail
{
    [self.menuPopoverController dismissPopoverAnimated:YES];

    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];

    if (controller != nil) {
        controller.mailComposeDelegate = self;
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        [controller setSubject:@"Support Request"];
        [controller setToRecipients:@[@"andypaker@qq.com"]];

        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
