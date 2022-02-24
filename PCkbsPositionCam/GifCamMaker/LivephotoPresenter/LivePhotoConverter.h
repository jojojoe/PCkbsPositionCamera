//
//  LivePhotoConverter.h
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/23.
//


#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface LivePhotoConverter : NSObject

+ (instancetype)sharedInstance;

- (void)convertVideoAssetToSandboxPathWithPhotoAsset:(PHAsset *)phasset firstImage:(UIImage *)firstImage completion:(void(^)(NSURL *videoPath, NSURL *imagePath))completion;

- (void)convertVideoToLivePhotoWithVideoPathUrl:(NSURL *)videoUrl imageUrl:(NSURL *)imageUrl completion:(void(^)(PHLivePhoto *livePhoto ))completion;

- (void)saveLivePhotoAssetWithVideoURL:(NSURL *)videoURL imageURL:(NSURL *)imageURL completion:(void(^)(NSError * _Nullable error))completion;


@end

NS_ASSUME_NONNULL_END
