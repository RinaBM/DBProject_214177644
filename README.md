# DBProject_214177644
# SmartRoute – Guided Travel Routes Management System

## Table of Contents

- [Phase 1: Design and Build the Database](#phase-1-design-and-build-the-database)
  - [Introduction](#introduction)
  - [Purpose of the Database](#purpose-of-the-database)
  - [Potential Use Cases](#potential-use-cases)
  - [Application Screens](#application-screens)
  - [ERD Entity-Relationship Diagram](#erd-entity-relationship-diagram)
  - [DSD Data Structure Diagram](#dsd-data-structure-diagram)
  - [Database Design 3NF](#database-design-3nf)
  - [SQL Scripts](#sql-scripts)
  - [Data](#data)
  - [Backup](#backup)
- [Phase 2: Integration](#phase-2-integration)

---

# Phase 1: Design and Build the Database

## Introduction

SmartRoute is a database system designed to manage guided travel routes and organized tours.

The system allows travel companies and tour organizers to manage travel routes, tourist sites, guided tours, guides, travelers, and bookings in a structured and reliable way.

The main goal of the system is to organize all information related to guided tours in one database, while preserving data consistency, avoiding duplication, and supporting future integration with other systems.

---

## Purpose of the Database

This database serves as a structured solution for managing guided travel activities.

The system allows:

- Creating and managing travel routes.
- Managing tourist sites and attractions.
- Connecting sites to routes.
- Scheduling guided tours based on existing routes.
- Assigning guides to guided tours.
- Managing travelers.
- Registering travelers to guided tours.
- Tracking bookings and payment status.

---

## Potential Use Cases

### Travel Company Managers

Managers can create new routes, add sites to each route, schedule guided tours, assign guides, and monitor bookings.

### Tour Guides

Guides can be assigned to guided tours and can view information about the tours they lead.

### Travelers

Travelers can be registered in the system and connected to bookings for guided tours.

### System Administrators

Administrators can manage all data in the system, including routes, sites, guides, travelers, tours, and bookings.

---

# Application Screens

The following screens were created using Google AI Studio as a visual prototype for the SmartRoute system.

---

## Screen 1 – Dashboard

The dashboard displays a general overview of the system, including active routes, tours, bookings, and general statistics.

Relevant entities:

- ROUTE
- GUIDEDTOUR
- BOOKING
- USERS

![Dashboard Screen](./שלב%20א/screens/dashboard.png)

---

## Screen 2 – Routes Management

This screen allows the manager to view and manage travel routes.

Each route includes information such as route name, difficulty level, estimated duration, distance, and description.

Relevant entities:

- ROUTE
- ROUTESITE
- SITE

![Routes Screen](./שלב%20א/screens/routes.png)

---

## Screen 3 – Sites Management

This screen allows the manager to manage tourist sites and attractions that can be included in travel routes.

Each site includes location details, category, and description.

Relevant entities:

- SITE
- ROUTESITE

![Sites Screen](./שלב%20א/screens/sites.png)

---

## Screen 4 – Guided Tours Management

This screen allows the manager to schedule guided tours based on existing routes and assign guides to them.

The screen supports tour status management such as upcoming tours, past tours, and drafts.

Relevant entities:

- GUIDEDTOUR
- GUIDE
- ROUTE

![Tours Screen](./שלב%20א/screens/tours.png)

---

## Screen 5 – Travelers Management

This screen allows the manager to manage travelers in the system.

Travelers can later be connected to bookings for guided tours.

Relevant entities:

- USERS
- BOOKING

![Travelers Screen](./שלב%20א/screens/travelers.png)

---

## Screen 6 – Bookings Management

This screen allows the manager to view and manage tour registrations.

Each booking connects a traveler to a guided tour and includes the number of participants and payment status.

Relevant entities:

- BOOKING
- USERS
- GUIDEDTOUR

![Bookings Screen](./שלב%20א/screens/bookings.png)

---

# ERD Entity-Relationship Diagram

The ERD describes the main entities in the SmartRoute system and the relationships between them.

Main entities:

- USERS
- GUIDE
- ROUTE
- SITE
- ROUTESITE
- GUIDEDTOUR
- BOOKING

Main relationships:

- A route can have many guided tours.
- A guide can lead many guided tours.
- A user can make many bookings.
- A guided tour can have many bookings.
- A route can include many sites.
- A site can appear in many routes.
- The relationship between ROUTE and SITE is represented by the ROUTESITE table.

[View ERD Diagram](./שלב%20א/diagrams/ERD.png)

![ERD Diagram](./שלב%20א/diagrams/ERD.png)

---

# DSD Data Structure Diagram

The DSD describes the final relational schema of the database, including tables, primary keys, foreign keys, and relationships.

[View DSD Diagram](./שלב%20א/diagrams/DSD.png)

![DSD Diagram](./שלב%20א/diagrams/DSD.png)

---

# Database Design 3NF

The database schema was normalized to at least Third Normal Form, 3NF.

The schema avoids unnecessary data duplication by separating the data into independent tables.

For example:

- Traveler information is stored only in the USERS table.
- Guide information is stored only in the GUIDE table.
- Route information is stored only in the ROUTE table.
- Site information is stored only in the SITE table.
- Booking information is stored only in the BOOKING table.
- The many-to-many relationship between ROUTE and SITE is implemented using the ROUTESITE bridge table.

This structure helps maintain data integrity and prevents update, insert, and delete anomalies.

---

# Core Entities

## USERS

Stores information about travelers in the system.

Main fields:

- user_id
- full_name
- email
- phone

---

## GUIDE

Stores information about tour guides.

Main fields:

- guide_id
- full_name
- phone
- email
- languages

---

## ROUTE

Stores information about travel routes.

Main fields:

- route_id
- route_name
- difficulty_level
- estimated_duration
- distance
- description

---

## SITE

Stores information about tourist sites and attractions.

Main fields:

- site_id
- site_name
- country
- city
- category
- description

---

## ROUTESITE

Represents the many-to-many relationship between routes and sites.

Main fields:

- route_id
- site_id
- visit_order

---

## GUIDEDTOUR

Stores information about scheduled guided tours.

Main fields:

- guided_tour_id
- start_date
- max_participants
- price
- status
- route_id
- guide_id

---

## BOOKING

Stores information about traveler registrations to guided tours.

Main fields:

- booking_id
- booking_date
- number_of_participants
- payment_status
- user_id
- guided_tour_id

---

# SQL Scripts

The following SQL scripts are included in the repository:

## Create Tables Script

The SQL script for creating the database tables is available in the repository:

[View createTables.sql](./שלב%20א/createTables.sql)

---

## Insert Data Script

The SQL script for inserting initial data into the database tables is available in the repository:

[View insertTables.sql](./שלב%20א/insertTables.sql)

---

## Drop Tables Script

The SQL script for dropping all tables is available in the repository:

[View dropTables.sql](./שלב%20א/dropTables.sql)

---

## Select All Data Script

The SQL script for selecting all data from all tables is available in the repository:

[View selectAll.sql](./שלב%20א/selectAll.sql)

---

# Data

The database is populated using several data insertion methods.

## First Method – Manual SQL Inserts

Manual insert commands are written in the file insertTables.sql.

This file contains initial sample records for each table.

[View insertTables.sql](./שלב%20א/insertTables.sql)

---

## Second Method – Python Script

A Python script is used to generate and insert a large amount of data directly into the PostgreSQL database.

This method is used to generate large tables with many records.

The script files are stored in the Programing folder.

[View Programing Folder](./שלב%20א/Programing)

---

## Third Method – CSV Import

CSV files are used to import data into the database.

The CSV files are stored in the DataImportFiles folder.

[View DataImportFiles Folder](./שלב%20א/DataImportFiles)

---

## External Data Generation Tool

Mockaroo or another external data generation tool can be used to generate CSV files or insert scripts.

The generated files are stored in the mockarooFiles folder.

[View mockarooFiles Folder](./שלב%20א/mockarooFiles)

---

# Planned Record Counts

The database is planned to include at least 500 records in each table.

In addition, at least two tables will include 20,000 records.

Suggested large tables:

| Table | Planned Number of Records |
|---|---:|
| USERS | 20,000 |
| BOOKING | 20,000 |
| ROUTE | 500 |
| SITE | 500 |
| GUIDE | 500 |
| GUIDEDTOUR | 500 |
| ROUTESITE | 500+ |

---

# Backup

Database backups will be created and saved with the date of the backup.

Two backup methods will be used:

1. Logical backup using pg_dump.
2. Backup using pgAdmin or Docker volume backup.

Backup files will be stored in the backup folder.

[View Backup Folder](./שלב%20א/backup)

---

# Technologies

- Database: PostgreSQL
- Backend: Node.js + Express
- Frontend: React
- Containerization: Docker & Docker Compose
- Database UI Tool: pgAdmin
- Data Generation: Python, CSV files, Mockaroo
- Development Environment: PyCharm / VS Code

---

# Getting Started

## Prerequisites

- Docker
- Docker Compose
- PostgreSQL / pgAdmin

---

## Running the Environment

To start the database environment, run:

```bash
docker compose up -d