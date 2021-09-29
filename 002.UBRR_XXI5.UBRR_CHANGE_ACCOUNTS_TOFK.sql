create or replace package ubrr_xxi5.UBRR_CHANGE_ACCOUNTS_TOFK is

/******************************************** HISTORY **********************************************\
   Дата          Автор          id         Описание
----------  ---------------  -----------  ------------------------------------------------------------
18.11.2020  Зеленко С.А.    [20-82101.1]  АБС: Изменение счетов ТОФК с 01.01.2021
01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
\******************************************** HISTORY **********************************************/

-->>01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
TYPE T_Coracca     IS RECORD ( caccount    xxi.fog_ed807_acc.caccount%type );
TYPE T_tab_coracca  IS TABLE OF T_Coracca;
--<<01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

-----------------------------------------------------------------
-- Вернем дату с котоой можно совершать платежи по новым ТОФК
-----------------------------------------------------------------
FUNCTION GET_DATE_YEAR_2021
  RETURN DATE;

  -----------------------------------------------------------------
-- Вернем дату до которой можно совершать по старым ТОФК
-----------------------------------------------------------------
FUNCTION GET_DATE_CHANGE_2021
  RETURN DATE;

-----------------------------------------------------------------
-- Вернем новые значения по счетам ТОФК
-----------------------------------------------------------------
FUNCTION GET_TOFK_ACCOUNTS( par_bik_old           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_OLD%type,          --БИК банка получателя (Старый)
                            par_account_old       in UBRR_DATA.UBRR_TOFK_ACCOUNTS.ACCOUNT_OLD%type,      --Счет получателя (Старый)
                            par_bik_new           out UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_NEW%type,         --БИК банка получателя (Новый)
                            par_corraccount_new   out UBRR_DATA.UBRR_TOFK_ACCOUNTS.CORRACCOUNT_NEW%type, --Кор. счет (Новый)
                            par_account_new       out UBRR_DATA.UBRR_TOFK_ACCOUNTS.ACCOUNT_NEW%type      --Счет получателя (Новый)
                           )
  RETURN BOOLEAN;

-----------------------------------------------------------------
-- проверим наличие нового БИК ТОФК в таблице соответсвия
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_BIK_NEW( par_bik_new           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_NEW%type          --БИК банка получателя (Новый)
                           )
  RETURN BOOLEAN;

-----------------------------------------------------------------
-- проверим наличие старого БИК ТОФК в таблице соответсвия
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_BIK_OLD( par_bik_old           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_OLD%type          --БИК банка получателя (Старый)
                           )
  RETURN BOOLEAN;

-----------------------------------------------------------------
-- Проверка наличия записи по счетам ТОФК в табилце соответсвия
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_ACCOUNTS( par_bik_old           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_OLD%type,     --БИК банка получателя (Старый)
                              par_account_old       in UBRR_DATA.UBRR_TOFK_ACCOUNTS.ACCOUNT_OLD%type  --Счет получателя (Старый)
                             )
  RETURN BOOLEAN;

-----------------------------------------------------------------
-- Проверка наличия записи по счетам ТОФК в табилце соответсвия
-- + сообщение
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_ACCOUNTS( par_bik_old           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_OLD%type,     --БИК банка получателя (Старый)
                              par_account_old       in UBRR_DATA.UBRR_TOFK_ACCOUNTS.ACCOUNT_OLD%type, --Счет получателя (Старый)
                              par_msg               out xxi.ups.cupsvalue%type
                             )
  RETURN BOOLEAN;

-----------------------------------------------------------------
-- Проверка платежа ТОФК на нужные реквизиты
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_PAYMENT( par_type              in number,           --БО1
                             par_payeraccount      in varchar2          --Счет плательщика
                             )
  RETURN BOOLEAN;

-----------------------------------------------------------------
-- Проверка счета получателя
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_RECEIVER_ACCA(par_bik               in varchar2,          --БИК
                                  par_cacca             in varchar2,          --Счет получателя
                                  par_err               out varchar2
                                 )
  RETURN BOOLEAN;

-----------------------------------------------------------------
-- Проверка кор. счета получателя
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_RECEIVER_CORACCA(par_bik               in varchar2,          --БИК
                                     par_сcoracca          in varchar2,          --кор. счет получателя
                                     par_err               out varchar2
                                     )
  RETURN BOOLEAN;

-----------------------------------------------------------------
-- Проведение платежа ТОФК по новым реквизитам с 01.01.2021
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_PAYBIKDT( par_type              in number,           --БО1
                              par_payeraccount      in varchar2,         --Счет плательщика
                              par_bik_new           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_NEW%type          --БИК банка получателя (Новый)
                             )
  RETURN BOOLEAN;

-----------------------------------------------------------------
-- Проведение платежа ТОФК по старым реквизитам с 01.01.2021
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_PAYBIKOLDDT( par_type              in number,           --БО1
                                 par_payeraccount      in varchar2,         --Счет плательщика
                                 par_bik_old           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_OLD%type          --БИК банка получателя (Новый)
                                )
  RETURN BOOLEAN;

-----------------------------------------------------------------
-- Проведение назначение платежа нерезедента с 01.01.2021
-----------------------------------------------------------------
FUNCTION CHECK_PAYPURP_NEREZ( par_payeraccount      in varchar2,         --Счет плательщика
                              par_ccreatstatus      in varchar2,         --Статус составителя (101)
                              par_ctrnacca          in varchar2,         --Счет получателя
                              par_purp              in varchar2,         --Назначенние платежа
                              par_msg               out xxi.ups.cupsvalue%type
                             )
  RETURN BOOLEAN;

-----------------------------------------------------------------
-- Вернем счетам ТОФК из табилце соответсвия
-----------------------------------------------------------------
FUNCTION GET_TOFK_ACCOUNTS_TRC( par_trc_num           IN  TRC.itrcNUM%TYPE,
                                par_trc_anum          IN  TRC.itrcANUM%TYPE,
                                par_bik_new           out UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_NEW%type,         --БИК банка получателя (Новый)
                                par_corraccount_new   out UBRR_DATA.UBRR_TOFK_ACCOUNTS.CORRACCOUNT_NEW%type, --Кор. счет (Новый)
                                par_account_new       out UBRR_DATA.UBRR_TOFK_ACCOUNTS.ACCOUNT_NEW%type      --Счет получателя (Новый)
                               )
  RETURN BOOLEAN;

-----------------------------------------------------------------
-- Проверка по счетам ТОФК для автомата по картотеке
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_AUTO_TRC( par_Itrcnum       in trc.ITRCNUM%type,
                              par_Itrcanum      in trc.ITRCANUM%type,
                              par_Itrctype      in trc.ITRCTYPE%type,       --БО1
                              par_Ctrcaccd      in trc.CTRCACCD%type,       --Счет плательщика
                              par_cTrcMfoA      in trc.CTRCMFOA%type,       --БИК банка получатеял
                              par_Ctrccoracca   in trc.CTRCCORACCA%type,    --К/С получателя
                              par_ctrcacca      in trc.CTRCACCA%type,       --Счет получателя
                              par_purp          in trc.CTRCPURP%type,       --Назначенние платежа
                              par_Bnamea        in trc.cTrcBnamea%type,     --Наименование банка получателя  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
                              p_err             out varchar2
                             )
  RETURN BOOLEAN;
  
-->>01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
-----------------------------------------------------------------
-- Проверка по счетам ТОФК для документы на картотеках (визуально)
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_VISUAL_TRC( par_Itrcnum       in trc.ITRCNUM%type,
                                par_Itrcanum      in trc.ITRCANUM%type,
                                par_Itrctype      in trc.ITRCTYPE%type,       --БО1
                                par_Ctrcaccd      in trc.CTRCACCD%type,       --Счет плательщика
                                par_cTrcMfoA      in trc.CTRCMFOA%type,       --БИК банка получатеял
                                par_Ctrccoracca   in trc.CTRCCORACCA%type,    --К/С получателя
                                par_ctrcacca      in trc.CTRCACCA%type,       --Счет получателя
                                par_purp          in trc.CTRCPURP%type,       --Назначенние платежа
                                par_Bnamea        in trc.cTrcBnamea%type,     --Наименование банка получателя  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
                                p_err             out varchar2
                               )
  RETURN BOOLEAN;  
--<<01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

-----------------------------------------------------------------
-- Проверка по счетам ТОФК для автомата по картотеке
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_AUTO_TRC( par_Itrcnum       in trc.ITRCNUM%type,
                              par_Itrcanum      in trc.ITRCANUM%type,
                              p_err             out varchar2
                             )
  RETURN BOOLEAN;

-----------------------------------------------------------------
-- Проверка по счетам ТОФК для
-- Документы на картотеках (визуально)
-----------------------------------------------------------------
FUNCTION VISUAL_AFFIRM_TRC(Marker_ID IN INTEGER)
  RETURN INTEGER;

-----------------------------------------------------------------
-- Проверка по счетам ТОФК для реестра
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_VISUAL_TRN( par_Itrnnum       in trn.ITRNNUM%type,
                                par_Itrnanum      in trn.ITRNANUM%type,
                                par_Itrntype      in trn.ITRNTYPE%type,       --БО1
                                par_Ctrnaccd      in trn.CTRNACCD%type,       --Счет плательщика
                                par_ctrnMfoA      in trn.CTRNMFOA%type,       --БИК банка получатеял
                                par_Ctrncoracca   in trn.CTRNCORACCA%type,    --К/С получателя
                                par_ctrnacca      in trn.CTRNACCA%type,       --Счет получателя
                                par_purp          in trn.ctrnPurp%type,       --Назначенние платежа
                                par_Bnamea        in trn.CTRNBNAMEA%type,     --Наименование банка получателя  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
                                p_err             out varchar2
                               )
  RETURN BOOLEAN;

-----------------------------------------------------------------
-- Проверка по счетам ТОФК для
-- Платежные документы (визуально)
-----------------------------------------------------------------
FUNCTION VISUAL_AFFIRM_TRN(Marker_ID IN INTEGER)
  RETURN INTEGER;

-->>01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
-----------------------------------------------------------------
-- Вернем счета ЕКС ТОФК из табилцы fog_ed807_acc
-----------------------------------------------------------------
FUNCTION GET_TOFK_CORACCA_OF_ED807(par_bik  in xxi.fog_ed807_acc.cbic%type)
  RETURN ubrr_xxi5.UBRR_CHANGE_ACCOUNTS_TOFK.T_tab_coracca;

-----------------------------------------------------------------
-- Проверим тип БИКа ТОФК для fog_ed807
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_PTTYPE_OF_ED807(par_pttype  in xxi.fog_ed807.cpttype%type)
  RETURN NUMBER;

-----------------------------------------------------------------
-- Вернем счета ЕКС ТОФК из табилцы fog_ed807_acc
-----------------------------------------------------------------
FUNCTION GET_TOFK_CORACCA_OF_ED807_PIPE(par_bik  in xxi.fog_ed807_acc.cbic%type)
  RETURN ubrr_xxi5.UBRR_CHANGE_ACCOUNTS_TOFK.T_tab_coracca pipelined;

-----------------------------------------------------------------
-- Вернем наименования банка получателя ТОФК из табилц fog_ed807
-----------------------------------------------------------------
FUNCTION GET_TOFK_BNAMEA_OF_ED807(par_bik       in xxi.FOG_ED807_ACC.cbic%type,
                                  par_сcoracca  in xxi.FOG_ED807_ACC.caccount%type
                                  )
  RETURN VARCHAR2;

-----------------------------------------------------------------
-- проверим наименования банка получателя
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_BNAMEA_OF_ED807(par_bik       in xxi.FOG_ED807_ACC.cbic%type,
                                    par_сcoracca  in xxi.FOG_ED807_ACC.caccount%type,
                                    par_bnamea    in varchar2,
                                    par_msg       out varchar2
                                    )
  RETURN BOOLEAN;

-----------------------------------------------------------------
-- Проведение платежа ТОФК по новым реквизитам с 01.01.2021
-- кредитование
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_PAYBIKKT( par_type              in number,           --БО1
                              par_bik_new           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_NEW%type          --БИК банка получателя (Новый)
                             )
  RETURN BOOLEAN;

-----------------------------------------------------------------
-- Присваиваем новые значения ТОФК для подмены из автомата
-----------------------------------------------------------------
FUNCTION UPD_TOFK_ACCOUNTS_AUTO_TRC(par_trc_num           IN  TRC.itrcNUM%TYPE,
                                    par_trc_anum          IN  TRC.itrcANUM%TYPE
                                    )
  RETURN BOOLEAN;
--<<01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

end UBRR_CHANGE_ACCOUNTS_TOFK;
/
create or replace package body ubrr_xxi5.UBRR_CHANGE_ACCOUNTS_TOFK is

/******************************************** HISTORY **********************************************\
   Дата          Автор          id         Описание
----------  ---------------  -----------  ------------------------------------------------------------
18.11.2020  Зеленко С.А.    [20-82101.1]  АБС: Изменение счетов ТОФК с 01.01.2021
01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
\******************************************** HISTORY **********************************************/

  g_type_tofk          xxi.ups.cupsvalue%type;
  g_account_tofk       xxi.ups.cupsvalue%type;
  g_msg_tofk           xxi.ups.cupsvalue%type;
  g_account_nerez      xxi.ups.cupsvalue%type;
  g_deptstatus_nerez   xxi.ups.cupsvalue%type;
  g_ctrnacca_nerez     xxi.ups.cupsvalue%type;
  g_msg_nerez          xxi.ups.cupsvalue%type;
  g_cacca              xxi.ups.cupsvalue%type;
  g_сcoracca           xxi.ups.cupsvalue%type;
  g_type_tofk_kt       xxi.ups.cupsvalue%type;  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
  g_pttype_of_ed807    xxi.ups.cupsvalue%type;  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

-----------------------------------------------------------------
-- Инициализация переменных для ТОФК
-----------------------------------------------------------------
PROCEDURE INIT_GLOBAL_ITEM
  IS
BEGIN
  g_type_tofk        := nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.TYPE'),'4|11|15|22|23');   --список БО1 для проверки
  g_account_tofk     := nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.ACCOUNT'),'401|402|403|404|405|406|407|40802|40807|40821');    --список маски счетов плательщиков для проверки
  g_msg_tofk         := PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.MSG');   --шаблон сообщения
END;

-----------------------------------------------------------------
-- Инициализация переменных для назначение платежа нерезедента
-----------------------------------------------------------------
PROCEDURE INIT_GLOBAL_NEREZ
  IS
BEGIN
  g_account_nerez        := nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.PURP_NEREZ_ACCOUNT'),'40807');           --список счёт плательщика
  g_deptstatus_nerez     := nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.PURP_NEREZ_DEPTSTATUS'),'06|08');        --список статус составителя (101)
  g_ctrnacca_nerez       := nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.PURP_NEREZ_CTRNACCA'),'40101|40302|40501........2|4060........1|40601........3|40701........1|40701........3|40503........4|40603........4|40703........4|0'); --список маски счетов получатей для проверки
  g_msg_nerez            := PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.PURP_NEREZ_MSG');
END;

-----------------------------------------------------------------
-- Инициализация переменных для счета получателя
-----------------------------------------------------------------
PROCEDURE INIT_GLOBAL_CACCA
  IS
BEGIN
  g_cacca                := nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.CACCA'),'0');  --список маски счетов получатей для проверки
END;

-----------------------------------------------------------------
-- Инициализация переменных для кор. счета
-----------------------------------------------------------------
PROCEDURE INIT_GLOBAL_СCORACCA
  IS
BEGIN
  g_сcoracca             := nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.СCORACCA'),'40102');  --список маски счетов получатей для проверки
END;

-->>01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
-----------------------------------------------------------------
-- Инициализация переменных для ТОФК, кредитование
-----------------------------------------------------------------
PROCEDURE INIT_GLOBAL_ITEM_KT
  IS
BEGIN
  g_type_tofk_kt     := nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.TYPE_KT'),'5|50|53');   --список БО1 для проверки
END;

-----------------------------------------------------------------
-- Инициализация переменных для ТОФК, тип БИК ED807
-----------------------------------------------------------------
PROCEDURE INIT_GLOBAL_PTTYPE_ED807
  IS
BEGIN
  g_pttype_of_ed807  := nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.PTTYPE_OF_ED807'),'51$|52$');
END;

--<<01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

-----------------------------------------------------------------
-- Вернем дату с котоой можно совершать платежи по новым ТОФК
-----------------------------------------------------------------
FUNCTION GET_DATE_YEAR_2021
  RETURN DATE
  IS
  l_dt   date := to_date('01.01.2021','DD.MM.YYYY');
BEGIN
  return nvl(to_date(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.DATE_YEAR_2021'),'DD.MM.YYYY'),l_dt);
EXCEPTION
  when OTHERS then
    return l_dt;
END;

-----------------------------------------------------------------
-- Вернем дату до которой можно совершать по старым ТОФК
-----------------------------------------------------------------
FUNCTION GET_DATE_CHANGE_2021
  RETURN DATE
  IS
BEGIN
  return to_date(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.DATE_CHANGE_2021'),'DD.MM.YYYY');
EXCEPTION
  when OTHERS then
    return null;
END;

-----------------------------------------------------------------
-- Вернем новые значения по счетам ТОФК из таблицы соответсвия
-----------------------------------------------------------------
FUNCTION GET_TOFK_ACCOUNTS( par_bik_old           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_OLD%type,          --БИК банка получателя (Старый)
                            par_account_old       in UBRR_DATA.UBRR_TOFK_ACCOUNTS.ACCOUNT_OLD%type,      --Счет получателя (Старый)
                            par_bik_new           out UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_NEW%type,         --БИК банка получателя (Новый)
                            par_corraccount_new   out UBRR_DATA.UBRR_TOFK_ACCOUNTS.CORRACCOUNT_NEW%type, --Кор. счет (Новый)
                            par_account_new       out UBRR_DATA.UBRR_TOFK_ACCOUNTS.ACCOUNT_NEW%type      --Счет получателя (Новый)
                           )
  RETURN BOOLEAN
  IS
  cursor cur_tofk(p_bik_old in varchar2, p_account_old in varchar2) is
  select a.bik_new,
         a.corraccount_new,
         a.account_new
    from UBRR_DATA.UBRR_TOFK_ACCOUNTS a
   where a.BIK_OLD = p_bik_old
     and a.ACCOUNT_OLD = p_account_old;
  l_res      boolean := false;
  l_acc      ubrr_data.ubrr_sud_ft_accounts.account_new%type;   -- 01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021   
BEGIN
  
  -->> 01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
  -- Проверка счета ТОФК по старым пеквизитам "Пинаев Д.Е. [19-59060.2] АБС: Изменение банковских счетов ТОФК (1часть)"
  l_acc :=	UBRR_XXI5.ubrr_trc_auto.get_sud_ft_account(p_Mfoa=>par_bik_old, p_cTrcAccA=>par_account_old);
  --<< 01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

  open cur_tofk(par_bik_old, nvl(l_acc,par_account_old)); -- 01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
  fetch cur_tofk into par_bik_new,par_corraccount_new,par_account_new;
  if cur_tofk%notfound then
   l_res := false;
  else
   l_res := true;
  end if;
  close cur_tofk;

  return l_res;

EXCEPTION
 when OTHERS then
   if cur_tofk%isopen then close cur_tofk; end if;
   return false;
END GET_TOFK_ACCOUNTS;

-----------------------------------------------------------------
-- проверим наличие нового БИК ТОФК в таблице соответсвия
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_BIK_NEW( par_bik_new           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_NEW%type          --БИК банка получателя (Новый)
                           )
  RETURN BOOLEAN
  IS
  cursor cur_tofk(p_bik_new in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_NEW%type) is
  select a.bik_new
    from UBRR_DATA.UBRR_TOFK_ACCOUNTS a
   where a.bik_new = p_bik_new;

  -->>01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
  cursor cur_tofk2(p_bik_new in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_NEW%type) is
  select a.cbic
    from xxi.FOG_ED807 a
   where regexp_like(a.cpttype,'^('||g_pttype_of_ed807||')')
     and a.cbic = p_bik_new
     and exists(select 1
                  from xxi.fog_ed807_acc aa
                 where aa.cregulationaccounttype = 'UTRA'
                   and aa.cbic = a.cbic
                );
  --<<01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

  l_bik_of_ed807     xxi.ups.cupsvalue%type := nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.BIK_OF_ED807'),'N'); --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
  l_bik_new          UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_NEW%type := '';
BEGIN

  -->>01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
  /*
  open cur_tofk(par_bik_new);
  fetch cur_tofk into l_bik_new;
  close cur_tofk;
  */
  INIT_GLOBAL_PTTYPE_ED807;

  if l_bik_of_ed807 = 'Y' then
    open cur_tofk2(par_bik_new);
    fetch cur_tofk2 into l_bik_new;
    close cur_tofk2;
  else
    open cur_tofk(par_bik_new);
    fetch cur_tofk into l_bik_new;
    close cur_tofk;
  end if;
  --<<01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

  if l_bik_new is null then
   return false;
  else
   return true;
  end if;

EXCEPTION
 when OTHERS then
   if cur_tofk%isopen then close cur_tofk; end if;
   if cur_tofk2%isopen then close cur_tofk2; end if; --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
   return false;
END CHECK_TOFK_BIK_NEW;

-----------------------------------------------------------------
-- проверим наличие старого БИК ТОФК в таблице соответсвия
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_BIK_OLD( par_bik_old           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_OLD%type          --БИК банка получателя (Старый)
                           )
  RETURN BOOLEAN
  IS
  cursor cur_tofk(p_bik_old in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_OLD%type) is
  select a.bik_old
    from UBRR_DATA.UBRR_TOFK_ACCOUNTS a
   where a.bik_old = p_bik_old;
  l_bik_old  UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_OLD%type := '';
BEGIN

  open cur_tofk(par_bik_old);
  fetch cur_tofk into l_bik_old;
  close cur_tofk;

  if l_bik_old is null then
   return false;
  else
   return true;
  end if;

EXCEPTION
 when OTHERS then
   if cur_tofk%isopen then close cur_tofk; end if;
   return false;
END CHECK_TOFK_BIK_OLD;

-----------------------------------------------------------------
-- Проверка наличия записи по счетам ТОФК в табилце соответсвия
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_ACCOUNTS( par_bik_old           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_OLD%type,     --БИК банка получателя (Старый)
                              par_account_old       in UBRR_DATA.UBRR_TOFK_ACCOUNTS.ACCOUNT_OLD%type  --Счет получателя (Старый)
                             )
  RETURN BOOLEAN
  IS
  l_bik_new           UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_NEW%type;
  l_corraccount_new   UBRR_DATA.UBRR_TOFK_ACCOUNTS.CORRACCOUNT_NEW%type;
  l_account_new       UBRR_DATA.UBRR_TOFK_ACCOUNTS.ACCOUNT_NEW%type;
BEGIN

  return GET_TOFK_ACCOUNTS( par_bik_old           => par_bik_old,
                            par_account_old       => par_account_old,
                            par_bik_new           => l_bik_new,
                            par_corraccount_new   => l_corraccount_new,
                            par_account_new       => l_account_new
                          );
END CHECK_TOFK_ACCOUNTS;

-----------------------------------------------------------------
-- Проверка наличия записи по счетам ТОФК в табилце соответсвия
-- + сообщение
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_ACCOUNTS( par_bik_old           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_OLD%type,     --БИК банка получателя (Старый)
                              par_account_old       in UBRR_DATA.UBRR_TOFK_ACCOUNTS.ACCOUNT_OLD%type, --Счет получателя (Старый)
                              par_msg               out xxi.ups.cupsvalue%type
                             )
  RETURN BOOLEAN
  IS

  l_bik_new           UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_NEW%type;
  l_corraccount_new   UBRR_DATA.UBRR_TOFK_ACCOUNTS.CORRACCOUNT_NEW%type;
  l_account_new       UBRR_DATA.UBRR_TOFK_ACCOUNTS.ACCOUNT_NEW%type;
  l_res               boolean := false;

  --заменим значения в шаблоне текста
  FUNCTION PARSE_MSG( par_bik_old           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_OLD%type,         --БИК банка получателя (Старый)
                      par_account_old       in UBRR_DATA.UBRR_TOFK_ACCOUNTS.ACCOUNT_OLD%type,     --Счет получателя (Старый)
                      par_bik_new           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_NEW%type,         --БИК банка получателя (Новый)
                      par_corraccount_new   in UBRR_DATA.UBRR_TOFK_ACCOUNTS.CORRACCOUNT_NEW%type, --Кор. счет (Новый)
                      par_account_new       in UBRR_DATA.UBRR_TOFK_ACCOUNTS.ACCOUNT_NEW%type      --Счет получателя (Новый)
                   )
  RETURN VARCHAR2
    IS
    l_res  xxi.ups.cupsvalue%type := '';
  BEGIN
    l_res := g_msg_tofk;
    if l_res is not null then
      l_res := replace(l_res,'$BIK_OLD$',par_bik_old);
      l_res := replace(l_res,'$ACCOUNT_OLD$',par_account_old);
      l_res := replace(l_res,'$BIK_NEW$',par_bik_new);
      l_res := replace(l_res,'$CORRACCOUNT_NEW$',par_corraccount_new);
      l_res := replace(l_res,'$ACCOUNT_NEW$',par_account_new);
    end if;
    return l_res;
  EXCEPTION
    when OTHERS then
      return l_res;
  END;
  --

BEGIN
  INIT_GLOBAL_ITEM;

  l_res := GET_TOFK_ACCOUNTS( par_bik_old           => par_bik_old,
                              par_account_old       => par_account_old,
                              par_bik_new           => l_bik_new,
                              par_corraccount_new   => l_corraccount_new,
                              par_account_new       => l_account_new
                            );

  if l_res then
    par_msg := PARSE_MSG( par_bik_old           => par_bik_old,
                          par_account_old       => par_account_old,
                          par_bik_new           => l_bik_new,
                          par_corraccount_new   => l_corraccount_new,
                          par_account_new       => l_account_new
                         );
  else
    par_msg := '';
  end if;

  return l_res;
END CHECK_TOFK_ACCOUNTS;

-----------------------------------------------------------------
-- Проверка платежа ТОФК на нужные реквизиты
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_PAYMENT( par_type              in number,           --БО1
                             par_payeraccount      in varchar2          --Счет плательщика
                             )
  RETURN BOOLEAN
  IS
  l_res               boolean := false;
BEGIN
  INIT_GLOBAL_ITEM;

  --проверим значения
  if regexp_like(par_type,'^('||g_type_tofk||')') and regexp_like(par_payeraccount,'^('||g_account_tofk||')') and trunc(ubrr_xxi5.ubrr_dtime.get_sysdate) >= ubrr_xxi5.ubrr_change_accounts_tofk.get_date_year_2021 then
    l_res := true;
  end if;

  return l_res;
EXCEPTION
 when OTHERS then
   return false;
END CHECK_TOFK_PAYMENT;

-----------------------------------------------------------------
-- Проверка счета получателя
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_RECEIVER_ACCA(par_bik               in varchar2,          --БИК
                                  par_cacca             in varchar2,          --Счет получателя
                                  par_err               out varchar2
                                 )
  RETURN BOOLEAN
  IS
  l_res               boolean := false;
BEGIN
  INIT_GLOBAL_CACCA;

  --проверим значения
  IF not regexp_like(par_cacca,'^('||g_cacca||')')  THEN
    par_err := 'Для БИК '|| par_bik ||' формат Л/С получателя не соответствуют маске '||replace(g_cacca,'|','%, ')||'%';
    return true;
  END IF;

  IF not ubrr_xxi5.ubrr_trc_auto.is_acc(par_cacca) THEN
    par_err := 'Для БИК '||par_bik ||' формат Л/С получателя не соответствуют, должны быть только числа';
    return true;
  END IF;

  return l_res;
EXCEPTION
 when OTHERS then
   return false;
END CHECK_TOFK_RECEIVER_ACCA;

-----------------------------------------------------------------
-- Проверка кор. счета получателя
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_RECEIVER_CORACCA(par_bik               in varchar2,          --БИК
                                     par_сcoracca          in varchar2,          --кор. счет получателя
                                     par_err               out varchar2
                                     )
  RETURN BOOLEAN
  IS
  l_res               boolean := false;
BEGIN
  INIT_GLOBAL_СCORACCA;

  --проверим значения
  IF not regexp_like(par_сcoracca,'^('||g_сcoracca||')')  THEN
    par_err := 'Для БИК '|| par_bik ||' формат К/С получателя не соответствуют маске '||replace(g_сcoracca,'|','%, ')||'%';
    return true;
  END IF;

  IF not ubrr_xxi5.ubrr_trc_auto.is_acc(par_сcoracca) or LENGTH(par_сcoracca) <> 20 THEN
    par_err := 'Для БИК '|| par_bik ||' формат К/С получателя не соответствуют, должны быть только числа и количество символов равно 20';
    return true;
  END IF;

  return l_res;
EXCEPTION
 when OTHERS then
   return false;
END CHECK_TOFK_RECEIVER_CORACCA;

-----------------------------------------------------------------
-- Проведение платежа ТОФК по новым реквизитам с 01.01.2021
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_PAYBIKDT( par_type              in number,           --БО1
                              par_payeraccount      in varchar2,         --Счет плательщика
                              par_bik_new           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_NEW%type          --БИК банка получателя (Новый)
                             )
  RETURN BOOLEAN
  IS
  l_res               boolean := false;
BEGIN
  --проВерим параметры платежа и текущую дату
  if ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_payment(par_type         => par_type,
                                                            par_payeraccount => par_payeraccount) then

    --проверим наличие БИКа ТОФК
    if ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_bik_new(par_bik_new => par_bik_new) then
      l_res := true;
    end if;

  end if;

  return l_res;
EXCEPTION
 when OTHERS then
   return false;
END CHECK_TOFK_PAYBIKDT;

-----------------------------------------------------------------
-- Проведение платежа ТОФК по старым реквизитам с 01.01.2021
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_PAYBIKOLDDT( par_type              in number,           --БО1
                                 par_payeraccount      in varchar2,         --Счет плательщика
                                 par_bik_old           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_OLD%type          --БИК банка получателя (Новый)
                                )
  RETURN BOOLEAN
  IS
  l_res               boolean := false;
BEGIN
  --проВерим параметры платежа и текущую дату
  if ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_payment(par_type         => par_type,
                                                            par_payeraccount => par_payeraccount) then

    --проверим наличие БИКа ТОФК
    if ubrr_xxi5.ubrr_change_accounts_tofk.CHECK_TOFK_BIK_OLD(par_bik_old => par_bik_old) then
      l_res := true;
    end if;

  end if;

  return l_res;
EXCEPTION
 when OTHERS then
   return false;
END CHECK_TOFK_PAYBIKOLDDT;

-----------------------------------------------------------------
-- Проведение назначение платежа нерезедента с 01.01.2021
-----------------------------------------------------------------
FUNCTION CHECK_PAYPURP_NEREZ( par_payeraccount      in varchar2,         --Счет плательщика
                              par_ccreatstatus      in varchar2,         --Статус составителя (101)
                              par_ctrnacca          in varchar2,         --Счет получателя
                              par_purp              in varchar2,         --Назначенние платежа
                              par_msg               out xxi.ups.cupsvalue%type
                             )
  RETURN BOOLEAN
  IS
  l_res               boolean := false;
BEGIN
  INIT_GLOBAL_NEREZ;

  --проверим что дата наступиса
  if trunc(ubrr_xxi5.ubrr_dtime.get_sysdate) >= ubrr_xxi5.ubrr_change_accounts_tofk.get_date_year_2021 then

    --проверим условия, что это наш платеж
    if regexp_like(par_payeraccount,'^('||g_account_nerez||')') and regexp_like(par_ccreatstatus,'^('||g_deptstatus_nerez||')') and regexp_like(par_ctrnacca,'^('||g_ctrnacca_nerez||')') then

      --проверим наличие нужных символов
      if nvl(par_purp,' ') not like '///__;%///%' or regexp_substr(substr(par_purp,4,2),'[^A-Z]') is not null then
        l_res := true;
        par_msg := g_msg_nerez;
      end if;

    end if;

  end if;

  return l_res;
EXCEPTION
 when OTHERS then
   return false;
END CHECK_PAYPURP_NEREZ;

-----------------------------------------------------------------
-- Вернем счетам ТОФК из табилце соответсвия
-----------------------------------------------------------------
FUNCTION GET_TOFK_ACCOUNTS_TRC( par_trc_num           IN  TRC.itrcNUM%TYPE,
                                par_trc_anum          IN  TRC.itrcANUM%TYPE,
                                par_bik_new           out UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_NEW%type,         --БИК банка получателя (Новый)
                                par_corraccount_new   out UBRR_DATA.UBRR_TOFK_ACCOUNTS.CORRACCOUNT_NEW%type, --Кор. счет (Новый)
                                par_account_new       out UBRR_DATA.UBRR_TOFK_ACCOUNTS.ACCOUNT_NEW%type      --Счет получателя (Новый)
                               )
  RETURN BOOLEAN
  IS

  CURSOR cTRC( p_trc_num  IN  TRC.itrcNUM%TYPE, p_trc_anum   IN  TRC.itrcANUM%TYPE ) IS
  SELECT TRC.cTRCAccD,
         TRC.iTRCType,
         TRC.cTrcMfoA,
         TRC.CTRCCORACCA,
         TRC.cTrcACCA,
         TRC.cTrcPurp
    FROM xxi."trc" TRC
   WHERE itrcNUM = p_trc_num
     AND itrcANUM = p_trc_anum;
  rTrc                cTrc%ROWTYPE;
  l_res               boolean := FALSE;

BEGIN

  open cTRC(par_trc_num,par_trc_anum);
  fetch cTRC into rTrc;
  close cTRC;

  IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_payment(par_type         => rTrc.Itrctype,
                                                            par_payeraccount => rTrc.cTrcAccD) THEN

    --IF trunc(ubrr_xxi5.ubrr_dtime.get_sysdate) >= ubrr_xxi5.ubrr_change_accounts_tofk.get_date_change_2021 THEN --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
    IF trunc(ubrr_xxi5.ubrr_dtime.get_sysdate) >= ubrr_xxi5.ubrr_change_accounts_tofk.get_date_year_2021 THEN

      l_res := GET_TOFK_ACCOUNTS( par_bik_old           => rTrc.Ctrcmfoa,
                                  par_account_old       => rTrc.Ctrcacca,
                                  par_bik_new           => par_bik_new,
                                  par_corraccount_new   => par_corraccount_new,
                                  par_account_new       => par_account_new
                                 );
    END IF;
  END IF;

  return l_res;
EXCEPTION
 when OTHERS then
   return false;
END GET_TOFK_ACCOUNTS_TRC;

-----------------------------------------------------------------
-- Проверка по счетам ТОФК для автомата по картотеке
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_AUTO_TRC( par_Itrcnum       in trc.ITRCNUM%type,
                              par_Itrcanum      in trc.ITRCANUM%type,
                              par_Itrctype      in trc.ITRCTYPE%type,       --БО1
                              par_Ctrcaccd      in trc.CTRCACCD%type,       --Счет плательщика
                              par_cTrcMfoA      in trc.CTRCMFOA%type,       --БИК банка получатеял
                              par_Ctrccoracca   in trc.CTRCCORACCA%type,    --К/С получателя
                              par_ctrcacca      in trc.CTRCACCA%type,       --Счет получателя
                              par_purp          in trc.CTRCPURP%type,       --Назначенние платежа
                              par_Bnamea        in trc.cTrcBnamea%type,     --Наименование банка получателя  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
                              p_err             out varchar2
                             )
  RETURN BOOLEAN
  IS

  cursor cur_dept_info(p_ITrcNum trc.ITRCNUM%type, p_ITrcANum trc.ITRCANUM%type) is
  Select cCreatStatus
    From TRC_DEPT_INFO
   Where INUM = p_ITrcNum
     And IANUM = p_ITrcANum;

  l_CreatStatus   TRC_DEPT_INFO.CCREATSTATUS%type := Null;
  l_msg           xxi.ups.cupsvalue%type;
BEGIN

  --необходимость проверки назначения
  IF NVL(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.PURP_NEREZ_CHECK'),'N') = 'Y' THEN

    --Статус составителя (101)
    OPEN cur_dept_info(par_Itrcnum,par_Itrcanum);
    FETCH cur_dept_info INTO l_CreatStatus;
    CLOSE cur_dept_info;

    --проверка назначение платежа нерезидента
    IF ubrr_xxi5.ubrr_change_accounts_tofk.check_paypurp_nerez(par_payeraccount => par_Ctrcaccd,
                                                               par_ccreatstatus => l_CreatStatus,
                                                               par_ctrnacca     => par_ctrcacca,
                                                               par_purp         => par_purp,
                                                               par_msg          => l_msg) THEN
      p_err := substr(l_msg,1,238);
      return true;
    END IF;
  END IF;

  --провера ТОФК новых
  IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_paybikdt(par_type        => par_Itrctype,
                                                             par_payeraccount => par_Ctrcaccd,
                                                             par_bik_new      => par_cTrcMfoA) THEN

    --Проверка счета получателя
    IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_receiver_acca(par_bik   => par_cTrcMfoA,
                                                                    par_cacca => par_ctrcacca,
                                                                    par_err   => p_err) THEN

      return true;
    END IF;

    --Проверка кор. счета получателя
    IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_receiver_coracca(par_bik      => par_cTrcMfoA,
                                                                       par_сcoracca => par_Ctrccoracca,
                                                                       par_err      => p_err) THEN

      return true;
    END IF;

    -->>01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
		--Проверка наименование банка по ТОФК
    IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_bnamea_of_ed807(par_bik      => par_cTrcMfoA,
                                                                      par_сcoracca => par_Ctrccoracca,
                                                                      par_bnamea   => par_Bnamea,
                                                                      par_msg      => l_msg) THEN

      p_err := substr('Необходимо изменить наименование банка получателя на "'||l_msg||'"',1,238);
      return true;
    END IF;
    --<<01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

  END IF;

  return false;

EXCEPTION
 when OTHERS then
   return false;
END CHECK_TOFK_AUTO_TRC;

-----------------------------------------------------------------
-- Проверка по счетам ТОФК для автомата по картотеке
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_AUTO_TRC( par_Itrcnum       in trc.ITRCNUM%type,
                              par_Itrcanum      in trc.ITRCANUM%type,
                              p_err             out varchar2
                             )
  RETURN BOOLEAN
  IS
  CURSOR cTRC( p_trc_num  IN  TRC.itrcNUM%TYPE, p_trc_anum   IN  TRC.itrcANUM%TYPE ) IS
  SELECT TRC.itrcNUM,
         TRC.itrcANUM,
         TRC.cTRCAccD,
         TRC.iTRCType,
         TRC.cTrcMfoA,
         TRC.CTRCCORACCA,
         TRC.cTrcACCA,
         TRC.cTrcPurp,
         TRC.cTrcBnamea  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
    FROM xxi."trc" TRC
   WHERE itrcNUM = p_trc_num
     AND itrcANUM = p_trc_anum;
  rTrc                cTrc%ROWTYPE;
BEGIN

  open cTRC(par_Itrcnum,par_Itrcanum);
  fetch cTRC into rTrc;
  close cTRC;

  return ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_auto_trc( par_itrcnum       => rTrc.Itrcnum,
                                                                  par_itrcanum      => rTrc.Itrcanum,
                                                                  par_itrctype      => rTrc.Itrctype,
                                                                  par_ctrcaccd      => rTrc.Ctrcaccd,
                                                                  par_ctrcmfoa      => rTrc.cTrcMfoA,
                                                                  par_ctrccoracca   => rTrc.Ctrccoracca,
                                                                  par_ctrcacca      => rTrc.cTrcAccA,
                                                                  par_purp          => rTrc.cTrcPurp,
                                                                  par_Bnamea        => rTrc.cTrcBnamea,  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
                                                                  p_err             => p_err
                                                                  );

EXCEPTION
 when OTHERS then
   return false;
END CHECK_TOFK_AUTO_TRC;

-->>01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
-----------------------------------------------------------------
-- Проверка по счетам ТОФК для документы на картотеках (визуально)
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_VISUAL_TRC( par_Itrcnum       in trc.ITRCNUM%type,
                                par_Itrcanum      in trc.ITRCANUM%type,
                                par_Itrctype      in trc.ITRCTYPE%type,       --БО1
                                par_Ctrcaccd      in trc.CTRCACCD%type,       --Счет плательщика
                                par_cTrcMfoA      in trc.CTRCMFOA%type,       --БИК банка получатеял
                                par_Ctrccoracca   in trc.CTRCCORACCA%type,    --К/С получателя
                                par_ctrcacca      in trc.CTRCACCA%type,       --Счет получателя
                                par_purp          in trc.CTRCPURP%type,       --Назначенние платежа
                                par_Bnamea        in trc.cTrcBnamea%type,     --Наименование банка получателя  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
                                p_err             out varchar2
                               )
  RETURN BOOLEAN
  IS

  cursor cur_dept_info(p_ITrcNum trc.ITRCNUM%type, p_ITrcANum trc.ITRCANUM%type) is
  Select cCreatStatus
    From TRC_DEPT_INFO
   Where INUM = p_ITrcNum
     And IANUM = p_ITrcANum;

  l_CreatStatus   TRC_DEPT_INFO.CCREATSTATUS%type := Null;
  l_msg           xxi.ups.cupsvalue%type;
BEGIN
  --провера ТОФК старых
  IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_payment(par_type         => par_Itrctype,
                                                            par_payeraccount => par_Ctrcaccd) THEN

    if ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_accounts(par_bik_old     => par_cTrcMfoA,
                                                               par_account_old => par_ctrcacca,
                                                               par_msg         => l_msg) THEN

      IF trunc(ubrr_xxi5.ubrr_dtime.get_sysdate) >= ubrr_xxi5.ubrr_change_accounts_tofk.get_date_change_2021 THEN
        p_err := substr(l_msg,1,218) ||' Необходимо изменить реквизиты.';
        return true;
      END IF;

    end if;
  END IF;

  --необходимость проверки назначения
  IF NVL(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.PURP_NEREZ_CHECK'),'N') = 'Y' THEN

    --Статус составителя (101)
    OPEN cur_dept_info(par_Itrcnum,par_Itrcanum);
    FETCH cur_dept_info INTO l_CreatStatus;
    CLOSE cur_dept_info;

    --проверка назначение платежа нерезидента
    IF ubrr_xxi5.ubrr_change_accounts_tofk.check_paypurp_nerez(par_payeraccount => par_Ctrcaccd,
                                                               par_ccreatstatus => l_CreatStatus,
                                                               par_ctrnacca     => par_ctrcacca,
                                                               par_purp         => par_purp,
                                                               par_msg          => l_msg) THEN
      p_err := substr(l_msg,1,238);
      return true;
    END IF;
  END IF;

  --провера ТОФК новых
  IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_paybikdt(par_type        => par_Itrctype,
                                                             par_payeraccount => par_Ctrcaccd,
                                                             par_bik_new      => par_cTrcMfoA) THEN

    --Проверка счета получателя
    IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_receiver_acca(par_bik   => par_cTrcMfoA,
                                                                    par_cacca => par_ctrcacca,
                                                                    par_err   => p_err) THEN

      return true;
    END IF;

    --Проверка кор. счета получателя
    IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_receiver_coracca(par_bik      => par_cTrcMfoA,
                                                                       par_сcoracca => par_Ctrccoracca,
                                                                       par_err      => p_err) THEN

      return true;
    END IF;

    -->>01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
		--Проверка наименование банка по ТОФК
    IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_bnamea_of_ed807(par_bik      => par_cTrcMfoA,
                                                                      par_сcoracca => par_Ctrccoracca,
                                                                      par_bnamea   => par_Bnamea,
                                                                      par_msg      => l_msg) THEN

      p_err := substr('Необходимо изменить наименование банка получателя на "'||l_msg||'"',1,238);
      return true;
    END IF;
    --<<01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

  END IF;

  return false;

EXCEPTION
 when OTHERS then
   return false;
END CHECK_TOFK_VISUAL_TRC;
--<<01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

-----------------------------------------------------------------
-- Проверка по счетам ТОФК для
-- Документы на картотеках (визуально)
-----------------------------------------------------------------
FUNCTION VISUAL_AFFIRM_TRC(Marker_ID IN INTEGER)
  RETURN INTEGER
  IS

  CURSOR curDocs IS
  SELECT T.itrcNUM,
         T.itrcANUM,
         T.cTRCAccD,
         T.iTRCType,
         T.cTrcMfoA,
         T.CTRCCORACCA,
         T.cTrcACCA,
         T.cTrcPurp,
         T.cTrcBnamea,  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
         T.RowID
    FROM xxi."trc" T, MRK M
   WHERE T.RowID = M.rMRKrowid
     AND M.iMRKmarkerid = Marker_ID;

  l_Docs_Cnt   INTEGER := 0;
  l_msg        xxi.ups.cupsvalue%type;
  l_process    VARCHAR2(30) := 'CARD';
BEGIN
  FOR cvDoc IN curDocs
    LOOP
      IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_visual_trc( par_itrcnum       => cvDoc.Itrcnum,
                                                                    par_itrcanum      => cvDoc.Itrcanum,
                                                                    par_itrctype      => cvDoc.Itrctype,
                                                                    par_ctrcaccd      => cvDoc.Ctrcaccd,
                                                                    par_ctrcmfoa      => cvDoc.cTrcMfoA,
                                                                    par_ctrccoracca   => cvDoc.Ctrccoracca,
                                                                    par_ctrcacca      => cvDoc.cTrcAccA,
                                                                    par_purp          => cvDoc.cTrcPurp,
                                                                    par_Bnamea        => cvDoc.cTrcBnamea,  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
                                                                    p_err             => l_msg
                                                                    ) THEN

        MBUNCH.Put(l_process, TO_CHAR(cvDoc.iTRCnum) || ',' || TO_CHAR(cvDoc.iTRCanum), substr(l_msg,1,256));
        DELETE FROM MRK WHERE rMRKrowid = cvDoc.rowid;
      ELSE
        l_Docs_Cnt := l_Docs_Cnt + 1;
        MBUNCH.Kill(l_process, TO_CHAR(cvDoc.iTRCnum) || ',' || TO_CHAR(cvDoc.iTRCanum));
      END IF;
    END LOOP;

  DBMS_TRANSACTION.Commit();

  RETURN l_Docs_Cnt;
END VISUAL_AFFIRM_TRC;


-----------------------------------------------------------------
-- Проверка по счетам ТОФК для реестра
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_VISUAL_TRN( par_Itrnnum       in trn.ITRNNUM%type,
                                par_Itrnanum      in trn.ITRNANUM%type,
                                par_Itrntype      in trn.ITRNTYPE%type,       --БО1
                                par_Ctrnaccd      in trn.CTRNACCD%type,       --Счет плательщика
                                par_ctrnMfoA      in trn.CTRNMFOA%type,       --БИК банка получатеял
                                par_Ctrncoracca   in trn.CTRNCORACCA%type,    --К/С получателя
                                par_ctrnacca      in trn.CTRNACCA%type,       --Счет получателя
                                par_purp          in trn.ctrnPurp%type,       --Назначенние платежа
                                par_Bnamea        in trn.CTRNBNAMEA%type,     --Наименование банка получателя  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
                                p_err             out varchar2
                               )
  RETURN BOOLEAN
  IS

  cursor cur_dept_info(p_ItrnNum trn.ItrnNUM%type, p_ItrnANum trn.ItrnANUM%type) is
  Select cCreatStatus
    From TRN_DEPT_INFO
   Where INUM = p_ItrnNum
     And IANUM = p_ItrnANum;

  l_CreatStatus   TRN_DEPT_INFO.CCREATSTATUS%type := Null;
  l_msg           xxi.ups.cupsvalue%type;
BEGIN
  --провера ТОФК старых
  IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_payment(par_type         => par_Itrntype,
                                                            par_payeraccount => par_Ctrnaccd) THEN

    if ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_accounts(par_bik_old     => par_ctrnMfoA,
                                                               par_account_old => par_ctrnacca,
                                                               par_msg         => l_msg) THEN

      IF trunc(ubrr_xxi5.ubrr_dtime.get_sysdate) >= ubrr_xxi5.ubrr_change_accounts_tofk.get_date_change_2021 THEN
        p_err := substr(l_msg,1,218) ||' Необходимо изменить реквизиты.';
        return true;
      END IF;

    end if;
  END IF;

    --необходимость проверки назначения
  IF NVL(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.PURP_NEREZ_CHECK'),'N') = 'Y' THEN
    --Статус составителя (101)
    OPEN cur_dept_info(par_Itrnnum,par_Itrnanum);
    FETCH cur_dept_info INTO l_CreatStatus;
    CLOSE cur_dept_info;

    --проверка назначение платежа нерезидента
    IF ubrr_xxi5.ubrr_change_accounts_tofk.check_paypurp_nerez(par_payeraccount => par_Ctrnaccd,
                                                               par_ccreatstatus => l_CreatStatus,
                                                               par_ctrnacca     => par_ctrnacca,
                                                               par_purp         => par_purp,
                                                               par_msg          => l_msg) THEN
      p_err := substr(l_msg,1,238);
      return true;
    END IF;
  END IF;

  --провера ТОФК новых
  IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_paybikdt(par_type        => par_Itrntype,
                                                             par_payeraccount => par_Ctrnaccd,
                                                             par_bik_new      => par_ctrnMfoA) THEN

    --Проверка счета получателя
    IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_receiver_acca(par_bik   => par_ctrnMfoA,
                                                                    par_cacca => par_ctrnacca,
                                                                    par_err   => p_err) THEN

      return true;
    END IF;

    --Проверка кор. счета получателя
    IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_receiver_coracca(par_bik      => par_ctrnMfoA,
                                                                       par_сcoracca => par_Ctrncoracca,
                                                                       par_err      => p_err) THEN

      return true;
    END IF;

    -->>01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
		--Проверка наименование банка по ТОФК
    IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_bnamea_of_ed807(par_bik      => par_ctrnMfoA,
                                                                      par_сcoracca => par_Ctrncoracca,
                                                                      par_bnamea   => par_Bnamea,
                                                                      par_msg      => l_msg) THEN

      p_err := substr('Необходимо изменить наименование банка получателя на "'||l_msg||'"',1,238);
      return true;
    END IF;
    --<<01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

  END IF;

  return false;

EXCEPTION
 when OTHERS then
   return false;
END CHECK_TOFK_VISUAL_TRN;

-----------------------------------------------------------------
-- Проверка по счетам ТОФК для
-- Платежные документы (визуально)
-----------------------------------------------------------------
FUNCTION VISUAL_AFFIRM_TRN(Marker_ID IN INTEGER)
  RETURN INTEGER
  IS

  CURSOR curDocs IS
  SELECT T.itrnnum,
         T.itrnanum,
         T.ctrnaccd,
         T.itrntype,
         T.ctrnMfoA,
         T.ctrncoracca,
         T.ctrnacca,
         T.ctrnPurp,
         T.ctrnbnamea,  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
         T.RowID
    FROM xxi."trn" T, MRK M
   WHERE T.RowID = M.rMRKrowid
     AND M.iMRKmarkerid = Marker_ID;

  l_Docs_Cnt   INTEGER := 0;
  l_msg        xxi.ups.cupsvalue%type;
  l_process    VARCHAR2(30) := 'VISUAL_AFFIRM';
BEGIN
  FOR cvDoc IN curDocs
    LOOP
      IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_visual_trn( par_itrnnum       => cvDoc.Itrnnum,
                                                                    par_itrnanum      => cvDoc.Itrnanum,
                                                                    par_itrntype      => cvDoc.Itrntype,
                                                                    par_ctrnaccd      => cvDoc.Ctrnaccd,
                                                                    par_ctrnmfoa      => cvDoc.ctrnMfoA,
                                                                    par_ctrncoracca   => cvDoc.Ctrncoracca,
                                                                    par_ctrnacca      => cvDoc.ctrnAccA,
                                                                    par_purp          => cvDoc.ctrnPurp,
                                                                    par_Bnamea        => cvDoc.Ctrnbnamea,  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
                                                                    p_err             => l_msg
                                                                    ) THEN

        MBUNCH.Put(l_process, TO_CHAR(cvDoc.itrnnum) || ',' || TO_CHAR(cvDoc.itrnanum), substr(l_msg,1,256));
        DELETE FROM MRK WHERE rMRKrowid = cvDoc.rowid;
      ELSE
        l_Docs_Cnt := l_Docs_Cnt + 1;
        MBUNCH.Kill(l_process, TO_CHAR(cvDoc.itrnnum) || ',' || TO_CHAR(cvDoc.itrnanum));
      END IF;
    END LOOP;

  DBMS_TRANSACTION.Commit();

  RETURN l_Docs_Cnt;
END VISUAL_AFFIRM_TRN;

-->>01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
-----------------------------------------------------------------
-- Вернем счета ЕКС ТОФК из табилцы fog_ed807_acc
-----------------------------------------------------------------
FUNCTION GET_TOFK_CORACCA_OF_ED807(par_bik  in xxi.fog_ed807_acc.cbic%type)
  RETURN ubrr_xxi5.UBRR_CHANGE_ACCOUNTS_TOFK.T_tab_coracca
  IS
  cursor cur_c0(p_bik  in fog_ed807_acc.cbic%type) is
  select a.caccount
    from xxi.fog_ed807_acc a
   where a.cregulationaccounttype = 'UTRA'
     and a.cbic = p_bik
     and exists(select 1 from FOG_ED807 t
                  where regexp_like(t.cpttype,'^('||g_pttype_of_ed807||')')
                    and t.cbic = a.cbic
                )
   order by a.caccount;

  l_tab_coracca      ubrr_xxi5.UBRR_CHANGE_ACCOUNTS_TOFK.T_tab_coracca := ubrr_xxi5.UBRR_CHANGE_ACCOUNTS_TOFK.T_tab_coracca();
BEGIN
  INIT_GLOBAL_PTTYPE_ED807;

  open cur_c0(par_bik);
  fetch cur_c0 bulk collect into l_tab_coracca;
  close cur_c0;

  RETURN l_tab_coracca;

EXCEPTION
  when OTHERS then
    l_tab_coracca := ubrr_xxi5.UBRR_CHANGE_ACCOUNTS_TOFK.T_tab_coracca();
    RETURN l_tab_coracca;
END GET_TOFK_CORACCA_OF_ED807;

-----------------------------------------------------------------
-- Проверим тип БИКа ТОФК для fog_ed807
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_PTTYPE_OF_ED807(par_pttype  in xxi.fog_ed807.cpttype%type)
  RETURN NUMBER
  IS
BEGIN
  INIT_GLOBAL_PTTYPE_ED807;

  return sys.diutil.bool_to_int(regexp_like(par_pttype,'^('||g_pttype_of_ed807||')'));
EXCEPTION
  when OTHERS then
    RETURN 0;
END CHECK_TOFK_PTTYPE_OF_ED807;

-----------------------------------------------------------------
-- Вернем счета ЕКС ТОФК из табилцы fog_ed807_acc
-----------------------------------------------------------------
FUNCTION GET_TOFK_CORACCA_OF_ED807_PIPE(par_bik  in xxi.fog_ed807_acc.cbic%type)
  RETURN ubrr_xxi5.UBRR_CHANGE_ACCOUNTS_TOFK.T_tab_coracca pipelined
  IS

  l_tab_coracca      ubrr_xxi5.UBRR_CHANGE_ACCOUNTS_TOFK.T_tab_coracca := ubrr_xxi5.UBRR_CHANGE_ACCOUNTS_TOFK.T_tab_coracca();
BEGIN

  l_tab_coracca := ubrr_xxi5.ubrr_change_accounts_tofk.get_tofk_coracca_of_ed807(par_bik => par_bik);

  FOR l_idx IN 1 .. l_tab_coracca.COUNT
    LOOP
      pipe row (l_tab_coracca(l_idx));
    END LOOP;

EXCEPTION
  when NO_DATA_NEEDED then
    RETURN;
  when OTHERS then
    RETURN;
END GET_TOFK_CORACCA_OF_ED807_PIPE;

-----------------------------------------------------------------
-- Вернем наименования банка получателя ТОФК из табилц fog_ed807
-----------------------------------------------------------------
FUNCTION GET_TOFK_BNAMEA_OF_ED807(par_bik       in xxi.FOG_ED807_ACC.cbic%type,
                                  par_сcoracca  in xxi.FOG_ED807_ACC.caccount%type
                                  )
  RETURN VARCHAR2
  IS
  cursor cur_c0(p_bik      in xxi.FOG_ED807_ACC.cbic%type,
                p_caccount in xxi.FOG_ED807_ACC.caccount%type,
                p_r1       in xxi.ups.cupsvalue%type,
                p_r2       in xxi.ups.cupsvalue%type,
                p_r3       in xxi.ups.cupsvalue%type) is
  select substr(a.cnamep
                ||p_r1||tt.cnamep
                ||p_r2||tt.ctnp
                ||p_r3||tt.cnnp,
                1,
                150) as bname
    from xxi.FOG_ED807_ACC t, xxi.FOG_ED807 tt, xxi.FOG_ED807 a
    where t.cbic = p_bik
      and t.CACCOUNT = p_caccount
      and t.CREGULATIONACCOUNTTYPE = 'UTRA'
      and t.cbic = tt.cbic
      and regexp_like(tt.cpttype,'^('||g_pttype_of_ed807||')')
      and t.caccountcbrbic = a.cbic;

  l_bnamea           VARCHAR2(150) := '';
  --разделители
  l_r1               xxi.ups.cupsvalue%type := PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.BNAMEA_OF_ED807_R1');
  l_r2               xxi.ups.cupsvalue%type := PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.BNAMEA_OF_ED807_R2');
  l_r3               xxi.ups.cupsvalue%type := PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.BNAMEA_OF_ED807_R3');

BEGIN
  INIT_GLOBAL_PTTYPE_ED807;

  open cur_c0(par_bik,par_сcoracca,l_r1,l_r2,l_r3);
  fetch cur_c0 into l_bnamea;
  close cur_c0;

  RETURN l_bnamea;

EXCEPTION
  when OTHERS then
    if cur_c0%isopen then close cur_c0; end if;
    RETURN l_bnamea;
END GET_TOFK_BNAMEA_OF_ED807;

-----------------------------------------------------------------
-- проверим наименования банка получателя
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_BNAMEA_OF_ED807(par_bik       in xxi.FOG_ED807_ACC.cbic%type,
                                    par_сcoracca  in xxi.FOG_ED807_ACC.caccount%type,
                                    par_bnamea    in varchar2,
                                    par_msg       out varchar2
                                    )
  RETURN BOOLEAN
  IS
  l_res               boolean := false;
BEGIN

  par_msg := ubrr_xxi5.ubrr_change_accounts_tofk.get_tofk_bnamea_of_ed807(par_bik      => par_bik,
                                                                          par_сcoracca => par_сcoracca
                                                                          );

  if par_msg is not null and upper(replace(replace(replace(par_msg,',',''),'.',''),' ','')) <> upper(replace(replace(replace( par_bnamea,',',''),'.',''),' ','')) then
   l_res := true;
  end if;

  return l_res;
EXCEPTION
 when OTHERS then
   return l_res;
END CHECK_TOFK_BNAMEA_OF_ED807;

-----------------------------------------------------------------
-- Проведение платежа ТОФК по новым реквизитам с 01.01.2021
-- кредитование
-----------------------------------------------------------------
FUNCTION CHECK_TOFK_PAYBIKKT( par_type              in number,           --БО1
                              par_bik_new           in UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_NEW%type          --БИК банка получателя (Новый)
                             )
  RETURN BOOLEAN
  IS
  l_res               boolean := false;
BEGIN
  INIT_GLOBAL_ITEM_KT;

  --проверим наличие БИКа ТОФК и текущую дату
  if ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_bik_new(par_bik_new => par_bik_new)
    and regexp_like(par_type,'^('||g_type_tofk_kt||')')
    and trunc(ubrr_xxi5.ubrr_dtime.get_sysdate) >= ubrr_xxi5.ubrr_change_accounts_tofk.get_date_year_2021 then

    l_res := true;
  end if;

  return l_res;
EXCEPTION
 when OTHERS then
   return false;
END CHECK_TOFK_PAYBIKKT;

-----------------------------------------------------------------
-- Присваиваем новые значения ТОФК для подмены из автомата
-----------------------------------------------------------------
FUNCTION UPD_TOFK_ACCOUNTS_AUTO_TRC(par_trc_num           IN  TRC.itrcNUM%TYPE,
                                    par_trc_anum          IN  TRC.itrcANUM%TYPE
                                    )
  RETURN BOOLEAN
  IS

  CURSOR cTRC( p_trc_num  IN  TRC.itrcNUM%TYPE, p_trc_anum   IN  TRC.itrcANUM%TYPE ) IS
  SELECT TRC.*
    FROM xxi."trc" TRC
   WHERE itrcNUM = p_trc_num
     AND itrcANUM = p_trc_anum;
  rTrc                cTrc%ROWTYPE;

  CURSOR cur_dept_info( p_trc_num  IN  TRC.itrcNUM%TYPE, p_trc_anum   IN  TRC.itrcANUM%TYPE ) IS
  SELECT TRC_DEPT_INFO.*
    FROM TRC_DEPT_INFO
   WHERE INUM = p_trc_num
     AND IANUM = p_trc_anum;
  r_dept_info         cur_dept_info%ROWTYPE;

  l_res               boolean := FALSE;
  l_itrctype          trc.ITRCTYPE%type := nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.UPD_TRC_ITRCTYPE'),11);
	l_bik_new           UBRR_DATA.UBRR_TOFK_ACCOUNTS.BIK_NEW%type := null;
	l_corraccount_new   UBRR_DATA.UBRR_TOFK_ACCOUNTS.CORRACCOUNT_NEW%type := null;
	l_account_new       UBRR_DATA.UBRR_TOFK_ACCOUNTS.ACCOUNT_NEW%type := null;
	l_ctrcbnamea        trc.CTRCBNAMEA%type;

BEGIN

  IF ubrr_xxi5.ubrr_change_accounts_tofk.get_tofk_accounts_trc( par_trc_num         => par_trc_num,
                                                                par_trc_anum        => par_trc_anum,
                                                                par_bik_new         => l_bik_new,
                                                                par_corraccount_new => l_corraccount_new,
                                                                par_account_new     => l_account_new)   THEN

    IF l_bik_new is not null and l_corraccount_new is not null and l_account_new is not null THEN

      open cTRC(par_trc_num,par_trc_anum);
      fetch cTRC into rTrc;
      close cTRC;

      CARD_EDIT.SetFieldByName ('ITRCTYPE', l_itrctype);
      CARD_EDIT.setFieldByName ('CTRCMFOA', l_bik_new);
      CARD_EDIT.SetFieldByName ('CTRCCORACCA', l_corraccount_new);
      CARD_EDIT.SetFieldByName ('CTRCBCITYA',rTrc.ctrcbcitya);
      CARD_EDIT.setFieldByName ('CTRCACCA', l_account_new);
      CARD_EDIT.SetFieldByName ('CTRCOWNA',rTrc.CTRCOWNA);
      CARD_EDIT.SetFieldByName ('CTRCINNA',rTrc.CTRCINNA);
      CARD_EDIT.SetFieldByName ('CTRCKPPA',rTrc.CTRCKPPA);
      CARD_EDIT.SetFieldByName ('CTRCDWAY',rTrc.CTRCDWAY);
      CARD_EDIT.SetFieldByName ('ITRCSOP',rTrc.ITRCSOP);
      CARD_EDIT.SetFieldByName ('ITRCDOCNUM',rTrc.ITRCDOCNUM);
      CARD_EDIT.SetFieldByName ('ITRCBATNUM',rTrc.ITRCBATNUM);
      CARD_EDIT.SetFieldByName ('CTRCCORACCO', '');
      CARD_EDIT.SetFieldByName ('ITRCPRIORITY',rTrc.ITRCPRIORITY);
      CARD_EDIT.SetFieldByName ('ITRCSBCODEA',rTrc.ITRCSBCODEA);
      CARD_EDIT.SetFieldByName ('CTRCPURP',rTrc.CTRCPURP);
      CARD_EDIT.SetFieldByName ('CTRCVO',rTrc.CTRCVO);
      CARD_EDIT.SetFieldByName ('CTRCTEXT3',rTrc.CTRCTEXT3);
      CARD_EDIT.SetFieldByName ('CTRCCLIENT_NAME',rTrc.CTRCCLIENT_NAME);
      CARD_EDIT.SetFieldByName ('CTRCCLIENT_INN',rTrc.CTRCCLIENT_INN);
      CARD_EDIT.SetFieldByName ('CTRCCLIENT_KPP',rTrc.CTRCCLIENT_KPP);

      l_ctrcbnamea := ubrr_xxi5.ubrr_change_accounts_tofk.get_tofk_bnamea_of_ed807(par_bik      => l_bik_new,
                                                                                   par_сcoracca => l_corraccount_new);
      CARD_EDIT.setFieldByName ('CTRCBNAMEA', nvl(l_ctrcbnamea,rTrc.Ctrcbnamea));

      open cur_dept_info(par_trc_num,par_trc_anum);
      fetch cur_dept_info into r_dept_info;
      close cur_dept_info;

      CARD_EDIT.SetFieldByName ('CCREATSTATUS',r_dept_info.ccreatstatus);
      CARD_EDIT.SetFieldByName ('CBUDCODE',r_dept_info.cbudcode);
      CARD_EDIT.SetFieldByName ('COKATOCODE',r_dept_info.cokatocode);
      CARD_EDIT.SetFieldByName ('CNALPURP',r_dept_info.cnalpurp);
      CARD_EDIT.SetFieldByName ('CNALPERIOD',r_dept_info.cnalperiod);
      CARD_EDIT.SetFieldByName ('CNALDOCNUM',r_dept_info.cnaldocnum);
      CARD_EDIT.SetFieldByName ('CNALDOCDATE',r_dept_info.cnaldocdate);
      CARD_EDIT.SetFieldByName ('CNALTYPE',r_dept_info.cnaltype);
      CARD_EDIT.SetFieldByName ('CDOCINDEX',r_dept_info.cdocindex);
      CARD_EDIT.SetFieldByName ('CCODEPURPOSE',r_dept_info.ccodepurpose);

      l_res := TRUE;
    ELSE
      l_res := FALSE;
    END IF;

  END IF;

  return l_res;
EXCEPTION
 when OTHERS then
   if cTRC%isopen then close cTRC; end if;
   if cur_dept_info%isopen then close cur_dept_info; end if;
   return false;
END UPD_TOFK_ACCOUNTS_AUTO_TRC;
--<<01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

end UBRR_CHANGE_ACCOUNTS_TOFK;
/
