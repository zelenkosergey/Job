CREATE OR REPLACE PACKAGE BODY UBRR_XXI5."UBRR_ULFL_COMSS_VER2" is
  /******************************* HISTORY UBRR ***************************************************************\
        Дата        Автор            ID        Описание
    ----------  ---------------  ---------  --------------------------------------------------------------------
    20.10.2015  ubrr pinaev      15-995     АБС: Комиссия за перевод ЮЛ - ФЛ в % https://redmine.lan.ubrr.ru/issues/25034
    13.11.2015  ubrr korolkov    15-1059.3  #25673 446-П. Доработка комиссионных модулей
    09.12.2015  ubrr pinaev      15-995     Ошибка #26464 https://redmine.lan.ubrr.ru/issues/26464
    19.02.2016  Пинаев Д.Е.      #28454     АБС: Комиссия за перевод ЮЛ - ФЛ в %. Исключения платежей.
    10.03.2016  Пинаев Д.Е.      [15-1547]  АБС: Комиссия в пользу ФЛ - проставление кат/гр https://redmine.lan.ubrr.ru/issues/29103
    18.03.2016  Макарова Л.Ю.    [15-1726]  АБС: Исключение из пакетов услуг комиссии в пользу ФЛ https://redmine.lan.ubrr.ru/issues/27519
    05.05.2016  Арсланов Д.Ф.    [16-1808.2.3.5.4.3.2]  #29736  ВУЗ РКО
    16.06.2016  Пинаев Д.Е.      [16-2126]  Доработка комиссионных модулей 446-П (новые счета)
    11.07.2016  Арсланов Д.Ф.    #33232     ВУЗ РКО Пункт договора о безакцептном списании
    23.05.2017  Новолодский А.Ю. [17-71]    АБС: Ошибка списании комиссиий по спецсчету на спецсчет по капремонту
    22.08.2017  Макарова Л.Ю.    [17-1031]  АБС: Добавить слова исключения для расчета комиссии при переводе средств в пользу ФЛ
    23.10.2017  Малых Д.В.       17-1225    АБС: Корректировка комиссии за перевод средств в пользу ФЛ
    04.12.2017  Малых Д.В.                  https://redmine.lan.ubrr.ru/issues/47017#note-69
    09.01.2018  Ёлгин Ю.А.       [17-913.2] АБС: Кат/гр при открытии счета
    21.02.2018  ubrr korolkov    [18-12.1]  АБС: Индивидуальные тарифы по комиссии за платежи в пользу ФЛ для ККК
    19.09.2018  Ризанов Р.Т.     [18-251]   АБС: Слова исключения по комиссии за платежи в пользу ФЛ ("сотрудник")
    12.02.2019  Ризанов Р.Т.     [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
    07.03.2019  Ризанов Р.Т.     [#60292] Ошибка при одновременном взимании комиссий UL_FL и UL_FL_VB            
    12.03.2019  Ризанов Р.Т.     [19-60337]   АБС: Добавление слов исключений в комиссию за внутрибанк в пользу ФЛ
    07.11.2019  Баязитов         [19-62184] Ежедневные комиссии УБРИР
    23.03.2020  Ризанов Р.Т.     [20-73286]   Добавление слов исключений в комиссии в пользу ФЛ
    09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ     
  \******************************* HISTORY UBRR ***************************************************************/

    cg_is_vuz   constant number(1)   := ubrr_util.isVuz; -- 07.11.2017 ubrr korolkov 17-1071
    cg_autab    constant number(3)   := 304;
    cg_112_72   constant varchar2(6) := '112/72';
    cg_112_35   constant varchar2(6) := '112/35';

    /*
    Выбираем подходящие трн
    */
    cursor get_calcTrn(p_d1 DATE, p_d2 DATE, p_mask varchar2, BankIdSmr number) -->><<--04.12.2017 Малых Д.В. https://redmine.lan.ubrr.ru/issues/47017#note-69
    is
    ------------------ межбанковские на ФЛ  -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ    
    select trn.ITRNNUM,
           ctrnaccd,
           ctrncur,
           mtrnsum,
           a.CACCPRIZN,
           a.IDSMR,
           a.iaccotd
            -->>23.10.2017  Малых Д.В.       17-1225   возьмем сумму проводок с начала месяца, текущую не берем.
           , nvl((select sum(mtrnsum)
                  from /*V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v xm -->><<--07.11.2019 Баязитов [19-62184] Ежедневные комиссии УБРИР
                  where xm.ctrnaccd = trn.ctrnaccd
                  and xm.ctrncur=trn.ctrncur
                  and xm.dtrntran between trunc(p_d1, 'MM') and p_d1 -1/86400
                  and xm.ctrnmfoa  not in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr) --! не наши филиалы -> внешний перевод -->><<--04.12.2017 Малых Д.В. https://redmine.lan.ubrr.ru/issues/47017#note-69
                  and ( --!  счет получателя, выделенный из трех полей платежного документа соответствует маскам 40817%,40820% ,423%,426%
                        xm.ctrnacca LIKE '40817%' OR xm.ctrnacca LIKE '40820%' OR
                        xm.ctrnacca LIKE '423%' OR xm.ctrnacca LIKE '426%' OR
                        regexp_substr(xm.CTRNOWNA, '\d{20}') LIKE '40817%' OR
                        regexp_substr(xm.CTRNOWNA, '\d{20}') LIKE '40820%' OR
                        regexp_substr(xm.CTRNOWNA, '\d{20}') LIKE '423%' OR
                        regexp_substr(xm.CTRNOWNA, '\d{20}') LIKE '426%' OR
                        regexp_substr(xm.ctrnpurp, '\d{20}') LIKE '40817%' OR
                        regexp_substr(xm.ctrnpurp, '\d{20}') LIKE '40820%' OR
                        regexp_substr(xm.ctrnpurp, '\d{20}') LIKE '423%' OR
                        regexp_substr(xm.ctrnpurp, '\d{20}') LIKE '426%')
                  and (xm.ITRNTYPE = 4 OR xm.ITRNTYPE = 11 AND EXISTS
                                                                    (select 1
                                                                     from trc
                                                                     where trc.ITRCNUM = xm.ITRNNUMANC
                                                                     and trc.ITRCTYPE = 4))
                  and lower(xm.CTRNPURP) not like '%командир%'
                  and lower(xm.CTRNPURP) not like '%кредит%'
                  and lower(xm.CTRNPURP) not like '%алимент%'
                  and lower(xm.CTRNPURP) not like '%з/п%'
                  and lower(xm.CTRNPURP) not like '%зар%пл%'
                  and lower(xm.CTRNPURP) not like '%аванс%'
                  and lower(xm.CTRNPURP) not like '%благотворит%'
                  and lower(xm.CTRNPURP) not like '%помощ%'
                  and lower(xm.CTRNPURP) not like '%агент%'
                  and lower(xm.CTRNPURP) not like '%подряд%'
                  and lower(xm.CTRNPURP) not like '%пособ%'
                  and lower(xm.CTRNPURP) not like '%стипенд%'
                  and lower(xm.CTRNPURP) not like '%страхов%'
                  and lower(xm.CTRNPURP) not like '%компенсац%'
                  and lower(xm.CTRNPURP) not like '%пенс%'
                  and lower(xm.CTRNPURP) not like '%возмещен%'
                  and lower(xm.CTRNPURP) not like '%отпускн%'
                  and lower(xm.CTRNPURP) not like '%увол%'
                  and lower(xm.CTRNPURP) not like '%преми%'
                  and lower(xm.CTRNPURP) not like '%дивиденд%'
                  and lower(xm.CTRNPURP) not like '%исп%лист%'
                  and lower(xm.CTRNPURP) not like '%судеб%реш%'
                  and lower(xm.CTRNPURP) not like '%реш%взыск%'
                  and lower(xm.CTRNPURP) not like '%уставн%'
                  and lower(xm.CTRNPURP) not like '%учредит%'
                  and lower(xm.CTRNPURP) not like '%предпринимат%'
                  and lower(xm.CTRNPURP) not like '%судебн%'
                  and nvl(regexp_count(lower(xm.CTRNPURP),'труд'),0) = nvl(regexp_count(lower(xm.CTRNPURP),'сотрудник'),0) -- 19.09.2018 ubrr rizanov [18-251] АБС: Слова исключения по комиссии за платежи в пользу ФЛ ("сотрудник")                                           
                  and lower(xm.CTRNPURP) not like '%ипотек%'
                  and lower(xm.CTRNPURP) not like '%ипотеч%'
                  and lower(xm.CTRNPURP) not like '%вознагражд%'
                  and lower(xm.CTRNPURP) not like '%отпуск%'
                  and lower(xm.CTRNPURP) not like '%больничн%лист%'
                  and lower(xm.CTRNPURP) not like '%постановлен%'
                  and lower(xm.CTRNPURP) not like '%суд%приказ%'
                  and lower(xm.CTRNPURP) not like '%зп%'
                  and lower(xm.CTRNPURP) not like '%исполнит%'
                  and lower(xm.CTRNPURP) not like '%гонорар%'
                  and lower(replace(xm.CTRNPURP,' ')) not like '%б/лист%'
                  and lower(replace(xm.CTRNPURP,' ')) not like '%б\лист%'
                  and lower(xm.CTRNPURP) not like '%доход%ип%'
                  and lower(xm.CTRNPURP) not like '%деятельност%ип%'
                  and lower(xm.CTRNPURP) not like '%суточн%'
                  and lower(xm.CTRNPURP) not like '%сутк%'
                  -- >> ubrr 23.03.2020  Ризанов Р.Т.  [20-73286] Добавление слов исключений в комиссии в пользу ФЛ
                  and lower(xm.CTRNPURP) not like '%возвр%тур%'                                
                  and lower(xm.CTRNPURP) not like '%возвр%аннул%'
                  and lower(xm.CTRNPURP) not like '%возвр%проживан%'                                                                
                  -- << ubrr 23.03.2020  Ризанов Р.Т.  [20-73286] Добавление слов исключений в комиссии в пользу ФЛ
                  and lower(replace(xm.CTRNPURP,' ')) not like '%з.пл%'
                  and lower(replace(xm.CTRNPURP,' ')) not like '%з\п%'
                  and lower(replace(xm.CTRNPURP,' ')) not like '%част%приб%'
                  and lower(replace(xm.CTRNPURP,' ')) not like '%межрасч%выплат%'
                  and not exists --если проведенная комиссия есть, например, осталась после удаления, заново НЕ выбираем.
                              (select 1
                               from ubrr_ulfl_tab_acc_coms c
                               where c.DCOMDATERAS = p_d1
                               and c.ICOMTRNNUM IS NOT NULL
                               and c.ccomaccd = xm.CTRNACCD)
                  -->>09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ
                  /*and not exists
                              (select 1
                               from ubrr_unique_tarif
                               where a.caccacc = cacc
                               and xm.dtrncreate between DOPENTARIF and DCANCELTARIF
                               and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)*/
                  --<<09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ             
               ),0)
               SumBefo,
               to_number(to_char(NVL(o.iOTDbatnum,70) )||'00') batnum,
               'UL_FL' ctypecom  -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
              --<<23.10.2017  Малых Д.В.       17-1225    возьмем сумму проводок с начала месяца, текущую не берем.
    from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn, acc a, otd o -->><<--23.10.2017  Малых Д.В.       17-1225   добавил    otd - для batnum (номер пачки) -->><<--07.11.2019 Баязитов [19-62184] Ежедневные комиссии УБРИР
    where cTRNcur = 'RUR'
    and a.iaccotd = o.iotdnum    -->><<--23.10.2017  Малых Д.В.       17-1225   добавил    otd - для batnum (номер пачки)
    and cACCacc = cTRNaccd
    and cTRNaccd like p_mask
    and cACCacc  like p_mask
    and cACCprizn <> 'З'
    and dtrntran between p_d1 and p_d2
    and ((trn.CTRNACCD like '40%' and
          to_number(substr(trn.CTRNACCD, 3, 1)) between 1 and 7) --! счет плательщика соответствует маскам 401-407%,40802%, 40807
          or trn.CTRNACCD like '40802%'
          or trn.CTRNACCD like '40807%'
          or trn.CTRNACCD like '40821%' -- UBRR Новолодский А. Ю. 23.05.2017 [17-71] АБС: Ошибка списании комиссиий по спецсчету на спецсчет по капремонту
        )
    -->>-- 10.03.2016  Пинаев Д.Е.      [15-1547]  АБС: Комиссия в пользу ФЛ - проставление кат/гр  https://redmine.lan.ubrr.ru/issues/29103
    and not exists (select /*+ index(GCS P_GCS_CUS_CAT_NUM)*/ 1
                    from gcs
                    where igcsCus = a.IACCCUS
                    and igcscat = 114
                    and igcsnum = 11
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where i_num = gcs.igcsCus
                                and i_table = 303
                                and d_create <= p_d2
                                and au.c_newdata like '114/' || to_char(gcs.igcsnum)))
    and not exists (select 1
                    from gac
                    where cgacacc = a.cACCacc
                    and cgaccur = a.cACCcur
                    and igaccat = 114
                    and igacnum = 11
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '114/' || to_char(gac.igacnum)))
    --<<-- 10.03.2016  Пинаев Д.Е.      [15-1547]  АБС: Комиссия в пользу ФЛ - проставление кат/гр  https://redmine.lan.ubrr.ru/issues/29103
    and not exists (select 1
                    from gac
                    where cgacacc = a.cACCacc
                    and cgaccur = a.cACCcur
                    and igaccat = 333
                    and igacnum = 2
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '333/' || to_char(gac.igacnum)))
    and not exists (select 1
                    from gac
                    where cgacacc = a.cACCacc
                    and cgaccur = a.cACCcur
                    and igaccat = 112
                    and igacnum in (1, 3, 4, 5, 7, 10, 13, 15, 16, 17, 19, 20, 21, 22, 23, 24, 25, 36, 37, 38, 39, 57, 76,
                                    70, -->><<-- 10.03.2016  Пинаев Д.Е.      [15-1547]  АБС: Комиссия в пользу ФЛ - проставление кат/гр
                                    71) -->><<-- 18.03.2016  Макарова Л.Ю.     [15-1726]  АБС: Комиссия в пользу ФЛ - проставление кат/гр )
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '112/' || to_char(gac.igacnum)))
    and not exists (select 1
                    from gac g1, gac g2
                    where g1.cgacacc = a.cACCacc
                    and g1.cgaccur = a.cACCcur
                    and g2.cgacacc = a.cACCacc
                    and g2.cgaccur = a.cACCcur
                    and g1.igaccat = 333
                    and g1.igacnum = 4
                    and g2.igaccat = 112
                    and g2.igacnum in (74)
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '333/' || to_char(g1.igacnum))
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '112/' || to_char(g2.igacnum)))
    and ( --!  счет получателя, выделенный из трех полей платежного документа соответствует маскам 40817%,40820% ,423%,426%
          trn.ctrnacca LIKE '40817%' OR trn.ctrnacca LIKE '40820%' OR
          trn.ctrnacca LIKE '423%' OR trn.ctrnacca LIKE '426%' OR
          regexp_substr(trn.CTRNOWNA, '\d{20}') LIKE '40817%' OR
          regexp_substr(trn.CTRNOWNA, '\d{20}') LIKE '40820%' OR
          regexp_substr(trn.CTRNOWNA, '\d{20}') LIKE '423%' OR
          regexp_substr(trn.CTRNOWNA, '\d{20}') LIKE '426%' OR
          regexp_substr(trn.ctrnpurp, '\d{20}') LIKE '40817%' OR
          regexp_substr(trn.ctrnpurp, '\d{20}') LIKE '40820%' OR
          regexp_substr(trn.ctrnpurp, '\d{20}') LIKE '423%' OR
          regexp_substr(trn.ctrnpurp, '\d{20}') LIKE '426%')
    and ctrnmfoa not in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr) --! не наши филиалы -> внешний перевод -->><<--04.12.2017 Малых Д.В. https://redmine.lan.ubrr.ru/issues/47017#note-69
    and lower(trn.CTRNPURP) not like '%командир%'
    and lower(trn.CTRNPURP) not like '%кредит%'
    and lower(trn.CTRNPURP) not like '%алимент%'
    and lower(trn.CTRNPURP) not like '%з/п%'
    and lower(trn.CTRNPURP) not like '%зар%пл%'
    and lower(trn.CTRNPURP) not like '%аванс%'
    and lower(trn.CTRNPURP) not like '%благотворит%'
    and lower(trn.CTRNPURP) not like '%помощ%'
    and lower(trn.CTRNPURP) not like '%агент%'
    and lower(trn.CTRNPURP) not like '%подряд%'
    and lower(trn.CTRNPURP) not like '%пособ%'
    and lower(trn.CTRNPURP) not like '%поcоб%' -- 07.11.2017 ubrr korolkov 17-1071 латинская "c"
    and lower(trn.CTRNPURP) not like '%стипенд%'
    and lower(trn.CTRNPURP) not like '%страхов%'
    and lower(trn.CTRNPURP) not like '%компенсац%'
    and lower(trn.CTRNPURP) not like '%пенс%'
    and lower(trn.CTRNPURP) not like '%возмещен%'
    and lower(trn.CTRNPURP) not like '%отпускн%'
    and lower(trn.CTRNPURP) not like '%увол%'
    and lower(trn.CTRNPURP) not like '%преми%'
    and lower(trn.CTRNPURP) not like '%дивиденд%'
    and lower(trn.CTRNPURP) not like '%исп%лист%'
    and lower(trn.CTRNPURP) not like '%судеб%реш%'
    and lower(trn.CTRNPURP) not like '%реш%взыск%'
    and lower(trn.CTRNPURP) not like '%уставн%'
    and lower(trn.CTRNPURP) not like '%учредит%'
    -->> 23.10.2017 Малых Д.В. 17-1225   по ТЗ
    /*
    and lower(trn.CTRNPURP) not like '%подотчет%'
    and lower(trn.CTRNPURP) not like '%подотчёт%'
    and lower(trn.CTRNPURP) not like '%под отчет%'
    and lower(trn.CTRNPURP) not like '%под отчёт%'
    */
    --<< 23.10.2017 Малых Д.В. 17-1225    по ТЗ
    and lower(trn.CTRNPURP) not like '%предпринимат%'
    /*and lower(trn.CTRNPURP) not like '%хоз%нужд%'*/ -->><<--  23.10.2017 Малых Д.В. 17-1225    по ТЗ
    and lower(trn.CTRNPURP) not like '%судебн%'
    and nvl(regexp_count(lower(trn.CTRNPURP),'труд'),0) = nvl(regexp_count(lower(trn.CTRNPURP),'сотрудник'),0) -- 19.09.2018 ubrr rizanov [18-251] АБС: Слова исключения по комиссии за платежи в пользу ФЛ ("сотрудник")               
    -->> 09.12.2015  ubrr pinaev      15-995     Добавление исключений https://redmine.lan.ubrr.ru/issues/26464
    and lower(trn.CTRNPURP) not like '%ипотек%'
    and lower(trn.CTRNPURP) not like '%ипотеч%'
    and lower(trn.CTRNPURP) not like '%вознагражд%'
    and lower(trn.CTRNPURP) not like '%отпуск%'
    and lower(trn.CTRNPURP) not like '%больничн%лист%'
    and lower(trn.CTRNPURP) not like '%постановлен%'
    and lower(trn.CTRNPURP) not like '%суд%приказ%'
    and lower(trn.CTRNPURP) not like '%зп%'
    /*and lower(trn.CTRNPURP) not like '%хоз%расх%'*/-->><<--  23.10.2017 Малых Д.В. 17-1225  по ТЗ
    --<< 09.12.2015  ubrr pinaev      15-995     Добавление исключений #26464 https://redmine.lan.ubrr.ru/issues/26464
    -->> 19.02.2016 Пинаев Д.Е.   #28454 АБС: Комиссия за перевод ЮЛ - ФЛ в %. Исключения платежей.
    and lower(trn.CTRNPURP) not like '%исполнит%'
    and lower(trn.CTRNPURP) not like '%гонорар%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%б/лист%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%б\лист%'
    and lower(trn.CTRNPURP) not like '%доход%ип%'
    and lower(trn.CTRNPURP) not like '%деятельност%ип%'
    --<< 19.02.2016 Пинаев Д.Е.   #28454 АБС: Комиссия за перевод ЮЛ - ФЛ в %. Исключения платежей.
    -->> ubrr korolkov
    and lower(trn.CTRNPURP) not like '%суточн%'
    and lower(trn.CTRNPURP) not like '%сутк%'
    -- >> ubrr 23.03.2020  Ризанов Р.Т.  [20-73286] Добавление слов исключений в комиссии в пользу ФЛ
    and lower(trn.CTRNPURP) not like '%возвр%тур%'                                
    and lower(trn.CTRNPURP) not like '%возвр%аннул%'
    and lower(trn.CTRNPURP) not like '%возвр%проживан%'                                                                
    -- << ubrr 23.03.2020  Ризанов Р.Т.  [20-73286] Добавление слов исключений в комиссии в пользу ФЛ
    and lower(replace(trn.CTRNPURP,' ')) not like '%з.пл%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%з\п%'
    --<< ubrr korolkov
    -->> 22.08.2017  Макарова Л.Ю. [17-1031] АБС: Добавить слова исключения для расчета комиссии при переводе средств в пользу ФЛ
    and lower(replace(trn.CTRNPURP,' ')) not like '%част%приб%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%межрасч%выплат%'
    --<< 22.08.2017  Макарова Л.Ю. [17-1031] АБС: Добавить слова исключения для расчета комиссии при переводе средств в пользу ФЛ
    and (ITRNTYPE = 4 OR ITRNTYPE = 11 AND EXISTS (select 1
                                                   from trc
                                                   where trc.ITRCNUM = trn.ITRNNUMANC
                                                   and trc.ITRCTYPE = 4))
    and not exists --если проведенная комиссия есть, например, осталась после удаления, заново НЕ выбираем.
                (select 1
                 from ubrr_ulfl_tab_acc_coms c
                 where c.DCOMDATERAS = p_d1
                 and c.ICOMTRNNUM IS NOT NULL
                 and c.ccomaccd = trn.CTRNACCD)
    /*
    Исключить клиентов, обслуживающихся по инд.тарифам (форма Настройки  комиссии для индвид.клиентов)
    */
    -->>09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ
   /* and not exists (select 1
                    from ubrr_unique_tarif
                    where a.caccacc = cacc
                    and trn.dtrncreate between DOPENTARIF and DCANCELTARIF
                    and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)*/            -->><<-- ubrr Арсланов Д.Ф. #29736 Доработки по РКО для ВУЗ
    --<<09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ                
    -->>23.10.2017 Малых Д.В. 17-1225  по ТЗ
    and not exists (select 1
                    from ubrr_data.ubrr_sbs_new
                    where idsmr = a.idsmr
                    and dSBSdate = p_d1
                    and cSBSaccd = a.caccacc
                    and cSBScurd = a.cacccur
                    and cSBSTypeCom = 'UL_FL'
                    and iSBStrnnum is not null)
    --<<23.10.2017 Малых Д.В. 17-1225  по ТЗ
    union all -->> 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
    ----------------внутрибанковские на ФЛ---------------------
    select trn.ITRNNUM,
           ctrnaccd,
           ctrncur,
           mtrnsum,
           a.CACCPRIZN,
           a.IDSMR,
           a.iaccotd
            -->>23.10.2017  Малых Д.В.       17-1225   возьмем сумму проводок с начала месяца, текущую не берем.
           , nvl((select sum(mtrnsum)
                  from /*V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v xm -->><<--07.11.2019 Баязитов [19-62184] Ежедневные комиссии УБРИР
                  where xm.ctrnaccd = trn.ctrnaccd
                  and xm.ctrncur=trn.ctrncur
                  and xm.dtrntran between trunc(p_d1, 'MM') and p_d1 -1/86400
                  and xm.ctrnmfoa  in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr) --! наши филиалы -> внутрибанк     -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
                  and ( --!  счет получателя, выделенный из трех полей платежного документа соответствует маскам 40817%,40820% ,423%,426%
                        xm.ctrnacca LIKE '40817%' OR xm.ctrnacca LIKE '40820%' OR
                        xm.ctrnacca LIKE '423%' OR xm.ctrnacca LIKE '426%' OR
                        regexp_substr(xm.CTRNOWNA, '\d{20}') LIKE '40817%' OR
                        regexp_substr(xm.CTRNOWNA, '\d{20}') LIKE '40820%' OR
                        regexp_substr(xm.CTRNOWNA, '\d{20}') LIKE '423%' OR
                        regexp_substr(xm.CTRNOWNA, '\d{20}') LIKE '426%' OR
                        regexp_substr(xm.ctrnpurp, '\d{20}') LIKE '40817%' OR
                        regexp_substr(xm.ctrnpurp, '\d{20}') LIKE '40820%' OR
                        regexp_substr(xm.ctrnpurp, '\d{20}') LIKE '423%' OR
                        regexp_substr(xm.ctrnpurp, '\d{20}') LIKE '426%')
                  and (    xm.ITRNTYPE = 4
                        or xm.ITRNTYPE = 2          -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
                        OR xm.ITRNTYPE in (11,28)   -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ 
                       AND EXISTS( select 1
                                     from trc
                                    where trc.ITRCNUM = xm.ITRNNUMANC
                                      and trc.ITRCTYPE in (2,4) ) -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
                      )
                  and lower(xm.CTRNPURP) not like '%командир%'
                  and lower(xm.CTRNPURP) not like '%кредит%'
                  and lower(xm.CTRNPURP) not like '%алимент%'
                  and lower(xm.CTRNPURP) not like '%з/п%'
                  and lower(xm.CTRNPURP) not like '%зар%пл%'
                  and lower(xm.CTRNPURP) not like '%аванс%'
                  and lower(xm.CTRNPURP) not like '%благотворит%'
                  and lower(xm.CTRNPURP) not like '%помощ%'
                  and lower(xm.CTRNPURP) not like '%агент%'
                  and lower(xm.CTRNPURP) not like '%подряд%'
                  and lower(xm.CTRNPURP) not like '%пособ%'
                  and lower(xm.CTRNPURP) not like '%стипенд%'
                  and lower(xm.CTRNPURP) not like '%страхов%'
                  and lower(xm.CTRNPURP) not like '%компенсац%'
                  and lower(xm.CTRNPURP) not like '%пенс%'
                  and lower(xm.CTRNPURP) not like '%возмещен%'
                  and lower(xm.CTRNPURP) not like '%отпускн%'
                  and lower(xm.CTRNPURP) not like '%увол%'
                  and lower(xm.CTRNPURP) not like '%преми%'
                  and lower(xm.CTRNPURP) not like '%дивиденд%'
                  and lower(xm.CTRNPURP) not like '%исп%лист%'
                  and lower(xm.CTRNPURP) not like '%судеб%реш%'
                  and lower(xm.CTRNPURP) not like '%реш%взыск%'
                  and lower(xm.CTRNPURP) not like '%уставн%'
                  and lower(xm.CTRNPURP) not like '%учредит%'
                  and lower(xm.CTRNPURP) not like '%предпринимат%'
                  and lower(xm.CTRNPURP) not like '%судебн%'
                  and nvl(regexp_count(lower(xm.CTRNPURP),'труд'),0) = nvl(regexp_count(lower(xm.CTRNPURP),'сотрудник'),0) -- 19.09.2018 ubrr rizanov [18-251] АБС: Слова исключения по комиссии за платежи в пользу ФЛ ("сотрудник")                                           
                  and lower(xm.CTRNPURP) not like '%ипотек%'
                  and lower(xm.CTRNPURP) not like '%ипотеч%'
                  and lower(xm.CTRNPURP) not like '%вознагражд%'
                  and lower(xm.CTRNPURP) not like '%отпуск%'
                  and lower(xm.CTRNPURP) not like '%больничн%лист%'
                  and lower(xm.CTRNPURP) not like '%постановлен%'
                  and lower(xm.CTRNPURP) not like '%суд%приказ%'
                  and lower(xm.CTRNPURP) not like '%зп%'
                  and lower(xm.CTRNPURP) not like '%исполнит%'
                  and lower(xm.CTRNPURP) not like '%гонорар%'
                  and lower(replace(xm.CTRNPURP,' ')) not like '%б/лист%'
                  and lower(replace(xm.CTRNPURP,' ')) not like '%б\лист%'
                  and lower(xm.CTRNPURP) not like '%доход%ип%'
                  and lower(xm.CTRNPURP) not like '%деятельност%ип%'
                  and lower(xm.CTRNPURP) not like '%суточн%'
                  and lower(xm.CTRNPURP) not like '%сутк%'
                  and lower(replace(xm.CTRNPURP,' ')) not like '%з.пл%'
                  and lower(replace(xm.CTRNPURP,' ')) not like '%з\п%'
                  and lower(replace(xm.CTRNPURP,' ')) not like '%част%приб%'
                  and lower(replace(xm.CTRNPURP,' ')) not like '%межрасч%выплат%'
                  and lower(xm.CTRNPURP) not like '%ген%согл%'              -- 12.03.2019 Ризанов Р.Т. [19-60337]   АБС: Добавление слов исключений в комиссию за внутрибанк в пользу ФЛ                                                       
                  and lower(xm.CTRNPURP) not like '%депоз%'    -- 07.03.2019 Ризанов Р.Т. [#60292] Ошибка при одновременном взимании комиссий UL_FL и UL_FL_VB                  
                  and lower(xm.CTRNPURP) not like '%вклад%'    -- 07.03.2019 Ризанов Р.Т. [#60292] Ошибка при одновременном взимании комиссий UL_FL и UL_FL_VB
                  -- >> ubrr 23.03.2020  Ризанов Р.Т.  [20-73286] Добавление слов исключений в комиссии в пользу ФЛ
                  and lower(xm.CTRNPURP) not like '%возвр%тур%'                                
                  and lower(xm.CTRNPURP) not like '%возвр%аннул%'
                  and lower(xm.CTRNPURP) not like '%возвр%проживан%'                                                                
                  -- << ubrr 23.03.2020  Ризанов Р.Т.  [20-73286] Добавление слов исключений в комиссии в пользу ФЛ
                  and not exists --если проведенная комиссия есть, например, осталась после удаления, заново НЕ выбираем.
                              (select 1
                               from ubrr_ulfl_tab_acc_coms c
                               where c.DCOMDATERAS = p_d1
                               and c.ICOMTRNNUM IS NOT NULL
                               and c.ccomaccd = xm.CTRNACCD)
                  -->>09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ
                  /*and not exists
                              (select 1
                               from ubrr_unique_tarif
                               where a.caccacc = cacc
                               and xm.dtrncreate between DOPENTARIF and DCANCELTARIF
                               and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)*/
                  --<<09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ             
               ),0)
               SumBefo,
               to_number(to_char(NVL(o.iOTDbatnum,70) )||'00') batnum,
               'UL_FL_VB' ctypecom  -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
              --<<23.10.2017  Малых Д.В.       17-1225    возьмем сумму проводок с начала месяца, текущую не берем.
    from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn, acc a, otd o -->><<--23.10.2017  Малых Д.В.       17-1225   добавил    otd - для batnum (номер пачки)-->><<--07.11.2019 Баязитов [19-62184] Ежедневные комиссии УБРИР
    where cTRNcur = 'RUR'
    and a.iaccotd = o.iotdnum    -->><<--23.10.2017  Малых Д.В.       17-1225   добавил    otd - для batnum (номер пачки)
    and cACCacc = cTRNaccd
    and cTRNaccd like p_mask
    and cACCacc  like p_mask
    and cACCprizn <> 'З'
    and dtrntran between p_d1 and p_d2
    and ((trn.CTRNACCD like '40%' and
          to_number(substr(trn.CTRNACCD, 3, 1)) between 1 and 7) --! счет плательщика соответствует маскам 401-407%,40802%, 40807
          or trn.CTRNACCD like '40802%'
          or trn.CTRNACCD like '40807%'
          or trn.CTRNACCD like '40821%' -- UBRR Новолодский А. Ю. 23.05.2017 [17-71] АБС: Ошибка списании комиссиий по спецсчету на спецсчет по капремонту
        )
    -->>-- 10.03.2016  Пинаев Д.Е.      [15-1547]  АБС: Комиссия в пользу ФЛ - проставление кат/гр  https://redmine.lan.ubrr.ru/issues/29103
    and not exists (select /*+ index(GCS P_GCS_CUS_CAT_NUM)*/ 1
                    from gcs
                    where igcsCus = a.IACCCUS
                    and igcscat = 114
                    and igcsnum = 11
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where i_num = gcs.igcsCus
                                and i_table = 303
                                and d_create <= p_d2
                                and au.c_newdata like '114/' || to_char(gcs.igcsnum)))
    and not exists (select 1
                    from gac
                    where cgacacc = a.cACCacc
                    and cgaccur = a.cACCcur
                    and igaccat = 114
                    and igacnum = 11
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '114/' || to_char(gac.igacnum)))
    --<<-- 10.03.2016  Пинаев Д.Е.      [15-1547]  АБС: Комиссия в пользу ФЛ - проставление кат/гр  https://redmine.lan.ubrr.ru/issues/29103
    and not exists (select 1
                    from gac
                    where cgacacc = a.cACCacc
                    and cgaccur = a.cACCcur
                    and igaccat = 333
                    and igacnum = 2
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '333/' || to_char(gac.igacnum)))
    and not exists (select 1
                    from gac
                    where cgacacc = a.cACCacc
                    and cgaccur = a.cACCcur
                    and igaccat = 112
                    and igacnum in (1, 3, 4, 5, 7, 10, 13, 15, 16, 17, 19, 20, 21, 22, 23, 24, 25, 36, 37, 38, 39, 57, 76,
                                    70, -->><<-- 10.03.2016  Пинаев Д.Е.      [15-1547]  АБС: Комиссия в пользу ФЛ - проставление кат/гр
                                    71) -->><<-- 18.03.2016  Макарова Л.Ю.     [15-1726]  АБС: Комиссия в пользу ФЛ - проставление кат/гр )
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '112/' || to_char(gac.igacnum)))
    and not exists (select 1
                    from gac g1, gac g2
                    where g1.cgacacc = a.cACCacc
                    and g1.cgaccur = a.cACCcur
                    and g2.cgacacc = a.cACCacc
                    and g2.cgaccur = a.cACCcur
                    and g1.igaccat = 333
                    and g1.igacnum = 4
                    and g2.igaccat = 112
                    and g2.igacnum in (74)
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '333/' || to_char(g1.igacnum))
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '112/' || to_char(g2.igacnum)))
    and ( --!  счет получателя, выделенный из трех полей платежного документа соответствует маскам 40817%,40820% ,423%,426%
          trn.ctrnacca LIKE '40817%' OR trn.ctrnacca LIKE '40820%' OR
          trn.ctrnacca LIKE '423%' OR trn.ctrnacca LIKE '426%' OR
          regexp_substr(trn.CTRNOWNA, '\d{20}') LIKE '40817%' OR
          regexp_substr(trn.CTRNOWNA, '\d{20}') LIKE '40820%' OR
          regexp_substr(trn.CTRNOWNA, '\d{20}') LIKE '423%' OR
          regexp_substr(trn.CTRNOWNA, '\d{20}') LIKE '426%' OR
          regexp_substr(trn.ctrnpurp, '\d{20}') LIKE '40817%' OR
          regexp_substr(trn.ctrnpurp, '\d{20}') LIKE '40820%' OR
          regexp_substr(trn.ctrnpurp, '\d{20}') LIKE '423%' OR
          regexp_substr(trn.ctrnpurp, '\d{20}') LIKE '426%')
    and ctrnmfoa in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr) --! наши филиалы -> внутренний перевод -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
    and lower(trn.CTRNPURP) not like '%командир%'
    and lower(trn.CTRNPURP) not like '%кредит%'
    and lower(trn.CTRNPURP) not like '%алимент%'
    and lower(trn.CTRNPURP) not like '%з/п%'
    and lower(trn.CTRNPURP) not like '%зар%пл%'
    and lower(trn.CTRNPURP) not like '%аванс%'
    and lower(trn.CTRNPURP) not like '%благотворит%'
    and lower(trn.CTRNPURP) not like '%помощ%'
    and lower(trn.CTRNPURP) not like '%агент%'
    and lower(trn.CTRNPURP) not like '%подряд%'
    and lower(trn.CTRNPURP) not like '%пособ%'
    and lower(trn.CTRNPURP) not like '%поcоб%' -- 07.11.2017 ubrr korolkov 17-1071 латинская "c"
    and lower(trn.CTRNPURP) not like '%стипенд%'
    and lower(trn.CTRNPURP) not like '%страхов%'
    and lower(trn.CTRNPURP) not like '%компенсац%'
    and lower(trn.CTRNPURP) not like '%пенс%'
    and lower(trn.CTRNPURP) not like '%возмещен%'
    and lower(trn.CTRNPURP) not like '%отпускн%'
    and lower(trn.CTRNPURP) not like '%увол%'
    and lower(trn.CTRNPURP) not like '%преми%'
    and lower(trn.CTRNPURP) not like '%дивиденд%'
    and lower(trn.CTRNPURP) not like '%исп%лист%'
    and lower(trn.CTRNPURP) not like '%судеб%реш%'
    and lower(trn.CTRNPURP) not like '%реш%взыск%'
    and lower(trn.CTRNPURP) not like '%уставн%'
    and lower(trn.CTRNPURP) not like '%учредит%'
    -->> 23.10.2017 Малых Д.В. 17-1225   по ТЗ
    /*
    and lower(trn.CTRNPURP) not like '%подотчет%'
    and lower(trn.CTRNPURP) not like '%подотчёт%'
    and lower(trn.CTRNPURP) not like '%под отчет%'
    and lower(trn.CTRNPURP) not like '%под отчёт%'
    */
    --<< 23.10.2017 Малых Д.В. 17-1225    по ТЗ
    and lower(trn.CTRNPURP) not like '%предпринимат%'
    /*and lower(trn.CTRNPURP) not like '%хоз%нужд%'*/ -->><<--  23.10.2017 Малых Д.В. 17-1225    по ТЗ
    and lower(trn.CTRNPURP) not like '%судебн%'
    and nvl(regexp_count(lower(trn.CTRNPURP),'труд'),0) = nvl(regexp_count(lower(trn.CTRNPURP),'сотрудник'),0) -- 19.09.2018 ubrr rizanov [18-251] АБС: Слова исключения по комиссии за платежи в пользу ФЛ ("сотрудник")               
    -->> 09.12.2015  ubrr pinaev      15-995     Добавление исключений https://redmine.lan.ubrr.ru/issues/26464
    and lower(trn.CTRNPURP) not like '%ипотек%'
    and lower(trn.CTRNPURP) not like '%ипотеч%'
    and lower(trn.CTRNPURP) not like '%вознагражд%'
    and lower(trn.CTRNPURP) not like '%отпуск%'
    and lower(trn.CTRNPURP) not like '%больничн%лист%'
    and lower(trn.CTRNPURP) not like '%постановлен%'
    and lower(trn.CTRNPURP) not like '%суд%приказ%'
    and lower(trn.CTRNPURP) not like '%зп%'
    /*and lower(trn.CTRNPURP) not like '%хоз%расх%'*/-->><<--  23.10.2017 Малых Д.В. 17-1225  по ТЗ
    --<< 09.12.2015  ubrr pinaev      15-995     Добавление исключений #26464 https://redmine.lan.ubrr.ru/issues/26464
    -->> 19.02.2016 Пинаев Д.Е.   #28454 АБС: Комиссия за перевод ЮЛ - ФЛ в %. Исключения платежей.
    and lower(trn.CTRNPURP) not like '%исполнит%'
    and lower(trn.CTRNPURP) not like '%гонорар%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%б/лист%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%б\лист%'
    and lower(trn.CTRNPURP) not like '%доход%ип%'
    and lower(trn.CTRNPURP) not like '%деятельност%ип%'
    --<< 19.02.2016 Пинаев Д.Е.   #28454 АБС: Комиссия за перевод ЮЛ - ФЛ в %. Исключения платежей.
    -->> ubrr korolkov
    and lower(trn.CTRNPURP) not like '%суточн%'
    and lower(trn.CTRNPURP) not like '%сутк%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%з.пл%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%з\п%'
    --<< ubrr korolkov
    -->> 22.08.2017  Макарова Л.Ю. [17-1031] АБС: Добавить слова исключения для расчета комиссии при переводе средств в пользу ФЛ
    and lower(replace(trn.CTRNPURP,' ')) not like '%част%приб%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%межрасч%выплат%'
    --<< 22.08.2017  Макарова Л.Ю. [17-1031] АБС: Добавить слова исключения для расчета комиссии при переводе средств в пользу ФЛ
    and lower(trn.CTRNPURP) not like '%ген%согл%'              -- 12.03.2019 Ризанов Р.Т. [19-60337]   АБС: Добавление слов исключений в комиссию за внутрибанк в пользу ФЛ    
    and lower(trn.CTRNPURP) not like '%депоз%'    -- 07.03.2019 Ризанов Р.Т. [#60292] Ошибка при одновременном взимании комиссий UL_FL и UL_FL_VB                  
    and lower(trn.CTRNPURP) not like '%вклад%'    -- 07.03.2019 Ризанов Р.Т. [#60292] Ошибка при одновременном взимании комиссий UL_FL и UL_FL_VB
    -- >> ubrr 23.03.2020  Ризанов Р.Т.  [20-73286] Добавление слов исключений в комиссии в пользу ФЛ
    and lower(trn.CTRNPURP) not like '%возвр%тур%'                                
    and lower(trn.CTRNPURP) not like '%возвр%аннул%'
    and lower(trn.CTRNPURP) not like '%возвр%проживан%'                                                                
    -- << ubrr 23.03.2020  Ризанов Р.Т.  [20-73286] Добавление слов исключений в комиссии в пользу ФЛ
    and (ITRNTYPE = 4 OR
           ITRNTYPE = 2 or                            -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ     
           ITRNTYPE in (11,28) AND EXISTS (select 1   -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
                                             from trc
                                            where trc.ITRCNUM = trn.ITRNNUMANC
                                              and trc.ITRCTYPE in (2,4) ) -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
        )                                              
    and not exists --если проведенная комиссия есть, например, осталась после удаления, заново НЕ выбираем.
                (select 1
                 from ubrr_ulfl_tab_acc_coms c
                 where c.DCOMDATERAS = p_d1
                 and c.ICOMTRNNUM IS NOT NULL
                 and c.ccomaccd = trn.CTRNACCD)
    /*
    Исключить клиентов, обслуживающихся по инд.тарифам (форма Настройки  комиссии для индвид.клиентов)
    */
    -->>09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ
    /*and not exists (select 1
                    from ubrr_unique_tarif
                    where a.caccacc = cacc
                    and trn.dtrncreate between DOPENTARIF and DCANCELTARIF
                    and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)   */         -->><<-- ubrr Арсланов Д.Ф. #29736 Доработки по РКО для ВУЗ
    --<<09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ                
    -->>23.10.2017 Малых Д.В. 17-1225  по ТЗ
    and not exists (select 1
                    from ubrr_data.ubrr_sbs_new
                    where idsmr = a.idsmr
                    and dSBSdate = p_d1
                    and cSBSaccd = a.caccacc
                    and cSBScurd = a.cacccur
                    and cSBSTypeCom = 'UL_FL_VB'
                    and iSBStrnnum is not null)
    --<<23.10.2017 Малых Д.В. 17-1225  по ТЗ
    --<< 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ        
    ;

    -->> 23.10.2017 Малых Д.В. 17-1225  по ТЗ
    cursor get_calcTrn_business_activity(p_d1 DATE, p_d2 DATE, p_mask varchar2, BankIdSmr number)
    is
     ------------------ межбанковские на ИП(ФЛ)  -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
    select trn.ITRNNUM,
           ctrnaccd,
           ctrncur,
           mtrnsum,
           a.CACCPRIZN,
           a.IDSMR,
           a.iaccotd
            -->>23.10.2017  Малых Д.В.       17-1225  возьмем проводки сначала месяца, текущую не берем.
           , nvl( (select sum(mtrnsum) from /*V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v xm -->><<--07.11.2019 Баязитов [19-62184] Ежедневные комиссии УБРИР
                   where xm.ctrnaccd = trn.ctrnaccd
                     and xm.ctrncur=trn.ctrncur
                     and xm.dtrntran between trunc(p_d1, 'MM') and p_d1 -1/86400
                     and xm.ctrnmfoa  not in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr)
                     and ( --!  счет получателя, выделенный из трех полей платежного документа соответствует маскам 40817%,40820% ,423%,426%
                           xm.ctrnacca LIKE '40817%' OR xm.ctrnacca LIKE '40820%' OR
                           xm.ctrnacca LIKE '423%' OR xm.ctrnacca LIKE '426%' OR
                           regexp_substr(xm.CTRNOWNA, '\d{20}') LIKE '40817%' OR
                           regexp_substr(xm.CTRNOWNA, '\d{20}') LIKE '40820%' OR
                           regexp_substr(xm.CTRNOWNA, '\d{20}') LIKE '423%' OR
                           regexp_substr(xm.CTRNOWNA, '\d{20}') LIKE '426%' OR
                           regexp_substr(xm.ctrnpurp, '\d{20}') LIKE '40817%' OR
                           regexp_substr(xm.ctrnpurp, '\d{20}') LIKE '40820%' OR
                           regexp_substr(xm.ctrnpurp, '\d{20}') LIKE '423%' OR
                           regexp_substr(xm.ctrnpurp, '\d{20}') LIKE '426%')
                     and (xm.ITRNTYPE = 4 OR xm.ITRNTYPE = 11 AND EXISTS (select 1
                                                                          from trc
                                                                          where trc.ITRCNUM = xm.ITRNNUMANC
                                                                          and trc.ITRCTYPE = 4))
                     and (lower(xm.CTRNPURP) not like '%командир%'
                     and lower(xm.CTRNPURP) not like '%кредит%'
                     and lower(xm.CTRNPURP) not like '%алимент%'
                     and lower(xm.CTRNPURP) not like '%з/п%'
                     and lower(xm.CTRNPURP) not like '%зар%пл%'
                     and lower(xm.CTRNPURP) not like '%аванс%'
                     and lower(xm.CTRNPURP) not like '%благотворит%'
                     and lower(xm.CTRNPURP) not like '%помощ%'
                     and lower(xm.CTRNPURP) not like '%агент%'
                     and lower(xm.CTRNPURP) not like '%подряд%'
                     and lower(xm.CTRNPURP) not like '%пособ%'
                     and lower(xm.CTRNPURP) not like '%стипенд%'
                     and lower(xm.CTRNPURP) not like '%страхов%'
                     and lower(xm.CTRNPURP) not like '%компенсац%'
                     and lower(xm.CTRNPURP) not like '%пенс%'
                     and lower(xm.CTRNPURP) not like '%возмещен%'
                     and lower(xm.CTRNPURP) not like '%отпускн%'
                     and lower(xm.CTRNPURP) not like '%увол%'
                     and lower(xm.CTRNPURP) not like '%преми%'
                     and lower(xm.CTRNPURP) not like '%дивиденд%'
                     and lower(xm.CTRNPURP) not like '%исп%лист%'
                     and lower(xm.CTRNPURP) not like '%судеб%реш%'
                     and lower(xm.CTRNPURP) not like '%реш%взыск%'
                     and lower(xm.CTRNPURP) not like '%уставн%'
                     and lower(xm.CTRNPURP) not like '%учредит%'
                     and lower(xm.CTRNPURP) not like '%судебн%'
                     and nvl(regexp_count(lower(xm.CTRNPURP),'труд'),0) = nvl(regexp_count(lower(xm.CTRNPURP),'сотрудник'),0) -- 19.09.2018 ubrr rizanov [18-251] АБС: Слова исключения по комиссии за платежи в пользу ФЛ ("сотрудник") 
                     and lower(xm.CTRNPURP) not like '%ипотек%'
                     and lower(xm.CTRNPURP) not like '%ипотеч%'
                     and lower(xm.CTRNPURP) not like '%вознагражд%'
                     and lower(xm.CTRNPURP) not like '%отпуск%'
                     and lower(xm.CTRNPURP) not like '%больничн%лист%'
                     and lower(xm.CTRNPURP) not like '%постановлен%'
                     and lower(xm.CTRNPURP) not like '%суд%приказ%'
                     and lower(xm.CTRNPURP) not like '%зп%'
                     and lower(xm.CTRNPURP) not like '%исполнит%'
                     and lower(xm.CTRNPURP) not like '%гонорар%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%б/лист%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%б\лист%'
                     and lower(xm.CTRNPURP) not like '%суточн%'
                     and lower(xm.CTRNPURP) not like '%сутк%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%з.пл%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%з\п%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%част%приб%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%межрасч%выплат%' )
                     and (   lower(xm.ctrnpurp) LIKE '%доход%ип%'
                          OR lower(xm.ctrnpurp) LIKE '%деятельност%ип%'
                          OR lower(xm.ctrnpurp) LIKE '%предпринимат%')
                     and (ITRNTYPE = 4 OR ITRNTYPE = 11 AND EXISTS (select 1
                                                                    from trc
                                                                    where trc.ITRCNUM = xm.ITRNNUMANC
                                                                    and trc.ITRCTYPE = 4))
                     and not exists --если проведенная комиссия есть, например, осталась после удаления, заново НЕ выбираем.
                                 (select 1
                                  from ubrr_ulfl_tab_acc_coms c
                                  where c.DCOMDATERAS = p_d1
                                  and c.ICOMTRNNUM IS NOT NULL
                                  and c.ccomaccd = xm.CTRNACCD)
                     /*
                      Исключить клиентов, обслуживающихся по инд.тарифам (форма Настройки  комиссии для индвид.клиентов)
                     */
                     -->>09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ
                     /*and not exists (select 1
                                     from ubrr_unique_tarif
                                     where a.caccacc = cacc
                                     and xm.dtrncreate between DOPENTARIF and DCANCELTARIF
                                     and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)*/
                     --><<09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ                
           ) , 0)   SumBefo,
           to_number(to_char(NVL(o.iOTDbatnum,70) )||'00') batnum,
          'IP_DOH' ctypecom  -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
           --<<23.10.2017  Малых Д.В.       17-1225
    from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn, acc a, otd o -->><<--23.10.2017  Малых Д.В.       17-1225 -->><<--07.11.2019 Баязитов [19-62184] Ежедневные комиссии УБРИР
    where cTRNcur = 'RUR'
    and a.iaccotd = o.iotdnum
    and cACCacc = cTRNaccd
    and cTRNaccd like p_mask
    and cACCacc  like p_mask
    and cACCprizn <> 'З'
    and dtrntran between p_d1 and p_d2
    AND trn.ctrnaccd LIKE '40802%'
    /*
       and ((trn.CTRNACCD like '40%' and
           to_number(substr(trn.CTRNACCD, 3, 1)) between 1 and 7) --! счет плательщика соответствует маскам 401-407%,40802%, 40807
           or trn.CTRNACCD like '40802%' or trn.CTRNACCD like '40807%' or
           trn.CTRNACCD like '42309%' or
    -- (нач.) UBRR Новолодский А. Ю. 23.05.2017 [17-71] АБС: Ошибка списании комиссиий по спецсчету на спецсчет по капремонту
           trn.CTRNACCD like '40821%'
           --trn.CTRNACCD like '40821________7______' or
           --trn.CTRNACCD like '40821________8______'
           )
    */
    -- (кон.) UBRR Новолодский А. Ю. 23.05.2017 [17-71] АБС: Ошибка списании комиссиий по спецсчету на спецсчет по капремонту
    -->>-- 10.03.2016  Пинаев Д.Е.      [15-1547]  АБС: Комиссия в пользу ФЛ - проставление кат/гр  https://redmine.lan.ubrr.ru/issues/29103
    and not exists (select /*+ index(GCS P_GCS_CUS_CAT_NUM)*/ 1
                    from gcs
                    where igcsCus = a.IACCCUS
                    and igcscat = 114
                    and igcsnum = 11
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where i_num=gcs.igcsCus
                                and i_table = 303
                                and d_create <= p_d2
                                and au.c_newdata like '114/' || to_char(gcs.igcsnum)))
    and not exists (select 1
                    from gac
                    where cgacacc = a.cACCacc
                    and cgaccur = a.cACCcur
                    and igaccat = 114
                    and igacnum = 11
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '114/' || to_char(gac.igacnum)))
    --<<-- 10.03.2016  Пинаев Д.Е.      [15-1547]  АБС: Комиссия в пользу ФЛ - проставление кат/гр  https://redmine.lan.ubrr.ru/issues/29103
    and not exists (select 1
                    from gac
                    where cgacacc = a.cACCacc
                    and cgaccur = a.cACCcur
                    and igaccat = 333
                    and igacnum = 2
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '333/' || to_char(gac.igacnum)))
    and not exists (select 1
                    from gac
                    where cgacacc = a.cACCacc
                    and cgaccur = a.cACCcur
                    and igaccat = 112
                    and igacnum in (1, 3, 4, 5, 7, 10, 13, 15, 16, 17, 19, 20, 21, 22, 23, 24, 25, 36, 37, 38, 39, 57, 76,
                                    70, -->><<-- 10.03.2016  Пинаев Д.Е.      [15-1547]  АБС: Комиссия в пользу ФЛ - проставление кат/гр
                                    71) -->><<-- 18.03.2016  Макарова Л.Ю.     [15-1726]  АБС: Комиссия в пользу ФЛ - проставление кат/гр )
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '112/' || to_char(gac.igacnum)))
    and not exists (select 1
                    from gac g1,
                         gac g2
                    where g1.cgacacc = a.cACCacc
                    and g1.cgaccur = a.cACCcur
                    and g2.cgacacc = a.cACCacc
                    and g2.cgaccur = a.cACCcur
                    and g1.igaccat = 333
                    and g1.igacnum = 4
                    and g2.igaccat = 112
                    and g2.igacnum in (74)
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '333/' || to_char(g1.igacnum))
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '112/' || to_char(g2.igacnum)))
    and ( --!  счет получателя, выделенный из трех полей платежного документа соответствует маскам 40817%,40820% ,423%,426%
          trn.ctrnacca LIKE '40817%' OR trn.ctrnacca LIKE '40820%' OR
          trn.ctrnacca LIKE '423%' OR trn.ctrnacca LIKE '426%' OR
          regexp_substr(trn.CTRNOWNA, '\d{20}') LIKE '40817%' OR
          regexp_substr(trn.CTRNOWNA, '\d{20}') LIKE '40820%' OR
          regexp_substr(trn.CTRNOWNA, '\d{20}') LIKE '423%' OR
          regexp_substr(trn.CTRNOWNA, '\d{20}') LIKE '426%' OR
          regexp_substr(trn.ctrnpurp, '\d{20}') LIKE '40817%' OR
          regexp_substr(trn.ctrnpurp, '\d{20}') LIKE '40820%' OR
          regexp_substr(trn.ctrnpurp, '\d{20}') LIKE '423%' OR
          regexp_substr(trn.ctrnpurp, '\d{20}') LIKE '426%')
    and ctrnmfoa not in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr) --! не наши филиалы -> внешний перевод
    and (lower(trn.CTRNPURP) not like '%командир%'
    and lower(trn.CTRNPURP) not like '%кредит%'
    and lower(trn.CTRNPURP) not like '%алимент%'
    and lower(trn.CTRNPURP) not like '%з/п%'
    and lower(trn.CTRNPURP) not like '%зар%пл%'
    and lower(trn.CTRNPURP) not like '%аванс%'
    and lower(trn.CTRNPURP) not like '%благотворит%'
    and lower(trn.CTRNPURP) not like '%помощ%'
    and lower(trn.CTRNPURP) not like '%агент%'
    and lower(trn.CTRNPURP) not like '%подряд%'
    and lower(trn.CTRNPURP) not like '%пособ%'
    and lower(trn.CTRNPURP) not like '%стипенд%'
    and lower(trn.CTRNPURP) not like '%страхов%'
    and lower(trn.CTRNPURP) not like '%компенсац%'
    and lower(trn.CTRNPURP) not like '%пенс%'
    and lower(trn.CTRNPURP) not like '%возмещен%'
    and lower(trn.CTRNPURP) not like '%отпускн%'
    and lower(trn.CTRNPURP) not like '%увол%'
    and lower(trn.CTRNPURP) not like '%преми%'
    and lower(trn.CTRNPURP) not like '%дивиденд%'
    and lower(trn.CTRNPURP) not like '%исп%лист%'
    and lower(trn.CTRNPURP) not like '%судеб%реш%'
    and lower(trn.CTRNPURP) not like '%реш%взыск%'
    and lower(trn.CTRNPURP) not like '%уставн%'
    and lower(trn.CTRNPURP) not like '%учредит%'
    -->> 23.10.2017 Малых Д.В. 17-1225
    /*
    and lower(trn.CTRNPURP) not like '%подотчет%'
    and lower(trn.CTRNPURP) not like '%подотчёт%'
    and lower(trn.CTRNPURP) not like '%под отчет%'
    and lower(trn.CTRNPURP) not like '%под отчёт%'
    */
    --<< 23.10.2017 Малых Д.В. 17-1225
    -- and lower(trn.CTRNPURP) not like '%предпринимат%'
    /*and lower(trn.CTRNPURP) not like '%хоз%нужд%'*/ -->><<--  23.10.2017 Малых Д.В. 17-1225
    and lower(trn.CTRNPURP) not like '%судебн%'
    and nvl(regexp_count(lower(trn.CTRNPURP),'труд'),0) = nvl(regexp_count(lower(trn.CTRNPURP),'сотрудник'),0) -- 19.09.2018 ubrr rizanov [18-251] АБС: Слова исключения по комиссии за платежи в пользу ФЛ ("сотрудник")              
    -->> 09.12.2015  ubrr pinaev      15-995     Добавление исключений https://redmine.lan.ubrr.ru/issues/26464
    and lower(trn.CTRNPURP) not like '%ипотек%'
    and lower(trn.CTRNPURP) not like '%ипотеч%'
    and lower(trn.CTRNPURP) not like '%вознагражд%'
    and lower(trn.CTRNPURP) not like '%отпуск%'
    and lower(trn.CTRNPURP) not like '%больничн%лист%'
    and lower(trn.CTRNPURP) not like '%постановлен%'
    and lower(trn.CTRNPURP) not like '%суд%приказ%'
    and lower(trn.CTRNPURP) not like '%зп%'
    /*and lower(trn.CTRNPURP) not like '%хоз%расх%'*/-->><<--  23.10.2017 Малых Д.В. 17-1225
    --<< 09.12.2015  ubrr pinaev      15-995     Добавление исключений #26464 https://redmine.lan.ubrr.ru/issues/26464
    -->> 19.02.2016 Пинаев Д.Е.   #28454 АБС: Комиссия за перевод ЮЛ - ФЛ в %. Исключения платежей.
    and lower(trn.CTRNPURP) not like '%исполнит%'
    and lower(trn.CTRNPURP) not like '%гонорар%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%б/лист%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%б\лист%'
    --and lower(trn.CTRNPURP) not like '%доход%ип%'
    --and lower(trn.CTRNPURP) not like '%деятельност%ип%'
    --<< 19.02.2016 Пинаев Д.Е.   #28454 АБС: Комиссия за перевод ЮЛ - ФЛ в %. Исключения платежей.
    -->> ubrr korolkov
    and lower(trn.CTRNPURP) not like '%суточн%'
    and lower(trn.CTRNPURP) not like '%сутк%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%з.пл%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%з\п%'
    --<< ubrr korolkov
    -->> 22.08.2017  Макарова Л.Ю. [17-1031] АБС: Добавить слова исключения для расчета комиссии при переводе средств в пользу ФЛ
    and lower(replace(trn.CTRNPURP,' ')) not like '%част%приб%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%межрасч%выплат%' )
    --<< 22.08.2017  Макарова Л.Ю. [17-1031] АБС: Добавить слова исключения для расчета комиссии при переводе средств в пользу ФЛ
    -->> 23.10.2017 Малых Д.В. 17-1225
    and (   lower(trn.ctrnpurp) LIKE '%доход%ип%'
         or lower(trn.ctrnpurp) LIKE '%деятельност%ип%'
         or lower(trn.ctrnpurp) LIKE '%предпринимат%')
    --<< 23.10.2017 Малых Д.В. 17-1225
    and (ITRNTYPE = 4 OR ITRNTYPE = 11 AND EXISTS (select 1
                                                   from trc
                                                   where trc.ITRCNUM = trn.ITRNNUMANC
                                                   and trc.ITRCTYPE = 4))
    and not exists --если проведенная комиссия есть, например, осталась после удаления, заново НЕ выбираем.
                  (select 1
                   from ubrr_ulfl_tab_acc_coms c
                   where c.DCOMDATERAS = p_d1
                   and c.ICOMTRNNUM IS NOT NULL
                   and c.ccomaccd = trn.CTRNACCD)
    /*
     Исключить клиентов, обслуживающихся по инд.тарифам (форма Настройки  комиссии для индвид.клиентов)
    */
    -->>09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ
    /*and not exists (select 1
                    from ubrr_unique_tarif
                    where a.caccacc = cacc
                    and trn.dtrncreate between DOPENTARIF and DCANCELTARIF
                    and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)*/
    --<<09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ                
    and not exists (select 1
                    from ubrr_data.ubrr_sbs_new
                    where idsmr = a.idsmr
                    and dSBSdate = p_d1
                    and cSBSaccd = a.caccacc
                    and cSBScurd = a.cacccur
                    and cSBSTypeCom = 'IP_DOH'
                    and iSBStrnnum is not null)
 union all  -->> 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
 ------------------ внутрибанковские на ИП(ФЛ)----------------------- 
    select trn.ITRNNUM,
           ctrnaccd,
           ctrncur,
           mtrnsum,
           a.CACCPRIZN,
           a.IDSMR,
           a.iaccotd
            -->>23.10.2017  Малых Д.В.       17-1225  возьмем проводки сначала месяца, текущую не берем.
           , nvl( (select sum(mtrnsum) from /*V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v xm -->><<--07.11.2019 Баязитов [19-62184] Ежедневные комиссии УБРИР
                   where xm.ctrnaccd = trn.ctrnaccd
                     and xm.ctrncur=trn.ctrncur
                     and xm.dtrntran between trunc(p_d1, 'MM') and p_d1 -1/86400
                     and xm.ctrnmfoa in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr)  --! наши филиалы -> внутрибанк     -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
                     and ( --!  счет получателя, выделенный из трех полей платежного документа соответствует маскам 40817%,40820% ,423%,426%
                           xm.ctrnacca LIKE '40817%' OR xm.ctrnacca LIKE '40820%' OR
                           xm.ctrnacca LIKE '423%' OR xm.ctrnacca LIKE '426%' OR
                           regexp_substr(xm.CTRNOWNA, '\d{20}') LIKE '40817%' OR
                           regexp_substr(xm.CTRNOWNA, '\d{20}') LIKE '40820%' OR
                           regexp_substr(xm.CTRNOWNA, '\d{20}') LIKE '423%' OR
                           regexp_substr(xm.CTRNOWNA, '\d{20}') LIKE '426%' OR
                           regexp_substr(xm.ctrnpurp, '\d{20}') LIKE '40817%' OR
                           regexp_substr(xm.ctrnpurp, '\d{20}') LIKE '40820%' OR
                           regexp_substr(xm.ctrnpurp, '\d{20}') LIKE '423%' OR
                           regexp_substr(xm.ctrnpurp, '\d{20}') LIKE '426%')
                     and (    xm.ITRNTYPE = 4
                           or xm.ITRNTYPE = 2         -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
                           OR xm.ITRNTYPE in (11,28) -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
                          AND EXISTS( select 1
                                        from trc
                                       where trc.ITRCNUM = xm.ITRNNUMANC
                                         and trc.ITRCTYPE in (2,4) ) -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
                         )
                     and (lower(xm.CTRNPURP) not like '%командир%'
                     and lower(xm.CTRNPURP) not like '%кредит%'
                     and lower(xm.CTRNPURP) not like '%алимент%'
                     and lower(xm.CTRNPURP) not like '%з/п%'
                     and lower(xm.CTRNPURP) not like '%зар%пл%'
                     and lower(xm.CTRNPURP) not like '%аванс%'
                     and lower(xm.CTRNPURP) not like '%благотворит%'
                     and lower(xm.CTRNPURP) not like '%помощ%'
                     and lower(xm.CTRNPURP) not like '%агент%'
                     and lower(xm.CTRNPURP) not like '%подряд%'
                     and lower(xm.CTRNPURP) not like '%пособ%'
                     and lower(xm.CTRNPURP) not like '%стипенд%'
                     and lower(xm.CTRNPURP) not like '%страхов%'
                     and lower(xm.CTRNPURP) not like '%компенсац%'
                     and lower(xm.CTRNPURP) not like '%пенс%'
                     and lower(xm.CTRNPURP) not like '%возмещен%'
                     and lower(xm.CTRNPURP) not like '%отпускн%'
                     and lower(xm.CTRNPURP) not like '%увол%'
                     and lower(xm.CTRNPURP) not like '%преми%'
                     and lower(xm.CTRNPURP) not like '%дивиденд%'
                     and lower(xm.CTRNPURP) not like '%исп%лист%'
                     and lower(xm.CTRNPURP) not like '%судеб%реш%'
                     and lower(xm.CTRNPURP) not like '%реш%взыск%'
                     and lower(xm.CTRNPURP) not like '%уставн%'
                     and lower(xm.CTRNPURP) not like '%учредит%'
                     and lower(xm.CTRNPURP) not like '%судебн%'
                     and nvl(regexp_count(lower(xm.CTRNPURP),'труд'),0) = nvl(regexp_count(lower(xm.CTRNPURP),'сотрудник'),0) -- 19.09.2018 ubrr rizanov [18-251] АБС: Слова исключения по комиссии за платежи в пользу ФЛ ("сотрудник") 
                     and lower(xm.CTRNPURP) not like '%ипотек%'
                     and lower(xm.CTRNPURP) not like '%ипотеч%'
                     and lower(xm.CTRNPURP) not like '%вознагражд%'
                     and lower(xm.CTRNPURP) not like '%отпуск%'
                     and lower(xm.CTRNPURP) not like '%больничн%лист%'
                     and lower(xm.CTRNPURP) not like '%постановлен%'
                     and lower(xm.CTRNPURP) not like '%суд%приказ%'
                     and lower(xm.CTRNPURP) not like '%зп%'
                     and lower(xm.CTRNPURP) not like '%исполнит%'
                     and lower(xm.CTRNPURP) not like '%гонорар%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%б/лист%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%б\лист%'
                     and lower(xm.CTRNPURP) not like '%суточн%'
                     and lower(xm.CTRNPURP) not like '%сутк%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%з.пл%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%з\п%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%част%приб%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%межрасч%выплат%' )
                     and (   lower(xm.ctrnpurp) LIKE '%доход%ип%'
                          OR lower(xm.ctrnpurp) LIKE '%деятельност%ип%'
                          OR lower(xm.ctrnpurp) LIKE '%предпринимат%')
                     and (    xm.ITRNTYPE = 4
                           or xm.ITRNTYPE = 2         -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
                           OR xm.ITRNTYPE in (11,28) -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
                          AND EXISTS( select 1
                                        from trc
                                       where trc.ITRCNUM = xm.ITRNNUMANC
                                         and trc.ITRCTYPE in (2,4) ) -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
                         )
                     and not exists --если проведенная комиссия есть, например, осталась после удаления, заново НЕ выбираем.
                                 (select 1
                                  from ubrr_ulfl_tab_acc_coms c
                                  where c.DCOMDATERAS = p_d1
                                  and c.ICOMTRNNUM IS NOT NULL
                                  and c.ccomaccd = xm.CTRNACCD)
                     /*
                      Исключить клиентов, обслуживающихся по инд.тарифам (форма Настройки  комиссии для индвид.клиентов)
                     */
                     -->>09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ
                     /*and not exists (select 1
                                     from ubrr_unique_tarif
                                     where a.caccacc = cacc
                                     and xm.dtrncreate between DOPENTARIF and DCANCELTARIF
                                     and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)*/
                     --<<09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ                
           ) , 0)   SumBefo,
           to_number(to_char(NVL(o.iOTDbatnum,70) )||'00') batnum,
          'IP_DOH_VB' ctypecom  -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
           --<<23.10.2017  Малых Д.В.       17-1225
    from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn, acc a, otd o -->><<--23.10.2017  Малых Д.В.       17-1225 -->><<--07.11.2019 Баязитов [19-62184] Ежедневные комиссии УБРИР
    where cTRNcur = 'RUR'
    and a.iaccotd = o.iotdnum
    and cACCacc = cTRNaccd
    and cTRNaccd like p_mask
    and cACCacc  like p_mask
    and cACCprizn <> 'З'
    and dtrntran between p_d1 and p_d2
    AND trn.ctrnaccd LIKE '40802%'
    /*
       and ((trn.CTRNACCD like '40%' and
           to_number(substr(trn.CTRNACCD, 3, 1)) between 1 and 7) --! счет плательщика соответствует маскам 401-407%,40802%, 40807
           or trn.CTRNACCD like '40802%' or trn.CTRNACCD like '40807%' or
           trn.CTRNACCD like '42309%' or
    -- (нач.) UBRR Новолодский А. Ю. 23.05.2017 [17-71] АБС: Ошибка списании комиссиий по спецсчету на спецсчет по капремонту
           trn.CTRNACCD like '40821%'
           --trn.CTRNACCD like '40821________7______' or
           --trn.CTRNACCD like '40821________8______'
           )
    */
    -- (кон.) UBRR Новолодский А. Ю. 23.05.2017 [17-71] АБС: Ошибка списании комиссиий по спецсчету на спецсчет по капремонту
    -->>-- 10.03.2016  Пинаев Д.Е.      [15-1547]  АБС: Комиссия в пользу ФЛ - проставление кат/гр  https://redmine.lan.ubrr.ru/issues/29103
    and not exists (select /*+ index(GCS P_GCS_CUS_CAT_NUM)*/ 1
                    from gcs
                    where igcsCus = a.IACCCUS
                    and igcscat = 114
                    and igcsnum = 11
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where i_num=gcs.igcsCus
                                and i_table = 303
                                and d_create <= p_d2
                                and au.c_newdata like '114/' || to_char(gcs.igcsnum)))
    and not exists (select 1
                    from gac
                    where cgacacc = a.cACCacc
                    and cgaccur = a.cACCcur
                    and igaccat = 114
                    and igacnum = 11
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '114/' || to_char(gac.igacnum)))
    --<<-- 10.03.2016  Пинаев Д.Е.      [15-1547]  АБС: Комиссия в пользу ФЛ - проставление кат/гр  https://redmine.lan.ubrr.ru/issues/29103
    and not exists (select 1
                    from gac
                    where cgacacc = a.cACCacc
                    and cgaccur = a.cACCcur
                    and igaccat = 333
                    and igacnum = 2
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '333/' || to_char(gac.igacnum)))
    and not exists (select 1
                    from gac
                    where cgacacc = a.cACCacc
                    and cgaccur = a.cACCcur
                    and igaccat = 112
                    and igacnum in (1, 3, 4, 5, 7, 10, 13, 15, 16, 17, 19, 20, 21, 22, 23, 24, 25, 36, 37, 38, 39, 57, 76,
                                    70, -->><<-- 10.03.2016  Пинаев Д.Е.      [15-1547]  АБС: Комиссия в пользу ФЛ - проставление кат/гр
                                    71) -->><<-- 18.03.2016  Макарова Л.Ю.     [15-1726]  АБС: Комиссия в пользу ФЛ - проставление кат/гр )
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '112/' || to_char(gac.igacnum)))
    and not exists (select 1
                    from gac g1,
                         gac g2
                    where g1.cgacacc = a.cACCacc
                    and g1.cgaccur = a.cACCcur
                    and g2.cgacacc = a.cACCacc
                    and g2.cgaccur = a.cACCcur
                    and g1.igaccat = 333
                    and g1.igacnum = 4
                    and g2.igaccat = 112
                    and g2.igacnum in (74)
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '333/' || to_char(g1.igacnum))
                    and exists (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= p_d2
                                and au.c_newdata like '112/' || to_char(g2.igacnum)))
    and ( --!  счет получателя, выделенный из трех полей платежного документа соответствует маскам 40817%,40820% ,423%,426%
          trn.ctrnacca LIKE '40817%' OR trn.ctrnacca LIKE '40820%' OR
          trn.ctrnacca LIKE '423%' OR trn.ctrnacca LIKE '426%' OR
          regexp_substr(trn.CTRNOWNA, '\d{20}') LIKE '40817%' OR
          regexp_substr(trn.CTRNOWNA, '\d{20}') LIKE '40820%' OR
          regexp_substr(trn.CTRNOWNA, '\d{20}') LIKE '423%' OR
          regexp_substr(trn.CTRNOWNA, '\d{20}') LIKE '426%' OR
          regexp_substr(trn.ctrnpurp, '\d{20}') LIKE '40817%' OR
          regexp_substr(trn.ctrnpurp, '\d{20}') LIKE '40820%' OR
          regexp_substr(trn.ctrnpurp, '\d{20}') LIKE '423%' OR
          regexp_substr(trn.ctrnpurp, '\d{20}') LIKE '426%')
    and ctrnmfoa in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr) --! наши филиалы -> внутренний перевод  -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
    and (lower(trn.CTRNPURP) not like '%командир%'
    and lower(trn.CTRNPURP) not like '%кредит%'
    and lower(trn.CTRNPURP) not like '%алимент%'
    and lower(trn.CTRNPURP) not like '%з/п%'
    and lower(trn.CTRNPURP) not like '%зар%пл%'
    and lower(trn.CTRNPURP) not like '%аванс%'
    and lower(trn.CTRNPURP) not like '%благотворит%'
    and lower(trn.CTRNPURP) not like '%помощ%'
    and lower(trn.CTRNPURP) not like '%агент%'
    and lower(trn.CTRNPURP) not like '%подряд%'
    and lower(trn.CTRNPURP) not like '%пособ%'
    and lower(trn.CTRNPURP) not like '%стипенд%'
    and lower(trn.CTRNPURP) not like '%страхов%'
    and lower(trn.CTRNPURP) not like '%компенсац%'
    and lower(trn.CTRNPURP) not like '%пенс%'
    and lower(trn.CTRNPURP) not like '%возмещен%'
    and lower(trn.CTRNPURP) not like '%отпускн%'
    and lower(trn.CTRNPURP) not like '%увол%'
    and lower(trn.CTRNPURP) not like '%преми%'
    and lower(trn.CTRNPURP) not like '%дивиденд%'
    and lower(trn.CTRNPURP) not like '%исп%лист%'
    and lower(trn.CTRNPURP) not like '%судеб%реш%'
    and lower(trn.CTRNPURP) not like '%реш%взыск%'
    and lower(trn.CTRNPURP) not like '%уставн%'
    and lower(trn.CTRNPURP) not like '%учредит%'
    -->> 23.10.2017 Малых Д.В. 17-1225
    /*
    and lower(trn.CTRNPURP) not like '%подотчет%'
    and lower(trn.CTRNPURP) not like '%подотчёт%'
    and lower(trn.CTRNPURP) not like '%под отчет%'
    and lower(trn.CTRNPURP) not like '%под отчёт%'
    */
    --<< 23.10.2017 Малых Д.В. 17-1225
    -- and lower(trn.CTRNPURP) not like '%предпринимат%'
    /*and lower(trn.CTRNPURP) not like '%хоз%нужд%'*/ -->><<--  23.10.2017 Малых Д.В. 17-1225
    and lower(trn.CTRNPURP) not like '%судебн%'
    and nvl(regexp_count(lower(trn.CTRNPURP),'труд'),0) = nvl(regexp_count(lower(trn.CTRNPURP),'сотрудник'),0) -- 19.09.2018 ubrr rizanov [18-251] АБС: Слова исключения по комиссии за платежи в пользу ФЛ ("сотрудник")              
    -->> 09.12.2015  ubrr pinaev      15-995     Добавление исключений https://redmine.lan.ubrr.ru/issues/26464
    and lower(trn.CTRNPURP) not like '%ипотек%'
    and lower(trn.CTRNPURP) not like '%ипотеч%'
    and lower(trn.CTRNPURP) not like '%вознагражд%'
    and lower(trn.CTRNPURP) not like '%отпуск%'
    and lower(trn.CTRNPURP) not like '%больничн%лист%'
    and lower(trn.CTRNPURP) not like '%постановлен%'
    and lower(trn.CTRNPURP) not like '%суд%приказ%'
    and lower(trn.CTRNPURP) not like '%зп%'
    /*and lower(trn.CTRNPURP) not like '%хоз%расх%'*/-->><<--  23.10.2017 Малых Д.В. 17-1225
    --<< 09.12.2015  ubrr pinaev      15-995     Добавление исключений #26464 https://redmine.lan.ubrr.ru/issues/26464
    -->> 19.02.2016 Пинаев Д.Е.   #28454 АБС: Комиссия за перевод ЮЛ - ФЛ в %. Исключения платежей.
    and lower(trn.CTRNPURP) not like '%исполнит%'
    and lower(trn.CTRNPURP) not like '%гонорар%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%б/лист%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%б\лист%'
    --and lower(trn.CTRNPURP) not like '%доход%ип%'
    --and lower(trn.CTRNPURP) not like '%деятельност%ип%'
    --<< 19.02.2016 Пинаев Д.Е.   #28454 АБС: Комиссия за перевод ЮЛ - ФЛ в %. Исключения платежей.
    -->> ubrr korolkov
    and lower(trn.CTRNPURP) not like '%суточн%'
    and lower(trn.CTRNPURP) not like '%сутк%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%з.пл%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%з\п%'
    --<< ubrr korolkov
    -->> 22.08.2017  Макарова Л.Ю. [17-1031] АБС: Добавить слова исключения для расчета комиссии при переводе средств в пользу ФЛ
    and lower(replace(trn.CTRNPURP,' ')) not like '%част%приб%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%межрасч%выплат%' )
    --<< 22.08.2017  Макарова Л.Ю. [17-1031] АБС: Добавить слова исключения для расчета комиссии при переводе средств в пользу ФЛ
    -->> 23.10.2017 Малых Д.В. 17-1225
    and (   lower(trn.ctrnpurp) LIKE '%доход%ип%'
         or lower(trn.ctrnpurp) LIKE '%деятельност%ип%'
         or lower(trn.ctrnpurp) LIKE '%предпринимат%')
    --<< 23.10.2017 Малых Д.В. 17-1225
    and (    ITRNTYPE = 4
          or ITRNTYPE = 2      -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
          OR ITRNTYPE in (11,28) 
         AND EXISTS( select 1
                       from trc
                      where trc.ITRCNUM = trn.ITRNNUMANC
                        and trc.ITRCTYPE in (2,4) ) -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
        )                                                   
    and not exists --если проведенная комиссия есть, например, осталась после удаления, заново НЕ выбираем.
                  (select 1
                   from ubrr_ulfl_tab_acc_coms c
                   where c.DCOMDATERAS = p_d1
                   and c.ICOMTRNNUM IS NOT NULL
                   and c.ccomaccd = trn.CTRNACCD)
    /*
     Исключить клиентов, обслуживающихся по инд.тарифам (форма Настройки  комиссии для индвид.клиентов)
    */
    -->>09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ
    /*and not exists (select 1
                    from ubrr_unique_tarif
                    where a.caccacc = cacc
                    and trn.dtrncreate between DOPENTARIF and DCANCELTARIF
                    and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)*/
    --<<09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ                
    and not exists (select 1
                    from ubrr_data.ubrr_sbs_new
                    where idsmr = a.idsmr
                    and dSBSdate = p_d1
                    and cSBSaccd = a.caccacc
                    and cSBScurd = a.cacccur
                    and cSBSTypeCom = 'IP_DOH_VB'
                    and iSBStrnnum is not null)
  --<< 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ                                         
 ;
    -->><<--  23.10.2017 Малых Д.В. 17-1225  по ТЗ

    -- проверяем наличие выделенных групп и категорий
    cursor specAcc(p_CACCACC varchar2,
                   p_cacccur varchar2,
                   p_d1      DATE,
                   p_d2      DATE) 
    is
    (select 1 as flag
     from au_attach_obg a1
     where caccacc = p_caccacc
       and cacccur = p_cacccur
       and c_newdata = '112/75'
       and p_d1 between trunc(d_create, 'mm') and last_day(add_months(d_create, 5))
       and exists
               (select 1
                from gac
                where cgacacc = p_caccacc and cgaccur = p_cacccur and igaccat = 112 and igacnum = 75
                union
                select 1
                from au_attach_obg a2
                where a2.caccacc = p_caccacc
                  and a2.cacccur = p_cacccur
                  and a2.i_table = 304 -- cg_autab
                  and a2.c_olddata = '112/75'
                  and a2.d_create > last_day(add_months(a1.d_create, 5))))
    union
    (select 1 as flag
     from gac
     where cgacacc = p_caccacc
       and cgaccur = p_cacccur
       and igaccat = 112
       and igacnum = 40
       and exists
               (select 1
                from xxi.au_attach_obg au
                where au.caccacc = p_caccacc
                  and au.cacccur = p_cacccur
                  and au.i_table = 304
                  and au.d_create <= p_d2 -- создна не позднее чем конец периода
                  and add_months(last_day(au.d_create), 11) > p_d1 -- посл день периода создания не ранее чем 11 месяцев назад от начала периода
                  and au.c_newdata = '112/40'))
    union
    (select 1 as flag
     from     xxi.au_attach_obg au_s
          inner join
              xxi.au_attach_obg au_e
          on au_e.caccacc = au_s.caccacc and au_e.cacccur = au_s.cacccur and au_e.i_table = 304 and au_e.C_OLDDATA = '112/40'
     where au_s.caccacc = p_caccacc
       and au_s.cacccur = 'RUR'
       and au_s.i_table = 304
       and au_s.d_create <= p_d2
       and au_e.d_create >= p_d1
       and add_months(last_day(au_s.d_create), 11) > p_d1
       and au_s.c_newdata = '112/40')
    union
    (select 1 as flag
     from xxi.au_attach_obg au
     where au.caccacc = p_caccacc
       and au.cacccur = p_cacccur
       and add_months(last_day(au.d_create), 3) > p_d1
       and au.d_create <= p_d2
       and au.i_table = 304 -- cg_autab
       and au.c_newdata = '112/59'
       and not exists
                   (select 'x'
                    from xxi.au_attach_obg au2
                    where au2.caccacc = au.caccacc
                      and au2.cacccur = au.cacccur
                      and au2.c_olddata = '112/59'
                      and au2.d_create >= au.d_create
                      and add_months(au2.d_create, 1) <= p_d2))
    union
    (select 1 as flag
     from gac
     where cgacacc = p_caccacc
       and cgaccur = p_cacccur
       and igaccat = 112
       and igacnum = 50
       and exists
               (select 1
                from xxi.au_attach_obg au
                where au.caccacc = p_caccacc
                  and au.cacccur = p_cacccur
                  and i_table = 304
                  and d_create <= p_d2
                  and add_months(last_day(d_create), 5) > p_d1
                  and au.c_newdata = '112/50'))
    -->> 21.02.2018 ubrr korolkov 18-12.1
    /*
    union
    select 1
    from gac
    where cgacacc = p_caccacc
      and cgaccur = p_cacccur
      and ((cg_is_vuz = 0 and igaccat = 112 and igacnum = 96)
           or
           (cg_is_vuz = 1 and igaccat = 112 and igacnum = 1017))
      and exists (select 1
                  from xxi.au_attach_obg au
                  where au.caccacc = p_caccacc
                    and au.cacccur = p_cacccur
                    and i_table = cg_autab
                    and d_create <= p_d2
                    and au.c_newdata = gac.igaccat || '/' || gac.igacnum)
    */
    --<< 21.02.2018 ubrr korolkov 18-12.1
    ;

  subtype t_Rec_specAcc is specAcc%rowtype;

  /*
  БТП. Межбанковский платеж в электронном виде для ТП "Экспресс 100"
  часть кода из процедуры "UBRR_XXI5"."UBRR_BNKSERV"
  строка 2872
  */

--  при этом экспресс делится на БТП и НТК
  cursor express100_cur(d1 date, d2 date, acc_1 varchar2) IS
    select ITRNNUM
      from (select ITRNNUM,
                   ctrnaccd,
                   ctrncur,
                   iACCotd,
                   ROW_NUMBER() over(partition by ctrnaccd, ctrncur, iACCotd order by ITRNNUM) rn
              from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v, acc a -->><<--07.11.2019 Баязитов [19-62184] Ежедневные комиссии УБРИР
              -->> 08.12.2015 Пинаев 15-995 https://redmine.lan.ubrr.ru/issues/26464 Ошибка #26464
                   ,(select g.cgacacc
                      from gac g
                     where g.igaccat = 112
                       and g.igacnum in (45, 81, 82, 83, 84, 85)
                       and exists
                     (select 1
                              from xxi.au_attach_obg au
                             where au.caccacc = g.cGACacc
                               and au.cacccur = g.cGACcur
                               and i_table = 304
                               and d_create <= d2
                               and au.c_newdata like
                                   '112/' || to_char(g.igacnum))) g
                --<< 08.12.2015 Пинаев 15-995 https://redmine.lan.ubrr.ru/issues/26464 Ошибка #26464
             where ctrnaccd like acc_1
             -->> 08.12.2015 Пинаев 15-995 https://redmine.lan.ubrr.ru/issues/26464 Ошибка #26464
               and a.caccacc = g.cgacacc -- Отсекаться должны лишь трн счетов с ТП Экспресс
               --<< 08.12.2015 Пинаев 15-995 https://redmine.lan.ubrr.ru/issues/26464 Ошибка #26464
               and ctrncur = 'RUR'
               and dtrntran between d1 and d2
               and ((itrntype in (4, 11, 15, 21, 22, 23) and
                   not (itrnpriority in (3, 4, 5)

                    and substr(ctrnacca, 1, 3) in
                    ('401', '402', '403', '404') and exists
                     (select 1
                             from trn_dept_info
                            where inum = itrnnum
                              and ianum = itrnanum
                              and ccreatstatus is not null))))
               and itrnsop = 4
               and ctrnmfoa not in (select cfilmfo from xxi."fil")
               and iTRNba2d not in (40813, 40817, 40818, 40820, 42309)
               and cACCacc = cTRNaccd
               and cACCcur = cTRNcur
               and cACCprizn <> 'З'
               and substr(caccacc, 1, 3) not in
                   ('401', '402', '403', '404', '409')
               and substr(to_char(itrnbatnum), 3) not in ('10', '13')
               and not exists (select 1
                      from gac
                     where cgacacc = a.cACCacc
                       and igaccat = 333
                       and igacnum = 2)
               and not exists
             (select 1
                      from gac
                     where cgacacc = a.cACCacc
                       and igaccat = 131
                       and exists
                     (select 1
                              from xxi.au_attach_obg au
                             where au.caccacc = a.cACCacc
                               and au.cacccur = a.cACCcur
                               and i_table = 304
                               and d_create <= d2
                               and au.c_newdata like '131%'))
                -->>23.10.2017  Малых Д.В.       17-1225  условие проверяется ранее (не понятно зачем это было включено, как следствие не попадали счета с категорией 112\81-85)
               /*and (exists (select 1
                              from xxi.au_attach_obg au
                             where au.caccacc = a.cACCacc
                               and au.cacccur = a.cACCcur
                               and d_create <= d2
                               and d_create >= d1
                               and i_table = 304
                               and au.c_newdata = '112/45') or exists
                    (select 1
                       from gac
                      where cgacacc = a.caccacc
                        and cgaccur = a.cacccur
                        and igaccat = 112
                        and igacnum = 45
                        and exists
                      (select 1
                               from xxi.au_attach_obg au
                              where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and d_create <= d2
                                and au.c_newdata = '112/45')))*/
                  -->>23.10.2017  Малых Д.В.       17-1225 условие проверяется ранее (не понятно зачем это было включено, как следствие не попадали счета с категорией 112\81-85)
               and not exists
             (select 1
                      from ubrr_unique_tarif
                     where ctrnaccd = cacc
                       and dtrncreate between DOPENTARIF and DCANCELTARIF
                       and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)           -->><<-- ubrr Арсланов Д.Ф. #29736 Доработки по РКО для ВУЗ
               and not exists
             (select 1
                      from gac
                     where cgacacc = a.cACCacc
                       and cgaccur = a.cACCcur
                       and igaccat = 112
                       and igacnum in (78, 79, 80)
                       and exists
                     (select 1
                              from xxi.au_attach_obg au
                             where au.caccacc = a.cACCacc
                               and au.cacccur = a.cACCcur
                               and i_table = 304
                               and d_create <= d2
                               and au.c_newdata like
                                   '112/' || to_char(gac.igacnum))))
     where rn <= 30;

  TYPE t_Rec_express100 IS TABLE OF express100_cur%ROWTYPE INDEX BY PLS_INTEGER;

  /*
  Первые 30 операций без комиссии. НТК
  строка 3209 UBRR_BNKSERV
  */
  cursor ntk_cur(d1 date, d2 date, acc_1 varchar2) IS
    select ITRNNUM
      from (select ITRNNUM,
                   ctrnaccd,
                   ctrncur,
                   iACCotd,
                   g.cgacacc,
                   ROW_NUMBER() over(partition by ctrnaccd, ctrncur, iACCotd order by ITRNNUM) rn
              from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v, -->><<--07.11.2019 Баязитов [19-62184] Ежедневные комиссии УБРИР
                   acc a,
                   (select g.cgacacc
                      from gac g
                     where g.igaccat = 112
                       and g.igacnum in (45, 81, 82, 83, 84, 85)
                       and exists
                     (select 1
                              from xxi.au_attach_obg au
                             where au.caccacc = g.cGACacc
                               and au.cacccur = g.cGACcur
                               and i_table = 304
                               and d_create <= d2
                               and au.c_newdata like
                                   '112/' || to_char(g.igacnum))) g
             where ctrnaccd like acc_1
               and ctrncur = 'RUR'
               and dtrntran between d1 and d2
               and not exists
             (select 1
                      from gac
                     where cgacacc = a.caccacc
                       and cgaccur = a.CACCCUR
                       and igaccat = 114
                       and igacnum = 10
                       and exists
                     (select 1
                              from xxi.au_attach_obg au
                             where au.caccacc = a.caccacc
                               and au.cacccur = a.CACCCUR
                               and i_table = 304
                               and d_create <= d2
                               and au.c_newdata = '114/10'))
               and ( -- межбанк
                    (((itrntype in (4, 11, 15, 21, 22, 23) and
                    not (itrnpriority in (3, 4, 5)

                     and substr(ctrnacca, 1, 3) in
                     ('401', '402', '403', '404') and exists
                      (select 1
                               from trn_dept_info
                              where inum = itrnnum
                                and ianum = itrnanum
                                and ccreatstatus is not null)))) and
                    ctrnmfoa not in (select cfilmfo from xxi."fil") and
                    substr(to_char(itrnbatnum), 3) not in ('10', '13'))
                   -- Внутрибанк, бумага
                    or
                    ((((itrntype in (2, 3, 14) and itrnpriority not in (3, 4) and
                    nvl(iTRNsop, 0) <> 4) or
                    (itrntype in (25, 28) and
                    nvl(iTRNsop, 0) not in (5, 7) and
                    itrnpriority not in (3, 4))) and
                    (substr(itrnba2c, 1, 3) in
                    (303, 405, 406, 407, 423, 426) or
                    itrnba2c in (40802, 40807, 40817, 40818, 40820))) or
                    (itrntype in (4,
                                   11,
                                   15,
                                   21, --22,
                                   23) and
                    not (itrnpriority in (3, 4, 5)

                     and substr(ctrnacca, 1, 3) in
                     ('401', '402', '403', '404') and exists
                      (select 1
                              from trn_dept_info
                             where inum = itrnnum
                               and ianum = itrnanum
                               and ccreatstatus is not null)) and
                    nvl(iTRNsop, 0) <> 4 and
                    ctrnmfoa in (select cfilmfo from xxi."fil"))))
               and iTRNba2d not in (40813, 40817, 40818, 40820, 42309)
               and cACCacc = cTRNaccd
               and cACCcur = cTRNcur
               and cACCprizn <> 'З'
               and a.caccacc = g.cgacacc
               -->> 08.12.2015 Пинаев 15-995 https://redmine.lan.ubrr.ru/issues/26464 Ошибка #26464
               /*(+)*/ -- До этого выбирались счета, не имеющие отношения к ТП ЭКСПРЕСС
               --<< 08.12.2015 Пинаев 15-995 https://redmine.lan.ubrr.ru/issues/26464 Ошибка #26464
               --------------------------
               and substr(caccacc, 1, 3) not in
                   ('401', '402', '403', '404', '409')
               and exists (select 1
                      from gac
                     where cgacacc = a.cACCacc
                       and cgaccur = a.cACCcur
                       and igaccat = 131
                       and exists
                     (select 1
                              from xxi.au_attach_obg au
                             where au.caccacc = a.cACCacc
                               and au.cacccur = a.cACCcur
                               and i_table = 304
                               and d_create <= d2
                               and au.c_newdata like '131%'))
               and not exists (select 1
                      from gac
                     where cgacacc = a.cACCacc
                       and cgaccur = a.cACCcur
                       and igaccat = 112
                       and igacnum in (36, 37, 38, 39, 40))
               and not exists
             (select 1
                      from gac
                     where cgacacc = a.cACCacc
                       and cgaccur = a.cACCcur
                       and igaccat = 112
                       and igacnum = 50
                       and exists
                     (select 1
                              from xxi.au_attach_obg au
                             where au.caccacc = a.cACCacc
                               and au.cacccur = a.cACCcur
                               and i_table = 304
                               and d_create <= d2
                               and add_months(last_day(d_create), 5) > d1
                               and au.c_newdata = '112/50'))

               and not exists (select 1
                      from xxi.au_attach_obg au
                     where au.caccacc = a.cACCacc
                       and au.cacccur = a.cACCcur
                       and add_months(last_day(d_create), 5) > d1
                       and d_create <= d2
                       and i_table = 304
                       and au.c_newdata = '112/50')
             and not exists
                    (select 1
                      from au_attach_obg a1
                     where caccacc = a.CACCACC
                       and cacccur = a.CACCCUR
                       and c_newdata = cg_112_72
                       and d1 between trunc(d_create, 'mm') and
                           last_day(add_months(d_create, 5))
                       and exists
                     (select 1
                              from gac
                             where cgacacc = a1.caccacc
                               and gac.CGACCUR = a1.cacccur
                               and igaccat = 112
                               and igacnum = 72
                            union
                            select 1
                              from au_attach_obg a2
                             where a2.caccacc = a1.caccacc
                               and a2.cacccur = a1.cacccur
                               and a2.i_table = cg_autab
                               and a2.c_olddata = cg_112_72
                               and a2.d_create <
                                   last_day(add_months(a1.d_create, 5))))
               and not exists
             (select 1
                      from au_attach_obg a1
                     where caccacc = a.CACCACC
                       and cacccur = a.CACCCUR
                       and c_newdata = cg_112_35
                       and d1 between trunc(d_create, 'mm') and
                           last_day(add_months(d_create, 2))
                       and exists
                     (select 1
                              from gac
                             where cgacacc = a1.caccacc
                               and gac.CGACCUR = a1.cacccur
                               and igaccat = 112
                               and igacnum = 35
                            union
                            select 1
                              from au_attach_obg a2
                             where a2.caccacc = a1.caccacc
                               and a2.cacccur = a1.cacccur
                               and a2.i_table = cg_autab
                               and a2.c_olddata = cg_112_35
                               and a2.d_create <
                                   last_day(add_months(a1.d_create, 2))))
               and not exists
             (select 1
                      from gac
                     where cgacacc = a.cACCacc
                       and cgaccur = a.cACCcur
                       and igaccat = 112
                       and igacnum in (78, 79, 80)
                       and exists
                     (select 1
                              from xxi.au_attach_obg au
                             where au.caccacc = a.cACCacc
                               and au.cacccur = a.cACCcur
                               and i_table = 304
                               and d_create <= d2
                               and au.c_newdata like
                                   '112/' || to_char(gac.igacnum)))
               and not exists
             (select 1
                      from gac
                     where cgacacc = a.caccacc
                       and cgaccur = a.cacccur
                       and igaccat = 112
                       and igacnum in (67, 86, 87, 88, 89, 90)
                       and exists
                     (select 1
                              from xxi.au_attach_obg au
                             where au.caccacc = a.cACCacc
                               and au.cacccur = a.cACCcur
                               and i_table = 304
                               and d_create <= d2
                               and au.c_newdata like
                                   '112/' || to_char(gac.igacnum)))
               and not exists
             (select 1
                      from ubrr_unique_tarif
                     where ctrnaccd = cacc
                       and dtrncreate between DOPENTARIF and DCANCELTARIF
                       and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)           -->><<-- ubrr Арсланов Д.Ф. #29736 Доработки по РКО для ВУЗ
         )
     WHERE
      -->> 09.12.2015  ubrr pinaev      15-995     Ошибка #26464 https://redmine.lan.ubrr.ru/issues/26464
        /* cgacacc is null
        or cgacacc is not null and */
        --<<  09.12.2015  ubrr pinaev      15-995     Ошибка #26464 https://redmine.lan.ubrr.ru/issues/26464
        rn <= 30;

  TYPE t_Rec_ntk IS TABLE OF ntk_cur%ROWTYPE INDEX BY PLS_INTEGER;

  ----------------------------------- Функции и процедуры -----------------------------------------------------------------
  function is_special_grp_condition_true(p_cTRNaccd varchar2,
                                         p_cacccur  varchar2,
                                         p_d1       date,
                                         p_d2       date) return integer is
    iFlag integer;
    vRes  t_Rec_specAcc;
  begin
    -- Для особо выделенных кат/гр
    open specAcc(p_cTRNaccd, p_cacccur, p_d1, p_d2);
    fetch specAcc
      into vRes;
    if specAcc%notfound then
      iFlag := 1; --  НЕТ записей как в постановке для особых групп нету, пусто. Значит БЕРЕМ TRN
    else
      iFlag := 0; -- условие не выполняется, ненужные записи в аудите присутствуют, НЕ БЕРЕМ запись TRN
    end if;
    close specAcc;
    return(iFlag);
  end is_special_grp_condition_true;

  /*
  если itrnnum попадает в первые 30 операций, за которые не взимается комиссия, возвращаем 1, иначе - 0
  */
  function is_free_express100_trn(c_express t_Rec_express100,
                                  i_itrnnum number) return integer IS
  begin
    FOR i IN 1 .. c_express.COUNT LOOP
      if c_express(i).itrnnum = i_itrnnum then
        return 1;
      end if;
    END LOOP;
    return 0;
  end is_free_express100_trn;
  /*
  первые 30 операций для Ntk
  */
  function is_free_ntk_trn(c_ntk t_Rec_ntk, i_itrnnum number) return integer IS
  begin
    FOR i IN 1 .. c_ntk.COUNT LOOP
      if c_ntk(i).itrnnum = i_itrnnum then
        return 1;
      end if;
    END LOOP;
    return 0;
  end is_free_ntk_trn;

  /*
  зная сумму оборота и шкалу, вычисляем комиссию
  */
  function get_comss_sum(p_sum number, p_scale_id integer) return number is
    CURSOR lim_cur(p_id integer) IS
      select ilimop_sum as slag,
             nvl(ilimop_sum_lead, 999999999) as slead,
             ILIMCOM_SUM as srate,
             ilimper as prate
        from (select l.*,
                     LEAD(l.ilimop_sum) over(order by l.ilimop_sum) as ilimop_sum_lead
                from lim l
               where l.ilimcol_id = p_id
                 and l.climdc = 'D');
    TYPE cLim IS TABLE OF lim_cur%ROWTYPE INDEX BY PLS_INTEGER;
    l_lim cLim;

  begin
    open lim_cur(p_scale_id);
    fetch lim_cur BULK COLLECT
      into l_lim;
    close lim_cur;

    FOR i IN 1 .. l_lim.COUNT LOOP
      if p_sum >= l_lim(i).slag and p_sum < l_lim(i).slead then
        if l_lim(i).srate is not null then
          --фиксированная сумма
          return l_lim(i).srate;
        end if;
        if l_lim(i).prate is not null then
          --процент от суммы
          return round(l_lim(i).prate * p_sum / 100, 2);
        end if;
      end if;
    END LOOP;
    return - 1;
  end get_comss_sum;

  /*
  вычисляем шкалу из таблицы UBRR_ULFL_COMSS_SCALE
  */
  function get_comss_scale(p_idsmr  in NUMBER,
                           p_idotdn in NUMBER,
                           p_sum    in NUMBER) return INTEGER is
    TYPE cScale IS TABLE OF UBRR_ULFL_COMSS_SCALE%ROWTYPE INDEX BY PLS_INTEGER;
    l_scale cScale;

  begin
    SELECT * BULK COLLECT INTO l_scale FROM UBRR_ULFL_COMSS_SCALE;

    FOR i IN 1 .. l_scale.COUNT LOOP
      if l_scale(i).idsmr = p_idsmr and l_scale(i).idotdn = p_idotdn and
          p_sum between l_scale(i).ifromsumm and
          nvl(l_scale(i).itosumm, 9999999999) then
        return l_scale(i).idscale;
      end if;
    END LOOP;

    FOR i IN 1 .. l_scale.COUNT LOOP
      if l_scale(i).idsmr = p_idsmr and l_scale(i).idotdn = -1 and
          p_sum between l_scale(i).ifromsumm and
          nvl(l_scale(i).itosumm, 9999999999) then
        return l_scale(i).idscale;
      end if;
    END LOOP;

    FOR i IN 1 .. l_scale.COUNT LOOP
      if l_scale(i).idsmr = -1 and l_scale(i).idotdn = -1 and
          p_sum between l_scale(i).ifromsumm and
          nvl(l_scale(i).itosumm, 9999999999) then
        return l_scale(i).idscale;
      end if;
    END LOOP;

    return - 1;
  end get_comss_scale;

  /*
  Выбрать из TRN подходящие и посчитать комиссию
  Запускается из формы ubrr_ulfl_acc_coms
  */
function calc_mask_comss(p_date date, p_mask varchar2)
    return varchar2
is
    vErr         varchar2(2000);
    IBO1         NUMBER;
    IBO2         NUMBER;
    cvcomstat    VARCHAR2(2000);
    -- iScale       integer; ->><<--23.10.2017  Малых Д.В. 17-1225 не используется  в текущем рассчете
    nComSum      number;
    --CMASK        VARCHAR2(20);
    --Caccc        VARCHAR2(20);
    --Ccurc        VARCHAR2(3);
    iCnt         integer;
    iAllCnt      integer;
    d2           date;
    iSessionId   number;
    --c_express100 t_Rec_express100; -->><<--23.10.2017  Малых Д.В. 17-1225 доп требования
    -- c_ntk        t_Rec_ntk;       -->><<--23.10.2017  Малых Д.В. 17-1225 доп требования
    cComm        varchar2(200);
    vCusNum      number;
    ismrrr       number(5);
    -->><<--23.10.2017  Малых Д.В. 17-1225 не используется   в текущем рассчете
    /*
    cursor c_smr is
    select idsmr from ubrr_smr;     -->><<-- ubrr Арсланов Д.Ф. #29736 Доработки по РКО для ВУЗ
    */
    -->><<--23.10.2017  Малых Д.В. 17-1225 не используется  в текущем рассчете
BEGIN
    vErr    := 'OK';
    iBO1    := 25;
    iBO2    := 5;
    d2      := /*ADD_MONTHS(p_date, 1) - 1 / 24 / 60 / 60;*/  p_date+ 86399/86400;-->><<--23.10.2017  Малых Д.В. 17-1225   изменил, по ТЗ
    iAllCnt := 0;

    -->>23.10.2017  Малых Д.В.       17-1225  очистку целевой таблицы перенес ниже
    /*
    delete from ubrr_ulfl_tab_acc_coms
    where DCOMDATERAS = p_date
    and ICOMTRNNUM IS NULL
    and ccomaccd like p_mask;
    */
    --<<23.10.2017  Малых Д.В.       17-1225   очистку целевой таблицы перенес ниже

    execute immediate 'truncate table UBRR_DATA.UBRR_ULFL_TEMP';
    execute immediate 'truncate table UBRR_DATA.UBRR_ULFL_TRACE';
    -->>23.10.2017  Малых Д.В. 17-1225 не используется
    /*
    for c in c_smr loop
    XXI_CONTEXT.Set_IDSmr(c.idsmr);
    */
    -->>23.10.2017  Малых Д.В. 17-1225 не используется

    ismrrr := ubrr_xxi5.ubrr_util.GetBankIdSmr;-->><<--04.12.2017 Малых Д.В. https://redmine.lan.ubrr.ru/issues/47017#note-69 --sys_context('B21', 'IdSmr'); --корректное логирование

    select UBRR_DATA.UBRR_ULFL_SESSION_SEQ.NEXTVAL
    into iSessionId
    from dual;

    INSERT INTO UBRR_DATA.UBRR_ULFL_TRACE
    VALUES (sysdate, 'Begin of idsmr=' || ismrrr || '  iSessionId=' || iSessionId);
    commit;
      -->>23.10.2017  Малых Д.В. 17-1225 доп требования
      /*
      -- читаем все операции экспресс 100 за которые не взимается комиссия
      open express100_cur(trunc (p_date, 'MM'), d2, p_mask); -->><<--23.10.2017  Малых Д.В. 17-1225 https://redmine.lan.ubrr.ru/issues/47017#note-14
      fetch express100_cur BULK COLLECT
        into c_express100;
      close express100_cur;
      cComm := 'выбрали express100: count=' || to_char(c_express100.count);
      INSERT INTO UBRR_DATA.UBRR_ULFL_TRACE VALUES (sysdate, cComm);
      commit;

      -- читаем все операции НТК за которые не взимается комиссия
      open ntk_cur(trunc (p_date, 'MM'), d2, p_mask); -->><<--23.10.2017  Малых Д.В. 17-1225 https://redmine.lan.ubrr.ru/issues/47017#note-14
      fetch ntk_cur BULK COLLECT
        into c_ntk;
      close ntk_cur;

      cComm := 'выбрали НТК: count=' || to_char(c_ntk.count);
      INSERT INTO UBRR_DATA.UBRR_ULFL_TRACE VALUES (sysdate, cComm);
      commit;
      */
      --<<23.10.2017  Малых Д.В. 17-1225 доп требования
      -->> 09.12.2015  ubrr pinaev      15-995     Ошибка #26464 https://redmine.lan.ubrr.ru/issues/26464

    iCnt :=0;
    --<< 09.12.2015  ubrr pinaev      15-995     Ошибка #26464 https://redmine.lan.ubrr.ru/issues/26464
    for rec_temp in get_calcTrn(p_date, d2, p_mask, ismrrr) loop
        if is_special_grp_condition_true(rec_temp.ctrnaccd, 'RUR', p_date, d2) = 1
           -->>23.10.2017  Малых Д.В. 17-1225 доп требования
           /*and
           is_free_express100_trn(c_express100, rec_temp.itrnnum) = 0 and
           is_free_ntk_trn(c_ntk, rec_temp.itrnnum) = 0 */
           -->>23.10.2017  Малых Д.В. 17-1225 доп требования
        then
            insert into UBRR_ULFL_TEMP
            values (iSessionId,
                    rec_temp.ITRNNUM,
                    rec_temp.ctrnaccd,
                    rec_temp.ctrncur,
                    rec_temp.mtrnsum,
                    rec_temp.CACCPRIZN,
                    rec_temp.IDSMR,
                    rec_temp.iaccotd,
                    rec_temp.Sumbefo,
                    rec_temp.batnum,
                    rec_temp.ctypecom -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
                    ); -->><<--23.10.2017  Малых Д.В.       17-1225  добавил поля   (коменты к полям в таблице)
            commit;
            -->> 09.12.2015  ubrr pinaev      15-995     Ошибка #26464 https://redmine.lan.ubrr.ru/issues/26464
            iCnt := iCnt+1;
            --<< 09.12.2015  ubrr pinaev      15-995     Ошибка #26464 https://redmine.lan.ubrr.ru/issues/26464
        end if;
    end loop;

    -->> 09.12.2015  ubrr pinaev      15-995     Ошибка #26464 https://redmine.lan.ubrr.ru/issues/26464
    cComm := 'закончили выбирать trn в UBRR_ULFL_TEMP count=' || iCnt;
    --<< 09.12.2015  ubrr pinaev      15-995     Ошибка #26464 https://redmine.lan.ubrr.ru/issues/26464

    INSERT INTO UBRR_DATA.UBRR_ULFL_TRACE VALUES (sysdate, cComm);
    commit;

    for rec in (select ctrnaccd,
                       ctrncur,
                       sum(mtrnsum) mtrnsum,
                       CACCPRIZN,
                       IDSMR,
                       iaccotd,
                       -->>23.10.2017  Малых Д.В. 17-1225 добавил поля
                       count(*) cnt,
                       max(Sumbefo) Sumbefo,
                       batnum,
                       ctypecom  -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ 
                       -->>23.10.2017  Малых Д.В. 17-1225 добавил поля
                from UBRR_ULFL_TEMP
                where id = iSessionId
                group by ctrnaccd, ctrncur, CACCPRIZN, IDSMR, iaccotd, batnum
                        ,ctypecom -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
               )
    loop
        /* iScale := get_comss_scale(rec.IDSMR, rec.iaccotd, rec.mtrnsum); -- найдем шкалу*/ -->><<--23.10.2017  Малых Д.В. 17-1225 штука больше не нужна рассчет комиссии и шкалы ниже
        /*
        В дополнение к стандартному алгоритму определения доходного счета, необходимо предусмотреть выбор доходного счета
        для списания комиссии, в соответствии с таблицей со-ответствия (которая пока не реализована) в разрезе типа клиента ЮЛ/ИП
        (определять по наличию кат/гр  15/4 на клиенте, таблица XXI.GCS). При выполнении доработки по двум веткам кода оставить тот же самый принцип получения маски доходного счета, описанный выше.
        */
        -->>--  16.06.2016  Пинаев Д.Е.      [16-2126] Доработка комиссионных модулей 446-П (новые счета)
        /*select count(*)
          into iCnt
          from acc a, gcs g
         where a.IACCCUS = g.igcscus
           and a.caccacc = rec.ctrnaccd
           and g.igcscat = 15
           and g.igcsnum = 4;

        if iCnt > 0 then
          -- ИП
          CMask := '70601810_' || rec.iaccotd || '2102320';
        else
          -- ЮЛ
          CMask := '70601810_' || rec.iaccotd || '2102320';
        end if;
        */
        --CMask := UBRR_RKO_SYMBOLS.get_new_rko_mask(to_char(rec.iaccotd), '320', rec.ctrnaccd, rec.ctrncur, '27402','27403');
        --<<--  16.06.2016  Пинаев Д.Е.      [16-2126] Доработка комиссионных модулей 446-П (новые счета)

        nComSum   := 0;
        cvcomstat := 'Новая';

        /* -- 21.02.2018 ubrr korolkov 18-12.1
        begin
          select caccacc, CACCCUR
            into caccc, ccurc
            from acc
           where caccacc like Cmask
             and IACCOTD = rec.iaccotd
          --   and CACCPRIZN = 'О'
             and rownum = 1;
            -->>--  16.06.2016  Пинаев Д.Е.      [16-2126] Доработка комиссионных модулей 446-П (новые счета)

            -->> 13.11.2015 ubrr korolkov 15-1059.3
            /*vCusNum := acc_info.Get_CusNum(rec.cTrnAccD, rec.cTrnCur);
            cAccC := ubrr_zaa_comms.Get_Acc446pFromOld(vCusNum, cAccC, cCurC);
            if cAccC is null then
                raise no_data_found;
            end if;* /
            --<< 13.11.2015 ubrr korolkov 15-1059.3
            --<<--  16.06.2016  Пинаев Д.Е.      [16-2126] Доработка комиссионных модулей 446-П (новые счета)
        exception
          when no_data_found then
            caccc     := '00000000000000000000';
            ccurc     := 'RUR';
            cvcomstat := 'Ошибка - Счет для списания комиссии не определен';
        end;
        */ -- 21.02.2018 ubrr korolkov 18-12.1

        -->>23.10.2017  Малых Д.В. 17-1225 не используется, комисия и шкалы считаются в   ubrr_xxi5.ubrr_bnkserv_calc_new.getsumcomiss
        /*
        if iScale > 0 then
          nComSum := get_comss_sum(rec.mtrnsum, iScale); -- посчитаем сумму комиссии
        else
          if instr(cvcomstat, 'Ошибка') > 0 then
            cvcomstat := 'Ошибка - шкала комиссии не определена.' ||
                         cvcomstat;
          else
            cvcomstat := 'Ошибка - шкала комиссии не определена.';
          end if;
        end if;
        */
        --<<23.10.2017  Малых Д.В. 17-1225  не используется, комисия и шкалы считаются в   ubrr_xxi5.ubrr_bnkserv_calc_new.getsumcomiss
        -->>23.10.2017  Малых Д.В. 17-1225
        --очистка целевой таблицы
        DELETE FROM ubrr_data.ubrr_sbs_new
        WHERE idsmr = sys_context('B21', 'IdSmr')
        AND isbstrnnum IS NULL
        AND dsbsdate = p_date
        AND isbstypecom = 16
        and csbstypecom = rec.ctypecom  -- 07.03.2019  Ризанов Р.Т. [#60292] Ошибка при одновременном взимании комиссий UL_FL и UL_FL_VB
        AND csbsaccd LIKE rec.ctrnaccd;

        --посчитаем сумму комиссии
        ncomsum := ubrr_xxi5.ubrr_bnkserv_calc_new.getsumcomiss(NULL,
                                                                NULL,
                                                                rec.ctrnaccd,
                                                                rec.ctrncur,
                                                                rec.iaccotd,
                                                                rec.ctypecom,  --'UL_FL',  -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
                                                                rec.mtrnsum,
                                                                rec.sumbefo);
        -->>23.10.2017  Малых Д.В. 17-1225
        if nComSum >= 0 /*or iScale = -1*/ then -->><<--23.10.2017  Малых Д.В. 17-1225 шкала тут теперь не нужна
            iAllCnt := iAllCnt + 1;
            -->>23.10.2017  Малых Д.В. 17-1225 нальем целевую таблу
            INSERT INTO ubrr_data.ubrr_sbs_new
                (csbsaccd, csbscurd, csbstypecom, msbssumpays, isbscountpays, msbssumcom, isbsotdnum, isbsbatnum, dsbsdate, isbstypecom, dsbsdatereg, MSBSSUMBEFO)
            VALUES
                (rec.ctrnaccd, rec.ctrncur
                , rec.ctypecom -- 'UL_FL' /*TypeCom*/ -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ 
                , rec.mtrnsum, rec.cnt, ncomsum, rec.iaccotd, rec.batnum, p_date, 16, p_date, rec.sumbefo);
            --<<23.10.2017  Малых Д.В. 17-1225 нальем целевую таблу
        end if;
    end loop;

    cComm := 'End of idsmr=' || ismrrr;
    INSERT INTO UBRR_DATA.UBRR_ULFL_TRACE VALUES (sysdate, cComm);
    commit;

    --end loop; -->><<--23.10.2017  Малых Д.В. 17-1225 не используется
    if iAllCnt > 0 then
        return vErr || iAllCnt;-->><<--23.10.2017  Малых Д.В. 17-1225 добавил iAllCnt для возврата кол-ва строк (нужно для формсы ubrr_bnkserv_everyday.fmx)
    else
        return 'Подходящих операций не найдено';
    end if;

exception
    when others then
        vErr := 'Не удалось произвести расчет: ' || dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
        return vErr;
end calc_mask_comss;


  -->>23.10.2017  Малых Д.В. 17-1225  АБС: Корректировка комиссии за перевод средств в пользу ФЛ
  --рассчет комиссии «за получение дохода от предпринимательской деятельности»
  FUNCTION calc_mask_comss_businact(p_date DATE, p_mask VARCHAR2)
      RETURN VARCHAR2
  IS
      verr         VARCHAR2(2000);
      cvcomstat    VARCHAR2(2000);
      ncomsum      NUMBER;
      --cmask        VARCHAR2(20);
      --caccc        VARCHAR2(20);
      --ccurc        VARCHAR2(3);
      iallcnt      INTEGER;
      d2           DATE;
      isessionid   NUMBER;
      --c_express100 t_rec_express100;
      --c_ntk        t_Rec_ntk;
      ccomm        VARCHAR2(200);
      ismrrr       varchar2(3);
      TYPE qw_1 IS RECORD(
          psessionid NUMBER,
          itrnnum    NUMBER,
          ctrnaccd   VARCHAR2(20 BYTE),
          ctrncur    VARCHAR2(3 BYTE),
          mtrnsum    NUMBER,
          caccprizn  CHAR(1 BYTE),
          idsmr      VARCHAR2(3 BYTE),
          iaccotd    NUMBER(4, 0),
          sumbefo    NUMBER,
          batnum     NUMBER,
          ctypecom varchar2(20) -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
          );
      TYPE t_rec_temp_ba IS TABLE OF qw_1 INDEX BY BINARY_INTEGER;
      ulfl t_rec_temp_ba;
      ids  NUMBER := 0;

      TYPE qw_2 IS RECORD(
          ctrnaccd  ubrr_data.ubrr_ulfl_temp_ba.ctrnaccd%TYPE,
          ctrncur   ubrr_data.ubrr_ulfl_temp_ba.ctrncur%TYPE,
          mtrnsum   ubrr_data.ubrr_ulfl_temp_ba.mtrnsum%TYPE,
          caccprizn ubrr_data.ubrr_ulfl_temp_ba.caccprizn%TYPE,
          idsmr     ubrr_data.ubrr_ulfl_temp_ba.idsmr%TYPE,
          iaccotd   ubrr_data.ubrr_ulfl_temp_ba.iaccotd%TYPE,
          cnt       NUMBER,
          sumbefo   ubrr_data.ubrr_ulfl_temp_ba.sumbefo%TYPE,
          batnum    ubrr_data.ubrr_ulfl_temp_ba.batnum%TYPE,
          ctypecom  ubrr_data.ubrr_ulfl_temp_ba.ctypecom%TYPE -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ             
          );
      TYPE t_rec_ulfl_ba IS TABLE OF qw_2 INDEX BY BINARY_INTEGER;
      ulfl_t t_rec_ulfl_ba;

      TYPE qw_3 IS RECORD(
          c_csbsaccd      ubrr_data.ubrr_sbs_new.csbsaccd%TYPE,
          c_csbscurd      ubrr_data.ubrr_sbs_new.csbscurd%TYPE,
          c_csbstypecom   ubrr_data.ubrr_sbs_new.csbstypecom%TYPE,
          c_msbssumpays   ubrr_data.ubrr_sbs_new.msbssumpays%TYPE,
          c_isbscountpays ubrr_data.ubrr_sbs_new.isbscountpays%TYPE,
          c_msbssumcom    ubrr_data.ubrr_sbs_new.msbssumcom%TYPE,
          c_isbsotdnum    ubrr_data.ubrr_sbs_new.isbsotdnum%TYPE,
          c_isbsbatnum    ubrr_data.ubrr_sbs_new.isbsbatnum%TYPE,
          c_dsbsdate      ubrr_data.ubrr_sbs_new.dsbsdate%TYPE,
          c_isbstypecom   ubrr_data.ubrr_sbs_new.isbstypecom%TYPE,
          c_dsbsdatereg   ubrr_data.ubrr_sbs_new.dsbsdatereg%TYPE,
          c_msbssumbefo   ubrr_data.ubrr_sbs_new.msbssumbefo%TYPE);
      TYPE col_sbs_new IS TABLE OF qw_3 INDEX BY BINARY_INTEGER;
      in_sbs col_sbs_new;
  BEGIN
      verr    := 'OK';
      d2      := p_date + 86399 / 86400;
      iallcnt := 0;
      --очистка временных таблиц от прошлых данных
      EXECUTE IMMEDIATE 'truncate table UBRR_DATA.UBRR_ULFL_TEMP_BA';
      EXECUTE IMMEDIATE 'truncate table UBRR_DATA.UBRR_ULFL_TRACE_BA';

      ismrrr := ubrr_xxi5.ubrr_util.GetBankIdSmr;-->><<--04.12.2017 Малых Д.В. https://redmine.lan.ubrr.ru/issues/47017#note-69 --sys_context('B21', 'IdSmr'); --корректное логирование

      SELECT ubrr_data.ubrr_ulfl_session_seq.nextval
       INTO isessionid
      FROM dual;

      INSERT INTO ubrr_data.ubrr_ulfl_trace_ba
      VALUES
          (SYSDATE, 'Begin of idsmr=' || ismrrr || '  iSessionId=' || isessionid);
      COMMIT;
      /*
      -- читаем все операции экспресс 100 за которые не взимается комиссия
      OPEN express100_cur(trunc (p_date, 'MM'), d2, p_mask);
      FETCH express100_cur BULK COLLECT
          INTO c_express100;
      CLOSE express100_cur;
      --запишем в лог
      cComm := 'выбрали express100_v2: count=' || to_char(c_express100.count);
      INSERT INTO ubrr_data.ubrr_ulfl_trace_ba VALUES (SYSDATE, ccomm);
      COMMIT;

       -- читаем все операции НТК за которые не взимается комиссия
      open ntk_cur(trunc (p_date, 'MM'), d2, p_mask);
      fetch ntk_cur BULK COLLECT
        into c_ntk;
      close ntk_cur;
       --запишем в лог
      cComm := 'выбрали НТК_v2: count=' || to_char(c_ntk.count);
      INSERT INTO ubrr_data.ubrr_ulfl_trace_ba VALUES (sysdate, cComm);
      commit;
      */


      FOR rec_temp IN get_calctrn_business_activity(p_date, d2, p_mask, ismrrr)
      LOOP
          IF is_special_grp_condition_true(rec_temp.ctrnaccd,
                                           'RUR',
                                           p_date,
                                           d2) = 1 /*AND
             is_free_express100_trn(c_express100, rec_temp.itrnnum) = 0 AND
             is_free_ntk_trn(c_ntk, rec_temp.itrnnum) = 0*/
          THEN
              ids := ids + 1;
              ulfl(ids).psessionid := isessionid;
              ulfl(ids).itrnnum    := rec_temp.itrnnum;
              ulfl(ids).ctrnaccd   := rec_temp.ctrnaccd;
              ulfl(ids).ctrncur    := rec_temp.ctrncur;
              ulfl(ids).mtrnsum    := rec_temp.mtrnsum;
              ulfl(ids).caccprizn  := rec_temp.caccprizn;
              ulfl(ids).idsmr      := rec_temp.idsmr;
              ulfl(ids).iaccotd    := rec_temp.iaccotd;
              ulfl(ids).sumbefo    := rec_temp.sumbefo;
              ulfl(ids).batnum     := rec_temp.batnum;
              ulfl(ids).ctypecom   := rec_temp.ctypecom; -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ             
              /*INSERT INTO ubrr_ulfl_temp_ba
              VALUES
                  (isessionid, rec_temp.itrnnum, rec_temp.ctrnaccd, rec_temp.ctrncur, rec_temp.mtrnsum, rec_temp.caccprizn,
                  rec_temp.idsmr, rec_temp.iaccotd, rec_temp.sumbefo, rec_temp.batnum);
              COMMIT;*/

          END IF;
      END LOOP;

      IF ulfl.COUNT > 0 THEN
        FORALL ids IN INDICES OF ulfl
          INSERT INTO ubrr_ulfl_temp_ba VALUES ulfl(ids);
        COMMIT;

        ccomm := 'закончили выбирать trn в UBRR_ULFL_TEMP_ba count=' || ids;

        INSERT INTO ubrr_data.ubrr_ulfl_trace_ba VALUES (SYSDATE, ccomm);
        COMMIT;

        ulfl.delete;
        ids := 0;

        SELECT ctrnaccd,
             ctrncur,
             SUM(mtrnsum) mtrnsum,
             caccprizn,
             idsmr,
             iaccotd,
             COUNT(*) cnt,
             max(sumbefo) sumbefo,
             batnum,
             ctypecom -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ             
        BULK COLLECT INTO ulfl_t
        FROM ubrr_ulfl_temp_ba
        WHERE id = isessionid
        GROUP BY ctrnaccd, ctrncur, caccprizn, idsmr, iaccotd, batnum
                ,ctypecom; -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ

        FOR i IN 1 .. ulfl_t.count
        LOOP
          /* -- 21.02.2018 ubrr korolkov 18-12.1
          cmask     := ubrr_rko_symbols.get_new_rko_mask(to_char(ulfl_t(i).iaccotd),
                                                         '320',
                                                         ulfl_t(i).ctrnaccd,
                                                         ulfl_t(i).ctrncur,
                                                         '27402',
                                                         '27403');
          ncomsum   := 0;
          cvcomstat := 'Новая';

          BEGIN
              SELECT caccacc, cacccur
              INTO caccc, ccurc
              FROM acc
              WHERE caccacc LIKE cmask
                    AND iaccotd = ulfl_t(i).iaccotd
                   --   and CACCPRIZN = 'О'
                    AND rownum = 1;
          EXCEPTION
              WHEN no_data_found THEN
                  caccc     := '00000000000000000000';
                  ccurc     := 'RUR';
                  cvcomstat := 'Ошибка - Счет для списания комиссии не определен';
          END;
          */ -- 21.02.2018 ubrr korolkov 18-12.1

          --очистка целевой таблицы
          DELETE FROM ubrr_data.ubrr_sbs_new
          WHERE idsmr = sys_context('B21', 'IdSmr')
                AND isbstrnnum IS NULL
                AND dsbsdate = p_date
                AND isbstypecom = 32
                and csbstypecom = ulfl_t(i).ctypecom  -- 07.03.2019  Ризанов Р.Т. [#60292] Ошибка при одновременном взимании комиссий UL_FL и UL_FL_VB                
                AND csbsaccd LIKE ulfl_t(i).ctrnaccd;

          --посчитаем сумму комиссии
          ncomsum := ubrr_xxi5.ubrr_bnkserv_calc_new.getsumcomiss(NULL,
                                                                  NULL,
                                                                  ulfl_t(i).ctrnaccd,
                                                                  ulfl_t  (i).ctrncur,
                                                                  ulfl_t  (i).iaccotd,
                                                                  ulfl_t  (i).ctypecom, --'IP_DOH',  --передача Типа комиссии. -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
                                                                  ulfl_t  (i).mtrnsum,
                                                                  ulfl_t  (i).sumbefo);

          IF ncomsum >= 0
          THEN
              iallcnt := iallcnt + 1;
              ids := ids + 1;
              in_sbs(ids).c_csbsaccd      := ulfl_t(i).ctrnaccd;
              in_sbs(ids).c_csbscurd      := ulfl_t(i).ctrncur;
              in_sbs(ids).c_csbstypecom   := ulfl_t(i).ctypecom; -- 'IP_DOH' /*TypeCom*/;  --передача Типа комиссии. -- 12.02.2019 Ризанов Р.Т. [18-57910.2] АБС: Доработка комиссии за внутрибанковские платежи в пользу ФЛ
              in_sbs(ids).c_msbssumpays   := ulfl_t(i).mtrnsum;
              in_sbs(ids).c_isbscountpays := ulfl_t(i).cnt;
              in_sbs(ids).c_msbssumcom    := ncomsum;
              in_sbs(ids).c_isbsotdnum    := ulfl_t(i).iaccotd;
              in_sbs(ids).c_isbsbatnum    := ulfl_t(i).batnum;
              in_sbs(ids).c_dsbsdate      := p_date;
              in_sbs(ids).c_isbstypecom   := 32;
              in_sbs(ids).c_dsbsdatereg   := p_date;
              in_sbs(ids).c_msbssumbefo   := ulfl_t(i).sumbefo;

              /*
              INSERT INTO ubrr_data.ubrr_sbs_new
                  (csbsaccd, csbscurd, csbstypecom, msbssumpays, isbscountpays, msbssumcom, isbsotdnum, isbsbatnum, dsbsdate, isbstypecom, dsbsdatereg, msbssumbefo)
              VALUES
                  (rec.ctrnaccd, rec.ctrncur, 'UL_FL_M' /*TypeCom*/ /*,rec.mtrnsum, rec.cnt, ncomsum, rec.iaccotd, rec.batnum, p_date, 16, p_date, rec.sumbefo);
              */
          END IF;
        END LOOP;

        FORALL ids IN INDICES OF in_sbs
          INSERT INTO ubrr_data.ubrr_sbs_new
              (csbsaccd,      csbscurd,
               csbstypecom,   msbssumpays,
               isbscountpays, msbssumcom,
               isbsotdnum,    isbsbatnum,
               dsbsdate,      isbstypecom,
               dsbsdatereg,   msbssumbefo)
          VALUES
              (in_sbs(ids).c_csbsaccd,     in_sbs(ids).c_csbscurd,
              in_sbs(ids).c_csbstypecom,   in_sbs(ids).c_msbssumpays,
              in_sbs(ids).c_isbscountpays, in_sbs(ids).c_msbssumcom,
              in_sbs(ids).c_isbsotdnum,    in_sbs(ids).c_isbsbatnum,
              in_sbs(ids).c_dsbsdate,      in_sbs(ids).c_isbstypecom,
              in_sbs(ids).c_dsbsdatereg,   in_sbs(ids).c_msbssumbefo);
        COMMIT;

        in_sbs.delete;
        ids := 0;

        ccomm := 'End of idsmr=' || ismrrr;
        INSERT INTO ubrr_data.ubrr_ulfl_trace_ba VALUES (SYSDATE, ccomm);
        COMMIT;

        IF iallcnt > 0
        THEN
          RETURN verr ||iallcnt;
        ELSE
          RETURN 'Подходящих операций не найдено';
        END IF;
      ELSE
        RETURN 'Подходящих операций не найдено';
      END IF;

  EXCEPTION
    WHEN OTHERS THEN
      verr := 'Не удалось произвести расчет: ' || dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
      RETURN verr;
  END calc_mask_comss_businact;
  --<<23.10.2017  Малых Д.В. 17-1225 АБС: Корректировка комиссии за перевод средств в пользу ФЛ

  function get_userid(p_usr varchar2 default null) return number is
    v_res usr.iusrid%type;
  begin
    select iusrid into v_res from usr where cusrlogname = nvl(p_usr, user);
    return v_res;
  exception
    when no_data_found then
      return null;
  end get_userid;

  /*
  регистрация комиссии
  */
  function Register(p_errmsg  out varchar2,
                    p_marker  in number,
                    p_regdate in date) return number is
    cInitSmr constant xxi."smr".idsmr%type := ubrr_get_context;
    rvDocument    UBRR_ZAA_COMMS.rtDocument;
    rvRetDoc      UBRR_ZAA_COMMS.rtRetDoc;
    Succ_Proc_Cnt number;
    Card_Proc_Cnt number;
    Err_Proc_Cnt  number;
    vcPrimAcc     varchar2(25);
    vAccName      xxi."acc".caccname%type;
    v_PrevIdSmr   ubrr_data.ubrr_ulfl_tab_acc_coms.idsmr%type;
    cPurpDog      VARCHAR2(100);
    vRegUser      xxi.usr.cusrlogname%type;

    cursor racc(p_marker number) is
      select a.rowid, a.*
        from ubrr_data.ubrr_ulfl_tab_acc_coms a, mrk
       where IMRKMARKERID = p_marker
         and RMRKROWID = a.rowid
         and ICOMTRNNUM IS NULL
         and a.CCOMACCC <> '00000000000000000000'
       order by a.idsmr;

  begin
    --------------------
    Succ_Proc_Cnt := 0;
    Card_Proc_Cnt := 0;
    Err_Proc_Cnt  := 0;
    for r in racc(p_marker) loop
      begin

        if v_PrevIdSmr <> r.IdSmr or v_PrevIdSmr is null then
          v_PrevIdSmr := r.IdSmr;
          XXI_CONTEXT.Set_IDSmr(r.IdSmr);
        end if;
        rvDocument         := null;
        rvDocument.cModule := 'UBRR_ULFL_ACC_COMS';
        rvDocument.cAccD   := r.CCOMACCD;
        rvDocument.cCurD   := r.CCOMCURD;
        rvDocument.cAccC   := r.CCOMACCC;
        rvDocument.cCurC   := 'RUR';
        rvDocument.dTran   := p_regdate;
        rvDocument.dComm   := r.dcomdateras;
        rvDocument.iDocNum := r.ICOMDOCNUM;
        rvDocument.iBatNum := 5407;
        rvDocument.iBo1    := r.ICOMTYPE;
        rvDocument.iBo2    := r.ICOMSOP;
        rvDocument.cType   := 'TC';
        vcPrimAcc          := '';

-- (нач.) UBRR Новолодский А. Ю. 23.05.2017 [17-71] АБС: Ошибка списании комиссиий по спецсчету на спецсчет по капремонту
        IF rvDocument.cAccD like '40821%'
           --(rvDocument.cAccD like '40821________7______' or
           --rvDocument.cAccD like '40821________8______')
        THEN
          BEGIN
            vcPrimAcc := rvDocument.cAccD; -- счёт 40821% поставим в назначение
            select caccacc
              into rvDocument.cAccD
              from acc
             where (caccacc like '406%' or caccacc like '407%' or
                   caccacc like '408%')
                 and not caccacc like '40821%'
          --     and not (caccacc like '40821________7______')
          --     and not (caccacc like '40821________8______')
                and     not exists (select 1
                                   from gac
                                   where cgacacc = acc.caccacc
                                     and igaccat = 333
                                     and igacnum = 4)
-- (кон.) UBRR Новолодский А. Ю. 23.05.2017 [17-71] АБС: Ошибка списании комиссиий по спецсчету на спецсчет по капремонту
               and caccprizn <> 'З'
               and iacccus =
                   (select iacccus from acc where caccacc = rvDocument.cAccD)
               and cacccur =
                   (select cacccur from acc where caccacc = rvDocument.cAccD)
               and rownum = 1;
          EXCEPTION
            WHEN No_Data_Found THEN
              rvDocument.mSumD := 0;
              update UBRR_ULFL_TAB_ACC_COMS
                 set ComSum   = rvDocument.mSumD,
                     cComStat = 'Отсутствует 406% или 407% или 408%'
               where rowid = r.rowid;
              continue;
          END;
        END IF;

        -- использовать функционал, РКО.Ежем.комиссий по замене счета списания комиссии по нотариусам
        if rvDocument.cAccD like '42309%' then
          vcPrimAcc        := rvDocument.cAccD;
          rvDocument.cAccD := UBRR_XXI5."UBRR_RKO".f_otheracc(rvDocument.cAccD,
                                                              rvDocument.cCurD,
                                                              2);
        end if;

        begin
          select caccname
            into vAccName
            from acc
           where caccacc = rvDocument.cAccC;
        EXCEPTION
          WHEN No_Data_Found then
            vAccName := 'Комиссия за перевод ЮЛ-ФЛ ';
        end;

        -- В назначении платежа ссылку на счет списания комиссии (счет ДТ, по которому рассчитывались обороты), указывать только тогда,когда производится реальная подмена счета (т.е. сета 40821,42309),
        if vcPrimAcc is not null then
          rvDocument.cPurp := vAccName || 'со счета (' || vcPrimAcc ||
                              ') за период с ' ||
                              to_char(r.dcomdateras, 'dd.mm.yyyy') ||
                              ' по ' || to_char(add_months(r.dcomdateras, 1) - 1,
                                                'dd.mm.yyyy') || ' г.';
        else
          rvDocument.cPurp := vAccName || ' за период с ' ||
                              to_char(r.dcomdateras, 'dd.mm.yyyy') ||
                              ' по ' || to_char(add_months(r.dcomdateras, 1) - 1,
                                                'dd.mm.yyyy') || ' г.';
        end if;

        if substr(r.CCOMACCD, 1, 8) = '40807810' then
          rvDocument.cPurp := '{VO80050}' || rvDocument.cPurp;
        end if;

        BEGIN
          -->>> 09.01.2018  Ёлгин Ю.А.       [17-913.2] АБС: Кат/гр при открытии счета
          if rvDocument.iBO1 = 25 then
            cPurpDog := ' ' || ubrr_xxi5.ubrr_zaa_comms.Get_LinkToContract(p_Account => nvl(vcPrimAcc, r.CCOMACCD),
                                                                           p_IdSmr   => r.idsmr);
          else
          --<<< 09.01.2018  Ёлгин Ю.А.       [17-913.2] АБС: Кат/гр при открытии счета
          select ' согл.п. ' ||
           -->> ubrr 11.07.2016 Арсланов Д.Ф. #33232 ВУЗ РКО Пункт договора о безакцептном списании
                decode(nump, 225, '2.2.5 дог. ', 32, '3.2 дог.', 1023, '2.3. Правил открытия, ведения и закрытия счетов ') ||
                case when nump not in (32, 1023) then '№ ' || caccsio || ' от ' ||to_char(dacclastoper, 'DD.MM.YYYY')
                     else ''
                end
          --<< ubrr 11.07.2016 Арсланов Д.Ф. #33232
            INTO cPurpDog
            from (select acc.caccsio,
                         acc.dacclastoper,
                         min(gac.igacnum) nump
                    from acc, gac
                   where caccacc = r.CCOMACCD
                     and cgacacc = caccacc
                     and ((igaccat = 170 and igacnum in (225, 1023)) or -->><<-- ubrr 11.07.2016 Арсланов Д.Ф. #33232 ВУЗ РКО Пункт договора о безакцептном списании
                         (igaccat = 172 and igacnum = 32))
                   group by acc.caccsio, acc.dacclastoper);
           end if; --  09.01.2018  Ёлгин Ю.А.       [17-913.2] АБС: Кат/гр при открытии счета
        EXCEPTION
          WHEN OTHERS THEN
            cPurpDog := '';
        END;
        rvDocument.cPurp   := rvDocument.cPurp || cPurpDog;
        rvDocument.cAccept := 'С акцептом';
        If instr(upper(rvDocument.cPurp), ' ДОГ.') = 0  and Instr(upper(rvDocument.cPurp), ' ПРАВИЛ ОТКРЫТИЯ')=0 Then
          Declare
            vCACCSIO      Varchar2(400);
            vDACCLASTOPER Varchar2(20);
          Begin
            If rvDocument.cAccD Is Not Null Then
              Select CACCSIO, to_char(DACCLASTOPER, 'dd.mm.rrrr')
                Into vCACCSIO, vDACCLASTOPER
                From ubrr_acc_v
               Where CACCACC = r.CCOMACCD
                 And CACCCUR = 'RUR';
              rvDocument.cPurp := rvDocument.cPurp || ' дог. ' || vCACCSIO ||
                                  ' от ' || vDACCLASTOPER;
            End If;
          Exception
            When Others Then
              Null;
          End;
        End If;

        rvDocument.cPurp := rvDocument.cPurp || chr(10) ||
                            ' НДС не облагается';
        rvDocument.mSumD := r.ComSum;

        vRegUser := ni_action.fGetAdmUser(ubrr_get_context);
        xxi.triggers.setuser(vRegUser);
        abr.triggers.setuser(vRegUser);
        access_2.cur_user_id := get_userid(vRegUser);
        rvRetDoc             := ubrr_zaa_comms.Register(rvDocument);

        xxi.triggers.setuser(null);
        abr.triggers.setuser(null);
        access_2.cur_user_id := get_userid();

        if rvRetDoc.cResult <> 'OK' then
          --Если не зарегистрировали
          UPDATE ubrr_ulfl_tab_acc_coms
             set CCOMSTAT = 'Ошибка: ' || rvRetDoc.cResult
           where CCOMACCD = r.CCOMACCD
             and DCOMDATERAS = r.DCOMDATERAS;
          Err_Proc_Cnt := Err_Proc_Cnt + 1;
        elsif rvRetDoc.cPlace = 'TRN' then
          ----->> Подмена пользователя
          update xxi."trn"
             set cTrnIdAffirm = vRegUser, cTrnIdOpen = vRegUser
           where iTrnNum = rvRetDoc.iNum
             and iTrnAnum = rvRetDoc.iANum;
          -----<< Подмена пользователя

          UPDATE ubrr_ulfl_tab_acc_coms
             set ICOMTRNNUM = rvRetDoc.iNum,
                 CCOMSTAT   = 'Проведена',
                 MCOMSUMREG = rvDocument.mSumD,
                 ITRNTRC    = 1
           where CCOMACCD = r.CCOMACCD
             and DCOMDATERAS = r.DCOMDATERAS;
          Succ_Proc_Cnt := Succ_Proc_Cnt + 1;

        elsif rvRetDoc.cPlace = 'TRC' then
          ----->> Подмена пользователя
          update xxi."trn"
             set cTrnIdAffirm = vRegUser, cTrnIdOpen = vRegUser
           where iTrnNum = rvRetDoc.iNum;
          -----<< Подмена пользователя
          UPDATE ubrr_ulfl_tab_acc_coms
             set ICOMTRNNUM = rvRetDoc.iCardNum,
                 CCOMSTAT   = 'Поставлена в картотеку 2',
                 MCOMSUMREG = rvDocument.mSumD,
                 ITRNTRC    = 2
           where CCOMACCD = r.CCOMACCD
             and DCOMDATERAS = r.DCOMDATERAS;
          Card_Proc_Cnt := Card_Proc_Cnt + 1;
        end if;
        /* -- 26.02.2018 ubrr korolkov 17-913.2
        -->>> 09.01.2018  Ёлгин Ю.А.       [17-913.2] АБС: Кат/гр при открытии счета
        if rvRetDoc.cResult = 'OK' and rvDocument.iBO1 = 25 then
            begin
                insert into gac (CGACCUR, IGACCAT, IGACNUM, CGACACC, IDSMR)
                values (rvDocument.cCurD, 172, 32, rvDocument.cAccD, r.idsmr);
            exception when others then
                null;
            end;
        end if;
        --<<< 09.01.2018  Ёлгин Ю.А.       [17-913.2] АБС: Кат/гр при открытии счета
        */ -- 26.02.2018 ubrr korolkov 17-913.2
      exception
        when others then
          update UBRR_ULFL_TAB_ACC_COMS
             set CCOMSTAT = 'Ошибка,' || dbms_utility.format_error_stack ||
                            chr(10) || dbms_utility.format_error_backtrace
           where rowid = r.rowid;
          Err_Proc_Cnt := Err_Proc_Cnt + 1;

      end;

    end loop;

    commit;
    xxi_context.set_idsmr(cInitSmr);
    return Succ_Proc_Cnt + Card_Proc_Cnt;

  exception
    when others then
      rollback;
      xxi_context.set_idsmr(cInitSmr);
      p_errmsg := dbms_utility.format_error_stack ||
                  dbms_utility.format_error_backtrace;
      return - 1;
  end Register;

end ubrr_ulfl_comss_ver2;
/
