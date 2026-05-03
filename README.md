# E-Commerce Database System

## Overview
This project is a fully normalized relational database designed for a standard e-commerce platform using Microsoft SQL Server. It manages core operations including customer data, product inventory, and secure order processing. The system relies on advanced SQL concepts such as triggers, views, and transactional stored procedures to maintain data integrity and automate backend processes.

## Key Features
* **Normalized Schema:** Data is structured across distinct tables (Customers, Products, Orders, OrderDetails) to minimize redundancy.
* **Automated Inventory Management:** Utilizes SQL Triggers to automatically deduct product stock quantities whenever a new order is successfully placed.
* **Secure Order Processing:** Implements Stored Procedures wrapped in Transaction blocks (`BEGIN TRY...BEGIN CATCH`) to ensure safe checkouts and prevent partial data entry during system failures.
* **Audit Logging:** An automated logging table tracks system actions, specifically successful checkout events, for security and auditing purposes.
* **Reporting Views:** Uses SQL Views and Joins to generate clean, readable order history reports from multiple relational tables.
* **Query Optimization:** Implements non-clustered indexes on high-traffic columns (like customer emails) to improve search performance.

## Technologies Used
* Microsoft SQL Server (MS SQL)
* T-SQL (Transact-SQL)

## Database Entities
1. **Customers:** Stores user identification and contact information.
2. **Products:** Manages the product catalog, pricing, and current stock levels.
3. **Orders:** Tracks high-level order metadata linked to specific customers.
4. **OrderDetails:** Maps individual products and quantities to specific orders.
5. **AuditLog:** Records automated system messages for completed transactions.

## Setup Instructions
1. Open SQL Server Management Studio (SSMS).
2. Connect to your local database engine.
3. Open a new query window.
4. Copy the contents of the provided `setup.sql` file and paste it into the query window.
5. Execute the script to build the database, generate the tables, insert sample data, and test the backend logic.
