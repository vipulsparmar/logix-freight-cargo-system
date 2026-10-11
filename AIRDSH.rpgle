**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-pi *n;
  inUser char(5);
end-pi;

dcl-f AIRDSH workstn extdesc('DEVLIB/AIRDSH')
      extfile(*extdesc);
dcl-f AIRMASTER usage(*input) keyed
      extdesc('DEVLIB/AIRMASTER') extfile(*extdesc)
      rename(AIRMASTER:AIRREC);

dcl-pr FLTLST extpgm('DEVLIB/FLTLST') end-pr;
dcl-pr BKGLST extpgm('DEVLIB/BKGLST') end-pr;
dcl-pr FORGOT extpgm('DEVLIB/FORGOT') end-pr;

chain inUser AIRREC;
if not %found(AIRMASTER);
  dspName = inUser;
else;
  dspName = airName;
endif;

msgFld = 'Welcome, Carrier Operations. Select an option (1-5).';

dow not *in03 and not *in12;
  exfmt AIRDSHSCR;

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
      callp(e) FLTLST();
      msgFld = 'Returned from Freight Linehauls.';
    when choice = 2;
      callp(e) FLTLST();
      msgFld = 'Returned from Linehaul Routes.';
    when choice = 3;
      callp(e) BKGLST();
      msgFld = 'Returned from Consignments & Manifests.';
    when choice = 4;
      msgFld = 'Choice 4: Profile viewed.';
    when choice = 5;
      callp(e) FORGOT();
      msgFld = 'Returned from Password Change.';
    other;
      msgFld = 'Invalid Choice. Enter 1 to 5.';
  endsl;

  choice = 0;
enddo;

*inlr = *on;
return;
