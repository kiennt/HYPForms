@import UIKit;

#import "HYPFormFieldHeadingLabel.h"

#import "HYPTextField.h"
#import "HYPFormFieldHeadingLabel.h"

#import "HYPFormField.h"

static const CGFloat HYPFormFieldCellMarginTop = 30.0f;
static const CGFloat HYPFormFieldCellMarginBottom = 10.0f;

static const NSInteger HYPFieldCellMargin = 10.0f;
static const NSInteger HYPFieldCellItemSmallHeight = 1.0f;
static const NSInteger HYPFieldCellItemHeight = 85.0f;

static const CGFloat HYPTextFormFieldCellMarginX = 10.0f;

static const CGFloat HYPFormFieldCellBorderWidth = 1.0f;
static const CGFloat HYPFormFieldCellCornerRadius = 5.0f;
static const CGFloat HYPFormFieldCellLeftMargin = 10.0f;

@protocol HYPBaseFormFieldCellDelegate;

@interface HYPBaseFormFieldCell : UICollectionViewCell

@property (nonatomic, strong) HYPFormFieldHeadingLabel *headingLabel;

@property (nonatomic, strong) HYPFormField *field;
@property (nonatomic, getter = isDisabled) BOOL disabled;

@property (nonatomic, weak) id <HYPBaseFormFieldCellDelegate> delegate;

- (void)updateFieldWithDisabled:(BOOL)disabled;
- (void)updateWithField:(HYPFormField *)field;
- (void)validate;

@end

@protocol HYPBaseFormFieldCellDelegate <NSObject>

- (void)fieldCell:(UICollectionViewCell *)fieldCell updatedWithField:(HYPFormField *)field;
- (void)fieldCell:(UICollectionViewCell *)fieldCell processTargets:(NSArray *)targets;

@end
