# Domestic Freight & Cargo Logistics System (LOGIX)

A full-stack IBM i (AS/400) multi-carrier enterprise application for freight linehauls, cargo consignment booking, and automated waybill generation.

---

## Target IBM i Environment
- **User Profile:** `VIPUL13051`
- **Library:** `DEVLIB`

---

## Architecture & Project Components

```text
.
├── create_tables.sql   # Full database DDL for all 10 tables + Freight seed data
├── build.sh            # Automated deploy & build script
├── RUNLOGIN.clp        # Master CL build & execution program
│
├── Display Files (DDS -> QDDSSRC):
│   ├── LOGIN.dspf      # Main Sign-On screen (LOGIX)
│   ├── REGIS.dspf      # Corporate Shipper Onboarding (with F4 Lookup)
│   ├── FORGOT.dspf     # Password Recovery & Security Verification
│   ├── ADMDSH.dspf     # Logistics Operations Dashboard
│   ├── AIRDSH.dspf     # Freight Carrier & Fleet Operator Dashboard
│   ├── CUSDSH.dspf     # Corporate Shipper / Consignor Dashboard
│   ├── AIRLST.dspf     # Subfile CRUD: Freight Carriers (2=Edit, 4=Deact, 5=View, F6=Add)
│   ├── CUSLST.dspf     # Subfile CRUD: Corporate Shippers (2=Edit, 4=Deact, 5=View, F6=Add)
│   ├── BKGLST.dspf     # Subfile CRUD: Consignments & Dispatches (2=Edit, 4=Cancel, 5=View, F6=Add)
│   ├── FLTLST.dspf     # Subfile CRUD: Freight Linehaul Routes (2=Edit, 4=Cancel, 5=View, F6=Add)
│   ├── GRVLST.dspf     # Subfile CRUD: Cargo Damage & Transit Claims (2=Resolve, 4=Dismiss, 5=View, F6=Add)
│   ├── CFGLST.dspf     # Subfile CRUD: Logistics Master Lookups (2=Edit, 4=Delete, 5=View, F6=Add)
│   ├── WNDLKP.dspf     # Windowed Subfile Dialog: F4 Pop-up Lookup Window
│   ├── CUSBKG.dspf     # Freight Route Search & Consignment Booking (AWB)
│   └── TRKSTG.dspf     # Live Milestone Cargo Tracking Timeline
│
├── Printer Files (DDS -> QDDSSRC):
│   ├── TKTRPT.prtf     # Consignment Waybill (AWB) / Goods Receipt Note
│   └── MANIFEST.prtf   # Daily Linehaul Dispatch Manifest Report (Truck/Air)
│
└── RPGLE Programs (ILE RPG -> QRPGLESRC):
    ├── LOGIN.rpgle     # Sign-on validation & logistics role routing
    ├── REGIS.rpgle     # Shipper onboarding logic with F4 lookup window
    ├── FORGOT.rpgle    # Security question check & password update
    ├── ADMDSH.rpgle    # Logistics operations dashboard & router
    ├── AIRDSH.rpgle    # Carrier dashboard & route scheduling router
    ├── CUSDSH.rpgle    # Corporate shipper dashboard & booking router
    ├── AIRLST.rpgle    # Interactive CRUD program for CARRMASTER (AIRMASTER)
    ├── CUSLST.rpgle    # Interactive CRUD program for CLIENTPF (USERMASTER)
    ├── BKGLST.rpgle    # Interactive CRUD program for SHIPMNTPF (BOOKINGPF)
    ├── FLTLST.rpgle    # Interactive CRUD program for ROUTEPF (FLIGHTPF)
    ├── GRVLST.rpgle    # Interactive CRUD program for CLAIMPF (GRIEVPF)
    ├── CFGLST.rpgle    # Interactive CRUD program for CONTROLTBL
    ├── WNDLKP.rpgle    # Pop-up window lookup handler for cargo hubs/codes
    ├── TKTRPT.rpgle    # Consignment Waybill report generator (spools to WRKSPLF)
    ├── MANIFEST.rpgle  # Daily Linehaul Dispatch Manifest generator
    ├── TRKSTG.rpgle    # Live Milestone Tracking timeline viewer
    └── CUSBKG.rpgle    # Freight Search, Tariff Engine & Capacity Depletion
```

---

## Complete Database Tables (10 Tables)

All tables are defined in [`create_tables.sql`](file:///d:/projects/FLIGHT-BOOKING-PROJECT/create_tables.sql):

1. **`CONTROLTBL`**: Logistics Master Codes (Cargo Hubs, Freight Services, Vehicle Types).
2. **`LOGINPF`**: User credentials & roles (`Admin`, `Airline`/Carrier, `Customer`/Shipper).
3. **`AIRMASTER`**: Freight Carriers & Fleet Operators (Blue Dart, TCI Freight, Safexpress, Delhivery).
4. **`USERMASTER`**: Registered Corporate Shippers (Tata Motors, Reliance Retail, Continental Automotive).
5. **`PSNGRPF`**: Consignees & Receiving Docks linked to Shippers.
6. **`FLIGHTPF`**: Scheduled Freight Linehauls & Linehaul Dispatches.
7. **`BOOKINGPF`**: Consignment Bookings & Shipment Ledger (AWB).
8. **`TICKETPF`**: Cargo Parcels & Packages in Shipment.
9. **`RATINGPF`**: Shipper Carrier Ratings & SLA Feedback.
10. **`GRIEVPF`**: Cargo Damage & Transit Claims.

---

## Key Enterprise Logistics Features

1. **Vibrant 5250 Color Architecture**:
   * Uses high-contrast 5250 color standards: `COLOR(TRQ)` for system titles and field labels, `COLOR(WHT) DSPATR(HI)` for brand logos and selected values, `COLOR(YLW)` for screen subtitles and rates, `COLOR(GRN)` for data values, `COLOR(BLU)` for borders and function key footers, and `COLOR(RED) DSPATR(HI)` for alert banners.

2. **Live 5-Stage Milestone Cargo Tracking (`TRKSTG`)**:
   * Displays end-to-end consignment progression: `[BOOKED]` $\rightarrow$ `[HUB CONSOLIDATED]` $\rightarrow$ `[IN LINEHAUL TRANSIT]` $\rightarrow$ `[DESTINATION TERMINAL]` $\rightarrow$ `[OUT FOR DOCK DELIVERY]`.

3. **Daily Linehaul Dispatch Manifest Report (`MANIFEST`)**:
   * Generates formal printed dispatch manifests (PRTF) with linehaul header, carrier, active AWB details, cargo weights, and total linehaul freight revenues spooled to `WRKSPLF`.

4. **Dynamic Tariff Engine & Payload Depletion (`CUSBKG`)**:
   * Automatically calculates total freight tariffs with base rate per kg plus terminal dock handling fees (Rs. 150).
   * Validates linehaul payload capacity in real-time, safely deducting booked cargo weights and rejecting bookings exceeding carrier limits.

5. **Sanitized 5250 Data Entry**:
   * Numeric input fields equipped with `CHECK(RZ)` and character validation to prevent hardware decimal validation exceptions (`CPF5002 / CPF5026`).

---

## Deploy & Run via VS Code "Code for IBM i"

1. Open VS Code with **Code for IBM i**.
2. Press `Ctrl+E` &rarr; Run Action: **"Deploy & Build Entire Project (build.sh)"**.
3. Open a 5250 Terminal (`Ctrl+Shift+P` &rarr; `IBM i: Open 5250 Terminal`) and run:
   ```cl
   CALL DEVLIB/LOGIN
   ```

### Default Credentials
* **Logistics Controller / Admin:** `ADM01` / `admin`
* **Carrier Representative (Blue Dart):** `A0001` / `air`
* **Corporate Shipper (Tata Motors):** `U0001` / `user`

