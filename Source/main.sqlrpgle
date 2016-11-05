**FREE
Ctl-Opt DftActGrp(*No) ActGrp(*NEW);

Dcl-F SCREEN Workstn;

//GitLogParse is used to look for all commits
//or for a specific file in the repo.
Dcl-Pr GitLogParse ExtPgm('GITLOGPRSE');
  *N Char(128); //Pass in gFile
  *N Ind;       //Pass in gValid
End-Pr;

Dcl-Pr GitBranch ExtPgm('GITBRANCH');
  pBranches LikeDS(Branches_Template) Dim(10);
End-Pr;

Dcl-Pr PASE ExtPgm('QP2SHELL2');
  Path   Char(32) Const;
  Script Char(128) Const;
END-PR;

//***************************

Dcl-Ds Branches_Template Qualified Template;
  Name   Char(20);
  Active Ind;
END-DS;

//***************************

Dcl-S  gCmtCnt  Int(5);
Dcl-Ds gCommits Qualified Dim(50);
  Hash   Char(7);
  Author Char(64);
  Date   Char(64);
  Text   Char(128);
End-Ds;

//***************************

Dcl-S gValid Ind       Inz(*On);
Dcl-S gFile  Char(128) Inz('*ALL');
Dcl-S gSQL   Varchar(150);

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
  GitLogParse(gFile:gValid);
ENDIF;

giti_LoadCommits();
giti_LoadScreen();

*InLR = *On;
Return;

//****************************

Dcl-Proc giti_LoadCommits;
  Dcl-S lIndex Int(3);
  Dcl-S lScan  Int(3);

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

  MSG = 'Showing ' + %Char(gCmtCnt) + ' commits.';

  EXEC SQL
    CLOSE Commits;

  For lIndex = 1 to %Elem(gCommits);
    gCommits(lIndex).Date = %Subst(gCommits(lIndex).Date:5:15);
    lScan = %Scan('<':gCommits(lIndex).Author);
    If (lScan > 0);
      gCommits(lIndex).Author = %Subst(gCommits(lIndex).Author:1:lScan-1);
    Endif;
  ENDFOR;

END-PROC;

//****************************

Dcl-Proc giti_LoadScreen;
  Dcl-S lIndex  Int(3)  Inz(1);
  Dcl-S lOptInd Int(3);
  Dcl-S lOpt    Char(2) Dim(15);
  Dcl-S lExit   Ind    Inz(*Off);

  Dow (lExit = *Off);
    ExSR  LoadData;
    EXFMT Main;

    Select;
      When (*In06);
        giti_DisplayBranches();

      When (*In12);
        lExit = *On;

      When (*In44); //Page up
        If (lIndex - 15 < 1);
          MSG = 'Start of data.';
          lIndex = 1;
        Else;
          MSG = *Blank;
          lIndex -= 15;
        ENDIF;

      When (*In66); //Page down
        If ((lIndex + 15) + 15 > gCmtCnt);
          lIndex = gCmtCnt - 15;
          If (lIndex < 1);
            lIndex = 1;
          ENDIF;
          MSG = 'End of data.';
        Else;
          MSG = *Blank;
          lIndex += 15;
        ENDIF;

      Other;
        If (FILE <> gFile);
          gFile = FILE;
          GitLogParse(gFile:gValid);
          If (gValid = *On);
            lIndex = 1;
            giti_LoadCommits();
          Endif;
        Else;
          Exsr ProcessOpt;
        ENDIF;

    ENDSL;

  ENDDO;

  Begsr ProcessOpt;
    lOpt(1)  = IN1;
    lOpt(2)  = IN2;
    lOpt(3)  = IN3;
    lOpt(4)  = IN4;
    lOpt(5)  = IN5;
    lOpt(6)  = IN6;
    lOpt(7)  = IN7;
    lOpt(8)  = IN8;
    lOpt(9)  = IN9;
    lOpt(10) = IN10;
    lOpt(11) = IN11;
    lOpt(12) = IN12;
    lOpt(13) = IN13;
    lOpt(14) = IN14;
    lOpt(15) = IN15;

    For lOptInd = 1 to 15;
      Select;
        When (lOpt(lOptInd) = '5');
          giti_DisplayCommit(gCommits(lIndex + (lOptInd-1)).Hash);
        When (lOpt(lOptInd) = '7');
          giti_ResetToCommit(gCommits(lIndex + (lOptInd-1)).Hash);
      ENDSL;
    ENDFOR;
  ENDSR;

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

    IN1  = *Blank;
    IN2  = *Blank;
    IN3  = *Blank;
    IN4  = *Blank;
    IN5  = *Blank;
    IN6  = *Blank;
    IN7  = *Blank;
    IN8  = *Blank;
    IN9  = *Blank;
    IN10 = *Blank;
    IN11 = *Blank;
    IN12 = *Blank;
    IN13 = *Blank;
    IN14 = *Blank;
    IN15 = *Blank;

    If (USER1 = *Blank);
      IN1 = x'2F';
    ENDIF;
    If (USER2 = *Blank);
      IN2 = x'2F';
    ENDIF;
    If (USER3 = *Blank);
      IN3 = x'2F';
    ENDIF;
    If (USER4 = *Blank);
      IN4 = x'2F';
    ENDIF;
    If (USER5 = *Blank);
      IN5 = x'2F';
    ENDIF;
    If (USER6 = *Blank);
      IN6 = x'2F';
    ENDIF;
    If (USER7 = *Blank);
      IN7 = x'2F';
    ENDIF;
    If (USER8 = *Blank);
      IN8 = x'2F';
    ENDIF;
    If (USER9 = *Blank);
      IN9 = x'2F';
    ENDIF;
    If (USER10 = *Blank);
      IN10 = x'2F';
    ENDIF;
    If (USER11 = *Blank);
      IN11 = x'2F';
    ENDIF;
    If (USER12 = *Blank);
      IN12 = x'2F';
    ENDIF;
    If (USER13 = *Blank);
      IN13 = x'2F';
    ENDIF;
    If (USER14 = *Blank);
      IN14 = x'2F';
    ENDIF;
    If (USER15 = *Blank);
      IN15 = x'2F';
    ENDIF;
  ENDSR;
END-PROC;

//*********************

Dcl-Proc giti_DisplayCommit;
  Dcl-Pi *N;
    pHash Char(7) Const;
  END-PI;

  Dcl-S  lExit   Ind Inz(*Off);
  Dcl-Ds lCommit LikeDS(gCommits);

  EXEC SQL
    SELECT commit_hash, commit_auth, commit_date, commit_text
    INTO :lCommit
    FROM QTEMP/GITLOG
    WHERE commit_hash = :pHash;

  If (SQLSTATE <> '00000');
    MSG = 'Unable to find commit.';
    Return;
  ENDIF;

  CMTHSH  = pHash;
  CMTAUT  = lCommit.Author;
  CMTDTE  = lCommit.Date;
  CMTMSG1 = %Subst(lCommit.Text:1:64);
  CMTMSG2 = %Subst(lCommit.Text:65);

  Dow (lExit = *Off);
    Exfmt CMTDSP;

    Select;
      When (*In12);
        lExit = *On;
      Other;
        //Nothing
    ENDSL;
  ENDDO;
END-PROC;

//**************************

Dcl-Proc giti_DisplayBranches;
  Dcl-Ds lBranches LikeDS(Branches_Template) Dim(10);
  Dcl-S  lExit     Ind     Inz(*Off);
  Dcl-S  lOpt      Char(2) Dim(10);
  Dcl-S  lIndex    Int(3);

  GitBranch(lBranches);
  Dow (lExit = *Off);
    Exsr LoadData;
    Exfmt BRANCHES;

    Select;
      When (*In12);
        lExit = *On;

      Other;
        Exsr CheckInput;
    ENDSL;
  ENDDO;

  Begsr CheckInput;
    lOpt(1)  = BIN1;
    lOpt(2)  = BIN2;
    lOpt(3)  = BIN3;
    lOpt(4)  = BIN4;
    lOpt(5)  = BIN5;
    lOpt(6)  = BIN6;
    lOpt(7)  = BIN7;
    lOpt(8)  = BIN8;
    lOpt(9)  = BIN9;
    lOpt(10) = BIN10;

    If (BIN0 = '5');
      //Create new branch
      If (BNAME0 <> *Blank);
        PASE('/QOpenSys/usr/bin/-sh' + x'00'
             :'git checkout -b ' + %Trim(BNAME0) + x'00');
        lExit = *On;
        Return;
      Endif;
    ENDIF;

    For lIndex = 1 to 10;
      If (lBranches(lIndex).Name = *Blank);
        Iter;
      ENDIF;

      Select;
        When (lOpt(lIndex) = 'D');
          //Delete branch
        When (lOpt(lIndex) = '5');
          PASE('/QOpenSys/usr/bin/-sh' + x'00'
              :'git checkout ' + %TrimR(lBranches(lIndex).Name) + x'00');
          GitLogParse(gFile:gValid);
          giti_LoadCommits();
          lExit = *On;
          Return; //exit proc
      ENDSL;
    ENDFOR;
  ENDSR;

  Begsr LoadData;
    BIN0  = *Blank;
    BIN1  = *Blank;
    BIN2  = *Blank;
    BIN3  = *Blank;
    BIN4  = *Blank;
    BIN5  = *Blank;
    BIN6  = *Blank;
    BIN7  = *Blank;
    BIN8  = *Blank;
    BIN9  = *Blank;
    BIN10 = *Blank;

    BNAME0  = *Blank;
    BNAME1  = lBranches(1).Name;
    BNAME2  = lBranches(2).Name;
    BNAME3  = lBranches(3).Name;
    BNAME4  = lBranches(4).Name;
    BNAME5  = lBranches(5).Name;
    BNAME6  = lBranches(6).Name;
    BNAME7  = lBranches(7).Name;
    BNAME8  = lBranches(8).Name;
    BNAME9  = lBranches(9).Name;
    BNAME10 = lBranches(10).Name;

    BACT1  = *Blank;
    BACT2  = *Blank;
    BACT3  = *Blank;
    BACT4  = *Blank;
    BACT5  = *Blank;
    BACT6  = *Blank;
    BACT8  = *Blank;
    BACT9  = *Blank;
    BACT10 = *Blank;

    If (BNAME1 = *Blank);
      BIN1 = x'2F';
    ENDIF;
    If (BNAME2 = *Blank);
      BIN2 = x'2F';
    ENDIF;
    If (BNAME3 = *Blank);
      BIN3 = x'2F';
    ENDIF;
    If (BNAME4 = *Blank);
      BIN4 = x'2F';
    ENDIF;
    If (BNAME5 = *Blank);
      BIN5 = x'2F';
    ENDIF;
    If (BNAME6 = *Blank);
      BIN6 = x'2F';
    ENDIF;
    If (BNAME7 = *Blank);
      BIN7 = x'2F';
    ENDIF;
    If (BNAME8 = *Blank);
      BIN8 = x'2F';
    ENDIF;
    If (BNAME9 = *Blank);
      BIN9 = x'2F';
    ENDIF;
    If (BNAME10 = *Blank);
      BIN10 = x'2F';
    ENDIF;

    If (lBranches(1).Active);
      BACT1 = '>';
    ENDIF;
    If (lBranches(2).Active);
      BACT2 = '>';
    ENDIF;
    If (lBranches(3).Active);
      BACT3 = '>';
    ENDIF;
    If (lBranches(4).Active);
      BACT4 = '>';
    ENDIF;
    If (lBranches(5).Active);
      BACT5 = '>';
    ENDIF;
    If (lBranches(6).Active);
      BACT6 = '>';
    ENDIF;
    If (lBranches(7).Active);
      BACT7 = '>';
    ENDIF;
    If (lBranches(8).Active);
      BACT8 = '>';
    ENDIF;
    If (lBranches(9).Active);
      BACT9 = '>';
    ENDIF;
    If (lBranches(10).Active);
      BACT10 = '>';
    ENDIF;
  Endsr;
END-PROC;

//******************

Dcl-Proc giti_ResetToCommit;
  Dcl-Pi *N;
    pHash Char(7) Const;
  END-PI;

  PASE('/QOpenSys/usr/bin/-sh' + x'00'
      :'git reset --hard ' + pHash + x'00');

  GitLogParse(gFile:gValid);
  giti_LoadCommits();
END-PROC;