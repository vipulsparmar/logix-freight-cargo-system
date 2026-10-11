**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-f BKGLST workstn extdesc('DEVLIB/BKGLST')
      extfile(*extdesc)
      sfile(BKGLSTSFL:rrn);
dcl-f BOOKINGPF usage(*input:*output:*update) keyed
      extdesc('DEVLIB/BOOKINGPF') extfile(*extdesc)
      rename(BOOKINGPF:BKGREC);

dcl-s rrn      packed(4:0) inz(0);
dcl-s nextNum  packed(4:0) inz(3);
dcl-s newBkId  char(5);

dcl-pr TRKSTG extpgm('DEVLIB/TRKSTG');
  inBkId char(5);
end-pr;
dcl-pr MANIFEST extpgm('DEVLIB/MANIFEST');
  inFltId char(5);
end-pr;

exsr LoadSubfile;

dow not *in03 and not *in12;
  write FOOTER;
  exfmt BKGLSTCTL;

  if *in03 or *in12;
    leave;
  endif;

  if *in05;
    exsr LoadSubfile;
    msgFld = 'Consignments refreshed.';
    iter;
  endif;

  if *in06;
    exsr AddBookingScreen;
    exsr LoadSubfile;
    iter;
  endif;

  readc BKGLSTSFL;
  dow not %eof(BKGLST);
    select;
      when sflOpt = '4'; // Cancel Booking
        chain sflBkId BKGREC;
        if %found(BOOKINGPF);
          bkStatus = 'C';
          bkRemark = 'Cancelled';
          update BKGREC;
          msgFld = 'Consignment ' + %trim(sflBkId) + ' cancelled.';
        endif;

      when sflOpt = '2'; // Edit Booking
        exsr EditBookingScreen;

      when sflOpt = '5'; // Live Milestone Tracking
        callp(e) TRKSTG(sflBkId);
        msgFld = 'Returned from Live Milestone Tracking.';

      when sflOpt = '6'; // Print Linehaul Manifest
        callp(e) MANIFEST(sflFltId);
        msgFld = 'Manifest printed for Linehaul ' + %trim(sflFltId) + '.';
    endsl;

    sflOpt = '';
    update BKGLSTSFL;
    readc BKGLSTSFL;
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
  write BKGLSTCTL;
  *in52 = *off;

  rrn = 0;
  setll *loval BKGREC;
  read BKGREC;

  dow not %eof(BOOKINGPF);
    sflOpt   = '';
    sflBkId  = bkId;
    sflUsrId = usrId;
    sflFltId = fltId;
    monitor;
      sflBkDat = %char(bkDate: *iso);
    on-error;
      sflBkDat = '2026-11-20';
    endmon;
    monitor;
      sflDepDt = %char(bkDepDate: *iso);
    on-error;
      sflDepDt = '2026-11-20';
    endmon;
    sflStat  = bkStatus;
    sflRmk   = bkRemark;

    rrn += 1;
    write BKGLSTSFL;
    read BKGREC;
  enddo;

  if rrn > 0;
    *in50 = *on;
    *in51 = *on;
    *in53 = *on;
  else;
    *in50 = *off;
    *in51 = *on;
    *in53 = *on;
    msgFld = 'No consignments found.';
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: EditBookingScreen
// -------------------------------------------------------------
begsr EditBookingScreen;
  chain sflBkId BKGREC;
  if %found(BOOKINGPF);
    dBkId  = bkId;
    dUsrId = usrId;
    dFltId = fltId;
    monitor;
      dTrvDt = %char(bkDepDate: *iso);
    on-error;
      dTrvDt = '2026-11-20';
    endmon;
    dStat  = bkStatus;
    dRmk   = bkRemark;
    dMsg   = 'Update details and press F6 to Save.';

    dow not *in03 and not *in12;
      exfmt BKGDTLSCR;

      if *in03 or *in12;
        leave;
      endif;

      if *in06;
        chain sflBkId BKGREC;
        if %found(BOOKINGPF);
          usrId    = dUsrId;
          fltId    = dFltId;
          bkStatus = dStat;
          bkRemark = dRmk;
          update BKGREC;
          msgFld = 'Consignment ' + %trim(sflBkId) + ' updated.';
        endif;
        leave;
      endif;
    enddo;
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: ViewBookingScreen
// -------------------------------------------------------------
begsr ViewBookingScreen;
  chain sflBkId BKGREC;
  if %found(BOOKINGPF);
    dBkId  = bkId;
    dUsrId = usrId;
    dFltId = fltId;
    monitor;
      dTrvDt = %char(bkDepDate: *iso);
    on-error;
      dTrvDt = '2026-11-20';
    endmon;
    dStat  = bkStatus;
    dRmk   = bkRemark;
    dMsg   = 'View-only mode. Press F3 or F12 to return.';

    dow not *in03 and not *in12;
      exfmt BKGDTLSCR;
      if *in03 or *in12;
        leave;
      endif;
    enddo;
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: AddBookingScreen
// -------------------------------------------------------------
begsr AddBookingScreen;
  dou not %found(BOOKINGPF);
    newBkId = 'B' + %editc(nextNum: 'X');
    chain newBkId BKGREC;
    if %found(BOOKINGPF);
      nextNum += 1;
    endif;
  enddo;

  dBkId  = newBkId;
  dUsrId = 'U0001';
  dFltId = 'FL001';
  dTrvDt = '2026-11-20';
  dStat  = 'U';
  dRmk   = 'Direct Cargo';
  dMsg   = 'Fill details and press F6 to create.';

  dow not *in03 and not *in12;
    exfmt BKGDTLSCR;

    if *in03 or *in12;
      leave;
    endif;

    if *in06;
      bkId      = newBkId;
      usrId     = dUsrId;
      fltId     = dFltId;
      bkDate    = %date();
      bkDepDate = %date();
      bkStatus  = dStat;
      bkRemark  = dRmk;
      write BKGREC;

      msgFld = 'Consignment ' + %trim(newBkId) + ' created!';
      nextNum += 1;
      leave;
    endif;
  enddo;
endsr;
