--1. Kitabxanada olmayan kitabları , kitabxanadan götürmək olmaz.

CREATE TRIGGER IssueBookStudent
ON S_Cards
AFTER INSERT
AS
BEGIN
    DECLARE @id int=0;
    SELECT @id=Id_Book FROM inserted
	IF EXISTS
	(
	  SELECT * FROM Books
	  WHERE Books.Id=@id AND Books.Quantity=0
	)
	BEGIN
	  PRINT 'Book Quantity=0'
	  ROLLBACK TRAN
	END
	
END

---------------------------------------------------

CREATE TRIGGER IssueBookTeacher
ON T_Cards
AFTER INSERT
AS
BEGIN
    DECLARE @id int=0;
    SELECT @id=Id_Book FROM inserted
	IF EXISTS
	(
	  SELECT * FROM Books
	  WHERE Books.Id=@id AND Books.Quantity=0
	)
	BEGIN
	  PRINT 'Book Quantity=0'
	  ROLLBACK TRAN
	END
	
END


INSERT INTO T_Cards VALUES (10,8,14,'2021.11.15',NULL,1)

--2. Müəyyən kitabı qaytardıqda, onun Quantity-si (sayı) artmalıdır.

CREATE TRIGGER ReturnBookStudent
ON S_Cards
AFTER UPDATE
AS
BEGIN
    DECLARE @id int=0;
	SELECT @id=Id_Book FROM inserted
	
	UPDATE Books
	SET Quantity=Quantity+1
	WHERE Books.Id=@id
END


 UPDATE S_Cards
 SET DateIn='2021.11.15'
 WHERE S_Cards.Id=12

 ---------------------------------------------

CREATE TRIGGER ReturnBookTeacher
ON T_Cards
AFTER UPDATE
AS
BEGIN
    DECLARE @id int=0;
	SELECT @id=Id_Book FROM inserted
	
	UPDATE Books
	SET Quantity=Quantity+1
	WHERE Books.Id=@id
END

 UPDATE T_Cards
 SET DateIn='2021.11.15'
 WHERE T_Cards.Id=7

--3. Kitab kitabxanadan verildikdə onun sayı azalmalıdır.
CREATE TRIGGER TakeBookStudent
ON S_Cards
AFTER INSERT
AS
BEGIN
    DECLARE @id int=0;
    SELECT @id=Id_Book FROM inserted
	
	UPDATE Books
	SET Quantity=Quantity-1
	WHERE Books.Id=@id
END

INSERT INTO S_Cards VALUES (110,17,11,'2021.11.15',NULL,1)

-----------------------------

CREATE TRIGGER TakeBookTeacher
ON T_Cards
AFTER INSERT
AS
BEGIN
    DECLARE @id int=0;
    SELECT @id=Id_Book FROM inserted
	
	UPDATE Books
	SET Quantity=Quantity-1
	WHERE Books.Id=@id
END

INSERT INTO T_Cards VALUES (10,8,18,'2021.11.15',NULL,1)

--4. Bir tələbə artıq 3 kitab götütürübsə ona yeni kitab vermək olmaz.
CREATE TRIGGER  CanNotGiveMoreThanThreeBookToStudent
ON S_Cards
AFTER INSERT
AS
BEGIN
    DECLARE @id int=0;
    SELECT @id=Id_Student FROM inserted
	
	DECLARE @bookcount int=0;
	SELECT @bookcount=COUNT(*) FROM Libs INNER JOIN S_Cards
    ON Libs.Id=S_Cards.Id_Lib INNER JOIN Students
    ON Id_Student=Students.Id INNER JOIN Books
    ON Id_Book=Books.Id
    WHERE Students.Id=@id AND DateIn IS NULL

	IF(@bookcount=4)
	BEGIN
	    PRINT 'This Student Take 3 Book'
		ROLLBACK TRAN
	END

END

INSERT INTO S_Cards VALUES (111,17,13,'2021.11.15',NULL,1)

--5. Əgər tələbə bir kitabı 2aydan çoxdur oxuyursa, bu halda tələbəyə yeni kitab vermək olmaz.

CREATE TRIGGER CanNotIssueNewBookToStudentReadBookMore2month
ON S_Cards
INSTEAD OF INSERT
AS 
BEGIN
    DECLARE @id int=0;
    SELECT @id=Id_Student FROM inserted

	IF EXISTS
    (
      SELECT * FROM Libs INNER JOIN S_Cards
      ON Libs.Id=S_Cards.Id_Lib INNER JOIN Students
      ON Id_Student=Students.Id INNER JOIN Books
      ON Id_Book=Books.Id
      WHERE Students.Id=@id AND DATEDIFF(MONTH,DateOut,GETDATE())>2 AND DateIn IS NULL
    )
    BEGIN 
      PRINT 'Can Not Issue New Book To Student (Read Book More 2 month)'
	  ROLLBACK TRAN
    END

END


 INSERT INTO S_Cards VALUES (120,16,4,'2021.11.15',NULL,2)


--6. Kitabı bazadan sildikdə, onun haqqında data LibDeleted cədvəlinə köçürülməlidir.

CREATE TRIGGER DeleteBook
ON Books
AFTER DELETE
AS
BEGIN
	DECLARE @LibDeleted TABLE
	(
		ID int, 
		Name nvarchar(30), 
		Pages int, 
		YearPress date, 
		ThemesID int,
		CategoryID int,
		AuthorID int,
		PressID int,
		Comment nvarchar(30),
		Quantity int
	)
	INSERT @LibDeleted
	SELECT Id, Name, Pages, YearPress, Id_Themes, 
	Id_Category, Id_Author, Id_Press, Comment, Quantity
	FROM deleted
END