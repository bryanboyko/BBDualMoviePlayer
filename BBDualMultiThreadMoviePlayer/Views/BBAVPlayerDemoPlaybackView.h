//
//  BBAVPlayerDemoPlaybackView.h
//  BBDualMultiThreadMoviePlayer
//
//  Created by Bryan Boyko on 9/3/14.
//  Copyright (c) 2014 none. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;

@interface BBAVPlayerDemoPlaybackView : UIView

@property (nonatomic, retain) AVPlayer *player;

- (void)setPlayer:(AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;

@end
