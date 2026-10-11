/* ------------------------------------------------------------- */
/* Freight & Cargo Logistics System (LOGIX) - Build & Run        */
/* Library: DEVLIB                                              */
/* User Profile: VIPUL13051                                     */
/* ------------------------------------------------------------- */
PGM
    /* Ensure DEVLIB is in library list */
    CHGLIBL    LIBL(DEVLIB QGPL QTEMP)

    /* ========================================================= */
    /* 1. Compile Display Files (DDS)                            */
    /* ========================================================= */
    CRTDSPF    FILE(DEVLIB/LOGIN)  SRCFILE(DEVLIB/QDDSSRC) +
                 SRCMBR(LOGIN) REPLACE(*YES) LVLCHK(*NO)
    CRTDSPF    FILE(DEVLIB/REGIS)  SRCFILE(DEVLIB/QDDSSRC) +
                 SRCMBR(REGIS) REPLACE(*YES) LVLCHK(*NO)
    CRTDSPF    FILE(DEVLIB/FORGOT) SRCFILE(DEVLIB/QDDSSRC) +
                 SRCMBR(FORGOT) REPLACE(*YES) LVLCHK(*NO)
    CRTDSPF    FILE(DEVLIB/ADMDSH) SRCFILE(DEVLIB/QDDSSRC) +
                 SRCMBR(ADMDSH) REPLACE(*YES) LVLCHK(*NO)
    CRTDSPF    FILE(DEVLIB/AIRDSH) SRCFILE(DEVLIB/QDDSSRC) +
                 SRCMBR(AIRDSH) REPLACE(*YES) LVLCHK(*NO)
    CRTDSPF    FILE(DEVLIB/CUSDSH) SRCFILE(DEVLIB/QDDSSRC) +
                 SRCMBR(CUSDSH) REPLACE(*YES) LVLCHK(*NO)
    CRTDSPF    FILE(DEVLIB/AIRLST) SRCFILE(DEVLIB/QDDSSRC) +
                 SRCMBR(AIRLST) REPLACE(*YES) LVLCHK(*NO)
    CRTDSPF    FILE(DEVLIB/CUSLST) SRCFILE(DEVLIB/QDDSSRC) +
                 SRCMBR(CUSLST) REPLACE(*YES) LVLCHK(*NO)
    CRTDSPF    FILE(DEVLIB/BKGLST) SRCFILE(DEVLIB/QDDSSRC) +
                 SRCMBR(BKGLST) REPLACE(*YES) LVLCHK(*NO)
    CRTDSPF    FILE(DEVLIB/FLTLST) SRCFILE(DEVLIB/QDDSSRC) +
                 SRCMBR(FLTLST) REPLACE(*YES) LVLCHK(*NO)
    CRTDSPF    FILE(DEVLIB/GRVLST) SRCFILE(DEVLIB/QDDSSRC) +
                 SRCMBR(GRVLST) REPLACE(*YES) LVLCHK(*NO)
    CRTDSPF    FILE(DEVLIB/CFGLST) SRCFILE(DEVLIB/QDDSSRC) +
                 SRCMBR(CFGLST) REPLACE(*YES) LVLCHK(*NO)
    CRTDSPF    FILE(DEVLIB/WNDLKP) SRCFILE(DEVLIB/QDDSSRC) +
                 SRCMBR(WNDLKP) REPLACE(*YES) LVLCHK(*NO)
    CRTDSPF    FILE(DEVLIB/CUSBKG) SRCFILE(DEVLIB/QDDSSRC) +
                 SRCMBR(CUSBKG) REPLACE(*YES) LVLCHK(*NO)
    CRTDSPF    FILE(DEVLIB/TRKSTG) SRCFILE(DEVLIB/QDDSSRC) +
                 SRCMBR(TRKSTG) REPLACE(*YES) LVLCHK(*NO)
    CRTPRTF    FILE(DEVLIB/TKTRPT) SRCFILE(DEVLIB/QDDSSRC) +
                 SRCMBR(TKTRPT) REPLACE(*YES) LVLCHK(*NO)
    CRTPRTF    FILE(DEVLIB/MANIFEST) SRCFILE(DEVLIB/QDDSSRC) +
                 SRCMBR(MANIFEST) REPLACE(*YES) LVLCHK(*NO)

    /* ========================================================= */
    /* 2. Compile Bound RPG Programs                             */
    /* ========================================================= */
    CRTBNDRPG  PGM(DEVLIB/REGIS) SRCFILE(DEVLIB/QRPGLESRC) +
                 SRCMBR(REGIS) DFTACTGRP(*NO) ACTGRP(*CALLER) +
                 REPLACE(*YES)

    CRTBNDRPG  PGM(DEVLIB/FORGOT) SRCFILE(DEVLIB/QRPGLESRC) +
                 SRCMBR(FORGOT) DFTACTGRP(*NO) ACTGRP(*CALLER) +
                 REPLACE(*YES)

    CRTBNDRPG  PGM(DEVLIB/AIRLST) SRCFILE(DEVLIB/QRPGLESRC) +
                 SRCMBR(AIRLST) DFTACTGRP(*NO) ACTGRP(*CALLER) +
                 REPLACE(*YES)

    CRTBNDRPG  PGM(DEVLIB/CUSLST) SRCFILE(DEVLIB/QRPGLESRC) +
                 SRCMBR(CUSLST) DFTACTGRP(*NO) ACTGRP(*CALLER) +
                 REPLACE(*YES)

    CRTBNDRPG  PGM(DEVLIB/BKGLST) SRCFILE(DEVLIB/QRPGLESRC) +
                 SRCMBR(BKGLST) DFTACTGRP(*NO) ACTGRP(*CALLER) +
                 REPLACE(*YES)

    CRTBNDRPG  PGM(DEVLIB/FLTLST) SRCFILE(DEVLIB/QRPGLESRC) +
                 SRCMBR(FLTLST) DFTACTGRP(*NO) ACTGRP(*CALLER) +
                 REPLACE(*YES)

    CRTBNDRPG  PGM(DEVLIB/GRVLST) SRCFILE(DEVLIB/QRPGLESRC) +
                 SRCMBR(GRVLST) DFTACTGRP(*NO) ACTGRP(*CALLER) +
                 REPLACE(*YES)

    CRTBNDRPG  PGM(DEVLIB/CFGLST) SRCFILE(DEVLIB/QRPGLESRC) +
                 SRCMBR(CFGLST) DFTACTGRP(*NO) ACTGRP(*CALLER) +
                 REPLACE(*YES)

    CRTBNDRPG  PGM(DEVLIB/WNDLKP) SRCFILE(DEVLIB/QRPGLESRC) +
                 SRCMBR(WNDLKP) DFTACTGRP(*NO) ACTGRP(*CALLER) +
                 REPLACE(*YES)

    CRTBNDRPG  PGM(DEVLIB/TKTRPT) SRCFILE(DEVLIB/QRPGLESRC) +
                 SRCMBR(TKTRPT) DFTACTGRP(*NO) ACTGRP(*CALLER) +
                 REPLACE(*YES)

    CRTBNDRPG  PGM(DEVLIB/CUSBKG) SRCFILE(DEVLIB/QRPGLESRC) +
                 SRCMBR(CUSBKG) DFTACTGRP(*NO) ACTGRP(*CALLER) +
                 REPLACE(*YES)
 
    CRTBNDRPG  PGM(DEVLIB/TRKSTG) SRCFILE(DEVLIB/QRPGLESRC) +
                 SRCMBR(TRKSTG) DFTACTGRP(*NO) ACTGRP(*CALLER) +
                 REPLACE(*YES)
 
    CRTBNDRPG  PGM(DEVLIB/MANIFEST) SRCFILE(DEVLIB/QRPGLESRC) +
                 SRCMBR(MANIFEST) DFTACTGRP(*NO) ACTGRP(*CALLER) +
                 REPLACE(*YES)

    CRTBNDRPG  PGM(DEVLIB/ADMDSH) SRCFILE(DEVLIB/QRPGLESRC) +
                 SRCMBR(ADMDSH) DFTACTGRP(*NO) ACTGRP(*CALLER) +
                 REPLACE(*YES)

    CRTBNDRPG  PGM(DEVLIB/AIRDSH) SRCFILE(DEVLIB/QRPGLESRC) +
                 SRCMBR(AIRDSH) DFTACTGRP(*NO) ACTGRP(*CALLER) +
                 REPLACE(*YES)

    CRTBNDRPG  PGM(DEVLIB/CUSDSH) SRCFILE(DEVLIB/QRPGLESRC) +
                 SRCMBR(CUSDSH) DFTACTGRP(*NO) ACTGRP(*CALLER) +
                 REPLACE(*YES)

    CRTBNDRPG  PGM(DEVLIB/LOGIN) SRCFILE(DEVLIB/QRPGLESRC) +
                 SRCMBR(LOGIN) DFTACTGRP(*NO) ACTGRP(*NEW) +
                 REPLACE(*YES)

    /* ========================================================= */
    /* 3. Launch System                                          */
    /* ========================================================= */
    CALL       PGM(DEVLIB/LOGIN)
ENDPGM