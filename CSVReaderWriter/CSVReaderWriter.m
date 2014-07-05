//
//  CSVReaderWriter.m
//  CSVReaderWriter
//
//  Created by Felix Garcia Lainez on 05/07/14.
//  Copyright (c) 2014 Felix Garcia Lainez. All rights reserved.
//

#import "CSVReaderWriter.h"

#import <UIKit/UIKit.h>

#pragma mark -
#pragma mark CSVReaderWriter Private API

@interface CSVReaderWriter(){
    /*
     * We use different input and output handles in order to support that
     * two different csv files are open in read and write mode concurrently
     */
    NSFileHandle* inputHandle;
    NSFileHandle* outputHandle;
}

/*!
 * Read a line of the CSV open in reading mode
 * \returns The read line
 */
- (NSString*)readLine;

/*!
 * Write a line in the CSV file open in writing mode
 * \param line The line to be written. It doesn't include the end of line character ('\n')
 */
- (void)writeLine:(NSString*)line;

@end

#pragma mark -
#pragma mark CSVReaderWriter Implementation

@implementation CSVReaderWriter

@synthesize separator;

#pragma mark -
#pragma mark Initialization

- (id)init{
    self = [super init];
    if (self){
        separator = @"\t";
    }
    return self;
}

- (id)initWithSeparator:(NSString*)aSeparator{
    self = [super init];
    if (self){
        separator = aSeparator;
    }
    return self;
}

#pragma mark -
#pragma mark Deprecated Methods

- (void)open:(NSString*)path mode:(FileMode)mode
{
    [self openWithFilePath:path mode:mode];
}

- (BOOL)read:(NSMutableString**)column1 column2:(NSMutableString**)column2
{
    NSMutableArray* colums = [NSMutableArray array];
    
    BOOL success = [self readLine:colums];
    
    if(success && [colums count] > 0)
    {
        *column1 = [NSMutableString stringWithString:colums[0]];
        
        if([colums count] > 1)
            *column2 = [NSMutableString stringWithString:colums[1]];
        else
            *column2 = nil;
    }
    else
    {
        *column1 = nil;
        *column2 = nil;
    }
    
    return success;
}

- (BOOL)read:(NSMutableArray*)columns
{
    return [self readLine:columns];
}

- (void)write:(NSArray*)columns
{
    [self writeLineWithColumns:columns];
}

#pragma mark -
#pragma mark Aux Methods

- (NSString*)readLine
{
    NSMutableString* line = [NSMutableString string];
    
    if(inputHandle)
    {
        uint8_t ch = 0;
        NSData* readData = nil;
    
        do
        {
            readData = [inputHandle readDataOfLength:1];
        
            if([readData length] > 0)
            {
                [readData getBytes:&ch length:1];
            
                if(ch != '\n')
                    [line appendFormat:@"%c", ch];
            }
        }
        while(ch != '\n' && [readData length] > 0);
    }
    else
    {
        NSException* ex = [NSException exceptionWithName:@"CSVReaderWriterOperationException"
                                                    reason:NSLocalizedString(@"Attempted to perform a read operation without a csv file open in FileModeRead mode", nil)
                                                    userInfo:nil];
        @throw ex;
    }
    
    return line;
}

- (void)writeLine:(NSString*)line
{
    if(outputHandle)
    {
        //We don't want to write blank lines
        if([line length] > 0)
            [outputHandle writeData:[[NSString stringWithFormat:@"%@\n", line] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else
    {
        NSException* ex = [NSException exceptionWithName:@"CSVReaderWriterOperationException"
                                                    reason:NSLocalizedString(@"Attempted to perform a write operation without a csv file open in FileModeWrite mode", nil)
                                                    userInfo:nil];
        @throw ex;
    }
}

#pragma mark -
#pragma mark New Implementation

- (BOOL)openWithFilePath:(NSString*)path mode:(FileMode)mode
{
    BOOL success = NO;
    
    if(mode == FileModeRead)
    {
        inputHandle = [NSFileHandle fileHandleForReadingAtPath:path];
   
        success = (inputHandle != nil);
    }
    else if (mode == FileModeWrite)
    {
        outputHandle = [NSFileHandle fileHandleForWritingAtPath:path];
        
        success = (outputHandle != nil);
    }
    else
    {
        NSException* ex = [NSException exceptionWithName:@"CSVReaderWriterUnknownFileModeException"
                                                    reason:NSLocalizedString(@"Unknown file mode specified", nil)
                                                    userInfo:nil];
        @throw ex;
    }
    
    return success;
}

- (BOOL)readLine:(NSMutableArray*)columns
{
    BOOL success = NO;
    
    NSString* line = [self readLine];
    
    if([line length] > 0)
    {
        success = YES;
        
        //In theory columns should be filled ONLY with the columns of the line,
        //so we are clearing all the items of the array before starting insertions.
        [columns removeAllObjects];
        
        NSArray* splitLine = [line componentsSeparatedByString:self.separator];
        
        for(NSString* column in splitLine)
            [columns addObject:column];
    }
        
    return success;
}

- (void)writeLineWithColumns:(NSArray*)columns
{
    [self writeLine:[columns componentsJoinedByString:self.separator]];
}

- (void)close
{
    [inputHandle closeFile];
    inputHandle = nil;
    
    [outputHandle closeFile];
    outputHandle = nil;
}

@end
