
#Область ОбработчикиКомандФормы  

&НаКлиенте
Асинх Процедура Заполнить(Команда)
	Если Объект.ДополнительныеНачисления.Количество() <> 0 Тогда
		
		Результат = Ждать ВопросАсинх("Табличная часть - ДополнительныеНачисления будет очищена. Продолжить?", 
		РежимДиалогаВопрос.ДаНет,,,"Вопрос.");	
		
		Если Результат = Неопределено Или Результат = КодВозвратаДиалога.Нет Тогда				
			Возврат;			
		КонецЕсли; 
		
	КонецЕсли;                
	
	Объект.ДополнительныеНачисления.Очистить();	
	ЗаполнитьНаСервере();
КонецПроцедуры

#КонецОбласти


#Область СлужебныеПроцедурыИФункции  

&НаСервере
Процедура ЗаполнитьНаСервере()    
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	BKM_ВыполненныеСотрудникомРаботыОстатки.Сотрудник КАК Сотрудник,
		|	BKM_ВыполненныеСотрудникомРаботыОстатки.ЧасовКОплатеОстаток КАК НачисленоЧасов,
		|	BKM_ВыполненныеСотрудникомРаботыОстатки.СуммаКОплатеОстаток КАК СуммаНачисления
		|ИЗ
		|	РегистрНакопления.BKM_ВыполненныеСотрудникомРаботы.Остатки(&ДатаДокумента, ) КАК BKM_ВыполненныеСотрудникомРаботыОстатки
		|ГДЕ
		|	BKM_ВыполненныеСотрудникомРаботыОстатки.СуммаКОплатеОстаток > 0";
	
	
	Запрос.УстановитьПараметр("ДатаДокумента", Объект.Дата);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		ТекстСообщения = "Нет данных для формирования списка.";
		ОбщегоНазначения.СообщитьПользователю(ТекстСообщения);
		Возврат;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
		
	Пока Выборка.Следующий() Цикл
		
		ЗаполнитьЗначенияСвойств(Объект.ДополнительныеНачисления.Добавить(), Выборка);
		
	КонецЦикла; 
	
КонецПроцедуры

#КонецОбласти