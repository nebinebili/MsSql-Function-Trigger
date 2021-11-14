--1. Müəyyən Publisher tərəfindən çap olunmuş minimum səhifəli kitabların siyahısını çıxaran funksiya yazın

CREATE FUNCTION MinumumPageBook(@PressName NVARCHAR(30))
RETURNS  Table
RETURN 
(
  SELECT TOP(3) Books.Pages,Books.Name AS BookName,Press.Name AS PressName FROM Books INNER JOIN Press
  ON Books.Id_Press=Press.Id
  WHERE Press.Name=@PressName
  ORDER BY Books.Pages 
)

SELECT * FROM MinumumPageBook('Piter')

--2. Orta səhifə sayı N-dən çox səhifəli kitab çap edən Publisherlərin adını qaytaran funksiya yazın. 
--N parameter olaraq göndərilir.

CREATE FUNCTION PublisherNameForAvgPages(@N int)
RETURNS TABLE
RETURN
(
   SELECT AVG(Pages) AS PagesAVG,Press.Name FROM Books INNER JOIN Press
   ON Books.Id_Press=Press.Id
   GROUP BY Press.Name
   HAVING AVG(Pages)>@N
)

SELECT * FROM PublisherNameForAvgPages(300)

--3. Müəyyən Publisher tərəfindən çap edilmiş bütün kitab səhifələrinin cəmini tapan və qaytaran funksiya yazın.

CREATE FUNCTION SumPagesBooks(@PressName NVARCHAR(30))
RETURNS  Table
RETURN 
(
  SELECT SUM(Pages) AS SumPagesBooks,Press.Name AS PressName FROM Books INNER JOIN Press
  ON Books.Id_Press=Press.Id
  WHERE Press.Name=@PressName
  GROUP BY Press.Name 
)

SELECT * FROM SumPagesBooks('Piter')

--4. Müəyyən iki tarix aralığında kitab götürmüş Studentlərin ad və soyadını list şəklində qaytaran funksiya yazın.

CREATE FUNCTION FStudents(@DateOut1 datetime,@DateOut2 datetime)
RETURNS TABLE
RETURN
(
  SELECT Students.FirstName,Students.LastName FROM Students INNER JOIN S_Cards
  ON Students.Id=S_Cards.Id_Student
  WHERE @DateOut1<S_Cards.DateOut AND S_Cards.DateOut<@DateOut2
)

SELECT * FROM FStudents('2000.05.18','2001.05.05')

--5. Müəyyən kitabla hal hazırda işləyən bütün tələbələrin siyahısını qaytaran funksiya yazın.

CREATE FUNCTION FBooks(@BookName NVARCHAR(100))
RETURNS TABLE
RETURN
(
  SELECT Books.Name,Students.FirstName,Students.LastName FROM Students INNER JOIN S_Cards
  ON Students.Id=S_Cards.Id_Student INNER JOIN Books
  ON Books.Id=S_Cards.Id_Book
  WHERE Books.Name=@BookName
)

SELECT * FROM FBooks('SQL')

--6. Çap etdiyi bütün səhifə cəmi N-dən böyük olan Publisherlər haqqında informasiya qaytaran funksiya yazın.

CREATE FUNCTION PublisherInfo(@N int)
RETURNS TABLE
RETURN
(
   SELECT Press.Id,Press.Name,SUM(Pages) AS PagesSUM FROM Books INNER JOIN Press
   ON Books.Id_Press=Press.Id
   GROUP BY Press.Name,Press.Id
   HAVING SUM(Pages)>@N
)

SELECT * FROM PublisherInfo(1000)

--7.Studentlər arasında Ən popular yazici və onun götürülmüş kitablarının 
--sayı haqqında informasiya verən funksiya yazın

CREATE FUNCTION PopularAuthorForStudents()
RETURNS TABLE
RETURN
(
  SELECT TOP(1) WITH TIES Authors.FirstName,COUNT(Authors.FirstName) AS Popular,Books.Name AS BookName
  FROM Students INNER JOIN S_Cards
  ON Students.Id=S_Cards.Id_Student INNER JOIN Books
  ON Id_Book=Books.Id INNER JOIN Authors
  ON Id_Author=Authors.Id
  GROUP BY Authors.FirstName,Books.Name
  ORDER BY Popular DESC
)

SELECT * FROM PopularAuthorForStudents()

--8.Studentlər və Teacherlər (hər ikisi) tərəfindən götürülmüş 
--(ortaq - həm onlar həm bunlar) kitabların listini qaytaran funksiya yazın.

CREATE FUNCTION BothBooksTeacherAndStuden()
RETURNS TABLE
RETURN 
(
   SELECT DISTINCT Books.Name FROM S_Cards INNER JOIN Books
   ON S_Cards.Id_Book=Books.Id
   WHERE Books.Name=ANY
   (
     SELECT Books.Name FROM T_Cards INNER JOIN Books
	 ON T_Cards.Id_Book=Books.Id
   )
)

SELECT * FROM BothBooksTeacherAndStuden()

--9. Kitab götürməyən tələbələrin sayını qaytaran funksiya yazın.

CREATE FUNCTION DintTakeBookStudentsCount()
RETURNS int
AS
BEGIN

  DECLARE @count int=0;
  SELECT @count=COUNT(Students.Id) FROM S_Cards FULL JOIN Students
  ON Students.Id=S_Cards.Id_Student
  WHERE Id_Book IS NULL

RETURN @count;
END


DECLARE @result int = 0
EXEC @result = DintTakeBookStudentsCount 
SELECT @result AS StudentCount

--10. Kitabxanaçılar və onların verdiyi kitabların sayını qaytaran funksiya yazın.

CREATE FUNCTION LibsTotalBooks()
RETURNS TABLE
RETURN
(
  SELECT Libs.LastName,Libs.FirstName,
  ((SELECT COUNT(*) 
  FROM S_Cards
  WHERE S_Cards.Id_Lib = Libs.Id
  GROUP BY S_Cards.Id_Lib) +
  (SELECT COUNT(*) 
  FROM T_Cards
  WHERE T_Cards.Id_Lib = Libs.Id
  GROUP BY T_Cards.Id_Lib)) AS Total
  FROM Libs
)

SELECT * FROM LibsTotalBooks()