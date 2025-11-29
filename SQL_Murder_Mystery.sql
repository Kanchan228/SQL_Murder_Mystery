Create database tech_nova;
-- DROP TABLES if exist
DROP TABLE IF EXISTS employees, keycard_logs, calls, alibis, evidence;

-- Employees Table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(50),
    department VARCHAR(50),
    role VARCHAR(50)
);

INSERT INTO employees VALUES
(1, 'Alice Johnson', 'Engineering', 'Software Engineer'),
(2, 'Bob Smith', 'HR', 'HR Manager'),
(3, 'Clara Lee', 'Finance', 'Accountant'),
(4, 'David Kumar', 'Engineering', 'DevOps Engineer'),
(5, 'Eva Brown', 'Marketing', 'Marketing Lead'),
(6, 'Frank Li', 'Engineering', 'QA Engineer'),
(7, 'Grace Tan', 'Finance', 'CFO'),
(8, 'Henry Wu', 'Engineering', 'CTO'),
(9, 'Isla Patel', 'Support', 'Customer Support'),
(10, 'Jack Chen', 'HR', 'Recruiter');

-- Keycard Logs Table
CREATE TABLE keycard_logs (
    log_id INT PRIMARY KEY,
    employee_id INT,
    room VARCHAR(50),
    entry_time TIMESTAMP,
    exit_time TIMESTAMP
);

INSERT INTO keycard_logs VALUES
(1, 1, 'Office', '2025-10-15 08:00', '2025-10-15 12:00'),
(2, 2, 'HR Office', '2025-10-15 08:30', '2025-10-15 17:00'),
(3, 3, 'Finance Office', '2025-10-15 08:45', '2025-10-15 12:30'),
(4, 4, 'Server Room', '2025-10-15 08:50', '2025-10-15 09:10'),
(5, 5, 'Marketing Office', '2025-10-15 09:00', '2025-10-15 17:30'),
(6, 6, 'Office', '2025-10-15 08:30', '2025-10-15 12:30'),
(7, 7, 'Finance Office', '2025-10-15 08:00', '2025-10-15 18:00'),
(8, 8, 'Server Room', '2025-10-15 08:40', '2025-10-15 09:05'),
(9, 9, 'Support Office', '2025-10-15 08:30', '2025-10-15 16:30'),
(10, 10, 'HR Office', '2025-10-15 09:00', '2025-10-15 17:00'),
(11, 4, 'CEO Office', '2025-10-15 20:50', '2025-10-15 21:00'); -- killer

-- Calls Table
CREATE TABLE calls (
    call_id INT PRIMARY KEY,
    caller_id INT,
    receiver_id INT,
    call_time TIMESTAMP,
    duration_sec INT
);

INSERT INTO calls VALUES
(1, 4, 1, '2025-10-15 20:55', 45),
(2, 5, 1, '2025-10-15 19:30', 120),
(3, 3, 7, '2025-10-15 14:00', 60),
(4, 2, 10, '2025-10-15 16:30', 30),
(5, 4, 7, '2025-10-15 20:40', 90);

-- Alibis Table
CREATE TABLE alibis (
    alibi_id INT PRIMARY KEY,
    employee_id INT,
    claimed_location VARCHAR(50),
    claim_time TIMESTAMP
);

INSERT INTO alibis VALUES
(1, 1, 'Office', '2025-10-15 20:50'),
(2, 4, 'Server Room', '2025-10-15 20:50'), -- false alibi
(3, 5, 'Marketing Office', '2025-10-15 20:50'),
(4, 6, 'Office', '2025-10-15 20:50');

-- Evidence Table
CREATE TABLE evidence (
    evidence_id INT PRIMARY KEY,
    room VARCHAR(50),
    description VARCHAR(255),
    found_time TIMESTAMP
);

INSERT INTO evidence VALUES
(1, 'CEO Office', 'Fingerprint on desk', '2025-10-15 21:05'),
(2, 'CEO Office', 'Keycard swipe logs mismatch', '2025-10-15 21:10'),
(3, 'Server Room', 'Unusual access pattern', '2025-10-15 21:15');

select * from keycard_logs;
SELECT * from evidence;
select * from alibis;
select * from calls;
select * from employees;

-- 1. Identify where and when the crime happened
SELECT  
      employee_id,
      room AS Crime_location,
	  entry_time AS suspect_entry_time,
      exit_time AS suspect_exit_time
FROM keycard_logs
WHERE room = 'CEO Office' AND 
      entry_time BETWEEN '2025-10-15 20:00:00' AND '2025-10-15 21:00:00';

-- 2. Analyze who accessed critical areas at the time
SELECT
      e.name as primary_suspect,
      k.room AS crime_loaction, 
      k.entry_time AS suspect_entry_time,
      k.exit_time AS suspect_exit_time
FROM keycard_logs k 
JOIN employees e ON k.employee_id = e.employee_id
WHERE k.room = 'CEO Office'AND 
     entry_time BETWEEN '2025-10-15 20:00:00' AND '2025-10-15 21:00:00';

-- 3. Cross-check alibis with actual logs

SELECT e.employee_id,
       e.name,
	   a.claimed_location,
       k.room as actual_location,
 CASE 
     WHEN a.claimed_location != k.room THEN 'Not_Match' 
	 ELSE 'Matched' 
     END AS alibi_verification
 FROM alibis a 
 JOIN keycard_logs k
     ON k.employee_id = a.employee_id 
JOIN employees e ON e.employee_id = a.employee_id;
    
-- 4. Investigate suspicious calls made around the time
SELECT 
    c.caller_id,
    e1.name AS caller_name,
    e2.name AS receiver_name,
    c.call_time,
    c.duration_sec,
    e1.department AS caller_dept,
    e1.role AS caller_role,
    e2.role AS reciever_role,
    e2.department AS reciever_dept
FROM calls c
JOIN employees e1 
      ON c.caller_id = e1.employee_id
JOIN employees e2 
      ON c.receiver_id = e2.employee_id
WHERE c.call_time BETWEEN 
      '2025-10-15 20:00:00' AND '2025-10-15 21:00:00';

-- 5. Match evidence with movements and claims
	
SELECT
    ev.evidence_id,
    ev.room AS evidence_room,
    ev.description,
    ev.found_time,
    e.name,
    a.claimed_location,
    k.room AS actual_location,
    CASE
        WHEN a.claimed_location IS NULL THEN 'ALIBI_NOT_AVAILABLE'
        WHEN ev.room = k.room THEN 'EVIDENCE_MATCH_WITH_MOVEMENT'
        WHEN ev.room = a.claimed_location THEN 'EVIDENCE_MATCH_WITH_ALIBI'
        WHEN a.claimed_location <> k.room THEN 'ALIBI_CONTRADICTION'
        ELSE 'NO_EVIDENCE_MATCH'
    END AS evidence_alignment_status
FROM evidence ev
LEFT JOIN keycard_logs k 
       ON ev.room = k.room
LEFT JOIN employees e 
       ON e.employee_id = k.employee_id
LEFT JOIN alibis a 
       ON a.employee_id = e.employee_id;

-- 6. Combine all findings to identify the killer       

WITH combined_flags AS (
    SELECT
        e.employee_id,
        e.name,
        (MAX(CASE WHEN ev.room = k.room THEN 1 ELSE 0 END) +
         MAX(CASE WHEN k.entry_time BETWEEN '2025-10-15 20:00:00' AND '2025-10-15 21:00:00' THEN 1 ELSE 0 END) +
         MAX(CASE WHEN c.call_time BETWEEN '2025-10-15 20:00:00' AND '2025-10-15 21:00:00' THEN 1 ELSE 0 END)
        ) AS killer_flag
    FROM employees e
    LEFT JOIN keycard_logs k ON e.employee_id = k.employee_id
    LEFT JOIN evidence ev ON ev.room = k.room
    LEFT JOIN calls c ON e.employee_id = c.caller_id
    GROUP BY e.employee_id, e.name)
SELECT name as Killer_name
FROM combined_flags
ORDER BY killer_flag DESC
LIMIT 1;


