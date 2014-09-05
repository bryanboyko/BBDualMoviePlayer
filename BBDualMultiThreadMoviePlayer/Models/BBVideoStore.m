//
//  BBVideoStore.m
//  BBDualMultiThreadMoviePlayer
//
//  Created by Bryan Boyko on 9/1/14.
//  Copyright (c) 2014 none. All rights reserved.
//

#import "BBVideoStore.h"
#import "BBVideo.h"
#import "BBImageStore.h"

@interface BBVideoStore ()

@property (nonatomic) NSMutableArray *privateVideos;

@end

@implementation BBVideoStore

+ (instancetype)sharedStore
{
    static BBVideoStore *sharedStore = nil;
    
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"singleton" reason:@"use [BBVideoStore sharedStore]" userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        self.privateVideos = [[NSMutableArray alloc] init];
        
        
        NSString *path = [self videoArchivePath];
        self.privateVideos = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        //if the array hadnt been saved previously, create a new empty one
        if (!_privateVideos) {
            _privateVideos = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (NSArray *)allVideos
{
    return self.privateVideos;
}

- (BBVideo *)createVideo
{
    BBVideo *video = [[BBVideo alloc] init];
    
    [self.privateVideos addObject:video];
    
    NSLog(@"privateVideos: %@", self.privateVideos);
    
    return video;
}

- (void)removeVideo:(BBVideo *)video
{
    NSString *key = video.videoKey;
    
    [[BBImageStore sharedStore] deleteImageForKey:key];
    
    [self.privateVideos removeObjectIdenticalTo:video];
}

- (NSString *)videoArchivePath
{
    NSArray *documentDictionaries = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //get the one document directory from the list
    NSString *documentDirectory = [documentDictionaries firstObject];
    
    NSLog(@"video archive path is: %@", documentDirectory);
    
    return [documentDirectory stringByAppendingPathComponent:@"videos.archive"];
}

- (BOOL)saveChanges
{
    NSString *path = [self videoArchivePath];
    
    //returns YES on success
    return [NSKeyedArchiver archiveRootObject:self.privateVideos toFile:path];
}

@end