//
//  LivePhotoConverter.m
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/23.
//


#import "LivePhotoConverter.h"
#import <Photos/Photos.h>
#import <CoreMedia/CMMetadata.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define NAME_TEMP_FILE      @"live_tmp.mov"
#define NAME_IMAGE_FILE     @"live_generated.jpg"
#define NAME_MOVIE_FILE     @"live_generated.mov"
#define NAME_Video_MOVIE_FILE     @"video_generated.mov"
#define NAME_Video_Image_FILE     @"video_generated.jpg"



#define LivePhoto_PATH_TEMP_FILE [NSTemporaryDirectory() stringByAppendingPathComponent:NAME_TEMP_FILE]
#define LivePhoto_PATH_IMAGE_FILE [NSTemporaryDirectory() stringByAppendingPathComponent:NAME_IMAGE_FILE]
#define LivePhoto_PATH_MOVIE_FILE [NSTemporaryDirectory() stringByAppendingPathComponent:NAME_MOVIE_FILE]

#define Video_PATH_MOVIE_FILE [NSTemporaryDirectory() stringByAppendingPathComponent:NAME_Video_MOVIE_FILE]

#define Video_PATH_Image_FILE [NSTemporaryDirectory() stringByAppendingPathComponent:NAME_Video_Image_FILE]
 




@interface LivePhotoConverter ()
//@property (nonatomic, copy) void(^completionBlock)(PHLivePhoto *livePhoto);
@property (nonatomic, strong) NSURL *userVideoPathUrl;
@property (nonatomic, strong) NSURL *userVideoImagePathUrl;

@property (nonatomic) AVAssetExportSession *session;
@property (nonatomic) AVURLAsset *asset;
@property (nonatomic) AVAssetReader *reader;
@property (nonatomic) AVAssetWriter *writer;
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) dispatch_group_t group;


@end


@implementation LivePhotoConverter
+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}


- (void)convertVideoAssetToSandboxPathWithPhotoAsset:(PHAsset *)phasset firstImage:(UIImage *)firstImage completion:(void(^)(NSURL *videoPath, NSURL *imagePath))completion {
    
    
    [UIImageJPEGRepresentation(firstImage, 1.0) writeToFile:Video_PATH_Image_FILE atomically:YES];
    self.userVideoImagePathUrl = [NSURL fileURLWithPath:Video_PATH_Image_FILE];
    
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:phasset];
    PHAssetResource *resource;
    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypePairedVideo || assetRes.type == PHAssetResourceTypeVideo) {
            resource = assetRes;
        }
        
        NSString * fileName = @"";
        if (resource.originalFilename) {
            fileName = resource.originalFilename;
        }
        if (phasset.mediaType == PHAssetMediaTypeVideo || phasset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHImageRequestOptionsVersionCurrent;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            self.userVideoPathUrl = [NSURL fileURLWithPath:Video_PATH_MOVIE_FILE];
            
            [[NSFileManager defaultManager] removeItemAtPath:[self.userVideoPathUrl path] error:nil];
            
            __weak typeof(self) weakSelf = self;
            [[PHImageManager defaultManager] requestAVAssetForVideo:phasset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
                AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
                exportSession.outputURL = strongSelf.userVideoPathUrl;
                exportSession.outputFileType =  AVFileTypeQuickTimeMovie;
                [exportSession exportAsynchronouslyWithCompletionHandler:^{
                    completion(strongSelf.userVideoPathUrl,strongSelf.userVideoImagePathUrl);
                }];
            }];
//

        }
    }
    
}

- (void)convertVideoToLivePhotoWithVideoPathUrl:(NSURL *)videoUrl imageUrl:(NSURL *)imageUrl completion:(void(^)(PHLivePhoto *livePhoto))completion {
    // courtesy of Genady Okrain:
    // https://realm.io/news/hacking-live-photos-iphone-6s/
    // https://github.com/genadyo/LivePhotoDemo/
    
    CGSize targetSize = CGSizeZero;
    PHImageContentMode contentMode = PHImageContentModeDefault;
    
    // call scary Private API to create the live photo
//    PHLivePhoto *livePhoto = [[PHLivePhoto alloc] init];
//
//    SEL initWithImageURLvideoURL = NSSelectorFromString(@"_initWithImageURL:videoURL:targetSize:contentMode:");
//
//    if ([livePhoto respondsToSelector:initWithImageURLvideoURL]) {
//        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[livePhoto methodSignatureForSelector:initWithImageURLvideoURL]];
//        [invocation setSelector:initWithImageURLvideoURL];
//        [invocation setTarget:livePhoto];
//        [invocation setArgument:&(imageUrl) atIndex:2];
//        [invocation setArgument:&(videoUrl) atIndex:3];
//        [invocation setArgument:&(targetSize) atIndex:4];
//        [invocation setArgument:&(contentMode) atIndex:5];
//        [invocation invoke];
//    }
//    if (completion) {
//        completion(livePhoto);
//    }
    NSData *data = [NSData dataWithContentsOfURL:imageUrl];

    UIImage *image = [UIImage imageWithData:data]; // 取得图片
 
    
    [PHLivePhoto requestLivePhotoWithResourceFileURLs:@[imageUrl,videoUrl] placeholderImage:image targetSize:targetSize contentMode:contentMode resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nonnull info) {
        if (completion) {
            if (livePhoto) {
                completion(livePhoto);
            }
            
        }
    }];
    
    
    
}


- (void)saveLivePhotoAssetWithVideoURL:(NSURL *)videoURL imageURL:(NSURL *)imageURL completion:(void(^)(NSError * _Nullable error))completion {
    
    NSString *identifier = [NSUUID UUID].UUIDString;
    
    [self useAssetWriter:imageURL video:videoURL identifier:identifier complete:^(BOOL success, NSString *photoFile, NSString *videoFile, NSError *error) {
        
        NSURL *photo = [NSURL fileURLWithPath:photoFile];
        NSURL *video = [NSURL fileURLWithPath:videoFile];
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
            [request addResourceWithType:PHAssetResourceTypePhoto fileURL:photo options:nil];
            [request addResourceWithType:PHAssetResourceTypePairedVideo fileURL:video options:nil];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) { NSLog(@"Saved."); }
            else { NSLog(@"Save error: %@", error); }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *title = success ? @"Saved" : @"Error";
                completion(error);
            });
        }];
    }];
    
    
}

- (void)useAssetWriter:(NSURL *)photoURL video:(NSURL *)videoURL identifier:(NSString *)identifier complete:(void (^)(BOOL success, NSString *photoFile, NSString *videoFile, NSError *error))complete {
    // Photo
    NSString *photoName = [photoURL lastPathComponent];
    NSString *photoFile = [self filePathFromDoc:photoName];
    [self addMetadataToPhoto:photoURL outputFile:photoFile identifier:identifier];
    
    // Video
    NSString *videoName = [videoURL lastPathComponent];
    NSString *videoFile = [self filePathFromDoc:videoName];
    [self addMetadataToVideo:videoURL outputFile:videoFile identifier:identifier];
    
    if (!self.group) return;
    dispatch_group_notify(self.group, dispatch_get_main_queue(), ^{
        [self finishWritingTracksWithPhoto:photoFile video:videoFile complete:complete];
    });
}

- (void)finishWritingTracksWithPhoto:(NSString *)photoFile video:(NSString *)videoFile complete:(void (^)(BOOL success, NSString *photoFile, NSString *videoFile, NSError *error))complete {
    [self.reader cancelReading];
    [self.writer finishWritingWithCompletionHandler:^{
        if (complete) complete(YES, photoFile, videoFile, nil);
    }];
}

- (void)addMetadataToPhoto:(NSURL *)photoURL outputFile:(NSString *)outputFile identifier:(NSString *)identifier {
    NSMutableData *data = [NSData dataWithContentsOfURL:photoURL].mutableCopy;
    UIImage *image = [UIImage imageWithData:data];
    CGImageRef imageRef = image.CGImage;
    NSDictionary *imageMetadata = @{(NSString *)kCGImagePropertyMakerAppleDictionary : @{@"17" : identifier}};
    CGImageDestinationRef dest = CGImageDestinationCreateWithData((CFMutableDataRef)data, kUTTypeJPEG, 1, nil);
    CGImageDestinationAddImage(dest, imageRef, (CFDictionaryRef)imageMetadata);
    CGImageDestinationFinalize(dest);
    [data writeToFile:outputFile atomically:YES];
}

- (NSString *)filePathFromDoc:(NSString *)filename {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [docPath stringByAppendingPathComponent:filename];
    return filePath;
}

- (void)addMetadataToVideo:(NSURL *)videoURL outputFile:(NSString *)outputFile identifier:(NSString *)identifier {
    NSError *error = nil;
    
    // Reader
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:&error];
    if (error) {
        NSLog(@"Init reader error: %@", error);
        return;
    }
    NSMutableArray<AVMetadataItem *> *metadata = asset.metadata.mutableCopy;
    AVMetadataItem *item = [self createContentIdentifierMetadataItem:identifier];
    [metadata addObject:item];
    
    // Writer
    NSURL *videoFileURL = [NSURL fileURLWithPath:outputFile];
    [self deleteFile:outputFile];
//
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL: videoFileURL fileType: AVFileTypeQuickTimeMovie error:&error];
    if (error) {
        NSLog(@"Init writer error: %@", error);
        return;
    }
    [writer setMetadata:metadata];
    
    // Tracks
    NSArray<AVAssetTrack *> *tracks = [asset tracks];
    for (AVAssetTrack *track in tracks) {
        NSDictionary *readerOutputSettings = nil;
        NSDictionary *writerOuputSettings = nil;
        if ([track.mediaType isEqualToString:AVMediaTypeAudio]) {
            readerOutputSettings = @{AVFormatIDKey : @(kAudioFormatLinearPCM)};
            writerOuputSettings = @{AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                    AVSampleRateKey : @(44100),
                                    AVNumberOfChannelsKey : @(2),
                                    AVEncoderBitRateKey : @(128000)};
        }
        AVAssetReaderTrackOutput *output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:readerOutputSettings];
        AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:track.mediaType outputSettings:writerOuputSettings];
        if ([reader canAddOutput:output] && [writer canAddInput:input]) {
            [reader addOutput:output];
            [writer addInput:input];
        }
    }
    
    // Metadata track
    AVAssetWriterInput *input = [self createStillImageTimeAssetWriterInput];
    AVAssetWriterInputMetadataAdaptor *adaptor = [AVAssetWriterInputMetadataAdaptor assetWriterInputMetadataAdaptorWithAssetWriterInput:input];
    if ([writer canAddInput:input]) {
        [writer addInput:input];
    }
    
    [writer startWriting];
    [writer startSessionAtSourceTime:kCMTimeZero];
    [reader startReading];
    
    // Write metadata track's metadata
    AVMetadataItem *timedItem = [self createStillImageTimeMetadataItem];
    CMTimeRange timedRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(1, 100));
    AVTimedMetadataGroup *timedMetadataGroup = [[AVTimedMetadataGroup alloc] initWithItems:@[timedItem] timeRange:timedRange];
    [adaptor appendTimedMetadataGroup:timedMetadataGroup];
    
    // Write other tracks
    self.reader = reader;
    self.writer = writer;
    self.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.group = dispatch_group_create();
    for (NSInteger i = 0; i < reader.outputs.count; ++i) {
        dispatch_group_enter(self.group);
        [self writeTrack:i];
    }
}

- (AVMetadataItem *)createStillImageTimeMetadataItem {
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.keySpace = AVMetadataKeySpaceQuickTimeMetadata;
    item.key = @"com.apple.quicktime.still-image-time";
    item.value = @(-1);
    item.dataType = (NSString *)kCMMetadataBaseDataType_SInt8;
    return item;
}

- (AVAssetWriterInput *)createStillImageTimeAssetWriterInput {
    NSArray *spec = @[@{(NSString *)kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier : @"mdta/com.apple.quicktime.still-image-time",
                        (NSString *)kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType : (NSString *)kCMMetadataBaseDataType_SInt8 }];
    CMFormatDescriptionRef desc = NULL;
    CMMetadataFormatDescriptionCreateWithMetadataSpecifications(kCFAllocatorDefault, kCMMetadataFormatType_Boxed, (__bridge CFArrayRef)spec, &desc);
    AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeMetadata outputSettings:nil sourceFormatHint:desc];
    return input;
}

- (void)writeTrack:(NSInteger)trackIndex {
    AVAssetReaderOutput *output = self.reader.outputs[trackIndex];
    AVAssetWriterInput *input = self.writer.inputs[trackIndex];
    
    [input requestMediaDataWhenReadyOnQueue:self.queue usingBlock:^{
        while (input.readyForMoreMediaData) {
            AVAssetReaderStatus status = self.reader.status;
            CMSampleBufferRef buffer = NULL;
            if ((status == AVAssetReaderStatusReading) &&
                (buffer = [output copyNextSampleBuffer])) {
                BOOL success = [input appendSampleBuffer:buffer];
                CFRelease(buffer);
                if (!success) {
                    NSLog(@"Track %d. Failed to append buffer.", (int)trackIndex);
                    [input markAsFinished];
                    dispatch_group_leave(self.group);
                    return;
                }
            } else {
                if (status == AVAssetReaderStatusReading) {
                    NSLog(@"Track %d complete.", (int)trackIndex);
                } else if (status == AVAssetReaderStatusCompleted) {
                    NSLog(@"Reader completed.");
                } else if (status == AVAssetReaderStatusCancelled) {
                    NSLog(@"Reader cancelled.");
                } else if (status == AVAssetReaderStatusFailed) {
                    NSLog(@"Reader failed.");
                }
                [input markAsFinished];
                dispatch_group_leave(self.group);
                return;
            }
        }
    }];
}

- (AVMetadataItem *)createContentIdentifierMetadataItem:(NSString *)identifier {
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.keySpace = AVMetadataKeySpaceQuickTimeMetadata;
    item.key = AVMetadataQuickTimeMetadataKeyContentIdentifier;
    item.value = identifier;
    return item;
}

- (void)deleteFile:(NSString *)file {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:file]) {
        [fm removeItemAtPath:file error:nil];
    }
}




@end
