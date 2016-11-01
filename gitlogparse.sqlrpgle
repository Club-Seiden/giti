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
  Pgms   Char(20) Const;        
END-PR;          

//************************               

Dcl-C LINE_LEN 128;

Dcl-Ds File_Temp Qualified Template;
 PathFile char(CMD_LEN);
 RtvData  char(CMD_LEN);
 OpenMode char(5);
 FilePtr  pointer inz;
End-ds;

Dcl-Ds gGitLog LikeDS(File_Temp);

//************************

Dcl-S gUser  Char(10) Inz(*User);
Dcl-S gFocus Varchar(128);

gFocus = %Trim(pFile);
If (gFocus = '*ALL');
  gFocus = '';
Endif;

gGitLog.PathFile = '/tmp/' + %TrimR(gUser) + 'git.log';

//Program will assume CURDIR is git repo

PASE('/QOpenSys/usr/bin/-sh' + x'00'               
    :'git log -- ' + gFocus + ' > '
    + %TrimR(gGitLog.PahtFile) + ' 2>&1' + x'00'
    :%Trim(pMbr) + x'00');                 
    
*InLR = *On;
Return;