//
//  DetailViewController.m
//  StoreSearch
//
//  Created by zhu yongxuan on 15/9/8.
//  Copyright (c) 2015年 zhu yongxuan. All rights reserved.
//

#import "DetailViewController.h"
#import "SearchResult.h"
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface DetailViewController () <UIGestureRecognizerDelegate>

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]
            initWithTarget:self action:@selector(close:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:gestureRecognizer];

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
}

#pragma - GestureRecognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return (touch.view == self.view);
}

#pragma mark - Action

- (IBAction)close:(id)sender
{
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (IBAction)openInStore:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.searchResult.storeURL]];
}

@end
