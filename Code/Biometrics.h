/*
 * Copyright © 2010 - 2023 Modo Labs Inc. All rights reserved.
 *
 * The license governing the contents of this file is located in the LICENSE
 * file located at the root directory of this distribution. If the LICENSE file
 * is missing, please contact sales@modolabs.com.
 *
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Biometrics : NSObject

+ (void)enrolled;
+ (void)unenrolled;
+ (void)successfulAuthentication;
+ (void)unsuccessfulAuthentication;

@end

NS_ASSUME_NONNULL_END
