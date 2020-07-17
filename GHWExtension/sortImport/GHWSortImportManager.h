//
//  GHWSortImportManager.h
//  GHWExtension
//
//  Created by 黑化肥发灰 on 2019/8/30.
//  Copyright © 2019 黑化肥发灰. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 对import的文件进行一定的规则来归类展示出来，让类的import看起来更加清晰
@interface GHWSortImportManager : NSObject

+ (GHWSortImportManager *)sharedInstane;

- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation;



@end

NS_ASSUME_NONNULL_END
