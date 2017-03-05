select * from registry;
-- Если будет подвязана отправка реестров, бухгалтерия то делать соответствующие проверки
-- !!!!! Убедиться что сейчас не происходит импорт реестров
-- TODO в импорте в случае ошибки возвращать в исходное состояние автоматически
delete from payment where registry_id in (select registry_id from registry where status=2); -- Из детализации удалится каскадно
update registry set status= 1 where status=2;

