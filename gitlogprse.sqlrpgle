**FREE
Ctl-Opt DftActGrp(*No) ActGrp(*NEW);

Dcl-Pi GITLOGPRSE;
  pFile Char(128);
End-Pi;

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

Dcl-Ds gGitLog LikeDS(File_Temp);

Dcl-S gisText Ind;
Dcl-Ds gLogEntry Qualified;
  Hash   Char(7);
  Author Char(64);
  Date   Char(64);
  Text   Char(128);
End-Ds;

//************************

Dcl-S gUser  Char(10) Inz(*User);
Dcl-S gFocus Varchar(128);

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

//Loop through file and parse it and fille gLogEntry

EXEC SQL
  INSERT INTO QTEMP/GITLOG (
    commit_hash, commit_auth, commit_date, commit_text
  ) values (
    :gGitLog.Hash,
    :gGitLog.Author,
    :gGitLog.Date,
    :gGitLog.Text
  );

*InLR = *On;
Return;