/*
********************************************************************************
CIS276 @PCC using SQL Server 2012

This script will validate the input CustID, OrderID, PartID, and Quantity and if
all validations pass will add a new lineitem to the ORDERITEMS table.

2015.03.02 Alan Miles, Instructor
2017.03.09 Jason Huels
********************************************************************************
*/
USE s276JHuels

/*
--------------------------------------------------------------------------------
ValidateCustID

This procedure will validate the input CustID and return Success if it passes and Fail
if it does not.

2017.03.09 Jason Huels
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidateCustID')
    BEGIN 
        DROP PROCEDURE ValidateCustID; 
    END;    -- must use block for more than one statement
-- END IF;  SQL Server does not use END IF 
GO

-- Notice my found variable contains the customer name
-- YOU can/should do something else to indicate a row exists to validate CustID

CREATE PROCEDURE ValidateCustID 
    @vCustid SMALLINT,
    @vFound  CHAR(25) OUTPUT 
AS 
BEGIN 
    SET @vFound = 'Fail';  -- initializes my found variable
    SELECT @vFound = Cname 
    FROM CUSTOMERS
    WHERE CustID = @vCustid;
END;
GO
/*
-- testing block for ValidateCustID
BEGIN
    
    DECLARE @vCname CHAR(25);  -- holds value returned from procedure

    EXECUTE ValidateCustID 1, @vCname OUTPUT;
    PRINT 'ValidateCustID test with valid CustID 1 returns ' + @vCname;

    EXECUTE ValidateCustID 5, @vCname OUTPUT;
    PRINT 'ValidateCustID test w/invalid CustID 5 returns ' + @vCname;

END;
GO
*/

/*
--------------------------------------------------------------------------------
ValidateOrderID

This procedure will validate the input OrderID and the OrderID/CustID combination
and return Success if it passes, Fail if the OrderID is invalid, or Invalid if the 
OrderID and CustID do not correspond.

2017.03.09 Jason Huels
---------------------------------
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidateOrderID')
    BEGIN DROP PROCEDURE ValidateOrderID; END;
GO

CREATE PROCEDURE ValidateOrderID -- with custid and orderid input
	@vCustID SMALLINT,
	@vOrderID SMALLINT,
	@vRetVal CHAR(25) OUTPUT 
AS 
BEGIN 
    SET @vRetVal = 'Fail';

-- OrderID found in ORDERS table . . .
	SELECT @vRetVal = 'Success'
    FROM ORDERS
    WHERE OrderID = @vOrderID;

    -- CustID/OrderID matching allows further processing 
	-- CustID/OrderID pairing is invalid.
	SELECT @vRetVal = 'Invalid' 
	FROM ORDERS
	WHERE OrderID = @vOrderID
	AND CustID <> @vCustID;
    
-- OrderID not found in ORDERS table is invalid.
END;
GO

/*
-- testing block for ValidateOrderID
BEGIN    
    DECLARE @vRetVal CHAR(25);

    EXECUTE ValidateOrderID 1,  6099, @vRetVal OUTPUT;
    PRINT 'ValidateOrderID test with valid CustID 1 and valid OrderID 6099 returns ' + @vRetVal;

    EXECUTE ValidateOrderID 21, 6099, @vRetVal OUTPUT;
    PRINT 'ValidateOrderID test w/ valid CustID 21 that does not correspond to valid OrderID 6099 returns ' + @vRetVal;
	
	EXECUTE ValidateOrderID 1, 9999, @vRetVal OUTPUT;
    PRINT 'ValidateOrderID test w/ invalid OrderID 9999 returns ' + @vRetVal;

END;
GO
*/

/*
--------------------------------------------------------------------------------
ValidatePartID

This procedure will validate the input PartID and return Success if it passes and Fail
if it does not.

2017.03.09 Jason Huels
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidatePartID')
    BEGIN DROP PROCEDURE ValidatePartID; END;
GO

CREATE PROCEDURE ValidatePartID 
	@vPartID SMALLINT,
	@vRetVal CHAR(25) OUTPUT 
AS 
BEGIN 
    SET @vRetVal = 'Fail';

-- PartID found in INVENTORY table . . .
	SELECT @vRetVal = 'Success'
    FROM INVENTORY
    WHERE PartID = @vPartID;
END;
GO

/*
-- testing block for ValidatePartID
BEGIN    
    DECLARE @vRetVal CHAR(25);
    EXECUTE ValidatePartID 1001, @vRetVal OUTPUT;
    PRINT 'ValidatePartID test with valid PartID 1001 returns ' + @vRetVal;

    EXECUTE ValidatePartID 1111, @vRetVal OUTPUT;
    PRINT 'ValidatePartID test w/invalid PartID 1111 returns ' + @vRetVal;
END;
GO
*/

/*
--------------------------------------------------------------------------------
ValidateQty

This procedure will validate the input Qty to make sure the value is positive
and return Success if it passes and Fail if it does not.

2017.03.09 Jason Huels
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidateQty')
    BEGIN DROP PROCEDURE ValidateQty; END;
GO

CREATE PROCEDURE ValidateQty 
	@vQty SMALLINT,
	@vRetVal CHAR(25) OUTPUT 
AS 
BEGIN 
    SET @vRetVal = 'Fail';
-- No query required; test for positive value
	IF @vQty > 0
		BEGIN
			SET @vRetVal = 'Success';	
		END;
END;
GO

/*
-- testing block for ValidateQty
BEGIN   
    DECLARE @vRetVal CHAR(25);

    EXECUTE ValidateQty 15, @vRetVal OUTPUT;
    PRINT 'ValidateQty test with valid Qty 15 returns ' + @vRetVal;

    EXECUTE ValidateQty -15, @vRetVal OUTPUT;
    PRINT 'ValidateQty test w/invalid Qty -15 returns ' + @vRetVal; 
END;
GO
*/

/*
--------------------------------------------------------------------------------
ORDERITEMS.Detail determines new value:
You can handle NULL within the projection but it can be done in two steps
(SELECT and then test).  It is important to deal with the possibility of NULL
because the detail is part of the primary key and therefore cannot contain NULL.

GetNewDetail

This procedure will determine and return the new detail value for the input OrderID

2017.03.09 Jason Huels
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'GetNewDetail')
    BEGIN DROP PROCEDURE GetNewDetail; END;
GO

CREATE PROCEDURE GetNewDetail 
	@vOrderID SMALLINT,
	@vNewDetail CHAR(25) OUTPUT 
AS 
BEGIN 
-- Use @vOrderid (input) to get @vNewDetail (output) via a query;
  SELECT  @vNewDetail = (ISNULL(MAX(Detail),0)+1)
  FROM    ORDERITEMS 
  WHERE   OrderID = @vOrderID;
END;
GO

/*
-- testing block for GetNewDetail 
BEGIN   
    DECLARE @vRetVal CHAR(25);

    EXECUTE GetNewDetail 6099, @vRetVal OUTPUT;
    PRINT 'GetNewDetail test with OrderID 6099 with 5 lineitems returns ' + @vRetVal; 
	EXECUTE GetNewDetail 6107, @vRetVal OUTPUT;
    PRINT 'GetNewDetail test with OrderID 6107 with 0 lineitems returns ' + @vRetVal;
END;
GO
*/

/*
--------------------------------------------------------------------------------
InventoryUpdateTRG

This trigger will ensure that the desired order quantity for the specified part
does not exceed the available stock quantity before updating the INVENTORY table

2017.03.09 Jason Huels
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'InventoryUpdateTRG')
    BEGIN DROP TRIGGER InventoryUpdateTRG; END;
GO

CREATE TRIGGER InventoryUpdateTRG
	ON INVENTORY
	FOR UPDATE
AS
	DECLARE @vQty SMALLINT;

BEGIN 

	SELECT	@vQty = StockQty
	FROM	INSERTED;

	-- compare (SELECT Stockqty FROM INSERTED) to zero
	IF @vQty < 0
		BEGIN
			-- your error handling
			RaisError('Error on Update. Ordered quantity exceeds stock quantity.',1,2) WITH SetError;
		END;

END; 
GO

/*
-- testing blocks for InventoryUpdateTRG
-- There should be at least three testing blocks here
BEGIN

	-- Ordered quantity results in a positive value
	UPDATE INVENTORY				
		SET StockQty = StockQty - 99
		WHERE PartID = 1001;

	-- Ordered quantity results in a 0 value
	UPDATE INVENTORY				
		SET StockQty = StockQty - 1
		WHERE PartID = 1001;

	-- Ordered quantity results in a negative value
	UPDATE INVENTORY				
		SET StockQty = StockQty - 101
		WHERE PartID = 1001;

END;
GO
*/

/*
--------------------------------------------------------------------------------
OrderitemsInsertTRG

This trigger will attempt to update the StockQty in the INVENTORY table before 
allowing an insert on the ORDERITEMS table

2017.03.09 Jason Huels
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'OrderitemsInsertTRG')
    BEGIN DROP TRIGGER OrderitemsInsertTRG; END;
GO

CREATE TRIGGER OrderitemsInsertTRG
ON ORDERITEMS
FOR INSERT
AS

		DECLARE @vQty SMALLINT;
		DECLARE @vPartID SMALLINT;

BEGIN 
    -- get new values for qty and partid from the INSERTED table
	SELECT	@vQty = Qty, @vPartID = PartID
	FROM	INSERTED;

    -- get current (changed) StockQty for this PartID
	SELECT	@vQty = StockQty - @vQty
	FROM	INVENTORY
	WHERE	PartID = @vPartID;

    -- UPDATE with current (changed) StockQty 
	UPDATE INVENTORY
		SET StockQty = @vQty
		WHERE PartID = @vPartID;

    -- your error handling
    IF (@@ERROR <> 0) 
        BEGIN 
            RaisError('An Error on Insert. Ordered quantity exceeds stock quantity.',1,2) WITH SetError;
        END;

END
GO

/*
-- testing blocks for OrderItemsInsertTrg
-- There should be at least three testing blocks here
BEGIN

	-- Ordered quantity results in a positive value
	INSERT INTO ORDERITEMS(Qty, PartID)
		VALUES(99, 1001);

	-- Ordered quantity results in a 0 value
	INSERT INTO ORDERITEMS(Qty, PartID)
		VALUES(1, 1001);

	-- Ordered quantity results in a negative value
	INSERT INTO ORDERITEMS(Qty, PartID)
		VALUES(101, 1001);

END;
GO
*/

/* 
--------------------------------------------------------------------------------
The TRANSACTION, this procedure calls GetNewDetail and performs an INSERT
to the ORDERITEMS table which in turn performs an UPDATE to the INVENTORY table.
Error handling determines COMMIT/ROLLBACK.

AddLineItem

This procedure will attempt to insert a new line item for the input values and will
issue a commit if the insert succeeds or a rollback if it fails

2017.03.10 Jason Huels
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'AddLineItem')
    BEGIN DROP PROCEDURE AddLineItem; END;
GO

CREATE PROCEDURE AddLineItem --[with OrderID, PartID and Qty input parameters]
	@vOrderID SMALLINT,
	@vPartID SMALLINT,
	@vQty SMALLINT
	
AS
BEGIN
	DECLARE @vNewDetail SMALLINT

BEGIN TRANSACTION    -- this is the only BEGIN TRANSACTION for the lab assignment
    EXECUTE GetNewDetail @vOrderID, @vNewDetail OUTPUT;
    INSERT INTO ORDERITEMS (OrderID, Detail, PartID, Qty)
		VALUES(@vOrderID, @vNewDetail, @vPartID, @vQty);

    -- your error handling
    IF (@@ERROR <> 0) 
        BEGIN 
            RaisError('Ordered quantity exceeds stock quantity. Issuing Rollback.',1,2) WITH SetError;
			ROLLBACK TRANSACTION;
        END;
	ELSE
		BEGIN
			PRINT (LTRIM(STR(@vQty)) + ' units of part ' + LTRIM(STR(@vPartID)) + ' added to order ' + LTRIM(STR(@vOrderID)) + '. Committing transaction.');
			COMMIT TRANSACTION;
		END;
-- END TRANSACTION;
END;
GO

-- No AddLineItem tests, saved for main block testing
-- well, you could EXECUTE AddLineItem 6099,1001,50
GO

/* 
--------------------------------------------------------------------------------
Puts all of the previous together to produce a solution for Lab8 done in
SQL Server. This stored procedure accepts the 4 pieces of input: 
Custid, Orderid, Partid, and Qty (in that order please). It validates all the 
data and does the transaction processing by calling the previously written and 
tested modules.

Lab8proc

This procedure will call the validation procedures for the input CustID, OrderID, 
PartID, and Qty and will call the AddLineItem procedure if all validations pass
or issue a failure message for each validation that fails.

2017.03.10 Jason Huels
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'Lab8proc')
    BEGIN DROP PROCEDURE Lab8proc; END;
GO

CREATE PROCEDURE Lab8proc --(with the four values input)
	@vCustID SMALLINT,
	@vOrderID SMALLINT,
	@vPartID SMALLINT,
	@vQty SMALLINT

	
AS

BEGIN

	DECLARE @vRetVal  CHAR(25); 
	DECLARE @vNewDetail  SMALLINT; 
	DECLARE @vMyBool  CHAR(25) = 'True';

	-- Validate CustID
    EXECUTE ValidateCustID @vCustID, @vRetVal OUTPUT;
	IF (@vRetVal = 'Fail') 
		BEGIN 
			PRINT('Invalid CustID') ;
			SET @vMyBool = 'False';
		END;

	-- Validate OrderID
	EXECUTE ValidateOrderID @vCustID, @vOrderID, @vRetVal OUTPUT;
	IF (@vRetVal = 'Fail') 
		BEGIN 
			PRINT('Invalid OrderID') ;
			SET @vMyBool = 'False';
		END;
	ELSE IF (@vRetVal = 'Invalid') 
		BEGIN 
			PRINT('OrderID does not match CustID') ;
			SET @vMyBool = 'False';
		END;

	-- Validate PartID
    EXECUTE ValidatePartID @vPartID, @vRetVal OUTPUT;
		IF (@vRetVal = 'Fail') 
			BEGIN 
				PRINT('Invalid PartID') ;
			SET @vMyBool = 'False';
		END;

	-- Validate Qty
    EXECUTE ValidateQty @vQty, @vRetVal OUTPUT;
		IF (@vRetVal = 'Fail') 
			BEGIN 
				PRINT('Invalid Qty') ;
				SET @vMyBool = 'False';
			END;

	-- IF everything validates THEN we can do the TRANSACTION
	    IF (@vMyBool = 'True') 
			BEGIN 
				EXECUTE AddLineItem @vOrderID, @vPartID, @vQty;
				PRINT (LTRIM(STR(@vQty)) + ' units of part ' + LTRIM(STR(@vPartID)) + ' added to order ' + LTRIM(STR(@vOrderID)));
			END;
		ELSE -- If the validations fail display this message...
			BEGIN
				PRINT ('Something went wrong.');
			END;
    -- ENDIF;
END;
GO 

/*
--------------------------------------------------------------------------------
-- Your testing blocks for Lab8proc goes last
--------------------------------------------------------------------------------
*/
/*
DECLARE
BEGIN
    
	-- Valid custID, orderID, and partID. Invalid quantity.
	EXECUTE Lab8proc 1, 6099, 1001, 0;

	-- Valid orderID, partID, and quantity. Invalid custid.
	EXECUTE Lab8proc 100, 6099, 1001, 99;

	-- Valid custID, partID, and quantity. Invalid orderID
	EXECUTE Lab8proc 1, 9099, 1001, 99;

	-- Valid custID, orderID, and quantity. Invalid partID
	EXECUTE Lab8proc 1, 6099, 1111, 99;

	-- All inputs valid but custID and orderID don't match
	EXECUTE Lab8proc 4, 6099, 1001, 99;

	-- All inputs valid but order Qty exceeds stockQty
	EXECUTE Lab8proc 1, 6099, 1001, 101; 

	-- All inputs valid with no conflicts.
	EXECUTE Lab8proc 1, 6099, 1001, 15;

END;
*/