//
//  GHWInitViewManager.h
//  GHWExtension
//
//  Created by 黑化肥发灰 on 2019/8/30.
//  Copyright © 2019 黑化肥发灰. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>
NS_ASSUME_NONNULL_BEGIN

/// 给某个类添加生命周期的默认方法
/// @discussion 会根据类的初始化方法的不同，去归类添加代码片段
@interface GHWInitViewManager : NSObject

+ (GHWInitViewManager *)sharedInstane;

- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation;

@end

NS_ASSUME_NONNULL_END
