# DBProject_214177644

# SmartRoute – Guided Travel Routes Management System

## Table of Contents

1. [Introduction](#introduction)
2. [System Purpose](#system-purpose)
3. [Application Screens](#application-screens)
4. [ERD Diagram](#erd-diagram)
5. [DSD Diagram](#dsd-diagram)
6. [Database Design – 3NF](#database-design--3nf)
7. [SQL Scripts](#sql-scripts)
8. [Data Insertion Methods](#data-insertion-methods)
9. [Backup](#backup)
10. [Technologies](#technologies)

---

## Introduction

SmartRoute is a database system designed for managing guided travel routes and organized tours.

The system allows travel companies and tour organizers to manage routes, tourist sites, guided tours, guides, travelers, and bookings in a structured and reliable way.

The database stores all main information required for planning and managing guided tours, while keeping the data organized, consistent, and easy to maintain.

---

## System Purpose

The system supports the following main actions:

* Creating and managing travel routes.
* Managing tourist sites and attractions.
* Connecting sites to routes.
* Scheduling guided tours according to existing routes.
* Assigning guides to guided tours.
* Managing travelers.
* Registering travelers to guided tours.
* Tracking bookings and payment status.

---

## Application Screens

The following screens were created using Google AI Studio as a visual prototype for the SmartRoute system.

link to my website: https://aistudio.google.com/apps/664d5084-b6b3-46bc-a42e-04a17ecb6ce5?showAssistant=true&showPreview=true&fullscreenApplet=true

### Dashboard

The dashboard displays a general overview of the system, including routes, bookings, and general statistics.

![Dashboard](./שלב%20א/screens/dashboard.png)

### Routes Management

This screen allows the manager to view and manage travel routes.

![Routes](./שלב%20א/screens/routes.png)

### Sites Management

This screen allows the manager to manage tourist sites and attractions.

![Sites](./שלב%20א/screens/sites.png)

### Travelers Management

This screen allows the manager to manage travelers in the system.

![Travelers](./שלב%20א/screens/travelers.png)

### Bookings Management

This screen allows the manager to view and manage tour registrations.

![Bookings](./שלב%20א/screens/bookings.png)

---

## ERD Diagram

The ERD describes the main entities in the SmartRoute system and the relationships between them.

Main entities:

* USERS
* GUIDE
* ROUTE
* SITE
* ROUTESITE
* GUIDEDTOUR
* BOOKING

Main relationships:

* A route can have many guided tours.
* A guide can lead many guided tours.
* A user can make many bookings.
* A guided tour can have many bookings.
* A route can include many sites.
* A site can appear in many routes.
* ROUTESITE represents the many-to-many relationship between ROUTE and SITE.

![ERD Diagram](./שלב%20א/diagrams/ERD.png)

---

## DSD Diagram

The DSD presents the final relational schema, including tables, primary keys, foreign keys, and relationships.

![DSD Diagram](./שלב%20א/diagrams/DSD.png)

---

## Database Design – 3NF

The database schema is normalized to at least Third Normal Form, 3NF.

The design separates the data into independent tables in order to reduce duplication and prevent update, insert, and delete anomalies.

Examples:

* Traveler information is stored only in the USERS table.
* Guide information is stored only in the GUIDE table.
* Route information is stored only in the ROUTE table.
* Site information is stored only in the SITE table.
* Booking information is stored only in the BOOKING table.
* The many-to-many relationship between ROUTE and SITE is implemented using the ROUTESITE table.

---

## SQL Scripts

The following SQL scripts are included in the repository:

| File                                           | Description                                                                         |
| ---------------------------------------------- | ----------------------------------------------------------------------------------- |
| [createTables.sql](./שלב%20א/createTables.sql) | Creates all database tables, including primary keys, foreign keys, and constraints. |
| [dropTables.sql](./שלב%20א/dropTables.sql)     | Drops all tables in the correct order.                                              |
| [insertTables.sql](./שלב%20א/insertTables.sql) | Inserts initial manual sample data.                                                 |
| [selectAll.sql](./שלב%20א/selectAll.sql)       | Selects all data from all tables.                                                   |

---

## Data Insertion Methods

The database was populated using three different data insertion methods.

---

### Method 1 – Python Data Generation

A Python script was used to generate and insert a large amount of data directly into the PostgreSQL database.

The script is stored in the `programming` folder:

[generateData.py](./שלב%20א/programming/generateData.py)

Final record counts after running the Python script:

| Table      | Number of Records |
| ---------- | ----------------: |
| USERS      |            20,020 |
| BOOKING    |            20,020 |
| GUIDE      |               520 |
| ROUTE      |               520 |
| SITE       |               520 |
| GUIDEDTOUR |               520 |
| ROUTESITE  |               521 |

This satisfies the requirement of at least 500 records in each table and at least 20,000 records in two tables.

Screenshot:

![Python Insert](./שלב%20א/screens/pyInsert.png)

---

### Method 2 – Mockaroo CSV Generation

Mockaroo was used as an external data generation tool.

A CSV file was generated for the GUIDE table.

The generated CSV file includes the following fields:

* guide_id
* full_name
* phone
* email
* languages

The file is stored in the `programming` folder:

[mockaroo_guides.csv](./שלב%20א/programming/mockaroo_guides.csv)

Screenshot:

![Mockaroo Insert](./שלב%20א/screens/mockarooInsert.png)

---

### Method 3 – Manual SQL Inserts

Manual SQL insert commands were written in the file `insertTables.sql`.

This file contains sample `INSERT` commands for the database tables.

File:

[insertTables.sql](./שלב%20א/insertTables.sql)

Screenshot:

![SQL Insert](./שלב%20א/screens/SQLInsert.png)

---

## Backup

Two backup methods were used for the database.

---

### Method 1 – SQL Backup using pg_dump

A logical SQL backup was created using the PostgreSQL `pg_dump` command.

The backup file is stored in the `backup` folder:

[backup_2026_05_27.sql](./שלב%20א/backup/backup_2026_05_27.sql)

This file is a readable SQL backup file.

Screenshot:

![SQL Backup](./שלב%20א/screens/SQLbackup.png)

---

### Method 2 – pgAdmin Custom Backup

A second backup was created using pgAdmin in custom backup format.

The backup file is stored in the `backup` folder:

[backup_pgadmin_2026_05_27.backup](./שלב%20א/backup/backup_pgadmin_2026_05_27.backup)

This file is a PostgreSQL custom backup file and is not meant to be read as plain text.

Screenshot:

![pgAdmin Backup](./שלב%20א/screens/pgBackup.png)

---

Both backup files were saved in the project repository under the `backup` folder.

---

## Technologies

* Database: PostgreSQL
* Database UI Tool: pgAdmin
* Containerization: Docker & Docker Compose
* Data Generation: Python, Mockaroo, CSV
* Development Environment: PyCharm / VS Code
* Frontend Prototype: React-based design created using Google AI Studio

---

## Running the Environment

To start the database environment, run:

```bash
docker compose up -d --build
```

To reset the database completely and recreate it from the initialization files:

```bash
docker compose down -v
docker compose up -d --build
```

After running the environment, pgAdmin is available at:

```text
http://localhost:8080
```
