//
//  BBVideoViewController.h
//  BBDualMultiThreadMoviePlayer
//
//  Created by Bryan Boyko on 9/1/14.
//  Copyright (c) 2014 none. All rights reserved.
//


#import <UIKit/UIKit.h>

@class BBAVPlayerDemoPlaybackView;
@class AVPlayer;
@class BBVideo;

@interface BBVideoViewController : UIViewController


@property (readwrite, retain) AVPlayer* mPlayer;
@property (readwrite, retain) AVPlayer* mPlayer2;
@property (nonatomic, strong) BBVideo *video;

- (instancetype)initForNewVideo:(BOOL)isNew;

@property (nonatomic, copy) void (^dismissBlock)(void);

- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context;

@end
