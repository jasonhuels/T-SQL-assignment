/*
@Lab8Grading.sql
CIS276 @ PCC for SQL Server2012
20150302 Alan Miles 
20060604 vj
20101208 vj added CustID/OrderID pairing test
20101209 vj inconsequential changes
*/

USE s276JHuels

BEGIN
    DECLARE @v_now DATETIME
    SET @v_now = GETDATE()
    PRINT CHAR(10) + '*****************************************************';
    PRINT '*  Lab8 using SQL Server 2012 graded on ' + CONVERT(CHAR(12), @v_now, 101) + '*';
    PRINT '*****************************************************';

END;
GO

PRINT CHAR(10) + '=====================================================';
PRINT 'TEST 1, expecting invalid CustID message';
PRINT 'Custid  BAD, Orderid  BAD, Partid Good, Qty GOOD';
PRINT 'Custid    9, Orderid 9999, Partid 1010, Qty    9';
PRINT '=====================================================' + CHAR(10);
EXECUTE Lab8proc 9, 9999, 1010, 9;
GO

PRINT CHAR(10) + '=====================================================';
PRINT 'TEST 2a, expecting invalid OrderID message';
PRINT 'Custid GOOD, Orderid  BAD, Partid GOOD, Qty GOOD';
PRINT 'Custid    1, Orderid 9999, Partid 1010, Qty    9';
PRINT '=====================================================' + CHAR(10);
EXECUTE Lab8proc 1, 9999, 1010, 9;
GO

PRINT CHAR(10) + '=====================================================';
PRINT 'TEST 2b, expect bad CustID/OrderID pair message';
PRINT 'Custid GOOD, Orderid GOOD, Partid GOOD, Qty GOOD';
PRINT 'Custid   21, Orderid 6099, Partid 1010, Qty    9';
PRINT '=====================================================' + CHAR(10);
EXECUTE Lab8proc 21, 6099, 1010, 9;
GO

PRINT CHAR(10) + '=====================================================';
PRINT 'TEST 3, expecting invalid PartID message';
PRINT 'Custid GOOD, Orderid GOOD, Partid  BAD, Qty GOOD';
PRINT 'Custid   1,  Orderid 6099, Partid 9999, Qty    9';
PRINT '=====================================================' + CHAR(10);
EXECUTE Lab8proc 1, 6099, 9999, 9;
GO

PRINT CHAR(10) + '=====================================================';
PRINT 'TEST 4, expecting invalid input Qty message';
PRINT 'Custid GOOD, Orderid GOOD, Partid GOOD, Qty BAD';
PRINT 'Custid    1, Orderid 6099, Partid 1001, Qty   0';
PRINT '=====================================================' + CHAR(10);
EXECUTE Lab8proc 1, 6099, 1001, 0;
GO

PRINT CHAR(10) + '=====================================================';
PRINT 'TEST 5, expecting invalid input Qty message';
PRINT 'Custid GOOD, Orderid GOOD, Partid GOOD, Qty BAD';
PRINT 'Custid    1, Orderid 6099, Partid 1001, Qty  -1';
PRINT '=====================================================' + CHAR(10);
EXECUTE Lab8proc 1, 6099, 1001, -1;
GO

PRINT CHAR(10) + '=====================================================';
PRINT 'TEST 6, expecting INSUFFICIENT STOCK ON HAND msg';
PRINT 'Custid GOOD, Orderid GOOD, Partid GOOD, Qty GOOD';
PRINT 'Custid   1,  Orderid 6099, Partid 1001, Qty  200';
PRINT '=====================================================' + CHAR(10);
PRINT 'INVENTORY AND ORDERITEMS BEFORE TEST'
SELECT * FROM INVENTORY WHERE PartID = 1001;
SELECT * FROM ORDERITEMS WHERE OrderID = 6099;
PRINT 'EXECUTE Lab8proc 1, 6099, 1001, 200'
EXECUTE Lab8proc 1, 6099, 1001, 200;
GO
PRINT CHAR(10) + 'INVENTORY AND ORDERITEMS AFTER TEST'
SELECT * FROM INVENTORY WHERE PartID = 1001;
SELECT * FROM ORDERITEMS WHERE OrderID = 6099;
GO

PRINT CHAR(10) + '=====================================================';
PRINT 'TEST 7, USES UP ALL STOCK ON HAND';
PRINT 'Custid GOOD, Orderid GOOD, Partid GOOD, Qty GOOD';
PRINT 'Custid    1, Orderid 6099, Partid 1001, Qty  100';
PRINT '=====================================================' + CHAR(10);
PRINT 'INVENTORY AND ORDERITEMS BEFORE TEST'
SELECT * FROM INVENTORY WHERE PartID = 1001;
SELECT * FROM ORDERITEMS WHERE OrderID = 6099;
PRINT 'EXECUTE Lab8proc 1, 6099, 1001, 100';
EXECUTE Lab8proc 1, 6099, 1001, 100;
GO
PRINT CHAR(10) + 'INVENTORY AND ORDERITEMS AFTER TEST'
SELECT * FROM INVENTORY WHERE PartID = 1001;
SELECT * FROM ORDERITEMS WHERE OrderID = 6099;
GO

PRINT CHAR(10) + '=====================================================';
PRINT 'TEST 8, INSUFFICIENT STOCK ON HAND';
PRINT 'Custid GOOD, Orderid GOOD, Partid GOOD, Qty GOOD';
PRINT 'Custid    1, Orderid 6099, Partid 1001, Qty    9';
PRINT '=====================================================' + CHAR(10);
PRINT 'INVENTORY AND ORDERITEMS BEFORE TEST'
SELECT * FROM INVENTORY WHERE PartID = 1001;
SELECT * FROM ORDERITEMS WHERE OrderID = 6099;
PRINT 'EXECUTE Lab8proc 1, 6099, 1001, 9';
EXECUTE Lab8proc 1, 6099, 1001, 9;
GO
PRINT 'INVENTORY AND ORDERITEMS AFTER TEST'
SELECT * FROM INVENTORY WHERE PartID = 1001;
SELECT * FROM ORDERITEMS WHERE OrderID = 6099;
GO

PRINT CHAR(10) + '=====================================================';
PRINT 'TEST 9, this is a good transaction';
PRINT 'Custid GOOD, Orderid GOOD, Partid GOOD, Qty GOOD';
PRINT 'Custid    1, Orderid 6099, Partid 1002, Qty   29';
PRINT '=====================================================' + CHAR(10);
PRINT 'INVENTORY AND ORDERITEMS BEFORE TEST'
SELECT * FROM INVENTORY WHERE PartID = 1002;
SELECT * FROM ORDERITEMS WHERE OrderID = 6099;
PRINT 'EXECUTE Lab8proc 1, 6099, 1002, 29';
EXECUTE Lab8proc 1, 6099, 1002, 29;
GO
PRINT CHAR(10) + 'INVENTORY AND ORDERITEMS AFTER TEST'
SELECT * FROM INVENTORY WHERE PartID = 1002;
SELECT * FROM ORDERITEMS WHERE OrderID = 6099;
GO

PRINT CHAR(10) + '=====================================================';
PRINT 'TEST 10, FIRST DETAIL LINE';
PRINT 'Custid GOOD, Orderid GOOD, Partid GOOD, Qty GOOD';
PRINT 'Custid   15, Orderid 6107, Partid 1003, Qty   10';
PRINT '=====================================================' + CHAR(10);
PRINT 'INVENTORY AND ORDERITEMS BEFORE TEST'
SELECT * FROM INVENTORY WHERE PartID = 1003;
SELECT * FROM ORDERITEMS WHERE OrderID = 6107;
PRINT 'EXECUTE Lab8proc 15, 6107, 1003, 10';
EXECUTE Lab8proc 15, 6107, 1003, 10;
GO
PRINT CHAR(10) + 'INVENTORY AND ORDERITEMS AFTER TEST'
SELECT * FROM INVENTORY WHERE PartID = 1003;
SELECT * FROM ORDERITEMS WHERE OrderID = 6107;
GO

PRINT '=====================================================';
PRINT '=====================================================';
PRINT '*     INSTRUCTOR GRADING RUN (TESTING) COMPLETE     *';
PRINT '=====================================================';
PRINT '=====================================================';