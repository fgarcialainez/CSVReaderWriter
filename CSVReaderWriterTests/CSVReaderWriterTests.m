//
//  CSVReaderWriterTests.m
//  CSVReaderWriterTests
//
//  Created by Felix Garcia Lainez on 05/07/14.
//  Copyright (c) 2014 Felix Garcia Lainez. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CSVReaderWriter.h"

@interface CSVReaderWriterTests : XCTestCase
{
    NSString *fullDirectoryPath;
    
    CSVReaderWriter* csvReadHandler;
    CSVReaderWriter* tsvReadWriteHandler;
}

- (NSString*)fullPathForWritingCSVWithFilename:(NSString*)filename;

@end

@implementation CSVReaderWriterTests

#pragma mark -
#pragma mark - Test Life Cycle Methods

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    //Create folder to write CSV files
    NSFileManager *fm = [NSFileManager defaultManager];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    
	fullDirectoryPath = [documentsDirectory stringByAppendingPathComponent:@"tests"];
    
    if(![fm fileExistsAtPath:fullDirectoryPath])
		[fm createDirectoryAtPath:fullDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    //Comma Separated Values (CSV)
    csvReadHandler = [[CSVReaderWriter alloc]initWithSeparator:@","];
    
    //Tab Separated Values (TSV)
    tsvReadWriteHandler = [[CSVReaderWriter alloc]init];
    tsvReadWriteHandler = [[CSVReaderWriter alloc]init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    //Remove all stored files
    NSFileManager *fm = [NSFileManager defaultManager];
	
	NSArray* contents = [fm contentsOfDirectoryAtPath:fullDirectoryPath error:nil];
	
	NSString* fullPath = nil;
	
	if([contents count] > 0)
	{
		for(id path in contents)
		{
			fullPath = [fullDirectoryPath stringByAppendingPathComponent:path];
			[fm removeItemAtPath:fullPath error:nil];
		}
	}
    
    //Remove tests folder
    [fm removeItemAtPath:fullDirectoryPath error:nil];
}

#pragma mark -
#pragma mark Aux Methods

- (NSString*)fullPathForWritingCSVWithFilename:(NSString*)filename
{
	return [NSString stringWithFormat:@"%@/%@", fullDirectoryPath, filename];
}

#pragma mark -
#pragma mark Test Methods

- (void)testReadCSVSchools
{
    NSString *filePathWrong = [[NSBundle bundleForClass:[CSVReaderWriterTests class]] pathForResource:@"School" ofType:@"csv"];
    NSString *filePathRight = [[NSBundle bundleForClass:[CSVReaderWriterTests class]] pathForResource:@"Schools" ofType:@"csv"];
    
    XCTAssertFalse([csvReadHandler openWithFilePath:filePathWrong mode:FileModeRead], @"School.csv doesn't exists");
    XCTAssertTrue([csvReadHandler openWithFilePath:filePathRight mode:FileModeRead], @"Error opening Schools.csv");

    //Open and Read the content of Schools.csv
    NSInteger nRows = 0;
    NSMutableArray* columns = [NSMutableArray array];
    
    while([csvReadHandler readLine:columns])
    {
        XCTAssertTrue([columns count] > 0, @"The number of columns must be greater than 0");
        
        [columns removeAllObjects];
        nRows++;
    }
    
    XCTAssertTrue(nRows > 0, @"The number of read rows must be greater than 0");
    
    //Close the open file
    [csvReadHandler close];
}

- (void)testReadCSVBatting
{
    //Open and Read the content of Batting.csv (6.5Mb)
    NSString *filePath = [[NSBundle bundleForClass:[CSVReaderWriterTests class]] pathForResource:@"Batting" ofType:@"csv"];
    
    XCTAssertTrue([csvReadHandler openWithFilePath:filePath mode:FileModeRead], @"Error opening Batting.csv");
    
    NSInteger nRows = 0;
    NSMutableArray* columns = [NSMutableArray array];
    
    while([csvReadHandler readLine:columns])
    {
        XCTAssertTrue([columns count] > 0, @"The number of columns must be greater than 0");
        
        [columns removeAllObjects];
        nRows++;
    }
    
    XCTAssertTrue(nRows > 0, @"The number of read rows must be greater than 0");
    
    //Close the open file
    [csvReadHandler close];
}

- (void)testCreateTSV
{
    //Open Schools.csv for Reading
    NSString *filePathRead = [[NSBundle bundleForClass:[CSVReaderWriterTests class]] pathForResource:@"Schools" ofType:@"csv"];
    
    XCTAssertTrue([csvReadHandler openWithFilePath:filePathRead mode:FileModeRead], @"Error opening Schools.csv");
    
    //Create and open SchoolsTSV.csv for Writing
    NSString *filePathWrite = [self fullPathForWritingCSVWithFilename:@"SchoolsTSV.csv"];
    [[NSFileManager defaultManager] createFileAtPath:filePathWrite contents:nil attributes:nil];
    
    XCTAssertTrue([tsvReadWriteHandler openWithFilePath:filePathWrite mode:FileModeWrite], @"Error opening SchoolsTSV.csv in FileModeWrite");
    
    //Perform Read (Schools.csv) and Write (SchoolsTSV.csv)
    NSInteger nRowsRead = 0;
    NSMutableArray* columns = [NSMutableArray array];
    
    while([csvReadHandler readLine:columns])
    {
        XCTAssertTrue([columns count] > 0, @"The number of columns must be greater than 0");
        
        //Write the line
        [tsvReadWriteHandler writeLineWithColumns:columns];
        
        [columns removeAllObjects];
        nRowsRead++;
    }
    
    //Check that the number of rows read in Schools.csv is the same than the number of rows written in SchoolsTSV.csv
    XCTAssertTrue([tsvReadWriteHandler openWithFilePath:filePathWrite mode:FileModeRead], @"Error opening SchoolsTSV.csv in FileModeRead");
    
    NSInteger nRowsWritten = 0;
    
    while([tsvReadWriteHandler readLine:columns])
    {
        XCTAssertTrue([columns count] > 0, @"The number of columns must be greater than 0");
        
        [columns removeAllObjects];
        nRowsWritten++;
    }
    
    XCTAssertEqual(nRowsRead, nRowsWritten, @"The number of rows read must be equal to the number of rows written");
    
    //Close the open files
    [csvReadHandler close];
    [tsvReadWriteHandler close];
}

- (void)testWriteOwnTSV
{
    //Open TestWriting.csv for Writing
    NSString *filePath = [self fullPathForWritingCSVWithFilename:@"TestWriting.csv"];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    
    XCTAssertTrue([tsvReadWriteHandler openWithFilePath:filePath mode:FileModeWrite], @"Error opening TestWriting.csv in FileModeWrite");
    
    //Write data
    NSArray* firstRowData = @[@"Felix", @"Garcia", @"Lainez", @"31", @"Huesca", @"Spain"];
    NSArray* secondRowData = @[@"Juan", @"Perez", @"Sanchez", @"25", @"Zaragoza", @"Spain"];
    NSArray* thirdRowData = @[@"Maria", @"Sanchez", @"Lopez", @"28", @"Zaragoza", @"Spain"];
    
    [tsvReadWriteHandler writeLineWithColumns:firstRowData];
    [tsvReadWriteHandler writeLineWithColumns:secondRowData];
    [tsvReadWriteHandler writeLineWithColumns:thirdRowData];
    
    //Check that number of rows written is 3
    XCTAssertTrue([tsvReadWriteHandler openWithFilePath:filePath mode:FileModeRead], @"Error opening TestWriting.csv in FileModeRead");
    
    NSInteger nRowsRead = 0;
    NSMutableArray* columns = [NSMutableArray array];
    
    while([tsvReadWriteHandler readLine:columns])
    {
        XCTAssertTrue([columns count] > 0, @"The number of columns must be greater than 0");
        
        [columns removeAllObjects];
        nRowsRead++;
    }
    
    XCTAssertEqual(nRowsRead, 3, @"The number of rows read must be 3");
    
    //Close the open files
    [tsvReadWriteHandler close];
}

- (void)testBoundaries
{
    //Open Schools.csv for Reading
    NSString *filePathRead = [[NSBundle bundleForClass:[CSVReaderWriterTests class]] pathForResource:@"Schools" ofType:@"csv"];
    
    XCTAssertTrue([csvReadHandler openWithFilePath:filePathRead mode:FileModeRead], @"Error opening Schools.csv");
    
    //Perform read operation with nil param (should return YES in order to keep backward compatibility)
    NSMutableArray* columnsRead = nil;
    XCTAssertTrue([csvReadHandler readLine:columnsRead], @"Read operation failed");
    
    //Open TestBoundaries.csv for Writing
    NSString *filePathWrite = [self fullPathForWritingCSVWithFilename:@"TestBoundaries.csv"];
    [[NSFileManager defaultManager] createFileAtPath:filePathWrite contents:nil attributes:nil];
    
    XCTAssertTrue([tsvReadWriteHandler openWithFilePath:filePathWrite mode:FileModeWrite], @"Error opening TestBoundaries.csv in FileModeWrite");
    
    //Perfor write operation with correct data
    [tsvReadWriteHandler writeLineWithColumns:@[@"Felix", @"Garcia", @"Lainez", @"31", @"Huesca", @"Spain"]];
    
    //Perform write operation with nil and zero columns array (no new lines should be added)
    [tsvReadWriteHandler writeLineWithColumns:nil];
    [tsvReadWriteHandler writeLineWithColumns:@[]];
    
    //Check that the number of rows is 1 (last two operations shouldn't add a new file)
    XCTAssertTrue([tsvReadWriteHandler openWithFilePath:filePathWrite mode:FileModeRead], @"Error opening TestBoundaries.csv in FileModeRead");
    
    NSInteger nRowsRead = 0;
    NSMutableArray* columns = [NSMutableArray array];
    
    while([tsvReadWriteHandler readLine:columns])
    {
        XCTAssertTrue([columns count] > 0, @"The number of columns must be greater than 0");
        
        [columns removeAllObjects];
        nRowsRead++;
    }
    
    XCTAssertEqual(nRowsRead, 1, @"The number of rows read must be 1");
    
    //Close the open files
    [csvReadHandler close];
    [tsvReadWriteHandler close];
}

- (void)testOneColumnCSV
{
    //Create and open TestOneColumn.csv for writing
    NSString* filePath = [self fullPathForWritingCSVWithFilename:@"TestOneColumn.csv"];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    
    XCTAssertTrue([tsvReadWriteHandler openWithFilePath:filePath mode:FileModeWrite], @"Error opening TestOneColumn.csv in FileModeWrite");
    
    [tsvReadWriteHandler writeLineWithColumns:@[@"Row1"]];
    [tsvReadWriteHandler writeLineWithColumns:@[@"Row2"]];
    [tsvReadWriteHandler writeLineWithColumns:@[@"Row3"]];
    [tsvReadWriteHandler writeLineWithColumns:@[@"Row4"]];
    [tsvReadWriteHandler writeLineWithColumns:@[@"Row5"]];
    
    //Open TestOneColumn.csv for reading
    XCTAssertTrue([tsvReadWriteHandler openWithFilePath:filePath mode:FileModeRead], @"Error opening TestOneColumn.csv in FileModeRead");
    
    NSInteger nRowsRead = 0;
    NSMutableArray* columns = [NSMutableArray array];
    
    while([tsvReadWriteHandler readLine:columns])
    {
        XCTAssertTrue([columns count] > 0, @"The number of columns must be greater than 0");
        
        [columns removeAllObjects];
        nRowsRead++;
    }
    
    XCTAssertEqual(nRowsRead, 5, @"The number of rows read must be 5");
    
    //Close the open files
    [tsvReadWriteHandler close];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void)testDeprecatedMethods
{
    //Test deprecated methods in order to keep backward compatibility
    
    //Create and open TestDeprecated.csv
    NSString *filePath = [self fullPathForWritingCSVWithFilename:@"TestDeprecated.csv"];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    
    //Using the deprecated methods there is no way to check if the file has been open successfully!!!
    [tsvReadWriteHandler open:filePath mode:FileModeWrite];
    
    //Write data
    NSArray* firstRowData = @[@"Felix", @"Garcia", @"Lainez", @"31", @"Huesca", @"Spain"];
    NSArray* secondRowData = @[@"Juan", @"Perez", @"Sanchez", @"25", @"Zaragoza", @"Spain"];
    NSArray* thirdRowData = @[@"Maria", @"Sanchez", @"Lopez", @"28", @"Zaragoza", @"Spain"];
    
    [tsvReadWriteHandler write:firstRowData];
    [tsvReadWriteHandler write:secondRowData];
    [tsvReadWriteHandler write:thirdRowData];
    
    //Check that number of rows written is 3
    [tsvReadWriteHandler open:filePath mode:FileModeRead];
    
    NSInteger nRowsRead = 0;
    NSMutableArray* columns = [NSMutableArray array];
    
    while([tsvReadWriteHandler read:columns])
    {
        XCTAssertTrue([columns count] > 0, @"The number of columns must be greater than 0");
        
        [columns removeAllObjects];
        nRowsRead++;
    }
    
    XCTAssertEqual(nRowsRead, 3, @"The number of rows read must be 3");
    
    //Test the other read method
    [tsvReadWriteHandler open:filePath mode:FileModeRead];
    
    NSMutableString* column1 = nil;
    NSMutableString* column2 = nil;
    
    XCTAssertTrue([tsvReadWriteHandler read:&column1 column2:&column2], @"Error opening TestDeprecated.csv in FileModeRead");
    XCTAssertEqualObjects(@"Felix", column1, @"First column read must contain the string \"Felix\"");
    XCTAssertEqualObjects(@"Garcia", column2, @"Second column read must contain the string \"Garcia\"");
    
    //Close the open files
    [tsvReadWriteHandler close];
}

- (void)testDeprecatedMethodsWithOneColumn
{
    //Create and open a CSV with a single column
    NSString* filePathOneColumn = [self fullPathForWritingCSVWithFilename:@"TestOneColumn.csv"];
    [[NSFileManager defaultManager] createFileAtPath:filePathOneColumn contents:nil attributes:nil];
    
    [tsvReadWriteHandler open:filePathOneColumn mode:FileModeWrite];
    
    [tsvReadWriteHandler write:@[@"Row1"]];
    [tsvReadWriteHandler write:@[@"Row2"]];
    [tsvReadWriteHandler write:@[@"Row3"]];
    [tsvReadWriteHandler write:@[@"Row4"]];
    
    //Open and read the CSV file with a single column (using read:)
    [tsvReadWriteHandler open:filePathOneColumn mode:FileModeRead];
    
    NSInteger nRowsRead = 0;
    NSMutableArray* columns = [NSMutableArray array];
    
    while([tsvReadWriteHandler read:columns])
    {
        XCTAssertTrue([columns count] > 0, @"The number of columns must be greater than 0");
        
        [columns removeAllObjects];
        nRowsRead++;
    }
    
    XCTAssertEqual(nRowsRead, 4, @"The number of rows read must be 4");
    
    //Open and read the CSV file with a single column (using read::)
    [tsvReadWriteHandler open:filePathOneColumn mode:FileModeRead];
    
    nRowsRead = 0;
    NSMutableString* column1 = nil;
    NSMutableString* column2 = nil;
    
    while([tsvReadWriteHandler read:&column1 column2:&column2])
    {
        XCTAssertNotNil(column1, @"The first column must contain a valid string");
        XCTAssertNil(column2, @"The second column must be nil");
        
        nRowsRead++;
    }
    
    XCTAssertEqual(nRowsRead, 4, @"The number of rows read must be 4");
    
    //Close the open files
    [tsvReadWriteHandler close];
    [tsvReadWriteHandler close];
}

#pragma clang diagnostic pop

- (void)testExceptions
{
    //Create and open TestExceptions.csv for writing
    NSString* filePath = [self fullPathForWritingCSVWithFilename:@"TestExceptions.csv"];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    
    //Check that is raised an exception if is performed an open operation with an invalid FileMode
    XCTAssertThrows([tsvReadWriteHandler openWithFilePath:filePath mode:(FileMode)5], @"Perform an open operation with an invalid FileMode should throw a CSVReaderWriterUnknownFileModeException");
    
    //Check that exceptions are raised correctly...
    XCTAssertThrows([tsvReadWriteHandler writeLineWithColumns:nil], @"Perform a writing operation without a csv file open in FileModeWrite should throw a CSVReaderWriterOperationException");
    XCTAssertThrows([tsvReadWriteHandler readLine:nil], @"Perform a reading operation without a csv file open in FileModeRead should throw a CSVReaderWriterOperationException");
    
    //Open the file in read and write modes
    XCTAssertTrue([tsvReadWriteHandler openWithFilePath:filePath mode:FileModeRead], @"Error opening TestExceptions.csv in FileModeRead");
    XCTAssertTrue([tsvReadWriteHandler openWithFilePath:filePath mode:FileModeWrite], @"Error opening TestExceptions.csv in FileModeWrite");
    
    //Test that exceptions are not raised (files open)...
    XCTAssertNoThrow([tsvReadWriteHandler writeLineWithColumns:nil], @"No exception should be raised");
    XCTAssertNoThrow([tsvReadWriteHandler readLine:nil], @"No exception should be raised");
    
    //Close the handler...
    [tsvReadWriteHandler close];
    
    //Test that exceptions are raised correctly (handlers should have been closed correctly)...
    XCTAssertThrows([tsvReadWriteHandler writeLineWithColumns:nil], @"Performing a writing operation without a csv file open in FileModeWrite should throw a CSVReaderWriterOperationException");
    XCTAssertThrows([tsvReadWriteHandler readLine:nil], @"Performing a reading operation without a csv file open in FileModeRead should throw a CSVReaderWriterOperationException");
}

@end