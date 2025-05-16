Setup Guide: Postgres Mock DB with pgAdmin

This guide walks you through setting up a PostgreSQL mock database along with pgAdmin using Docker Compose. 
You will be able to run a PostgreSQL server with preloaded data and access it via a web-based pgAdmin interface.

1. Prerequisites

- Docker and Docker Compose must be installed.
- This guide assumes the project directory includes:
  - `docker-compose.yml`
  - `init/01_init_schema.sql`
  - `init/02_complete_sample_data.sql`

2. Folder Structure

Ensure your project folder has the following structure:

project-root/
├── docker-compose.yml
└── init/
    ├── 01_init_schema.sql
    └── 02_complete_sample_data.sql

3. Docker Compose Setup

The docker-compose.yml includes two services:
- `db`: A PostgreSQL 16 container seeded with mock data
- `pgadmin`: A pgAdmin 4 web interface to manage your database

Make sure your `docker-compose.yml` has the following relevant content:


services:
  db:
    image: postgres:16
    container_name: mock_postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: mockdb
    ports:
      - "5432:5432"
    volumes:
      - ./init:/docker-entrypoint-initdb.d
      - pg_data:/var/lib/postgresql/data

  pgadmin:
    image: dpage/pgadmin4
    container_name: mock_pgadmin
    ports:
      - "5050:80"
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@example.com
      PGADMIN_DEFAULT_PASSWORD: admin
    depends_on:
      - db

volumes:
  pg_data:

4. Running the Setup

In a terminal, navigate to your project directory and run:

docker compose down -v  # optional, to reset everything
docker compose up --build

Wait until you see logs confirming tables and inserts were successful.

5. Accessing pgAdmin

Open http://localhost:5050 in your browser.

Login using:
- Email: admin@example.com
- Password: admin

Register a new server in pgAdmin:
- Name: mockdb
- Host: db
- Port: 5432
- Maintenance DB: mockdb
- Username: postgres
- Password: postgres

Save and connect. You will now see all tables and data inside pgAdmin.

6. Tips

- If you get connection errors in pgAdmin, clear the master password cache.
- If data doesn't appear, ensure your `init` files executed correctly.
- If stuck, run `docker compose down -v` to reset and retry.
