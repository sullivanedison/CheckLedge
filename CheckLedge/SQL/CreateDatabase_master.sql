/*
	CheckLedge®
	© 2018 Yttrium Software, Inc.

	CreateDatabase_master.sql

	Creates the master database and database objects for CheckLedge® version 1.0.0.0

	Change Log
	-------------------------------------------------------------------------
	20 May 2018 : EMS : Initial creation


*/

SET NOCOUNT ON
GO

/*** Step 1: Create and setup the database ***/

-- Create the database
CREATE DATABASE [CheckLedge]
CONTAINMENT = NONE
ON PRIMARY 
	(
		  NAME = N'CheckLedge'
		, FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.YTTRIUM\MSSQL\DATA\CheckLedge.mdf'
		, SIZE = 8192KB
		, FILEGROWTH = 65536KB
	)
LOG ON 
	(
		  NAME = N'CheckLedge_log'
		, FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.YTTRIUM\MSSQL\DATA\CheckLedge_log.ldf'
		, SIZE = 8192KB
		, FILEGROWTH = 65536KB
	)
GO

-- Set database settings
ALTER DATABASE [CheckLedge] SET COMPATIBILITY_LEVEL = 130
GO
ALTER DATABASE [CheckLedge] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [CheckLedge] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [CheckLedge] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [CheckLedge] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [CheckLedge] SET ARITHABORT OFF 
GO
ALTER DATABASE [CheckLedge] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [CheckLedge] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [CheckLedge] SET AUTO_CREATE_STATISTICS ON(INCREMENTAL = OFF)
GO
ALTER DATABASE [CheckLedge] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [CheckLedge] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [CheckLedge] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [CheckLedge] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [CheckLedge] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [CheckLedge] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [CheckLedge] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [CheckLedge] SET  DISABLE_BROKER 
GO
ALTER DATABASE [CheckLedge] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [CheckLedge] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [CheckLedge] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [CheckLedge] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [CheckLedge] SET  READ_WRITE 
GO
ALTER DATABASE [CheckLedge] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [CheckLedge] SET  MULTI_USER 
GO
ALTER DATABASE [CheckLedge] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [CheckLedge] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [CheckLedge] SET DELAYED_DURABILITY = DISABLED 
GO

-- Set scoped configuration settings
USE [CheckLedge]
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO


-- Set the filegroup to PRIMARY
USE [CheckLedge]
GO

IF NOT EXISTS
(
	SELECT
		[name]
	FROM
		sys.filegroups
	WHERE
		[is_default] = 1
		AND [name] = N'PRIMARY'
)
BEGIN
	ALTER DATABASE [CheckLedge]
	MODIFY FILEGROUP [PRIMARY] DEFAULT
	;

END
GO


/*** Step 2: Create the tables ***/

USE [CheckLedge]
GO

-- AccountTypes
CREATE TABLE
	[AccountTypes]
	(
		  [uAccountTypesId] uniqueidentifier
			CONSTRAINT [uAccountTypesId_default]
			DEFAULT NEWSEQUENTIALID() ROWGUIDCOL
		, [cName] varchar(40) NOT NULL

		  CONSTRAINT [AccountTypes_PK] PRIMARY KEY ([uAccountTypesId])
		, CONSTRAINT [AccountTypes_cName_unq] UNIQUE ([cName])
	)
;

INSERT INTO [AccountTypes] ([cName])
SELECT 'Checking'
UNION SELECT 'Savings'
UNION SELECT 'Loan'
UNION SELECT 'Credit Card'
;

GO


-- Accounts
CREATE TABLE
	[Accounts]
	(
		  [uAccountsId] uniqueidentifier
			CONSTRAINT [uAccountsId_default]
			DEFAULT NEWSEQUENTIALID() ROWGUIDCOL
		, [uAccountTypesId] uniqueidentifier			
		, [cName] varchar(100) NOT NULL
		, [cBankName] varchar(100)
		, [cAccountNumber] varchar(100)
		, [cRoutingNumber] varchar(9)
		, [yCreditLimit] money
		, [yOverdraftMax] money
		, [dOpened] datetime
		, [lClosed] bit NOT NULL
		, [dClosed] datetime
		, [mNotes] varchar(MAX)

		  CONSTRAINT [Accounts_PK] PRIMARY KEY ([uAccountsId])
		, FOREIGN KEY ([uAccountTypesId]) REFERENCES [AccountTypes] ([uAccountTypesId])
		, CONSTRAINT [Accounts_cName_unq] UNIQUE ([uAccountTypesId], [cName])
	)
;

GO


-- BillCycles
CREATE TABLE
	[BillCycles]
	(
		  [uBillCyclesId] uniqueidentifier
			CONSTRAINT [uBillCyclesId_default]
			DEFAULT NEWSEQUENTIALID() ROWGUIDCOL
		, [cName] varchar(40) NOT NULL

		  CONSTRAINT [BillCycles_PK] PRIMARY KEY ([uBillCyclesId])
		, CONSTRAINT [BillCycles_cName_unq] UNIQUE ([cName])
	)
;

INSERT INTO [BillCycles] ([cName])
SELECT 'All' AS [cName]
;

GO


-- BillerTypes
CREATE TABLE
	[BillerTypes]
	(
		  [uBillerTypesId] uniqueidentifier
			CONSTRAINT [uBillerTypesId_default]
			DEFAULT NEWSEQUENTIALID() ROWGUIDCOL
		, [cName] varchar(40) NOT NULL

		  CONSTRAINT [BillerTypes_PK] PRIMARY KEY ([uBillerTypesId])
		, CONSTRAINT [BillerTypes_cName_unq] UNIQUE ([cName])
	)
;

INSERT INTO [BillerTypes] ([cName])
SELECT 'Auto Loan' AS [cName]
UNION SELECT 'Child Care' AS [cName]
UNION SELECT 'Credit Card' AS [cName]
UNION SELECT 'Entertainment' AS [cName]
UNION SELECT 'Fitness' AS [cName]
UNION SELECT 'Insurance' AS [cName]
UNION SELECT 'Medical' AS [cName]
UNION SELECT 'Mortgage' AS [cName]
UNION SELECT 'Personal Loan' AS [cName]
UNION SELECT 'Rent' AS [cName]
UNION SELECT 'Student Loan' AS [cName]
UNION SELECT 'Utilities' AS [cName]
;

GO


-- Billers
CREATE TABLE
	[Billers]
	(
		  [uBillersId] uniqueidentifier
			CONSTRAINT [uBillersId_default]
			DEFAULT NEWSEQUENTIALID() ROWGUIDCOL
		, [uBillCyclesId] uniqueidentifier
		, [uBillerTypesId] uniqueidentifier
		, [cName] varchar(100) NOT NULL
		, [cAddress1] varchar(100)
		, [cAddress2] varchar(100)
		, [cCity] varchar(100)
		, [cState] varchar(7)
		, [cZip] varchar(11)
		, [cPhone] varchar(15)
		, [cAccountNumber] varchar(100)
		, [iDueDay] int
		, [mNotes] varchar(MAX)
		, [cWebsite] varchar(4000)
		, [dCreated] datetime
		, [dUpdated] datetime
		, [lInactive] bit

		  CONSTRAINT [Billers_PK] PRIMARY KEY ([uBillersId])
		, FOREIGN KEY ([uBillCyclesId]) REFERENCES [BillCycles] ([uBillCyclesId])
		, FOREIGN KEY ([uBillerTypesId]) REFERENCES [BillerTypes] ([uBillerTypesId])
		, CONSTRAINT [Billers_cName_unq] UNIQUE ([cName])
	)
;

GO


-- TransactionTypes
CREATE TABLE
	[TransactionTypes]
	(
		  [uTransactionTypesId] uniqueidentifier
			CONSTRAINT [uTransactionTypesId_default]
			DEFAULT NEWSEQUENTIALID() ROWGUIDCOL
		, [uAccountTypesId] uniqueidentifier			
		, [cName] varchar(40) NOT NULL
		, [lSubtract] bit NOT NULL

		  CONSTRAINT [TransactionTypes_PK] PRIMARY KEY ([uTransactionTypesId])
		, FOREIGN KEY ([uAccountTypesId]) REFERENCES [AccountTypes] ([uAccountTypesId])
		, CONSTRAINT [TransactionTypes_cName_unq] UNIQUE ([uAccountTypesId], [cName])
	)
;

INSERT INTO
	[TransactionTypes]
	(
		  [uAccountTypesId]  
		, [cName]
		, [lSubtract]
	)
SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Checking') AS [uAccountTypesId]
	, 'Deposit' AS [cName]
	, 0 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Checking') AS [uAccountTypesId]
	, 'Check' AS [cName]
	, 1 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Checking') AS [uAccountTypesId]
	, 'Debit Card' AS [cName]
	, 1 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Checking') AS [uAccountTypesId]
	, 'Withdrawal' AS [cName]
	, 1 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Checking') AS [uAccountTypesId]
	, 'Interest' AS [cName]
	, 0 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Checking') AS [uAccountTypesId]
	, 'Online Bill Pay' AS [cName]
	, 1 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Checking') AS [uAccountTypesId]
	, 'Bank Credit' AS [cName]
	, 0 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Checking') AS [uAccountTypesId]
	, 'Bank Fee' AS [cName]
	, 1 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Savings') AS [uAccountTypesId]
	, 'Deposit' AS [cName]
	, 0 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Savings') AS [uAccountTypesId]
	, 'Debit Card' AS [cName]
	, 1 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Savings') AS [uAccountTypesId]
	, 'Withdrawal' AS [cName]
	, 1 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Savings') AS [uAccountTypesId]
	, 'Interest' AS [cName]
	, 0 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Savings') AS [uAccountTypesId]
	, 'Bank Credit' AS [cName]
	, 0 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Savings') AS [uAccountTypesId]
	, 'Bank Fee' AS [cName]
	, 1 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Credit Card') AS [uAccountTypesId]
	, 'Charge' AS [cName]
	, 0 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Credit Card') AS [uAccountTypesId]
	, 'Interest' AS [cName]
	, 0 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Credit Card') AS [uAccountTypesId]
	, 'Fee' AS [cName]
	, 0 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Credit Card') AS [uAccountTypesId]
	, 'Payment' AS [cName]
	, 1 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Loan') AS [uAccountTypesId]
	, 'Principal' AS [cName]
	, 0 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Loan') AS [uAccountTypesId]
	, 'Interest' AS [cName]
	, 0 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Loan') AS [uAccountTypesId]
	, 'Fee' AS [cName]
	, 0 AS [lSubtract]
UNION SELECT
	  (SELECT [uAccountTypesId] FROM [AccountTypes] WHERE [cName] = 'Loan') AS [uAccountTypesId]
	, 'Payment' AS [cName]
	, 1 AS [lSubtract]
;

GO


-- Transactions
CREATE TABLE
	[Transactions]
	(
		  [uTransactionsId] uniqueidentifier
			CONSTRAINT [uTransactionsId_default]
			DEFAULT NEWSEQUENTIALID() ROWGUIDCOL
		, [uAccountsId] uniqueidentifier
		, [uTransactionTypesId] uniqueidentifier
		, [uBillersId] uniqueidentifier
		, [iTransactionNumber] int NOT NULL
		, [dTransaction] datetime NOT NULL
		, [cDescription] varchar(1000)
		, [yAmount] money NOT NULL
		, [iCheckNumber] int
		, [lReconciled] bit
		, [lCanceled] bit
		, [mNotes] varchar(MAX)
		, [mBankId] varchar(MAX)

		  CONSTRAINT [Transactions_PK] PRIMARY KEY ([uTransactionsId])
		, FOREIGN KEY ([uAccountsId]) REFERENCES [Accounts] ([uAccountsId])
		, FOREIGN KEY ([uTransactionTypesId]) REFERENCES [TransactionTypes] ([uTransactionTypesId])
		, FOREIGN KEY ([uBillersId]) REFERENCES [Billers] ([uBillersId])
		, CONSTRAINT [Transactions_iTransactionNumber_unq] UNIQUE ([uAccountsId], [iTransactionNumber])
	)
;

GO