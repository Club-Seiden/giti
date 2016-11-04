**FREE
Ctl-Opt DftActGrp(*No) ActGrp(*NEW);

Dcl-Ds Branches_Template Qualified Template;
  Name   Char(20);
  Active Ind;
END-DS;

Dcl-Pi GITBRANCH;
  pBranches LikeDS(Branches_Template) Dim(10);
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
END-PR;

//************************

Dcl-C LINE_LEN 32;

Dcl-Ds File_Temp Qualified Template;
 PathFile char(LINE_LEN);
 RtvData  char(LINE_LEN);
 OpenMode char(5);
 FilePtr  pointer inz;
End-ds;

Dcl-Ds gBrnchFile LikeDS(File_Temp);

//***********************

Dcl-S gUser  Char(10) Inz(*User);
Dcl-S gIndex Int(3) Inz(1);

gBrnchFile.PathFile = '/tmp/' + %TrimR(gUser) + 'brnch.log';
PASE('/QOpenSys/usr/bin/-sh' + x'00'
    :'git branch --list > '
    + %TrimR(gBrnchFile.PathFile) + ' 2>&1' + x'00');

//Next we will want to read that stream file
gBrnchFile.PathFile    = %TrimR(gBrnchFile.PathFile) + x'00';
gBrnchFile.OpenMode = 'r' + x'00';
gBrnchFile.FilePtr  = OpenFile(%addr(gBrnchFile.PathFile)
                              :%addr(gBrnchFile.OpenMode));

If (gBrnchFile.FilePtr = *Null);
  //File didn't open?
  Return;
ENDIF;

gIndex = 1;
Dow (ReadFile(%addr(gBrnchFile.RtvData)
             :%Len(gBrnchFile.RtvData)
             :gBrnchFile.FilePtr) <> *null);

  If (%Subst(gBrnchFile.RtvData:1:1) = '*');
    pBranches(gIndex).Active = *On;
  Else;
    pBranches(gIndex).Active = *Off;
  ENDIF;

  pBranches(gIndex).Name = %Subst(pBranches(gIndex).Name:3);
  gIndex += 1;

  gBrnchFile.RtvData = '';
Enddo;

CloseFile(gBrnchFile.FilePtr);

*InLR = *On;
Return;
