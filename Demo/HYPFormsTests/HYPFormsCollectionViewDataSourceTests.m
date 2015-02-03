@import UIKit;
@import XCTest;

#import "HYPFieldValidation.h"
#import "HYPForm.h"
#import "HYPFormField.h"
#import "HYPFormsCollectionViewDataSource.h"
#import "HYPFormSection.h"
#import "HYPFormsManager.h"
#import "HYPFormTarget.h"

#import "NSJSONSerialization+ANDYJSONFile.h"

@interface HYPFormsCollectionViewDataSourceTests : XCTestCase <HYPFormsLayoutDataSource>

@property (nonatomic, strong) HYPFormsManager *formsManager;
@property (nonatomic, strong) HYPFormsCollectionViewDataSource *dataSource;

@end

@implementation HYPFormsCollectionViewDataSourceTests

- (void)setUp
{
    [super setUp];

    HYPFormsLayout *layout = [[HYPFormsLayout alloc] init];
    layout.dataSource = self;

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                             collectionViewLayout:layout];

    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"forms.json"];

    self.formsManager = [[HYPFormsManager alloc] initWithJSON:JSON
                                           initialValues:nil
                                        disabledFieldIDs:nil
                                                disabled:NO];

    self.dataSource = [[HYPFormsCollectionViewDataSource alloc] initWithCollectionView:collectionView
                                                                       andFormsManager:self.formsManager];
}

- (void)tearDown
{
    self.formsManager = nil;
    self.dataSource = nil;

    [super tearDown];
}

- (void)testIndexInForms
{
    [self.dataSource processTarget:[HYPFormTarget hideFieldTargetWithID:@"display_name"]];
    [self.dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"display_name"]];
    HYPFormField *field = [self.formsManager fieldWithID:@"display_name" includingHiddenFields:YES];
    NSUInteger index = [field indexInSectionUsingForms:self.formsManager.forms];
    XCTAssertEqual(index, 2);

    [self.dataSource processTarget:[HYPFormTarget hideFieldTargetWithID:@"username"]];
    [self.dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"username"]];
    field = [self.formsManager fieldWithID:@"username" includingHiddenFields:YES];
    index = [field indexInSectionUsingForms:self.formsManager.forms];
    XCTAssertEqual(index, 2);

    [self.dataSource processTargets:[HYPFormTarget hideFieldTargetsWithIDs:@[@"first_name",
                                                                             @"address",
                                                                             @"username"]]];
    [self.dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"username"]];
    field = [self.formsManager fieldWithID:@"username" includingHiddenFields:YES];
    index = [field indexInSectionUsingForms:self.formsManager.forms];
    XCTAssertEqual(index, 1);
    [self.dataSource processTargets:[HYPFormTarget showFieldTargetsWithIDs:@[@"first_name",
                                                                             @"address"]]];

    [self.dataSource processTargets:[HYPFormTarget hideFieldTargetsWithIDs:@[@"last_name",
                                                                             @"address"]]];
    [self.dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"address"]];
    field = [self.formsManager fieldWithID:@"address" includingHiddenFields:YES];
    index = [field indexInSectionUsingForms:self.formsManager.forms];
    XCTAssertEqual(index, 0);
    [self.dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"last_name"]];
}

- (void)testEnableAndDisableTargets
{
    HYPFormField *targetField = [self.formsManager fieldWithID:@"base_salary" includingHiddenFields:YES];
    XCTAssertFalse(targetField.isDisabled);

    HYPFormTarget *disableTarget = [HYPFormTarget disableFieldTargetWithID:@"base_salary"];
    [self.dataSource processTarget:disableTarget];
    XCTAssertTrue(targetField.isDisabled);

    HYPFormTarget *enableTarget = [HYPFormTarget enableFieldTargetWithID:@"base_salary"];
    [self.dataSource processTargets:@[enableTarget]];
    XCTAssertFalse(targetField.isDisabled);

    [self.dataSource disable];
    XCTAssertTrue(targetField.isDisabled);

    [self.dataSource enable];
    XCTAssertFalse(targetField.isDisabled);
}

- (void)testInitiallyDisabled
{
    HYPFormField *totalField = [self.formsManager fieldWithID:@"total" includingHiddenFields:YES];
    XCTAssertTrue(totalField.disabled);
}

- (void)testUpdatingTargetValue
{
    HYPFormField *targetField = [self.formsManager fieldWithID:@"display_name" includingHiddenFields:YES];
    XCTAssertNil(targetField.fieldValue);

    HYPFormTarget *updateTarget = [HYPFormTarget updateFieldTargetWithID:@"display_name"];
    updateTarget.targetValue = @"John Hyperseed";

    [self.dataSource processTarget:updateTarget];
    XCTAssertEqualObjects(targetField.fieldValue, @"John Hyperseed");
}

- (void)testDefaultValue
{
    HYPFormField *usernameField = [self.formsManager fieldWithID:@"username" includingHiddenFields:YES];
    XCTAssertNotNil(usernameField.fieldValue);
}

- (void)testCondition
{
    HYPFormField *displayNameField = [self.formsManager fieldWithID:@"display_name" includingHiddenFields:YES];
    HYPFormField *usernameField = [self.formsManager fieldWithID:@"username" includingHiddenFields:YES];
    HYPFieldValue *fieldValue = usernameField.fieldValue;
    XCTAssertEqualObjects(fieldValue.valueID, @0);

    HYPFormTarget *updateTarget = [HYPFormTarget updateFieldTargetWithID:@"display_name"];
    updateTarget.targetValue = @"Mr.Melk";

    updateTarget.condition = @"$username == 2";
    [self.dataSource processTarget:updateTarget];
    XCTAssertNil(displayNameField.fieldValue);

    updateTarget.condition = @"$username == 0";
    [self.dataSource processTarget:updateTarget];
    XCTAssertEqualObjects(displayNameField.fieldValue, @"Mr.Melk");
}

- (void)testReloadWithDictionary
{
    [self.dataSource reloadWithDictionary:@{@"first_name" : @"Elvis",
                                            @"last_name" : @"Nunez"}];

    HYPFormField *field = [self.formsManager fieldWithID:@"display_name" includingHiddenFields:YES];
    XCTAssertEqualObjects(field.fieldValue, @"Elvis Nunez");
}

- (void)testInsertFieldInSection
{
    HYPFormField *field = [[HYPFormField alloc] initWithDictionary:@{@"id" : @"companies[1].fax_number",
                                                                     @"title" : @"Fax number 1",
                                                                     @"type" : @"number",
                                                                     @"size" : @{@"width" : @30,
                                                                                 @"height" : @1}
                                                                     }
                                                          position:2
                                                          disabled:NO
                                                 disabledFieldsIDs:nil];

    // NSInteger numberOfItemsBeforeInsert = [self.collectionView numberOfItemsInSection:2];

    HYPFormSection *section = [self.formsManager sectionWithID:@"companies[1]"];
    NSInteger numberOfFields = section.fields.count;
    XCTAssertEqual(numberOfFields, 2);

    [self.dataSource insertField:field inSectionWithID:@"companies[1]"];

    section = [self.formsManager sectionWithID:@"companies[1]"];
    XCTAssertEqual(section.fields.count, numberOfFields + 1);

    // XCTAssertEqual(numberOfItemsBeforeInsert + 1, [self.collectionView numberOfItemsInSection:2]);
}

- (void)testInsertSectionInForm
{
    HYPFormSection *section = [[HYPFormSection alloc] initWithDictionary:@{@"id" : @"companies[2]",
                                                                           @"fields" : @[@{@"id" : @"companies[2].name",
                                                                                           @"title" : @"Name 3",
                                                                                           @"type" : @"name",
                                                                                           @"size" : @{@"width" : @70,
                                                                                                       @"height" : @1}
                                                                                           },
                                                                                         @{@"id" : @"companies[2].phone_number",
                                                                                           @"title" : @"Phone number 3",
                                                                                           @"type" : @"number",
                                                                                           @"size" : @{@"width" : @30,
                                                                                                       @"height" : @1}
                                                                                           }]}
                                                                position:2
                                                                disabled:NO
                                                       disabledFieldsIDs:nil
                                                           isLastSection:YES];

    // NSInteger numberOfItemsBeforeInsert = [self.collectionView numberOfItemsInSection:2];

    [self.dataSource insertSection:section inFormWithID:@"companies"];

    // XCTAssertEqual(numberOfItemsBeforeInsert + 2, [self.collectionView numberOfItemsInSection:2]);
}

- (void)testRemoveFieldWithID
{
    [self.dataSource removeFieldWithID:@"companies[0].name"];
}

- (void)testRemoveSectionWithID
{
    [self.dataSource removeSectionWithID:@"companies[0]"];
}

#pragma mark - HYPFormsLayoutDataSource

- (NSArray *)forms
{
    return self.formsManager.forms;
}

- (NSArray *)collapsedForms
{
    return self.dataSource.collapsedForms;
}

@end
