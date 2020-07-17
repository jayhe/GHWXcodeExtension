//
//  GHWAddImportManager.m
//  GHWExtension
//
//  Created by 黑化肥发灰 on 2019/9/15.
//  Copyright © 2019 Jingyao. All rights reserved.
//

#import "GHWAddImportManager.h"
#import "GHWExtensionConst.h"

@implementation GHWAddImportManager

+ (GHWAddImportManager *)sharedInstane {
    static dispatch_once_t predicate;
    static GHWAddImportManager * sharedInstane;
    dispatch_once(&predicate, ^{
        sharedInstane = [[GHWAddImportManager alloc] init];
    });
    return sharedInstane;
}

- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
    if (![invocation.buffer.selections count]) {
        return;
    }
    
    XCSourceTextRange *selectRange = invocation.buffer.selections[0]; //从buffer中获取选中的第一个区域XCSourceTextRange
    NSInteger startLine = selectRange.start.line; // 选中的区域的开始行号
    NSInteger endLine = selectRange.end.line; // 选中的区域的结束行号
    NSInteger startColumn = selectRange.start.column; // 选中区域的开始列
    NSInteger endColumn = selectRange.end.column; // 选中区域的结束列
    
    if (startLine != endLine || startColumn == endColumn) { // 如果选择了多行则不处理，或者选择的列区域长度小于1也不处理
        return;
    }
    
    NSString *selectLineStr = invocation.buffer.lines[startLine]; // 取出选中的行的内容
    NSString *selectContentStr = [[selectLineStr substringWithRange:NSMakeRange(startColumn, endColumn - startColumn)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; // 根据选中的列的开始和结束位置来获取选中的内容
    if ([selectContentStr length] == 0) {
        return;
    }
    NSString *insertStr = [NSString stringWithFormat:@"#import \"%@.h\"", selectContentStr]; // 拼接导入头文件的内容
    
    // 遍历获取buffer中的最后一个import的行的索引
    NSInteger lastImportIndex = -1;
    for (NSInteger i = 0; i < [invocation.buffer.lines count]; i++) {
        NSString *contentStr = [invocation.buffer.lines[i] deleteSpaceAndNewLine];
        if ([contentStr hasPrefix:@"#import"]) {
            lastImportIndex = i;
        }
    }
    // 判断是否是已经导入过的头文件，如果是则不需要再插入
    NSInteger alreadyIndex = [invocation.buffer.lines indexOfFirstItemContainStr:insertStr];
    if (alreadyIndex != NSNotFound) {
        return;
    }
    // 设置插入的行号，如果buffer中已经有import过则lastImportIndex不为-1，此时插入到lastImportIndex的后一行；否则就插入在首行
    NSInteger insertIndex = 0;
    if (lastImportIndex != -1) {
        insertIndex = lastImportIndex + 1;
    }
    [invocation.buffer.lines insertObject:insertStr atIndex:insertIndex];
}

@end
