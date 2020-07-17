
//  GHWAddLazyCodeManager.h
//  GHWExtension
//
//  Created by 黑化肥发灰 on 2019/8/30.
//  Copyright © 2019年 黑化肥发灰. All rights reserved.


#import <XcodeKit/XcodeKit.h>

/// 给属性添加lazy code：根据自定义的lazy code的格式去添加
/// @discussion 可以根据项目的代码规范定义常用的懒加载的代码片段
@interface GHWAddLazyCodeManager : NSObject

+(GHWAddLazyCodeManager *)sharedInstane;
/**
 自动添加视图布局 && 设置Getter方法 && 自动AddSubView
 @param invocation 获取选中的字符流
 */
- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation;

@end
