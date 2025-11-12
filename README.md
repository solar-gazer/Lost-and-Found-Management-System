# Lost-and-Found-Management-System
A MySQL + Python-based Lost and Found Management System demonstrating CRUD operations, triggers, functions, procedures, and a Tkinter GUI frontend.
# Lost and Found Management System
## *A MySQL + Python Tkinter-based DBMS Project*



## Overview
The Lost and Found Management System is a database-driven application designed to help users report, manage, and recover lost or found items within an organization.

It connects a **MySQL database** with a **Python Tkinter GUI**, integrating advanced database concepts such as **stored procedures, triggers, functions, and complex queries** to provide a real-time, efficient management tool.



## Key Features & SQL Concepts

This project demonstrates core database concepts through the following features:

* **Add Lost Item:** Adds a new lost item using a dedicated form. (Demonstrates: Stored Procedure - `AddLostItem()`)
* **View/Delete Items:** Allows viewing the master list and removing outdated lost items. (Demonstrates: CRUD Operations - `SELECT`, `DELETE`)
* **Manage Claims:** Administrator interface for approving or rejecting item claims. (Demonstrates: Trigger - `after_claim_update`)
* **Notifications:** Auto-generated alerts sent to users when their claim is approved. (Demonstrates: Trigger Output)
* **Total Claims by User:** Displays the total number of claims made by any given user. (Demonstrates: SQL Function - `GetTotalClaimsByUser()`)
* **Category Summary:** Counts the lost items grouped by their category. (Demonstrates: Aggregate Query - `GROUP BY`)
* **Pending Users:** Identifies all users with claims currently awaiting approval. (Demonstrates: Nested Query)
* **Approved Claims:** Displays the claimant and found item details for approved claims. (Demonstrates: Join Query)

---

## Advanced SQL Components

The system utilizes the following advanced SQL objects:

* **Trigger:** `after_claim_update`
    * *Description:* Automatically creates a notification when a claim status is changed to 'Approved'.
* **Procedure:** `AddLostItem()`
    * *Description:* Encapsulates the logic for safely adding a new lost item record.
* **Function:** `GetTotalClaimsByUser()`
    * *Description:* Returns the total count of claims submitted by a specific User ID.

---

## Database Schema

The system is built on five core entities:

* `user(UserID, Name, Email, Role, ...)`
* `lostitem(LostItemID, Title, Category, LocationLost, ...)`
* `founditem(FoundItemID, Title, Category, LocationFound, ...)`
* `claim(ClaimID, FoundItemID, ClaimantID, Status, AdminID, ...)`
* `notification(NotificationID, UserID, Message, Status, DateTime)`

**Normalization:** All relations are normalized up to **Third Normal Form (3NF)**, ensuring data integrity and minimizing redundancy.

## Authors: 
Aditya CS, Aadarsh Koushik

## How to Run the Application

## Step 1: Import Database

Use a MySQL client (like MySQL Workbench or the command line) to import the schema and data.

```sql
SOURCE sql/lostandfound_final.sql;
```
## Step 2: Install Dependencies
pip install mysql-connector-python

## Step 3: Run the GUI
python src/lostandfound_gui.py

## Conclusion
This project successfully demonstrates an end-to-end Database Management System integrated with a user-friendly graphical frontend. It fulfills all academic rubric requirements, covering DDL, DML, CRUD operations, triggers, functions, procedures, complex queries, and normalization.