

SET @registry_name = '%(registry_name)s'$$
SET @registry_id = (SELECT REGISTRY_ID FROM registry WHERE PROG = 1 AND NAME = @registry_name)$$

DROP TABLE IF EXISTS tmp_stream_%(registry_name)s$$
DROP TABLE IF EXISTS tmp_paynode_%(registry_name)s$$
DROP TABLE IF EXISTS tmp_organization_%(registry_name)s$$


CREATE TEMPORARY TABLE tmp_stream_%(registry_name)s (
  `EXTERNAL_TIME` DATETIME DEFAULT NULL,
  `BACKEND_TIME` DATETIME DEFAULT NULL,
  `SERVICE_NAME` VARCHAR(150) DEFAULT NULL,
  `SERVICE_CODE` INT(11) DEFAULT NULL,
  `ACCOUNT` VARCHAR(20) DEFAULT NULL,
  `FIO` VARCHAR(100) DEFAULT NULL,
  `ADDRESS` VARCHAR(150) DEFAULT NULL,
  `ORGANIZATION_NAME` VARCHAR(100) DEFAULT NULL,
  `PAYNODE_CODE` INT(11) DEFAULT NULL,
  `PAYNODE_ADDRESS` VARCHAR(150) DEFAULT NULL,
  `CASHIER` VARCHAR(80) DEFAULT NULL,
  `SUMM_NO_FEE` DECIMAL(12,2) DEFAULT NULL,
  `FEE` DECIMAL(12,2) DEFAULT NULL,
  `PAYNUMBER` INT(11) DEFAULT NULL,
  `STATUS` INT(11) DEFAULT NULL,
  `EXTERNAL_ID` VARCHAR(25) DEFAULT NULL,
  `COMMENT` VARCHAR(200) DEFAULT NULL 
) ENGINE=INNODB DEFAULT CHARSET=UTF8$$

LOAD DATA INFILE '%(path)s'
INTO TABLE tmp_stream_%(registry_name)s
CHARACTER SET CP1251 
FIELDS TERMINATED BY ';' 
LINES TERMINATED BY '\n'
(EXTERNAL_TIME,BACKEND_TIME,@service_name,SERVICE_CODE,ACCOUNT,FIO,ADDRESS,ORGANIZATION_NAME,PAYNODE_CODE,PAYNODE_ADDRESS,CASHIER,SUMM_NO_FEE,FEE,PAYNUMBER,STATUS,EXTERNAL_ID,COMMENT)
SET SERVICE_NAME = left(@service_name, 150)$$

UPDATE registry 
SET PAYMENTS_COUNT = (SELECT COUNT(*) FROM tmp_stream_%(registry_name)s)
WHERE REGISTRY_ID = @registry_id$$


-- --------- Актуализируем Организации ------------
INSERT INTO organization (NAME, NAME_STREAM)
SELECT DISTINCT ORGANIZATION_NAME, ORGANIZATION_NAME 
FROM tmp_stream_%(registry_name)s 
WHERE ORGANIZATION_NAME NOT IN (SELECT NAME_STREAM FROM organization where NAME_STREAM is not null)
ORDER BY ORGANIZATION_NAME$$

-- Создаем временную чтобы исключить вероятность задвоения платежей в случае неуникальности названий организаций 
CREATE TEMPORARY TABLE tmp_organization_%(registry_name)s AS 
SELECT MIN(ORGANIZATION_ID) AS ORGANIZATION_ID, NAME_STREAM
FROM organization
GROUP BY NAME_STREAM$$


-- --------- Актуализируем Услуги ------------
-- возможно потребуется обновлять названия. сделать аналогично с ППП
INSERT INTO service (ORGANIZATION_ID, CODE_STREAM, NAME_STREAM)
SELECT tmp_organization_%(registry_name)s.ORGANIZATION_ID, SERVICE_CODE, SERVICE_NAME
FROM tmp_stream_%(registry_name)s AS tmp
LEFT JOIN tmp_organization_%(registry_name)s ON tmp_organization_%(registry_name)s.NAME_STREAM = tmp.ORGANIZATION_NAME
WHERE SERVICE_CODE NOT IN (SELECT CODE_STREAM FROM service where CODE_STREAM is not null)
GROUP BY tmp_organization_%(registry_name)s.ORGANIZATION_ID , SERVICE_NAME, SERVICE_CODE 
ORDER BY tmp_organization_%(registry_name)s.ORGANIZATION_ID,tmp.SERVICE_CODE$$


-- --------- Актуализируем ППП ---------------------
CREATE TEMPORARY TABLE tmp_paynode_%(registry_name)s AS
SELECT DISTINCT PAYNODE_CODE, PAYNODE_ADDRESS
FROM tmp_stream_%(registry_name)s$$

INSERT INTO paynode (CODE_STREAM, ADDRESS, ADDRESS_STREAM)
SELECT DISTINCT PAYNODE_CODE, PAYNODE_ADDRESS, PAYNODE_ADDRESS 
FROM tmp_paynode_%(registry_name)s
WHERE PAYNODE_CODE NOT IN (SELECT CODE_STREAM FROM paynode where CODE_STREAM is not null)
ORDER BY PAYNODE_CODE$$

UPDATE paynode
INNER JOIN tmp_paynode_%(registry_name)s ON tmp_paynode_%(registry_name)s.PAYNODE_CODE = paynode.CODE_STREAM 
SET paynode.ADDRESS_STREAM = tmp_paynode_%(registry_name)s.PAYNODE_ADDRESS$$


-- --------- Грузим оплаты ---------------------
INSERT INTO payment
(`PAYNUMBER`,`PROG`,`ORDER_TYPE`,`STATUS`,`ACCOUNT`,`FIO`,`ADDRESS`,`ORGANIZATION_ID`,`EXTERNAL_ID`,`EXTERNAL_TIME`,
`BACKEND_TIME`,`SUMM`,`FEE`,`PAYNODE_ID`,`CASHIER`,`REGISTRY_ID`)
SELECT 
tmp.`PAYNUMBER`, 
1 AS PROG, 
CASE WHEN tmp.`SUMM_NO_FEE`>=0 THEN 0 ELSE 1 END AS ORDER_TYPE,
tmp.`STATUS`,
tmp.`ACCOUNT`,
tmp.`FIO`,
tmp.`ADDRESS`,
tmp_organization_%(registry_name)s.`ORGANIZATION_ID`, 
tmp.`EXTERNAL_ID`,
tmp.`EXTERNAL_TIME`,
tmp.`BACKEND_TIME`,
tmp.`SUMM_NO_FEE`+tmp.`FEE` AS SUMM,
tmp.`FEE`,
paynode.`PAYNODE_ID`, 
tmp.`CASHIER`,
@registry_id AS `REGISTRY_ID`
FROM tmp_stream_%(registry_name)s AS tmp
LEFT JOIN tmp_organization_%(registry_name)s ON tmp_organization_%(registry_name)s.NAME_STREAM=tmp.ORGANIZATION_NAME
LEFT JOIN paynode ON paynode.CODE_STREAM = tmp.PAYNODE_CODE$$


-- --------- Грузим услуги -------------------------
-- Если когда-нибудь код услуги станет не уникальным по стриму то добавить условие по организации: 
-- LEFT JOIN service ON [..] and service.organization_id = tmp.org_id(как-то так)
INSERT INTO detail
(`SERVICE_ID`,`PAYMENT_ID`,`SUMM_NF`)
SELECT service.SERVICE_ID, payment.PAYMENT_ID, tmp.SUMM_NO_FEE
FROM tmp_stream_%(registry_name)s AS tmp
LEFT JOIN payment ON payment.PAYNUMBER = tmp.PAYNUMBER 
LEFT JOIN service ON service.CODE_STREAM = tmp.SERVICE_CODE
WHERE payment.PROG = 1$$

-- --------- Устанавливаем флаг в "Загружено"--------
UPDATE registry SET status = 3 WHERE REGISTRY_ID = @registry_id$$