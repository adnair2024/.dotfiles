SELECT
    (SELECT COUNT(*) FROM Category)        AS category_count,
    (SELECT COUNT(*) FROM Publisher)       AS publisher_count,
    (SELECT COUNT(*) FROM Author)          AS author_count,
    (SELECT COUNT(*) FROM Book)            AS book_count,
    (SELECT COUNT(*) FROM Member)          AS member_count,
    (SELECT COUNT(*) FROM BookAuthor)      AS bookauthor_count,
    (SELECT COUNT(*) FROM BORROWINGRECORD) AS borrowing_count;
