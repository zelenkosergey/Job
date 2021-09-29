CREATE OR REPLACE PACKAGE BODY XXI."UTIL_FREADER" IS
/****************************** HISTORY UBRR ******************************************\

****************************************************************************
Изменения:
----------------------------------------------------------------------------
Дата        Автор            ID         Описание
----------  ---------------  --------- ---------------------------------------
26.04.2013  Новолодский А.Ю. 12-124     Регистрация в отложенные с помощью ПО FineReader
                                                                                при наличии приостановления операций по счету плательщика
17.09.2013  Новолодский А.Ю. 12-124     Отключаем штатный функционал проверки признака счета
                                                                                https://redmine.lan.ubrr.ru/issues/9581
31.10.2013  Новолодский А.Ю. 12-2029    Ошибка регистрации Инкассового поручения через ПО FineReader
                                                                                https://redmine.lan.ubrr.ru/issues/10184
02.02.2015  Новолодский А Ю. [15-22]    АБС: БО2=8 при списании инкассовых из картотеки
19.02.2015  Новолодский А.Ю. [14-239]   контроль зачисления на КРС
06.04.2015  Новолодский А.Ю. [15-219]   АБС: Запрет зачисления мб платежей на КРС
13.04.2015  Новолодский А.Ю. [14-1134]  АБС: Доработка экспорта документов из ПО FineReader For Bank 7.0 в АБС
29.12.2015  ubrr korolkov    15-537.1   АБС: Зачисление на 40821 (ОТКБ)
04.03.2016  Новолодский А.Ю. [15-1641.3] АБС: 148-н. Контроль заполнения бюджетных полей (Fine-Reader)
15.03.2016  ubrr korolkov    15-537.1   Новое Требование #29231
30.05.2016  ubrr korolkov    16-1808    [16-1808.11.30] ВУЗ-банк. Доработка ПО FineReader #30671#note-6
02.12.2016  ubrr MakarovaLU  [16-2308.5] Fine Reader: Отключения контроля БИКа получателя и счет получателя по 107н
                                                                             https://redmine.lan.ubrr.ru/issues/38271
16.01.2017  Пинаев Д.Е.      #38808     [16-2429.4] Fine Reader: Доработка АБС и ИБ по 107н (по ошибкам ГИС ГМП) - п.2, 3, 4
19.01.2017  Коломиец Д.С.    [16-2680.3] Fine Reader: Контроль количества символов (210) в назначении платежа
17.03.2017  ubrr belosheykin [xxxxxx]    орфографические правки
17.04.2017  ubrr korolkov    16-2959.4  Fine Reader Зачисление на 40821 для ВУЗ, согласно 161-ФЗ "О национальной платежной системе"
29.06.2017  Ёлгин Ю.А.       [16-3300.1.1] https://redmine.lan.ubrr.ru/issues/43068  АБС: Централизация платежей. Этап II - ЗДА
27.08.2017  Ёлгин Ю.А.       [17-1076]    АБС: Контроль платежей клиентов
17.09.2017  ubrr belosheykin 17-473.5    АБС: Указание информации в реквизитах распоряжений о переводе денежных
                                         средств в уплату платежей в бюджетную систему (107-Н) к 02.10.2017
03.10.2017  ubrr korolkov    17-473.5    Поле 108
03.11.2017  Ёлгин Ю.А.       [17-1423]   АБС: Поле 108 в бюджетных платежах https://redmine.lan.ubrr.ru/issues/47827#note-6
03.11.2017  Седавных Н.А.    [17-1236]   Уведомление о факте зачисления на счет ФЛ ("третейск")
18.11.2017  Ёлгин Ю.А.       [17-1323]   АБС: Контроль сомнительных операций через Почту РФ и сотовых операторов
13.11.2017  Пинаев Д.Е.      [17-1198]   АБС: Новый модуль для контроля СВК веерных платежей (алгоритм)
11.04.2018  Пинаев Д.Е.      [18-268]    АБС: Доработка модуля "Контроль платежей" Клиент 550-П
13.04.2018  Пинаев Д.Е.      [17-1575]   АБС: Онлайн контроль операций с признаком "аккумулирующий транзит"
18.05.2018  Пинаев Д.Е.      [17-1637.1] АБС: Платежи с пачкой 555 (ОТКБ)
26.04.2018  Киселев А.А.     [17-1267.1] АБС: Поле 110 в распоряжениях о переводе средств
28.06.2018  Пинаев Д.Е.      [18-464]    Доп к [15-43] АБС: Новый пакет услуг с авансовой оплатой за пакет платежей)
27.08.2018  Пинаев Д.Е.      [18-617.1]  АБС: Ручной разбор платежей при наличии просрочки по КД
07.02.2019  Ризанов Р.Т.     [18-58411]  АБС: ТП "Промо" в режиме "Эконом"
26.07.2019  Баязитов         [18-742.1]  АБС: Новые параметры по запрету кредитовых зачислений по внутрибанку
20.08.2019  Баязитов         [18-742.1]  АБС: Новые параметры по запрету кредитовых зачислений по внутрибанку - доп.требование
18.11.2020  Зеленко С.А.     [20-82101.1] АБС: Изменение счетов ТОФК с 01.01.2021
01.02.2021  Зеленко С.А.     [DKBPA-38]  АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
****************************** HISTORY UBRR *****************************************/
    vcmagic_num   CONSTANT VARCHAR2 (23) := '71371371371371371371371';
    gtotal                 INTEGER;
    gused                  INTEGER;

--->>>ubrr 05.11.2007 Кузнецов Е.В. Перенос собственных разработок из версии 4
    FUNCTION usr_getdelway (potdnum IN NUMBER, pbo1 IN NUMBER)
        RETURN VARCHAR2 IS
        usr_cdelway   VARCHAR2 (10);
    BEGIN
        SELECT cdelway
          INTO usr_cdelway
          FROM ubrr_katpm_freader_batch
         WHERE iotdnum = potdnum AND itopnum = pbo1;

        RETURN usr_cdelway;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    mbunch.put('FREADER', '32', 'usr_cdelway = ' || usr_cdelway);
    END;

---<<<ubrr 05.11.2007 Кузнецов Е.В. Перенос собственных разработок из версии 4

    ------------------------------------------------------------------------------------------
-- Функция определяет вид платежа
------------------------------------------------------------------------------------------
    FUNCTION getdelway (pdelway IN VARCHAR2, pmfoa IN VARCHAR2)
        RETURN VARCHAR2 IS
        vuer   fog.cfoguer%TYPE;
        vuvr   fog.cfoguvr%TYPE;
        vrkc   fog.cfogrkc%TYPE;
    BEGIN
        IF pdelway IS NOT NULL THEN
            RETURN pdelway;
        END IF;

        -- определение способа доставки для данного банка
        BEGIN
            SELECT cfoguer, cfoguvr, cfogrkc
              INTO vuer, vuvr, vrkc
              FROM fog
             WHERE cfogmfo8 = pmfoa;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN NULL;
        END;

        IF vuer IN ('01', '03', '04', '05') THEN -->> Буткевич Д.А. 26.08.2010 добавлен 5ый тип в связи с измениениями ЦБ БИК
            RETURN 'E';
        ELSIF vuer = '02' THEN
            BEGIN
                SELECT cfoguer, cfoguvr, cfogrkc
                  INTO vuer, vuvr, vrkc
                  FROM fog
                 WHERE cfogmfo8 = vrkc;

------>>>>>>>>>>>ubrr Begin. Исправил Радик. По служебке Самохваловой от 19.01.2004
                IF vuer IN ('01', '03', '04', '05') THEN  -->> Буткевич Д.А. 26.08.2010 добавлен 5ый тип в связи с измениениями ЦБ БИК
                    IF SUBSTR (vrkc, 1, 4) = '0465' THEN
                        RETURN NULL;
                    ELSE
                        RETURN 'E';
                    END IF;
                ELSE
                    RETURN 'P';
                END IF;
------<<<<<<<<<<<<<ubrr   END Исправил Радик. По служебке Самохваловой от 19.01.2004
/*-->>>ubrr Было до 19.01.2004
        IF vuer IN ('01', '03', '04')
        THEN
          RETURN 'E';
        ELSE
          RETURN 'P';
        END IF;
*/--<<<ubrr Было до 19.01.2004
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN 'P';
            END;
        ELSE
            RETURN 'P';
        END IF;

        RETURN NULL;
    END;

------------------------------------------------------------------------------------------
-- Функция проверяет зарегистрирован ли документ с такимим параметрами
------------------------------------------------------------------------------------------
    FUNCTION isdocduplicated (
        perr      OUT      VARCHAR2,
        pdocnum   IN       NUMBER,
        ddate     IN       DATE,
        paccd     IN       VARCHAR2,
        pacca     IN       VARCHAR2,
        psum      IN       NUMBER
    )
        RETURN BOOLEAN IS
        CURSOR ctrn IS
            SELECT 'x'
              FROM v_trn_part_current
             WHERE itrndocnum = pdocnum
               AND dtrndoc = ddate
               AND ctrnaccd = paccd
               AND ctrnacca = pacca
               AND mtrnsum = psum;

        vdummy   CHAR (1);
    BEGIN
        OPEN ctrn;

        FETCH ctrn
         INTO vdummy;

        CLOSE ctrn;

        IF vdummy = 'x' THEN
            perr := 'Этот документ уже зарегистрирован.';
            RETURN FALSE;
        END IF;

        RETURN TRUE;
    END isdocduplicated;

    FUNCTION isdocduplicateddp (
        perr      OUT      VARCHAR2,
        pdocnum   IN       NUMBER,
        ddate     IN       DATE,
        paccd     IN       VARCHAR2,
        pacca     IN       VARCHAR2,
        psum      IN       NUMBER
    )
        RETURN BOOLEAN IS
        CURSOR cdp IS
            SELECT 'x'
              FROM dp_doc
             WHERE idocnum = pdocnum
               AND ddoc = ddate
               AND cpayeracc = paccd
               AND crecipacc = pacca
               AND msumm = psum;

        vdummy   CHAR (1);
    BEGIN
        OPEN cdp;

        FETCH cdp
         INTO vdummy;

        CLOSE cdp;

        IF vdummy = 'x' THEN
            perr := 'Этот документ уже зарегистрирован в отложенные платежи.';
            RETURN FALSE;
        END IF;

        RETURN TRUE;
    END isdocduplicateddp;

--========================================================================
    FUNCTION isdocduplicatedoncard (
        perr      OUT      VARCHAR2,
        pdocnum   IN       NUMBER,
        ddate     IN       DATE,
        paccd     IN       VARCHAR2,
        pacca     IN       VARCHAR2,
        psum      IN       NUMBER
    )
        RETURN BOOLEAN IS
        CURSOR ctrc IS
            SELECT 'x'
              FROM trc
             WHERE itrcdocnum = pdocnum
               AND dtrcdoc = ddate
               AND ctrcaccd = paccd
               AND ctrcacca = pacca
               AND mtrcsum = psum;

        cdummy   CHAR (1);
    BEGIN
        OPEN ctrc;

        FETCH ctrc
         INTO cdummy;

        CLOSE ctrc;

        IF cdummy = 'x' THEN
            perr := 'Этот документ уже зарегистрирован на картатеке.';
            RETURN FALSE;
        END IF;

        perr := 'OK';
        RETURN TRUE;
    END isdocduplicatedoncard;

    --
    -- Ключевание РКЦшного счета
    --
    FUNCTION rkcacc_is_keyed (rkc_bic IN VARCHAR2,                                        -- БИК РКЦ
                                                  coracc IN VARCHAR2)
        -- Корсчет
    RETURN BOOLEAN IS
        vcrkc_bic   VARCHAR2 (9)  := LPAD (rkc_bic, 9, '0');
        vccor_acc   VARCHAR2 (20) := LPAD (coracc, 20, '0');
        vcvalue     VARCHAR2 (23)
            :=    '0'
               || SUBSTR (vcrkc_bic, 5, 2)
               || SUBSTR (vccor_acc, 1, 8)
               || '0'
               || SUBSTR (vccor_acc, 10);
        nsum        NUMBER        := 0;
    BEGIN
        FOR i IN 1 .. 23 LOOP
            IF SUBSTR (vcvalue, i, 1) NOT IN ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0') THEN
                RETURN FALSE;
            END IF;

            nsum :=
                   nsum + TO_NUMBER (SUBSTR (vcmagic_num, i, 1))
                          * TO_NUMBER (SUBSTR (vcvalue, i, 1));
        END LOOP;

        RETURN TO_CHAR (MOD (nsum * 3, 10)) = SUBSTR (vccor_acc, 9, 1);
    END rkcacc_is_keyed;

    --
    -- Ключевание банковского счета
    --
    FUNCTION bankacc_is_keyed (bank_bic IN VARCHAR2,                                    -- БИК Банка
                                                    ACCOUNT IN VARCHAR2)             -- Счет в банке
        RETURN BOOLEAN IS
        vcbank_bic   VARCHAR2 (9)  := LPAD (bank_bic, 9, '0');
        vcaccount    VARCHAR2 (20) := LPAD (ACCOUNT, 20, '0');
        vcvalue      VARCHAR2 (23)
            := SUBSTR (vcbank_bic, 7, 3) || SUBSTR (vcaccount, 1, 8) || '0'
               || SUBSTR (vcaccount, 10);
        nsum         NUMBER        := 0;
    BEGIN
        FOR i IN 1 .. 23 LOOP
            IF SUBSTR (vcvalue, i, 1) NOT IN ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0') THEN
                RETURN FALSE;
            END IF;

            nsum :=
                   nsum + TO_NUMBER (SUBSTR (vcmagic_num, i, 1))
                          * TO_NUMBER (SUBSTR (vcvalue, i, 1));
        END LOOP;

        RETURN TO_CHAR (MOD (nsum * 3, 10)) = SUBSTR (vcaccount, 9, 1);
    END bankacc_is_keyed;

    --
    -- Функция проверки допустимости атрибутов внешнего корреспондента в нац вал
    --
    FUNCTION check_correspondent (
        cerror     OUT      VARCHAR2,
        cmfo9      IN       VARCHAR2,
        ccoracc    IN       VARCHAR2,
        caccount   IN       VARCHAR2,
        cinn       IN       VARCHAR2,
        dtran      IN       DATE DEFAULT NULL                      -->>><<<Лобик Д.А.ubrr 12.01.2007
    )
        RETURN INTEGER IS
        CURSOR curfog IS
            SELECT cfogmfo8, ifogcoracc_new, dfogdel_date, cfoginheritor, ifogfininst
              FROM fog
             WHERE cfogmfo8 = cmfo9;

        CURSOR curfok IS
            SELECT cfokdisable, cfokdescrip,
                   TRUNC (dfokdisable) dfokdisable                -->>><<<Лобик Д.А.ubrr 12.01.2007
              FROM fok
             WHERE cfokmfo8 = cmfo9 AND cfokacc = caccount;

        rfog                   curfog%ROWTYPE;
        rfok                   curfok%ROWTYPE;
        bfound                 BOOLEAN;
        bkeyed                 BOOLEAN;
        icheck_correspondent   INTEGER                := -1;
        v_dfokdisable          fok.dfokdisable%TYPE;              -->>><<<Лобик Д.А.ubrr 12.01.2007
    BEGIN
        DECLARE
            e_check_correspondent   EXCEPTION;
        BEGIN
            OPEN curfog;

            FETCH curfog
             INTO rfog;

            bfound := curfog%FOUND;

            CLOSE curfog;

            IF NOT bfound THEN
                cerror :=
                         'Кредитная организация с кодом ' || cmfo9 || ' отсутствует в справочнике.';
                RAISE e_check_correspondent;
            END IF;

            IF rfog.dfogdel_date IS NOT NULL THEN
                cerror :=
                       'Кредитная организация с кодом '
                    || cmfo9
                    || ' закрыта с '
                    || TO_CHAR (rfog.dfogdel_date, 'DD.MM.YYYY')
                    || '. БИК правоприемника: '
                    || NVL (rfog.cfoginheritor, 'отсутствует')
                    || '.';
                RAISE e_check_correspondent;
            END IF;

            
            -->>18.11.2020  Зеленко С.А.    [20-82101.1]  АБС: Изменение счетов ТОФК с 01.01.2021 (добавил проверку БИК)
            IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_bik_new(cMfo9) and trunc(ubrr_xxi5.ubrr_dtime.get_sysdate) >= ubrr_xxi5.ubrr_change_accounts_tofk.get_date_year_2021 THEN
              IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_receiver_coracca(par_bik => cMfo9,
                                                                                 par_сcoracca =>cCorAcc,
                                                                                 par_err => cError) THEN
                RAISE e_Check_Correspondent;
              END IF; 
            ELSE
              IF NOT (NVL (ccoracc, 'NULL$') = NVL (TO_CHAR (rfog.ifogcoracc_new), 'NULL$')) THEN
                  cerror :=
                         'Указан неверный корсчет '
                      || ccoracc
                      || ' правильное значение: '
                      || TO_CHAR (rfog.ifogcoracc_new)
                      || '.';
                  RAISE e_check_correspondent;
              END IF;
            END IF;
            --<<18.11.2020  Зеленко С.А.    [20-82101.1]  АБС: Изменение счетов ТОФК с 01.01.2021 (добавил проверку БИК)
            
            -->>18.11.2020  Зеленко С.А.    [20-82101.1]  АБС: Изменение счетов ТОФК с 01.01.2021
            declare
              l_msg xxi.ups.cupsvalue%type;
            begin
              --проверим старые ТОФК
              IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_accounts(par_bik_old     => cmfo9,
                                                                         par_account_old => caccount,
                                                                         par_msg         => l_msg) THEN

                IF trunc(ubrr_xxi5.ubrr_dtime.get_sysdate) >= ubrr_xxi5.ubrr_change_accounts_tofk.get_date_change_2021 THEN
                  cerror := (l_msg ||' Необходимо изменить реквизиты.');
                  RAISE e_check_correspondent;
                END IF;

              END IF;

              --проверим новые ТОФК
              IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_bik_new(par_bik_new => cmfo9) and
                 trunc(ubrr_xxi5.ubrr_dtime.get_sysdate) >= ubrr_xxi5.ubrr_change_accounts_tofk.GET_DATE_YEAR_2021  THEN

                IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_receiver_acca(par_bik => cmfo9,
                                                                                par_cacca => caccount,
                                                                                par_err => cerror) THEN
                 RAISE e_check_correspondent;
               END IF;

              ELSE

                --старая логика проверки ключевания счета
                IF rfog.ifogfininst = 2 THEN
                    bkeyed := rkcacc_is_keyed (cmfo9, caccount);
                ELSE
                    bkeyed := bankacc_is_keyed (cmfo9, caccount);
                END IF;

                IF NOT bkeyed THEN
                    cerror := 'Счет ' || caccount || ' не проходит контроля на ключевание.';
                    RAISE e_check_correspondent;
                END IF;
              END IF;

            end;
            --<<18.11.2020  Зеленко С.А.    [20-82101.1]  АБС: Изменение счетов ТОФК с 01.01.2021

            OPEN curfok;

            FETCH curfok
             INTO rfok;

            CLOSE curfok;

            IF     rfok.cfokdisable = 'D'
               -->>>Лобик Д.А.ubrr 12.01.2007  надо учитывать дату, с которой действует закрытие счета
               AND (   v_dfokdisable IS NULL                     --даты нет=>запрет действует всегда
                    OR                            --дата есть и проводка не до нее=>запрет действует
                       (TRUNC (NVL (dtran, SYSDATE)) >= v_dfokdisable AND v_dfokdisable IS NOT NULL
                       )
                   )
                    --<<<Лобик Д.А.ubrr 12.01.2007  надо учитывать дату, с которой действует закрытие счета
            THEN
        -->>>Лобик Д.А.ubrr 12.01.2007  надо учитывать дату, с которой действует закрытие счета
--        cerror := nvl(rfok.cfokdescrip, 'Счет ' || caccount || ' в ' || cmfo9 || ' закрыт.'); -->>>comm<<<--ubrr 12.01.2007
                cerror :=
                    NVL (rfok.cfokdescrip,
                            TO_CHAR (v_dfokdisable, 'dd.mm.yyyy')
                         || ' Счет '
                         || caccount
                         || ' в '
                         || cmfo9
                         || ' закрыт.'
                        );
                --<<<Лобик Д.А.ubrr 12.01.2007  надо учитывать дату, с которой действует закрытие счета
                RAISE e_check_correspondent;
            END IF;

            --   if not UTIL.INN_Is_Keyed (cInn) then
            --      cError := 'ИНН ' || cInn || ' не проходит контроля на ключевание.';
            --      raise e_Check_Correspondent;
            --   end if;
            icheck_correspondent := 0;
        EXCEPTION
            WHEN e_check_correspondent THEN
                NULL;
            WHEN OTHERS THEN
                cerror := 'FO_ATTRIBUTE.Check_Correspondent: ' || SQLERRM;
        END;

        RETURN icheck_correspondent;
    END check_correspondent;

------------------------------------------------------------------------------------------
-- Функция возвращает номер пачки по типу документа и логину пользователя               --
------------------------------------------------------------------------------------------
    FUNCTION getbatchnumber (ptype IN NUMBER, plogname IN fr_batches.cfrblogname%TYPE)
        RETURN NUMBER IS
        vcbatnum   NUMBER (5);
    BEGIN

        ----->>>>>> paa14082009 запись в логи
        UBRR_KATPM_SPOOL_DEBUG_MSG(-4,'Define batch pBO1time = ');
        ----->>>>>> paa14082009 запись в логи
        BEGIN
            SELECT ifrbatnum
              INTO vcbatnum
              FROM fr_batches
             WHERE ifrtop = ptype AND cfrblogname = plogname AND ROWNUM = 1;

            RETURN vcbatnum;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                SELECT ifrbatnum
                  INTO vcbatnum
                  FROM fr_batches
                 WHERE ifrtop = ptype AND cfrblogname IS NULL AND ROWNUM = 1;

                RETURN vcbatnum;
        END;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END;

--->>>ubrr 05.12.2007 Кузекцов Е.В. перенос собственных разработок из версии 4
------------------------------------------------------------------------------------------
-- UBRR Функция возвращает номер пачки по типу документа                                --
------------------------------------------------------------------------------------------
    FUNCTION getbatchnumber (potdnum IN NUMBER, pbo1 IN NUMBER)
        RETURN NUMBER IS
        vcbatnum   NUMBER (5);
        --usr_time   VARCHAR2 (10);
    BEGIN

        ----->>>>>> paa14082009 запись в логи
        UBRR_KATPM_SPOOL_DEBUG_MSG(-4,'Define batch-2 OTD= ['||to_char(pOTDNum) || '] pBO1 = ['||to_char(pBO1) ||']'); -- time = ['|| usr_time || ']');
        ----->>>>>> paa14082009 запись в логи
        /*
        SELECT TO_CHAR (ubrr_dtime.get_sysdate, 'HH24:MI') -->>><<< ubrr.kev 21.05.2008 Учет часового пояса сеанса
          INTO usr_time
          FROM DUAL;
        */
        -- Корольков Д.А. убрал проверку на время https://redmine.lan.ubrr.ru/issues/2792
        --IF usr_time > '16:00' THEN
            SELECT ibatnum_after16
              INTO vcbatnum
              FROM ubrr_katpm_freader_batch
             WHERE iotdnum = potdnum AND itopnum = pbo1;
        /*ELSE
            SELECT ibatnum_before16
              INTO vcbatnum
              FROM ubrr_katpm_freader_batch
             WHERE iotdnum = potdnum AND itopnum = pbo1;
        END IF;*/

        -----<<<<<< paa14082009 запись в логи
        UBRR_KATPM_SPOOL_DEBUG_MSG(-3,'Batch = '||to_char(vcBatNum));
        ----->>>>>> paa14082009 запись в логи
        RETURN vcbatnum;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END;

    FUNCTION cf_note_paymentformula (note_payment IN VARCHAR2)
        RETURN VARCHAR2 IS
        pos   NUMBER;
    BEGIN
        IF INSTR (LOWER (note_payment), 'включая ндс') > 0 THEN
            pos := INSTR (LOWER (note_payment), 'включая ндс');
        ELSIF INSTR (LOWER (note_payment), 'без ндс') > 0 THEN
            pos := INSTR (LOWER (note_payment), 'без ндс');
        ELSIF INSTR (LOWER (note_payment), 'в т.ч. ндс') > 0 THEN
            pos := INSTR (LOWER (note_payment), 'в т.ч. ндс');
        ELSIF INSTR (LOWER (note_payment), 'ндс не облагается') > 0 THEN
            pos := INSTR (LOWER (note_payment), 'ндс не облагается');
        ELSIF INSTR (LOWER (note_payment), 'без налога ндс') > 0 THEN
            pos := INSTR (LOWER (note_payment), 'без налога ндс');
        ELSIF INSTR (LOWER (note_payment), 'ндс не предусмотрен') > 0 THEN
            pos := INSTR (LOWER (note_payment), 'ндс не предусмотрен');
        ELSIF INSTR (LOWER (note_payment), 'в том числе ндс') > 0 THEN
            pos := INSTR (LOWER (note_payment), 'в том числе ндс');
        ELSIF INSTR (LOWER (note_payment), 'ндс не предусматривается') > 0 THEN
            pos := INSTR (LOWER (note_payment), 'ндс не предусматривается');
        ELSIF INSTR (LOWER (note_payment), 'в т.ч. включая ндс') > 0 THEN
            pos := INSTR (LOWER (note_payment), 'в т.ч. включая ндс');
        ELSIF INSTR (LOWER (note_payment), 'ндс нет') > 0 THEN
            pos := INSTR (LOWER (note_payment), 'ндс нет');
        ELSIF INSTR (LOWER (note_payment), 'без учета ндс') > 0 THEN
            pos := INSTR (LOWER (note_payment), 'без учета ндс');
        ELSIF INSTR (LOWER (note_payment), 'в тч ндс') > 0 THEN
            pos := INSTR (LOWER (note_payment), 'в тч ндс');
        -- katyuhin 11042005 - begin
        ELSIF INSTR (LOWER (note_payment), 'ндс') > 0 THEN
            pos := INSTR (LOWER (note_payment), 'ндс');
        -- katyuhin 11042004 - end
        ELSE
            RETURN note_payment;
        END IF;

        RETURN SUBSTR (note_payment, 1, pos - 1) || CHR (10) || SUBSTR (note_payment, pos);
    END;

---<<<ubrr 05.12.2007 Кузекцов Е.В. перенос собственных разработок из версии 4

------------------------------------------------------------------------------------------
-- Буферная функция регистрации платежных документов для вызова из FineReader           --
------------------------------------------------------------------------------------------
    FUNCTION REGISTER (
        perr               IN OUT   VARCHAR2,                                 -- Сообщение об ошибке
        pdate              IN       DATE,                                            -- Дата платежа
        pbo1fr             IN       VARCHAR2,                             -- БО1 in ('PP','IP','PT')
        ppaycond           IN       VARCHAR2,                                      -- Условие оплаты
        pvaldate           IN       VARCHAR2,                                  -- Дата валютирования
        ppayer             IN       VARCHAR2,                            -- Наименование плательщика
        ppayeracc          IN       VARCHAR2,                                    -- Счет плательщика
        ppayerinn          IN       VARCHAR2,                                     -- ИНН плательщика
        ppayercoracc       IN       VARCHAR2,                                 -- Корсчет плательщика
        ppayerbic          IN       VARCHAR2,                               -- БИК банка плательщика
        ppayerbank         IN       VARCHAR2,                      -- Наименование банка плательщика
        precipient         IN       VARCHAR2,                             -- Наименование получателя
        precipientacc      IN       VARCHAR2,                                     -- Счет получателя
        precipientinn      IN       VARCHAR2,                                      -- ИНН получателя
        precipientcoracc   IN       VARCHAR2,                            -- Корсчет банка получателя
        precipientbic      IN       VARCHAR2,                                -- БИК банка получателя
        precipientbank     IN       VARCHAR2,                       -- Наименование банка получателя
        psum               IN       NUMBER,                                         -- Сумма платежа
        ppurpose           IN       VARCHAR2,                                  -- Назначение платежа
        pdocnum            IN       NUMBER,                                       -- Номер документа
        ppriority          IN       NUMBER,                                   -- Очередность платежа
        pdeliveryway       IN       VARCHAR2,                                     -- Способ доставки
        pkppplat           IN       VARCHAR2,                                      -- КПП плателщика
        pkpprec            IN       VARCHAR2,                                      -- КПП получателя
        pcreatstatus       IN       VARCHAR2 DEFAULT NULL,                         -- 101
        pbudcode           IN       VARCHAR2 DEFAULT NULL,                         -- 104
        pokatocode         IN       VARCHAR2 DEFAULT NULL,                         -- 105
        pnalpurp           IN       VARCHAR2 DEFAULT NULL,                         -- 106
        pnalperiod         IN       VARCHAR2 DEFAULT NULL,                         -- 107
        pnaldocnum         IN       VARCHAR2 DEFAULT NULL,                         -- 108
        pnaldocdate        IN       VARCHAR2 DEFAULT NULL,                         -- 109
        pnaltype           IN       VARCHAR2 DEFAULT NULL,                         -- 110
        pbatnum            IN       VARCHAR2 DEFAULT NULL,                            -- номер пачки
-- (нач.) UBRR Новолодский А. Ю. 13.04.2015 [14-1134] АБС: Доработка экспорта документов из ПО FineReader For Bank 7.0 в АБС
        pvo                IN       VARCHAR2 DEFAULT NULL,                            -- вид операции, 7я модель
        pdocindex          IN       VARCHAR2 DEFAULT NULL                             -- 107н 22
-- (кон.) UBRR Новолодский А. Ю. 13.04.2015 [14-1134] АБС: Доработка экспорта документов из ПО FineReader For Bank 7.0 в АБС
    )
        RETURN VARCHAR2 IS
        vret                VARCHAR2 (256);
        vbo1                top.itopnum%TYPE;
        vvo                 trn.ctrnvo%TYPE;
        vdelway             VARCHAR2 (10);
        vibatnum            NUMBER (5);
        retcode             VARCHAR2 (256);
        cdocstate           VARCHAR2 (64);
        vvaldate            DATE;
        vacceptter          NUMBER (3);
        vplace              VARCHAR2 (30);
        vdeptinfo           ts.t_deptinfo;
        vbo2                sop.isopid%TYPE;
        terr                VARCHAR2 (2048);
-- (нач) UBRR Новолодский А. Ю.
        vPayer              VARCHAR2 (2048):=ppayer;
        bIsForeign          Boolean:=False;
-- (кон) UBRR Новолодский А. Ю.
        vincdate            VARCHAR2 (10);
        lf                  CHAR                 DEFAULT CHR (10);
        tregistersequence   VARCHAR2 (32);
-->>>ubrr 05.12.2007 Кузнецов Е.В. перенос собственного функционала из АБС v4
        i                   NUMBER (5);
        p                   trn.ctrnpurp%TYPE;
        suboptype           trn.itrnsop%TYPE     := 100;                             --lip 21/02/05
        --usr_ppaycond        trn.ctrntext3%TYPE;
        -->> 30.05.2016 ubrr korolkov 16-1808.11.30
        --usr_iotdnum         NUMBER;
        vOtdNum             number;
        --<< 30.05.2016 ubrr korolkov 16-1808.11.30
        vrecipientacc       VARCHAR2 (25);
        vregistrintobtn     BOOLEAN              := FALSE;
        --vssb                BOOLEAN              := FALSE;
        -- UBRR katyuhin >>>
        v_nhiddenbo1        NUMBER               := NULL;
        v_cdtplace          VARCHAR2 (3);
        v_cctplace          VARCHAR2 (3);
    -- UBRR katyuhin <<<
        bExtr               boolean;
        vBudg               pls_integer; -- признак бюджетности
        vEcon               pls_integer; -- эконом
        vPurp               varchar2(1024);
        vOurBic             pls_integer;
        bPT2TRN             Boolean :=False;
        vpaycond            varchar2(4000):=Trim(ppaycond);
        vpurpose            varchar2(4000):=ppurpose;
    --<<<ubrr 05.12.2007 Кузнецов Е.В. перенос собственного функционала из АБС v4

        -->> 17.09.2017 ubrr belosheykin 17-473.5
        c_02_10_2017        date;
        l_state_021017      Boolean := false;
        --<< 17.09.2017 ubrr belosheykin 17-473.5

        -->>> Ёлгин Ю.А. 27.08.2017 [17-1076] АБС: Контроль платежей клиентов
        vcCtrlResult        varchar(10);
        vcErrorMsg          varchar(2000);
        --<<<  Ёлгин Ю.А. 27.08.2017 [17-1076] АБС: Контроль платежей клиентов

        -->> 08.11.2017    Пинаев Д.Е.      [17-1198]      АБС: Новый модуль для контроля СВК веерных платежей (алгоритм)
        vcCpCtrlMsg         varchar(2000);
        vcPayTypes          varchar(100);
        l_ret               signtype;
        --<< 08.11.2017    Пинаев Д.Е.      [17-1198]      АБС: Новый модуль для контроля СВК веерных платежей (алгоритм)

        -->> 13.04.2018 Пинаев Д.Е. [17-1575] АБС: Онлайн контроль операций с признаком "аккумулирующий транзит"
        rAccuValues   ubrr_cp_pkg.r_accu_values;
        aID4log       ubrr_cp_pkg.t_tab_id4log;
        --<< 13.04.2018 Пинаев Д.Е. [17-1575] АБС: Онлайн контроль операций с признаком "аккумулирующий транзит"

        -->> 27.08.2018 Пинаев Д.Е. [18-617.1] АБС: Ручной разбор платежей при наличии просрочки по КД
        vcOverdueCtrlResult  varchar(10);
        --<< 27.08.2018 Пинаев Д.Е. [18-617.1] АБС: Ручной разбор платежей при наличии просрочки по КД

        -->> 18.05.2018  Пинаев Д.Е. [17-1637.1] АБС: Платежи с пачкой 555 (ОТКБ)
        vcMiddleErrorMsg    varchar(2000);
        vcMiddleCtrlResult  varchar(10);
        vcMiddlePayTypes    varchar(100);
        aCatGr              ubrr_cpm_control.t_tab_catgr;
        vibatnum_tmp        NUMBER (5);
        tabAttr             TS.T_TabTrnAttr := TS.T_TabTrnAttr();
        --<< 18.05.2018  Пинаев Д.Е. [17-1637.1] АБС: Платежи с пачкой 555 (ОТКБ)

        -->>-- 16.01.2017 Пинаев Д.Е.  #38808 [16-2429.4] Fine Reader: Доработка АБС и ИБ по 107н (по ошибкам ГИС ГМП) - п.2, 3, 4
        function check_pnalperiod( p_107 in varchar2, p_104 in varchar2, p_106 in varchar2, p_perr in out varchar2 )
            return boolean
        is
            bRet            boolean := true;
            l_str_err_107   Varchar2(512); -->><< 17.09.2017 ubrr belosheykin 17-473.5
        begin
            If p_104 like '153%' and
               -->> 17.09.2017 ubrr belosheykin 17-473.5
               ((p_106 in ('0','00','ДЕ','ПО', 'КТ','ИД','ИП','ТУ','БД','ИН',
                           'КП','ДК','ПК','КК','ТК') and l_state_021017 = false)
               or
                (l_state_021017 = true and p_106 in ('0','00','ДЕ','ПО', 'КТ','ИД','ИП','ТУ','БД','ИН',
                                                     'КП','ДК','ПК','КК','ТК','ПД','КВ')))  then
               --<< 17.09.2017 ubrr belosheykin 17-473.5
                If length(p_107) = 8 then
                    return true;
                Else
                    bRet := false;
                end if;
            end if;

            if bRet then
               case length(p_107)
                when 1 then
                 If p_107<>'0' then bRet:=false;
                 end if;
                when 10 then
                 If regexp_like(p_107,'\w{2}\.\w{2}\.\w{4}' )  then
                  Case substr(p_107,1,2)
                   when 'МС' then
                     begin  if substr(p_107,4,2) between 1 and 12 then  bRet:=true; else  bRet:=false; end if;
                     exception when others then  bRet:=false; end;
                   when 'КВ' then
                     begin  if substr(p_107,4,2) between 1 and 4 then  bRet:=true; else  bRet:=false; end if;
                     exception when others then  bRet:=false; end;
                   when 'ПЛ' then
                     begin  if substr(p_107,4,2) between 1 and 2 then  bRet:=true; else  bRet:=false; end if;
                     exception when others then  bRet:=false; end;
                   when 'ГД' then
                     begin  if substr(p_107,4,2) between 0 and 0 then  bRet:=true; else  bRet:=false; end if;
                     exception when others then  bRet:=false; end;
                   Else
                    begin  p_perr := to_date(p_107); bRet:=true; exception when others then  bRet:=false;
                    end;
                  end case;
                 Else
                  bRet:=false;
                 end if;
               Else -- количество символов другое
                bRet:=false;
               end case;
             end if;

             if l_state_021017 = true then
               l_str_err_107 := 'б) значение должно иметь 8 знаков (код таможенного органа, который состоит из 8 цифр без разделительных знаков),   при осуществлении таможенных и иных платежей от внешнеэкономической деятельности: Таможенные и иные платежи от внешнеэкономической деятельности определять по условию, если поле 104 "КБК" начинается на 153%, а поле 106 "Основание платежа" принимает сле-дующие значения: "0", "00", "ДЕ", "ПО", "КТ", "ИД", "ИП", "ТУ", "БД", "ИН", "КП", "ДК", "ПК", "КК", "ТК", "ПД", "КВ".';
             else
               l_str_err_107 := 'б) значение должно иметь 8 знаков (код таможенного органа, который состоит из 8 цифр без разделительных знаков),   при осуществлении таможенных и иных платежей от внешнеэкономической деятельности: Таможенные и иные платежи от внешнеэкономической деятельности определять по условию, если поле 104 "КБК" начинается на 153%, а поле 106 "Основание платежа" принимает сле-дующие значения: "0", "00", "ДЕ", "ПО", "КТ", "ИД", "ИП", "ТУ", "БД", "ИН", "КП", "ДК", "ПК", "КК", "ТК".';
             end if;
             if not bRet then
                p_perr:=p_perr||'Реквизит "Налоговый период (107)" : '||lf||
                 'а) значение должно иметь 10 знаков, восемь из которых имеют смысловое значение, а два являются разделительными знаками и заполняются точкой ("."); '||lf||
                 '   первые два знака показателя могут принимать следующие значения: '||lf||
                 '•     "01-31" - если предусмотрена конкретная дата уплаты платежа, то проставляется эта дата в формате "ДД.ММ.ГГГГ" (например, "04.09.2014"); '||lf||
                 '•     "МС" - месячные платежи, имеют вид "МС.ХХ.УУУУ, где ХХ - номер месяца, за который проводится платеж (от 01 до 12), УУУУ - год, за который производится уплата (например, "МС.02.2014"); '||lf||
                 '•     "КВ" - квартальные платежи, имеют вид "КВ.ХХ.УУУУ, где ХХ - номер квартала, за который проводится уплата (от 01 до 04), УУУУ - год, за ко-торый производится уплата (например, "КВ.01.2014"); '||lf||
                 '•     "ПЛ" - полугодовые платежи, имеют вид "ПЛ.ХХ.УУУУ, где ХХ - принимает значение 01 или 02, в зависимости от того за 1 или за 2 полугодие производится платеж, УУУУ - год, за который производится уплата (например, "ПЛ.02.2014"); '||lf||
                 '•     "ГД" - годовые платежи, имеют вид "ГД.00.УУУУ, где УУУУ - год, за кото-рый уплачивается платеж (например, "ГД.00.2014"). '||lf||
                 l_str_err_107||lf||
                 'в) Значение "Налогового периода" может быть равно нулю "0".';
             end if;

            return bRet;
        end;

        procedure check_pkppplat(p_pkppplat in varchar2, p_pPayerAcc  in varchar2, p_perr  in out varchar2) is
            vIACCCUS number;
        begin

            select IACCCUS into vIACCCUS
            from ubrr_acc_v
            where cAccAcc = p_pPayerAcc and cAccCur = util.base_cur and caccprizn = 'О' and rownum = 1;

            -->> 17.09.2017 ubrr belosheykin 17-473.5
            if (pcreatstatus is not null and
               regexp_like(ppayerinn, '^(\d{5}|\d{10})$') and
               not regexp_like(ppayerinn, '^(0+)$')) and
               l_state_021017 = true then
              if p_pkppplat = '0' then
                p_perr:=p_perr||'Если  поле Статус составителя (101) заполнено и ИНН плательщика (60) имеет значение '||
                                'из 10 – ти или 5-ти знаков, то  КПП плательщика (102) не может принимать значение '||
                                'ноль "0".';
              end if;
            end if;
            --<< 17.09.2017 ubrr belosheykin 17-473.5

            if rp_cus.iscustomeringroup(vIACCCUS, 15, 4) = 1 then  -- ИП
              if  p_pkppplat <> '0' then
                p_perr:=p_perr||'Значение реквизита «КПП плательщика» для ИП должно быть заполнено нолем ("0").';
              end if;
            elsif not regexp_like(p_pkppplat, '^\d{9}$') or regexp_like(p_pkppplat,'^00\d+') then
                p_perr:=p_perr||'Значение реквизита «КПП плательщика» для ЮЛ должно содержать 9 знаков (цифр).';
            end if;
        end;
        --<<-- 16.01.2017 Пинаев Д.Е.  #38808 [16-2429.4] Fine Reader: Доработка АБС и ИБ по 107н (по ошибкам ГИС ГМП) - п.2, 3, 4

    /* Корольков Д.А.  03.06.2011  Доработка механизма определения пачек
                                   https://redmine.lan.ubrr.ru/issues/2792  */
    BEGIN
        IF gtotal < gused THEN
            perr :=
                   'Превышено число лицензий АБС Банк XXI Век. Использовано='
                || gused
                || ' доступно='
                || gtotal;
            vret := 'Bad';
            RETURN 'Bad';
        END IF;

        DBMS_TRANSACTION.SAVEPOINT ('BEFORE_REGISTER');
        vret := 'Ok';
        mbunch.put('FREADER', '20', 'pbo1fr= ' || pbo1fr);
        mbunch.put('FREADER', '35', 'pcreatstatus= ' || pcreatstatus);


-- (нач.) UBRR Новолодский А. Ю. Новолодский А. Ю. 04.03.2016 [15-1641.3] АБС: 148-н. Контроль заполнения бюджетных полей (Fine-Reader)
        If
--            pbo1fr In ('PP', 'PT')
             pbo1fr In ('PP', 'IP')-->> 02.12.2016  ubrr MakarovaLU  [16-2308.5]
             --And substr(precipientbic, 7, 3) In ('000', '001', '002') -->> 02.12.2016  ubrr MakarovaLU  [16-2308.5]
            And
            (
                substr(precipientacc, 1, 5) In ('40101', '40302')
                Or
                substr(precipientacc, 1, 5) = '40501' And substr(precipientacc, 14, 1)='2'
                Or
                substr(precipientacc, 1, 5) = '40601' And substr(precipientacc, 14, 1) In ('1' ,'3')
                Or
                substr(precipientacc, 1, 5) = '40701' And substr(precipientacc, 14, 1) In ('1' ,'3')
                Or
                substr(precipientacc, 1, 5) = '40503' And substr(precipientacc, 14, 1)='4'
                Or
                substr(precipientacc, 1, 5) = '40603' And substr(precipientacc, 14, 1)='4'
                Or
                substr(precipientacc, 1, 5) = '40703' And substr(precipientacc, 14, 1)='4'
                Or
                regexp_like(precipientacc,'^('||nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.CACCA'),'0')||')')  --01.02.2021  Зеленко С.А.     [DKBPA-38]  АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
            )
        Then
            perr:=Null;

            If  -- 1
                Not (Length(ppayerinn) In (5, 10, 12))
                Or
                Substr(ppayerinn, 1, 2)='00'
                Or
                Length(ppayerinn)=5 and regexp_count(ppayerinn, '0')=5
            Then
                perr :=perr||'Некорректное значение поля "ИНН плательщика"'||lf;
            End If;

            If  -- 2
                Not Length(precipientinn)=10
                Or
                Substr(precipientinn, 1, 2)='00'
            Then
                perr :=perr||'Некорректное значение поля "ИНН получателя"'||lf;
            End If;

            -->> 17.09.2017 ubrr belosheykin 17-473.5
            c_02_10_2017 := to_date(Pref.Get_Preference(Preference => 'UBRR_CHECK_TAX021017',
                                                        UserName => Pref.c_UniversUser), 'dd.mm.yyyy');

            if pdate >= c_02_10_2017 then
              l_state_021017 := true;
            else
              l_state_021017 := false;
            end if;
            if pbo1fr in ('PP', 'IP') and pcreatstatus = '15' and l_state_021017 = true then
              --add_message('Поле статус составителя (101) не может принимать значение 15 с указанным БО1.');
              perr :=perr||'Для ЮЛ/ИП статус составителя с кодом «15 - Кредитная организация (филиал кредитной '||
                          'организации), платежный агент, организация федеральной почтовой связи, составившие '||
                          'платежное поручение на общую сумму с реестром на перевод денежных средств, принятых '||
                          'от плательщиков - физических лиц»,  не доступен для выбора.'||lf;
            end if;
            --<< 17.09.2017 ubrr belosheykin 17-473.5

           -->>-- 16.01.2017 Пинаев Д.Е.  #38808 [16-2429.4] Fine Reader: Доработка АБС и ИБ по 107н (по ошибкам ГИС ГМП) - п.2, 3, 4
           check_pkppplat(pkppplat, pPayerAcc, perr);
           /* If -- 3.1
                pkppplat<>'0'
                And
                (
                    Not Length(pkppplat)=9
                    Or
                    Substr(pkppplat, 1, 2)='00'
                )
            Then
                perr :=perr||'Некорректное значение поля "КПП плательщика"'||lf;
            End If;*/
           --<<-- 16.01.2017 Пинаев Д.Е.  #38808 [16-2429.4] Fine Reader: Доработка АБС и ИБ по 107н (по ошибкам ГИС ГМП) - п.2, 3, 4

            If -- 3.2
                pkpprec<>'0'
                And
                (
                    Length(pkpprec)<>9
                    Or
                    Substr(pkpprec, 1, 2)='00'
                )
            Then
                perr :=perr||'Некорректное значение поля "КПП получателя"'||lf;
            End If;

            If -- 4
                (
                    pbudcode='0'
                    And
                    (Substr(precipientacc, 1, 5) = '40101'
                     OR regexp_like(precipientacc,'^('||nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.CACCA'),'0')||')') ) --01.02.2021  Зеленко С.А.     [DKBPA-38]  АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
                )
                Or
                (
                    pbudcode<>'0'
                    And
                    (
                        Length(pbudcode)<>20
                        Or
                        regexp_count(pbudcode, '0')=20
                    )
                )
            Then
                perr :=perr||'Некорректное значение поля "104"'||lf;
            End If;

            If -- 5
                (
                    pokatocode='0'
                    And
                    (Substr(precipientacc, 1, 5) = '40101'
                     OR regexp_like(precipientacc,'^('||nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.CACCA'),'0')||')') ) --01.02.2021  Зеленко С.А.     [DKBPA-38]  АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
                )
                Or
                (
                    pokatocode<>'0'
                    And
                    (
                        Not (Length(pokatocode) In (8, 11))
                        Or
                        regexp_count(pokatocode, '0')=8
                        Or
                        regexp_count(pokatocode, '0')=11
                    )
                )
            Then
                perr :=perr||'Некорректное значение поля "105"'||lf;
            End If;
            -->>-- 16.01.2017 Пинаев Д.Е.  #38808 [16-2429.4] Fine Reader: Доработка АБС и ИБ по 107н (по ошибкам ГИС ГМП) - п.2, 3, 4
            /*
            If -- 6
                pdocindex<>0
                And
                (
                    Not (Length(pdocindex) In (20, 25))
                    Or
                    regexp_count(pdocindex, '0') In (20, 25)
                )
            Then
                perr :=perr||'Некорректное значение поля "УИН"'||lf;
            End If;*/
          /*  if pdocindex is null -- должно быть заполнено
               or pdocindex = '0' -- не равно 0
               or Not (Length(pdocindex) In (20, 25)) -- 20 или 25 символов
               or regexp_count(pdocindex, '0') In (20, 25) -- все знаки одновременно не могут принимать значение ноль ("0")
               or nvl(pbudcode, '0')<>'0' and pdocindex=pbudcode --Значение поля 22 "УИН" не должно совпадать со значением поля 104 "КБК" (в случае отличия поля 104 "КБК" от «0»)
            then
                perr :=perr||'Некорректное значение поля "УИН"'||lf;
            end if;*/
            --<<-- 16.01.2017 Пинаев Д.Е.  #38808 [16-2429.4] Fine Reader: Доработка АБС и ИБ по 107н (по ошибкам ГИС ГМП) - п.2, 3, 4

            If -- 7
                pnalpurp<>'0'
                And
                Length(pnalpurp)<>2
            Then
                perr :=perr||'Некорректное значение поля "106"'||lf;
            End If;

            If -- 8
--                Length(trim(translate(pnaldocnum,'0123456789','          ')))>0 -- Ёлгин Ю.А. 03.11.2017 [17-1423] https://redmine.lan.ubrr.ru/issues/47906#note-2
--                Or
                Length(pnaldocnum)> 15
-->>> Ёлгин Ю.А. 03.11.2017 [17-1423] АБС: Поле 108 в бюджетных платежах https://redmine.lan.ubrr.ru/issues/47827#note-6
--                -->> 03.10.2017 ubrr korolkov 17-473.5
--                or
--                (length(pnaldocnum) = 1 and pnaldocnum != '0')
--                --<< 03.10.2017 ubrr korolkov 17-473.5
--<<< Ёлгин Ю.А. 03.11.2017 [17-1423] АБС: Поле 108 в бюджетных платежах https://redmine.lan.ubrr.ru/issues/47827#note-6
                /*Or
                (
                    pnaldocnum='0'
                    And
                    pcreatstatus In ('03', '16', '19', '20', '24')
                    And
                    pdocindex Is Null
                    And
                    Length(ppayerinn)<>10
                )*/
            Then
                perr :=perr||'Некорректное значение поля "108"'||lf;
            End If;

            If -- 9
                pnaldocdate<>'0'
            Then
                If Length(pnaldocdate)>15
                Then
                    perr :=perr||'Некорректное значение поля "109"'||lf;
                End If;

                Declare -- 9
                    dCheckDate Date;
                Begin
                    Begin
                        /*iNum:=to_number(substr(pnaldocdate, 1, 2));
                        If iNum Not Between 1 And 31 Then
                            perr :=perr||'Некорректное значение поля "109"'||lf;
                        End If;
                        iNum:=to_number(substr(pnaldocdate, 4, 2));
                        If iNum Not Between 1 And 12 Then
                            perr :=perr||'Некорректное значение поля "109"'||lf;
                        End If;
                        iNum:=to_number(substr(pnaldocdate, 7, 4));
                        \*If iNum Not Between 2000 And 2050 Then
                            perr :=perr||'Некорректное значение поля "109"'||lf;
                        End If;*\
                        If Substr(pnaldocdate, 3, 1) <> '.' And Substr(pnaldocdate, 5, 1) <> '.' Then
                            perr :=perr||'Некорректное значение поля "109"'||lf;
                        End If;*/
                        dCheckDate:=to_date(substr(pnaldocdate, 1, 10), 'dd.mm.rrrr');
                    Exception
                        When Others Then
                            perr :=perr||'Некорректное значение поля "109"'||lf;
                    End;
                End;
            End If;

            If -- 10
                pcreatstatus In ('03','16','19','20','24')
                And
                (
                    pnaldocnum='0' -- 108
                    Or
                    pdocindex='0'  -- 22
                )
                And
                (
                    Length(ppayerinn)<>12
                    Or
                    Substr(ppayerinn, 1, 2)='00'
                )
            Then
                perr :=perr||'Некорректное значение поля "ИНН плательщика"'||lf;
            End If;

            If -- 11
                pcreatstatus In ('09', '10', '11', '12', '13', '14')
                And
                (
                    Length(ppayerinn)<>12
                    Or
                    Substr(ppayerinn, 1, 2)='00'
                )
            Then
                perr :=perr||'Некорректное значение поля "ИНН плательщика"'||lf;
            End If;

            If perr Is Not Null Then
                perr :=perr|| lf;
                vret := 'Bad';
                RETURN 'Bad';
            End If;
        End If;
-- (кон.) UBRR Новолодский А. Ю. Новолодский А. Ю. 04.03.2016 [15-1641.3] АБС: 148-н. Контроль заполнения бюджетных полей (Fine-Reader)

--(нач.) UBRR Новолодский А. Ю. 26.03.2013 https://redmine.lan.ubrr.ru/issues/6821
        If pbo1fr = 'PT' Then
            If pdate>=to_date('01.04.2013', 'dd.mm.rrrr') Then
                Null;
        --- (нач.) UBRR Новолодский А. Ю. 11.05.2012
            ElsIf Instr(Upper(nvl(vpaycond, 'zzz')), 'С АКЦЕПТОМ')=0 Then
                    perr :=perr||'Условие оплаты должно быть <С акцептом>.'|| lf;
                    RETURN 'Bad';
        --- (кон.) UBRR Новолодский А. Ю. 11.05.2012
            End If;
        End If;
--(кон.) UBRR Новолодский А. Ю. 26.03.2013 https://redmine.lan.ubrr.ru/issues/6821

--- (нач.) UBRR Новолодский А. Ю.   16.07.2012
        If pbo1fr = 'PT' And substr(vpaycond, 1, 1)='!' Then
            vpaycond:=replace(vpaycond, '!');
            bPT2TRN:=True;
        End If;
--- (кон.) UBRR Новолодский А. Ю.   16.07.2012

        IF pcreatstatus IS NOT NULL AND pbo1fr <> 'PT' THEN
            IF pbudcode IS NULL THEN
                perr :=
--                     perr||'Не задан код бюджетной организации налогового платежа. Принимаем равным нулю.'|| lf;
                       perr||'Не задан код бюджетной организации налогового платежа.'|| lf;
                --   vret    := 'Bad';
                RETURN 'Bad';
-->>>ubrr 05.12.2007 Кузнецов Е.В. перенос собственного функционала из АБС v4
-- (нач.) UBRR Новолодский А. Ю. Новолодский А. Ю. 04.03.2016 [15-1641.3] АБС: 148-н. Контроль заполнения бюджетных полей (Fine-Reader)
--- закомментировал
            /*ELSIF LENGTH (pbudcode) <> 20 AND pdate >= TO_DATE ('01.01.2005', 'dd.mm.yyyy') THEN
                                                                                      --lip 03/02/05
                perr := perr || 'Ошибка в коде бюджетной организации налогового платежа' || lf;
                                                                                 --end lip 03/02/05
                RETURN 'Bad';*/
-- (кон.) UBRR Новолодский А. Ю. Новолодский А. Ю. 04.03.2016 [15-1641.3] АБС: 148-н. Контроль заполнения бюджетных полей (Fine-Reader)
--<<<ubrr 05.12.2007 Кузнецов Е.В. перенос собственного функционала из АБС v4
            END IF;

--<<<ubrr 02.02.2010 Буткевич Д.А. добавлена проверка на наличие № документа
            IF pdocnum  IS NULL THEN
                perr := perr || 'При регистрации документа не присвоился № документа' || lf;
                vret := 'Bad';
            END IF;

--<<<ubrr 02.02.2010 Буткевич Д.А. добавлена проверка по полю ОКАТО
            IF pokatocode IS NULL or UTIL.Is_Number(pokatocode) = FALSE THEN
--        perr := perr || 'Не задано ОКАТО налогового платежа. Принимаем равным нулю.' || lf;
                perr := perr || 'Неправильно задано ОКАТО налогового платежа.'
                             || lf; -- ubrr belosheykin 17.03.2017 орфографические правки
                --   vret    := 'Bad';
                RETURN 'Bad';
            END IF;

--<<<ubrr 02.02.2010 Буткевич Д.А. добавлена проверка по полю КПП плательщика
            IF UTIL.Is_Number(pkppplat) = FALSE THEN
                perr := perr || 'Неправильно задан КПП плательщика' || lf; -- ubrr belosheykin 17.03.2017 орфографические правки
                vret := 'Bad';
            END IF;

--<<<ubrr 02.02.2010 Буткевич Д.А. добавлена проверка по полю КПП
            IF UTIL.Is_Number(pkpprec) = FALSE THEN
                perr := perr || 'Неправильно задан КПП получателя' || lf; -- ubrr belosheykin 17.03.2017 орфографические правки
                vret := 'Bad';
            END IF;

            IF pokatocode IS NULL THEN
--        perr := perr || 'Не задано ОКАТО налогового платежа. Принимаем равным нулю.' || lf;
                perr := perr || 'Не задано ОКАТО налогового платежа.' || lf;
                --   vret    := 'Bad';
                RETURN 'Bad';
            END IF;

            IF pnalpurp IS NULL THEN
--        perr := perr || 'Не задано назначение налогового платежа. Принимаем равным нулю.' || lf;
                perr := perr || 'Не задано назначение налогового платежа.' || lf;
                --   vret    := 'Bad';
                RETURN 'Bad';
            END IF;

            IF pnalperiod IS NULL THEN
--        perr := perr || 'Не задан период налогового платежа. Принимаем равным нулю.' || lf;
                perr := perr || 'Не задан период налогового платежа.' || lf;
                --   vret    := 'Bad';
                RETURN 'Bad';
            -->>-- 16.01.2017 Пинаев Д.Е.  #38808 [16-2429.4] Fine Reader: Доработка АБС и ИБ по 107н (по ошибкам ГИС ГМП) - п.2, 3, 4
            ELSE
                if not check_pnalperiod( p_107 => pnalperiod, p_104 => pbudcode, p_106 => pnalpurp, p_perr => perr ) then
                  return 'Bad';
                end if;
            --<<-- 16.01.2017 Пинаев Д.Е.  #38808 [16-2429.4] Fine Reader: Доработка АБС и ИБ по 107н (по ошибкам ГИС ГМП) - п.2, 3, 4
            END IF;

            IF pnaldocnum IS NULL THEN
--        perr := perr || 'Не задан номер документа налогового платежа. Принимаем равным нулю.' || lf;
                perr := perr || 'Не задан номер документа налогового платежа.' || lf;
                --   vret    := 'Bad';
                RETURN 'Bad';
            END IF;

            IF pnaldocdate IS NULL THEN
--        perr := perr || 'Не задана дата налогового платежа. Принимаем равной нулю.' || lf;
                perr := perr || 'Не задана дата налогового платежа.' || lf;
                --   vret    := 'Bad';
                RETURN 'Bad';
            END IF;

            /* -- 26.04.2018  Киселев А.А.     [17-1267.1] АБС: Поле 110 в распоряжениях о переводе средств
            IF pnaltype IS NULL THEN
--        perr := perr || 'Не задан тип налогового платежа. Принимаем равным нулю.' || lf;
                perr := perr || 'Не задан тип налогового платежа.' || lf;
                --   vret    := 'Bad';
                RETURN 'Bad';
            END IF;
            */ -- 26.04.2018  Киселев А.А.     [17-1267.1] АБС: Поле 110 в распоряжениях о переводе средств
        END IF;

        -->>26.07.2019 Баязитов [18-742.1] АБС: Новые параметры по запрету кредитовых зачислений по внутрибанку
        declare
          cvReason   varchar2(200);
        begin
          ubrr_logging_pack.log_ex('UFREADER check_deny_cred_inbank: precipientacc='||precipientacc||'; precipientbic='||precipientbic||'; precipient='||precipient||'; ppurpose='||ppurpose);
          if ubrr_xxi5.ubrr_zaa_abs_util.check_deny_cred_inbank(cvReason, precipientacc, precipientbic, precipient, ppurpose) = 1 then
                    perr := perr || cvReason || lf;
            return 'Bad';
                  end if;
        exception
          when others then
            ubrr_logging_pack.log_ex('UFREADER check_deny_cred_inbank: ' || dbms_utility.format_error_stack || chr(10) || dbms_utility.format_error_backtrace);
        end;
        --<<26.07.2019 Баязитов [18-742.1] АБС: Новые параметры по запрету кредитовых зачислений по внутрибанку

        -- определение БО1
        vbo1 := getbo1 (precipientbic, pbo1fr, vpaycond, ppayerbic, vbo2, bPT2TRN, precipientacc );
        -->> 26.04.2018  Киселев А.А.     [17-1267.1] АБС: Поле 110 в распоряжениях о переводе средств
            --===========================================================
            if  regexp_like(ppayeracc,   '^4(0[1-7]|0802|0807|0821|2309)') and
              regexp_like(precipientacc, '^40(101|302|501\d{8}2|601\d{8}[13]|701\d{8}[13]|503\d{8}4|603\d{8}4|703\d{8}4)')
              and ppayeracc not like '47416%'
              and (vbo1 in (2, 4, 11, 23, 26, 28) and substr(ppayeracc, 6, 3) = '810')
           then
             null;
           else
               -->> 23.04.2018 Киселев А.А. [17-1267.1] АБС: Поле 110 в распоряжениях о переводе средств
               --===============================================
               -- для небюджентных платежей:
               -- (если поле 110 имеет некорректный формат) или 1 или пусто
               -- Выводить предупреждающее сообщение
               -- о некорректном формате с указанием требования к формату
               --===============================================
               IF pnaltype IS NOT NULL AND pnaltype <> '1' AND pdate >= to_date(pref.get_global_preference('UBRR_CHECK_TAX110'), 'dd.mm.yyyy')
                 AND NVL(vbo2,0) NOT IN (7,9)
                 THEN
                   perr := perr || 'Поле 110 - "Код выплат" может быть пустым или заполнено значением "1"' || lf;
                   RETURN 'Bad';
               END IF;
            END IF;
            --<< 26.04.2018  Киселев А.А.     [17-1267.1] АБС: Поле 110 в распоряжениях о переводе средств
        -->> 29.12.2015 ubrr korolkov 15-537.1
        terr := ubrr_zaa_abs_util.Check_40821(p_Date      => util.current_date,
                                              p_OpType    => vbo1,
                                              p_PayerAcc  => pPayerAcc,
                                              p_RecipAcc  => pRecipientAcc,
                                              p_PayerName => pPayer,
                                              p_RecipName => pRecipient,
                                              p_PayerBik  => pPayerbic,
                                              p_RecipBik  => pRecipientBic,
                                              p_Purp      => pPurpose);
        if terr is not null then
            perr := /*perr ||*/ terr || lf; -- 17.04.2017 ubrr korolkov 16-2959.4 #41344#note-8
            RETURN 'Bad';
        end if;
        --<< 29.12.2015 ubrr korolkov 15-537.1
        -->>UBRR 19.01.2017 Коломиец Д.С. [16-2680.3] Fine Reader: Контроль количества символов (210) в назначении платежа
        if terr is null /*and rDP.COPER not IN ('IBANK2', 'CLIENTBANK', 'CORREQTS')*/ then
          terr:=ubrr_util.not_reg_trn(vbo1, pPayerAcc, pPurpose, pRecipientBic, util.current_date);
          if terr is not null then
            perr := perr || terr || lf;
            RETURN 'Bad';
          end if;
        end if;
        --<<UBRR 19.01.2017 Коломиец Д.С. [16-2680.3] Fine Reader: Контроль количества символов (210) в назначении платежа

-- UBRR (нач.) Новолодский А. Ю. 15.07.2011 контроль адреса мнх клиента
        If (precipientacc Like '30111%' Or precipientacc Like '30114%' Or
                precipientacc Like '30122%' Or precipientacc Like '30123%' Or
                precipientacc Like '30230%' Or precipientacc Like '30231%')
            And psum>15000.00 Then
                bIsForeign:=True;
                Declare
                    C Integer;
                Begin
                    Select Count(1)
                    Into C
                    From Dual
                    Where vPayer like '%//%//';
                    If C=0 Then
                        perr := perr || 'В поле "Наименование плательщика" д.б. адрес местонахождения и кол-во символов не должно превышать 160' || lf;
                        vret := 'Bad';
                    End If;
                End;

            If Length(vPayer)>254 Then
                vPayer:=substr(vPayer,1,254)||'//';
            End If;

        End If;
-- UBRR (кон.) Новолодский А. Ю. 15.07.2011 контроль адреса мнх клиента

-->>>ubrr 05.12.2007 Кузнецов Е.В. перенос собственного функционала из АБС v4---
        IF pdate IS NULL THEN
            perr := perr || 'Отсутствует дата платежного документа' || lf;
            vret := 'Bad';
        END IF;

        -- Определим, есть ли документы на картотеке2 , и если есть - отвергнем регистрацию
        -- добавил Михайловский 09,2003
        --IF ACC_INFO.GetDocsSumOnFile(pPayerAcc,'RUR','2') <> 0 THEN
        --   perr := perr || 'Есть документы в картотеке 2' || lf;
        --   vret := 'Bad';
        --END IF;

        -- UBRR katyuhin >>>
        IF ubrr_tert_fil.get_filid (ppayeracc, 'RUR') IS NULL THEN
            v_cdtplace := '1';

            -- Если счет плательщика принадлежит к УБРиР, то наличие К2 запрещает регистрацию (добавил Михайловский 09,2003)
            --IF acc_info.getdocssumonfile (ppayeracc, 'RUR', '2') <> 0 THEN
            --  perr := perr || 'Есть документы в картотеке 2' || lf;
            --  vret := 'Bad';
            --END IF;
        ELSE
            v_cdtplace := '2';
        END IF;

        IF ubrr_tert_fil.get_filid (precipientacc, 'RUR') IS NULL THEN
            v_cctplace := '1';
        ELSE
            v_cctplace := '2';
        END IF;

        -- UBRR katyuhin <<<

        --<<<ubrr 05.12.2007 Кузнецов Е.В. перенос собственного функционала из АБС v4---
        IF pbo1fr = 'PT' AND INSTR (UPPER (vpaycond), 'БЕЗ АКЦЕПТА', 1, 1) = 0 THEN
            vincdate := NVL (pref.get_global_preference (UPPER ('DNV.Card1_ShiftAccept')), '1');

            -- DELETE FROM bom WHERE cbomprocess = 'FREADER';
            mbunch.put('FREADER', '1', 'pdate = ' || to_char(pdate, 'DD.MM.YYYY'));
            mbunch.put('FREADER', '2', 'vincdate = ' || vincdate);
            mbunch.put('FREADER', '3', 'pvaldate = ' || pvaldate);
            IF LENGTH (TRIM (pvaldate)) = 0 OR pvaldate IS NULL THEN
                --   vValDate:=UTIL.Current_Date+6;
                vvaldate := pcaliso.next_workday (util.base_cur, util.CURRENT_DATE, 5 + vincdate);
            mbunch.put('FREADER', '4', 'vvaldate0 = ' || to_char(vvaldate, 'DD.MM.YYYY'));
            ELSE
                BEGIN
                    vacceptter := TO_NUMBER (pvaldate, '999');
                    --vValDate:=UTIL.Current_Date+vAcceptTer+1;
                    vvaldate :=
                        pcaliso.next_workday (util.base_cur,
                                              util.CURRENT_DATE,
                                              vacceptter + vincdate
                                             );
                mbunch.put('FREADER', '5', 'vvaldate1 = ' || to_char(vvaldate, 'DD.MM.YYYY'));
                EXCEPTION
                    WHEN OTHERS THEN
                        BEGIN
                            vvaldate := TO_DATE (pvaldate, 'DD.MM.YYYY');
                            mbunch.put('FREADER', '6', 'vvaldate2 = ' || to_char(vvaldate, 'DD.MM.YYYY'));
                        EXCEPTION
                            WHEN OTHERS THEN
                                perr := perr || 'Неверно задан срок для акцепта.' || lf;
                                vret := 'Bad';
                        --return 'Bad';
                        END;
                END;
            END IF;
        ELSE
            vvaldate := NULL;
        END IF;

        -->> 29.12.2015 ubrr korolkov 15-537.1 перенёс выше
        -- определение БО1
        -- vbo1 := getbo1 (precipientbic, pbo1fr, vpaycond, ppayerbic, vbo2, bPT2TRN, precipientacc );
        --<< 29.12.2015 ubrr korolkov 15-537.1
--- (нач.) UBRR Новолодский А. Ю.   31.10.2013 12-2029 для ПТ с счетами ССБ БО1=22 - в TRN
        If pbo1fr = 'PT' And Not bPT2TRN And vbo1 = '22' Then
            bPT2TRN:=True;
        End If;
--- (кон.) UBRR Новолодский А. Ю.   31.10.2013 12-2029 для ПТ с счетами ССБ БО1=22 - в TRN

-- (нач.) UBRR Новолодский А. Ю. 06.04.2015 [15-219] АБС: Запрет зачисления мб платежей на КРС
        If vbo1='2' And ppayerinn Is Not Null And precipientinn Is Not Null Then
            If ubrr_xxi5.ubrr_bbt_compare.Is_Acc_In_CatGrp(precipientacc, 'RUR', 333, 2) And ppayerinn<>precipientinn Then
                Declare
                    dRKODate Date;
                Begin
                    select nvl(DACCLASTOPER, to_date('01.01.2010', 'dd.mm.rrrr'))
                    into dRKODate
                    from ubrr_acc_v
                    where caccacc=precipientacc and caccprizn='О' and rownum=1;
                    If dRKODate>=to_date('01.05.2015', 'dd.mm.rrrr')
                        Or ubrr_xxi5.ubrr_bbt_compare.Is_Acc_In_CatGrp(precipientacc, 'RUR', 333, 3)
                    Then
                        perr:='Зачисление на чужой корпоративный счет запрещено';
                        RETURN 'Bad';
                    End If;
                Exception
                    When Others Then Null;
                End;
            End If;
        End If;
-- (кон.) UBRR Новолодский А. Ю. 06.04.2015 [15-219] АБС: Запрет зачисления мб платежей на КРС

--- (нач.) UBRR Новолодский А. Ю. 02.02.2015  [15-22] АБС: БО2=8 при списании инкассовых из картотеки
        If substr(vpurpose,1,1)='*' Then
            vpurpose:=substr(vpurpose,2);
            If pbo1fr = 'IP' And vbo1 = '23' Then
                vbo2:=8;
                suboptype:=8;
            End If;
        End If;
--- (кон.) UBRR Новолодский А. Ю. 02.02.2015  [15-22] АБС: БО2=8 при списании инкассовых из картотеки

-->>>ubrr 05.12.2007 Кузнецов Е.В. перенос собственного функционала из АБС v4---
--    IF vBO1 = 2 AND ubrr_tert_fil.get_filid(pRecipientAcc,'RUR') IS NOT NULL THEN
--      vSSB := TRUE;
--      vBO1 := 4;
--    END IF;

        -- UBRR katyuhin >>>
        IF vbo1 = 2 THEN
            IF v_cdtplace <> v_cctplace THEN
                v_nhiddenbo1 := 2;
                vbo1 := 4;
            END IF;
        END IF;

-- UBRR katyuhin <<<

        -- djachenko TZ 289
        IF ubrr_djko_cd_tech.checkbo1 (vbo1, pdate) = 1 THEN
            vrecipientacc :=
                ubrr_djko_cd_tech.getnewtechacc (SUBSTR (TRIM (vpurpose), 1, 20),
                                                 util.base_cur,
                                                 precipientacc
                                                );

            IF vrecipientacc IS NOT NULL THEN
                vregistrintobtn := TRUE;
            END IF;
        END IF;

        -- Абрамов А.В. UBRR_BTN
        IF precipientacc IS NULL AND vrecipientacc IS NULL THEN
            perr := perr || 'Документ необходимо маршрутизировать на забаланс' || lf;
            vret := 'Bad';
        END IF;

        -- lipchak 02/06/04 begin
        -- блокировка корреспонденции счета с самим собой
        IF vbo1 = 2 AND ppayeracc = precipientacc THEN
            perr := perr || 'Дт не может быть равен Кт для вн. док-тов' || lf;
            vret := 'Bad';
        END IF;

    -- lipchak 02/06/04 end
--<<<ubrr 05.12.2007 Кузнецов Е.В. перенос собственного функционала из АБС v4---

-- (нач.) UBRR Новолодский А. Ю. 13.04.2015 [14-1134] АБС: Доработка экспорта документов из ПО FineReader For Bank 7.0 в АБС
        -- определение вида опреации
        if pvo is not null then
            vvo := pvo;
        else
            vvo := idoc_util.get_defaultvo (vbo1);
        end if;
-- (кон.) UBRR Новолодский А. Ю. 13.04.2015 [14-1134] АБС: Доработка экспорта документов из ПО FineReader For Bank 7.0 в АБС

        -- определение способа доставки
-->>>ubrr katyuhin 16.04.2005 - begin
        -->> 30.05.2016 ubrr korolkov 16-1808.11.30
        if ubrr_util.IsVuz = 1 then
            begin
                select iAccOtd
                into vOtdNum
                from ubrr_acc_v
                where cAccAcc = pPayerAcc and cAccCur = util.base_cur and caccprizn = 'О' and rownum = 1;
            exception
                when no_data_found then
                    vOtdNum := null;
            end;
        else
        --<< 30.05.2016 ubrr korolkov 16-1808.11.30
            BEGIN
                SELECT usr.iusrbranch
                  INTO vOtdNum
                  FROM usr
                 WHERE usr.cusrlogname = USER;
            EXCEPTION
                WHEN OTHERS THEN
                    vOtdNum := NULL;
            END;
        end if;

        IF vOtdNum IS NOT NULL THEN

            IF pdeliveryway IS NULL THEN
                vdelway := usr_getdelway (vOtdNum, vbo1);
            END IF;

            -->> korolkov (-begin-)
            -- Проверим precipientbic
            begin
                select count(*)
                into vOurBic
                from ubrr_smr
                where csmrmfo8 = precipientbic;
            exception when others then vOurBic := 0;
            end;

            -- Определим режим
            if ( util.is_acc_in_catgrp(ppayeracc,util.base_cur,112,6) or  -- Эконом
                 util.is_acc_in_catgrp(ppayeracc,util.base_cur,112,8)
                 -->> 28.06.2018 Пинаев Д.[18-464] Доп к [15-43] АБС: Новый пакет услуг с авансовой оплатой за пакет платежей)
                 or util.is_acc_in_catgrp(ppayeracc,util.base_cur,112,97) -- "Эконом c 01.07.2018"
                 --<< 28.06.2018 Пинаев Д.[18-464] Доп к [15-43] АБС: Новый пакет услуг с авансовой оплатой за пакет платежей)
                 or util.is_acc_in_catgrp(ppayeracc,util.base_cur,112,67)    -- 07.02.2019 Ризанов Р.Т. Тарифный план "Все просто !" [18-58411] АБС: ТП "Промо" в режиме "Эконом"
                 or util.is_acc_in_catgrp(ppayeracc,util.base_cur,112,1018)  -- 07.02.2019 Ризанов Р.Т. Тариф "Проще простого"       [18-58411] АБС: ТП "Промо" в режиме "Эконом"
                 )
            then vEcon := 1;
            else vEcon := 0;
            end if;

            mbunch.put('FREADER', '24', 'vEcon= '   ||vEcon);
            mbunch.put('FREADER', '22', 'vOtdNum= ' ||vOtdNum);
            mbunch.put('FREADER', '23', 'vbo1= '    ||vbo1);
            mbunch.put('FREADER', '26', 'vOurBic= ' ||vOurBic);

            -- Уберем "!" из назначения для категории/группы 3/12
            if util.is_acc_in_catgrp(ppayeracc,util.base_cur,3,12) then
                vPurp := replace(vpurpose,'!');
            else
                vPurp := vpurpose;
            end if;

            -- UBRR katyuhin >>>
            if vbo1 not in (2,3,4,5,14,25,26,99,23,53,15,21,22,52,55) then
                vibatnum := getbatchnumber (vOtdNum, NVL (v_nhiddenbo1, vbo1));
            -- Внутрибанк
            elsif (/*vbo1 in (2,3,14,25,26,99) or*/ vOurBic >= 1) then
                vibatnum := substr(to_char(getbatchnumber (vOtdNum, NVL (v_nhiddenbo1, vbo1))),0,2) || '00';
            -- Межбанковское дебетовое и кредитовое платежное поручение
            elsif vbo1 in (4,5) then
                -- Бюджетный документ, если заполнены все налоговые поля
                if   pkppplat     is not null
                 and pkpprec      is not null
                 and pcreatstatus is not null
                 and pbudcode     is not null
                 and pokatocode   is not null
                 and pnalpurp     is not null
                 and pnalperiod   is not null
                 and pnaldocnum   is not null
                 and pnaldocdate  is not null
                 and pnaltype     is not null
                 --and pdocindex    is not null -- UBRR Новолодский А. Ю. 13.04.2015 [14-1134] АБС: Доработка экспорта документов из ПО FineReader For Bank 7.0 в АБС
                then vBudg := 1;
                else vBudg := 0;
                end if;
                mbunch.put('FREADER', '27', 'vBudg= '||vBudg);
                --
                if vEcon = 1 then
                    if (vBudg = 0 and instr(vPurp,'!') > 0) -- Не в бюджет с "!" в назначении
                    then
                        vibatnum := substr(to_char(getbatchnumber (vOtdNum, NVL (v_nhiddenbo1, vbo1))),0,2) || '01';
                    else
                        vibatnum := substr(to_char(getbatchnumber (vOtdNum, NVL (v_nhiddenbo1, vbo1))),0,2) || '02';
                    end if;
                else
                    vibatnum := substr(to_char(getbatchnumber (vOtdNum, NVL (v_nhiddenbo1, vbo1))),0,2) || '01';
                end if;
            -- Инкассовое поручение, платёжное требование
            elsif vbo1 in (23,53,15,21,22,52,55) then
                if /*nvl(pdeliveryway,'E') = 'E' and */ precipientbic like '0465%' then
                    if vEcon = 1 then
                        vibatnum := substr(to_char(getbatchnumber (vOtdNum, NVL (v_nhiddenbo1, vbo1))),0,2) || '02';
                    else
                        vibatnum := substr(to_char(getbatchnumber (vOtdNum, NVL (v_nhiddenbo1, vbo1))),0,2) || '01';
                    end if;
                elsif /*pdeliveryway = 'P' and*/ precipientbic not like '0465%' then
                    vibatnum := substr(to_char(getbatchnumber (vOtdNum, NVL (v_nhiddenbo1, vbo1))),0,2) || '04';
                end if;
            end if;
            mbunch.put('FREADER', '21', 'vibatnum= '||vibatnum);
            -- UBRR katyuhin <<<
            --<< korolkov (-end-)
        END IF;


-- (нач) UBRR Новолодский плат. в иностр. банк
        If /*Length(vPayer)>160 And */bIsForeign Then
            vibatnum:=777;
        End If;
-- (кон) UBRR Новолодский плат. в иностр. банк
--<<<ubrr katyuhin 16.04.2005 - end

        IF vbo1 IN (15, 22, 23) THEN
            vdelway := '?';
        ELSE
            vdelway := getdelway (pdeliveryway, RTRIM (precipientbic));
        END IF;

        -- Проверка рекивзитов корреспондента
        IF check_correspondent (terr,
                                precipientbic,
                                precipientcoracc,
                                precipientacc,
                                precipientinn
                                             -->>>Лобик Д.А.ubrr 12.01.2007 надо учитывать дату, с которой действует закрытие счета
           ,
                                TRUNC (GREATEST (util.CURRENT_DATE, NVL (pdate, SYSDATE), SYSDATE))
                               --<<<Лобик Д.А.ubrr 12.01.2007 надо учитывать дату, с которой действует закрытие счета
                               ) = -1 THEN
            perr := perr || terr || lf;
            vret := 'Bad';
        --return 'Bad';
        END IF;
        
        -->>01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
        --проверка наименование банка по ТОФК
        IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_paybikdt(par_type         => vbo1,
                                                                   par_payeraccount => ppayeracc,
                                                                   par_bik_new      => precipientbic)      
         THEN

          IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_bnamea_of_ed807(par_bik        => precipientbic,
                                                                            par_сcoracca   => precipientcoracc,
                                                                            par_bnamea     => precipientbank,
                                                                            par_msg        => terr) THEN
            
            perr := perr || 'Необходимо изменить наименование банка получателя на "'||terr ||'"'||lf;
            vret := 'Bad';
          END IF;                                                                       
        
        END IF;
        --<<01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021          

        -- определение был ли данный документ уже введен
        IF NOT isdocduplicated (terr, pdocnum, pdate, ppayeracc, precipientacc, psum) THEN
            perr := perr || terr || lf;
            vret := 'Bad';
        --return 'Bad';
        END IF;

        -- определение был ли данный документ уже введен в отложенные платежи
        -- UBRR katyuhin >>>
        --IF v_cdtplace = '2' THEN
            IF NOT isdocduplicateddp (terr, pdocnum, pdate, ppayeracc, precipientacc, psum) THEN
                perr := perr || terr || lf;
                vret := 'Bad';
            --return 'Bad';
            END IF;
        --END IF;

        -- UBRR katyuhin <<<

        /* -->>>ubrr так как постановка на картотеку не используется для ССБ и УБРиР
    -- определение был ли данный документ уже введен на картотеку
    IF NOT isdocduplicatedoncard(terr, pdocnum, pdate, ppayeracc, precipientacc, psum)
    THEN
      perr := perr || terr || lf;
      vret := 'Bad';
      --return 'Bad';
    END IF;
*/
   --<<<ubrr так как постановка на картотеку не используется для ССБ и УБРиР

-- (нач.) UBRR 17.09.2013  Новолодский А.Ю. 12-124 Отключаем штатный функционал проверки признака счета

/**************************************************************************************/
/* Проверка счета плательшика                                                         */
/**************************************************************************************/
/*    cdocstate := idoc_util.check_account(terr, ppayeracc, util.base_cur,ppriority);
-- UBRR katyuhin >>>

        IF v_cdtplace <> '1' THEN
            -- Для плательщика ССБ
            IF cdocstate = 'ACC_NOT_FOUND' THEN
                perr := perr || 'Счет плательщика ' || ppayeracc || ' не найден.' || lf;
                vret := 'Bad';
            --return 'Bad';
            ELSIF cdocstate = 'ACC_CLOSED' THEN
                perr := perr || 'Счет плательщика ' || ppayeracc || ' закрыт.' || lf;
                vret := 'Bad';
            --return 'Bad';
            ELSIF cdocstate = 'ACC_ARRESTED' AND vbo1 NOT IN (3, 15) THEN
                vret := '-';
                perr := perr || 'Счет плательщика ' || ppayeracc || ' арестован.' || lf;
            -- return 'Bad';
            ELSIF cdocstate = 'ACC_BLOCKED' AND vbo1 NOT IN (3, 15) THEN
                vret := '-';
        mbunch.put('FREADER', '7', 'Счет плательщика блокирован! ');
                perr := perr || 'Счет плательщика ' || ppayeracc || ' блокирован.' || lf;
            -- return 'Bad';
            ELSIF cdocstate = 'ACC_PARTLY_BLOCKED' AND vbo1 NOT IN (3, 15) THEN
                --   vret := '-';
                perr := perr || 'Счет плательщика ' || ppayeracc || ' частично блокирован.' || lf;
            -- return 'Bad';
            END IF;
        ELSE
            -- Для плательщика УБРиР
            IF cdocstate = 'ACC_NOT_FOUND' THEN
                perr := 'Счет плательщика ' || ppayeracc || ' не найден.';
                vret := '-';
            ELSIF cdocstate = 'ACC_CLOSED' THEN
                perr := 'Счет плательщика ' || ppayeracc || ' закрыт.';
                vret := '-';
            ELSIF cdocstate = 'ACC_ARRESTED' THEN
                perr := 'Счет плательщика ' || ppayeracc || ' арестован.';
                vret := '-';
            ELSIF cdocstate = 'ACC_BLOCKED' THEN
                perr := 'Счет плательщика ' || ppayeracc || ' блокирован.';
        mbunch.put('FREADER', '7', 'Счет плательщика блокирован! ');
                vret := '-';
            ELSIF cdocstate = 'ACC_PARTLY_BLOCKED' THEN
                perr := 'Счет плательщика ' || ppayeracc || ' частично блокирован.';
                vret := '-';
            END IF;
        END IF;

        -- UBRR katyuhin <<<
*/
-- (кон.) UBRR 17.09.2013  Новолодский А.Ю. 12-124 Отключаем штатный функционал проверки признака счета

        IF vibatnum IS NULL or vibatnum in (0,1,2,4) THEN        -->>><<<ubrr 05.12.2007 Кузнецов Е.В. перенос собственного функционала из АБС v4---
            -->> korolkov (-begin-)
                  -- Определим режим
                  if ( util.is_acc_in_catgrp(ppayeracc,util.base_cur,112,6) or  -- Эконом
                       util.is_acc_in_catgrp(ppayeracc,util.base_cur,112,8)
                       -->> 28.06.2018 Пинаев Д.[18-464] Доп к [15-43] АБС: Новый пакет услуг с авансовой оплатой за пакет платежей)
                       or util.is_acc_in_catgrp(ppayeracc,util.base_cur,112,97) -- "Эконом c 01.07.2018"
                       --<< 28.06.2018 Пинаев Д.[18-464] Доп к [15-43] АБС: Новый пакет услуг с авансовой оплатой за пакет платежей)
                       or util.is_acc_in_catgrp(ppayeracc,util.base_cur,112,67)    -- 07.02.2019 Ризанов Р.Т. Тарифный план "Все просто !" [18-58411] АБС: ТП "Промо" в режиме "Эконом"
                       or util.is_acc_in_catgrp(ppayeracc,util.base_cur,112,1018)  -- 07.02.2019 Ризанов Р.Т. Тариф "Проще простого"       [18-58411] АБС: ТП "Промо" в режиме "Эконом"
                      )
                    then vEcon := 1;
                  else vEcon := 0;
                  end if;
                  -- Уберем "!" из назначения для категории/группы 3/12
                  if util.is_acc_in_catgrp(ppayeracc,util.base_cur,3,12)
                   then vPurp := replace(vpurpose,'!');
                  else vPurp := vpurpose;
                  end if;
                        if vbo1 not in (2,3,4,5,14,25,26,99,23,53,15,21,22,52,55)
                         then
                        vibatnum := NVL (pbatnum, getbatchnumber (vbo1, USER));
                        -- Внутрибанк
                        elsif (/*vbo1 in (2,3,14,25,26,99) or */ vOurBic >= 1)
                         then vibatnum := substr(to_char(NVL (pbatnum, getbatchnumber (vbo1, USER))),0,2) || '00';
                        -- Межбанковское дебетовое и кредитовое платежное поручение
                        elsif vbo1 in (4,5) then
                            -- Бюджетный документ, если заполнены все налоговые поля
                            if   pkppplat     is not null
                             and pkpprec      is not null
                             and pcreatstatus is not null
                             and pbudcode     is not null
                             and pokatocode   is not null
                             and pnalpurp     is not null
                             and pnalperiod   is not null
                             and pnaldocnum   is not null
                             and pnaldocdate  is not null
                             and pnaltype     is not null
                             --and pdocindex    is not null -- UBRR Новолодский А. Ю. 13.04.2015 [14-1134] АБС: Доработка экспорта документов из ПО FineReader For Bank 7.0 в АБС
                             then vBudg := 1;
                            else vBudg := 0;
                            end if;
                            dbms_output.put_line('vBudg ' || vBudg);
                            dbms_output.put_line('vPurp' || vPurp);
                            --
                            if vEcon = 1 then
                               if (vBudg = 0 and instr(vPurp,'!') > 0) -- Не бюджет с "!" в назначении
                                 then vibatnum := substr(to_char(NVL (pbatnum, getbatchnumber (vbo1, USER))),0,2) || '01';
                                 else vibatnum := substr(to_char(NVL (pbatnum, getbatchnumber (vbo1, USER))),0,2) || '02';
                               end if;
                            else vibatnum := substr(to_char(NVL (pbatnum, getbatchnumber (vbo1, USER))),0,2) || '01';
                            end if;
                        -- Инкассовое поручение, платёжное требование
                        elsif vbo1 in (23,53,15,21,22,52,55) then
                        dbms_output.put_line('econ' || vEcon);
                        dbms_output.put_line('delway'|| nvl(pdeliveryway,'E'));
                            if /*nvl(pdeliveryway,'E') = 'E' and*/ precipientbic like '0465%' then
                              if vEcon = 1 then vibatnum := substr(to_char(NVL (pbatnum, getbatchnumber (vbo1, USER))),0,2) || '02';
                                           else vibatnum := substr(to_char(NVL (pbatnum, getbatchnumber (vbo1, USER))),0,2) || '01';
                              end if;
                            elsif /*pdeliveryway = 'P' and*/ precipientbic not like '0465%'
                             then vibatnum := substr(to_char(NVL (pbatnum, getbatchnumber (vbo1, USER))),0,2) || '04';
                            end if;
                        end if;

            --<< korolkov (-end-)
            dbms_output.put_line('2_ ' ||vibatnum);
            mbunch.put('FREADER', '9', 'vibatnum= '||vibatnum);
        END IF;  -->>><<<ubrr 05.12.2007 Кузнецов Е.В. перенос собственного функционала из АБС v4---

        IF vret <> 'Ok' THEN
            RETURN 'Bad';
        END IF;

--->>>ubrr 05.11.2007 Кузнецов Е.В. перенос собственных разработок из АБС v4
-- katyuhin 11022005 - begin
        /*IF INSTR (UPPER (NVL (vpaycond, 'x')), 'БЕЗ АКЦЕПТА', 1, 1) <> 0 THEN
            usr_ppaycond := NULL;
        ELSE
            usr_ppaycond := vpaycond;
        END IF;*/

-- katyuhin 11042005 - end

        --lip 28/02/05
        i := INSTR (LOWER (vpurpose), 'ндс');
        p := vpurpose;

        BEGIN
            IF i > 0 THEN
                p := cf_note_paymentformula (p);
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p := vpurpose;
        END;

--end 28/02/05
        IF vregistrintobtn THEN
            vret :=
                ubrr_abrr_btn_reg.REGISTER (ubrr_abrr_btn_reg.btn_mode_reg,
                                            errormsg            => perr,
                                            optype              => vbo1,
                                            regdate             => util.CURRENT_DATE,
                                            payeracc            => ppayeracc,
                                            recipientacc        => vrecipientacc,
                                            summa               => psum,
                                            docdate             => pdate,
                                            purpose             => p,
                                            docnum              => pdocnum,
                                            priority            => ppriority,
                                            suboptype           => suboptype,         --lip 21/02/05
                                            -- CorAccO       => vPayerCorAcc,
                                            mfoa                => RTRIM (precipientbic),
                                            coracca             => RTRIM (precipientcoracc),
                                            coraccaname         => precipientbank,
                                            recipientname       => precipient,
                                            inna                => RTRIM (RTRIM (precipientinn),
                                                                          CHR (10)
                                                                         ),
                                            deliveryway         => vdelway,
                                            client_name         => vPayer,
                                            client_inn          => RTRIM (ppayerinn),
                                            cvo                 => vvo,
                                            batnum              => vibatnum,
                                            valdate             => NULL,
                                            client_kpp          => pkppplat,
                                            kppa                => pkpprec,
                                            zbl_acc             => vrecipientacc         -- katyuhin
                                           );
            perr := 'reg to btn';
        ELSE
---<<<ubrr 05.11.2007 Кузнецов Е.В. перенос собственных разработок из АБС v4

            --> UBRR Зуев А.А. 03.07.2008 проверка на экстримистов
            if UBRR_ZAA_EKSTRIMIST.Check_Ekstremist (vPayer, precipient, vpurpose) <> 'OK' then
                vret := '-';
                bExtr := true;
            else
                bExtr := false;
            end if;
            --< UBRR Зуев А.А. 03.07.2008 проверка на экстримистов

            -->>> Ёлгин Ю.А. 27.08.2017 [17-1076] АБС: Контроль платежей клиентов
            vcCtrlResult :=
                ubrr_clients_payment_control.checkOperation(ErrorMsg      => vcErrorMsg,
                                                            pTypes        => vcPayTypes, -->><<-- 08.11.2017 Пинаев Д.Е. [17-1198] АБС: Новый модуль для контроля СВК веерных платежей (алгоритм)
                                                            CTRNINNA      => RTRIM (RTRIM (precipientinn), CHR (10)),-->><<-- 27.11.2017 Пинаев Д.Е. [17-1198] АБС: Новый модуль для контроля СВК веерных платежей (алгоритм)
                                                            BeginDate     => trunc(util.CURRENT_DATE),
                                                            EndDate       => trunc(util.CURRENT_DATE) + 1,
                                                            RegDate       => util.CURRENT_DATE,
                                                            PayerAcc      => ppayeracc,
                                                            RecipientAcc  => precipientacc,
                                                            Summa         => psum,
                                                            MFOa          => RTRIM (precipientbic),
                                                            Purpose       => p,
                                                            RecipientName => precipient,
                                                            pITRNSOP      => vbo2, -->><<-- 11.04.2018  Пинаев Д.Е.      [18-268]    АБС: Доработка модуля "Контроль платежей" Клиент 550-П
                                                            -->>-- 13.04.2018 Пинаев Д.Е. [17-1575] АБС: Онлайн контроль операций с признаком "аккумулирующий транзит"
                                                            paccu_values => rAccuValues,
                                                            p_aID4log => aID4log );
                                                             --<<-- 13.04.2018 Пинаев Д.Е. [17-1575] АБС: Онлайн контроль операций с признаком "аккумулирующий транзит"

            --<<< Ёлгин Ю.А. 27.08.2017 [17-1076] АБС: Контроль платежей клиентов

            -->> 18.05.2018 Пинаев Д.Е. [17-1637.1] АБС: Платежи с пачкой 555 (ОТКБ)
            ubrr_cpm_control.Get_CatGrp_777(p_aCatGr=>aCatGr,
                           p_payeracc=>ppayeracc,
                           p_recipientacc=>precipientacc,
                           p_PurpIN=>vpurpose,
                           p_OpType=>vbo1,
                           p_qInnA=>precipientinn,
                           p_qPayerINN=>ppayerinn,
                           p_qMFOa=> RTRIM(precipientbic),
                           p_qPayerName => precipient,
                           p_qSumma => psum );

            vcMiddleCtrlResult :=
                ubrr_cpm_control.checkOperation(ErrorMsg   => vcMiddleErrorMsg,
                                                            pTypes        => vcMiddlePayTypes,
                                                            PayerAcc      => ppayeracc,
                                                            RecipientAcc  => precipientacc,
                                                            Purpose       => p,
                                                            RecipientName => precipient,
                                                            pITRNTYPE     => vbo1,
                                                            pITRNSOP      => vbo2,
                                                            pCatgr        => aCatGr
                                                            );

            if vcMiddleCtrlResult='BAD'  then

               tabAttr.Extend();
               tabAttr(1).ID_Attr:= ubrr_cpm_control.getMiddleCtrlAttrId;
               tabAttr(1).cValue := vcMiddlePayTypes;

            end if;
            --<< 18.05.2018 Пинаев Д.Е. [17-1637.1] АБС: Платежи с пачкой 555 (ОТКБ)

/***************************************************************************************/
/*   Попытка регистрации в соответствии с настройками, eсли нет картотеки кроме БО1 3,15            */
/***************************************************************************************/
            IF (NOT card.check_pres_on_card (ppayeracc, util.base_cur, terr) OR vbo1 IN (3, 15))
               AND vret <> '-'
               -->> 06.12.2017 Пинаев Д. [17-1198] АБС: Новый модуль для контроля СВК веерных платежей (алгоритм)
               --and vcCtrlResult != 'BAD' --Ёлгин Ю.А. 27.08.2017 [17-1076] АБС: Контроль платежей клиентов
               and (vcCtrlResult != 'BAD' or not ubrr_clients_payment_control.pay_type_exist(p_types=>nvl(vcPayTypes,'-'),p_type => 4)) -->><<--Пинаев 20,09,2018
               --<< 06.12.2017 Пинаев Д. [17-1198] АБС: Новый модуль для контроля СВК веерных платежей (алгоритм)
            THEN
                mbunch.put('FREADER', '8', 'vret= '||vret);
                BEGIN
                    SELECT registersequence
                      INTO tregistersequence
                      FROM fr_batches
                     WHERE ifrtop = vbo1 AND cfrblogname = USER AND ROWNUM = 1;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        BEGIN
                            SELECT registersequence
                              INTO tregistersequence
                              FROM fr_batches
                             WHERE ifrtop = vbo1 AND cfrblogname IS NULL AND ROWNUM = 1;
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                tregistersequence := '2TRN';
                        END;
                END;


                --  IDOC_REG.SetUpRegisterParams( '2TRN&FILE2' );
                -- по частично блокированным счетам ПП - в отложенные
                IF     cdocstate = 'ACC_PARTLY_BLOCKED'
                   AND vbo1 NOT IN (3, 15)
                   AND pbo1fr = 'PP'
                   -- UBRR katyuhin >>>
                   --AND v_cdtplace <> '1'
                                        -- UBRR katyuhin <<<
                THEN
                    tregistersequence := '2DP';
                END IF;

--- (нач.) UBRR Новолодский А. Ю.   16.07.2012 на картотеку
                If pbo1fr = 'PT' And nvl(tregistersequence, '2TRN') != '2DP' Then
                    If bPT2TRN Then
                        tregistersequence := '2TRN';
                    Else
                        tregistersequence := '2FILE1';
                    End If;
                End If;
--- (кон.) UBRR Новолодский А. Ю.   16.07.2012 на картотеку

-- (нач.) UBRR Новолодский А. Ю. 26.04.2013 https://redmine.lan.ubrr.ru/issues/7263
                IF pbo1fr IN ('PT', 'PP', 'IP')
                THEN
                    DECLARE
                        CURSOR CrCheck IS
                            SELECT SUM(n)
                              FROM (SELECT COUNT(1) n
                                      FROM ACC_OVER_SUM s
                                     WHERE s.cAOSsumtype IN ('B', 'O')
                                       AND s.cAOSstat = '1'
                                       AND s.cAOSacc = ppayeracc
                                       AND s.cAOScur = util.base_cur
                                    UNION
                                    SELECT COUNT(1) n
                                      FROM acc a
                                     WHERE a.caccacc = ppayeracc
                                       AND a.cacccur = util.base_cur
                                       AND a.CACCPRIZN IN ('А', 'Б', 'Ч'));
                        nStopCnt NUMBER;
                    BEGIN
                        OPEN CrCheck;
                        FETCH CrCheck
                            INTO nStopCnt;
                        CLOSE CrCheck;
                        IF nStopCnt > 0
                        THEN
                            tregistersequence := '2DP';
                        END IF;
                    END;
                END IF;
-- (кон.) UBRR Новолодский А. Ю. 26.04.2013 https://redmine.lan.ubrr.ru/issues/7263

                -->> 12.02.2018 ubrr korolkov 17-1565
                if   vcCtrlResult = 'BAD'
                 and nvl(tregistersequence, '$') != '2DP'
                 and (   vBo1 IN (1, 2, 3, 14, 24, 25, 26, 28) or vBo1 < 1 -- Внутрибанковский документ
                      or ubrr_zaa_abs_util.IsOurBik(pRecipientBic)
                      or vBo2 = 4)
                then
                    tRegisterSequence := '2DP';
                end if;
                --<< 12.02.2018 ubrr korolkov 17-1565

                -->> 06.12.2017 Пинаев Д. [17-1198] АБС: Новый модуль для контроля СВК веерных платежей (алгоритм)
                if vcCtrlResult = 'BAD' and NVL (tregistersequence, '2TRN') not in ('2TRN', '2DP') then
                  tregistersequence := '2DP';
                end if;
                --<< 06.12.2017 Пинаев Д. [17-1198] АБС: Новый модуль для контроля СВК веерных платежей (алгоритм)

        -->> 27.08.2018 Пинаев Д.Е. [18-617.1] АБС: Ручной разбор платежей при наличии просрочки по КД
                if not ubrr_dp.check_overdue(P_ITYPE=> vbo1,
                             P_IPRIORITY => ppriority,
                             p_PayerAcc => ppayeracc,
                             p_RecipientAcc => precipientacc,
                             p_ITRNSOP => vbo2) then

                    vcOverdueCtrlResult := 'BAD';

                    if  nvl(tregistersequence, '$') = '2TRN' then
                         tregistersequence := '2DP';
                    end if;

                end if;
        --<< 27.08.2018 Пинаев Д.Е. [18-617.1] АБС: Ручной разбор платежей при наличии просрочки по КД

                mbunch.put('FREADER', '10', 'tregistersequence= '||tregistersequence);
                idoc_reg.setupregisterparams (NVL (tregistersequence, '2TRN'));
                mbunch.put('FREADER', '11', 'pdate_end = ' || to_date(pdate, 'DD.MM.YYYY'));
                mbunch.put('FREADER', '12', 'valdate_end = ' || to_date(vvaldate, 'DD.MM.YYYY'));

                vret :=
                    idoc_reg.REGISTER (errormsg            => terr,
                                       optype              => vbo1,
                                       suboptype           => vbo2,
                                       -- Тип операции 2-го порядка
                                       regdate             => util.CURRENT_DATE,
                                       payeracc            => ppayeracc,
                                       recipientacc        => precipientacc,
                                       summa               => psum,
                                       docdate             => pdate,
                                       purpose             => vpurpose,
                                       docnum              => pdocnum,
                                       priority            => ppriority,
                                       --                            CorAccO       => vPayerCorAcc,
                                       mfoa                => RTRIM (precipientbic),
                                       coracca             => RTRIM (precipientcoracc),
                                       coraccaname         => precipientbank,
                                       recipientname       => precipient,
                                       inna                => RTRIM (RTRIM (precipientinn),
                                                                     CHR (10)),
                                       deliveryway         => vdelway,
                                       client_name         => vPayer,
                                       client_inn          => RTRIM (ppayerinn),
                                       cvo                 => vvo,
                                       batnum              => vibatnum,
                                       valdate             => vvaldate,
                                       client_kpp          => pkppplat,
                                       kppa                => pkpprec,
                                       dshadow             => util.CURRENT_DATE,
                                       ccondpay            => vpaycond
                                       , tabAttr           => tabAttr -->><<-- 02.08.2018 Пинаев Д.Е. [17-1637.1] АБС: Платежи с пачкой 555 (ОТКБ)
                                      );
                -->> UBRR 03.11.2017 Седавных Н.А. [17-1236] Уведомление о факте зачисления на счет ФЛ ("третейск")
                if  psum > 300000
                  and (substr(precipientacc, 1, 5) in ('40817', '40820') or substr(precipientacc, 1, 3) in ('423', '426'))
                  and (   upper(vpurpose) like upper('%третейск%')
                       or upper(vpurpose) like upper('%арбитраж%')
                       or upper(vpurpose) like upper('%ФС%')
                       or upper(vpurpose) like upper('%исп.%')
                       or upper(vpurpose) like upper('%исполнительный%')
                       or upper(vpurpose) like upper('%испол%')
                       or upper(vpurpose) like upper('%по трудовым спорам%')
                       or upper(vpurpose) like upper('%надписи%нотариуса%')
                       or upper(vpurpose) like upper('%нотариуса%надписи%')
                      )
                    then
                    begin
                        if idoc_reg.GetRegisterParam('CPLACE2') = 'TRN' then
                            UBRR_XXI5.UBRR_CLIENTS_PAYMENT_CONTROL.addSendObnal('TRN');
                        elsif idoc_reg.GetRegisterParam('CPLACE2') = 'DP'  then
                            UBRR_XXI5.UBRR_CLIENTS_PAYMENT_CONTROL.addSendObnal('DP');
                        else
                          UBRR_XXI5.UBRR_CLIENTS_PAYMENT_CONTROL.addSendObnal('KRT');
                        end if;
                    end;
                end if;
                --<< UBRR 03.11.2017 Седавных Н.А. [17-1236] Уведомление о факте зачисления на счет ФЛ ("третейск")
      mbunch.put('FREADER', '13', 'vret= '||vret);

                IF vret = 'Ok' THEN
                    vplace := idoc_reg.getregisterparam ('cPlace2');

                -->> 27.08.2018 Пинаев Д.Е. [18-617.1] АБС: Ручной разбор платежей при наличии просрочки по КД
                    if vcOverdueCtrlResult = 'BAD' and idoc_reg.GetRegisterParam('CPLACE2') = 'DP' then
                       mbunch.put('DP_DOC', TO_CHAR(DP.GetLastID), 'По клиенту есть просроч.задолж. по КД, необх. сообщить Кред.спец.');
                    end if;
                --<< 27.08.2018 Пинаев Д.Е. [18-617.1] АБС: Ручной разбор платежей при наличии просрочки по КД


                    -->> 06.12.2017 Пинаев Д. [17-1198] АБС: Новый модуль для контроля СВК веерных платежей (алгоритм)
                    if vcCtrlResult = 'BAD' then
                      declare
                        iDocNum     number;
                      begin
                        if idoc_reg.GetRegisterParam('CPLACE2') = 'TRN' then
                            iDocNum := idoc_reg.GetLastDocID;
                            insert into xxi.gtr values(iDocNum, 0,
                                   ubrr_xxi5.Ubrr_Clients_Payment_Control.getCatParam,
                                   ubrr_xxi5.Ubrr_Clients_Payment_Control.getGrParam);
                            l_ret := ubrr_cp_pkg.reg_doc(vcCpCtrlMsg, '2TRN', vcPayTypes, iDocNum
                            -->> 13.04.2018 Пинаев Д.Е. [17-1575] АБС: Онлайн контроль операций с признаком "аккумулирующий транзит"
                             ,0,rAccuValues, aID4log );
                            --<< 13.04.2018 Пинаев Д.Е. [17-1575] АБС: Онлайн контроль операций с признаком "аккумулирующий транзит"
                        elsif idoc_reg.GetRegisterParam('CPLACE2') = 'DP'  then
                            iDocNum := DP.GetLastID;
                            insert into xxi.dp_gtr values(iDocNum,
                                   ubrr_xxi5.Ubrr_Clients_Payment_Control.getCatParam,
                                   ubrr_xxi5.Ubrr_Clients_Payment_Control.getGrParam);
                            l_ret := ubrr_cp_pkg.reg_doc(vcCpCtrlMsg, '2DP', vcPayTypes, iDocNum
                            -->> 13.04.2018 Пинаев Д.Е. [17-1575] АБС: Онлайн контроль операций с признаком "аккумулирующий транзит"
                             ,0,rAccuValues, aID4log );
                            --<< 13.04.2018 Пинаев Д.Е. [17-1575] АБС: Онлайн контроль операций с признаком "аккумулирующий транзит"
                        end if;
                      end;
                      vcCtrlResult := null;
                    end if;
                    aID4log.delete;
                    --<< 06.12.2017 Пинаев Д. [17-1198] АБС: Новый модуль для контроля СВК веерных платежей (алгоритм)

                    -->>21.05.2018 Пинаев Д.Е. [17-1637.1] АБС: Платежи с пачкой 555 (ОТКБ)
                    if vcMiddleCtrlResult = 'BAD' then

                      declare
                        iDocNum     number;
                      begin
                        if  vplace = 'TRN' then
                            iDocNum := idoc_reg.GetLastDocID;
                            l_ret := ubrr_cpm_pkg.reg_doc(vcCpCtrlMsg, '2TRN', vcMiddlePayTypes, iDocNum);
                            Ubrr_cpm_Control.insert_gtr(iDocNum, aCatGr, 'TRN');
                        elsif  vplace = 'DP'  then
                            iDocNum := DP.GetLastID;
                            l_ret := ubrr_cpm_pkg.reg_doc(vcCpCtrlMsg, '2DP', vcMiddlePayTypes, iDocNum);
                            Ubrr_cpm_Control.insert_gtr(iDocNum, aCatGr, '2DP');
                        elsif  vplace in  ('FILE1', 'FILE2')  then
                            iDocNum := card.Get_Last_Num;
                            l_ret := ubrr_cpm_pkg.reg_doc(vcCpCtrlMsg, vplace, vcMiddlePayTypes, iDocNum);
                            Ubrr_cpm_Control.insert_gtr(iDocNum, aCatGr, vplace);
                        end if;
                      end;
                      vcMiddleCtrlResult := null;
                    end if;
                    aCatGr.delete;
                    --<<21.05.2018 Пинаев Д.Е. [17-1637.1] АБС: Платежи с пачкой 555 (ОТКБ)

                    -- TRN, FILE1, FILE2
                    perr := perr || 'Документ зарегистрирован в ';

                    IF vplace = 'TRN' THEN
                        perr := perr || 'реестре.';
                    ELSIF vplace = 'FILE1' THEN
                        perr := perr || 'картотеке 1.';
                    ELSIF vplace = 'FILE2' THEN
                        perr := perr || 'картотеке 2.';
                    ELSE
                        perr := perr || vplace;
                    END IF;

                    perr := perr || lf;
                      mbunch.put('FREADER', '36', 'reg='||perr);
               -->>> Ёлгин Ю.А. 29.06.2017 https://redmine.lan.ubrr.ru/issues/43068 [16-3300.1.1] АБС: Централизация платежей. Этап II - ЗДА
                  if instr(ppaycond, '!') > 0 then
                     if ubrr_eua_zda_util.findRecordInZDA(ppayeracc, pdate) then
                        declare
                           iTrnNum  number;
                           iTrnANum number;
                           iAttrID  number := ubrr_eua_zda_util.ZDA_ATTR_ID;
                           iResult  number := -1;
                        begin
                           iTrnNum:=idoc_reg.GetLastDocID;
                           if vplace = 'TRN' then
                              iResult := ubrr_eua_zda_util.add_trnAttr(iTrnNum, 0, iAttrID);
                           elsif vplace in ('FILE1', 'FILE2') then
                              iResult := ubrr_eua_zda_util.add_trcAttr(iTrnNum, 0, iAttrID);
                           end if;
                           if iResult != 0 then
                              perr := perr||' ('||'Ошибка добавления доп.атрибута в '||vplace||')';
                           end if;
                        end;
                     end if;
                  end if;
               --<<< Ёлгин Ю.А. 29.06.2017 https://redmine.lan.ubrr.ru/issues/43068 [16-3300.1.1] АБС: Централизация платежей. Этап II - ЗДА
-- (нач) UBRR Новолодский плат. в иностр. банк
                    If bIsForeign Then
                        Declare
                            iTrnNum Number;
                        Begin
                            iTrnNum:=idoc_reg.GetLastDocID;
                            If Length(vPayer)>160 Then
                                INSERT INTO GTR(IGTRTRNNUM,IGTRTRNANUM,IGTRCAT,IGTRNUM)
                                VALUES (iTrnNum, 0, 999, 4);
                            Else
                                INSERT INTO GTR(IGTRTRNNUM,IGTRTRNANUM,IGTRCAT,IGTRNUM)
                                VALUES (iTrnNum, 0, 999, 3);
                            End If;
                        End;
                    End If;
-- (кон) UBRR Новолодский плат. в иностр. банк

                END IF;
            ELSE
                perr := perr || terr || lf;
                vret := '-';
            END IF;

    mbunch.put('FREADER', '14', 'vbo1= '||vbo1);
            IF vret <> 'Ok'
                           -- UBRR katyuhin >>>
               --AND v_cdtplace <> '1'
                                    -- UBRR katyuhin <<<
            THEN
              mbunch.put('FREADER', '18', vret); --Иванов Д.Г.
              mbunch.put('FREADER', '19', perr); --Иванов Д.Г.
/***************************************************************************************/
/*       Регистрация в отложенные eсли недостаточно средств на счете или есть картотека*/
/***************************************************************************************/
/*     RetCode := DP.Register ( vcErrMsg => pErr,
vdTran => NULL,
vdVal => pDate,
vdCreate => Util.Current_Date,
vdDoc => pDate,
viType => vBO1,
viSop => 4,
viDocNum => pDocNum,
viBathNum => viBatNum,
vcPayerAcc => pPayerAcc,
vcPayerINN => pPayerInn,
vcPayerName => pPayer,
vcRecipAcc => pRecipientAcc,
vcRecipINN => pRecipientInn,
vcRecipName => pRecipient,
vcRecipMFO => pRecipientBic,
vcRecipCorAcc => pRecipientCorAcc,
vcRecipSBCode => NULL,
vcRecipBankName => pRecipientBank,
vcCur => Util.Base_Cur,
vmSumm => pSum,
vcDWay => vDelWay,
viPriority => pPriority,
vcPurp => pPurpose,
vcVO => vVO,
vcCondPay => NULL,
vcPayerKPP => pKppPlat,
vcRecipKPP => pKppRec);*/
                IF pbo1fr <> 'PT' THEN
                    vdeptinfo.ccreatstatus := pcreatstatus;                        -- VARCHAR2 (2),
                    vdeptinfo.cbudcode := NVL (pbudcode, 0);                      -- VARCHAR2 (20),
                    vdeptinfo.cokatocode := NVL (pokatocode, 0);                  -- VARCHAR2 (11),
                    vdeptinfo.cnalpurp := NVL (pnalpurp, 0);                       -- VARCHAR2 (2),
                    vdeptinfo.cnalperiod := NVL (pnalperiod, 0);                  -- VARCHAR2 (10),
                    vdeptinfo.cnaldocnum := NVL (pnaldocnum, 0);                  -- VARCHAR2 (15),
                    vdeptinfo.cnaldocdate := NVL (pnaldocdate, 0);                -- VARCHAR2 (10),
                    vdeptinfo.cnaltype := NVL (pnaltype, 0);                        -- VARCHAR2 (2)
                    vdeptinfo.cDocIndex := NVL(pdocindex, 0); -- UBRR Новолодский А. Ю. 13.04.2015 [14-1134] АБС: Доработка экспорта документов из ПО FineReader For Bank 7.0 в АБС

                END IF;

      mbunch.put('FREADER', '15', 'в отложенные');
          -->> 13.11.2017 Пинаев Д.Е. [17-1198] АБС: Новый модуль для контроля СВК веерных платежей (алгоритм)
          /*
          -->>> Ёлгин Ю.А. 27.08.2017 [17-1076] АБС: Контроль платежей клиентов
            if vcCtrlResult = 'BAD' then
              if vibatnum not in (666, 330) then
                  vibatnum := 777;
              end if;
            end if;
          -->>> Ёлгин Ю.А. 27.08.2017 [17-1076] АБС: Контроль платежей клиентов
          */
          --<< 13.11.2017 Пинаев Д.Е. [17-1198] АБС: Новый модуль для контроля СВК веерных платежей (алгоритм)

                idoc_reg.setupregisterparams ('2DP');
                retcode :=
                    idoc_reg.REGISTER (errormsg            => terr,
                                       optype              => vbo1,
                                       regdate             => util.CURRENT_DATE,
                                       payeracc            => ppayeracc,
                                       recipientacc        => precipientacc,
                                       summa               => psum,
                                       docdate             => pdate,
                                       purpose             => vpurpose,
                                       docnum              => pdocnum,
                                       priority            => ppriority,
                                       suboptype           => suboptype, -->>><<<--ubrr lip 21/02/05
                                       --                            CorAccO       => vPayerCorAcc,
                                       mfoa                => RTRIM (precipientbic),
                                       coracca             => RTRIM (precipientcoracc),
                                       coraccaname         => precipientbank,
                                       recipientname       => precipient,
                                       inna                => RTRIM (RTRIM (precipientinn),
                                                                     CHR (10)),
                                       deliveryway         => vdelway,
                                       client_name         => vPayer,
                                       client_inn          => RTRIM (ppayerinn),
                                       cvo                 => vvo,
                                       batnum              => vibatnum,
                                       valdate             => vvaldate,
                                       client_kpp          => pkppplat,
                                       kppa                => pkpprec,
                                       dshadow             => util.CURRENT_DATE,
                                       ccondpay            => vpaycond,
                                       rdeptinfo           => vdeptinfo                          --,
                                      --         cIDOpen       => pUser
                                      );
                -->> UBRR 03.11.2017 Седавных Н.А. [17-1236] Уведомление о факте зачисления на счет ФЛ ("третейск")
                if upper(retcode) = upper('Ok')
                  and psum > 300000
                  and (substr(precipientacc, 1, 5) in ('40817', '40820') or substr(precipientacc, 1, 3) in ('423', '426'))
                  and (   upper(vpurpose) like upper('%третейск%')
                       or upper(vpurpose) like upper('%арбитраж%')
                       or upper(vpurpose) like upper('%ФС%')
                       or upper(vpurpose) like upper('%исп.%')
                       or upper(vpurpose) like upper('%исполнительный%')
                       or upper(vpurpose) like upper('%испол%')
                       or upper(vpurpose) like upper('%по трудовым спорам%')
                       or upper(vpurpose) like upper('%надписи%нотариуса%')
                       or upper(vpurpose) like upper('%нотариуса%надписи%')
                      )
                    then
                    begin
                        if idoc_reg.GetRegisterParam('CPLACE2') = 'TRN' then
                            UBRR_XXI5.UBRR_CLIENTS_PAYMENT_CONTROL.addSendObnal('TRN');
                        elsif idoc_reg.GetRegisterParam('CPLACE2') = 'DP'  then
                            UBRR_XXI5.UBRR_CLIENTS_PAYMENT_CONTROL.addSendObnal('DP');
                        else
                          UBRR_XXI5.UBRR_CLIENTS_PAYMENT_CONTROL.addSendObnal('KRT');
                        end if;
                    end;
                end if;
                --<< UBRR 03.11.2017 Седавных Н.А. [17-1236] Уведомление о факте зачисления на счет ФЛ ("третейск")
      mbunch.put('FREADER', '16', 'retcode' || retcode);
                IF retcode = 'Ok' THEN
                    /*        if pCreatStatus IN( '01', '02', '03', '04', '05', '06', '07', '08' ) THEN
                       if DP.Add_DeptInfo ( cError => pErr,
                                            vID => NULL,
                                            cCreatStatus => pCreatStatus,
                                            cBudCode => pBudCode,
                                            cOKATOCode => pOKATOCode,
                                            cNalPurp => pNalPurp,
                                            cNalPeriod => pNalPeriod,
                                            cNalDocNum => pNalDocNum,
                                            cNalDocDate => pNalDocDate,
                                            cNalType => pNalType ) <> 0 then
                          DBMS_TRANSACTION.ROLLBACK_SAVEPOINT( 'BEFORE_REGISTER' );
                          return 'ERROR';
                       end if;
                    end if; */
--> ubrr Зуев А.А. 04.07.2008 Если в отоженные попал из-за подозрения на терориста
                    if bExtr then
                       UBRR_ZAA_EKSTRIMIST.Set_Manual_DP(DP.GetLastID, pdate, 'Подозрение на экстремизм', 'O');
                    end if;
--< ubrr Зуев А.А. 04.07.2008 Если в отоженные попал из-за подозрения на терориста
                    perr := perr || 'Документ зарегестрирован в отложенные платежи.' || lf;

               -->>> Ёлгин Ю.А. 29.06.2017 https://redmine.lan.ubrr.ru/issues/43068 [16-3300.1.1] АБС: Централизация платежей. Этап II - ЗДА
                  if instr(ppaycond, '!') > 0 then
                     if ubrr_eua_zda_util.findRecordInZDA(ppayeracc, pdate) then
                        declare
                           iTrnNum     number;
                           cError      varchar2(1000);
                           rAttrRecord ts.T_TrnAttr;
                           tAttrTab    ts.T_TabTrnAttr;
                           iResult     number := -1;
                        begin
                           iTrnNum := DP.GetLastID;
                           rAttrRecord.id_attr := ubrr_eua_zda_util.ZDA_ATTR_ID;
                           rAttrRecord.cvalue := to_char(iTrnNum);
                           tAttrTab  := xxi_ts.T_TabTrnAttr(rAttrRecord);
                           iResult := ubrr_dp.add_dpattr(cError,iTrnNum, tAttrTab);
                           if iResult !=0 then
                              perr := perr||' ('||cError||')';
                           end if;
                        end;
                     end if;
                  end if;
               --<<< Ёлгин Ю.А. 29.06.2017 https://redmine.lan.ubrr.ru/issues/43068 [16-3300.1.1] АБС: Централизация платежей. Этап II - ЗДА
              -->>> Ёлгин Ю.А. 27.08.2017 [17-1076] АБС: Контроль платежей клиентов
                if vcCtrlResult = 'BAD' then
                  declare
                    iDocNum     number;
                    --cRes        varchar2(2000); -->><<-- 09.11.2017 Пинаев Д.Е. [17-1198] АБС: Новый модуль для контроля СВК веерных платежей (алгоритм)
                    vCat        number;
                    vGr         number;
                  begin
                    vCat := ubrr_xxi5.Ubrr_Clients_Payment_Control.getCatParam;
                    vGr :=  ubrr_xxi5.Ubrr_Clients_Payment_Control.getGrParam;
                    iDocNum := DP.GetLastID;
                    insert into xxi.dp_gtr values(iDocNum, vCat, vGr);
                    l_ret := ubrr_cp_pkg.reg_doc(vcCpCtrlMsg, '2DP', vcPayTypes, iDocNum); -->><<-- 09.11.2017 Пинаев Д.Е. [17-1198] АБС: Новый модуль для контроля СВК веерных платежей (алгоритм)
                    --cRes := ubrr_xxi5.Ubrr_Clients_Payment_Control.lockOperation(iDocNum); -->><<---- 09.11.2017 Пинаев Д.Е. [17-1198] АБС: Новый модуль для контроля СВК веерных платежей (алгоритм)
                  end;

                end if;
                vcCtrlResult := null;
              -->>> Ёлгин Ю.А. 27.08.2017 [17-1076] АБС: Контроль платежей клиентов

                    -->>21.05.2018 Пинаев Д.Е. [17-1637.1] АБС: Платежи с пачкой 555 (ОТКБ)
                    aID4log.delete;

                    if vcMiddleCtrlResult = 'BAD' then
                      l_ret := ubrr_cpm_pkg.reg_doc(vcCpCtrlMsg, '2DP', vcMiddlePayTypes, DP.GetLastID);
                      Ubrr_cpm_Control.insert_gtr(DP.GetLastID, aCatGr, '2DP');
                      vcMiddleCtrlResult := null;
                    end if;
                    aCatGr.delete;
                    --<<21.05.2018 Пинаев Д.Е. [17-1637.1] АБС: Платежи с пачкой 555 (ОТКБ)



-- (нач) UBRR Новолодский плат. в иностр. банк
                    If bIsForeign Then
                        Declare
                            iTrnNum Number;
                        Begin
                            --T:=idoc_reg.GetLastDocUID();
                            iTrnNum := DP.GetLastID;
                            If Length(vPayer)>160 Then
                                INSERT INTO GTR(IGTRTRNNUM,IGTRTRNANUM,IGTRCAT,IGTRNUM)
                                VALUES (iTrnNum, 0, 999, 4);
                            Else
                                INSERT INTO GTR(IGTRTRNNUM,IGTRTRNANUM,IGTRCAT,IGTRNUM)
                                VALUES (iTrnNum, 0, 999, 3);
                            End If;
                        End;
                    End If;
-- (кон) UBRR Новолодский плат. в иностр. банк

                    RETURN 'Ok';
                ELSE
                    perr := perr || terr || lf;
                    RETURN 'Bad';
                END IF;
/**************************************************************************************/
            END IF;
        END IF;
    --vRegistrIntoBTN -->>><<<ubrr 05.11.2007 Кузнецов Е.В. перенос собственных разработок из АБС v4

    mbunch.put('FREADER', '17', '17');
                --COMMIT; -- UBRR Новолодский А. Ю. 04.03.2016 [15-1641.3] перенёс коммит после BEFORE_REGISTER

        IF pcreatstatus IS NOT NULL AND pbo1fr <> 'PT' AND UPPER (vret) = 'OK' THEN
            IF idoc_reg.add_deptinfo (cerror             => terr,
                                      inum               => NULL,
                                      ianum              => NULL,
                                      ccreatstatus       => pcreatstatus,
                                      cbudcode           => NVL (pbudcode, 0),
                                      cokatocode         => NVL (pokatocode, 0),
                                      cnalpurp           => NVL (pnalpurp, 0),
                                      cnalperiod         => NVL (pnalperiod, 0),
                                      cnaldocnum         => NVL (pnaldocnum, 0),
                                      cnaldocdate        => NVL (pnaldocdate, 0),
                                      cnaltype           => NVL (pnaltype, 0),
                                      cDocIndex          => NVL (pdocindex, 0) -- UBRR Новолодский А. Ю. 13.04.2015 [14-1134] АБС: Доработка экспорта документов из ПО FineReader For Bank 7.0 в АБС
                                     ) <> 0 THEN
                DBMS_TRANSACTION.rollback_savepoint ('BEFORE_REGISTER');
                perr := perr || terr || lf;
                RETURN 'Bad';
            END IF;
        END IF;
        COMMIT; -- UBRR Новолодский А. Ю. 04.03.2016 [15-1641.3] перенёс коммит после BEFORE_REGISTER

        RETURN vret;
    END;

    FUNCTION getbo1cognitive (precipientbic IN VARCHAR2, pbo1fr IN VARCHAR2, ppaycond IN VARCHAR2)
        RETURN NUMBER IS
        vbo2   sop.isopid%TYPE;
    BEGIN
        RETURN getbo1 (precipientbic, pbo1fr, ppaycond, precipientbic, vbo2);
    END;

    FUNCTION getbo1 (
        precipientbic   IN       VARCHAR2,
        pbo1fr          IN       VARCHAR2,
        ppaycond        IN       VARCHAR2,
        ppayerbic       IN       VARCHAR2,
        pbo2            OUT      sop.isopid%TYPE,
        pbPT2TRN        IN       BOOLEAN Default False, -- UBRR,
        precipientacc       In Varchar2 DEFAULT NULL   -- UBRR Новолодский А. Ю.
    )
        RETURN NUMBER IS
        vourbic   VARCHAR2 (12);
        vbo1      top.itopnum%TYPE;
        tIdSmr   varchar2(3) := ubrr_get_context;
        lidsmr Number;    -- UBRR Новолодский А. Ю.
    BEGIN
        vourbic := swift_pref.getourbic ('RUS');

--- (нач.) UBRR Новолодский А. Ю.   31.10.2013 12-2029 для ИП/ПТ с счетами ССБ БО1=23/22 - в TRN
        If precipientacc Is Not Null Then
            Begin
                Select idsmr
                Into lidsmr
                From ubrr_acc_v
                Where caccacc=precipientacc And Rownum=1;
            Exception
                When No_Data_Found Then
                    lidsmr:=-1;
            End;
        End If;

--- (кон.) UBRR Новолодский А. Ю.   31.10.2013 12-2029 для ИП/ПТ с счетами ССБ БО1=23/22 - в TRN

        IF vourbic = LTRIM (RTRIM (precipientbic)) THEN
            IF pbo1fr = 'IP' THEN
--- (нач.) UBRR Новолодский А. Ю.   31.10.2013 12-2029 для ИП с счетами ССБ БО1=23
                If lidsmr!=tIdSmr Then
                    vbo1 := 23;                                      -- межбанк  инкассовое поручение
                Else
                    vbo1 := 26;                                      -- Внутреннее инкассовое поручение
                End If;
--- (кон.) UBRR Новолодский А. Ю.   31.10.2013 12-2029 для ИП с счетами ССБ БО1=23
            ELSIF pbo1fr = 'PT' THEN
--- (нач.) UBRR Новолодский А. Ю.   16.07.2012 на картотеку
                IF Not pbPT2TRN And INSTR (UPPER (ppaycond), 'БЕЗ АКЦЕПТА', 1, 1) = 0 THEN
                    vbo1 := 3;                                   -- Внутреннее требование акцептное
                ELSE
                    vbo1 := 25;                               -- Внутреннее требование безакцептное
                END IF;
--- (нач.) UBRR Новолодский А. Ю.   31.10.2013 12-2029 для ПТ с счетами ССБ БО1=23
                If lidsmr!=tIdSmr Then
                    If pbPT2TRN Then
                        vbo1 := 22;                                  -- межбанк требование акцептное
                    Else
                        vbo1 := 15;
                    End If;
                End If;
--- (кон.) UBRR Новолодский А. Ю.   31.10.2013 12-2029 для ПТ с счетами ССБ БО1=23
--- (кон.) UBRR Новолодский А. Ю.   16.07.2012 на картотеку
            ELSE
                vbo1 := 2;                                        -- Внутреннее платежное поручение
            END IF;

            IF SUBSTR (LTRIM (RTRIM (ppayerbic)), 3, 2) = SUBSTR (vourbic, 3, 2) THEN
                BEGIN
                    SELECT ifrsopours                                                  -- Наш регион
                      INTO pbo2
                      FROM fr_batches
                     WHERE ifrtop = vbo1 AND cfrblogname = USER AND ROWNUM = 1;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        BEGIN
                            SELECT ifrsopours
                              INTO pbo2
                              FROM fr_batches
                             WHERE ifrtop = vbo1 AND cfrblogname IS NULL AND ROWNUM = 1;
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                pbo2 := NULL;
                        END;
                END;
            ELSE
                BEGIN
                    SELECT ifrsopthem                                               -- Не наш регион
                      INTO pbo2
                      FROM fr_batches
                     WHERE ifrtop = vbo1 AND cfrblogname = USER AND ROWNUM = 1;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        BEGIN
                            SELECT ifrsopthem
                              INTO pbo2
                              FROM fr_batches
                             WHERE ifrtop = vbo1 AND cfrblogname IS NULL AND ROWNUM = 1;
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                pbo2 := NULL;
                        END;
                END;
            END IF;
        ELSE
            IF pbo1fr = 'IP' THEN
                vbo1 := 23;                                         -- Внешнее инкассовое поручение
            ELSIF pbo1fr = 'PT' THEN

--- (нач.) UBRR Новолодский А. Ю.   16.07.2012 на картотеку
                IF Not pbPT2TRN And INSTR (UPPER (ppaycond), 'БЕЗ АКЦЕПТА', 1, 1) = 0 THEN
                    vbo1 := 15;                                     -- Внешнее требование акцептное
                ELSE
                    vbo1 := 22;                                  -- Внешнее требование безакцептное
                END IF;
--- (кон.) UBRR Новолодский А. Ю.   16.07.2012 на картотеку

            ELSE
                vbo1 := 4;                                           -- Внешнее платежное поручение
            END IF;

            IF SUBSTR (LTRIM (RTRIM (precipientbic)), 3, 2) = SUBSTR (vourbic, 3, 2) THEN
                BEGIN
                    SELECT ifrsopours                                                  -- Наш регион
                      INTO pbo2
                      FROM fr_batches
                     WHERE ifrtop = vbo1 AND cfrblogname = USER AND ROWNUM = 1;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        BEGIN
                            SELECT ifrsopours
                              INTO pbo2
                              FROM fr_batches
                             WHERE ifrtop = vbo1 AND cfrblogname IS NULL AND ROWNUM = 1;
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                pbo2 := NULL;
                        END;
                END;
            ELSE
                BEGIN
                    SELECT ifrsopthem                                               -- Не наш регион
                      INTO pbo2
                      FROM fr_batches
                     WHERE ifrtop = vbo1 AND cfrblogname = USER AND ROWNUM = 1;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        BEGIN
                            SELECT ifrsopthem
                              INTO pbo2
                              FROM fr_batches
                             WHERE ifrtop = vbo1 AND cfrblogname IS NULL AND ROWNUM = 1;
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                pbo2 := NULL;
                        END;
                END;
            END IF;
        END IF;

        RETURN vbo1;
    END;
------------------------------------------------------------------------------------------
BEGIN
    -- проверка количества лицензий
    qtrn.get_licinfo (gtotal, gused);
END;
/
