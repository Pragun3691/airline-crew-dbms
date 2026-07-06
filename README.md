# Airline Crew Allocation & Duty Scheduling — DBMS Project (UCS310)

Course team project (3 members: Muskan, Zaira Iqbal, Pragun Aggarwal) — Thapar, 4th semester. Kept as a private archive and DBMS revision anchor.

**My part:** End-to-end — the ER design, relational schema, SQL implementation, the PL/SQL layer (procedures, functions, triggers), and the synopsis document. Built with AI-assisted tooling; this archive doubles as my DBMS revision material, which I'm working through line by line.

## What's inside
- `airline_crew_livesql.sql` — full build script: 9 tables normalized to BCNF, sample data, 3 stored procedures (`sp_add_crew`, `sp_assign_duty`, `sp_flight_crew`), 2 functions (`fn_total_duty_hours`, `fn_is_available`), and triggers including `trg_max_daily_hours` (blocks assignments beyond duty-hour limits) and `trg_flight_audit`.
- `docs/DBMS_Synopsis.pdf` — ER model, functional dependencies, normalization walkthrough to BCNF.

## Why it's archived
Worked, runnable examples of normalization, integrity constraints, stored procedures, and triggers — revision material for DBMS interview prep (Aug–Sep 2026).
