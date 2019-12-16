---
title: C语言操作数据库
tags: Database
---
# C语言操作数据库

## Access Database

1. Access文件路径：`D:\Database1.accdb`，表结构如下图所示：<br/>![]({{site_url}}/assets/blog/c-database/access.png)
<!--more-->

	```cpp
	#include <stdio.h>
	#include <Windows.h>
	#include <sqlext.h>

	int main(int argc, char ** argv) {
		int iRet = 0;
		HENV hEnv;
		HDBC hDbc;
		HSTMT hStmt;
		RETCODE retCode;

		char driver[] = "Driver={Microsoft Access Driver (*.mdb, *.accdb)};";
		char dsn[] = "DSN='';";
		char dbq[] = "DBQ=";
		char uid[] = "UID=";
		char pwd[] = "PWD=";

		char dbqStr[64] = { 0 };
		sprintf(dbqStr, "%s%s%s", dbq, "D:\\Database1.accdb", ";");
		char uidStr[64] = { 0 };
		sprintf(uidStr, "%s%s%s", uid, "admin", ";");
		char pwdStr[64] = { 0 };
		sprintf(pwdStr, "%s%s%s", pwd, "admin", ";");

		char connStr[256] = { 0 };
		sprintf(connStr, "%s%s%s%s%s", driver, dsn, dbqStr, uidStr, pwdStr);
		char connOutStr[256] = { 0 };
		int connOutLen = 0;

		if (SQLAllocEnv(&hEnv)) {
			iRet = -1;
		}

		if (SQLAllocConnect(hEnv, &hDbc)) {
			iRet = -1;
		}

		retCode = SQLDriverConnect(hDbc, NULL, (unsigned char*)connStr,
			SQL_NTS, (unsigned char*)connOutStr,
			255, (SQLSMALLINT*)&connOutLen, SQL_DRIVER_NOPROMPT);//建立连接

		if (SQL_SUCCEEDED(retCode)) {
			if (!SQLAllocStmt(hDbc, &hStmt)) {
				char queryStr[256] = { 0 };
				sprintf(queryStr, "%s%s%s%s%s%s", "SELECT ", "value ", "FROM ", "pSystem ", "WHERE ", "ProjIdbw=8 and ProjNodeI=10 and Key='WPCLOUD_PRIMARY_SCADA_ID';");
				if (!SQLPrepare(hStmt, queryStr, SQL_NTS)) {
					SQLCHAR chval[128] = {0}; //将结果绑定到该缓冲区
					int retNum;//结果长度
					SQLBindCol(hStmt, 1, SQL_C_CHAR, chval, 128, (SQLINTEGER*)&retNum);//将应用程序数据缓冲区绑定到结果集中的列。
					if (!SQLExecute(hStmt)) {
						retCode = SQLFetch(hStmt);//获取数据，保存在chval中，将数据长度保存在retNum中
						while (SQL_SUCCEEDED(retCode)) {//循环获取数据
							printf("%s\n", chval);
							retCode = SQLFetch(hStmt);
						}
					} else
						iRet = -1;
				} else
					iRet = -1;
				SQLFreeStmt(hStmt, SQL_DROP);
			} else
				iRet = -1;
		}

		SQLDisconnect(hDbc);
		SQLFreeHandle(SQL_HANDLE_DBC, hDbc);
		SQLFreeHandle(SQL_HANDLE_ENV, hEnv);
		return iRet;
	}
	```
