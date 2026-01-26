-- Business Operation: Insert new books into the library catalog
-- This operation adds new books to the Book table.
-- To insert different books, replace the values inside the VALUES section.

INSERT INTO Book (BookID, Title, ISBN, PublisherID, CategoryID)
VALUES
    (2001, 'The Silent Orbit', '978-1-55555-010-1', 1, 3),
    (2002, 'The Memory Engine', '978-1-55555-010-2', 2, 4),
    (2003, 'Empire of Ash', '978-1-55555-010-3', 3, 2);
