CREATE OR REPLACE PACKAGE UBRR_XXI5.ubrr_sap_cd
IS
/******************************* HISTORY UBRR *************************************** * *\
Дата        Автор            ID        Описание
----------  ---------------  --------- ---------------------------------------
08.09.2015   Лобик Д.А.      [15-997]  #24595 SAP R/3: Инспекция кода E7P, EEP
                                       Send_SMS,AddPart, Clear_SchedPayPrcForAdvance, Add_SchedPayPrc
                                       CreateNewMaturity,Add_SchedLim,Change_AGRSIGNDATE,Change_CrInfo
                                       Change_BKI_REQUEST, Change_LIMIT_EXPIRE_DATE,Change_SMS_AGR
                                       CreateNewZalog, CHANGE_CURATORID
----------  ---------------  --------- ---------------------------------------
10.12.2015  Рохин Е.А.       [#26420]  Добавлена процедура передачи значения в таблицу cdh
----------  ---------------  --------- ---------------------------------------
28.05.2016  Некрасов А.В.    [#30540]  Добавлена функция для установки контекста
----------  ---------------  --------- ---------------------------------------
30.05.2016  ubrr korolkov    [16-1808] 16-1808.2.3.2.4.5 Generate_Annuitet
----------  ---------------  --------- ---------------------------------------
19.07.2016  ubrr korolkov    [16-1808] 16-1808.2.3.2.4.5 Generate_Annuitet, добавлен p_tp_correct
----------  ---------------  --------- ---------------------------------------
07.2017     Бунтова О.Г.         [15-1115.1] Автоматизация скоринг-гарантий, процедура GetBPLimSCG
----------  ---------------  --------- ---------------------------------------
08.10.2018  Бунтова О.Г. #56138 [18-494] Расчет кода 8769
----------  ---------------  --------- ---------------------------------------
08.07.2020  Пылаев Е.А.      [19-59018] РАЗРАБОТКА АБС : Разделение отправки СМС- E-Mail-уведомлений УБРиР и ВУЗ
22.03.2021  Зеленко С.А.     DKBPA-105 ЭТАП 4.1 (репликация АБС): Формат распоряжения. ЗИУ для кредитов по короткой схеме
\******************************* HISTORY UBRR *****************************************/

  function SetSAPCDContext(cpIDSMR in VARCHAR2 default null) return varchar2;

  -- Abramov A.V. Edition two
  procedure CreateAgr(
    cpNumDog         in     varchar2   -- Символьный номер договора
   ,dpSignDate       in     varchar2   -- Дата подписания договора
   ,dpStartDate      in     varchar2   -- Дата договора
   ,dpEndDate        in     varchar2   -- Дата окончания договора
   --,dpSignDate       in     date       -- Дата подписания договора
   --,dpStartDate      in     date       -- Дата договора
   --,dpEndDate        in     date       -- Дата окончания договора
   ,ipGroup          in     number     -- Номер группы
   ,ipClientNum      in     number     -- Номер клиетна
   ,cClientName      in     varchar2   -- Наименование клиетна
   ,сpCur            in     varchar2   -- Валюта договора
   ,mpSum            in     number     -- Сумма договора
   ,ppIntRate        in     number     -- Процентная ставка
   ,ppPenyRate       in     number     -- Пени на средства
   ,ppPenyType       in     number     -- Тип пеней на средства (дневные 0, годовые 1)
   ,ppPenyRate2      in     number     -- Пени на проценты
   ,ppPenyType2      in     number     -- Тип пеней на проценты (дневные 0, годовые 1)
   ,ipPrtf           in     varchar2   -- Портфель
   ,cBranch          in     varchar2   -- Отделение
   ---->>>>>>Lobik D.A. ubrr 27.12.2005
   ,iLineType        in     number
   ,dpFirstTransDate in     varchar2   -- Дата первой выдачи
   --,dFirstTransDate  in     date       -- Дата первой выдачи
   ,n_PERCTERMID     in     number     --id Срока оплаты %%
   ,mFirstTransSum   in     number     -- Суммы первой выдачи
   ,iloan_aim        in     number     -- Код цли кредита по табл. CAU
   ,iTurnType        in     number     -- Тип оборота (3 - X-дневный, 5 - в рабочих днях, 0 - в календарных днях)
   ,iTurnover        in     number     -- оборачиваемость кредита
   ----<<<<<---Lobik D.A. ubrr 27.12.2005
   ---->>>>>>Lobik D.A. ubrr 14.03.2006
   ,сAcc             in     varchar2   -- текущий счет
   ,сBIC             in     varchar2   -- БИК банка
     ----->>>>>>>>>>>>>>Lobik D.A. ubrr 04.07.2006
   ,is_IN_BKI     in       varchar2   -- Согласие на ЗАПРОС в БКИ (Y-ДА N-НЕТ)  UBRR Portnyagin D.Y. 19.09.2011
   ,dp_IN_BKI     in       varchar2   -- Дата Согласия на ЗАПРОС в БКИ UBRR Portnyagin D.Y. 19.09.2011
   ,iCR_OUT          in     number     --согласие сообщать в БКИ
   ,dpCR_OUT         in     varchar2   --дата согласия
   --,dCR_OUT          in     date       --дата согласия
   ,cCR_ID           in     varchar2   --код субъекта кредитной истории
     -----<<<<<<<<<<<<Lobik D.A. ubrr 04.07.2006
   ----<<<<<<<Lobik D.A. ubrr 14.03.2006
   -- >>> Рохин Е.А. 01.11.2011 (11-859)
   ,cpSMS_AGR     in       varchar2   -- Согласие на SMS-информирование
   ,cpSMS_INF     in       varchar2   -- Телефон для SMS-информирования
   ,cpEMAIL_AGR   in       varchar2   -- Согласие на E-Mail-информирование
   ,cpEMAIL_INF   in       varchar2   -- Адрес эл.почты для E-Mail-информирования
   -- <<< Рохин Е.А. 01.11.2011 (11-859)
   -- >>> Рохин Е.А. 25.09.2014 #16715 [14-528.4]
   ,cpUBRRMAIL    in       varchar2   -- Адрес эл.почты на сервере Банка для извещений
   -- <<< Рохин Е.А. 25.09.2014 #16715 [14-528.4]
   ,iXOverDays       in     number     --дни X-овер--->>><<<Лобик-Некрасов 24.01.2007
   ,noutAgrid        in out number    -- Числовой номер договора
   ,cpPunktBASp      in     varchar2   -- (ubrr) Samokaev R.V. --- 13.02.2008 --
   ,cpGrpObsp        in     varchar2   -- (ubrr) Samokaev R.V. --- 13.02.2008 --
   ,cnIsTransh       in     number     -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   ,cpABS            in     varchar2   -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   ,p_ret_day        IN     NUMBER     -- День платежа 01-31 Портнягин Д.Ю. 19.12.2012
   ,cpRepayment      in     varchar2 default null  -- Порядок гашения задолженности 14-528 Рохин Е.А. 30.06.2014
   ,p_PERCCODE8769   in     NUMBER     -- Процент к коду 8769 - 08.10.2018 Бунтова О.Г. #56138 [18-494] Расчет кода 8769
   ,cpStatus         out    varchar2   -- Статус
   ,cpErrorMsg       out    varchar2   -- Сообщение об ошибке
                                   );

  procedure AddPart(
    npAgrid      in       number   -- Числовой номер договора
   ,dpEndDate    in       varchar2 -- Дата возврата
   --,dpEndDate    in       date     -- Дата возврата
   ,ipPart       in       number   -- номер части
   ,mpSum        in       number   -- Сумма части
   ,cpABS        in       varchar2 -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
   --,cpErrorMsg   in out   varchar2 -- Сообщение об ошибке
   ,cpErrorMsg  out       varchar2 -- Сообщение об ошибке
   --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                                  );

  procedure CreateNewZalog(
    npAgrid      in       number   -- Числовой номер договора
   ,dpDate       in       varchar2 -- Дата
   ,DpDsnDate    in       varchar2 -- Дата Решения
   ,iwarrantor   IN       varchar2 --
   ,ipType       in       number   -- Тип обеспечения из таблицы czv
   ,ipSubType    in       number   -- Подтип обеспечения из таблицы czw
   ,ipQuality    in       varchar2 --number   -- Категория качества обеспечения (пустая, 1, 2)
   ,сpCur        in       varchar2 -- Валюта
   ,mpSum        in       number   -- Сумма части
   ,mpQSum       in       number   -- Сумма части минус издержки
   ,mpMrktSum    in       number   -- Рыночная стоимость
   ,cNAME        in       varchar2 --------warrantor attributes
   ,cNAMEFULL    in       varchar2
   ,cINN         in       varchar2
   ,cKPP         in       varchar2
   ,cOKVED       in       varchar2
   ,cOKPO        in       varchar2
   ,cOGRN        in       varchar2
   ,cADDR        in       varchar2
   ,cADDR2       in       varchar2
   ,cPERSON      in       varchar2
   ,cPASPTYPE    in       varchar2
   ,cPASPNUM     in       varchar2
   ,cPASPSER     in       varchar2
   ,cPASPPLACE   in       varchar2
   ,dPASPDATE    in       varchar2
   ,cpComment    in       varchar2 -- Примечание к обеспечению
   ,cpPersname   in       varchar2 --
--> Зуев А.А. документ по обеспечению
   ,cpAgrNum     in       varchar2
   ,dpAgrDate    in       varchar2
   ,cpAgrAdrr    in       varchar2
--< Зуев А.А. документ по обеспечению
   ,cpABS        in       varchar2 -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
   --,cpErrorMsg   in out   varchar2 -- Сообщение об ошибке
   ,cpErrorMsg  out       varchar2 -- Сообщение об ошибке
   --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                                  );
  ---->>>>>>Lobik D.A. ubrr 28.12.2005
  procedure CreateNewMaturity(
    npAgrid      in       number   -- Числовой номер договора
   ,mpSum        in       number   -- Сумма созврата
   ,dpDate       in       varchar2 -- Дата возврата
   -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
   --,cpErrorMsg   in out   varchar2 -- Сообщение об ошибке
   ,cpErrorMsg  out       varchar2 -- Сообщение об ошибке
   --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                                  );
  function sap_2_char(ss in varchar2,ii in number)return varchar2;
  ----<<<<<Lobik D.A. ubrr 28.12.2005

  PROCEDURE CreatePart(
   npAgrid          in       number   -- номер договора
  ,dpDelivery       in       varchar2 -- Дата выдачи
  ,ppIntRate        in       number   -- Процентная ставка
  ,npSumPart_30d    in       number   -- Сумма части (до 30 дней)
  ,npSumPart_90d    in       number   -- Сумма части (от 31 до 90 дней)
  ,npSumPart_180d   in       number   -- Сумма части (от 91 до 180 дней)
  ,npSumPart_1y     in       number   -- Сумма части (от 181 дня до 1 года)
  ,npSumPart_3y     in       number   -- Сумма части (от 1 года до 3 лет)
  ,npSumPart_ovr3y  in       number   -- Сумма части (свыше 3 лет)
  ,cpABS            in       varchar2 -- (ubrr) Samokaev R.V. --- 22.12.2007 --
  ,npStrNumPart     out      number   -- Номер начальной части
  ,npFinNumPart     out      number   -- Номер последней части
  ,cpErrorMsg       out      varchar2 -- Сообщение об ошибке
                       );

  procedure Add_SchedPayPrc(
    npAgrid      in       number   -- Числовой номер договора
   ,dpDateClc    in       varchar2 -- Дата начисления %
   ,dpDatePay    in       varchar2 -- Дата уплаты %
   -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
   --,cpErrorMsg   in out   varchar2 -- Сообщение об ошибке
   ,cpErrorMsg  out       varchar2 -- Сообщение об ошибке
   --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                       );

  PROCEDURE calc_interval(npAgrid      in     number
                         ,dpFirstNach  in     date
                         ,dpFirstPay   in     date
                         ,spErrMessage in out varchar2);


  procedure Change_CuratorID (npAgrid      in       number,     -- Числовой номер договора)
                              npCuratorID  in       number,     -- ID Куратора
                              -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                              --cpErrorMsg   in out   varchar2 -- Сообщение об ошибке
                              cpErrorMsg  out       varchar2 -- Сообщение об ошибке
                              --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                              );

  PROCEDURE Change_CrInfo (ipAgrId in       number,
                           ipCrOut in       number,
                           dpCrOut in       varchar2,
                           --dpCrOut in date,
                           cpBKIId in       varchar2,
                           cpAbs   in       varchar2,
                           -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                           --,cpErrMsg   in out   varchar2 -- Сообщение об ошибке
                           cpErrMsg  out       varchar2 -- Сообщение об ошибке
                           --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                           );

  --->>>ubrr Кожевников Е.А. 2010/03/23 10-301 (Рохин Е.А.)
  ----------------------------------------------------------------------------------------------
  -- Функция определения техн. номера договора ЗА дату (учитывает пролонгации и возвращает призак корректности определения)
  -- c_IsCorrect = NULL , если техн. номер определен однозначно
  -- c_IsCorrect = 'X'  , если все пролонгации и родительский договор закрыты

   PROCEDURE Get_AgrID (i_agr       in  NUMBER
                       ,onDate      in  DATE
                       ,i_is_line   in  NUMBER
                       ,n_agrnum    OUT xxi.cda.ncdaagrid%TYPE
                       ,c_IsCorrect OUT char);
  ---<<<ubrr Кожевников Е.А. 2010/03/23 10-301 (Рохин Е.А.)

  --->>>ubrr Некрасов А.В. 2010/12/06 10-876
  /* При выдаче первого транша с условием уплаты % авансом
     нужно расчистить график начисления/уплаты % начиная с даты подписания договора
     по дату начисления %, которая <= периода уплаты % авансом
  */
   procedure Clear_SchedPayPrcForAdvance(npAgrid                 in     number
                                        ,dSAPDayOfPay            in     varchar2
                                        ,dSAPDayOfPrc            in     varchar2
                                         --Последний день месяца первой уплаты %
                                        -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                                        --,cpErrorMsg   in out   varchar2 -- Сообщение об ошибке
                                        ,cpErrorMsg  out       varchar2 -- Сообщение об ошибке
                                        --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                                        );
  ---<<<ubrr Некрасов А.В. 2010/12/06 10-876

  --->>>ubrr Некрасов А.В. 2011/01/24 11-206.2
  /* Создание записи в графике изменения лимита
     (если дата 00000000 - удаляются все записи в графике,
      если дата разумная - добавляется новая запись)
  */
    procedure Add_SchedLim(
       npAgrid      in       number   -- Числовой номер договора
      ,dpDateLim    in       varchar2 -- Дата записи графика изменения лимита
      ,npAmountLim  in       number   -- Величина лимита с даты
      -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
      --,cpErrorMsg   in out   varchar2 -- Сообщение об ошибке
      ,cpErrorMsg  out       varchar2 -- Сообщение об ошибке
      --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                       );
  ---<<<ubrr Некрасов А.В. 2011/01/24 11-206.2

-- признак согласия заемщика на запрос в БКИ
 PROCEDURE Change_BKI_REQUEST ( ipAgrId   in number,
                                is_IN_BKI in varchar2,
                                dpCrIn    in varchar2,
                                cpABS     in varchar2,
                                -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                                --cpErrMsg   in out   varchar2 -- Сообщение об ошибке
                                cpErrMsg  out       varchar2 -- Сообщение об ошибке
                                --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
       );
--    Процедура отправки SMS
 PROCEDURE Send_SMS
                (
                 cpSMS_Phone IN     varchar2                 --Номер телефона получателя (например,79226093222)
                ,cpSMS_Body  IN     varchar2                 --Текст сообщения до 1000 символов
                -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                --,cpErrorMsg  IN OUT varchar2                 -- Сообщение об ошибке
                --,cpSMS_Time  IN OUT varchar2                 -- Время создания сообщения
                ,cpErrorMsg OUT varchar2                 -- Сообщение об ошибке
                ,cpSMS_Time OUT varchar2                 -- Время создания сообщения
                --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                -->> 08.07.2020 Пылаев Е.А [19-59018] Разделение отправки СМС- E-Mail-уведомлений УБРиР и ВУЗ
                ,npVuz       IN     number default 0
                --<< 08.07.2020 Пылаев Е.А [19-59018] Разделение отправки СМС- E-Mail-уведомлений УБРиР и ВУЗ
                );
-- Отправка почты через внешний маршрутизатор
 PROCEDURE SEND_MAIL
     (
       Adres        IN      VARCHAR2  -- Адрес получателя сообщения 50
      ,Subject      IN      VARCHAR2  -- Тема сообщения 50
      ,Message      IN      VARCHAR2  -- Сообщение  2000
      ,cpErrorMsg   IN OUT  varchar2  -- Сообщение об ошибке
      ,cpEMAIL_Time IN OUT  varchar2  -- Время создания сообщения
      -->> 08.07.2020 Пылаев Е.А [19-59018] Разделение отправки СМС- E-Mail-уведомлений УБРиР и ВУЗ
      ,npVuz       IN     number default 0
      --<< 08.07.2020 Пылаев Е.А [19-59018] Разделение отправки СМС- E-Mail-уведомлений УБРиР и ВУЗ
      );
-- признаки согласия на информирование, телефон, e-mail
 PROCEDURE Change_SMS_Agr (ipAgrId     in      number,
                           dpSMS_AGR   in      varchar2,
                           cpSMS_AGR   in      varchar2,
                           cpSMS_INF   in      varchar2,
                           cpEMAIL_AGR in      varchar2,
                           cpEMAIL_INF in      varchar2,
                           -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                           --cpErrMsg   in out   varchar2 -- Сообщение об ошибке
                           cpErrMsg  out       varchar2 -- Сообщение об ошибке
                           --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                           );
  --->>>ubrr Некрасов А.В. 2011/11/15 11-484
  /* Добавление атрибута "Ответственное подразделение ДР" для Клиента  */
   procedure Add_Atr_Cus_From_Sap(
       npCus        in       number   -- Номер клиента
      ,npIDAtr      in       number   -- ID атрибута
      ,сpAtrVal     in       varchar2 -- Значение атрибута
      ,dpAtrDate    in       varchar2 -- Дата начала действия атрибута
      ,cpResult     out      varchar2 -- Сообщение об ошибке
                                  );
  /* Добавление атрибута "Методика ДР" для кр. договора  */
   procedure Add_Atr_Gr_From_Sap(
       npAgr        in       number   -- Номер кр. договора
      ,npIDAtr      in       number   -- ID атрибута
      ,сpAtrVal     in       varchar2 -- Значение атрибута
      ,cpResult     out      varchar2 -- Сообщение об ошибке
                                  );
  ---<<<ubrr Некрасов А.В. 2011/11/15 11-484
  --->>>ubrr Некрасов А.В. 2013/03/06 12-965
 /* Дата фактического подписания договора */
 PROCEDURE Change_AGRSIGNDATE ( ipAgrId   in number,
                                dpSignDate    in varchar2,
                                cpABS     in varchar2,
                                -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                                --cpErrMsg   in out   varchar2 -- Сообщение об ошибке
                                cpErrMsg  out       varchar2 -- Сообщение об ошибке
                                --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
       );
  ---<<<ubrr Некрасов А.В. 2013/03/06 12-965

--->>>ubrr Рохин Е.А. 2013/05/07 12-1166
-- Дата выбора лимита
 PROCEDURE Change_LIMIT_EXPIRE_DATE ( ipAgrId           in      number,
                                      dpConditionDate   in      varchar2,
                                      dpLimitExpireDate in      varchar2,
                                      cpABS             in      varchar2,
                                      -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                                      --cpErrMsg   in out   varchar2 -- Сообщение об ошибке
                                      cpErrMsg  out       varchar2 -- Сообщение об ошибке
                                      --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
       );
---<<<ubrr Рохин Е.А. 2013/05/07 12-1166

-- >>> Рохин Е.А. 25.09.2014 #16715 [14-528.4]
-- Логин и пароль E-mail на сервере Банка для извещений о задолженности
 PROCEDURE Get_UBRR_Email_Address   ( ipCusNum          in      number,
                                      cpSAPLogin        in      varchar2,
                                      cpEmailAddress    in out  varchar2,
                                      cpEmailPassword   in out  varchar2,
                                      cpErrMsg          in out  varchar2
       );
-- <<< Рохин Е.А. 25.09.2014 #16715 [14-528.4]

-- >>> Рохин Е.А. 26.05.2015 #22087 [15-199]
-- Указание ПСК в кредитном договоре
 PROCEDURE Change_PSK ( ipAgrId      in      number,
                        dpDate       in      varchar2,
                        npPSK        in      number,
                        cpInsertOnly in      varchar2,
                        cpErrMsg     in out  varchar2
       );

 FUNCTION Calc_PSK( ipAgrId      in      number ) return number;
-- <<< Рохин Е.А. 26.05.2015 #22087 [15-199]
-->> Рохин Е.А. 10.12.2015 #26420 [15-692.1
 PROCEDURE UpdateCDH (ipAgrid  in  number,
                      ipPart   in  number,
                      cpTerm   in  varchar2,
                      cpDate   in  varchar2,
                      cpParam  in  varchar2,
                      cpValue  in  varchar2,
                      cpErrMsg out varchar2
                     );
--<< Рохин Е.А. 10.12.2015 #26420 [15-692.1

-->> 30.05.2016 ubrr korolkov 16-1808.2.3.2.4.5
procedure Generate_Annuitet(p_cMsg          out varchar2,
                            p_id            in  varchar2,   -- Идентификатор расчёта
                            p_StartDate     in  varchar2,   -- Дата начала выплат
                            p_EndDate       in  varchar2,       -- Дата окончания выплат (договора)
                            p_StartSum      in  number,     -- Сумма кредита
                            p_Prc           in  number,     -- Процентная ставка
                            p_sum_repay     in  number,     -- Сумма аннуитета
                            p_dt            in  varchar2,   -- Дата первого возврата
                            p_interv        in  number default 0, -- период
                                                                  --  0 - мес
                                                                  --  1 - квартал
                                                                  --  2 - полгода
                                                                  --  3 - год
                            p_fl            in  number default 1, -- тип определения сдвига
                                                                  --  0 - по дню месяца даты dFirstPay (для интервалов > мес)
                                                                  --  1 - по последнему дню интервала
                                                                  --  2 - по сдвигу задаваемой даты dFirstPay от начала
                                                                  --  3 - через указанное количество рабочих дней от начала интервала
                            p_tp_correct    in  NUMBER default 1, -- поведение при учете выходных дней
                                                                  -- 1 сдвигать интервал начисления
                            p_only_working_days in number default null, -- исключать выходные (0 - нет, 1 - исключать)
                            p_AB            in  number default null,  --  0 - с возвратом позже
                                                                      -- -1 - с возвратом ранее
                            p_dt2           in  number default null);

procedure CreatePrcSchedule(p_ErrMsg    out varchar2,
                            p_AgrId      in  number);
--<< 30.05.2016 ubrr korolkov 16-1808.2.3.2.4.5
-->> Бунтова 07.2017 #44404: [15-1115.1] Автоматизация скоринг-гарантий
PROCEDURE GetBPLimSCG ( p_npCus     in      number,
                        p_dpZc      in      varchar2,
                        p_cpDemp    in      number,
                        p_SumLimit  out     number
                     );
--<< Бунтова 07.2017 #44404: [15-1115.1] Автоматизация скоринг-гарантий

-->>22.03.2021  Зеленко С.А.     DKBPA-105 ЭТАП 4.1 (репликация АБС): Формат распоряжения. ЗИУ для кредитов по короткой схеме
-------------------------------------------------------------------------------
-- Процедура генерации графика начислений
-------------------------------------------------------------------------------
PROCEDURE ZIU_Calc_Interval(p_Agrid           in     number,
                            p_StartDate       in     date,
                            p_FinishDate      in     date,
                            p_PerctermID      in     number,
                            p_ErrMessage      in out varchar2
                            );

-------------------------------------------------------------------------------
-- Процедура добавления данных в таблицу для изменения графика гашения
-------------------------------------------------------------------------------
PROCEDURE ZIU_Repayment_Schedule( p_AgrId            in number,      -- Код кредитного договора
                                  p_ChangeDate       in varchar2,    -- Дата внесения изменеия (дата с)
                                  p_PayAmount        in number,      -- Сумма
                                  p_PayDate          in varchar2,    -- Дата
                                  p_Status           out varchar2,   -- Статус
                                  p_ErrorMsg         out varchar2    -- Сообщение об ошибке
                                );

-------------------------------------------------------------------------------
-- Процедура добавления данных в таблицу для изменения графика изменения лимита
-------------------------------------------------------------------------------
PROCEDURE ZIU_Limit_Change_Schedule( p_AgrId            in number,      -- Код кредитного договора
                                     p_ChangeDate       in varchar2,    -- Дата внесения изменеия (дата с)
                                     p_LimAmount        in number,      -- Сумма
                                     p_LimDate          in varchar2,    -- Дата
                                     p_Status           out varchar2,   -- Статус
                                     p_ErrorMsg         out varchar2    -- Сообщение об ошибке
                                   );

-------------------------------------------------------------------------------
-- Процедура добавления данных в таблицу для изменеия обеспечания
-------------------------------------------------------------------------------
PROCEDURE ZIU_Change_Zalog( p_AgrId            in number,      -- Код кредитного договора
                            p_ChangeDate       in varchar2,    -- Дата внесения изменеия (дата с)
                            p_Atribut          in varchar2,    -- Номер документа залога
                            p_Amount           in number,      -- Сумма
                            p_Status           out varchar2,   -- Статус
                            p_ErrorMsg         out varchar2    -- Сообщение об ошибке
                          );

-------------------------------------------------------------------------------
-- Процедура урегулирование стоимости залога
-------------------------------------------------------------------------------
PROCEDURE ZIU_Settlement_Zalog( p_AgrId            in number,      -- Код кредитного договора
                                p_ABS              in varchar2,    -- Филиал
                                p_ChangeDate       in varchar2,    -- Дата внесения изменеия (дата с)
                                p_Status           out varchar2,   -- Статус
                                p_ErrorMsg         out varchar2    -- Сообщение об ошибке
                               );

-------------------------------------------------------------------------------
-- Процедура изменения КД. ЗИУ для кредитов по короткой схеме (основная)
-------------------------------------------------------------------------------
PROCEDURE ZIU_Change_Agr( p_AgrId            in number,      -- Код кредитного договора
                          p_ABS              in varchar2,    -- Филиал
                          p_ChangeDate       in varchar2,    -- Дата внесения изменеия (дата с)
                          p_UpdRate          in varchar2,    -- Признак изменения (Процентная ставка)
                          p_Rate             in number,      -- Процентная ставка
                          p_UpdPenyRate      in varchar2,    -- Признак изменения (Пени на ОД)
                          p_PenyRate         in number,      -- Пени на ОД
                          p_UpdPenyType      in varchar2,    -- Признак изменения (Тип пеней на ОД)
                          p_PenyType         in number,      -- Тип пеней на ОД (дневные 0, годовые 1)
                          p_UpdPenyRate2     in varchar2,    -- Признак изменения (Пени на проценты)
                          p_PenyRate2        in number,      -- Пени на проценты
                          p_UpdPeny2Type     in varchar2,    -- Признак изменения (Тип пеней на процент)
                          p_PenyType2        in number,      -- Тип пеней на проценты (дневные 0, годовые 1)
                          p_UpdAmount2       in varchar2,    -- Признак изменения (Сумма заявки)
                          p_Amount2          in number,      -- Сумма заявки
                          p_CURR2            in varchar2,    -- Валюты заявки (Для проверки с текущей валютой кредитного договора)
                          p_UpdEndDate       in varchar2,    -- Признак изменения (Дата окончаиня договора)
                          p_EndDate_Old      in varchar2,    -- Дата окончания договора (старая дата)
                          p_EndDate_New      in varchar2,    -- Дата окончания договора (новая дата)
                          p_PerctermID       in number,      -- id Срока оплаты %%
                          p_UpdBicAcc        in varchar2,    -- Признак изменения (реквизитов)
                          p_caccacc          in varchar2,    -- Текущий счет
                          p_BIC              in varchar2,    -- БИК банка
                          p_UpdRepaySch      in varchar2,    -- Признак изменения (График гашения)
                          p_UpdLimitSch      in varchar2,    -- Признак изменения (График изменения лимита)
                          p_CrdType2         in number,      -- Тип КД
                          p_UpdZalog         in varchar2,    -- Признак изменения (Изменение стоимости обесепчения/ Прекращение обеспечения сумма 0 )
                          p_Status           out varchar2,   -- Статус
                          p_ErrorMsg         out varchar2    -- Сообщение об ошибке
                         );
--<<22.03.2021  Зеленко С.А.     DKBPA-105 ЭТАП 4.1 (репликация АБС): Формат распоряжения. ЗИУ для кредитов по короткой схеме

END;
/
CREATE OR REPLACE PACKAGE BODY UBRR_XXI5.ubrr_sap_cd
IS
/******************************* HISTORY UBRR *****************************************\
Дата        Автор            ID        Описание
----------  ---------------  --------- ---------------------------------------
17.05.2012  Некрасов А.В.    [XXXXXX]  В процедуре создания кредита из SAP WF
                                       закомментирована НЕ передача в кредит кода ПОС
                                       (часть Пункта плана 12-654)
                                       "выдачи скоринг-кредитов Бизнес-хит физ.лицам (по <Критичным> доработкам в АБС)"
----------  ---------------  --------- ---------------------------------------
06.02.2012  Рохин Е.А.       [XXXXXX]  Для передачи рыночной стоимости залога внесены
                                       изменения в процедуру
                                            CreateNewZalog
                                       (Пункт плана 12-345)
                                       "Доработка отчета по обеспечению (в рамках SAP R3-WF)"
----------  ---------------  --------- ---------------------------------------
22.10.2010  Рохин Е.А.       [XXXXXX]  Для возможности вызова не через хранимые процедуры из ORACLE SAP,
                                       а напрямую из ABAP посредством Native-SQL:
                                       1. внесены изменения в процедуры:
                                            CreateAgr
                                            AddPart
                                            CreateNewZalog
                                            CreateNewMaturity
                                            CreatePart
                                            Add_SchedPayPrc
                                       2. функция
                                            Change_CrInfo
                                       переделана в процедуру с одним выходным параметром
                                       (Пункт плана 10-693)
----------  ---------------  --------- ---------------------------------------
06.12.2010  Некрасов А.В.    [XXXXXX]  При выдаче первого транша с условием уплаты %
                                       авансом нужно расчистить график
                                       начисления/уплаты % начиная с даты подписания
                                       договора по дату начисления %, которая <=
                                       периода уплаты % авансом
                                       (Пункт плана 10-876)
----------  ---------------  --------- ---------------------------------------
21.01.2011  Рохин Е.А.       [XXXXXX]  Для передачи номера группы для кредитов МСП
                                       внесены изменения в процедуру
                                            CreateAgr
                                       (Пункт плана 11-261)
                                       "Автоматическое присвоение группы кредитных
                                        договоров"
----------  ---------------  --------- ---------------------------------------
24.01.2011  Некрасов А.В.    [XXXXXX]  Создание записи в графике изменения лимита
                                       (если дата 00000000 - удаляются все записи
                                        в графике,
                                        если дата разумная - добавляется новая
                                        запись)
                                       (Пункт плана 11-206.2)
----------  ---------------  --------- ---------------------------------------
01.11.2011  Рохин Е.А.       [XXXXXX]  Создание процедур отправки SMS и E-mail
                                       (Пункт плана 11-859)
----------  ---------------  --------- ---------------------------------------
31.10.2012  Рохин Е.А.       [XXXXXX]  Передача признака изменяемого лимита
                                       для овердрафтов
                                       (Пункт плана 12-664)
----------  ---------------  --------- ---------------------------------------
12.04.2013  Некрасов А.В.    [XXXXXX]  Дата фактического подписания
                                       кредитного договора
                                       (Пункт плана 12-965)
----------  ---------------  --------- ---------------------------------------
12.04.2013  Рохин Е.А.       [XXXXXX]  Дата выбора лимита
                                       (Пункт плана 12-1166)
----------  ---------------  --------- ---------------------------------------
11.10.2012  Некрасов А.В.    [XXXXXX]  Исправление ошибки из-за "Доработка SAP R3 в части заведения кредитных
                                       договоров (дата подписания, переодичность контроля доп. условий
----------  ---------------  --------- ---------------------------------------
30.06.2014  Рохин Е.А.       [#15003]  Передача очередности гашения при создании кредитного договора
                                       (Пункт плана 14-528)
----------  ---------------  --------- ---------------------------------------
25.09.2014  Рохин Е.А.       [#16715]  Получение E-mail на сервере Банка для извещений о задолженности для ФЛ
                                       Передача E-mail на сервере Банка для извещений о задолженности для ФЛ
                                       при создании кредитного договора
                                       (Пункт плана 14-528.4)
----------  ---------------  --------- ---------------------------------------
26.12.2014  Рохин Е.А.       [#18689]  Исправлена ошибка неуникальности записи при определении процентных ставок
                                       по пеням на ссудную задолженность и проценты
                                       при попытке создания частей по траншу (CreatePart)
----------  ---------------  --------- ---------------------------------------
26.05.2015  Рохин Е.А.       [#22087]  Добавлена процедура передачи ПСК в кредитный договор
                                       и функция расчета ПСКдля форм альтернативной печати
----------  ---------------  --------- ---------------------------------------
08.09.2015   Лобик Д.А.      [15-997]  #24595 SAP R/3: Инспекция кода E7P, EEP
                                       Send_SMS, AddPart, Clear_SchedPayPrcForAdvance, Add_SchedPayPrc
                                       CreateNewMaturity, Add_SchedLim,Change_AGRSIGNDATE,Change_CrInfo
                                       Change_BKI_REQUEST, Change_LIMIT_EXPIRE_DATE,Change_SMS_AGR
                                       CreateNewZalog, CHANGE_CURATORID
----------  ---------------  --------- ---------------------------------------
10.12.2015  Рохин Е.А.       [#26420]  Добавлена процедура передачи значения в таблицу cdh
----------  ---------------  --------- ---------------------------------------
28.05.2016  Некрасов А.В.    [#30540]  Добавлена функция для установки контекста
----------  ---------------  --------- ---------------------------------------
30.05.2016  ubrr korolkov    [16-1808] 16-1808.2.3.2.4.5 Generate_Annuitet
----------  ---------------  --------- ---------------------------------------
19.07.2016  ubrr korolkov    [16-1808] 16-1808.2.3.2.4.5 Generate_Annuitet, добавлен p_tp_correct
----------  ---------------  --------- ---------------------------------------
28.07.2016  Чепель С.А.      [#34714]  Cвод портфеля ВУЗ банка по кредитам ФЛ (сверка)
----------  ---------------  --------- ---------------------------------------
01.08.2016  Рохин Е.А.       [16-1808] 16-1808.2.3.2.4.5 Откорректирована установка признаков отправки в БКИ
----------  ---------------  --------- ---------------------------------------
07.2017     Бунтова          [15-1115.1] Автоматизация скоринг-гарантий - Процедура определения свободного лимита
----------  ---------------  --------- ---------------------------------------
08.10.2018  Бунтова О.Г. #56138 [18-494] Расчет кода 8769
----------  ---------------  --------- ---------------------------------------
23.10.2019  Пинаев Д.Е.      [19-67365] Разработка - TUTDF версии 6.01 (29.10.19)
----------  ---------------  --------- ---------------------------------------
08.07.2020  Пылаев Е.А.      [19-59018] РАЗРАБОТКА АБС : Разделение отправки СМС- E-Mail-уведомлений УБРиР и ВУЗ
22.03.2021  Зеленко С.А.     DKBPA-105 ЭТАП 4.1 (репликация АБС): Формат распоряжения. ЗИУ для кредитов по короткой схеме
\******************************* HISTORY UBRR *****************************************/

  g_log_enable xxi.ups.cupsvalue%type := nvl(PREF.Get_Preference('UBRR_XXI5.UBRR_SAP_CD.ZIU_WRITE_LOG.ENABLE'),'N'); --22.03.2021  Зеленко С.А.     DKBPA-105 ЭТАП 4.1 (репликация АБС): Формат распоряжения. ЗИУ для кредитов по короткой схеме

  procedure CreateAgr(
    cpNumDog      in       varchar2   -- Символьный номер договора
   ,dpSignDate    in       varchar2   -- Дата подписания договора
   ,dpStartDate   in       varchar2   -- Дата договора
   ,dpEndDate     in       varchar2   -- Дата окончания договора
   --,dpSignDate    in       date       -- Дата подписания договора
   --,dpStartDate   in       date       -- Дата договора
   --,dpEndDate     in       date       -- Дата окончания договора
   ,ipGroup       in       number     -- Номер группы
   ,ipClientNum   in       number     -- Номер клиетна
   ,cClientName   in       varchar2   -- Наименование клиетна
   ,сpCur         in       varchar2   -- Валюта договора
   ,mpSum         in       number     -- Сумма договора
   ,ppIntRate     in       number     -- Процентная ставка
   ,ppPenyRate    in       number     -- Пени на средства
   ,ppPenyType    in       number     -- Тип пеней на средства (дневные 0, годовые 1)
   ,ppPenyRate2   in       number     -- Пени на проценты
   ,ppPenyType2   in       number     -- Тип пеней на проценты (дневные 0, годовые 1)
   ,ipPrtf        in       varchar2   -- Портфель
   ,cBranch       in       varchar2   -- Отделение
   ---->>>>>>Lobik D.A. ubrr 27.12.2005
   ,iLineType     in       number
   ,dpFirstTransDate in    varchar2   -- Дата первой выдачи
   --,dFirstTransDate in     date       -- Дата первой выдачи
   ,n_PERCTERMID    in     number     --id Срока оплаты %%
   ,mFirstTransSum  in     number     -- Суммы первой выдачи
   ,iloan_aim       in     number     -- Код цли кредита по табл. CAU
   ,iTurnType       in     number     -- Тип оборота (3 - X-дневный, 5 - в рабочих днях, 0 - в календарных днях)
   ,iTurnover       in     number     -- оборачиваемость кредита
   ----<<<<<---Lobik D.A. ubrr 27.12.2005
   ---->>>>>>Lobik D.A. ubrr 14.03.2006
   ,сAcc          in       varchar2   -- текущий счет
   ,сBIC          in       varchar2   -- БИК банка
     ----->>>>>>>>>>>>>>Lobik D.A. ubrr 04.07.2006
   ,is_IN_BKI     in       varchar2   -- Согласие на ЗАПРОС в БКИ (Y-ДА N-НЕТ)  UBRR Portnyagin D.Y. 19.09.2011
   ,dp_IN_BKI     in       varchar2   -- Дата Согласия на ЗАПРОС в БКИ UBRR Portnyagin D.Y. 19.09.2011
   ,iCR_OUT       in       number     --согласие сообщать в БКИ
   ,dpCR_OUT      in       varchar2   --дата согласия
   ,cCR_ID        in       varchar2   --код субъекта кредитной истории
     -----<<<<<<<<<<<<Lobik D.A. ubrr 04.07.2006
   ----<<<<<<<Lobik D.A. ubrr 14.03.2006
   -- >>> Рохин Е.А. 01.11.2011 (11-859)
   ,cpSMS_AGR     in       varchar2   -- Согласие на SMS-информирование
   ,cpSMS_INF     in       varchar2   -- Телефон для SMS-информирования
   ,cpEMAIL_AGR   in       varchar2   -- Согласие на E-Mail-информирование
   ,cpEMAIL_INF   in       varchar2   -- Адрес эл.почты для E-Mail-информирования
   -- <<< Рохин Е.А. 01.11.2011 (11-859)
   -- >>> Рохин Е.А. 25.09.2014 #16715 [14-528.4]
   ,cpUBRRMAIL    in       varchar2   -- Адрес эл.почты на сервере Банка для извещений
   -- <<< Рохин Е.А. 25.09.2014 #16715 [14-528.4]
   ,iXOverDays    in       number     --дни X-овер--->>><<<Лобик-Некрасов 24.01.2007
   ,noutAgrid     in out   number     -- Числовой номер договора
   ,cpPunktBASp   IN       varchar2   -- (ubrr) Samokaev R.V. --- 13.02.2008 --
   ,cpGrpObsp     in       varchar2   -- (ubrr) Samokaev R.V. --- 13.02.2008 --
   ,cnIsTransh    in       number     -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   ,cpABS         in       varchar2   -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   ,p_ret_day     IN NUMBER -- День платежа 01-31 Портнягин Д.Ю. 19.12.2012
   ,cpRepayment   in       varchar2   -- Порядок гашения задолженности 14-528 Рохин Е.А. 30.06.2014
   ,p_PERCCODE8769   in    NUMBER     -- Процент к коду 8769 - 08.10.2018 Бунтова О.Г. #56138 [18-494] Расчет кода 8769
   ,cpStatus      out      varchar2   -- Статус
   ,cpErrorMsg    out      varchar2   -- Сообщение об ошибке
                                   )
  is
   nPenyType    number;
   npAgrid CDA.ncdaagrid%TYPE;
   iCnt         NUMBER:=0;
   ---->>>>>>>Lobik D.A. ubrr 19.04.2006
   d_intcalc cds.dcdsintcalcdate%type;
   d_intpmt cds.dcdsintpmtdate%type;
   ----<<<<<<<Lobik D.A. ubrr 19.04.2006
   vnABS        VARCHAR2(2);-- (ubrr) Samokaev R.V. --- 22.12.2007 --
   vcAcc        VARCHAR2(25);-- (ubrr) Samokaev R.V. --- 22.12.2007 --
   vnGrpObsp    NUMBER;     -- (ubrr) Samokaev R.V. --- 13.02.2008 --

   cIsFOG       NUMBER;     -- (ubrr) Samokaev R.V. --- 19.06.2008 --
   cNameBankFOG VARCHAR2(128);-- (ubrr) Samokaev R.V. --- 19.06.2008 --
   nIDKBNK      NUMBER;     -- (ubrr) Samokaev R.V. --- 19.06.2008 --
   cIsAccSSB    NUMBER;     -- (ubrr) Samokaev R.V. --- 19.06.2008 -- наличие счёта на балансе ССБ
   cSetBIC      VARCHAR2(9);-- (ubrr) Samokaev R.V. --- 19.06.2008 -- БИК из настроечной таблицы;
   nKodF        NUMBER;
   dvSignDate   date;       -- Дата подписания договора
   dvStartDate  date;       -- Дата договора
   dvEndDate    date;       -- Дата окончания договора
   dvCR_OUT     date;       -- Дата согласия на передачу в БКИ
   dvFirstTransDate date;   -- Дата первой выдачи
   iPrt         NUMBER;
   dvBKI_IN date;
   vCalcMeth    CD_RETS_OUTS_OBOROTS.CALC_METHOD%type := 0;
  begin
--  RAISE_APPLICATION_ERROR(-20001,'ppPenyType='||to_char(ppPenyType));
-- Рохин Е.А. 22.10.2010 Переход от вызова хранимых процедур к прямому вызову (begin)

  IF nvl(ipPrtf,'0') <> '0' THEN
    BEGIN
        iPrt := to_number(ipPrtf);
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
  END IF;
  -- код портфеля не передаем в создаваемый кредитный договор
-- Некрасов А.В. 17.05.2012 а в 12-654 снова передаем
--  iPrt := null;

  -- Преобразуем даты
  BEGIN
    select   decode( dpSignDate,      '00000000', null, to_date(dpSignDate,       'YYYYMMDD') ),
             decode( dpStartDate,     '00000000', null, to_date(dpStartDate,      'YYYYMMDD') ),
             decode( dpEndDate,       '00000000', null, to_date(dpEndDate,        'YYYYMMDD') ),
             decode( dpCR_OUT,        '00000000', null, to_date(dpCR_OUT,         'YYYYMMDD') ),
             decode( dpFirstTransDate,'00000000', null, to_date(dpFirstTransDate, 'YYYYMMDD') ),
             decode( dp_IN_BKI ,      '00000000', null, to_date(dp_IN_BKI ,       'YYYYMMDD') )
        into dvSignDate,
             dvStartDate,
             dvEndDate,
             dvCR_OUT,
             dvFirstTransDate,
             dvBKI_IN
        from DUAL;
  EXCEPTION WHEN OTHERS THEN
        dvSignDate := null;
        dvStartDate := null;
        dvEndDate := null;
        dvCR_OUT := null;
        dvFirstTransDate := null;
        dvBKI_IN := null;
  END;
-- Рохин Е.А. 22.10.2010 Переход от вызова хранимых процедур к прямому вызову (end)

  cpStatus  := 'ERR';

  -- Check Block
  IF dvStartDate >= dvEndDate THEN
    cpErrorMsg    := char_to_sap('Дата окончания ранее Даты выдачи');
    return;
  END IF;

-- (ubrr) Samokaev R.V. --- 22.12.2007 --(begin)
/*  IF cpABS = '0' THEN vnABS := '1';  END IF;
  IF cpABS = '4' THEN vnABS := '2';  END IF;
--vnABS := '1';
  XXI_CONTEXT.Set_IDSmr (vnABS);
-- (ubrr) Samokaev R.V. --- 22.12.2007 --(end)---*/

-- Зуев А.А. 03.02.2009 № 5041-05/001797 ставим cpABS как текущий idSmr
  XXI_CONTEXT.Set_IDSmr (cpABS);

  select CSMRMFO8 into cSetBIC from smr;

  -->>>>>>>>>
  --  RAISE_APPLICATION_ERROR(-20001,to_char(noutAgrid)||' CD agreement Number must be entered!');
  if noutAgrid is null or noutAgrid = 0 then
      npAgrid := CD.New_ID(90000);
  else
      npAgrid := noutAgrid;
  end if;
--  RAISE_APPLICATION_ERROR(-20001,to_char(noutAgrid)||' CD agreement Number must be entered!');
  --<<<<<<<<
  LOOP
      BEGIN
-- (ubrr) Samokaev R.V. --- 19.06.2008 --(begin)
-- (ubrr) Samokaev R.V. --- 22.12.2007 --(begin)
--Проверка на существование счёта в таблице АСС

        select count('x') into cIsFOG from FOG where CFOGMFO8 = сBIC;
        if cIsFOG >0 then
          select CFOGNAME into cNameBankFOG from FOG where CFOGMFO8 = сBIC;
        end if;
        begin
          select NBNK_ID into nIDKBNK from KBNK where CBNK_RBIC = сBIC;
        exception when NO_DATA_FOUND then
          nIDKBNK := null;
        end;

        select count('x') into cIsAccSSB from xxi."acc" where CACCACC = сAcc and CACCCUR = сpCur and IDSMR = 2;
        begin
          select CACCACC into vcACC from ACC where CACCACC = сAcc and CACCCUR = сpCur;
        exception when NO_DATA_FOUND then
          vcACC := null;
        end;

--obuhov.v('SRV2!  - '||сBIC||' - '||сAcc);

        IF сBIC is null or сAcc is null or сBIC = '' or сAcc ='' or сBIC = '0' or сAcc ='0' or сBIC = '000000000' or сAcc ='00000000000000000000' THEN
          nKodF := null;
          vcACC := null;
--obuhov.v('SRV 1');
        ELSIF сBIC is not null and сBIC <> '' and (cIsFOG=0 and nIDKBNK is null) THEN
          nKodF := null;
          vcACC := null;
--obuhov.v('SRV 2');
        ELSIF сBIC = cSetBIC and vcACC is not null THEN
          nKodF := null;
--          vcACC := null;
--obuhov.v('SRV 3');
        ELSIF сBIC = '046577795' and vnABS = '1' and cIsAccSSB >0 THEN
          nKodF := 2903;
          vcACC := null;
--obuhov.v('SRV 4');
        ELSIF nIDKBNK is not null THEN
          nKodF := nIDKBNK;
          vcACC := null;
--obuhov.v('SRV 5');
        ELSIF nIDKBNK is null and сBIC <> '046577795' THEN
          INSERT INTO kbnk (cbnk_rbic, cbnk_name) values (сBIC, cNameBankFOG);
          begin
            select NBNK_ID into nIDKBNK from KBNK where CBNK_RBIC = сBIC;
          exception when NO_DATA_FOUND then
            nIDKBNK := null;
          end;
          nKodF := nIDKBNK;
          vcACC := null;
--obuhov.v('SRV 6');
        ELSE
          nKodF := null;
          vcACC := null;
        END IF;
-- (ubrr) Samokaev R.V. --- 22.12.2007 --(end)
-- (ubrr) Samokaev R.V. --- 19.06.2008 --(end)

        INSERT INTO xxi."cda"
                (ncdaAGRID, dcdaSIGNDATE, dcdaSIGNDATE2, iCDAnumgroup
                ,ccdaagrmnt
                , icdaclient, ccdacuriso, mcdatotal,CCDANORMNAME
                ---->>>>>>Lobik D.A. ubrr 27.12.2005
                ,ICDAISLINE
                ,icdalinetype
                ,icdapurpose
                ----<<<<<Lobik D.A. ubrr 27.12.2005
                ---->>>>>>Lobik D.A. ubrr 14.03.2006 (№ б/н от 09.03.2006 Некрасов п.п.8,2,7)
                ,ICDACOLLID -- группа обеспеченности -->>><<<--ubrr 13/02/2008 Самокаев Р.В.
                ,CCDACOMMSACCEPT
                ,CCDALOANACCEPT
                ,CCDAPERCENTACCEPT
                ,ICDAINTONOVD -->>><<<--ubrr 23/12/2007 Кузнецов Е.В.
                ,ICDAFEETYPE
                ,DCDALINEEND
                ,ICDACURRENTTYPE
                ,CCDACURRENTACC
                ----<<<<<Lobik D.A. ubrr 14.03.2006 (№ б/н от 09.03.2006 Некрасов п.п.8,2,7)
     ----->>>>>>>>>>>>>>Lobik D.A. ubrr 04.07.2006
                ,ccdacrinfo   --согласие сообщать в БКИ
                ,dcdacrinfdate--дата согласия
                ,ccdacrinfocode--код субъекта кредитной истории
     -----<<<<<<<<<<<<Lobik D.A. ubrr 04.07.2006
                ,ICDAFEETYPE4I
                )
        VALUES      (npAgrid, /*dpSignDate*/dvStartDate, dvSignDate
                 , decode(nvl(ipGroup,0),0,9999,ipGroup) --ipGroup
--ubrr---(изменено)--- Самокаев Р.В. ---26.12.2007 ---(begin)
--                ,decode(noutAgrid,null,cpNumDog,to_char(npAgrid))
                , decode(nvl(cpNumDog, ''), '', to_char(npAgrid), cpNumDog)
--ubrr---(изменено)--- Самокаев Р.В. ---26.12.2007 ---(end)
                , ipClientNum, сpCur, mpSum,char_convert.char_from_sap(cClientName)
                 ---->>>>>>Lobik D.A. ubrr 27.12.2005
                 --к сожалению в sap-е коды линий заданы не как в кредитном модуле
                ,decode(sign(nvl(iLineType,0)-2),-1,0,1)--срочный для null и iLineType<2
                ,decode(sign(nvl(iLineType,0)-2),-1,null,--срочный для null и iLineType<2
                        decode(iLineType,
                               2,2,--овердрафт
                               6,2,--овердрафт --->>><<<--Лобик Д.А.24.10.2006 по заявке Некрасова от 23.10.2006 вн.№ 6253
                               ---->>>>>>Lobik D.A. ubrr 14.03.2006 (№ б/н от 09.03.2006 Некрасов п.5)
                               --3,0,--Линия с лимитом задолженности
                               3,4,--Многочаст.линия с лимитом задолженности
                               --4,1,--Линия с лимитом выдачи
                               4,3,--Многочаст.линия с лимитом выдачи
                               ----<<<<<Lobik D.A. ubrr 14.03.2006 (№ б/н от 09.03.2006 Некрасов п.5)
                               null--другие линии не определены, м.б. определить в кред.мод.
                              )
                       )
                ,iloan_aim
                ,decode(cpGrpObsp, '+', 1, '?', 2, '-', 3)
                 ----<<<<<Lobik D.A. ubrr 27.12.2005
                ---->>>>>>Lobik D.A. ubrr 14.03.2006 (№ б/н от 09.03.2006 Некрасов п.п.8,2,7)
--              18.01.2012 Теперь п. Б/А списания могут содержать русские буквы
                ,char_convert.char_from_sap(cpPunktBASp)
                ,char_convert.char_from_sap(cpPunktBASp)
                ,char_convert.char_from_sap(cpPunktBASp)
/*
--ubrr---(изменено)--- Самокаев Р.В. ---13.02.2008 ---(begin)
                ,cpPunktBASp -- (ubrr) Samokaev R.V. --- 13.02.2008 --
--                ,'2.3.2'--прорисывать константу - глупость, но так просят
                ,cpPunktBASp -- (ubrr) Samokaev R.V. --- 13.02.2008 --
                ,cpPunktBASp -- (ubrr) Samokaev R.V. --- 13.02.2008 --
--ubrr---(изменено)--- Самокаев Р.В. ---13.02.2008 ---(end)
*/
                , 1 -- начислять на просроченные средства по базовой ставке -->>><<<--ubrr 23/12/2007 Кузнецов Е.В.
                --->>> Lobik-Nekrasov 24.01.2007
                ---,decode(ppPenyRate,null,0,0,0,1)--если есть пени, то они годовые
                ,decode(ppPenyType,null,1,0,1,0)--если 0, то год
                --<<< Lobik-Nekrasov 24.01.2007
                --->>>--Лобик Д.А.24.10.2006 по заявке Некрасова от 23.10.2006 вн.№ 6253
                --,decode(sign(nvl(iLineType,0)-2),-1,null,dpEndDate)--срок возврата для линий
--                ,decode(iLineType,6,null, decode(sign(nvl(iLineType,0)-2),-1,null,dvEndDate))--срок возврата для линий
                ---<<<--Лобик Д.А.24.10.2006 по заявке Некрасова от 23.10.2006 вн.№ 6253
                --->>>--Некрасов А.В. 21.05.2012, ошибка c 2006 при обработке вида кредита 6 (овер с изм лимитом)
                ,decode(iLineType,6,dvEndDate, decode(sign(nvl(iLineType,0)-2),-1,null,dvEndDate))--срок возврата для линий
                ---<<<--Некрасов А.В. 21.05.2012, ошибка c 2006 при обработке вида кредита 6 (овер с изм лимитом)
                ,0 --ICDACURRENTTYPE
                ,vcACC-- текущий счет по БИКу банка
                ----<<<<<Lobik D.A. ubrr 14.03.2006 (№ б/н от 09.03.2006 Некрасов п.п.8,2,7)
                ----->>>>>>>>>>>>>>Lobik D.A. ubrr 04.07.2006
                ,decode(iCR_OUT,1,'1','0')--согласие сообщать в БКИ
                ,decode(iCR_OUT,1,dvCR_OUT,null)--дата согласия
                ,decode(iCR_OUT,1,char_convert.char_from_sap(cCR_ID),null)--код субъекта кредитной истории
                -----<<<<<<<<<<<<Lobik D.A. ubrr 04.07.2006
                ,decode(ppPenyType2,null,1,0,1,0)--если 0, то год
                );

        if  nKodF is not null then
--obuhov.v('SRV insert into CDA_ACC_OUT');
          insert into CDA_ACC_OUT (NADDAGRID, IADDTYPEOUT, NADDTYPE, CADDACC, CADDCURISO, NADDKBNKID)
               values (npAgrid, 2, 2, сAcc, сpCur, nKodF);
        end if;

        EXIT;
       EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
          if noutAgrid is null or noutAgrid = 0 then
              npAgrid := CD.New_ID(90000);
              iCnt := iCnt + 1;
          else
             RAISE_APPLICATION_ERROR(-20001,'Unique agr.num.must be entered,not'||to_char(npAgrid)||'!');
          end if;
       END;
       --
       IF   iCnt > 10 THEN
             RAISE_APPLICATION_ERROR(-20001,'No found free number CD agrid');
       END IF;
  END LOOP;
  --

  --  cBranch  -- Отделение
     if nvl(cBranch,'0') <> '0' then
      BEGIN
        select 1
        INTO iCnt
        from otd where iOTDnum = to_number(cBranch) ;

        UPDATE CDA SET ICDABRANCH =  to_number(cBranch)
        WHERE ncdaAGRID = npAgrid;

      EXCEPTION WHEN OTHERS THEN
       Null;
      END;
     end if;

-- create part #1 (CDQ)
--
    INSERT INTO CDQ
                (ncdqAGRID, icdqPART)
    VALUES      (npAgrid, 1);
-- make it 30-days-a-month (CDH)
    INSERT INTO CDH
                (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, icdhIVAL)
    VALUES      (npAgrid, 1, dvStartDate, 'MONTH', 1);

-- make it 360-days-in-a-year one (CDH)
    INSERT INTO CDH
                (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, icdhIVAL)
    VALUES      (npAgrid, 1, dvStartDate, 'YEAR', 366);

-- restforint (CDH)
    INSERT INTO CDH
                (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, icdhIVAL)
    VALUES      (npAgrid, 1, dvStartDate, 'REST', 1);

    INSERT INTO CDH
                (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, icdhIVAL)
    VALUES      (npAgrid, 1, dvStartDate, 'INCTYPE', 2);

    INSERT INTO CDH
                (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, icdhIVAL)
    VALUES      (npAgrid, 1, dvStartDate, 'ROUND', 2);

    if ppIntRate is not null then
      INSERT INTO CDH
                  (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
      VALUES      (npAgrid, 1, dvStartDate, 'INTRATE', ppIntRate);
-->>>ubrr 23/12/2007 Кузнецов Е.В.
      INSERT INTO CDH
                  (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
      VALUES      (npAgrid, 1, dvStartDate, 'OVDRATE', ppIntRate);
--<<<ubrr 23/12/2007 Кузнецов Е.В.
    end if;
    if nvl(ppPenyRate,0) > 0 then
      INSERT INTO CDH
                  (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
      VALUES      (npAgrid, 1, dvStartDate, 'LOANFINE', ppPenyRate);
    end if;
    if nvl(ppPenyRate2,0) > 0 then
      INSERT INTO CDH
                  (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
      VALUES      (npAgrid, 1, dvStartDate, 'INTFINE', ppPenyRate2);
    end if;

    if iPrt is not null then
      INSERT INTO CDH
                  (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, icdhiVAL)
      VALUES      (npAgrid, 1, dvStartDate, 'PRTF', iPrt);
    end if;

--ubrr---(добавлено)--- Самокаев Р.В. ---31.07.2008 ---(begin)
    select decode(ppPenyType,null,1,0,1,0) into nPenyType from dual;
    INSERT INTO CDH
                (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, icdhIVAL)
    VALUES      (npAgrid, 1, dvStartDate, 'LFEETYPE', nPenyType);
--ubrr---(добавлено)--- Самокаев Р.В. ---31.07.2008 ---(end)

    if dvEndDate is not null then
      ---->>>Лобик Д.А. 05.03.2007 по с/з Некрасова А.В. от 26.02.2007
      ---insert into cdr
      ---            (ncdragrid, icdrpart, dcdrdate, mcdrsum)
      ---values      (npAgrid, 1, dpEndDate, mpSum);
      begin--для оверов в cdr не надо ничего вставлять
          iCnt:=0;
          select count(*)
          into iCnt
          from cda
          where cda.ncdaagrid=npAgrid
                and cda.icdaisline=1
                and icdalinetype=2 ---овердрафт
          ;
          if cnIsTransh = 0 then
            if iCnt = 0 then --наш договор - не является овердрафтом
              insert into cdr
                          (ncdragrid, icdrpart, dcdrdate, mcdrsum)
              values      (npAgrid, 1, dvEndDate, mpSum);
            end if;
          end if;
      exception when others then
              null;
      end;
      ---<<<Лобик Д.А. 05.03.2007 по с/з Некрасова А.В. от 26.02.2007
    end if;--if dpEndDate is not nul
    --

     -->>> Lobik-Nekrasov 24.01.2007
     ---insert into ubrr_djko_cd_cdaadd2(ncda2agrid, icdalastpercent)
     --- values (npAgrid, 1);
     if nvl(iXOverDays,0)>0 then --X-овердрафты
        INSERT INTO ubrr_djko_cd_cdaadd2
               (ncda2agrid,icdalastpercent,icdaspover,icdafeetype,icdascaseid)
        VALUES (npAgrid   , 1             ,iXOverDays,  1        ,null       );
     else
        insert into ubrr_djko_cd_cdaadd2(ncda2agrid, icdalastpercent)
        values (npAgrid, 1);
     end if;--if nvl(iXOverDays,0)>0 then
     --<<< Lobik-Nekrasov 24.01.2007

    ---->>>>>>Lobik D.A. ubrr 24.03.2006
        --в ubrr_djko_cd_cdaadd2 был неверный тип ncda2agrid
    ----<<<<<<Lobik D.A. ubrr 24.03.2006

    ---->>>>>>Lobik D.A. ubrr 28.12.2005
    --Первая выдача
    if dvFirstTransDate is not null then
      ---->>>Лобик Д.А. 05.03.2007 по с/з Некрасова А.В. от 26.02.2007
      ---insert into cdp
      ---            (ncdpagrid, icdppart, dcdpdate       , mcdpsum)
      ---values      (npAgrid  , 1       , dFirstTransDate, mFirstTransSum);
      begin--для оверов в cdp не надо ничего вставлять
          iCnt:=0;
          select count(*)
          into iCnt
          from cda
          where cda.ncdaagrid=npAgrid
                and cda.icdaisline=1
                and icdalinetype=2 ---овердрафт
          ;

          if cnIsTransh = 0 then
            if iCnt = 0 then --наш договор - не является овердрафтом
              insert into cdp
                          (ncdpagrid, icdppart, dcdpdate       , mcdpsum)
              values      (npAgrid  , 1       , dvFirstTransDate, decode(sign(nvl(iLineType,0)-2),-1,mpSum,mFirstTransSum));
            end if;
          end if;
      exception when others then
              null;
      end;
      ---<<<Лобик Д.А. 05.03.2007 по с/з Некрасова А.В. от 26.02.2007
    end if;

    if iTurnover<>0 and iTurnover is not null
       --не X-овердрафты
       and nvl(iXOverDays,0)=0 -->>><<<Лобик Д.А. 05.03.2007 по с/з Некрасова А.В. от 26.02.2007
    then
        -->> 30.05.2016 ubrr korolkov 16-1808.2.3.2.4.5
        if iTurnType = 5 then
            vCalcMeth := ubrr_cd.CM_WORKING_DAYS;
        end if;
        --<< 30.05.2016 ubrr korolkov 16-1808.2.3.2.4.5
        begin
            insert into CD_RETS_OUTS_OBOROTS( ID_REG, OBOROT_DN, CALC_METHOD)
                                      values(npAgrid, iTurnover, vCalcMeth);
        exception  when others then
            null;
        end;
    end if;
    ----<<<<<---Lobik D.A. ubrr 28.12.2005

    ---->>>>>>Lobik D.A. ubrr 14.03.2006 (№ б/н от 09.03.2006 Некрасов п.3)

--ubrr---(изменено)--- Самокаев Р.В. ---13.02.2008 ---(begin)
    --группа обеспеч-ти = необеспеченная
    if cpGrpObsp = '+' then vnGrpObsp := 1;
     elsif cpGrpObsp = '?' then vnGrpObsp := 2;
     elsif cpGrpObsp = '-' then vnGrpObsp := 3;
    end if;
      CD.Update_History(npAgrid, 1, 'COLLID', dvStartDate, null, null, vnGrpObsp, null);
--ubrr---(изменено)--- Самокаев Р.В. ---13.02.2008 ---(end)

    if  nvl(iLineType,0)>0 then--линия
       CD.Update_History(npAgrid, 1, 'LIMIT' , dvStartDate,mpSum, null, null, null);
    end if;

   ---->>>>>>>Lobik D.A. ubrr 19.04.2006
     --Первое начисление %% - минимум  из:
      --      -последнего календарного дня месяца реквизита "Дата договора" и
      --      -реквизита "Срок возврата"

      d_intcalc:=least(last_day(dvStartDate),dvEndDate);
       --"Первая уплата %" -
      --   -Для значения реквизита заявки "Срок оплаты процентов" равному 1 - "В момент окончательного погашения кредита" - ставить равной реквизиту "Срок возврата",
      --   -Для остальных значений реквизита заявки "Срок оплаты процентов" - ставить минимум из:
      --        --10 числа следующего месяца за месяцем "Дата договора" и
      --        --реквизита "Срок возврата"

--->>>> (изм)---Самокаев Р.В. --- 19.06.2008 --- (begin)

-->> Портнягин Д.Ю. 19.12.2012 Прописываем в договоре параметр "День платежа"
      IF p_ret_day > 0 THEN
        cdterms.update_history(AGRID   => npAgrid,
                               PART    => 1,
                               Term    => 'UBRRPDAY',
                               EffDate => dvStartDate,
                               CVAL    => p_ret_day);
      END IF;
--<< Портнягин Д.Ю. 19.12.2012

      IF n_PERCTERMID = 1 or n_PERCTERMID = 3 or n_PERCTERMID = 999 then
        if n_PERCTERMID = 1 then
            d_intpmt:=dvEndDate;
        else
            d_intpmt:=least(last_day(dvStartDate)+10,dvEndDate);
        end if;
        calc_interval(npAgrid ,d_intcalc, d_intpmt, cpErrorMsg);
      -->> Портнягин Д.Ю. 19.12.2012 применение плавающих графиков
      ELSIF n_PERCTERMID = 6 THEN
        ubrr_xxi5.ubrr_cd_interval.init(npAgrid);
        ubrr_xxi5.ubrr_cd_interval.calc_interval (  p_fixed_param              => 0,  -- Расчет: 0-с даты подписания
                                                                                      --         1-с текущей даты
                                                    p_interv                   => 0,  -- Интервал: 0-месяц
                                                                                      --           1-квартал
                                                                                      --           2-полгода
                                                                                      --           3-год
                                                                                      --           4-декада
                                                    p_dt                       => nvl(dvFirstTransDate,dvSignDate), -- Первое начисление
                                                    p_dt2                      => to_date('01'||to_char(add_months(nvl(dvFirstTransDate,dvSignDate),1),'mm.yyyy'),'dd.mm.yyyy'), -- Первая уплата
                                                    p_pay_during               => 1, -- Уплатить в течение  1-да 0-нет          *
                                                    p_work_day                 => 0, -- Рабочих 1-да 0-нет                      *
                                                    p_num_of_day               => 5, -- Дней                                    *
                                                    p_type_rem                 => 9,  -- Тип определения сдвига: 0-по сдвигу первой даты
                                                                                      --                         1-по последнему дню интервала
                                                                                      --                         2-по дню месяца первой даты
                                                                                      --                         9-по дню месяца первой уплаты
                                                    p_pay_day                  => p_ret_day,
                                                    p_only_working_days        => 1, -- Исключать выходные
                                                    p_ab                       => 1, -- '1'  - с возвратом позже
                                                                                     -- '-1' - с возвратом ранее
                                                    p_tp_correct               => 0, -- сдвигать интервал начисления 1-да 0-нет
                                                    p_calc_date_last_day       => 0, -- Считать даты последним днем месяца? 1-да 0-нет
                                                    p_is_first_date_last_day   => 0, -- Считать дату первого начисления  последним днем месяца? 1-да 0-нет
                                                    p_is_first_pay_last_day    => 0  -- Считать дату первой уплаты последним днем месяца? 1-да 0-нет
                                                  );
      --<< Портнягин Д.Ю. 19.12.2012 применение плавающих графиков
      ELSIF n_PERCTERMID = 8 THEN -- по дату погашения
        ubrr_xxi5.ubrr_cd_interval.init(npAgrid);
        ubrr_xxi5.ubrr_cd_interval.calc_interval (  p_fixed_param              => 0,  -- Расчет: 0-с даты подписания
                                                                                      --         1-с текущей даты
                                                    p_interv                   => 0,  -- Интервал: 0-месяц
                                                                                      --           1-квартал
                                                                                      --           2-полгода
                                                                                      --           3-год
                                                                                      --           4-декада
                                                    p_dt                       => nvl(dvFirstTransDate,dvSignDate), -- Первое начисление
                                                    p_dt2                      => to_date('01'||to_char(add_months(nvl(dvFirstTransDate,dvSignDate),1),'mm.yyyy'),'dd.mm.yyyy'), -- Первая уплата
                                                    p_pay_during               => 1, -- Уплатить в течение  1-да 0-нет          *
                                                    p_work_day                 => 0, -- Рабочих 1-да 0-нет                      *
                                                    p_num_of_day               => 0, -- Дней                                    *
                                                    p_type_rem                 => 9,  -- Тип определения сдвига: 0-по сдвигу первой даты
                                                                                      --                         1-по последнему дню интервала
                                                                                      --                         2-по дню месяца первой даты
                                                                                      --                         9-по дню месяца первой уплаты
                                                    p_pay_day                  => p_ret_day,
                                                    p_only_working_days        => 1, -- Исключать выходные
                                                    p_ab                       => 1, -- '1'  - с возвратом позже
                                                                                     -- '-1' - с возвратом ранее
                                                    p_tp_correct               => 1, -- сдвигать интервал начисления 1-да 0-нет
                                                    p_calc_date_last_day       => 0, -- Считать даты последним днем месяца? 1-да 0-нет
                                                    p_is_first_date_last_day   => 0, -- Считать дату первого начисления  последним днем месяца? 1-да 0-нет
                                                    p_is_first_pay_last_day    => 0  -- Считать дату первой уплаты последним днем месяца? 1-да 0-нет
                                                  );
      END IF;
---<<<< (изм)---Самокаев Р.В. --- 19.06.2008 --- (end)

   ----<<<<<<<Lobik D.A. ubrr 19.04.2006
    ----<<<<<Lobik D.A. ubrr 14.03.2006 (№ б/н от 09.03.2006 Некрасов п.3)
-->> Рохин Е.А. 04.10.2011
-- признак согласия заемщика на передачу в БКИ
    if iCR_OUT = 1 then
       INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , CCDHCVAL)
       VALUES      (npAgrid
                  , 1
                  , dvCR_OUT
                  , 'CDCRINF'
                  , char_convert.char_from_sap(cCR_ID)
       );
    end if;
--<< Рохин Е.А. 04.10.2011
-->> Рохин Е.А. 01.08.2016 признаки отправки в БКИ устанавливаем всегда; если нет даты согласия, то с даты подписания
    INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , ICDHIVAL)
       VALUES      (npAgrid
                  , 1
                  , nvl(dvCR_OUT, dvStartDate)
                  , 'AGR_NBKI'
                  , 1
       );

    INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , ICDHIVAL)
       VALUES      (npAgrid
                  , 1
                  , nvl(dvCR_OUT, dvStartDate)
                  , 'AGR_OKB'
                  , 0
       );

    INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , ICDHIVAL)
       VALUES      (npAgrid
                  , 1
                  , nvl(dvCR_OUT, dvStartDate)
                  , 'AGR_EQV'
                  , 0
       );
--<< Рохин Е.А. 01.08.2016 признаки отправки в БКИ устанавливаем всегда; если нет даты согласия, то с даты подписания

-->> Portnyagin D.Y. 19.09.2011
-- признак согласия заемщика на запрос в БКИ
    if dvBKI_IN is not null AND is_IN_BKI is not null then
       INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , CCDHCVAL)
       VALUES      (npAgrid
                  , 1
                  , dvBKI_IN
                  , 'UBRR_BKI'
                  , is_IN_BKI
       );
    end if;
--<< Portnyagin D.Y. 19.09.2011
  -- >>> Рохин Е.А. 01.11.2011 (11-859)
    if cpSMS_AGR = 'Y' then
      begin
       INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , ICDHIVAL)
       VALUES      (npAgrid
                  , 1
                  , dvStartDate
                  , 'UBRRSMSA'
                  ,1
       );
       INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , CCDHCVAL)
       VALUES      (npAgrid
                  , 1
                  , dvStartDate
                  , 'UBRR_SMS'
                  , char_convert.char_from_sap(cpSMS_INF)
       );
      end;
    else
       INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , ICDHIVAL)
       VALUES      (npAgrid
                  , 1
                  , dvStartDate
                  , 'UBRRSMSA'
                  ,0
       );
    end if;
    if cpEMAIL_AGR = 'Y' then
      begin
       INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , ICDHIVAL)
       VALUES      (npAgrid
                  , 1
                  , dvStartDate
                  , 'UBRREMLA'
                  ,1
       );
       INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , CCDHCVAL)
       VALUES      (npAgrid
                  , 1
                  , dvStartDate
                  , 'UBRR_EML'
                  , char_convert.char_from_sap(cpEMAIL_INF)
       );
      end;
    else
       INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , ICDHIVAL)
       VALUES      (npAgrid
                  , 1
                  , dvStartDate
                  , 'UBRREMLA'
                  ,0
       );
    end if;
  -- <<< Рохин Е.А. 01.11.2011 (11-859)

  -- >>> -- Рохин Е.А.  31.10.2012  #5017  12-664
    -- для овердрафтов с изменяемым лимитом
    -- установим значение признака в условиях договора
    if nvl(iLineType,0) = 6 then
      INSERT INTO CDH( ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , ICDHIVAL)
       VALUES     ( npAgrid
                  , 1
                  , dvStartDate
                  , 'UBRR_LIM'
                  ,1
                  );
    end if;
  -- <<< -- Рохин Е.А.  31.10.2012  #5017  12-664

  -- >>> -- Рохин Е.А.  30.06.2014  #15003  14-528
    if cpRepayment is null or
       char_convert.char_from_sap(cpRepayment) = ''
    then
       null;
    else
        INSERT
            INTO ubrr_data.UBRR_SRR_CDA_PROP_val
            VALUES ( 1
                   , npAgrid
                   , char_convert.char_from_sap(cpRepayment)
                   );
    end if;
  -- <<< -- Рохин Е.А.  30.06.2014  #15003  14-528
  -- >>> -- Рохин Е.А.  25.09.2014 #16715 [14-528.4]
    if cpUBRRMAIL is null or cpUBRRMAIL = '' or cpUBRRMAIL = ' '
    then
        null;
    else
        INSERT INTO CDH(ncdhAGRID
                      , icdhPART
                      , dcdhDATE
                      , ccdhTERM
                      , CCDHCVAL)
        VALUES      (npAgrid
                   , 1
                   , dvStartDate
                   , 'UBRRMAIL'
                   , cpUBRRMAIL
       );
    end if;
  -- <<< -- Рохин Е.А.  25.09.2014 #16715 [14-528.4]
  -->> 08.10.2018 Бунтова О.Г. #56138 [18-494] Расчет кода 8769
  if p_PERCCODE8769 = 0
    then
        null;
    else
        INSERT INTO CDH(ncdhAGRID
                      , icdhPART
                      , dcdhDATE
                      , ccdhTERM
                      , PCDHPVAL)
        VALUES      (npAgrid
                   , 1
                   , dvStartDate
                   , 'CODE8769'
                   , p_PERCCODE8769
       );
    end if;
  --<< 08.10.2018 Бунтова О.Г. #56138 [18-494] Расчет кода 8769
    cpErrorMsg    := char_to_sap('OK');
    noutAgrid := npAgrid;
    cpStatus  := 'OK';

    if n_PERCTERMID = 7 then
        insert into xxi.cda2 ( NCDA2AGRID, NCDA2FLFX_A, NCDA2ANN_A, MCDA2SUM_A, NCDA2INT_A, DCDA2DTF_A,
                               NCDA2DTN_A, NCDA2OWD_A, NCDA2OWDCR_A, DCDA2DTL_A )
                      values ( npAgrid, 1, 1, 0, 0, dvStartDate,
                               nvl( p_ret_day, 0), 1, 1, dvEndDate );
    end if;

    -->> 23.10.2019 Пинаев Д.Е. [19-67365] Разработка - TUTDF версии 6.01 (29.10.19)
    ubrr_bki_uid.save_uid_to_cd(P_agrid => npAgrid);
    --<< 23.10.2019 Пинаев Д.Е. [19-67365] Разработка - TUTDF версии 6.01 (29.10.19)

    return;
  exception
    when others then
      cpStatus  := 'ERR';
      cpErrorMsg    := char_to_sap( dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace());
      return;
  end;

  PROCEDURE CreatePart(
   npAgrid          in       number   -- номер договора
   ,dpDelivery      in       varchar2 -- Дата выдачи
   ,ppIntRate       in       number   -- Процентная ставка
   ,npSumPart_30d   in       number   -- Сумма части (до 30 дней)
   ,npSumPart_90d   in       number   -- Сумма части (от 31 до 90 дней)
   ,npSumPart_180d  in       number   -- Сумма части (от 91 до 180 дней)
   ,npSumPart_1y    in       number   -- Сумма части (от 181 дня до 1 года)
   ,npSumPart_3y    in       number   -- Сумма части (от 1 года до 3 лет)
   ,npSumPart_ovr3y in       number   -- Сумма части (свыше 3 лет)
   ,cpABS           in       varchar2 -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   ,npStrNumPart    out      number   -- Номер начальной части
   ,npFinNumPart    out      number   -- Номер последней части
   ,cpErrorMsg      out      varchar2 -- Сообщение об ошибке
                       )
  IS
-- (ubrr) (изм) Samokaev R.V. --- 31.07.2007 --(begin)
--    TYPE T_SummOfParts IS VARRAY(5) OF NUMBER;
    TYPE T_SummOfParts IS VARRAY(30) OF NUMBER;
-- (ubrr) (изм) Samokaev R.V. --- 31.07.2007 --(end)
    SummOfParts T_SummOfParts := T_SummOfParts();
    cnt         number:=0;
    nPart       number:=0;  -- счётчик частей транша
    vcPenyRate  number;
    vcPenyRate2 number;
    vnABS       varchar2(2);-- (ubrr) Samokaev R.V. --- 22.12.2007 --
    nContext    number;
    dvDelivery  date;
--
  BEGIN

    if cpABS is null then
      cpErrorMsg := char_to_sap('Номер АБС = NULL');
      return;
    end if;

-- Рохин Е.А. 22.10.2010 Переход от вызова хранимых процедур к прямому вызову (begin)
    BEGIN
      select   decode( dpDelivery, '00000000', null, to_date(dpDelivery, 'YYYYMMDD') )
        into dvDelivery
        from DUAL;
    EXCEPTION WHEN OTHERS THEN
        dvDelivery := null;
    END;

    -->> Рохин Е.А. 26.12.2014 #18689
    if dvDelivery = null then -- дата не указана
      cpErrorMsg := char_to_sap('Не указана дата выдачи транша');
      return;
    end if;
    --<< Рохин Е.А. 26.12.2014 #18689
-- Рохин Е.А. 22.10.2010 Переход от вызова хранимых процедур к прямому вызову (end)
/*
-- (ubrr) Samokaev R.V. --- 22.12.2007 --(begin)
  IF cpABS = '0' THEN
    vnABS := '1';
  END IF;
  IF cpABS = '4' THEN
    vnABS := '2';
  END IF;

  XXI_CONTEXT.Set_IDSmr (vnABS);*/
-- (ubrr) Samokaev R.V. --- 22.12.2007 --(end)---

-- Зуев А.А. 03.02.2009 № 5041-05/001797 ставим cpABS как текущий idSmr
  XXI_CONTEXT.Set_IDSmr (cpABS);

    select count(*)
      into cnt
      from cda
     where cda.ncdaagrid = npAgrid
       and icdaisline = 1
       and icdalinetype in (3, 4); ---Многочастевые линии с лим выдачи и лимитом задолж.

    if cnt = 0 then -- договор не является многочастевой линией
      cpErrorMsg := char_to_sap('Тип договора - не многочастевая линия');
      return;
    end if;

    if nvl(npSumPart_30d, 0) != 0 then
      SummOfParts.Extend;
      SummOfParts(SummOfParts.last) := npSumPart_30d;
    end if;
    if nvl(npSumPart_90d, 0) != 0 then
      SummOfParts.Extend;
      SummOfParts(SummOfParts.last) := npSumPart_90d;
    end if;
    if nvl(npSumPart_180d, 0) != 0 then
      SummOfParts.Extend;
      SummOfParts(SummOfParts.last) := npSumPart_180d;
    end if;
    if nvl(npSumPart_1y, 0) != 0 then
      SummOfParts.Extend;
      SummOfParts(SummOfParts.last) := npSumPart_1y;
    end if;
    if nvl(npSumPart_3y, 0) != 0 then
      SummOfParts.Extend;
      SummOfParts(SummOfParts.last) := npSumPart_3y;
    end if;
    if nvl(npSumPart_ovr3y, 0) != 0 then
      SummOfParts.Extend;
      SummOfParts(SummOfParts.last) := npSumPart_ovr3y;
    end if;

    begin
      select nvl(max(ICDPPART), 0) into npStrNumPart from CDP where NCDPAGRID = npAgrid;
    exception when NO_DATA_FOUND then
      npStrNumPart := 0;
    end;
-- Рохин Е.А. 27.10.2010 Ставки берем из последней части
    begin
      select PCDHPVAL into vcPenyRate from CDH H
           where H.NCDHAGRID = npAgrid
           and   H.CCDHTERM = 'LOANFINE'
           and   H.ICDHPART = npStrNumPart
           -->> Рохин Е.А. 26.12.2014 #18689 Ставку (одну!) берем последнюю по дате
           and   H.DCDHDATE = (select max(DCDHDATE) from CDH
                                where NCDHAGRID = H.NCDHAGRID
                                and   CCDHTERM = 'LOANFINE'
                                and   ICDHPART = H.ICDHPART
                                and   DCDHDATE <= dvDelivery);
           --<< Рохин Е.А. 26.12.2014 #18689 Ставку (одну!) берем последнюю по дате
    exception when NO_DATA_FOUND then
      begin
      select PCDHPVAL into vcPenyRate from CDH H
           where H.NCDHAGRID = npAgrid
           and   H.CCDHTERM = 'LOANFINE'
           and   H.ICDHPART = 1
           -->> Рохин Е.А. 26.12.2014 #18689 Ставку (одну!) берем последнюю по дате
           and   H.DCDHDATE = (select max(DCDHDATE) from CDH
                                where NCDHAGRID = H.NCDHAGRID
                                and   CCDHTERM = 'LOANFINE'
                                and   ICDHPART = H.ICDHPART
                                and   DCDHDATE <= dvDelivery);
           --<< Рохин Е.А. 26.12.2014 #18689 Ставку (одну!) берем последнюю по дателеднюю по дате
      exception when NO_DATA_FOUND then vcPenyRate := 0;
      end;
    end;
    begin
      select PCDHPVAL into vcPenyRate2 from CDH H
           where H.NCDHAGRID = npAgrid
           and   H.CCDHTERM = 'INTFINE'
           and   H.ICDHPART = npStrNumPart
           -->> Рохин Е.А. 26.12.2014 #18689 Ставку (одну!) берем последнюю по дате
           and   H.DCDHDATE = (select max(DCDHDATE) from CDH
                                where NCDHAGRID = H.NCDHAGRID
                                and   CCDHTERM = 'INTFINE'
                                and   ICDHPART = H.ICDHPART
                                and   DCDHDATE <= dvDelivery);
           --<< Рохин Е.А. 26.12.2014 #18689 Ставку (одну!) берем последнюю по дате
    exception when NO_DATA_FOUND then
      begin
      select PCDHPVAL into vcPenyRate2 from CDH H
           where H.NCDHAGRID = npAgrid
           and   H.CCDHTERM = 'INTFINE'
           and   H.ICDHPART = 1
           -->> Рохин Е.А. 26.12.2014 #18689 Ставку (одну!) берем последнюю по дате
           and   H.DCDHDATE = (select max(DCDHDATE) from CDH
                                where NCDHAGRID = H.NCDHAGRID
                                and   CCDHTERM = 'INTFINE'
                                and   ICDHPART = H.ICDHPART
                                and   DCDHDATE <= dvDelivery);
           --<< Рохин Е.А. 26.12.2014 #18689 Ставку (одну!) берем последнюю по дателеднюю по дате
      exception when NO_DATA_FOUND then vcPenyRate2 := 0;
      end;
    end;
--      obuhov.V('SRV (npStrNumPart)- '||to_char(npStrNumPart));


      npFinNumPart := npStrNumPart+SummOfParts.Count;

    if npStrNumPart = 0 then
      for nPart IN 1..SummOfParts.Count
      loop
        if nPart > 1 then
          insert into CDQ (NCDQAGRID, ICDQPART)
             values (npAgrid, (npStrNumPart+nPart));
          INSERT INTO CDH
                      (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
          VALUES      (npAgrid, (npStrNumPart+nPart), dvDelivery, 'INTRATE', ppIntRate);
          INSERT INTO CDH
                      (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
          VALUES      (npAgrid, (npStrNumPart+nPart), dvDelivery, 'OVDRATE', ppIntRate);
          INSERT INTO CDH
                      (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
          VALUES      (npAgrid, (npStrNumPart+nPart), dvDelivery, 'LOANFINE', vcPenyRate);
          INSERT INTO CDH
                      (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
          VALUES      (npAgrid, (npStrNumPart+nPart), dvDelivery, 'INTFINE', vcPenyRate2);
        end if;
        insert into CDP (NCDPAGRID, ICDPPART, DCDPDATE, MCDPSUM)
           values (npAgrid, (npStrNumPart+nPart), dvDelivery, SummOfParts(nPart));
      end loop;
    else
      for nPart IN 1..SummOfParts.Count
      loop
        insert into CDQ (NCDQAGRID, ICDQPART)
           values (npAgrid, (npStrNumPart+nPart));
        insert into CDP (NCDPAGRID, ICDPPART, DCDPDATE, MCDPSUM)
           values (npAgrid, (npStrNumPart+nPart), dvDelivery, SummOfParts(nPart));
        INSERT INTO CDH
                    (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
        VALUES      (npAgrid, (npStrNumPart+nPart), dvDelivery, 'INTRATE', ppIntRate);
        INSERT INTO CDH
                    (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
        VALUES      (npAgrid, (npStrNumPart+nPart), dvDelivery, 'OVDRATE', ppIntRate);
        INSERT INTO CDH
                    (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
        VALUES      (npAgrid, (npStrNumPart+nPart), dvDelivery, 'LOANFINE', vcPenyRate);
        INSERT INTO CDH
                      (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
        VALUES      (npAgrid, (npStrNumPart+nPart), dvDelivery, 'INTFINE', vcPenyRate2);
      end loop;
  end if;

    npStrNumPart := npStrNumPart+1;

    cpErrorMsg    := char_to_sap('OK');
    return;
  exception
    when others then
      cpErrorMsg    := char_to_sap(sqlerrm);
      return;
  END;


  procedure AddPart(
    npAgrid      in       number   -- Числовой номер договора
   ,dpEndDate    in       varchar2   -- Дата возврата
   --,dpEndDate    in       date   -- Дата возврата
   ,ipPart       in       number   -- номер части
   ,mpSum        in       number   -- Сумма части
   ,cpABS        in       varchar2 -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
   --,cpErrorMsg   in out   varchar2 -- Сообщение об ошибке
   ,cpErrorMsg  out       varchar2 -- Сообщение об ошибке
   --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                                  )
  is
    cnt         number:=0;-->>><<<Лобик Д.А. 05.03.2007 по с/з Некрасова А.В. от 26.02.2007
    vnABS       varchar2(2);-- (ubrr) Samokaev R.V. --- 22.12.2007 --
    dvEndDate   date;
  begin

/*-- (ubrr) Samokaev R.V. --- 22.12.2007 --(begin)
    IF cpABS = '0' THEN vnABS := '1';  END IF;
    IF cpABS = '4' THEN vnABS := '2';  END IF;

    XXI_CONTEXT.Set_IDSmr (vnABS);
-- (ubrr) Samokaev R.V. --- 22.12.2007 --(end)---*/
-- Рохин Е.А. 22.10.2010 Переход от вызова хранимых процедур к прямому вызову
  select decode( dpEndDate,
                 '00000000', null,
                 to_date(dpEndDate, 'YYYYMMDD')
               )
    into dvEndDate
    from DUAL;
-- Зуев А.А. 03.02.2009 № 5041-05/001797 ставим cpABS как текущий idSmr
  XXI_CONTEXT.Set_IDSmr (cpABS);

    ---->>>Лобик Д.А. 05.03.2007 по с/з Некрасова А.В. от 26.02.2007
    ---insert into cdr
    ---            (ncdragrid, icdrpart, dcdrdate, mcdrsum)
    ---values      (npAgrid, ipPart, dpEndDate, mpSum);

    begin--для оверов в cdr не надо ничего вставлять
        select count(*)
        into cnt
        from cda
        where cda.ncdaagrid=npAgrid
              and cda.icdaisline=1
              and icdalinetype=2 ---овердрафт
        ;
        if cnt = 0 then --наш договор - не является овердрафтом
            insert into cdr
                        (ncdragrid, icdrpart, dcdrdate, mcdrsum)
            values      (npAgrid, ipPart, dvEndDate, mpSum);
        end if;
    exception when others then
            null;
    end;
    ---<<<Лобик Д.А. 05.03.2007 по с/з Некрасова А.В. от 26.02.2007
    cpErrorMsg    := char_to_sap('OK');
    return;
  exception
    when others then
      cpErrorMsg    := char_to_sap( sqlerrm);
      return;
  end;

  function sap_2_char(ss in varchar2,ii in number)return varchar2
  is
  ret varchar2(4000):=ss;
  begin
/*       return(
              replace(
                      substr(ltrim(rtrim(char_convert.char_from_sap(ss))),1,ii)
                      ,lpad('0',ii,'0')
                      ,to_char(null)
              )
             );
*/
       ret:=substr(ltrim(rtrim(char_convert.char_from_sap(ss))),1,ii);
       if instr(ret,'0',1,length(ret))=0 then
           return(ret);
       else
           return(null);
       end if;
  end;

  procedure CreateNewZalog(
    npAgrid      in       number   -- Числовой номер договора
   ,dpDate       in       varchar2 -- Дата
   ,DpDsnDate    in       varchar2 -- Дата Решения
   ,iwarrantor   IN       varchar2 --
   ,ipType       in       number   -- Тип обеспечения из таблицы czv
   ,ipSubType    in       number   -- Подтип обеспечения из таблицы czw
   ,ipQuality    in       varchar2 -- number   -- Категория качества обеспечения (пустая, 1, 2)
   ,сpCur        in       varchar2 -- Валюта
   ,mpSum        in       number   -- Сумма части
   ,mpQSum       in       number   -- Сумма части минус издержки------->>>>><<<<<<<---
   ,mpMrktSum    in       number   -- Рыночная стоимость
   ,cNAME        in       varchar2 --------warrantor attributes
   ,cNAMEFULL    in       varchar2
   ,cINN         in       varchar2
   ,cKPP         in       varchar2
   ,cOKVED       in       varchar2
   ,cOKPO        in       varchar2
   ,cOGRN        in       varchar2
   ,cADDR        in       varchar2
   ,cADDR2       in       varchar2
   ,cPERSON      in       varchar2
   ,cPASPTYPE    in       varchar2
   ,cPASPNUM     in       varchar2
   ,cPASPSER     in       varchar2
   ,cPASPPLACE   in       varchar2
   ,dPASPDATE    in       varchar2
   ,cpComment    in       varchar2 -- Примечание к обеспечению
   ,cpPersname   in       varchar2 --
--> Зуев А.А. документ по обеспечению
   ,cpAgrNum     in       varchar2
   ,dpAgrDate    in       varchar2
   ,cpAgrAdrr    in       varchar2
--< Зуев А.А. документ по обеспечению
   ,cpABS        in       varchar2 -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
   --,cpErrorMsg   in out   varchar2 -- Сообщение об ошибке
   ,cpErrorMsg  out       varchar2 -- Сообщение об ошибке
   --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                                  )
  is
    IDCZO       number;
    IDCZH       number;
    IDCZHOPERATOR CZH.CCZHOPERATOR%TYPE;
    i_pType CZO.NCZOCZV%TYPE;
    i_pSubType CZO.NCZOCZW%TYPE;
    iipQuality  number;
    iiwarrantor number;
    num_cus     number := 0;
    d_PASPDATE  date :=null;
    vnABS       varchar2(2);-- (ubrr) Samokaev R.V. --- 22.12.2007 --
    ivCdhDocId  number;
    ivCdhType   number;
    ivCdhSchema number;
    dvDate      date;
    dvAgrDate   date;
    dvDsnDate   date;

  begin
    --->>>>>>>>>>>>>>
-- Рохин Е.А. 22.10.2010 Переход от вызова хранимых процедур к прямому вызову (begin)
  -- Преобразуем даты
    BEGIN
      select   decode( dpDate,    '00000000', null, to_date(dpDate,    'YYYYMMDD') ),
               decode( dpAgrDate, '00000000', null, to_date(dpAgrDate, 'YYYYMMDD') ),
               decode( dpDsnDate, '00000000', null, to_date(dpDsnDate, 'YYYYMMDD') )
        into dvDate,
             dvAgrDate,
             dvDsnDate
        from DUAL;
    EXCEPTION WHEN OTHERS THEN
        dvDate    := null;
        dvAgrDate := null;
        dvDsnDate := null;
    END;
-- Рохин Е.А. 22.10.2010 Переход от вызова хранимых процедур к прямому вызову (end)
    iipQuality :=to_number(ltrim(rtrim(ipQuality)));
-- (ubrr) Samokaev R.V. --- 13.02.2008 --(begin)---
    if ipType in (-1,2) then -- 1=имущество и 2=поручительство
--    if ipType in (1,2) then -- 1=имущество и 2=поручительство
-- (ubrr) Samokaev R.V. --- 13.02.2008 --(end)---
        iiwarrantor:=to_number(ltrim(rtrim(iwarrantor)));
        ivCdhType := 4;
        ivCdhSchema := 10;
    else-- 1=имущество
        iiwarrantor:=null;
        ivCdhType := 5;
        ivCdhSchema := 9;
    end if;
    --<<<<<<<<<<<<<<<<
   begin
    select  iabsczv, iabsczw into i_pType, i_pSubType FROM ubrr_cd_sap_zalog
    where ISAPTYPE = ipType AND ISAPSUBTYPE = ipSubType ;
   exception  when others then
      cpErrorMsg    := char_to_sap('Неверное заполнение таблиц связи залогов SAP <=> ABS');
      return;
    end;

/*-- (ubrr) Samokaev R.V. --- 22.12.2007 --(begin)---
  IF cpABS = '0' THEN vnABS := '1';  END IF;
  IF cpABS = '4' THEN vnABS := '2';  END IF;
--vnABS := '1';
  XXI_CONTEXT.Set_IDSmr (vnABS);
-- (ubrr) Samokaev R.V. --- 22.12.2007 --(end)---*/
-- Зуев А.А. 03.02.2009 № 5041-05/001797 ставим cpABS как текущий idSmr
  XXI_CONTEXT.Set_IDSmr (cpABS);

    -- В форме CDZO
    select S_CZO.nextval
    into   IDCZO
    from   sys.dual;
    --------->>>>>>>>>>>>>>
    num_cus:=null;
    if 1=0 then --iiwarrantor is not null and iiwarrantor<>0 then
        begin --добавляем поручителя-клиента в список поручителей

            SELECT S_CPOZ.NEXTVAL INTO num_cus FROM SYS.DUAL ;
/*            insert into CPOZ
            SELECT num_cus,null,null,null,null,null,null,null,null,null,null,null,
                   user, null,null,null,null,null,
                   0, null,null,null,null,null,null,null,null,null,
                   0,null,null,null,null,null,null,null,null,null,null,null,null,
                     null,null,null,null,null,null,null,null,null,null,null,null,
                   iiwarrantor
            FROM dual
            where not exists (select '*'
                              from cpoz
                              where icpozcusnum is not null
                                    and icpozcusnum=iiwarrantor
                             );
*/
           INSERT INTO cpoz (icpo   ,ccpozidopen,icpozcusnum,ncpozfwt)
           VALUES           (num_cus,       user,iiwarrantor,       0);
        exception when others then
           begin--видимо, этот клиент уже заведен как поручитель
              select icpo
              into num_cus
              from cpoz
              where icpozcusnum=iiwarrantor and icpozcusnum is not null;
           exception when others then
              num_cus:=null;
           end;
        end;
    elsif iiwarrantor is not null and iiwarrantor<>0 then
        begin--может быть, этот клиент уже заведен как поручитель
           select icpo
           into num_cus
           from cpoz
           where icpozcusnum=iiwarrantor and icpozcusnum is not null;
        exception when others then
            begin--добавляем нового поручителя-клиента в список поручителей
               SELECT S_CPOZ.NEXTVAL INTO num_cus FROM SYS.DUAL ;

               INSERT INTO cpoz (icpo   ,ccpozidopen,icpozcusnum,ncpozfwt)
               VALUES           (num_cus,       user,iiwarrantor,       0);
            exception when others then
               num_cus:=null;
            end;
        end;
    elsif iiwarrantor is not null and iiwarrantor=0 then--поручитель-неклиент
        num_cus:=null;
        begin--может быть, клиент с таки cNAMEFULL уже заведен как поручитель
           select icpo
           into num_cus
           from cpoz
           where upper(ltrim(rtrim(CCPONAME)))=upper(ltrim(rtrim(sap_2_char(cNAMEFULL,255))))
                 and ltrim(rtrim(CCPONAME)) is not null
                 and rownum=1;
        exception when others then
           num_cus:=null;
        end;
        if num_cus is null then--клиента с таки cNAMEFULL нет в поручителях
            if ltrim(rtrim(dPASPDATE))='00000000'then
              d_PASPDATE:=null;
            else
              d_PASPDATE:=to_date(ltrim(rtrim(dPASPDATE)),'YYYYMMDD');
            end if;
            SELECT S_CPOZ.NEXTVAL INTO num_cus FROM SYS.DUAL ;
            INSERT INTO  CPOZ
                  ( ICPO , CCPOZFLAG , CCPOZREZ , DCPOZOPEN , DCPOZEDIT
                   , NCPOZOKPO , CCPOZADDR , CCPOZPHONE1 , CCPOZPHONE2 , CCPOZPHONE3--2
                  , CCPOZFAMILY1 , CCPOZFAMILY2 , CCPOZIDOPEN , CCPONAME , CCPOZPRIM--3
                  , NCPOZTAXNUM , CCPOZNUMNAL , CCPOZENAME , NCPOZOTD , CCPOZCOATO
                  , CCPOZADDR_PHIS , CCPOZKSIVA , CCPOZIND , NCPOZOKONX , CCPOZKFC
                  , CCPOZFULLDOC , CCPOZCOUNTRY1 , CCPOZCOUNTRY2 , NCPOZFWT , CCPOZEMAIL
                  , CCPOZFAX , CCPOZWWW , CCPOZSOOGU , CCPOZKOPF , CCPOZPASSP_NUM
                  , CCPOZPASSP_SER , DCPOZPASSP , CCPOZPASSP_PLACE , CCPOZCLSB , CCPOZADDR_IND
                  , CCPOZADDR_CITY , CCPOZADDR_PUNCT , CCPOZADDR_STREET , CCPOZADDR_DOM , CCPOZADDR_KORP
                  , CCPOZADDR_KV , CCPOZADDR_PHIS_IND , CCPOZADDR_PHIS_CITY , CCPOZADDR_PHIS_PUNCT , CCPOZADDR_PHIS_STREET
                  , CCPOZADDR_PHIS_DOM , CCPOZADDR_PHIS_KORP , CCPOZADDR_PHIS_KV , ICPOZCUSNUM
                  )
             VALUES(num_cus,null,null,to_date(null),to_date(null)
                    ,sap_2_char(cOKPO,9),sap_2_char(cADDR,256),null,null,null--2
                    ,sap_2_char(cPERSON,255),null,user,sap_2_char(cNAMEFULL,255)--3
                      ,sap_2_char(cNAME,132)--3
                    ,null,sap_2_char(cINN,13),null,0,null--4
                    ,sap_2_char(cADDR2,256),null,null,null,null--5
                    ,null,null,null,0,null--6
                    ,null,null,null,null,sap_2_char(cPASPNUM,20)--7
                    ,sap_2_char(cPASPSER,10),d_PASPDATE--to_date(ltrim(rtrim(dPASPDATE)) ,'YYYYMMDD')--8
                      ,sap_2_char(cPASPPLACE,100),null,null--8
                    ,null,null,null,null,null
                    ,null,null,null,null,null
                    ,null,null,null,to_number(null)
                   );
        else--клиент с таки cNAMEFULL уже заведен как поручитель
            --обновим его данные
            update CPOZ
            set
                    NCPOZOKPO=sap_2_char(cOKPO,9)
                  , CCPOZADDR=sap_2_char(cADDR,256)--2
                  , CCPOZFAMILY1=sap_2_char(cPERSON,255)
                  , CCPOZIDOPEN=user
                  , CCPOZPRIM=sap_2_char(cNAME,132)--3
                  , CCPOZNUMNAL=sap_2_char(cINN,13)
                  , NCPOZOTD=0 --4
                  , CCPOZADDR_PHIS=sap_2_char(cADDR2,256)--5
                  , NCPOZFWT =0 --6
                  , CCPOZPASSP_NUM=sap_2_char(cPASPNUM,20)--7
                  , CCPOZPASSP_SER=sap_2_char(cPASPSER,10)
                  , DCPOZPASSP=d_PASPDATE
                  , CCPOZPASSP_PLACE=sap_2_char(cPASPPLACE,100)--8
            where ICPO=num_cus;
        end if;--if num_cus=null then
/*
    ,cKPP        IN VARCHAR2
    ,cOKVED      IN VARCHAR2
    ,cOKPO       IN VARCHAR2
    ,cOGRN       IN VARCHAR2
    ,cPASPTYPE   IN VARCHAR2
*/                   null;
    end if;

--> Зуев А.А. документ по обеспечению
    INSERT INTO cdh_doc
           (NCDHAGRID,ICDHTYPE,CCDHATRIBUT,DCDHREG,CCDHSHEMA,CCDHCOMM)
    VALUES (npAgrid, ivCdhType, char_convert.char_from_sap(cpAgrNum), dvAgrDate, ivCdhSchema, char_convert.char_from_sap(cpAgrAdrr))
    RETURNING icdhid into ivCdhDocId;
--< Зуев А.А. документ по обеспечению

    ----------<<<<<<<<<<<<<<<<<<<
    INSERT INTO CZO
                (ICZO, CCZOSCHET, NCZOAGRID, NCZOMAKRO
                , CCZOCOMMENT
                ,NCZOPEREOCENKA, NCZOPORUCH, NCZOCZV, NCZOCZW, CCZOCUR
                ,ICZOAUTOCORR, NCZOIDDOC, PCZOCOEFF, CCZOSECURACC
                ,NCZOCOEFFCORR
                ,NCZOZLG  -->>>><<<<--(добавлено) Samokaev R.V. --- 23.04.2008
                )--decode(iiwarrantor,0,null,iiwarrantor)
    VALUES      (IDCZO, null, npAgrid, null
-- (ubrr) (закоммент) Samokaev R.V. --- 13.02.2008 --(begin)--- для обработки залогодателей также как и поручителей
--                 ,decode(ipType,1 --залог только в комментарий по письму Некрасова А. от 22.03.06
--                                  ,substr(char_convert.char_from_sap(cpPersname)||' ('||char_convert.char_from_sap(cpComment)||')',1,1024)
                                  ,char_convert.char_from_sap( cpComment)
--                        )
-- (ubrr) (закоммент) Samokaev R.V. --- 13.02.2008 --(end)---

                ,null
-- (ubrr) (изменено) Samokaev R.V. --- 23.04.2008 --(begin)--- для обработки залогодателей и поручителей по правильному
                ,decode(ipType,2,num_cus,null)
--                num_cus
-- (ubrr) (изменено) Samokaev R.V. --- 23.04.2008 --(end)---
                ,i_pType, i_pSubType, сpCur--->><<--
                ,null, ivCdhDocId, null, null
                ,null
-- (ubrr) (добавлено) Samokaev R.V. --- 23.04.2008 --(begin)--- для обработки залогодателей и поручителей по правильному
                ,decode(ipType,1,iwarrantor,null)
-- (ubrr) (добавлено) Samokaev R.V. --- 23.04.2008 --(end)---
                );


    -->> 23.10.2019 Пинаев Д.Е. [19-67365] Разработка - TUTDF версии 6.01 (29.10.19)
    if i_pType = 225 then
    ubrr_bki_uid.SAVE_CZOPORUCH_UID(
        OP_NCZOAGRID  => npAgrid,
        OP_NCZOPORUCH => num_cus);
    end if;
    -->> 23.10.2019 Пинаев Д.Е. [19-67365] Разработка - TUTDF версии 6.01 (29.10.19)

    CDUTIL_ZO.Set_CZO_IPARAM(IDCZO, 'QUALITY', ipQuality, dvDate);

    SELECT S_CZH.nextval
    into   IDCZH
    from   sys.dual;

    SELECT USER
    INTO   IDCZHOPERATOR
    FROM   DUAL;

    INSERT INTO CZH
                (ICZH, CCZHOPERATOR, DCZHDATE, NCZHSUMMA, CCZHCOMMENT
                ,NCZHCZO, MCZHSUMLIQUID)
    VALUES      (IDCZH, IDCZHOPERATOR, dvDate, mpSum, 'Новое обеспечение'
                ,IDCZO, decode(mpQSum,0,mpSum,mpQSum));--->>>>>>><<<<<--

-- >>> Рохин Е.А. 06.02.2012 (12-345)
    if mpMrktSum is not null and mpMrktSum > 0 then
        insert into CZHM
                    ( NCZHMCZO, DCZHMDATE, MCZHMSUM, NCZHMBS )
        values      ( IDCZO,    dvDsnDate, mpMrktSum, 0 );

    end if;
-- <<< Рохин Е.А. 06.02.2012 (12-345)
    cpErrorMsg    := char_to_sap('OK');

    return;
  exception when others then
      cpErrorMsg    := char_to_sap('З: '||to_char(npAgrid)||to_char(iiwarrantor)||'-'||to_char(num_cus)|| sqlerrm);
--    cpErrorMsg    := char_to_sap(sqlerrm);
      return;
  end;


  ---->>>>>>Lobik D.A. ubrr 28.12.2005
  procedure CreateNewMaturity(
    npAgrid      in       number   -- Числовой номер договора
   ,mpSum        in       number   -- Сумма созврата
   ,dpDate       in       varchar2 -- Дата возврата
   -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
   --,cpErrorMsg   in out   varchar2 -- Сообщение об ошибке
   ,cpErrorMsg  out       varchar2 -- Сообщение об ошибке
   --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                                  )
  is
     cnt number:=0;-->>><<<Лобик Д.А. 05.03.2007 по с/з Некрасова А.В. от 26.02.2007
     dvDate date;
  begin
    ---->>>Лобик Д.А. 05.03.2007 по с/з Некрасова А.В. от 26.02.2007
    /*
      --if mpSum<0 then
         --delete from cdr where ncdragrid=npAgrid;
      --else
         --так сложно потому что могут быть повторения
         insert into cdr
         select npAgrid,1,dpDate,mpSum
         from dual
         where not exists (select '*'
                           from cdr
                           where ncdragrid=npAgrid
                                 and icdrpart=1
                                 and dcdrdate=dpDate
                          );
         --меняем сумму ранее заведенного возврата
         update cdr
         set mcdrsum=mpSum
         where ncdragrid=npAgrid
               and icdrpart=1
               and dcdrdate=dpDate;
    */
-- Рохин Е.А. 22.10.2010 Переход от вызова хранимых процедур к прямому вызову (begin)
    BEGIN
      select   decode( dpDate, '00000000', null, to_date(dpDate, 'YYYYMMDD') )
        into dvDate
        from DUAL;
    EXCEPTION WHEN OTHERS THEN
        dvDate := null;
    END;
-- Рохин Е.А. 22.10.2010 Переход от вызова хранимых процедур к прямому вызову (end)
    begin--для оверов в cdr не надо ничего вставлять
        select count(*)
        into cnt
        from cda
        where cda.ncdaagrid=npAgrid
              and cda.icdaisline=1
              and icdalinetype=2 ---овердрафт
        ;
        if cnt = 0 then --наш договор - не является овердрафтом
             --if mpSum<0 then
                --delete from cdr where ncdragrid=npAgrid;
             --else
             --так сложно потому что могут быть повторения
             insert into cdr
--             select npAgrid,1,dpDate,mpSum
             select npAgrid,1,dvDate,mpSum,dvDate
             from dual
             where not exists (select '*'
                               from cdr
                               where ncdragrid=npAgrid
                                     and icdrpart=1
                                     and dcdrdate=dvDate
                              );
             --меняем сумму ранее заведенного возврата
             update cdr
             set mcdrsum=mpSum
             where ncdragrid=npAgrid
                   and icdrpart=1
                   and dcdrdate=dvDate;
           /*--так нельзя,см. выше
             insert into cdr
                         (ncdragrid, icdrpart, dcdrdate, mcdrsum)
             values      (npAgrid  ,        1,   dpDate, mpSum);
          */
          --end if;
        end if;--if cnt = 0
    exception when others then
            null;
    end;
    ---<<<Лобик Д.А. 05.03.2007 по с/з Некрасова А.В. от 26.02.2007

      cpErrorMsg    := char_to_sap('OK');
      return;
  exception
    when others then
      cpErrorMsg    := char_to_sap('CreateNewMaturity: ' || sqlerrm);
      return;
  end;--CreateNewMaturity
  ----<<<<<Lobik D.A. ubrr 28.12.2005

  procedure Add_SchedPayPrc(
    npAgrid      in       number   -- Числовой номер договора
   ,dpDateClc    in       varchar2 -- Дата начисления %
   ,dpDatePay    in       varchar2 -- Дата уплаты %
   -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
   --,cpErrorMsg   in out   varchar2 -- Сообщение об ошибке
   ,cpErrorMsg  out       varchar2 -- Сообщение об ошибке
   --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                                  )
  is
      cnt       number:=0;
      dvDateClc date;
      dvDatePay date;
  begin
-- Рохин Е.А. 22.10.2010 Переход от вызова хранимых процедур к прямому вызову (begin)
  -- Преобразуем даты
    BEGIN
      select   decode( dpDateClc, '00000000', null, to_date(dpDateClc, 'YYYYMMDD') ),
               decode( dpDatePay, '00000000', null, to_date(dpDatePay, 'YYYYMMDD') )
        into dvDateClc,
             dvDatePay
        from DUAL;
    EXCEPTION WHEN OTHERS THEN
        dvDateClc := null;
        dvDatePay := null;
    END;
-- Рохин Е.А. 22.10.2010 Переход от вызова хранимых процедур к прямому вызову (end)
    select count(*) into cnt from CDS
     where NCDSAGRID = npAgrid and DCDSINTCALCDATE = dvDateClc;
    if cnt = 0 then
     insert into CDS (NCDSAGRID, DCDSINTCALCDATE, DCDSINTPMTDATE)
     values (npAgrid, dvDateClc, dvDatePay);
    end if;
    cpErrorMsg := char_to_sap('OK');
    return;
  exception
    when others then
      cpErrorMsg    := char_to_sap( sqlerrm);
      return;
  end;


  PROCEDURE calc_interval(npAgrid      in     number
                         ,dpFirstNach  in     date
                         ,dpFirstPay   in     date
                         ,spErrMessage in out varchar2)
  is

    LSdate      date :=CD.get_LSdate;--Текущая дата
    dStart      date; --Дата начала изменений (вначале дата начала договора)
    dFinish     date;
    tpDayOff    number:=1; -- учет праздничных дней
                            --  0 - не учитывать
                            --  -1 - сдвигать на ранее
                            --  1 - сдвигать на позже
    isCorDayOff number:=0; -- поведение при учете выходных дней
--

    dFirstN     date := dpFirstNach;
    dFirstPay   date := dpFirstPay;

    nn          number := 1;
    nnmax       number := 500;
    rm          number := 0;
    rd          number := 0;
    rdm         number := 0;
    rdc         number := 0;
    rm_N        number := 0;
    rd_N        number := 0;
    rdm_N       number := 0;
    rdc_N       number := 0;
    sm          number;
    dFirst      date;
    dFirst_N    date;
    dPay        date;
    dPay_N      date;

    Date_Choice number;
    Yes_No_Comm varchar2(100);

    FUNCTION getdPay(dFirst_F date, rd_F number,sm_F number,rdc_F number, rm_F number,rdm_F number)
    RETURN date IS
         dPay_F date;
         last_day_month date;
    BEGIN
                dPay_F := ADD_MONTHS(dFirst_F,rm_F)+rdm_F-1;
                last_day_month := LAST_DAY(ADD_MONTHS(dFirst_F,rm_F));
                if dPay_F > last_day_month then
                   dPay_F := last_day_month;
                end if;
        RETURN  dPay_F;
    END;-- getdPay()

  begin

    BEGIN
      Select dcdvENDDATE into dFinish from vcda where ncdvAGRID=npAgrid;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       dFinish := NULL;
    END;


  BEGIN
    Select dcdvSIGNDATE into dStart from vcda where ncdvAGRID=npAgrid;
    EXCEPTION
    WHEN OTHERS THEN
      dStart:=null;
  END;

  Date_Choice := 0;
  delete from cds where NCDSAGRID=npAgrid and DCDSINTCALCDATE>=dStart /*or DCDSINTPMTDATE>=dStart) Считаем, что окончание интервала зависит только от даты начисления!*/;

  nn  := 1;

  dFirst := TRUNC(dFirstPay,'MON');
  dFirst_N := TRUNC(dFirstN,'MON');
  sm := 1;

  rd  := dFirstPay-dFirst - 10*rdc;
  rm  := TRUNC(MONTHS_BETWEEN(dFirstPay,dFirst));
  rdm := to_number(to_char(dFirstPay,'DD'));

  rd_N  := dFirstN-dFirst_N - 10*rdc_N;
  rm_N  := TRUNC(MONTHS_BETWEEN(dFirstN, dFirst_N));
  rdm_N := to_number(to_char(dFirstN,'DD'));

--dbms_output.put_line('1');
--dbms_output.put_line(dFirstN);

  IF (dFirstN = LAST_DAY(dFirstN)) AND (rdm_N < 31) THEN
--       Yes_No_Comm := 'Считать дату первого начисления '||to_char(dFirstN,'DD.MM.YYYY')||' последним днем месяца?';
    rdm_N := 31;
  END IF;
--       Yes_No_Comm := 'Считать дату первой уплаты '||to_Char(dFirstPay,'DD.MM.YYYY')||' последним днем месяца?';
  IF (dFirstPay = LAST_DAY(dFirstPay)) AND (rdm < 31) THEN
    rdm := 31;
  END IF;

  <<loop_Pay>>
    LOOP
      dPay := getdPay(dFirst,rd,sm,rdc,rm,rdm);
      dPay_N := getdPay(dFirst_N,rd_N,sm,rdc_N,rm_N,rdm_N);

      dFirstN:=dPay_N;
      dFirstPay := dPay;
--dbms_output.put_line('2');
--dbms_output.put_line(dFirstN);
      WHILE not DJ_DATE.Is_Working_Day(dFirstPay) LOOP dFirstPay:=dFirstPay+1; END LOOP;

      if dFinish <= dFirstPay then
        dFirstPay := dFinish;
      end if;
      if dFinish <= dFirstN then
        dFirstN := dFinish;
      end if;

--dbms_output.put_line('3');
--dbms_output.put_line(dFirstN);

      IF isCorDayOff=1 THEN dFirstN:=dFirstPay; END IF;
--msg(to_char(dPay)||' '||cc||' to->'||to_char(dFirstN)||' pay->'||to_char(dFirstPay));

      IF dFirstN>=dStart and dFirstPay>=dStart THEN
        INSERT INTO cds (ncdsAGRID, dcdsINTCALCDATE, dcdsINTPMTDATE)
          VALUES ( npAgrid, dFirstN, dFirstPay);
      END IF;

      IF dFirstN>=dFinish /*OR dFirstPay>=dFinish*/ THEN
        EXIT;
      END IF;
        -- шаг цикла
      IF nn >= nnmax THEN
        spErrMessage :='Прерывание по ограничению на количество платежей (>500)!';
        EXIT;
      ELSE
        nn:=nn+1;
           dFirst := ADD_MONTHS(dFirst,sm);
           dFirst_N := ADD_MONTHS(dFirst_N,sm);
      END IF;

    END LOOP;-- loop_Pay;

  exception
    when others then
      null;
  end;

--Портнягин Д.Ю. Признак согласия заемщика на запрос в БКИ
 PROCEDURE Change_BKI_REQUEST ( ipAgrId   in number,
                                is_IN_BKI in varchar2,
                                dpCrIn    in varchar2,
                                cpABS     in varchar2,
                                -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                                --cpErrMsg   in out   varchar2 -- Сообщение об ошибке
                                cpErrMsg  out       varchar2 -- Сообщение об ошибке
                                --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
 )
 is
    cvLastIdSmr  smr.idsmr%type;
    cvErrMsg     varchar2(1024):='OK';
    dvCrIn       date;
    LOCKED EXCEPTION;
    PRAGMA EXCEPTION_INIT(LOCKED, -54);
 begin
   cvLastIdSmr := ubrr_get_context;
   XXI_CONTEXT.Set_IDSmr (cpABS);
   begin
       select decode( dpCrIn , '00000000', null, to_date(dpCrIn , 'YYYYMMDD') )
        into dvCrIn
        from dual;
   exception when others then
       dvCrIn := null;
   end;
   begin
      if dvCrIn is not null then
         cdterms.Update_History(ipAgrId, 1, 'UBRR_BKI', dvCrIn, null, null, null, is_IN_BKI);
      else
         delete cdh
          where ncdhAGRID=ipAgrId
            AND icdhPART=1
            AND ccdhTERM='UBRR_BKI';
      end if;
   exception
   when no_data_found then
      cvErrMsg := 'Договор №'||ipAgrId||' не обнаружен';
   when locked then
      cvErrMsg:= 'Договор №'||ipAgrId||' заблокирован';
   end;
   XXI_CONTEXT.Set_IDSmr (cvLastIdSmr);
   cpErrMsg := char_to_sap(cvErrMsg);
 exception when others then
   cpErrMsg := char_to_sap(sqlerrm);
   return;
 end;

-- Зуев А.А. согласие клиента на БКИ
  PROCEDURE Change_CrInfo (ipAgrId  in      number,
                           ipCrOut  in      number,
                           dpCrOut  in      varchar2,
                          --dpCrOut   in      date,
                           cpBKIId  in      varchar2,
                           cpAbs    in      varchar2,
                           -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                           --,cpErrMsg   in out   varchar2 -- Сообщение об ошибке
                           cpErrMsg  out       varchar2 -- Сообщение об ошибке
                           --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                           )
  is
    ivExists     number;
    cvIdSmr      varchar2(3);
    cvLastIdSmr  varchar2(3);
    cvErrMsg     varchar2(1024):='OK';
    cvBKIId      varchar2(32);
    cvCrOut      varchar2(1);
    dvCrOut      date;
    LOCKED EXCEPTION;
    PRAGMA EXCEPTION_INIT(LOCKED, -54);
  begin
/*    if cpABS = '0' THEN
       cvIdSmr := '1';
    elsif cpABS = '4' THEN
       cvIdSmr := '2';
    END IF;*/

    if ipCrOut = 1 then
        cvCrOut := '1';
        -- Рохин Е.А. 22.10.2010 Переход от вызова хранимых процедур к прямому вызову
        --dvCrOut := dpCrOut;
        dvCrOut := to_date(dpCrOut, 'YYYYMMDD');
        cvBKIId := char_convert.char_from_sap(cpBKIId);
    else
        cvCrOut := '0';
        dvCrOut := NULL;
        cvBKIId := NULL;
    end if;

    cvLastIdSmr := ubrr_get_context;
-- Зуев А.А. 03.02.2009 № 5041-05/001797 ставим cpABS как текущий idSmr
    XXI_CONTEXT.Set_IDSmr (cpABS);

    begin
        select 1
          into ivExists
          from cda
         where ncdaagrid = ipAgrId
         FOR UPDATE NOWAIT;
        update cda
           set ccdacrinfo = cvCrOut, --согласие сообщать в БКИ
               dcdacrinfdate = dvCrOut, --дата согласия
               ccdacrinfocode = cvBKIId --код субъекта кредитной истории
         where ncdaagrid = ipAgrId;
        if dvCrOut is not null then
            cdterms.Update_History(ipAgrId, 1, 'CDCRINF' , dvCrOut, null, null, null, cvBKIId);
        else
            delete cdh
             where ncdhAGRID=ipAgrId
               AND icdhPART=1
               AND ccdhTERM in ('CDCRINF'); --, 'AGR_NBKI', 'AGR_OKB', 'AGR_EQV'); -->><< Рохин Е.А. 01.08.2016
        end if;
-->> Рохин Е.А. 01.08.2016 пишем только если ничего нет
        begin
            select 1
                into ivExists
                from xxi.cdh
                where ncdhagrid = ipAgrId
                and   ccdhterm = 'AGR_NBKI';
        exception when no_data_found then
            cdterms.Update_History(ipAgrId, 1, 'AGR_NBKI', dvCrOut, null, null, 1,    null);
        end;
        begin
            select 1
                into ivExists
                from xxi.cdh
                where ncdhagrid = ipAgrId
                and   ccdhterm = 'AGR_OKB';
        exception when no_data_found then
            cdterms.Update_History(ipAgrId, 1, 'AGR_OKB', dvCrOut, null, null, 1,    null);
        end;
        begin
            select 1
                into ivExists
                from xxi.cdh
                where ncdhagrid = ipAgrId
                and   ccdhterm = 'AGR_EQV';
        exception when no_data_found then
            cdterms.Update_History(ipAgrId, 1, 'AGR_EQV', dvCrOut, null, null, 1,    null);
        end;
--<< Рохин Е.А. 01.08.2016 пишем только если ничего нет
    exception when no_data_found then
        cvErrMsg := 'Договор №'||ipAgrId||' не обнаружен';
              when locked then
        cvErrMsg := 'Договор №'||ipAgrId||' заблокирован';
    end;
    XXI_CONTEXT.Set_IDSmr (cvLastIdSmr);
    cpErrMsg := char_to_sap(cvErrMsg);
    return;
  exception when others then
    cpErrMsg := char_to_sap(sqlerrm);
    return;
  end;

--Рохин Е. Передача Ответственного за ведение кредита
  procedure Change_CuratorID (npAgrid      in       number,     -- Числовой номер договора)
                              npCuratorID  in       number,     -- ID Куратора
                              -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                              --cpErrorMsg   in out   varchar2 -- Сообщение об ошибке
                              cpErrorMsg  out       varchar2 -- Сообщение об ошибке
                              --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                              )
  is
      cnt number:=0;
  begin
    update xxi."cda" set   NCDACURATORID = npCuratorID
                     where NCDAAGRID     = npAgrid;
    commit;
    cpErrorMsg := char_to_sap('OK');
    return;
  exception when others then
    cpErrorMsg    := char_to_sap(sqlerrm);
    return;
  end;

  --->>>ubrr Кожевников Е.А. 2010/03/23 10-301 (Рохин Е.А.)
  ----------------------------------------------------------------------------------------------
  -- Функция определения техн. номера договора ЗА дату (учитывает пролонгации и возвращает призак корректности определения)
  -- c_IsCorrect = NULL , если техн. номер определен однозначно
  -- c_IsCorrect = 'X'  , если все пролонгации и родительский договор закрыты

   PROCEDURE Get_AgrID (i_agr       in  number,
                        onDate      in  date,
                        i_is_line   in  number,
                        n_agrnum    OUT xxi.cda.ncdaagrid%type,
                        c_IsCorrect OUT char)
   IS
      --n_pcdhpval xxi.cdh.pcdhpval%type:=0;
      v_i    PLS_INTEGER := 0;
   BEGIN
     c_IsCorrect := NULL;
     n_agrnum := 0;
     FOR r_cdh IN (
        SELECT a.ncdaagrid, a.icdastatus,
                    sign(nvl(cdbalance.get_cursaldo (a.ncdaagrid,
                                               1, -- основная задолженность
                                               NULL, --IPART
                                               NULL,
                                               onDate -- за дату
                                              ),0)
                       + nvl(cdbalance.get_cursaldo (a.ncdaagrid,
                                               5, -- просроченная задолженность
                                               NULL,--IPART
                                               NULL,
                                               onDate -- за дату
                                              ),0)
                  )
              debt,
              sign((
              select nvl(sum(decode(icdetype,65,mcdesum,66,-mcdesum)),0)
                from cde
               where cde.icdetype in (65,66)
                 and cde.ncdeagrid = a.ncdaagrid
                 and cde.dcdedate <= onDate)
               )
               lim,
                    (select nvl(pcdhpval,0)
                from   xxi.cdh
                where      ncdhagrid = a.ncdaagrid
                       --and icdhpart  = i_tranche
                       and ccdhterm  = 'INTRATE'
                       and dcdhdate  =(select max(h.dcdhdate)
                                       from xxi.cdh h
                                       where h.ncdhagrid=a.ncdaagrid
                                           --and h.icdhpart = i_tranche
                                           and h.ccdhterm = 'INTRATE'
                                           and h.dcdhdate <= onDate
                                    )
                    and rownum=1) pcdhpval

        FROM xxi."cda" a
        WHERE --trunc(a.ncdaagrid) = trunc(i_agr)
              a.ncdaagrid BETWEEN trunc(i_agr) AND trunc(i_agr)+0.99
          AND a.icdastatus = 2 -- только незавершенные пролонгации
          AND a.icdaisline between nvl(i_is_line, 0) and 1
        ORDER BY debt desc, lim desc, ncdaagrid desc
     ) LOOP
        IF v_i = 0 THEN
          n_agrnum := r_cdh.ncdaagrid;
          v_i := v_i + 1;
          EXIT;
        END IF;
     END LOOP;

     IF v_i = 0 THEN
       c_IsCorrect := 'X'; -- все пролонгации закрыты
     END IF;

   EXCEPTION
      WHEN others THEN
          c_IsCorrect := NULL;
          n_agrnum := -1;
   END Get_AgrID;
  ---<<<ubrr Кожевников Е.А. 2010/03/23 10-301 (Рохин Е.А.)

  --->>>ubrr Некрасов А.В. 2010/12/06 10-876
  /* При выдаче первого транша с условием уплаты % авансом
     нужно расчистить график начисления/уплаты % начиная с даты подписания договора
     по дату начисления %, которая <= периода уплаты % авансом
  */
   procedure Clear_SchedPayPrcForAdvance(npAgrid                 in     number
                                        ,dSAPDayOfPay            in     varchar2
                                        --День первой уплаты %
                                        ,dSAPDayOfPrc            in     varchar2
                                        --День начисления % авансом (по)
                                        -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                                        --,cpErrorMsg   in out   varchar2 -- Сообщение об ошибке
                                        ,cpErrorMsg  out       varchar2 -- Сообщение об ошибке
                                        --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                                        )
   IS
    dDayOfPay           date; --День первой уплаты %
    dDayOfPrc           date; --День начисления % авансом (по)
   BEGIN
    BEGIN
      select   decode( dSAPDayOfPrc, '00000000', null, to_date(dSAPDayOfPrc, 'YYYYMMDD') )
        into dDayOfPrc
        from DUAL;
     EXCEPTION WHEN OTHERS THEN
       dDayOfPrc := null;
    END;
    BEGIN
      select   decode( dSAPDayOfPay, '00000000', null, to_date(dSAPDayOfPay, 'YYYYMMDD') )
        into dDayOfPay
        from DUAL;
     EXCEPTION WHEN OTHERS THEN
       dDayOfPay := null;
    END;
     BEGIN
       update CDS
           SET DCDSINTPMTDATE =  dDayOfPay
           where NCDSAGRID = npAgrid
             and DCDSINTCALCDATE <= dDayOfPrc
       ;
       cpErrorMsg := char_to_sap('OK');
       return;
      EXCEPTION
       WHEN NO_DATA_FOUND THEN
        cpErrorMsg := char_to_sap('OK');
     END;

    exception
     when others then
      cpErrorMsg    := char_to_sap( sqlerrm);
      return;

   END Clear_SchedPayPrcForAdvance;
  ---<<<ubrr Некрасов А.В. 2010/12/06 10-876

  --->>>ubrr Некрасов А.В. 2011/01/24 11-206.2
  /* Создание записи в графике изменения лимита
     (если дата 00000000 - удаляются все записи в графике,
      если дата разумная - добавляется новая запись)
  */
   procedure Add_SchedLim(
       npAgrid      in       number   -- Числовой номер договора
      ,dpDateLim    in       varchar2 -- Дата записи графика изменения лимита
      ,npAmountLim  in       number   -- Величина лимита с даты
      -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
      --,cpErrorMsg   in out   varchar2 -- Сообщение об ошибке
      ,cpErrorMsg  out       varchar2 -- Сообщение об ошибке
      --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                       )
   IS
    dDayOfLim           date; --Дата записи графика изменения лимита
   BEGIN
     if dpDateLim = '00000000' then
--     Удалим все записи типа 'LIMIT'
       BEGIN
         delete CDH where ncdhagrid = npAgrid and icdhpart = 1 and ccdhterm = 'LIMIT';

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             cpErrorMsg := char_to_sap('OK');
       END;
       cpErrorMsg := char_to_sap('OK');
     else
--     Добавим новую запись типа 'LIMIT'
       BEGIN
         select   decode( dpDateLim, '00000000', null, to_date(dpDateLim, 'YYYYMMDD') )
           into dDayOfLim
           from DUAL;
        EXCEPTION WHEN OTHERS THEN
          dDayOfLim := null;
       END;

       CD.Update_History(npAgrid, 1, 'LIMIT' , dDayOfLim, npAmountLim, null, null, null);

       cpErrorMsg := char_to_sap('OK');
     end if;

     exception
       when others then
         cpErrorMsg    := char_to_sap( sqlerrm);
         return;
   END Add_SchedLim;
  ---<<<ubrr Некрасов А.В. 2011/01/24 11-206.2
  -- >>> Рохин Е.А. 01.11.2011 (11-859)
  --    Процедура отправки SMS
   PROCEDURE Send_SMS
                (
                 cpSMS_Phone IN     varchar2                 --Номер телефона получателя (например,79226093222)
                ,cpSMS_Body  IN     varchar2                 --Текст сообщения до 1000 символов
                -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                --,cpErrorMsg  IN OUT varchar2                 -- Сообщение об ошибке
                --,cpSMS_Time  IN OUT varchar2                 -- Время создания сообщения
                ,cpErrorMsg OUT varchar2                 -- Сообщение об ошибке
                ,cpSMS_Time OUT varchar2                 -- Время создания сообщения
                --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                -->> 08.07.2020 Пылаев Е.А [19-59018] Разделение отправки СМС- E-Mail-уведомлений УБРиР и ВУЗ
                ,npVuz       IN     number default 0
                --<< 08.07.2020 Пылаев Е.А [19-59018] Разделение отправки СМС- E-Mail-уведомлений УБРиР и ВУЗ
                )
   IS
        cvSMS_Body  VARCHAR2(1000);
        cvSMS_Time  ubrr_shm_tab_sms.DSMS_CREATE%type;
   BEGIN
        cvSMS_Body := sap_2_char(cpSMS_Body,1000);
        begin
            -->> 08.07.2020 Пылаев Е.А [19-59018] Разделение отправки СМС- E-Mail-уведомлений УБРиР и ВУЗ
            if npVuz = 1 then
               UBRR_SEND.Send_SMS(cpSMS_Phone,cvSMS_Body,9);
            else
                UBRR_SEND.Send_SMS(cpSMS_Phone,cvSMS_Body);
            end if;
            --UBRR_SEND.Send_SMS(cpSMS_Phone,cvSMS_Body);
            --<< 08.07.2020 Пылаев Е.А [19-59018] Разделение отправки СМС- E-Mail-уведомлений УБРиР и ВУЗ
            begin
                select DSMS_CREATE into cvSMS_Time
                    from ubrr_shm_tab_sms
                    where CSMS_PHONE = cpSMS_Phone
                      and CSMS_BODY  = cvSMS_Body
                      and CSMS_USER  = 'T_SAPLINK';
            exception
                when others then
                    cpErrorMsg := char_to_sap('SMS не передана');
                    cpSMS_Time := to_char(sysdate,'HH24MISS');
                    return;
            end;
            cpErrorMsg := char_to_sap('OK');
            cpSMS_Time := to_char(cvSMS_Time,'HH24MISS');
        exception
            when others then
                cpErrorMsg := char_to_sap( sqlerrm);
                cpSMS_Time := to_char(sysdate,'HH24MISS');
        end;
   END Send_SMS;
-- Отправка почты через внешний маршрутизатор
   PROCEDURE SEND_MAIL
     (
       Adres        IN      VARCHAR2  -- Адрес получателя сообщения 50
      ,Subject      IN      VARCHAR2  -- Тема сообщения 50
      ,Message      IN      VARCHAR2  -- Сообщение  2000
      ,cpErrorMsg   IN OUT  varchar2  -- Сообщение об ошибке
      ,cpEMAIL_Time IN OUT  varchar2  -- Время создания сообщения
      -->> 08.07.2020 Пылаев Е.А [19-59018] Разделение отправки СМС- E-Mail-уведомлений УБРиР и ВУЗ
      ,npVuz       IN     number default 0
      --<< 08.07.2020 Пылаев Е.А [19-59018] Разделение отправки СМС- E-Mail-уведомлений УБРиР и ВУЗ
      )
   IS
        cvMAIL_Adres    VARCHAR2(50);
        cvMAIL_Subject  VARCHAR2(50);
        cvMAIL_Body     VARCHAR2(2000);
        cvMAIL_Time    ABRR_MAIL.DDAT%type;
   BEGIN
        cvMAIL_Adres    := sap_2_char(Adres,   50  );
        cvMAIL_Subject  := sap_2_char(Subject, 50  );
        cvMAIL_Body     := sap_2_char(Message, 2000);
        begin
             -->> 08.07.2020 Пылаев Е.А [19-59018] Разделение отправки СМС- E-Mail-уведомлений УБРиР и ВУЗ
            if npVuz = 1 then
                UBRR_SEND.SET_VUZ(1);
            else
                UBRR_SEND.SET_VUZ(null);
            end if;
            --<< 08.07.2020 Пылаев Е.А [19-59018] Разделение отправки СМС- E-Mail-уведомлений УБРиР и ВУЗ
            UBRR_SEND.Send_MAIL(cvMAIL_Adres,cvMAIL_Subject, cvMAIL_Body);
            begin
                select DDAT into cvMAIL_Time
                    from ABRR_MAIL
                    where C_MAIL    = cvMAIL_Adres
                      and C_SUBJECT = cvMAIL_Subject
                      and CMSG      = cvMAIL_Body
                      and CUSR      = 'T_SAPLINK';
            exception
                when others then
                    cpErrorMsg   := char_to_sap('Сообщение не передано');
                    cpEMAIL_Time := to_char(sysdate,'HH24MISS');
                    return;
            end;
            cpErrorMsg   := char_to_sap('OK');
            cpEMAIL_Time := to_char(cvMAIL_Time,'HH24MISS');
        exception
            when others then
                cpErrorMsg   := char_to_sap( sqlerrm);
                cpEMAIL_Time := to_char(sysdate,'HH24MISS');
        end;
   END SEND_MAIL;
   PROCEDURE Change_SMS_Agr (ipAgrId     in      number,
                             dpSMS_AGR   in      varchar2,
                             cpSMS_AGR   in      varchar2,
                             cpSMS_INF   in      varchar2,
                             cpEMAIL_AGR in      varchar2,
                             cpEMAIL_INF in      varchar2,
                             -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                             --cpErrMsg   in out   varchar2 -- Сообщение об ошибке
                             cpErrMsg  out       varchar2 -- Сообщение об ошибке
                             --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                             )
   IS
        cvSMS_AGR   number;
        cvSMS_INF   varchar2(11);
        cvEMAIL_AGR number;
        cvEMAIL_INF varchar2(50);
        dvSMS_AGR   date;
   BEGIN
        cpErrMsg := char_to_sap( 'OK' );
-- Признак согласия на SMS-информирование
        begin
            select icdhival, dcdhDATE into cvSMS_AGR, dvSMS_AGR from cdh
                where ncdhAGRID = ipAgrId
                  and icdhPART  = 1
                  and ccdhTERM  = 'UBRRSMSA'
                  and rownum    = 1
            order by dcdhDATE desc;
        exception when others then
            cvSMS_AGR := null;
            dvSMS_AGR := null;
        end;
        if cvSMS_AGR is null then
                   INSERT INTO CDH(ncdhAGRID
                                 , icdhPART
                                 , dcdhDATE
                                 , ccdhTERM
                                 , ICDHIVAL)
                       VALUES ( ipAgrid
                              , 1
                              , to_date(dpSMS_AGR, 'YYYYMMDD')
                              , 'UBRRSMSA'
                              , decode(cpSMS_AGR, 'Y', 1, 0)
                               );
        else
          if ( nvl(cvSMS_AGR, 2) = 1 and cpSMS_AGR = 'N' )
                or
             ( nvl(cvSMS_AGR, 2) = 0 and cpSMS_AGR = 'Y' ) then
            begin
                if to_char(nvl(dvSMS_AGR, to_date('01.01.0001', 'DD.MM.YYYY')), 'YYYYMMDD') <> dpSMS_AGR then
                   INSERT INTO CDH(ncdhAGRID
                                 , icdhPART
                                 , dcdhDATE
                                 , ccdhTERM
                                 , ICDHIVAL)
                       VALUES ( ipAgrid
                              , 1
                              , to_date(dpSMS_AGR, 'YYYYMMDD')
                              , 'UBRRSMSA'
                              , decode(cpSMS_AGR, 'Y', 1, 0)
                               );
                else
                   UPDATE cdh SET ICDHIVAL = decode(cpSMS_AGR, 'Y', 1, 0)
                        WHERE ncdhAGRID = ipAgrid
                          AND icdhPART  = 1
                          AND dcdhDATE  = dvSMS_AGR
                          AND ccdhTERM  = 'UBRRSMSA';
                end if;
            EXCEPTION WHEN OTHERS THEN
               cpErrMsg := char_to_sap( sqlerrm);
               return;
            end;
          end if;
        end if;
-- Телефон для SMS-информирования
        begin
            select ccdhcval, dcdhDATE into cvSMS_INF, dvSMS_AGR from cdh
                where ncdhAGRID = ipAgrId
                  and icdhPART  = 1
                  and ccdhTERM  = 'UBRR_SMS'
                  and rownum    = 1
            order by dcdhDATE desc;
        exception when others then
            cvSMS_INF := null;
            dvSMS_AGR := null;
        end;
        if dvSMS_AGR is null then
                   INSERT INTO CDH(ncdhAGRID
                                 , icdhPART
                                 , dcdhDATE
                                 , ccdhTERM
                                 , CCDHCVAL)
                       VALUES ( ipAgrid
                              , 1
                              , to_date(dpSMS_AGR, 'YYYYMMDD')
                              , 'UBRR_SMS'
                              , char_convert.char_from_sap(cpSMS_INF)
                               );
        else
          if nvl(cvSMS_INF,'') <> char_convert.char_from_sap(cpSMS_INF) then
            begin
                if to_char(nvl(dvSMS_AGR, to_date('01.01.0001', 'DD.MM.YYYY')), 'YYYYMMDD') <> dpSMS_AGR then
                   INSERT INTO CDH(ncdhAGRID
                                 , icdhPART
                                 , dcdhDATE
                                 , ccdhTERM
                                 , CCDHCVAL)
                       VALUES ( ipAgrid
                              , 1
                              , to_date(dpSMS_AGR, 'YYYYMMDD')
                              , 'UBRR_SMS'
                              , char_convert.char_from_sap(cpSMS_INF)
                               );
                else
                   UPDATE cdh SET CCDHCVAL = char_convert.char_from_sap(cpSMS_INF)
                        WHERE ncdhAGRID = ipAgrid
                          AND icdhPART  = 1
                          AND dcdhDATE  = dvSMS_AGR
                          AND ccdhTERM  = 'UBRR_SMS';
                end if;
            EXCEPTION WHEN OTHERS THEN
               cpErrMsg := char_to_sap( sqlerrm);
               return;
            end;
          end if;
        end if;
-- Признак согласия на E-mail-информирование
        begin
            select icdhival, dcdhDATE into cvEMAIL_AGR, dvSMS_AGR from cdh
                where ncdhAGRID = ipAgrId
                  and icdhPART  = 1
                  and ccdhTERM  = 'UBRREMLA'
                  and rownum    = 1
            order by dcdhDATE desc;
        exception when others then
            cvEMAIL_AGR := null;
            dvSMS_AGR := null;
        end;
        if cvEMAIL_AGR is null then
                   INSERT INTO CDH(ncdhAGRID
                                 , icdhPART
                                 , dcdhDATE
                                 , ccdhTERM
                                 , ICDHIVAL)
                       VALUES ( ipAgrid
                              , 1
                              , to_date(dpSMS_AGR, 'YYYYMMDD')
                              , 'UBRREMLA'
                              ,decode(cpEMAIL_AGR, 'Y', 1, 0)
                               );
        else
          if ( nvl(cvEMAIL_AGR, 2) = 1 and cpEMAIL_AGR = 'N' )
                or
             ( nvl(cvEMAIL_AGR, 2) = 0 and cpEMAIL_AGR = 'Y' )
          then
            begin
                if to_char(nvl(dvSMS_AGR, to_date('01.01.0001', 'DD.MM.YYYY')), 'YYYYMMDD') <> dpSMS_AGR then
                   INSERT INTO CDH(ncdhAGRID
                                 , icdhPART
                                 , dcdhDATE
                                 , ccdhTERM
                                 , ICDHIVAL)
                       VALUES ( ipAgrid
                              , 1
                              , to_date(dpSMS_AGR, 'YYYYMMDD')
                              , 'UBRREMLA'
                              ,decode(cpEMAIL_AGR, 'Y', 1, 0)
                               );
                else
                   UPDATE cdh SET ICDHIVAL = decode(cpEMAIL_AGR, 'Y', 1, 0)
                        WHERE ncdhAGRID = ipAgrid
                          AND icdhPART  = 1
                          AND dcdhDATE  = dvSMS_AGR
                          AND ccdhTERM  = 'UBRREMLA';
                end if;
            EXCEPTION WHEN OTHERS THEN
               cpErrMsg := char_to_sap( sqlerrm);
               return;
            end;
          end if;
        end if;
-- Адрес эл.почты для E-mail-информирования
        begin
            select ccdhcval, dcdhDATE into cvEMAIL_INF, dvSMS_AGR from cdh
                where ncdhAGRID = ipAgrId
                  and icdhPART  = 1
                  and ccdhTERM  = 'UBRR_EML'
                  and rownum    = 1
            order by dcdhDATE desc;
        exception when others then
            cvEMAIL_INF := null;
            dvSMS_AGR := null;
        end;
        if dvSMS_AGR is null then
                   INSERT INTO CDH(ncdhAGRID
                                 , icdhPART
                                 , dcdhDATE
                                 , ccdhTERM
                                 , CCDHCVAL)
                       VALUES ( ipAgrid
                              , 1
                              , to_date(dpSMS_AGR, 'YYYYMMDD')
                              , 'UBRR_EML'
                              , char_convert.char_from_sap(cpEMAIL_INF)
                               );
        else
          if nvl(cvEMAIL_INF,'') <> char_convert.char_from_sap(cpEMAIL_INF) then
            begin
                if to_char(nvl(dvSMS_AGR, to_date('01.01.0001', 'DD.MM.YYYY')), 'YYYYMMDD') <> dpSMS_AGR then
                   INSERT INTO CDH(ncdhAGRID
                                 , icdhPART
                                 , dcdhDATE
                                 , ccdhTERM
                                 , CCDHCVAL)
                       VALUES ( ipAgrid
                              , 1
                              , to_date(dpSMS_AGR, 'YYYYMMDD')
                              , 'UBRR_EML'
                              , char_convert.char_from_sap(cpEMAIL_INF)
                               );
                else
                   UPDATE cdh SET CCDHCVAL = char_convert.char_from_sap(cpEMAIL_INF)
                        WHERE ncdhAGRID = ipAgrid
                          AND icdhPART  = 1
                          AND dcdhDATE  = dvSMS_AGR
                          AND ccdhTERM  = 'UBRR_EML';
                end if;
            EXCEPTION WHEN OTHERS THEN
               cpErrMsg := char_to_sap( sqlerrm);
               return;
            end;
          end if;
        end if;
   END Change_SMS_Agr;
-- >>> Рохин Е.А. 01.11.2011 (11-859)
  --->>>ubrr Некрасов А.В. 2011/11/15 11-484
  /* Добавление атрибута "Ответственное подразделение ДР" для Клиента  */
   procedure Add_Atr_Cus_From_Sap(
       npCus        in       number   -- Номер клиента
      ,npIDAtr      in       number   -- ID атрибута
      ,сpAtrVal     in       varchar2 -- Значение атрибута
      ,dpAtrDate    in       varchar2 -- Дата начала действия атрибута
      ,cpResult     out      varchar2 -- Сообщение об ошибке
                                  )
   IS
     cvATR    VARCHAR2(50);
   BEGIN
     BEGIN
       cpResult := char_to_sap(
         ubrr_xxi5.atr_util.add_atr_cus(npCus,npIDAtr,char_convert.char_from_sap(сpAtrVal),to_date(dpAtrDate,'YYYYMMDD'))
       )
      ;
      EXCEPTION WHEN OTHERS THEN
       cpResult := char_to_sap( sqlerrm);
       return;
     END;
   END Add_Atr_Cus_From_Sap;
  /* Добавление атрибута "Методика ДР" для кр. договора  */
   procedure Add_Atr_Gr_From_Sap(
       npAgr        in       number   -- Номер кр. договора
      ,npIDAtr      in       number   -- ID атрибута
      ,сpAtrVal     in       varchar2 -- Значение атрибута
      ,cpResult     out      varchar2 -- Сообщение об ошибке
                                  )
   IS
   BEGIN
     BEGIN
       cpResult := char_to_sap( ubrr_xxi5.atr_util.add_atr_gr(npAgr,npIDAtr,char_convert.char_from_sap(сpAtrVal)) );
      EXCEPTION WHEN OTHERS THEN
       cpResult := char_to_sap( sqlerrm);
       return;
     END;
   END Add_Atr_Gr_From_Sap;
  ---<<<ubrr Некрасов А.В. 2011/11/15 11-484
  --->>>ubrr Некрасов А.В. 2013/03/06 12-965
-- дата фактического подписания договора
  PROCEDURE Change_AGRSIGNDATE ( ipAgrId   in number,
                                dpSignDate    in varchar2,
                                cpABS     in varchar2,
                                -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                                --cpErrMsg   in out   varchar2 -- Сообщение об ошибке
                                cpErrMsg  out       varchar2 -- Сообщение об ошибке
                                --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                               )
 is
    cvLastIdSmr  smr.idsmr%type;
    LOCKED EXCEPTION;
    PRAGMA EXCEPTION_INIT(LOCKED, -54);
 begin
   cpErrMsg :=char_to_sap('OK');
   cvLastIdSmr := ubrr_get_context;
   XXI_CONTEXT.Set_IDSmr (cpABS);
   update xxi."cda"
         set DCDASIGNDATE2 = decode( dpSignDate , '00000000', null, to_date(dpSignDate , 'YYYYMMDD') )
         where NCDAAGRID = ipAgrId
         ;
   XXI_CONTEXT.Set_IDSmr (cvLastIdSmr);
 exception
   when locked then
      cpErrMsg:= char_to_sap('Договор №'||ipAgrId||' заблокирован');
   when others then
      cpErrMsg := char_to_sap(sqlerrm);
   return;
 end;
  ---<<<ubrr Некрасов А.В. 2013/03/06 12-965

  --->>>ubrr Рохин Е.А. 2013/05/07 12-1166
 PROCEDURE Change_LIMIT_EXPIRE_DATE ( ipAgrId           in      number,
                                      dpConditionDate   in      varchar2,
                                      dpLimitExpireDate in      varchar2,
                                      cpABS             in      varchar2,
                                      -->>>ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
                                      --cpErrMsg   in out   varchar2 -- Сообщение об ошибке
                                      cpErrMsg  out       varchar2 -- Сообщение об ошибке
                                      --<<<ubrr Лобик Д.А.08.09.2015 #24595 [15-997] SAP R/3: Инспекция кода E7P, EEP
)
 is
    cvLastIdSmr         smr.idsmr%type;
    cvErrMsg            varchar2(1024):='OK';
    dvConditionDate     date;
    dvLimitExpireDate   varchar2(10);
    LOCKED EXCEPTION;
    PRAGMA EXCEPTION_INIT(LOCKED, -54);
 begin
   cvLastIdSmr := ubrr_get_context;
   XXI_CONTEXT.Set_IDSmr (cpABS);
   begin
       select decode( dpConditionDate , '00000000', null, to_date(dpConditionDate , 'YYYYMMDD') )
        into dvConditionDate
        from dual;
   exception when others then
       dvConditionDate := null;
   end;
   begin
       select decode( dpLimitExpireDate ,
                      '00000000', null,
                      to_char( to_date(dpLimitExpireDate , 'YYYYMMDD'), 'DD.MM.YYYY' )
                    )
        into dvLimitExpireDate
        from dual;
   exception when others then
       dvConditionDate := null;
   end;
   begin
      if dvConditionDate is not null and dvLimitExpireDate is not null then
         cdterms.Update_History(ipAgrId, 1, 'DLIMEXP', dvConditionDate, null, null, null, dvLimitExpireDate);
      else
         delete cdh
          where ncdhAGRID=ipAgrId
            AND icdhPART=1
            AND ccdhTERM='DLIMEXP';
      end if;
   exception
   when no_data_found then
      cvErrMsg := 'Договор №'||ipAgrId||' не обнаружен';
   when locked then
      cvErrMsg:= 'Договор №'||ipAgrId||' заблокирован';
   end;
   XXI_CONTEXT.Set_IDSmr (cvLastIdSmr);
   cpErrMsg := char_to_sap(cvErrMsg);
 exception when others then
   XXI_CONTEXT.Set_IDSmr (cvLastIdSmr);
   cpErrMsg := char_to_sap(sqlerrm);
   return;
 end;
  ---<<<ubrr Рохин Е.А. 2013/05/07 12-1166

-- >>> Рохин Е.А. 25.09.2014 #16715 [14-528.4]
-- Логин и пароль E-mail на сервере Банка для извещений о задолженности
 PROCEDURE Get_UBRR_Email_Address   ( ipCusNum          in      number,
                                      cpSAPLogin        in      varchar2,
                                      cpEmailAddress    in out  varchar2,
                                      cpEmailPassword   in out  varchar2,
                                      cpErrMsg          in out  varchar2
)
is
    cvPartnerNum    UBRR_CRM.ubrr_crm_buh_clients_set.partner%type;
    cvErrMsg        varchar2(100) := '';
begin
    cpEmailAddress  := '';
    cpEmailPassword := '';
    cpErrMsg        := ''; --char_to_sap('OK');
    -- >>> Поиск номера ДП в CRM
    begin
        select    partner
            into  cvPartnerNum
            from  UBRR_CRM.ubrr_crm_buh_clients_set
            where clientid = to_char(ipCusNum)
              and rownum   = 1;
    exception
        when NO_DATA_FOUND then
            cpErrMsg        := char_to_sap('01-'||sqlerrm);
            return;
    end;
    -- <<< Поиск номера ДП в CRM

    -- >>> Поиск УБРиРовского E-mail
    begin
       select distinct
            EMAIL,
            PSWD
          into
            cpEmailAddress,
            cpEmailPassword
          from ubrr_crm_bp_email@uvkl.world
         where partner = cvPartnerNum;
    exception
        when NO_DATA_FOUND then
            cpEmailAddress := '';
        when others        then
            cpErrMsg        := char_to_sap(sqlerrm);
            return;
    end;
    -- <<< Поиск УБРиРовского E-mail

    if cpEmailAddress = '' or cpEmailAddress is null then
    -- >>> E-mail не найден. Надо его создать
        begin
            ubrr_crm_bp_email_sign.Set_usr@uvkl.world(
                                    cpSAPLogin );
            ubrr_crm_bp_email_sign.Ins_Email@uvkl.world(
                                    pPartner  => cvPartnerNum,
                                    pSignStat => 1,
                                    pDate     => trunc(sysdate),
                                    pErr      => cvErrMsg );
            if cvErrMsg is not null and cvErrMsg != '' then
                cpErrMsg := '02-01-'||cvErrMsg;
            end if;
            ubrr_crm_bp_email_sign.Open_Email@uvkl.world(
                                    pPartner  => cvPartnerNum,
                                    pErr      => cvErrMsg );
            if cvErrMsg is not null and cvErrMsg != '' then
                if cpErrMsg is not null and cpErrMsg != '' then
                    cpErrMsg := cpErrMsg||' 02-02-'||cvErrMsg;
                else
                    cpErrMsg := '02-02-'||cvErrMsg;
                end if;
            end if;
            commit;
            select distinct
                EMAIL,
                PSWD
              into
                cpEmailAddress,
                cpEmailPassword
              from ubrr_crm_bp_email@uvkl.world
             where partner = cvPartnerNum;
        exception
            when others then
                cpErrMsg := char_to_sap('02-'||sqlerrm);
                return;
        end;
    -- <<< E-mail не найден. Надо его создать
    end if;
    cpEmailPassword := char_to_sap(cpEmailPassword);
    if cpErrMsg != '' then
        cpErrMsg        := char_to_sap(cpErrMsg);
    else
        cpErrMsg        := char_to_sap('OK');
    end if;
end;  --Get_UBRR_Email_Address
-- <<< Рохин Е.А. 25.09.2014 #16715 [14-528.4]

-- >>> Рохин Е.А. 26.05.2015 #22087 [15-199]
-- Указание ПСК в кредитном договоре
 PROCEDURE Change_PSK ( ipAgrId      in      number,
                        dpDate       in      varchar2,
                        npPSK        in      number,
                        cpInsertOnly in      varchar2,
                        cpErrMsg     in out  varchar2
       )
is
    dvPSKDate   date;
    ivPSKCounts number := 0;
begin
    select count(*)
     into ivPSKCounts
     from xxi."cda"
     where ncdaagrid = ipAgrId;
    if ivPSKCounts = 0 then
        cpErrMsg        := char_to_sap('Неверно указан номер договора');
        return;
    end if;
    begin
       select decode( dpDate ,
                      '00000000', null,
                      to_date(dpDate , 'YYYYMMDD')
                    )
        into dvPSKDate
        from dual;
    exception when others then
       dvPSKDate := null;
    end;
    if dvPSKDate = null then
        cpErrMsg        := char_to_sap('Не указана дата ПСК');
        return;
    end if;
    begin
        select count(*)
         into ivPSKCounts
         from xxi.cdh
         where ncdhagrid = ipAgrId
         and   icdhpart  = 1
         and   ccdhterm = 'UBRRPSK';
    exception when others then
        ivPSKCounts := 0;
    end;
    if cpInsertOnly = 'X' and ivPSKCounts != 0 then
        cpErrMsg        := char_to_sap('ПСК уже указано в договоре');
        return;
    elsif ivPSKCounts != 0 then
        begin
            select count(*)
             into ivPSKCounts
             from xxi.cdh
             where ncdhagrid = ipAgrId
             and   icdhpart  = 1
             and   ccdhterm = 'UBRRPSK'
             and   dcdhdate  = dvPSKDate;
        exception when others then
            ivPSKCounts := 0;
        end;
    end if;
    if ivPSKCounts = 0 then
        insert into xxi.cdh (
         NCDHagrid,
         ICDHpart,
         CCDHterm,
         DCDHdate,
         MCDHmval,
         PCDHpval,
         ICDHival,
         CCDHcval )
        values (
         ipAgrId,
         1,
         'UBRRPSK',
         dvPSKDate,
         null,
         npPSK,
         null,
         null );
    else
        update xxi.cdh
         set PCDHpval = npPSK
         where ncdhagrid = ipAgrId
         and   icdhpart  = 1
         and   ccdhterm  = 'UBRRPSK'
         and   dcdhdate  = dvPSKDate;
    end if;
    cpErrMsg        := char_to_sap('OK');
end;


FUNCTION Calc_PSK( ipAgrId      in      number ) return number
is
    dv_EmissionDate date;
    nv_EmissionSumm xxi.cdp.MCDPSUM%type; -->><< 28.07.2016 Чепель С.А. #34714;
    nv_PSK_SUM_new  number;
    nv_PSK_SUM_old  number;
    nv_shift_value  number(5,4);
    nv_psk_accuracy number(5,4);
    nv_psk_diff     number;
    nv_psk          number;
    nv_psk_shift    number;
    nv_psk_new      number;
    iv_idsmr        xxi."cda".idsmr%type;
    iv_curr_idsmr   xxi."cda".idsmr%type;
    nv_ret          number(10,3);
    FUNCTION Calc_PSK_Summ( npPercent in number, dpEmissiondate date) return number
    is
        CURSOR Grafic is
            select dat,smpay from (
                select
                   a.dog dog,
                   0 part,
                   a.dat dat,
                   max(a.dtFrom) dtFrom,
                   max(a.dtTo) dtTo,
                   sum(a.smPayL) smPayL,
                   sum(a.smPayI) smPayI,
                   sum(a.smPayK) smPayK,
                   sum(a.smPay)  smPay
                   from
                   (
                   SELECT
                    dog,
                    part,
                    dat,
                    MAX(dFrom) dtFrom,
                    MAX(dTo) dtTo,
                    SUM(smPayL) smPayL,
                    SUM(smPayI) smPayI,
                    SUM(smPayK) smPayK,
                    SUM(smPayL+smPayI+smPayK) smPay
                   FROM
                   (
                   select
                    NCDRAGRID dog,
                    ICDRPART part,
                    DCDRDATE dat,
                    to_date(null) dFrom,
                    to_date(null) dTo,
                    MCDRSUM smPayL,
                    0 smPayI,
                    0 smPayK
                   from cdr
                   union
                   select
                    NCDIAGRID dog ,
                    ICDIPART part,
                    DCDIPMTDUE dat,
                    DCDIFROM dFrom,
                    DCDITO dTo,
                    0 smPayL,
                    (MCDITOTAL-decode(MCDIPAYED,null,0,MCDIPAYED)) smPayI,
                    0 smPayK
                   from v_cdi
                   WHERE ccdirt='T'
                   union
                   select
                    NCDKAGRID dog ,
                    ICDKPART part,
                    DCDKPMTDUE dat,
                    DCDKFROM dFrom,
                    DCDKTO dTo,
                    0 smPayL,
                    0 smPayI,
                    ROUND((MCDKTOTAL-decode(MCDKPAYED,null,0,MCDKPAYED))*
                      (REVAL.Cur_Rate_New(CCDKCUR, DCDKTO)/REVAL.Cur_Rate_New(cdTErms2.get_curiso(NCDKAGRID), DCDKTO)),2) smPayK
                   from v_cdk
                   )
                   GROUP BY dog,
                        part,
                        dat
                   ) a
                   group by  dog, dat
                   )
                   where dog = ipAgrId
                   order by dat;
        nv_ret          number;
        iv_e_k          number(2,0);
        iv_q_k          number(6,0);
        nv_Percent      number(10,10);
        dv_EmissionDate date;
        nv_EmissionSumm xxi.cdp.MCDPSUM%type; -->><< 28.07.2016 Чепель С.А. #34714;
        iv_Payment_Day  number(2,0);
        iv_Emission_Day number(2,0);
    begin
        nv_ret := 0;
        nv_Percent := npPercent / (12 * 100);
        select to_number(to_char(dpEmissionDate,'DD'))
         into iv_Emission_Day
         from dual;
        for Payment in Grafic
        loop
            select to_number(to_char(Payment.dat,'DD'))
             into iv_Payment_Day
             from dual;
            if iv_Payment_Day >= iv_Emission_Day then
                iv_e_k := iv_Payment_Day - iv_Emission_Day;
                iv_q_k := MONTHS_BETWEEN(Payment.dat, dpEmissionDate);
            else
                iv_e_k := iv_Payment_Day - iv_Emission_Day + 30;
                iv_q_k := MONTHS_BETWEEN(Payment.dat, dpEmissionDate) - 1;
            end if;
            nv_ret := nv_ret + Payment.smpay / ( ( 1 + ( 12 * iv_e_k * nv_Percent / 365 ) ) * power( 1 + nv_percent, iv_q_k ) );
        end loop;
        return nv_ret;
    end;

begin
    select dcdpdate, mcdpsum
     into  dv_EmissionDate, nv_EmissionSumm
     from  cdp
     where ncdpagrid = ipAgrId;
    nv_shift_value  := 1 / 100;
    nv_psk_accuracy := 1 / 1000;
    select CDREP_UTIL.GET_INTRATE( ncdaagrid, dcdastarted ), idsmr
     into nv_psk, iv_idsmr
     from xxi."cda"
     where ncdaagrid = ipAgrId;
    loop
        nv_psk_shift   := nv_psk + nv_shift_value;
        nv_PSK_SUM_old := Calc_PSK_Summ( nv_psk,       dv_EmissionDate );
        nv_PSK_SUM_new := Calc_PSK_Summ( nv_psk_shift, dv_EmissionDate );
        nv_psk_new     := nv_psk + nv_shift_value * ( ( nv_EmissionSumm - nv_PSK_SUM_old ) / ( nv_PSK_SUM_new - nv_PSK_SUM_old ) );
        nv_psk_diff    := nv_psk_new - nv_psk;
        nv_psk         := nv_psk_new;
        exit when abs(nv_psk_diff) < nv_psk_accuracy;
    end loop;
    nv_ret := nv_psk;
    return nv_ret;
end Calc_PSK;
-- <<< Рохин Е.А. 26.05.2015 #22087 [15-199]
-->> Рохин Е.А. 10.12.2015 #26420 [15-692.1]
PROCEDURE UpdateCDH (ipAgrid  in  number,
                     ipPart   in  number,
                     cpTerm   in  varchar2,
                     cpDate   in  varchar2,
                     cpParam  in  varchar2,
                     cpValue  in  varchar2,
                     cpErrMsg out varchar2
                     )
is
begin
    case cpParam
        when 'MVAL' then
            cdterms.Update_History(ipAgrid,
                                   ipPart,
                                   cpTerm,
                                   to_date(cpDate,'YYYYMMDD'),
                                   to_number(cpValue),
                                   null,
                                   null,
                                   null);
        when 'PVAL' then
            cdterms.Update_History(ipAgrid,
                                   ipPart,
                                   cpTerm,
                                   to_date(cpDate,'YYYYMMDD'),
                                   null,
                                   to_number(cpValue),
                                   null,
                                   null);
        when 'IVAL' then
            cdterms.Update_History(ipAgrid,
                                   ipPart,
                                   cpTerm,
                                   to_date(cpDate,'YYYYMMDD'),
                                   null,
                                   null,
                                   to_number(cpValue),
                                   null);
        when 'CVAL' then
            cdterms.Update_History(ipAgrid,
                                   ipPart,
                                   cpTerm,
                                   to_date(cpDate,'YYYYMMDD'),
                                   null,
                                   null,
                                   null,
                                   cpValue);
    end case;
    cpErrMsg := char_to_sap('OK');
exception
    when others then
     cpErrMsg := char_to_sap(sqlerrm);
end UpdateCDH;
--<< Рохин Е.А. 10.12.2015 #26420 [15-692.1


function SetSAPCDContext(cpIDSMR in VARCHAR2 default null) return varchar2
  is
       ret varchar2(32767):='';
begin
  xxi_context.Set_IDSmr ( cpIDSMR );
  return UBRR_XXI5.ubrr_get_context;
  exception when others then
      return null;--'error SetSAPCDContext:'||sqlerrm;
end; --SetSAPCDContext

-->> 30.05.2016 ubrr korolkov 16-1808.2.3.2.4.5
procedure Generate_Annuitet(p_cMsg          out varchar2,
                            p_id            in  varchar2,   -- Идентификатор расчёта
                            p_StartDate     in  varchar2,   -- Дата начала выплат
                            p_EndDate       in  varchar2,   -- Дата окончания выплат (договора)
                            p_StartSum      in  number,     -- Сумма кредита
                            p_Prc           in  number,     -- Процентная ставка
                            p_sum_repay     in  number,     -- Сумма аннуитета
                            p_dt            in  varchar2,   -- Дата первого возврата
                            p_interv        in  number default 0, -- период
                                                                  --  0 - мес
                                                                  --  1 - квартал
                                                                  --  2 - полгода
                                                                  --  3 - год
                            p_fl            in  number default 1, -- тип определения сдвига
                                                                  --  0 - по дню месяца даты dFirstPay (для интервалов > мес)
                                                                  --  1 - по последнему дню интервала
                                                                  --  2 - по сдвигу задаваемой даты dFirstPay от начала
                                                                  --  3 - через указанное количество рабочих дней от начала интервала
                            p_tp_correct    in  NUMBER default 1, -- поведение при учете выходных дней
                                                                  -- 1 сдвигать интервал начисления
                            p_only_working_days in number default null, -- исключать выходные (0 - нет, 1 - исключать)
                            p_AB            in  number default null,  --  0 - с возвратом позже
                                                                      -- -1 - с возвратом ранее
                            p_dt2           in  number default null)
is
    vErrMsg     varchar2(2000);
    vStartDate  date;
    vEndDate    date;
    vDt         date;
begin
    vStartDate := to_date(p_StartDate,'YYYYMMDD');
    vEndDate := to_date(p_EndDate,'YYYYMMDD');
    vDt := to_date(p_dt,'YYYYMMDD');

    ubrr_cdterms3.Generate_Annuitet(vErrMsg,
                                    p_id,
                                    vStartdate,
                                    vEndDate,
                                    p_StartSum,
                                    p_Prc,
                                    p_sum_repay,
                                    vDt,
                                    p_interv,
                                    p_fl,
                                    p_tp_correct,
                                    p_ONLY_WORKING_DAYS,
                                    p_AB,
                                    p_dt2);
    commit;
    p_cMsg := char_to_sap(vErrMsg);
end Generate_Annuitet;
--
-- Создать график начисления процентов на основании графика гашения ОД
--
procedure CreatePrcSchedule(p_ErrMsg    out varchar2,
                            p_AgrId      in  number)
is
    vAgrId      xxi."cda".ncdaagrid%type;
    vStatus     xxi."cda".icdastatus%type;
    vIsLine     xxi."cda".icdaisline%type;
    v_CDR_Count number;
    v_ann_summ  xxi."cda".mcdatotal%type;
begin
    p_ErrMsg := 'OK';
    begin
        select ncdaagrid, icdastatus, icdaisline
        into vAgrId, vStatus, vIsLine
        from xxi."cda"
        where ncdaagrid = p_AgrId;
    exception
        when no_data_found then
            p_ErrMsg := 'Договор с номером ' || to_char(p_AgrId) || 'не найден';
    end;

    if vAgrId is not null then
        if vStatus <> 0 then
            p_ErrMsg := 'Договор должен быть в статусе "Черновик"';
        elsif vIsLine <> 0 then
            p_ErrMsg := 'Договор должен быть срочным';
        else
            delete from cds where ncdsagrid = vAgrId;

            insert into cds
                select ncdragrid, dcdrdate, dcdrdate
                from cdr
                where ncdragrid = vAgrId;
        end if;
    end if;

    begin
        select ncda2agrid
        into vAgrId
        from xxi.cda2
        where ncda2agrid = p_AgrId;
    exception
        when no_data_found then
            vAgrId := null;
    end;
    if  vAgrId is not null then
        select count(*) into v_CDR_Count from xxi.cdr where ncdragrid = vAgrId;
        delete FROM V_CDI WHERE V_CDI.NCDIAGRID = vAgrId;
        CDinterest.recalc_interest(vAgrId, 'T', Do_Commit => FALSE, Generate_Details => FALSE);
        for payment in ( select smPay, count(*) smCounts from
                         (select  a.dat dat,
                                  sum(a.smPay)  smPay
                          from (   SELECT   part,
                                            dat,
                                            MAX(dFrom) dtFrom,
                                            MAX(dTo) dtTo,
                                            SUM(smPayL) smPayL,
                                            SUM(smPayI) smPayI,
                                            SUM(smPayL+smPayI) smPay
                                   FROM (      select  NCDRAGRID dog,
                                                       ICDRPART part,
                                                       DCDRDATE dat,
                                                       to_date(null) dFrom,
                                                       to_date(null) dTo,
                                                       MCDRSUM smPayL,
                                                       0 smPayI
                                               from cdr
                                               where NCDRAGRID = vAgrId
                                               and   DCDRDATE > sysdate
                                               and   DCDRDATE < (select max(dcdrdate) from xxi.cdr where ncdragrid = vAgrId)
                                               union
                                               select  NCDIAGRID dog ,
                                                       ICDIPART part,
                                                       DCDIPMTDUE dat,
                                                       DCDIFROM dFrom,
                                                       DCDITO dTo,
                                                       0 smPayL,
                                                       (MCDITOTAL-decode(MCDIPAYED,null,0,MCDIPAYED)) smPayI
                                               from v_cdi
                                               where NCDIAGRID = vAgrId
                                               and   DCDIPMTDUE > sysdate
                                               and   DCDIPMTDUE < (select max(dcdrdate) from xxi.cdr where ncdragrid = vAgrId))
                                   GROUP BY part, dat ) a
                          group by  dat)
                         group by smPay
                         order by smCounts)

        loop
            if payment.smCounts/(v_CDR_Count-1) > 0.8 then
                --dbms_output.put_line('Договор: '||cr.ncdaagrid||' Сумма платежа '||payment.smPay||' встречается '||payment.smCounts||' раз из '||to_char(v_CDR_Count-1));
                v_ann_summ := payment.smPay;
            end if;
        end loop;
        update xxi.cda2
            set MCDA2SUM_A   = v_ann_summ
            where NCDA2AGRID = vAgrId;
    end if;
    p_ErrMsg := char_to_sap(p_ErrMsg);

exception
    when others then
        p_ErrMsg := char_to_sap(dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
end CreatePrcSchedule;
--<< 30.05.2016 ubrr korolkov 16-1808.2.3.2.4.5
-->> Бунтова 07.2017 #44404: [15-1115.1] Автоматизация скоринг-гарантий
PROCEDURE GetBPLimSCG ( p_npCus     in      number,
                        p_dpZc      in      varchar2,
                        p_cpDemp    in      number,
                        p_SumLimit  out     number
                     )
is
begin
    IF p_cpDemp = 1 then
      BEGIN
        SELECT sum(decode(iaccbs2, 91319, restf(caccacc,cacccur,to_date(p_dpZc,'YYYYMMDD'),idsmr),91315, -restf(caccacc,cacccur,to_date(p_dpZc,'YYYYMMDD'),idsmr)
                        )
                 )
                 INTO p_SumLimit
        FROM xxi."acc" w
        WHERE w.IACCCUS =  9188971
          and w.caccprizn = 'О'
          and w.iaccbs2 in (91315,91319)
          and upper(w.caccsio) like '%Д%';
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       p_SumLimit := 0;
     END;
    ELSE
      BEGIN
        SELECT sum(decode(iaccbs2, 91319, restf(caccacc,cacccur,to_date(p_dpZc,'YYYYMMDD'),idsmr),91315, -restf(caccacc,cacccur,to_date(p_dpZc,'YYYYMMDD'),idsmr)
                         )
                  )
               INTO p_SumLimit
        FROM xxi."acc" w
        WHERE w.IACCCUS =  9188971
          and w.caccprizn = 'О'
          and w.iaccbs2 in (91315,91319)
          and w.caccsio is not null;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        p_SumLimit := 0;
      END;
    END IF;
end GetBPLimSCG;
--<< Бунтова 07.2017 #44404: [15-1115.1] Автоматизация скоринг-гарантий

-->>22.03.2021  Зеленко С.А.     DKBPA-105 ЭТАП 4.1 (репликация АБС): Формат распоряжения. ЗИУ для кредитов по короткой схеме
-------------------------------------------------------------------------------
-- Процедура логирования
-------------------------------------------------------------------------------
PROCEDURE ZIU_Write_Log(p_cmess in varchar2)
  is
  pragma autonomous_transaction;
BEGIN
  if g_log_enable = 'Y' then
    insert into UBRR_DATA.UBRR_SAP_ZIU_LOG(message)
                    values (substr(p_cmess,1,2000));
    commit;
  end if;
END;

-------------------------------------------------------------------------------
-- Процедура генерации графика начислений (основной)
-------------------------------------------------------------------------------
PROCEDURE ZIU_Calc_Interval_O(p_Agrid      in     number,
                              p_start      in     date,
                              p_finish     in     date,
                              p_perctermid in     number
                             )
  IS

  dStart      date := p_start; --Дата начала изменений (вначале дата начала договора)
  dFinish     date := p_finish;

  tpDayOff    number:=1; -- учет праздничных дней
                          --  0 - не учитывать
                          --  -1 - сдвигать на ранее
                          --  1 - сдвигать на позже
  isCorDayOff number:=0; -- поведение при учете выходных дней

  dFirstN     date;
  dFirstPay   date;
  nn          number := 1;
  nnmax       number := 500;
  rm          number := 0;
  rd          number := 0;
  rdm         number := 0;
  rdc         number := 0;
  rm_N        number := 0;
  rd_N        number := 0;
  rdm_N       number := 0;
  rdc_N       number := 0;
  sm          number;
  dFirst      date;
  dFirst_N    date;
  dPay        date;
  dPay_N      date;

  FUNCTION getdPay(dFirst_F date, rd_F number,sm_F number,rdc_F number, rm_F number,rdm_F number)
  RETURN date IS
    dPay_F date;
    last_day_month date;
  BEGIN
    dPay_F := ADD_MONTHS(dFirst_F,rm_F)+rdm_F-1;
    last_day_month := LAST_DAY(ADD_MONTHS(dFirst_F,rm_F));
    if dPay_F > last_day_month then
       dPay_F := last_day_month;
    end if;
    RETURN  dPay_F;
  END;

BEGIN

  dFirstN  := least(last_day(dStart),dFinish);

  if p_perctermid = 1 then
    dFirstPay:=dFinish;
  else
    dFirstPay:=least(last_day(dStart)+10,dFinish);
  end if;

  delete from cds
     where NCDSAGRID=p_Agrid
       and DCDSINTCALCDATE>=dStart;

  nn  := 1;

  dFirst := TRUNC(dFirstPay,'MON');
  dFirst_N := TRUNC(dFirstN,'MON');
  sm := 1;

  rd  := dFirstPay-dFirst - 10*rdc;
  rm  := TRUNC(MONTHS_BETWEEN(dFirstPay,dFirst));
  rdm := to_number(to_char(dFirstPay,'DD'));

  rd_N  := dFirstN-dFirst_N - 10*rdc_N;
  rm_N  := TRUNC(MONTHS_BETWEEN(dFirstN, dFirst_N));
  rdm_N := to_number(to_char(dFirstN,'DD'));

  IF (dFirstN = LAST_DAY(dFirstN)) AND (rdm_N < 31) THEN
    rdm_N := 31;
  END IF;

  IF (dFirstPay = LAST_DAY(dFirstPay)) AND (rdm < 31) THEN
    rdm := 31;
  END IF;

  <<loop_Pay>>
    LOOP
      dPay := getdPay(dFirst,rd,sm,rdc,rm,rdm);
      dPay_N := getdPay(dFirst_N,rd_N,sm,rdc_N,rm_N,rdm_N);

      dFirstN:=dPay_N;
      dFirstPay := dPay;

      WHILE not DJ_DATE.Is_Working_Day(dFirstPay) LOOP dFirstPay:=dFirstPay+1; END LOOP;

      if dFinish <= dFirstPay then
        dFirstPay := dFinish;
      end if;
      if dFinish <= dFirstN then
        dFirstN := dFinish;
      end if;


      IF isCorDayOff=1 THEN dFirstN:=dFirstPay; END IF;

      IF dFirstN>=dStart and dFirstPay>=dStart THEN
        INSERT INTO cds (ncdsAGRID, dcdsINTCALCDATE, dcdsINTPMTDATE)
          VALUES ( p_Agrid, dFirstN, dFirstPay);
      END IF;

      IF dFirstN>=dFinish THEN
        EXIT;
      END IF;

      -- шаг цикла
      IF nn >= nnmax THEN
        EXIT;
      ELSE
        nn:=nn+1;
           dFirst := ADD_MONTHS(dFirst,sm);
           dFirst_N := ADD_MONTHS(dFirst_N,sm);
      END IF;

    END LOOP;-- loop_Pay;
END;

-------------------------------------------------------------------------------
-- Процедура генерации графика начислений (плавающий)
-------------------------------------------------------------------------------
PROCEDURE ZIU_Calc_Interval( p_Agrid       in number,
                             P_DT          IN DATE,   -- Первое начисление
                             P_DT2         IN DATE,   -- Первая уплата
                             P_TYPE_REM    IN NUMBER DEFAULT 0, -- Тип определения сдвига: 0-по сдвигу первой даты
                                                      --                         1-по последнему дню интервала
                                                      --                         2-по дню месяца первой даты
                                                      --                         9-по дню месяца первой уплаты
                             P_PAY_DAY     IN NUMBER, -- День уплаты
                             P_INTERV      IN NUMBER, -- Интервал: 0-месяц
                                                      --           1-квартал
                                                      --           2-полгода
                                                      --           3-год
                                                      --           4-декада
                             P_FIXED_PARAM IN NUMBER, -- Расчет: 0-с даты подписания
                                                      --         1-с текущей даты
                             P_ONLY_WORKING_DAYS IN NUMBER, -- Исключать выходные
                             P_AB          IN NUMBER, -- '1'  - с возвратом позже
                                                      -- '-1' - с возвратом ранее
                             P_TP_CORRECT  IN NUMBER, -- сдвигать интервал начисления 1-да 0-нет
                             P_PAY_DURING  IN NUMBER, -- Уплатить в течение  1-да 0-нет          *
                             P_WORK_DAY    IN NUMBER, -- Рабочих 1-да 0-нет                      *
                             P_NUM_OF_DAY  IN NUMBER, -- Дней                                    *
                             P_CALC_DATE_LAST_DAY         IN NUMBER DEFAULT 0, -- Считать даты последним днем месяца? 1-да 0-нет
                             P_IS_FIRST_DATE_LAST_DAY     IN NUMBER DEFAULT 0, -- Считать дату первого начисления  последним днем месяца? 1-да 0-нет
                             P_IS_FIRST_PAY_LAST_DAY      IN NUMBER DEFAULT 0,  -- Считать дату первой уплаты последним днем месяца? 1-да 0-нет
                             P_TO_CALENDAR IN NUMBER DEFAULT 0,  -- Разбвать периоды календарно 1-да 0-нет
                             P_TO_DATE     IN DATE DEFAULT NULL,  -- РАссчитать график до даты   -->><< 11.11.2013 Портнягин Д.Ю. 12-1990 Продление графиков гашения при наступлении срока окончания договора
                             P_FIXED_DATE  IN DATE DEFAULT NULL
                            )
  IS
    --Agrid       number := p_Agrid;
    dStart      date;  --Дата начала изменений (вначале дата начала договора)

    dFirstN     date := P_DT;
    dFirstPay   date := P_DT2;
    dFinish     date;

    tpDayOff    number:=0; -- учет праздничных дней
                        --  0 - не учитывать
                        -- -1 - сдвигать на ранее
                        --  1 - сдвигать на позже
    isCorDayOff number:=0; -- поведение при учете выходных дней
                        -- 0 оставить дату начисления, как есть
                        -- 1 сдвигать интервал начисления
--
    nn  number := 1;
    nnmax  number := 1000;
    rm  number := 0;
    rd  number := 0;
    rdm number := 0;
    rdc  number := 0;
    rm_N  number := 0;
    rd_N  number := 0;
    rdm_N number := 0;
    rdc_N  number := 0;
    sm  number;
    dFirst  date;
    dFirst_N  date;
    dPay    date;
    dPay_N  date;
    V_PAY_DAY NUMBER;
    i_days_plus NUMBER;

    FUNCTION getdPay(dFirst_F date, rd_F number,sm_F number,rdc_F number, rm_F number,rdm_F number)
    RETURN date IS
         dPay_F date;
         last_day_month date;
    BEGIN

        IF P_INTERV in (0,1,2,3) THEN -- помесячно -- квартал -- полугод -- год
            IF P_TYPE_REM = 0 THEN   -- 0 - по сдвигу от начала задаваемой даты dFirstPay
                dPay_F := dFirst_F + rd_F;
            ELSIF P_TYPE_REM = 9 THEN
                  begin
                    dPay_F := to_date(to_char(V_PAY_DAY)||'.'||to_char(dFirst_F, 'MM.YYYY'), 'DD.MM.YYYY');
                  EXCEPTION WHEN OTHERS THEN
                    dPay_F := LAST_DAY(dFirst_F) + 1;
                  END;

            ELSIF P_TYPE_REM=1 THEN   --  1 - по последнему дню интервала
                dPay_F := ADD_MONTHS(dFirst_F,sm_F)-1;
            ELSIF P_TYPE_REM=2 THEN   --  2 - по дню месяца даты dFirstPay (для интервалов > мес)
                dPay_F := ADD_MONTHS(dFirst_F,rm_F)+rdm_F-1;
                last_day_month := LAST_DAY(ADD_MONTHS(dFirst_F,rm_F));
                if dPay_F > last_day_month then
                   dPay_F := last_day_month;
                end if;
            END IF;
        ELSIF P_INTERV=4 THEN -- декада
            IF P_TYPE_REM in (0,2) THEN   --  0 - по сдвигу от начала задаваемой даты dFirstPay
                dPay_F := dFirst_F + 10*rdc_F+ rd_F;
            ELSIF   P_TYPE_REM=1 THEN   --  1 - по последнему дню интервала
                if rdc_F=2 then   dPay_F := LAST_DAY(dFirst_F);
                else            dPay_F := dFirst_F + 10*(rdc_F+1)-1;
                end if;
            END IF;
        END IF;
        RETURN  dPay_F;
    END getdPay;

BEGIN

  IF P_TYPE_REM=9 THEN
    IF P_PAY_DAY IS NOT NULL THEN
      V_PAY_DAY:= P_PAY_DAY;
    ELSE
      V_PAY_DAY:= nvl(ubrr_xxi5.ubrr_cd_interval.get_pay_day(p_Agrid),10); --если не указан день, то указываем 10 число
    END IF;

    IF  EXTRACT(DAY FROM last_day(dFirstPay)) < V_PAY_DAY THEN
      i_days_plus := V_PAY_DAY - EXTRACT(DAY FROM last_day(dFirstPay));
      dFirstPay := last_day(dFirstPay)+1;
    ELSE
      i_days_plus := 0;
      dFirstPay := to_date(to_char(V_PAY_DAY)||'.'||to_char(dFirstPay, 'MM.YYYY'), 'DD.MM.YYYY');
    END IF;
  END IF;

  dFinish := trunc(P_TO_DATE);

  IF dFinish IS NULL THEN
    raise_application_error(-20000,'ZIU_Calc_Interval. Не определена дата окончания.');
  END IF;

  IF P_FIXED_PARAM=1 THEN
    dStart := trunc(P_FIXED_DATE);
  else
      BEGIN
        SELECT dcdvSIGNDATE into dStart from vcda where ncdvAGRID=p_Agrid;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          dStart := NULL;
      END;
  END IF;

  IF dStart IS NULL THEN
    raise_application_error(-20000,'ZIU_Calc_Interval. Не определена дата начала.');
  END IF;

  IF (P_ONLY_WORKING_DAYS=1) THEN
    tpDayOff := P_AB;
    isCorDayOff := P_TP_CORRECT;
  END IF;

  DELETE FROM cds
    WHERE NCDSAGRID=p_Agrid
      AND DCDSINTCALCDATE>=dStart;

  nn  := 1;

  IF P_INTERV=0 THEN -- помесячно
    IF i_days_plus > 0 THEN  --25.01.2013
      dFirst := TRUNC(add_months(dFirstPay,-1),'MON');
    ELSE
      dFirst := TRUNC(dFirstPay,'MON');
    END if;
    dFirst_N := TRUNC(dFirstN,'MON');
    sm := 1;
  ELSIF P_INTERV=1 THEN -- квартал
    dFirst := TRUNC(dFirstPay,'Q');
    dFirst_N := TRUNC(dFirstN,'Q');
    sm := 3;
  ELSIF P_INTERV=2 THEN -- полугод
    dFirst := TRUNC(dFirstPay,'Y');
    dFirst_N := TRUNC(dFirstN,'Y');
    IF months_between(dFirstPay, dFirst) > 6 THEN
        dFirst := add_months(dFirst, 6);
    END IF;
    IF months_between(dFirstN, dFirst_N) > 6 THEN
        dFirst_N := add_months(dFirst_N, 6);
    END IF;
    sm := 6;
  ELSIF P_INTERV=3 THEN -- год
    dFirst := TRUNC(dFirstPay,'Y');
    dFirst_N := TRUNC(dFirstN,'Y');
    sm := 12;
  ELSIF P_INTERV=4 THEN -- декада
    dFirst := TRUNC(dFirstPay,'MON');
    dFirst_N := TRUNC(dFirstN,'MON');
    IF      dFirstPay >= (dFirst+20) THEN  rdc := 2;
    ELSIF   dFirstPay >= (dFirst+10) THEN  rdc := 1;
    ELSE    rdc := 0;
    END IF;
    IF      dFirstN >= (dFirst_N+20) THEN  rdc_N := 2;
    ELSIF   dFirstN >= (dFirst_N+10) THEN  rdc_N := 1;
    ELSE    rdc_N := 0;
    END IF;
    sm := 1;
  END IF;

  rd  := (dFirstPay - dFirst - 10*rdc);
  rm  := TRUNC(MONTHS_BETWEEN(dFirstPay,dFirst));
  rdm := to_number(to_char(dFirstPay,'DD'));

  rd_N  := dFirstN-dFirst_N - 10*rdc_N;
  rm_N  := TRUNC(MONTHS_BETWEEN(dFirstN,dFirst_N));
  rdm_N := to_number(to_char(dFirstN,'DD'));

  IF (P_TYPE_REM =2) THEN
    IF    ((dFirstPay = LAST_DAY(dFirstPay))
      AND (rdm < 31))
      AND ((dFirstN = LAST_DAY(dFirstN))
      AND (rdm_N < 31))
    THEN

      IF P_CALC_DATE_LAST_DAY = 1 THEN
        rdm := 31;
        rdm_N := 31;
      END IF;

    END IF;

    IF (dFirstN = LAST_DAY(dFirstN)) AND (rdm_N < 31) THEN
      IF P_IS_FIRST_DATE_LAST_DAY = 1 THEN rdm_N := 31; END IF;
    END IF;
    IF (P_PAY_DURING = 0) AND (dFirstPay = LAST_DAY(dFirstPay)) AND (rdm < 31) THEN
      IF P_IS_FIRST_PAY_LAST_DAY = 1 THEN rdm := 31; END IF;
    END IF;
  END IF;
  <<loop_Pay>>
  LOOP
    dPay := getdPay(dFirst,rd,sm,rdc,rm,rdm);
    dPay_N := getdPay(dFirst_N,rd_N,sm,rdc_N,rm_N,rdm_N);

    dFirstN := dPay_N;
    dFirstPay := dPay;

    IF (P_PAY_DURING = 1) AND (P_NUM_OF_DAY > 0) THEN
      IF P_WORK_DAY = 1 THEN
        IF P_TYPE_REM=9 THEN
          NULL;

        ELSE
          dFirstPay:=DJ_DATE.Add_Working_Days(dFirstN,P_NUM_OF_DAY);
        END IF;
      ELSE

        IF P_TYPE_REM=9 THEN
            NULL;
        ELSE
          dFirstPay:=dFirstN + P_NUM_OF_DAY;
        END IF;

      END IF;
    END IF;

    IF tpDayOff=-1 THEN --  сдвигать на ранее
        WHILE not DJ_DATE.Is_Working_Day(dFirstPay) LOOP dFirstPay:=dFirstPay-1; END LOOP;
    ELSIF tpDayOff=1 THEN --  сдвигать на позже
        WHILE not DJ_DATE.Is_Working_Day(dFirstPay) LOOP dFirstPay:=dFirstPay+1; END LOOP;
    END IF;

    IF P_TYPE_REM=9 THEN
      IF (P_PAY_DURING = 1) AND (P_NUM_OF_DAY > 0) THEN
        IF P_WORK_DAY = 1 THEN
          dFirstN   := DJ_DATE.Add_Working_Days(dFirstPay,-P_NUM_OF_DAY);
        ELSE
          dFirstN :=dFirstPay - P_NUM_OF_DAY;
        END IF;
      END IF;
    END IF;

    if dFinish <= dFirstPay then
       dFirstPay := dFinish;
       IF P_TYPE_REM=9 THEN
          dFirstN := dFinish;
       END IF;
    end if;
    if dFinish <= dFirstN then
       dFirstN := dFinish;
    end if;

    IF isCorDayOff=1 THEN dFirstN:=dFirstPay; END IF;

    IF dFirstN>=dStart and dFirstPay>=dStart THEN
       INSERT INTO cds (ncdsAGRID, dcdsINTCALCDATE, dcdsINTPMTDATE)
                VALUES ( p_Agrid, dFirstN, dFirstPay);
    END IF;

    IF dFirstN>=dFinish /*OR dFirstPay>=dFinish*/ THEN
      EXIT;
    END IF;
    -- шаг цикла
    IF nn >= nnmax THEN
        EXIT;
    ELSE
        nn:=nn+1;
        IF P_INTERV in (0,1,2,3) THEN -- помесячно -- квартал -- полугод -- год
              dFirst := ADD_MONTHS(dFirst,sm);
              dFirst_N := ADD_MONTHS(dFirst_N,sm);
        ELSIF P_INTERV=4 THEN -- декада
            IF rdc=2 THEN
              dFirst := ADD_MONTHS(dFirst,sm);
              rdc:=0;
            ELSE
              rdc:=rdc+1;
            END IF;
            IF rdc_N=2 THEN
              dFirst_N := ADD_MONTHS(dFirst_N,sm);
              rdc_N:=0;
            ELSE
              rdc_N:=rdc_N+1;
            END IF;
        END IF;
    END IF;
  END LOOP;
END ZIU_Calc_Interval;

-------------------------------------------------------------------------------
-- Процедура генерации графика начислений
-------------------------------------------------------------------------------
PROCEDURE ZIU_Calc_Interval(p_Agrid           in     number,
                            p_StartDate       in     date,
                            p_FinishDate      in     date,
                            p_PerctermID      in     number,
                            p_ErrMessage      in out varchar2
                            )
  is

BEGIN
  ZIU_Write_Log('Start ZIU_Calc_Interval(p_AgrId'        ||' => '||p_AgrId||','||
                                        'p_StartDate'    ||' => '||p_StartDate||','||
                                        'p_PerctermID'   ||' => '||p_PerctermID||','||
                                        'p_FinishDate'   ||' => '||p_FinishDate||')');

  IF p_PerctermID = 1 or p_PerctermID = 3 THEN
    ZIU_Calc_Interval_O(p_Agrid      => p_Agrid,
                        p_start      => p_StartDate,
                        p_finish     => p_FinishDate,
                        p_perctermid => p_PerctermID
                        );

  ELSIF p_PerctermID = 8 THEN -- по дату погашения
    ZIU_calc_interval ( p_Agrid                    => p_Agrid,
                        p_fixed_param              => 1,  -- Расчет: 0-с даты подписания
                                                          --         1-с текущей даты
                        p_interv                   => 0,  -- Интервал: 0-месяц
                                                          --           1-квартал
                                                          --           2-полгода
                                                          --           3-год
                                                          --           4-декада
                        p_dt                       => p_StartDate, -- Первое начисление
                        p_dt2                      => to_date('01'||to_char(/*add_months(*/p_StartDate/*,1)*/,'mm.yyyy'),'dd.mm.yyyy'), -- Первая уплата
                        p_pay_during               => 1, -- Уплатить в течение  1-да 0-нет          *
                        p_work_day                 => 0, -- Рабочих 1-да 0-нет                      *
                        p_num_of_day               => 0, -- Дней                                    *
                        p_type_rem                 => 9,  -- Тип определения сдвига: 0-по сдвигу первой даты
                                                          --                         1-по последнему дню интервала
                                                          --                         2-по дню месяца первой даты
                                                          --                         9-по дню месяца первой уплаты
                        p_pay_day                  => '',
                        p_only_working_days        => 1, -- исключать выходные (0 - нет, 1 - исключать)
                        p_ab                       => 1, -- '1'  - с возвратом позже
                                                         -- '-1' - с возвратом ранее
                        p_tp_correct               => 1, -- сдвигать интервал начисления 1-да 0-нет
                        p_calc_date_last_day       => 0, -- Считать даты последним днем месяца? 1-да 0-нет
                        p_is_first_date_last_day   => 0, -- Считать дату первого начисления  последним днем месяца? 1-да 0-нет
                        p_is_first_pay_last_day    => 0, -- Считать дату первой уплаты последним днем месяца? 1-да 0-нет
                        p_to_date                  => p_FinishDate,
                        P_FIXED_DATE               => p_StartDate
                      );
  ELSIF p_PerctermID = 6 THEN
    ZIU_calc_interval ( p_Agrid                    => p_Agrid,
                        p_fixed_param              => 1,  -- Расчет: 0-с даты подписания
                                                          --         1-с текущей даты
                        p_interv                   => 0,  -- Интервал: 0-месяц
                                                          --           1-квартал
                                                          --           2-полгода
                                                          --           3-год
                                                          --           4-декада
                        p_dt                       => p_StartDate, -- Первое начисление
                        p_dt2                      => to_date('01'||to_char(/*add_months(*/p_StartDate/*,1)*/,'mm.yyyy'),'dd.mm.yyyy'), -- Первая уплата
                        p_pay_during               => 1, -- Уплатить в течение  1-да 0-нет          *
                        p_work_day                 => 0, -- Рабочих 1-да 0-нет                      *
                        p_num_of_day               => 5, -- Дней                                    *
                        p_type_rem                 => 9,  -- Тип определения сдвига: 0-по сдвигу первой даты
                                                          --                         1-по последнему дню интервала
                                                          --                         2-по дню месяца первой даты
                                                          --                         9-по дню месяца первой уплаты
                        p_pay_day                  => '',
                        p_only_working_days        => 1, -- исключать выходные (0 - нет, 1 - исключать)
                        p_ab                       => 1, -- '1'  - с возвратом позже
                                                         -- '-1' - с возвратом ранее
                        p_tp_correct               => 0, -- сдвигать интервал начисления 1-да 0-нет
                        p_calc_date_last_day       => 0, -- Считать даты последним днем месяца? 1-да 0-нет
                        p_is_first_date_last_day   => 0, -- Считать дату первого начисления  последним днем месяца? 1-да 0-нет
                        p_is_first_pay_last_day    => 0, -- Считать дату первой уплаты последним днем месяца? 1-да 0-нет
                        p_to_date                  => p_FinishDate,
                        P_FIXED_DATE               => p_StartDate
                      );
  END IF;

  ZIU_Write_Log('End ZIU_Calc_Interval ОК');

EXCEPTION
  WHEN OTHERS THEN
    ZIU_Write_Log('EXCEPTION ZIU_Calc_Interval '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    p_ErrMessage := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
END;

-------------------------------------------------------------------------------
-- Процедура добавления данных в таблицу для изменения графика гашения
-------------------------------------------------------------------------------
PROCEDURE ZIU_Repayment_Schedule( p_AgrId            in number,      -- Код кредитного договора
                                  p_ChangeDate       in varchar2,    -- Дата внесения изменеия (дата с)
                                  p_PayAmount        in number,      -- Сумма
                                  p_PayDate          in varchar2,    -- Дата
                                  p_Status           out varchar2,   -- Статус
                                  p_ErrorMsg         out varchar2    -- Сообщение об ошибке
                                )
  is

  l_ChangeDate               date;
  l_PayDate                  date;
  l_ubrr_sap_ziu_temp_gtt    UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT%rowtype;

BEGIN
  ZIU_Write_Log('Start ZIU_Repayment_Schedule(p_AgrId'        ||' => '||p_AgrId||','||
                                              'p_ChangeDate'  ||' => '||p_ChangeDate||','||
                                              'p_PayAmount'   ||' => '||p_PayAmount||','||
                                              'p_PayDate'     ||' => '||p_PayDate||')');
  p_Status := char_to_sap('OK');

  --преобразуем дату изменеиня
  begin
     select decode(p_ChangeDate ,'00000000',null,to_date(p_ChangeDate , 'YYYYMMDD')),
            decode(p_PayDate    ,'00000000',null,to_date(p_PayDate    , 'YYYYMMDD'))
      into l_ChangeDate,
           l_PayDate
      from dual;
  exception
    when others then
     l_ChangeDate := null;
     l_PayDate := null;
  end;

  if l_ChangeDate is not null and l_PayDate is not null then

    l_ubrr_sap_ziu_temp_gtt.nagrid      := p_AgrId;
    l_ubrr_sap_ziu_temp_gtt.cchangetype := 'GR_REPAY';
    l_ubrr_sap_ziu_temp_gtt.npart       := 1;
    l_ubrr_sap_ziu_temp_gtt.cterm       := '';
    l_ubrr_sap_ziu_temp_gtt.msum        := p_PayAmount;
    l_ubrr_sap_ziu_temp_gtt.dgrdate     := l_PayDate;
    l_ubrr_sap_ziu_temp_gtt.catribut    := '';
    l_ubrr_sap_ziu_temp_gtt.dchangedate := l_ChangeDate;

    insert into UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT
         values l_ubrr_sap_ziu_temp_gtt;

  else
    raise_application_error(-20000,'ZIU_Repayment_Schedule. Неверный формат дат YYYYMMDD или пустые значение.');
  end if;

  ZIU_Write_Log('End ZIU_Repayment_Schedule ОК');

EXCEPTION
  WHEN OTHERS THEN
    ZIU_Write_Log('EXCEPTION ZIU_Repayment_Schedule '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    p_Status   := char_to_sap('ERR');
    p_ErrorMsg := char_to_sap(TS.To_2000 ('Ошибка:'||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace));
END;

-------------------------------------------------------------------------------
-- Процедура добавления данных в таблицу для изменения графика изменения лимита
-------------------------------------------------------------------------------
PROCEDURE ZIU_Limit_Change_Schedule( p_AgrId            in number,      -- Код кредитного договора
                                     p_ChangeDate       in varchar2,    -- Дата внесения изменеия (дата с)
                                     p_LimAmount        in number,      -- Сумма
                                     p_LimDate          in varchar2,    -- Дата
                                     p_Status           out varchar2,   -- Статус
                                     p_ErrorMsg         out varchar2    -- Сообщение об ошибке
                                   )
 is

  l_ChangeDate               date;
  l_LimDate                  date;
  l_ubrr_sap_ziu_temp_gtt    UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT%rowtype;

BEGIN
  ZIU_Write_Log('Start ZIU_Limit_Change_Schedule(p_AgrId'       ||' => '||p_AgrId||','||
                                                'p_ChangeDate'  ||' => '||p_ChangeDate||','||
                                                'p_LimAmount'   ||' => '||p_LimAmount||','||
                                                'p_LimDate'     ||' => '||p_LimDate||')');
  p_Status := char_to_sap('OK');

  --преобразуем дату изменеиня
  begin
     select decode(p_ChangeDate ,'00000000',null,to_date(p_ChangeDate , 'YYYYMMDD')),
            decode(p_LimDate    ,'00000000',null,to_date(p_LimDate    , 'YYYYMMDD'))
      into l_ChangeDate,
           l_LimDate
      from dual;
  exception
    when others then
     l_ChangeDate := null;
     l_LimDate := null;
  end;

  if l_ChangeDate is not null and p_LimDate is not null then

    l_ubrr_sap_ziu_temp_gtt.nagrid      := p_AgrId;
    l_ubrr_sap_ziu_temp_gtt.cchangetype := 'GR_LIMIT';
    l_ubrr_sap_ziu_temp_gtt.npart       := 1;
    l_ubrr_sap_ziu_temp_gtt.cterm       := 'LIMIT';
    l_ubrr_sap_ziu_temp_gtt.msum        := p_LimAmount;
    l_ubrr_sap_ziu_temp_gtt.dgrdate     := l_LimDate;
    l_ubrr_sap_ziu_temp_gtt.catribut    := '';
    l_ubrr_sap_ziu_temp_gtt.dchangedate := l_ChangeDate;

    insert into UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT
         values l_ubrr_sap_ziu_temp_gtt;

  else
    raise_application_error(-20000,'ZIU_Limit_Change_Schedule. Неверный формат дат YYYYMMDD или пустые значение.');
  end if;

  ZIU_Write_Log('End ZIU_Limit_Change_Schedule ОК');

EXCEPTION
  WHEN OTHERS THEN
    ZIU_Write_Log('EXCEPTION ZIU_Limit_Change_Schedule '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    p_Status   := char_to_sap('ERR');
    p_ErrorMsg := char_to_sap(TS.To_2000 ('Ошибка:'||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace));
END;

-------------------------------------------------------------------------------
-- Процедура добавления данных в таблицу для изменеия обеспечания
-------------------------------------------------------------------------------
PROCEDURE ZIU_Change_Zalog( p_AgrId            in number,      -- Код кредитного договора
                            p_ChangeDate       in varchar2,    -- Дата внесения изменеия (дата с)
                            p_Atribut          in varchar2,    -- Номер документа залога
                            p_Amount           in number,      -- Сумма
                            p_Status           out varchar2,   -- Статус
                            p_ErrorMsg         out varchar2    -- Сообщение об ошибке
                          )
 is

  l_ChangeDate               date;
  l_ubrr_sap_ziu_temp_gtt    UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT%rowtype;

BEGIN
  ZIU_Write_Log('Start ZIU_Change_Zalog(p_AgrId'       ||' => '||p_AgrId||','||
                                       'p_ChangeDate'  ||' => '||p_ChangeDate||','||
                                       'p_Atribut'     ||' => '||p_Atribut||','||
                                       'p_Amount'      ||' => '||p_Amount||')');
  p_Status := char_to_sap('OK');

  --преобразуем дату изменеиня
  begin
     select decode(p_ChangeDate ,'00000000',null,to_date(p_ChangeDate , 'YYYYMMDD'))
      into l_ChangeDate
      from dual;
  exception
    when others then
     l_ChangeDate := null;
  end;

  if l_ChangeDate is not null then

    l_ubrr_sap_ziu_temp_gtt.nagrid      := p_AgrId;
    l_ubrr_sap_ziu_temp_gtt.cchangetype := 'CH_ZALOG';
    l_ubrr_sap_ziu_temp_gtt.npart       := '';
    l_ubrr_sap_ziu_temp_gtt.cterm       := '';
    l_ubrr_sap_ziu_temp_gtt.msum        := p_Amount;
    l_ubrr_sap_ziu_temp_gtt.dgrdate     := '';
    l_ubrr_sap_ziu_temp_gtt.catribut    := char_convert.char_from_sap(p_Atribut);
    l_ubrr_sap_ziu_temp_gtt.dchangedate := l_ChangeDate;

    insert into UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT
         values l_ubrr_sap_ziu_temp_gtt;

  else
    raise_application_error(-20000,'ZIU_Change_Zalog. Неверный формат даты изменения YYYYMMDD или пустое значение.');
  end if;

  ZIU_Write_Log('End ZIU_Change_Zalog ОК');

EXCEPTION
  WHEN OTHERS THEN
    ZIU_Write_Log('EXCEPTION ZIU_Change_Zalog '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    p_Status   := char_to_sap('ERR');
    p_ErrorMsg := char_to_sap(TS.To_2000 ('Ошибка:'||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace));
END;

-------------------------------------------------------------------------------
-- Процедура очистки временных данных
-------------------------------------------------------------------------------
PROCEDURE ZIU_Clear_ubrr_sap_ziu_temp
  is
BEGIN
  delete from UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT;
END;

-------------------------------------------------------------------------------
-- Процедура очистки временных данных, урегулирование стоимости залога
-------------------------------------------------------------------------------
PROCEDURE ZIU_Clear_Temp_Zalog( p_AgrId            in number,      -- Код кредитного договора
                                p_session          in varchar2     -- Сессия пользователя
                               )
  is
  pragma autonomous_transaction;
BEGIN
  CDENV.Clear_Temp_Table('CD1');
  CDENV.Clear_Temp_Table('CDT');
  CDENV.Clear_Temp_Table('CDD');
  CDENV.Clear_Temp_Table('CDTC');
  CDENV.Clear_Temp_Table('CDT_CDTC');

  delete from CD1 where CD1.NCD1AGRID = p_AgrId and CD1.CCD1SESSION = p_session;
  delete from CDD where CDD.NCDDAGRID = p_AgrId and CDD.CCDDSESSIONID = p_session;
  delete from CDT where CDT.NCDTAGRID = p_AgrId and CDT.CCDTSESSIONID = p_session;
  delete from CDTC where CDTC.NCDTAGRID = p_AgrId and CDTC.CCDTSESSIONID = p_session;
  delete from CDT_CDTC where CDT_CDTC.CCDTSESSIONID = p_session;

  CD2TRN.Del_AllDocTun;
  dbms_sql_add.commit;
END;

-------------------------------------------------------------------------------
-- Процедура урегулирование стоимости залога
-------------------------------------------------------------------------------
PROCEDURE ZIU_Settlement_Zalog( p_AgrId            in number,      -- Код кредитного договора
                                p_ABS              in varchar2,    -- Филиал
                                p_ChangeDate       in varchar2,    -- Дата внесения изменеия (дата с)
                                p_Status           out varchar2,   -- Статус
                                p_ErrorMsg         out varchar2    -- Сообщение об ошибке
                               )
  is

  cursor cur_czh(par_AgrId in xxi."czo".NCZOAGRID%type, par_ddate in xxi.czh.dczhdate%type) is
  select count(t.iczh)
    from xxi.czh t
   where t.NCZHCZO in (select a.ICZO
                         from  xxi."czo" a
                        where a.NCZOAGRID  = par_AgrId
                     )
     and t.dczhdate = par_ddate;

  cursor cur_sap(par_sesion in varchar2) is
  select TS.To_2000 (LISTAGG(aa.ccapmessage, ' ') WITHIN GROUP (ORDER BY aa.ICAPID desc) )
    from CAP aa
   where aa.ccapsessionid = par_sesion
     and aa.ccaplevel = 'E'
  order by aa.ICAPID desc;

  l_session       varchar2(64) := UserEnv('SESSIONID');
  l_CurrentIdsmr  smr.idsmr%type := ubrr_get_context; --первичный филиал
  l_StMsg         VARCHAR2(20);
  l_CountErr      NUMBER := 0;
  l_CountAcs      NUMBER := 0;
  l_ErrMsg        VARCHAR2 (2000);
  l_ChangeDate    date;
  l_operdate      date;
  l_count_czh     NUMBER := 0;

  l_RegUser       xxi.usr.cusrlogname%type;

  function get_userid( p_usr varchar2 default null )
  return number
  is
    v_res usr.iusrid%type;
  begin
    select iusrid
      into v_res
      from usr
     where cusrlogname = coalesce(p_usr, user);
    return v_res;
  exception
    when no_data_found then
      return null;
  end get_userid;

BEGIN
  ZIU_Write_Log('Start ZIU_Settlement_Zalog(p_AgrId'       ||' => '||p_AgrId||','||
                                           'p_ABS'         ||' => '||p_ABS||','||
                                           'p_ChangeDate'  ||' => '||p_ChangeDate||')');

  p_Status := char_to_sap('OK');

  --преобразуем дату изменеиня
  begin
     select decode(p_ChangeDate ,'00000000',null,to_date(p_ChangeDate , 'YYYYMMDD'))
      into l_ChangeDate
      from dual;
  exception
    when others then
     l_ChangeDate := null;
  end;

  if l_ChangeDate is null then
    raise_application_error(-20000,'ZIU_Settlement_Zalog. Неверный формат даты внесения изменения YYYYMMDD или пустое значение.');
  end if;

  --если текущий филиал не равен указанному в параметрах переключимся
  if l_CurrentIdsmr <> p_ABS then
    XXI_CONTEXT.Set_IDSmr (p_ABS);
  end if;

  open cur_czh(p_AgrId,l_ChangeDate);
  fetch cur_czh into l_count_czh;
  close cur_czh;

  if l_count_czh > 0 then

    -- очистка временных данных, урегулирование стоимости залога
    ZIU_Clear_Temp_Zalog(p_AgrId    => p_AgrId,
                         p_session  => l_session
                         );

    l_ErrMsg := cdenv.test_lock_cd1 (p_AgrId);
    IF l_ErrMsg = 'OK' THEN
      l_ErrMsg := cdenv.test_lock_cdd (p_AgrId);
    END IF;

    IF l_ErrMsg != 'OK' THEN
       raise_application_error(-20000,'ZIU_Settlement_Zalog. Договор '||p_AgrId||' уже отфильтрован для формирования документопроводок! Обрабатывается пользователем ' || l_ErrMsg);
    ELSE

      INSERT INTO CD1(ncd1AGRID,CCD1SESSION)
               VALUES(p_AgrId,l_session);

      IF PREF.Get_Preference(USER,'Type_Set_CDTdate_from_LSdate')='TRUE' THEN
        l_operdate := CD.get_LSdate;
      ELSE
        l_operdate := l_ChangeDate/*TRUNC(SYSDATE)*/;
      END IF;

      --пересчитаем данные
      cdevents.recalc_cdd_one(agrid    => p_AgrId,
                              evdate   => l_ChangeDate,
                              typemask => '61#62#161#162#'
                              );


      cd2trn.set_acc_cur(null);
      cd2trn.Set_Cur_KBNK(NULL);
      cd2trn.Set_Acc_Out_Cur(NULL);

      --выбрали запись и указали сумму
      begin
        update CDD t
           set t.ccddMARKED = 1,
               t.mcddevtsum = t.mcddsum
         where t.ncddagrid = p_AgrId
           and t.ccddsessionid = l_session
           --только то что меняли в дату, то и выбираем
           and exists(select 1
                        from  xxi.czh tt, xxi."czo" a
                       where tt.NCZHCZO = a.ICZO
                         and a.NCZOAGRID  = t.ncddagrid
                         and tt.nczhczo = t.ncddczo
                         and tt.dczhdate = l_ChangeDate
                     );
      exception
        when NO_DATA_FOUND then
          raise_application_error(-20000,'ZIU_Settlement_Zalog. По договору '||p_AgrId||' нет пересчитанных данных залога для обновления (таблица CDD)');
      end;

      l_RegUser := ni_action.fGetAdmUser(ubrr_get_context);

      xxi.triggers.setuser(l_RegUser);
      abr.triggers.setuser(l_RegUser);
      access_2.cur_user_id := get_userid(l_RegUser);

      --подготовим возможные документопроводок
      l_StMsg := cd2trn.populate_cdt(errmsg         => l_ErrMsg,
                                     docdate        => l_operdate,
                                     regdate        => l_operdate,
                                     valdate        => l_operdate,
                                     flag_procedure => 'SWIFT'
                                     );
      if l_StMsg != 'OK' then

        if l_ErrMsg is null then
          open cur_sap(l_session);
          fetch cur_sap into l_ErrMsg;
          close cur_sap;
        end if;

        raise_application_error(-20000,'ZIU_Settlement_Zalog. CD2TRN.Populate_CDT ErrMsg = '||l_ErrMsg);
      end if;

      --генерация проводок и действий
      l_CountErr := CD2TRN.CDT2TRN(outmsg =>l_ErrMsg,
                                   outcnt =>l_CountAcs
                                   );

      xxi.triggers.setuser(null);
      abr.triggers.setuser(null);
      access_2.cur_user_id := get_userid();

      if l_CountErr <> 0 then
        raise_application_error(-20000,'ZIU_Settlement_Zalog. CD2TRN.CDT2TRN OutMESSAGE = '||l_ErrMsg);
      end if;

      CDCOMPL.Init_Tab;

      -- очистка временных данных, урегулирование стоимости залога
      ZIU_Clear_Temp_Zalog(p_AgrId    => p_AgrId,
                           p_session  => l_session
                           );
    END IF;

  end if;

  --вернемся в нужный филиал
  if l_CurrentIdsmr <> ubrr_get_context then
    XXI_CONTEXT.Set_IDSmr(l_CurrentIdsmr);
  end if;

  ZIU_Write_Log('End ZIU_Settlement_Zalog ОК');

EXCEPTION
  WHEN OTHERS THEN
    ZIU_Write_Log('EXCEPTION ZIU_Settlement_Zalog '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    p_Status   := char_to_sap('ERR');
    p_ErrorMsg := char_to_sap(TS.To_2000 ('Ошибка урегулирования стоимости залога :'||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace));

    xxi.triggers.setuser(null);
    abr.triggers.setuser(null);
    access_2.cur_user_id := get_userid();

    -- очистка временных данных, урегулирование стоимости залога
    ZIU_Clear_Temp_Zalog(p_AgrId    => p_AgrId,
                         p_session  => l_session
                         );
END;

-------------------------------------------------------------------------------
-- Процедура изменения КД. ЗИУ для кредитов по короткой схеме (основная)
-------------------------------------------------------------------------------
PROCEDURE ZIU_Change_Agr( p_AgrId            in number,      -- Код кредитного договора
                          p_ABS              in varchar2,    -- Филиал
                          p_ChangeDate       in varchar2,    -- Дата внесения изменеия (дата с)
                          p_UpdRate          in varchar2,    -- Признак изменения (Процентная ставка)
                          p_Rate             in number,      -- Процентная ставка
                          p_UpdPenyRate      in varchar2,    -- Признак изменения (Пени на ОД)
                          p_PenyRate         in number,      -- Пени на ОД
                          p_UpdPenyType      in varchar2,    -- Признак изменения (Тип пеней на ОД)
                          p_PenyType         in number,      -- Тип пеней на ОД (дневные 0, годовые 1)
                          p_UpdPenyRate2     in varchar2,    -- Признак изменения (Пени на проценты)
                          p_PenyRate2        in number,      -- Пени на проценты
                          p_UpdPeny2Type     in varchar2,    -- Признак изменения (Тип пеней на процент)
                          p_PenyType2        in number,      -- Тип пеней на проценты (дневные 0, годовые 1)
                          p_UpdAmount2       in varchar2,    -- Признак изменения (Сумма заявки)
                          p_Amount2          in number,      -- Сумма заявки
                          p_CURR2            in varchar2,    -- Валюты заявки (Для проверки с текущей валютой кредитного договора)
                          p_UpdEndDate       in varchar2,    -- Признак изменения (Дата окончаиня договора)
                          p_EndDate_Old      in varchar2,    -- Дата окончания договора (старая дата)
                          p_EndDate_New      in varchar2,    -- Дата окончания договора (новая дата)
                          p_PerctermID       in number,      -- id Срока оплаты %%
                          p_UpdBicAcc        in varchar2,    -- Признак изменения (реквизитов)
                          p_caccacc          in varchar2,    -- Текущий счет
                          p_BIC              in varchar2,    -- БИК банка
                          p_UpdRepaySch      in varchar2,    -- Признак изменения (График гашения)
                          p_UpdLimitSch      in varchar2,    -- Признак изменения (График изменения лимита)
                          p_CrdType2         in number,      -- Тип КД
                          p_UpdZalog         in varchar2,    -- Признак изменения (Изменение стоимости обесепчения/ Прекращение обеспечения сумма 0 )
                          p_Status           out varchar2,   -- Статус
                          p_ErrorMsg         out varchar2    -- Сообщение об ошибке
                         )
  IS

  cursor cur_cda(par_AgrId in xxi.cda.NCDAAGRID%type) is
  select a.*
    from xxi.cda a
   where a.NCDAAGRID = par_AgrId;

  cursor cur_cdh(par_AgrId      in xxi.cdh.ncdhagrid%type,
                 par_ChangeDate in xxi.cdh.dcdhdate%type,
                 par_term       in varchar2) is
  select a.*
    from xxi.cdh a
   where a.ncdhagrid = par_AgrId
     and regexp_like(a.ccdhterm,'^('||par_term||')')
     and a.dcdhdate > par_ChangeDate;

  cursor cur_gr_temp(par_AgrId         in UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.NAGRID%type,
                     par_changedate    in UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.DCHANGEDATE%type,
                     par_changetype    in UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.CCHANGETYPE%type) is
  select t.*
    from UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT t
   where t.nagrid = par_AgrId
     and t.dchangedate = par_changedate
     and t.cchangetype = par_changetype;

  cursor cur_doc_zalog(par_AgrId      in xxi.cdh_doc.ncdhagrid%type,
                       par_Atribut    in xxi.cdh_doc.ccdhatribut%type) is
  select a.icdhid,
         count(a.ccdhatribut) over (order by a.ncdhagrid ) as kol
    from xxi.cdh_doc a
   where a.ncdhagrid = par_AgrId
     and a.ccdhatribut = par_Atribut;

  cursor cur_czh_zalog(par_AgrId      in xxi.cdh_doc.ncdhagrid%type,
                       par_IdDOC      in xxi."czo".NCZOIDDOC%type) is
  select *
    from  xxi.czh
   where NCZHCZO in (select a.ICZO from  xxi."czo" a
                      where a.NCZOAGRID  = par_AgrId
                        and a.NCZOIDDOC  = par_IdDOC
                     );

  LOCKED_AGR      EXCEPTION;
  PRAGMA          EXCEPTION_INIT(LOCKED_AGR, -54);

  type t_tbl_gr_temp is table of cur_gr_temp%rowtype index by binary_integer;
  l_tbl_gr_temp   t_tbl_gr_temp;

  l_rec_cda       cur_cda%rowtype;
  l_rec_cdh       cur_cdh%rowtype;
  l_rec_doc_zalog cur_doc_zalog%rowtype;
  l_rec_czh_zalog cur_czh_zalog%rowtype;

  l_CurrentIdsmr  smr.idsmr%type := ubrr_get_context; --первичный филиал
  l_CurrentDate   date := TRUNC(sysdate);
  l_ChangeDate    date;
  l_EndDate_New   date;
  l_EndDate_Old   date;
  l_KodF          number;
  l_cACC          varchar2(25);
  l_IDKBNK        number;
  l_NameBankFOG   varchar2(128);
  l_IsFOG         number;
  l_IsAccSSB      NUMBER;
  l_CurrentBIC    xxi.smr.CSMRMFO8%type;
  l_errmessage    varchar2(2000);
  l_prmessage     varchar2(2000);

  --
  procedure set_errormsg(par_ErrorMsg in varchar2)
    is
  begin
    ZIU_Write_Log('ZIU_Change_Agr Предупреждения: '||par_ErrorMsg);
    if l_prmessage is null then
      l_prmessage := par_ErrorMsg ;
    else
      l_prmessage := TS.To_2000(l_prmessage ||'#'|| par_ErrorMsg);
    end if;
  end;

  procedure close_cursor
    is
  begin
    if cur_cda%isopen then close cur_cda; end if;
    if cur_cdh%isopen then close cur_cdh; end if;
    if cur_gr_temp%isopen then close cur_gr_temp; end if;
    if cur_doc_zalog%isopen then close cur_doc_zalog; end if;
    if cur_czh_zalog%isopen then close cur_czh_zalog; end if;
  end;

BEGIN
  ZIU_Write_Log('Start ZIU_Change_Agr(p_AgrId'        ||' => '||p_AgrId||','||
                                     'p_ABS'          ||' => '||p_ABS||','||
                                     'p_ChangeDate'   ||' => '||p_ChangeDate||','||
                                     'p_UpdRate'      ||' => '||p_UpdRate||','||
                                     'p_Rate'         ||' => '||p_Rate||','||
                                     'p_UpdPenyRate'  ||' => '||p_UpdPenyRate||','||
                                     'p_PenyRate'     ||' => '||p_PenyRate||','||
                                     'p_UpdPenyType'  ||' => '||p_UpdPenyType||','||
                                     'p_PenyType'     ||' => '||p_PenyType||','||
                                     'p_UpdPenyRate2' ||' => '||p_UpdPenyRate2||','||
                                     'p_PenyRate2'    ||' => '||p_PenyRate2||','||
                                     'p_UpdPeny2Type' ||' => '||p_UpdPeny2Type||','||
                                     'p_PenyType2'    ||' => '||p_PenyType2||','||
                                     'p_UpdAmount2'   ||' => '||p_UpdAmount2||','||
                                     'p_Amount2'      ||' => '||p_Amount2||','||
                                     'p_CURR2'        ||' => '||p_CURR2||','||
                                     'p_UpdEndDate'   ||' => '||p_UpdEndDate||','||
                                     'p_EndDate_Old'  ||' => '||p_EndDate_Old||','||
                                     'p_EndDate_New'  ||' => '||p_EndDate_New||','||
                                     'p_PerctermID'   ||' => '||p_PerctermID||','||
                                     'p_UpdBicAcc'    ||' => '||p_UpdBicAcc||','||
                                     'p_caccacc'      ||' => '||p_caccacc||','||
                                     'p_BIC'          ||' => '||p_BIC||','||
                                     'p_UpdRepaySch'  ||' => '||p_UpdRepaySch||','||
                                     'p_UpdLimitSch'  ||' => '||p_UpdLimitSch||','||
                                     'p_CrdType2'     ||' => '||p_CrdType2||','||
                                     'p_UpdZalog'     ||' => '||p_UpdZalog||')');
  p_Status := char_to_sap('OK');

  --если текущий филиал не равен указанному в параметрах переключимся
  if l_CurrentIdsmr <> p_ABS then
    XXI_CONTEXT.Set_IDSmr (p_ABS);
  end if;

  select CSMRMFO8
    into l_CurrentBIC
    from smr;

  --преобразуем дату изменеиня
  begin
     select decode(p_ChangeDate ,'00000000',null,to_date(p_ChangeDate , 'YYYYMMDD'))
      into l_ChangeDate
      from dual;
  exception
    when others then
     l_ChangeDate := null;
  end;

  if l_ChangeDate is null then
    raise_application_error(-20000,'ZIU_Change_Agr. Неверный формат даты внесения изменения YYYYMMDD или пустое значение.');
  end if;

  --провеим что такой котракт есть
  open cur_cda(p_AgrId);
  fetch cur_cda into l_rec_cda;
  if cur_cda%notfound then
    raise_application_error(-20000,'ZIU_Change_Agr. Договор c №'||p_AgrId||' не найден');
  end if;
  close cur_cda;

 /* ----------------------------------------
  if 1=1 \*заглушка пока вызываем просто из SAP ничего не делаем *\  then
    raise_application_error (-20000,'Установлена заглушка!!!');
  end if;
  ----------------------------------------*/

  IF (upper(p_UpdRate) = 'X' or upper(p_UpdPenyRate) = 'X' or upper(p_UpdPenyType) = 'X' or upper(p_UpdPenyRate2) = 'X' or upper(p_UpdPeny2Type) = 'X') THEN

    --6.1.13.3.2.  Собственно % ставка
    if upper(p_UpdRate) = 'X' then

      cd.update_history(agrid   => l_rec_cda.ncdaagrid,
                        part    => null,
                        term    => 'INTRATE',
                        effdate => l_ChangeDate,
                        mval    => null,
                        pval    => p_Rate,
                        ival    => null,
                        cval    => null
                        );

      cd.update_history(agrid   => l_rec_cda.ncdaagrid,
                        part    => null,
                        term    => 'OVDRATE',
                        effdate => l_ChangeDate,
                        mval    => null,
                        pval    => p_Rate,
                        ival    => null,
                        cval    => null
                        );

      if l_ChangeDate > l_CurrentDate then
        set_errormsg('Процентная ставка установлена будущей датой '|| to_char(l_ChangeDate,'DD.MM.YYYY') ||'.' );
      end if;

      l_rec_cdh := null;
      open cur_cdh(l_rec_cda.ncdaagrid,l_ChangeDate,'INTRATE|OVDRATE');
      fetch cur_cdh into l_rec_cdh;
      close cur_cdh;

      if l_rec_cdh.ncdhagrid is not null then
        set_errormsg('В КД есть установленные ранее % ставки с датами > '|| to_char(l_ChangeDate,'DD.MM.YYYY') ||', проверьте необходимость их удаления.' );
      end if;
    end if;

    --6.1.13.3.3.  Собственно тип и % пени на ОД и %
    --Пени на ОД
    if upper(p_UpdPenyRate) = 'X' then
      cd.update_history(agrid   => l_rec_cda.ncdaagrid,
                        part    => null,
                        term    => 'LOANFINE',
                        effdate => l_ChangeDate,
                        mval    => null,
                        pval    => p_PenyRate,
                        ival    => null,
                        cval    => null
                        );

    end if;
    --Тип пеней на ОД
    if upper(p_UpdPenyType) = 'X' then
      cd.update_history(agrid   => l_rec_cda.ncdaagrid,
                        part    => 1,
                        term    => 'LFEETYPE',
                        effdate => l_ChangeDate,
                        mval    => null,
                        pval    => null,
                        ival    => (case when p_PenyType = 0 then 1 else 0 end), --если 0, то год,
                        cval    => null
                        );
    end if;

    --Пени на проценты
    if upper(p_UpdPenyRate2) = 'X' then
      cd.update_history(agrid   => l_rec_cda.ncdaagrid,
                        part    => null,
                        term    => 'INTFINE',
                        effdate => l_ChangeDate,
                        mval    => null,
                        pval    => p_PenyRate2,
                        ival    => null,
                        cval    => null
                        );
    end if;
    --Тип пеней на проценты
    if upper(p_UpdPeny2Type) = 'X' then
      begin
        update xxi.cda a
           set a.ICDAFEETYPE4I = decode(p_PenyType2,0,1,0) --если 0, то год
         where a.NCDAAGRID = l_rec_cda.ncdaagrid;
      end;
    end if;

    if l_ChangeDate > l_CurrentDate and (upper(p_UpdPenyRate) = 'X' or upper(p_UpdPenyType) = 'X' or upper(p_UpdPenyRate2) = 'X' or upper(p_UpdPeny2Type) = 'X') then
      set_errormsg('Процентная пени/тип пени установлены будущей датой '|| to_char(l_ChangeDate,'DD.MM.YYYY') ||'.' );
    end if;

    l_rec_cdh := null;
    open cur_cdh(l_rec_cda.ncdaagrid,l_ChangeDate,'LOANFINE|LFEETYPE|INTFINE');
    fetch cur_cdh into l_rec_cdh;
    close cur_cdh;

    if l_rec_cdh.ncdhagrid is not null and (upper(p_UpdPenyRate) = 'X' or upper(p_UpdPenyType) = 'X' or upper(p_UpdPenyRate2) = 'X') then
      set_errormsg('В КД есть установленные ранее % ставки/тип пени с датами > '|| to_char(l_ChangeDate,'DD.MM.YYYY') ||', проверьте необходимость их удаления.' );
    end if;

  END IF;

  --6.1.13.3.4.  Собственно сумма/валюта
  IF upper(p_UpdAmount2) = 'X' THEN

    if l_rec_cda.ccdacuriso = p_CURR2 then

      update xxi.cda a
         set a.MCDATOTAL = p_Amount2
       where a.NCDAAGRID = l_rec_cda.ncdaagrid;

      --Если вид кредита овердрафт (с изменяемым/неизменяемым лимитом) - то дополнительно заменить для ТНКД в АБС график изменения лимита
      If p_CrdType2 in (2,6) then
        --удаляем старый график
        delete from xxi.cdh a
         where a.ccdhterm = 'LIMIT'
           and a.ncdhagrid = l_rec_cda.ncdaagrid
           and a.dcdhdate >= l_ChangeDate
           and a.icdhpart = 1;

        --добавим запись LIMIT с ДатаС
        cd.update_history(agrid   => l_rec_cda.ncdaagrid,
                          part    => 1,
                          term    => 'LIMIT',
                          effdate => l_ChangeDate,
                          mval    => p_Amount2,
                          pval    => null,
                          ival    => null,
                          cval    => null
                          );
      end if;

    else
      set_errormsg('Изменяется валюта КД – произведите изменения суммы/валюты договора вручную.' );
    end if;
  END IF;

  --6.1.13.3.5.  Собственно дата окончания договора
  IF upper(p_UpdEndDate) = 'X' and p_CrdType2 in (3,4,2,6) THEN

    --преобразуем дату изменеиня
    begin
       select decode(p_EndDate_New ,'00000000',null,to_date(p_EndDate_New , 'YYYYMMDD')),
              decode(p_EndDate_Old ,'00000000',null,to_date(p_EndDate_Old , 'YYYYMMDD'))
         into l_EndDate_New,
              l_EndDate_Old
         from dual;
    exception
      when others then
       l_EndDate_New := null;
       l_EndDate_Old := null;
    end;

    if l_EndDate_New is not null or l_EndDate_Old is not null then

      --6.1.13.3.5.2.  если старая дата окончания < новой даты окончания
      if l_EndDate_Old < l_EndDate_New and p_CrdType2 in (2,6) then
        if p_PerctermID = 999 then
          set_errormsg('Срок уплаты % по спец. графику – произведите продление графика начисления и уплаты % вручную.' );
        else
          ZIU_Calc_Interval(p_agrid      => l_rec_cda.ncdaagrid,
                            p_startdate  => trunc(l_EndDate_Old,'MONTH'),
                            p_finishdate => l_EndDate_New,
                            p_PerctermID => p_PerctermID,
                            p_errmessage => l_errmessage
                           );
          if l_errmessage is not null then
            raise_application_error(-20000,l_errmessage);
          end if;
        end if;
      end if;

      --6.1.13.3.5.3.  если старая дата окончания >  новой даты окончания
      if l_EndDate_Old > l_EndDate_New and p_CrdType2 in (2,6)  then
        set_errormsg('Срок КД уменьшается – произведите скорректируйте график начисления и уплаты % вручную.' );
      end if;

      update xxi.cda a
         set a.dcdalineend = l_EndDate_New
       where a.NCDAAGRID = l_rec_cda.ncdaagrid;
    else
      raise_application_error(-20000,'ZIU_Change_Agr. Неверный формат старой/новой даты окончания договора YYYYMMDD или пустые значение.');
    end if;
  END IF;

  --6.1.13.3.9.  Собственно реквизиты зачисления
  IF upper(p_UpdBicAcc) = 'X' THEN

    select count('x')
      into l_IsFOG
      from FOG
     where CFOGMFO8 = p_BIC;
    if l_IsFOG >0 then
      select CFOGNAME
        into l_NameBankFOG
        from FOG
       where CFOGMFO8 = p_BIC;
    end if;

    begin
      select NBNK_ID
        into l_IDKBNK
        from KBNK
       where CBNK_RBIC = p_BIC;
    exception
      when NO_DATA_FOUND then
      l_IDKBNK := null;
    end;

    select count('x')
      into l_IsAccSSB
      from xxi."acc"
     where CACCACC = p_caccacc
       and CACCCUR = l_rec_cda.ccdacuriso
       and IDSMR = '2';
    begin
      select CACCACC
        into l_cACC
        from ACC
       where CACCACC = p_caccacc and CACCCUR = l_rec_cda.ccdacuriso;
    exception
      when NO_DATA_FOUND then
       l_cACC := null;
    end;

    IF p_BIC is null or p_caccacc is null or p_BIC = '' or p_caccacc = '' or p_BIC = '0' or p_caccacc ='0' or p_BIC = '000000000' or p_caccacc ='00000000000000000000' THEN
      l_KodF := null;
      l_cACC := null;
    ELSIF p_BIC is not null and p_BIC <> '' and (l_IsFOG=0 and l_IDKBNK is null) THEN
      l_KodF := null;
      l_cACC := null;
    ELSIF p_BIC = l_CurrentBIC and l_cACC is not null THEN
      l_KodF := null;
    ELSIF p_BIC = '046577795' and p_ABS = '1' and l_IsAccSSB >0 THEN
      l_KodF := 2903;
      l_cACC := null;
    ELSIF l_IDKBNK is not null THEN
      l_KodF := l_IDKBNK;
      l_cACC := null;
    ELSIF l_IDKBNK is null and p_BIC <> '046577795' THEN
      insert into kbnk (cbnk_rbic, cbnk_name)
                values (p_BIC, l_NameBankFOG)
             returning NBNK_ID into l_IDKBNK;
      l_KodF := l_IDKBNK;
      l_cACC := null;
    ELSE
      l_KodF := null;
      l_cACC := null;
    END IF;

    update xxi.cda a
       set a.CCDACURRENTACC = l_cACC
     where a.ncdaagrid = l_rec_cda.ncdaagrid;

    if l_KodF is not null then

      --удаляем все внешние счета согласно п. 6.1.13.3.9.1
      delete from CDA_ACC_OUT t
        where t.naddagrid = l_rec_cda.ncdaagrid;

      BEGIN
        insert into CDA_ACC_OUT (NADDAGRID,
                                 IADDTYPEOUT,
                                 NADDTYPE,
                                 CADDACC,
                                 CADDCURISO,
                                 NADDKBNKID)
                        values (l_rec_cda.ncdaagrid,
                                2,
                                2,
                                p_caccacc,
                                l_rec_cda.ccdacuriso,
                                l_KodF);

      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          null;
      END;
    end if;
  END IF;

  --6.1.13.3.6.  Собственно график гашения
  IF upper(p_UpdRepaySch) = 'X' and p_CrdType2 in ( 1 ) THEN

    --удаляем старый график
    delete from xxi.cdr a
      where a.ncdragrid = l_rec_cda.ncdaagrid
        and a.dcdrdate >= l_ChangeDate
        and a.icdrpart = 1;

    l_tbl_gr_temp.delete;

    --добавим новый
    --Вернем значения из временной таблицы
    open cur_gr_temp(l_rec_cda.ncdaagrid,l_ChangeDate,'GR_REPAY');
    fetch cur_gr_temp bulk collect into l_tbl_gr_temp;
    close cur_gr_temp;

    if l_tbl_gr_temp.count() = 0  then
      raise_application_error(-20000,'ZIU_Change_Agr. Установлен признак измения графика гашения, но нет новых данных для даного КД.');
    end if;

    for i in l_tbl_gr_temp.first .. l_tbl_gr_temp.last
      loop
        --добавим из переданного графика то что больше ДатаС
        if l_tbl_gr_temp(i).dgrdate >= l_ChangeDate then
          BEGIN
            insert into xxi.cdr( ncdragrid,
                                 icdrpart,
                                 dcdrdate,
                                 mcdrsum,
                                 dcdrlatest
                                )
                         values( l_tbl_gr_temp(i).nagrid,
                                 l_tbl_gr_temp(i).npart,
                                 l_tbl_gr_temp(i).dgrdate,
                                 l_tbl_gr_temp(i).msum,
                                 l_tbl_gr_temp(i).dgrdate
                                );
          EXCEPTION
             WHEN DUP_VAL_ON_INDEX THEN
               raise_application_error(-20000,'ZIU_Change_Agr. При измение графика гашения нарушено ограничение уникальности для данного КД.');
          END;
        end if;
      end loop;

  END IF;

  --6.1.13.3.7.  Собственно график изменения лимита
  IF upper(p_UpdLimitSch) = 'X' and p_CrdType2 in (3, 4, 2, 6) THEN

    --удаляем старый график
    delete from xxi.cdh a
     where a.ccdhterm = 'LIMIT'
       and a.ncdhagrid = l_rec_cda.ncdaagrid
       and a.dcdhdate >= l_ChangeDate
       and a.icdhpart = 1;

    l_tbl_gr_temp.delete;

    --добавим новый
    --Вернем значения из временной таблицы
    open cur_gr_temp(l_rec_cda.ncdaagrid,l_ChangeDate,'GR_LIMIT');
    fetch cur_gr_temp bulk collect into l_tbl_gr_temp;
    close cur_gr_temp;

    if l_tbl_gr_temp.count() = 0  then
      raise_application_error (-20000,'ZIU_Change_Agr. Установлен признак измения графика изменения лимита, но нет новых данных для даного КД.');
    end if;

    for i in l_tbl_gr_temp.first .. l_tbl_gr_temp.last
      loop
        --добавим из переданного графика то что больше ДатаС
        if l_tbl_gr_temp(i).dgrdate >= l_ChangeDate then
          cd.update_history(agrid   => l_tbl_gr_temp(i).nagrid,
                            part    => l_tbl_gr_temp(i).npart,
                            term    => l_tbl_gr_temp(i).cterm,
                            effdate => l_tbl_gr_temp(i).dgrdate,
                            mval    => l_tbl_gr_temp(i).msum,
                            pval    => null,
                            ival    => null,
                            cval    => null
                            );
        end if;
      end loop;

  END IF;

  --6.1.13.3.8.  Собственно договоры обеспечения
  IF upper(p_UpdZalog) = 'X' THEN

    l_tbl_gr_temp.delete;

    --Вернем значения из временной таблицы
    open cur_gr_temp(l_rec_cda.ncdaagrid,l_ChangeDate,'CH_ZALOG');
    fetch cur_gr_temp bulk collect into l_tbl_gr_temp;
    close cur_gr_temp;

    if l_tbl_gr_temp.count() = 0  then
      raise_application_error (-20000,'ZIU_Change_Agr. Установлен признак измения обеспечения, но нет данных для даного КД.');
    end if;

    for i in l_tbl_gr_temp.first .. l_tbl_gr_temp.last
      loop

        --6.1.13.3.8.1. Если изменяется залоговая стоимость l_tbl_gr_temp(i).msum > 0
        --6.1.13.3.8.2. Если прекращается действие договоров обеспечения (сумма 0) l_tbl_gr_temp(i).msum = 0
        l_rec_doc_zalog := null;

        open cur_doc_zalog(l_tbl_gr_temp(i).nagrid,l_tbl_gr_temp(i).catribut);
        fetch cur_doc_zalog into l_rec_doc_zalog;
        close cur_doc_zalog;

        if l_rec_doc_zalog.kol = 1 then

          open cur_czh_zalog(l_tbl_gr_temp(i).nagrid,l_rec_doc_zalog.icdhid);
          fetch cur_czh_zalog into l_rec_czh_zalog;
          close cur_czh_zalog;

          SELECT S_CZH.nextval
            into l_rec_czh_zalog.iczh
            from sys.dual;

          l_rec_czh_zalog.cczhoperator := USER;
          l_rec_czh_zalog.nczhsumma := l_tbl_gr_temp(i).msum;
          l_rec_czh_zalog.mczhsumliquid := l_tbl_gr_temp(i).msum;
          l_rec_czh_zalog.dczhdate := l_ChangeDate;

          --если есть в дату изменения
          delete from xxi.czh a
              where a.nczhczo = l_rec_czh_zalog.nczhczo
                and a.dczhdate = l_rec_czh_zalog.dczhdate;

          --добавим новую
          insert into xxi.czh (ICZH,
                               NCZHCZO,
                               DCZHDATE,
                               NCZHSUMMA,
                               CCZHOPERATOR,
                               CCZHCOMMENT,
                               MCZHSUMLIQUID,
                               NCZHDOCID,
                               CCZHCURLIQUID
                               )
                       values (l_rec_czh_zalog.iczh,
                               l_rec_czh_zalog.nczhczo,
                               l_rec_czh_zalog.dczhdate,
                               l_rec_czh_zalog.nczhsumma,
                               l_rec_czh_zalog.cczhoperator,
                               decode(l_rec_czh_zalog.nczhsumma,0,'Списание всего залога','Изменение стоимости обеспечение'),
                               l_rec_czh_zalog.mczhsumliquid,
                               l_rec_czh_zalog.nczhdocid,
                               l_rec_czh_zalog.cczhcurliquid
                               );

        else
          set_errormsg('К КД '||l_tbl_gr_temp(i).nagrid||' в АБС не найден или не единственный договор обеспечения с юр. номером '||l_tbl_gr_temp(i).catribut||' – произведите по нему изменения вручную.' );
        end if;

      end loop;

  END IF;

  --вернем предупреждения
  if l_prmessage is not null then
    p_ErrorMsg := char_to_sap(l_prmessage);
  end if;

  --вернемся в нужный филиал
  if l_CurrentIdsmr <> ubrr_get_context then
    XXI_CONTEXT.Set_IDSmr(l_CurrentIdsmr);
  end if;

  --очистим таблицу
  ZIU_Clear_ubrr_sap_ziu_temp;

  ZIU_Write_Log('End ZIU_Change_Agr '||utl_raw.cast_to_varchar2(p_status));

EXCEPTION
  WHEN LOCKED_AGR THEN
    dbms_transaction.rollback;
    ZIU_Write_Log('EXCEPTION ZIU_Change_Agr '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    p_Status   := char_to_sap('ERR');
    p_ErrorMsg := char_to_sap('Ошибка : ZIU_Change_Agr. Договор №'||p_AgrId||' заблокирован');
    close_cursor;
    --очистим таблицу
    ZIU_Clear_ubrr_sap_ziu_temp;
  WHEN OTHERS THEN
    dbms_transaction.rollback;
    ZIU_Write_Log('EXCEPTION ZIU_Change_Agr '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    p_Status   := char_to_sap('ERR');
    p_ErrorMsg := char_to_sap(TS.To_2000 ('Ошибка : '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace));
    close_cursor;
    --очистим таблицу
    ZIU_Clear_ubrr_sap_ziu_temp;
END;
--<<22.03.2021  Зеленко С.А.     DKBPA-105 ЭТАП 4.1 (репликация АБС): Формат распоряжения. ЗИУ для кредитов по короткой схеме

END;
/
