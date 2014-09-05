//
//  BBImageStore.m
//  BBDualMultiThreadMoviePlayer
//
//  Created by Bryan Boyko on 9/1/14.
//  Copyright (c) 2014 none. All rights reserved.
//

#import "BBImageStore.h"

@interface BBImageStore ()

- (NSString *)imagePathForKey:(NSString *)key;

@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation BBImageStore

+ (instancetype)sharedStore
{
    static BBImageStore *sharedStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    
    return sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"use sharedStore" userInfo:nil];
    
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] init];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(clearCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    
    return self;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    self.dictionary[key] = image;
    
    
    //create full path for the image
    NSString *imagePath = [self imagePathForKey:key];
    
    //turn image into JPEG data
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    
    //write it to full path
    [data writeToFile:imagePath atomically:YES];
}

- (void)setImageTwo:(UIImage *)image forKey:(NSString *)key
{
    self.dictionary[key] = image;
    
    
    //create full path for the image
    NSString *imagePath = [self imagePathForKey:key];
    
    //turn image into JPEG data
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    
    //write it to full path
    [data writeToFile:imagePath atomically:YES];
}

- (UIImage *)imageForKey:(NSString *)key
{
    //if possible, get it from the dictionary
    UIImage *result = self.dictionary[key];
    
    if (!result) {
        NSString *imagePath = [self imagePathForKey:key];
        
        // create uiimage object from file
        result = [UIImage imageWithContentsOfFile:imagePath];
        
        //if found, place in cache
        if (result) {
            self.dictionary[key] = result;
        } else {
            NSLog(@"error: unable to find %@", [self imagePathForKey:key]);
        }
    }
    
    return result;
}

- (void)deleteImageForKey:(NSString *)key
{
    if (!key) {
        return;
    }
    [self.dictionary removeObjectForKey:key];
    
    NSString *imagePath = [self imagePathForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
}

- (NSString *)imagePathForKey:(NSString *)key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:key];
}

- (void)clearCache:(NSNotification *)note
{
    NSLog(@"flushing %d images out of the cache", [self.dictionary count]);
    [self.dictionary removeAllObjects];
}
@end