SELECT r.RecordID, r.BookID, r.MemberID
FROM BORROWINGRECORD r
LEFT JOIN Book b ON r.BookID = b.BookID
LEFT JOIN Member m ON r.MemberID = m.MemberID
WHERE b.BookID IS NULL OR m.MemberID IS NULL;
