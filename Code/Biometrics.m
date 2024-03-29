/*
 * Copyright © 2010 - 2023 Modo Labs Inc. All rights reserved.
 *
 * The license governing the contents of this file is located in the LICENSE
 * file located at the root directory of this distribution. If the LICENSE file
 * is missing, please contact sales@modolabs.com.
 *
 */

#import "Biometrics.h"
#import "notify.h"

@implementation Biometrics

+ (void)enrolled {
    [self postEnrollment:true];
}

+ (void)unenrolled {
    [self postEnrollment:false];
}

+ (void)successfulAuthentication {
    notify_post("com.apple.BiometricKit_Sim.fingerTouch.match");
    notify_post("com.apple.BiometricKit_Sim.pearl.match");
}

+ (void)unsuccessfulAuthentication {
    notify_post("com.apple.BiometricKit_Sim.fingerTouch.nomatch");
    notify_post("com.apple.BiometricKit_Sim.pearl.nomatch");
}

+ (void)postEnrollment:(BOOL)isEnrolled {
    int token;
    notify_register_check("com.apple.BiometricKit.enrollmentChanged", &token);
    notify_set_state(token, isEnrolled);
    notify_post("com.apple.BiometricKit.enrollmentChanged");
}

@end
