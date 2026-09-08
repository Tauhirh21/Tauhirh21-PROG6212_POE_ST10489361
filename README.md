# RaceDay - Event Management System

**PROG6212 Portfolio of Evidence - Part 1**

---

## Project Description

RaceDay is a full-stack web-based event management system designed specifically for the South African road running, walking, and cycling community. The platform allows Event Organisers to capture and manage events, categories, and participant results, while Participants can browse upcoming events, enter events, track their personal performance history, and prepare for race day.

---

## User Roles

### Organiser
- Create, edit, and delete events
- Manage event categories
- Capture participant results
- View all event enrolments

### Participant
- Create an account
- Browse events
- Enter an event by selecting a category
- View their own enrolments
- Track their personal  results

---

## Part 1 Deliverables

All planning documents are stored in the `/docs` folder:

| File | Description |
|------|-------------|
| `ERD_RaceDay.png` | Entity Relationship Diagram showing all 6 entities, attributes, and relationships |
| `API_Endpoint_Plan.md` | Complete API endpoint specification with HTTP methods, routes, role requirements, request/response formats |
| `RaceDay_Schema_Seed.sql` | SQL script to create the database schema and seed with sample data |

---

## CI/CD Status

![CI/CD Green Build](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/validate-docs.yml/badge.svg)

*Screenshot of successful build:*

![Green Build Screenshot](docs/green-build.png)

---

## Video Presentation

[Watch the walkthrough video](https://youtu.be/YOUR_VIDEO_LINK_HERE)

---

## Setup Instructions

### Prerequisites
- SQL Server (Local or School server)
- SQL Server Management Studio (SSMS)
- Visual Studio 2022
- Git

### Running the SQL Script
1. Open SSMS and connect to your SQL Server instance
2. Open the file `docs/RaceDay_Schema_Seed.sql`
3. Execute the script (F5)
4. Verify all tables and data are created successfully

### Repository Structure