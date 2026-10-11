**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-f CUSLST workstn extdesc('DEVLIB/CUSLST')
      extfile(*extdesc)
      sfile(CUSLSTSFL:rrn);
dcl-f USERMASTER usage(*input:*output:*update) keyed
      extdesc('DEVLIB/USERMASTER') extfile(*extdesc)
      rename(USERMASTER:USERREC);
dcl-f LOGINPF usage(*input:*output) keyed
      extdesc('DEVLIB/LOGINPF') extfile(*extdesc)
      rename(LOGINPF:LOGINREC);

dcl-s rrn       packed(4:0) inz(0);
dcl-s nextNum   packed(4:0) inz(4);
dcl-s newCusId  char(5);

exsr LoadSubfile;

dow not *in03 and not *in12;
  write FOOTER;
  exfmt CUSLSTCTL;

  if *in03 or *in12;
    leave;
  endif;

  if *in05;
    exsr LoadSubfile;
    msgFld = 'Shippers refreshed.';
    iter;
  endif;

  if *in06;
    exsr AddCustomerScreen;
    exsr LoadSubfile;
    iter;
  endif;

  readc CUSLSTSFL;
  dow not %eof(CUSLST);
    select;
      when sflOpt = '4'; // Deactivate Customer
        chain sflId USERREC;
        if %found(USERMASTER);
          usrStatus = 'I';
          usrRemark = 'Deactivated';
          update USERREC;
          msgFld = 'Shipper ' + %trim(sflId) + ' deactivated.';
        endif;

      when sflOpt = '2'; // Edit Customer
        exsr EditCustomerScreen;

      when sflOpt = '5'; // View Customer
        exsr ViewCustomerScreen;
    endsl;

    sflOpt = '';
    update CUSLSTSFL;
    readc CUSLSTSFL;
  enddo;

  exsr LoadSubfile;
enddo;

*inlr = *on;
return;

// -------------------------------------------------------------
// Subroutine: LoadSubfile
// -------------------------------------------------------------
begsr LoadSubfile;
  *in52 = *on;
  *in50 = *off;
  write CUSLSTCTL;
  *in52 = *off;

  rrn = 0;
  setll *loval USERREC;
  read USERREC;

  dow not %eof(USERMASTER);
    sflOpt  = '';
    sflId   = usrId;
    sflName = usrName;
    sflCity = usrCity;
    sflSte  = usrState;
    sflMob  = usrMobNum;
    sflStat = usrStatus;
    sflRmk  = usrRemark;

    rrn += 1;
    write CUSLSTSFL;
    read USERREC;
  enddo;

  if rrn > 0;
    *in50 = *on;
    *in51 = *on;
    *in53 = *on;
  else;
    *in50 = *off;
    *in51 = *on;
    *in53 = *on;
    msgFld = 'No shippers found.';
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: EditCustomerScreen
// -------------------------------------------------------------
begsr EditCustomerScreen;
  chain sflId USERREC;
  if %found(USERMASTER);
    dUsrId = usrId;
    dName  = usrName;
    dMob   = usrMobNum;
    dEml   = usrEmail;
    dCty   = usrCity;
    dSte   = usrState;
    dPin   = usrPinCode;
    dStat  = usrStatus;
    dRmk   = usrRemark;
    dMsg   = 'Update details and press F6 to Save.';

    dow not *in03 and not *in12;
      exfmt CUSDTLSCR;

      if *in03 or *in12;
        leave;
      endif;

      if *in06;
        chain sflId USERREC;
        if %found(USERMASTER);
          usrName    = dName;
          usrMobNum  = dMob;
          usrEmail   = dEml;
          usrCity    = dCty;
          usrState   = dSte;
          usrPinCode = dPin;
          usrStatus  = dStat;
          usrRemark  = dRmk;
          update USERREC;
          msgFld = 'Shipper ' + %trim(sflId) + ' updated.';
        endif;
        leave;
      endif;
    enddo;
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: ViewCustomerScreen
// -------------------------------------------------------------
begsr ViewCustomerScreen;
  chain sflId USERREC;
  if %found(USERMASTER);
    dUsrId = usrId;
    dName  = usrName;
    dMob   = usrMobNum;
    dEml   = usrEmail;
    dCty   = usrCity;
    dSte   = usrState;
    dPin   = usrPinCode;
    dStat  = usrStatus;
    dRmk   = usrRemark;
    dMsg   = 'View-only mode. Press F3 or F12 to return.';

    dow not *in03 and not *in12;
      exfmt CUSDTLSCR;
      if *in03 or *in12;
        leave;
      endif;
    enddo;
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: AddCustomerScreen
// -------------------------------------------------------------
begsr AddCustomerScreen;
  dou not %found(USERMASTER);
    newCusId = 'U' + %editc(nextNum: 'X');
    chain newCusId USERREC;
    if %found(USERMASTER);
      nextNum += 1;
    endif;
  enddo;

  dUsrId = newCusId;
  dName  = '';
  dMob   = '';
  dEml   = '';
  dCty   = '';
  dSte   = '';
  dPin   = 0;
  dStat  = 'A';
  dRmk   = 'New Shipper';
  dMsg   = 'Fill details and press F6 to create.';

  dow not *in03 and not *in12;
    exfmt CUSDTLSCR;

    if *in03 or *in12;
      leave;
    endif;

    if *in06;
      if %trim(dName) = '';
        dMsg = 'Company Name is required.';
        iter;
      endif;

      usrId      = newCusId;
      usrName    = dName;
      usrDOB     = %date();
      usrGender  = 'C';
      usrMobNum  = dMob;
      usrEmail   = dEml;
      usrCity    = dCty;
      usrPinCode = dPin;
      usrState   = dSte;
      usrAddress = '';
      usrAadhar  = 0;
      usrStatus  = dStat;
      usrRemark  = dRmk;
      write USERREC;

      userId    = newCusId;
      userPass  = '123';
      userRole  = 'Customer';
      lastLogin = %date();
      userQstn  = 'City';
      userAnswr = dCty;
      status    = 'A';
      remark    = 'Active Shipper';
      write LOGINREC;

      msgFld = 'Shipper ' + %trim(newCusId) + ' created!';
      nextNum += 1;
      leave;
    endif;
  enddo;
endsr;
