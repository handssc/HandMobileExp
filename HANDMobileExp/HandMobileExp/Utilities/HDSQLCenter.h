//
//  EXPSqlCenter.h
//  HandMobileExp
//
//  Created by jiangtiteng on 14-7-1.
//  Copyright (c) 2014年 hand. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMResultSet.h"

@interface HDSQLCenter : NSObject
//查询ToDoList操作
-(FMResultSet *)SQLQueryToDoList:(FMDatabase *)db;
//查询ToDoList摘要操作
-(FMResultSet *)SQLQueryToDoListDigest:(FMDatabase *)db;
//查询动作(单条)
-(FMResultSet *)SQLQueryAction:(FMDatabase *)db conditions:(NSDictionary *) conditions;
//建表
-(BOOL)SQLCreatTable:(FMDatabase *)db;
//切换用户清理表数据
-(BOOL)SQLCleanTable:(FMDatabase *)db;
//提交成功,删除本地记录
-(BOOL)SQLRemoveRecords:(FMDatabase *)db recordList:(NSArray *) recordList;
-(BOOL)SQLUpdateRecords:(FMDatabase *)db recordList:(NSArray *) recordList;
-(BOOL)SQLUpdateDeliverRecords:(FMDatabase *)db recordList:(NSArray *) recordList;
-(BOOL)SQLInsertRecords:(FMDatabase *)db recordList:(NSArray *) recordList;

//将动作保存到动作表
-(BOOL)SQLActionInsertRecords:(FMDatabase *)db recordList:(NSArray *) recordList;
//将动作提交到本地(单条)
-(BOOL)SQLActionSubmitLocal:(FMDatabase *)db recordList:(NSArray *) recordList;



//条件查询MOBILE_EXP_REPORT_LINE
-(FMResultSet *)QUERY_MOBILE_EXP_REPORT_LINE:(FMDatabase *)db
                                       param:(NSDictionary *)param;

@end
