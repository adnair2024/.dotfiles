SELECT
    r.RecordID,
    b.Title AS BookTitle,
    a.FirstName || ' ' || a.LastName AS Author,
    c.CategoryName,
    p.Name AS Publisher,
    m.FirstName || ' ' || m.LastName AS Borrower,
    r.BorrowDate,
    r.ReturnDate
FROM BORROWINGRECORD r
JOIN Book b ON r.BookID = b.BookID
JOIN BookAuthor ba ON b.BookID = ba.BookID
JOIN Author a ON ba.AuthorID = a.AuthorID
JOIN Category c ON b.CategoryID = c.CategoryID
JOIN Publisher p ON b.PublisherID = p.PublisherID
JOIN Member m ON r.MemberID = m.MemberID
LIMIT 5;
