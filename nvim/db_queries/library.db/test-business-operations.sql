------------------------------------------------------------
-- TEST 1: Confirm both business operations worked
-- This test checks that:
--   (1) New books were successfully inserted
--   (2) Member email updates were applied correctly
------------------------------------------------------------

-- 1. Check new books exist AND have valid publisher/category relationships
SELECT 
    b.BookID,
    b.Title,
    b.ISBN,
    p.Name AS PublisherName,
    c.CategoryName
FROM Book b
JOIN Publisher p ON b.PublisherID = p.PublisherID
JOIN Category c ON b.CategoryID = c.CategoryID
WHERE b.BookID IN (2001, 2002, 2003);

-- 2. Verify member email updates worked
SELECT
    MemberID,
    FirstName,
    LastName,
    Email
FROM Member
WHERE MemberID IN (5, 6);

-- 3. Extra integrity check: ensure no duplicate ISBNs were created
SELECT ISBN, COUNT(*) AS CountOfISBN
FROM Book
GROUP BY ISBN
HAVING COUNT(*) > 1;
