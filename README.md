Domestic Flight Booking System (IBM i RPG Project)

This project is a case study demonstrating a Login Flow developed in RPGLE, with supporting CL, DDS, and SQL artifacts. It runs on IBM i (AS/400) and shows integration of display files, database files, and RPGLE business logic.

Project Structure
.
├── RUNLOGIN.clp        # CL program to compile and run the project
├── LOGIN.dspf          # Display file (DDS) for the login screen
├── LOGIN.rpgle         # RPGLE program handling login logic
├── create_tables.sql   # SQL script to create database tables
└── README.md           # Project documentation

Components

1. create_tables.sql
Defines the physical files (tables) required:

LOGINPF → Stores user login credentials (ID, password, role).
USERMASTER → Stores customer information.
PSNGRPF → Stores passenger details linked to a user.

2. LOGIN.dspf
A DDS Display File for the login screen:

User ID and Password fields.
Function keys:
F3 = Exit
F6 = Register new customer
F7 = Forgot password

3. LOGIN.rpgle
The RPGLE program:

Displays login screen (EXFMT LOGINSCR).
Handles user input:
F6 → Registration program call placeholder.
F7 → Forgot password program call placeholder.
ENTER → Validates user credentials against LOGINPF.
Routes to different dashboards based on role: Admin, Airline, or Customer.

4. RUNLOGIN.clp
Control Language (CL) program to automate compilation and execution:

Sets library list.
Compiles the display file.
Compiles the RPG module.
Creates the program.
Calls the program.

How to Run

1. Create Source Physical Files (if not already created):

CRTSRCPF FILE(AMATHUR1/QDDSSRC) RCDLEN(112)
CRTSRCPF FILE(AMATHUR1/QRPGLESRC) RCDLEN(112)

2. Load the sources into the respective members:

LOGIN.dspf → QDDSSRC/LOGIN
LOGIN.rpgle → QRPGLESRC/LOGIN
RUNLOGIN.clp → QCLSRC/RUNLOGIN

3. Create database files:

RUNSQLSTM SRCFILE(AMATHUR1/QDDSSRC) SRCMBR(CREATE_TABLES)

4. Compile and run using the CL program:

CALL PGM(AMATHUR1/RUNLOGIN)

Notes
This is a demonstration case study, not production-ready code.
Error handling, security (e.g., password encryption), and full registration flows can be added.
Designed for educational and case study purposes.
