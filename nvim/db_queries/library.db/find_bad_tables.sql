SELECT Book.BookID, Book.Title, Author.FirstName || ' ' || Author.LastName AS AuthorName
FROM Book
LEFT JOIN BookAuthor ON Book.BookID = BookAuthor.BookID
LEFT JOIN Author ON BookAuthor.AuthorID = Author.AuthorID
WHERE Author.AuthorID IS NULL;
