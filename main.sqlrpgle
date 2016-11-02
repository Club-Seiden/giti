**FREE
Ctl-Opt DftActGrp(*No) ActGrp(*NEW);

//GitLogParse is used to look for all commits
//or for a specific file in the repo.
Dcl-Pr GitLogParse ExtPgm('GITLOGPRSE');
  *N Char(128); //Pass in gFile
End-Pr;

Dcl-S gFile Char(128) Inz('*ALL'); 

//Program will assume CURDIR is repository

//When the program loads we need to make a place to store the git log
EXEC SQL 
  CREATE TABLE QTEMP/GITLOG (
    commit_id   int primary key generated always identity not null,
    commit_hash char(7) not null,
    commit_auth char(64) not null,
    commit_date char(64) not null,
    commit_text char(128) not null
  );

GitLogParse(gFile);

*InLR = *On;
Return;