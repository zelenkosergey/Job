CREATE OR REPLACE PROCEDURE UBRR_XXI5."UBRR_BNKSERV_IB" ( portion_date1 in date
                                                         ,portion_date2 in date
                                                         ,dtran         in date
                                                         ,ls            in varchar2 default null ) IS
/*************************************************** HISTORY *****************************************************\
   Дата          Автор          id        Описание
----------  ---------------  --------- ------------------------------------------------------------------------------
18.05.2011  Корольков Д.А.              ТП "Туристический" https://redmine.lan.ubrr.ru/issues/2793
23.11.2011  Корольков Д.А.              Новые тарифы ( 112/35 - Стартовый;
                                                       112/36 - Пакетный 30;
                                                       112/37 - Пакетный 60;
                                                       112/38 - Все включено;
                                                       112/39 - Торговый;
                                                       112/40 - Все включено(оплачена годовая комиссия) )
                                                       https://redmine.lan.ubrr.ru/issues/3905
28.12.2011  Бездворный А.В.             Исключаем счета КРС, категория/группа - 333/2
16.05.2012  Корольков Д.А.              ТП "Экспресс 100" https://redmine.lan.ubrr.ru/issues/4849
08.06.2012  Корольков Д.А.              Изменения тарифов 01.06.2012 https://redmine.lan.ubrr.ru/issues/4936
27.06.2012  Корольков Д.А.              Убраны блоки по расчёту комиссий:
                                            Межбанковский платеж на бумажном носителе для ТП "Пакетный 30"
                                            Межбанковский платеж на бумажном носителе для ТП "Экспресс 100"
                                            Межбанковский платеж на бумажном носителе для ТП <Пакетный 60>
                                            Межбанковский платеж на бумажном носителе для ТП <Торговый>
                                            Внутрибанковский платеж на бумажном носителе для тарифов: 112/35 - Стартовый,
                                                                                                      112/35 - Тест-драйв - новый UBRR Pashevich A. #12-1224 условие срочно Эконом
                                                                                                      112/36 - Пакетный 30,
                                                                                                      112/37 - Пакетный 60,
                                                                                                      112/38 - Все включено,
                                                                                                      112/39 - Торговый,
                                                                                                      112/40 - Все включено
                                            Внутрибанковский платеж на бумажном носителе для тарифа "Экспресс 100"
                                            Проведение платежей текущей датой: с 17-00 ч до 18-00 ч внутрибанковский платеж
                                                                               с 18-00 ч до 20-00 ч внутрибанковский платеж
                                                                               с 20-00 ч до 22-00 ч внутрибанковский платеж
                                            --
                                            Исходную версию искать в Y:\#For_Update
12.07.2012  Корольков Д.А.              Изменение тарифов с 01.07.2012 https://redmine.lan.ubrr.ru/issues/5118
23.08.2012  Корольков Д.А.              Новый пакет "Бизнес-комплект", тарифы для НТК https://redmine.lan.ubrr.ru/issues/5420
25.03.2013  Пашевич А.О.                Изменены тарифы Континенталь
04.04.2013  Пашевич А.О.                Добавлены расчеты , аналогичные прежним, по счетам из справочника
                                            "Настройка индивидуальных комиссий для крупных клиентов"
                                            Самоинкассация считается в отдельной процедуре ubrr_xxi5.ubrr_unq_comms
08.05.2013  Пашевич А.О.                Курпные клиенты RKO тариф по справочнику
19.08.2013  Пашевич А.О.                Тариф Муниципальный
24.05.2013  Галиева Н.А.                Изменение тарифов на 01.07.2013 г.
11.10.2013  Пашевич А.О.                https://redmine.lan.ubrr.ru/issues/8201
                                            Тарифный план "Туристический"
                                            Добавить в тарифный план "Туристический" (валютный пакет) лимит
                                            бесплатных межбанковских платежей - 4000 шт., т.е. за 4000 платежей комиссия не взымается,
                                            начиная с 4001 платежа-комиссия за межбанковский платеж по стандарту.
14.11.2013  Галиева Н.А.                Добавление новых ТП 6474,6471,6473 на 01.11.2013 г.
25.10.2013  Корольков Д.А.  12-1657     (#9707) Тарифный план "Аккредитивы в иностранной валюте"(112/59)
11.12.2013  y.metalnikov@i-sys.ruf
                            12-2172     АБС Иизменения по формированию комиссий за ведение счета и за подтверждение платежей.(112/40)
                                            https://redmine.lan.ubrr.ru/issues/11232
20.12.2013  Корольков Д.А.  12-2288     (#11418) Изменение очередности списания денежных средств, ст 855 ГК (комиссия за платежки)
29.01.2014  Галиева Н.А.                Изменение тарифов на 01.01.2014 г. Распоряжение № 7006-4596 от 11.12.2013
20.03.2014  Галиева Н.А.                Добавление новых ТП 6480,6490,6491,6481,6482,6484,6486,6487 на 17.03.2014 г.
12.03.2014  Пашевич А.О.                Добавляем счета 42309 https://redmine.lan.ubrr.ru/issues/11596
06.05.2014  Пашевич А.О.    14-406      Тарифный план "Все просто"
09.06.2014  Галиева Н.А. Добавление новой ТП 6488,6497.
                            14-992      АБС: Автоматизация формирования комиссии по пакету "Тест-драйв Премиум"
                            14-959      AБС: Стоимость платежей в зависимости от времени их проведения
30.10.2014  Pashevich AO                добавление аудита по кт/группы  + нотариус
21.01.2015  Галиева Н.А.                Изменение тарифов на 01.01.2014 г. Распоряжение № 7006-4289 от 09.12.2014 г.
16.12.2014  Pashevich           14-1344 AO АБС: Настройка комиссии по ТП Яблоко за каждый операционный день
18.02.2015  Новолодский А. Ю.   12-2313 Тарифный план "Эквайринг" https://redmine.lan.ubrr.ru/issues/11831
02.02.2015  Новолодский А. Ю.   12-2313 Тарифный план "Эквайринг" https://redmine.lan.ubrr.ru/issues/11831, доработки
06.04.2015  ubrr Макарова Л.Ю.  15-42   Доп. комиссия за ведение счета Ибанк-Pro Online
07.04.2015  ubrr Макарова Л.Ю.  15-231  ТП "Онлайн бесплатно"
08.04.2015  ubrr Макарова Л.Ю.  15-223  ТП "Все в дом", ТП "Все в дом премиум"
09.04.2015  ubrr Макарова Л.Ю.  15-279  ТП "Зарплатный"
06.05.2015  ubrr Макарова Л.Ю.  15-42   доп.треб. https://redmine.lan.ubrr.ru/issues/19917#note-36
26.05.2015  ubrr korolkov       15-453  Бизнес-комплект 3,6,12
30.04.2015  Новолодский А.Ю.    [15-44] АБС: Введение платы за смс-информирование
29.06.2015  Макарова Л.Ю.       [15-613] ТП Муниципальный-1 https://redmine.lan.ubrr.ru/issues/23046
07.07.2015  Галиева Н.А.          Добавление новой ТП 6483 на 01.07.2015 г.
20.07.2015  Галиева Н.А.           Изменение тарифов на 01.07.2015 г. Распоряжение № 7006-1990 от от 08.06.2015 г.
27.07.2015  Макарова Л.Ю.        15-830 АБС: ТП Все просто в НТК
04.08.2015  Галиева Н.А.         Испраление ошибки  по тарифам  Чебоксары ,Белгород -Комиссия за ведение р/с в режиме <Эконом> с использованием системы удаленного доступа без предоставления выписок и документов в бумажном виде
22.08.2015  Макарова Л.Ю.        [15-841] АБС: Взимание комиссий. Тарифы НТК с 03.08.15
01.09.2015  Макарова Л.Ю.        [15-921] АБС: Ведение счета бесплатно
30.09.2015  Ubrr Маkarova L.U. [15-1101] АБС: ТП Эквайринг для НТК
09.11.2015  Ubrr Pinaev  сортировка по  ITRNNUM https://redmine.lan.ubrr.ru/issues/25034
22.01.2016 Ubrr Маkarova L.U. [15-1644] АБС: Доработка ТП "Эквайринг", "Эквайринг-Все просто!"
25.01.2016  Галиева Н.А.           Изменение тарифов на 01.01.2016 г. Распоряжение № 7006-3351 от 10.12.2015 г.
03.02.2016  Галиева Н.А.          Исправление замечаний после предварительного расчета  6491,6483,6250,6245,6204,6242
15.02.2016  Галиева Н.А.         Исправление замечаний после окончательного  расчета  6245,6204,6242
11.03.2016 Макарова Л.Ю.         15-1221.1 АБС: Доработка ТП "Онлайн +" (ОТКБ) #25313
06.04.2016 Галиева Н.А        Распоряжение от 19.02.2016 № 7006-222 (тарифы НТК )
19.04.2016 Галиева Н.А        Распоряжение от 15.03.2016 № 7006-355 с 01.04.2016 тарифы SMS-рассылки
05.05.2016 Арсланов Д.Ф.   [16-1808.2.3.5.4.3.2]  #29736  ВУЗ РКО
10.07.2016 Арсланов Д.Ф.   16-2143.2 "Тест-драйв+"
18.07.2016 Галиева Н.А        Распоряжение  от  16.06.2016  № 7006-936 Изменение тарифов на 01.07.2016 г
21.07.2016 ubrr Maкарова Л.Ю. 16-2340 Бизнес-комплект БТП
07.09.2016 ubrr Maкарова Л.Ю. 16-2451 АБС: Пакет услуг Светофор в БТП и НТК
24.09.2016 ubrr Maкарова Л.Ю. 16-2653 АБС: Кат/гр 112/94 для пакета услуг "Бизнес-комплект"
19.10.2016 ubrr Maкарова Л.Ю. 16-2790 АБС: Удаление категории/группы 112/93 по пакету "Тест-драйв+", бюджет IB-Pro
25.10.2016 Галиева Н.А   Добавление новых ТП 6489-тарифы как 6472, ТП 6265- тарифы как у 6253 (письмо от ДРКК)
03.12.2016 Макарова Л.Ю.      16-2817 АБС Бухгалтерия: Корректное взимание комиссии (#38446)
17.01.2017 Галиева Н.А  Распоряжение  от  19.12.2016  № 7006-2097 Изменение тарифов на 01.01.2017 г , от 19.12.2016 № 7006-2096 (НТК)
09.02.2017 Галиева Н.А   Добавление  ТП 6257 - тарифы как 6237 (исправление ошибки)
18.04.2017 Галиева Н.А   Добавление  ТП 6485 Кунгурский фил.Пермский.Распоряжение  от 27.03.2017 № 7006-466
24.05.2017 Макарова Л.Ю. [14-985.18] Некорректное списание комиссии за проведение платежей ЮЛ и ИП
25.05.2017 Галиева Н.А  Распоряжения № 7006-574 от 13.04.2017  Изменение тарифов на 01.05.2017 г  ЦФК =0
13.06.2017 Макарова Л.Ю.  Восстановление процедуры расчета по всем типам комиссий, после решения иницдента  https://redmine.lan.ubrr.ru/issues/43726
21.07.2017 г. Галиева Н.А  Распоряжения № № 7006-931 от 09.06.2017  Изменение тарифов на 01.07.2017 г
19.01.2018 Галиева Н.А  Распоряжения от 15.12.2017 № 7006-2358  Изменение тарифов на 01.01.2018 г
29.10.2018 Баязитов      [18-592.2] АБС Разовая комиссия по светофору
27.12.2018 Баязитов      [15-43] АБС: Новый пакет услуг с авансовой оплатой за пакет платежей
01.02.2019 Фридьев П.В.  [19-58770] Изменение даты запуска пролонгации пакетов
31.05.2019 Ризанов Р.Т.  [19-59153] АБС. Лимит платежей в пакеты услуг "Бизнес-Класс 3,6,12"
23.10.2019 Баязитов      [19-62184] Разработка: Ежемесячные ИБ PRO + комис. в валюте за РКО
06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии
13.12.2019 Ризанов Р.Т.  [69650]     Новый тарифный план - комиссия за зачисление
23.01.2020 Баязитов      [19-64846]  АБС: Уведомление об окончании пакета в ИБ + искл услуги "Эксплуатация ИБ-про" из пакетов услуг
31.08.2020 Зеленко С.А.  [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ
09.09.2020 Зеленко С.А.  [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ (доработка расчета суммы для индивидуальных тарифов)
\*************************************************** HISTORY *****************************************************/

    d1       date := portion_date1; -- Пришедшие даты с вызова процедуры
    d2       date := portion_date2;
    d3          date := dtran;
    acc_1       varchar2(25) := NVL(ls,'40___810%');
    ivTime      number;
    cg_112_59   varchar2(6) := '112/59';
    v_autab     number(3)   := 304;
    cg_112_70   varchar2(6) := '112/70';-- UBRR Pashevich AO 14-959
    -- UBRR Pashevich AO 14-992
    cg_112_72   varchar2(6) := '112/72';
    cg_112_35   varchar2(6) := '112/35';
    -->> UBRR Макарова Л.Ю. 15-279
    cg_112_75   varchar2(6) := '112/75';
    --<< UBRR Макарова Л.Ю. 15-279
     -- UBRR Pashevich AO 14-992
    l_cidsmr    smr.idsmr%type := sys_context ('B21', 'IDSmr');  -- ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии
    -->>28.01.2020 Баязитов [19-64846]
    dg_date_start constant date := to_date('01.01.1990', 'dd.mm.rrrr');
    dg_date_end   constant date := to_date('01.01.4000', 'dd.mm.rrrr');
    --<<28.01.2020 Баязитов [19-64846]
BEGIN
   DELETE FROM SBS    where csbsdo ='R_IB';
    DBMS_TRANSACTION.COMMIT;
/*     where csbsdo in ('UAB','PP9','PE9','PP6','PE6','PP3','PP1',
                      'RKO','REO','RKB','REB','RKS','016','017',
                      '018','045','INF')*/

    select -1*ismrtimeshift/60
      into ivTime
      from smr;

    -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии
    -->>19.09.2019 Баязитов [19-62974] IV ЭТАП - Механизм анализа кат/гр ежем.комиссий
    declare
      vErr  varchar2(2000);
    begin
      ubrr_bnkserv_calc_new_proc.fill_rko_acc_catgr( p_cerr           => vErr
                                                    ,p_dportion_date2 => d2        -- расчетная дата - окончание периода дат, по которую считается комиссия  
                                                    ,p_dtran          => dtran     -- дата, в которую формируются документы комиссии
                                                    ,p_cls            => ls );
      
      if vErr is not null then
        ubrr_bnkserv_calc_new_lib.writeprotocol('UBRR_BNKSERV_IB : расчет прерван из_за ошибки в ubrr_bnkserv_calc_new_proc.fill_rko_acc_catgr');
        return;
      end if;
    end;
    --<<19.09.2019 Баязитов [19-62974] IV ЭТАП - Механизм анализа кат/гр ежем.комиссий
    -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии    

-->>--ubrr Макарова Л.Ю. 15-42 Доп. комиссия за ведение счета Ибанк-Pro Online
   INSERT INTO SBS
   ( cSBSpayfrom_acc,cSBSacc, cSBScur, mSBStoll_sum, cSBSdo ,iSBSdebdoc,mSBSdebob,iSBScreddoc,mSBScredob)
   (select to_char(sysdate,'HH24:MI:SS'), acc,ctrncur,/*400*/500,'R_IB', sum(cd),sum(md),sum(cc),sum(mc) --- 19.01.2018 Галиева Н.А  Распоряжения от 15.12.2017 № 7006-2358
      from (
             select /*+ index( trn I_TRN_OLD_NEW_DAC )*/ -->><<--23.10.2019 Баязитов [19-62184] замена I_TRN_ACCD_CUR_DTRN_TYPE на I_TRN_OLD_NEW_DAC
                    ctrnaccd acc,ctrncur,count(1) c,iaccotd,count(1) cd,sum(mtrnsum) md ,0 cc,0 mc, caccmail
             from acc,
                  /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn -->><<--23.10.2019 Баязитов [19-62184] Разработка: Ежемесячные ИБ PRO + комис. в валюте за РКО
             where
               -- ubrr katyuhin >>>
                   acc.caccacc LIKE acc_1
               and acc.cacccur = 'RUR'
               and acc.caccprizn <> 'З'
               -->> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии
               -->>18.09.2019 Баязитов [19-62974] IV ЭТАП
               and exists (select 1
                             from ubrr_rko_acc_catgr r
                            where r.cacc     = cTRNaccd
                              and r.ccur     = ctrncur
                              and r.i_catnum = 105
                              and r.i_grpnum = 2
                              and r.idsmr    = l_cidsmr
                              )
               --<<18.09.2019 Баязитов [19-62974] IV ЭТАП
               -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии               
               and trn.CTRNIDOPEN='IBANK2'
               and not exists (select 1
                             from sbs
                            where csbsdo = 'R_IB'
                              and csbsacc= acc.caccacc
               )
               and acc.iaccbs2 NOT IN (40813, 40817, 40818, 40820
                                      -- UBRR Pashevich A. 12-101
                                      ,42309,40810,40811,40812,40823,40824 -->><<-- ubrr 12.07.2016 Арсланов Д.Ф. #30780
                                      -- UBRR Pashevich A. 12-101
                                      )
                           -- ubrr katyuhin <<<
               and trn.ctrnaccd = acc.cACCacc
               and trn.ctrncur = acc.cACCcur
               and dtrntran between d1 and d2+86399/86400
               -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии               
               -->>18.09.2019 Баязитов [19-62974] IV ЭТАП
               and not exists (select 1
                                 from ubrr_rko_acc_catgr r
                                where r.cacc = acc.cACCacc
                                  and r.ccur = acc.cACCcur
                                  and r.i_catnum = 112
                                  and r.i_grpnum in (-->><<--23.01.2020 Баязитов [19-64846] убраны кат/гр https://redmine.lan.ubrr.ru/issues/70705#note-3
                                                     94,                  -- 24.09.2016 ubrr Maкарова Л.Ю. 16-2653 АБС: Кат/гр 112/94 для пакета услуг "Бизнес-комплект"
                                                     57,71,               -- 29.06.2015  Макарова Л.Ю.       [15-613] ТП Муниципальный-1
                                                     10,                  -- 19.10.2016 ubrr Maкарова Л.Ю. 16-2790  бюджет IB-Pro                          
                                                     67                   -- 18.09.2019 Баязитов [19-62974] IV ЭТАП
                                                    ,45                   -- ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии ВУЗ                                                     
                                                    )
                                  and r.idsmr    = l_cidsmr                                                                                      
                              )
               --<<18.09.2019 Баязитов [19-62974] IV ЭТАП
               -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии               
-->> 01.02.2019 Фридьев П.В.  [19-58770] Изменение даты запуска пролонгации пакетов
                -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии
               -->>18.09.2019 Баязитов [19-62974] IV ЭТАП
               and not exists (select 1
                                 from ubrr_rko_acc_catgr r
                                where r.cacc     = acc.cACCacc
                                  and r.ccur     = acc.cACCcur
                                  and r.i_catnum = 114
                                  and r.i_grpnum = 16
                                  and r.idsmr    = l_cidsmr                                  
                              )
               --<<18.09.2019 Баязитов [19-62974] IV ЭТАП
                -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии               
--<< 01.02.2019 Фридьев П.В.  [19-58770] Изменение даты запуска пролонгации пакетов
 -->> UBRR Макарова Л.Ю. 15-279
    and not exists ( select 1
                          from au_attach_obg a1
                            where     caccacc =acc.CACCACC  and cacccur = acc.CACCCUR
                                  and c_newdata = cg_112_75
                                  and d1 between trunc(d_create,'mm') and last_day(add_months (d_create,5))
                                  and exists ( -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии
                                              select 1
                                                from ubrr_rko_acc_catgr r
                                               where r.cacc     = a1.cACCacc
                                                 and r.ccur     = a1.cACCcur
                                                 and r.i_catnum = 112
                                                 and r.i_grpnum = 75
                                                 and r.idsmr    = l_cidsmr -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии                                                   
                                               union
                                                select 1
                                                 from au_attach_obg a2
                                                  where     a2.caccacc   = a1.caccacc
                                                        and a2.cacccur   = a1.cacccur
                                                        and a2.i_table   = v_autab
                                                        and a2.c_olddata = cg_112_75
                                                        and a2.d_create>last_day(add_months (a1.d_create,5))
                                                )
                         )
                -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии                         
               -->>18.09.2019 Баязитов [19-62974] IV ЭТАП
               and not exists (select 1
                                 from ubrr_rko_acc_catgr r
                                where r.cacc     = acc.cACCacc
                                  and r.ccur     = acc.cACCcur
                                  and r.i_catnum = 112
                                  and r.i_grpnum in (6,8)
                                  and r.idsmr    = l_cidsmr                                     
                              )
               --<<18.09.2019 Баязитов [19-62974] IV ЭТАП
               -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии
               -->>ubrr 13.12.2019  Ризанов Р.Т. [69650] Новый тарифный план - комиссия за зачисление
               and not exists ( select 1
                                  from ubrr_rko_acc_catgr   r
                                      ,ubrr_rko_exinc_catgr e 
                                 where r.i_catnum   = e.icat
                                   and r.i_grpnum   = e.igrp
                                   and e.ccom_type  = 'R_IB'
                                   and e.exinc      = 0
                                   and r.cacc       = acc.caccacc
                                   and r.ccur       = acc.cACCcur                                 
                                   -->>23.01.2020 Баязитов [19-64846]
                                   and (select trunc(max(au.d_create))
                                          from xxi.au_attach_obg au
                                         where au.caccacc = r.cacc
                                           and au.cacccur = r.ccur
                                           and au.i_table = 304
                                           and au.c_newdata = e.icat||'/'||e.igrp
                                           and trunc(au.d_create) <= r.d_date) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end)
                                   --<<23.01.2020 Баязитов [19-64846]
                              )              
               --<<ubrr 13.12.2019  Ризанов Р.Т. [69650] Новый тарифный план - комиссия за зачисление                              
               -->>31.08.2020 Зеленко С.А.  [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ 
               and not exists (select 1 from UBRR_UNIQUE_TARIF_ACC uutc,
                                             UBRR_UNIQUE_ACC_COMMS uuac 
                                       where caccacc = uutc.cacc 
                                         and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF 
                                         and l_cidsmr = uutc.idsmr
                                         and uutc.status = 'N'
                                         and uutc.uuta_id = uuac.uuta_id
                                         and uuac.com_type = 'R_IB')
               --<<31.08.2020 Зеленко С.А.  [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ 
             group by ctrnaccd,ctrncur,iACCotd, caccmail
           )
group by acc,ctrncur,iaccotd, caccmail);
DBMS_TRANSACTION.COMMIT;
--<<--ubrr Макарова Л.Ю. 15-42 Доп. комиссия за ведение счета Ибанк-Pro Online

-->>--ubrr Макарова Л.Ю. 15-42 Доп. комиссия за ведение счета Ибанк-Pro Все просто
   INSERT INTO SBS
   ( cSBSpayfrom_acc,cSBSacc, cSBScur, mSBStoll_sum, cSBSdo ,iSBSdebdoc,mSBSdebob,iSBScreddoc,mSBScredob)
   (select to_char(sysdate,'HH24:MI:SS'), acc,ctrncur,/*400*/500,'R_IB',sum(cd),sum(md),sum(cc),sum(mc) --- 19.01.2018 Галиева Н.А  Распоряжения от 15.12.2017 № 7006-2358
      from (
             select /*+ index( trn I_TRN_OLD_NEW_DAC )*/ -->><<--23.10.2019 Баязитов [19-62184] замена I_TRN_ACCD_CUR_DTRN_TYPE на I_TRN_OLD_NEW_DAC
                    ctrnaccd acc,ctrncur,count(1) c,iaccotd,count(1) cd,sum(mtrnsum) md ,0 cc,0 mc, caccmail
             from acc,
                  /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn -->><<--23.10.2019 Баязитов [19-62184] Разработка: Ежемесячные ИБ PRO + комис. в валюте за РКО
             where     acc.caccacc LIKE acc_1
                   and acc.cacccur = 'RUR'
               and acc.caccprizn <> 'З'
               -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии               
               -->>18.09.2019 Баязитов [19-62974] IV ЭТАП
               and exists (select 1
                             from ubrr_rko_acc_catgr r
                            where r.cacc     = cTRNaccd
                              and r.ccur     = ctrncur
                              and r.i_catnum = 105
                              and r.i_grpnum = 2
                              and r.idsmr    = l_cidsmr                              
                          )
               --<<18.09.2019 Баязитов [19-62974] IV ЭТАП
               -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии               
               and trn.CTRNIDOPEN='IBANK2'
               and not exists (select 1
                               from sbs
                               where csbsdo = 'R_IB'
                               and csbsacc= acc.caccacc)
               /*-->> 26.05.2015 ubrr korolkov 15-453 #22215#note-3
               and acc.iaccbs2 NOT IN (40813, 40817, 40818, 40820,42309)
               and SUBSTR (acc.caccacc, 1, 3) NOT IN ('401', '402', '403', '404', '409')
               AND acc.caccacc NOT LIKE '40821________7%'
               */--<< 26.05.2015 ubrr korolkov 15-453 #22215#note-3
               and trn.ctrnaccd = acc.cACCacc
               and trn.ctrncur = acc.cACCcur
               and dtrntran between d1 and d2+86399/86400
               /*-->> 26.05.2015 ubrr korolkov 15-453 #22215#note-3
               and (  (    itrntype in (2,3,4,11,14,15,21,22,23,25,28)
                       and (   substr(itrnba2c,1,3) in (111,301,302,303,401,402,403,404,405,406,407,423,426)
                            or itrnba2c in (10000,40802,40807,40817,40818,40820,40911))
                        and exists (select --+ index( t I_TRN_ACCD_CUR_DTRN_TYPE )
                                           1
                                      from xxi.V_TRN_PART_CURRENT t
                                     where t.ctrnaccd = trn.ctrnaccd
                                       and t.ctrncur = trn.ctrncur
                                       and dtrntran between d1 and d2+86399/86400
                                       and itrnsop=4))
                    or (    itrntype in (9,13))
                    )
                */--<< 26.05.2015 ubrr korolkov 15-453 #22215#note-3
               -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии                
               -->>18.09.2019 Баязитов [19-62974] IV ЭТАП
               and exists (select 1
                             from ubrr_rko_acc_catgr r
                            where r.cacc     = acc.caccacc
                              and r.ccur     = acc.cacccur
                              and r.i_catnum = 112
                              and r.i_grpnum = 67
                              and r.idsmr    = l_cidsmr                              
                          )
               --<<18.09.2019 Баязитов [19-62974] IV ЭТАП
               -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии               
                -->> 26.05.2015 ubrr korolkov 15-453
                -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии                
               -->>18.09.2019 Баязитов [19-62974] IV ЭТАП
                and not exists (select 1
                                  from ubrr_rko_acc_catgr r
                                 where r.cacc     = acc.cACCacc
                                   and r.ccur     = acc.cACCcur
                                   and r.i_catnum = 112
                                   and r.i_grpnum in (-->><<--23.01.2020 Баязитов [19-64846] убраны кат/гр https://redmine.lan.ubrr.ru/issues/70705#note-3
                                                      94,                 -- 24.09.2016 ubrr Maкарова Л.Ю. 16-2653 АБС: Кат/гр 112/94 для пакета услуг "Бизнес-комплект"
                                                      57,71,              -- 29.06.2015  Макарова Л.Ю.       [15-613] ТП Муниципальный-1
                                                      10)                 -- 19.10.2016 ubrr Maкарова Л.Ю. 16-2790  бюджет IB-Pro
                                   and r.idsmr    = l_cidsmr                                                  
                               )
               --<<18.09.2019 Баязитов [19-62974] IV ЭТАП
               -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии   
               -->>31.08.2020 Зеленко С.А.  [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ 
               and not exists (select 1 from UBRR_UNIQUE_TARIF_ACC uutc,
                                             UBRR_UNIQUE_ACC_COMMS uuac 
                                       where caccacc = uutc.cacc 
                                         and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF 
                                         and l_cidsmr = uutc.idsmr
                                         and uutc.status = 'N'
                                         and uutc.uuta_id = uuac.uuta_id
                                         and uuac.com_type = 'R_IB')
               --<<31.08.2020 Зеленко С.А.  [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ                                         
-->> 01.02.2019 Фридьев П.В.  [19-58770] Изменение даты запуска пролонгации пакетов
               -- ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии
               -->>18.09.2019 Баязитов [19-62974] IV ЭТАП
               and not exists (select 1
                                  from ubrr_rko_acc_catgr r
                                 where r.cacc     = acc.cACCacc
                                   and r.ccur     = acc.cACCcur
                                   and r.i_catnum = 114
                                   and r.i_grpnum = 16
                                   and r.idsmr    = l_cidsmr                                   
                              )
               --<<18.09.2019 Баязитов [19-62974] IV ЭТАП
               -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии
               -->>ubrr 13.12.2019  Ризанов Р.Т. [69650] Новый тарифный план - комиссия за зачисление
               and not exists ( select 1
                                  from ubrr_rko_acc_catgr   r
                                      ,ubrr_rko_exinc_catgr e 
                                 where r.i_catnum   = e.icat
                                   and r.i_grpnum   = e.igrp
                                   and e.ccom_type  = 'R_IB'
                                   and e.exinc      = 0
                                   and r.cacc       = acc.caccacc
                                   and r.ccur       = acc.cACCcur                                 
                                   -->>23.01.2020 Баязитов [19-64846]
                                   and (select trunc(max(au.d_create))
                                          from xxi.au_attach_obg au
                                         where au.caccacc = r.cacc
                                           and au.cacccur = r.ccur
                                           and au.i_table = 304
                                           and au.c_newdata = e.icat||'/'||e.igrp
                                           and trunc(au.d_create) <= r.d_date) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end)
                                   --<<23.01.2020 Баязитов [19-64846]
                              )              
               --<<ubrr 13.12.2019  Ризанов Р.Т. [69650] Новый тарифный план - комиссия за зачисление                              
--<< 01.02.2019 Фридьев П.В.  [19-58770] Изменение даты запуска пролонгации пакетов
-- (нач.) Новолодский А. Ю. 18.02.2015 12-2313
                --and ubrr_xxi5.ubrr_rko.iseqrexistscatgrlist(ctrnaccd, ctrncur, d1, d2) is null
               and not exists (select 1
                 from sbs
                where csbsdo like 'R_EKV%'
                  and csbsacc = ctrnaccd)
-->>--11.03.2016 15-1221.1 АБС: Доработка ТП "Онлайн +" (ОТКБ) #25313 Макарова Л.Ю. Мин.тариф, отс-ют обороты

              and not exists (select 1
                                from sbs
                               where csbsdo like 'R_Onl%'
                                 and csbsacc=ctrnaccd)
--<<--11.03.2016 15-1221.1 АБС: Доработка ТП "Онлайн +" (ОТКБ) #25313 Макарова Л.Ю. Мин.тариф, отс-ют обороты
-- (кон.) Новолодский А. Ю. 18.02.2015 12-2313
            group by ctrnaccd,ctrncur,iACCotd, caccmail
)
group by acc,ctrncur,iaccotd, caccmail);
DBMS_TRANSACTION.COMMIT;
--<<--ubrr Макарова Л.Ю. 15-42 Доп. комиссия за ведение счета Ибанк-Pro Все просто
-->>--ubrr Макарова Л.Ю. 15-42 Доп. комиссия за ведение счета Ибанк-Pro Кр клиенты
  
  ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif := 'Y';          --09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ (доработка расчета суммы для индивидуальных тарифов)
  ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_day := 'N';      --09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ (доработка расчета суммы для индивидуальных тарифов)
  ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_id_check := 'N'; --09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ (доработка расчета суммы для индивидуальных тарифов)
  
  INSERT INTO SBS
   ( cSBSpayfrom_acc,cSBSacc, cSBScur, mSBStoll_sum, cSBSdo ,iSBSdebdoc,mSBSdebob,iSBScreddoc,mSBScredob)
   (select to_char(sysdate,'HH24:MI:SS'), acc,ctrncur,
           sum(sumcom), --31.08.2020 Зеленко С.А.  [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ 
          'R_IB',
          sum(cd),sum(md),sum(cc),sum(mc)
      from (
             select /*+ index( trn I_TRN_OLD_NEW_DAC )*/ -->><<--23.10.2019 Баязитов [19-62184] замена I_TRN_ACCD_CUR_DTRN_TYPE на I_TRN_OLD_NEW_DAC
                    ctrnaccd acc,ctrncur,count(1) c,iaccotd,count(1) cd,sum(mtrnsum) md,0 cc,0 mc,caccmail,ubrr_xxi5.UBRR_UNIQ_ACC_SUM(ctrnaccd,ctrncur,iaccotd,d1,'R_IB',sum(mtrnsum),0) sumcom --31.08.2020 Зеленко С.А.  [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ 
                   from acc,
                  /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn -->><<--23.10.2019 Баязитов [19-62184] Разработка: Ежемесячные ИБ PRO + комис. в валюте за РКО
             where
               -- ubrr katyuhin >>>
                   acc.caccacc LIKE acc_1
               and acc.cacccur = 'RUR'
               and acc.caccprizn <> 'З'
               -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии               
               -->>18.09.2019 Баязитов [19-62974] IV ЭТАП
               and exists (select 1
                             from ubrr_rko_acc_catgr r
                            where r.cacc     = cTRNaccd
                              and r.ccur     = ctrncur
                              and r.i_catnum = 105
                              and r.i_grpnum = 2
                              and r.idsmr    = l_cidsmr                              
                          )
               --<<18.09.2019 Баязитов [19-62974] IV ЭТАП
               -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии               
               and trn.CTRNIDOPEN='IBANK2'
               and not exists (select 1
                               from sbs
                               where csbsdo = 'R_IB'
                               and csbsacc= acc.caccacc)
               /* -->> 26.05.2015 ubrr korolkov 15-453 #22215#note-3
               and acc.iaccbs2 NOT IN (40813, 40817, 40818, 40820
                                       -- UBRR Pashevich A. 12-101
                                       ,42309
                                       -- UBRR Pashevich A. 12-101
                                      )
               and SUBSTR (acc.caccacc, 1, 3) NOT IN ('401', '402', '403', '404', '409')
               AND acc.caccacc NOT LIKE '40821________7%' -- 29/12/2011 Бездворный А.В. комиссии по 40821 (контрагенты) по РКО не считаем
               */--<< 26.05.2015 ubrr korolkov 15-453 #22215#note-3
               -- ubrr katyuhin <<<
               and trn.ctrnaccd = acc.cACCacc
               and trn.ctrncur = acc.cACCcur
               and dtrntran between d1 and d2+86399/86400
               -->>31.08.2020 Зеленко С.А.  [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ 
               and exists (select 1 from UBRR_UNIQUE_TARIF_ACC uutc,
                                         UBRR_UNIQUE_ACC_COMMS uuac 
                                   where caccacc = uutc.cacc 
                                     and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF
                                     and l_cidsmr = uutc.idsmr
                                     and uutc.status = 'N'
                                     and uutc.uuta_id = uuac.uuta_id
                                     and uuac.com_type = 'R_IB')           
                --<<31.08.2020 Зеленко С.А.  [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ         
                -->> 26.05.2015 ubrr korolkov 15-453
                -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии                
                -->>19.09.2019 Баязитов [19-62974] IV ЭТАП
                and not exists (select 1
                                  from ubrr_rko_acc_catgr r
                                 where r.cacc = acc.cACCacc
                                   and r.ccur = acc.cACCcur
                                   and r.i_catnum = 112
                                   and r.i_grpnum in (-->><<--23.01.2020 Баязитов [19-64846] убраны кат/гр https://redmine.lan.ubrr.ru/issues/70705#note-3
                                                      94,                 --24.09.2016 ubrr Maкарова Л.Ю. 16-2653 АБС: Кат/гр 112/94 для пакета услуг "Бизнес-комплект"
                                                      57,71,              --29.06.2015  Макарова Л.Ю.       [15-613] ТП Муниципальный-1
                                                      10)                 -- 19.10.2016 ubrr Maкарова Л.Ю. 16-2790  бюджет IB-Pro
                                   and r.idsmr    = l_cidsmr                                                  
                               )
                --<<19.09.2019 Баязитов [19-62974] IV ЭТАП
                -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии                
-->> 01.02.2019 Фридьев П.В.  [19-58770] Изменение даты запуска пролонгации пакетов
               -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии
               -->>19.09.2019 Баязитов [19-62974] IV ЭТАП
               and not exists (select 1
                                 from ubrr_rko_acc_catgr r
                                where r.cacc     = acc.cACCacc
                                  and r.ccur     = acc.cACCcur
                                  and r.i_catnum = 114
                                  and r.i_grpnum = 16
                                  and r.idsmr    = l_cidsmr                                    
                              )
               --<<19.09.2019 Баязитов [19-62974] IV ЭТАП
               -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии
               -->>ubrr 13.12.2019  Ризанов Р.Т. [69650] Новый тарифный план - комиссия за зачисление
               and not exists ( select 1
                                  from ubrr_rko_acc_catgr   r
                                      ,ubrr_rko_exinc_catgr e 
                                 where r.i_catnum   = e.icat
                                   and r.i_grpnum   = e.igrp
                                   and e.ccom_type  = 'R_IB'
                                   and e.exinc      = 0
                                   and r.cacc       = acc.caccacc
                                   and r.ccur       = acc.cACCcur                                 
                                   -->>23.01.2020 Баязитов [19-64846]
                                   and (select trunc(max(au.d_create))
                                          from xxi.au_attach_obg au
                                         where au.caccacc = r.cacc
                                           and au.cacccur = r.ccur
                                           and au.i_table = 304
                                           and au.c_newdata = e.icat||'/'||e.igrp
                                           and trunc(au.d_create) <= r.d_date) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end)
                                   --<<23.01.2020 Баязитов [19-64846]
                              )              
               --<<ubrr 13.12.2019  Ризанов Р.Т. [69650] Новый тарифный план - комиссия за зачисление                              
--<< 01.02.2019 Фридьев П.В.  [19-58770] Изменение даты запуска пролонгации пакетов
             group by ctrnaccd,ctrncur,iACCotd,caccmail
 )
group by acc,ctrncur,iaccotd, caccmail);
DBMS_TRANSACTION.COMMIT;
  
  ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif := 'N';          --09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ (доработка расчета суммы для индивидуальных тарифов)
  ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_id_check := 'Y'; --09.09.2020  Зеленко С.А.     [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ (доработка расчета суммы для индивидуальных тарифов)
  
--<<--ubrr Макарова Л.Ю. 15-42 Доп. комиссия за ведение счета Ибанк-Pro Кр Клиенты

-->>--ubrr Макарова Л.Ю. 15-42 Доп. комиссия за ведение счета Ибанк-Pro Туристический
-->>07.10.2019 Баязитов [19-62974] IV ЭТАП не рассчитывается
/* INSERT INTO SBS
   ( cSBSpayfrom_acc,cSBSacc, cSBScur, mSBStoll_sum, cSBSdo ,iSBSdebdoc,mSBSdebob,iSBScreddoc,mSBScredob)
   (select to_char(sysdate,'HH24:MI:SS'), acc, ctrncur, \*400*\500, 'R_IB', sum(cd), sum(md), sum(cc), sum(mc) --- 19.01.2018 Галиева Н.А  Распоряжения от 15.12.2017 № 7006-2358
      from (select ctrnaccd acc, ctrncur, count(1) c, iaccotd, count(1) cd, sum(mtrnsum) md , 0 cc, 0 mc, caccmail
              from xxi.V_TRN_PART_CURRENT trn, acc a
             where ctrnaccd like acc_1
               and cTRNcur = 'RUR'
               and dtrntran between d1 and d2+86399/86400
               and a.cACCacc = cTRNaccd
               and a.cACCcur = cTRNcur
               and a.cACCprizn <> 'З'
               -->>19.09.2019 Баязитов [19-62974] IV ЭТАП
               \*and exists (SELECT 1
                           FROM gac
                           WHERE cgacacc = cTRNaccd
                           AND cgaccur = ctrncur
                           AND igaccat = 105
                           AND igacnum = 2)*\
               and exists (select 1
                             from ubrr_rko_acc_catgr
                            where cacc = cTRNaccd
                              and ccur = ctrncur
                              and c_data = '105/2')
               --<<19.09.2019 Баязитов [19-62974] IV ЭТАП
               and trn.CTRNIDOPEN='IBANK2'
               and not exists (select 1
                               from sbs
                               where csbsdo = 'R_IB'
                               and csbsacc= a.caccacc)
-->>--11.03.2016 15-1221.1 АБС: Доработка ТП "Онлайн +" (ОТКБ) #25313 Макарова Л.Ю. Мин.тариф, отс-ют обороты

              and not exists (select 1
                                from sbs
                               where csbsdo like 'R_Onl%'
                                 and csbsacc=a.caccacc)
               -->>19.09.2019 Баязитов [19-62974] IV ЭТАП
               \*and not exists (select 1
                          from gac
                         where cgacacc = a.cACCacc
                           and cgaccur = a.cACCcur
                           and igaccat = 131
                           and exists (select 1
                                         from xxi.au_attach_obg au
                                        where au.caccacc = a.cACCacc
                                          and au.cacccur = a.cACCcur
                                          and i_table = 304
                                          and d_create <= d2
                                          and au.c_newdata like '131%'))*\
               and not exists (select 1
                                 from ubrr_rko_acc_catgr
                                where cacc = a.cACCacc
                                  and ccur = a.cACCcur
                                  and trunc(d_create) <= d2
                                  and c_data like '131%')
               --<<19.09.2019 Баязитов [19-62974] IV ЭТАП
-->> UBRR Макарова Л.Ю. 15-42 доп.треб. https://redmine.lan.ubrr.ru/issues/19917#note-36
                -->> 26.05.2015 ubrr korolkov 15-453
                -->>19.09.2019 Баязитов [19-62974] IV ЭТАП
                \*and not exists (select 1
                                from gac
                                where cgacacc = a.cACCacc
                                and cgaccur = a.cACCcur
                                and igaccat = 112
                                and igacnum in (78,79,80,
                                99,100,101,102,103, --27.12.2018 Баязитов [15-43]
                                104,105,106, -- Бизнес  Премиум  3, 6, 12  -- ubrr 31.05.2019 Ризанов Р.Т. [19-59153] АБС. Лимит платежей в пакеты услуг "Бизнес-Класс 3,6,12"
                                94,--24.09.2016 ubrr Maкарова Л.Ю. 16-2653 АБС: Кат/гр 112/94 для пакета услуг "Бизнес-комплект"
                                57,71,--29.06.2015  Макарова Л.Ю.       [15-613] ТП Муниципальный-1
                                10)-- 19.10.2016 ubrr Maкарова Л.Ю. 16-2790  бюджет IB-Pro
                                and exists (select 1
                                            from xxi.au_attach_obg au
                                            where au.caccacc = a.cACCacc
                                            and au.cacccur = a.cACCcur
                                            and i_table = 304
                                            and trunc(d_create) <= d2
                                            and au.c_newdata like '112/'||to_char(gac.igacnum)))*\
                and not exists (select 1
                                  from ubrr_rko_acc_catgr
                                 where cacc = a.cACCacc
                                   and ccur = a.cACCcur
                                   and trunc(d_create) <= d2
                                   and c_data in ('112/78','112/79','112/80',
                                                  '112/99','112/100','112/101','112/102','112/103',
                                                  '112/104','112/105','112/106',
                                                  '112/94',
                                                  '112/57','112/71',
                                                  '112/10'))
                --<<19.09.2019 Баязитов [19-62974] IV ЭТАП
-->> 01.02.2019 Фридьев П.В.  [19-58770] Изменение даты запуска пролонгации пакетов
               -->>19.09.2019 Баязитов [19-62974] IV ЭТАП
               \*and not exists (select 1
                                 from gac
                                 where cgacacc = a.cACCacc
                                   and cgaccur = a.cACCcur
                                   and igaccat = 114
                                   and igacnum = 16)*\
               and not exists (select 1
                                 from ubrr_rko_acc_catgr
                                where cacc = a.cACCacc
                                  and ccur = a.cACCcur
                                  and c_data = '114/16')
               --<<19.09.2019 Баязитов [19-62974] IV ЭТАП
--<< 01.02.2019 Фридьев П.В.  [19-58770] Изменение даты запуска пролонгации пакетов
                --<< 26.05.2015 ubrr korolkov 15-453
               and ( exists (select 1
                              from gac
                             where cGACacc = a.cACCacc
                               and cgaccur = a.cACCcur
                               and igaccat = 112
                               and igacnum = 31)
                 or exists (select 1
                              from xxi.AU_ATTACH_OBG au
                             where au.caccacc = a.cACCacc
                               and au.cacccur = a.cACCcur
                               and to_char(d_create,'mmyyyy') = to_char(add_months(d1,-1),'mmyyyy')
                               and i_table = 304
                               and nvl(au.c_newdata,au.c_olddata) = '112/31'
                               )
                                    )
---<<<UBRR Pashevich A. #12-508
               and not exists (select 1 from ubrr_unique_tarif where ctrnaccd =cacc and dtrncreate between DOPENTARIF and DCANCELTARIF and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)           -->><<-- ubrr Арсланов Д.Ф. #29736 Доработки по РКО для ВУЗ
            group by ctrnaccd,ctrncur,iACCotd, caccmail)
group by acc,ctrncur,iaccotd, caccmail);
DBMS_TRANSACTION.COMMIT;*/
--<<07.10.2019 Баязитов [19-62974] IV ЭТАП не рассчитывается
--<<--ubrr Макарова Л.Ю. 15-42 Доп. комиссия за ведение счета Ибанк-Pro Туристический

-->>--ubrr Макарова Л.Ю. 15-42 Доп. комиссия за ведение счета Ибанк-Pro Экспресс-100
 INSERT INTO SBS
   ( cSBSpayfrom_acc,cSBSacc, cSBScur, mSBStoll_sum, cSBSdo ,iSBSdebdoc,mSBSdebob,iSBScreddoc,mSBScredob)
   (select to_char(sysdate,'HH24:MI:SS'), acc, ctrncur,
         /*400*/500,--- 19.01.2018 Галиева Н.А  Распоряжения от 15.12.2017 № 7006-2358
           'R_IB', sum(cd), sum(md), sum(cc), sum(mc)
      from (select ctrnaccd acc, ctrncur, count(1) c, iaccotd, count(1) cd, sum(mtrnsum) md , 0 cc, 0 mc, caccmail
              from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn, acc a -->><<--23.10.2019 Баязитов [19-62184] Разработка: Ежемесячные ИБ PRO + комис. в валюте за РКО
             where ctrnaccd like acc_1
               and cTRNcur = 'RUR'
               and dtrntran between d1 and d2+86399/86400
               and a.cACCacc = cTRNaccd
               and a.cACCcur = cTRNcur
               and a.cACCprizn <> 'З'
               -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии               
               -->>19.09.2019 Баязитов [19-62974] IV ЭТАП
               and exists (select 1
                             from ubrr_rko_acc_catgr r
                            where r.cacc     = cTRNaccd
                              and r.ccur     = ctrncur
                              and r.i_catnum = 105
                              and r.i_grpnum = 2
                          )
               --<<19.09.2019 Баязитов [19-62974] IV ЭТАП
               -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии               
               and trn.CTRNIDOPEN='IBANK2'
               and not exists (select 1
                               from sbs
                               where csbsdo = 'R_IB'
                               and csbsacc= a.caccacc)
               -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии                               
               -->>19.09.2019 Баязитов [19-62974] IV ЭТАП
             and exists (select 1
                           from ubrr_rko_acc_catgr r
                          where r.cacc     = a.cACCacc
                            and r.ccur     = a.cACCcur
                            and r.i_catnum = 112
                            and r.i_grpnum = 45
                           and r.idsmr     = l_cidsmr                               
                        )
            --<<19.09.2019 Баязитов [19-62974] IV ЭТАП
            -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии            
            -->> 26.05.2015 ubrr korolkov 15-453
            -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии            
            -->>19.09.2019 Баязитов [19-62974] IV ЭТАП
            and not exists (select 1
                              from ubrr_rko_acc_catgr r
                             where r.cacc     = a.cACCacc
                               and r.ccur     = a.cACCcur
                               and r.i_catnum = 112
                               and r.i_grpnum in (-->><<--23.01.2020 Баязитов [19-64846] убраны кат/гр https://redmine.lan.ubrr.ru/issues/70705#note-3
                                                 94,                 -- 24.09.2016 ubrr Maкарова Л.Ю. 16-2653 АБС: Кат/гр 112/94 для пакета услуг "Бизнес-комплект"
                                                 57,71,              -- 29.06.2015  Макарова Л.Ю.       [15-613] ТП Муниципальный-1
                                                 10)                 -- 19.10.2016 ubrr Maкарова Л.Ю. 16-2790  бюджет IB-Pro
                               and r.idsmr    = l_cidsmr                               
                           )
            --<<19.09.2019 Баязитов [19-62974] IV ЭТАП
            -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии            
            --<< 26.05.2015 ubrr korolkov 15-453
-->> 01.02.2019 Фридьев П.В.  [19-58770] Изменение даты запуска пролонгации пакетов
               -->>19.09.2019 Баязитов [19-62974] IV ЭТАП
               -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии               
               and not exists (select 1
                                  from ubrr_rko_acc_catgr r
                                 where cacc       = a.cACCacc
                                   and ccur       = a.cACCcur
                                   and r.i_catnum = 114
                                   and r.i_grpnum = 16
                                   and r.idsmr    = l_cidsmr
                              )
               --<<19.09.2019 Баязитов [19-62974] IV ЭТАП
               -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии
               -->>ubrr 13.12.2019  Ризанов Р.Т. [69650] Новый тарифный план - комиссия за зачисление
               and not exists ( select 1
                                  from ubrr_rko_acc_catgr   r
                                      ,ubrr_rko_exinc_catgr e 
                                 where r.i_catnum   = e.icat
                                   and r.i_grpnum   = e.igrp
                                   and e.ccom_type  = 'R_IB'
                                   and e.exinc      = 0
                                   and r.cacc       = a.caccacc
                                   and r.ccur       = a.cACCcur                                 
                                   -->>23.01.2020 Баязитов [19-64846]
                                   and (select trunc(max(au.d_create))
                                          from xxi.au_attach_obg au
                                         where au.caccacc = r.cacc
                                           and au.cacccur = r.ccur
                                           and au.i_table = 304
                                           and au.c_newdata = e.icat||'/'||e.igrp
                                           and trunc(au.d_create) <= r.d_date) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end)
                                   --<<23.01.2020 Баязитов [19-64846]
                              )              
               --<<ubrr 13.12.2019  Ризанов Р.Т. [69650] Новый тарифный план - комиссия за зачисление                              
--<< 01.02.2019 Фридьев П.В.  [19-58770] Изменение даты запуска пролонгации пакетов
---<<<UBRR Pashevich A. #12-508
               -->>31.08.2020 Зеленко С.А.  [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ 
               and not exists (select 1 from UBRR_UNIQUE_TARIF_ACC uutc,
                                             UBRR_UNIQUE_ACC_COMMS uuac 
                                       where ctrnaccd = uutc.cacc 
                                         and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF 
                                         and l_cidsmr = uutc.idsmr
                                         and uutc.status = 'N'
                                         and uutc.uuta_id = uuac.uuta_id
                                         and uuac.com_type = 'R_IB')
               --<<31.08.2020 Зеленко С.А.  [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ        
            group by ctrnaccd,ctrncur,iACCotd, caccmail)
group by acc,ctrncur,iaccotd, caccmail);
--<<--ubrr Макарова Л.Ю. 15-42 Доп. комиссия за ведение счета Ибанк-Pro Экспресс-100


-->>--ubrr Макарова Л.Ю. 15-42 Доп. комиссия за ведение счета Ибанк-Pro Эконом
 INSERT INTO SBS
   ( cSBSpayfrom_acc,cSBSacc, cSBScur, mSBStoll_sum, cSBSdo ,iSBSdebdoc,mSBSdebob,iSBScreddoc,mSBScredob)
   (select to_char(sysdate,'HH24:MI:SS'), acc,ctrncur,
           /*400*/500, --- 19.01.2018 Галиева Н.А  Распоряжения от 15.12.2017 № 7006-2358
            'R_IB',--нет разделения по выпискам
            sum(cd),sum(md),sum(cc),sum(mc)
       from (select ctrnaccd acc,ctrncur,count(1) c,iaccotd,count(1) cd,sum(mtrnsum) md ,0 cc,0 mc, caccmail
              from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn, acc a -->><<--23.10.2019 Баязитов [19-62184] Разработка: Ежемесячные ИБ PRO + комис. в валюте за РКО
             where ctrnaccd like acc_1
             and cTRNcur = 'RUR'
             -->> Ubrr Маkarova L.U. Торговый,условия отбора док-тов, для взимания комиссии
             -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии             
             -->>19.09.2019 Баязитов [19-62974] IV ЭТАП
             and exists (select 1
                           from ubrr_rko_acc_catgr r
                          where r.cacc     = cTRNaccd
                            and r.ccur     = ctrncur
                            and r.i_catnum = 105
                            and r.i_grpnum = 2
                            and r.idsmr    = l_cidsmr
                        )
             --<<19.09.2019 Баязитов [19-62974] IV ЭТАП
             -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии             
             and trn.CTRNIDOPEN='IBANK2'
             and not exists (select 1
                             from sbs
                             where csbsdo = 'R_IB'
                             and csbsacc= a.caccacc)
             and dtrntran between d1 and d2+86399/86400
                 -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии             
                 -->>19.09.2019 Баязитов [19-62974] IV ЭТАП
                 and exists (select 1
                               from ubrr_rko_acc_catgr r
                              where r.cacc     = cACCacc
                                and r.ccur     = cACCcur
                                and r.i_catnum = 112
                                and r.i_grpnum in (6,8)
                                and r.idsmr    = l_cidsmr
                            )
                and not exists (select 1
                                  from ubrr_rko_acc_catgr r
                                 where r.cacc     = a.cACCacc
                                   and r.ccur     = a.cACCcur
                                   and r.i_catnum = 112
                                   and r.i_grpnum in (-->><<--23.01.2020 Баязитов [19-64846] убраны кат/гр https://redmine.lan.ubrr.ru/issues/70705#note-3
                                                      94,                 --24.09.2016 ubrr Maкарова Л.Ю. 16-2653 АБС: Кат/гр 112/94 для пакета услуг "Бизнес-комплект"
                                                      57,71,              --29.06.2015  Макарова Л.Ю.       [15-613] ТП Муниципальный-1
                                                      10)                 -- 19.10.2016 ubrr Maкарова Л.Ю. 16-2790  бюджет IB-Pro
                                   and r.idsmr    = l_cidsmr                                                      
                               )
                 --<<19.09.2019 Баязитов [19-62974] IV ЭТАП
                 -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии                 
-->> 01.02.2019 Фридьев П.В.  [19-58770] Изменение даты запуска пролонгации пакетов
               -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии
               -->>19.09.2019 Баязитов [19-62974] IV ЭТАП
               and not exists (select 1
                                 from ubrr_rko_acc_catgr r
                                where r.cacc     = a.cACCacc
                                  and r.ccur     = a.cACCcur
                                  and r.i_catnum = 114
                                  and r.i_grpnum = 16
                                  and r.idsmr    = l_cidsmr
                              )
               --<<19.09.2019 Баязитов [19-62974] IV ЭТАП
               -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии
               -->>ubrr 13.12.2019  Ризанов Р.Т. [69650] Новый тарифный план - комиссия за зачисление
               and not exists ( select 1
                                  from ubrr_rko_acc_catgr   r
                                      ,ubrr_rko_exinc_catgr e 
                                 where r.i_catnum   = e.icat
                                   and r.i_grpnum   = e.igrp
                                   and e.ccom_type  = 'R_IB'
                                   and e.exinc      = 0
                                   and r.cacc       = a.caccacc
                                   and r.ccur       = a.cACCcur                                 
                                   -->>23.01.2020 Баязитов [19-64846]
                                   and (select trunc(max(au.d_create))
                                          from xxi.au_attach_obg au
                                         where au.caccacc = r.cacc
                                           and au.cacccur = r.ccur
                                           and au.i_table = 304
                                           and au.c_newdata = e.icat||'/'||e.igrp
                                           and trunc(au.d_create) <= r.d_date) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end)
                                   --<<23.01.2020 Баязитов [19-64846]
                              )              
               --<<ubrr 13.12.2019  Ризанов Р.Т. [69650] Новый тарифный план - комиссия за зачисление                              
--<< 01.02.2019 Фридьев П.В.  [19-58770] Изменение даты запуска пролонгации пакетов
                and cACCacc = cTRNaccd
               and cACCcur = cTRNcur
               and cACCprizn <> 'З'
---<<<UBRR Pashevich A. #12-508
               -->>31.08.2020 Зеленко С.А.  [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ 
               and not exists (select 1 from UBRR_UNIQUE_TARIF_ACC uutc,
                                             UBRR_UNIQUE_ACC_COMMS uuac 
                                       where ctrnaccd = uutc.cacc 
                                         and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF 
                                         and l_cidsmr = uutc.idsmr
                                         and uutc.status = 'N'
                                         and uutc.uuta_id = uuac.uuta_id
                                         and uuac.com_type = 'R_IB')
               --<<31.08.2020 Зеленко С.А.  [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ         
             group by ctrnaccd,ctrncur,iACCotd, caccmail
                         )
group by acc,ctrncur,iaccotd, caccmail);
DBMS_TRANSACTION.COMMIT;
--<<--ubrr Макарова Л.Ю. 15-42 Доп. комиссия за ведение счета Ибанк-Pro Эконом
---<<< Pashevich A. #12-508

-->>29.10.2018  Баязитов [18-592.2] АБС Разовая комиссия по светофору
declare
    type t_tAccList Is Table of acc%rowtype index by binary_integer;
    tAccList t_tAccList;

    iAccSel    integer;
    nOstMax    number;
    dOstDate   date;
    ost_vr     number;
    ost_rr     number;
    ost_vp     number;
    deb_dark   number;
    cred_dark  number;
    iCurIdSmr  number := ubrr_get_context;
  PROCEDURE WriteProtocol(cMess IN VARCHAR2) is
   PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO ubrr_data.ubrr_sbs_new_log (UserName, SessionID, Log_date, Message)
    VALUES (USER, UserEnv('SessionID'), SysDate, 'UBRR_BNKSERV_IB: ' || cMess);
    COMMIT;
  END;
begin
    delete from sbs where csbsdo = 'R_IB_LT';
    DBMS_TRANSACTION.COMMIT;

    delete from ubrr_data.ubrr_sbs_ext e
     where e.csbsdo = 'R_IB_LT'
       and e.idsmr = iCurIdSmr;

    WriteProtocol('Разовая комиссия по светофору. Начало');

    for Cr IN (select icusnum, click_count, click_summa
                 from correqts.v_ubrr_kontur_counter@cts
                where click_month between d1 and d2 + 86399/86400)
    loop
        tAccList.delete;

        select *
        bulk collect into tAccList
        from acc a
        where a.IACCCUS=Cr.icusnum
          and a.caccprizn<>'З'
          and a.caccprizn='О'
          and a.caccacc like acc_1
          and a.cacccur = 'RUR'
          -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии          
          -->>19.09.2019 Баязитов [19-62974] IV ЭТАП
          and exists (select 1
                        from ubrr_rko_acc_catgr r
                       where r.cacc     = a.caccacc
                         and r.ccur     = a.cacccur
                         and r.i_catnum = 3
                         and r.i_grpnum = 36
                         and r.idsmr    = l_cidsmr
                     )     
          and not exists (select 1
                            from ubrr_rko_acc_catgr r
                           where r.cacc     = a.caccacc
                             and r.ccur     = a.cacccur
                             and r.i_catnum = 333
                             and r.i_grpnum = 2
                             and r.idsmr    = l_cidsmr
                         );
          --<<19.09.2019 Баязитов [19-62974] IV ЭТАП
          -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии          
        if nvl(tAccList.Count, 0) = 0 then
            select *
            bulk collect into tAccList
            from acc a
            where a.IACCCUS=Cr.icusnum
              and a.caccprizn<>'З'
              and a.caccprizn<>'О'
              and a.caccacc like acc_1
              and a.cacccur = 'RUR'
               -- ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии              
              -->>19.09.2019 Баязитов [19-62974] IV ЭТАП
              and exists (select 1
                            from ubrr_rko_acc_catgr r
                           where r.cacc     = a.caccacc
                             and r.ccur     = a.cacccur
                             and r.i_catnum = 3
                             and r.i_grpnum = 36
                             and r.idsmr    = l_cidsmr
                         )     
              and not exists (select 1
                                from ubrr_rko_acc_catgr r
                               where r.cacc     = a.caccacc
                                 and r.ccur     = a.cacccur
                                 and r.i_catnum = 333
                                 and r.i_grpnum = 2
                                 and r.idsmr    = l_cidsmr
                         );
              --<<19.09.2019 Баязитов [19-62974] IV ЭТАП
              -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии              
        end if;
        WriteProtocol('Клиент ' || Cr.icusnum || ' кол-во счетов ' || nvl(tAccList.Count, 0));

        if nvl(tAccList.Count, 0) > 0 then
            iAccSel := NULL;
            nOstMax := -99e99;
            -- Выбрать из полученной выборки счетов, в разрезе клиента, любой р/с с наибольшим остатком на дату расчета
            for i IN tAccList.first .. tAccList.last loop
                WriteProtocol('Счет ' || tAccList(i).caccacc || ' филиал '  || tAccList(i).idsmr);

                if tAccList(i).idsmr = iCurIdSmr
                then
                    UTIL_DM2.Acc_Ost2(0, tAccList(i).caccacc, tAccList(i).cacccur, dtran, ost_vr, ost_rr, ost_vp, deb_dark, cred_dark);
                    IF tAccList(i).caccap='П' THEN
                        ost_vr := -ost_vr;
                        ost_rr := -ost_rr;
                        ost_vp := -ost_vp;
                    END IF;
                    WriteProtocol('Остаток ' || ost_vr);
                    if ost_vr > nOstMax
                    then
                        nOstMax := ost_vr;
                        iAccSel := i;
                    end if;
                end if;
            end loop;

            if iAccSel is not null then
                WriteProtocol('Выбран счет ' || tAccList(iAccSel).caccacc  || ' с макс. остатком ' || nOstMax || ' на ' || to_char(dtran, 'dd.mm.rrrr') || ', в кол-ве кликов: ' || Cr.click_count);

                INSERT INTO SBS ( cSBSpayfrom_acc, cSBSacc, cSBScur, mSBStoll_sum, cSBSdo ,iSBSdebdoc,mSBSdebob,iSBScreddoc,mSBScredob)
                    (select to_char(sysdate,'HH24:MI:SS'), tAccList(iAccSel).caccacc, tAccList(iAccSel).cacccur, Cr.click_summa, 'R_IB_LT', 0, 0, 0, 0
                       from acc a
                      where caccacc like tAccList(iAccSel).caccacc
                        and cacccur = 'RUR'
                        and cACCprizn <> 'З'
                        and not exists (select 1
                                          from sbs
                                         where csbsdo = 'R_IB_LT'
                                           and csbsacc= a.caccacc)
                            -- >> ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии                                           
                            -->>19.09.2019 Баязитов [19-62974] IV ЭТАП
                            and not exists (select 1
                                              from ubrr_rko_acc_catgr r
                                             where r.cacc     = cACCacc
                                               and r.ccur     = cACCcur
                                               and r.i_catnum = 114
                                               and r.i_grpnum = 12
                                               and r.idsmr    = l_cidsmr
                                               and exists (select 1
                                                             from xxi.au_attach_obg au
                                                            where r.cacc              = caccacc
                                                              and r.ccur              = cacccur
                                                              and trunc(au.d_create) >= d1
                                                              and trunc(au.d_create) <= d2
                                                              and au.c_newdata        ='114/12')                                               
                                          )
                            --<<19.09.2019 Баязитов [19-62974] IV ЭТАП
                            -- << ubrr 06.11.2019  Ризанов Р.Т.  [19-64491] РАЗРАБОТКА (ДОП.) УБРИР РКО Ежем.комиссии                            
                       );

                insert into ubrr_data.ubrr_sbs_ext (cSBSacc, cSBSdo, idsmr, icusnum, ccomment)
                     values (tAccList(iAccSel).caccacc, 'R_IB_LT', iCurIdSmr, Cr.icusnum, Cr.click_count);
            end if;
        else
            WriteProtocol('R_IB_LT Не найден счет для списания комиссии клиент № ' || Cr.icusnum);

            insert into SBS (cSBSpayfrom_acc, cSBSacc, cSBScur, mSBStoll_sum, cSBSdo, iSBSdebdoc, msbsdebob)
            values (to_char(sysdate, 'HH24:MI:SS'), '<р/с не найден>', 'RUR', 0, 'R_IB_LT Не найден счет для списания комиссии клиент № ' || Cr.icusnum || ' ' ||  to_char(dtran, 'dd.mm.rrrr hh24:mi:ss'), 0, 0);

            insert into ubrr_data.ubrr_sbs_ext (cSBSdo, idsmr, icusnum) values ('R_IB_LT', iCurIdSmr, Cr.icusnum);
        end if;
    end loop;
    WriteProtocol('Разовая комиссия по светофору. Конец');

    tAccList.delete;

    dbms_transaction.commit;
end;
--<<29.10.2018  Баязитов [18-592.2] АБС Разовая комиссия по светофору

    --ЗАЧЕМ??
    -- UBRR Pashevich A. 12-101
Begin
 ubrr_rko.SBSchangeacc('',1);
 dbms_transaction.commit;
end;
-- UBRR Pashevich A. 12-101
-- 06.04.2015 ubrr Макарова Л.Ю. 15-42 Доп. комиссия за ведение счета Ибанк-Pro Online--
-- убираем разные счета одного и того же клиента, оставляем один
    DECLARE
        CURSOR Cr IS
            SELECT * FROM sbs WHERE csbsdo in ('R_IB', 'R_IB_LT');  -->><<--07.11.2018  Баязитов [18-592.2] АБС Разовая комиссия по светофору
        CrRow Cr%ROWTYPE;
    BEGIN
        LOOP
            IF NOT Cr%ISOPEN
            THEN
                OPEN Cr;
            END IF;
            FETCH Cr
                INTO CrRow;
            IF Cr%FOUND
            THEN
                DELETE FROM sbs
                 WHERE csbsdo in ('R_IB', 'R_IB_LT') -->><<--07.11.2018  Баязитов [18-592.2] АБС Разовая комиссия по светофору
                       AND csbsacc IN
                       (SELECT caccacc
                              FROM acc
                             WHERE caccprizn <> 'З'
                                   AND iacccus =
                                   (SELECT iacccus
                                          FROM acc
                                         WHERE caccacc = CrRow.csbsacc
                                               AND rownum = 1))
                       AND csbsacc <> CrRow.csbsacc;
                IF SQL%ROWCOUNT > 0
                THEN
                    CLOSE Cr;
                END IF;
            ELSE
                EXIT;
            END IF;
        END LOOP;
        IF Cr%ISOPEN
        THEN
            CLOSE Cr;
        END IF;
    END;
      dbms_transaction.commit;
END ubrr_bnkserv_ib;
/
