//
//  t_Sandbox.m
//  Template
//
//  Created by yj on 14-9-24.
//  Copyright (c) 2014年 cdeledu. All rights reserved.
//

#import "t_Sandbox.h"

@implementation t_Sandbox

+ (NSString *)appPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

+ (NSString *)docPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

+ (NSString *)libPrefPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	return [[paths objectAtIndex:0] stringByAppendingFormat:@"/Preference"];
}

+ (NSString *)libCachePath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	return [[paths objectAtIndex:0] stringByAppendingFormat:@"/Caches"];
}

+ (NSString *)tmpPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	return [[paths objectAtIndex:0] stringByAppendingFormat:@"/tmp"];
}

+ (BOOL)touch:(NSString *)path
{
	if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:path] )
	{
		return [[NSFileManager defaultManager] createDirectoryAtPath:path
										 withIntermediateDirectories:YES
														  attributes:nil
															   error:NULL];
	}
	
	return NO;
}

/**
 *	@brief	判断文件路径是否存在
 *
 *	@param 	fullPathName 	文件完整路径
 *
 *	@return	返回是否存在
 */
+ (BOOL)fileExists:(NSString *)fullPathName
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    return [file_manager fileExistsAtPath:fullPathName];
}

/**
 *	@brief	删除文件
 *
 *	@param 	fullPathName 	文件完整路径
 *
 *	@return	是否删除成功
 */
+ (BOOL)remove:(NSString *)fullPathName
{
    NSError *error = nil;
    NSFileManager *file_manager = [NSFileManager defaultManager];
    if ([file_manager fileExistsAtPath:fullPathName]) {
        [file_manager removeItemAtPath:fullPathName error:&error];
    }
    if (error) {
        return NO;
    }
    return YES;
}

/**
 *	@brief	创建文件夹
 *
 *	@param 	dir 	文件夹名字
 */
+ (void)makeDirs:(NSString *)dir
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    [file_manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
}

/**
 *	@brief	判断Document文件路径是否存在
 *
 *	@param 	fileName 	文件名
 *
 *	@return	返回是否存在文件路径
 */
+ (BOOL)fileExistInDocumentPath:(NSString*)fileName

{
	if(fileName == nil)
		return NO;
	NSString* documentsPath = [self documentPath:fileName];
	return [[NSFileManager defaultManager] fileExistsAtPath: documentsPath];
}

/**
 *	@brief	通过文件名，获取Document完整路径，如果不存在返回为nil
 *
 *	@param 	fileName 	文件名
 *
 *	@return	返回完整路径
 */
+ (NSString*)documentPath:(NSString*)fileName

{
	if(fileName == nil)
		return nil;
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex: 0];
	NSString* documentsPath = [documentsDirectory stringByAppendingPathComponent: fileName];
	return documentsPath;
}

/**
 *	@brief	删除Document文件
 *
 *	@param 	fileName 	文件名
 *
 *	@return	是否成功删除
 */
+ (BOOL)deleteDocumentFile:(NSString*)fileName

{
    BOOL del = NO;
	if(fileName == nil)
		return del;
	NSString* documentsPath = [self documentPath:fileName];
	if( [[NSFileManager defaultManager] fileExistsAtPath: documentsPath])
	{
		
		del = [[NSFileManager defaultManager] removeItemAtPath: documentsPath error:nil];
	}
	return del;
}

/**
 *	@brief	判断Cache是否存在
 *
 *	@param 	fileName 	文件名
 *
 *	@return	是否存在文件
 */
+ (BOOL)fileExistInCachesPath:(NSString*)fileName

{
	if(fileName == nil)
		return NO;
	NSString* cachesPath = [self cachesFilePath:fileName];
	return [[NSFileManager defaultManager] fileExistsAtPath: cachesPath];
}

/**
 *	@brief	通过文件名返回完整的Caches目录下的路径，如果不存在该路径返回nil
 *
 *	@param 	fileName 	文件名
 *
 *	@return	返回Caches完整路径
 */
+ (NSString* )cachesFilePath:(NSString*)fileName
{
	if(fileName == nil)
		return nil;
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString* cachesDirectory = [paths objectAtIndex: 0];
	NSString* cachesPath = [cachesDirectory stringByAppendingPathComponent: fileName];
	return cachesPath;
}

/**
 *	@brief	删除Caches文件
 *
 *	@param 	fileName 	文件名
 *
 *	@return	删除是否成功
 */
+ (BOOL)deleteCachesFile:(NSString*)fileName

{
    BOOL del = NO;
	if(fileName == nil)
		return del;
	NSString* cachesPath = [self cachesFilePath:fileName];
	if( [[NSFileManager defaultManager] fileExistsAtPath: cachesPath])
	{
		del = [[NSFileManager defaultManager] removeItemAtPath: cachesPath error:nil];
	}
	return del;
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end
