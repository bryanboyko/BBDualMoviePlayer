//
//  BBVideo.h
//  BBDualMultiThreadMoviePlayer
//
//  Created by Bryan Boyko on 9/1/14.
//  Copyright (c) 2014 none. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBVideo : NSObject <NSCoding>

@property (nonatomic, copy) NSString *videoName;
@property (nonatomic, copy) NSString *videoTwoName;
@property (nonatomic, copy) NSURL *videoURL;
@property (nonatomic, copy) NSURL *videoTwoURL;

@property (nonatomic, copy) NSString *videoKey;
@property (nonatomic, copy) NSString *videoTwoKey;

@property (nonatomic) UIImage *thumbnail;
@property (nonatomic) UIImage *thumbnailTwo;

// designated initailzer for BBVideo
- (instancetype)initWithVideoName:(NSString *)videoName
                     videoTwoName:(NSString *)videoTwoName
                         videoURL:(NSURL *)videoURL
                      videoTwoURL:(NSURL *)videoTwoURL;

- (void)setThumbnailFromImage:(UIImage *)image;
- (void)setThumbnailFromImageTwo:(UIImage *)image;

@end
