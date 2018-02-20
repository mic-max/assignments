#include <stdio.h>
exec sql include sqlca;
exec sql begin declare section;
  char sqlstmt[1024];
  char *MYID= "fedora/oracle";
exec sql end declare section;

void reportError(char* succ, char *fail) {
  printf("%s\n", sqlca.sqlcode == 0 ? succ : fail);
}

void createTable(char* command) {
  strcpy(sqlstmt, command);

  exec sql execute immediate :sqlstmt;
  reportError("Table created", "Table not created");
}

void dropTable(char* tableName) {
  strcpy(sqlstmt, "drop table ");
  strcat(sqlstmt, tableName);
  exec sql execute immediate :sqlstmt;
  reportError("Table dropped", "Table not dropped");
}

void connectDB() {
  exec sql connect :MYID;
  reportError("Connected to ORACLE", "Connect Failed");
}

int main() {
  connectDB();

  exec sql set transaction read write;

  createTable("create table bank (b# char(2) primary key, name varchar2(10) not null, city varchar2(10) not null)");
  createTable("create table customer (c# char(2) primary key, name varchar2(10) not null, age int not null, city varchar2(10) not null)");
  createTable("create table account (c# char(2), b# char(2), balance int not null, primary key(b#, c#), foreign key(b#) references bank(b#) on delete cascade, foreign key(c#) references customer(c#) on delete cascade)");
     
  // dropTable("account");
  // dropTable("bank");
  // dropTable("customer");

  exec sql commit release;
  exit(0);
}
