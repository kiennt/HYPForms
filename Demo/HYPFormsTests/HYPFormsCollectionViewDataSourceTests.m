@import UIKit;
@import XCTest;

#import "HYPFieldValidation.h"
#import "HYPForm.h"
#import "HYPFormField.h"
#import "HYPFormsCollectionViewDataSource.h"
#import "HYPFormSection.h"
#import "HYPFormsManager.h"
#import "HYPFormTarget.h"
#import "HYPImageFormFieldCell.h"

#import "NSJSONSerialization+ANDYJSONFile.h"

@interface HYPFormsCollectionViewDataSource ()

@property (nonatomic, strong) HYPFormsManager *formsManager;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@interface HYPFormsCollectionViewDataSourceTests : XCTestCase <HYPFormsCollectionViewDataSourceDataSource>

@end

@implementation HYPFormsCollectionViewDataSourceTests

- (HYPFormsCollectionViewDataSource *)dataSource
{
    HYPFormsLayout *layout = [[HYPFormsLayout alloc] init];

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                                          collectionViewLayout:layout];

    [collectionView registerClass:[HYPImageFormFieldCell class] forCellWithReuseIdentifier:HYPImageFormFieldCellIdentifier];

    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"forms.json"];

    HYPFormsManager *formsManager = [[HYPFormsManager alloc] initWithJSON:JSON
                                                            initialValues:nil
                                                         disabledFieldIDs:nil
                                                                 disabled:NO];

    HYPFormsCollectionViewDataSource *dataSource = [[HYPFormsCollectionViewDataSource alloc] initWithCollectionView:collectionView
                                                                                                    andFormsManager:formsManager];

    collectionView.dataSource = dataSource;
    layout.dataSource = dataSource;
    dataSource.dataSource = self;

    return dataSource;
}

- (void)testIndexInForms
{
    HYPFormsCollectionViewDataSource *dataSource = [self dataSource];

    [dataSource processTarget:[HYPFormTarget hideFieldTargetWithID:@"display_name"]];
    [dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"display_name"]];
    HYPFormField *field = [dataSource.formsManager fieldWithID:@"display_name" includingHiddenFields:YES];
    NSUInteger index = [field indexInSectionUsingForms:dataSource.formsManager.forms];
    XCTAssertEqual(index, 2);

    [dataSource processTarget:[HYPFormTarget hideFieldTargetWithID:@"username"]];
    [dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"username"]];
    field = [dataSource.formsManager fieldWithID:@"username" includingHiddenFields:YES];
    index = [field indexInSectionUsingForms:dataSource.formsManager.forms];
    XCTAssertEqual(index, 2);

    [dataSource processTargets:[HYPFormTarget hideFieldTargetsWithIDs:@[@"first_name",
                                                                        @"address",
                                                                        @"username"]]];
    [dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"username"]];
    field = [dataSource.formsManager fieldWithID:@"username" includingHiddenFields:YES];
    index = [field indexInSectionUsingForms:dataSource.formsManager.forms];
    XCTAssertEqual(index, 1);
    [dataSource processTargets:[HYPFormTarget showFieldTargetsWithIDs:@[@"first_name",
                                                                        @"address"]]];

    [dataSource processTargets:[HYPFormTarget hideFieldTargetsWithIDs:@[@"last_name",
                                                                        @"address"]]];
    [dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"address"]];
    field = [dataSource.formsManager fieldWithID:@"address" includingHiddenFields:YES];
    index = [field indexInSectionUsingForms:dataSource.formsManager.forms];
    XCTAssertEqual(index, 0);
    [dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"last_name"]];
}

- (void)testEnableAndDisableTargets
{
    HYPFormsCollectionViewDataSource *dataSource = [self dataSource];

    HYPFormField *targetField = [dataSource.formsManager fieldWithID:@"base_salary" includingHiddenFields:YES];
    XCTAssertFalse(targetField.isDisabled);

    HYPFormTarget *disableTarget = [HYPFormTarget disableFieldTargetWithID:@"base_salary"];
    [dataSource processTarget:disableTarget];
    XCTAssertTrue(targetField.isDisabled);

    HYPFormTarget *enableTarget = [HYPFormTarget enableFieldTargetWithID:@"base_salary"];
    [dataSource processTargets:@[enableTarget]];
    XCTAssertFalse(targetField.isDisabled);

    [dataSource disable];
    XCTAssertTrue(targetField.isDisabled);

    [dataSource enable];
    XCTAssertFalse(targetField.isDisabled);
}

- (void)testInitiallyDisabled
{
    HYPFormsCollectionViewDataSource *dataSource = [self dataSource];

    HYPFormField *totalField = [dataSource.formsManager fieldWithID:@"total" includingHiddenFields:YES];
    XCTAssertTrue(totalField.disabled);
}

- (void)testUpdatingTargetValue
{
    HYPFormsCollectionViewDataSource *dataSource = [self dataSource];

    HYPFormField *targetField = [dataSource.formsManager fieldWithID:@"display_name" includingHiddenFields:YES];
    XCTAssertNil(targetField.fieldValue);

    HYPFormTarget *updateTarget = [HYPFormTarget updateFieldTargetWithID:@"display_name"];
    updateTarget.targetValue = @"John Hyperseed";

    [dataSource processTarget:updateTarget];
    XCTAssertEqualObjects(targetField.fieldValue, @"John Hyperseed");
}

- (void)testDefaultValue
{
    HYPFormsCollectionViewDataSource *dataSource = [self dataSource];

    HYPFormField *usernameField = [dataSource.formsManager fieldWithID:@"username" includingHiddenFields:YES];
    XCTAssertNotNil(usernameField.fieldValue);
}

- (void)testCondition
{
    HYPFormsCollectionViewDataSource *dataSource = [self dataSource];

    HYPFormField *displayNameField = [dataSource.formsManager fieldWithID:@"display_name" includingHiddenFields:YES];
    HYPFormField *usernameField = [dataSource.formsManager fieldWithID:@"username" includingHiddenFields:YES];
    HYPFieldValue *fieldValue = usernameField.fieldValue;
    XCTAssertEqualObjects(fieldValue.valueID, @0);

    HYPFormTarget *updateTarget = [HYPFormTarget updateFieldTargetWithID:@"display_name"];
    updateTarget.targetValue = @"Mr.Melk";

    updateTarget.condition = @"$username == 2";
    [dataSource processTarget:updateTarget];
    XCTAssertNil(displayNameField.fieldValue);

    updateTarget.condition = @"$username == 0";
    [dataSource processTarget:updateTarget];
    XCTAssertEqualObjects(displayNameField.fieldValue, @"Mr.Melk");
}

- (void)testReloadWithDictionary
{
    HYPFormsCollectionViewDataSource *dataSource = [self dataSource];

    [dataSource reloadWithDictionary:@{@"first_name" : @"Elvis",
                                       @"last_name" : @"Nunez"}];

    HYPFormField *field = [dataSource.formsManager fieldWithID:@"display_name" includingHiddenFields:YES];
    XCTAssertEqualObjects(field.fieldValue, @"Elvis Nunez");
}

- (void)testInsertFieldInSection
{
    HYPFormsCollectionViewDataSource *dataSource = [self dataSource];

    HYPFormField *field = [[HYPFormField alloc] initWithDictionary:@{@"id" : @"companies[1].fax_number",
                                                                     @"title" : @"Fax number 1",
                                                                     @"type" : @"number",
                                                                     @"size" : @{@"width" : @30,
                                                                                 @"height" : @1}
                                                                     }
                                                          position:2
                                                          disabled:NO
                                                 disabledFieldsIDs:nil];

    NSInteger sections = [dataSource.collectionView numberOfSections];
    for (NSInteger i = 0; i < sections; i++) {
        NSInteger rows = [dataSource.collectionView numberOfItemsInSection:i];
        for (NSInteger j = 0; j < rows; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            UICollectionViewCell *cell = [dataSource.collectionView cellForItemAtIndexPath:indexPath];
            NSLog(@"found cell: (%@) %@", indexPath, cell);
        }
    }

    NSInteger numberOfItemsBeforeInsert = [dataSource.collectionView numberOfItemsInSection:2];

    HYPFormSection *section = [dataSource.formsManager sectionWithID:@"companies[1]"];
    NSInteger numberOfFields = section.fields.count;
    XCTAssertEqual(numberOfFields, 2);

    [dataSource insertField:field inSectionWithID:@"companies[1]"];

    section = [dataSource.formsManager sectionWithID:@"companies[1]"];
    XCTAssertEqual(section.fields.count, numberOfFields + 1);

    XCTAssertEqual(numberOfItemsBeforeInsert + 1, [dataSource.collectionView numberOfItemsInSection:2]);
}

- (void)testInsertSectionInForm
{
    HYPFormsCollectionViewDataSource *dataSource = [self dataSource];

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

    NSInteger numberOfItemsBeforeInsert = [dataSource.collectionView numberOfItemsInSection:2];

    [dataSource insertSection:section inFormWithID:@"companies"];

    XCTAssertEqual(numberOfItemsBeforeInsert + 2, [dataSource.collectionView numberOfItemsInSection:2]);
}

- (void)testRemoveFieldWithID
{
    HYPFormsCollectionViewDataSource *dataSource = [self dataSource];

    [dataSource removeFieldWithID:@"companies[0].name"];
}

- (void)testRemoveSectionWithID
{
    HYPFormsCollectionViewDataSource *dataSource = [self dataSource];

    [dataSource removeSectionWithID:@"companies[0]"];
}

#pragma mark - HYPFormsCollectionViewDataSourceDataSource

- (UICollectionViewCell *)formsCollectionDataSource:(HYPFormsCollectionViewDataSource *)formsCollectionDataSource
                                       cellForField:(HYPFormField *)field atIndexPath:(NSIndexPath *)indexPath
{
    HYPImageFormFieldCell *cell;

    BOOL isImageCell = (field.type == HYPFormFieldTypeCustom && [field.typeString isEqual:@"image"]);
    if (isImageCell) {
        cell = [formsCollectionDataSource.collectionView dequeueReusableCellWithReuseIdentifier:HYPImageFormFieldCellIdentifier
                                                                                   forIndexPath:indexPath];
    }

    return cell;
}


@end
