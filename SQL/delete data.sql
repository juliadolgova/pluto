-- Удалить данные и сбросить счетчики
delete from detail;
delete from payment;
delete from registry;
ALTER TABLE payment AUTO_INCREMENT = 1;
ALTER TABLE detail AUTO_INCREMENT = 1;
ALTER TABLE registry AUTO_INCREMENT = 1;
INSERT INTO registry(`NAME`,`PROG`,`STATUS`) VALUES ('590',2,3);