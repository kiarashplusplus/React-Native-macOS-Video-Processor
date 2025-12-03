#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(VideoProcessor, RCTEventEmitter)

RCT_EXTERN_METHOD(processVideo:(NSString *)input
                  output:(NSString *)output
                  segments:(NSArray *)segments
                  outputFormat:(NSString *)outputFormat
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(trimVideo:(NSString *)input
                  output:(NSString *)output
                  startTime:(double)startTime
                  endTime:(double)endTime
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getMetadata:(NSString *)input
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(generateThumbnail:(NSString *)input
                  output:(NSString *)output
                  time:(double)time
                  maxWidth:(NSNumber *)maxWidth
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(adjustVolume:(NSString *)input
                  output:(NSString *)output
                  volume:(double)volume
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(cancelProcessing)

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

@end
