**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-f FLTLST workstn extdesc('DEVLIB/FLTLST')
      extfile(*extdesc)
      sfile(FLTLSTSFL:rrn);
dcl-f FLIGHTPF usage(*input:*output:*update) keyed
      extdesc('DEVLIB/FLIGHTPF') extfile(*extdesc)
      rename(FLIGHTPF:FLTREC);

dcl-s rrn      packed(4:0) inz(0);
dcl-s nextNum  packed(4:0) inz(4);
dcl-s newFltId char(5);
dcl-s isEdit   ind inz(*off);

exsr LoadSubfile;

dow not *in03 and not *in12;
  write FOOTER;
  exfmt FLTLSTCTL;

  if *in03 or *in12;
    leave;
  endif;

  // F5 = Refresh Subfile
  if *in05;
    exsr LoadSubfile;
    msgFld = 'Freight linehauls refreshed.';
    iter;
  endif;

  // F6 = Add New Flight
  if *in06;
    exsr AddFlightScreen;
    exsr LoadSubfile;
    iter;
  endif;

  // Process selected subfile records
  readc FLTLSTSFL;
  dow not %eof(FLTLST);
    select;
      when sflOpt = '4'; // Cancel Flight
        chain sflFltId FLTREC;
        if %found(FLIGHTPF);
          fltStatus = 'C';
          fltRemark = 'Cancelled';
          update FLTREC;
          msgFld = 'Linehaul ' + %trim(sflFltId) + ' marked as Cancelled.';
        endif;

      when sflOpt = '2'; // Edit Flight
        exsr EditFlightScreen;

      when sflOpt = '5'; // View Flight Details
        exsr ViewFlightScreen;
    endsl;

    sflOpt = '';
    update FLTLSTSFL;
    readc FLTLSTSFL;
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
  write FLTLSTCTL;
  *in52 = *off;

  rrn = 0;
  setll *loval FLTREC;
  read FLTREC;

  dow not %eof(FLIGHTPF);
    sflOpt   = '';
    sflFltId = fltId;
    sflAirId = airId;
    sflOrig  = fltOrigin;
    sflDest  = fltDest;
    sflPrice = fltTkPrice;
    sflSeat  = fltTotSeat;
    sflStat  = fltStatus;
    sflRmk   = fltRemark;

    rrn += 1;
    write FLTLSTSFL;
    read FLTREC;
  enddo;

  if rrn > 0;
    *in50 = *on;
    *in51 = *on;
    *in53 = *on;
  else;
    *in50 = *off;
    *in51 = *on;
    *in53 = *on;
    msgFld = 'No freight linehauls found in database.';
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: EditFlightScreen
// -------------------------------------------------------------
begsr EditFlightScreen;
  chain sflFltId FLTREC;
  if %found(FLIGHTPF);
    dFltId = fltId;
    dAirId = airId;
    dOrig  = fltOrigin;
    dDest  = fltDest;
    dPrice = fltTkPrice;
    dSeat  = fltTotSeat;
    dStat  = fltStatus;
    dRmk   = fltRemark;
    dMsg   = 'Edit linehaul fields and press F6 to update.';

    dow not *in03 and not *in12;
      exfmt FLTDTLSCR;
      if *in03 or *in12;
        leave;
      endif;

      if *in06; // Save Update
        fltOrigin  = dOrig;
        fltDest    = dDest;
        fltTkPrice = dPrice;
        fltTotSeat = dSeat;
        fltStatus  = dStat;
        fltRemark  = dRmk;
        update FLTREC;
        msgFld = 'Linehaul ' + %trim(dFltId) + ' updated successfully.';
        leave;
      endif;
    enddo;
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: ViewFlightScreen
// -------------------------------------------------------------
begsr ViewFlightScreen;
  chain sflFltId FLTREC;
  if %found(FLIGHTPF);
    dFltId = fltId;
    dAirId = airId;
    dOrig  = fltOrigin;
    dDest  = fltDest;
    dPrice = fltTkPrice;
    dSeat  = fltTotSeat;
    dStat  = fltStatus;
    dRmk   = fltRemark;
    dMsg   = 'Press F12 to return to linehaul directory.';

    dow not *in03 and not *in12;
      exfmt FLTDTLSCR;
      if *in03 or *in12;
        leave;
      endif;
    enddo;
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: AddFlightScreen
// -------------------------------------------------------------
begsr AddFlightScreen;
  // Determine next flight ID
  dou not %found(FLIGHTPF);
    newFltId = 'F' + %editc(nextNum: 'X');
    chain newFltId FLTREC;
    if %found(FLIGHTPF);
      nextNum += 1;
    endif;
  enddo;

  dFltId = newFltId;
  dAirId = 'A0001';
  dOrig  = 'Delhi';
  dDest  = 'Mumbai';
  dPrice = 45;
  dSeat  = 200;
  dStat  = 'A';
  dRmk   = 'On Time';
  dMsg   = 'Fill linehaul route details and press F6 to Save.';

  dow not *in03 and not *in12;
    exfmt FLTDTLSCR;
    if *in03 or *in12;
      leave;
    endif;

    if *in06;
      fltId      = dFltId;
      airId      = dAirId;
      fltOrigin  = dOrig;
      fltDest    = dDest;
      fltTkPrice = dPrice;
      fltTotSeat = dSeat;
      fltStatus  = dStat;
      fltRemark  = dRmk;
      fltRange   = 10000;
      fltFuelCap = 200000;
      airModel   = '20TR';
      write FLTREC;
      msgFld = 'Linehaul ' + %trim(dFltId) + ' scheduled successfully.';
      leave;
    endif;
  enddo;
endsr;
