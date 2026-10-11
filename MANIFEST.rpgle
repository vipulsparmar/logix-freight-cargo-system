**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-pi *n;
  inFltId char(5);
end-pi;

dcl-f MANIFEST printer usage(*output)
      extdesc('DEVLIB/MANIFEST') extfile(*extdesc);
dcl-f FLIGHTPF usage(*input) keyed
      extdesc('DEVLIB/FLIGHTPF') extfile(*extdesc)
      rename(FLIGHTPF:FLTREC);
dcl-f AIRMASTER usage(*input) keyed
      extdesc('DEVLIB/AIRMASTER') extfile(*extdesc)
      rename(AIRMASTER:AIRREC);
dcl-f BOOKINGPF usage(*input) keyed
      extdesc('DEVLIB/BOOKINGPF') extfile(*extdesc)
      rename(BOOKINGPF:BKGREC);
dcl-f USERMASTER usage(*input) keyed
      extdesc('DEVLIB/USERMASTER') extfile(*extdesc)
      rename(USERMASTER:USRREC);
dcl-f PSNGRPF usage(*input) keyed
      extdesc('DEVLIB/PSNGRPF') extfile(*extdesc)
      rename(PSNGRPF:PSGREC);

dcl-s targetFlt char(5);
dcl-s totCount  packed(4:0) inz(0);
dcl-s totWeight packed(5:0) inz(0);
dcl-s totRev    packed(8:0) inz(0);
dcl-s lineFreight packed(7:0) inz(0);

if inFltId <> '';
  targetFlt = inFltId;
else;
  targetFlt = 'F0001';
endif;

// Fetch Route Header Details
chain targetFlt FLTREC;
if %found(FLIGHTPF);
  mnFlt  = fltId;
  mnFrom = fltOrigin;
  mnTo   = fltDest;
  chain airId AIRREC;
  if %found(AIRMASTER);
    mnAir = airName;
  else;
    mnAir = airId;
  endif;
else;
  mnFlt  = targetFlt;
  mnFrom = 'Origin Hub';
  mnTo   = 'Destination Hub';
  mnAir  = 'LOGIX Fleet';
endif;

mnDat = %char(%date(): *iso);
write MNFHDR;

// Loop Bookings for this Linehaul
setll *loval BKGREC;
read BKGREC;
dow not %eof(BOOKINGPF);
  if fltId = targetFlt;
    mAwb = bkId;
    mStat = bkStatus;

    // Get Shipper Name
    chain usrId USRREC;
    if %found(USERMASTER);
      mShpNm = usrName;
    else;
      mShpNm = usrId;
    endif;

    // Get Cargo Weight & Packages from PSNGRPF
    setll usrId PSGREC;
    reade usrId PSGREC;
    if not %eof(PSNGRPF);
      mPkgs = 1;
      mCgoWt = psgAge;
      if mCgoWt <= 0;
        mCgoWt = 25;
      endif;
    else;
      mPkgs = 1;
      mCgoWt = 25;
    endif;

    // Freight = Weight * Rate
    if fltTkPrice > 0;
      lineFreight = mCgoWt * fltTkPrice;
    else;
      lineFreight = mCgoWt * 50;
    endif;
    mFrt = lineFreight;

    totCount += 1;
    totWeight += mCgoWt;
    totRev += lineFreight;

    write MNFDTL;
  endif;
  read BKGREC;
enddo;

// Write Summary Totals
mTotShp = totCount;
mTotWt  = totWeight;
mTotRev = totRev;
write MNFTOT;

*inlr = *on;
return;
