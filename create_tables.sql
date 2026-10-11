-- =============================================================
-- Domestic Freight & Cargo Logistics System (LOGIX)
-- Complete Database Schema & Seed Data (10 Tables)
-- Target Library: DEVLIB
-- =============================================================

-- 1. CONTROLTBL - Logistics Hub & Code Lookups
CREATE OR REPLACE TABLE DEVLIB.CONTROLTBL (
    keyField1   VARCHAR(10) NOT NULL,
    keyField2   VARCHAR(10) NOT NULL,
    valField    VARCHAR(10) NOT NULL,
    description FOR COLUMN ctlDesc VARCHAR(30) NOT NULL,
    PRIMARY KEY (keyField1, keyField2, valField)
);

-- 2. LOGINPF - User Credentials & Roles (Admin, Carrier, Shipper)
CREATE OR REPLACE TABLE DEVLIB.LOGINPF (
    userId      CHAR(5)     NOT NULL,
    userPass    VARCHAR(20) NOT NULL,
    userRole    VARCHAR(10) NOT NULL,
    lastLogin   DATE,
    userQstn    VARCHAR(30),
    userAnswr   VARCHAR(30),
    status      CHAR(1)     DEFAULT 'A',
    remark      VARCHAR(15),
    PRIMARY KEY (userId)
);

-- 3. AIRMASTER - Freight Carriers & Fleet Operators
CREATE OR REPLACE TABLE DEVLIB.AIRMASTER (
    airId       CHAR(5)        NOT NULL,
    airName     VARCHAR(20)    NOT NULL,
    airMobNum   VARCHAR(10),
    airEmail    VARCHAR(50),
    airCity     VARCHAR(20),
    airPinCode  NUMERIC(6, 0),
    airState    VARCHAR(20),
    airAddress  VARCHAR(100),
    airFleet    NUMERIC(5, 0)  DEFAULT 0,
    airEstDate  DATE,
    airRating   DECIMAL(3, 2)  DEFAULT 4.50,
    airStatus   CHAR(1)        DEFAULT 'A',
    airRemark   VARCHAR(15),
    PRIMARY KEY (airId)
);

-- 4. USERMASTER - Registered Corporate Clients / Shippers
CREATE OR REPLACE TABLE DEVLIB.USERMASTER (
    usrId       CHAR(5)        NOT NULL,
    usrName     VARCHAR(20)    NOT NULL,
    usrDOB      DATE,
    usrGender   CHAR(1)        DEFAULT 'C',
    usrMobNum   VARCHAR(10),
    usrEmail    VARCHAR(50),
    usrCity     VARCHAR(20),
    usrPinCode  NUMERIC(6, 0),
    usrState    VARCHAR(20),
    usrAddress  VARCHAR(100),
    usrAadhar   NUMERIC(12, 0),
    usrStatus   CHAR(1)        DEFAULT 'A',
    usrRemark   VARCHAR(15),
    PRIMARY KEY (usrId)
);

-- 5. PSNGRPF - Consignees & Delivery Hubs
CREATE OR REPLACE TABLE DEVLIB.PSNGRPF (
    psgId       CHAR(5)     NOT NULL,
    usrId       CHAR(5)     NOT NULL,
    psgName     VARCHAR(20) NOT NULL,
    psgGender   CHAR(1)     DEFAULT 'C',
    psgAge      NUMERIC(2, 0) DEFAULT 1,
    psgRltn     VARCHAR(10),
    PRIMARY KEY (psgId)
);

-- 6. FLIGHTPF - Freight Routes & Scheduled Linehauls
CREATE OR REPLACE TABLE DEVLIB.FLIGHTPF (
    fltId       CHAR(5)       NOT NULL,
    airId       CHAR(5)       NOT NULL,
    fltRange    NUMERIC(5, 0),
    fltFuelCap  NUMERIC(6, 0),
    airModel    VARCHAR(5),
    fltTotSeat  NUMERIC(3, 0),
    fltOrigin   VARCHAR(20)   NOT NULL,
    fltDest     VARCHAR(20)   NOT NULL,
    fltTkPrice  NUMERIC(5, 0) NOT NULL,
    fltArrTime  TIME,
    fltDepTime  TIME,
    fltEndTime  TIME,
    fltTotDur   TIME,
    fltCabBag   NUMERIC(1, 0) DEFAULT 7,
    fltMainBag  NUMERIC(2, 0) DEFAULT 15,
    fltStatus   CHAR(1)       DEFAULT 'A',
    fltRemark   VARCHAR(15),
    PRIMARY KEY (fltId)
);

-- 7. BOOKINGPF - Consignment Bookings / Shipments
CREATE OR REPLACE TABLE DEVLIB.BOOKINGPF (
    bkId        CHAR(5)     NOT NULL,
    usrId       CHAR(5)     NOT NULL,
    fltId       CHAR(5)     NOT NULL,
    bkDate      DATE,
    bkDepDate   DATE,
    bkStatus    CHAR(1)     DEFAULT 'U',
    bkRemark    VARCHAR(15),
    PRIMARY KEY (bkId)
);

-- 8. TICKETPF - Cargo Parcels & Packages in Shipment
CREATE OR REPLACE TABLE DEVLIB.TICKETPF (
    tktId       CHAR(5)       NOT NULL,
    bkId        CHAR(5)       NOT NULL,
    psgId       CHAR(5)       NOT NULL,
    tktSeatNum  NUMERIC(3, 0),
    tktStatus   CHAR(1)       DEFAULT 'U',
    tktRemark   VARCHAR(15),
    PRIMARY KEY (tktId)
);

-- 9. RATINGPF - Shipper SLA & Transporter Ratings
CREATE OR REPLACE TABLE DEVLIB.RATINGPF (
    usrId       CHAR(5)       NOT NULL,
    fltId       CHAR(5)       NOT NULL,
    rating      NUMERIC(1, 0) NOT NULL,
    feedback    VARCHAR(50),
    PRIMARY KEY (usrId, fltId)
);

-- 10. GRIEVPF - Cargo Damage & Transit Claims
CREATE OR REPLACE TABLE DEVLIB.GRIEVPF (
    grvId       CHAR(5)       NOT NULL,
    usrId       CHAR(5)       NOT NULL,
    fltId       CHAR(5)       NOT NULL,
    complaint   VARCHAR(100)  NOT NULL,
    response    VARCHAR(100),
    status      CHAR(1)       DEFAULT 'P',
    PRIMARY KEY (grvId)
);

-- =============================================================
-- Seed Data: Logistics Hubs, Carriers, Shippers, Routes
-- =============================================================

DELETE FROM DEVLIB.CONTROLTBL;
INSERT INTO DEVLIB.CONTROLTBL
(keyField1, keyField2, valField, description) VALUES
('Hub',     'Zone',    'DEL',     'Delhi Cargo Hub'),
('Hub',     'Zone',    'BOM',     'Mumbai Port Terminal'),
('Hub',     'Zone',    'BLR',     'Bangalore Logistics Park'),
('Hub',     'Zone',    'MAA',     'Chennai Freight Dock'),
('Hub',     'Zone',    'HYD',     'Hyderabad Air Cargo'),
('Hub',     'Zone',    'PNQ',     'Pune Auto Logistics'),
('Service', 'Class',   'EXP',     'Express Air Cargo'),
('Service', 'Class',   'SUR',     'Surface Heavy Linehaul'),
('Service', 'Class',   'FTL',     'Full Truck Load'),
('Vehicle', 'Type',    'A330',    'Airbus A330 Freighter'),
('Vehicle', 'Type',    '20TR',    '20-Ton Multi-Axle Trailer'),
('Vehicle', 'Type',    '10TN',    '10-Ton Heavy Truck'),
('Vehicle', 'Type',    'VAN',     'Express City Courier Van');

DELETE FROM DEVLIB.LOGINPF;
INSERT INTO DEVLIB.LOGINPF
(userId, userPass, userRole, lastLogin, userQstn, userAnswr, status,
 remark) VALUES
('ADM01', 'admin', 'Admin', CURRENT DATE, 'First Hub?', 'Delhi Hub',
 'A', 'Logistics Admin'),
('A0001', 'air', 'Airline', CURRENT DATE, 'HQ City?', 'Gurugram',
 'A', 'Blue Dart Rep'),
('U0001', 'user', 'Customer', CURRENT DATE, 'First Hub?', 'Pune Hub',
 'A', 'Tata Motors Log');

DELETE FROM DEVLIB.AIRMASTER;
INSERT INTO DEVLIB.AIRMASTER
(airId, airName, airMobNum, airEmail, airCity, airPinCode,
 airState, airAddress, airFleet, airEstDate, airRating, airStatus,
 airRemark) VALUES
('A0001', 'Blue Dart Express', '9811223344', 'help@bluedart.com',
 'Gurugram', 122001, 'Haryana', 'Blue Dart Air Hub, Delhi-NCR',
 450, '1983-11-19', 4.80, 'A', 'Active Carrier'),
('A0002', 'TCI Freight Line', '9822334455', 'ops@tcifreight.com',
 'Gurugram', 122002, 'Haryana', 'TCI House, Sector 32, Gurugram',
 1200, '1958-05-15', 4.60, 'A', 'Active Carrier'),
('A0003', 'Safexpress Cargo', '9833445566', 'care@safexpress.com',
 'Delhi', 110037, 'Delhi', 'Safexpress Logistics Park, NH-8',
 800, '1997-03-25', 4.50, 'A', 'Active Carrier'),
('A0004', 'Delhivery Freight', '9844556677', 'ops@delhivery.com',
 'Gurugram', 122003, 'Haryana', 'Plot 5, Sector 44, Gurugram',
 650, '2011-05-01', 4.70, 'A', 'Active Carrier');

DELETE FROM DEVLIB.USERMASTER;
INSERT INTO DEVLIB.USERMASTER
(usrId, usrName, usrDOB, usrGender, usrMobNum, usrEmail,
 usrCity, usrPinCode, usrState, usrAddress, usrAadhar,
 usrStatus, usrRemark) VALUES
('U0001', 'Tata Motors Supply', '1945-09-01', 'C', '9820011223',
 'supply@tatamotors.com', 'Pune', 411018, 'Maharashtra',
 'Tata Motors Plant Gate 2, Pimpri, Pune', 270012345678,
 'A', 'Corp Shipper'),
('U0002', 'Reliance Retail Log', '2006-05-10', 'C', '9830022334',
 'logistics@relianceretail.com', 'Mumbai', 400051, 'Maharashtra',
 'Reliance Corporate Park, Ghansoli, Navi Mumbai', 270087654321,
 'A', 'Corp Shipper'),
('U0003', 'Continental Auto Sp', '1998-08-15', 'C', '9840033445',
 'spares@continental.com', 'Bangalore', 560100, 'Karnataka',
 'Electronic City Phase 2, Bangalore', 290099887766,
 'A', 'Corp Shipper');

DELETE FROM DEVLIB.PSNGRPF;
INSERT INTO DEVLIB.PSNGRPF
(psgId, usrId, psgName, psgGender, psgAge, psgRltn) VALUES
('P0001', 'U0001', 'Chennai Auto Plant', 'C', 1, 'Plant Dock'),
('P0002', 'U0001', 'Delhi Parts Hub', 'C', 1, 'Depot Hub'),
('P0003', 'U0002', 'Kolkata DC Warehouse', 'C', 1, 'Wholesale DC');

DELETE FROM DEVLIB.FLIGHTPF;
INSERT INTO DEVLIB.FLIGHTPF
(fltId, airId, fltRange, fltFuelCap, airModel, fltTotSeat,
 fltOrigin, fltDest, fltTkPrice, fltArrTime, fltDepTime,
 fltEndTime, fltTotDur, fltCabBag, fltMainBag, fltStatus,
 fltRemark) VALUES
('F0001', 'A0001', 3500, 45000, 'A330', 250, 'Pune', 'Chennai',
 85, '06:30:00', '02:00:00', '06:30:00', '04:30:00', 5, 25,
 'A', 'On-Time Express'),
('F0002', 'A0002', 1500, 20000, '20TR', 180, 'Mumbai', 'Delhi',
 45, '18:00:00', '06:00:00', '18:00:00', '12:00:00', 5, 20,
 'A', 'Surface Linehaul'),
('F0003', 'A0004', 1200, 10000, '10TN', 120, 'Bangalore', 'Hyderabad',
 55, '15:30:00', '08:00:00', '15:30:00', '07:30:00', 5, 10,
 'A', 'Daily Dispatch');

DELETE FROM DEVLIB.BOOKINGPF;
INSERT INTO DEVLIB.BOOKINGPF
(bkId, usrId, fltId, bkDate, bkDepDate, bkStatus, bkRemark) VALUES
('B0001', 'U0001', 'F0001', CURRENT DATE, '2026-11-20', 'U',
 'Priority Freight'),
('B0002', 'U0002', 'F0002', CURRENT DATE, '2026-11-22', 'U',
 'Surface Heavy'),
('B0003', 'U0003', 'F0003', CURRENT DATE, '2026-11-25', 'U',
 'Express Cargo');

DELETE FROM DEVLIB.TICKETPF;
INSERT INTO DEVLIB.TICKETPF
(tktId, bkId, psgId, tktSeatNum, tktStatus, tktRemark) VALUES
('T0001', 'B0001', 'P0001', 50, 'U', 'Pallet Loaded'),
('T0002', 'B0002', 'P0003', 40, 'U', 'Container Bay'),
('T0003', 'B0003', 'P0001', 25, 'U', 'Air Cargo Box');

DELETE FROM DEVLIB.RATINGPF;
INSERT INTO DEVLIB.RATINGPF
(usrId, fltId, rating, feedback) VALUES
('U0001', 'F0001', 5, 'Fast dock turnaround and zero transit damage!');

DELETE FROM DEVLIB.GRIEVPF;
INSERT INTO DEVLIB.GRIEVPF
(grvId, usrId, fltId, complaint, response, status) VALUES
('C0001', 'U0001', 'F0001',
 'Outer pallet wrapping damaged during Pune hub handover',
 'Hub inspection complete, contents intact, repacked', 'P');