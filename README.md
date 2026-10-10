# ex603-RideShare-Database
This repository will hold a postgresql generated database for a ride share company. 

The database will include information on riders, drivers, trips, driver_badges, driver_badge_awards, and the fare_amount.

This database handles core ride-sharing transactions and a driver rewards system. It uses a structured setup to keep data clean, safe, and efficient.
1. Table Creation and Reset Order
When working with relational databases, tables with references (Foreign Keys) cannot be created or deleted randomly.
Creation Order (Top-to-Bottom)
1. riders – Independent. Stores user data. No external dependencies.
2. drivers – Independent. Stores operator profile data.
3. driver_badges – Independent. Stores the available catalog of badge names and descriptions.
4. trips – Dependent. Connects a rider and a driver together. Both must exist before a trip can happen.
5. driver_badge_awards – Dependent. A junction table linking drivers to the badges they earn. Both the driver and the badge must exist first.
Destruction Order (Reset Block)
When resetting the database, we drop tables in the exact reverse order:
driver_badge_awards ➔ trips ➔ driver_badges ➔ drivers ➔ riders
This prevents errors because you cannot delete a table (like riders) while another table (like trips) is still actively pointing to it.
2. Table Summary & Design Highlights
• riders: Tracks passengers. The email column is unique and required so users cannot register twice with the same account.
• drivers: Tracks contractors. The license number column is unique to prevent duplicate or fraudulent driver registrations.
• driver_badges: A master list of all awards a driver can get (like "Top Rated" or "Night Owl").
• trips: Records completed journeys. It uses the DECIMAL(10,2) type for fares to avoid mathematical rounding errors common with standard decimals. The trip end time can be empty (NULL) to account for rides currently in progress.
• driver_badge_awards: Records which driver earned what badge and when. It automatically sets the time using the database's internal clock (CURRENT_TIMESTAMP).
3. Key Safeguards & Rules
• Named Constraints: Every primary key (pk_), foreign key (fk_), and unique column (uq_) is explicitly named. This means if a query breaks a rule, the error message clearly tells us exactly which constraint was violated, instead of giving a generic database error code.
• Exact Type Matching: Every foreign key data type matches its primary key counterpart perfectly as an INTEGER. This ensures fast searches and prevents validation bugs.
• Smart Deletions:
	• If a rider deletes their profile, their trip history is completely wiped out (ON DELETE CASCADE).
	• If a driver leaves the company, their historical trip logs remain intact for financial auditing, but their driver connection is cleared out (ON DELETE SET NULL).

