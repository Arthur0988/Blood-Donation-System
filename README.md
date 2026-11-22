# Blood-Donation-System

so uhh ito po yung mga code and stuff

1. database.sql (Run First in SQL Server Management Studio)
Open SSMS, connect to localhost\SQLEXPRESS (or .), click New Query, paste this entire file, and press F5. It safely creates the BloodDonationSystem database, all 7 tables (DONOR, MEDICAL_STAFF, SCREENING, BLOOD_BAGS, BLOOD_COMPONENTS, BLOOD_REQUESTS, and SYSTEM_USERS), and populates all 180 rows.

2. package.json
Save this in BloodDonationSystem\package.json.

3. server.js (Universal Laptop Connection)
Save this in BloodDonationSystem\server.js. Instead of hardcoding a specific PC name like AJ\SQLEXPRESS, it uses localhost\SQLEXPRESS (with an automatic fallback to localhost) and tries both ODBC Driver 17 and ODBC Driver 18 so it connects automatically on any Windows laptop running SQL Server Express.
  
4. public\index.html
Create a subfolder named public inside BloodDonationSystem, and save this complete file as BloodDonationSystem\public\index.html. It includes the staff login gate (plus a 1-click "Quick Demo Login" button for smooth presentations), Dashboard Overview KPIs, all 6 database views (including the fixed db.screening || db.screenings loader), and interactive modals to add new records live during your presentation.


Quick Setup Checklist on the Presentation Laptop
Install Prerequisites (if not already on the presentation laptop):

Node.js (LTS)

SQL Server Express + SQL Server Management Studio (SSMS)

Run database.sql in SSMS (F5) to create BloodDonationSystem and insert all 180 records.

Start the Web Server: Open Command Prompt / PowerShell inside C:\BloodDonationSystem and run:

Bash
npm install
node server.js
