//
//  CSVReaderWriter.h
//  CSVReaderWriter
//
//  Created by Felix Garcia Lainez on 05/07/14.
//  Copyright (c) 2014 Felix Garcia Lainez. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * Modes in which a CSV file can be open.
 */
typedef NS_ENUM(NSUInteger, FileMode) {
    FileModeRead = 1,
    FileModeWrite = 2
};

/*
 * Utility class to handle CSV files.
 * This class supports read and write operations in two different files. Reading operations will be performed in the
 * file open in read mode and writing operations will be performed in the file open in write mode.
 */
@interface CSVReaderWriter : NSObject

/*!
 * Separator between columns or fields. Default value is '\\t'.
 */
@property (nonatomic, strong) NSString* separator;

/*!
 * Initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 * \param aSeparator Separator between columns or fields.
 * \returns An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (id)initWithSeparator:(NSString*)aSeparator;

/*!
 * Open a CSV file for reading or writing.
 *
 * Throws an CSVReaderWriterUnknownFileModeException if the mode specified is not valid.
 *
 * \param path The fullpath of the CSV file to open.
 * \param mode The mode used to open the file.
 */
- (void)open:(NSString*)path mode:(FileMode)mode __attribute((deprecated("Use openWithFilePath:mode: instead")));

/*!
 * Open a CSV file for reading or writing.
 *
 * Throws an CSVReaderWriterUnknownFileModeException if the mode specified is not valid.
 *
 * \param path The fullpath of the CSV file to open.
 * \param mode The mode used to open the file.
 * \returns YES if the file has been open succesfully, else NO (for instance if the file doesn't exists).
 */
- (BOOL)openWithFilePath:(NSString*)path mode:(FileMode)mode;

/*!
 * Read a line of the CSV open in reading mode, returning the content of the two first columns of the line read,
 *
 * Throws an CSVReaderWriterOperationException if doesn't exists a csv file open in FileModeRead.
 *
 * \param column1 Output parameter to retrieve the content of the first column in the line.
 * \param column2 Output parameter to retrieve the content of the second column in the line.
 * \returns YES if the read operation has been completed successfully, else NO.
 */
- (BOOL)read:(NSMutableString**)column1 column2:(NSMutableString**)column2 __attribute((deprecated("Use readLine: instead")));

/*!
 * Read a line of the CSV open in reading mode, returning the content of all the columns of the line read.
 *
 * Throws an CSVReaderWriterOperationException if doesn't exists a csv file open in FileModeRead.
 *
 * \param columns Holds the content of the lines read. Each item of the array contains a column of the line.
 * \returns YES if the read operation has been completed successfully, else NO.
 */
- (BOOL)read:(NSMutableArray*)columns __attribute((deprecated("Use readLine: instead")));

/*!
 * Read a line of the CSV open in reading mode, returning the content of all the columns of the line read.
 *
 * Throws an CSVReaderWriterOperationException if doesn't exists a csv file open in FileModeRead.
 *
 * \param columns Holds the content of the lines read. Each item of the array contains a column of the line.
 * \returns YES if the read operation has been completed successfully, else NO.
 */
- (BOOL)readLine:(NSMutableArray*)columns;

/*!
 * Write a line in the CSV file open in writing mode.
 *
 * Throws an CSVReaderWriterOperationException if doesn't exists a csv file open in FileModeWrite.
 *
 * \param columns The columns of the new line to be added.
 */
- (void)write:(NSArray*)columns __attribute((deprecated("Use writeLineWithColumns: instead")));

/*!
 * Write a line in the CSV file open in writing mode.
 *
 * Throws an CSVReaderWriterOperationException if doesn't exists a csv file open in FileModeWrite.
 *
 * \param columns The columns of the new line to be added.
 */
- (void)writeLineWithColumns:(NSArray*)columns;

/*!
 * Close the open CSV files.
 */
- (void)close;

@end