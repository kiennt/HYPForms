#import "HYPFormFieldHeadingLabel.h"

#import "UIColor+ANDYHex.h"
#import "UIFont+HYPFormsStyles.h"
#import "UIColor+HYPFormsColors.h"

@implementation HYPFormFieldHeadingLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    self.font = [UIFont HYPFormsSmallSize];
    self.textColor = [UIColor HYPFormsCoreBlue];

    return self;
}

@end
