#import "HYPPostalCodeManager.h"

#import "NSJSONSerialization+ANDYJSONFile.h"

@interface HYPPostalCodeManager ()

@property (nonatomic, retain) NSDictionary *postalCodes;

@end

@implementation HYPPostalCodeManager

+ (instancetype)sharedManager
{
    static HYPPostalCodeManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [HYPPostalCodeManager new];
    });

    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;

    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"postal_codes.json"
                                                             inBundle:[NSBundle bundleForClass:[HYPPostalCodeManager class]]];
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary new];

    for (NSDictionary *entry in JSON) {
        [mutableDictionary setValue:entry[@"City"] forKey:entry[@"Code"]];
    }

    _postalCodes = [mutableDictionary copy];

    return self;
}

- (BOOL)validatePostalCode:(NSString *)postalCode
{
    return (self.postalCodes[postalCode]) ? YES : NO;
}

- (NSString *)cityForPostalCode:(NSString *)postalCode
{
    return (self.postalCodes[postalCode]) ?: nil;
}

@end
