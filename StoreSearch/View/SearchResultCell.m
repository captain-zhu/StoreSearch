//
//  SearchResultCell.m
//  StoreSearch
//
//  Created by zhu yongxuan on 15/9/7.
//  Copyright (c) 2015年 zhu yongxuan. All rights reserved.
//

#import "SearchResultCell.h"
#import "SearchResult.h"
#import "UIImageView+AFNetworking.h"

@implementation SearchResultCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    UIView *selectedView = [[UIView alloc] initWithFrame:CGRectZero];
    selectedView.backgroundColor = [UIColor colorWithRed:20/255.0f
                                                   green:160/255.0f blue:160/255.0f alpha:0.5f];
    self.selectedBackgroundView = selectedView;
}

- (void)configureForSearchResult:(SearchResult *)searchResult
{
    self.nameLabel.text = searchResult.name;

    NSString *artistName = searchResult.artistName;
    if (artistName == nil) {
        artistName = @"Unkwnown";
    }

    NSString *kind = [searchResult kindForDisplay];
    self.artistNameLabel.text = [NSString stringWithFormat:
            @"%@ (%@)", artistName, kind];
    [self.artworkImageView setImageWithURL:[NSURL URLWithString:searchResult.artworkURL60]
                          placeholderImage:[UIImage imageNamed:@"Placeholder"]];
}

#pragma mark - ReUse
- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.artworkImageView cancelImageRequestOperation];
    self.nameLabel.text = nil;
    self.artistNameLabel.text = nil;
}

@end
