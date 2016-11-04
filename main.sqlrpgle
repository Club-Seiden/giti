**FREE
Ctl-Opt DftActGrp(*No) ActGrp(*NEW);

Dcl-F SCREEN Workstn;

//GitLogParse is used to look for all commits
//or for a specific file in the repo.
Dcl-Pr GitLogParse ExtPgm('GITLOGPRSE');
  *N Char(128); //Pass in gFile
End-Pr;

Dcl-S  gCmtCnt  Int(5);
Dcl-Ds gCommits Qualified Dim(50);
  Hash   Char(7);
  Author Char(64);
  Date   Char(64);
  Text   Char(128);
End-Ds;

Dcl-S gFile Char(128) Inz('*ALL');
Dcl-S gSQL  Varchar(150);

//Program will assume CURDIR is repository
FILE = gFile;

//When the program loads we need to make a place to store the git log
EXEC SQL
  CREATE TABLE QTEMP/GITLOG (
    commit_id   int generated always as identity not null,
    commit_hash char(7) not null,
    commit_auth char(64) not null,
    commit_date char(64) not null,
    commit_text char(128) not null
  );

If (SQLSTATE = '00000');
  GitLogParse(gFile);
ENDIF;

giti_LoadCommits();
giti_LoadScreen();

*InLR = *On;
Return;

//****************************

Dcl-Proc giti_LoadCommits;
  Dcl-S lIndex Int(3);

  Clear gCommits;

  EXEC SQL
    DECLARE Commits CURSOR FOR
      SELECT commit_hash, commit_auth, commit_date, commit_text
      FROM QTEMP/GITLOG;

  EXEC SQL
    OPEN Commits;

  EXEC SQL
    FETCH NEXT FROM Commits
    FOR 50 ROWS
    INTO :gCommits;

  gCmtCnt = SQLER3;
  If (gCmtCnt > %Elem(gCommits));
    gCmtCnt = %Elem(gCommits);
  ENDIF;

  EXEC SQL
    CLOSE Commits;

  For lIndex = 1 to %Elem(gCommits);
    gCommits(lIndex).Date = %Subst(gCommits(lIndex).Date:5:15);
    gCommits(lIndex).Author = %Subst(gCommits(lIndex).Author:1:%Scan('<':gCommits(lIndex).Author)-1);
  ENDFOR;

END-PROC;

//****************************

Dcl-Proc giti_LoadScreen;
  Dcl-S lIndex Int(3) Inz(1);
  Dcl-S lExit  Ind    Inz(*Off);

  Dow (lExit = *Off);
    ExSR  LoadData;
    EXFMT Main;

    Select;
      When (*In12);
        lExit = *On;

      When (*In44); //Page up
        If (lIndex - 15 < 1);
          MSG = 'Start of data';
          lIndex = 1;
        Else;
          MSG = *Blank;
          lIndex -= 15;
        ENDIF;

      When (*In66); //Page down
        If ((lIndex + 15) + 15 > gCmtCnt);
          lIndex = gCmtCnt - 15;
          MSG = 'End of data';
        Else;
          MSG = *Blank;
          lIndex += 15;
        ENDIF;

      Other;
        If (FILE <> gFile);
          gFile = FILE;
          GitLogParse(gFile);
          lIndex = 1;
          giti_LoadCommits();
        ENDIF;


    ENDSL;

  ENDDO;

  Begsr LoadData;
    USER1  = gCommits(lIndex).Author;
    USER2  = gCommits(lIndex+1).Author;
    USER3  = gCommits(lIndex+2).Author;
    USER4  = gCommits(lIndex+3).Author;
    USER5  = gCommits(lIndex+4).Author;
    USER6  = gCommits(lIndex+5).Author;
    USER7  = gCommits(lIndex+6).Author;
    USER8  = gCommits(lIndex+7).Author;
    USER9  = gCommits(lIndex+8).Author;
    USER10 = gCommits(lIndex+9).Author;
    USER11 = gCommits(lIndex+10).Author;
    USER12 = gCommits(lIndex+11).Author;
    USER13 = gCommits(lIndex+12).Author;
    USER14 = gCommits(lIndex+13).Author;
    USER15 = gCommits(lIndex+14).Author;

    DATE1  = gCommits(lIndex).Date;
    DATE2  = gCommits(lIndex+1).Date;
    DATE3  = gCommits(lIndex+2).Date;
    DATE4  = gCommits(lIndex+3).Date;
    DATE5  = gCommits(lIndex+4).Date;
    DATE6  = gCommits(lIndex+5).Date;
    DATE7  = gCommits(lIndex+6).Date;
    DATE8  = gCommits(lIndex+7).Date;
    DATE9  = gCommits(lIndex+8).Date;
    DATE10 = gCommits(lIndex+9).Date;
    DATE11 = gCommits(lIndex+10).Date;
    DATE12 = gCommits(lIndex+11).Date;
    DATE13 = gCommits(lIndex+12).Date;
    DATE14 = gCommits(lIndex+13).Date;
    DATE15 = gCommits(lIndex+14).Date;

    MSG1  = gCommits(lIndex).Text;
    MSG2  = gCommits(lIndex+1).Text;
    MSG3  = gCommits(lIndex+2).Text;
    MSG4  = gCommits(lIndex+3).Text;
    MSG5  = gCommits(lIndex+4).Text;
    MSG6  = gCommits(lIndex+5).Text;
    MSG7  = gCommits(lIndex+6).Text;
    MSG8  = gCommits(lIndex+7).Text;
    MSG9  = gCommits(lIndex+8).Text;
    MSG10 = gCommits(lIndex+9).Text;
    MSG11 = gCommits(lIndex+10).Text;
    MSG12 = gCommits(lIndex+11).Text;
    MSG13 = gCommits(lIndex+12).Text;
    MSG14 = gCommits(lIndex+13).Text;
    MSG15 = gCommits(lIndex+14).Text;
  ENDSR;
END-PROC;