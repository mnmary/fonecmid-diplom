#Область ПрограммныйИнтерфейс

// Работа с Телеграм

// Отправить уведомления в телеграмм.
Процедура ОтправитьУведомленияВТелеграмм() Экспорт
	
	Токен = Константы.BKM_ТокенУправленияТелеграмБотом.Получить();
	
	Если Не ЗначениеЗаполнено(Токен) Тогда
		
		ЖурналРегистрации.ДобавитьСообщениеДляЖурналаРегистрации("Отправка сообщения в телеграмм. Сообщение не отправлено.", УровеньЖурналаРегистрации.Ошибка,,, 
		"Токен для Телегамм не установлен.");
		Возврат;
		
	КонецЕсли;
	
	ИдентификаторЧата = Константы.BKM_ТелеграмИдентификаторГруппыОповещения.Получить();
	
	Если Не ЗначениеЗаполнено(ИдентификаторЧата) Тогда
		
		ЖурналРегистрации.ДобавитьСообщениеДляЖурналаРегистрации("Отправка сообщения в телеграмм. Сообщение не отправлено.", УровеньЖурналаРегистрации.Ошибка,,, 
		"Идентификатор чата для Телеграмм не установлен.");
		Возврат;
		
	КонецЕсли;
	
	Выборка = ПолучитьУведомленияДляОтправки();
		
	Пока Выборка.Следующий() Цикл
		
		Ответ = ОтправитьСообщениеВТелеграмм(Выборка.ТекстСообщения, Токен, ИдентификаторЧата);
		Если Ответ = Неопределено Тогда
			
			Продолжить;	
			
		КонецЕсли; 
		
		Если Ответ.КодСостояния = 200 Тогда
			
			УведомлениеОбъект = Выборка.Ссылка.ПолучитьОбъект();	
			УведомлениеОбъект.Удалить();
			
		Иначе
			
			ОписаниеОшибки = Ответ.ПолучитьТелоКакСтроку();	
			ЖурналРегистрации.ДобавитьСообщениеДляЖурналаРегистрации("Отправка сообщений в телеграмм. Сообщение не отправлено.", УровеньЖурналаРегистрации.Ошибка,,,ОписаниеОшибки);
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Отправить сообщение в телеграмм.
// 
// Параметры:
//  ТекстСообщения - Произвольный, Строка - Текст сообщения
//  Токен - Произвольный, Строка - Токен
//  ИдентификаторЧата - Произвольный, Строка - Идентификатор чата
// 
// Возвращаемое значение:
//  Неопределено, HTTPОтвет - Отправить сообщение в телеграмм
Функция ОтправитьСообщениеВТелеграмм(Знач ТекстСообщения, Знач Токен, Знач ИдентификаторЧата)
	
	Ответ = Неопределено;
	
	Попытка 
		
		Соединение = Новый HTTPСоединение("api.telegram.org",,,,,, ОбщегоНазначенияКлиентСервер.НовоеЗащищенноеСоединение());
		
		ДанныеСообщения = Новый Структура;
		ДанныеСообщения.Вставить("chat_id",ИдентификаторЧата);
		ДанныеСообщения.Вставить("text",ТекстСообщения);
		
		ЗаписьJSON = Новый ЗаписьJSON;
		ЗаписьJSON.УстановитьСтроку();
		ЗаписатьJSON(ЗаписьJSON,ДанныеСообщения);
		СообщениеДляОтправки = ЗаписьJSON.Закрыть();
		
		Заголовки = Новый Соответствие;
		Заголовки.Вставить("content-type", "application/json");
		
		АдресURL = СтрШаблон("/bot%1/sendMessage", Токен);
		HTTPЗапрос = Новый HTTPЗапрос(АдресURL, Заголовки);
		HTTPЗапрос.УстановитьТелоИзСтроки(СообщениеДляОтправки);
		Ответ = Соединение.ОтправитьДляОбработки(HTTPЗапрос);
		
	Исключение
		
		ЖурналРегистрации.ДобавитьСообщениеДляЖурналаРегистрации("Отправка сообщения в телеграмм. Непредвиденная ошибка.",УровеньЖурналаРегистрации.Ошибка,,,ОписаниеОшибки());		
		Возврат Неопределено;
		
	КонецПопытки;
	
		Возврат Ответ;
		
КонецФункции

// Получить уведомления для отправки.
// 
// Возвращаемое значение:
//  ВыборкаИзРезультатаЗапроса - Получить уведомления для отправки
Функция ПолучитьУведомленияДляОтправки()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	BKM_УведомленияТелеграмБоту.Ссылка КАК Ссылка,
	               |	BKM_УведомленияТелеграмБоту.ТекстСообщения КАК ТекстСообщения
	               |ИЗ
	               |	Справочник.BKM_УведомленияТелеграмБоту КАК BKM_УведомленияТелеграмБоту";

	
	Возврат Запрос.Выполнить().Выбрать();
	
КонецФункции


// BKM отправка сообщений в телеграм - метод для регламентного задания.
Процедура BKM_ОтправкаСообщенийВТелеграм() Экспорт
	ОтправитьУведомленияВТелеграмм();
КонецПроцедуры

#КонецОбласти