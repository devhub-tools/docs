-- =============================================================================
-- QUERYDESK SAMPLE DATABASE: Pinnacle Trust Financial Group (PTFG)
-- A fictional bank for evaluating QueryDesk. All data is fabricated: names,
-- SSNs, card numbers, account numbers, and routing numbers are not real.
--
-- WHAT THIS SCRIPT DOES
--   1. Creates 10 tables, 4 views, and sample data in the public schema.
--   2. Creates two login roles, each with a randomly generated password:
--        querydesk_readonly   can read data only
--        querydesk_readwrite  can read, insert, update, and delete data
--      Neither role can create, alter, or drop objects.
--   3. Returns both usernames and passwords as the final result. Use
--      querydesk_readonly when you first connect QueryDesk.
--
-- RUN IT ONLY ON A NEW, EMPTY DATABASE. It creates objects and a role; it does
-- not delete anything. If any of its objects or the role already exist, the
-- script stops with an error.
--
-- Requires PostgreSQL 13 or later.
-- =============================================================================

SET search_path TO public;

-- =============================================================================
-- ENUMS
-- =============================================================================

CREATE TYPE account_type_enum   AS ENUM ('CHECKING', 'SAVINGS', 'MONEY_MARKET', 'CD', 'LOAN');
CREATE TYPE account_status_enum AS ENUM ('ACTIVE', 'FROZEN', 'CLOSED', 'PENDING');
CREATE TYPE txn_type_enum       AS ENUM ('DEPOSIT', 'WITHDRAWAL', 'TRANSFER', 'PAYMENT', 'FEE', 'INTEREST', 'REVERSAL');
CREATE TYPE card_type_enum      AS ENUM ('DEBIT', 'CREDIT', 'PREPAID');
CREATE TYPE card_status_enum    AS ENUM ('ACTIVE', 'BLOCKED', 'EXPIRED', 'CANCELLED');
CREATE TYPE loan_status_enum    AS ENUM ('PENDING', 'APPROVED', 'ACTIVE', 'DEFAULTED', 'PAID_OFF', 'DECLINED');
CREATE TYPE branch_region_enum  AS ENUM ('NORTHEAST', 'SOUTHEAST', 'MIDWEST', 'SOUTHWEST', 'WEST');
CREATE TYPE emp_role_enum       AS ENUM ('TELLER', 'LOAN_OFFICER', 'BRANCH_MANAGER', 'ANALYST', 'COMPLIANCE', 'IT');
CREATE TYPE alert_type_enum     AS ENUM ('FRAUD', 'OVERDRAFT', 'LARGE_TRANSACTION', 'LOGIN_FAILURE', 'PII_ACCESS');

-- =============================================================================
-- TABLE: branches
-- =============================================================================
CREATE TABLE branches (
    branch_id       SERIAL PRIMARY KEY,
    branch_code     VARCHAR(10)         NOT NULL UNIQUE,
    branch_name     VARCHAR(100)        NOT NULL,
    region          branch_region_enum  NOT NULL,
    address_line1   VARCHAR(150)        NOT NULL,
    address_line2   VARCHAR(100),
    city            VARCHAR(80)         NOT NULL,
    state           CHAR(2)             NOT NULL,
    zip_code        VARCHAR(10)         NOT NULL,
    phone           VARCHAR(20)         NOT NULL,
    opened_date     DATE                NOT NULL,
    is_active       BOOLEAN             NOT NULL DEFAULT TRUE
);

INSERT INTO branches (branch_code, branch_name, region, address_line1, city, state, zip_code, phone, opened_date) VALUES
('BRN-001', 'Pinnacle Downtown',       'NORTHEAST', '400 Commerce Blvd',    'Harborfield',    'NY', '10021', '212-555-0101', '2001-03-15'),
('BRN-002', 'Pinnacle Midtown East',   'NORTHEAST', '88 Lexington Ave',     'Harborfield',    'NY', '10022', '212-555-0202', '2004-07-01'),
('BRN-003', 'Pinnacle Southgate',      'SOUTHEAST', '1200 Magnolia Pkwy',   'Cedarville',     'GA', '30301', '404-555-0303', '2006-11-20'),
('BRN-004', 'Pinnacle Lakeside',       'MIDWEST',   '75 Lakeshore Dr',      'Millbrook',      'IL', '60601', '312-555-0404', '2008-05-10'),
('BRN-005', 'Pinnacle Westfield',      'WEST',      '5500 Sunset Corridor', 'Valdera',        'CA', '90210', '310-555-0505', '2010-09-30'),
('BRN-006', 'Pinnacle Desert Springs', 'SOUTHWEST', '900 Mesa Verde Rd',    'Redstone',       'AZ', '85001', '602-555-0606', '2012-01-14'),
('BRN-007', 'Pinnacle North Harbor',   'NORTHEAST', '3 Wharf Street',       'Harborfield',    'NY', '10030', '212-555-0707', '2015-06-22'),
('BRN-008', 'Pinnacle Crossroads',     'MIDWEST',   '221 Elm Junction',     'Fairhaven',      'OH', '44101', '216-555-0808', '2017-03-09'),
('BRN-009', 'Pinnacle Bayview',        'WEST',      '1800 Bayfront Ave',    'Valdera',        'CA', '90211', '310-555-0909', '2019-08-05'),
('BRN-010', 'Pinnacle Pinehurst',      'SOUTHEAST', '480 Pinehurst Blvd',   'Cedarville',     'GA', '30302', '404-555-1010', '2021-02-28');

-- =============================================================================
-- TABLE: employees
-- =============================================================================
CREATE TABLE employees (
    employee_id     SERIAL PRIMARY KEY,
    branch_id       INT             NOT NULL REFERENCES branches(branch_id),
    first_name      VARCHAR(60)     NOT NULL,
    last_name       VARCHAR(60)     NOT NULL,
    ssn             CHAR(11)        NOT NULL UNIQUE,   -- FORMAT: XXX-XX-XXXX (FICTIONAL)
    email           VARCHAR(120)    NOT NULL UNIQUE,
    phone           VARCHAR(20),
    date_of_birth   DATE            NOT NULL,
    hire_date       DATE            NOT NULL,
    role            emp_role_enum   NOT NULL,
    salary          NUMERIC(12,2)   NOT NULL,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE
);

INSERT INTO employees (branch_id, first_name, last_name, ssn, email, phone, date_of_birth, hire_date, role, salary) VALUES
(1,  'Gerald',    'Thorne',     '112-48-9301', 'g.thorne@ptfg-internal.com',    '212-555-1001', '1972-04-12', '2005-06-01', 'BRANCH_MANAGER',  95000.00),
(1,  'Mariela',   'Voss',       '224-67-1182', 'm.voss@ptfg-internal.com',      '212-555-1002', '1988-09-22', '2011-03-15', 'TELLER',          42000.00),
(2,  'Desmond',   'Fitch',      '338-91-4473', 'd.fitch@ptfg-internal.com',     '212-555-1003', '1980-01-05', '2009-07-20', 'LOAN_OFFICER',    74000.00),
(3,  'Priya',     'Nambiar',    '445-23-7764', 'p.nambiar@ptfg-internal.com',   '404-555-1004', '1975-11-30', '2007-09-01', 'BRANCH_MANAGER',  97000.00),
(4,  'Luca',      'Bernetti',   '556-84-2255', 'l.bernetti@ptfg-internal.com',  '312-555-1005', '1993-07-14', '2018-01-10', 'TELLER',          40500.00),
(5,  'Tasha',     'Elmwood',    '667-35-9146', 't.elmwood@ptfg-internal.com',   '310-555-1006', '1985-03-27', '2013-05-22', 'ANALYST',         82000.00),
(6,  'Harold',    'Quint',      '778-56-3037', 'h.quint@ptfg-internal.com',     '602-555-1007', '1969-08-08', '2012-02-14', 'COMPLIANCE',      88000.00),
(7,  'Celeste',   'Morrow',     '889-12-6628', 'c.morrow@ptfg-internal.com',    '212-555-1008', '1991-12-01', '2016-11-30', 'TELLER',          41000.00),
(8,  'Ivan',      'Draskovic',  '990-43-5519', 'i.draskovic@ptfg-internal.com', '216-555-1009', '1983-06-18', '2017-04-05', 'LOAN_OFFICER',    76000.00),
(9,  'Yolanda',   'Ferris',     '101-74-8810', 'y.ferris@ptfg-internal.com',    '310-555-1010', '1977-02-24', '2020-08-17', 'IT',              91000.00),
(10, 'Nathaniel', 'Cross',      '202-85-9921', 'n.cross@ptfg-internal.com',     '404-555-1011', '1990-10-09', '2021-03-01', 'TELLER',          39500.00),
(1,  'Simone',    'Gallagher',  '313-96-1032', 's.gallagher@ptfg-internal.com', '212-555-1012', '1986-05-15', '2014-09-08', 'ANALYST',         84000.00);

-- =============================================================================
-- TABLE: customers
-- =============================================================================
CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    branch_id       INT             NOT NULL REFERENCES branches(branch_id),
    first_name      VARCHAR(60)     NOT NULL,
    last_name       VARCHAR(60)     NOT NULL,
    ssn             CHAR(11)        NOT NULL UNIQUE,   -- FORMAT: XXX-XX-XXXX (FICTIONAL)
    date_of_birth   DATE            NOT NULL,
    email           VARCHAR(120)    NOT NULL UNIQUE,
    phone           VARCHAR(20)     NOT NULL,
    address_line1   VARCHAR(150)    NOT NULL,
    address_line2   VARCHAR(100),
    city            VARCHAR(80)     NOT NULL,
    state           CHAR(2)         NOT NULL,
    zip_code        VARCHAR(10)     NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE
);

INSERT INTO customers (branch_id, first_name, last_name, ssn, date_of_birth, email, phone, address_line1, city, state, zip_code) VALUES
(1,  'Arthur',    'Pemberton',  '521-30-8847', '1968-07-22', 'a.pemberton@mailsim.net',  '917-555-2001', '14 Greystone Terrace',   'Harborfield',  'NY', '10021'),
(1,  'Diane',     'Lustig',     '634-21-9958', '1975-11-04', 'd.lustig@mailsim.net',     '917-555-2002', '77 Birchwood Lane',      'Harborfield',  'NY', '10022'),
(2,  'Omar',      'Rashidi',    '745-32-1069', '1990-03-15', 'o.rashidi@mailsim.net',    '646-555-2003', '203 Crescent Ave Apt 4B','Harborfield',  'NY', '10022'),
(3,  'Felicity',  'Crane',      '856-43-2170', '1983-09-28', 'f.crane@mailsim.net',      '404-555-2004', '50 Dogwood Drive',       'Cedarville',   'GA', '30301'),
(4,  'Marcus',    'Holloway',   '967-54-3281', '1971-01-09', 'm.holloway@mailsim.net',   '312-555-2005', '890 North Wacker Ct',    'Millbrook',    'IL', '60601'),
(5,  'Ingrid',    'Solberg',    '178-65-4392', '1995-06-17', 'i.solberg@mailsim.net',    '310-555-2006', '2211 Pacific Rim Way',   'Valdera',      'CA', '90210'),
(6,  'Jerome',    'Kauffman',   '289-76-5403', '1960-12-30', 'j.kauffman@mailsim.net',   '602-555-2007', '3 Cactus Wren Rd',       'Redstone',     'AZ', '85001'),
(7,  'Sabrina',   'Whitfield',  '390-87-6514', '1987-04-05', 's.whitfield@mailsim.net',  '212-555-2008', '19 Harbour Point Loop',  'Harborfield',  'NY', '10030'),
(8,  'Timothy',   'Nguyen',     '401-98-7625', '1978-08-19', 't.nguyen@mailsim.net',     '216-555-2009', '642 Maple Ridge Blvd',   'Fairhaven',    'OH', '44101'),
(9,  'Rosa',      'Mendenhall', '512-09-8736', '1992-02-11', 'r.mendenhall@mailsim.net', '310-555-2010', '5 Tidewater Court',      'Valdera',      'CA', '90211'),
(10, 'Franklin',  'Osei',       '623-10-9847', '1965-10-03', 'f.osei@mailsim.net',       '404-555-2011', '88 Loblolly Pine Dr',    'Cedarville',   'GA', '30302'),
(1,  'Vivienne',  'Ashworth',   '734-21-0958', '1980-05-27', 'v.ashworth@mailsim.net',   '917-555-2012', '5 Park Crescent',        'Harborfield',  'NY', '10021'),
(3,  'Derek',     'Tanaka',     '845-32-1069', '1973-03-14', 'd.tanaka@mailsim.net',     '404-555-2013', '120 Peach Orchard Rd',   'Cedarville',   'GA', '30301'),
(5,  'Monique',   'Delacroix',  '956-43-2170', '1988-11-22', 'm.delacroix@mailsim.net',  '310-555-2014', '77 Wilshire Blvd #900',  'Valdera',      'CA', '90210'),
(6,  'Patrick',   'Sundaram',   '167-54-3281', '1997-07-08', 'p.sundaram@mailsim.net',   '602-555-2015', '45 Sonoran Loop',        'Redstone',     'AZ', '85001');

-- =============================================================================
-- TABLE: accounts
-- =============================================================================
CREATE TABLE accounts (
    account_id      SERIAL PRIMARY KEY,
    customer_id     INT                 NOT NULL REFERENCES customers(customer_id),
    branch_id       INT                 NOT NULL REFERENCES branches(branch_id),
    account_number  VARCHAR(20)         NOT NULL UNIQUE,
    account_type    account_type_enum   NOT NULL,
    status          account_status_enum NOT NULL DEFAULT 'ACTIVE',
    balance         NUMERIC(15,2)       NOT NULL DEFAULT 0.00,
    interest_rate   NUMERIC(5,4),
    opened_date     DATE                NOT NULL,
    closed_date     DATE
);

INSERT INTO accounts (customer_id, branch_id, account_number, account_type, status, balance, interest_rate, opened_date) VALUES
(1,  1,  'PTFG-00100001', 'CHECKING',     'ACTIVE',  4825.33,   NULL,   '2005-02-10'),
(1,  1,  'PTFG-00100002', 'SAVINGS',      'ACTIVE',  18200.50,  0.0135, '2005-02-10'),
(2,  1,  'PTFG-00100003', 'CHECKING',     'ACTIVE',  2310.77,   NULL,   '2008-06-15'),
(3,  2,  'PTFG-00200001', 'CHECKING',     'ACTIVE',  7650.00,   NULL,   '2012-09-01'),
(3,  2,  'PTFG-00200002', 'MONEY_MARKET', 'ACTIVE',  52000.00,  0.0210, '2015-04-22'),
(4,  3,  'PTFG-00300001', 'SAVINGS',      'ACTIVE',  9450.88,   0.0120, '2010-11-30'),
(5,  4,  'PTFG-00400001', 'CHECKING',     'FROZEN',  125.40,    NULL,   '2009-03-17'),
(5,  4,  'PTFG-00400002', 'CD',           'ACTIVE',  25000.00,  0.0475, '2022-01-05'),
(6,  5,  'PTFG-00500001', 'CHECKING',     'ACTIVE',  3100.20,   NULL,   '2018-07-14'),
(7,  6,  'PTFG-00600001', 'SAVINGS',      'ACTIVE',  6600.00,   0.0130, '2013-05-05'),
(8,  7,  'PTFG-00700001', 'CHECKING',     'ACTIVE',  11240.85,  NULL,   '2016-12-20'),
(9,  8,  'PTFG-00800001', 'CHECKING',     'ACTIVE',  874.10,    NULL,   '2019-10-03'),
(9,  8,  'PTFG-00800002', 'SAVINGS',      'ACTIVE',  4310.00,   0.0115, '2020-01-15'),
(10, 9,  'PTFG-00900001', 'MONEY_MARKET', 'ACTIVE',  87500.00,  0.0195, '2017-08-28'),
(11, 10, 'PTFG-01000001', 'CHECKING',     'ACTIVE',  2200.60,   NULL,   '2021-03-10'),
(12, 1,  'PTFG-00100004', 'SAVINGS',      'ACTIVE',  33000.00,  0.0140, '2011-07-04'),
(13, 3,  'PTFG-00300002', 'CHECKING',     'CLOSED',  0.00,      NULL,   '2014-02-18'),
(14, 5,  'PTFG-00500002', 'CD',           'ACTIVE',  10000.00,  0.0460, '2023-03-01'),
(15, 6,  'PTFG-00600002', 'SAVINGS',      'ACTIVE',  1750.00,   0.0110, '2022-09-15');

-- =============================================================================
-- TABLE: payment_cards
-- =============================================================================
CREATE TABLE payment_cards (
    card_id         SERIAL PRIMARY KEY,
    account_id      INT             NOT NULL REFERENCES accounts(account_id),
    customer_id     INT             NOT NULL REFERENCES customers(customer_id),
    card_type       card_type_enum  NOT NULL,
    card_status     card_status_enum NOT NULL DEFAULT 'ACTIVE',
    card_number     VARCHAR(19)     NOT NULL UNIQUE,  -- FORMAT: XXXX-XXXX-XXXX-XXXX (FICTIONAL)
    cvv             CHAR(3)         NOT NULL,         -- FICTIONAL
    cardholder_name VARCHAR(120)    NOT NULL,
    expiry_month    SMALLINT        NOT NULL,
    expiry_year     SMALLINT        NOT NULL,
    issued_date     DATE            NOT NULL,
    credit_limit    NUMERIC(12,2),
    billing_address VARCHAR(200)
);

INSERT INTO payment_cards (account_id, customer_id, card_type, card_status, card_number, cvv, cardholder_name, expiry_month, expiry_year, issued_date, credit_limit, billing_address) VALUES
(1,  1,  'DEBIT',  'ACTIVE',     '4532-1188-0343-6467', '782', 'Arthur Pemberton',  12, 2027, '2023-01-10', NULL,      '14 Greystone Terrace, Harborfield, NY 10021'),
(3,  2,  'DEBIT',  'ACTIVE',     '4916-3384-9027-1154', '541', 'Diane Lustig',      08, 2026, '2022-08-15', NULL,      '77 Birchwood Lane, Harborfield, NY 10022'),
(4,  3,  'DEBIT',  'ACTIVE',     '5425-2334-3010-9903', '318', 'Omar Rashidi',      03, 2028, '2024-03-01', NULL,      '203 Crescent Ave Apt 4B, Harborfield, NY 10022'),
(6,  4,  'CREDIT', 'ACTIVE',     '4111-1111-1111-1122', '904', 'Felicity Crane',    06, 2027, '2022-06-20', 8000.00,   '50 Dogwood Drive, Cedarville, GA 30301'),
(7,  5,  'DEBIT',  'BLOCKED',    '5500-0055-5555-5580', '217', 'Marcus Holloway',   09, 2025, '2021-09-17', NULL,      '890 North Wacker Ct, Millbrook, IL 60601'),
(9,  6,  'CREDIT', 'ACTIVE',     '3714-496353-98431',   '093', 'Ingrid Solberg',    11, 2026, '2022-11-14', 12000.00,  '2211 Pacific Rim Way, Valdera, CA 90210'),
(10, 7,  'DEBIT',  'ACTIVE',     '6011-1111-1117-7706', '652', 'Jerome Kauffman',   04, 2027, '2023-04-05', NULL,      '3 Cactus Wren Rd, Redstone, AZ 85001'),
(11, 8,  'CREDIT', 'ACTIVE',     '4012-8888-8888-1892', '449', 'Sabrina Whitfield', 07, 2028, '2024-07-20', 15000.00,  '19 Harbour Point Loop, Harborfield, NY 10030'),
(12, 9,  'DEBIT',  'ACTIVE',     '5105-1051-0510-5109', '773', 'Timothy Nguyen',    01, 2026, '2022-01-03', NULL,      '642 Maple Ridge Blvd, Fairhaven, OH 44101'),
(14, 10, 'CREDIT', 'ACTIVE',     '4539-1488-0343-6182', '821', 'Rosa Mendenhall',   10, 2027, '2023-10-01', 20000.00,  '5 Tidewater Court, Valdera, CA 90211'),
(15, 11, 'DEBIT',  'ACTIVE',     '4916-0387-9416-3456', '335', 'Franklin Osei',     05, 2026, '2022-05-11', NULL,      '88 Loblolly Pine Dr, Cedarville, GA 30302'),
(16, 12, 'CREDIT', 'CANCELLED',  '5425-2334-3010-4421', '560', 'Vivienne Ashworth', 02, 2024, '2020-02-28', 10000.00,  '5 Park Crescent, Harborfield, NY 10021'),
(18, 14, 'PREPAID','ACTIVE',     '4111-2222-3333-4444', '112', 'Monique Delacroix', 12, 2025, '2023-12-05', NULL,      '77 Wilshire Blvd #900, Valdera, CA 90210');

-- =============================================================================
-- TABLE: bank_account_details  (ACH and routing numbers: masking demo target)
-- =============================================================================
CREATE TABLE bank_account_details (
    detail_id       SERIAL PRIMARY KEY,
    customer_id     INT             NOT NULL REFERENCES customers(customer_id),
    account_id      INT             NOT NULL REFERENCES accounts(account_id),
    routing_number  CHAR(9)         NOT NULL,   -- FICTIONAL ABA-format
    account_number  VARCHAR(17)     NOT NULL,   -- FICTIONAL
    bank_name       VARCHAR(100)    NOT NULL,
    account_label   VARCHAR(60),
    is_primary      BOOLEAN         NOT NULL DEFAULT FALSE,
    verified        BOOLEAN         NOT NULL DEFAULT FALSE,
    added_at        TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

INSERT INTO bank_account_details (customer_id, account_id, routing_number, account_number, bank_name, account_label, is_primary, verified) VALUES
(1,  1,  '021300077', '483920011847',    'Pinnacle Trust Financial Group', 'Primary Checking',  TRUE,  TRUE),
(1,  2,  '021300077', '483920011848',    'Pinnacle Trust Financial Group', 'Savings',           FALSE, TRUE),
(2,  3,  '021300077', '592840022951',    'Pinnacle Trust Financial Group', 'Checking',          TRUE,  TRUE),
(3,  4,  '026009593', '7741002938472',   'Pinnacle Trust Financial Group', 'Checking',          TRUE,  TRUE),
(4,  6,  '061000104', '883940049201',    'Pinnacle Trust Financial Group', 'Savings',           TRUE,  TRUE),
(5,  7,  '071000013', '9948201039284',   'Pinnacle Trust Financial Group', 'Frozen Checking',  TRUE,  FALSE),
(6,  9,  '122105155', '1122003948201',   'Pinnacle Trust Financial Group', 'Checking',          TRUE,  TRUE),
(7,  10, '111000025', '22310049182',     'Pinnacle Trust Financial Group', 'Savings',           TRUE,  TRUE),
(8,  11, '021300077', '334920018493',    'Pinnacle Trust Financial Group', 'Checking',          TRUE,  TRUE),
(9,  12, '041001039', '445810029384',    'Pinnacle Trust Financial Group', 'Checking',          TRUE,  FALSE),
(10, 14, '122105155', '5567200938471',   'Pinnacle Trust Financial Group', 'Money Market',      TRUE,  TRUE),
(11, 15, '061000104', '667930011029',    'Pinnacle Trust Financial Group', 'Checking',          TRUE,  TRUE),
(12, 16, '021300077', '778840025031',    'Pinnacle Trust Financial Group', 'Savings',           TRUE,  TRUE),
(14, 18, '122105155', '9901200482031',   'Pinnacle Trust Financial Group', 'CD Account',        TRUE,  TRUE),
(15, 19, '111000025', '1103920039124',   'Pinnacle Trust Financial Group', 'Savings',           TRUE,  TRUE);

-- =============================================================================
-- TABLE: transactions
-- =============================================================================
CREATE TABLE transactions (
    transaction_id      SERIAL PRIMARY KEY,
    account_id          INT             NOT NULL REFERENCES accounts(account_id),
    related_account_id  INT             REFERENCES accounts(account_id),
    txn_type            txn_type_enum   NOT NULL,
    amount              NUMERIC(15,2)   NOT NULL,
    balance_after       NUMERIC(15,2)   NOT NULL,
    description         VARCHAR(255),
    merchant_name       VARCHAR(120),
    merchant_category   VARCHAR(80),
    txn_date            TIMESTAMPTZ     NOT NULL,
    posted_date         TIMESTAMPTZ,
    is_flagged          BOOLEAN         NOT NULL DEFAULT FALSE
);

INSERT INTO transactions (account_id, related_account_id, txn_type, amount, balance_after, description, merchant_name, merchant_category, txn_date, posted_date) VALUES
(1,  NULL, 'DEPOSIT',    2500.00, 5100.00,  'Payroll direct deposit',          'Fargate & Associates',   'Employer',         '2024-10-01 08:05:00+00', '2024-10-01 08:05:00+00'),
(1,  NULL, 'WITHDRAWAL', 75.00,   5025.00,  'ATM withdrawal – BRN-001',        NULL,                     'ATM',              '2024-10-03 14:22:00+00', '2024-10-03 14:22:00+00'),
(1,  NULL, 'PAYMENT',    1200.00, 3825.00,  'Rent payment',                    'Greystone Property Mgmt','Rent',             '2024-10-04 09:00:00+00', '2024-10-04 09:00:00+00'),
(1,  2,   'TRANSFER',   200.00,  3625.00,  'Transfer to savings',             NULL,                     'Internal Transfer','2024-10-10 11:30:00+00', '2024-10-10 11:30:00+00'),
(2,  1,   'TRANSFER',   200.00,  18400.00, 'Transfer from checking',          NULL,                     'Internal Transfer','2024-10-10 11:30:00+00', '2024-10-10 11:30:00+00'),
(3,  NULL, 'DEPOSIT',    3000.00, 5310.77,  'Payroll direct deposit',          'Nexgrid Corp',           'Employer',         '2024-10-01 08:10:00+00', '2024-10-01 08:10:00+00'),
(3,  NULL, 'PAYMENT',    500.00,  4810.77,  'Online bill payment – utilities', 'Clearwater Utilities',   'Utilities',        '2024-10-06 10:15:00+00', '2024-10-06 10:15:00+00'),
(4,  NULL, 'DEPOSIT',    8000.00, 15650.00, 'Wire transfer received',          NULL,                     'Wire',             '2024-10-02 13:00:00+00', '2024-10-02 13:00:00+00'),
(4,  NULL, 'FEE',        35.00,   15615.00, 'Incoming wire fee',               NULL,                     'Bank Fee',         '2024-10-02 13:01:00+00', '2024-10-02 13:01:00+00'),
(5,  NULL, 'INTEREST',   91.00,   52091.00, 'Monthly interest credit',         NULL,                     'Interest',         '2024-10-31 23:59:00+00', '2024-11-01 00:00:00+00'),
(6,  NULL, 'DEPOSIT',    500.00,  9950.88,  'Mobile deposit – check',          NULL,                     'Check Deposit',    '2024-10-07 16:45:00+00', '2024-10-08 09:00:00+00'),
(7,  NULL, 'WITHDRAWAL', 40.00,   85.40,    'ATM withdrawal',                  NULL,                     'ATM',              '2024-10-11 18:00:00+00', '2024-10-11 18:00:00+00'),
(9,  NULL, 'DEPOSIT',    1500.00, 4600.20,  'Freelance payment received',      'Orion Creative LLC',     'Freelance',        '2024-10-05 12:00:00+00', '2024-10-05 12:00:00+00'),
(10, NULL, 'PAYMENT',    200.00,  6400.00,  'Credit card payment',             NULL,                     'Credit Card',      '2024-10-08 09:30:00+00', '2024-10-08 09:30:00+00'),
(11, NULL, 'DEPOSIT',    5000.00, 16240.85, 'Payroll direct deposit',          'Novatel Systems',        'Employer',         '2024-10-01 08:00:00+00', '2024-10-01 08:00:00+00'),
(11, NULL, 'PAYMENT',    320.00,  15920.85, 'Insurance premium',               'BlueSky Insurance',      'Insurance',        '2024-10-12 11:00:00+00', '2024-10-12 11:00:00+00'),
(12, NULL, 'WITHDRAWAL', 200.00,  674.10,   'POS purchase – grocery',          'FreshMart Superstore',   'Grocery',          '2024-10-09 15:20:00+00', '2024-10-09 15:20:00+00'),
(14, NULL, 'INTEREST',   142.00,  87642.00, 'Monthly interest credit',         NULL,                     'Interest',         '2024-10-31 23:59:00+00', '2024-11-01 00:00:00+00'),
(15, NULL, 'DEPOSIT',    800.00,  3000.60,  'Payroll direct deposit',          'Redwood County Schools', 'Employer',         '2024-10-01 08:00:00+00', '2024-10-01 08:00:00+00'),
(16, NULL, 'INTEREST',   39.05,   33039.05, 'Monthly interest credit',         NULL,                     'Interest',         '2024-10-31 23:59:00+00', '2024-11-01 00:00:00+00'),
(1,  NULL, 'PAYMENT',    58.49,   3566.51,  'POS – streaming subscriptions',   'CineStream Plus',        'Entertainment',    '2024-10-15 20:00:00+00', '2024-10-15 20:00:00+00'),
(9,  NULL, 'PAYMENT',    99.00,   4501.20,  'POS – online retail',             'Harborway Market',       'Retail',           '2024-10-17 14:30:00+00', '2024-10-17 14:30:00+00'),
(4,  NULL, 'WITHDRAWAL', 7000.00, 8615.00,  'Large cash withdrawal – flagged', NULL,                     'ATM',              '2024-10-20 10:00:00+00', '2024-10-20 10:00:00+00');

-- Flag the large suspicious withdrawal
UPDATE transactions SET is_flagged = TRUE WHERE description LIKE '%flagged%';

-- =============================================================================
-- TABLE: loans
-- =============================================================================
CREATE TABLE loans (
    loan_id         SERIAL PRIMARY KEY,
    customer_id     INT             NOT NULL REFERENCES customers(customer_id),
    branch_id       INT             NOT NULL REFERENCES branches(branch_id),
    officer_id      INT             NOT NULL REFERENCES employees(employee_id),
    loan_type       VARCHAR(50)     NOT NULL,
    status          loan_status_enum NOT NULL DEFAULT 'PENDING',
    principal       NUMERIC(15,2)   NOT NULL,
    outstanding     NUMERIC(15,2)   NOT NULL,
    interest_rate   NUMERIC(5,4)    NOT NULL,
    term_months     SMALLINT        NOT NULL,
    monthly_payment NUMERIC(12,2)   NOT NULL,
    origination_date DATE           NOT NULL,
    maturity_date   DATE            NOT NULL,
    last_payment_date DATE
);

INSERT INTO loans (customer_id, branch_id, officer_id, loan_type, status, principal, outstanding, interest_rate, term_months, monthly_payment, origination_date, maturity_date, last_payment_date) VALUES
(1,  1,  3,  'Personal Loan',   'ACTIVE',    15000.00,  11200.00,  0.0899, 60,  311.38,  '2021-05-01', '2026-05-01', '2024-10-01'),
(2,  1,  3,  'Auto Loan',       'ACTIVE',    24000.00,  18950.00,  0.0649, 72,  397.70,  '2022-01-15', '2028-01-15', '2024-10-15'),
(4,  3,  3,  'Home Equity',     'ACTIVE',    80000.00,  72000.00,  0.0725, 120, 936.08,  '2020-09-01', '2030-09-01', '2024-10-01'),
(5,  4,  9,  'Personal Loan',   'DEFAULTED', 10000.00,  8500.00,   0.1199, 48,  263.34,  '2021-11-01', '2025-11-01', '2023-06-01'),
(7,  6,  9,  'Auto Loan',       'ACTIVE',    32000.00,  25100.00,  0.0599, 72,  527.37,  '2022-07-01', '2028-07-01', '2024-10-01'),
(8,  7,  3,  'Mortgage',        'ACTIVE',    350000.00, 341000.00, 0.0685, 360, 2296.86, '2023-03-01', '2053-03-01', '2024-10-01'),
(10, 9,  3,  'Personal Loan',   'PAID_OFF',  5000.00,   0.00,      0.0799, 24,  225.73,  '2020-01-01', '2022-01-01', '2022-01-01'),
(11, 10, 9,  'Auto Loan',       'ACTIVE',    18500.00,  14200.00,  0.0749, 60,  370.96,  '2022-06-01', '2027-06-01', '2024-10-01'),
(13, 3,  3,  'Personal Loan',   'DECLINED',  8000.00,   0.00,      0.0999, 36,  258.14,  '2023-08-01', '2026-08-01', NULL),
(15, 6,  9,  'Student Loan',    'ACTIVE',    22000.00,  20500.00,  0.0499, 120, 232.94,  '2023-09-01', '2033-09-01', '2024-10-01');

-- =============================================================================
-- TABLE: fraud_alerts
-- =============================================================================
CREATE TABLE fraud_alerts (
    alert_id        SERIAL PRIMARY KEY,
    account_id      INT             NOT NULL REFERENCES accounts(account_id),
    customer_id     INT             NOT NULL REFERENCES customers(customer_id),
    transaction_id  INT             REFERENCES transactions(transaction_id),
    alert_type      alert_type_enum NOT NULL,
    severity        SMALLINT        NOT NULL CHECK (severity BETWEEN 1 AND 5),
    description     TEXT            NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    resolved_at     TIMESTAMPTZ,
    resolved_by     INT             REFERENCES employees(employee_id),
    is_resolved     BOOLEAN         NOT NULL DEFAULT FALSE
);

INSERT INTO fraud_alerts (account_id, customer_id, transaction_id, alert_type, severity, description, is_resolved, resolved_by) VALUES
(7,  5,  12, 'OVERDRAFT',         2, 'Account balance critically low after ATM withdrawal. Balance: $85.40.',          TRUE,  7),
(4,  3,  8,  'LARGE_TRANSACTION', 3, 'Incoming wire transfer of $8,000 flagged for review per BSA threshold.',          TRUE,  7),
(4,  3,  23, 'FRAUD',             5, 'Unusual large cash withdrawal of $7,000. Customer travel notice not on file.',    FALSE, NULL),
(11, 8,  NULL,'LOGIN_FAILURE',    2, 'Three failed login attempts detected on online banking portal. IP: 192.168.4.22.',TRUE,  10),
(1,  1,  NULL,'PII_ACCESS',       3, 'Employee accessed customer SSN and full account record outside of normal hours.', FALSE, NULL),
(9,  6,  22, 'FRAUD',             4, 'Card-not-present transaction flagged: $99.00 at Harborway Market, unusual geo.',   TRUE,  7),
(12, 9,  17, 'OVERDRAFT',         1, 'Balance fell below $1,000 minimum threshold after POS grocery purchase.',          TRUE,  8),
(5,  3,  10, 'LARGE_TRANSACTION', 2, 'Interest credit posted; balance review automated alert for money market.',         TRUE,  6);

-- =============================================================================
-- TABLE: audit_log  (tracks who accessed sensitive PII fields)
-- =============================================================================
CREATE TABLE audit_log (
    log_id          SERIAL PRIMARY KEY,
    employee_id     INT             NOT NULL REFERENCES employees(employee_id),
    customer_id     INT             REFERENCES customers(customer_id),
    account_id      INT             REFERENCES accounts(account_id),
    action          VARCHAR(80)     NOT NULL,
    table_accessed  VARCHAR(60)     NOT NULL,
    fields_accessed TEXT[],
    ip_address      INET,
    accessed_at     TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    justification   TEXT
);

INSERT INTO audit_log (employee_id, customer_id, account_id, action, table_accessed, fields_accessed, ip_address, justification) VALUES
(1,  1,  1,  'SELECT',  'customers',          ARRAY['ssn','date_of_birth','address_line1'],    '10.10.1.5',  'Account review request from customer'),
(3,  3,  4,  'SELECT',  'customers',          ARRAY['ssn','email','phone'],                    '10.10.1.12', 'Loan application identity verification'),
(3,  4,  6,  'UPDATE',  'loans',              ARRAY['status','outstanding'],                   '10.10.1.12', 'Loan status update post-payment review'),
(7,  5,  7,  'SELECT',  'accounts',           ARRAY['balance','status','account_number'],      '10.10.2.3',  'Fraud investigation – frozen account'),
(7,  3,  4,  'SELECT',  'bank_account_details',ARRAY['routing_number','account_number'],       '10.10.2.3',  'BSA review of large wire transfer'),
(6,  NULL, NULL,'SELECT','employees',         ARRAY['salary','ssn','date_of_birth'],           '10.10.3.8',  'Annual compensation benchmarking report'),
(10, 8,  11, 'SELECT',  'payment_cards',      ARRAY['card_number','cvv','expiry_year'],        '10.10.4.1',  'Customer reported lost card – verify details'),
(1,  1,  1,  'SELECT',  'customers',          ARRAY['ssn'],                                   '10.10.1.5',  NULL),  -- no justification: triggers PII alert
(9,  10, 14, 'SELECT',  'transactions',       ARRAY['amount','txn_date','merchant_name'],      '10.10.5.2',  'Monthly account statement reconciliation'),
(4,  13, 17, 'UPDATE',  'accounts',           ARRAY['status','closed_date'],                  '10.10.6.7',  'Account closure processing');

-- =============================================================================
-- USEFUL VIEWS FOR QUERYDESK EXERCISES
-- =============================================================================

-- View: full customer profile with PII (target for masking demos)
CREATE VIEW vw_customer_pii AS
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name           AS full_name,
    c.ssn,
    c.date_of_birth,
    c.email,
    c.phone,
    c.address_line1,
    c.city,
    c.state,
    c.zip_code,
    b.branch_name
FROM customers c
JOIN branches b ON c.branch_id = b.branch_id;

-- View: account summary with balances
CREATE VIEW vw_account_summary AS
SELECT
    a.account_id,
    a.account_number,
    a.account_type,
    a.status,
    a.balance,
    c.first_name || ' ' || c.last_name AS customer_name,
    b.branch_name
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
JOIN branches  b ON a.branch_id   = b.branch_id;

-- View: card details (primary obfuscation demo target)
CREATE VIEW vw_card_pii AS
SELECT
    pc.card_id,
    pc.cardholder_name,
    pc.card_type,
    pc.card_number,
    pc.cvv,
    pc.expiry_month,
    pc.expiry_year,
    pc.card_status,
    c.email,
    c.ssn
FROM payment_cards pc
JOIN customers c ON pc.customer_id = c.customer_id;

-- View: open fraud alerts with customer info
CREATE VIEW vw_open_fraud_alerts AS
SELECT
    fa.alert_id,
    fa.alert_type,
    fa.severity,
    fa.description,
    fa.created_at,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    a.account_number,
    a.balance
FROM fraud_alerts fa
JOIN customers c ON fa.customer_id = c.customer_id
JOIN accounts  a ON fa.account_id  = a.account_id
WHERE fa.is_resolved = FALSE;

-- =============================================================================
-- INDEXES FOR QUERY PERFORMANCE EXERCISES
-- =============================================================================
CREATE INDEX idx_accounts_customer        ON accounts(customer_id);
CREATE INDEX idx_transactions_account     ON transactions(account_id);
CREATE INDEX idx_transactions_date        ON transactions(txn_date);
CREATE INDEX idx_fraud_alerts_customer    ON fraud_alerts(customer_id);
CREATE INDEX idx_audit_log_employee       ON audit_log(employee_id);
CREATE INDEX idx_loans_customer           ON loans(customer_id);
CREATE INDEX idx_customers_branch         ON customers(branch_id);
CREATE INDEX idx_payment_cards_account    ON payment_cards(account_id);

-- =============================================================================
-- QUERYDESK LOGIN ROLES
-- Generates a 64-character password for each role and stores it for this
-- session only. The passwords never appear in the SQL text.
-- =============================================================================
SELECT set_config('querydesk.readonly_password',
       replace(gen_random_uuid()::text || gen_random_uuid()::text, '-', ''), false),
       set_config('querydesk.readwrite_password',
       replace(gen_random_uuid()::text || gen_random_uuid()::text, '-', ''), false);

DO $$
BEGIN
    EXECUTE format('CREATE ROLE querydesk_readonly WITH LOGIN PASSWORD %L',
                   current_setting('querydesk.readonly_password'));
    EXECUTE format('CREATE ROLE querydesk_readwrite WITH LOGIN PASSWORD %L',
                   current_setting('querydesk.readwrite_password'));
    EXECUTE format('GRANT CONNECT ON DATABASE %I TO querydesk_readonly, querydesk_readwrite',
                   current_database());
END
$$;

GRANT USAGE ON SCHEMA public TO querydesk_readonly, querydesk_readwrite;

-- Read-only: SELECT on every table and view.
GRANT SELECT ON ALL TABLES IN SCHEMA public TO querydesk_readonly;

-- Read/write: data changes, plus sequence access so INSERTs can use SERIAL IDs.
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO querydesk_readwrite;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO querydesk_readwrite;

-- =============================================================================
-- RESULT: the values for your QueryDesk credentials.
-- =============================================================================
SELECT current_database() AS database_name, 'querydesk_readonly' AS username,
       current_setting('querydesk.readonly_password') AS password
UNION ALL
SELECT current_database(), 'querydesk_readwrite',
       current_setting('querydesk.readwrite_password');
