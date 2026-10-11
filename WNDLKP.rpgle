**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-pi *n;
  inCategory char(10) const;
  outVal     char(10);
end-pi;

dcl-f WNDLKP workstn extdesc('DEVLIB/WNDLKP')
      extfile(*extdesc)
      sfile(WNDSFL:rrn);
dcl-f CONTROLTBL usage(*input) keyed alias
      extdesc('DEVLIB/CONTROLTBL') extfile(*extdesc)
      rename(CONTROLTBL:CTLREC);

dcl-s rrn packed(4:0) inz(0);

outVal = '';
exsr LoadSubfile;

dow not *in03 and not *in12;
  write WNDFTR;
  exfmt WNDCTL;

  if *in03 or *in12;
    outVal = '';
    leave;
  endif;

  readc WNDSFL;
  dow not %eof(WNDLKP);
    if sflOpt = '1';
      outVal = sflCode;
      leave;
    endif;
    sflOpt = '';
    update WNDSFL;
    readc WNDSFL;
  enddo;

  if outVal <> '';
    leave;
  endif;
enddo;

*inlr = *on;
return;

// -------------------------------------------------------------
// Subroutine: LoadSubfile
// -------------------------------------------------------------
begsr LoadSubfile;
  *in52 = *on;
  *in50 = *off;
  write WNDCTL;
  *in52 = *off;

  rrn = 0;
  setll *loval CTLREC;
  read CTLREC;

  dow not %eof(CONTROLTBL);
    if inCategory = '' or %trim(keyField2) = %trim(inCategory);
      sflOpt  = '';
      sflCode = valField;
      sflDesc = description;

      rrn += 1;
      write WNDSFL;
    endif;

    read CTLREC;
  enddo;

  if rrn > 0;
    *in50 = *on;
    *in51 = *on;
    *in53 = *on;
    wndMsg = 'Select with 1 and press Enter.';
  else;
    *in50 = *off;
    *in51 = *on;
    *in53 = *on;
    wndMsg = 'No lookups for ' + %trim(inCategory);
  endif;
endsr;
