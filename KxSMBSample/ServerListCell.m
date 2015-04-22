//
//  ServerListCell.m
//  SMBFileReader
//
//  Created by ShotaTakai on 2015/04/05.
//

#import "ServerListCell.h"

@implementation ServerListCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
#pragma mark - Lifecycle
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat W = 30;
    self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.size.height/2 - W/2, W, W);
}

@end
