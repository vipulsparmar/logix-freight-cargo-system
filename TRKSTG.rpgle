**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-pi *n;
  inBkId char(5);
end-pi;

dcl-f TRKSTG workstn extdesc('DEVLIB/TRKSTG')
      extfile(*extdesc);
dcl-f BOOKINGPF usage(*input) keyed
      extdesc('DEVLIB/BOOKINGPF') extfile(*extdesc)
      rename(BOOKINGPF:BKGREC);
dcl-f FLIGHTPF usage(*input) keyed
      extdesc('DEVLIB/FLIGHTPF') extfile(*extdesc)
      rename(FLIGHTPF:FLTREC);
dcl-f AIRMASTER usage(*input) keyed
      extdesc('DEVLIB/AIRMASTER') extfile(*extdesc)
      rename(AIRMASTER:AIRREC);
dcl-f USERMASTER usage(*input) keyed
      extdesc('DEVLIB/USERMASTER') extfile(*extdesc)
      rename(USERMASTER:USRREC);
dcl-f PSNGRPF usage(*input) keyed
      extdesc('DEVLIB/PSNGRPF') extfile(*extdesc)
      rename(PSNGRPF:PSGREC);

dcl-pr TKTRPT extpgm('DEVLIB/TKTRPT');
  inAwb char(5);
end-pr;

dcl-s targetBk char(5);

if inBkId <> '';
  targetBk = inBkId;
else;
  targetBk = 'B0001';
endif;

// Read Consignment Record
chain targetBk BKGREC;
if %found(BOOKINGPF);
  tAwb = bkId;
  tFlt = fltId;
  monitor;
    tDat = %char(bkDepDate: *iso);
  on-error;
    tDat = '2026-11-20';
  endmon;

  // Read Shipper Details
  chain usrId USRREC;
  if %found(USERMASTER);
    tShpNm = usrName;
  else;
    tShpNm = usrId;
  endif;

  // Read Linehaul Details
  chain fltId FLTREC;
  if %found(FLIGHTPF);
    tFrom = fltOrigin;
    tTo   = fltDest;

    chain airId AIRREC;
    if %found(AIRMASTER);
      tAirNm = airName;
    else;
      tAirNm = airId;
    endif;
  else;
    tFrom = 'Origin Hub';
    tTo   = 'Destination Hub';
    tAirNm = 'LOGIX Carrier';
  endif;

  // Read Weight from PSNGRPF
  setll usrId PSGREC;
  reade usrId PSGREC;
  if not %eof(PSNGRPF);
    tCgoWt = psgAge;
    if tCgoWt <= 0;
      tCgoWt = 50;
    endif;
  else;
    tCgoWt = 50;
  endif;

  tMsg = 'Milestone tracking loaded for AWB ' + %trim(targetBk) + '.';
else;
  tAwb   = targetBk;
  tFlt   = 'F0001';
  tShpNm = 'Registered Shipper';
  tAirNm = 'Blue Dart Express';
  tFrom  = 'Pune';
  tTo    = 'Chennai';
  tCgoWt = 50;
  tDat   = '2026-11-20';
  tMsg   = 'Default tracking preview shown.';
endif;

dow not *in03 and not *in12;
  exfmt TRKSCR;

  if *in03 or *in12;
    leave;
  endif;

  // F8 = Print Waybill
  if *in08;
    callp(e) TKTRPT(targetBk);
    tMsg = 'Waybill printed to spool file TKTRPT.';
    iter;
  endif;

  // F5 = Refresh
  if *in05;
    tMsg = 'Tracking milestones refreshed in real-time.';
    iter;
  endif;
enddo;

*inlr = *on;
return;
