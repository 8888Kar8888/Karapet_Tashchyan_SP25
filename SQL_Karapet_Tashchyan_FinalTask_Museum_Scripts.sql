DROP DATABASE IF EXISTS museum_management;
CREATE DATABASE museum_management;


DROP SCHEMA IF EXISTS museum CASCADE;
CREATE SCHEMA museum;

DROP TYPE IF EXISTS museum.item_category;
CREATE TYPE museum.item_category AS ENUM ('artwork', 'artifact', 'specimen', 'historical object');

DROP TYPE IF EXISTS museum.item_status;
CREATE TYPE museum.item_status AS ENUM ('in storage', 'on display', 'under maintenance');


DROP TABLE IF EXISTS museum.Item CASCADE;
CREATE TABLE museum.Item (
    item_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    item_type museum.item_category NOT NULL,
    date_acquired DATE NOT NULL,
    
    CONSTRAINT chk_item_date_acquired CHECK (date_acquired > '2024-01-01'),
    CONSTRAINT chk_item_title_length CHECK (LENGTH(title) > 0)
);

DROP TABLE IF EXISTS museum.Inventory CASCADE;
CREATE TABLE museum.Inventory (
    inventory_id SERIAL PRIMARY KEY,
    item_id INT NOT NULL,
    location VARCHAR(20) NOT NULL,
    status museum.item_status NOT NULL,
    last_checked DATE,
    measured_value NUMERIC CHECK (measured_value >= 0), 
    
    CONSTRAINT fk_inventory_item FOREIGN KEY (item_id) REFERENCES museum.Item(item_id),
    CONSTRAINT chk_inventory_last_checked CHECK (last_checked IS NULL OR last_checked > '2024-01-01'),
    CONSTRAINT chk_inventory_location CHECK (location IN ('north wing', 'south wing', 'east wing', 'west wing'))
);

DROP TABLE IF EXISTS museum.Exhibition CASCADE;
CREATE TABLE museum.Exhibition (
    exhibition_id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    description TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_online BOOLEAN NOT NULL DEFAULT FALSE, 
    
    CONSTRAINT chk_exhibition_dates CHECK (end_date > start_date),
    CONSTRAINT chk_exhibition_name_length CHECK (LENGTH(name) > 0)
);

DROP TABLE IF EXISTS museum.ItemExhibition CASCADE;
CREATE TABLE museum.ItemExhibition (
    item_id INT NOT NULL,
    exhibition_id INT NOT NULL,
    
    CONSTRAINT pk_itemexhibition PRIMARY KEY (item_id, exhibition_id),
    
    CONSTRAINT fk_itemexhibition_item FOREIGN KEY (item_id)
        REFERENCES museum.Item (item_id)
        ON DELETE CASCADE,
        
    CONSTRAINT fk_itemexhibition_exhibition FOREIGN KEY (exhibition_id)
        REFERENCES museum.Exhibition (exhibition_id)
        ON DELETE CASCADE
);

DROP TABLE IF EXISTS museum.Visitor CASCADE;
CREATE TABLE museum.Visitor (
    visitor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    email VARCHAR(50) UNIQUE, 
    visit_date DATE NOT NULL,
    purpose VARCHAR(20),
    
    CONSTRAINT chk_visitor_visit_date CHECK (visit_date > '2024-01-01'),
    CONSTRAINT chk_visitor_purpose CHECK (purpose IN ('education', 'tour', 'research'))
);

DROP TABLE IF EXISTS museum.Employee CASCADE;
CREATE TABLE museum.Employee (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    position VARCHAR(30) NOT NULL,
    phone_number VARCHAR(20),
    
    CONSTRAINT chk_employee_phone_number CHECK (phone_number ~ '^\+?[0-9]{1,15}$')
);


ALTER TABLE museum.Item 
    ADD CONSTRAINT chk_item_description_length CHECK (LENGTH(description) > 10); 

ALTER TABLE museum.Inventory 
    ADD CONSTRAINT chk_inventory_status CHECK (status IN ('in storage', 'on display', 'under maintenance'));

ALTER TABLE museum.Exhibition 
    ADD CONSTRAINT chk_exhibition_duration CHECK (end_date > start_date);

ALTER TABLE museum.Visitor 
    ADD CONSTRAINT chk_visitor_email_format CHECK (email ~* '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$'); 

ALTER TABLE museum.Employee 
    ADD CONSTRAINT chk_employee_position CHECK (position IN ('curator', 'guide', 'technician', 'admin')); 



WITH inserted_item AS (
    INSERT INTO museum.Item (title, description, item_type, date_acquired)
    SELECT 'Mona Lisa', 'A portrait of a woman painted by Leonardo da Vinci.', 'artwork'::museum.item_category, '2024-03-15'::date
    WHERE NOT EXISTS (SELECT 1 FROM museum.Item WHERE title = 'Mona Lisa')
    UNION ALL
    SELECT 'Ancient Vase', 'A pottery vase from the Roman Empire period.', 'artifact'::museum.item_category, '2024-03-10'::date
    WHERE NOT EXISTS (SELECT 1 FROM museum.Item WHERE title = 'Ancient Vase')
    UNION ALL
    SELECT 'Dinosaur Fossil', 'A fossil of a prehistoric dinosaur.', 'specimen'::museum.item_category, '2024-04-01'::date
    WHERE NOT EXISTS (SELECT 1 FROM museum.Item WHERE title = 'Dinosaur Fossil')
    UNION ALL
    SELECT 'Historical Map', 'A 16th-century map of the world.', 'historical object'::museum.item_category, '2024-04-05'::date
    WHERE NOT EXISTS (SELECT 1 FROM museum.Item WHERE title = 'Historical Map')
    UNION ALL
    SELECT 'The Starry Night', 'A painting by Vincent van Gogh depicting a starry night sky.', 'artwork'::museum.item_category, '2024-02-25'::date
    WHERE NOT EXISTS (SELECT 1 FROM museum.Item WHERE title = 'The Starry Night')
    UNION ALL
    SELECT 'Ancient Sword', 'A sword used in medieval combat.', 'artifact'::museum.item_category, '2024-03-20'::date
    WHERE NOT EXISTS (SELECT 1 FROM museum.Item WHERE title = 'Ancient Sword')
    RETURNING item_id, title
)
INSERT INTO museum.Inventory (item_id, location, status, last_checked, measured_value)
SELECT item_id, 'north wing', 'on display'::museum.item_status, '2024-04-15'::date, 50.2 FROM inserted_item WHERE title = 'Mona Lisa'
UNION ALL
SELECT item_id, 'south wing', 'in storage'::museum.item_status, '2024-03-10'::date, 32.0 FROM inserted_item WHERE title = 'Ancient Vase'
UNION ALL
SELECT item_id, 'east wing', 'under maintenance'::museum.item_status, NULL, 15.5 FROM inserted_item WHERE title = 'Dinosaur Fossil'
UNION ALL
SELECT item_id, 'west wing', 'on display'::museum.item_status, '2024-04-10'::date, 20.0 FROM inserted_item WHERE title = 'Historical Map'
UNION ALL
SELECT item_id, 'north wing', 'on display'::museum.item_status, '2024-03-25'::date, 45.3 FROM inserted_item WHERE title = 'The Starry Night'
UNION ALL
SELECT item_id, 'south wing', 'in storage'::museum.item_status, '2024-04-02'::date, 22.1 FROM inserted_item WHERE title = 'Ancient Sword';



ALTER TABLE museum.Exhibition
ALTER COLUMN name TYPE VARCHAR(100);


WITH inserted_exhibition AS (
    INSERT INTO museum.Exhibition (name, description, start_date, end_date, is_online)
    SELECT 'Impressionist Paintings', 'A collection of famous impressionist paintings.', '2024-03-01'::date, '2024-03-15'::date, FALSE
    WHERE NOT EXISTS (SELECT 1 FROM museum.Exhibition WHERE name = 'Impressionist Paintings')
    UNION ALL
    SELECT 'Ancient Civilizations', 'An exhibition showcasing artifacts from ancient civilizations.', '2024-03-10'::date, '2024-04-01'::date, TRUE
    WHERE NOT EXISTS (SELECT 1 FROM museum.Exhibition WHERE name = 'Ancient Civilizations')
    UNION ALL
    SELECT 'Fossils of the Past', 'An exhibition of dinosaur fossils.', '2024-03-20'::date, '2024-04-10'::date, FALSE
    WHERE NOT EXISTS (SELECT 1 FROM museum.Exhibition WHERE name = 'Fossils of the Past')
    UNION ALL
    SELECT 'Renaissance Art', 'A collection of famous Renaissance artworks.', '2024-04-05'::date, '2024-04-20'::date, TRUE
    WHERE NOT EXISTS (SELECT 1 FROM museum.Exhibition WHERE name = 'Renaissance Art')
    UNION ALL
    SELECT 'Roman Antiquities', 'Artifacts from the Roman Empire.', '2024-02-28'::date, '2024-03-12'::date, FALSE
    WHERE NOT EXISTS (SELECT 1 FROM museum.Exhibition WHERE name = 'Roman Antiquities')
    UNION ALL
    SELECT 'Modern Art', 'Exhibition of modern art and contemporary pieces.', '2024-04-01'::date, '2024-04-15'::date, TRUE
    WHERE NOT EXISTS (SELECT 1 FROM museum.Exhibition WHERE name = 'Modern Art')
    RETURNING exhibition_id, name
)
INSERT INTO museum.ItemExhibition (item_id, exhibition_id)
SELECT i.item_id, e.exhibition_id
FROM museum.Item i
JOIN inserted_exhibition e ON (
    (i.title = 'Mona Lisa' AND e.name = 'Impressionist Paintings') OR
    (i.title = 'Ancient Vase' AND e.name = 'Ancient Civilizations') OR
    (i.title = 'Dinosaur Fossil' AND e.name = 'Fossils of the Past') OR
    (i.title = 'Historical Map' AND e.name = 'Renaissance Art') OR
    (i.title = 'The Starry Night' AND e.name = 'Impressionist Paintings') OR
    (i.title = 'Ancient Sword' AND e.name = 'Ancient Civilizations')
);



WITH inserted_visitor AS (
    INSERT INTO museum.Visitor (first_name, last_name, email, visit_date, purpose)
    SELECT 'John', 'Doe', 'john.doe@example.com', '2024-04-10'::date, 'tour'
    WHERE NOT EXISTS (SELECT 1 FROM museum.Visitor WHERE email = 'john.doe@example.com')
    UNION ALL
    SELECT 'Jane', 'Smith', 'jane.smith@example.com', '2024-04-02'::date, 'research'
    WHERE NOT EXISTS (SELECT 1 FROM museum.Visitor WHERE email = 'jane.smith@example.com')
    UNION ALL
    SELECT 'Albert', 'Johnson', 'albert.johnson@example.com', '2024-03-28'::date, 'education'
    WHERE NOT EXISTS (SELECT 1 FROM museum.Visitor WHERE email = 'albert.johnson@example.com')
    UNION ALL
    SELECT 'Emily', 'Davis', 'emily.davis@example.com', '2024-04-04'::date, 'tour'
    WHERE NOT EXISTS (SELECT 1 FROM museum.Visitor WHERE email = 'emily.davis@example.com')
    UNION ALL
    SELECT 'Michael', 'Brown', 'michael.brown@example.com', '2024-03-15'::date, 'tour'
    WHERE NOT EXISTS (SELECT 1 FROM museum.Visitor WHERE email = 'michael.brown@example.com')
    UNION ALL
    SELECT 'Sarah', 'Wilson', 'sarah.wilson@example.com', '2024-04-12'::date, 'research'
    WHERE NOT EXISTS (SELECT 1 FROM museum.Visitor WHERE email = 'sarah.wilson@example.com')
    RETURNING visitor_id, first_name
)
SELECT visitor_id, 'museum-visitor' FROM inserted_visitor;


WITH inserted_employee AS (
    INSERT INTO museum.Employee (first_name, last_name, position, phone_number)
    SELECT 'Alice', 'Taylor', 'curator', '+1234567890'
    WHERE NOT EXISTS (SELECT 1 FROM museum.Employee WHERE phone_number = '+1234567890')
    UNION ALL
    SELECT 'Bob', 'Martinez', 'guide', '+1987654321'
    WHERE NOT EXISTS (SELECT 1 FROM museum.Employee WHERE phone_number = '+1987654321')
    UNION ALL
    SELECT 'Charlie', 'Gonzalez', 'technician', '+1122334455'
    WHERE NOT EXISTS (SELECT 1 FROM museum.Employee WHERE phone_number = '+1122334455')
    UNION ALL
    SELECT 'David', 'Lee', 'admin', '+1222333445'
    WHERE NOT EXISTS (SELECT 1 FROM museum.Employee WHERE phone_number = '+1222333445')
    UNION ALL
    SELECT 'Eva', 'Clark', 'curator', '+1333444555'
    WHERE NOT EXISTS (SELECT 1 FROM museum.Employee WHERE phone_number = '+1333444555')
    UNION ALL
    SELECT 'Frank', 'Rodriguez', 'guide', '+1444555666'
    WHERE NOT EXISTS (SELECT 1 FROM museum.Employee WHERE phone_number = '+1444555666')
    RETURNING employee_id, first_name
)
SELECT employee_id, 'museum-employee' FROM inserted_employee;



CREATE OR REPLACE FUNCTION museum.update_item_column(
    p_item_id INT,
    p_column_name TEXT,
    p_new_value TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS
$$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := FORMAT('UPDATE museum.Item SET %I = $1 WHERE item_id = $2', p_column_name);
    EXECUTE v_sql USING p_new_value, p_item_id;
END;
$$;

--SELECT museum.update_item_column(1, 'title', 'Mona Lisa - Updated');

--SELECT item_id, title FROM museum.Item WHERE item_id = 1;


CREATE TABLE museum.Transaction (
    transaction_id SERIAL PRIMARY KEY,
    item_id INT REFERENCES museum.Item(item_id) ON DELETE CASCADE,
    visitor_id INT REFERENCES museum.Visitor(visitor_id) ON DELETE CASCADE,
    transaction_date DATE NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,  -- or you can later make it ENUM
    amount NUMERIC(10,2)
);

CREATE TYPE museum.transaction_type AS ENUM ('purchase', 'loan', 'donation');


CREATE OR REPLACE FUNCTION museum.add_transaction(
    p_item_title text,
    p_visitor_first_name text,
    p_visitor_last_name text,
    p_transaction_date date,
    p_transaction_type museum.transaction_type,
    p_amount numeric
)
RETURNS void AS $$
DECLARE
    v_item_id INTEGER;
    v_visitor_id INTEGER;
BEGIN
    -- Check if the item exists
    SELECT item_id INTO v_item_id
    FROM museum.Item
    WHERE title = p_item_title;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Item with title "%" not found.', p_item_title;
    END IF;

    -- Check if the visitor exists
    SELECT visitor_id INTO v_visitor_id
    FROM museum.Visitor
    WHERE first_name = p_visitor_first_name
    AND last_name = p_visitor_last_name;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Visitor with name "%" not found.', p_visitor_first_name || ' ' || p_visitor_last_name;
    END IF;

    -- Insert the transaction
    INSERT INTO museum.Transaction (item_id, visitor_id, transaction_date, transaction_type, amount)
    VALUES (v_item_id, v_visitor_id, p_transaction_date, p_transaction_type, p_amount);

    -- Optionally, you can raise a notice to confirm the transaction was added.
    RAISE NOTICE 'Transaction added successfully for item "%" and visitor "%".', p_item_title, p_visitor_first_name || ' ' || p_visitor_last_name;
END;
$$ LANGUAGE plpgsql;



SELECT museum.add_transaction(
    p_item_title := 'Mona Lisa - Updated',
    p_visitor_first_name := 'John',
    p_visitor_last_name := 'Doe',
    p_transaction_date := CURRENT_DATE,
    p_transaction_type := 'purchase',  -- Assuming 'purchase' is valid in your ENUM
    p_amount := 150.00
);



SELECT * FROM museum.Item WHERE title like '%Mona%';
SELECT * FROM museum.Visitor WHERE first_name = 'John' and last_name = 'Doe';


CREATE OR REPLACE VIEW museum.quarterly_analytics AS
WITH most_recent_quarter AS (
    SELECT
        DATE_TRUNC('quarter', MAX(transaction_date)) AS most_recent_quarter_start,
        DATE_TRUNC('quarter', MAX(transaction_date)) + INTERVAL '3 months' AS most_recent_quarter_end
    FROM museum.Transaction
),
transaction_analytics AS (
    SELECT
        t.transaction_type,
        COUNT(t.transaction_id) AS transaction_count,
        SUM(t.amount) AS total_amount,
        COUNT(DISTINCT t.item_id) AS distinct_items_count
    FROM museum.Transaction t
    JOIN most_recent_quarter mrq ON t.transaction_date >= mrq.most_recent_quarter_start
    AND t.transaction_date < mrq.most_recent_quarter_end
    GROUP BY t.transaction_type
)
SELECT
    transaction_type,
    transaction_count,
    total_amount,
    distinct_items_count
FROM transaction_analytics;


--SELECT * FROM museum.quarterly_analytics;



CREATE ROLE manager_read_only NOINHERIT;

ALTER ROLE manager_read_only LOGIN;

GRANT USAGE ON SCHEMA museum TO manager_read_only;  
GRANT SELECT ON ALL TABLES IN SCHEMA museum TO manager_read_only;  

GRANT SELECT ON ALL SEQUENCES IN SCHEMA museum TO manager_read_only;


ALTER DEFAULT PRIVILEGES IN SCHEMA museum GRANT SELECT ON TABLES TO manager_read_only;
ALTER DEFAULT PRIVILEGES IN SCHEMA museum GRANT SELECT ON SEQUENCES TO manager_read_only;

REVOKE ALL PRIVILEGES ON DATABASE museum_management FROM manager_read_only;

