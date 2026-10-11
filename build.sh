#!/QOpenSys/usr/bin/sh
# -----------------------------------------------------------------
# Domestic Freight & Cargo Logistics System (LOGIX) - Automated Build & Deploy
# Run via Code for IBM i Deploy Action or PASE terminal
# -----------------------------------------------------------------

TARGET_LIB="DEVLIB"
DIR=$(cd "$(dirname "$0")" && pwd)

echo "==========================================================="
echo "Building Freight & Cargo System (LOGIX) in $TARGET_LIB"
echo "Source IFS Directory: $DIR"
echo "==========================================================="

# 1. Create Library and Source Physical Files if not already created
echo "[1/5] Ensuring Library & Source Physical Files exist..."
system "CRTLIB LIB($TARGET_LIB) TEXT('Freight & Cargo Logistics System')" 2>/dev/null
system "CRTSRCPF FILE($TARGET_LIB/QDDSSRC) RCDLEN(112)" 2>/dev/null
system "CRTSRCPF FILE($TARGET_LIB/QRPGLESRC) RCDLEN(112)" 2>/dev/null
system "CRTSRCPF FILE($TARGET_LIB/QCLSRC) RCDLEN(112)" 2>/dev/null

# 2. Execute SQL Database Tables & Seed Data
echo "[2/5] Creating Database Tables and Loading Seed Data..."
system "RUNSQLSTM SRCSTMF('$DIR/create_tables.sql') COMMIT(*NONE)"

# 3. Copy Display Files & Printer Files to QDDSSRC and Compile
echo "[3/5] Deploying & Compiling Display & Printer Files (DDS)..."
for dspf in LOGIN REGIS FORGOT ADMDSH AIRDSH CUSDSH AIRLST CUSLST BKGLST FLTLST GRVLST CFGLST WNDLKP CUSBKG TRKSTG; do
    echo "  -> Processing $dspf.dspf..."
    system "CPYFRMSTMF FROMSTMF('$DIR/$dspf.dspf') TOMBR('/QSYS.LIB/$TARGET_LIB.LIB/QDDSSRC.FILE/$dspf.MBR') MBROPT(*REPLACE)"
    system "CRTDSPF FILE($TARGET_LIB/$dspf) SRCFILE($TARGET_LIB/QDDSSRC) SRCMBR($dspf) REPLACE(*YES) LVLCHK(*NO)"
done

for prtf in TKTRPT MANIFEST; do
    echo "  -> Processing $prtf.prtf (Printer File)..."
    system "CPYFRMSTMF FROMSTMF('$DIR/$prtf.prtf') TOMBR('/QSYS.LIB/$TARGET_LIB.LIB/QDDSSRC.FILE/$prtf.MBR') MBROPT(*REPLACE)"
    system "CRTPRTF FILE($TARGET_LIB/$prtf) SRCFILE($TARGET_LIB/QDDSSRC) SRCMBR($prtf) REPLACE(*YES) LVLCHK(*NO)"
done

# 4. Copy RPGLE Files to QRPGLESRC and Compile
echo "[4/5] Deploying & Compiling RPGLE Programs..."
for rpg in REGIS FORGOT ADMDSH AIRDSH CUSDSH AIRLST CUSLST BKGLST FLTLST GRVLST CFGLST WNDLKP TKTRPT CUSBKG TRKSTG MANIFEST; do
    echo "  -> Processing $rpg.rpgle..."
    system "CPYFRMSTMF FROMSTMF('$DIR/$rpg.rpgle') TOMBR('/QSYS.LIB/$TARGET_LIB.LIB/QRPGLESRC.FILE/$rpg.MBR') MBROPT(*REPLACE)"
    system "CRTBNDRPG PGM($TARGET_LIB/$rpg) SRCFILE($TARGET_LIB/QRPGLESRC) SRCMBR($rpg) DFTACTGRP(*NO) ACTGRP(*CALLER) REPLACE(*YES)"
done

echo "  -> Processing LOGIN.rpgle (*NEW activation group)..."
system "CPYFRMSTMF FROMSTMF('$DIR/LOGIN.rpgle') TOMBR('/QSYS.LIB/$TARGET_LIB.LIB/QRPGLESRC.FILE/LOGIN.MBR') MBROPT(*REPLACE)"
system "CRTBNDRPG PGM($TARGET_LIB/LOGIN) SRCFILE($TARGET_LIB/QRPGLESRC) SRCMBR(LOGIN) DFTACTGRP(*NO) ACTGRP(*NEW) REPLACE(*YES)"

# 5. Copy and Compile CL Program
echo "[5/5] Deploying CL Program..."
system "CPYFRMSTMF FROMSTMF('$DIR/RUNLOGIN.clp') TOMBR('/QSYS.LIB/$TARGET_LIB.LIB/QCLSRC.FILE/RUNLOGIN.MBR') MBROPT(*REPLACE)"
system "CRTCLPGM PGM($TARGET_LIB/RUNLOGIN) SRCFILE($TARGET_LIB/QCLSRC) SRCMBR(RUNLOGIN) REPLACE(*YES)"

echo "==========================================================="
echo "BUILD COMPLETED SUCCESSFULLY!"
echo "To run the application, open a 5250 Terminal and run:"
echo "  CALL DEVLIB/LOGIN"
echo "==========================================================="
