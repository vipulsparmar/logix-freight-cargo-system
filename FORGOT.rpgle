**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-f FORGOT workstn extdesc('DEVLIB/FORGOT')
      extfile(*extdesc);
dcl-f LOGINPF usage(*input:*update) keyed
      extdesc('DEVLIB/LOGINPF') extfile(*extdesc)
      rename(LOGINPF:LOGINREC);

msgFld = 'Enter Login ID and press Enter.';

dow not *in03 and not *in12;
  exfmt FORGOTSCR;

  if *in03 or *in12;
    leave;
  endif;

  if *in05;
    lgnId  = '';
    secQst = '';
    secAns = '';
    newPsw = '';
    cfmPsw = '';
    msgFld = 'Screen refreshed.';
    iter;
  endif;

  // On Enter: fetch security question
  if not *in06;
    if %trim(lgnId) = '';
      msgFld = 'Please enter a Login ID.';
      iter;
    endif;

    chain lgnId LOGINREC;
    if %found(LOGINPF);
      secQst = userQstn;
      msgFld = 'Enter answer and new password, press F6.';
    else;
      secQst = '';
      msgFld = 'Login ID not found in system.';
    endif;
    iter;
  endif;

  // On F6: Validate answer & update password
  if *in06;
    chain lgnId LOGINREC;
    if not %found(LOGINPF);
      msgFld = 'Login ID not found.';
      iter;
    endif;

    if %lower(%trim(secAns)) <> %lower(%trim(userAnswr));
      msgFld = 'Incorrect security answer!';
      iter;
    endif;

    if %trim(newPsw) = '' or %trim(newPsw) <> %trim(cfmPsw);
      msgFld = 'Passwords must match!';
      iter;
    endif;

    userPass = newPsw;
    update LOGINREC;
    msgFld = 'Password changed! Press F12 to return.';
  endif;
enddo;

*inlr = *on;
return;
