**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-f REGIS workstn extdesc('DEVLIB/REGIS')
      extfile(*extdesc);
dcl-f USERMASTER usage(*input:*output) keyed
      extdesc('DEVLIB/USERMASTER') extfile(*extdesc)
      rename(USERMASTER:USERREC);
dcl-f LOGINPF usage(*input:*output) keyed
      extdesc('DEVLIB/LOGINPF') extfile(*extdesc)
      rename(LOGINPF:LOGINREC);

dcl-pr WNDLKP extpgm('DEVLIB/WNDLKP');
  inCategory char(10) const;
  outVal     char(10);
end-pr;

dcl-s nextNum packed(4:0) inz(4);
dcl-s newId   char(5);
dcl-s lkpVal  char(10);
dcl-s lkpCat  char(10) inz('State');

// Find first available User ID (e.g. U0004)
dou not %found(LOGINPF);
  newId = 'U' + %editc(nextNum: 'X');
  chain newId LOGINPF;
  if %found(LOGINPF);
    nextNum += 1;
  endif;
enddo;

dspId   = newId;
dspGnd  = 'C';
msgFld  = 'Fill company details and press F6 to Register.';

dow not *in03 and not *in12;
  exfmt REGISSCR;

  if *in03 or *in12;
    leave;
  endif;

  // F5 = Reset/Refresh
  if *in05;
    dspName = '';
    dspDob  = 0;
    dspMob  = '';
    dspAad  = '';
    dspEml  = '';
    dspCty  = '';
    dspPin  = 0;
    dspSte  = '';
    dspAdd  = '';
    dspPass = '';
    msgFld  = 'Screen refreshed.';
    iter;
  endif;

  // F4 = Window Lookup for State
  if *in04;
    lkpCat = 'State';
    callp(e) WNDLKP(lkpCat: lkpVal);
    if not %error and lkpVal <> '';
      dspSte = lkpVal;
      msgFld = 'Selected State: ' + %trim(dspSte);
    else;
      msgFld = 'Gender: M/F. State: RJ, DL, MH. Date: YYYYMMDD';
    endif;
    iter;
  endif;

  // F6 = Register
  if *in06;
    if %trim(dspName) = '' or %trim(dspPass) = '';
      msgFld = 'Company Name and Password are required.';
      iter;
    endif;

    if %len(%trim(dspMob)) < 10;
      msgFld = 'Mobile must be 10 digits.';
      iter;
    endif;

    // Check if user already exists
    chain dspId LOGINPF;
    if %found(LOGINPF);
      msgFld = 'User ID already exists. Aborted.';
      iter;
    endif;

    // Populate and write USERMASTER record
    usrId      = dspId;
    usrName    = dspName;
    if dspDob > 19000101;
      monitor;
        usrDOB = %date(dspDob: *iso);
      on-error;
        usrDOB = %date();
      endmon;
    else;
      usrDOB = %date();
    endif;
    usrGender  = dspGnd;
    usrMobNum  = dspMob;
    usrEmail   = dspEml;
    usrCity    = dspCty;
    usrPinCode = dspPin;
    usrState   = dspSte;
    usrAddress = dspAdd;
    if %trim(dspAad) <> '';
      monitor;
        usrAadhar = %dec(%trim(dspAad): 12: 0);
      on-error;
        usrAadhar = 0;
      endmon;
    else;
      usrAadhar = 0;
    endif;
    usrStatus  = 'A';
    usrRemark  = 'Corp Shipper';
    write USERREC;

    // Populate and write LOGINPF record
    userId    = dspId;
    userPass  = dspPass;
    userRole  = 'Customer';
    lastLogin = %date();
    userQstn  = 'First Hub?';
    userAnswr = 'Pune Hub';
    status    = 'A';
    remark    = 'Active Shipper';
    write LOGINREC;

    msgFld = 'Shipper ' + %trim(dspId) + ' Onboarded! Press F12.';
  endif;
enddo;

*inlr = *on;
return;
