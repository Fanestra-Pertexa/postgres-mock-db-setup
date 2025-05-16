CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TYPE user_role AS ENUM ('Patient', 'Provider', 'CareNavigator', 'Admin');
CREATE TYPE user_status AS ENUM ('Active', 'Inactive', 'Suspended');
CREATE TYPE patient_sync_status AS ENUM ('CREATED_PENDING_SYNC', 'CREATED_SYNC', 'Inactive', 'FAILED_SYNC');
CREATE TYPE gender_enum AS ENUM ('Male', 'Female', 'Other');
CREATE TYPE currency_enum AS ENUM ('USD', 'CAD', 'INR');
CREATE TYPE session_status_enum AS ENUM ('Active', 'Completed', 'Cancelled');
CREATE TYPE telehealth_role_enum AS ENUM ('Host', 'Guest', 'Moderator');
CREATE TYPE transaction_type_enum AS ENUM ('Credit', 'Debit');

CREATE TABLE "user" (
  user_id UUID PRIMARY KEY,
  user_role user_role,
  user_role_text VARCHAR,
  status user_status,
  status_text VARCHAR,
  created_at_utc TIMESTAMP,
  updated_at_utc TIMESTAMP
);

CREATE TABLE auth0_identities (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES "user"(user_id),
  auth0_id VARCHAR,
  connection VARCHAR,
  connection_name VARCHAR,
  created_at_utc TIMESTAMP,
  updated_at_utc TIMESTAMP
);

CREATE TABLE patient (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES "user"(user_id),
  auth0_id UUID,
  fhir_resource_id UUID,
  email VARCHAR,
  phone_e164 VARCHAR,
  fname VARCHAR,
  mname VARCHAR,
  lname VARCHAR,
  date_of_birth DATE,
  locale VARCHAR,
  profile_image_url VARCHAR,
  sync_attempts INT,
  status patient_sync_status,
  iscorporate BOOLEAN,
  created_at_utc TIMESTAMP,
  updated_at_utc TIMESTAMP
);

CREATE TABLE address (
  address_id UUID PRIMARY KEY,
  user_id UUID REFERENCES "user"(user_id),
  address_line_1 VARCHAR,
  address_line_2 VARCHAR,
  city VARCHAR,
  state VARCHAR,
  country VARCHAR,
  zipcode VARCHAR,
  created_at_utc TIMESTAMP,
  updated_at_utc TIMESTAMP
);

CREATE TABLE partner (
  partner_id UUID PRIMARY KEY,
  partner_name VARCHAR,
  metadata JSONB,
  is_active BOOLEAN,
  created_at_utc TIMESTAMP,
  updated_at_utc TIMESTAMP
);

CREATE TABLE partner_patient (
  partner_id UUID REFERENCES partner(partner_id),
  id UUID REFERENCES patient(id),
  is_active BOOLEAN,
  created_at_utc TIMESTAMP,
  updated_at_utc TIMESTAMP
);

CREATE TABLE provider (
  provider_id UUID PRIMARY KEY,
  user_id UUID REFERENCES "user"(user_id),
  speciality JSONB,
  gender_id gender_enum,
  gender_name VARCHAR,
  is_available BOOLEAN,
  state_license_code VARCHAR,
  emergency_contact_phone_e164 VARCHAR,
  preferred_language_id UUID,
  created_at_utc TIMESTAMP,
  updated_at_utc TIMESTAMP
);

CREATE TABLE language (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES "user"(user_id),
  language_label VARCHAR
);

CREATE TABLE provider_license_information (
  id UUID PRIMARY KEY,
  provider_id UUID REFERENCES provider(provider_id),
  state_license_code VARCHAR,
  state_license_number VARCHAR,
  expiry_date DATE,
  created_at_utc TIMESTAMP,
  updated_at_utc TIMESTAMP
);

CREATE TABLE client (
  id UUID PRIMARY KEY,
  name VARCHAR,
  metadata JSONB,
  created_at_utc TIMESTAMP,
  updated_at_utc TIMESTAMP
);

CREATE TABLE roborita_machine (
  id UUID PRIMARY KEY,
  address_line1 VARCHAR,
  address_line2 VARCHAR,
  city VARCHAR,
  state_code VARCHAR,
  country VARCHAR,
  serial_number VARCHAR,
  model_number VARCHAR,
  installation_date DATE,
  client_id UUID REFERENCES client(id),
  remote_access_config JSONB,
  created_at_utc TIMESTAMP,
  updated_at_utc TIMESTAMP
);

CREATE TABLE revenue_shares (
  id UUID PRIMARY KEY,
  roborita_d UUID REFERENCES roborita_machine(id),
  configuration JSONB,
  created_at_utc TIMESTAMP,
  updated_at_utc TIMESTAMP
);

CREATE TABLE telehealth_session (
  id UUID PRIMARY KEY,
  room_name VARCHAR,
  room_url VARCHAR,
  api_session_id VARCHAR,
  wait_time_mins INT,
  triage_time_mins INT,
  duration INT,
  current_visit_metadata JSONB,
  who_ended_session UUID REFERENCES "user"(user_id),
  renewal_numbers INT,
  payment_transaction_ids JSONB,
  status session_status_enum,
  created_at_utc TIMESTAMP,
  updated_at_utc TIMESTAMP
);

CREATE TABLE telehealth_participant (
  id UUID PRIMARY KEY,
  session_id UUID REFERENCES telehealth_session(id),
  user_id UUID REFERENCES "user"(user_id),
  telehealth_api_participant_id UUID,
  telehealth_api_role telehealth_role_enum,
  joined_at_utc TIMESTAMP,
  telehealth_api_token VARCHAR,
  left_at_utc TIMESTAMP,
  created_at_utc TIMESTAMP,
  updated_at_utc TIMESTAMP
);

CREATE TABLE partner_account (
  id UUID PRIMARY KEY,
  partner_id UUID REFERENCES partner(partner_id),
  current_balance NUMERIC,
  created_on_utc TIMESTAMP,
  modified_on_utc TIMESTAMP
);

CREATE TABLE partner_price_breakup (
  id UUID PRIMARY KEY,
  partner_id UUID REFERENCES partner(partner_id),
  timeslot_duration INT,
  cost_in_credits DOUBLE PRECISION,
  cost_in_dcurrency DOUBLE PRECISION,
  currency currency_enum,
  is_active BOOLEAN,
  created_on_utc TIMESTAMP,
  modified_on_utc TIMESTAMP
);

CREATE TABLE account_transaction (
  id UUID PRIMARY KEY,
  account_id UUID REFERENCES partner_account(id),
  stripe_transaction_id VARCHAR,
  transaction_type transaction_type_enum,
  amount DOUBLE PRECISION,
  created_on_utc TIMESTAMP,
  modified_on_utc TIMESTAMP
);