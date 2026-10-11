**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-pi *n;
  inUser char(5);
end-pi;

dcl-f CUSDSH workstn extdesc('DEVLIB/CUSDSH')
      extfile(*extdesc);
dcl-f USERMASTER usage(*input) keyed
      extdesc('DEVLIB/USERMASTER') extfile(*extdesc)
      rename(USERMASTER:USERREC);

dcl-pr FLTLST extpgm('DEVLIB/FLTLST') end-pr;
dcl-pr BKGLST extpgm('DEVLIB/BKGLST') end-pr;
dcl-pr FORGOT extpgm('DEVLIB/FORGOT') end-pr;
dcl-pr CUSBKG extpgm('DEVLIB/CUSBKG');
  pUser char(5);
end-pr;

chain inUser USERREC;
if %found(USERMASTER);
  cusName = usrName;
else;
  cusName = inUser;
endif;

msgFld = 'Welcome, ' + %trim(cusName) + '! Select option (1-4).';

dow not *in03 and not *in12;
  exfmt CUSDSHSCR;

  if *in03 or *in12;
    leave;
  endif;

  if *in05;
    choice = 0;
    msgFld = 'Screen refreshed.';
    iter;
  endif;

  if *in11;
    msgFld = 'Deactivation request submitted for review.';
    iter;
  endif;

  select;
    when choice = 1;
      msgFld = 'Choice 1: Profile viewed.';
    when choice = 2;
      callp(e) CUSBKG(inUser);
      if %error;
        msgFld = 'Failed to open Consignment Booking. Check joblog.';
      else;
        msgFld = 'Returned from Route Search & Cargo Booking.';
      endif;
    when choice = 3;
      callp(e) BKGLST();
      msgFld = 'Returned from Consignments & Tracking.';
    when choice = 4;
      callp(e) FORGOT();
      msgFld = 'Returned from Password Change.';
    other;
      msgFld = 'Invalid Choice. Enter 1 to 4.';
  endsl;

  choice = 0;
enddo;

*inlr = *on;
return;
