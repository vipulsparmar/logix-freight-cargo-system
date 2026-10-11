**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-f CFGLST workstn extdesc('DEVLIB/CFGLST')
      extfile(*extdesc)
      sfile(CFGLSTSFL:rrn);
dcl-f CONTROLTBL usage(*input:*output:*update:*delete) keyed alias
      extdesc('DEVLIB/CONTROLTBL') extfile(*extdesc)
      rename(CONTROLTBL:CTLREC);

dcl-s rrn packed(4:0) inz(0);

exsr LoadSubfile;

dow not *in03 and not *in12;
  write FOOTER;
  exfmt CFGLSTCTL;

  if *in03 or *in12;
    leave;
  endif;

  if *in05;
    exsr LoadSubfile;
    msgFld = 'Logistics codes refreshed.';
    iter;
  endif;

  if *in06;
    exsr AddCodeScreen;
    exsr LoadSubfile;
    iter;
  endif;

  readc CFGLSTSFL;
  dow not %eof(CFGLST);
    select;
      when sflOpt = '4'; // Delete Code
        chain (sflCat: sflType: sflCode) CTLREC;
        if %found(CONTROLTBL);
          delete CTLREC;
          msgFld = 'Entry ' + %trim(sflCode) + ' deleted.';
        endif;

      when sflOpt = '2'; // Edit Code
        exsr EditCodeScreen;

      when sflOpt = '5'; // View Code
        exsr ViewCodeScreen;
    endsl;

    sflOpt = '';
    update CFGLSTSFL;
    readc CFGLSTSFL;
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
  write CFGLSTCTL;
  *in52 = *off;

  rrn = 0;
  setll *loval CTLREC;
  read CTLREC;

  dow not %eof(CONTROLTBL);
    sflOpt  = '';
    sflCat  = keyField1;
    sflType = keyField2;
    sflCode = valField;
    sflDesc = description;

    rrn += 1;
    write CFGLSTSFL;
    read CTLREC;
  enddo;

  if rrn > 0;
    *in50 = *on;
    *in51 = *on;
    *in53 = *on;
  else;
    *in50 = *off;
    *in51 = *on;
    *in53 = *on;
    msgFld = 'No logistics codes found.';
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: EditCodeScreen
// -------------------------------------------------------------
begsr EditCodeScreen;
  chain (sflCat: sflType: sflCode) CTLREC;
  if %found(CONTROLTBL);
    dCat  = keyField1;
    dType = keyField2;
    dCode = valField;
    dDesc = description;
    dMsg  = 'Update description and press F6 to Save.';

    dow not *in03 and not *in12;
      exfmt CFGDTLSCR;
      if *in03 or *in12;
        leave;
      endif;

      if *in06;
        chain (sflCat: sflType: sflCode) CTLREC;
        if %found(CONTROLTBL);
          description = dDesc;
          update CTLREC;
          msgFld = 'Code ' + %trim(dCode) + ' updated.';
        endif;
        leave;
      endif;
    enddo;
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: ViewCodeScreen
// -------------------------------------------------------------
begsr ViewCodeScreen;
  chain (sflCat: sflType: sflCode) CTLREC;
  if %found(CONTROLTBL);
    dCat  = keyField1;
    dType = keyField2;
    dCode = valField;
    dDesc = description;
    dMsg  = 'View-only mode. Press F3 or F12 to return.';

    dow not *in03 and not *in12;
      exfmt CFGDTLSCR;
      if *in03 or *in12;
        leave;
      endif;
    enddo;
  endif;
endsr;

// -------------------------------------------------------------
// Subroutine: AddCodeScreen
// -------------------------------------------------------------
begsr AddCodeScreen;
  dCat  = 'Hub';
  dType = 'Zone';
  dCode = '';
  dDesc = '';
  dMsg  = 'Enter Category, Type, Code and press F6 to Save.';

  dow not *in03 and not *in12;
    exfmt CFGDTLSCR;

    if *in03 or *in12;
      leave;
    endif;

    if *in06;
      if %trim(dCode) = '' or %trim(dDesc) = '';
        dMsg = 'Code and Description are required.';
        iter;
      endif;

      keyField1   = dCat;
      keyField2   = dType;
      valField    = dCode;
      description = dDesc;
      write CTLREC;

      msgFld = 'Code ' + %trim(dCode) + ' added successfully!';
      leave;
    endif;
  enddo;
endsr;
