CREATE TABLE `Purchase` (
	`pk`	INT	NOT NULL,
	`Cost`	BIGINT	NULL,
	`MaterialId`	INT	NOT NULL,
	`Purchase`	FLOAT	NULL
);

CREATE TABLE `BOM` (
	`ProductId`	INT	NOT NULL,
	`MaterialId`	INT	NOT NULL,
	`MaterialAmount`	FLOAT	NULL
);

CREATE TABLE `EarnCost` (
	`pk`	VARCHAR(255)	NOT NULL,
	`Earning`	BIGINT	NULL,
	`Cost`	BIGINT	NULL
);

CREATE TABLE `Materials` (
	`pk`	INT	NOT NULL,
	`원자재명`	CHAR	NULL,
	`가격`	INT	NULL,
	`입고량`	FLOAT	NULL
);

CREATE TABLE `Assets` (
	`TotalAssets`	BIGINT	NULL,
	`CurrenAssets`	BIGINT	NULL
);

CREATE TABLE `Transaction details` (
	`pk`	INT	NOT NULL,
	`Earning`	BIGINT	NULL,
	`ProductId`	INT	NOT NULL,
	`Date`	DATE	NULL,
	`Sales`	FLOAT	NULL
);

CREATE TABLE `Order` (
	`MpsId`	INT	NOT NULL
);

CREATE TABLE `MPS` (
	`pk`	INT	NOT NULL,
	`ProductId`	INT	NOT NULL,
	`Period`	DATE	NULL,
	`Volume`	FLOAT	NULL,
	`IsPassed`	TINYINT	NULL
);

CREATE TABLE `QC` (
	`ProductId`	INT	NOT NULL,
	`IsPassed`	TINYINT	NULL
);

CREATE TABLE `Member` (
	`pk`	INT	NOT NULL,
	`ID`	CHAR	NULL,
	`Password`	CHAR	NULL,
	`Name`	CHAR	NULL,
	`Email`	CHAR	NULL,
	`Dept`	CHAR	NULL,
	`Years`	INT	NULL,
	`Salary`	BIGINT	NULL
);

CREATE TABLE `Product` (
	`pk`	INT	NOT NULL,
	`제품명`	CHAR	NULL,
	`재고량`	FLOAT	NULL,
	`단가`	INT	NULL
);

ALTER TABLE `Purchase` ADD CONSTRAINT `PK_PURCHASE` PRIMARY KEY (
	`pk`,
	`Cost`
);

ALTER TABLE `EarnCost` ADD CONSTRAINT `PK_EARNCOST` PRIMARY KEY (
	`pk`
);

ALTER TABLE `Materials` ADD CONSTRAINT `PK_MATERIALS` PRIMARY KEY (
	`pk`
);

ALTER TABLE `Transaction details` ADD CONSTRAINT `PK_TRANSACTION DETAILS` PRIMARY KEY (
	`pk`,
	`Earning`
);

ALTER TABLE `MPS` ADD CONSTRAINT `PK_MPS` PRIMARY KEY (
	`pk`
);

ALTER TABLE `Member` ADD CONSTRAINT `PK_MEMBER` PRIMARY KEY (
	`pk`
);

ALTER TABLE `Product` ADD CONSTRAINT `PK_PRODUCT` PRIMARY KEY (
	`pk`
);

