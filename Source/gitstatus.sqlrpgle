**FREE
Ctl-Opt NoMain;

Dcl-Ds Changes_Template Qualified Template;
  Type Char(8);
  File Char(30);
End-Ds;

//**********************************

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

//********************************

Dcl-C LINE_LEN 32;

Dcl-Ds File_Temp Qualified Template;
 PathFile char(LINE_LEN);
 RtvData  char(LINE_LEN);
 OpenMode char(5);
 FilePtr  pointer inz;
End-ds;

Dcl-Ds gStatusFile LikeDS(File_Temp);

//***************************

Dcl-S gUser  Char(10) Inz(*User);
Dcl-S gIndex Int(3) Inz(1);

Dcl-Proc GITSTATUS Export;
  Dcl-Pi GitStatus;
    pChanges LikeDS(Changes_Template) Dim(9);
  End-Pi;

  gStatusFile.PathFile = '/tmp/' + %TrimR(gUser) + 'brnch.log';
  PASE('/QOpenSys/usr/bin/-sh' + x'00'
      :'git status -s > '
      + %TrimR(gStatusFile.PathFile) + ' 2>&1' + x'00');

  //Next we will want to read that stream file
  gStatusFile.PathFile    = %TrimR(gStatusFile.PathFile) + x'00';
  gStatusFile.OpenMode = 'r' + x'00';
  gStatusFile.FilePtr  = OpenFile(%addr(gStatusFile.PathFile)
                                :%addr(gStatusFile.OpenMode));

  If (gStatusFile.FilePtr = *Null);
    //File didn't open?
    Return;
  ENDIF;

  gIndex = 1;
  Dow (ReadFile(%addr(gStatusFile.RtvData)
               :%Len(gStatusFile.RtvData)
               :gStatusFile.FilePtr) <> *null);

    If (gIndex > %Elem(pChanges));
      Iter;
    Endif;
    
    gStatusFile.RtvData = %xlate(x'00':' ':gStatusFile.RtvData);//End of record null
    gStatusFile.RtvData = %xlate(x'25':' ':gStatusFile.RtvData);//Line feed (LF)
    gStatusFile.RtvData = %xlate(x'0D':' ':gStatusFile.RtvData);//Carriage return (CR)
    gStatusFile.RtvData = %xlate(x'05':' ':gStatusFile.RtvData);//Tab

    pChanges(gIndex).Type = %Subst(gStatusFile.RtvData:2:1);
    pChanges(gIndex).File = %Subst(gStatusFile.RtvData:4);
    
    gIndex += 1;

    gStatusFile.RtvData = '';
  Enddo;

  CloseFile(gStatusFile.FilePtr);

  Return;
End-Proc;