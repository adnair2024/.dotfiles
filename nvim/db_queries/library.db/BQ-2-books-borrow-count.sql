SELECT
    Book.BookID,
    Book.Title,
    COUNT(BorrowingRecord.RecordID) AS TimesBorrowed
FROM Book
LEFT JOIN BorrowingRecord ON Book.BookID = BorrowingRecord.BookID
GROUP BY Book.BookID, Book.Title
ORDER BY TimesBorrowed DESC;
