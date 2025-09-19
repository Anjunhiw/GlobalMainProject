-- --------------------------------------------------------
-- 호스트:                          127.0.0.1
-- 서버 버전:                        11.7.2-MariaDB - mariadb.org binary distribution
-- 서버 OS:                        Win64
-- HeidiSQL 버전:                  12.10.0.7000
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- globalmainproj_01 데이터베이스 구조 내보내기
CREATE DATABASE IF NOT EXISTS `globalmainproj_01` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci */;
USE `globalmainproj_01`;

-- 테이블 globalmainproj_01.assetplan 구조 내보내기
CREATE TABLE IF NOT EXISTS `assetplan` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `Date` date DEFAULT NULL COMMENT '예정일',
  `ProductId` int(11) DEFAULT NULL COMMENT '제품아이디',
  `Amount` int(11) DEFAULT NULL COMMENT '판매량',
  PRIMARY KEY (`pk`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='자금계획';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 globalmainproj_01.assets 구조 내보내기
CREATE TABLE IF NOT EXISTS `assets` (
  `TotalAssets` bigint(20) DEFAULT NULL COMMENT '총자금',
  `CurrenAssets` bigint(20) DEFAULT NULL COMMENT '유동자금',
  `TotalEarning` bigint(20) DEFAULT NULL,
  `TotalCost` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='자금';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 globalmainproj_01.bom 구조 내보내기
CREATE TABLE IF NOT EXISTS `bom` (
  `ProductId` int(11) NOT NULL COMMENT '제품Id',
  `MaterialId` int(11) NOT NULL COMMENT '원자재Id',
  `MaterialAmount` float DEFAULT NULL COMMENT '필요자재량',
  KEY `ProductId` (`ProductId`),
  KEY `MaterialId` (`MaterialId`),
  CONSTRAINT `MaterialId` FOREIGN KEY (`MaterialId`) REFERENCES `material` (`pk`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `ProductId` FOREIGN KEY (`ProductId`) REFERENCES `product` (`pk`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='자재명세서';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 globalmainproj_01.earncost 구조 내보내기
CREATE TABLE IF NOT EXISTS `earncost` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `EarningId` int(11) NOT NULL DEFAULT 0 COMMENT '판매수익',
  `CostId` int(11) NOT NULL DEFAULT 0 COMMENT '구매금액',
  PRIMARY KEY (`pk`),
  KEY `FK1` (`EarningId`),
  KEY `FK_earncost_purchase` (`CostId`),
  CONSTRAINT `FK1` FOREIGN KEY (`EarningId`) REFERENCES `transaction_details` (`pk`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `FK_earncost_purchase` FOREIGN KEY (`CostId`) REFERENCES `purchase` (`pk`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='비용/지출';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 globalmainproj_01.material 구조 내보내기
CREATE TABLE IF NOT EXISTS `material` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `Category` char(50) DEFAULT '원자재' COMMENT '카테고리',
  `Name` char(50) DEFAULT NULL COMMENT '원자재명',
  `Specification` char(50) DEFAULT NULL COMMENT '규격',
  `Unit` char(10) DEFAULT NULL COMMENT '단위',
  `Price` int(11) DEFAULT NULL COMMENT '가격',
  `Stock` float DEFAULT NULL COMMENT '입고량',
  `Amount` float DEFAULT NULL COMMENT '입고금액',
  PRIMARY KEY (`pk`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='원자재';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 globalmainproj_01.member 구조 내보내기
CREATE TABLE IF NOT EXISTS `member` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `ID` char(10) DEFAULT NULL COMMENT '아이디',
  `Password` char(100) DEFAULT NULL COMMENT '비밀번호',
  `Name` char(10) DEFAULT NULL COMMENT '이름',
  `Birth` date DEFAULT NULL COMMENT '생년월일',
  `Email` char(20) DEFAULT NULL COMMENT '이메일',
  `Dept` char(10) DEFAULT NULL COMMENT '부서',
  `Rank` char(50) DEFAULT NULL COMMENT '직급',
  `Years` int(11) DEFAULT NULL COMMENT '근속연수',
  `Salary` bigint(20) DEFAULT NULL COMMENT '급여',
  PRIMARY KEY (`pk`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='회원';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 globalmainproj_01.mps 구조 내보내기
CREATE TABLE IF NOT EXISTS `mps` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `ProductId` int(11) NOT NULL COMMENT '제품Id',
  `Period` date DEFAULT NULL COMMENT '기간(종료일)',
  `Volume` float DEFAULT NULL COMMENT '생산량',
  PRIMARY KEY (`pk`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='기준생산계획';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 globalmainproj_01.mrp 구조 내보내기
CREATE TABLE IF NOT EXISTS `mrp` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `Date` date DEFAULT NULL,
  `MaterialId` int(11) DEFAULT NULL,
  `ProductId` int(11) DEFAULT NULL,
  `Requirement` float DEFAULT NULL,
  `MRPStatus` char(50) DEFAULT NULL,
  PRIMARY KEY (`pk`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='MRP';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 globalmainproj_01.order 구조 내보내기
CREATE TABLE IF NOT EXISTS `order` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `Date` date DEFAULT NULL COMMENT '주문일자',
  `ProductId` int(11) NOT NULL DEFAULT 0 COMMENT '제품아이디',
  `ProductName` char(50) DEFAULT NULL COMMENT '제품명',
  `Amount` bigint(20) DEFAULT NULL COMMENT '수량',
  `Price` float DEFAULT NULL COMMENT '단가',
  `Total` float DEFAULT NULL COMMENT '총액',
  `OrderStatus` char(50) NOT NULL DEFAULT '진행중' COMMENT '주문상태',
  PRIMARY KEY (`pk`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='주문관리\r\n';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 globalmainproj_01.product 구조 내보내기
CREATE TABLE IF NOT EXISTS `product` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `Category` char(50) DEFAULT '제품' COMMENT '카테고리',
  `Name` char(50) DEFAULT NULL COMMENT '제품명',
  `Model` char(50) DEFAULT NULL COMMENT '모델명',
  `Specification` char(50) NOT NULL DEFAULT '0' COMMENT '규격',
  `Price` int(11) DEFAULT NULL COMMENT '단가',
  `Stock` float DEFAULT NULL COMMENT '재고량',
  `Amount` float DEFAULT NULL COMMENT '재고금액',
  PRIMARY KEY (`pk`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='제품';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 globalmainproj_01.purchase 구조 내보내기
CREATE TABLE IF NOT EXISTS `purchase` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `Date` date DEFAULT NULL,
  `Cost` bigint(20) NOT NULL COMMENT '구매금액',
  `MaterialId` int(11) NOT NULL COMMENT '원자재Id',
  `Purchase` float DEFAULT NULL COMMENT '구매량',
  PRIMARY KEY (`pk`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='원자재 구매';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 globalmainproj_01.qc 구조 내보내기
CREATE TABLE IF NOT EXISTS `qc` (
  `MpsId` int(11) NOT NULL COMMENT 'MPS ID',
  `IsPassed` tinyint(1) DEFAULT NULL COMMENT '합불여부',
  KEY `MpsId` (`MpsId`),
  CONSTRAINT `MpsId` FOREIGN KEY (`MpsId`) REFERENCES `mps` (`pk`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='QC';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 globalmainproj_01.transaction_details 구조 내보내기
CREATE TABLE IF NOT EXISTS `transaction_details` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `Earning` bigint(20) NOT NULL COMMENT '판매수익',
  `ProductId` int(11) NOT NULL COMMENT '제품Id',
  `Date` date DEFAULT NULL COMMENT '거래일',
  `Sales` float DEFAULT NULL COMMENT '판매량',
  PRIMARY KEY (`pk`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='거래명세서';

-- 내보낼 데이터가 선택되어 있지 않습니다.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
