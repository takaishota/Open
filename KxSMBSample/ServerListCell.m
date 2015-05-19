//
//  ServerListCell.m
//  SMBFileReader
//
//  Created by ShotaTakai on 2015/04/05.
//

#import "ServerListCell.h"
#import "UIColor+CustomColors.h"
#import <POP/POP.h>

@implementation ServerListCell

#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = [UIColor customGrayColor];
        self.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:20];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([reuseIdentifier isEqualToString:@"EditableCell"]) {
            self.accessoryView = [self generateAccessoryButton];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat W = 30;
    CGFloat xOffset = 50;
    self.imageView.frame = CGRectMake(xOffset, self.frame.size.height/2 - W/2, W, W);
}

#pragma mark - Custom Accessors
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (self.highlighted) {
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.duration = 0.1;
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.95, 0.95)];
        [self.textLabel pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    } else {
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        scaleAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
        scaleAnimation.springBounciness = 20.f;
        [self.textLabel pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (UIButton*)generateAccessoryButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, self.bounds.size.height);
    button.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:16];
    [button setTitle:@"編集" forState:UIControlStateNormal];
    [button setTitleColor:self.tintColor forState:UIControlStateNormal];
    
    return button;
}

@end
