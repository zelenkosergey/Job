create or replace package ubrr_xxi5.ubrr_bnkserv_online_comiss is

/*************************************************** HISTORY *****************************************************\
   Дата          Автор          id        Описание
----------  ---------------  -----------  -------------------------------------------------------------------------
19.07.2021  Зеленко С.А.     DKBPA-1571   ВБ переводы. Взимание комиссий в режиме "онлайн"
\*************************************************** HISTORY *****************************************************/

  TYPE type_tbl_trn IS TABLE OF xxi.trn%ROWTYPE index by binary_integer;
  t_tbl_trn  type_tbl_trn;
  
  TYPE T_Rec_Commis       IS RECORD (cSBSaccd          ubrr_data.ubrr_sbs_new.cSBSaccd%type, 
                                     cSBScurd          ubrr_data.ubrr_sbs_new.cSBScurd%type,  
                                     cSBSTypeCom       ubrr_data.ubrr_sbs_new.cSBSTypeCom%type,  
                                     mSBSsumpays       ubrr_data.ubrr_sbs_new.mSBSsumpays%type,  
                                     iSBScountPays     ubrr_data.ubrr_sbs_new.iSBScountPays%type,  
                                     mSBSsumcom        ubrr_data.ubrr_sbs_new.mSBSsumcom%type,  
                                     iSBSotdnum        ubrr_data.ubrr_sbs_new.iSBSotdnum%type,  
                                     iSBSBatNum        ubrr_data.ubrr_sbs_new.iSBSBatNum%type,  
                                     dSBSDate          ubrr_data.ubrr_sbs_new.dSBSDate%type, 
                                     iSBSTypeCom       ubrr_data.ubrr_sbs_new.iSBSTypeCom%type,  
                                     dsbsdatereg       ubrr_data.ubrr_sbs_new.dsbsdatereg%type,  
                                     MSBSSUMBEFO       ubrr_data.ubrr_sbs_new.msbssumbefo%type
                                     );
  r_Rec_Commis               T_Rec_Commis;  

-----------------------------------------------------------------
-- Логирование ошибок онлайн комиссий
-----------------------------------------------------------------
PROCEDURE Write_Error_Log(par_cmess in varchar2);

-----------------------------------------------------------------
-- При удалении основного документа из реестра, удаляем комиссию из ubrr_sbs_new
-----------------------------------------------------------------
procedure delete_online_sbs(p_itrnnum  in ubrr_sbs_new.itrnnum%type,
                   p_itrnanum in ubrr_sbs_new.itrnanum%type);
                   
-----------------------------------------------------------------
-- При удалении из картотеки комиссии, удаляем комиссию из ubrr_sbs_new
-----------------------------------------------------------------
procedure delete_online_trc_sbs( p_isbstrnnum in ubrr_sbs_new.isbstrnnum%type);

-----------------------------------------------------------------
-- Инициализация переменных для онлайн комиссий
-----------------------------------------------------------------
PROCEDURE Init_Global_Item;

-----------------------------------------------------------------
-- Вернуть первую дату и время добавления в TRN
-----------------------------------------------------------------
FUNCTION Get_Date_Create_AU(par_Itrnnum       in au_trn_act.ITRNNUM%type,
                            par_Itrnanum      in au_trn_act.ITRNANUM%type
                            )
  RETURN DATE;
  
-----------------------------------------------------------------
-- Вернуть данные для формирования назначения платежа TRN
-----------------------------------------------------------------
FUNCTION Get_attrib_trn(par_Itrnnum         in  xxi.trn.ITRNNUM%type,
                        par_Itrnanum        in  xxi.trn.ITRNANUM%type
                        )
  RETURN VARCHAR2;
    
-----------------------------------------------------------------
-- Проверка платежа на взымаиние комиссии
-----------------------------------------------------------------
FUNCTION PreCheck_Trn_Comiss(par_Itrnnum       in xxi.trn.ITRNNUM%type,
                             par_Itrnanum      in xxi.trn.ITRNANUM%type
                             )
  RETURN BOOLEAN;
  
-----------------------------------------------------------------
-- Проверка БИКа банка, относится ли он к нашему банку или внешний
-----------------------------------------------------------------
FUNCTION Check_Current_Bank_Bik(par_ctrnmfoa       in xxi.trn.CTRNMFOA%type
                                )
  RETURN BOOLEAN;  

-----------------------------------------------------------------
-- Проверка отделения настройки комиссии
-----------------------------------------------------------------
FUNCTION Check_Otd_Comiss(par_com_type      in ubrr_data.ubrr_rko_tarif.com_type%type,
                          par_otd           in ubrr_data.ubrr_rko_tarif_otdsum.otd%type
                          )
  RETURN NUMBER;
    
-----------------------------------------------------------------
-- Проверка счета в полях операции, проверяем что он относится в ФЛ
-----------------------------------------------------------------
FUNCTION Check_Account_FL(par_ctrnacca  in trn.ctrnacca%type,
                          par_ctrnowna  in trn.ctrnowna%type,
                          par_ctrnpurp  in trn.ctrnpurp%type 
                          )
  RETURN NUMBER;

-----------------------------------------------------------------
-- Проверка счета и клиента на категорию/группу по типу комиссии
-----------------------------------------------------------------
FUNCTION Check_Gac_Gcs_Ex(par_com_type      in ubrr_rko_exinc_catgr_new_v.ccom_type%type,
                          par_caccacc       in acc.caccacc%type,
                          par_cacccur       in acc.cacccur%type,
                          par_iacccus       in acc.iacccus%type
                          )
  RETURN NUMBER;  
  
-----------------------------------------------------------------
-- Проверка слов исключений назначения платежа для ULFL_VB
-----------------------------------------------------------------
FUNCTION Check_Word_Ex_ULFL_VB(par_caccacc      in acc.caccacc%type,
                               par_cacccur      in acc.cacccur%type,
                               par_purp         in varchar2,
                               par_dttran       in date
                               )
  RETURN NUMBER;

-----------------------------------------------------------------
-- Вернем сумму накопительного итога по счету за период (ULFL_VB)
-----------------------------------------------------------------
FUNCTION Get_SumBefo_ULFL_VB(par_ctrnaccd     in xxi.trn.ctrnaccd%type, 
                             par_ctrncur      in xxi.trn.ctrncur%type,                    
                             par_dt_trn       in date
                             )
  RETURN NUMBER;

-----------------------------------------------------------------
-- Вернем данные по комиссии 
-----------------------------------------------------------------
FUNCTION Get_Comiss(par_Itrnnum       in xxi.trn.ITRNNUM%type,
                    par_Itrnanum      in xxi.trn.ITRNANUM%type
                    )
  RETURN T_Rec_Commis;
  
-----------------------------------------------------------------
-- Вернем данные по комиссии 
-----------------------------------------------------------------
FUNCTION Get_Comiss(par_ctrnaccd     in xxi.trn.ctrnaccd%type, 
                    par_ctrncur      in xxi.trn.ctrncur%type, 
                    par_mtrnsum      in xxi.trn.mtrnsum%type, 
                    par_ctrnacca     in xxi.trn.ctrnacca%type, 
                    par_ctrnowna     in xxi.trn.ctrnowna%type, 
                    par_ctrnpurp     in xxi.trn.ctrnpurp%type, 
                    par_dtrntran     in xxi.trn.dtrntran%type, 
                    par_dtrncreate   in xxi.trn.dtrncreate%type, 
                    par_ctrnmfoa     in xxi.trn.ctrnmfoa%type, 
                    par_itrntype     in xxi.trn.itrntype%type, 
                    par_iTRNsop      in xxi.trn.itrnsop%type,
                    par_itrnpriority in xxi.trn.itrnpriority%type,
                    par_itrnba2c     in xxi.trn.itrnba2c%type,
                    par_ccreatstatus in xxi.trn_dept_info.ccreatstatus%type,
                    par_itrnnumanc   in xxi.trn.itrnnumanc%type,                    
                    par_dt_trn       in date
                    )
  RETURN T_Rec_Commis;

-----------------------------------------------------------------
-- Вернем только сумму комиссии 
-----------------------------------------------------------------
FUNCTION Get_Comiss_Sum(par_ctrnaccd     in xxi.trn.ctrnaccd%type, 
                        par_ctrncur      in xxi.trn.ctrncur%type, 
                        par_mtrnsum      in xxi.trn.mtrnsum%type, 
                        par_ctrnacca     in xxi.trn.ctrnacca%type, 
                        par_ctrnowna     in xxi.trn.ctrnowna%type, 
                        par_ctrnpurp     in xxi.trn.ctrnpurp%type, 
                        par_dtrntran     in xxi.trn.dtrntran%type, 
                        par_dtrncreate   in xxi.trn.dtrncreate%type, 
                        par_ctrnmfoa     in xxi.trn.ctrnmfoa%type, 
                        par_itrntype     in xxi.trn.itrntype%type, 
                        par_iTRNsop      in xxi.trn.itrnsop%type,
                        par_itrnpriority in xxi.trn.itrnpriority%type,
                        par_itrnba2c     in xxi.trn.itrnba2c%type,
                        par_ccreatstatus in xxi.trn_dept_info.ccreatstatus%type,
                        par_itrnnumanc   in xxi.trn.itrnnumanc%type,                    
                        par_dt_trn       in date
                        )
  RETURN NUMBER;  

-----------------------------------------------------------------
-- Функция расчета по взымаинию онлайн комиссий
-----------------------------------------------------------------
FUNCTION Calc_Online_Comiss(par_Itrnnum       in xxi.trn.ITRNNUM%type,
                            par_Itrnanum      in xxi.trn.ITRNANUM%type
                            )
  RETURN INTEGER;  
  
-----------------------------------------------------------------
-- Функция возвращает ID атрибута платежа, означающего связь с проводкой:
-- если платеж возникает при списании
-----------------------------------------------------------------
FUNCTION get_write_off_trn_attr_id return number;

-----------------------------------------------------------------
-- если idoc_reg.register запускаем при списании
-----------------------------------------------------------------
function is_write_off ( tabAttr IN TS.T_TabTrnAttr ) return boolean;  

-----------------------------------------------------------------
-- Возвращает строку для формы int_r_i c суммой начисленной комиссии из ubrr_sbs_new
-----------------------------------------------------------------
function get_comiss_info(p_itrnnum in trn.itrnnum%type, 
                         p_itrnanum in trn.itrnanum%type) 
  return varchar2;  
  
-----------------------------------------------------------------
-- Тестовый расчет за период
-----------------------------------------------------------------
FUNCTION Calc_Test_Comiss(p_d1 in date, p_d2 in date,/* p_datereg in date,*/ p_reg in integer)
  RETURN integer;

-----------------------------------------------------------------
-- Откат комиссий, помеченных в форме
-----------------------------------------------------------------
function writeoff_doc(p_markerid in number) return varchar2;
    
-----------------------------------------------------------------
-- Функция расчета по взымаинию онлайн комиссии
-----------------------------------------------------------------
FUNCTION Calc_Comiss(par_Itrnnum       in xxi.trn.ITRNNUM%type,
                     par_Itrnanum      in xxi.trn.ITRNANUM%type,
                    -- par_datereg       in date    default null,
                     par_reg           in integer default 1
                     )
  RETURN INTEGER;  
  
-----------------------------------------------------------------
-- Регистрация комиссии из SBS_NEW
-----------------------------------------------------------------
FUNCTION Register(par_id_sbs          in ubrr_data.ubrr_sbs_new.id%TYPE,
                  par_Itrnnum         in  xxi.trn.ITRNNUM%type,
                  par_Itrnanum        in  xxi.trn.ITRNANUM%type
                  )
  RETURN NUMBER;  
  
end ubrr_bnkserv_online_comiss;
/
create or replace package body ubrr_xxi5.ubrr_bnkserv_online_comiss is

/*************************************************** HISTORY *****************************************************\
   Дата          Автор          id        Описание
----------  ---------------  -----------  -------------------------------------------------------------------------
19.07.2021  Зеленко С.А.     DKBPA-1571   ВБ переводы. Взимание комиссий в режиме "онлайн"
19.08.2021  Пинаев Д.Е.      DKBPA-1571   ВБ переводы. Взимание комиссий в режиме "онлайн"
\*************************************************** HISTORY *****************************************************/

  gc_BankIdSmr               xxi.smr.IDSMR%type;
  gd_ip_doh_excl             date;
  gd_ulfl_vb_enable_online   date; --дата включения онлайн-комиссии ULFL_VB
  gd_pp3_enable_online       date; --дата включения онлайн-комиссии PP3
  gc_ErrorMessage            varchar2(2000);
  
  gc_enable_online           xxi.ups.cupsvalue%type;
  gc_enable_list_otd         xxi.ups.cupsvalue%type;
  gc_payer_account           xxi.ups.cupsvalue%type;
  gc_not_payer_account       xxi.ups.cupsvalue%type;
  gc_type_all                xxi.ups.cupsvalue%type;
  gc_not_receiver_account    xxi.ups.cupsvalue%type;
  gc_not_type_sop            xxi.ups.cupsvalue%type;
  gc_not_sop_type            xxi.ups.cupsvalue%type; 
  gc_not_type_purp           xxi.ups.cupsvalue%type;
  gc_not_gac                 xxi.ups.cupsvalue%type;
  
-->> 19.08.2021  Пинаев Д.Е.      DKBPA-1571   ВБ переводы. Взимание комиссий в режиме "онлайн"
  gc_write_off_plat          constant number := 999001;  
  gc_trn_limit_bulk          constant number := 100;
  
-----------------------------------------------------------------
-- Функция возвращает ID атрибута платежа, означающего связь с проводкой:
-- если платеж возникает при списании
-----------------------------------------------------------------
FUNCTION get_write_off_trn_attr_id return number
IS BEGIN
    return gc_write_off_plat;
END;  

-----------------------------------------------------------------
-- если idoc_reg.register запускаем при списании
-----------------------------------------------------------------
function is_write_off ( tabAttr IN TS.T_TabTrnAttr ) return boolean is
    l_ret boolean := false; 
begin
  
    if tabAttr is null then
      return l_ret;
    end if;  

    for i in 1..tabAttr.count loop
      if tabAttr(i).ID_Attr = gc_write_off_plat and tabAttr(i).cValue='1' then
        l_ret := true;
      end if;

    end loop;

    return l_ret;

end;

-----------------------------------------------------------------
-- Возвращает строку для формы int_r_i c суммой начисленной комиссии из ubrr_sbs_new
-----------------------------------------------------------------
function get_comiss_info(p_itrnnum in trn.itrnnum%type, p_itrnanum in trn.itrnanum%type) return varchar2 is
  l_comiss_info varchar2(2000);  
begin
  
  select chr(10)||'Рассчитана комиссия - '||to_char(msbssumcom, 'FM999990D90')||' руб.'
    into l_comiss_info
    from ubrr_sbs_new
   where itrnnum = p_itrnnum
     and itrnanum = p_itrnanum;

  return l_comiss_info;
  
exception
  when no_data_found then
    return null;
  when too_many_rows then
    return null;   
end;

-----------------------------------------------------------------
-- При удалении основного документа из реестра, удаляем комиссию из ubrr_sbs_new
-----------------------------------------------------------------
procedure delete_online_sbs(p_itrnnum  in ubrr_sbs_new.itrnnum%type,
                            p_itrnanum in ubrr_sbs_new.itrnanum%type) is
  l_isbstrntrc ubrr_sbs_new.isbstrntrc%type;
  l_isbstrnnum ubrr_sbs_new.isbstrnnum%type;
  l_error_msg  varchar2(2000);
begin

  select isbstrntrc, isbstrnnum
    into l_isbstrntrc, l_isbstrnnum
    from ubrr_sbs_new
   where itrnnum = p_itrnnum
     and itrnanum = p_itrnanum;

  if l_isbstrntrc = 1 then
  
    delete ubrr_sbs_new
     where itrnnum = p_itrnnum
       and itrnanum = p_itrnanum;
  
  elsif l_isbstrntrc = 2 then
  
    if CARD.Delete_Document(l_error_msg, l_isbstrnnum, 0) = 0 then
      delete ubrr_sbs_new
       where itrnnum = p_itrnnum
         and itrnanum = p_itrnanum;
    end if;
  
  end if;

exception
  when no_data_found then
    null;
  when too_many_rows then
    null;
end;

-----------------------------------------------------------------
-- При удалении из картотеки комиссии, удаляем комиссию из ubrr_sbs_new
-----------------------------------------------------------------
procedure delete_online_trc_sbs( p_isbstrnnum in ubrr_sbs_new.isbstrnnum%type) 
is
begin
  
   delete ubrr_sbs_new t
   where t.isbstrnnum = p_isbstrnnum and
         t.isbstrntrc = 2;

end;

--<< 19.08.2021  Пинаев Д.Е.      DKBPA-1571   ВБ переводы. Взимание комиссий в режиме "онлайн"

-----------------------------------------------------------------
-- Инициализация переменных для онлайн комиссий
-----------------------------------------------------------------
PROCEDURE Init_Global_Item
  IS
  --lc_msg   VARCHAR2(32767):=$$plsql_unit||'.Init_Global_Item:';
BEGIN
  gd_ip_doh_excl := nvl(ubrr_pref.Get_Date_Preference(pref.c_universuser,'IP_DOH_EXCLUDE_DATE'), to_date('01.01.4000', 'dd.mm.rrrr') );
  gc_BankIdSmr := ubrr_util.GetBankIdSmr;

  gd_ulfl_vb_enable_online := coalesce(ubrr_pref.Get_Date_Preference(pref.c_universuser, 'DKBPA_1571.UBRR_BNKSERV_ONLINE_COMISS.ULFL_VB_ENABLE_DATE'), to_date('31.12.4000','dd.mm.yyyy'));
  gd_pp3_enable_online := coalesce(ubrr_pref.Get_Date_Preference(pref.c_universuser, 'DKBPA_1571.UBRR_BNKSERV_ONLINE_COMISS.PP3_ENABLE_DATE'), to_date('31.12.4000','dd.mm.yyyy'));
  
  gc_enable_online := nvl(PREF.Get_Preference('DKBPA_1571.UBRR_BNKSERV_ONLINE_COMISS.ENABLE_ONLINE'),'N');   --включена настройка или нет Y/N
  gc_enable_list_otd := nvl(PREF.Get_Preference('DKBPA_1571.UBRR_BNKSERV_ONLINE_COMISS.ENABLE_LIST_OTD'),'0000');   --включена настройка для списка отделений
  gc_payer_account := nvl(PREF.Get_Preference('DKBPA_1571.UBRR_BNKSERV_ONLINE_COMISS.PAYER_ACCOUNT'),'40...810');   --маска счетов плательщика
  gc_not_payer_account := nvl(PREF.Get_Preference('DKBPA_1571.UBRR_BNKSERV_ONLINE_COMISS.NOT_PAYER_ACCOUNT'),'401|402|403|404|409|40813|40817|40818|40820|42309|40810|40811|40812|40823|40824');   --маски счетов плательщиков которые исключаем
  gc_type_all := nvl(PREF.Get_Preference('DKBPA_1571.UBRR_BNKSERV_ONLINE_COMISS.TYPE_ALL'),'2|3|4|11|14|15|21|23|25|28');   --список всех БО1 для выборки
  gc_not_receiver_account := nvl(PREF.Get_Preference('DKBPA_1571.UBRR_BNKSERV_ONLINE_COMISS.NOT_RECEIVER_ACCOUNT'),'47423|70601');   --маски счетов получателей которые исключаем
  gc_not_type_sop := nvl(PREF.Get_Preference('DKBPA_1571.UBRR_BNKSERV_ONLINE_COMISS.NOT_TYPE_SOP'),'25');   --список БО1 для исключени совместнос БО2
  gc_not_sop_type := nvl(PREF.Get_Preference('DKBPA_1571.UBRR_BNKSERV_ONLINE_COMISS.NOT_SOP_TYPE'),'5|6');   --список БО2 для исключени совместнос БО1
  gc_not_type_purp := nvl(PREF.Get_Preference('DKBPA_1571.UBRR_BNKSERV_ONLINE_COMISS.NOT_TYPE_PURP'),'22|25');   --список БО1 для исключени с назначением платежа
  gc_not_gac := nvl(PREF.Get_Preference('DKBPA_1571.UBRR_BNKSERV_ONLINE_COMISS.NOT_GAC'),'333/2');   --список БО1 для исключени с назначением платежа

  /*Write_Error_Log(lc_msg||chr(10)||
  'gd_ulfl_vb_enable_online='||gd_ulfl_vb_enable_online  || ','||chr(10)||
  'gd_pp3_enable_online='||gd_pp3_enable_online  || ','||chr(10)||
  'gc_enable_list_otd='||gc_enable_list_otd      || ','||chr(10)||
  'gc_payer_account='||gc_payer_account        || ','||chr(10)||
  'gc_not_payer_account='||gc_not_payer_account    || ','||chr(10)||
  'gc_type_all='||gc_type_all             || ','||chr(10)||
  'gc_not_receiver_account='||gc_not_receiver_account    || ','||chr(10)||
  'gc_not_type_sop='||gc_not_type_sop            || ','||chr(10)||
  'gc_not_sop_type='||gc_not_sop_type            || ','||chr(10)||
  'gc_not_type_purp='||gc_not_type_purp           || ','||chr(10)||
  'gc_not_gac='||gc_not_gac     
   );*/  

END;

-----------------------------------------------------------------
-- Вернуть сообщение об ошибке
-----------------------------------------------------------------
FUNCTION Get_ErrorMessage
RETURN VARCHAR2
  IS
BEGIN
   RETURN gc_ErrorMessage;
END Get_ErrorMessage;

-----------------------------------------------------------------
-- Запомнить сообщение об ошибке
-----------------------------------------------------------------
PROCEDURE Set_ErrorMessage(par_cmess  IN  VARCHAR2)
  IS
BEGIN
   gc_ErrorMessage := TS.To_2000(par_cmess);
END Set_ErrorMessage;
  
-----------------------------------------------------------------
-- Логирование ошибок онлайн комиссий
-----------------------------------------------------------------
PROCEDURE Write_Error_Log(par_cmess in varchar2)
  IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  insert into ubrr_data.ubrr_bnkserv_online_comiss_log(username, 
                                                       sessionid, 
                                                       datelog, 
                                                       message)
                                                values(user, 
                                                       userenv('SessionID'), 
                                                       sysdate, 
                                                       TS.To_2000(par_cmess)
                                                       );
  Set_ErrorMessage(TS.To_2000(par_cmess));
  commit;
END Write_Error_Log;

-----------------------------------------------------------------
-- Добавить запись в ubrr_sbs_new вернем id
-----------------------------------------------------------------
FUNCTION Ins_sbs_new(par_cSBSaccd        in  ubrr_data.ubrr_sbs_new.cSBSaccd%type, 
                     par_cSBScurd        in  ubrr_data.ubrr_sbs_new.cSBScurd%type,  
                     par_cSBSTypeCom     in  ubrr_data.ubrr_sbs_new.cSBSTypeCom%type,  
                     par_mSBSsumpays     in  ubrr_data.ubrr_sbs_new.mSBSsumpays%type,  
                     par_iSBScountPays   in  ubrr_data.ubrr_sbs_new.iSBScountPays%type,  
                     par_mSBSsumcom      in  ubrr_data.ubrr_sbs_new.mSBSsumcom%type,  
                     par_iSBSotdnum      in  ubrr_data.ubrr_sbs_new.iSBSotdnum%type,  
                     par_iSBSBatNum      in  ubrr_data.ubrr_sbs_new.iSBSBatNum%type,  
                     par_dSBSDate        in  ubrr_data.ubrr_sbs_new.dSBSDate%type, 
                     par_iSBSTypeCom     in  ubrr_data.ubrr_sbs_new.iSBSTypeCom%type,  
                     par_dsbsdatereg     in  ubrr_data.ubrr_sbs_new.dsbsdatereg%type,  
                     par_MSBSSUMBEFO     in  ubrr_data.ubrr_sbs_new.msbssumbefo%type,
                     par_Itrnnum         in  xxi.trn.ITRNNUM%type,
                     par_Itrnanum        in  xxi.trn.ITRNANUM%type
                    )
  RETURN NUMBER
  IS
  l_res        NUMBER;
BEGIN
  
  INSERT INTO ubrr_data.ubrr_sbs_new(cSBSaccd, 
                                     cSBScurd, 
                                     cSBSTypeCom, 
                                     mSBSsumpays, 
                                     iSBScountPays, 
                                     mSBSsumcom, 
                                     iSBSotdnum, 
                                     iSBSBatNum, 
                                     dSBSDate, 
                                     iSBSTypeCom, 
                                     dsbsdatereg, 
                                     msbssumbefo,
                                     itrnnum,
                                     itrnanum)
                            values (par_cSBSaccd, 
                                    par_cSBScurd, 
                                    par_cSBSTypeCom, 
                                    par_mSBSsumpays, 
                                    par_iSBScountPays, 
                                    par_mSBSsumcom, 
                                    par_iSBSotdnum, 
                                    par_iSBSBatNum, 
                                    par_dSBSDate, 
                                    par_iSBSTypeCom, 
                                    par_dsbsdatereg, 
                                    par_msbssumbefo,
                                    par_Itrnnum,
                                    par_Itrnanum
                                    )
     returning ubrr_data.ubrr_sbs_new.id into l_res;  
    
  RETURN l_res;
  
EXCEPTION
 WHEN OTHERS THEN
   Write_Error_Log('Itrnnum = '||par_Itrnnum||' Itrnanum = '||par_Itrnanum|| chr(10) ||dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
   RETURN NULL;
END Ins_sbs_new;

-----------------------------------------------------------------
-- Регистрация комиссии из SBS_NEW
-----------------------------------------------------------------
FUNCTION Register(par_id_sbs          in ubrr_data.ubrr_sbs_new.id%TYPE,
                  par_Itrnnum         in  xxi.trn.ITRNNUM%type,
                  par_Itrnanum        in  xxi.trn.ITRNANUM%type
                  )
  RETURN NUMBER
  IS
  cursor cur_sbs_new(p_id_sbs in ubrr_data.ubrr_sbs_new.id%TYPE) is    
  select a.*
    from ubrr_data.ubrr_sbs_new a
   where a.id = p_id_sbs;
              
  l_rec_sbs_new   ubrr_xxi5.ubrr_bnkserv_calc_new_lib.t_rec_sbs_new;
  l_regres        ubrr_xxi5.ubrr_bnkserv_calc_new_lib.t_rec_register_result;
  l_common_res    ubrr_xxi5.ubrr_bnkserv_calc_new_lib.t_rec_register_result;
  l_mess          varchar2(2000);

begin

  l_common_res.l_trn_cnt := 0;
  l_common_res.l_trc_cnt := 0;
  l_common_res.l_err_cnt := 0;
  
  open cur_sbs_new(par_id_sbs);
  fetch cur_sbs_new into l_rec_sbs_new;
  close cur_sbs_new;
  
  l_regres := ubrr_xxi5.ubrr_bnkserv_calc_new_lib.register_single( p_regdate              => l_rec_sbs_new.dsbsdatereg
                                                                   ,p_TypeCom             => l_rec_sbs_new.isbstypecom
                                                                   ,p_Mess                => l_mess
                                                                   ,p_portion_date1       => l_rec_sbs_new.dsbsdatereg
                                                                   ,p_portion_date2       => l_rec_sbs_new.dsbsdatereg
                                                                   ,p_ls                  => l_rec_sbs_new.csbsaccd 
                                                                   ,p_sbs_new             => l_rec_sbs_new
                                                                   );

  l_common_res.l_trn_cnt := l_common_res.l_trn_cnt + l_regres.l_trn_cnt;
  l_common_res.l_trc_cnt := l_common_res.l_trc_cnt + l_regres.l_trc_cnt;
  l_common_res.l_err_cnt := l_common_res.l_err_cnt + l_regres.l_err_cnt;
  
  if ( l_common_res.l_err_cnt <> 0 ) then
     Write_Error_Log('Itrnnum = '||par_Itrnnum||' Itrnanum = '||par_Itrnanum|| chr(10) || 'Ошибка при регистрации комиссии. Смотрите таблицу ubrr_sbs_new ');
  end if;
  
  return (l_common_res.l_trn_cnt + l_common_res.l_trc_cnt);

EXCEPTION
  WHEN OTHERS THEN
    Write_Error_Log('Itrnnum = '||par_Itrnnum||' Itrnanum = '||par_Itrnanum|| chr(10) || 'Ошибка регистрации комиссии: '|| chr(10) ||dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
    RETURN -1;
END Register;

-----------------------------------------------------------------
-- Вернуть первую дату и время добавления в TRN
-----------------------------------------------------------------
FUNCTION Get_Date_Create_AU(par_Itrnnum       in au_trn_act.ITRNNUM%type,
                            par_Itrnanum      in au_trn_act.ITRNANUM%type
                            )
  RETURN DATE
  IS
  cursor cur_get_au(p_Itrnnum in au_trn_act.ITRNNUM%type, p_Itrnanum in au_trn_act.ITRNANUM%type) is
  select t.d_create
   from au_trn_act t
  where t.itrnnum = p_Itrnnum
    and t.itrnanum = p_Itrnanum
    and t.c_type = 'I'
  order by t.d_create;

  l_dt au_trn_act.d_create%TYPE;
BEGIN
  OPEN cur_get_au(par_Itrnnum,par_Itrnanum);
  FETCH cur_get_au INTO l_dt;
  CLOSE cur_get_au;
    
  RETURN l_dt;
END;

-----------------------------------------------------------------
-- Вернуть данные для формирования назначения платежа TRN
-----------------------------------------------------------------
FUNCTION Get_attrib_trn(par_Itrnnum         in  xxi.trn.ITRNNUM%type,
                        par_Itrnanum        in  xxi.trn.ITRNANUM%type
                        )
  RETURN VARCHAR2
  IS
  cursor cur_att_trn(p_Itrnnum in xxi.trn.ITRNNUM%type, p_Itrnanum in xxi.trn.ITRNANUM%type) is
  select t.itrndocnum
         ,t.mtrnsum
         ,t.dtrndoc
    from xxi.trn   t
   where t.itrnnum = p_Itrnnum
     and t.itrnanum = p_Itrnanum;
  l_row_att    cur_att_trn%rowtype;
  l_res        varchar2(1000); 
BEGIN

  OPEN cur_att_trn(par_Itrnnum,par_Itrnanum);
  FETCH cur_att_trn INTO l_row_att;
  CLOSE cur_att_trn;
  
  if l_row_att.itrndocnum is not null or l_row_att.mtrnsum is not null or l_row_att.dtrndoc is not null then
    l_res :=  'дата - '            ||to_char(l_row_att.dtrndoc,'dd.mm.yyyy')             ||' '||
              'сумма - '          ||to_char(l_row_att.mtrnsum,'FM999G999G999G999G990D00')||' '||
              'номер документа - '||l_row_att.itrndocnum;
  end if;

  RETURN l_res;
  
EXCEPTION
 WHEN OTHERS THEN
   if cur_att_trn%isopen then close cur_att_trn; end if;
   RETURN l_res;
END;

-----------------------------------------------------------------
-- Проверка платежа на взымаиние комиссии
-----------------------------------------------------------------
FUNCTION PreCheck_Trn_Comiss(par_Itrnnum       in xxi.trn.ITRNNUM%type,
                             par_Itrnanum      in xxi.trn.ITRNANUM%type
                             )
  RETURN BOOLEAN
  IS
  cursor cur_sbs_new(p_Itrnnum in ubrr_data.ubrr_sbs_new.itrnnum%type, p_Itrnanum in ubrr_data.ubrr_sbs_new.itrnanum%type) is  
  select count(1) 
    from ubrr_data.ubrr_sbs_new t
   where t.itrnnum = p_Itrnnum 
     and t.itrnanum = p_Itrnanum
     and t.iSBStrnnum is not null
     and t.ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created;
     
  cursor cur_trn_check(p_Itrnnum in xxi.trn.ITRNNUM%type, p_Itrnanum in xxi.trn.ITRNANUM%type) is  
  select a.itrnnum
    from xxi.trn a
   where a.itrnnum = p_Itrnnum 
     and a.itrnanum = p_Itrnanum
     and regexp_like(a.ctrnaccd,'^('||gc_payer_account||')')
     and not regexp_like(a.ctrnaccd,'^('||gc_not_payer_account||')')
     and UBRR_XXI5.UBRR_CHECK_PAY_BUDGET(a.itrnnum,a.itrnanum,a.ctrncoracca,a.ctrnacca) = 0     
     and regexp_like(a.itrntype,'^('||gc_type_all||')') 
     and not regexp_like(a.ctrnaccc,'^('||gc_not_receiver_account||')')    
     and not ( regexp_like(a.itrntype,'^('||gc_not_type_sop||')') and  regexp_like( coalesce(a.itrnsop,0),'^('||gc_not_sop_type||')') )
     and not ( regexp_like(a.itrntype,'^('||gc_not_type_purp||')')
               and regexp_like(a.ctrnpurp, '^ *(|! *)0406')
               and exists (select 1
                            from xxi."smr"
                           where csmrmfo8 = a.ctrnmfoa
                           )
              )
     and exists(select 1
                 from acc t
                where t.caccacc = a.ctrnaccd
                  and t.cacccur = a.ctrncur
                  and regexp_like(t.IACCOTD,'^('||gc_enable_list_otd||')') )
     and not exists(select 1
                      from gac
                     where cgacacc = a.ctrnaccd
                      and cgaccur = a.ctrncur
                      and regexp_like(igaccat||'/'||igacnum,'^('||gc_not_gac||')')
                    );              
  
  l_cur_row    cur_trn_check%rowtype;
  l_res        boolean := false;
  l_count      number := 0;

BEGIN  
  --инициализируем переменные пакета
  Init_Global_Item;
  
  --проверим значение переменной, включение онлайн комиссий
  if gc_enable_online = 'Y' then     
    
    --проверим, еще не расчитывали
    open cur_sbs_new(par_Itrnnum,par_Itrnanum);
    fetch cur_sbs_new into l_count;
    close cur_sbs_new;

    if l_count > 0 then
      l_res := false;   
    else
      --проверим, подходит ли нам операция, вернем запись trn
      open cur_trn_check(par_Itrnnum,par_Itrnanum);
      fetch cur_trn_check into l_cur_row;
      close cur_trn_check;
      
      if l_cur_row.itrnnum is not null then
        l_res := true;
      else 
        l_res := false;
      end if; 
    end if;     
   
  end if;
    
  RETURN l_res;
  
EXCEPTION
 WHEN OTHERS THEN
   if cur_sbs_new%isopen then close cur_sbs_new; end if;
   if cur_trn_check%isopen then close cur_trn_check; end if;
   Write_Error_Log(dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
   RETURN false;
END PreCheck_Trn_Comiss;

-----------------------------------------------------------------
-- Проверка БИКа банка, относится ли он к нашему банку или внешний
-----------------------------------------------------------------
FUNCTION Check_Current_Bank_Bik(par_ctrnmfoa       in xxi.trn.CTRNMFOA%type
                                )
  RETURN BOOLEAN
  IS
  cursor cur_bik(p_ctrnmfoa in xxi.trn.CTRNMFOA%type) is  
  select count(1)
    from dual
   where exists (select 1
                   from xxi."fil" 
                  where idsmr = gc_BankIdSmr 
                    and cfilmfo = p_ctrnmfoa
                 );             
  
  l_count      number := 0;
BEGIN
  
  --проверим БИК
  open cur_bik(par_ctrnmfoa);
  fetch cur_bik into l_count;
  close cur_bik;
    
  RETURN sys.diutil.int_to_bool(l_count);
  
EXCEPTION
 WHEN OTHERS THEN
   if cur_bik%isopen then close cur_bik; end if;
   Write_Error_Log(dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
   RETURN false;
END Check_Current_Bank_Bik;

-----------------------------------------------------------------
-- Проверка отделения настройки комиссии
-----------------------------------------------------------------
FUNCTION Check_Otd_Comiss(par_com_type      in ubrr_data.ubrr_rko_tarif.com_type%type,
                          par_otd           in ubrr_data.ubrr_rko_tarif_otdsum.otd%type
                          )
  RETURN NUMBER
  IS
  cursor cur_otd(p_com_type in ubrr_data.ubrr_rko_tarif.com_type%type, p_otd in ubrr_data.ubrr_rko_tarif_otdsum.otd%type) is  
  select count(1)
    from dual
   where exists (
                 select 1 
                   from ubrr_data.ubrr_rko_tarif v,
                        ubrr_data.ubrr_rko_tarif_otdsum o
                  where v.Parent_IdSmr = gc_BankIdSmr 
                    and v.com_type = p_com_type
                    and v.id = o.id_com
                    and o.otd = p_otd
                );               
  
  l_res      number := 0;

BEGIN

  --проверим отделение
  open cur_otd(par_com_type,par_otd);
  fetch cur_otd into l_res;
  close cur_otd;
    
  RETURN l_res;
  
EXCEPTION
 WHEN OTHERS THEN
   if cur_otd%isopen then close cur_otd; end if;
   Write_Error_Log(dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
   RETURN l_res;
END Check_Otd_Comiss;

-----------------------------------------------------------------
-- Проверка счета в полях операции, проверяем что он относится в ФЛ
-----------------------------------------------------------------
FUNCTION Check_Account_FL(par_ctrnacca  in trn.ctrnacca%type,
                          par_ctrnowna  in trn.ctrnowna%type,
                          par_ctrnpurp  in trn.ctrnpurp%type 
                          ) 
  RETURN NUMBER
  IS
  
  lc_OwnaStr               varchar2(2000);  
  lc_PurpStr               varchar2(2000);
  lc_find_account_str      varchar2(50);
  l_res                    number := 0;

BEGIN
  
  --1. проверим счет получателя par_ctrnacca  
  IF par_ctrnacca LIKE '40817%' OR 
     par_ctrnacca LIKE '40820%' OR
     par_ctrnacca LIKE '423%' OR 
     par_ctrnacca LIKE '426%' THEN
    
    --если счет корректный, то возвращаем 1   
    l_res := 1;
  END IF;
   
  --2. ищем счет в тексте par_ctrnowna
  IF l_res = 0 THEN     
    
    lc_OwnaStr := regexp_replace(par_ctrnowna,'([-]|[,]|[.])+'/*'( |#|\|-|/|[(]|[)]|,|№|[[]|[]]|[.]|[\]|-|{|})+'*/);
    lc_find_account_str := null;  
    
    for i in 1..100
    loop

      lc_find_account_str:= regexp_substr(lc_OwnaStr, '\d{20,}', 1, i);

      --если не нашли - сразу выход
      if lc_find_account_str is null then
        exit;
      end if;

      if ((nvl(length(lc_find_account_str), 0) = 20) 
           and (substr(lc_find_account_str, 1, 5) in ('40817','40820') or substr(lc_find_account_str, 1, 3) in ('423','426')) )  then
        
        l_res := 1;
        exit;
      end if;
    end loop;       
  END IF;

  --3. ищем счет в тексте par_ctrnpurp
  IF l_res = 0 THEN   
   
   lc_PurpStr := regexp_replace(par_ctrnpurp,'([-]|[,]|[.])+'/*'( |#|\|-|/|[(]|[)]|,|№|[[]|[]]|[.]|[\]|-|{|})+'*/);
   lc_find_account_str := null;  
   
   for i in 1..100
    loop
      lc_find_account_str:= regexp_substr(lc_purpstr, '\d{20,}', 1, i);

      -- если не нашли - сразу выход
      if lc_find_account_str is null then
        exit;
      end if;

      if ((nvl(length(lc_find_account_str), 0) = 20) 
           and (substr(lc_find_account_str, 1, 5) in ('40817','40820') or substr(lc_find_account_str, 1, 3) in ('423','426')) )  then
        
        l_res := 1;
        exit;
      end if;
    end loop;
  END IF;      

  RETURN l_res;
    
EXCEPTION
  WHEN OTHERS THEN
    Write_Error_Log(dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);    
    RETURN l_res;
END Check_Account_FL;

-----------------------------------------------------------------
-- Проверка счета и клиента на категорию/группу по типу комиссии
-----------------------------------------------------------------
FUNCTION Check_Gac_Gcs_Ex(par_com_type      in ubrr_rko_exinc_catgr_new_v.ccom_type%type,
                          par_caccacc       in acc.caccacc%type,
                          par_cacccur       in acc.cacccur%type,
                          par_iacccus       in acc.iacccus%type
                          )
  RETURN NUMBER
  IS  
  cursor cur_exinc_catgr(p_ccom_type in ubrr_rko_exinc_catgr_new_v.ccom_type%type) is  
  select * 
    from ubrr_rko_exinc_catgr_new_v t
   where t.ccom_type = p_ccom_type 
     and t.parentidsmr = gc_BankIdSmr
   order by t.parameter;             

  cursor cur_gac(p_cgacacc in gac.cgacacc%type, p_cgaccur in gac.cgaccur%type, p_igaccat in gac.igaccat%type, p_igacnum in gac.igacnum%type) is    
  select count(1)
    from gac
   where cgacacc = p_cgacacc
     and cgaccur = p_cgaccur
     and igaccat = p_igaccat
     and igacnum = p_igacnum;

  cursor cur_gcs(p_igcsCus in gcs.igcsCus%type, p_igcscat in gcs.igcscat%type, p_igcsnum in gcs.igcsnum%type) is       
  select /*+ index(GCS P_GCS_CUS_CAT_NUM)*/
         count(1)
    from gcs
   where igcsCus = p_igcsCus
     and igcscat = p_igcscat
     and igcsnum = p_igcsnum;
     
  cursor cur_gac_ulfl_vb(p_cgacacc in gac.cgacacc%type, p_cgaccur in gac.cgaccur%type) is    
  select count(1)
    from gac g1, gac g2
   where g1.cgacacc = p_cgacacc
     and g1.cgaccur = p_cgaccur
     and g2.cgacacc = p_cgacacc
     and g2.cgaccur = p_cgaccur
     and g1.igaccat = 333
     and g1.igacnum = 4
     and g2.igaccat = 112
     and g2.igacnum in (74);

  cursor cur_gac_pp3(p_cgacacc in gac.cgacacc%type, p_cgaccur in gac.cgaccur%type) is    
  select count(1)
    from gac
   where cgacacc = p_cgacacc
     and cgaccur = p_cgaccur
     and igaccat = 112
     and igacnum in (73, 74)
     and exists(select 1
                  from gac
                 where cgacacc = p_cgacacc 
                   and cgaccur = p_cgaccur 
                   and igaccat = 333 
                   and igacnum = 4);          
  
  type t_cat_table is Table of ubrr_rko_exinc_catgr_new_v%rowtype index by binary_integer;
  tcat_list   t_cat_table;  
  l_res       number := 0;

BEGIN
  
  --вернем список категорий/групп
  open cur_exinc_catgr(par_com_type);
  fetch cur_exinc_catgr bulk collect into tcat_list;
  close cur_exinc_catgr;

  if tcat_list.count > 0 then
    for idx in tcat_list.first .. tcat_list.last
      loop
        
        --проверим по GAC
        if tcat_list(idx).parameter = 'GAC' then
          
          open cur_gac(par_caccacc, par_cacccur, tcat_list(idx).icat, tcat_list(idx).igrp);
          fetch cur_gac into l_res;
          close cur_gac;
          
          --дальше нет смысла проверять, есть запись выходим
          if l_res > 0 then
            exit;
          end if;
        end if;
        
        --проверим по GCS
        if tcat_list(idx).parameter = 'GCS' then

          open cur_gcs(par_iacccus, tcat_list(idx).icat, tcat_list(idx).igrp);
          fetch cur_gcs into l_res;
          close cur_gcs;
          
          --дальше нет смысла проверять, есть запись выходим
          if l_res > 0 then
            exit;
          end if;    
        end if;        
        
      end loop;
  end if;
  
  --пока оставим так для UL_FL_VB, нет настройки в таблице ubrr_rko_exinc_catgr_new_v
  if par_com_type = 'UL_FL_VB' and l_res = 0 then
    open cur_gac_ulfl_vb(par_caccacc, par_cacccur);
    fetch cur_gac_ulfl_vb into l_res;
    close cur_gac_ulfl_vb;         
  end if;
  
  --пока оставим так для PP3, нет настройки в таблице ubrr_rko_exinc_catgr_new_v
  if par_com_type = 'PP3' and l_res = 0 then
    open cur_gac_pp3(par_caccacc, par_cacccur);
    fetch cur_gac_pp3 into l_res;
    close cur_gac_pp3;         
  end if;  
    
  RETURN l_res;
  
EXCEPTION
 WHEN OTHERS THEN
   if cur_exinc_catgr%isopen then close cur_exinc_catgr; end if;
   if cur_gac%isopen then close cur_gac; end if;
   if cur_gcs%isopen then close cur_gcs; end if;
   if cur_gac_ulfl_vb%isopen then close cur_gac_ulfl_vb; end if;
   if cur_gac_pp3%isopen then close cur_gac_pp3; end if;   
   Write_Error_Log(dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
   RETURN l_res;
END Check_Gac_Gcs_Ex;

-----------------------------------------------------------------
-- Проверка слов исключений назначения платежа для ULFL_VB
-----------------------------------------------------------------
FUNCTION Check_Word_Ex_ULFL_VB(par_caccacc      in acc.caccacc%type,
                               par_cacccur      in acc.cacccur%type,
                               par_purp         in varchar2,
                               par_dttran       in date
                               )
  RETURN NUMBER
  IS 
  cursor cur_word(p_caccacc in acc.caccacc%type,p_cacccur in acc.cacccur%type,p_purp in varchar2,p_dttran in date) is  
  select 1 
    from dual
   where
    (   p_dttran < gd_ip_doh_excl
        or (lower(p_purp) not like  '%самозанят%'
        and lower(p_purp) not like  '%зарегистр%качеств%плательщ%')
        or not exists (select 1
                         from gac
                         where cgacacc = p_caccacc
                           and cgaccur = p_cacccur
                           and igaccat = 112
                           and igacnum in (100,101,102,104,105,106,109)
                           /*and exists (select 1
                                           from xxi.au_attach_obg au
                                          where au.caccacc = a.cACCacc
                                            and au.cacccur = a.cACCcur
                                            and au.i_table = 304
                                            and au.d_create <= d2
                                            and au.c_newdata like '112/' || to_char(gac.igacnum))*/
                                  )
    )
    and lower(p_purp) not like '%командир%'
    and lower(p_purp) not like '%кредит%'
    and lower(p_purp) not like '%алимент%'
    and lower(p_purp) not like '%з/п%'
    and lower(p_purp) not like '%заработн%плат%'
    and lower(p_purp) not like '%зарплат%'
    and lower(p_purp) not like '%зар.%пл%'
    and lower(p_purp) not like '%заробот%плат%'
    and lower(p_purp) not like '%зараб%пл%'
    and lower(p_purp) not like '%зар плат%'
    and lower(p_purp) not like '%зар.%пл%'
    and lower(p_purp) not like '%зар/плат%'
    and lower(p_purp) not like '%зарпл%'
    and lower(p_purp) not like '%аванс%'
    and lower(p_purp) not like '%благотворит%'
    and lower(p_purp) not like '%помощ%'
    and lower(p_purp) not like '%агент%'
    and lower(p_purp) not like '%подряд%'
    and lower(p_purp) not like '%пособ%'
    and lower(p_purp) not like '%стипенд%'
    and lower(p_purp) not like '%страхов%'
    and lower(p_purp) not like '%компенсац%'
    and lower(p_purp) not like '%пенс%'
    and lower(p_purp) not like '%возмещен%'
    and lower(p_purp) not like '%отпускн%'
    and lower(p_purp) not like '%увол%'
    and lower(p_purp) not like '%преми%'
    and lower(p_purp) not like '%дивиденд%'
    and lower(p_purp) not like '%исп%лист%'
    and lower(p_purp) not like '%судеб%реш%'
    and lower(p_purp) not like '%реш%взыск%'
    and lower(p_purp) not like '%уставн%'
    and lower(p_purp) not like '%учредит%'
    and (lower(p_purp) not like '%предпринимат%' or p_dttran >= gd_ip_doh_excl ) 
    and lower(p_purp) not like '%судебн%'
    and nvl(regexp_count(lower(p_purp),'труд'),0) = nvl(regexp_count(lower(p_purp),'сотрудник'),0)
    and lower(p_purp) not like '%ипотек%'
    and lower(p_purp) not like '%ипотеч%'
    and lower(p_purp) not like '%вознагражд%'
    and lower(p_purp) not like '%отпуск%'
    and lower(p_purp) not like '%больничн%лист%'
    and lower(p_purp) not like '%постановлен%'
    and lower(p_purp) not like '%суд%приказ%'
    and lower(p_purp) not like '%зп за%'
    and lower(p_purp) not like '%числен%зп%'
    and lower(p_purp) not like '%исполнит%производ%'
    and lower(p_purp) not like '%исполнит%произ-в%'
    and lower(p_purp) not like '%исполнит%пр-в%'
    and lower(p_purp) not like '%исполнительн%документ%'
    and lower(p_purp) not like '%исполнительн%приказ%'
    and lower(p_purp) not like '%гонорар%'
    and lower(replace(p_purp,' ')) not like '%б/лист%'
    and lower(replace(p_purp,' ')) not like '%б\лист%'
    and (lower(p_purp) not like '%доход%ип%'
    and lower(p_purp) not like '%деятельност%ип%' or p_dttran >= gd_ip_doh_excl ) 
    and lower(p_purp) not like '%суточн%'
    and lower(p_purp) not like '%сутк%'
    and lower(replace(p_purp,' ')) not like '%з.пл%'
    and lower(replace(p_purp,' ')) not like '%з\п%'
    and lower(replace(p_purp,' ')) not like '%част%приб%'
    and lower(replace(p_purp,' ')) not like '%межрасч%выплат%'
    and lower(p_purp) not like '%генеральн%соглашен%'
    and lower(p_purp) not like '%ген. соглаш%'
    and lower(p_purp) not like '%генер%соглаш%'
    and lower(p_purp) not like '%генерал%соглаш%'
    and lower(p_purp) not like '%ген.соглаш%' 
    and lower(p_purp) not like '%депоз%' 
    and lower(p_purp) not like '%пополн%вклад%' 
    and lower(p_purp) not like '%вклад%';
        
  l_res      number := 0;

BEGIN
   
  --проверим слова исключений
  open cur_word(par_caccacc,par_cacccur,par_purp,par_dttran);
  fetch cur_word into l_res;
  close cur_word;

  RETURN l_res;
    
EXCEPTION
 WHEN OTHERS THEN
   if cur_word%isopen then close cur_word; end if;
    Write_Error_Log(dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);     
   RETURN l_res;
END Check_Word_Ex_ULFL_VB;

/*
-----------------------------------------------------------------
-- Вернем данные по комиссии если платеж пожходит под ULFL_VB
-----------------------------------------------------------------
FUNCTION Get_MoneyOrder_ULFL_VB(par_Itrnnum       in xxi.trn.ITRNNUM%type,
                                par_Itrnanum      in xxi.trn.ITRNANUM%type,
                                par_dt_trn        in date
                                )
  RETURN T_Rec_Commis
  IS 
  
  cursor cur_trn_of_sbs_new(p_Itrnnum in xxi.trn.ITRNNUM%type, p_Itrnanum in xxi.trn.ITRNANUM%type, p_date in date) is
  select ctrnaccd, 
         ctrncur,
         typecom, 
         mtrnsum,
         1, 
         ubrr_xxi5.ubrr_bnkserv_calc_new.getsumcomiss(NULL, NULL, ctrnAccD, ctrncur, iaccotd, typecom, mtrnsum, SumBefo) sumcom,
         iaccotd, 
         (case when gc_BankIdSmr = '16' then 5407 else to_number(to_char(NVL(iOTDbatnum,70) )||'00') end) batnum,
         trunc(sysdate),
         (case when gc_BankIdSmr = '16' then 3 else 16 end) itypecom,
         trunc(sysdate),
         SumBefo
   from (select trn.itrnnum, 
                trn.itrnanum, 
                trn.ctrnaccd, 
                trn.ctrncur, 
                trn.mtrnsum, 
                'UL_FL_VB' TypeCom, 
                o.iOTDbatnum,
                a.iaccotd,
                a.iacccus, 
                nvl((select sum(mtrnsum) 
                           from V_TRN_PART_CURRENT xm
                          where xm.ctrnaccd =  trn.ctrnaccd
                            and xm.ctrncur = trn.ctrncur
                            and xm.dtrntran between trunc(p_date, 'MM') and p_date --!!!!!!!!!!!!
                            and xm.ctrnmfoa in (select cfilmfo from xxi."fil" where idsmr = gc_BankIdSmr)  --! наши филиалы -> внутрибанк                                 
                            and ubrr_xxi5.ubrr_bnkserv_online_comiss.check_account_fl(xm.ctrnacca,xm.ctrnowna,xm.ctrnpurp) = 1   --!  счет получателя, выделенный из трех полей платежного документа соответствует маскам 40817%,40820% ,423%,426%                            
                            and (    xm.ITRNTYPE = 4
                                  OR xm.ITRNTYPE = 2        
                                  OR xm.ITRNTYPE in (11,28) 
                                 AND EXISTS( select 1
                                               from trc
                                              where trc.ITRCNUM = xm.ITRNNUMANC
                                                and trc.ITRCTYPE in (2,4) )
                                )
                            and ubrr_xxi5.ubrr_bnkserv_online_comiss.check_word_ex_ulfl_vb(trn.ctrnaccd,trn.ctrncur,xm.ctrnpurp,xm.dtrntran) = 1    
                         ),0) SumBefo,               
                trn.ctrnacca,
                trn.ctrnowna,
                trn.ctrnpurp,
                trn.dtrntran
           from xxi.V_TRN_PART_CURRENT trn, acc a, otd o
          where 1=1
            and trn.ITRNNUM = p_Itrnnum
            and trn.ITRNANUM = p_Itrnanum
            and trn.dtrncreate >= gd_ulfl_vb_enable_online--pinaev
            and a.cACCacc = trn.cTRNaccd
            and a.cacccur = trn.ctrncur        
            and a.cACCprizn <> 'З'
            and o.iotdnum = a.iaccotd
            and ((trn.CTRNACCD like '40%' and to_number(substr(trn.CTRNACCD, 3, 1)) between 1 and 7) --! счет плательщика соответствует маскам 401-407%,40802%, 40807
                  or trn.CTRNACCD like '40802%'
                  or trn.CTRNACCD like '40807%'
                  or trn.CTRNACCD like '40821%'
                 )
            and trn.ctrnmfoa in (select f.cfilmfo 
                                   from xxi."fil" f
                                  where f.idsmr = gc_BankIdSmr)
            and (    ITRNTYPE = 4
                  OR ITRNTYPE = 2       
                  OR ITRNTYPE in (11,28) 
                  AND EXISTS( select 1
                               from trc
                              where trc.ITRCNUM = trn.ITRNNUMANC
                                and trc.ITRCTYPE  in (2,4) ) 
                )                    
        )
  where ubrr_xxi5.ubrr_bnkserv_online_comiss.check_account_fl(ctrnacca,ctrnowna,ctrnpurp) = 1  --проверка счет ФЛ
    and ubrr_xxi5.ubrr_bnkserv_online_comiss.check_word_ex_ulfl_vb(ctrnaccd,ctrncur,ctrnpurp,dtrntran) = 1  --проверка свола исключений    
    and ubrr_xxi5.ubrr_bnkserv_online_comiss.check_otd_comiss('UL_FL_VB',iaccotd) = 1  --проверка отделения
    and ubrr_xxi5.ubrr_bnkserv_online_comiss.check_gac_gcs_ex('UL_FL_VB',ctrnaccd,ctrncur,iacccus) = 0 --проверка кат/гр
    ; 

  lr_Rec_Commis       T_Rec_Commis;
BEGIN  
  
  --проверим платеж
  OPEN cur_trn_of_sbs_new(par_Itrnnum, par_Itrnanum,par_dt_trn);
  FETCH cur_trn_of_sbs_new INTO lr_Rec_Commis;
  CLOSE cur_trn_of_sbs_new;
    
  RETURN lr_Rec_Commis;

EXCEPTION
  WHEN OTHERS THEN
    if cur_trn_of_sbs_new%isopen then close cur_trn_of_sbs_new; end if;
    Write_Error_Log('Itrnnum = '||par_Itrnnum||' Itrnanum = '||par_Itrnanum|| chr(10) ||dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
    RETURN lr_Rec_Commis;
END Get_MoneyOrder_ULFL_VB;
*/

-----------------------------------------------------------------
-- Вернем сумму накопительного итога по счету за период (ULFL_VB)
-----------------------------------------------------------------
FUNCTION Get_SumBefo_ULFL_VB(par_ctrnaccd     in xxi.trn.ctrnaccd%type, 
                             par_ctrncur      in xxi.trn.ctrncur%type,                    
                             par_dt_trn       in date
                             )
  RETURN NUMBER
  IS

  cursor cur_SumBefo_trn(p_ctrnaccd in xxi.trn.ctrnaccd%type,p_ctrncur in xxi.trn.ctrncur%type,p_dt_trn in date) is   
  select sum(mtrnsum)
    from (
          select xm.mtrnsum,
                 xm.ctrnaccd,
                 xm.ctrncur,
                 xm.ctrnacca,
                 xm.ctrnowna,
                 xm.ctrnpurp,
                 xm.dtrntran
            from xxi.trn xm
           where xm.ctrnaccd = p_ctrnaccd
             and xm.ctrncur = p_ctrncur
             and xm.dtrntran >= trunc(p_dt_trn, 'MM') 
             and xm.dtrntran < p_dt_trn
             and xm.ctrnmfoa in (select cfilmfo from xxi."fil" where idsmr = gc_BankIdSmr)  --! наши филиалы -> внутрибанк                                                         
             and (    xm.ITRNTYPE = 4
                   OR xm.ITRNTYPE = 2        
                   OR xm.ITRNTYPE in (11,28) 
                  AND EXISTS( select 1
                               from trc
                              where trc.ITRCNUM = xm.ITRNNUMANC
                                and trc.ITRCTYPE in (2,4) )
                 )
           )     
   where ubrr_xxi5.ubrr_bnkserv_online_comiss.check_account_fl(ctrnacca,ctrnowna,ctrnpurp) = 1   --!  счет получателя, выделенный из трех полей платежного документа соответствует маскам 40817%,40820% ,423%,426%    
     and ubrr_xxi5.ubrr_bnkserv_online_comiss.check_word_ex_ulfl_vb(ctrnaccd,ctrncur,ctrnpurp,dtrntran) = 1
     ;
            
  ln_SumBefo      NUMBER := 0;
BEGIN
    
  open cur_SumBefo_trn(par_ctrnaccd,par_ctrncur,par_dt_trn);
  fetch cur_SumBefo_trn into ln_SumBefo;
  close cur_SumBefo_trn;

  RETURN NVL(ln_SumBefo,0);
  
EXCEPTION
  WHEN OTHERS THEN
    Write_Error_Log(dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
    RETURN ln_SumBefo;
END Get_SumBefo_ULFL_VB;

-----------------------------------------------------------------
-- Вернем данные по комиссии если платеж пожходит под ULFL_VB
-----------------------------------------------------------------
FUNCTION Get_MoneyOrder_ULFL_VB(par_ctrnaccd    in xxi.trn.ctrnaccd%type, 
                                par_ctrncur     in xxi.trn.ctrncur%type, 
                                par_mtrnsum     in xxi.trn.mtrnsum%type, 
                                par_ctrnacca    in xxi.trn.ctrnacca%type, 
                                par_ctrnowna    in xxi.trn.ctrnowna%type, 
                                par_ctrnpurp    in xxi.trn.ctrnpurp%type, 
                                par_dtrntran    in xxi.trn.dtrntran%type, 
                                par_dtrncreate  in xxi.trn.dtrncreate%type, 
                                par_ctrnmfoa    in xxi.trn.ctrnmfoa%type, 
                                par_itrntype    in xxi.trn.itrntype%type, 
                                par_itrnnumanc  in xxi.trn.itrnnumanc%type, 
                                par_dt_trn      in date
                                )
  RETURN T_Rec_Commis
  IS 
  
  cursor cur_trn_of_sbs_new(p_ctrnaccd    in xxi.trn.ctrnaccd%type, 
                            p_ctrncur     in xxi.trn.ctrncur%type, 
                            p_mtrnsum     in xxi.trn.mtrnsum%type, 
                            p_ctrnacca    in xxi.trn.ctrnacca%type, 
                            p_ctrnowna    in xxi.trn.ctrnowna%type, 
                            p_ctrnpurp    in xxi.trn.ctrnpurp%type, 
                            p_dtrntran    in xxi.trn.dtrntran%type, 
                            p_dtrncreate  in xxi.trn.dtrncreate%type, 
                            p_ctrnmfoa    in xxi.trn.ctrnmfoa%type, 
                            p_itrntype    in xxi.trn.itrntype%type, 
                            p_itrnnumanc  in xxi.trn.itrnnumanc%type,
                            p_date        in date) is
  select ctrnaccd, 
         ctrncur,
         typecom, 
         mtrnsum,
         1, 
         ubrr_xxi5.ubrr_bnkserv_calc_new.getsumcomiss(NULL, NULL, ctrnAccD, ctrncur, iaccotd, typecom, mtrnsum, SumBefo) sumcom,
         iaccotd, 
         (case when 1 = '16' then 5407 else to_number(to_char(NVL(iOTDbatnum,70) )||'00') end) batnum,
         trunc(par_dtrncreate),
         (case when 1 = '16' then 3 else 16 end) itypecom,
         trunc(sysdate),
         SumBefo
   from (select 
                a.cACCacc as ctrnaccd, 
                a.cacccur as ctrncur, 
                p_mtrnsum as mtrnsum, 
                'UL_FL_VB' TypeCom, 
                o.iOTDbatnum,
                a.iaccotd,
                a.iacccus, 
                coalesce(ubrr_xxi5.ubrr_bnkserv_online_comiss.get_sumbefo_ulfl_vb(a.cACCacc,a.cacccur,p_date),0) SumBefo,               
                p_ctrnacca as ctrnacca,
                p_ctrnowna as ctrnowna,
                p_ctrnpurp as ctrnpurp,
                p_dtrntran as dtrntran
           from acc a, otd o
          where 1=1
            and trunc(p_dtrncreate) >= gd_ulfl_vb_enable_online--pinaev
            and a.cACCacc = p_cTRNaccd
            and a.cacccur = p_ctrncur        
            and a.cACCprizn <> 'З'
            and o.iotdnum = a.iaccotd
            and ((a.cACCacc like '40%' and to_number(substr(a.cACCacc, 3, 1)) between 1 and 7) --! счет плательщика соответствует маскам 401-407%,40802%, 40807
                  or a.cACCacc like '40802%'
                  or a.cACCacc like '40807%'
                  or a.cACCacc like '40821%'
                 )
            and p_ctrnmfoa in (select f.cfilmfo 
                                   from xxi."fil" f
                                  where f.idsmr = gc_BankIdSmr)                 
            and (    p_ITRNTYPE = 4
                  OR p_ITRNTYPE = 2       
                  OR p_ITRNTYPE in (11,28) 
                  AND EXISTS( select 1
                               from trc
                              where trc.ITRCNUM = p_ITRNNUMANC
                                and trc.ITRCTYPE  in (2,4) ) 
                )                    
        )
  where ubrr_xxi5.ubrr_bnkserv_online_comiss.check_account_fl(ctrnacca,ctrnowna,ctrnpurp) = 1  --проверка счет ФЛ
    and ubrr_xxi5.ubrr_bnkserv_online_comiss.check_word_ex_ulfl_vb(ctrnaccd,ctrncur,ctrnpurp,dtrntran) = 1  --проверка свола исключений    
    and ubrr_xxi5.ubrr_bnkserv_online_comiss.check_otd_comiss('UL_FL_VB',iaccotd) = 1  --проверка отделения
    and ubrr_xxi5.ubrr_bnkserv_online_comiss.check_gac_gcs_ex('UL_FL_VB',ctrnaccd,ctrncur,iacccus) = 0 --проверка кат/гр
    ; 

  lr_Rec_Commis       T_Rec_Commis;
BEGIN  
  
  --проверим платеж
  OPEN cur_trn_of_sbs_new(par_ctrnaccd,par_ctrncur,par_mtrnsum,par_ctrnacca,par_ctrnowna,par_ctrnpurp,par_dtrntran,par_dtrncreate,par_ctrnmfoa,par_itrntype,par_itrnnumanc,par_dt_trn);
  FETCH cur_trn_of_sbs_new INTO lr_Rec_Commis;
  CLOSE cur_trn_of_sbs_new;
    
  RETURN lr_Rec_Commis;

EXCEPTION
  WHEN OTHERS THEN
    if cur_trn_of_sbs_new%isopen then close cur_trn_of_sbs_new; end if;
    Write_Error_Log(dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
    RETURN lr_Rec_Commis;
END Get_MoneyOrder_ULFL_VB;

/*
-----------------------------------------------------------------
-- Вернем данные по комиссии если платеж пожходит под PP3
-----------------------------------------------------------------
FUNCTION Get_MoneyOrder_PP3(par_Itrnnum       in xxi.trn.ITRNNUM%type,
                            par_Itrnanum      in xxi.trn.ITRNANUM%type
                            )
  RETURN T_Rec_Commis
  IS 
  
  cursor cur_trn_of_sbs_new(p_Itrnnum in xxi.trn.ITRNNUM%type, p_Itrnanum in xxi.trn.ITRNANUM%type) is
  select ctrnaccd,
         ctrncur,
         TypeCom,
         mtrnsum,
         1,
         sumcom,
         iaccotd,
         batnum,
         trunc(sysdate),
         1,
         trunc(sysdate),
         '' SumBefo
   from (select itrnnum,
                itrnanum,
                ctrnaccd,
                ctrncur,
                mtrnsum,
                ubrr_xxi5.ubrr_bnkserv_calc_new.getsumcomiss(itrnnum, itrnanum, ctrnAccD, ctrncur, a.iaccotd,'PP3', mtrnsum, 0) sumcom,
                'PP3' as TypeCom,
                a.iaccotd,
                a.iacccus,
                to_number(to_char(nvl(iOTDbatnum, 70)) || '00') batnum
           from xxi.v_trn_part_current t, acc a, otd o
           where 1=1
             and t.ITRNNUM = p_Itrnnum
             and t.ITRNANUM = p_Itrnanum
             and t.dtrncreate >= gd_pp3_enable_online--pinaev
             and a.caccacc = t.ctrnaccd
             and a.cacccur = t.ctrncur
             and a.caccprizn <> 'З'
             and o.iotdnum = a.iaccotd
             and ((((itrntype in (2, 3, 14) and itrnpriority not in (3, 4) and nvl(iTRNsop, 0) <> 4)
                 or  (itrntype in (25, 28)
                  and nvl(iTRNsop, 0) not in (5, 7)
                  and itrnpriority not in (3, 4)
                  and not (itrntype = 25
                       and regexp_like(ctrnpurp, '^ *(|! *)0406')
                       and exists
                               (select 1
                                from xxi."smr"
                                where csmrmfo8 = ctrnmfoa))))
               and (substr(itrnba2c, 1, 3) in (303, 405, 406, 407, 423, 426)
                 or itrnba2c in (40802, 40807, 40817, 40818, 40820)))
               or  (itrntype in (4, 11, 15, 21, 23)
                --and ubrr_xxi5.ubrr_check_pay_budget(itrnnum,itrnanum,ctrncoracca,ctrnacca) = 0
                and nvl(iTRNsop, 0) <> 4
                and ctrnmfoa in (select cfilmfo
                                 from xxi."fil"
                                 where idsmr = gc_BankIdSmr)
                and not (itrntype=4 and itrnsop=51 and ctrnpurp like '0450%') )
                )           
             and iTRNba2d not in (40813,40817,40818,40820,42309,40810,40811,40812,40823,40824)
             and a.caccacc <> '40703810100080000005'
             and substr(a.caccacc, 1, 3) not in ('401','402','403','404','409')
             and nvl(iTRNsop,0) <> 4 
        )
      where ubrr_xxi5.ubrr_bnkserv_online_comiss.check_otd_comiss('PP3',iaccotd) = 1  --проверка отделения
        and ubrr_xxi5.ubrr_bnkserv_online_comiss.check_gac_gcs_ex('PP3',ctrnaccd,ctrncur,iacccus) = 0 --проверка кат/гр*\
  ;
    
  lr_Rec_Commis       T_Rec_Commis;
BEGIN  
  
  --проверим платеж
  OPEN cur_trn_of_sbs_new(par_Itrnnum, par_Itrnanum);
  FETCH cur_trn_of_sbs_new INTO lr_Rec_Commis;
  CLOSE cur_trn_of_sbs_new;
    
  RETURN lr_Rec_Commis;

EXCEPTION
  WHEN OTHERS THEN
    if cur_trn_of_sbs_new%isopen then close cur_trn_of_sbs_new; end if;
    Write_Error_Log('Itrnnum = '||par_Itrnnum||' Itrnanum = '||par_Itrnanum|| chr(10) ||dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
    RETURN lr_Rec_Commis;
END Get_MoneyOrder_PP3;
*/

-----------------------------------------------------------------
-- Вернем данные по комиссии если платеж пожходит под PP3
-----------------------------------------------------------------
FUNCTION Get_MoneyOrder_PP3(par_ctrnaccd     in xxi.trn.ctrnaccd%type, 
                            par_ctrncur      in xxi.trn.ctrncur%type, 
                            par_mtrnsum      in xxi.trn.mtrnsum%type, 
                            par_ctrnacca     in xxi.trn.ctrnacca%type, 
                            par_ctrnpurp     in xxi.trn.ctrnpurp%type, 
                            par_dtrncreate   in xxi.trn.dtrncreate%type, 
                            par_ctrnmfoa     in xxi.trn.ctrnmfoa%type, 
                            par_itrntype     in xxi.trn.itrntype%type,
                            par_iTRNsop      in xxi.trn.itrnsop%type,
                            par_itrnpriority in xxi.trn.itrnpriority%type,
                            par_itrnba2c     in xxi.trn.itrnba2c%type,
                            par_ccreatstatus in xxi.trn_dept_info.ccreatstatus%type
                            )
  RETURN T_Rec_Commis
  IS 
  
  cursor cur_trn_of_sbs_new(p_ctrnaccd     in xxi.trn.ctrnaccd%type, 
                            p_ctrncur      in xxi.trn.ctrncur%type, 
                            p_mtrnsum      in xxi.trn.mtrnsum%type, 
                            p_ctrnacca     in xxi.trn.ctrnacca%type, 
                            p_ctrnpurp     in xxi.trn.ctrnpurp%type, 
                            p_dtrncreate   in xxi.trn.dtrncreate%type, 
                            p_ctrnmfoa     in xxi.trn.ctrnmfoa%type, 
                            p_itrntype     in xxi.trn.itrntype%type,
                            p_iTRNsop      in xxi.trn.itrnsop%type,
                            p_itrnpriority in xxi.trn.itrnpriority%type,
                            p_itrnba2c     in xxi.trn.itrnba2c%type,
                            p_ccreatstatus in xxi.trn_dept_info.ccreatstatus%type,
                            p_ctrnacca_old  xxi.ups.cupsvalue%type,
                            p_ctrnacca_new  xxi.ups.cupsvalue%type) is
  select ctrnaccd,
         ctrncur,
         TypeCom,
         mtrnsum,
         1,
         sumcom,
         iaccotd,
         batnum,
         trunc(par_dtrncreate),
         1,
         trunc(sysdate),
         '' SumBefo
   from (select a.caccacc as ctrnaccd,
                a.cacccur as ctrncur,
                p_mtrnsum as mtrnsum,
                ubrr_xxi5.ubrr_bnkserv_calc_new.getsumcomiss(null/*itrnnum*/, null/*itrnanum*/, a.caccacc, a.cacccur, a.iaccotd,'PP3', p_mtrnsum, 0) sumcom,
                'PP3' as TypeCom,
                a.iaccotd,
                a.iacccus,
                to_number(to_char(nvl(iOTDbatnum, 70)) || '00') batnum
           from acc a, otd o
           where 1=1
             and p_dtrncreate >= gd_pp3_enable_online--pinaev
             and a.caccacc = p_ctrnaccd
             and a.cacccur = p_ctrncur
             and a.caccprizn <> 'З'
             and o.iotdnum = a.iaccotd
             and ((((p_itrntype in (2, 3, 14) and p_itrnpriority not in (3, 4) and nvl(p_iTRNsop, 0) <> 4)
                 or  (p_itrntype in (25, 28)
                  and nvl(p_iTRNsop, 0) not in (5, 7)
                  and p_itrnpriority not in (3, 4)
                  and not (p_itrntype = 25
                       and regexp_like(p_ctrnpurp, '^ *(|! *)0406')
                       and exists
                               (select 1
                                from xxi."smr"
                                where csmrmfo8 = p_ctrnmfoa))))
               and (substr(p_itrnba2c, 1, 3) in (303, 405, 406, 407, 423, 426)
                 or p_itrnba2c in (40802, 40807, 40817, 40818, 40820)))
               or  (p_itrntype in (4, 11, 15, 21, 23)
                -->>проверка платежа в бюждет если есть статус
                --and ubrr_xxi5.ubrr_check_pay_budget(itrnnum,itrnanum,ctrncoracca,ctrnacca) = 0
                and not (
                          (regexp_like(p_ctrnacca,'^('||p_ctrnacca_old||')')
                           and p_ccreatstatus is not null
                          )
                          OR
                          (regexp_like(p_ctrnacca,'^('||p_ctrnacca_new||')')
                           )
                        )
                --<<        
                and nvl(p_iTRNsop, 0) <> 4
                and p_ctrnmfoa in (select cfilmfo
                                 from xxi."fil"
                                 where idsmr = gc_BankIdSmr)
                and not (p_itrntype=4 and p_itrnsop=51 and p_ctrnpurp like '0450%') )
                )           
             and substr(a.caccacc, 1, 5) not in ('40813','40817','40818','40820','42309','40810','40811','40812','40823','40824')
             and a.caccacc <> '40703810100080000005'
             and substr(a.caccacc, 1, 3) not in ('401','402','403','404','409')
             and nvl(p_iTRNsop,0) <> 4 
        )
      where ubrr_xxi5.ubrr_bnkserv_online_comiss.check_otd_comiss('PP3',iaccotd) = 1  --проверка отделения
        and ubrr_xxi5.ubrr_bnkserv_online_comiss.check_gac_gcs_ex('PP3',ctrnaccd,ctrncur,iacccus) = 0 --проверка кат/гр
  ;
    
  lr_Rec_Commis       T_Rec_Commis;
  l_ctrnacca_old      xxi.ups.cupsvalue%type := nvl(PREF.Get_Preference('UBRR_CHECK_PAY_BUDGET.CTRNACCA_OLD'),'401|402|403|404');                                              --список маски старых счетов
  l_ctrnacca_new      xxi.ups.cupsvalue%type := nvl(PREF.Get_Preference('UBRR_CHECK_PAY_BUDGET.CTRNACCA_NEW'),'03100|03212|03222|03232|03242|03252|03262|03272|03221|03231');  --список маски новых счетов
BEGIN  
  
  --проверим платеж
  OPEN cur_trn_of_sbs_new(par_ctrnaccd,par_ctrncur,par_mtrnsum,par_ctrnacca,par_ctrnpurp,par_dtrncreate,par_ctrnmfoa,par_itrntype,par_iTRNsop,par_itrnpriority,par_itrnba2c,par_ccreatstatus,l_ctrnacca_old,l_ctrnacca_new);
  FETCH cur_trn_of_sbs_new INTO lr_Rec_Commis;
  CLOSE cur_trn_of_sbs_new;
    
  RETURN lr_Rec_Commis;

EXCEPTION
  WHEN OTHERS THEN
    if cur_trn_of_sbs_new%isopen then close cur_trn_of_sbs_new; end if;
    Write_Error_Log(dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
    RETURN lr_Rec_Commis;
END Get_MoneyOrder_PP3;

-----------------------------------------------------------------
-- Вернем данные по комиссии 
-----------------------------------------------------------------
FUNCTION Get_Comiss(par_Itrnnum       in xxi.trn.ITRNNUM%type,
                    par_Itrnanum      in xxi.trn.ITRNANUM%type
                    )
  RETURN T_Rec_Commis
  IS

  cursor cur_trn(p_Itrnnum in xxi.trn.ITRNNUM%type, p_Itrnanum in xxi.trn.ITRNANUM%type) is  
  select a.*
    from xxi.trn a
   where a.itrnnum = p_Itrnnum 
     and a.itrnanum = p_Itrnanum;
     
  cursor cur_trn_dept_info(p_Itrnnum in xxi.trn.ITRNNUM%type, p_Itrnanum in xxi.trn.ITRNANUM%type) is  
  select a.*
    from xxi.trn_dept_info a
   where a.inum = p_Itrnnum 
     and a.ianum = p_Itrnanum;     

  lr_trn              cur_trn%rowtype; 
  lr_trn_dept_info    cur_trn_dept_info%rowtype;      
  l_dt_trn            date; 
  lr_Rec_Commis       T_Rec_Commis;
BEGIN  

  open cur_trn(par_Itrnnum,par_Itrnanum);
  fetch cur_trn into lr_trn;
  close cur_trn;

  open cur_trn_dept_info(par_Itrnnum,par_Itrnanum);
  fetch cur_trn_dept_info into lr_trn_dept_info;
  close cur_trn_dept_info;  

  --вернем дату создания операции
  l_dt_trn := coalesce(lr_trn.dtrntran, Get_Date_Create_AU(par_Itrnnum,par_Itrnanum), sysdate);

  --вернем данные
  lr_Rec_Commis := ubrr_xxi5.ubrr_bnkserv_online_comiss.get_comiss( par_ctrnaccd     => lr_trn.ctrnaccd,
                                                                    par_ctrncur      => lr_trn.ctrncur,
                                                                    par_mtrnsum      => lr_trn.mtrnsum,
                                                                    par_ctrnacca     => lr_trn.ctrnacca,
                                                                    par_ctrnowna     => lr_trn.ctrnowna,
                                                                    par_ctrnpurp     => lr_trn.ctrnpurp,
                                                                    par_dtrntran     => lr_trn.dtrntran,
                                                                    par_dtrncreate   => lr_trn.dtrncreate,
                                                                    par_ctrnmfoa     => lr_trn.ctrnmfoa,
                                                                    par_itrntype     => lr_trn.itrntype,
                                                                    par_itrnsop      => lr_trn.itrnsop,
                                                                    par_itrnpriority => lr_trn.itrnpriority,
                                                                    par_itrnba2c     => lr_trn.itrnba2c,
                                                                    par_ccreatstatus => lr_trn_dept_info.ccreatstatus,
                                                                    par_itrnnumanc   => lr_trn.itrnnumanc,
                                                                    par_dt_trn       => l_dt_trn
                                                                    );
 
  RETURN lr_Rec_Commis;
  
EXCEPTION
  WHEN OTHERS THEN
    Write_Error_Log('Itrnnum = '||par_Itrnnum||' Itrnanum = '||par_Itrnanum|| chr(10) ||dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
    RETURN lr_Rec_Commis;
END Get_Comiss;

-----------------------------------------------------------------
-- Вернем данные по комиссии 
-----------------------------------------------------------------
FUNCTION Get_Comiss(par_ctrnaccd     in xxi.trn.ctrnaccd%type, 
                    par_ctrncur      in xxi.trn.ctrncur%type, 
                    par_mtrnsum      in xxi.trn.mtrnsum%type, 
                    par_ctrnacca     in xxi.trn.ctrnacca%type, 
                    par_ctrnowna     in xxi.trn.ctrnowna%type, 
                    par_ctrnpurp     in xxi.trn.ctrnpurp%type, 
                    par_dtrntran     in xxi.trn.dtrntran%type, 
                    par_dtrncreate   in xxi.trn.dtrncreate%type, 
                    par_ctrnmfoa     in xxi.trn.ctrnmfoa%type, 
                    par_itrntype     in xxi.trn.itrntype%type, 
                    par_iTRNsop      in xxi.trn.itrnsop%type,
                    par_itrnpriority in xxi.trn.itrnpriority%type,
                    par_itrnba2c     in xxi.trn.itrnba2c%type,
                    par_ccreatstatus in xxi.trn_dept_info.ccreatstatus%type,
                    par_itrnnumanc   in xxi.trn.itrnnumanc%type,                    
                    par_dt_trn       in date
                    )
  RETURN T_Rec_Commis
  IS
  
  lr_Rec_Commis       T_Rec_Commis;
BEGIN  
  
  --инициализируем переменные пакета
  Init_Global_Item;
  
  --установить пакетную переменную
  ubrr_xxi5.ubrr_bnkserv_calc_new.set_dater(p_date => par_dt_trn);
   
  --вернем данные ULFL_VB
  lr_Rec_Commis := Get_MoneyOrder_ULFL_VB(par_ctrnaccd    => par_ctrnaccd, 
                                          par_ctrncur     => par_ctrncur, 
                                          par_mtrnsum     => par_mtrnsum,
                                          par_ctrnacca    => par_ctrnacca,
                                          par_ctrnowna    => par_ctrnowna,
                                          par_ctrnpurp    => par_ctrnpurp,
                                          par_dtrntran    => par_dtrntran,
                                          par_dtrncreate  => par_dtrncreate,
                                          par_ctrnmfoa    => par_ctrnmfoa,
                                          par_itrntype    => par_itrntype,
                                          par_itrnnumanc  => par_itrnnumanc,
                                          par_dt_trn      => par_dt_trn
                                          );
  if lr_Rec_Commis.cSBSTypeCom is not null then     
    RETURN lr_Rec_Commis;
  end if;
  
  --вернем данные PP3
  lr_Rec_Commis := Get_MoneyOrder_PP3(par_ctrnaccd     => par_ctrnaccd,
                                      par_ctrncur      => par_ctrncur,
                                      par_mtrnsum      => par_mtrnsum,
                                      par_ctrnacca     => par_ctrnacca,
                                      par_ctrnpurp     => par_ctrnpurp,
                                      par_dtrncreate   => par_dtrncreate,
                                      par_ctrnmfoa     => par_ctrnmfoa,
                                      par_itrntype     => par_itrntype,
                                      par_itrnsop      => par_itrnsop,
                                      par_itrnpriority => par_itrnpriority,
                                      par_itrnba2c     => par_itrnba2c,
                                      par_ccreatstatus => par_ccreatstatus
                                      );
                                      
  if lr_Rec_Commis.cSBSTypeCom is not null then     
    RETURN lr_Rec_Commis;
  end if;  

  RETURN lr_Rec_Commis;
  
EXCEPTION
  WHEN OTHERS THEN
    Write_Error_Log(dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
    RETURN lr_Rec_Commis;
END Get_Comiss;

-----------------------------------------------------------------
-- Вернем только сумму комиссии 
-----------------------------------------------------------------
FUNCTION Get_Comiss_Sum(par_ctrnaccd     in xxi.trn.ctrnaccd%type, 
                        par_ctrncur      in xxi.trn.ctrncur%type, 
                        par_mtrnsum      in xxi.trn.mtrnsum%type, 
                        par_ctrnacca     in xxi.trn.ctrnacca%type, 
                        par_ctrnowna     in xxi.trn.ctrnowna%type, 
                        par_ctrnpurp     in xxi.trn.ctrnpurp%type, 
                        par_dtrntran     in xxi.trn.dtrntran%type, 
                        par_dtrncreate   in xxi.trn.dtrncreate%type, 
                        par_ctrnmfoa     in xxi.trn.ctrnmfoa%type, 
                        par_itrntype     in xxi.trn.itrntype%type, 
                        par_iTRNsop      in xxi.trn.itrnsop%type,
                        par_itrnpriority in xxi.trn.itrnpriority%type,
                        par_itrnba2c     in xxi.trn.itrnba2c%type,
                        par_ccreatstatus in xxi.trn_dept_info.ccreatstatus%type,
                        par_itrnnumanc   in xxi.trn.itrnnumanc%type,                    
                        par_dt_trn       in date
                        )
  RETURN NUMBER
  IS
  
  lr_Rec_Commis       T_Rec_Commis;
BEGIN
  
  --вернем данные
  lr_Rec_Commis := ubrr_xxi5.ubrr_bnkserv_online_comiss.get_comiss( par_ctrnaccd     => par_ctrnaccd,
                                                                    par_ctrncur      => par_ctrncur,
                                                                    par_mtrnsum      => par_mtrnsum,
                                                                    par_ctrnacca     => par_ctrnacca,
                                                                    par_ctrnowna     => par_ctrnowna,
                                                                    par_ctrnpurp     => par_ctrnpurp,
                                                                    par_dtrntran     => par_dtrntran,
                                                                    par_dtrncreate   => par_dtrncreate,
                                                                    par_ctrnmfoa     => par_ctrnmfoa,
                                                                    par_itrntype     => par_itrntype,
                                                                    par_itrnsop      => par_itrnsop,
                                                                    par_itrnpriority => par_itrnpriority,
                                                                    par_itrnba2c     => par_itrnba2c,
                                                                    par_ccreatstatus => par_ccreatstatus,
                                                                    par_itrnnumanc   => par_itrnnumanc,
                                                                    par_dt_trn       => par_dt_trn
                                                                    );
  RETURN NVL(lr_Rec_Commis.mSBSsumcom,0);
  
EXCEPTION
  WHEN OTHERS THEN
    Write_Error_Log(dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
    RETURN 0;
END Get_Comiss_Sum;


-----------------------------------------------------------------
-- Тестовый расчет за период
-----------------------------------------------------------------
FUNCTION Calc_Test_Comiss(p_d1            in date,
                          p_d2            in date,
                      --    p_datereg       in date,
                          p_reg           in integer)  RETURN integer
  IS
  
  l_tbl_trn  ubrr_xxi5.ubrr_bnkserv_online_comiss.type_tbl_trn;
  l_new_cnt integer:=0;
     
  cursor cur_trn_check(p_d1 in date, p_d2 in date) is  
  select a.*
    from V_TRN_PART_CURRENT a
   where 1=1
     and a.DTRNCREATE >= p_d1 and a.DTRNCREATE <= p_d2    
    and regexp_like(a.ctrnaccd,'^('||gc_payer_account||')')
     and not regexp_like(a.ctrnaccd,'^('||gc_not_payer_account||')')
     and UBRR_XXI5.UBRR_CHECK_PAY_BUDGET(a.itrnnum,a.itrnanum,a.ctrncoracca,a.ctrnacca) = 0     
     and regexp_like(a.itrntype,'^('||gc_type_all||')') 
     and not regexp_like(a.ctrnaccc,'^('||gc_not_receiver_account||')')    
     and not ( regexp_like(a.itrntype,'^('||gc_not_type_sop||')') and  regexp_like( coalesce(a.itrnsop,0),'^('||gc_not_sop_type||')') )
     and not ( regexp_like(a.itrntype,'^('||gc_not_type_purp||')')
               and regexp_like(a.ctrnpurp, '^ *(|! *)0406')
               and exists (select 1
                            from xxi."smr"
                           where csmrmfo8 = a.ctrnmfoa
                           )
              )
      and exists (select 1
                   from xxi."fil" 
                  where idsmr = gc_BankIdSmr 
                    and cfilmfo = a.CTRNMFOA--p_ctrnmfoa
                 )        
      and exists(select 1
                 from acc t
                where t.caccacc = a.ctrnaccd
                  and t.cacccur = a.ctrncur
                  and regexp_like(t.IACCOTD,'^('||gc_enable_list_otd||')') )
     and not exists(select 1
                      from gac
                     where cgacacc = a.ctrnaccd
                      and cgaccur = a.ctrncur
                      and regexp_like(igaccat||'/'||igacnum,'^('||gc_not_gac||')')
                    )
     and not exists(  select 1
                     from ubrr_data.ubrr_sbs_new t
                     where t.itrnnum = a.Itrnnum 
                       and t.itrnanum = a.Itrnanum
                       and t.iSBStrnnum is not null
                       and t.ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created
    );

   
BEGIN
  --инициализируем переменные пакета
  Init_Global_Item;
  --Write_Error_Log('Calc_TestComiss:тестовый расчет онлайн-комисси за период c ' || to_char(p_d1,'dd.mm.yyyy') || ' по ' || to_char(p_d1,'dd.mm.yyyy')||',регистрация: '|| p_reg);

  --проверим значение переменной, включение онлайн комиссий
  if gc_enable_online = 'Y' then  
     
    open  cur_trn_check( p_d1, p_d2 ); 
    
    loop

      l_tbl_trn.delete();
        
      fetch cur_trn_check bulk collect into l_tbl_trn limit gc_trn_limit_bulk;      
      exit when l_tbl_trn.count =0;
      
      --Write_Error_Log('Calc_TestComiss:l_tbl_trn.count='||l_tbl_trn.count);
      
      for i in 1..l_tbl_trn.count loop 
        
          delete  ubrr_data.ubrr_sbs_new t
                     where t.itrnnum = l_tbl_trn(i).itrnnum 
                       and t.itrnanum = l_tbl_trn(i).itrnanum
                       and t.iSBStrnnum is null;
                       
          l_new_cnt :=  l_new_cnt + ubrr_xxi5.ubrr_bnkserv_online_comiss.Calc_Comiss ( l_tbl_trn(i).itrnnum, l_tbl_trn(i).itrnanum, /*p_datereg,*/ p_reg );
/*          if l_new_cnt = 1 then            
             Write_Error_Log('Calc_TestComiss: есть комиссия для l_tbl_trn(i).itrnnum=' || l_tbl_trn(i).itrnnum);
          end if;*/
          
      end loop;
      
    end loop;
    
    l_tbl_trn.delete();
    close cur_trn_check;
      
  end if; 
      
  return l_new_cnt; 
    
EXCEPTION
 WHEN OTHERS THEN
   if cur_trn_check%isopen then close cur_trn_check; end if;
   Write_Error_Log(dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
   return l_new_cnt;
END Calc_Test_Comiss;

-----------------------------------------------------------------
-- Откат комиссий, помеченных в форме
-----------------------------------------------------------------
function writeoff_doc( p_markerid in number ) return varchar2 is

  cursor cur_racc is
    select *
      from ubrr_data.ubrr_sbs_new a, mrk
     where mrk.imrkmarkerid = p_markerid
       and mrk.rmrkrowid = a.rowid
       and a.csbsstat is not null
     order by a.idsmr;

  l_cdelretcode  varchar2(2000);
  l_cdelerrormsg varchar2(2000);
  l_isucctrn     number := 0;
  l_isucctrc     number := 0;
  l_ibad        number := 0;

BEGIN

  for r in cur_racc loop
  
    l_cdelretcode  := null;
    l_cdelerrormsg := null;
  
    if r.isbstrntrc = 1 then
      -- реестр
      l_cdelretcode := doc_del.delete_logical(l_cdelerrormsg,
                                              r.isbstrnnum,
                                              1);
    elsif r.isbstrntrc = 2 then
      --картотека
      l_cdelretcode := card.delete_document(l_cdelerrormsg, r.isbstrnnum, 0);
    end if;
  
    if l_cdelretcode <> 'Ok' and l_cdelretcode <> '0' and
       l_cdelerrormsg not like 'Документ ID%' THEN
    
      l_ibad := l_ibad + 1;
    
      update ubrr_data.ubrr_sbs_new
         set CSBSSTAT = 'Ошибка при откате: ' || l_cdelerrormsg
       where csbsaccd = r.csbsaccd
         and dsbsdate = r.dsbsdate
         and rowid = r.rmrkrowid;
    
    else
    
      update ubrr_data.ubrr_sbs_new
         set csbsstat    = null,
             isbstrnnum  = null,
             isbstrntrc  = null,
             isbsdocnum  = null,
             isbsbatnum  = null,
             dsbsdatereg = null
       where csbsaccd = r.csbsaccd
         and dsbsdate = r.dsbsdate
         and rowid = r.rmrkrowid;
    
      if r.isbstrntrc = 1 then
        l_isucctrn := l_isucctrn + 1;
      elsif r.isbstrntrc = 2 then
        l_isucctrc := l_isucctrc + 1;
      end if;
    
    end if;
  
  end loop;

  return('Удалено:' || chr(10) || 'из реестра документов: ' || l_isucctrn ||
         chr(10) || 'из картотеки: ' || l_isucctrc || chr(10) ||
         'c ошибкой: ' || l_ibad);

exception
  when others then
    rollback;
    return ts.to_2000('Ошибка при удалении документов: ' ||
                      dbms_utility.format_error_stack || ' ' ||
                      dbms_utility.format_error_backtrace);
end;

-----------------------------------------------------------------
-- Функция расчета по взымаинию онлайн комиссии
-----------------------------------------------------------------
FUNCTION Calc_Comiss(par_Itrnnum       in xxi.trn.ITRNNUM%type,
                     par_Itrnanum      in xxi.trn.ITRNANUM%type,
                    -- par_datereg       in date    default null,
                     par_reg           in integer default 1 )
  RETURN INTEGER
  IS 
  cursor cur_trn(p_Itrnnum in xxi.trn.ITRNNUM%type, p_Itrnanum in xxi.trn.ITRNANUM%type) is  
  select a.*
    from xxi.trn a
   where a.itrnnum = p_Itrnnum 
     and a.itrnanum = p_Itrnanum
     FOR UPDATE;
  
  cSavePoint          DCL.T_Name;
  l_tbl_trn           ubrr_xxi5.ubrr_bnkserv_online_comiss.type_tbl_trn;
  ln_trn_comiss       INTEGER := 0;
  ln_id_sbs_new       NUMBER;
  ln_reg              NUMBER;
  --lc_msg              VARCHAR2(32767) := $$plsql_unit||'.Calc_Comiss:';--pin
BEGIN
  DCL.SavePoint(cSavePoint);
  
  DECLARE 
    e_Calc_Error        EXCEPTION;
    e_No_Calc_Required  EXCEPTION;  
  BEGIN 
     
    l_tbl_trn.delete();
    
    --вернем даныне по операции в коллекцию и залочим запись
    OPEN cur_trn(par_Itrnnum, par_Itrnanum);
    FETCH cur_trn BULK COLLECT INTO l_tbl_trn;
    CLOSE cur_trn;
          
    IF l_tbl_trn.count = 0 THEN
      RAISE e_No_Calc_Required;
    END IF;
    
    --пройдем циклом, но знаем что там 1 запись
    FOR iCurrent IN l_tbl_trn.first .. l_tbl_trn.last 
      LOOP
        
        --Write_Error_Log(lc_msg||'Itrnnum = '||par_Itrnnum||' Itrnanum = '||par_Itrnanum );--pin
 
        --проверим что наш банк
        IF Check_Current_Bank_Bik(l_tbl_trn(iCurrent).ctrnmfoa) then                
          
          r_Rec_Commis := null;
          
          --Write_Error_Log(lc_msg||'Check_Current_Bank_Bik = true:'||l_tbl_trn(iCurrent).ctrnmfoa );--pin
          
          --вернем данные по комисси
          r_Rec_Commis := ubrr_xxi5.ubrr_bnkserv_online_comiss.get_comiss(l_tbl_trn(iCurrent).itrnnum, l_tbl_trn(iCurrent).itrnanum);

          if r_Rec_Commis.cSBSTypeCom is not null then
            
            --Write_Error_Log(lc_msg||'Itrnnum = '||par_Itrnnum||' Itrnanum = '||par_Itrnanum|| r_Rec_Commis.cSBSTypeCom );--pin
            -->>pin
            /*if par_reg=1 and par_datereg is not null then
               r_Rec_Commis.dsbsdatereg := par_datereg;
            end if;*/
            --<<pin  
            
            --добавим запись в ubrr_sbs_new
            ln_id_sbs_new := Ins_sbs_new(par_cSBSaccd        => r_Rec_Commis.cSBSaccd, 
                                         par_csbscurd        => r_rec_commis.csbscurd, 
                                         par_cSBSTypeCom     => r_Rec_Commis.cSBSTypeCom,  
                                         par_mSBSsumpays     => r_Rec_Commis.mSBSsumpays, 
                                         par_iSBScountPays   => r_Rec_Commis.iSBScountPays, 
                                         par_mSBSsumcom      => r_Rec_Commis.mSBSsumcom, 
                                         par_iSBSotdnum      => r_Rec_Commis.iSBSotdnum,  
                                         par_iSBSBatNum      => r_Rec_Commis.iSBSBatNum,  
                                         par_dSBSDate        => r_Rec_Commis.dSBSDate, 
                                         par_iSBSTypeCom     => r_Rec_Commis.iSBSTypeCom,  
                                         par_dsbsdatereg     => r_Rec_Commis.dsbsdatereg,  
                                         par_MSBSSUMBEFO     => r_Rec_Commis.MSBSSUMBEFO,
                                         par_Itrnnum         => l_tbl_trn(iCurrent).itrnnum,
                                         par_Itrnanum        => l_tbl_trn(iCurrent).itrnanum
                                         );

            --Write_Error_Log('ln_id_sbs_new = '||ln_id_sbs_new);--pin
        
            if ln_id_sbs_new is null then
              if Get_ErrorMessage is null then
                Write_Error_Log('Itrnnum = '||l_tbl_trn(iCurrent).itrnnum||' Itrnanum = '||l_tbl_trn(iCurrent).itrnanum|| ' Ошибка при создание записи в ubrr_sbs_new, вернулся пустой ID');
              end if;  
              RAISE e_Calc_Error; 
            end if;
            
            --обновляем запись в ubrr_sbs_new
            ubrr_xxi5.ubrr_bnkserv_calc_new.updateacccomiss(p_typecom  => r_Rec_Commis.iSBSTypeCom,
                                                            p_date     => r_Rec_Commis.dSBSDate,
                                                            p_regdate  => r_Rec_Commis.dSBSDate,
                                                            p_ls       => r_Rec_Commis.cSBSaccd,
                                                            p_id_sbs   => ln_id_sbs_new,
                                                            p_commit   => 'N'
                                                            );
            
            if par_reg = 1 then --pin
              
              --регистрация документа
              ln_reg := Register(par_id_sbs         => ln_id_sbs_new ,
                                 par_Itrnnum        => l_tbl_trn(iCurrent).itrnnum,
                                 par_Itrnanum       => l_tbl_trn(iCurrent).itrnanum
                                );            
              --Write_Error_Log('ln_reg = '||ln_reg);--pin                              
                                
              if ln_reg < 0 then
                RAISE e_Calc_Error;
              end if;
            
            end if; --pin
                
            ln_trn_comiss := 1;   
          else
            RAISE e_No_Calc_Required;
          end if;          
        
        ELSE
          --Write_Error_Log(lc_msg||'Check_Current_Bank_Bik = false:'||l_tbl_trn(iCurrent).ctrnmfoa );
          RAISE e_No_Calc_Required;
        END IF;
      
      END LOOP;
  
  EXCEPTION
    WHEN e_No_Calc_Required THEN
      DCL.RollBack(cSavePoint);
      ln_trn_comiss := 0;
    WHEN e_Calc_Error THEN
      DCL.RollBack(cSavePoint);
      ln_trn_comiss := LEAST (ln_trn_comiss, -1);
    WHEN OTHERS THEN
      DCL.RollBack(cSavePoint);
      ln_trn_comiss := -2;
      Write_Error_Log('Itrnnum = '||par_Itrnnum||' Itrnanum = '||par_Itrnanum|| chr(10) ||dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
  END;    
    
  RETURN ln_trn_comiss;

EXCEPTION
  WHEN OTHERS THEN
    DCL.RollBack(cSavePoint);
    RETURN -2;
    Write_Error_Log('Itrnnum = '||par_Itrnnum||' Itrnanum = '||par_Itrnanum|| chr(10) ||dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);  
END; 

-----------------------------------------------------------------
-- Функция расчета по взымаинию онлайн комиссии
-----------------------------------------------------------------
FUNCTION Calc_Online_Comiss(par_Itrnnum       in xxi.trn.ITRNNUM%type,
                            par_Itrnanum      in xxi.trn.ITRNANUM%type
                            )
  RETURN INTEGER
  IS
  
  ln_trn_comiss   INTEGER := 0;
  --lc_msg          VARCHAR2(32767):=$$plsql_unit||'.Calc_Online_Comiss:';--pin
BEGIN
  --Write_Error_Log(lc_msg||'Itrnnum = '||par_Itrnnum||' Itrnanum = '||par_Itrnanum );--pin
  
  --Проверка платежа
  IF ubrr_xxi5.ubrr_bnkserv_online_comiss.PreCheck_Trn_Comiss(par_itrnnum => par_itrnnum, par_itrnanum => par_itrnanum) then   
    --Write_Error_Log(lc_msg||'Начнем расчет комиссий' );--pin
    --Начнем расчет комиссий
    ln_trn_comiss := Calc_Comiss(par_itrnnum => par_itrnnum, par_itrnanum => par_itrnanum);
  end if;
  
  RETURN ln_trn_comiss;
  
END Calc_Online_Comiss;
  
END ubrr_bnkserv_online_comiss;
/
