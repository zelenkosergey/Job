CREATE OR REPLACE PACKAGE UBRR_XXI5."UBRR_ZAA_COMMS"
IS
/***************************************** HISTORY *******************************************\
   Дата          Автор          id        Описание
----------  ---------------  --------- --------------------------------------------------------
12.11.2015  ubrr korolkov    15-1059.1  АБС: 446-П. Доработка комиссионных модулей
23.11.2015  ubrr korolkov    15-922     Get_Acc446p: добавлен параметр p_Otd
29.03.2017  ubrr sevastyanov 16-3100.2  Регистрация межфилиальных платежных документов
09.01.2018  Ёлгин Ю.А.       [17-913.2] АБС: Кат/гр при открытии счета
25.02.2019  Ризанов Р.Т.     [17-1790] АБС: Комиссиии за РКО при наличии овердрафтных договоров
\***************************************** HISTORY *******************************************/

    Function Get_Acc707 (cpAcc706 in varchar2,
                         cpKeyBy in varchar2 default null)
    return varchar2;

    -->> 12.11.2015 ubrr korolkov 15-1059.1
    function Get_Acc446pFromOld (p_CusNum      in number,
                                 p_OldAccount  in varchar2,
                                 p_OldCurrency in varchar2 default null,
                                 p_IdSmr       in varchar2 default null)
    return varchar2;

    function Get_Acc446p (p_CusNum  in number,
                          p_AccMask in varchar2,
                          p_AccCur  in varchar2 default null,
                          p_IdSmr   in varchar2 default null,
                          p_Otd     in number   default null)
    return varchar2;
    --<< 12.11.2015 ubrr korolkov 15-1059.1

    type rtDocument is record (cModule varchar2(32),
                               cAccD   varchar2(25),
                               cCurD   varchar2(3),
                               mSumD   number,
                               cNameD  varchar2(256),
                               cInnD   varchar2(13),
                               cAccC   varchar2(25),
                               cCurC   varchar2(3),
                               mSumC   number,
                               cNameC  varchar2(256),
                               cInnC   varchar2(13),
                               cPayer  varchar2(25),
                               cPayee  varchar2(25),
                               dTran   date,
                               dComm   date,
                               iDocNum number,
                               iBatNum number,
                               cPurp   varchar2(1024),
                               cAccept varchar2(1024),
                               iBo1    number,
                               iBo2    number,
                               cType   varchar2(3),
                               iParent number,
-- Забаланс
                               cZblAcc varchar2(25),
                               mNdsSum number,
                               cNdsAcc varchar2(25),
                               cPurp1  varchar2(1024),
                               cPurp2  varchar2(1024),
                               
                               lmode_available_rest boolean -- ubrr 25.02.2019 Ризанов Р.Т. [17-1790] АБС: Комиссиии за РКО при наличии овердрафтных договоров 
                              );

    type rtRetDoc is record (cResult varchar2(1024),
                             iNum     number,
                             iANum    number,
                             iCardNum number,
                             cBtnRef  varchar2(29), -- (нач.) UBRR Новолодский А. Ю. 02.10.2015 расширение поля REF
                             cPlace   varchar2(3));

    Function Register (rpDocument in rtDocument)
    return rtRetDoc;

    -->> UBRR 29.03.2017 Севастьянов С.В. Регистрация межфилиальных платежных документов
    Function Register_MFR(
               rpDocument    in rtDocument, 
               d_idsmr       in smr.idsmr%type, 
               c_idsmr       in smr.idsmr%type, 
               p_regdate     in date,
               mfr_text_err out varchar2)
    return rtRetDoc;
    --<< UBRR 29.03.2017 Севастьянов С.В. Регистрация межфилиальных платежных документов
    
    Function RegisterMo
    return rtRetDoc;

    Function RegisterCard
    return rtRetDoc;

    Function RegisterZbl
    return rtRetDoc;
    
    -->>> 09.01.2018 Ёлгин Ю.А. [17-913.2]
    function Get_LinkToContract(p_Account varchar2, 
                                p_IdSmr   varchar2,
                                p_AccSio  varchar2 default null,
                                p_AccLastOper date default null)
    return varchar2;
    --<<< 09.01.2018 Ёлгин Ю.А. [17-913.2]
END; -- Package spec
/
CREATE OR REPLACE PACKAGE BODY UBRR_XXI5."UBRR_ZAA_COMMS"
IS
/******************************* HISTORY UBRR ***************************************************************\
    Дата        Автор            ID             Описание
----------  ---------------  ----------------  --------------------------------------------------------------
16.01.2014  ubrr korolkov    12-2288.2(#11743) Изменение очередности списания денежных средств
12.11.2015  ubrr korolkov    15-1059.1(#25674) АБС: 446-П. Доработка комиссионных модулей
23.11.2015  ubrr korolkov    15-922   (#26004) Get_Acc446p: добавлен параметр p_Otd
29.03.2017  ubrr sevastyanov 16-3100.2         Регистрация межфилиальных платежных документов
07.11.2017  ubrr korolkov    [17-1071]         АБС: Ежедневные комиссии за платежи
09.01.2018  Ёлгин Ю.А.       [17-913.2] АБС: Кат/гр при открытии счета
01.02.2019  Фридьев П.В.     [19-58770]        Изменение даты запуска пролонгации пакетов
25.02.2019  Ризанов Р.Т.     [17-1790] АБС: Комиссиии за РКО при наличии овердрафтных договоров
19.07.2021  Зеленко С.А.     DKBPA-1571   ВБ переводы. Взимание комиссий в режиме "онлайн"
\******************************* HISTORY UBRR ***************************************************************/
    rsDocument rtDocument;
    rsSmr      smr%rowtype;
    rsSmr_to   smr%rowtype;
    BankIdSmr  smr.idsmr%type;

    Function Get_Acc707 (cpAcc706 in varchar2,
                         cpKeyBy in varchar2 default null)
    return varchar2
    is
        cvAcc707 varchar2(25);
        cvKey    varchar2(1);
    begin
        cvAcc707 := substr(cpAcc706,1,2)||'7'||substr(cpAcc706,4,17);
        cvKey := UBRR_ZAA_CALC_KEY(cpKeyedValue => cvAcc707,
                                   cpKeyBy => cpKeyBy);
        cvAcc707 := substr(cvAcc707,1,8)||cvKey||substr(cvAcc707,10,11);
        return cvAcc707;
    end;

    -->> 12.11.2015 ubrr korolkov 15-1059.1
    function Get_Acc446pFromOld (p_CusNum      in number,
                                 p_OldAccount  in varchar2,
                                 p_OldCurrency in varchar2 default null,
                                 p_IdSmr       in varchar2 default null)
    return varchar2
    is
        vRet ubrr_acc_446p.caccacc446p%type;
        vCur ubrr_acc_446p.cacccur_old%type;
        vCusType varchar2(1);
    begin
        if rp_cus.iscustomeringroup (p_CusNum, 15, 4) = 1 then
            vCusType := '0';
        else
            vCusType := '1';
        end if;

        vCur := nvl(p_OldCurrency, nvl(acc_info.Get_AccCur(p_OldAccount),'RUR'));
        begin
            select a.caccacc446p
            into vRet
            from ubrr_acc_446p a, ubrr_profit_symbol s, xxi."acc" acc
            where a.caccacc_old = p_OldAccount
            and a.cacccur_old = vCur
            and a.idsmr = nvl(p_IdSmr,ubrr_get_context)
            and acc.caccacc = a.caccacc446p
            and acc.cacccur = a.cacccur446p
            and acc.idsmr = a.idsmr
            and s.symbol = nvl(acc.iaccprofit, substr(a.caccacc446p, 14, 5))
            and s.custype = vCusType
            and rownum = 1;
        exception
            when no_data_found then
                null;
        end;
        return vRet;
    end Get_Acc446pFromOld;

    function Get_Acc446p (p_CusNum  in number,
                          p_AccMask in varchar2,
                          p_AccCur  in varchar2 default null,
                          p_IdSmr   in varchar2 default null,
                          p_Otd     in number   default null)
    return varchar2
    is
        vRet ubrr_acc_446p.caccacc446p%type;
        vCusType varchar2(1);
    begin
        if rp_cus.iscustomeringroup (p_CusNum, 15, 4) = 1 then
            vCusType := '0';
        else
            vCusType := '1';
        end if;
        begin
            select a.caccacc446p
            into vRet
            from ubrr_acc_446p a, ubrr_profit_symbol s, xxi."acc" acc
            where a.caccacc446p like p_AccMask
            and a.cacccur446p = nvl(p_AccCur,'RUR')
            and a.idsmr = nvl(p_IdSmr, ubrr_get_context)
            and ( a.iaccotd = p_Otd or p_Otd is null )
            and acc.caccacc = a.caccacc446p
            and acc.cacccur = a.cacccur446p
            and acc.idsmr = a.idsmr
            and s.symbol = nvl(acc.iaccprofit, substr(a.caccacc446p, 14, 5))
            and s.custype = vCusType
            and rownum = 1;
        exception
            when no_data_found then
                null;
        end;
        return vRet;
    end Get_Acc446p;
    --<< 12.11.2015 ubrr korolkov 15-1059.1

    Function Register (rpDocument in rtDocument)
    return rtRetDoc
    is
        rvDocument  rtDocument := rpDocument; -->><< ubrr 05.04.2017 Севастьянов С.В. 16-3100.2 Комиссии по ЕКО
        rvRetDoc    rtRetDoc;
        cvPrizn     varchar2(1);
        mvRest      number;
        cvAcc47423  varchar2(25);
        cvAcc707    varchar2(25);
        bvNewAcc    boolean;
        ivCountCard number;
        cvBtnRef    varchar2(32);
        UserEx      Exception;
        mvOver      number;
        vcnt        number := 0;
        l_action_sum varchar2(1) := ubrr_bnkserv_balance.gc_action_sum_n;  -- ubrr 21.02.2019 Ризанов Р.Т. [17-1790] АБС: Комиссиии за РКО при наличии овердрафтных договоров
    begin
-- Данные из смр могут пригодится, каждый раз принимаются если вдруг контекст сменится
        select *
          into rsSmr
          from smr;
        -->> ubrr 05.04.2017 Севастьянов С.В. 16-3100.2 Комиссии по ЕКО
        select *
          into rsSmr_to
          from smr;

        select count(*)
          into vcnt
          from xxi."acc"
         where caccacc = rvDocument.cPayee
           and cACCcur = rvDocument.cCurC;

        if vcnt = 1 then
          select *
           into rsSmr_to
           from xxi."smr"
          where idsmr = (select idsmr
                           from xxi."acc"
                          where caccacc = rvDocument.cPayee
                            and cACCcur = rvDocument.cCurC);
        end if;
        --<< ubrr 05.04.2017 Севастьянов С.В. 16-3100.2 Комиссии по ЕКО

        rvDocument := rpDocument;
        if rvDocument.mSumC <= 0 or rvDocument.mSumD <= 0 then
           rvRetDoc.cResult := 'Сумма документа нулевая или отрицательная';
           raise UserEx;
        end if;
-- Собираем атрибуты счетов дт и кт
        if rvDocument.cNameD is null then
          select cACCname, cCUSnumnal, caccprizn
            into rvDocument.cNameD, rvDocument.cInnD, cvPrizn
            from acc, cus
           where CACCACC = rvDocument.cAccD
             and cACCcur = rvDocument.cCurD
             and iCUSnum = iACCcus;
        end if;
        if cvPrizn = 'З' then
            rvRetDoc.cResult := 'Счет '||rvDocument.cAccD||' закрыт';
            raise UserEx;
        end if;
        if rvDocument.cNameC is null then
          select cACCname, cCUSnumnal
            into rvDocument.cNameC, rvDocument.cInnC
            from acc, cus
           where CACCACC = rvDocument.cAccC
             and cACCcur = rvDocument.cCurC
             and iCUSnum = iACCcus;
        end if;
-- условие безакцептного списания
        if rvDocument.cAccept is null then
            begin
                select ' N '||nvl(caccsio,'Б/н')||' от '||to_char(dacclastoper,'DD.MM.YYYY')
                  into rvDocument.cAccept
                  from acc
                 where caccacc = rvDocument.cAccD
                   and cacccur = rvDocument.cCurD;

                select 'Без акцепта согласно '||obg.cobgname||rvDocument.cAccept
                  INTO rvDocument.cAccept
                  from obg, gac
                 where iobgcat = 170
                   and iobgnum = igacnum
                   and iobgcat = igaccat
                   and cgacacc = rvDocument.cAccD
                   and cgaccur = rvDocument.cCurD;
            exception WHEN OTHERS THEN
               rsDocument.cAccept := 'Без акцепта согласно п.___ договора банковского счета'||rvDocument.cAccept;
            end;
        end if;
        rvRetDoc.cResult := 'OK';
        rsDocument := rvDocument;
        if cvPrizn <> 'О' then
           if rsDocument.cType not like '%C%' then
               rvRetDoc.cResult := 'Необходима постановка на картотеку: статус cчета не О';
               raise UserEx;
           else
                rsDocument.cType := 'C';
           end if;
        end if;
        select count(*)
          into ivCountCard
          from trc
         where ctrcaccd = rsDocument.cAccD
           and ctrcstate = '2'
           and ctrcstatenc = '1'
           and mtrcleft <> 0;
-- Есть документы на картотеке, поставим тудаже
        if ivCountCard <> 0 then
           if rsDocument.cType not like '%C%' then
               rvRetDoc.cResult := 'Необходима постановка на картотеку: есть документы на картотеке';
               raise UserEx;
           else
                rsDocument.cType := 'C';
           end if;
        end if;
-- Посчитаем остаток и хватает ли его, - овер
        if rsDocument.cType <> 'C' and rsDocument.cAccD not like '47423%' then
            mvRest := ACC_INFO.GetAccountPP(rsDocument.cAccD, rsDocument.cCurD, rsDocument.dTran);
            mvOver := TRUN.Get_Overdraft(rsDocument.cAccD, rsDocument.cCurD, rsDocument.dTran);
-- Если овер отрицательный, то это блокировка и ее вычитать не надо
            if mvOver > 0 then
                mvRest := mvRest - mvOver;
            end if;
            if mvRest < rsDocument.mSumD then
            -->> ubrr 21.02.2019 Ризанов Р.Т. [17-1790] АБС: Комиссиии за РКО при наличии овердрафтных договоров            
                l_action_sum := ubrr_bnkserv_balance.gc_action_sum_n;
                if ( nvl(rsDocument.lmode_available_rest,false) ) then -- хотим обрабатывать комиссиию в режиме доступного остатка
                   l_action_sum := ubrr_bnkserv_balance.action_sum( p_acc     => rvDocument.cAccD    -- счет с которого планируется списание
                                                                   ,p_cur     => rvDocument.cCurD    -- валюта счета   
                                                                   ,p_idsmr   => ubrr_get_context    -- филиал счета                    
                                                                   ,p_date    => rvDocument.dTran    -- дата расчета остатков как дата_регистрации док-та комиссии 
                                                                   ,p_sum     => rvDocument.mSumD    -- сумма операции списания
                                                                   ,p_add4log => 'cType='||rsDocument.cType||';'
                                                                   ,p_log     => true
                                                                  );
                   l_action_sum := nvl(l_action_sum,ubrr_bnkserv_balance.gc_action_sum_n);                
                end if; 
                if l_action_sum in ( ubrr_bnkserv_balance.gc_action_sum_n, ubrr_bnkserv_balance.gc_action_sum_c ) then
                    if rsDocument.cType not like '%C%' then
                       rvRetDoc.cResult := 'Необходима постановка на картотеку: по счету не достаточно средтсв';
                       raise UserEx;
                    elsif rsDocument.cType like '%C%' then
                       rsDocument.cType := 'C';
                    end if;
                elsif l_action_sum =  ubrr_bnkserv_balance.gc_action_sum_t then
                    rsDocument.cType := replace(rsDocument.cType, 'C');    
                end if;
            --<< ubrr 21.02.2019 Ризанов Р.Т. [17-1790] АБС: Комиссиии за РКО при наличии овердрафтных договоров                    
            else
                rsDocument.cType := replace(rsDocument.cType, 'C');
            end if;
        end if;
-- Регистрация в картотеку
        if rsDocument.cType = 'C' then
-- Проверка на предыдущий год
            if to_char(rsDocument.dTran,'YYYY') <> to_char(rsDocument.dComm,'YYYY')
               and nvl(rsDocument.cModule, '#') != 'ubrr_sbs_new.Ежедневные' -- 07.11.2017 ubrr korolkov 17-1071
            then
-- Заменим счет на 707
               if rsDocument.cAccC like '706%' then
                   rsDocument.cAccC := Get_Acc707(rsDocument.cAccC);
               end if;

               begin
                   select caccacc
                     into cvAcc707
                     from acc
                    where caccacc = rsDocument.cAccC
                      and cacccur = rsDocument.cCurC;
               exception when no_data_found then
                    rvRetDoc.cResult := 'Счет '||rsDocument.cAccC||' не найден';
                    raise UserEx;
               end;
            end if;
            rvRetDoc := RegisterCard;
-- Если прошлый год надо поставить пачку 115 и признак СПОД
            if to_char(rsDocument.dTran,'YYYY') <> to_char(rsDocument.dComm,'YYYY')
               and nvl(rsDocument.cModule, '#') != 'ubrr_sbs_new.Ежедневные' -- 07.11.2017 ubrr korolkov 17-1071
            then
                update trn
                   set ctrnpurp = 'СПОД. '||rsDocument.cPurp,
                       itrnbatnum = 115
                 where itrnnum = rvRetDoc.iNum
                   and ctrnaccc = rsDocument.cAccC;
            end if;
            if rvRetDoc.cResult <> 'OK' then
               raise UserEx;
            end if;
-- Регистрация в ТРН
        elsif rsDocument.cType = 'T' then
-- Проверка на предыдущий год
            if to_char(rsDocument.dTran,'YYYY') <> to_char(rsDocument.dComm,'YYYY')
               and nvl(rsDocument.cModule, '#') != 'ubrr_sbs_new.Ежедневные' -- 07.11.2017 ubrr korolkov 17-1071
               and nvl(rsDocument.cModule, '#') != 'ubrr_sbs_new.в 1 р.д. мес.' -- 01.02.2019 Фридьев П.В. [19-58770] Изменение даты запуска пролонгации пакетов
            then
-- сразу с 47423
               if rsDocument.cAccD like '47423%' then
                   if rsDocument.cAccC like '706%' then
                       rsDocument.cAccC := Get_Acc707(rsDocument.cAccC);
                   end if;
                   begin
                      select caccacc
                        into cvAcc707
                        from acc
                       where caccacc = rsDocument.cAccC
                         and cacccur = rsDocument.cCurC;
                   exception when no_data_found then
                      rvRetDoc.cResult := 'Счет '||rsDocument.cAccC||' не найден';
                      raise UserEx;
                   end;
                   rsDocument.cPurp := 'СПОД. '||rsDocument.cPurp;
                   rsDocument.iBatNum := 115;
                   rvRetDoc := RegisterMo;
                   if rvRetDoc.cResult <> 'OK' then
                      raise UserEx;
                   end if;
               else
-- получим счет 47423
                   cvAcc47423 := CARD.Get_BVBAccount(rvRetDoc.cResult, bvNewAcc, rsDocument.dTran, rsDocument.cAccD, rsDocument.cCurD, 0, rsDocument.cCurD).cAcc;
                   if cvAcc47423 is null then
                    raise UserEx;
                   end if;

                   if rsDocument.cAccC like '706%' then
                       rsDocument.cAccC := Get_Acc707(rsDocument.cAccC);
                   end if;
                   begin
                      select caccacc
                        into cvAcc707
                        from acc
                       where caccacc = rsDocument.cAccC
                         and cacccur = rsDocument.cCurC;
                   exception when no_data_found then
                      rvRetDoc.cResult := 'Счет '||rsDocument.cAccC||' не найден';
                      raise UserEx;
                   end;

                   rsDocument.cAccD := cvAcc47423;
                   rsDocument.cPurp := 'СПОД. '||rsDocument.cPurp;
                   rsDocument.iBatNum := 115;
                   rsDocument.iBo1 := 0;
                   rsDocument.iBo2 := null;
-- первая часть документа
                   rvRetDoc := RegisterMo;
                   if rvRetDoc.cResult <> 'OK' then
                      raise UserEx;
                   end if;
                   rsDocument := rvDocument;
                   rsDocument.iParent := rvRetDoc.iNum;
                   rsDocument.cAccC := cvAcc47423;
                   rsDocument.cCurC := rsDocument.cCurD;
                   rsDocument.mSumC := rsDocument.mSumD;
-- вторая часть документа
                   rvRetDoc := RegisterMo;
                   if rvRetDoc.cResult <> 'OK' then
                      raise UserEx;
                   end if;
                   rvRetDoc.iANum := 0;
                end if;
            else
-- обычная регистраци
                rvRetDoc := RegisterMo;
            end if;
-- Регистрация в забаланс
        elsif rsDocument.cType = 'Z' then
-- Проверка на предыдущий год
            if to_char(rsDocument.dTran,'YYYY') <> to_char(rsDocument.dComm,'YYYY')
               and nvl(rsDocument.cModule, '#') != 'ubrr_sbs_new.Ежедневные' -- 07.11.2017 ubrr korolkov 17-1071
            then
-- получим счет 47423
               cvAcc47423 := CARD.Get_BVBAccount(rvRetDoc.cResult, bvNewAcc, rsDocument.dTran, rsDocument.cAccD, rsDocument.cCurD, 0, rsDocument.cCurD).cAcc;
               if cvAcc47423 is null then
                raise UserEx;
               end if;

               if rsDocument.cAccC like '706%' then
                   rsDocument.cAccC := Get_Acc707(rsDocument.cAccC);
               end if;
               begin
                  select caccacc
                    into cvAcc707
                    from acc
                   where caccacc = rsDocument.cAccC
                     and cacccur = rsDocument.cCurC;
               exception when no_data_found then
                  rvRetDoc.cResult := 'Счет '||rsDocument.cAccC||' не найден';
                  raise UserEx;
               end;

               rsDocument.cAccD := cvAcc47423;
               rsDocument.cPurp := rsDocument.cPurp;
               rsDocument.cPurp1 := rsDocument.cPurp1;
               rsDocument.cPurp2 := rsDocument.cPurp2;
               rsDocument.iBo1 := 1;
               rsDocument.iBo2 := null;
-- первая часть документа, идет в забаланс, а второй частью закрывается c баланса
               rvRetDoc := RegisterZbl;
               cvBtnRef := rvRetDoc.cBtnRef;
               if rvRetDoc.cResult <> 'OK' then
                  raise UserEx;
               end if;
-- Поставим пачку 115 и признак СПОД
               update trn
                  set ctrnpurp = 'СПОД. '||rsDocument.cPurp,
                      itrnbatnum = 115
                where itrnnum = rvRetDoc.iNum
                  and itrnanum = 0;
               rsDocument := rvDocument;

               rsDocument.cAccC := cvAcc47423;
               rsDocument.cCurC := rsDocument.cCurD;
               rsDocument.mSumD := rsDocument.mSumD + rsDocument.mNdsSum;
               rsDocument.mSumC := rsDocument.mSumD;
-- вторая часть документа, идет отдельным документом
               rsDocument.iParent := null;
               rvRetDoc := RegisterMo;
               if rvRetDoc.cResult <> 'OK' then
                  raise UserEx;
               end if;
               rvRetDoc.cBtnRef := cvBtnRef;
            else
-- обычная регистраци
               rvRetDoc := RegisterZbl;
            end if;
        end if;
        Return rvRetDoc;
    exception when others then
        rvRetDoc.cResult := nvl(rvRetDoc.cResult,sqlerrm);
        Return rvRetDoc;
    end;

    Function RegisterMo
    return rtRetDoc
    is
        rvRetDoc rtRetDoc;
        cvRes    varchar2(1024);
    begin
        savepoint sp_Mo_Reg;
        cvRes := MO.Register(ErrorMsg      => rvRetDoc.cResult,
                             DebitAcc      => rsDocument.cAccD,
                             DebitCur      => rsDocument.cCurD,
                             CreditAcc     => rsDocument.cAccC,
                             CreditCur     => rsDocument.cCurC,
                             DebitSum      => rsDocument.mSumD,
                             CreditSum     => rsDocument.mSumC,
                             OpType        => rsDocument.iBo1,
                             -->>19.07.2021  Зеленко С.А.     DKBPA-1571   ВБ переводы. Взимание комиссий в режиме "онлайн"
                             --Turnovers     => 'ART&ACR',
                             Turnovers     => (case when rsDocument.iParent is not null then 'LIKEPARENT' else 'ART&ACR' end),
                             --<<19.07.2021  Зеленко С.А.     DKBPA-1571   ВБ переводы. Взимание комиссий в режиме "онлайн"
                             SubOpType     => rsDocument.iBo2,
                             RegDate       => rsDocument.dTran,
                             DocDate       => rsDocument.dTran,
                             DocNum        => rsDocument.iDocNum,
                             BatNum        => rsDocument.iBatNum,
                             Debtor_Name   => rsDocument.cNameD,
                             Debtor_INN    => rsDocument.cInnD,
                             Creditor_Name => rsDocument.cNameC,
                             Creditor_INN  => rsDocument.cInnC,
                             Purpose       => rsDocument.cPurp,
                             TermsOfPay    => rsDocument.cAccept,
                             Vo            => '02',
                             Priority      => 5, -- 16.01.2014 ubrr korolkov 12-2288.2(#11743)
                             Payer_Acc     => rsDocument.cPayer,
                             Payee_Acc     => rsDocument.cPayee,
                             ParentID      => rsDocument.iParent,
                             CtrlDebAcc    => 'N',
                             CtrlCredAcc   => 'N');
        if cvRes = 'Ok' then
            rvRetDoc.cPlace := 'TRN';
            rvRetDoc.iNum := Mo.getlastdocid;
            rvRetDoc.iANum := Mo.getlastdocida;
            rvRetDoc.cResult := 'OK';
        else
            rollback to sp_Mo_Reg;
        end if;
        return rvRetDoc;
    exception when others then
        rollback to sp_Mo_Reg;
        rvRetDoc.cResult := sqlerrm;
        Return rvRetDoc;
    end;

    Function RegisterCard
    return rtRetDoc
    is
        rParam  CARD.T_SetUpParam;
        rvRetDoc rtRetDoc;
        ivRes    number;
    begin
        savepoint sp_Card_Reg;
        if rsDocument.mNdsSum is not null then
           rParam.mVatSum  := rsDocument.mNdsSum;
           rParam.cVatAcc  := rsDocument.cNdsAcc;
           rParam.cVatCur  := 'RUR';
           rParam.cVatPurp := rsDocument.cPurp2;
           CARD.Set_Up_At_File_ParamR (rParam);
           rsDocument.mSumD := rsDocument.mSumD + rsDocument.mNdsSum;
        end if;

        ivRes := CARD.Set_Up_At_File(vcERROR_MSG    => rvRetDoc.cResult,
                                     cACCD          => rsDocument.cAccD,
                                     cCURRENCY      => rsDocument.cCurD,
                                     cACCC          => rsDocument.cAccC,
                                     cCredCur       => rsDocument.cCurC,
                                     dCREATE        => rsDocument.dTran,
                                     dDOC           => rsDocument.dTran,
                                     dVAL           => rsDocument.dTran,
                                     mSUM           => rsDocument.mSumD,
                                     cSumCur        => rsDocument.cCurD,
                                     iDOCNUM        => rsDocument.iDocNum,
                                     iBATNUM        => rsDocument.iBatNum,
                                     vcPURP         => rsDocument.cPurp,
                                     cCondPay       => rsDocument.cAccept,
                                     iTOP           => rsDocument.iBo1,
                                     iSOP           => rsDocument.iBo2,
                                     vcCLIENT_NAME  => rsDocument.cNameD,
                                     vcCLIENT_INN   => rsDocument.cInnD,
                                     vcACCA         => rsDocument.cPayee,
                                     vcOWNA         => rsDocument.cNameC,
                                     vcINNA         => rsDocument.cInnC,
                                     vcMFOA         => rsSmr_to.CSMRMFO8,   -->><< ubrr 05.04.2017 Севастьянов С.В. 16-3100.2 Комиссии по ЕКО
                                     vcCORACCA      => rsSmr_to.CSMRKORACC, -->><< ubrr 05.04.2017 Севастьянов С.В. 16-3100.2 Комиссии по ЕКО
                                     vcBNAMEA       => rsSmr.CSMRNAME,
                                     vcMFOO         => rsSmr.CSMRMFO8,
                                     cCORACCO       => rsSmr.CSMRKORACC,
                                     iPRIORITY      => 5, -- 16.01.2014 ubrr korolkov 12-2288.2(#11743)
                                     Next_Control   => 'N');
        if ivRes = 0 then
            rvRetDoc.cPlace := 'TRC';
            rvRetDoc.iCardNum  := CARD.Get_Last_Num;
            rvRetDoc.iNum := Mo.getlastdocid;
            rvRetDoc.iANum := Mo.getlastdocida;
            rvRetDoc.cResult := 'OK';
        else
            rollback to sp_Card_Reg;
        end if;
        return rvRetDoc;
    exception when others then
        rollback to sp_Card_Reg;
        rvRetDoc.cResult := sqlerrm;
        Return rvRetDoc;
    end;

    -->> НАЧАЛО UBRR 10.03.2017 Севастьянов С.В. [16-3100.2] АБС: Комиссия за пересчет ЕКО между филиалами
  ---- Определение корр. счета по IDSMR источник и назначение, валюта cчета, признак (DB = Дебет или CR = Кредит)
  FUNCTION Get_Corr_Acc(c_idsmr in VARCHAR2, c_cur in VARCHAR2,Db_Cr in varchar2,c_src_idsmr in varchar2 default null) return VARCHAR2
   is
     ret  VARCHAR2(25):='3030?';
     cBs2 VARCHAR2(20):='303';
   begin
   /*dbms_output.put_line('Get_Corr_Acc 1:c_idsmr='||c_idsmr
                        ||' c_cur='||c_cur
                        ||' Db_Cr='||Db_Cr
                        ||' c_src_idsmr='||c_src_idsmr
   );/**/
        if     Db_Cr='DB'then
           cBs2:='30302%';
        elsif  Db_Cr='CR'then
           cBs2:='30301%';
        end if;
        if c_idsmr='1'and c_cur='RUR'then
            select caccacc
            into ret
            from  xxi."smr" smr, ubrr_acc_v acc
            where   acc.idsmr    =c_idsmr  --smr.idsmr    =acc.idsmr
                and smr.idsmr    =nvl(c_src_idsmr, BankIdSmr)
                and acc.caccacc  like cBs2 --'30301%'
                and acc.cacccur  =c_cur
                and acc.iaccotd  =smr.ISMROTD
                and acc.caccprizn='О'
                --and rownum=1;
                and exists(select '*' from xxi."mca" where cmcaacc=caccacc and cmcacur=c_cur and idsmr=acc.idsmr)-->>><<<ubrr Лобик Д.А.02.12.2009, 03.11.2009 № 5041-05/020066 Безакцептное списание с р/с Заемщиков и Поручителей, открытых в филиалах
                ;
   /*dbms_output.put_line('Get_Corr_Acc 2:cBs2='||cBs2
                        ||' ret='||ret
   );/**/
        else
            select caccacc
            into ret
            from  xxi."smr" smr, xxi."acc" acc
            where   smr.idsmr    =acc.idsmr
                and smr.idsmr    =c_idsmr
                and acc.caccacc  like cBs2||'9000' --'30301%'
                and acc.cacccur  =c_cur
                and acc.iaccotd  =smr.ISMROTD
                and acc.caccprizn='О'
                --and rownum=1;
                and exists(select '*' from xxi."mca" where cmcaacc=caccacc and cmcacur=c_cur and idsmr=acc.idsmr)-->>><<<ubrr Лобик Д.А.02.12.2009, 03.11.2009 № 5041-05/020066 Безакцептное списание с р/с Заемщиков и Поручителей, открытых в филиалах
                ;
   /*dbms_output.put_line('Get_Corr_Acc 3:cBs2='||cBs2
                        ||' ret='||ret
   );/**/

               /*
                select * from xxi."kbnk" , xxi."smr" smr, xxi."mca" mca
                where NBNK_CUS is not null
                and nbnk_cus=ISMRCUS
                and nbnk_id=imcabank_id
                and cmcaacc like cBs2 --'30301%'
                --and cmcacur='RUR'
                and mca.idsmr=smr.idsmr
                and smr.idsmr='5'
                */
        end if;--if c_idsmr='1'and c_cur='RUR'then
        return ret;
   exception when others then
          /*dbms_output.put_line('Get_Corr_Acc ERROR:cBs2='||cBs2
                               ||' ret='||ret
                               ||' error='||sqlerrm
          );/**/
          return ret;
   end Get_Corr_Acc;
  --<< КОНЕЦ UBRR 10.03.2017 Севастьянов С.В. [16-3100.2] АБС: Комиссия за пересчет ЕКО между филиалами
   function get_userid(p_usr varchar2 default null) return number is
    v_res usr.iusrid%type;
  begin
    select iusrid into v_res from usr where cusrlogname = nvl(p_usr, user);
    return v_res;
  exception
    when no_data_found then
      return null;
  end get_userid;


  function reg_to_trn(
             p_trn_rec     in xxi."trn"%rowtype,
             p_regdate     in date,
             cPlace        in varchar2,
             iCardNum      in integer,
             mfr_text_err out varchar2
                     )
  return TS.T_Trn_ID is
    v_ttrnid             TS.T_Trn_ID;
    iok                  number;
    v_error_msg          varchar2(1024);
    v_erms               varchar2(1024);
    r_idoc_ctrl_except   exception;
    r_QTRN_exception     exception;
    mfr_exception        exception;
    trn_rec              xxi."trn"%rowtype := p_trn_rec;
    v_state              varchar2(12);
    v_ActionCause        varchar2(4000);
  begin
    -- исключение из проверки(Check_40821) по счетам 40821 второй и/или третей проводки для МФР (для PDOG_REG проверка зашита в таблице select * from AC_DATA where upper(CDEFINT) = Upper('IDOC_REG.Check'))
    v_ActionCause := card.Get_ActionCause;
    card.Set_ActionCause(trn_rec.CTRNPURP);
    -- регистрация платежного документа
      v_error_msg := PDOC_REG.Entry_PDoc(
                       Error_Msg      => v_erms,                    -- Сообщение об ошибке
                       BO1            => 52,                        -- БО1
                       Client_Acc     => trn_rec.CTRNCLIENT_ACC,    -- Счет клиента нашего банка
                       Corr_RBIC      => trn_rec.cTRNmfoa,          -- БИК банка корреспондента
                       Corr_CorAcc    => trn_rec.cTRNcoracca,       -- Корсчет банка корреспондента
                       Corr_Acc       => trn_rec.CTRNACCA,          -- Счет корреспондента
                       Doc_Sum        => trn_rec.mTRNsum,           -- Сумма документа
                       Debit_Acc      => trn_rec.CTRNACCD,          -- Счет дебета
                       Credit_Acc     => trn_rec.CTRNACCC,          -- Счет кредита
                       State          => '40001',                   -- Состояние, в котором надо зарегистрировать
                       Purpose        => trn_rec.CTRNPURP,          -- Назначение платежа
                                                                    -- БО2
                       Client_RBIC    => trn_rec.cTRNMfoO,          -- БИК клиента нашего банка
                       Client_CorAcc  => trn_rec.cTRNcoracco,       -- Корсчет нашего банка
                       Client_Name    => trn_rec.ctrnclient_name,   -- Наименование клиента нашего банка
                       Corr_Bank_Name => trn_rec.cTRNbnamea,        -- Наименование банка корреспондента
                       Corr_Name      => trn_rec.cTRNowna,          -- Наименование корреспондента
                       Doc_Num        => trn_rec.iTRNdocnum,        -- Номер документа
                       Batch_Num      => trn_rec.iTRNbatnum,        -- Номер пачки
                       Reg_Date       => p_regdate,                 -- Дата регистрации
                       Doc_Date       => p_regdate,                 -- Дата документа
                       Val_Date       => p_regdate,                 -- Срок платежа
                       Priority       => 5,                         -- Приоритет
                       Client_INN     => trn_rec.cTRNclient_inn,    -- ИНН клиента нашего банка
                       Corr_INN       => trn_rec.cTRNinna,          -- ИНН корреспондента
                       -- DWay           IN  TRN.cTRNdway%TYPE     DEFAULT NULL,    -- Тип платежа (почта/телеграф/Эл.платеж)
                       -- Abs_Debit_Acc  IN  T_NumAcc              DEFAULT NULL,    -- Счет дебета для выписки
                       -- Abs_Credit_Acc IN  T_NumAcc              DEFAULT NULL,    -- Счет кредита для выписки
                       -- Corr_SBCodeA   IN  TRN.iTRNSBCodeA%TYPE  DEFAULT NULL,    -- Код участника клиринга
                       Ent_Date       => p_regdate,        --IN  DATE                  DEFAULT NULL,    -- дата поступления документа в банк (от клиента)
                       -- Client_KPP     IN  TRN.cTRNclient_kpp%TYPE DEFAULT NULL,  -- КПП клиента нашего банка
                       -- Corr_KPP       => r_cur_cdt.ccdtinna,    --IN  TRN.cTRNkppa%TYPE     DEFAULT NULL,    -- КПП корреспондента
                       cVO            => '02'-- r_cur_cdt.ccdtvo  --IN  TRN.cTrnVO%TYPE       DEFAULT NULL,    -- Вид операции
                       -- cDocRef        IN  TRN.cTrnRef%TYPE      DEFAULT NULL,    -- SWIFT reference
                       -- cSupplCond     IN  TRN.cTrnText3%TYPE    DEFAULT NULL,    -- дополнительные условия
                       -- rDeptInfo      IN  TS.T_DeptInfo         DEFAULT NULL,    -- Ведомственная информация
                       -- rCardHistor    IN  TS.T_CardHistor       DEFAULT NULL,    -- Атрибуты платежного ордера
                       -- rLetOfCr       IN  TS.T_LetOfCr          DEFAULT NULL,    -- Атрибуты аккредитива
                       -- ID_Bnk         IN  INTEGER DEFAULT NULL                   -- Ссылка на БНК
                       );
      card.Set_ActionCause(v_ActionCause);
      v_ttrnid := PDOC_REG.Get_LastDoc_UID;
      -- проверяем результат выполнения
      IF  upper(v_error_msg) <> 'OK' THEN
        raise r_QTRN_exception;
      end if;
      -- запоминаем ид-шник созданной транзакции
      trn_rec.iTrnNum  := v_ttrnid.num;
      trn_rec.iTrnAnum := v_ttrnid.anum;
      -- подтверждение документа:
      IF cPlace = 'TRC' THEN
      -- если картотека:
        v_error_msg := card.Affirm_Doc_Card (
                         ErrorMsg   => v_erms,              -- OUT VARCHAR2,           -- Сообщение об ошибке для возврата
                         iTRC_Num   => iCardNum,            -- IN  INTEGER,            -- iTRCnum документа
                         iTRC_ANum  => 0,                   -- IN  INTEGER,            -- iTRCanum документа
                         AffirmDate => p_regdate);          -- IN  TRC.dTRCtran%TYPE) -- Тип последконтроля
        IF upper(v_error_msg) = 'AFF_ALREADY_AFFIRMED' THEN -- Документ уже подтвержден в картотеке №2.
          v_error_msg := 'OK';
        END IF;
      ELSE
        v_error_msg := idoc_ctrl.Affirm_Doc (
                         iTRN_Num    => v_ttrnid.num,      -- IN  TRN.iTRNnum%TYPE,   -- iTRNnum документа
                         iTRN_ANum   => v_ttrnid.Anum,     -- IN  TRN.iTRNanum%TYPE,  -- iTRNanum документа
                         AffirmDate  => p_regdate,         -- IN  DATE,               -- Дата подтверждения
                         ErrorMsg    => v_erms) ;          -- Сообщение об ошибке для возврата
        IF upper(v_error_msg) = 'AFF_ALREADY_AFFIRMED' THEN -- Документ уже подтвержден
          v_error_msg := 'OK';
        END IF;
      END IF;
      -- считываем статус последней транзакции
      SELECT CTRNSTATE1||CTRNSTATE2||CTRNSTATE3||CTRNSTATE5
        INTO v_state
        FROM xxi."trn"
       WHERE itrnnum  = v_ttrnid.num
         AND itrnanum = v_ttrnid.Anum;
      -- проверка статуса последней транзакции:
      IF v_state = '3100' THEN
        -- устанавливаю статус макет сформирован
        UPDATE xxi."trn"
           SET cTrnState2 = '2',
               cTrnState5 = '1'
         WHERE itrnnum  = v_ttrnid.num
           AND itrnanum = v_ttrnid.Anum;
        -- последконтроль
        iok := -->>><<<ubrr Лобик Д.А.27.01.2010, 09-3, 5041-05/001235 от 22.01.10  Безакцептное списание с р/с Заемщиков/Поручителей, открытых в филиалах
             idoc_ctrl.to_balance(dtran       => trn_rec.DTRNTRAN,
                                  rid         => v_ttrnid,
                                  bignorerb   => FALSE, -->>><<<ubrr Лобик Д.А.27.01.2010, 09-3, 5041-05/001235 от 22.01.10  Безакцептное списание с р/с Заемщиков/Поручителей, открытых в филиалах TRUE
                                  cerror      => v_error_msg);
        IF iok <> 0
        THEN
          raise r_idoc_ctrl_except;
        end if;
      end if;
    -- сохраняем идентификаторы транзакции (чтобы потом можно было найти связанные проводки)
    INSERT INTO XXI.trn_trn(Isrcnum, Isrcanum, Idestnum, Idestanum) values (p_trn_rec.iTrnNum, p_trn_rec.iTrnAnum, trn_rec.iTrnNum, trn_rec.iTrnAnum);
    -- исключаем документ из обработки по ЛОРО счетам
    INSERT INTO ubrr_data.ubrr_trn_loro_excpt VALUES(trn_rec.iTrnNum, trn_rec.iTrnAnum);
    -- успех
    mfr_text_err  :=  'OK';
    return        v_ttrnid;
  -- обработка исключений:
  exception
    when r_QTRN_exception then
      v_ttrnid.Num        := null;
      v_ttrnid.Anum       := null;
      mfr_text_err        := 'r_QTRN_exception: ' || substr(v_error_msg || ' ' || v_erms, 1, 255);
      return v_ttrnid;
    when r_idoc_ctrl_except then
      v_ttrnid.Num        := null;
      v_ttrnid.Anum       := null;
      mfr_text_err        := 'r_idoc_ctrl_except: ' || substr(v_error_msg || ' ' || v_erms, 1, 255);
      return v_ttrnid;
    when others then
      v_ttrnid.Num        := null;
      v_ttrnid.Anum       := null;
      mfr_text_err        := 'others: ' || substr(substr(sqlerrm, 1, 55) || ' ' || DBMS_UTILITY.Format_Call_Stack(), 1, 255);
      return v_ttrnid;
  end;

  Function Register_MFR(rpDocument   in rtDocument,
                        d_idsmr      in smr.idsmr%type,
                        c_idsmr      in smr.idsmr%type,
                        p_regdate    in date,
                        mfr_text_err out varchar2)
  return rtRetDoc is
       r_smr_from           xxi."smr"%ROWTYPE; -- откуда (IDSMR дебета)
       r_smr_to             xxi."smr"%ROWTYPE; -- куда   (IDSMR кредита)
       r_smr_go             xxi."smr"%ROWTYPE; -- ГО
       v_accd               varchar2(50);
       v_accc               varchar2(50);
       -- v_newpurp            varchar2(4000);
       -- iok                  number;
       v_error_msg          varchar2(1024);
       v_erms               varchar2(1024);
       r_idoc_ctrl_except   exception;
       r_QTRN_exception     exception;
       mfr_exception        exception;
       rvDocument           rtDocument := rpDocument;
       rvRetDoc             rtRetDoc;
       v_message_err_       varchar2(1024);
       trn_rec              xxi."trn"%rowtype;
       vRegUser             xxi.usr.cusrlogname%type;
       vRegUser1            xxi.usr.cusrlogname%type;  -->><<-- ubrr 23.09.2016 Арсланов Д.Ф. 16-2222 Изменение пользователя для проводки
       s_idsmr              smr.idsmr%type := d_idsmr;
       -- v_state              varchar2(12);              -- статус транзакции
       v_algoritm           number := 0;
       vctrnclient_name     varchar2(255);
       -- v_ActionCause        varchar2(4000);
  begin
    --- получаем инф по IDSMR
    SELECT * INTO r_smr_from FROM xxi."smr" WHERE idsmr = d_idsmr;
    SELECT * INTO r_smr_to   FROM xxi."smr" WHERE idsmr = c_idsmr;
    SELECT * INTO r_smr_go   FROM xxi."smr" WHERE idsmr = '1';
    --- сохраним счет клиента
    v_accd              := rvDocument.cAccD;
    v_accc              := rvDocument.cAccC;
    -- собственно шаг 1
    -- устанавливаем точку отката
    savepoint bbw_x;
    -- меняем контекст
    XXI_CONTEXT.Set_IDSmr(ID_Smr => d_idsmr);
    -- меняем некоторые параметры такие как БО1, счет кредита и наименование получателя
    rvDocument.iBo1    := 22;
    rvDocument.iBo2    := null;
    -- Расчетный Счет или Доходный счет комиссии находится в Головном.
    -- Делаем 2-е проводки через счет межфилиальных расчетов в голове
    if (c_idsmr != d_idsmr) AND  (d_idsmr = 1 OR c_idsmr = 1) then
      rvDocument.cAccC   := get_corr_acc(d_idsmr /*ОТКУДА*/, rvDocument.cCurD, 'CR', c_idsmr /*КУДА*/);
      v_algoritm := 0;
    elsif (c_idsmr != d_idsmr AND  d_idsmr != 1 AND c_idsmr != 1) then
      rvDocument.cAccC   := get_corr_acc(d_idsmr /*ОТКУДА*/, rvDocument.cCurD, 'CR', '1' /*КУДА*/);
      v_algoritm := 1;
    end if;
    -- Устанавливаем счет получателя и наим. получ.
    rvDocument.cPayee  := v_accc;
    -- назначение платежа
    XXI_CONTEXT.Set_IDSmr(ID_Smr => c_idsmr);
    begin
          select cACCname
            into rvDocument.cNameC
            from acc, cus
           where CACCACC = v_accc
             and cACCcur = rvDocument.cCurC
             and iCUSnum = iACCcus;
    exception when others then null; end;
    XXI_CONTEXT.Set_IDSmr(ID_Smr => d_idsmr);
    -- v_newpurp          := rvDocument.cpurp;
    rvDocument.cpurp   := rvDocument.cNameC || /*' в рамках ЕКО, р/с ' || v_accd ||/**/ ' ' || rpDocument.cPurp;
    --
    rvDocument.cNameC  := r_smr_to.CSMRNAME; -- наименование получ.
    -- проверяем что правильно отработала функция поиска корр. счета
    if substr(rvDocument.cAccC, -1) = '?'
    then
      rvRetDoc.cResult := 'error get_corr_acc: ' || rvDocument.cAccC;
    else
      -- воспользуемся стандартной функцией регистрации документа
      rvRetDoc         := ubrr_zaa_comms.Register(rvDocument);
    end if;
    -- если что-то пошло не так обработаем эту ситуацию:
    if rvRetDoc.cResult != 'OK'
    then
    -- проверка картатека не картатека
      if rvRetDoc.cPlace != 'TRC'
      then
        mfr_text_err  := 'REG' || to_char(v_algoritm) || '_MFR: Step_1: ';
      else
        mfr_text_err  := 'CARD_REG' || to_char(v_algoritm) || '_MFR: Step_1: ';
      end if;
    -- формируем лог событий:
      mfr_text_err  := mfr_text_err || substr(rvRetDoc.cResult, 1, 255);
    -- инициируем обработку исключений
      raise mfr_exception;
    end if;
    --********************
    --**** шаг второй: ***
    --********************
    if rvRetDoc.cPlace != 'TRC'
    then
      mfr_text_err  := 'REG' || to_char(v_algoritm) || '_MFR: Step_2: ';
    else
      mfr_text_err      := 'CARD_REG' || to_char(v_algoritm) || '_MFR: Step_2: ';
      rvRetDoc.cResult  := mfr_text_err;
      rvRetDoc.iCardNum := null;
      rollback to bbw_x;
      -- idoc_reg.setupregisterparams(regseq => '2FILE2', regcpdfrom => NULL, regctrlmode => 'N');
      rvDocument.iBo1   := 25; -- ставим на картотеку с БО1 = 25
      rvDocument.iBo2   := rpDocument.iBo2;
      rvDocument.cNameC := rvDocument.cNameC || ' ' || v_accc; -- наименование получ.
      -- rvDocument.cPurp  := replace(rvDocument.cPurp, '40821', '4O821');
      --rvDocument.cPurp  := v_newpurp;
      --rvDocument.cPurp2 := rvDocument.cPurp;
      --v_ActionCause     := card.Get_ActionCause;
      --card.Set_ActionCause(rvDocument.cpurp);
      rvRetDoc          := ubrr_zaa_comms.Register(rvDocument);
      --card.Set_ActionCause(v_ActionCause);
      if rvRetDoc.cResult != 'OK'
      then
        -- формируем лог событий:
        mfr_text_err  := mfr_text_err || substr(rvRetDoc.cResult, 1, 255);
        -- инициируем обработку исключений
        raise mfr_exception;
      end if;
    end if;
    -- шаг второй необходимо найти созданные транзакции
    declare
       v_ttrnid       TS.T_Trn_ID;
       viTrnNum       xxi."trn".iTrnNum%type;
       viTrnANum      xxi."trn".iTrnANum%type;
       viTrnNum_last  xxi."trn".iTrnNum%type;
       viTrnANum_last xxi."trn".iTrnANum%type;
    begin
       if rvRetDoc.cPlace != 'TRC'
       then
         viTrnNum := rvRetDoc.iNum;
       else
         select t.*
           into trn_rec
           from (select *
                   from xxi."trn" t
                  where t.ITRNNUM = (select ITRNNUM from xxi."trn" t where t.ITRNNUMANC = rvRetDoc.iCardNum)
               order by t.iTrnAnum desc
                ) t
          where rownum = 1;
        -- Запомним найденную транзакцию
        viTrnNum  := trn_rec.iTrnNum;
        viTrnANum := trn_rec.iTrnAnum;
       end if;
    -- шаг третий:
    if rvRetDoc.cPlace != 'TRC'
    then
      mfr_text_err  := 'REG' || to_char(v_algoritm) || '_MFR: Step_3: ';
    else
      mfr_text_err  := 'CARD_REG' || to_char(v_algoritm) || '_MFR: Step_3: ';
    end if;
    -- шаг третий по найденным транзакциям ищем нужную нам транзакцию,
    -- собственно по которой будем реализовывать межфилиальную цепочку
    if rvRetDoc.cPlace != 'TRC'
    then
      select t.*
        into trn_rec
        from (-- поиск нужной транзакции:
                select *
                  from xxi."trn" t
                 where t.iTrnNum  = viTrnNum
                   and t.CTRNACCC like '303%' -- '70%'
                   and t.ITRNTYPE = 22
              order by t.iTrnAnum desc
             ) t
       where rownum = 1;
    end if;

    if rvRetDoc.cPlace != 'TRC' then
      mfr_text_err  := 'REG' || to_char(v_algoritm) || '_MFR: Step_4: ';
    else
      mfr_text_err  := 'CARD_REG' || to_char(v_algoritm) || '_MFR: Step_4: ';
    end if;

    -- шаг четвертый в данную транзакцию вносим необх коррекции:
    -- XXI_CONTEXT.Set_IDSmr(ID_Smr => d_idsmr);
    trn_rec.itrntype   := 22;
   -- if rvRetDoc.cPlace != 'TRC'
   -- then
      trn_rec.itrnsop    := null;
   -- end if;
    trn_rec.CTRNACCC     := v_accc;-- get_corr_acc(d_idsmr /*ОТКУДА*/, rvDocument.cCurD, 'CR', c_idsmr /*КУДА*/);
    trn_rec.CTRNACCD     := v_accd;
    trn_rec.cTRNMfoO     := r_smr_from.cSMRmfo8;
    trn_rec.cTRNcoracco  := r_smr_from.cSMRKorAcc; -- trn_rec.CTRNACCC;
    trn_rec.cTRNmfoa     := r_smr_to.cSMRmfo8;
    trn_rec.cTRNcoracca  := r_smr_to.cSMRKorAcc;
    trn_rec.cTRNbnamea   := r_smr_from.cSMRName;
    trn_rec.cTRNtext4    := r_smr_from.cSMRCity;
    trn_rec.cTrnAccA     := v_accc;
    --
    -->> UBRR 06.03.2017 Севастьянов С.В исправление наименования получ.
    trn_rec.CTRNOWNA       := r_smr_to.CSMRNAME;
    --<< (кон.) UBRR 06.03.2017 Севастьянов С.В исправление наименования получ.
    if rvRetDoc.cPlace = 'TRC'
    then
      -- сумма комиссии
      trn_rec.mTRNsum := rvDocument.mSumD;
    end if;
    --
    v_ttrnid.num     := trn_rec.iTrnNum;
    v_ttrnid.anum    := trn_rec.iTrnANum;
    -- Формирование МФ проводок (1-ая мф проводка):
    if rvRetDoc.cPlace != 'TRC' then
      mfr_text_err  := 'REG' || to_char(v_algoritm) || '_MFR: Step_5: ';
    else
      mfr_text_err  := 'CARD_REG' || to_char(v_algoritm) || '_MFR: Step_5: ';
    end if;
    -- шаг пятый организуем межфилиальную цепочку:
    if v_algoritm = 0 then -- случай когда 2-е проводки
      -- Устанавливаем контекст:
      XXI_CONTEXT.Set_IDSmr(ID_Smr => c_idsmr);
      -- Дебет меняем
      trn_rec.CTRNACCD        := get_corr_acc(c_idsmr /*ОТКУДА*/, rvDocument.cCurC, 'DB', d_idsmr /*КУДА*/);
      -- Кредит восстанавливаем как было
      trn_rec.CTRNACCC        := v_accc; -- фактически назначение (счет кассы)
      trn_rec.CTRNCURC        := rpDocument.cCurC; -- валюта кредита
      -- устанавливаем БО1 и БО2
      trn_rec.itrntype        := 52;
      trn_rec.itrnsop         := null;
      --- iTrnNum    -- Идентификатор
      --- iTrnAnum   -- 0 - родитель, 1..N дочерний документ (Уникальным ид явл два поля: iTrnNum, iTrnAnum)
      viTrnNum                := trn_rec.iTrnNum;
      viTrnANum               := trn_rec.iTrnAnum;
      --------
      trn_rec.cTRNMfoO        := r_smr_to.cSMRmfo8;
      trn_rec.cTRNcoracco     := r_smr_to.cSMRKorAcc; -- trn_rec.CTRNACCD;
      trn_rec.cTRNmfoa        := r_smr_from.cSMRmfo8;
      trn_rec.cTRNcoracca     := r_smr_from.cSMRKorAcc;
      trn_rec.cTRNbnamea      := r_smr_to.cSMRName;
      trn_rec.cTRNtext4       := r_smr_to.cSMRCity;
      trn_rec.cTrnAccA        := v_accd; -- Счет с которого спишется комиссия
      trn_rec.CTRNCLIENT_ACC  := v_accc; -- исправлено 24.02.2017
      trn_rec.idsmr           := c_idsmr;
      --------
      /*begin
          select cACCname
            into trn_rec.CTRNOWNA
            from acc, cus
           where CACCACC = trn_rec.CTRNACCC
             and cACCcur = trn_rec.CTRNCURC
             and iCUSnum = iACCcus;
      exception when others then null; end;/**/
      -- меняем назначение
      --v_newpurp              := '' || ' ' || trn_rec.CTRNOWNA || ' в рамках ЕКО, р/с ' || v_accd || ' ' || rpDocument.cPurp /*trn_rec.CTRNPURP/**/;
      --trn_rec.CTRNPURP       := v_newpurp;
      -->> начало UBRR 07.03.2017 Севастьянов С.В. исправление назначения платежа для картотеки
      --if rvRetDoc.cPlace = 'TRC' then
      --  update xxi."trc" t
      --     set t.CTRCPURP = v_newpurp
      --   where t.itrcnum = rvRetDoc.iCardNum;
      --end if;
      --<< конец UBRR 07.03.2017 Севастьянов С.В. исправление назначения платежа для картотеки
      -->> UBRR 06.03.2017 Севастьянов С.В. исправление наименования получателя
      trn_rec.CTRNOWNA        := trn_rec.ctrnclient_name; -- наименование счета плательщика
      trn_rec.ctrnclient_name := r_smr_to.cSMRName;       -- наименование счета получателя
      --<< (кон.) UBRR 06.03.2017 Севастьянов С.В. исправление наименования получателя
      v_ttrnid.num          := null;
      v_ttrnid.anum         := null;
   else -- случай когда нужно 3-и проводки
      -- меняем и кредит и дебет
      XXI_CONTEXT.Set_IDSmr(ID_Smr => '1');
      -- меняем дебет и кредет
      trn_rec.CTRNACCD  := get_corr_acc('1', rvDocument.cCurC, 'DB', d_idsmr);
      trn_rec.CTRNACCC  := get_corr_acc('1', rvDocument.cCurC, 'CR', c_idsmr);
      -- устанавливаем БО1 и БО2
      trn_rec.itrntype  := 52;   -- БО1
      trn_rec.itrnsop   := null; -- БО2
      --- iTrnNum   -- Идентификатор --- xxi.S_ITRNNUM.nextval; --
      --- iTrnAnum  -- 0 - родитель, 1..N дочерний документ (Уникальным ид явл два поля: iTrnNum, iTrnAnum)
      viTrnNum          := trn_rec.iTrnNum;
      viTrnANum         := trn_rec.iTrnAnum;
      --------
      trn_rec.cTRNMfoO       := r_smr_to.cSMRmfo8;   -- >><< UBRR 09.03.2017 Севастьянов С.В. было ГО стало ИДСМР Получателя
      trn_rec.cTRNcoracco    := r_smr_to.cSMRKorAcc; -- >><< UBRR 09.03.2017 Севастьянов С.В. было ГО стало ИДСМР Получателя
      trn_rec.cTRNmfoa       := r_smr_from.cSMRmfo8;
      trn_rec.cTRNcoracca    := r_smr_from.cSMRKorAcc; -- trn_rec.CTRNACCC;
      trn_rec.cTRNbnamea     := r_smr_go.cSMRName;
      trn_rec.cTRNtext4      := r_smr_go.cSMRCity;
      trn_rec.cTrnAccA       := v_accd;
      trn_rec.cTrnClient_Acc := v_accc; -- исправлено 24.02.2017
      trn_rec.idsmr          := '1';
      -------
      -->> UBRR 06.03.2017 Севастьянов С.В. исправление наименования получателя
      trn_rec.CTRNOWNA          := trn_rec.ctrnclient_name; -- наименование счета плательщика
      trn_rec.ctrnclient_name   := r_smr_to.cSMRName;       -- наименование счета получателя
      --<< (кон.) UBRR 06.03.2017 Севастьянов С.В. исправление наименования получателя
      -- создаем вторую проводку
      v_ttrnid.num     := null;
      v_ttrnid.anum    := null;
      -- v_ttrnid         := qtrn.Get_NextTrnID(v_ttrnid);
      -- trn_rec.iTrnNum  := v_ttrnid.num;
      -- trn_rec.iTrnAnum := v_ttrnid.anum;
      vctrnclient_name := trn_rec.CTRNOWNA;
   end if;
        --*****************************************
        --*** регистрация платежного документа: ***
        --*****************************************
        v_ttrnid := reg_to_trn(
                               trn_rec,
                               p_regdate,
                               rvRetDoc.cPlace,
                               rvRetDoc.iCardNum,
                               v_message_err_
                               );
        -- проверка результата регистрации платежного документа:
        if upper(v_message_err_) != 'OK' then
          if substr(v_message_err_, 1, length('r_QTRN_exception: ')) = 'r_QTRN_exception: ' then
            mfr_text_err := mfr_text_err || v_message_err_;
            raise r_QTRN_exception;
          end if;
          if substr(v_message_err_, 1, length('r_idoc_ctrl_except: ')) = 'r_idoc_ctrl_except: ' then
            mfr_text_err := mfr_text_err || v_message_err_;
            raise r_idoc_ctrl_except;
          end if;
          if substr(v_message_err_, 1, length('others: ')) = 'others: ' then
            mfr_text_err := mfr_text_err || v_message_err_;
            raise r_idoc_ctrl_except;
          end if;
          mfr_text_err := mfr_text_err || v_message_err_;
          raise r_idoc_ctrl_except;
        end if;
        -- запоминаем ид-шник созданной транзакции
        trn_rec.iTrnNum  := v_ttrnid.num;
        trn_rec.iTrnAnum := v_ttrnid.anum;
        --***********************************************
        --*** конец регистрация платежного документа: ***
        --***********************************************
      -- если необходимо 3-и проводки
      if v_algoritm = 1 then
        -- устанавливаем контекст
        XXI_CONTEXT.Set_IDSmr(ID_Smr => c_idsmr);
        -- меняем только дебет, кредит восстанавливаем
        trn_rec.CTRNACCD  := get_corr_acc(c_idsmr, rvDocument.cCurC, 'DB', '1');
        trn_rec.CTRNACCC  := v_accc;      -- назначение платежа, доходный счет кассы
        trn_rec.CTRNCURC  := rpDocument.cCurC; -- валюта кредита
        -- устанавливаем БО1 и БО2
        trn_rec.itrntype  := 52;
        --- iTrnNum   -- Идентификатор --- xxi.S_ITRNNUM.nextval; --
        --- iTrnAnum  -- 0 - родитель, 1..N дочерний документ (Уникальным ид явл два поля: iTrnNum, iTrnAnum)
        viTrnNum_last  := v_ttrnid.Num;
        viTrnANum_last := v_ttrnid.Anum;
        --------
        trn_rec.cTRNMfoO       := r_smr_to.cSMRmfo8;
        trn_rec.cTRNcoracco    := r_smr_to.cSMRKorAcc; -- trn_rec.CTRNACCD;
        trn_rec.cTRNmfoa       := r_smr_from.cSMRmfo8;
        trn_rec.cTRNcoracca    := r_smr_from.cSMRKorAcc;
        trn_rec.cTRNbnamea     := r_smr_to.cSMRName;
        trn_rec.cTRNtext4      := r_smr_to.cSMRCity;
        trn_rec.cTrnAccA       := v_accd;    -- исправлено 24.02.2017 было r.cSBSAccC
        trn_rec.cTrnClient_Acc := v_accc;
        trn_rec.idsmr          := c_idsmr;
        --------
        if rvRetDoc.cPlace != 'TRC' then
          mfr_text_err  := 'REG' || to_char(v_algoritm) || '_MFR: Step_5.2.1: ';
        else
          mfr_text_err  := 'CARD_REG' || to_char(v_algoritm) || '_MFR: Step_5.2.1: ';
        end if;
        --------
        /*begin
          select cACCname
            into trn_rec.CTRNOWNA
            from acc, cus
           where CACCACC = trn_rec.CTRNACCC
             and cACCcur = trn_rec.CTRNCURC
             and iCUSnum = iACCcus;
        exception when others then null; end;/**/
        -- меняем назначение
        --v_newpurp             := '' || ' ' || trn_rec.CTRNOWNA || ' в рамках ЕКО, р/с ' || v_accd || ' ' || rvDocument.cPurp /* trn_rec.CTRNPURP/**/;
        --trn_rec.CTRNPURP := v_newpurp;
        -->> начало UBRR 07.03.2017 Севастьянов С.В. исправление назначения платежа для картотеки
        --if rvRetDoc.cPlace = 'TRC' then
        --  update xxi."trc" t
        --     set t.CTRCPURP = v_newpurp
        --   where t.itrcnum = rvRetDoc.iCardNum;
        --end if;
        --<< конец UBRR 07.03.2017 Севастьянов С.В. исправление назначения платежа для картотеки
        -->> UBRR 06.03.2017 Севастьянов С.В. исправление наименования получателя
        trn_rec.CTRNOWNA        := vctrnclient_name;  -- наименование счета плательщика
        trn_rec.ctrnclient_name := r_smr_to.cSMRName; -- наименование счета получателя
        --<< (кон.) UBRR 06.03.2017 Севастьянов С.В. исправление наименования получателя
        -- создаем третью проводку
        v_ttrnid.num     := null;
        v_ttrnid.anum    := null;
        -- v_ttrnid         := qtrn.Get_NextTrnID(v_ttrnid);
        trn_rec.iTrnNum  := viTrnNum_last;
        trn_rec.iTrnAnum := viTrnANum_last;
        --*****************************************
        --*** регистрация платежного документа: ***
        --*****************************************
        v_ttrnid := reg_to_trn(
                               trn_rec,
                               p_regdate,
                               rvRetDoc.cPlace,
                               rvRetDoc.iCardNum,
                               v_message_err_
                               );
        -- проверка результата регистрации платежного документа:
        if upper(v_message_err_) != 'OK' then
          if substr(v_message_err_, 1, length('r_QTRN_exception: ')) = 'r_QTRN_exception: ' then
            mfr_text_err := mfr_text_err || v_message_err_;
            raise r_QTRN_exception;
          end if;
          if substr(v_message_err_, 1, length('r_idoc_ctrl_except: ')) = 'r_idoc_ctrl_except: ' then
            mfr_text_err := mfr_text_err || v_message_err_;
            raise r_idoc_ctrl_except;
          end if;
          if substr(v_message_err_, 1, length('others: ')) = 'others: ' then
            mfr_text_err := mfr_text_err || v_message_err_;
            raise r_idoc_ctrl_except;
          end if;
          mfr_text_err := mfr_text_err || v_message_err_;
          raise r_idoc_ctrl_except;
        end if;
        -- запоминаем ид-шник созданной транзакции
        trn_rec.iTrnNum  := v_ttrnid.num;
        trn_rec.iTrnAnum := v_ttrnid.anum;
      end if;
      -- устанавливаем одинаковое назначение для всех проводок
      declare
        tranzrownum number := 1;
      begin
        for tranz in (
                      select *
                        from (-- первая проводка (БО1 = 22 если не картотека)
                              select idsmr, iTrnNum, ITRNANUM
                                from xxi."trn" t
                               where t.iTrnNum  = viTrnNum
                                 and t.ITRNANUM = viTrnANum
                              --
                              union all
                              -- вторая проводка (БО1=52)
                              select idsmr, iTrnNum, ITRNANUM
                                from xxi."trn" t
                               where t.iTrnNum  = viTrnNum_last
                                 and t.ITRNANUM = viTrnANum_last
                              --
                              union all
                              -- третия проводка (БО1=52)
                              -- данная проводка отсутствует если счет кредита или дебита находятся в ГО
                              select idsmr, iTrnNum, ITRNANUM
                                from xxi."trn" t
                               where t.iTrnNum  = trn_rec.iTrnNum
                                 and t.ITRNANUM = trn_rec.iTrnAnum
                             ) order by iTrnNum
                     )
          loop
            mfr_text_err   := 'REG' || to_char(v_algoritm) || '_MFR: Step_5.' || to_char(tranzrownum) || ': ';
            XXI_CONTEXT.Set_IDSmr(tranz.idsmr);
            --
            xxi.triggers.setuser(null);
            abr.triggers.setuser(null);
            access_2.cur_user_id := get_userid();
            --
            vRegUser  := ni_action.fGetAdmUser(ubrr_get_context);
            vRegUser1 := case when BankIdSmr = 16 then 'T_VUZDAYCOM' else vRegUser end;
            -- Если БО1 = 22
            if tranzrownum = 1 then
              update xxi."trn" t
                 set t.CTRNMFOA    = r_smr_to.cSMRmfo8,
                     t.CTRNCORACCA = r_smr_to.cSMRKorAcc
              where t.iTrnNum  = tranz.iTrnNum
                 and t.idsmr    = tranz.idsmr
                 and t.ITRNANUM = tranz.ITRNANUM;
            end if;
            --
            if (tranzrownum < 3 and v_algoritm = 1) or
               (tranzrownum < 2 and v_algoritm = 0)
            then
              update xxi."trn" t
                 set -- t.CTRNPURP     = v_newpurp,
                     t.cTrnIdAffirm = vRegUser1,
                     t.cTrnIdOpen   = vRegUser
               where t.iTrnNum  = tranz.iTrnNum
                 and t.idsmr    = tranz.idsmr
                 and t.ITRNANUM = tranz.ITRNANUM;
            else
              update xxi."trn" t
                 set -- t.CTRNPURP       = v_newpurp,
                     t.cTrnIdAffirm   = vRegUser1,
                     t.cTrnIdOpen     = vRegUser,
                     t.CTRNCLIENT_ACC = trn_rec.CTRNCLIENT_ACC
               where t.iTrnNum  = tranz.iTrnNum
                 and t.idsmr    = tranz.idsmr
                 and t.ITRNANUM = tranz.ITRNANUM;
            end if;
            --
            tranzrownum := tranzrownum + 1;
          end loop;
      -- вот собственно и все
        mfr_text_err      := mfr_text_err || 'OK';
      -- восстанавливаем пользователя
        XXI_CONTEXT.Set_IDSmr(s_idsmr);
        xxi.triggers.setuser(null);
        abr.triggers.setuser(null);
        access_2.cur_user_id := get_userid(s_idsmr);
      --
      --  vRegUser  := ni_action.fGetAdmUser(s_idsmr);
      --  vRegUser1 := case when BankIdSmr = 16 then 'T_VUZDAYCOM' else vRegUser end;
      --
      end;
      -- исключаем документ из обработки по ЛОРО счетам
      -- INSERT INTO ubrr_data.ubrr_trn_loro_excpt VALUES(trn_rec.iTrnNum, trn_rec.iTrnAnum);
    end;
    -->> UBRR 07.02.2017 Восстановление контекста Севастьянов С.В.-->>
    if (c_idsmr != s_idsmr) or (d_idsmr != s_idsmr) then
      XXI_CONTEXT.Set_IDSmr(ID_Smr => s_idsmr);
    end if;
    --<<-----------------------------------------------------------<<
    -- возвращаем результат работы:
    rvRetDoc.cResult := 'OK';
    return rvRetDoc;
    -- обработка ошибок:
    exception
      when r_QTRN_exception then
        -- откат
        rollback to bbw_x;
        -- восстанавливаем контекст
        XXI_CONTEXT.Set_IDSmr(ID_Smr => s_idsmr);
        mfr_text_err        := mfr_text_err || substr(v_error_msg, 1, 120) || ' : ' || substr(v_erms, 1, 120);
        rvRetDoc.cResult    := mfr_text_err;
        return rvRetDoc;
      when r_idoc_ctrl_except then
        rollback to bbw_x;
        -- восстанавливаем контекст
        XXI_CONTEXT.Set_IDSmr(ID_Smr => s_idsmr);
        mfr_text_err        := mfr_text_err || substr(v_error_msg, 1, 255);
        rvRetDoc.cResult    := mfr_text_err;
        return rvRetDoc;
      when others then
        -- повторное восстановление:
        rollback to bbw_x;
        XXI_CONTEXT.Set_IDSmr(ID_Smr => s_idsmr);
        mfr_text_err := mfr_text_err || substr(sqlerrm, 1, 255);
        rvRetDoc.cResult    := mfr_text_err;
        return rvRetDoc;
    end;

    Function RegisterZbl
    return rtRetDoc
    is
        rvRetDoc rtRetDoc;
        cvRes    varchar2(1024);
    begin
        savepoint sp_Mo_Reg;
        cvRes := ubrr_abrr_btn_reg.Register (cpBtnMode      => 'REGISTER',
                                             ErrorMsg       => rvRetDoc.cResult,
                                             OpType         => rsDocument.iBo1,
                                             RegDate        => rsDocument.dTran,
                                             PayerAcc       => rsDocument.cAccD,
                                             RecipientAcc   => null,
                                             Summa          => rsDocument.mSumD + rsDocument.mNdsSum,
                                             DocDate        => rsDocument.dTran,
                                             Purpose        => rsDocument.cPurp,
                                             DocNum         => rsDocument.iDocNum,
                                             BatNum         => rsDocument.iBatNum,
                                             ValDate        => null,
                                             Priority       => 5, -- 16.01.2014 ubrr korolkov 12-2288.2(#11743)
                                             SubOpType      => rsDocument.iBo2,
                                             RecipientName  => rsDocument.cNameC,
                                             INNA           => rsDocument.cInnC,
                                             Client_Name    => rsDocument.cNameD,
                                             Client_INN     => rsDocument.cInnD,
                                             cDocCurrency   => rsDocument.cCurD,
                                             cCondPay       => rsDocument.cAccept,
                                             ZBL_ACC        => rsDocument.cZblAcc,
                                             ZBL_ACC_DEB    => rsDocument.cZblAcc);
        if cvRes = 'Ok' then
            rvRetDoc.cPlace := 'BTN';
            rvRetDoc.cBtnRef := ubrr_abrr_btn_reg.GetLastBtnId;
            UBRR_ABRR_BTN.Clear_Temp_Tranzit;
            UBRR_ABRR_BTN.Insert_Temp_Tranzit(rsDocument.cAccC,
                                              rsDocument.mSumC,
                                              rsDocument.cPurp1);
            UBRR_ABRR_BTN.Insert_Temp_Tranzit(rsDocument.cNdsAcc,
                                              rsDocument.mNdsSum,
                                              rsDocument.cPurp2);
            cvRes := UBRR_ABRR_BTN.Registr_tranzit(rvRetDoc.cBtnRef,
                                                   rsDocument.dTran,
                                                   1,rsDocument.iBatNum,
                                                   rvRetDoc.cResult);
            UBRR_ABRR_BTN.Clear_Temp_Tranzit;
            if cvRes = 'Ok' then
                rvRetDoc.iNum := ubrr_abrr_btn.GetLastDocID;
                rvRetDoc.iANum := 0;
                rvRetDoc.cResult := 'OK';
            else
                rollback to sp_Mo_Reg;
            end if;
        else
            rollback to sp_Mo_Reg;
        end if;
        return rvRetDoc;
    exception when others then
        rollback to sp_Mo_Reg;
        rvRetDoc.cResult := sqlerrm;
        Return rvRetDoc;
    end;
    -->>> 09.01.2018 Ёлгин Ю.А. [17-913.2]
    function Get_LinkToContract(p_Account varchar2, 
                                p_IdSmr   varchar2,
                                p_AccSio  varchar2 default null,
                                p_AccLastOper date default null)
    return varchar2  is
        vcIDSmr varchar2(3) := nvl(p_IdSmr, BankIdSmr);
        vcResult varchar2(200);
        vcAccSio xxi."acc".CACCSIO%type;
        vdAccLastOper xxi."acc".dacclastoper%type;
    begin
        if vcIDSmr = '16' then
            vcResult := 'согл. договора РКО';    
        else
            vcResult := 'согл. дог. банковского счета';
        end if;
        if p_AccSio is not null and p_AccLastOper is not null then
            vcResult := vcResult || ' № ' || p_AccSio || ' от ' || to_char(p_AccLastOper, 'dd.mm.yyyy');
        else
            begin
                select CACCSIO, DACCLASTOPER
                  into vcAccSio, vdAccLastOper
                  from xxi."acc" a
                 where a.caccacc = p_Account 
                   and a.idsmr = vcIDSmr
                   and rownum=1; 
                if vcAccSio is not null then
                    vcResult := vcResult ||' № '||vcAccSio||' от '||to_char(vdAccLastOper, 'dd.mm.yyyy');
                end if;    
            exception when others then
                null; -- не нашли договор
            end;
        end if;
        return vcResult;           
    end Get_LinkToContract;
    --<<< 09.01.2018 Ёлгин Ю.А. [17-913.2]    
BEGIN
  BankIdSmr := ubrr_util.GetBankIdSmr;
END;
/
