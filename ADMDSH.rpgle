**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-pi *n;
  inUser char(5);
end-pi;

dcl-f ADMDSH workstn extdesc('DEVLIB/ADMDSH')
      extfile(*extdesc);

// Sub-screen prototypes
dcl-pr AIRLST extpgm('DEVLIB/AIRLST') end-pr;
dcl-pr CUSLST extpgm('DEVLIB/CUSLST') end-pr;
dcl-pr BKGLST extpgm('DEVLIB/BKGLST') end-pr;
dcl-pr FLTLST extpgm('DEVLIB/FLTLST') end-pr;
dcl-pr GRVLST extpgm('DEVLIB/GRVLST') end-pr;
dcl-pr CFGLST extpgm('DEVLIB/CFGLST') end-pr;
dcl-pr FORGOT extpgm('DEVLIB/FORGOT') end-pr;

msgFld = 'Welcome, Logistics Admin. Select an option (1-7).';

dow not *in03 and not *in12;
  exfmt ADMDSHSCR;

  if *in03 or *in12;
    leave;
  endif;

  if *in05;
    choice = 0;
    msgFld = 'Screen refreshed.';
    iter;
  endif;

  select;
    when choice = 1;
      callp(e) AIRLST();
      if %error;
        msgFld = 'Failed to open AIRLST. Check joblog.';
      else;
        msgFld = 'Returned from Manage Carriers.';
      endif;
    when choice = 2;
      callp(e) CUSLST();
      if %error;
        msgFld = 'Failed to open CUSLST. Check joblog.';
      else;
        msgFld = 'Returned from Manage Shippers.';
      endif;
    when choice = 3;
      callp(e) BKGLST();
      if %error;
        msgFld = 'Failed to open BKGLST. Check joblog.';
      else;
        msgFld = 'Returned from View Consignments.';
      endif;
    when choice = 4;
      callp(e) FLTLST();
      if %error;
        msgFld = 'Failed to open FLTLST. Check joblog.';
      else;
        msgFld = 'Returned from View Linehauls.';
      endif;
    when choice = 5;
      callp(e) GRVLST();
      if %error;
        msgFld = 'Failed to open GRVLST. Check joblog.';
      else;
        msgFld = 'Returned from Manage Transit Claims.';
      endif;
    when choice = 6;
      callp(e) CFGLST();
      if %error;
        msgFld = 'Failed to open CFGLST. Check joblog.';
      else;
        msgFld = 'Returned from Logistics Master Setup.';
      endif;
    when choice = 7;
      callp(e) FORGOT();
      if %error;
        msgFld = 'Failed to open FORGOT. Check joblog.';
      else;
        msgFld = 'Returned from Password Change.';
      endif;
    other;
      msgFld = 'Invalid Choice. Enter 1 to 7.';
  endsl;

  choice = 0;
enddo;

*inlr = *on;
return;
