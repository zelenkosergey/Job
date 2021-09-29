CREATE OR REPLACE PACKAGE UBRR_XXI5.ubrr_isys_for_cd_bki_V7_05
  IS
/******************************* HISTORY UBRR *****************************************\
Дата        Автор            ID        Описание
----------  ---------------  --------- ---------------------------------------
12.05.2021  Зеленко С.А      DKBPA-845    Новые форматы для передачи данных в НБКИ – TUTDF 7.05. + доработки по недопущению санкций ЦБ
02.06.2021  Зеленко С.А      DKBPA-1378   Этап 2. Цессии. Поле "лимит/сумма обязательств"
17.06.2021  Пинаев Д.Е.      DKBPA-1434   Выпуск формата передачи данных в НБКИ - TUTDF 8.0 с 19.07.2021
\******************************* HISTORY UBRR *****************************************/

  gc_far_date  constant date := to_date('31.12.9999','dd.mm.yyyy'); --12.05.2021  Зеленко С.А      DKBPA-845

   FUNCTION get_tech_agrid
    ( p_nagrid IN cda.ncdaagrid%TYPE,
      p_date IN DATE DEFAULT CD.get_lsdate)
   RETURN cda.ncdaagrid%TYPE;

   FUNCTION IsSpisRemed
    ( p_nagrid IN cda.ncdaagrid%TYPE,
      p_date IN DATE DEFAULT CD.get_lsdate)
   RETURN NUMBER;

   FUNCTION GetSumOver
    ( p_nagrid IN cda.ncdaagrid%TYPE,
      p_date IN DATE DEFAULT CD.get_lsdate)
   RETURN NUMBER;

   FUNCTION IsContEveryMonthPay
    ( p_nagrid IN cda.ncdaagrid%TYPE)
   RETURN NUMBER;

   FUNCTION GetContPeriodPayPerc
    ( p_nagrid IN cda.ncdaagrid%TYPE,
      p_date DATE)
   RETURN NUMBER;

   FUNCTION GetSumByCont
    ( p_nagrid IN cda.ncdaagrid%TYPE,
      p_date DATE)
   RETURN NUMBER;
   --UBRR Салахеев Р.Р. 14-838
   function cdeisRemed(pIEVENTID number)return number ;
   function get_sum_rem(pcusid number,pd date)return number;
   --14-1398
   function Get_name(p_cusid number, p_id number) return VARCHAR2;
   --15-18
   function Get_ACCs(p_Agrid number) return number;
   -->> 17.06.2021  Пинаев Д.Е.      DKBPA-1434   Выпуск формата передачи данных в НБКИ - TUTDF 8.0 с 19.07.2021
   -- Полная стоимость кредита, в денежном выражении
   function Get_ACCs_money(p_Agrid number) return number;
   --<< 17.06.2021  Пинаев Д.Е.      DKBPA-1434   Выпуск формата передачи данных в НБКИ - TUTDF 8.0 с 19.07.2021

   function Get_ClType(p_Client number, p_Agrid number) return number;
   function Get_InfoPoruch (p in number, p_Agrid in number, p_Client in number default null, p_date in date default CD.GET_LSDate, p_d353 in date default to_date('01.02.2015', 'dd.mm.yyyy')) return number;

   -->> ubrr Арсланов Д.Ф. 15-303 Функция возвращает дату последней проводки по погашению по счетам 91704, 91802, 91803 по безнадежным
   function Get_PayOff_Remed_Date
     (p_nagrid IN cda.ncdaagrid%TYPE,
      p_date in date,
      p_edate in date
     ) return date;
   -->> ubrr Арсланов Д.Ф. 15-303

   -->> ubrr Рохин Е.А. 16-2520.11 Удаление лишних данных
   function Del_PersDataFL(pcusid number) return number;
   function Del_PersDataUL(pcusid number) return number;
   function Del_Address(pcusid number) return number;
   --<< ubrr Рохин Е.А. 16-2520.11 Удаление лишних данных

   -- >> ubrr 01.10.2019  Ризанов Р.Т.  [19-59626] Разработка НБКИ - TUTDF версии 4.10.
   -- округление суммы по определенному требованию
   function round_sum_bki( p_val in number )
   return number;
   -- << ubrr 01.10.2019  Ризанов Р.Т.  [19-59626] Разработка НБКИ - TUTDF версии 4.10.

   -->>ubrr 06.06.2020  Арсланов Д.Ф. [20-74056]  Доработка отчета в НБКИ 7.01 (льготный период)
   function get_TR_Field_V49 (p_Agrid number, p_date date) return varchar2;  -- Сегмент TR Поле 49 "Дата окончания льготного периода"
   function get_TR_Field_V51 (p_Agrid number, p_date date) return varchar2;  -- Сегмент TR Поле 51 "Дата неподтверждения/неустановления льготного периода"
   function get_TR_Field_V52 (p_Agrid number, p_date date) return varchar2;  -- Сегмент TR Поле 52 "Основание установления льготного периода"
   function get_TR_Field_V53 (p_Agrid number, p_date date) return varchar2;  -- Сегмент TR Поле 53 "Дата начала льготного периода"
   --<<ubrr 06.06.2020  Арсланов Д.Ф. [20-74056]  Доработка отчета в НБКИ 7.01 (льготный период)

-->>12.05.2021  Зеленко С.А      DKBPA-845
-------------------------------------------------------------------------------
-- Функция получения даты начала КД
-------------------------------------------------------------------------------
function get_agrid_datbeg(par_agrid in cda.ncdaagrid%type)
  return date;

-------------------------------------------------------------------------------
-- Функция получения даты окончания КД
-------------------------------------------------------------------------------
function get_agrid_datend(par_agrid in cda.ncdaagrid%type)
  return date;

-------------------------------------------------------------------------------
-- Процедура расчета ежемесячных дат (700100180011,700100180016)
-------------------------------------------------------------------------------
procedure Calc_Dat_Month_ListTable(p_p3  in varchar2,
                                   p_p9  in varchar2,
                                   p_p10 in varchar2
                                  );

-------------------------------------------------------------------------------
-- Процедура расчета ежемесячных дат (700100170011)
-------------------------------------------------------------------------------
procedure Calc_Dat_Month_Table(p_p9 in varchar2
                              );

------------------------------------------------------------------------------------
-- Процедура добавения записи в таблицу справочника наихудших значений
-- Своевременности платежей за календарный месяц
------------------------------------------------------------------------------------
procedure set_ubrr_cd_bki_prsr_countday( p_nagrid     in ubrr_data.ubrr_cd_bki_prsr_countday.nagrid%type,
                                         p_datmonth   in ubrr_data.ubrr_cd_bki_prsr_countday.datmonth%type,
                                         p_datprsr    in ubrr_data.ubrr_cd_bki_prsr_countday.datprsr%type,
                                         p_ncountday  in ubrr_data.ubrr_cd_bki_prsr_countday.ncountday%type
                                         );

------------------------------------------------------------------------------------
-- Получить значение своевременности платежа согласно количества дней просрочки
------------------------------------------------------------------------------------
function get_typesp_of_countday( p_countday in number )
  return varchar2;

------------------------------------------------------------------------------------
-- Рассчитаем своевременности платежа по возникновению просроченнной задолженности на отчетную дату
-- Проверим со справочником снаихудших значений Своевременности платежей за календарный месяц
------------------------------------------------------------------------------------
function get_calc_prsr_of_agrid( p_agrID    in number,
                                 p_datprsr  in date
                                )
  return varchar2;

------------------------------------------------------------------------------------
-- Получить первичный договор
------------------------------------------------------------------------------------
function get_agrid_of_parent( p_agrID  in cda.ncdaagrid%TYPE
                            )
  return cda.ncdaagrid%TYPE;
  
------------------------------------------------------------------------------------
-- Остаток по внебалансовым счетам на дату, списаных за счет резерва
------------------------------------------------------------------------------------
function get_sum_isremed(p_agrID        in number,
                         p_date         in date
                         )
  return number;
  
------------------------------------------------------------------------------------
-- Дата обнуления остатка по внебалансовым счетах, списаных за счет резерва
------------------------------------------------------------------------------------  
function get_date_isremed(p_agrID        in number)
  return date;

------------------------------------------------------------------------------------
-- Вернем лимит кредита, если на дату он = 0, вернем предыдущее значение <> 0
------------------------------------------------------------------------------------
function get_limit_td(p_agrid     in number, 
                      p_effdate   in date
                      ) 
  return number;    
--<<12.05.2021  Зеленко С.А      DKBPA-845

-->>02.06.2021  Зеленко С.А      DKBPA-1378 
------------------------------------------------------------------------------------
-- Проверим для «первичных» срочных пролонгаций подходит ли под цессию 
-- является «купленным»/«проданным»   
------------------------------------------------------------------------------------
function check_agrid_bought_sold(p_agrID  in cda.ncdaagrid%TYPE
                                )
  return boolean;
  
------------------------------------------------------------------------------------
-- Вернем дату из «проданной» пролонгации  
------------------------------------------------------------------------------------
function get_signdate_bought_sold(p_agrID  in cda.ncdaagrid%TYPE
                                 )
  return date;
  
------------------------------------------------------------------------------------
-- Вернем сумму из «проданной» пролонгации (проверим валюту)
------------------------------------------------------------------------------------
function get_total_bought_sold(p_agrID  in cda.ncdaagrid%TYPE
                               )
  return number;  
--<<02.06.2021  Зеленко С.А      DKBPA-1378 

END;
/
CREATE OR REPLACE PACKAGE BODY UBRR_XXI5.ubrr_isys_for_cd_bki_V7_05
IS
/******************************* HISTORY UBRR *****************************************\
Дата        Автор            ID        Описание
----------  ---------------  --------- ---------------------------------------
12.05.2021  Зеленко С.А      DKBPA-845    Новые форматы для передачи данных в НБКИ – TUTDF 7.05. + доработки по недопущению санкций ЦБ
02.06.2021  Зеленко С.А      DKBPA-1378   Этап 2. Цессии. Поле "лимит/сумма обязательств"
17.06.2021  Пинаев Д.Е.      DKBPA-1434   Выпуск формата передачи данных в НБКИ - TUTDF 8.0 с 19.07.2021
\******************************* HISTORY UBRR *****************************************/

   FUNCTION get_tech_agrid
    ( p_nagrid IN cda.ncdaagrid%TYPE,
      p_date IN DATE DEFAULT CD.get_lsdate)
   RETURN cda.ncdaagrid%TYPE
    IS
      icntOpens INTEGER;
      iAgrid cda.ncdaagrid%TYPE:=0;
   BEGIN
     -->>12.05.2021  зеленко с.а      dkbpa-845
     --изменяется логика работы функции, что передали то и вернули, что бы не менять все вызовы
     /*
     select count(*)
     into icntopens
     from xxi."cda" a
     where a.ncdaagrid between trunc(p_nagrid) and trunc(p_nagrid)+0.99
       and dcdastarted<=p_date and (icdastatus=2 or dcdaclosed>p_date);
     if icntopens=0 then
       select max(ncdaagrid)
       into iagrid
       from xxi."cda" a
       where a.ncdaagrid between trunc(p_nagrid) and trunc(p_nagrid)+0.99
         and dcdastarted<=p_date;
     elsif icntopens=1 then
       select ncdaagrid
       into iagrid
       from xxi."cda" a
       where a.ncdaagrid between trunc(p_nagrid) and trunc(p_nagrid)+0.99
         and dcdastarted<=p_date and (icdastatus=2 or dcdaclosed>p_date);
     else
       select ncdaagrid
       into iagrid
       from (
         select a.ncdaagrid,
           sign(nvl(cdbalance.get_cursaldo (a.ncdaagrid, 1, null, null, p_date),0)
              + nvl(cdbalance.get_cursaldo (a.ncdaagrid, 5, null, null, p_date),0)
               ) debt,
           sign((select nvl(sum(decode(icdetype,65,mcdesum,66,-mcdesum)),0)
                 from cde
                 where cde.icdetype in (65,66)
                   and cde.ncdeagrid = a.ncdaagrid
                   and cde.dcdedate <= p_date)
               ) lim
        from xxi."cda" a
        where a.ncdaagrid between trunc(p_nagrid) and trunc(p_nagrid)+0.99
          and dcdastarted<=p_date and (icdastatus=2 or dcdaclosed>p_date)
        order by debt desc, lim desc, ncdaagrid desc
       ) where rownum=1;
     end if;
     if iagrid=0 then
       iagrid := p_nagrid;
     end if;
     return iagrid;
     */
     return p_nagrid;
     --<<12.05.2021  зеленко с.а      dkbpa-845
   exception
      -->>12.05.2021  зеленко с.а      dkbpa-845
      when value_error then
        return null;
      --<<12.05.2021  зеленко с.а      dkbpa-845
      when others then
        return p_nagrid;
   end;

   FUNCTION IsSpisRemed_old  --IsSpisRemed 02.06.2021  Зеленко С.А      DKBPA-1378   Этап 2. Цессии. Поле "лимит/сумма обязательств"
    ( p_nagrid IN cda.ncdaagrid%TYPE,
      p_date IN DATE DEFAULT CD.get_lsdate)
   RETURN NUMBER
   IS
      iIsremed INTEGER := 0;
      vDateClosed DATE;
   BEGIN
     -->> ubrr Арсланов Д.Ф. 15-303 Для закрытых более 5 лет назад считаем их полностью закрытыми, безнадежные не считаем
     SELECT dCDAclosed
     INTO vDateClosed
     FROM cda
     WHERE ncdaagrid = p_nagrid;
     IF vDateClosed IS NULL OR ADD_MONTHS(vDateClosed, 60)>p_date THEN -- Не прошло 5 лет
     --<< ubrr Арсланов Д.Ф. 15-303 Для закрытых более 5 лет назад считаем их полностью закрытыми, безнадежные не считаем
       BEGIN
         SELECT 1
         INTO iIsRemed
         FROM DUAL WHERE EXISTS (
           SELECT 1 FROM cde cde1
           WHERE cde1.ncdeagrid = p_nagrid
             AND cde1.icdetype=12
             AND cde1.dcdedate<=p_date
             AND exists (SELECT 1 FROM cde cde2, gtr g
                         WHERE cde2.ncdeagrid=cde1.ncdeagrid
                           AND cde2.dcdedate<=p_date
                           AND cde2.icdetype=54
                           AND cde2.icdetrnnum=g.igtrtrnnum
                           AND cde2.icdetrnanum=g.igtrtrnanum
                           AND g.igtrcat=808
                           AND g.igtrnum=34
                         )
         );
       EXCEPTION
         WHEN OTHERS THEN
         BEGIN
           SELECT 1
           INTO iIsRemed
           FROM DUAL WHERE EXISTS (
             SELECT 1 FROM cde cde1, trn t
             WHERE cde1.ncdeagrid = p_nagrid
               AND cde1.icdetype IN (82, 182)
               AND cde1.dcdedate<=p_date
               AND cde1.icdetrnnum=t.itrnnum
               AND cde1.icdetrnanum=t.itrnanum
               AND (t.ctrnaccd like '917%' or t.ctrnaccd like '918%')
           );
         EXCEPTION
           WHEN OTHERS THEN
             RETURN 0;
         END;
       END;
     END IF;
     RETURN iIsRemed;
   EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
   END;
   
   -->>02.06.2021  Зеленко С.А      DKBPA-1378   Этап 2. Цессии. Поле "лимит/сумма обязательств"
   FUNCTION IsSpisRemed
    ( p_nagrid IN cda.ncdaagrid%TYPE,
      p_date IN DATE DEFAULT CD.get_lsdate)
   RETURN NUMBER
   IS
      iIsremed INTEGER := 0;
      vDateClosed DATE;
   BEGIN
     SELECT dCDAclosed
     INTO vDateClosed
     FROM cda
     WHERE ncdaagrid = p_nagrid;
     
     IF vDateClosed IS NULL OR ADD_MONTHS(vDateClosed, 60)>p_date THEN -- Не прошло 5 лет
       BEGIN
         SELECT 1
         INTO iIsRemed
         FROM DUAL WHERE EXISTS (
           SELECT 1 FROM cde cde1
           WHERE cde1.ncdeagrid = p_nagrid
             AND cde1.icdetype=12
             AND cde1.dcdedate<=p_date
             AND exists (SELECT 1 FROM cde cde2, gtr g
                         WHERE cde2.ncdeagrid=cde1.ncdeagrid
                           AND cde2.dcdedate<=p_date
                           AND cde2.icdetype=54
                           AND cde2.icdetrnnum=g.igtrtrnnum
                           AND cde2.icdetrnanum=g.igtrtrnanum
                           AND g.igtrcat=808
                           AND g.igtrnum=34
                         )
         );
       EXCEPTION
         WHEN OTHERS THEN
         BEGIN
           SELECT 1
           INTO iIsRemed
           FROM DUAL WHERE EXISTS (
             SELECT 1 FROM cde cde1, trn t
             WHERE cde1.ncdeagrid = p_nagrid
               AND cde1.icdetype IN (82, 182)
               AND cde1.dcdedate<=p_date
               AND cde1.icdetrnnum=t.itrnnum
               AND cde1.icdetrnanum=t.itrnanum
               AND (t.ctrnaccd like '917%' or t.ctrnaccd like '918%')
           );
         EXCEPTION
           WHEN OTHERS THEN
           BEGIN
             SELECT 1
             INTO iIsRemed
             FROM DUAL WHERE EXISTS (
               SELECT 1 FROM cde cde1, trn t
               WHERE cde1.ncdeagrid = p_nagrid
                 AND cde1.icdetype IN (12, 13)
                 AND cde1.dcdedate<=p_date
                 AND cde1.icdetrnnum=t.itrnnum
                 AND cde1.icdetrnanum=t.itrnanum
                 AND (upper(t.ctrnpurp) like '%СПИСАНИЕ%ЗА%СЧЕТ%РЕЗЕРВА%')
             );
           EXCEPTION
             WHEN OTHERS THEN
               RETURN 0;
           END;
         END;
       END;
     END IF;
     RETURN iIsRemed;
   EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
   END;
   --<<02.06.2021  Зеленко С.А      DKBPA-1378   Этап 2. Цессии. Поле "лимит/сумма обязательств"     

   -->> ubrr Арсланов Д.Ф. 15-303 Расчет сумм для безнадежных ссуд
   function get_sum_rem_new(pnagrid number, pcusid number, pDateClose date, pd date) return number is
     rez number := 0;
   begin
     IF pDateClose IS NULL OR ADD_MONTHS(pDateClose, 60)>pd THEN
       select nvl(sum(xXi.Util_Dm2.Acc_Ostt(null,caccacc, cacccur, pd+1, 'V', 1, 'TRUE', idsmr)),0)
       into rez
       from ubrr_acc_v acc
       where acc.IACCCUS=pcusid
         and iaccbs2 in (91704, 91802, 91803)
         and acc.DACCOPEN<=pd and (caccprizn<>'З' or acc.DACCCLOSE>pd)
         -->>12.05.2021  зеленко с.а      dkbpa-845
         --and acc.caccacc like '%'||trunc(pnagrid)
         and (acc.caccacc like '%'||trunc(pnagrid)
              or
              exists(select 1
                       from xxi."cda" c
                      where c.ncdaagrid = pnagrid
                        and c.idsmr = acc.idsmr 
                        and (c.ccdaagrmnt = acc.CACCSIO 
                             or 
                             to_char(trunc(c.ncdaagrid)) = acc.CACCSIO
                             )
                     )
              );
         --<<12.05.2021  зеленко с.а      dkbpa-845
     END IF;
     return rez;
   EXCEPTION
     WHEN OTHERS THEN
       RETURN 0;
   end;
   --<< ubrr Арсланов Д.Ф. 15-303 Расчет сумм для безнадежных ссуд

   FUNCTION GetSumOver
    ( p_nagrid IN cda.ncdaagrid%TYPE,
      p_date IN DATE DEFAULT CD.get_lsdate)
   RETURN NUMBER
   IS
     nSumOver NUMBER:=0;
     vcusid number;
     vCloseDate date;
   BEGIN
     nSumOver:=
        NVL(CDSTATE.Get_Int_626_Date_TD(p_nagrid,p_date),0)+
        NVL(CDSTATE.get_int_626nb_td   (p_nagrid,p_date),0) +
        NVL(CDSTATE2.Get_RestLoan_PRSR (p_nagrid,p_date),0)+
        NVL(CDBALANCE.get_CurSaldo(p_nagrid,113,null,null,p_date),0)+
--        nvl(CDBALANCE.get_CurSaldo(p_nagrid,25 ,null,null,p_date),0)+ UBRR Салахеев Р.Р. 14-838
--        nvl(CDBALANCE.get_CurSaldo(p_nagrid,26 ,null,null,p_date),0)+ UBRR Салахеев Р.Р. 14-838
--        nvl(CDBALANCE.get_CurSaldo(p_nagrid,40 ,null,null,p_date),0)+
--        nvl(CDBALANCE.get_CurSaldo(p_nagrid,126,null,null,p_date),0)+ UBRR Салахеев Р.Р. 14-838
        nvl(CDBALANCE.get_CurSaldo(p_nagrid,106,null,null,p_date),0);
     -->> ubrr Арсланов Д.Ф. 15-303 Изменен расчет сумм для безнадежных ссуд
        select cda.ICDACLIENT, cda.dcdaClosed into vcusid, vClosedate from xxi."cda" cda where cda.NCDAAGRID=p_nagrid and rownum=1;
     RETURN nSumOver+get_sum_rem_new(p_nagrid, vcusid, vClosedate, p_date);
     --<< ubrr Арсланов Д.Ф. 15-303 Изменен расчет сумм для безнадежных ссуд

   END;
/*5 – Счет просрочки
6 – Счет просроченных %
13 – Внебалансовый счет учета просроченных %
113 – Внебалансовый счет учета просроченных % на просроченные средства
40 – Счет учета накопленной комиссии
106 – Счет просроченных % на просроченные средства
*/
   FUNCTION IsContEveryMonthPay
    ( p_nagrid IN cda.ncdaagrid%TYPE)
   RETURN NUMBER
   IS
     IsEveryMonthpay NUMBER :=0;
     i_Cnt NUMBER;
     d_MaxD DATE;
 -->>-- 14-838
     IsEveryQuarterpay NUMBER :=0;
     IsEveryHalfYearpay NUMBER :=0;
     IsEveryYearpay NUMBER :=0;
 --<<-- 14-838
   BEGIN
     SELECT CASE WHEN count(*)/
                      decode(
                             round(months_between(max(dcdrdate), min(dcdrdate))),
                             0,
                             1,
                             round(months_between(max(dcdrdate), min(dcdrdate)))
                            )<1
            THEN 0
            ELSE 1
            END
       INTO IsEveryMonthpay
       FROM cdr
       WHERE ncdragrid = p_nagrid;
-->>-- 14-838
     SELECT CASE WHEN count(*)*3/
                      decode(
                             round(months_between(max(dcdrdate), min(dcdrdate))),
                             0,
                             1,
                             round(months_between(max(dcdrdate), min(dcdrdate)))
                            )<1
            THEN 0
            ELSE 1
            END
       INTO IsEveryQuarterpay
       FROM cdr
       WHERE ncdragrid = p_nagrid;
     SELECT CASE WHEN count(*)*6/
                      decode(
                             round(months_between(max(dcdrdate), min(dcdrdate))),
                             0,
                             1,
                             round(months_between(max(dcdrdate), min(dcdrdate)))
                            )<1
            THEN 0
            ELSE 1
            END
       INTO IsEveryHalfYearpay
       FROM cdr
       WHERE ncdragrid = p_nagrid;
     SELECT CASE WHEN count(*)*12/
                      decode(
                             round(months_between(max(dcdrdate), min(dcdrdate))),
                             0,
                             1,
                             round(months_between(max(dcdrdate), min(dcdrdate)))
                            )<1
            THEN 0
            ELSE
            CASE WHEN count(*)*12/
                      decode(
                             round(months_between(max(dcdrdate), min(dcdrdate))),
                             0,
                             1,
                             round(months_between(max(dcdrdate), min(dcdrdate)))
                            )>1.5
            THEN 0
            ELSE 1
            END
            END
       INTO IsEveryYearpay
       FROM cdr
       WHERE ncdragrid = p_nagrid;
    IF IsEveryMonthpay = 1 then
       RETURN 3;
    ELSE
       IF IsEveryQuarterpay = 1 then
            RETURN 4;
       ELSE
            IF IsEveryHalfYearpay = 1 then
                RETURN 5;
            ELSE
                IF IsEveryYearpay = 1 then
                    RETURN 6;
                ELSE
                    return 0;
                END IF; --halfyear
            END IF; --halfyear
       END IF; --qurter
    END IF; --month
     --RETURN IsEveryMonthpay;
--<<-- 14-838
   EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
   END;

   FUNCTION getContPeriodPayPerc
    ( p_nagrid IN cda.ncdaagrid%TYPE,
      p_date DATE)
   RETURN NUMBER
   IS
     iPeriod NUMBER := 7;
     --n_AgrId cda.ncdaagrid%TYPE := p_nagrid; --12.05.2021  зеленко с.а      dkbpa-845
     --i_Cnt NUMBER;   --12.05.2021  зеленко с.а      dkbpa-845
     d_MaxD DATE;
   BEGIN
     -->>12.05.2021  зеленко с.а      dkbpa-845
     /*
     IF trunc(p_nagrid)<>p_nagrid THEN
       -- Если в p_date было погашение или перевод на просрочку % по материнскому договору, то берем график по нему
       SELECT COUNT(*)
       INTO i_Cnt
       FROM cde
       WHERE cde.ncdeagrid=trunc(p_nagrid) AND cde.dcdedate<=p_date AND
             cde.icdetype IN (3, 73, 173);
       IF i_Cnt>0 THEN
         n_AgrId := trunc(p_nagrid);
       END IF;
       -- Иначе - по переданному номер договору
     END IF;
     SELECT MAX(CDS.DCDSINTPMTDATE)
     INTO d_MaxD
     FROM CDS WHERE CDS.NCDSAGRID=n_AgrId;
     */
     SELECT MAX(CDS.DCDSINTPMTDATE)
     INTO d_MaxD
     FROM CDS WHERE CDS.NCDSAGRID = p_nagrid;
     --<<12.05.2021  зеленко с.а      dkbpa-845
     IF d_maxD IS NULL THEN
       RETURN iPeriod;
     END IF;
     SELECT DECODE(CNT/decode(CNT1,0,1,CNT1),1,3,3,4,7)
     INTO iPeriod
     FROM
       ( SELECT DECODE(SUM(CNT),1,1,SUM(DECODE(MMM,MAXMMM,0,CNT))) CNT
               ,DECODE(SUM(CNT),1,1,SUM(DECODE(MMM,MAXMMM,0,1 ) ) ) CNT1
         FROM (
           SELECT TRUNC(CDs.DCDSINTPMTDATE,'MONTH') MMM, COUNT(*)CNT
                  ,MAX(TRUNC(CDs.DCDSINTPMTDATE,'MONTH')) OVER() MAXMMM
           FROM CDS WHERE CDS.NCDSAGRID=p_nAgrid
           GROUP BY TRUNC(CDS.DCDSINTPMTDATE,'MONTH')
         )
       );
     RETURN iPeriod;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN iPeriod;
  END;

  FUNCTION GetSumByCont
   ( p_nagrid IN cda.ncdaagrid%TYPE,
     p_date DATE)
  RETURN NUMBER
  IS
    nSumCont NUMBER:=0;
    vcusid number;
    vCloseDate DATE;
  BEGIN
    nSumCont:=
              NVL(CDBALANCE.get_CurSaldo(p_nagrid,1,null,null,p_date),0)+   --Ссудный счет
              NVL(CDBALANCE.get_CurSaldo(p_nagrid,5,null,null,p_date),0)+   --Счет просрочки
              NVL(CDBALANCE.get_CurSaldo(p_nagrid,10,null,null,p_date),0)+  --Счет требований банка
              NVL(CDBALANCE.get_CurSaldo(p_nagrid,6,null,null,p_date),0)+   --Счет просроченных %
              NVL(CDBALANCE.get_CurSaldo(p_nagrid,13,null,null,p_date),0)+  --Внебалансовый счет учета просроченных %
              NVL(CDBALANCE.get_CurSaldo(p_nagrid,101,null,null,p_date),0)+ --Счет требований банка на % на просроченные средства
              NVL(CDBALANCE.get_CurSaldo(p_nagrid,106,null,null,p_date),0)+ --Счет просроченных % на просроченные средства
              NVL(CDBALANCE.get_CurSaldo(p_nagrid,113,null,null,p_date),0)+ --Внебалансовый счет учета просроченных % на просроченные средства
              NVL(CDBALANCE.get_CurSaldo(p_nagrid,25,null,null,p_date),0)+  --Счет накопленных пеней на средства
              NVL(CDBALANCE.get_CurSaldo(p_nagrid,26,null,null,p_date),0)+  --Счет накопленных пеней на %
              NVL(CDBALANCE.get_CurSaldo(p_nagrid,27,null,null,p_date),0)+  --Внебалансовый счет накопленных пеней на средства
              NVL(CDBALANCE.get_CurSaldo(p_nagrid,28,null,null,p_date),0)+  --Начисление накопленных пеней на % на в/б
              NVL(CDBALANCE.get_CurSaldo(p_nagrid,126,null,null,p_date),0)+ --Счет накопленных пеней на % на просроченные средства
--UBRR Салахеев Р.Р. 14-838   NVL(CDBALANCE.get_CurSaldo(p_nagrid,40,null,null,p_date),0)+  --Счет учета накопленной комиссии
--UBRR Салахеев Р.Р. 14-838   NVL(CDBALANCE.get_CurSaldo(p_nagrid,41,null,null,p_date) ,0)  --Внебалансовый счет учета накопленных комиссий
    0;
     -->> ubrr Арсланов Д.Ф. 15-303 Изменен расчет сумм для безнадежных ссуд
        select cda.ICDACLIENT, cda.dcdaClosed into vcusid, vClosedate from xxi."cda" cda where cda.NCDAAGRID=p_nagrid and rownum=1;
     RETURN nSumCont+get_sum_rem_new(p_nagrid, vcusid, vClosedate, p_date);
    --<< ubrr Арсланов Д.Ф. 15-303 Изменен расчет сумм для безнадежных ссуд

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;
--UBRR Салахеев Р.Р. 14-838
function cdeisRemed(pIEVENTID number)return number is
  iIsRemed integer;
BEGIN
 SELECT 1
 INTO iIsRemed
 FROM DUAL WHERE EXISTS (
   SELECT 1 FROM cde cde1
   WHERE cde1.icdetype=12
     AND cde1.icdeeventid=pIEVENTID
     AND exists (SELECT 1 FROM cde cde2, gtr g
                 WHERE cde2.ncdeagrid=cde1.ncdeagrid
                   AND cde2.dcdedate=cde1.dcdedate
                   AND cde2.icdetype=54
                   AND cde2.icdetrnnum=g.igtrtrnnum
                   AND cde2.icdetrnanum=g.igtrtrnanum
                   AND g.igtrcat=808
                   AND g.igtrnum=34
                 )
 );
 RETURN iIsRemed; -- Нашли списание безнадежной задолженности
EXCEPTION
 WHEN OTHERS THEN
 BEGIN
   SELECT 1
   INTO iIsRemed
   FROM DUAL WHERE EXISTS (
     SELECT 1 FROM cde cde1, trn t
     WHERE cde1.icdeeventid=pIEVENTID
       AND cde1.icdetype IN (82, 182)
       AND cde1.icdetrnnum=t.itrnnum
       AND cde1.icdetrnanum=t.itrnanum
       AND (t.ctrnaccd like '917%' or t.ctrnaccd like '918%')
   );
   RETURN iIsRemed;
 EXCEPTION
   WHEN OTHERS THEN
     RETURN 0;
 END;
END;

function get_sum_rem(pcusid number,pd date)return number is
rez number;
begin
select nvl(sum(xXi.Util_Dm2.Acc_Ostt(null,caccacc, cacccur, pd+1, 'V', 1, 'TRUE', idsmr)),0) into rez
from ubrr_acc_v acc where acc.IACCCUS=pcusid and regexp_like(caccacc,'^(916|917|918)') and pd between acc.DACCOPEN and acc.DACCCLOSE;
return rez;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
end;

-->>-- 14-1398
function Get_name
    (p_cusid number, p_id number)
    return VARCHAR2 is
    cl_name varchar2(30);
    vClCat number := 4;
    cv_family   VARCHAR2(64);
    cv_fname    VARCHAR2(30);
    cv_mname    VARCHAR2(30);
begin
    cl_name := '';
    vClCat := CDTERMS2.get_catcli(p_cusid,15);
    select
            decode(
            vClCat, 4,
                --nvl(
                nvl(ccusfamily1,
                decode(UPPER(substr(CCUSNAME,1,31)), 'ИНДИВИДУАЛЬНЫЙ ПРЕДПРИНИМАТЕЛЬ ', substr(ccusname, 32, INSTR(substr(ccusname, 32),' ')-1))),
                --ccusfamily1,
                SUBSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(ccusname),1,INSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(ccusname),' ')-1)
            ),
            decode (
            vClCat, 4,
                nvl(ccusfname1,
                --decode(UPPER(substr(CCUSNAME,1,31)), 'ИНДИВИДУАЛЬНЫЙ ПРЕДПРИНИМАТЕЛЬ ', substr(substr(ccusname, 33), INSTR(substr(ccusname, 33), ' ')+1, INSTR(substr(ccusname, 33),' ',1,2)-INSTR(substr(ccusname, 33),' ')-1))),
                decode(UPPER(substr(CCUSNAME,1,31)), 'ИНДИВИДУАЛЬНЫЙ ПРЕДПРИНИМАТЕЛЬ ',
                substr(substr(ccusname, 32), INSTR(substr(ccusname, 32), ' ')+1, INSTR(substr(ccusname, 32),' ',1,2)-INSTR(substr(ccusname, 32),' ')))),
                SUBSTR(SUBSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(CCUSNAME),INSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(CCUSNAME),' ')+1 ,1000),1,
                INSTR( SUBSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(CCUSNAME),INSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(CCUSNAME),' ')+1 ,1000),' ')-1)
            ),
            decode (
            vClCat, 4,
                nvl(ccusmname1,
                --decode(UPPER(substr(CCUSNAME,1,31)), 'ИНДИВИДУАЛЬНЫЙ ПРЕДПРИНИМАТЕЛЬ ', substr(substr(ccusname, 34+INSTR(substr(ccusname, 33), ' ')), INSTR(substr(ccusname, 34+INSTR(substr(ccusname, 33), ' ')), ' ')+1, INSTR(substr(ccusname, 34+INSTR(substr(ccusname, 33), ' ')),' ',1,2)-INSTR(substr(ccusname, 34+INSTR(substr(ccusname, 33), ' ')),' ')-1))),
                decode(UPPER(substr(CCUSNAME,1,31)), 'ИНДИВИДУАЛЬНЫЙ ПРЕДПРИНИМАТЕЛЬ ',
                substr(substr(ccusname, 32), INSTR(substr(ccusname, 32), ' ',1,2)+1))),
                SUBSTR(SUBSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(CCUSNAME),INSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(CCUSNAME),' ')+1 ,1000),
                INSTR(SUBSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(CCUSNAME),INSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(CCUSNAME),' ')+1 ,1000),' ')+1 ,1000)
            )
        into cv_family, cv_fname, cv_mname
        from cus
        where icusnum = p_cusid;
    case p_id
        when 1 then
            cl_name := cv_family;
        when 2 then
            if cv_fname is null then
                cl_name := cv_mname;
            else
                cl_name := cv_fname;
            end if;
        when 3 then
            if cv_fname is null then
                cl_name := null;
            else
                cl_name := cv_mname;
            end if;
    end case;
/*    case
        when p_id = 1 -- Фамилия
        then
            select
                decode(
                vClCat, 4,
                    --nvl(
                    nvl(ccusfamily1,
                    decode(UPPER(substr(CCUSNAME,1,31)), 'ИНДИВИДУАЛЬНЫЙ ПРЕДПРИНИМАТЕЛЬ ', substr(ccusname, 32, INSTR(substr(ccusname, 32),' ')-1))),
                    --ccusfamily1,
                    SUBSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(ccusname),1,INSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(ccusname),' ')-1)
                )
            into cl_name
            from cus
            where icusnum = p_cusid;
        when p_id = 2 -- Имя
        then
            select
                decode (
                vClCat, 4,
                    nvl(ccusfname1,
                    --decode(UPPER(substr(CCUSNAME,1,31)), 'ИНДИВИДУАЛЬНЫЙ ПРЕДПРИНИМАТЕЛЬ ', substr(substr(ccusname, 33), INSTR(substr(ccusname, 33), ' ')+1, INSTR(substr(ccusname, 33),' ',1,2)-INSTR(substr(ccusname, 33),' ')-1))),
                    decode(UPPER(substr(CCUSNAME,1,31)), 'ИНДИВИДУАЛЬНЫЙ ПРЕДПРИНИМАТЕЛЬ ',
                    substr(substr(ccusname, 32), INSTR(substr(ccusname, 32), ' ')+1, INSTR(substr(ccusname, 32),' ',1,2)-INSTR(substr(ccusname, 32),' ')))),
                    SUBSTR(SUBSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(CCUSNAME),INSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(CCUSNAME),' ')+1 ,1000),1,
                    INSTR( SUBSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(CCUSNAME),INSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(CCUSNAME),' ')+1 ,1000),' ')-1)
                )
            into cl_name
            from cus
            where icusnum = p_cusid;
        when p_id = 3 -- Отчество
        then
            select
                decode (
                vClCat, 4,
                    nvl(ccusmname1,
                    --decode(UPPER(substr(CCUSNAME,1,31)), 'ИНДИВИДУАЛЬНЫЙ ПРЕДПРИНИМАТЕЛЬ ', substr(substr(ccusname, 34+INSTR(substr(ccusname, 33), ' ')), INSTR(substr(ccusname, 34+INSTR(substr(ccusname, 33), ' ')), ' ')+1, INSTR(substr(ccusname, 34+INSTR(substr(ccusname, 33), ' ')),' ',1,2)-INSTR(substr(ccusname, 34+INSTR(substr(ccusname, 33), ' ')),' ')-1))),
                    decode(UPPER(substr(CCUSNAME,1,31)), 'ИНДИВИДУАЛЬНЫЙ ПРЕДПРИНИМАТЕЛЬ ',
                    substr(substr(ccusname, 32), INSTR(substr(ccusname, 32), ' ',1,2)+1))),
                    SUBSTR(SUBSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(CCUSNAME),INSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(CCUSNAME),' ')+1 ,1000),
                    INSTR(SUBSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(CCUSNAME),INSTR(UBRR_LIV_CD_UTIL.get_true_CliName_ip(CCUSNAME),' ')+1 ,1000),' ')+1 ,1000)
                )
            into cl_name
            from cus
            where icusnum = p_cusid;
            --decode(UPPER(substr(CCUSNAME,1,31)), 'ИНДИВИДУАЛЬНЫЙ ПРЕДПРИНИМАТЕЛЬ ', substr(substr(ccusname, 34+INSTR(substr(ccusname, 33), ' ')), INSTR(substr(ccusname, 34+INSTR(substr(ccusname, 33), ' ')), ' ')+1, INSTR(substr(ccusname, 34+INSTR(substr(ccusname, 33), ' ')),' ',1,2)-INSTR(substr(ccusname, 34+INSTR(substr(ccusname, 33), ' ')),' ')-1))
    end case;*/
    --dbms_output.put_line(cl_name);
    cl_name := INITcap(cl_name);
    return cl_name;
    EXCEPTION
    WHEN OTHERS THEN
        RETURN '';
end Get_name;
--<<-- 14-1398

-->>-- 15-18
-- Расчет полной стоимости кредита
function Get_ACCs
    (p_Agrid number)
    return number is
    --PRAGMA AUTONOMOUS_TRANSACTION;
    vSum number := 0;

    vDateStarted date;
    v_current_sysdate date := CD.GET_LSDate;
begin
    /*
    begin
    dbms_output.disable;
    CDinterest.recalc_interest(p_Agrid, 'T', Do_Commit => FALSE, Generate_Details => FALSE, Generate_End_Month => FALSE);
    CDComms.Recalc_Comms (p_Agrid, 'T');
    select
    sum(smPay) into vSum
    from
    (select
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
    group by  dog, dat)
    where dog = P_Agrid;
    end;
*/
    -->> ubrr 01.10.2019  Ризанов Р.Т.  [19-59626] Разработка НБКИ - TUTDF версии 4.10.
    select s.pcdhpval
      into vSum
      from ( select h.pcdhpval --mcdhmval --<<< Рохин Е.А. 28.05.2015 #22087 [15-199] 353-ФЗ. Доработка расчета ПСК
                   ,row_number() over ( partition by trunc(h.ncdhagrid) order by h.dcdhdate desc, h.dcdhedit desc) rn
               from cdh h
              where trunc(h.ncdhagrid) = p_Agrid
                AND ccdhterm = 'UBRRPSK'
           ) s
     where s.rn=1;
    --<< ubrr 01.10.2019  Ризанов Р.Т.  [19-59626] Разработка НБКИ - TUTDF версии 4.10.

    return vSum;
    EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line(SQLERRM);
        RETURN 0;
end Get_ACCs;

-->> 17.06.2021  Пинаев Д.Е.      DKBPA-1434   Выпуск формата передачи данных в НБКИ - TUTDF 8.0 с 19.07.2021
-- Полная стоимость кредита, в денежном выражении
function Get_ACCs_money
    (p_Agrid number)
    return number is
    vSum number := 0;
    vDateStarted date;
    v_current_sysdate date := CD.GET_LSDate;
begin

    select s.mcdhmval
      into vSum
      from ( select h.mcdhmval
                   ,row_number() over ( partition by trunc(h.ncdhagrid) order by h.dcdhdate desc, h.dcdhedit desc) rn
               from cdh h
              where trunc(h.ncdhagrid) = p_Agrid
                AND ccdhterm = 'UBRRPSK'
           ) s
     where s.rn=1;

    return vSum;
    EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
end Get_ACCs_money;
--<< 17.06.2021  Пинаев Д.Е.      DKBPA-1434   Выпуск формата передачи данных в НБКИ - TUTDF 8.0 с 19.07.2021


-- Отношение Клиента к договору
function Get_ClType
    (p_Client number, p_Agrid number)
    return number is
    vClType number := 0;
    vClNum number := 0;
begin
    select ttype into vClType
    from
        (select
            icdaclient clNum,
            1 ttype
        from cda
        where trunc(ncdaagrid) = p_Agrid
        union all
        select distinct
            ICPOZCUSNUM clNum,
            2 ttype
        from czo, cpoz
        where nczoczv = 225 and cpoz.icpo = czo.nczoporuch and trunc(nczoagrid) = p_Agrid
        )
    where
        clNum = p_Client ;
    dbms_output.enable;
    dbms_output.put_line('vClType = ' || vClType);
    return vClType;
    EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
end Get_ClType;

-- Разные свойства Поручительств кредитного договора
function Get_InfoPoruch (
    p in number,
    p_Agrid in number,
    p_Client in number default null,
    p_date in date default CD.GET_LSDate,
    p_d353 in date default to_date('01.02.2015', 'dd.mm.yyyy'))
    return number is
    vReturn number := 0;
    vSum number := 0;
begin
    case
        when p = 1 -- Наличие Поручителей у Заемщика
        then
        begin
            select distinct
                sum(nczhsumma) into vSum
            from
                (select distinct
                    iczo,
                    nczoczv,
                    nczoagrid,
                    nczoporuch,
                    ICPOZCUSNUM,
                    cczoschet,
                    dczhdate,
                    nczhsumma,
                    cczocomment,
                    min(dczhdate) over (partition by trunc(nczhczo)) min_dczhdate,
                    max(dczhdate) over (partition by trunc(nczhczo)) max_dczhdate
                from
                    czo, czh, cpoz
                where
                    nczhczo = iczo
                    and nczoczv = 225
                    and cpoz.icpo = czo.nczoporuch
                    and nczoagrid = p_Agrid
                    and dczhdate <= p_date
                )
            where
                min_dczhdate >= p_d353
                and max_dczhdate <= p_date
                and dczhdate = max_dczhdate;

            if vSum > 0 then vReturn := 1;
            end if;
        end;
        when p = 2 -- Расчет суммы поручительства по Заемщику или Поручителю
        then
        begin
            select distinct
                sum(nczhsumma) into vSum
            from
                (select distinct
                    iczo,
                    nczoczv,
                    nczoagrid,
                    nczoporuch,
                    ICPOZCUSNUM,
                    cczoschet,
                    dczhdate,
                    nczhsumma,
                    cczocomment,
                    min(dczhdate) over (partition by trunc(nczhczo)) min_dczhdate,
                    max(dczhdate) over (partition by trunc(nczhczo)) max_dczhdate
                from
                    czo, czh, cpoz
                where
                    nczhczo = iczo
                    and nczoczv = 225
                    and cpoz.icpo = czo.nczoporuch
                    and nczoagrid = p_Agrid
                    and (ICPOZCUSNUM = p_Client or p_client is null)
                    and dczhdate <= p_date
                )
            where
                min_dczhdate >= p_d353
                and max_dczhdate <= p_date
                and dczhdate = max_dczhdate;
            vReturn := vSum;
        end;
    end case;
    return vReturn;
    EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
end Get_InfoPoruch;

--<<-- 15-18

   -->> ubrr Арсланов Д.Ф. 15-303 Функция возвращает дату последней проводки по погашению по счетам 91704, 91802, 91803 по безнадежным
   function Get_PayOff_Remed_Date
     (p_nagrid IN cda.ncdaagrid%TYPE,
      p_date in date,
      p_edate in date
     ) return date
   is
     vDate DATE;
     vDateE DATE;
   BEGIN
     vDateE := nvl(p_edate, to_date('19000102', 'YYYYMMDD'));
     SELECT MAX(trunc(dtrntran))
     INTO vDate
     from trn
     where dtrntran between vDateE and p_date+1-1/86400
       and ctrnaccc in
         (select caccacc
          from cda, acc
          where ncdaagrid = p_nagrid
            and iacccus = icdaclient
            and iaccbs2 in (91704, 91802, 91803)
            -->>12.05.2021  зеленко с.а      dkbpa-845
            --and caccacc like '%'||Trunc(p_nagrid)
            and (caccacc like '%'||Trunc(p_nagrid)
                or
                exists( select 1
                         from xxi.cdh_doc a
                        where a.ncdhagrid = cda.ncdaagrid
                          and instr(a.ccdhatribut,acc.CACCSIO) > 0
                       )
                )
            --<<12.05.2021  зеленко с.а      dkbpa-845
         );

      vDate := NVL(vDate, vDateE);
      RETURN vDate;
   exception
     WHEN OTHERS THEN
       RETURN vDateE;
   END;
   -->> ubrr Арсланов Д.Ф. 15-303
   -->> ubrr Рохин Е.А. 16-2520.11 Удаление лишних данных
   function Del_PersDataFL
    (pcusid number) return number
   is v_cus         xxi.cus%rowtype;
      v_NeedToDel   boolean := false;
      v_res         number  := 0;
      v_err         varchar2(2000);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN -- ubrr_data.ubrr_vuz_fiz_lica
        begin
            select distinct c.*
                into v_cus
                from xxi.cus c, ubrr_data.ubrr_vuz_fiz_lica t
                where c.icusnum = pcusid
                and   c.icusnum = t.icusnum;
            if v_cus.ccuspassp_ser   is not null and
               v_cus.ccuspassp_num   is not null and
               v_cus.ccuspassp_place is not null and
               v_cus.dcuspassp       is not null
            then
                v_NeedToDel := true;
            else
                v_NeedToDel := false;
            end if;
        exception
            when no_data_found then
                v_NeedToDel := false;
        end;
        if v_NeedToDel then
            delete from ubrr_data.ubrr_vuz_fiz_lica where icusnum = pcusid;
            commit;
            v_res := 1;
        else
            v_res := 0;
        end if;
        return v_res;
   exception
        when others then
            begin
                v_err := to_char(pcusid)||' '||substr(sqlerrm, 1,2000);
                rollback;
                insert into cap(ccapmessage) values(v_err);
                commit;
                return -1;
            end;
   END;

   function Del_PersDataUL
    (pcusid number) return number
   is v_cus         xxi.cus%rowtype;
      v_NeedToDel   boolean := false;
      v_res         number  := 0;
      v_resident    number  := 1;
      v_err         varchar2(2000);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN -- ubrr_vuz_yur_lica
        begin
            select igcsnum
                into v_resident
                from xxi.gcs
                where igcscus = pcusid
                and   igcscat = 7;
        exception when no_data_found then v_resident := 1;
        end;
        begin
            select distinct c.*
                into v_cus
                from xxi.cus c, ubrr_data.ubrr_vuz_yur_lica t
                where c.icusnum = pcusid
                and   c.icusnum = t.icusnum;
            if ( (v_resident = 1 and v_cus.ccusnumnal   is not null)or
                 (v_resident = 0 and (v_cus.ccusnumnal   is not null or v_cus.ccusiin is not null))
               ) and
               v_cus.ccusksiva    is not null
            then
                v_NeedToDel := true;
            else
                v_NeedToDel := false;
            end if;
        exception
            when no_data_found then
                v_NeedToDel := false;
        end;
        if v_NeedToDel then
            delete from ubrr_data.ubrr_vuz_yur_lica where icusnum = pcusid;
            commit;
            v_res := 1;
        else
            v_res := 0;
        end if;
        return v_res;
   exception
        when others then
            begin
                v_err := to_char(pcusid)||' '||substr(sqlerrm, 1,2000);
                rollback;
                insert into cap(ccapmessage) values(v_err);
                commit;
                return -1;
            end;
   END;

   function Del_Address
    (pcusid number) return number
   is v_cus         xxi.cus%rowtype;
      v_NeedToDel   boolean := false;
      v_res         number  := 0;
      v_err         varchar2(2000);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN -- ubrr_vuz_adresses_fiz_lica
        begin
            select distinct c.*
                into v_cus
                from xxi.cus c, ubrr_data.ubrr_vuz_adresses_fiz_lica t
                where c.icusnum = pcusid
                and   c.icusnum = t.icusnum;
            if (v_cus.CCUSADDR_CITY  is not null or
                v_cus.CCUSADDR_PUNCT is not null)   and
               v_cus.CCUSADDR_STREET is not null    and
               (v_cus.CCUSADDR_DOM   is not null or
                v_cus.CCUSADDR_KORP  is not null or
                v_cus.CCUSADDR_KV    is not null)     and
               (v_cus.CCUSADDR_PHIS_CITY  is not null or
                v_cus.CCUSADDR_PHIS_PUNCT is not null)   and
               v_cus.CCUSADDR_PHIS_STREET is not null    and
               (v_cus.CCUSADDR_PHIS_DOM   is not null or
                v_cus.CCUSADDR_PHIS_KORP  is not null or
                v_cus.CCUSADDR_PHIS_KV    is not null)
            then
                v_NeedToDel := true;
            else
                v_NeedToDel := false;
            end if;
        exception
            when no_data_found then
                v_NeedToDel := false;
        end;
        if v_NeedToDel then
            delete from ubrr_data.ubrr_vuz_adresses_fiz_lica where icusnum = pcusid;
            commit;
            v_res := 1;
        else
            v_res := 0;
        end if;
        return v_res;
   exception
        when others then
            begin
                v_err := to_char(pcusid)||' '||substr(sqlerrm, 1,2000);
                rollback;
                insert into cap(ccapmessage) values(v_err);
                commit;
                return -1;
            end;
   END;
   --<< ubrr Рохин Е.А. 16-2520.11 Удаление лишних данных

   -- >> ubrr 01.10.2019  Ризанов Р.Т.  [19-59626] Разработка НБКИ - TUTDF версии 4.10.
   -- округление суммы по определенному требованию
   function round_sum_bki( p_val in number )
   return number
   is
      l_ret number;
   begin
       if p_val is null then
          return null;
       end if;

       if ( p_val > 0 and p_val < 1 ) then
          l_ret:=1;
       elsif ( p_val > 9999999999) then
          l_ret:= 9999999999;
       else
          l_ret:=round(p_val);
       end if;

       return l_ret;
   end round_sum_bki;
   -- << ubrr 01.10.2019  Ризанов Р.Т.  [19-59626] Разработка НБКИ - TUTDF версии 4.10.

   -->>ubrr 06.06.2020  Арсланов Д.Ф. [20-74056]  Доработка отчета в НБКИ 7.01 (льготный период)

   -- Строка "Фактически начался льготный период"
   function get_row_for_begin_LP (p_Agrid number, p_date date, p_creason varchar2 default null)
   return ubrr_data.ubrr_cdh_info%rowtype
   is
     r_ubrr_cdh_info  ubrr_data.ubrr_cdh_info%rowtype;
   begin
     for rec in
       ( select *
           from ubrr_data.ubrr_cdh_info
          where ncdhagrid >= trunc(p_Agrid)
            and ncdhagrid < p_Agrid + 1
            and dcdhdate  = p_date
            and (     p_creason is null
                  and creason_ds in ('01', '02', '03')
                   or creason_ds = p_creason
                )
       )
     loop
       r_ubrr_cdh_info := rec;
       exit;

     end loop;
     return r_ubrr_cdh_info;

   end get_row_for_begin_LP;

   -- Строка "Фактически закончился льготный период"
   function get_row_for_end_LP (p_Agrid number, p_date date)
   return ubrr_data.ubrr_cdh_info%rowtype
   is
     r_ubrr_cdh_info  ubrr_data.ubrr_cdh_info%rowtype;
   begin
     for rec in
       ( select *
           from ubrr_data.ubrr_cdh_info
         where ncdhagrid >= trunc(p_Agrid)
            and ncdhagrid < p_Agrid + 1
            and ddat_okon_fact_ds  = p_date
            and creason_ds in ('02', '03')
            and nvl(ccause_okon_ds,'??????') not in ('04')
       )
     loop
       r_ubrr_cdh_info := rec;
       exit;

     end loop;
     return r_ubrr_cdh_info;

   end get_row_for_end_LP;

   -- Строка "Фактически непредоставлен/не подтвержден льготный период"
   function get_row_for_noset_LP (p_Agrid number, p_date date)
   return ubrr_data.ubrr_cdh_info%rowtype
   is
     r_ubrr_cdh_info  ubrr_data.ubrr_cdh_info%rowtype;
   begin
     for rec in
       ( select *
           from ubrr_data.ubrr_cdh_info
          where ncdhagrid >= trunc(p_Agrid)
            and ncdhagrid < p_Agrid + 1
            and ddat_noset_lp  = p_date
            and creason_ds in ('02')
            and nvl(ccause_okon_ds,'??????') in ('04')
       )
     loop
       r_ubrr_cdh_info := rec;
       exit;

     end loop;
     return r_ubrr_cdh_info;

   end get_row_for_noset_LP;

   -- Сегмент TR Поле 49 "Дата окончания льготного периода"
   function get_TR_Field_V49 (p_Agrid number, p_date date)
   return varchar2
   is
     v_result varchar2(8);
   begin
     v_result := to_char(get_row_for_begin_LP(p_Agrid, p_date).ddat_okon, 'YYYYMMDD');
     if trunc(v_result) is null then
       v_result := to_char(get_row_for_end_LP(p_Agrid, p_date).ddat_okon_fact_ds, 'YYYYMMDD');
     end if;
     v_result := nvl(v_result, '        ');

     return v_result;

   end get_TR_Field_V49;

   -- Сегмент TR Поле 51 "Дата неподтверждения/неустановления льготного периода"
   function get_TR_Field_V51 (p_Agrid number, p_date date)
   return varchar2
   is
     v_result varchar2(8);
   begin
     v_result := to_char(get_row_for_noset_LP(p_Agrid, p_date).ddat_noset_lp, 'YYYYMMDD');
     v_result := nvl(v_result, '        ');

     return v_result;

   end get_TR_Field_V51;

   -- Сегмент TR Поле 52 "Основание установления льготного периода"
   function get_TR_Field_V52 (p_Agrid number, p_date date)
   return varchar2
   is
     v_result varchar2(2);
   begin
     v_result := get_row_for_begin_LP(p_Agrid, p_date).creason_ds;
     if v_result is null then
       v_result := get_row_for_begin_LP(p_Agrid, p_date, '04').creason_ds;
     end if;
     v_result := nvl(v_result, '  ');


     return v_result;

   end get_TR_Field_V52;

   -- Сегмент TR Поле 53 "Дата начала льготного периода"
   function get_TR_Field_V53 (p_Agrid number, p_date date)
   return varchar2
   is
     v_result varchar2(8) := '        ';
   begin
     v_result := to_char(get_row_for_begin_LP(p_Agrid, p_date).ddat_ds, 'YYYYMMDD');
     if trunc(v_result) is null then
       v_result := to_char(get_row_for_end_LP(p_Agrid, p_date).ddat_ds, 'YYYYMMDD');
     end if;
     if trunc(v_result) is null then
       v_result := to_char(get_row_for_noset_LP(p_Agrid, p_date).ddat_ds, 'YYYYMMDD');
     end if;
     v_result := nvl(v_result, '        ');

     return v_result;

   end get_TR_Field_V53;
   --<<ubrr 06.06.2020  Арсланов Д.Ф. [20-74056]  Доработка отчета в НБКИ 7.01 (льготный период)

-->>12.05.2021  Зеленко С.А      DKBPA-845
-------------------------------------------------------------------------------
-- Функция получения даты начала КД
-------------------------------------------------------------------------------
function get_agrid_datbeg(par_agrid in cda.ncdaagrid%type)
  return date
IS
  cursor cur_c0(p_agrid in cda.ncdaagrid%type) is
  select (CASE
          WHEN a.DCDASIGNDATE2 is not null THEN a.DCDASIGNDATE2
          WHEN a.DCDASIGNDATE >= a.DCDASTARTED THEN a.DCDASIGNDATE
          ELSE a.DCDASTARTED END)
   from CDA a
  where a.NCDAAGRID = p_agrid;

  l_d_ret  date;

BEGIN
  --найдем дату начала КД попробуем по пролонгации
  open cur_c0(par_agrid);
  fetch cur_c0 into l_d_ret;
  close cur_c0;

  return l_d_ret;
END get_agrid_datbeg;

-------------------------------------------------------------------------------
-- Функция получения даты окончания КД
-------------------------------------------------------------------------------
function get_agrid_datend(par_agrid in cda.ncdaagrid%type)
  return date
IS
  cursor cur_c1(p_agrid in cda.ncdaagrid%type) is
  select coalesce(a.DCDACLOSED,gc_far_date)
   from CDA a
  where a.NCDAAGRID = p_agrid;

  l_count_agrid  number := 0;
  l_d_ret        date;
  l_d_add        date; --02.06.2021  Зеленко С.А      DKBPA-1378

BEGIN
  --найдем дату окончания
  open cur_c1(par_agrid);
  fetch cur_c1 into l_d_ret;
  close cur_c1;
  
  -->>02.06.2021  Зеленко С.А      DKBPA-1378
  --КД «списанных за счет резерва» 
  IF l_d_ret <> gc_far_date and ubrr_xxi5.ubrr_isys_for_cd_bki_V7_05.isspisremed(p_nagrid => par_agrid, p_date => l_d_ret) = 1 THEN
    l_d_add := ADD_MONTHS( l_d_ret, 60);
    l_d_ret := least(l_d_add, nvl(ubrr_xxi5.ubrr_isys_for_cd_bki_V7_05.get_date_isremed(p_agrid => par_agrid ), l_d_add) );    
  END IF;
  --<<02.06.2021  Зеленко С.А      DKBPA-1378

  return l_d_ret;
END get_agrid_datend;

-------------------------------------------------------------------------------
-- Процедура расчета ежемесячных дат (700100180011,700100180016)
-------------------------------------------------------------------------------
procedure Calc_Dat_Month_ListTable(p_p3  in varchar2,
                                   p_p9  in varchar2,
                                   p_p10 in varchar2
                                  )
  is
  pragma autonomous_transaction;
  type t_Table is Table of UBRR_DATA.UBRR_CD_BKI_DAT_GTT%ROWTYPE index by binary_integer;
  tListZaem t_Table;
  tListPoruch t_Table;
  tListGaran t_Table;
  tListDate t_Table;

  cursor cur_zaem(par_p3 varchar2, par_p10 in varchar2) is
  SELECT CDA.NCDAAGRID,
         null as date_mm,
         ubrr_xxi5.ubrr_isys_for_cd_bki_V7_05.get_agrid_datbeg(par_agrid => CDA.NCDAAGRID) as datbeg,
         ubrr_xxi5.ubrr_isys_for_cd_bki_V7_05.get_agrid_datend(par_agrid => CDA.NCDAAGRID) as datend,
         null as caccacc,
         null as ipozcusnum,
         null as ctype
    FROM /*CDA*/ v_ubrr_cda_of_nbki CDA --02.06.2021  Зеленко С.А      DKBPA-1378
   WHERE EXISTS (select 1
                   from ubrr_cd_uid_20_78770 t
                  where trunc(t.ncdaagrid)=trunc(CDA.NCDAAGRID)
                    and t.set_code = par_p10
                 )
     AND (par_p3 = 0 OR par_p3 = 1);

  cursor cur_poruch(par_p3 varchar2, par_p10 in varchar2) is
  select NCZOAGRID as ncdaagrid,
         null as date_mm,
         /*MIN_CZHDATE*/ GREATEST(MIN_CZHDATE,ubrr_xxi5.ubrr_isys_for_cd_bki_v7_05.get_agrid_datbeg(par_agrid => NCZOAGRID)) as datbeg, --02.06.2021  Зеленко С.А      DKBPA-1378
         coalesce(( select MIN(DCZHDATE)
                     from CZH 
                     where CZH.NCZHCZO=ICZO AND CZH.NCZHSUMMA=0 AND CZH.DCZHDATE>MIN_CZHDATE),
                    ubrr_xxi5.ubrr_isys_for_cd_bki_V7_05.get_agrid_datend(par_agrid => NCZOAGRID) 
                  ) as datend,
        null as caccacc,
        ICPOZCUSNUM as ipozcusnum,
        null as ctype
  from
  (
   SELECT NCZOAGRID,
          ICPOZCUSNUM,
          CZO.ICZO,
          (select MIN(DCZHDATE) FROM CZH WHERE CZH.NCZHCZO=CZO.ICZO AND CZH.NCZHSUMMA>0) MIN_CZHDATE
      FROM CZO, CPOZ
     WHERE NCZOCZV = 225
      AND CZO.NCZOPORUCH = CPOZ.ICPO
      AND exists (
                  select 1
                    from ubrr_czo_uid_20_78770 t
                   where trunc(t.nczoagrid)=trunc(CZO.NCZOAGRID)
                     and t.nczoporuch=CZO.NCZOPORUCH
                     and t.set_code = par_p10
                  )
      -->>02.06.2021  Зеленко С.А      DKBPA-1378)
      AND exists (select 1 
                    from v_ubrr_cda_of_nbki CDA
                   where CDA.NCDAAGRID = CZO.NCZOAGRID
                  ) 
      --<<02.06.2021  Зеленко С.А      DKBPA-1378)
      AND (par_p3 = 0 OR par_p3 = 1 OR par_p3 = 2)
  );

  cursor cur_garan(par_p3 varchar2, par_p10 in varchar2) is
  SELECT null as ncdaagrid,
         null as date_mm,
         (select min(DTRNTRAN) from TRN where (CTRNACCD = CACCACC OR CTRNACCC = CACCACC) AND MTRNSUM <> 0 and itrntype >= 0  ) as datbeg,
         (case when CACCPRIZN='З' then (select max(DTRNTRAN) from TRN where (CTRNACCD = CACCACC OR CTRNACCC = CACCACC) AND MTRNSUM <> 0 and itrntype >= 0  ) else DDDCDATE end) as datend,
         CACCACC as caccacc,
         null as ipozcusnum,
         null as ctype
    FROM ACC, DDC
   WHERE IACCBS2 = 91315
     AND IACCCUS <> 0
     AND CDDCACC = CACCACC
     AND CACCCUR = CDDCCUR
     AND DDC.IDSMR = ACC.IDSMR
     AND UPPER(CACCNAME) LIKE '%ГАРАНТИЯ%'
     AND (par_p3 = 3 OR par_p3 = 0)
     AND ubrr_xxi6.ubrr_sap_la.acc_in_290920_list@ABS6(CACCACC, par_p10) = 1
     AND EXISTS ( SELECT 1
                    FROM GCS
                   WHERE GCS.IGCSCUS = ACC.IACCCUS
                     AND IGCSCAT = 15
                     AND IGCSNUM IN (2, 4));

  cursor cur_dat(par_agrid CDA.NCDAAGRID%type, par_datbeg date, par_datend date, par_caccacc varchar2, par_ipozcusnum number, par_ctype varchar2, par_p9 varchar2) is
  select ncdaagrid, date_mm, datbeg, datend, caccacc, ipozcusnum, ctype
    from
   (
   with dat_kd as ( SELECT trunc(par_datbeg) as datbeg,
                           trunc(par_datend) as datend,
                           par_agrid  as ncdaagrid,
                           par_caccacc as caccacc,
                           par_ipozcusnum as ipozcusnum,
                           par_ctype as ctype
                      FROM dual
                   ),
        dat_conn as (select last_day(dat_kd.datbeg -1 + level) as date_mm,
                             dat_kd.datbeg,
                             dat_kd.datend,
                             dat_kd.ncdaagrid,
                             dat_kd.caccacc,
                             dat_kd.ipozcusnum,
                             dat_kd.ctype
                        from dat_kd
                      connect by level < ( decode(dat_kd.datend,gc_far_date,CD.get_lsdate,dat_kd.datend) - dat_kd.datbeg +1)
                      group by last_day(dat_kd.datbeg-1 + level), dat_kd.datbeg, dat_kd.datend, dat_kd.ncdaagrid, dat_kd.caccacc, dat_kd.ipozcusnum, dat_kd.ctype
                      order by 1),
        dat_end1 as (select CD.get_lsdate as date_mm,
                            dat_kd.datbeg,
                            dat_kd.datend,
                            dat_kd.ncdaagrid,
                            dat_kd.caccacc,
                            dat_kd.ipozcusnum,
                            dat_kd.ctype
                       from dat_kd
                      where dat_kd.datend > CD.get_lsdate--dat_kd.datend = gc_far_date
                    ),
        dat_end2 as (select dat_kd.datend as date_mm,
                            dat_kd.datbeg,
                            dat_kd.datend,
                            dat_kd.ncdaagrid,
                            dat_kd.caccacc,
                            dat_kd.ipozcusnum,
                            dat_kd.ctype
                       from dat_kd
                      where dat_kd.datend <= CD.get_lsdate  --dat_kd.datend != gc_far_date
                    ),
        dat_join as (select date_mm, datbeg, datend, ncdaagrid, caccacc, ipozcusnum, ctype from dat_conn where dat_conn.date_mm >= dat_conn.datbeg and dat_conn.date_mm < dat_conn.datend
                     union
                     select date_mm, datbeg, datend, ncdaagrid, caccacc, ipozcusnum, ctype from dat_end1
                     union
                     select date_mm, datbeg, datend, ncdaagrid, caccacc, ipozcusnum, ctype from dat_end2
                  )
    select ncdaagrid, date_mm, datbeg, datend, caccacc, ipozcusnum, ctype
      from dat_join

  )
  where date_mm between TO_DATE(par_p9,'dd.mm.yyyy') AND CD.get_lsdate
    and date_mm between datbeg and datend
  group by date_mm, datbeg, datend, ncdaagrid, caccacc, ipozcusnum, ctype
  order by date_mm;

BEGIN

  --очистим временную таблицу
  delete from UBRR_DATA.UBRR_CD_BKI_DAT_GTT;
  tListZaem.delete;
  tListPoruch.delete;
  tListGaran.delete;
  tListDate.delete;

  --проверим дату начало выгрузки и дату окончания выгрузки
  if TO_DATE(p_p9,'dd.mm.yyyy') <= CD.get_lsdate then

    --Заемщики
    open cur_zaem(p_p3,p_p10);
    fetch cur_zaem bulk collect into tListZaem;
    close cur_zaem;

    if tListZaem.count > 0 then
      for idx in tListZaem.first .. tListZaem.last
        loop
          --создаем периоды по заемщикам
          open cur_dat(tListZaem(idx).NAGRID, tListZaem(idx).datbeg, tListZaem(idx).datend, tListZaem(idx).caccacc, tListZaem(idx).ipozcusnum, 'Z', p_p9);
          fetch cur_dat bulk collect into tListDate;
          close cur_dat;

          if tListDate.count > 0 then
            --добавим данные во временную таблицу
            forall idx1 in tListDate.first .. tListDate.last
              insert into UBRR_DATA.UBRR_CD_BKI_DAT_GTT(NAGRID,
                                                        DATMM,
                                                        DATBEG,
                                                        DATEND,
                                                        CACCACC,
                                                        IPOZCUSNUM,
                                                        CTYPER)
                                                values (tListDate(idx1).NAGRID,
                                                        tListDate(idx1).DATMM,
                                                        tListDate(idx1).DATBEG,
                                                        tListDate(idx1).DATEND,
                                                        tListDate(idx1).CACCACC,
                                                        tListDate(idx1).IPOZCUSNUM,
                                                        tListDate(idx1).CTYPER
                                                        );
          end if;
          tListDate.delete;
        end loop;
        tListZaem.delete;
    end if;

    --Поручители
    open cur_poruch(p_p3,p_p10);
    fetch cur_poruch bulk collect into tListPoruch;
    close cur_poruch;

    if tListPoruch.count > 0 then
      for idx in tListPoruch.first .. tListPoruch.last
        loop
          --создаем периоды по поручителям
          open cur_dat(tListPoruch(idx).NAGRID, tListPoruch(idx).datbeg, tListPoruch(idx).datend, tListPoruch(idx).caccacc, tListPoruch(idx).ipozcusnum, 'P', p_p9);
          fetch cur_dat bulk collect into tListDate;
          close cur_dat;

          if tListDate.count > 0 then
            --добавим данные во временную таблицу
            forall idx1 in tListDate.first .. tListDate.last
              insert into UBRR_DATA.UBRR_CD_BKI_DAT_GTT(NAGRID,
                                                        DATMM,
                                                        DATBEG,
                                                        DATEND,
                                                        CACCACC,
                                                        IPOZCUSNUM,
                                                        CTYPER)
                                                values (tListDate(idx1).NAGRID,
                                                        tListDate(idx1).DATMM,
                                                        tListDate(idx1).DATBEG,
                                                        tListDate(idx1).DATEND,
                                                        tListDate(idx1).CACCACC,
                                                        tListDate(idx1).IPOZCUSNUM,
                                                        tListDate(idx1).CTYPER
                                                        );
          end if;
          tListDate.delete;
        end loop;
        tListPoruch.delete;
    end if;

    --Гарантии
    open cur_garan(p_p3,p_p10);
    fetch cur_garan bulk collect into tListGaran;
    close cur_garan;

    if tListGaran.count > 0 then
      for idx in tListGaran.first .. tListGaran.last
        loop
          --создаем периоды по поручителям
          open cur_dat(tListGaran(idx).NAGRID, tListGaran(idx).datbeg, tListGaran(idx).datend, tListGaran(idx).caccacc, tListGaran(idx).ipozcusnum, 'G', p_p9);
          fetch cur_dat bulk collect into tListDate;
          close cur_dat;

          if tListDate.count > 0 then
            --добавим данные во временную таблицу
            forall idx1 in tListDate.first .. tListDate.last
              insert into UBRR_DATA.UBRR_CD_BKI_DAT_GTT(NAGRID,
                                                        DATMM,
                                                        DATBEG,
                                                        DATEND,
                                                        CACCACC,
                                                        IPOZCUSNUM,
                                                        CTYPER)
                                                values (tListDate(idx1).NAGRID,
                                                        tListDate(idx1).DATMM,
                                                        tListDate(idx1).DATBEG,
                                                        tListDate(idx1).DATEND,
                                                        tListDate(idx1).CACCACC,
                                                        tListDate(idx1).IPOZCUSNUM,
                                                        tListDate(idx1).CTYPER
                                                        );
          end if;
          tListDate.delete;
        end loop;
        tListGaran.delete;
    end if;
  end if;
  commit;
  
EXCEPTION
  when OTHERS then
    rollback;
END Calc_Dat_Month_ListTable;

-------------------------------------------------------------------------------
-- Процедура расчета ежемесячных дат (700100170011)
-------------------------------------------------------------------------------
procedure Calc_Dat_Month_Table(p_p9 in varchar2
                              )
  is
  pragma autonomous_transaction;
  type t_Table is Table of UBRR_DATA.UBRR_CD_BKI_DAT_GTT%ROWTYPE index by binary_integer;
  tListZaem t_Table;
  tListDate t_Table;

  cursor cur_zaem(par_p9 varchar2) is
  select ncdaagrid,
         date_mm,
         datbeg,
         datend,
         caccacc,
         ipozcusnum,
         ctype
   from
    (
    SELECT CDA.NCDAAGRID,
           null as date_mm,
           ubrr_xxi5.ubrr_isys_for_cd_bki_V7_05.get_agrid_datbeg(par_agrid => CDA.NCDAAGRID) as datbeg,
           ubrr_xxi5.ubrr_isys_for_cd_bki_V7_05.get_agrid_datend(par_agrid => CDA.NCDAAGRID) as datend,
           null as caccacc,
           null as ipozcusnum,
           null as ctype
      FROM /*CDA*/ v_ubrr_cda_of_nbki CDA --02.06.2021  Зеленко С.А      DKBPA-1378
     WHERE icdastatus >= 2      
    )
   where datend >= last_day(to_date(par_p9,'dd.mm.yyyy'))
     and datbeg < to_date(par_p9,'dd.mm.yyyy');

  cursor cur_dat(par_agrid CDA.NCDAAGRID%type, par_datbeg date, par_datend date, par_caccacc varchar2, par_ipozcusnum number, par_ctype varchar2, par_p9 varchar2) is
  select ncdaagrid, date_mm, datbeg, datend, caccacc, ipozcusnum, ctype
    from
   (
   with dat_kd as ( SELECT trunc(par_datbeg) as datbeg,
                           trunc(par_datend) as datend,
                           par_agrid  as ncdaagrid,
                           par_caccacc as caccacc,
                           par_ipozcusnum as ipozcusnum,
                           par_ctype as ctype
                      FROM dual
                   ),
        dat_conn as (select last_day(dat_kd.datbeg -1 + level) as date_mm,
                             dat_kd.datbeg,
                             dat_kd.datend,
                             dat_kd.ncdaagrid,
                             dat_kd.caccacc,
                             dat_kd.ipozcusnum,
                             dat_kd.ctype
                        from dat_kd
                      connect by level < ( decode(dat_kd.datend,gc_far_date,CD.get_lsdate,dat_kd.datend) - dat_kd.datbeg +1)
                      group by last_day(dat_kd.datbeg-1 + level), dat_kd.datbeg, dat_kd.datend, dat_kd.ncdaagrid, dat_kd.caccacc, dat_kd.ipozcusnum, dat_kd.ctype
                      order by 1),
        dat_join as (select date_mm, datbeg, datend, ncdaagrid, caccacc, ipozcusnum, ctype
                       from dat_conn
                      where dat_conn.date_mm >= dat_conn.datbeg and dat_conn.date_mm < dat_conn.datend
                     union
                     select dat_kd.datend as date_mm, datbeg, datend, ncdaagrid, caccacc, ipozcusnum, ctype
                       from dat_kd
                      where dat_kd.datbeg = dat_kd.datend
                        and dat_kd.datend = last_day(dat_kd.datend)
                  )
    select ncdaagrid, date_mm, datbeg, datend, caccacc, ipozcusnum, ctype
      from dat_join

  )
  where date_mm between TO_DATE(par_p9,'dd.mm.yyyy') AND CD.get_lsdate
    and date_mm between datbeg and datend
  group by date_mm, datbeg, datend, ncdaagrid, caccacc, ipozcusnum, ctype
  order by date_mm;

BEGIN

  --очистим временную таблицу
  delete from UBRR_DATA.UBRR_CD_BKI_DAT_GTT;
  tListZaem.delete;
  tListDate.delete;

  --проверим дату начало выгрузки и дату окончания выгрузки
  if TO_DATE(p_p9,'dd.mm.yyyy') <= CD.get_lsdate then

    --Заемщики
    open cur_zaem(p_p9);
    fetch cur_zaem bulk collect into tListZaem;
    close cur_zaem;

    if tListZaem.count > 0 then
      for idx in tListZaem.first .. tListZaem.last
        loop
          --создаем периоды по заемщикам
          open cur_dat(tListZaem(idx).NAGRID, tListZaem(idx).datbeg, tListZaem(idx).datend, tListZaem(idx).caccacc, tListZaem(idx).ipozcusnum, 'Z', p_p9);
          fetch cur_dat bulk collect into tListDate;
          close cur_dat;

          if tListDate.count > 0 then
            --добавим данные во временную таблицу
            forall idx1 in tListDate.first .. tListDate.last
              insert into UBRR_DATA.UBRR_CD_BKI_DAT_GTT(NAGRID,
                                                        DATMM,
                                                        DATBEG,
                                                        DATEND,
                                                        CACCACC,
                                                        IPOZCUSNUM,
                                                        CTYPER)
                                                values (tListDate(idx1).NAGRID,
                                                        tListDate(idx1).DATMM,
                                                        tListDate(idx1).DATBEG,
                                                        tListDate(idx1).DATEND,
                                                        tListDate(idx1).CACCACC,
                                                        tListDate(idx1).IPOZCUSNUM,
                                                        tListDate(idx1).CTYPER
                                                        );
          end if;
          tListDate.delete;
        end loop;
        tListZaem.delete;
    end if;
  end if;
  commit;

EXCEPTION
  when OTHERS then
    rollback;
END Calc_Dat_Month_Table;

------------------------------------------------------------------------------------
-- Получить ранюю дату возникновения просроченнной задолженности на отчетную дату
------------------------------------------------------------------------------------
function get_date_prsr_of_agrid( p_agrID   in number,
                                 p_datprsr in date
                                )
  return date
  is
  cursor cur_c0( par_agrID number, par_datprsr date, par_datend date) is
  SELECT MIN(
            LEAST(
                  NVL(CDSTATE2.get_startprsr(CDA.ncdaagrid,CDQ.icdqpart,par_datprsr,'B'),par_datend),
                  NVL(CDSTATE2.get_startprsr(CDA.ncdaagrid,CDQ.icdqpart,par_datprsr,'N'),par_datend),
                  NVL(CDSTATE2.get_startprsr(CDA.ncdaagrid,CDQ.icdqpart,par_datprsr,'A'),par_datend),
                  NVL(CDSTATE2.get_startprsr(CDA.ncdaagrid,CDQ.icdqpart,par_datprsr,'C'),par_datend),
                  NVL(CDSTATE2.get_startprsr(CDA.ncdaagrid,CDQ.icdqpart,par_datprsr,'D'),par_datend),
                  NVL(CDSTATE2.get_startprsr(CDA.ncdaagrid,CDQ.icdqpart,par_datprsr,'E'),par_datend),
                  NVL(CDSTATE2.get_startprsr(CDA.ncdaagrid,CDQ.icdqpart,par_datprsr,'F'),par_datend),
                  NVL(CDSTATE2.get_startprsr(CDA.ncdaagrid,CDQ.icdqpart,par_datprsr,'H'),par_datend),
                  NVL(CDSTATE2.get_startprsr(CDA.ncdaagrid,CDQ.icdqpart,par_datprsr,'G'),par_datend)
                 )
              ) as l_date
    FROM CDA,CDQ
   WHERE ncdaagrid = par_agrID
     AND CDQ.ncdqagrid=CDA.ncdaagrid;
  l_dret    date;
begin
  open cur_c0(p_agrID, p_datprsr, gc_far_date);
  fetch cur_c0 into l_dret;
  close cur_c0;
  return l_dret;
end get_date_prsr_of_agrid;

------------------------------------------------------------------------------------
-- Получить значение своевременности платежа согласно количества дней просрочки
------------------------------------------------------------------------------------
function get_typesp_of_countday( p_countday in number )
  return varchar2
  is
  cursor cur_c0 ( par_countday in number) is
  select (CASE
          WHEN SIGN(par_countday)      = -1 THEN '1'
          WHEN SIGN(119 -par_countday) = -1 THEN '5'
          WHEN SIGN(89  -par_countday) = -1 THEN '4'
          WHEN SIGN(59  -par_countday) = -1 THEN '3'
          WHEN SIGN(29  -par_countday) = -1 THEN '2'
          WHEN SIGN( 7  -par_countday) = -1 THEN 'C'
          ELSE 'B'
         END) as typesp
    from dual;
  l_cret varchar2(1);
begin
  open cur_c0(p_countday);
  fetch cur_c0 into l_cret;
  close cur_c0;
  return l_cret;
end get_typesp_of_countday;

------------------------------------------------------------------------------------
-- Получить значение из справочника наихудших значений Своевременности платежей
-- за календарный месяц
------------------------------------------------------------------------------------
function get_ubrr_cd_bki_prsr_countday( p_nagrid     in ubrr_data.ubrr_cd_bki_prsr_countday.nagrid%type,
                                        p_datmonth   in ubrr_data.ubrr_cd_bki_prsr_countday.datmonth%type
                                       )
  return ubrr_data.ubrr_cd_bki_prsr_countday%rowtype
  is
  cursor cur_c0(par_nagrid in ubrr_data.ubrr_cd_bki_prsr_countday.nagrid%type, par_datmonth in ubrr_data.ubrr_cd_bki_prsr_countday.datmonth%type) is
  select a.*
    from ubrr_data.ubrr_cd_bki_prsr_countday a
   where a.nagrid = par_nagrid
     and a.datmonth = par_datmonth;
  l_rowtype   ubrr_data.ubrr_cd_bki_prsr_countday%rowtype;
begin
  open cur_c0(p_nagrid,p_datmonth);
  fetch cur_c0 into l_rowtype;
  close cur_c0;
  return l_rowtype;
end get_ubrr_cd_bki_prsr_countday;

------------------------------------------------------------------------------------
-- Процедура добавения записи в таблицу справочника наихудших значений
-- Своевременности платежей за календарный месяц
------------------------------------------------------------------------------------
procedure set_ubrr_cd_bki_prsr_countday( p_nagrid     in ubrr_data.ubrr_cd_bki_prsr_countday.nagrid%type,
                                         p_datmonth   in ubrr_data.ubrr_cd_bki_prsr_countday.datmonth%type,
                                         p_datprsr    in ubrr_data.ubrr_cd_bki_prsr_countday.datprsr%type,
                                         p_ncountday  in ubrr_data.ubrr_cd_bki_prsr_countday.ncountday%type
                                         )
  is
  pragma autonomous_transaction;
begin
  execute immediate 'merge into ubrr_data.ubrr_cd_bki_prsr_countday dst
                     using (select :new_nagrid nagrid,:new_datmonth datmonth,:new_datprsr datprsr,:new_ncountday ncountday from dual) src
                       on ( dst.nagrid = src.nagrid
                            and dst.datmonth = src.datmonth )
                       when matched then
                            update set dst.datprsr  = src.datprsr,
                                       dst.ncountday = src.ncountday
                       when not matched then
                             insert(    nagrid,     datmonth,    datprsr,      ncountday)
                             values(src.nagrid, src.datmonth, src.datprsr, src.ncountday) '
     using p_nagrid,p_datmonth,p_datprsr,p_ncountday;
   commit;
exception
  when others then
    rollback;
    raise_application_error(-20005,'Error in '|| dbms_utility.format_error_backtrace || ' ' ||  dbms_utility.format_error_stack);
end set_ubrr_cd_bki_prsr_countday;

------------------------------------------------------------------------------------
-- Процедура рассчета наихудшие значений Своевременности платежей
-- (кол-во дней просрочки и дата) в отчетном месяце по дату отчета
------------------------------------------------------------------------------------
procedure calc_prsr_agrid_of_month( p_agrID              in number,
                                    p_datbegprsr         in date,
                                    p_datendprsr         in date,
                                    p_ncountday_out      out number,
                                    p_datprsr_out        out date
                                   )
  is
  l_datbeg        date := p_datbegprsr;
  l_datend        date := p_datendprsr;
  l_date_prsr     date;
  l_nloop         number := 0;
  l_ncountday_max number := -9999999;
  l_ncountday_out number;
  l_datprsr_out   date;
begin

  if l_datbeg = l_datend then
    --вернем дату возникновения просрочки
    l_date_prsr := get_date_prsr_of_agrid(p_agrID,l_datbeg);

    --расчитаем количество дней просрочки
    p_ncountday_out := l_datbeg - l_date_prsr;
    p_datprsr_out := l_datbeg;
  else

    --расчитаем за каждый день и найдем наихудшее
    while l_datbeg <= l_datend
      loop
        l_nloop := l_nloop + 1;

        --вернем дату возникновения просрочки
        l_date_prsr := get_date_prsr_of_agrid(p_agrID, l_datbeg);

        --расчитаем количество дней просрочки
        l_ncountday_out := l_datbeg - l_date_prsr;
        l_datprsr_out := l_datbeg;

        if l_ncountday_out > l_ncountday_max then
          l_ncountday_max := l_ncountday_out;
          p_ncountday_out := l_ncountday_out;
          p_datprsr_out := l_datprsr_out;
        end if;

        l_datbeg := l_datbeg + 1;
        --счетчик количетва дней в месяце, на всякий случай
        if l_nloop = 31 then
          exit;
        end if;
      end loop;
  end if;
end calc_prsr_agrid_of_month;

------------------------------------------------------------------------------------
-- Рассчитаем своевременности платежа по возникновению просроченнной задолженности на отчетную дату
-- Проверим со справочником снаихудших значений Своевременности платежей за календарный месяц
------------------------------------------------------------------------------------
function get_calc_prsr_of_agrid( p_agrID    in number,
                                 p_datprsr  in date
                                )
  return varchar2
  is
  l_ret                varchar2(10);
  l_dprsr              date;
  l_ncountday          number;
  l_rowtype            ubrr_data.ubrr_cd_bki_prsr_countday%rowtype;
  l_ncountday_of_month number;
  l_date_of_month      date;
begin

  --вернем дату возникновения просрочки
  l_dprsr := get_date_prsr_of_agrid(p_agrID,p_datprsr);
  --расчитаем количество дней просрочки
  l_ncountday := p_datprsr - l_dprsr;

  --проверим наличие записи в справочнике
  l_rowtype := get_ubrr_cd_bki_prsr_countday(p_agrID, trunc(p_datprsr,'MONTH') );

  --если найдено значение и Дата расчета ПО >=  Даты составления отчета  - 1 и оно «хуже»
  if l_rowtype.datprsr >= (p_datprsr - 1) and l_rowtype.ncountday >= l_ncountday then

    l_ret := get_typesp_of_countday(p_countday => l_rowtype.ncountday);

  --если найдено значение и Дата расчета ПО >=  Даты составления отчета  - 1 и оно «лучше»
  elsif l_rowtype.datprsr >= (p_datprsr - 1) and l_rowtype.ncountday < l_ncountday then

    l_ret := get_typesp_of_countday(p_countday => l_ncountday);

    --обновим значение в справочнике
    set_ubrr_cd_bki_prsr_countday(p_agrID,trunc(p_datprsr,'MONTH'),p_datprsr,l_ncountday);

  --если найдено значение и Дата расчета ПО <  Даты составления отчета  - 1, то рассчитываем СП с Даты расчета ПО +1 по Дату составления расчета – 1
  elsif l_rowtype.datprsr < (p_datprsr - 1) and l_rowtype.ncountday < l_ncountday then

    --проверим за период которго нет просрочку, найдем большую
    calc_prsr_agrid_of_month(p_agrID,l_rowtype.datprsr+1,p_datprsr - 1, l_ncountday_of_month, l_date_of_month);

    --выбираем наихудшее
    if l_ncountday_of_month > l_ncountday then
      l_ncountday :=  l_ncountday_of_month;
    end if;

    --обновим значение в справочнике
    set_ubrr_cd_bki_prsr_countday(p_agrID,trunc(p_datprsr,'MONTH'),p_datprsr,l_ncountday);

    l_ret := get_typesp_of_countday(p_countday => l_ncountday);

  --если не найдено значение, то считаем СП с 1го дня месяца по Дату составления отчета, берем наихудшее значение. Для КИ берем наихудшую из рассчитанных СП.
  else

    --проверим за период которго нет просрочку, найдем большую
    calc_prsr_agrid_of_month(p_agrID,trunc(p_datprsr,'MONTH'),p_datprsr, l_ncountday_of_month, l_date_of_month);

    --обновим значение в справочнике
    set_ubrr_cd_bki_prsr_countday(p_agrID,trunc(p_datprsr,'MONTH'),p_datprsr,l_ncountday_of_month);

    l_ret := get_typesp_of_countday(p_countday => l_ncountday_of_month);

  end if;

  return l_ret;
end get_calc_prsr_of_agrid;

------------------------------------------------------------------------------------
-- Получить первичный договор
------------------------------------------------------------------------------------
function get_agrid_of_parent( p_agrID  in cda.ncdaagrid%TYPE
                            )
  return cda.ncdaagrid%TYPE
  is
  cursor cur_c0( par_agrID  cda.ncdaagrid%TYPE) is
  SELECT CDA.ncdaparent
    FROM CDA
   WHERE CDA.ncdaagrid = par_agrID;
  l_parent  cda.ncdaparent%TYPE;
  l_ret     cda.ncdaagrid%TYPE;
begin
  open cur_c0(p_agrID);
  fetch cur_c0 into l_parent;
  close cur_c0;

  if l_parent is null then
    if trunc(p_agrID) = p_agrID then 
      l_ret := trunc(p_agrID);
    else
      l_ret := p_agrID;
    end if;  
  else
    l_ret := p_agrID;
  end if;

  return l_ret;
end get_agrid_of_parent;

------------------------------------------------------------------------------------
-- Остаток по внебалансовым счетам на дату, списаных за счет резерва
------------------------------------------------------------------------------------
function get_sum_isremed(p_agrID        in number,
                         p_date         in date
                         )
  return number 
  is
  cursor cur_c0(par_agrID in number) is
  select cda.ICDACLIENT, 
         cda.dcdaClosed 
    from xxi."cda" cda 
   where cda.NCDAAGRID = par_agrID;

  cursor cur_c1(par_agrID in number, par_cusid number, par_date in date) is   
  select coalesce(sum(t.MTRNSUM),0)
    from trn t
  where t.CTRNACCD in ( select caccacc
                          from ubrr_acc_v acc
                         where acc.IACCCUS = par_cusid
                           and iaccbs2 in (91704)
                           and acc.DACCOPEN <= par_date
                           and (caccprizn <> 'З' or acc.DACCCLOSE > par_date)
                           and (acc.caccacc like '%'||trunc(par_agrID)
                                or
                                exists(select 1
                                         from xxi."cda" c
                                        where c.ncdaagrid = par_agrID
                                          and c.idsmr = acc.idsmr 
                                          and (c.ccdaagrmnt = acc.CACCSIO 
                                               or 
                                               to_char(trunc(c.ncdaagrid)) = acc.CACCSIO
                                               )
                                       )
                                )
                                  
                        )
   and t.DTRNTRN_TRUNC <= par_date
   and t.ITRNBA2C = 91604;
    
  l_cur_row   cur_c0%rowtype;
  l_ost_rem   number := 0;
  l_ob_acc    number := 0;
begin
  
  --найдем код клиента и дату закрытия
  open cur_c0(p_agrID);
  fetch cur_c0 into l_cur_row;
  close cur_c0;
  
  --сумма оборотов по счету 91704 - 91604 до даты
  open cur_c1(p_agrID,l_cur_row.icdaclient,p_date);
  fetch cur_c1 into l_ob_acc;
  close cur_c1;
  
  --остаток по внебалансовым счетам на дату
  l_ost_rem := get_sum_rem_new(p_agrID, l_cur_row.icdaclient, l_cur_row.dcdaclosed, p_date);
  
  return l_ost_rem - l_ob_acc;

exception
  when others then
    return 0;
end;

------------------------------------------------------------------------------------
-- Дата обнуления остатка по внебалансовым счетах, списаных за счет резерва
------------------------------------------------------------------------------------
function get_date_isremed(p_agrID        in number)
  return date 
  is
  pragma autonomous_transaction;
  tListAcc T_Tab_Varchar2_2000 := T_Tab_Varchar2_2000 ();
      
  cursor cur_c0(par_agrID in number) is
  select cda.ICDACLIENT, 
         cda.dcdaClosed 
    from xxi."cda" cda 
   where cda.NCDAAGRID = par_agrID;

  cursor cur_c1(par_agrID in number, par_cusid number) is   
  select caccacc
    from ubrr_acc_v acc
   where acc.IACCCUS = par_cusid
     and iaccbs2 in (91704, 91802, 91803)
     and (acc.caccacc like '%'||trunc(par_agrID)
          or
          exists(select 1
                   from xxi."cda" c
                  where c.ncdaagrid = par_agrID
                    and c.idsmr = acc.idsmr 
                    and (c.ccdaagrmnt = acc.CACCSIO 
                         or 
                         to_char(trunc(c.ncdaagrid)) = acc.CACCSIO
                         )
                 )
          )
     order by caccacc;
 
  cursor cur_c2 is            
  select sum(ost_acc),
         max(dt_acc) 
   from
  ( 
  select sum(acr.macrdebob-acr.macrcredob) as ost_acc,
         max(acr.dacrdate) as dt_acc
    from acr
   where (acr.dacrdate,acr.cacracc) in (select max(c.dacrdate),
                                               c.cacracc
                                          from acr c, on_temp
                                         where c.cacracc = on_temp.c_1
                                         group by c.cacracc
                                        )                                      
  group by acr.dacrdate, acr.cacracc);        

  cursor cur_c3 is            
  select sum(c.macrdebob-c.macrcredob) as ost
    from acr c, on_temp
   where (c.dacrdate) = (select max(cc.dacrdate)
                           from acr cc
                          where cc.cacracc = c.cacracc
                            and cc.dacrdate < (select max(ccc.dacrdate)
                                                 from acr ccc
                                                where ccc.cacracc = cc.cacracc
                                             group by ccc.cacracc
                                             )
                           group by cc.cacracc                                   
                         )
      and c.cacracc = on_temp.c_1
     ;              
        
      
  l_cur_row         cur_c0%rowtype;
  l_date_acr        date;
  l_ost_b           number := 0;
  l_ost_a           number := 0;
  l_date_r          date;
begin
  --очистим временную табицу
  delete from on_temp;
  
  --найдем код клиента и дату закрытия
  open cur_c0(p_agrID);
  fetch cur_c0 into l_cur_row;
  close cur_c0;
    
  --найдем список счетов
  open cur_c1(p_agrID,l_cur_row.icdaclient);
  fetch cur_c1 bulk collect into tListAcc;
  close cur_c1;    
  
  --есть счета
  if tListAcc.count > 0 then
      --добавим во временную таблицу для быстрой обработки
      insert into on_temp(on_temp.c_1)
        select column_value from table(tListAcc);
      
      --проверим остаток по максимальным датам
      open cur_c2;
      fetch cur_c2 into l_ost_b, l_date_acr;
      close cur_c2;
            
      if l_ost_b = 0 then
        --проверим остаток на предыдущую дату от максимальной
        open cur_c3;
        fetch cur_c3 into l_ost_a;
        close cur_c3;
              
        if l_ost_a <> 0 then
          l_date_r := l_date_acr;
        end if;
      end if;             
  end if;
  commit;                
  
  return l_date_r;

exception
  when others then
    rollback;
    return l_date_r;
end;

------------------------------------------------------------------------------------
-- Вернем лимит кредита, если на дату он = 0, вернем предыдущее значение <> 0
------------------------------------------------------------------------------------
function get_limit_td(p_agrid     in number, 
                      p_effdate   in date
                      ) 
  return number 
  is
  cursor cur_c0(par_agrID in number, par_effdate in date) is
  select dcdhdate
    from cdh
    where ncdhagrid = par_agrID
      and icdhpart = 1
      and ccdhterm = 'LIMIT'
      and dcdhdate <= par_effdate
      and mcdhmval <> 0
  order by dcdhdate desc;        
    
  l_limit       number;
  l_dt_before   date;
begin
    
  l_limit := cdterms.get_limit_td(agrid   => p_agrid,
                                  effdate => p_effdate
                                  );                          
  if l_limit = 0 then
    --венрем предыдущую не нулевую запись
    open cur_c0(p_agrid,p_effdate);
    fetch cur_c0 into l_dt_before;
    close cur_c0;

    if l_dt_before is not null then
      --вернем предыдущее не 0 значение
      l_limit := cdterms.get_limit_td(agrid   => p_agrid,
                                      effdate => l_dt_before
                                      );                                          
    end if;
            
  end if;
                                     
  return l_limit;
exception
  when others then
    return 0;  
end;
--<<12.05.2021  Зеленко С.А      DKBPA-845

-->>02.06.2021  Зеленко С.А      DKBPA-1378 
------------------------------------------------------------------------------------
-- Проверим для «первичных» срочных пролонгаций подходит ли под цессию 
-- является «купленным»/«проданным»   
------------------------------------------------------------------------------------
function check_agrid_bought_sold(p_agrID  in cda.ncdaagrid%TYPE
                                )
  return boolean
  is
  cursor cur_c0( par_agrID  cda.ncdaagrid%TYPE) is
  select count(1)
    from xxi."cda" cda
  where 1=1
    and cda.NCDAAGRID = par_agrID
    and cda.NCDAPARENT is null
    and cda.icdaisline = 0
    and exists ( select 1 
                   from xxi.cdh 
                  where ncdhagrid = cda.ncdaagrid 
                    and ccdhterm = 'LOANACC' 
                    and ( ccdhcval like '478%' or ccdhcval like '44_11%' or ccdhcval like '45_11%' )
                  );
  l_count   number := 0;
  l_ret     boolean := false;
begin
  open cur_c0(p_agrID);
  fetch cur_c0 into l_count;
  close cur_c0;

  if l_count > 0 then
    l_ret := true;
  else
    l_ret := false;
  end if;

  return l_ret;
exception
  when others then
    return false;  
end check_agrid_bought_sold;

------------------------------------------------------------------------------------
-- Вернем дату из «проданной» пролонгации  
------------------------------------------------------------------------------------
function get_signdate_bought_sold(p_agrID  in cda.ncdaagrid%TYPE
                                 )
  return date
  is
  cursor cur_c0( par_agrID  cda.ncdaagrid%TYPE) is
  select cda2.DCDASIGNDATE
    from xxi."cda" cda, xxi."cda" cda2 
  where 1=1
    and cda.NCDAAGRID = par_agrID
    and cda.NCDAPARENT is null
    and cda.icdaisline = 0
    and exists ( select 1 
                   from xxi.cdh 
                  where ncdhagrid = cda.ncdaagrid 
                    and ccdhterm = 'LOANACC' 
                    and ( ccdhcval like '478%' or ccdhcval like '44_11%' or ccdhcval like '45_11%' )
                  ) 
    and cda2.NCDAAGRID in (select max(c3.ncdaagrid) 
                             from XXI."cda" c3 
                            where c3.ccdaagrmnt = cda.ccdaagrmnt 
                              and c3.idsmr <> cda.idsmr 
                              and cda.DCDASIGNDATE2 >= c3.DCDASIGNDATE2
                           );
  l_ret     date := null;
begin
  
  --провеим наш ли это КД цессии
  if ubrr_xxi5.ubrr_isys_for_cd_bki_v7_05.check_agrid_bought_sold(p_agrid => p_agrid) then
    open cur_c0(p_agrID);
    fetch cur_c0 into l_ret;
    close cur_c0;
  end if;

  return l_ret;
exception
  when others then
    return l_ret;  
end get_signdate_bought_sold;

------------------------------------------------------------------------------------
-- Вернем сумму из «проданной» пролонгации (проверим валюту)
------------------------------------------------------------------------------------
function get_total_bought_sold(p_agrID  in cda.ncdaagrid%TYPE
                               )
  return number
  is
  cursor cur_c0( par_agrID  cda.ncdaagrid%TYPE) is
  select cda.CCDACURISO B_CCDACURISO,
         cda.DCDASTARTED B_DCDASTARTED,
         cda2.MCDATOTAL S_MCDATOTAL,
         cda2.CCDACURISO S_CCDACURISO
    from xxi."cda" cda, xxi."cda" cda2 
   where 1=1
     and cda.NCDAAGRID = par_agrID
     and cda.NCDAPARENT is null
     and cda.icdaisline = 0
     and exists (select 1 
                   from xxi.cdh 
                  where ncdhagrid = cda.ncdaagrid 
                    and ccdhterm = 'LOANACC' 
                    and ( ccdhcval like '478%' or ccdhcval like '44_11%' or ccdhcval like '45_11%' )
                  ) 
     and cda2.NCDAAGRID in (select max(c3.ncdaagrid) 
                              from XXI."cda" c3 
                             where c3.ccdaagrmnt = cda.ccdaagrmnt 
                               and c3.idsmr <> cda.idsmr 
                               and cda.DCDASIGNDATE2 >= c3.DCDASIGNDATE2
                           );
  l_row_cur cur_c0%rowtype;
  l_ret     number := null;
begin
  
  --провеим наш ли это КД цессии
  if ubrr_xxi5.ubrr_isys_for_cd_bki_v7_05.check_agrid_bought_sold(p_agrid => p_agrid) then
    
    open cur_c0(p_agrID);
    fetch cur_c0 into l_row_cur;
    close cur_c0;
    
    if l_row_cur.b_ccdacuriso <> l_row_cur.s_ccdacuriso then
      --различные валюты, пересчитаем в рублевый эквивалент 
      l_ret := round(l_row_cur.s_mcdatotal * REVAL.Cur_Rate_New(l_row_cur.s_ccdacuriso,l_row_cur.b_dcdastarted ),2);
    else
      l_ret := l_row_cur.s_mcdatotal;
    end if;
  
  end if;

  return l_ret;
exception
  when others then
    return l_ret;  
end get_total_bought_sold;
--<<02.06.2021  Зеленко С.А      DKBPA-1378 

END ubrr_isys_for_cd_bki_V7_05;
/
