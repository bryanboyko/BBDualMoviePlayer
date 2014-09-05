//
//  BBVideoStore.h
//  BBDualMultiThreadMoviePlayer
//
//  Created by Bryan Boyko on 9/1/14.
//  Copyright (c) 2014 none. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBVideo;

@interface BBVideoStore : NSObject

@property (nonatomic, readonly) NSArray *allVideos;

+ (instancetype)sharedStore;
- (BBVideo *)createVideo;

- (void)removeVideo:(BBVideo *)video;

- (BOOL)saveChanges;


@end

