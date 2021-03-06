//
//  DetailViewController.h
//  StoreSearch
//
//  Created by zhu yongxuan on 15/9/8.
//  Copyright (c) 2015年 zhu yongxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResult;

typedef NS_ENUM(NSInteger, DetailViewControllerAnimationType) {
    DetailViewControllerAnimationTypeSlide,
    DetailViewControllerAnimationTypeFade
};
@interface DetailViewController : UIViewController<UISplitViewControllerDelegate>

@property (nonatomic, strong) SearchResult *searchResult;

@property (nonatomic, weak) IBOutlet UIView *popupView;
@property (nonatomic, weak) IBOutlet UIImageView *artworkImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *kindLabel;
@property (nonatomic, weak) IBOutlet UILabel *genreLabel;
@property (nonatomic, weak) IBOutlet UIButton *priceButton;

- (void)presentInParentViewController:(UIViewController *)parentViewController;
- (void)dismissFromParentViewControllerWithAnimationType:(DetailViewControllerAnimationType)animationType;
- (void)sendSupportEmail;
@end
