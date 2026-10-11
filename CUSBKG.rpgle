**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-pi *n;
  inUser char(5);
end-pi;

dcl-f CUSBKG workstn extdesc('DEVLIB/CUSBKG')
      extfile(*extdesc)
      sfile(FLTSELSFL:rrn);
dcl-f FLIGHTPF usage(*input:*update) keyed
      extdesc('DEVLIB/FLIGHTPF') extfile(*extdesc)
      rename(FLIGHTPF:FLTREC);
dcl-f AIRMASTER usage(*input) keyed
      extdesc('DEVLIB/AIRMASTER') extfile(*extdesc)
      rename(AIRMASTER:AIRREC);
dcl-f USERMASTER usage(*input) keyed
      extdesc('DEVLIB/USERMASTER') extfile(*extdesc)
      rename(USERMASTER:USERREC);
dcl-f BOOKINGPF usage(*input:*output) keyed
      extdesc('DEVLIB/BOOKINGPF') extfile(*extdesc)
      rename(BOOKINGPF:BKGREC);
dcl-f TICKETPF usage(*input:*output) keyed
      extdesc('DEVLIB/TICKETPF') extfile(*extdesc)
      rename(TICKETPF:TKTREC);
dcl-f PSNGRPF usage(*input:*output) keyed
      extdesc('DEVLIB/PSNGRPF') extfile(*extdesc)
      rename(PSNGRPF:PSGREC);

dcl-pr TKTRPT extpgm('DEVLIB/TKTRPT');
  pBkId  char(5);
  pUsrId char(5);
end-pr;

dcl-s rrn       packed(4:0) inz(0);
dcl-s selFltId  char(5);
dcl-s selAirNm  char(15);
dcl-s bkNum     packed(4:0) inz(2);
dcl-s psgNum    packed(4:0) inz(4);
dcl-s tktNum    packed(4:0) inz(2);
dcl-s nextBk    char(5);
dcl-s nextPsg   char(5);
dcl-s nextTkt   char(5);
dcl-s bookedBk  char(5) inz('');

// Search screen default values
srcOrig = 'Pune';
srcDest = 'Chennai';
srcDat  = 20261120;
srcPass = 1;
srcMsg  = 'Enter origin, destination hubs and press Enter to search.';

dow not *in03 and not *in12;
  exfmt SRCHSCR;

  if *in03 or *in12;
    leave;
  endif;

  if *in05;
    srcOrig = '';
    srcDest = '';
    srcDat  = 20261120;
    srcPass = 1;
    srcMsg  = 'Search cleared.';
    iter;
  endif;

  // Perform search and load subfile
  exsr LoadAvailableFlights;

  if rrn = 0;
    srcMsg = 'No linehauls found for this route. Try another.';
    iter;
  endif;

  // Show available flights subfile
  dow not *in03 and not *in12;
    write SELFOOTER;
    exfmt FLTSELCTL;

    if *in03 or *in12;
      leave;
    endif;

    // Check if user selected a flight with 1
    selFltId = '';
    readc FLTSELSFL;
    dow not %eof(CUSBKG);
      if sflOpt = '1';
        selFltId = sflFlt;
        selAirNm = sflAir;
        leave;
      endif;
      sflOpt = '';
      update FLTSELSFL;
      readc FLTSELSFL;
    enddo;

    if selFltId <> '';
      exsr BookingConfirmation;
      leave;
    endif;
  enddo;
enddo;

*inlr = *on;
return;

// -------------------------------------------------------------
// Subroutine: LoadAvailableFlights
// -------------------------------------------------------------
begsr LoadAvailableFlights;
  *in52 = *on;
  *in50 = *off;
  write FLTSELCTL;
  *in52 = *off;

  rrn = 0;
  setll *loval FLTREC;
  read FLTREC;

  dow not %eof(FLIGHTPF);
    if fltStatus = 'A' and
       (%trim(srcOrig) = '' or
        %lower(%trim(fltOrigin)) = %lower(%trim(srcOrig))) and
       (%trim(srcDest) = '' or
        %lower(%trim(fltDest)) = %lower(%trim(srcDest)));

      chain airId AIRREC;
      if %found(AIRMASTER);
        sflAir = airName;
      else;
        sflAir = airId;
      endif;

      sflOpt  = '';
      sflFlt  = fltId;
      sflTime = '13:30';
      sflSeat = fltTotSeat;
      sflFare = fltTkPrice;
      sflRmk  = fltRemark;

      rrn += 1;
      write FLTSELSFL;
    endif;

    read FLTREC;
  enddo;

  if rrn > 0;
    *in50 = *on;
    *in51 = *on;
    *in53 = *on;
    selMsg = 'Found ' + %char(rrn) + ' linehauls. Type 1 to Select.';
  else;
    *in50 = *off;
    *in51 = *on;
    *in53 = *on;
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: BookingConfirmation
// -------------------------------------------------------------
begsr BookingConfirmation;
  chain selFltId FLTREC;
  chain inUser USERREC;
  if not %found(USERMASTER);
    usrName = inUser;
    usrGender = 'M';
  endif;

  cFltId = selFltId;
  cAirNm = selAirNm;
  cRoute = %trim(fltOrigin) + ' -> ' + %trim(fltDest);
  cTrvDt = '2026-11-20';
  cFare  = fltTkPrice;
  cPsgNm = usrName;
  cPsgNd = 'C';
  cPsgAg = 50;
  cPsRlt = 'Pallet';
  // Tariff Engine: Base Freight + Terminal Dock Handling Fee (150 INR)
  cTotFr = (cFare * cPsgAg) + 150;
  cnfMsg = 'Review cargo details. Tariff includes Rs.150 dock fee. F6=Book';

  dow not *in03 and not *in12;
    exfmt CNFSCR;

    if *in03 or *in12;
      leave;
    endif;

    // Recalculate freight whenever weight is updated
    if cPsgAg <= 0;
      cPsgAg = 10;
    endif;
    cTotFr = (cFare * cPsgAg) + 150;

    // F8 = Print Waybill
    if *in08;
      if bookedBk <> '';
        callp(e) TKTRPT(bookedBk: inUser);
        cnfMsg = 'Waybill sent to spool for ' + %trim(bookedBk);
      else;
        cnfMsg = 'Please confirm consignment (F6) before printing!';
      endif;
      iter;
    endif;

    // F6 = Confirm Reservation
    if *in06;
      // Real-time Capacity Depletion Check
      chain selFltId FLTREC;
      if %found(FLIGHTPF);
        if cPsgAg > fltTotSeat;
          cnfMsg = 'Insufficient payload capacity! Available: '
                 + %char(fltTotSeat) + ' Kg.';
          iter;
        endif;
        fltTotSeat -= cPsgAg;
        update FLTREC;
      endif;

      // Auto generate next Booking ID
      dou not %found(BOOKINGPF);
        nextBk = 'B' + %editc(bkNum: 'X');
        chain nextBk BKGREC;
        if %found(BOOKINGPF);
          bkNum += 1;
        endif;
      enddo;

      // Auto generate next Passenger ID
      dou not %found(PSNGRPF);
        nextPsg = 'P' + %editc(psgNum: 'X');
        chain nextPsg PSGREC;
        if %found(PSNGRPF);
          psgNum += 1;
        endif;
      enddo;

      // Auto generate next Ticket ID
      dou not %found(TICKETPF);
        nextTkt = 'T' + %editc(tktNum: 'X');
        chain nextTkt TKTREC;
        if %found(TICKETPF);
          tktNum += 1;
        endif;
      enddo;

      // Write Passenger record
      psgId     = nextPsg;
      usrId     = inUser;
      psgName   = cPsgNm;
      psgGender = cPsgNd;
      psgAge    = cPsgAg;
      psgRltn   = cPsRlt;
      write PSGREC;

      // Write Booking record
      bkId      = nextBk;
      usrId     = inUser;
      fltId     = selFltId;
      bkDate    = %date();
      bkDepDate = %date();
      bkStatus  = 'U';
      bkRemark  = 'Cargo Booked';
      write BKGREC;

      // Write Ticket record
      tktId      = nextTkt;
      bkId       = nextBk;
      psgId      = nextPsg;
      tktSeatNum = 50;
      tktStatus  = 'U';
      tktRemark  = 'Pallet Loaded';
      write TKTREC;

      bookedBk = nextBk;

      // Automatically print Consignment Waybill Spool
      callp(e) TKTRPT(nextBk: inUser);

      cnfMsg = 'Consignment ' + %trim(nextBk) + ' Confirmed! Waybill Spooled.';
    endif;
  enddo;
endsr;
