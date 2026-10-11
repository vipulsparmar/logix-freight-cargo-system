**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-f GRVLST workstn extdesc('DEVLIB/GRVLST')
      extfile(*extdesc)
      sfile(GRVLSTSFL:rrn);
dcl-f GRIEVPF usage(*input:*output:*update) keyed
      extdesc('DEVLIB/GRIEVPF') extfile(*extdesc)
      rename(GRIEVPF:GRVREC);

dcl-s rrn       packed(4:0) inz(0);
dcl-s nextNum   packed(4:0) inz(2);
dcl-s newGrvId  char(5);

exsr LoadSubfile;

dow not *in03 and not *in12;
  write FOOTER;
  exfmt GRVLSTCTL;

  if *in03 or *in12;
    leave;
  endif;

  if *in05;
    exsr LoadSubfile;
    msgFld = 'Transit claims refreshed.';
    iter;
  endif;

  if *in06;
    exsr AddComplaintScreen;
    exsr LoadSubfile;
    iter;
  endif;

  readc GRVLSTSFL;
  dow not %eof(GRVLST);
    select;
      when sflOpt = '4'; // Dismiss Complaint
        chain sflGrvId GRVREC;
        if %found(GRIEVPF);
          status   = 'D';
          response = 'Dismissed / Closed';
          update GRVREC;
          msgFld = 'Claim ' + %trim(sflGrvId) + ' dismissed.';
        endif;

      when sflOpt = '2'; // Resolve Complaint
        exsr ResolveComplaintScreen;

      when sflOpt = '5'; // View Complaint
        exsr ViewComplaintScreen;
    endsl;

    sflOpt = '';
    update GRVLSTSFL;
    readc GRVLSTSFL;
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
  write GRVLSTCTL;
  *in52 = *off;

  rrn = 0;
  setll *loval GRVREC;
  read GRVREC;

  dow not %eof(GRIEVPF);
    sflOpt   = '';
    sflGrvId = grvId;
    sflUsrId = usrId;
    sflFltId = fltId;
    sflStat  = status;
    sflCmpl  = complaint;

    rrn += 1;
    write GRVLSTSFL;
    read GRVREC;
  enddo;

  if rrn > 0;
    *in50 = *on;
    *in51 = *on;
    *in53 = *on;
  else;
    *in50 = *off;
    *in51 = *on;
    *in53 = *on;
    msgFld = 'No transit claims found.';
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: ResolveComplaintScreen
// -------------------------------------------------------------
begsr ResolveComplaintScreen;
  chain sflGrvId GRVREC;
  if %found(GRIEVPF);
    dGrvId = grvId;
    dUsrId = usrId;
    dFltId = fltId;
    dStat  = 'R';
    dCmpl  = complaint;
    dResp  = response;
    dMsg   = 'Type resolution response and press F6 to Resolve.';

    dow not *in03 and not *in12;
      exfmt GRVDTLSCR;
      if *in03 or *in12;
        leave;
      endif;

      if *in06;
        chain sflGrvId GRVREC;
        if %found(GRIEVPF);
          status    = dStat;
          complaint = dCmpl;
          response  = dResp;
          update GRVREC;
          msgFld = 'Claim ' + %trim(dGrvId) + ' resolved!';
        endif;
        leave;
      endif;
    enddo;
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: ViewComplaintScreen
// -------------------------------------------------------------
begsr ViewComplaintScreen;
  chain sflGrvId GRVREC;
  if %found(GRIEVPF);
    dGrvId = grvId;
    dUsrId = usrId;
    dFltId = fltId;
    dStat  = status;
    dCmpl  = complaint;
    dResp  = response;
    dMsg   = 'View mode. Press F3 or F12 to return.';

    dow not *in03 and not *in12;
      exfmt GRVDTLSCR;
      if *in03 or *in12;
        leave;
      endif;
    enddo;
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: AddComplaintScreen
// -------------------------------------------------------------
begsr AddComplaintScreen;
  dou not %found(GRIEVPF);
    newGrvId = 'C' + %editc(nextNum: 'X');
    chain newGrvId GRVREC;
    if %found(GRIEVPF);
      nextNum += 1;
    endif;
  enddo;

  dGrvId = newGrvId;
  dUsrId = 'U0001';
  dFltId = 'FL001';
  dStat  = 'P';
  dCmpl  = 'Cargo packaging damaged during transit';
  dResp  = 'Pending investigation';
  dMsg   = 'Fill transit claim and press F6 to Submit.';

  dow not *in03 and not *in12;
    exfmt GRVDTLSCR;

    if *in03 or *in12;
      leave;
    endif;

    if *in06;
      grvId     = newGrvId;
      usrId     = dUsrId;
      fltId     = dFltId;
      complaint = dCmpl;
      response  = dResp;
      status    = dStat;
      write GRVREC;

      msgFld = 'Transit Claim ' + %trim(newGrvId) + ' logged!';
      nextNum += 1;
      leave;
    endif;
  enddo;
endsr;
