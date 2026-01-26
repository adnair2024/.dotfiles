SELECT
    BorrowingRecord.RecordID,
    Member.FirstName AS MemberFirstName,
    Member.LastName AS MemberLastName,
    Book.Title AS BookTitle,
    BorrowingRecord.BorrowDate,
    BorrowingRecord.ReturnDate
FROM BorrowingRecord
JOIN Member ON BorrowingRecord.MemberID = Member.MemberID
JOIN Book ON BorrowingRecord.BookID = Book.BookID
ORDER BY BorrowingRecord.ReturnDate NULLS FIRST, BorrowingRecord.BorrowDate ASC;
