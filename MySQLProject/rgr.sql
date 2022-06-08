CREATE DATABASE UkrPoshta;

USE UkrPoshta;

CREATE TABLE Newspaper(
NewsId INT PRIMARY KEY NOT NULL UNIQUE,
NewsName VARCHAR(50) NOT NULL UNIQUE,
SernameEd VARCHAR(30) NOT NULL,
NameEd VARCHAR(30),
SecNameEd VARCHAR(30),
Prise FLOAT NOT NULL
);

CREATE TABLE PrintingHouse(
HouseId VARCHAR(10) PRIMARY KEY NOT NULL UNIQUE,
HouseName VARCHAR(50) NOT NULL UNIQUE,
HouseAdress VARCHAR(100) NOT NULL
);

CREATE TABLE PostalOffice(
PostId VARCHAR(10) NOT NULL PRIMARY KEY UNIQUE,
PostalAdress VARCHAR(100)
);


CREATE TABLE Circulation(
HouseId VARCHAR(10) NOT NULL,
NewsId INT NOT NULL,
Amount INT,
CONSTRAINT House FOREIGN KEY (HouseId) REFERENCES PrintingHouse(HouseId) ON DELETE CASCADE,
CONSTRAINT NewsPaper FOREIGN KEY (NewsId) REFERENCES Newspaper(NewsId) ON DELETE CASCADE
);


CREATE TABLE Deliveries(
PostId VARCHAR(10) NOT NULL,
NewsId INT NOT NULL,
HouseId VARCHAR(10) NOT NULL,
Amount INT,
CONSTRAINT P_id FOREIGN KEY (PostId) REFERENCES PostalOffice(PostId) ON DELETE CASCADE,
CONSTRAINT P_NewsPaper FOREIGN KEY (NewsId) REFERENCES Circulation(NewsId) ON DELETE CASCADE,
CONSTRAINT P_HouseId FOREIGN KEY (HouseId) REFERENCES Circulation(HouseId) ON UPDATE CASCADE
);

DROP TABLE Deliveries;

DROP TABLE Circulation;

#заповнимо таблиці даними

INSERT Newspaper(NewsId, NewsName,  SernameEd, NameEd, SecNameEd, Prise)
VALUE (86621, 'На пенсії',  'Скоробогатько', 'Олександр', 'Міронович', 10.45),
      (60174, 'Пенсійна телепрограма', 'Скоробогатько', 'Олександр', 'Міронович', 6.80),
      (76312, 'Бульвар Гордона', 'Кресяк', 'Андрій', 'Романович', 20.05),
      (76395, 'Forbes Ukraine', 'Кравець', 'Марта', 'Олегівна', 199.00),
      (33602, 'Порадниця', 'Шахрайчук', 'Анастасія', 'Євгенівна', 45.00),
      (86505, 'Мої літа - моє багатство', 'Скиба', 'Олександр', 'Володимирович', 29.95),
      (49256, 'Погляд часу', 'Вітик', 'Орест', 'Дмітрович', 15.77),
      (35365, 'Наша кухня', 'Шахрайчук', 'Анастасія', 'Євгенівна', 16.50),
      (61019, 'Сільські вісті', 'Ризванюк', 'Тетяна', 'Олексіївна', 34.48),
      (37278, 'Країна', 'Матюшко', 'Елеонора', 'Романівна', 106.00);
      
INSERT PrintingHouse(HouseId, HouseName, HouseAdress)
VALUE('03584', 'Видання Основа', 'вул. Жилянська 87/30'),
     ('03148', 'Копі центр Срібний Млин', 'пл. Льва Толстого, 1, ТРЦ Метроград, 4-й квартал'),
	 ('03494', 'Компанія Юнівест Маркетинг', 'вул. Дмитрієвська, 44б'),
	 ('03511', 'MD print', 'вул. Гончарна, 3'),
     ('01001', 'Індіго прінт', 'вул. Шота Руставелі, 20б'),
     ('04050', 'Тіпографія Акцент', 'вул. Раскової Марини, 11б');
	
INSERT PostalOffice(PostId, PostalAdress)
VALUE ('02166', 'просп. Лісовий, 25'),
	  ('02088', 'вул. Харченка Євгенія, 49'),
      ('05300', 'вул. Кірпи Георгія, 2'),
	  ('02091', 'шосе Харківське, 164'),
	  ('02144', 'вул. Русової Софії, 5'),
	  ('03146', 'вул. Коласа Якуба, 11');
      
#процедура для коректного заповнення таблиці із тиражами
 DELIMITER // 
CREATE PROCEDURE InsertingCirculation(Housename VARCHAR(50), Newsname VARCHAR(50), amount INT) 
BEGIN
DECLARE C INT DEFAULT 0;
DECLARE IndbyHouse VARCHAR(10);
DECLARE IndbyNews INT;
SET IndbyHouse = (SELECT HouseId FROM PrintingHouse WHERE PrintingHouse.HouseName = Housename);
SET IndbyNews = (SELECT NewsId FROM Newspaper WHERE Newspaper.NewsName = Newsname);
SELECT COUNT(*) INTO C FROM Circulation WHERE
Circulation.HouseId = IndbyHouse AND Circulation.NewsId = IndbyNews;
IF C = 0 THEN
INSERT INTO Circulation(HouseId, NewsId, Amount)
VALUE (IndbyHouse, IndbyNews, amount);
ELSE 
UPDATE Circulation
SET Amount = amount WHERE Circulation.HouseId = IndbyHouse AND Circulation.NewsId = IndbyNews;
END IF; 
END// 

CALL InsertingCirculation('Компанія Юнівест Маркетинг', 'Країна', 700) ;
CALL InsertingCirculation('Компанія Юнівест Маркетинг', 'Forbes Ukraine', 1300) ;
CALL InsertingCirculation('Копі центр Срібний Млин', 'На пенсії', 2000) ;  
CALL InsertingCirculation('Копі центр Срібний Млин', 'Пенсійна телепрограма', 3000) ;   
CALL InsertingCirculation('Тіпографія Акцент', 'Пенсійна телепрограма', 2000) ;   
CALL InsertingCirculation('Тіпографія Акцент', 'Мої літа - моє багатство', 1500) ;   
CALL InsertingCirculation('Індіго прінт', 'Погляд часу', 1000) ;
CALL InsertingCirculation('MD print', 'Бульвар Гордона', 900) ;
CALL InsertingCirculation('Видання Основа', 'Бульвар Гордона', 500) ;  
CALL InsertingCirculation('Тіпографія Акцент', 'Бульвар Гордона', 2000) ;   
CALL InsertingCirculation('Копі центр Срібний Млин', 'Наша кухня', 2000) ;   
CALL InsertingCirculation('Видання Основа', 'Сільські вісті', 500) ;   
CALL InsertingCirculation('MD print', 'Порадниця', 4000) ;   
CALL InsertingCirculation('Видання Основа', 'Погляд часу', 1100) ; //

 
#процедура для коректного заповнення таблиці із поставками
CREATE PROCEDURE InsertingDeliveries(Postid VARCHAR(10), Housename VARCHAR(100), Newsname VARCHAR(100), amount INT)
BEGIN
DECLARE C INT DEFAULT 0;
DECLARE IndbyHouse VARCHAR(10);
DECLARE IndbyNews INT;
SET IndbyHouse = (SELECT HouseId FROM PrintingHouse WHERE PrintingHouse.HouseName = Housename);
SET IndbyNews = (SELECT NewsId FROM Newspaper WHERE Newspaper.NewsName = Newsname);
SELECT COUNT(*) INTO C FROM  Deliveries WHERE 
Deliveries.PostId = Postid AND Deliveries.NewsId = IndbyNews AND Deliveries.HouseId = IndbyHouse;
IF C = 0 THEN 
INSERT INTO Deliveries(PostId, NewsId,  HouseId, Amount)
VALUE (Postid, IndbyNews,  IndbyHouse, amount);
ELSE 
UPDATE Deliveries
SET Amount = amount WHERE Deliveries.HouseId = IndbyHouse AND Deliveries.NewsId = IndbyNews;
END IF;
END; //

#Типографія не може постачати журналів більше, ніж вона друкує (або коли вона не друкує їх зовсім)
CREATE TRIGGER NumberOfNewspapersInHouseInsert
BEFORE INSERT
ON Deliveries
FOR EACH ROW
BEGIN
DECLARE NumCir INT;
DECLARE NumDel INT;
SELECT IFNULL(SUM(Amount), 0) INTO NumCir FROM Circulation WHERE 
Circulation.HouseId = NEW.HouseId AND Circulation.NewsId = NEW.NewsId;
SELECT IFNULL(SUM(Amount), 0) INTO NumDel FROM Deliveries WHERE 
Deliveries.HouseId = NEW.HouseId AND Deliveries.NewsId = NEW.NewsId;
IF NumCir < (NumDel + NEW.Amount) THEN
SIGNAL SQLSTATE VALUE '45000'
SET MESSAGE_TEXT = 'Ця типографія не друкує стільки потрібних журналів!';
END IF;
END;//

CREATE TRIGGER NumberOfNewspapersInHouseUpdate
BEFORE UPDATE
ON Deliveries
FOR EACH ROW
BEGIN
DECLARE NumCir INT;
SELECT IFNULL(SUM(Amount), 0) INTO NumCir FROM Circulation WHERE 
Circulation.HouseId = NEW.HouseId AND Circulation.NewsId = NEW.NewsId;
IF NumCir < NEW.Amount THEN
SIGNAL SQLSTATE VALUE '45000'
SET MESSAGE_TEXT = 'Ця типографія не друкує стільки потрібних журналів!';
END IF;
END;//

CALL InsertingDeliveries( '02088', 'Компанія Юнівест Маркетинг', 'Країна', 700) ;
CALL InsertingDeliveries('02091', 'Компанія Юнівест Маркетинг', 'Forbes Ukraine', 1300) ;
CALL InsertingDeliveries('02166', 'Копі центр Срібний Млин', 'На пенсії', 700) ;  
CALL InsertingDeliveries('02166', 'Копі центр Срібний Млин', 'Пенсійна телепрограма', 1000) ;
CALL InsertingDeliveries('02144', 'Копі центр Срібний Млин', 'На пенсії', 800) ;  
CALL InsertingDeliveries('02144', 'MD print', 'Порадниця', 2000) ;    
CALL InsertingDeliveries('02091', 'Тіпографія Акцент', 'Пенсійна телепрограма', 2000) ;   
CALL InsertingDeliveries('03146', 'Тіпографія Акцент', 'Мої літа - моє багатство', 500) ;   
CALL InsertingDeliveries('02166', 'Індіго прінт', 'Погляд часу', 800) ;
CALL InsertingDeliveries('02144', 'MD print', 'Бульвар Гордона', 900) ;
CALL InsertingDeliveries('02088', 'Копі центр Срібний Млин', 'На пенсії', 500) ; 
CALL InsertingDeliveries('02091', 'Копі центр Срібний Млин', 'Пенсійна телепрограма', 2000) ;   
CALL InsertingDeliveries('02088', 'Видання Основа', 'Бульвар Гордона', 500) ;  
CALL InsertingDeliveries('02088', 'Тіпографія Акцент', 'Бульвар Гордона', 1000) ;  
CALL InsertingDeliveries('03146', 'Тіпографія Акцент', 'Бульвар Гордона', 1000) ;  
CALL InsertingDeliveries('03146', 'Копі центр Срібний Млин', 'Наша кухня', 2000) ;   
CALL InsertingDeliveries('02091', 'Тіпографія Акцент', 'Мої літа - моє багатство', 1000) ; 
CALL InsertingDeliveries('02091', 'Видання Основа', 'Сільські вісті', 500) ;   
CALL InsertingDeliveries('05300', 'MD print', 'Порадниця', 2000) ;  
CALL InsertingDeliveries('02091', 'Видання Основа', 'Погляд часу', 1100) ; //

CALL InsertingDeliveries('02091', 'Видання Основа', 'Погляд часу', 10000) ; //

# Друкарня може бути закрита, тоді необхідно скоригувати роботу інших друкарень з урахуванням потреб поштових відділень у газетах. 
# будемо передавати друк потрібних газет тіпогафіям із найменшим тиражем. 

CREATE VIEW TotalCirculation
AS
SELECT HouseId, SUM(Amount) AS SM FROM Circulation
GROUP BY HouseId
ORDER BY SM;//

SELECT *FROM TotalCirculation;//

CREATE PROCEDURE CloseHouse(Housename VARCHAR(100))
BEGIN
DECLARE MinSum INT;
DECLARE MinHouse VARCHAR(10);
SELECT MIN(SM) INTO MinSum  FROM TotalCirculation 
WHERE HouseId != (SELECT HouseId FROM PrintingHouse WHERE PrintingHouse.HouseName = Housename);
SELECT HouseId INTO MinHouse FROM TotalCirculation WHERE SM = MinSum;
UPDATE Circulation
SET Circulation.HouseId = MinHouse 
WHERE Circulation.HouseId = (SELECT HouseId FROM PrintingHouse WHERE PrintingHouse.HouseName = Housename);
END;//

CALL CloseHouse('MD print');//


# За якими адресами друкуються газети цієї назви?

CREATE PROCEDURE WhereThisNewspaper(Newsname VARCHAR(100))
BEGIN
DECLARE Id INT;
SELECT NewsId INTO Id FROM Newspaper WHERE Newspaper.NewsName = Newsname;
SELECT HouseAdress AS 'Адреса типографії' FROM PrintingHouse WHERE 
HouseId IN (SELECT HouseId FROM Circulation WHERE Circulation.NewsId = Id);
END;//

CALL WhereThisNewspaper('Погляд часу');//

# Прізвище редактора газети, яке друкується у зазначеній друкарні найбільшим тиражем?
DROP PROCEDURE BestEditorOfHouse;//
CREATE PROCEDURE BestEditorOfHouse(House VARCHAR(100))
BEGIN
DECLARE Id VARCHAR(10);
DECLARE Maximum INT;
SELECT HouseId INTO Id FROM PrintingHouse WHERE PrintingHouse.HouseName = House;
SELECT MAX(Amount) INTO Maximum FROM Circulation WHERE Circulation.HouseId = Id;
SELECT SernameEd AS 'Прізвище редактора' FROM Newspaper WHERE Newspaper.NewsId IN 
(SELECT NewsId FROM Circulation WHERE Circulation.HouseId = Id AND Circulation.Amount = Maximum);
END;//


CALL BestEditorOfHouse('Видання Основа');//

# На які поштові відділення (адреси) надходить газета, яка має ціну більшу за вказану?
DROP PROCEDURE MoreExpensiveThan;//
CREATE PROCEDURE MoreExpensiveThan(prise FLOAT)
BEGIN
SELECT DISTINCT PostalAdress AS 'Адреси поштових відділень' FROM Deliveries
JOIN PostalOffice ON  Deliveries.PostId = PostalOffice.PostId 
WHERE Deliveries.NewsId IN (SELECT NewsId FROM Newspaper WHERE Newspaper.Prise > prise);
END;//

CALL MoreExpensiveThan(20.50);//
DROP PROCEDURE ThereAreLessThan;//
# Які газети та куди (номер пошти) надходять у кількості меншій, ніж задане?
CREATE PROCEDURE ThereAreLessThan(num INT)
BEGIN
SELECT Deliveries.PostId AS 'Номер відділення', NewsName AS 'Газета' FROM Deliveries
JOIN Newspaper ON  Deliveries.NewsId = Newspaper.NewsId 
WHERE Deliveries.Amount < num;
END;//



CALL ThereAreLessThan(1000);//

DROP PROCEDURE WhereItGoes;//
# 	Куди надходить ця газета, що друкується за цією адресою.
CREATE PROCEDURE WhereItGoes(newsname VARCHAR(100), adress VARCHAR(100))
BEGIN
SELECT DISTINCT PostalAdress AS 'Адреса відділення', Deliveries.PostId AS 'Номер відділення'
FROM Deliveries
JOIN PostalOffice ON Deliveries.PostId = PostalOffice.PostId
WHERE NewsId = (SELECT NewsId FROM Newspaper WHERE Newspaper.NewsName = newsname)
AND HouseId = (SELECT HouseId FROM PrintingHouse WHERE PrintingHouse.HouseAdress = adress);
END;//

CALL WhereItGoes('Бульвар Гордона', 'вул. Раскової Марини, 11б');//

# Необхідно передбачити можливість видачі довідки про індекс та ціну вказаної газети:
CREATE PROCEDURE NewspaperReference(Newsname VARCHAR(100))
BEGIN
SELECT NewsId AS 'Індес', Prise AS 'Ціна' FROM Newspaper 
WHERE Newspaper.NewsName = Newsname;
END;//

CALL NewspaperReference('Forbes Ukraine');//

# Звіт повинен містити по кожній друкарні такі відомості: загальна кількість газет, що друкуються в друкарні, 
# кількість газет кожного найменування, які газети і в якій кількості друкарня відправляє в кожне поштове відділення.

CREATE VIEW AllNewspapersInCirc
AS
SELECT HouseName AS 'Типографія', NewsName AS 'Газета', Amount AS 'Кількість'
FROM Circulation 
JOIN PrintingHouse
ON PrintingHouse.HouseId = Circulation.HouseId
JOIN Newspaper
ON Newspaper.NewsId = Circulation.NewsId;//

CREATE VIEW AllNewspapersInDels
AS
SELECT PostalAdress AS 'Поштове відділення', HouseName AS 'Типографія', 
NewsName AS 'Газета', Amount AS 'Кількість'
FROM Deliveries 
JOIN PrintingHouse
ON PrintingHouse.HouseId = Deliveries.HouseId
JOIN Newspaper
ON Newspaper.NewsId = Deliveries.NewsId
JOIN PostalOffice
ON PostalOffice.PostId = Deliveries.PostId;//


CREATE PROCEDURE Report()
BEGIN
SELECT HouseName AS 'Типографія', SM AS 'Загальна кількість газет'
FROM TotalCirculation
JOIN  PrintingHouse ON
TotalCirculation.HouseId = PrintingHouse.HouseId;
SELECT * FROM AllNewspapersInCirc;
SELECT * FROM AllNewspapersInDels;
END;//


CALL Report();//