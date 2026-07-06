-- ============================================================
--  AIRLINE CREW ALLOCATION & DUTY SCHEDULING DATABASE SYSTEM
--  UCS310 – Database Management Systems
--  Thapar Institute of Engineering and Technology
--  Authors : Muskan (1024160074) | Zaira Iqbal (1024160093)
--            Pragun Aggarwal (1024160094)
--  Platform : Oracle Live SQL
-- ============================================================

-- ============================================================
-- SECTION 1 : DROP TABLES (run safely even on first use)
-- ============================================================
BEGIN
    FOR t IN (SELECT table_name FROM user_tables
              WHERE table_name IN ('DUTY_ASSIGNMENT','CREW_QUALIFICATION',
                                   'FLIGHT','QUALIFICATION','CREW',
                                   'AIRCRAFT','AIRPORT'))
    LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
END;
/

-- ============================================================
-- SECTION 2 : DROP SEQUENCES
-- ============================================================
BEGIN
    FOR s IN (SELECT sequence_name FROM user_sequences
              WHERE sequence_name IN ('SEQ_CREW','SEQ_AIRCRAFT','SEQ_AIRPORT',
                                      'SEQ_FLIGHT','SEQ_QUAL','SEQ_CREWQUAL',
                                      'SEQ_DUTY'))
    LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
    END LOOP;
END;
/

-- ============================================================
-- SECTION 3 : CREATE SEQUENCES
-- ============================================================
CREATE SEQUENCE seq_crew      START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_aircraft  START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_airport   START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_flight    START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_qual      START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_crewqual  START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_duty      START WITH 1 INCREMENT BY 1 NOCACHE;

-- ============================================================
-- SECTION 4 : CREATE TABLES
-- ============================================================

-- 4.1  AIRPORT
CREATE TABLE Airport (
    id      NUMBER        PRIMARY KEY,
    name    VARCHAR2(100) NOT NULL,
    city    VARCHAR2(80)  NOT NULL,
    country VARCHAR2(80)  NOT NULL
);

-- 4.2  AIRCRAFT
CREATE TABLE Aircraft (
    id           NUMBER        PRIMARY KEY,
    model        VARCHAR2(60)  NOT NULL UNIQUE,
    capacity     NUMBER(4)     NOT NULL CHECK (capacity > 0),
    manufacturer VARCHAR2(80)  NOT NULL
);

-- 4.3  CREW
CREATE TABLE Crew (
    id              NUMBER        PRIMARY KEY,
    name            VARCHAR2(100) NOT NULL,
    role            VARCHAR2(20)  NOT NULL
                        CHECK (role IN ('Pilot','Co-Pilot','Cabin Crew')),
    licenseNo       VARCHAR2(30)  NOT NULL UNIQUE,
    experienceYears NUMBER(3)     NOT NULL CHECK (experienceYears >= 0),
    contactNo       VARCHAR2(15)  NOT NULL
);

-- 4.4  FLIGHT
CREATE TABLE Flight (
    id            NUMBER        PRIMARY KEY,
    flightNumber  VARCHAR2(15)  NOT NULL UNIQUE,
    source        VARCHAR2(80)  NOT NULL,
    destination   VARCHAR2(80)  NOT NULL,
    departureTime TIMESTAMP     NOT NULL,
    arrivalTime   TIMESTAMP     NOT NULL,
    aircraftId    NUMBER        NOT NULL,
    CONSTRAINT fk_flight_aircraft FOREIGN KEY (aircraftId)
        REFERENCES Aircraft (id),
    CONSTRAINT chk_flight_times CHECK (arrivalTime > departureTime)
);

-- 4.5  QUALIFICATION
CREATE TABLE Qualification (
    id            NUMBER        PRIMARY KEY,
    aircraftModel VARCHAR2(60)  NOT NULL,
    requiredRole  VARCHAR2(20)  NOT NULL
                      CHECK (requiredRole IN ('Pilot','Co-Pilot','Cabin Crew'))
);

-- 4.6  CREW_QUALIFICATION  (pivot / bridge table)
CREATE TABLE Crew_Qualification (
    id              NUMBER PRIMARY KEY,
    crewId          NUMBER NOT NULL,
    qualificationId NUMBER NOT NULL,
    CONSTRAINT fk_cq_crew FOREIGN KEY (crewId)
        REFERENCES Crew (id) ON DELETE CASCADE,
    CONSTRAINT fk_cq_qual FOREIGN KEY (qualificationId)
        REFERENCES Qualification (id) ON DELETE CASCADE,
    CONSTRAINT uq_crew_qual UNIQUE (crewId, qualificationId)
);

-- 4.7  DUTY_ASSIGNMENT
CREATE TABLE Duty_Assignment (
    id        NUMBER    PRIMARY KEY,
    crewId    NUMBER    NOT NULL,
    flightId  NUMBER    NOT NULL,
    dutyDate  DATE      NOT NULL,
    dutyHours NUMBER(4,2) NOT NULL
                  CHECK (dutyHours > 0 AND dutyHours <= 14),
    CONSTRAINT fk_duty_crew   FOREIGN KEY (crewId)   REFERENCES Crew (id),
    CONSTRAINT fk_duty_flight FOREIGN KEY (flightId) REFERENCES Flight (id),
    CONSTRAINT uq_crew_flight_date UNIQUE (crewId, flightId, dutyDate)
);

-- ============================================================
-- SECTION 5 : INSERT SAMPLE DATA
-- ============================================================

-- 5.1  Airports
INSERT INTO Airport VALUES (seq_airport.NEXTVAL, 'Indira Gandhi International', 'New Delhi',   'India');
INSERT INTO Airport VALUES (seq_airport.NEXTVAL, 'Chhatrapati Shivaji Maharaj', 'Mumbai',      'India');
INSERT INTO Airport VALUES (seq_airport.NEXTVAL, 'Kempegowda International',    'Bengaluru',   'India');
INSERT INTO Airport VALUES (seq_airport.NEXTVAL, 'Netaji Subhas Chandra Bose',  'Kolkata',     'India');
INSERT INTO Airport VALUES (seq_airport.NEXTVAL, 'Dubai International',          'Dubai',       'UAE');

-- 5.2  Aircraft
INSERT INTO Aircraft VALUES (seq_aircraft.NEXTVAL, 'Boeing 737',   180, 'Boeing');
INSERT INTO Aircraft VALUES (seq_aircraft.NEXTVAL, 'Airbus A320',  180, 'Airbus');
INSERT INTO Aircraft VALUES (seq_aircraft.NEXTVAL, 'Boeing 777',   396, 'Boeing');
INSERT INTO Aircraft VALUES (seq_aircraft.NEXTVAL, 'Airbus A380',  555, 'Airbus');
INSERT INTO Aircraft VALUES (seq_aircraft.NEXTVAL, 'ATR 72',       70,  'ATR');

-- 5.3  Crew  (10 members)
INSERT INTO Crew VALUES (seq_crew.NEXTVAL, 'Arjun Sharma',    'Pilot',      'LIC-001', 12, '9876543210');
INSERT INTO Crew VALUES (seq_crew.NEXTVAL, 'Priya Mehta',     'Co-Pilot',   'LIC-002',  7, '9876543211');
INSERT INTO Crew VALUES (seq_crew.NEXTVAL, 'Rohit Singh',     'Cabin Crew', 'LIC-003',  5, '9876543212');
INSERT INTO Crew VALUES (seq_crew.NEXTVAL, 'Anjali Verma',    'Cabin Crew', 'LIC-004',  4, '9876543213');
INSERT INTO Crew VALUES (seq_crew.NEXTVAL, 'Karan Patel',     'Pilot',      'LIC-005', 15, '9876543214');
INSERT INTO Crew VALUES (seq_crew.NEXTVAL, 'Sneha Iyer',      'Co-Pilot',   'LIC-006',  6, '9876543215');
INSERT INTO Crew VALUES (seq_crew.NEXTVAL, 'Vikram Nair',     'Cabin Crew', 'LIC-007',  3, '9876543216');
INSERT INTO Crew VALUES (seq_crew.NEXTVAL, 'Deepika Joshi',   'Cabin Crew', 'LIC-008',  8, '9876543217');
INSERT INTO Crew VALUES (seq_crew.NEXTVAL, 'Amit Chaudhary',  'Pilot',      'LIC-009', 20, '9876543218');
INSERT INTO Crew VALUES (seq_crew.NEXTVAL, 'Meera Kapoor',    'Co-Pilot',   'LIC-010',  9, '9876543219');

-- 5.4  Flights  (8 flights)
INSERT INTO Flight VALUES (seq_flight.NEXTVAL, 'AI-101', 'New Delhi', 'Mumbai',
    TIMESTAMP '2026-05-01 06:00:00', TIMESTAMP '2026-05-01 08:10:00', 1);
INSERT INTO Flight VALUES (seq_flight.NEXTVAL, 'AI-202', 'Mumbai', 'Bengaluru',
    TIMESTAMP '2026-05-01 09:00:00', TIMESTAMP '2026-05-01 10:30:00', 2);
INSERT INTO Flight VALUES (seq_flight.NEXTVAL, 'AI-303', 'New Delhi', 'Dubai',
    TIMESTAMP '2026-05-02 14:00:00', TIMESTAMP '2026-05-02 17:30:00', 3);
INSERT INTO Flight VALUES (seq_flight.NEXTVAL, 'AI-404', 'Kolkata', 'New Delhi',
    TIMESTAMP '2026-05-03 07:00:00', TIMESTAMP '2026-05-03 09:30:00', 1);
INSERT INTO Flight VALUES (seq_flight.NEXTVAL, 'AI-505', 'Bengaluru', 'Mumbai',
    TIMESTAMP '2026-05-04 11:00:00', TIMESTAMP '2026-05-04 12:20:00', 2);
INSERT INTO Flight VALUES (seq_flight.NEXTVAL, 'AI-606', 'Mumbai', 'Dubai',
    TIMESTAMP '2026-05-05 22:00:00', TIMESTAMP '2026-05-06 01:00:00', 4);
INSERT INTO Flight VALUES (seq_flight.NEXTVAL, 'AI-707', 'New Delhi', 'Kolkata',
    TIMESTAMP '2026-05-06 08:00:00', TIMESTAMP '2026-05-06 10:15:00', 5);
INSERT INTO Flight VALUES (seq_flight.NEXTVAL, 'AI-808', 'Dubai', 'Mumbai',
    TIMESTAMP '2026-05-07 15:00:00', TIMESTAMP '2026-05-07 19:30:00', 3);

-- 5.5  Qualifications
INSERT INTO Qualification VALUES (seq_qual.NEXTVAL, 'Boeing 737',  'Pilot');
INSERT INTO Qualification VALUES (seq_qual.NEXTVAL, 'Boeing 737',  'Co-Pilot');
INSERT INTO Qualification VALUES (seq_qual.NEXTVAL, 'Boeing 737',  'Cabin Crew');
INSERT INTO Qualification VALUES (seq_qual.NEXTVAL, 'Airbus A320', 'Pilot');
INSERT INTO Qualification VALUES (seq_qual.NEXTVAL, 'Airbus A320', 'Co-Pilot');
INSERT INTO Qualification VALUES (seq_qual.NEXTVAL, 'Airbus A320', 'Cabin Crew');
INSERT INTO Qualification VALUES (seq_qual.NEXTVAL, 'Boeing 777',  'Pilot');
INSERT INTO Qualification VALUES (seq_qual.NEXTVAL, 'Boeing 777',  'Co-Pilot');
INSERT INTO Qualification VALUES (seq_qual.NEXTVAL, 'Airbus A380', 'Pilot');
INSERT INTO Qualification VALUES (seq_qual.NEXTVAL, 'ATR 72',      'Pilot');

-- 5.6  Crew Qualifications
INSERT INTO Crew_Qualification VALUES (seq_crewqual.NEXTVAL, 1,  1);  -- Arjun  -> B737 Pilot
INSERT INTO Crew_Qualification VALUES (seq_crewqual.NEXTVAL, 1,  7);  -- Arjun  -> B777 Pilot
INSERT INTO Crew_Qualification VALUES (seq_crewqual.NEXTVAL, 2,  2);  -- Priya  -> B737 Co-Pilot
INSERT INTO Crew_Qualification VALUES (seq_crewqual.NEXTVAL, 3,  3);  -- Rohit  -> B737 Cabin
INSERT INTO Crew_Qualification VALUES (seq_crewqual.NEXTVAL, 4,  6);  -- Anjali -> A320 Cabin
INSERT INTO Crew_Qualification VALUES (seq_crewqual.NEXTVAL, 5,  4);  -- Karan  -> A320 Pilot
INSERT INTO Crew_Qualification VALUES (seq_crewqual.NEXTVAL, 5,  9);  -- Karan  -> A380 Pilot
INSERT INTO Crew_Qualification VALUES (seq_crewqual.NEXTVAL, 6,  5);  -- Sneha  -> A320 Co-Pilot
INSERT INTO Crew_Qualification VALUES (seq_crewqual.NEXTVAL, 7,  3);  -- Vikram -> B737 Cabin
INSERT INTO Crew_Qualification VALUES (seq_crewqual.NEXTVAL, 8,  6);  -- Deepika -> A320 Cabin
INSERT INTO Crew_Qualification VALUES (seq_crewqual.NEXTVAL, 9,  7);  -- Amit   -> B777 Pilot
INSERT INTO Crew_Qualification VALUES (seq_crewqual.NEXTVAL, 10, 8);  -- Meera  -> B777 Co-Pilot

-- 5.7  Duty Assignments
INSERT INTO Duty_Assignment VALUES (seq_duty.NEXTVAL, 1, 1, DATE '2026-05-01', 2.17);
INSERT INTO Duty_Assignment VALUES (seq_duty.NEXTVAL, 2, 1, DATE '2026-05-01', 2.17);
INSERT INTO Duty_Assignment VALUES (seq_duty.NEXTVAL, 3, 1, DATE '2026-05-01', 2.17);
INSERT INTO Duty_Assignment VALUES (seq_duty.NEXTVAL, 5, 2, DATE '2026-05-01', 1.50);
INSERT INTO Duty_Assignment VALUES (seq_duty.NEXTVAL, 6, 2, DATE '2026-05-01', 1.50);
INSERT INTO Duty_Assignment VALUES (seq_duty.NEXTVAL, 4, 2, DATE '2026-05-01', 1.50);
INSERT INTO Duty_Assignment VALUES (seq_duty.NEXTVAL, 9, 3, DATE '2026-05-02', 3.50);
INSERT INTO Duty_Assignment VALUES (seq_duty.NEXTVAL, 10,3, DATE '2026-05-02', 3.50);
INSERT INTO Duty_Assignment VALUES (seq_duty.NEXTVAL, 8, 3, DATE '2026-05-02', 3.50);
INSERT INTO Duty_Assignment VALUES (seq_duty.NEXTVAL, 1, 4, DATE '2026-05-03', 2.50);
INSERT INTO Duty_Assignment VALUES (seq_duty.NEXTVAL, 2, 4, DATE '2026-05-03', 2.50);
INSERT INTO Duty_Assignment VALUES (seq_duty.NEXTVAL, 7, 4, DATE '2026-05-03', 2.50);

COMMIT;

-- ============================================================
-- SECTION 6 : SQL QUERIES (Demonstration Queries)
-- ============================================================

-- Q1: List all crew members with their role
SELECT id, name, role, licenseNo, experienceYears
FROM   Crew
ORDER  BY role, name;

-- Q2: All flights with aircraft model
SELECT f.flightNumber, f.source, f.destination,
       TO_CHAR(f.departureTime,'DD-MON-YYYY HH24:MI') AS departure,
       TO_CHAR(f.arrivalTime,  'DD-MON-YYYY HH24:MI') AS arrival,
       a.model AS aircraft
FROM   Flight f
JOIN   Aircraft a ON f.aircraftId = a.id
ORDER  BY f.departureTime;

-- Q3: Duty schedule with crew and flight details
SELECT c.name   AS crew_name,
       c.role,
       f.flightNumber,
       f.source,
       f.destination,
       da.dutyDate,
       da.dutyHours
FROM   Duty_Assignment da
JOIN   Crew   c ON da.crewId   = c.id
JOIN   Flight f ON da.flightId = f.id
ORDER  BY da.dutyDate, f.flightNumber;

-- Q4: Total duty hours per crew member
SELECT c.name, c.role,
       ROUND(SUM(da.dutyHours),2) AS total_duty_hours,
       COUNT(da.id)               AS total_assignments
FROM   Crew c
JOIN   Duty_Assignment da ON c.id = da.crewId
GROUP  BY c.name, c.role
ORDER  BY total_duty_hours DESC;

-- Q5: Qualified crew for Boeing 777 as Pilot
SELECT c.name, c.licenseNo, c.experienceYears
FROM   Crew c
JOIN   Crew_Qualification cq ON c.id = cq.crewId
JOIN   Qualification q       ON cq.qualificationId = q.id
WHERE  q.aircraftModel = 'Boeing 777'
AND    q.requiredRole  = 'Pilot';

-- Q6: Flights with no crew assigned yet
SELECT f.flightNumber, f.source, f.destination,
       TO_CHAR(f.departureTime,'DD-MON-YYYY HH24:MI') AS departure
FROM   Flight f
WHERE  f.id NOT IN (SELECT DISTINCT flightId FROM Duty_Assignment);

-- Q7: Crew members with more than 1 qualification
SELECT c.name, c.role, COUNT(cq.id) AS qualification_count
FROM   Crew c
JOIN   Crew_Qualification cq ON c.id = cq.crewId
GROUP  BY c.name, c.role
HAVING COUNT(cq.id) > 1
ORDER  BY qualification_count DESC;

-- Q8: Aircraft utilization (number of flights per aircraft)
SELECT a.model, a.manufacturer, COUNT(f.id) AS total_flights
FROM   Aircraft a
LEFT JOIN Flight f ON a.id = f.aircraftId
GROUP  BY a.model, a.manufacturer
ORDER  BY total_flights DESC;

-- ============================================================
-- SECTION 7 : VIEWS
-- ============================================================

CREATE OR REPLACE VIEW vw_crew_schedule AS
SELECT c.id    AS crew_id,
       c.name  AS crew_name,
       c.role,
       f.flightNumber,
       f.source,
       f.destination,
       TO_CHAR(f.departureTime,'DD-MON-YYYY HH24:MI') AS departure,
       TO_CHAR(f.arrivalTime,  'DD-MON-YYYY HH24:MI') AS arrival,
       da.dutyDate,
       da.dutyHours,
       a.model AS aircraft_model
FROM   Duty_Assignment da
JOIN   Crew    c ON da.crewId   = c.id
JOIN   Flight  f ON da.flightId = f.id
JOIN   Aircraft a ON f.aircraftId = a.id;

-- Use the view
SELECT * FROM vw_crew_schedule ORDER BY dutyDate, flightNumber;

CREATE OR REPLACE VIEW vw_crew_duty_summary AS
SELECT c.id   AS crew_id,
       c.name,
       c.role,
       COUNT(da.id)               AS total_flights,
       ROUND(SUM(da.dutyHours),2) AS total_hours
FROM   Crew c
LEFT JOIN Duty_Assignment da ON c.id = da.crewId
GROUP  BY c.id, c.name, c.role;

SELECT * FROM vw_crew_duty_summary ORDER BY total_hours DESC NULLS LAST;

-- ============================================================
-- SECTION 8 : PL/SQL – STORED PROCEDURES
-- ============================================================

-- 8.1  Add a new crew member
CREATE OR REPLACE PROCEDURE sp_add_crew (
    p_name    IN Crew.name%TYPE,
    p_role    IN Crew.role%TYPE,
    p_license IN Crew.licenseNo%TYPE,
    p_exp     IN Crew.experienceYears%TYPE,
    p_contact IN Crew.contactNo%TYPE
) AS
    v_id NUMBER;
BEGIN
    v_id := seq_crew.NEXTVAL;
    INSERT INTO Crew VALUES (v_id, p_name, p_role, p_license, p_exp, p_contact);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Crew member ' || p_name ||
                         ' added with ID = ' || v_id);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: License number already exists.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        ROLLBACK;
END sp_add_crew;
/

-- Test it
BEGIN
    sp_add_crew('Neha Saxena', 'Cabin Crew', 'LIC-011', 2, '9123456780');
END;
/

-- 8.2  Assign crew to a flight (with duplicate and conflict check)
CREATE OR REPLACE PROCEDURE sp_assign_duty (
    p_crew_id   IN NUMBER,
    p_flight_id IN NUMBER,
    p_duty_date IN DATE,
    p_hours     IN NUMBER
) AS
    v_count   NUMBER;
    v_crew    Crew.name%TYPE;
    v_flight  Flight.flightNumber%TYPE;
BEGIN
    -- Validate crew exists
    SELECT name INTO v_crew FROM Crew WHERE id = p_crew_id;

    -- Validate flight exists
    SELECT flightNumber INTO v_flight FROM Flight WHERE id = p_flight_id;

    -- Check for duplicate assignment
    SELECT COUNT(*) INTO v_count
    FROM   Duty_Assignment
    WHERE  crewId   = p_crew_id
    AND    flightId = p_flight_id
    AND    dutyDate = p_duty_date;

    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('WARNING: ' || v_crew ||
                             ' is already assigned to flight ' || v_flight ||
                             ' on ' || TO_CHAR(p_duty_date,'DD-MON-YYYY'));
        RETURN;
    END IF;

    -- Check for same-date conflict (already flying another flight at same time)
    SELECT COUNT(*) INTO v_count
    FROM   Duty_Assignment da
    JOIN   Flight f1 ON da.flightId = f1.id
    JOIN   Flight f2 ON f2.id = p_flight_id
    WHERE  da.crewId   = p_crew_id
    AND    da.dutyDate = p_duty_date
    AND    f1.departureTime < f2.arrivalTime
    AND    f1.arrivalTime   > f2.departureTime;

    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('CONFLICT: ' || v_crew ||
                             ' has an overlapping flight on ' ||
                             TO_CHAR(p_duty_date,'DD-MON-YYYY'));
        RETURN;
    END IF;

    INSERT INTO Duty_Assignment
        VALUES (seq_duty.NEXTVAL, p_crew_id, p_flight_id, p_duty_date, p_hours);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('SUCCESS: ' || v_crew ||
                         ' assigned to flight ' || v_flight ||
                         ' on ' || TO_CHAR(p_duty_date,'DD-MON-YYYY'));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Crew or Flight ID not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        ROLLBACK;
END sp_assign_duty;
/

-- Test it
BEGIN
    sp_assign_duty(5, 5, DATE '2026-05-04', 1.33);
END;
/

-- 8.3  Show all crew on a specific flight
CREATE OR REPLACE PROCEDURE sp_flight_crew (
    p_flight_number IN VARCHAR2
) AS
    CURSOR c_crew IS
        SELECT c.name, c.role, da.dutyHours
        FROM   Duty_Assignment da
        JOIN   Crew   c ON da.crewId   = c.id
        JOIN   Flight f ON da.flightId = f.id
        WHERE  f.flightNumber = p_flight_number;

    v_found BOOLEAN := FALSE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Crew for Flight: ' || p_flight_number || ' ===');
    FOR r IN c_crew LOOP
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE(RPAD(r.name,20) || RPAD(r.role,12) ||
                             r.dutyHours || ' hrs');
    END LOOP;
    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('No crew assigned to this flight.');
    END IF;
END sp_flight_crew;
/

-- Test it
BEGIN
    sp_flight_crew('AI-101');
END;
/

-- ============================================================
-- SECTION 9 : PL/SQL – FUNCTIONS
-- ============================================================

-- 9.1  Get total duty hours of a crew member
CREATE OR REPLACE FUNCTION fn_total_duty_hours (
    p_crew_id IN NUMBER
) RETURN NUMBER AS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(dutyHours), 0)
    INTO   v_total
    FROM   Duty_Assignment
    WHERE  crewId = p_crew_id;
    RETURN ROUND(v_total, 2);
EXCEPTION
    WHEN OTHERS THEN RETURN 0;
END fn_total_duty_hours;
/

-- Test it
BEGIN
    DBMS_OUTPUT.PUT_LINE('Total duty hours for crew 1: ' ||
                          fn_total_duty_hours(1) || ' hrs');
END;
/

-- 9.2  Check if a crew member is available on a date
CREATE OR REPLACE FUNCTION fn_is_available (
    p_crew_id IN NUMBER,
    p_date    IN DATE
) RETURN VARCHAR2 AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM   Duty_Assignment
    WHERE  crewId   = p_crew_id
    AND    dutyDate = p_date;

    IF v_count = 0 THEN
        RETURN 'AVAILABLE';
    ELSE
        RETURN 'BUSY (' || v_count || ' assignment(s))';
    END IF;
END fn_is_available;
/

-- Test it
BEGIN
    DBMS_OUTPUT.PUT_LINE('Crew 1 on 01-May-2026: ' ||
                          fn_is_available(1, DATE '2026-05-01'));
    DBMS_OUTPUT.PUT_LINE('Crew 1 on 10-May-2026: ' ||
                          fn_is_available(1, DATE '2026-05-10'));
END;
/

-- ============================================================
-- SECTION 10 : PL/SQL – TRIGGERS
-- ============================================================

-- 10.1  Prevent crew from being assigned > 14 duty hours per day
CREATE OR REPLACE TRIGGER trg_max_daily_hours
BEFORE INSERT ON Duty_Assignment
FOR EACH ROW
DECLARE
    v_existing_hours NUMBER;
BEGIN
    SELECT NVL(SUM(dutyHours), 0)
    INTO   v_existing_hours
    FROM   Duty_Assignment
    WHERE  crewId   = :NEW.crewId
    AND    dutyDate = :NEW.dutyDate;

    IF (v_existing_hours + :NEW.dutyHours) > 14 THEN
        RAISE_APPLICATION_ERROR(-20001,
            'DUTY HOUR LIMIT EXCEEDED: Crew member cannot work more than 14 hours per day. '
            || 'Current hours: ' || v_existing_hours
            || ', Attempted to add: ' || :NEW.dutyHours);
    END IF;
END trg_max_daily_hours;
/

-- 10.2  Log new flight insertions into an audit table
CREATE TABLE Flight_Audit (
    audit_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    flight_id   NUMBER,
    flightNumber VARCHAR2(15),
    action      VARCHAR2(10),
    action_time TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE OR REPLACE TRIGGER trg_flight_audit
AFTER INSERT OR UPDATE OR DELETE ON Flight
FOR EACH ROW
DECLARE
    v_action VARCHAR2(10);
BEGIN
    IF    INSERTING THEN v_action := 'INSERT';
    ELSIF UPDATING  THEN v_action := 'UPDATE';
    ELSE                 v_action := 'DELETE';
    END IF;

    INSERT INTO Flight_Audit (flight_id, flightNumber, action)
    VALUES (
        NVL(:NEW.id,      :OLD.id),
        NVL(:NEW.flightNumber, :OLD.flightNumber),
        v_action
    );
END trg_flight_audit;
/

-- Test trigger: insert a flight and check audit
INSERT INTO Flight VALUES (seq_flight.NEXTVAL, 'AI-999', 'Mumbai', 'Bengaluru',
    TIMESTAMP '2026-06-01 06:00:00', TIMESTAMP '2026-06-01 07:30:00', 2);
COMMIT;

SELECT * FROM Flight_Audit;

-- ============================================================
-- SECTION 11 : PL/SQL – CURSOR EXAMPLE (Duty Report)
-- ============================================================

DECLARE
    CURSOR c_report IS
        SELECT c.name, c.role,
               f.flightNumber, f.source, f.destination,
               da.dutyDate, da.dutyHours
        FROM   Duty_Assignment da
        JOIN   Crew   c ON da.crewId   = c.id
        JOIN   Flight f ON da.flightId = f.id
        ORDER  BY da.dutyDate, c.name;

    v_line VARCHAR2(200);
BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD('=',80,'='));
    DBMS_OUTPUT.PUT_LINE('           CREW DUTY ASSIGNMENT REPORT');
    DBMS_OUTPUT.PUT_LINE(RPAD('=',80,'='));
    DBMS_OUTPUT.PUT_LINE(
        RPAD('NAME',20) || RPAD('ROLE',12) || RPAD('FLIGHT',10) ||
        RPAD('FROM',15) || RPAD('TO',15) || RPAD('DATE',14) || 'HRS'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-',80,'-'));

    FOR r IN c_report LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.name,20)          ||
            RPAD(r.role,12)          ||
            RPAD(r.flightNumber,10)  ||
            RPAD(r.source,15)        ||
            RPAD(r.destination,15)   ||
            RPAD(TO_CHAR(r.dutyDate,'DD-MON-YY'),14) ||
            r.dutyHours
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(RPAD('=',80,'='));
END;
/

-- ============================================================
-- SECTION 12 : ADVANCED QUERIES
-- ============================================================

-- A1: Most experienced crew per role
SELECT role, name, licenseNo, experienceYears
FROM (
    SELECT role, name, licenseNo, experienceYears,
           RANK() OVER (PARTITION BY role ORDER BY experienceYears DESC) AS rnk
    FROM   Crew
)
WHERE rnk = 1;

-- A2: Flights with complete crew (at least Pilot + Co-Pilot + Cabin Crew)
SELECT f.flightNumber, f.source, f.destination,
       SUM(CASE WHEN c.role = 'Pilot'      THEN 1 ELSE 0 END) AS pilots,
       SUM(CASE WHEN c.role = 'Co-Pilot'   THEN 1 ELSE 0 END) AS copilots,
       SUM(CASE WHEN c.role = 'Cabin Crew' THEN 1 ELSE 0 END) AS cabin
FROM   Flight f
JOIN   Duty_Assignment da ON f.id = da.flightId
JOIN   Crew c ON da.crewId = c.id
GROUP  BY f.flightNumber, f.source, f.destination
HAVING SUM(CASE WHEN c.role = 'Pilot'      THEN 1 ELSE 0 END) >= 1
AND    SUM(CASE WHEN c.role = 'Co-Pilot'   THEN 1 ELSE 0 END) >= 1
AND    SUM(CASE WHEN c.role = 'Cabin Crew' THEN 1 ELSE 0 END) >= 1;

-- A3: Crew who have NEVER been assigned a flight
SELECT c.id, c.name, c.role, c.licenseNo
FROM   Crew c
WHERE  c.id NOT IN (SELECT DISTINCT crewId FROM Duty_Assignment);

-- A4: Running total of duty hours per crew member (window function)
SELECT c.name, f.flightNumber, da.dutyDate, da.dutyHours,
       SUM(da.dutyHours) OVER (
           PARTITION BY da.crewId
           ORDER BY da.dutyDate
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total_hours
FROM   Duty_Assignment da
JOIN   Crew   c ON da.crewId   = c.id
JOIN   Flight f ON da.flightId = f.id
ORDER  BY da.crewId, da.dutyDate;

-- A5: Aircraft with highest average flight duration (in hours)
SELECT a.model, a.manufacturer,
       COUNT(f.id) AS total_flights,
       ROUND(AVG(
           (CAST(f.arrivalTime AS DATE) - CAST(f.departureTime AS DATE)) * 24
       ), 2) AS avg_duration_hrs
FROM   Aircraft a
JOIN   Flight f ON a.id = f.aircraftId
GROUP  BY a.model, a.manufacturer
ORDER  BY avg_duration_hrs DESC;

-- ============================================================
-- SECTION 13 : INTEGRITY TEST CASES
-- ============================================================

-- TEST 1: Try assigning same crew to same flight on same date (should fail)
BEGIN
    sp_assign_duty(1, 1, DATE '2026-05-01', 2.17);
END;
/

-- TEST 2: Try inserting crew with invalid role (should fail - check constraint)
BEGIN
    INSERT INTO Crew VALUES (seq_crew.NEXTVAL, 'Test Person', 'Ground Staff',
                             'LIC-999', 2, '1234567890');
END;
/

-- TEST 3: Try inserting flight with arrival before departure (should fail)
BEGIN
    INSERT INTO Flight VALUES (seq_flight.NEXTVAL, 'AI-000', 'Delhi', 'Mumbai',
        TIMESTAMP '2026-05-10 10:00:00', TIMESTAMP '2026-05-10 09:00:00', 1);
END;
/

-- ============================================================
-- END OF SCRIPT
-- ============================================================
COMMIT;
SELECT 'Database System Deployed Successfully!' AS status FROM DUAL;
