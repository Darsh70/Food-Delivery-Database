/* DROP statements to clean up objects from previous run */ 
-- Triggers
DROP TRIGGER trg_customer;
DROP TRIGGER trg_driver;
DROP TRIGGER trg_restaurant; DROP TRIGGER trg_menu_item; DROP TRIGGER trg_c_order;
-- Sequences
DROP SEQUENCE seq_cust_id;
DROP SEQUENCE seq_driver_id; DROP SEQUENCE seq_restaurant_id; DROP SEQUENCE seq_menu_item_id; DROP SEQUENCE seq_order_id;
-- Views
DROP VIEW customercontact; DROP VIEW drivercontact;
-- Indexes
DROP INDEX idx_customer_cust_fname; DROP INDEX idx_customer_cust_lname; DROP INDEX idx_driver_driver_vehicleno; DROP INDEX idx_restaurant_restaurant_zip;
-- Constraints
ALTER TABLE order_menu_items DROP CONSTRAINT fk_Order_menu_item_Menu_items; ALTER TABLE order_menu_items DROP CONSTRAINT fk_Order_menu_item_Order;
ALTER TABLE c_order DROP CONSTRAINT fk_cust_order;
ALTER TABLE c_order DROP CONSTRAINT fk_driver_order;
ALTER TABLE c_order DROP CONSTRAINT fk_restaurant_order;
ALTER TABLE menu_item DROP CONSTRAINT fk_menu_item_restaurant;
-- Tables
DROP TABLE order_menu_items; DROP TABLE menu_item;
DROP TABLE c_order;
DROP TABLE restaurant;
DROP TABLE driver;

DROP TABLE customer;
/* Creating tables based on entities */
CREATE TABLE customer (
cust_id NUMBER(10) NOT NULL,
cust_fname cust_lname cust_phone cust_email
VARCHAR2(50) VARCHAR2(50) VARCHAR2(20) VARCHAR2(100)
NOT NULL, NOT NULL, NOT NULL, NOT NULL,
CONSTRAINT pk_customer PRIMARY KEY (cust_id) );
CREATE TABLE driver (
driver_id
driver_fname
driver_lname
driver_phone
driver_vehicleno VARCHAR2(20)
NUMBER(10) NOT NULL,
VARCHAR2(50) VARCHAR2(50) VARCHAR2(20)
NOT NULL, NOT NULL, NOT NULL,
NOT NULL,
CONSTRAINT pk_driver PRIMARY KEY (driver_id) );
CREATE TABLE restaurant (
restaurant_id
restaurant_name
cuisine_type
restaurant_phone
restaurant_address VARCHAR2(200) NOT NULL, restaurant_zip VARCHAR2(10) NOT NULL,
CONSTRAINT pk_restaurant PRIMARY KEY (restaurant_id) );
CREATE TABLE menu_item (
NUMBER(10) NOT NULL, VARCHAR2(100) NOT NULL,
VARCHAR2(50) NOT NULL, VARCHAR2(20) NOT NULL,
menu_item_id
item_price
item_name
item_description VARCHAR2(200) NOT NULL, restaurant_id NUMBER(10) NOT NULL,
CONSTRAINT pk_menu_item PRIMARY KEY (menu_item_id),
NUMBER(10) NOT NULL, NUMBER(8, 2) NOT NULL,
VARCHAR2(100) NOT NULL,

CONSTRAINT fk_menu_item_restaurant FOREIGN KEY (restaurant_id)
REFERENCES restaurant(restaurant_id) );
CREATE TABLE c_order (
order_id NUMBER(10) NOT NULL, restaurant_id NUMBER(10) NOT NULL, driver_id NUMBER(10) NOT NULL, cust_id NUMBER (10) NOT NULL, driver_rating NUMBER(1),
order_total DECIMAL(5,2),
driver_tip DECIMAL(5,2) DEFAULT 0,
CONSTRAINT pk_c_order PRIMARY KEY (order_id), CONSTRAINT fk_restaurant_order FOREIGN KEY (restaurant_id) REFERENCES restaurant(restaurant_id),
CONSTRAINT fk_driver_order FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
CONSTRAINT fk_cust_order FOREIGN KEY (cust_id) REFERENCES customer(cust_id)
);
CREATE TABLE order_menu_items (
order_id
menu_item_id
item_quantity
special_instructions VARCHAR2(200),
CONSTRAINT pk_Order_menu_item PRIMARY KEY (order_id, menu_item_id), CONSTRAINT fk_Order_menu_item_Order FOREIGN KEY (order_id) REFERENCES c_order (order_id),
CONSTRAINT fk_Order_menu_item_Menu_items FOREIGN KEY (menu_item_id) REFERENCES menu_item(menu_item_id)
);
/* Creating indexes for frequently-queried columns */
-- Customer
CREATE INDEX idx_customer_cust_fname ON customer(cust_fname); CREATE INDEX idx_customer_cust_lname ON customer(cust_lname);
-- Driver
CREATE INDEX idx_driver_driver_vehicleno ON driver(driver_vehicleno);
NUMBER(10), NUMBER(10),
NUMBER(4),

-- Restaurant
CREATE INDEX idx_restaurant_restaurant_zip ON restaurant(restaurant_zip);
/* Creating Views */
-- Business Purpose: CustomerContanct will be used to rapidly retrieve the contact details of the customer
CREATE OR REPLACE VIEW CustomerContact AS
SELECT cust_fname, cust_lname, cust_phone
FROM customer;
-- Business Purpose: DriverContanct will be used to rapidly retrieve the contact details of the driver/delivery person
CREATE OR REPLACE VIEW DriverContact AS
SELECT driver_fname, driver_lname, driver_phone
FROM driver;
/* Creating Sequences */
CREATE SEQUENCE seq_cust_id START WITH 1
INCREMENT BY 1
NOCACHE;
CREATE SEQUENCE seq_driver_id START WITH 1
INCREMENT BY 1
NOCACHE;
CREATE SEQUENCE seq_restaurant_id START WITH 1
INCREMENT BY 1
NOCACHE;
CREATE SEQUENCE seq_menu_item_id START WITH 1
INCREMENT BY 1
NOCACHE;
CREATE SEQUENCE seq_order_id START WITH 1
INCREMENT BY 1
NOCACHE;

/* Create Triggers */
CREATE OR REPLACE TRIGGER trg_customer BEFORE INSERT ON customer
FOR EACH ROW
BEGIN
IF :NEW.cust_id IS NULL THEN :NEW.cust_id := seq_cust_id.NEXTVAL;
END IF; END;
/
CREATE OR REPLACE TRIGGER trg_driver BEFORE INSERT ON driver
FOR EACH ROW
BEGIN
IF :NEW.driver_id IS NULL THEN :NEW.driver_id :=seq_driver_id.NEXTVAL;
END IF;
END; /
CREATE OR REPLACE TRIGGER trg_restaurant BEFORE INSERT ON restaurant
FOR EACH ROW
BEGIN
IF :NEW.restaurant_id IS NULL THEN :NEW.restaurant_id :=seq_restaurant_id.NEXTVAL; END IF;
END; /
CREATE OR REPLACE TRIGGER trg_menu_item BEFORE INSERT ON menu_item
FOR EACH ROW
BEGIN
IF :NEW.menu_item_id IS NULL THEN :NEW.menu_item_id :=seq_menu_item_id.NEXTVAL; END IF;
END; /
CREATE OR REPLACE TRIGGER trg_c_order

BEFORE INSERT ON c_order FOR EACH ROW
BEGIN
IF :NEW.order_id IS NULL THEN :NEW.order_id :=seq_order_id.NEXTVAL;
END IF; END;
/
