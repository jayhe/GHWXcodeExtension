//
//  GHWInitViewManager.m
//  GHWExtension
//
//  Created by 黑化肥发灰 on 2019/8/30.
//  Copyright © 2019 黑化肥发灰. All rights reserved.
//

#import "GHWInitViewManager.h"
#import "GHWExtensionConst.h"

@interface GHWInitViewManager ()

@property (nonatomic, strong) NSMutableIndexSet *indexSet;

@end

@implementation GHWInitViewManager

+ (GHWInitViewManager *)sharedInstane {
    static dispatch_once_t predicate;
    static GHWInitViewManager * sharedInstane;
    dispatch_once(&predicate, ^{
        sharedInstane = [[GHWInitViewManager alloc] init];
    });
    return sharedInstane;
}

- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
    [self.indexSet removeAllIndexes];
    
    // 添加 extension 代码
    NSString *className = [invocation.buffer.lines fetchClassName]; // 获取本文件的类名
    if ([invocation.buffer.lines indexOfFirstItemContainStr:[NSString stringWithFormat:@"@interface %@ ()", className]] == NSNotFound) { // 判断是否有写类的extension代码
        // 没有添加则添加默认的extension代码
        NSString *extensionStr = [NSString stringWithFormat:kInitViewExtensionCode, className]; // 初始化extension代码
        NSArray *contentArray = [extensionStr componentsSeparatedByString:@"\n"]; // 根据换行符将字符串分割成数组
        NSInteger impIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kImplementation]; // 找到类的implementation的代码的行的index
        [invocation.buffer.lines insertItemsOfArray:contentArray fromIndex:impIndex]; // 将extension代码插入到implementation代码的前面
    }
    // 根据不同的UI类的类型来添加不同的UI类的初始化方法
    // 这里可以根据自己项目定制的类名的代码规范来写条件分支
    if ([[className lowercaseString] hasSuffix:@"view"] ||
        [[className lowercaseString] hasSuffix:@"bar"] ||
        [[className lowercaseString] hasSuffix:@"collectioncell"] ||
        [[className lowercaseString] hasSuffix:@"collectionviewcell"]) {
        // 添加 Life Cycle 代码，如果类中未实现的话
        if ([invocation.buffer.lines indexOfFirstItemContainStr:@"(instancetype)initWithFrame"] == NSNotFound) {
            // 删除类的实现中的默认的代码片段
            [self deleteCodeWithInvocation:invocation];
            // 插入Life Cycle代码片段
            NSInteger lifeCycleIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kImplementation]; // 找到implementation代码的行号
            if (lifeCycleIndex != NSNotFound) {
                lifeCycleIndex = lifeCycleIndex + 1; // 插入到@implementation xxx 的后面
                NSString *lifeCycleStr = kInitViewLifeCycleCode;
                NSArray *lifeCycleContentArray = [lifeCycleStr componentsSeparatedByString:@"\n"];
                [invocation.buffer.lines insertItemsOfArray:lifeCycleContentArray fromIndex:lifeCycleIndex];
            }
        }
    } else if ([[className lowercaseString] hasSuffix:@"tableviewcell"] ||
               [[className lowercaseString] hasSuffix:@"tablecell"]) {
        // 添加 Life Cycle 代码
        if ([invocation.buffer.lines indexOfFirstItemContainStr:@"(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier"] == NSNotFound) {
            [self deleteCodeWithInvocation:invocation];
            NSInteger lifeCycleIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kImplementation];
            if (lifeCycleIndex != NSNotFound) {
                lifeCycleIndex = lifeCycleIndex + 1;
                NSString *lifeCycleStr = kInitTableViewCellLifeCycleCode;
                NSArray *lifeCycleContentArray = [lifeCycleStr componentsSeparatedByString:@"\n"];
                [invocation.buffer.lines insertItemsOfArray:lifeCycleContentArray fromIndex:lifeCycleIndex];
            }
        }
    } else if ([[className lowercaseString] hasSuffix:@"controller"] ||
               [className hasSuffix:@"VC"] ||
               [className hasSuffix:@"Vc"]) {
        // 添加 Life Cycle 代码
        if ([invocation.buffer.lines indexOfFirstItemContainStr:kGetterSetterPragmaMark] == NSNotFound) {
            [self deleteCodeWithInvocation:invocation];
            NSInteger lifeCycleIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kImplementation];
            if (lifeCycleIndex != NSNotFound) {
                lifeCycleIndex = lifeCycleIndex + 1;
                NSString *lifeCycleStr = kInitViewControllerLifeCycleCode;
                NSArray *lifeCycleContentArray = [lifeCycleStr componentsSeparatedByString:@"\n"];
                [invocation.buffer.lines insertItemsOfArray:lifeCycleContentArray fromIndex:lifeCycleIndex];
            }
        }
    } else if ([[className lowercaseString] hasSuffix:@"headerview"] ||
               [[className lowercaseString] hasSuffix:@"footerview"] ||
               [[className lowercaseString] hasSuffix:@"headerfooterview"]) {
        if ([invocation.buffer.lines indexOfFirstItemContainStr:@"(instancetype)initWithReuseIdentifier:"] == NSNotFound) {
            [self deleteCodeWithInvocation:invocation];
            NSInteger lifeCycleIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kImplementation];
            if (lifeCycleIndex != NSNotFound) {
                NSInteger insertIndex = lifeCycleIndex + 1;
                NSArray *lifeCycleContentArray = [kInitTableViewHeaderFooterViewLifeCycleCode componentsSeparatedByString:@"\n"];
                [invocation.buffer.lines insertItemsOfArray:lifeCycleContentArray fromIndex:insertIndex];
            }
        }
    }
}


/// 删除@implementation xxx @end 之前的类创建的时候的默认代码，例如注释掉的drawRect等等
/// @param invocation  commond invocation
- (void)deleteCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
    NSInteger impIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kImplementation]; // @implementation xxx的行
    NSInteger endIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kEnd fromIndex:impIndex]; // @end 的行
    if (impIndex != NSNotFound && endIndex != NSNotFound) {
        for (NSInteger i = impIndex + 1; i < endIndex - 1; i++) { // 遍历开始行和结束行之前的行信息，如果剔除空格或者换行内容不为空，则将该行号暂存起来
            NSString *contentStr = [invocation.buffer.lines[i] deleteSpaceAndNewLine];
            if ([contentStr length]) {
                [self.indexSet addIndex:i];
            }
        }
    }
    if ([self.indexSet count]) {
        [invocation.buffer.lines removeObjectsAtIndexes:self.indexSet]; // 从buffer中删除到有内容的行
    }
}


- (NSMutableIndexSet *)indexSet{
    if (!_indexSet) {
        _indexSet = [[NSMutableIndexSet alloc] init];
    }
    return _indexSet;
}

@end
