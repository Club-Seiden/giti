**FREE
Ctl-Opt NoMain;

//************************

dcl-pr OpenFile pointer extproc('_C_IFS_fopen');
 *n pointer value;  //File name
 *n pointer value;  //File mode
end-pr;

dcl-pr ReadFile pointer extproc('_C_IFS_fgets');
 *n pointer value;  //Retrieved data
 *n int(10) value;  //Data size
 *n pointer value;  //Misc pointer
end-pr;

dcl-pr CloseFile extproc('_C_IFS_fclose');
 *n pointer value;  //Misc pointer
end-pr;

Dcl-Pr PASE ExtPgm('QP2SHELL2');
  Path   Char(32) Const;
  Script Char(128) Const;
  //Pgms   Char(20) Const;
END-PR;

//************************

Dcl-C LINE_LEN 128;

Dcl-Ds File_Temp Qualified Template;
 PathFile char(LINE_LEN);
 RtvData  char(LINE_LEN);
 OpenMode char(5);
 FilePtr  pointer inz;
End-ds;

Dcl-S  gRecords Int(5) Inz(0);
Dcl-Ds gGitLog  LikeDS(File_Temp);
Dcl-S  gKey     Char(6);

Dcl-S gIsText Ind;
Dcl-S gText   Varchar(128);

Dcl-Ds gLogEntry Qualified;
  Hash   Char(7);
  Author Char(64);
  Date   Char(64);
  Text   Char(128);
End-Ds;

//************************

Dcl-S gUser  Char(10) Inz(*User);
Dcl-S gFocus Varchar(128);

Dcl-Proc GITLOGPRSE Export;
  Dcl-Pi GITLOGPRSE;
    pFile  Char(128);
    pValid Ind;
  End-Pi;

  gFocus = %Trim(pFile);
  If (gFocus = '*ALL');
    gFocus = '';
  Elseif (gFocus <> '');
    gFocus = ' -- ' + gFocus;
  Endif;

  gGitLog.PathFile = '/tmp/' + %TrimR(gUser) + 'git.log';

  //Program will assume CURDIR is git repo

  //First we need to take the content of GIT LOG into a stream file
  PASE('/QOpenSys/usr/bin/-sh' + x'00'
      :'git --no-pager log ' + gFocus + ' > '
      + %TrimR(gGitLog.PathFile) + ' 2>&1' + x'00');

  //Next we will want to read that stream file
  gGitLog.PathFile    = %TrimR(gGitLog.PathFile) + x'00';
  gGitLog.OpenMode = 'r' + x'00';
  gGitLog.FilePtr  = OpenFile(%addr(gGitLog.PathFile)
                             :%addr(gGitLog.OpenMode));

  If (gGitLog.FilePtr = *Null);
    //Failed to open file
    Return;
  ENDIF;

  gIsText = *Off;
  Log_Clear();

  Dow (ReadFile(%addr(gGitLog.RtvData)
               :%Len(gGitLog.RtvData)
               :gGitLog.FilePtr) <> *null);

    If (%Subst(gGitLog.RtvData:1:1) = x'25');
      gIsText = *On;
      Iter;
    ENDIF;

    gGitLog.RtvData = %xlate(x'00':' ':gGitLog.RtvData);//End of record null
    gGitLog.RtvData = %xlate(x'25':' ':gGitLog.RtvData);//Line feed (LF)
    gGitLog.RtvData = %xlate(x'0D':' ':gGitLog.RtvData);//Carriage return (CR)
    gGitLog.RtvData = %xlate(x'05':' ':gGitLog.RtvData);//Tab

    gKey = %Subst(gGitLog.RtvData:1:6);

    Select;
      When (gKey = 'commit');
        if (gIsText = *On);
          //Last commit finished, write to file?
          gLogEntry.Text = gText;
          Log_Commit();
          Clear gText;
          Clear gLogEntry;
          gIsText = *Off;
        ENDIF;
        gLogEntry.Hash = %Subst(gGitLog.RtvData:8:7);

      When (gKey = 'Author');
        gLogEntry.Author = %Subst(gGitLog.RtvData:9);

      When (gKey = 'Date:');
        gLogEntry.Date = %Subst(gGitLog.RtvData:9);

      When (gGitLog.RtvData = *Blank);
        gIsText = *On;

      Other;
        If (gIsText);
          gText += %Trim(gGitLog.RtvData) + ' ';
        ENDIF;

    ENDSL;

    gGitLog.RtvData = '';
  Enddo;

  CloseFile(gGitLog.FilePtr);

  If (gRecords = 0);
    pValid = *Off;
    showMessage('The file you provided may be invalid.');
  Else;
    pValid = *On;
  ENDIF;

  *InLR = *On;
  Return;
End-Proc;

Dcl-Proc Log_Clear;
  EXEC SQL
    DELETE FROM QTEMP/GITLOG;
END-PROC;

Dcl-Proc Log_Commit;
  EXEC SQL
    INSERT INTO QTEMP/GITLOG (
      commit_hash, commit_auth, commit_date, commit_text
    ) values (
      :gLogEntry.Hash,
      :gLogEntry.Author,
      :gLogEntry.Date,
      :gLogEntry.Text
    );

  gRecords += 1;
END-PROC;

//**************

Dcl-Proc showMessage;
  Dcl-Pi showMessage;
    Text Varchar(8192) Const;
  END-PI;

  Dcl-DS ErrCode;
    BytesIn  Int(10) Inz(0);
    BytesOut Int(10) Inz(0);
  END-DS;

  Dcl-PR QUILNGTX ExtPgm('QUILNGTX');
    MsgText     Char(8192)    Const;
    MsgLength   Int(10)       Const;
    MessageId   Char(7)       Const;
    MessageFile Char(21)      Const;
    dsErrCode   Like(ErrCode);
  END-PR;

  QUILNGTX(Text:%Len(Text):
     '':'':
     ErrCode);

  Return;
END-PROC;