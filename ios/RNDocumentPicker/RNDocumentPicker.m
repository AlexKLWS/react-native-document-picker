//
//  RNDocumentPicker.m
//  AppExtensions
//
//  Created by Alex Korzh on 02/07/2019.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RNDocumentPicker, NSObject)
RCT_EXTERN_METHOD(show:(NSDictionary<NSString *, id> * _Nonnull)options callback:(RCTResponseSenderBlock _Nonnull)callback);
@end
