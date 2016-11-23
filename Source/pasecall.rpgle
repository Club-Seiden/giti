**FREE

Ctl-Opt NoMain;

Dcl-S gWithPath Ind Inz(*ON);

Dcl-Pr PASECall ExtPgm('QP2SHELL2');
  Path   Char(32) Const;
  Script Char(1024) Const;
END-PR;

Dcl-Proc giti_PaseCall Export;
  Dcl-Pi *N;
    pCommand Char(1024) Const;
  END-PI;

  Dcl-S lCmd Varchar(1024);

  lCmd = %Trim(pCommand);

  If (gWithPath);
     lCmd = 'export PATH='
          + '/QOpenSys/usr/bin:'
          + '/usr/ccs/bin:'
          + '/QOpenSys/usr/bin/X11:'
          + '/usr/sbin:'
          + '.:'
          + '/usr/bin & '
          + lCmd;

  ENDIF;

  lCmd += x'00';

  PASECall('/QOpenSys/usr/bin/-sh' + x'00'
          : lCmd);
END-PROC;