//
//  BBAVPlayerDemoPlaybackView.m
//  BBDualMultiThreadMoviePlayer
//
//  Created by Bryan Boyko on 9/3/14.
//  Copyright (c) 2014 none. All rights reserved.
//

#import "BBAVPlayerDemoPlaybackView.h"
#import <AVFoundation/AVFoundation.h>



@implementation BBAVPlayerDemoPlaybackView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer*)player
{
    return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player
{
    [(AVPlayerLayer*)[self layer] setPlayer:player];
}

/* Specifies how the video is displayed within a player layer’s bounds.
 (AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    playerLayer.videoGravity = fillMode;
}

@end
