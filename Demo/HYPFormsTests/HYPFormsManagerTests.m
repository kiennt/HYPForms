@import XCTest;

#import "HYPFormsManager.h"

#import "HYPForm.h"
#import "HYPFormSection.h"
#import "HYPFormField.h"
#import "HYPFormTarget.h"
#import "HYPFieldValidation.h"
#import "HYPFormsCollectionViewDataSource.h"

#import "NSDictionary+ANDYSafeValue.h"
#import "NSJSONSerialization+ANDYJSONFile.h"

@interface HYPFormsManagerTests : XCTestCase

@property (nonatomic, strong) HYPFormsManager *manager;
@property (nonatomic, strong) HYPFormsCollectionViewDataSource *dataSource;

@end

@implementation HYPFormsManagerTests

- (void)testFormsGeneration
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"forms.json"];

    HYPFormsManager *manager = [[HYPFormsManager alloc] initWithJSON:JSON
                                                       initialValues:nil
                                                            disabled:NO];

    XCTAssertNotNil(manager.forms);

    XCTAssertTrue(manager.forms.count > 0);

    XCTAssertTrue(manager.hiddenFieldsAndFieldIDsDictionary.count == 0);

    XCTAssertTrue(manager.hiddenSections.count == 0);
}

- (void)testDefaultValues
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"default-values.json"
                                                             inBundle:[NSBundle bundleForClass:[self class]]];

    NSDate *date = [NSDate date];

    HYPFormsManager *manager = [[HYPFormsManager alloc] initWithJSON:JSON
                                                       initialValues:@{@"contract_type" : [NSNull null],
                                                                       @"start_date" : date,
                                                                       @"base_salary": @2}
                                                            disabled:NO];

    XCTAssertEqualObjects([manager.values objectForKey:@"contract_type"], @0);
    XCTAssertEqualObjects([manager.values objectForKey:@"start_date"], date);
    XCTAssertEqualObjects([manager.values objectForKey:@"base_salary"], @2);
}

- (void)testCalculatedValues
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"number-formula.json"
                                                             inBundle:[NSBundle bundleForClass:[self class]]];

    HYPFormsManager *manager = [[HYPFormsManager alloc] initWithJSON:JSON
                                                       initialValues:@{@"base_salary" : @1,
                                                                       @"bonus" : @100}
                                                            disabled:NO];

    XCTAssertEqualObjects([manager.values objectForKey:@"base_salary"], @1);
    XCTAssertEqualObjects([manager.values objectForKey:@"bonus"], @100);
    XCTAssertEqualObjects([manager.values objectForKey:@"total"], @300);
}

- (void)testFormsGenerationHideTargets
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"forms.json"];

    HYPFormsManager *manager = [[HYPFormsManager alloc] initWithJSON:JSON
                                                       initialValues:@{@"contract_type" : @1}
                                                            disabled:NO];

    XCTAssertTrue(manager.hiddenFieldsAndFieldIDsDictionary.count > 0);

    XCTAssertTrue(manager.hiddenSections.count > 0);
}

- (void)testRequiredFields
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"forms.json"];

    HYPFormsManager *manager = [[HYPFormsManager alloc] initWithJSON:JSON
                                                       initialValues:nil
                                                            disabled:NO];

    NSDictionary *requiredFormFields = [manager requiredFormFields];

    XCTAssertTrue([requiredFormFields andy_valueForKey:@"first_name"]);

    XCTAssertTrue([requiredFormFields andy_valueForKey:@"last_name"]);

    XCTAssertNil([requiredFormFields andy_valueForKey:@"address"]);
}

- (void)testFieldValidation
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"field-validations.json"
                                                             inBundle:[NSBundle bundleForClass:[self class]]];

    HYPFormsManager *manager = [[HYPFormsManager alloc] initWithJSON:JSON
                                                       initialValues:nil
                                                            disabled:NO];

    NSArray *fields = [manager invalidFormFields];

    XCTAssertTrue(fields.count == 1);

    XCTAssertEqualObjects([[fields firstObject] fieldID], @"first_name");
}

- (void)testFieldWithIDWithIndexPath
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"forms.json"];

    HYPFormsManager *manager = [[HYPFormsManager alloc] initWithJSON:JSON
                                                       initialValues:@{@"first_name" : @"Elvis",
                                                                       @"last_name" : @"Nunez"}
                                                            disabled:NO];

    HYPFormField *firstNameField = [manager fieldWithID:@"first_name" includingHiddenFields:NO];
    XCTAssertNotNil(firstNameField);
    XCTAssertEqualObjects(firstNameField.fieldID, @"first_name");

    [self.dataSource processTarget:[HYPFormTarget hideFieldTargetWithID:@"start_date"]];
    HYPFormField *startDateField = [manager fieldWithID:@"start_date" includingHiddenFields:NO];
    XCTAssertNotNil(startDateField);
    XCTAssertEqualObjects(startDateField.fieldID, @"start_date");
    [self.dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"start_date"]];

    [self.dataSource processTarget:[HYPFormTarget hideSectionTargetWithID:@"employment-1"]];
    HYPFormField *contractTypeField = [manager fieldWithID:@"contract_type" includingHiddenFields:NO];
    XCTAssertNotNil(contractTypeField);
    XCTAssertEqualObjects(contractTypeField.fieldID, @"contract_type");
    [self.dataSource processTarget:[HYPFormTarget showSectionTargetWithID:@"employment-1"]];
}

- (void)testShowingFieldMultipleTimes
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"multiple-show-hide-field-targets.json"
                                                             inBundle:[NSBundle bundleForClass:[self class]]];

    HYPFormsManager *normalManager = [[HYPFormsManager alloc] initWithJSON:JSON
                                                             initialValues:@{@"contract_type" : @1,
                                                                             @"salary_type": @1}
                                                                  disabled:NO];

    NSUInteger numberOfFields = [[[normalManager.forms firstObject] fields] count];
    XCTAssertEqual(numberOfFields, 2);

    HYPFormsManager *evaluatedManager = [[HYPFormsManager alloc] initWithJSON:JSON
                                                                initialValues:@{@"contract_type" : @0,
                                                                                @"salary_type": @0}
                                                                     disabled:NO];

    NSUInteger numberOfFieldsWithHiddenTargets = [[[evaluatedManager.forms firstObject] fields] count];
    XCTAssertEqual(numberOfFieldsWithHiddenTargets, 3);
}

- (void)testHidingFieldMultipleTimes
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"multiple-show-hide-field-targets.json"
                                                             inBundle:[NSBundle bundleForClass:[self class]]];

    HYPFormsManager *normalManager = [[HYPFormsManager alloc] initWithJSON:JSON
                                                             initialValues:nil
                                                                  disabled:NO];

    NSUInteger numberOfFields = [[[normalManager.forms firstObject] fields] count];
    XCTAssertEqual(numberOfFields, 3);

    HYPFormsManager *evaluatedManager = [[HYPFormsManager alloc] initWithJSON:JSON
                                                                initialValues:@{@"contract_type" : @1,
                                                                                @"salary_type": @1}
                                                                     disabled:NO];

    NSUInteger numberOfFieldsWithHiddenTargets = [[[evaluatedManager.forms firstObject] fields] count];
    XCTAssertEqual(numberOfFieldsWithHiddenTargets, 2);
}

- (void)testShowingSectionMultipleTimes
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"multiple-show-hide-section-targets.json"
                                                             inBundle:[NSBundle bundleForClass:[self class]]];

    HYPFormsManager *normalManager = [[HYPFormsManager alloc] initWithJSON:JSON
                                                             initialValues:@{@"contract_type" : @1,
                                                                             @"salary_type": @1}
                                                                  disabled:NO];

    NSUInteger numberOfSections = [[[normalManager.forms firstObject] sections] count];
    XCTAssertEqual(numberOfSections, 2);

    HYPFormsManager *evaluatedManager = [[HYPFormsManager alloc] initWithJSON:JSON
                                                                initialValues:@{@"contract_type" : @0,
                                                                                @"salary_type": @0}
                                                                     disabled:NO];

    NSUInteger numberOfSectionsWithHiddenTargets = [[[evaluatedManager.forms firstObject] sections] count];
    XCTAssertEqual(numberOfSectionsWithHiddenTargets, 3);
}

- (void)testHidingSectionMultipleTimes
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"multiple-show-hide-section-targets.json"
                                                             inBundle:[NSBundle bundleForClass:[self class]]];

    HYPFormsManager *normalManager = [[HYPFormsManager alloc] initWithJSON:JSON
                                                             initialValues:nil
                                                                  disabled:NO];

    NSUInteger numberOfSections = [[[normalManager.forms firstObject] sections] count];
    XCTAssertEqual(numberOfSections, 3);

    HYPFormsManager *evaluatedManager = [[HYPFormsManager alloc] initWithJSON:JSON
                                                                initialValues:@{@"contract_type" : @1,
                                                                                @"salary_type": @1}
                                                                     disabled:NO];

    NSUInteger numberOfSectionsWithHiddenTargets = [[[evaluatedManager.forms firstObject] sections] count];
    XCTAssertEqual(numberOfSectionsWithHiddenTargets, 2);
}

@end
