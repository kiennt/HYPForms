#import "HYPFormField.h"

@interface HYPInputValidator : NSObject

@property (nonatomic, strong) NSDictionary *validations;

- (BOOL)validateReplacementString:(NSString *)string withText:(NSString *)text withRange:(NSRange)range;

@end
