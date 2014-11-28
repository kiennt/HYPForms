#import "HYPDropdownFormFieldCell.h"

#import "HYPFieldValue.h"
#import "HYPFieldValuesTableViewController.h"

static const CGSize HYPDropdownPopoverSize = { .width = 320.0f, .height = 308.0f };

@interface HYPDropdownFormFieldCell () <HYPTextFieldDelegate, HYPFieldValuesTableViewControllerDelegate>

@property (nonatomic, strong) HYPFieldValuesTableViewController *fieldValuesController;

@end

@implementation HYPDropdownFormFieldCell

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame contentViewController:self.fieldValuesController
                 andContentSize:HYPDropdownPopoverSize];
    if (!self) return nil;

    [self.iconButton setImage:[UIImage imageNamed:@"ic_mini_arrow_down"] forState:UIControlStateNormal];

    return self;
}

#pragma mark - Getters

- (HYPFieldValuesTableViewController *)fieldValuesController
{
    if (_fieldValuesController) return _fieldValuesController;

    _fieldValuesController = [[HYPFieldValuesTableViewController alloc] init];
    _fieldValuesController.delegate = self;

    return _fieldValuesController;
}

#pragma mark - Private headers

- (void)updateWithField:(HYPFormField *)field
{
    [super updateWithField:field];

    if (field.fieldValue) {
        if ([field.fieldValue isKindOfClass:[HYPFieldValue class]]) {
            HYPFieldValue *fieldValue = (HYPFieldValue *)field.fieldValue;
            self.fieldValueLabel.text = fieldValue.title;
        } else {

            for (HYPFieldValue *fieldValue in field.values) {
                if ([fieldValue identifierIsEqualTo:field.fieldValue]) {
                    field.fieldValue = fieldValue;
                    self.fieldValueLabel.text = fieldValue.title;
                    break;
                }
            }
        }
    } else {
        self.fieldValueLabel.text = nil;
    }
}

- (void)updateContentViewController:(UIViewController *)contentViewController withField:(HYPFormField *)field
{
    self.fieldValuesController.field = self.field;
}

#pragma mark - HYPFieldValuesTableViewControllerDelegate

- (void)fieldValuesTableViewController:(HYPFieldValuesTableViewController *)fieldValuesTableViewController
                      didSelectedValue:(HYPFieldValue *)selectedValue
{
    self.field.fieldValue = selectedValue;

    [self updateWithField:self.field];

    [self validate];

    [self.popoverController dismissPopoverAnimated:YES];

    if ([self.delegate respondsToSelector:@selector(fieldCell:updatedWithField:)]) {
        [self.delegate fieldCell:self updatedWithField:self.field];
    }
}

@end