//
//  BBVideoViewController.m
//  BBDualMultiThreadMoviePlayer
//
//  Created by Bryan Boyko on 9/1/14.
//  Copyright (c) 2014 none. All rights reserved.
//

#import "BBVideoViewController.h"
#import "BBVideo.h"
#import "BBVideoStore.h"
#import "BBImageStore.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "BBAVPlayerDemoPlaybackView.h"


static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;


@interface BBVideoViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *videoNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *videoTwoNameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewTwo;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *albumButton;
@property (weak, nonatomic) IBOutlet UILabel *videoOneNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoTwoNameLabel;

@property (nonatomic, strong)MPMoviePlayerController *videoController;
@property (nonatomic, strong)MPMoviePlayerController *videoTwoController;

@property (nonatomic) BOOL chooseVideoOne;
@property (nonatomic) BOOL photoAlbum;
@property (nonatomic) UIView *moviePlayerOne;
@property (nonatomic) UIView *moviePlayerTwo;

@property (nonatomic) BBAVPlayerDemoPlaybackView *movieOnePlayer;
@property (nonatomic) BBAVPlayerDemoPlaybackView *movieTwoPlayer;


- (IBAction)takePicture:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)chooseFromPhotoAlbum:(id)sender;
- (IBAction)playVideo:(id)sender;

@end

@implementation BBVideoViewController

- (instancetype)initForNewVideo:(BOOL)isNew
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        if (isNew) {
            UIBarButtonItem *doneVideo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
            self.navigationItem.rightBarButtonItem = doneVideo;
            
            UIBarButtonItem *cancelVideo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
            self.navigationItem.leftBarButtonItem = cancelVideo;
        }
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:@"Wrong init" reason:@"Use initForNewVideo" userInfo:nil];
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.video.videoName;
    
    self.movieOnePlayer = [[BBAVPlayerDemoPlaybackView alloc] initWithFrame:CGRectMake(0, 50, 320, 265)];
    self.movieOnePlayer.backgroundColor = [UIColor blackColor];
    self.movieTwoPlayer = [[BBAVPlayerDemoPlaybackView alloc] initWithFrame:CGRectMake(0, 315, 320, 265)];
    self.movieTwoPlayer.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.movieOnePlayer];
    [self.view addSubview:self.movieTwoPlayer];
    
    NSLog(@"URL 1: %@, URL 2: %@", self.video.videoURL, self.video.videoTwoURL);
    self.mPlayer = [AVPlayer playerWithURL:self.video.videoURL];
    self.mPlayer2 = [AVPlayer playerWithURL:self.video.videoTwoURL];
    [self.mPlayer addObserver:self forKeyPath:@"status" options:0 context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    
    self.movieOnePlayer.hidden = YES;
    self.movieTwoPlayer.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    UIInterfaceOrientation io = [[UIApplication sharedApplication] statusBarOrientation];
    [self prepareViewsForOrientation:io];
    
    BBVideo *video = self.video;
    
    self.videoNameTextField.text = video.videoName;
    self.videoTwoNameTextField.text = video.videoTwoName;
    
    NSString *itemKey = self.video.videoKey;
    NSString *itemKeyTwo = self.video.videoTwoKey;
    if (itemKey) {
        // Get images for image keys from the image store
        UIImage *imageToDisplay = [[BBImageStore sharedStore] imageForKey:itemKey];
        UIImage *imageToDisplayTwo = [[BBImageStore sharedStore] imageForKey:itemKeyTwo];
        
        // Use that image to put on the screen in imageView
        self.imageView.image = imageToDisplay;
        self.imageViewTwo.image = imageToDisplayTwo;
    } else {
        // Clear the imageView
        self.imageView.image = nil;
        self.imageViewTwo.image = nil;
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    
    BBVideo *video = self.video;
    video.videoName = self.videoNameTextField.text;
    video.videoTwoName = self.videoTwoNameTextField.text;
    video.videoURL = self.video.videoURL;
    video.videoTwoURL = self.video.videoTwoURL;
}

- (IBAction)takePicture:(id)sender {
    self.photoAlbum = NO;
    
    UIAlertView *chooseVideoAlert = [[UIAlertView alloc] initWithTitle:@"Choose which video you would like to add" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Video One", @"Video Two", nil];
    [chooseVideoAlert show];
}

- (IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            self.chooseVideoOne = YES;
            break;
        case 2:
            self.chooseVideoOne = NO;
            break;
        default:
            break;
    }
    
    if (self.photoAlbum == NO) {
        [self performSelector:@selector(presentImagePicker) withObject:nil];
    } else {
        [self performSelector:@selector(presentPhotoAlbum) withObject:nil];
    }
    
}

- (void)presentImagePicker
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, nil];
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (IBAction)chooseFromPhotoAlbum:(id)sender {
    
    self.photoAlbum = YES;
    
    UIAlertView *chooseVideoAlert = [[UIAlertView alloc] initWithTitle:@"Choose which video you would like to add" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Video One", @"Video Two", nil];
    [chooseVideoAlert show];
}

- (void)presentPhotoAlbum
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,      nil];
    }
    
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)playVideo:(id)sender {
        
        //force horizontal then play side by side
        //        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        //            objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),    UIInterfaceOrientationLandscapeRight);
        //        }
        
        
        if (self.mPlayer.status == AVPlayerStatusReadyToPlay) {
            
            self.movieOnePlayer.hidden = NO;
            self.movieTwoPlayer.hidden = NO;
            
            [self.movieTwoPlayer setPlayer:self.mPlayer2];
            [self.movieOnePlayer setPlayer:self.mPlayer];
            [self.mPlayer seekToTime:kCMTimeZero];
            [self.mPlayer2 seekToTime:kCMTimeZero];
            [self.mPlayer play];
            [self.mPlayer2 play];
            
            // add nav bar button to stop videos
            

            UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"STOP" style:UIBarButtonItemStylePlain target:self action:@selector(stopPlayingVideos)];
            self.navigationItem.rightBarButtonItem = rightButton;
    }
}


- (void)stopPlayingVideos
{

    // stop videos
    [self.mPlayer pause];
    [self.mPlayer2 pause];
    self.movieOnePlayer.hidden = YES;
    self.movieTwoPlayer.hidden = YES;

    // remove stop button
    self.navigationItem.rightBarButtonItem =  nil;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.movie"]){
        // Saving the video / // Get the new unique filename
        NSString *sourcePath = [[info objectForKey:@"UIImagePickerControllerMediaURL"]relativePath];
        UISaveVideoAtPathToSavedPhotosAlbum(sourcePath, nil, @selector(video:didFinishSavingWithError:contextInfo:),nil);
    }
    
    if (self.chooseVideoOne == YES) {
        self.video.videoURL = info[UIImagePickerControllerMediaURL];
        [self performSelector:@selector(addImageToImageView) withObject:self afterDelay:0];
    } else {
        self.video.videoTwoURL = info[UIImagePickerControllerMediaURL];
        [self performSelector:@selector(addImageToImageViewTwo) withObject:self afterDelay:0];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}



//required for saving video to album
- (void)video: (NSString *) videoPath didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    
    NSLog(@"Video Saving Error: %@", error);
    [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
    NSLog(@"saved video to album");
    
}

- (void)addImageToImageView
{
    //retrieve thumbnail from videoURL
    AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:self.video.videoURL options:nil];
    AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
    generate1.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 2);
    CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
    self.imageView.image = one;
    [self.video setThumbnailFromImage:one];
    
    
    if (one) {
        [[BBImageStore sharedStore] setImage:one forKey:self.video.videoKey];
    }
}

- (void)addImageToImageViewTwo
{
    //retrieve thumbnail from videoURL
    AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:self.video.videoTwoURL options:nil];
    AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
    generate1.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 2);
    CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *two = [[UIImage alloc] initWithCGImage:oneRef];
    self.imageViewTwo.image = two;
    [self.video setThumbnailFromImageTwo:two];
    
    
    if (two) {
        [[BBImageStore sharedStore] setImage:two forKey:self.video.videoTwoKey];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

// intended for playing videos horizontally...
- (void)prepareViewsForOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.navigationController.navigationBarHidden = YES;
        self.imageView.hidden = YES;
        self.imageViewTwo.hidden = YES;
        self.cameraButton.enabled = NO;
        self.toolbar.hidden = YES;
        self.videoNameTextField.hidden = YES;
        self.videoTwoNameTextField.hidden = YES;
        self.videoOneNameLabel.hidden = YES;
        self.videoTwoNameLabel.hidden = YES;
    } else {
        self.navigationController.navigationBarHidden = NO;
        self.imageView.hidden = NO;
        self.imageViewTwo.hidden = NO;
        self.cameraButton.enabled = YES;
        self.toolbar.hidden = NO;
        self.videoNameTextField.hidden = NO;
        self.videoTwoNameTextField.hidden = NO;
        self.videoOneNameLabel.hidden = NO;
        self.videoTwoNameLabel.hidden = NO;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self prepareViewsForOrientation:toInterfaceOrientation];
}

- (void)save:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

- (void)cancel:(id)sender
{
    //if user cancels, remove exercise from store
    [[BBVideoStore sharedStore] removeVideo:self.video];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{

}

@end
