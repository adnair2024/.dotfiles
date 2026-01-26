-- Business Operation: Update members' email addresses
-- Used when patrons change their contact information.
-- Modify the WHERE clause to update one or many members.

UPDATE Member
SET Email = 'new_email@example.com'
WHERE MemberID IN (5, 6);
