**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-f AIRLST workstn extdesc('DEVLIB/AIRLST')
      extfile(*extdesc)
      sfile(AIRLSTSFL:rrn);
dcl-f AIRMASTER usage(*input:*output:*update) keyed
      extdesc('DEVLIB/AIRMASTER') extfile(*extdesc)
      rename(AIRMASTER:AIRREC);

dcl-s rrn      packed(4:0) inz(0);
dcl-s nextNum  packed(4:0) inz(5);
dcl-s newAirId char(5);

exsr LoadSubfile;

dow not *in03 and not *in12;
  write FOOTER;
  exfmt AIRLSTCTL;

  if *in03 or *in12;
    leave;
  endif;

  if *in05;
    exsr LoadSubfile;
    msgFld = 'Freight Carriers refreshed.';
    iter;
  endif;

  if *in06;
    exsr AddAirlineScreen;
    exsr LoadSubfile;
    iter;
  endif;

  readc AIRLSTSFL;
  dow not %eof(AIRLST);
    select;
      when sflOpt = '4'; // Deactivate Airline
        chain sflId AIRREC;
        if %found(AIRMASTER);
          airStatus = 'I';
          airRemark = 'Inactive';
          update AIRREC;
          msgFld = 'Carrier ' + %trim(sflId) + ' deactivated.';
        endif;

      when sflOpt = '2'; // Edit Airline
        exsr EditAirlineScreen;

      when sflOpt = '5'; // View Airline Details
        exsr ViewAirlineScreen;
    endsl;

    sflOpt = '';
    update AIRLSTSFL;
    readc AIRLSTSFL;
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
  write AIRLSTCTL;
  *in52 = *off;

  rrn = 0;
  setll *loval AIRREC;
  read AIRREC;

  dow not %eof(AIRMASTER);
    sflOpt   = '';
    sflId    = airId;
    sflName  = airName;
    sflCity  = airCity;
    sflFleet = airFleet;
    sflRate  = airRating;
    sflStat  = airStatus;
    sflRmk   = airRemark;

    rrn += 1;
    write AIRLSTSFL;
    read AIRREC;
  enddo;

  if rrn > 0;
    *in50 = *on;
    *in51 = *on;
    *in53 = *on;
  else;
    *in50 = *off;
    *in51 = *on;
    *in53 = *on;
    msgFld = 'No carriers found.';
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: EditAirlineScreen
// -------------------------------------------------------------
begsr EditAirlineScreen;
  chain sflId AIRREC;
  if %found(AIRMASTER);
    dAirId = airId;
    dAirNm = airName;
    dMob   = airMobNum;
    dEml   = airEmail;
    dCty   = airCity;
    dSte   = airState;
    dFlt   = airFleet;
    dRate  = airRating;
    dStat  = airStatus;
    dRmk   = airRemark;
    dMsg   = 'Edit fields and press F6 to update carrier.';

    dow not *in03 and not *in12;
      exfmt AIRDTLSCR;
      if *in03 or *in12;
        leave;
      endif;

      if *in06;
        airName    = dAirNm;
        airMobNum  = dMob;
        airEmail   = dEml;
        airCity    = dCty;
        airState   = dSte;
        airFleet   = dFlt;
        airRating  = dRate;
        airStatus  = dStat;
        airRemark  = dRmk;
        update AIRREC;
        msgFld = 'Carrier ' + %trim(dAirId) + ' updated successfully.';
        leave;
      endif;
    enddo;
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: ViewAirlineScreen
// -------------------------------------------------------------
begsr ViewAirlineScreen;
  chain sflId AIRREC;
  if %found(AIRMASTER);
    dAirId = airId;
    dAirNm = airName;
    dMob   = airMobNum;
    dEml   = airEmail;
    dCty   = airCity;
    dSte   = airState;
    dFlt   = airFleet;
    dRate  = airRating;
    dStat  = airStatus;
    dRmk   = airRemark;
    dMsg   = 'Press F12 to return to directory.';

    dow not *in03 and not *in12;
      exfmt AIRDTLSCR;
      if *in03 or *in12;
        leave;
      endif;
    enddo;
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: AddAirlineScreen
// -------------------------------------------------------------
begsr AddAirlineScreen;
  dou not %found(AIRMASTER);
    newAirId = 'A' + %editc(nextNum: 'X');
    chain newAirId AIRREC;
    if %found(AIRMASTER);
      nextNum += 1;
    endif;
  enddo;

  dAirId = newAirId;
  dAirNm = '';
  dMob   = '9876543210';
  dEml   = 'ops@carrier.com';
  dCty   = 'Mumbai';
  dSte   = 'Maharashtra';
  dFlt   = 25;
  dRate  = 4.00;
  dStat  = 'A';
  dRmk   = 'Active';
  dMsg   = 'Enter new Carrier Name and press F6 to Register.';

  dow not *in03 and not *in12;
    exfmt AIRDTLSCR;
    if *in03 or *in12;
      leave;
    endif;

    if *in06;
      if %trim(dAirNm) = '';
        dMsg = 'Airline Name is required!';
        iter;
      endif;

      airId      = dAirId;
      airName    = dAirNm;
      airMobNum  = dMob;
      airEmail   = dEml;
      airCity    = dCty;
      airPinCode = 400001;
      airState   = dSte;
      airAddress = 'Airport Terminal';
      airFleet   = dFlt;
      airEstDate = %date();
      airRating  = dRate;
      airStatus  = dStat;
      airRemark  = dRmk;
      write AIRREC;
      msgFld = 'Airline ' + %trim(dAirId) + ' created successfully.';
      leave;
    endif;
  enddo;
endsr;
