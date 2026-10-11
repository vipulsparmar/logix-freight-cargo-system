**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-pi *n;
  inBkId  char(5);
  inUsrId char(5);
end-pi;

dcl-f TKTRPT printer usage(*output)
      extdesc('DEVLIB/TKTRPT') extfile(*extdesc);
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
      rename(USERMASTER:USERREC);
dcl-f TICKETPF usage(*input) keyed
      extdesc('DEVLIB/TICKETPF') extfile(*extdesc)
      rename(TICKETPF:TKTREC);

// Lookup booking record
chain inBkId BKGREC;
if not %found(BOOKINGPF);
  *inlr = *on;
  return;
endif;

// Lookup customer details
chain inUsrId USERREC;
if not %found(USERMASTER);
  usrName = inUsrId;
endif;

// Lookup scheduled flight details
chain fltId FLTREC;
if not %found(FLIGHTPF);
  fltOrigin = 'Unknown';
  fltDest   = 'Unknown';
endif;

// Lookup airline name
chain airId AIRREC;
if not %found(AIRMASTER);
  airName = airId;
endif;

// Locate ticket record
setll *loval TKTREC;
read TKTREC;
dow not %eof(TICKETPF);
  if bkId = inBkId;
    leave;
  endif;
  read TKTREC;
enddo;

// Populate and print Consignment Waybill (AWB) Spool File
prPass = usrName;
prBkId = inBkId;
prFlt  = fltId;
prAir  = airName;
prFrom = fltOrigin;
prTo   = fltDest;
monitor;
  prDate = %char(bkDepDate: *iso);
on-error;
  prDate = '2026-11-20';
endmon;
prSeat = %char(tktSeatNum);
prTkt  = tktId;

write PASSHDR;

*inlr = *on;
return;
