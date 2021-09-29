CREATE OR REPLACE PACKAGE UBRR_XXI5."UBRR_BNKSERV_CALC_NEW_LIB"

-------------------------------------------------------------------------------------------------
-- ����� �������� � ���� ������ ��� ������� �������� �� ubrr_bnkserv_calc_new, ubrr_bnkserv
-------------------------------------------------------------------------------------------------

/*************************************************** HISTORY *****************************************************\
   ����          �����          id        ��������
----------  ---------------  -----------  ------------------------------------------------------------------------------
24.07.2019  ������� �.�.     [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
03.08.2019  ������� �.�.     [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
15.10.2019  ��������         [19-62184] �������� �� ��� ��� �������� �-�� "����" https://redmine.lan.ubrr.ru/issues/67214#note-2
13.12.2019  ������� �.�.     [69650]    ����� �������� ���� - �������� �� ����������
09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� 
11.02.2021  ������ �.�.      �DKBPA-245 ��������� ������ ���������� �������� �� ������� ������ - �����
03.03.2021  ������� �.�.     DKBPA-264 ��� ��: ������� ����� � ����������� �� ���-�� ���� ��� �������� �����
19.07.2021  ������� �.�.     DKBPA-1571   �� ��������. �������� �������� � ������ "������"
\*************************************************** HISTORY *****************************************************/
is
-- >> ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
subtype t_rec_sbs_new         is ubrr_data.ubrr_sbs_new%rowtype;
type    t_tbl_sbs_new         is table of t_rec_sbs_new index by binary_integer;
type    t_rec_register_result is record( l_trn_cnt pls_integer
                                        ,l_trc_cnt pls_integer
                                        ,l_err_cnt pls_integer ); 
-- << ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����

gc_calc_table_sbs     constant pls_integer := 1;         -- ������������� ������� SBS ��� ������� ��������
gc_calc_table_sbs_new constant pls_integer := 2;         -- ������������� ������� UBRR_SBS_NEW ��� ������� ��������
gc_ls                 constant varchar2(25) :='40___810%';

-- >> ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
gc_com_type_hold_no        constant ubrr_rko_com_types.ihold%type := 0;   -- �������� �� �������� ������������          (ubrr_rko_com_types)        
gc_com_type_hold2month     constant ubrr_rko_com_types.ihold%type := 1;   -- �������� ����� ���� �������� � ����������� (ubrr_rko_com_types)

gc_sbs_hold_no            constant ubrr_sbs_new.ihold%type := 0;      -- ��������  �� ����������        
gc_sbs_hold2month         constant ubrr_sbs_new.ihold%type := 1;      -- ��������  �������� � �����������
gc_sbs_hold_created       constant ubrr_sbs_new.ihold%type := 2;      -- ��������� �������� �� ����������

gc_csbsstat_hold_monthly   constant ubrr_sbs_new.csbsstat%type := '���������� � �����������';
gc_csbsstat_pass           constant ubrr_sbs_new.csbsstat%type := '���������'               ; 
gc_csbsstat_file2          constant ubrr_sbs_new.csbsstat%type := '���������� � ��������� 2';

gc_limit_bulk_monthly_hold constant pls_integer := 1000;

g_purp_ntk  number(1); -- 14.06.2018 ubrr korolkov #50487 -- 03.08.2019  ������� �.�. [19-62808] -- ���������� �� ubrr_bnkserv_calc_new

-- << ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����

-->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
gc_comm_freq_monthly          constant ubrr_rko_com_types.freq%type := '�����������'; 
gc_comm_freq_daily            constant ubrr_rko_com_types.freq%type := '����������';
gc_comm_freq_timer            constant ubrr_rko_com_types.freq%type := '�� �������';

gc_pref_rework_link_commiss   constant ups.cupspref%type:='UBRR_BNKSERV_CONTROL_LINK_COMMISS';    -- ��� ����������� �������� ��������� �������� � ��������� ���������
gc_pref_run_timer_commiss     constant ups.cupspref%type:='UBRR_BNKSERV_RUN_TIMER_COMMISS';       -- ��� ����������� ������� ������� �� �������                
gc_pref_test_timer_commiss    constant ups.cupspref%type:='UBRR_BNKSERV_TEST_TIMER_COMMISS';      -- ��� ����������� ������ �����  ������� �� �������
gc_pref_from_hh_timer_commiss constant ups.cupspref%type:='UBRR_BNKSERV_FROM_HH24_TIMER_COMMISS'; -- ��� �������, ������� � �������� ����� ����������� ������ ��������
--<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������

-->>09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������
gc_sbs_uniq_taif              varchar2(1) := 'N';  -- ��������� � ubrr_bnkserv_calc_new.getsumcomiss, ������� ������� ����� ��� �������������� �������
gc_sbs_uniq_taif_day          varchar2(1) := 'N';  -- ��������� � ubrr_bnkserv_calc_new_lib.GetSumComiss_Uniq, ������� ����������/�����������
gc_sbs_uniq_taif_id_check     varchar2(1) := 'Y';  -- ��������� � ubrr_bnkserv_calc_new_lib.GetSumComiss_Uniq, ������� ������� ID ������ ��� ��� (����������� �� ����� ID)
--<<09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������

gc_Check_Online_Trc           VARCHAR2(1) := 'N';  --19.07.2021  ������� �.�.     DKBPA-1571   �� ��������. �������� �������� � ������ "������"

-- �����������
procedure writeprotocol(cmess in varchar2);
  
-->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
-- ����������� � ��������� : 0 ��� 1
procedure writeprotocol( cmess in varchar2
                        ,p_log in pls_integer );
--<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
--------------------------------------------------------
function get_userid( p_usr varchar2 default null )  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� ����� 
return number;

---------------------------------------------------------------
-- ����������� ��� �� ����� ����� ��� c ������������ 
-- �� ��� ������������� � select (����� ����� ��������)
-- ���� 131 ��� ���  �� �����, �� ���������� �������� p_otd
-- ���� 131 ��� ���� �� �����, �� ��� �� ������ �� null
--                    ����� ���������� ���
function mvz_gac( p_acc     in acc.caccacc%type
                 ,p_cur     in acc.cacccur%type
                 ,p_otd     in acc.iaccotd%type
                 ,p_TypeCom in varchar2                  
                 ,p_idsmr   in varchar2
                 ,p_log     in pls_integer default 0 )
return number;

--��������� ����� �������� �� ��������
-- ���������� �� ubrr_bnkserv_calc_new  
function GetTarifId( p_Acc       in acc.caccacc%type
                    ,p_Cur       in acc.cacccur%type
                    ,p_Otd       in acc.iaccotd%type
                    ,p_TypeCom   in varchar2
                    ,p_WithCat   in number
                    ,p_BankIdSmr in varchar2
                    ,p_dater     in date ) 
return number;

-- ������ ��� ���� ubrr_bnkserv_calc_new.GetSumComiss
function getsumcomiss( p_TrnNum      in trn.itrnnum%type
                      ,p_TrnAnum     in trn.itrnanum%type
                      ,p_Acc         in acc.caccacc%type
                      ,p_Cur         in acc.cacccur%type
                      ,p_Otd         in acc.iaccotd%type
                      ,p_TypeCom     in varchar2
                      ,p_SumTrn      in number
                      ,p_SumBefo     in number default null 
                      ,p_g_tarif_id  in out integer
                      ,p_mtarif      in out number  -- ���������� � ��������� ��� UpdateAccComiss
                      ,p_mtarifPrc   in out number  -- ���������� � ��������� ��� UpdateAccComiss
                      ,p_BankIdSmr   in varchar2
                      ,p_dater       in date ) 
  return number;
  
-->>09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� 
function GetSumComiss_Uniq( p_TrnNum      in trn.itrnnum%type
                           ,p_TrnAnum     in trn.itrnanum%type
                           ,p_Acc         in acc.caccacc%type
                           ,p_Cur         in acc.cacccur%type
                           ,p_Otd         in acc.iaccotd%type
                           ,p_TypeCom     in varchar2
                           ,p_SumTrn      in number
                           ,p_SumBefo     in number default null
                           ,p_g_tarif_id  in out integer
                           ,p_mtarif      in out number  -- ���������� � ��������� ��� UpdateAccComiss
                           ,p_mtarifPrc   in out number  -- ���������� � ��������� ��� UpdateAccComiss
                           ,p_BankIdSmr   in varchar2
                           ,p_dater       in date) 
  return number;
--<<09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��                 

-- ����������� ������� ��������� �2 ��� �1 ������ ������
function have_kartoteka( p_caccacc   in varchar2
                        ,p_cacccur   in varchar2
                        ,p_date_tran in date )
return boolean;

-- ����������� ����� �������� ������� �� ������� �����
-- ���������� �� ubrr_bnkserv_calc_new
procedure AnalizeClient( p_Client     in cus.icusnum%TYPE
                        ,p_dat_beg    in date
                        ,p_dat_end    in date
                        ,p_dtran      in date
                        ,p_calc_table in pls_integer default gc_calc_table_sbs_new );

--  
function Analize_Accounts_For_RKO ( portion_date1 in date
                                   ,portion_date2 in date
                                   ,dtran         in date
                                   ,p_ls          in varchar2
                                   ,p_calc_table  in pls_integer default gc_calc_table_sbs_new )
return number;

-->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
-- �������� �������� ���������� ��������� � trn � sbs_new
-- p_nid - id � sbs_new
function strattrib_trn_sbs_one( p_nsbsid in number )
return varchar2;      
--<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
     
-- >> ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����                                   
--  ����������� �������� �� SBS_NEW
-- p_test=0 - �� ������� �������� ����� (�������� ����� ���������������� � �������)
  function Register( p_regdate             in  date
                    ,p_TypeCom             in  number
                    ,p_Mess                out varchar2
                    ,p_portion_date1       in  date   default null
                    ,p_portion_date2       in  date   default null
                    ,p_ls                  in  varchar2
                    ,p_mode_available_rest in boolean default false  -- ubrr 21.02.2019 ������� �.�. [17-1790] ���: ��������� �� ��� ��� ������� ������������ ���������
                    ,p_mode_hold           in boolean default false  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                    ,p_test                in number default 0                    
                   )
  return number;

--  ����������� �������� �� SBS_NEW
-- p_test=0 - �� ������� �������� ����� (�������� ����� ���������������� � �������)
  function Register_single( p_regdate             in  date
                           ,p_TypeCom             in  number
                           ,p_Mess                out varchar2
                           ,p_portion_date1       in  date   default null
                           ,p_portion_date2       in  date   default null
                           ,p_ls                  in  varchar2
                           ,p_mode_available_rest in boolean default false  -- ubrr 21.02.2019 ������� �.�. [17-1790] ���: ��������� �� ��� ��� ������� ������������ ���������
                           ,p_mode_hold           in boolean default false  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                           ,p_sbs_new             in t_rec_sbs_new
                           ,p_test                in number default 0                           
                          )
  return t_rec_register_result;

-- ��������� ������ �� �������� p_hold (ubrr_sbs_new.ihold)
function stat4hold(p_hold in number)
return varchar2;  

-- ������������ � SBS_NEW ����������� �������� �� ���������� ����������
-- ���������� ���������� ��������� � ubrr_sbs_new
-- ����������� ��������� � ubrr_sbs_new ��� �����,��� 
procedure create_monthly_comm_from_hold( p_portion_date1 in date
                                        ,p_portion_date2 in date
                                        ,p_dtran         in date     -- ���� ������� ��������
                                        ,p_ls            in varchar2 default gc_ls );
                                        
-- �������� ����������� �� ���������� ����������
-- ���������� � trn/trc
function process_monthly_comm_from_hold( p_dtran          in  date
                                        ,p_portion_date1  in  date     default null
                                        ,p_portion_date2  in  date     default null
                                        ,p_ls             in  varchar2 default gc_ls
                                        ,p_test           in  number   default 0
                                        ,p_Mess           out varchar2 )
return number;

-- �������� ����������� �� ���������� ����������
-- ���������� � trn/trc 
procedure process_monthly_comm_from_hold( p_dtran          in  date
                                         ,p_portion_date1  in  date     default null
                                         ,p_portion_date2  in  date     default null
                                         ,p_ls             in  varchar2 default gc_ls
                                         ,p_test           in  number   default 0
                                         ,p_Mess           out varchar2 );

-- << ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����

-->> ubrr 15.10.2019 �������� [19-62184] �������� �� ��� ��� �������� �-�� "����" https://redmine.lan.ubrr.ru/issues/67214#note-2
-- ��������� �������� ������� ��� ������� ��������
procedure fill_trn_old_new(p_d1 in date
                          ,p_d2 in date);
--<< ubrr 15.10.2019 �������� [19-62184] �������� �� ��� ��� �������� �-�� "����" https://redmine.lan.ubrr.ru/issues/67214#note-2

-->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
-- �������� ���� ����������. ��� �������� INC
function doc_is_inc( p_ntrnnum  in number
                    ,p_ntrnanum in number )
return boolean;

-- �������� id �������� ��������� ��������� ��� ������ �������� ubrr_sbs_new
procedure get_link_trnnum_from_comm( p_nid   in  number
                                    ,p_nnum  out number
                                    ,p_nanum out number
                                   );

-- �������� id ���������-��������
-- �� id ��������� ���������
-- ��������� ��� �������� ���� INC (���� ��������-���� �������� � ������)
procedure get_id_comm_doc( p_nnum       in  number
                          ,p_nanum      in  number
                          ,p_ctypecom   in  varchar2                          
                          ,p_isbstrnnum out number
                          ,p_csbsstat   out varchar2 );

-- �������� ��������� �������� ��������� �������� �� id
-- ��������� ��� �������� ���� INC (���� ��������-���� �������� � ������)
procedure get_attrib_comm_doc( p_isbstrnnum in  number
                              ,p_csbsstat   in  varchar2
                              ,p_ddoc       out date
                              ,p_idocnum    out number
                              ,p_caccd      out varchar2
                              ,p_caccc      out varchar2
                              ,p_msum       out number
                              ,p_trntrc     out varchar2 );

-- ��������-��������
function msg_check_doc_inc( p_ntrnnum  in number
                           ,p_ntrnanum in number )
return varchar2;

-- ���������� ������ ������� �������� �� �������
function f_pref_run_timer_commiss
return boolean;

-- �������� ������������� ������� �� ����������� ���� ��������
function comm_freq( p_com_type in varchar2 )
return varchar2;

-- �������� �������� ��������� "�� �������"
function comm_freq_is_timer( p_com_type in varchar2 )
return boolean;

-- ���� ����������� ��������� ��������� ��� ����������� ������ SBS_NEW
function datereg_trn_from_link_comm( p_nid in number )
return date;

-- ������� ������� ������� �������� �� �������
function enable_run_calc_timer_commis
return boolean;
--<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
-->> 11.02.2021 ������ �.�. ����������: ��������� ������ ���������� �������� �� ������� ������ - �����
function get_free_limit( p_iobgcat obg.iobgcat%type, 
                         p_iobgnum obg.iobgnum%type, 
                         p_caccacc xxi.au_attach_obg.caccacc%type,
                         p_ndef_lim number default 100 ) return number; 
--<< 11.02.2021 ������ �.�. ����������: ��������� ������ ���������� �������� �� ������� ������ - �����

-->>03.03.2021  ������� �.�.     DKBPA-264 ��� ��: ������� ����� � ����������� �� ���-�� ���� ��� �������� �����
-- ������ ���������� ����� �������� � ����������� �� ���-�� ���� ��� �������� ����� 
FUNCTION Get_Sum_First_Month(par_acc       in xxi.acc.CACCACC%type,
                             par_cur       in xxi.acc.CACCCUR%type,
                             par_datbeg    in date,
                             par_datend    in date,
                             par_sum       in number
                            )
  RETURN NUMBER;

-- �������� ����������� ����� �������� � ����������� �� ���-�� ���� ��� �������� ����� 
PROCEDURE Calc_Sum_First_Month(portion_date1  in date,
                               portion_date2  in date,
                               par_ls         in varchar2 
                              ); 
--<<03.03.2021  ������� �.�.     DKBPA-264 ��� ��: ������� ����� � ����������� �� ���-�� ���� ��� �������� �����  

-->>19.07.2021  ������� �.�.     DKBPA-1571   �� ��������. �������� �������� � ������ "������"
--������ ��������� ���������� �������� ������ � �������, ������������� ��������� ��� ��������� ��������
FUNCTION Get_Last_Itrcnum
  RETURN NUMBER;

--�������� ��������� �������� ������ � �������, ������������� ��������� ��� ��������� ��������
PROCEDURE Set_Last_Itrcnum ( par_Itrcnum IN NUMBER );

--���������� �������, �������� � ��������� �� ������
PROCEDURE Set_Check_Online_Trc( par_Check_Trc IN VARCHAR2 );
--<<19.07.2021  ������� �.�.     DKBPA-1571   �� ��������. �������� �������� � ������ "������"

end ubrr_bnkserv_calc_new_lib;
/
CREATE OR REPLACE PACKAGE BODY UBRR_XXI5."UBRR_BNKSERV_CALC_NEW_LIB"
/*************************************************** HISTORY *****************************************************\
   ����          �����          id        ��������
----------  ---------------  -----------  ------------------------------------------------------------------------------
24.07.2019  ������� �.�.     [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
14.10.2019  ��������         [19-62808]  https://redmine.lan.ubrr.ru/issues/67609
15.10.2019  ��������         [19-62184] �������� �� ��� ��� �������� �-�� "����" https://redmine.lan.ubrr.ru/issues/67214#note-2
02.12.2019  ��������         [19-62184] ����������� ������ dup_val_on_index: ORA-00001: unique constraint (UBRR_DATA.P_TRN_OLD_NEW_NUM)
09.12.2019  ��������         [19-62184] ����������� ������ dup_val_on_index: ORA-00001: unique constraint (UBRR_DATA.P_TRN_OLD_NEW_NUM) https://redmine.lan.ubrr.ru/issues/69720
13.12.2019  ������� �.�.     [69650]    ����� �������� ���� - �������� �� ����������
14.02.2020  ��������         [20-71606] ������������� �������� ����������, �-�������������, �����������
02.03.2020  ��������         [19-69558.2] �������� �������� �������������, ���������, �������������
04.03.2020  ������� �.�.     [20-71832] ���: ��������� ������ "������" (���)
09.04.2020  ������� �.�.     [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
28.05.2020 UBRR Lazarev      [20-74342] https://redmine.lan.ubrr.ru/issues/74342
09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
22.01.2021  ������� �.�.     DKBPA-139 ���.���������� ��������. ����������� ���������� �������� �� ����� ����
11.02.2021  ������ �.�.      �DKBPA-245 ��������� ������ ���������� �������� �� ������� ������ - �����
17.02.2021  ������ �.�.      DKBPA-42 ��������� ������� �� ��������������
03.03.2021  ������� �.�.     DKBPA-264 ��� ��: ������� ����� � ����������� �� ���-�� ���� ��� �������� �����
12.03.2021  ������� �.�.     [DKBPA-402]   ���: ����. ��������� ���������� �� �� ����� ���� (���)
25.05.2021  ������ �.�.      DKBPA-760    ���������� ��������� ������� ���/�� ��� ������� ����������� �������� ��� ���
13.07.2021  ������� �.�.     DKBPA-1652 ���������� ������ ����������� �������� �� ���������� ��� ������ "����� ������" - 2 ����
19.07.2021  ������� �.�.     DKBPA-1571   �� ��������. �������� �������� � ������ "������"
\*************************************************** HISTORY *****************************************************/
is

  iLast_Itrcnum        INTEGER := 0;  --19.07.2021  ������� �.�.     DKBPA-1571   �� ��������. �������� �������� � ������ "������"
  
-- >> ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
-- �������� ��������������� ���������� ���������� ��������
cursor g_cur_monthly_hold( p_portion_date1 in date
                          ,p_portion_date2 in date
                          ,p_ls            in varchar2 default gc_ls
                          ,p_idsmr         in varchar2 )
is
   select ISBSTYPECOM
         ,CSBSTYPECOM
         ,CSBSACCD
         ,CSBSCURD
         ,CSBSACCD_ZAM
         ,CSBSCURD_ZAM
         ,CSBSACCC
         ,CSBSCURC
         ,sum( MSBSSUMPAYS )   MSBSSUMPAYS
         ,sum(ISBSCOUNTPAYS)   ISBSCOUNTPAYS
         ,sum(MSBSSUMCOM)      MSBSSUMCOM
         ,ISBSOTDNUM
         ,ISBSBATNUM
         ,CSBSPACK
         ,sum(MSBSSUMBEFO)     MSBSSUMBEFO
         ,IDSMR_TO
         ,TARIF_ID
         ,cast(collect(s.id) as ubrr_integer_tab) list_daily_id
     from ubrr_sbs_new s
    where s.ihold     = gc_sbs_hold2month
      and s.dsbsdate >=  p_portion_date1
      and s.dsbsdate <= (p_portion_date2 + 86399/86400)
      and s.idsmr       = p_idsmr
      and isbstrnnum is null
      and s.CSBSSTAT = gc_csbsstat_hold_monthly -- �� ���� ������ ������, ��� ������
      and s.csbsaccd like p_ls
    group by s.ISBSTYPECOM
            ,s.CSBSTYPECOM
            ,s.CSBSACCD
            ,s.CSBSCURD
            ,s.CSBSACCD_ZAM
            ,s.CSBSCURD_ZAM
            ,s.CSBSACCC
            ,s.CSBSCURC
            ,s.ISBSOTDNUM
            ,s.ISBSBATNUM
            ,s.IDSMR
            ,s.CSBSPACK
            ,s.IDSMR_TO
            ,s.TARIF_ID;
----- g_cur_daily_hold

subtype t_rec_monthly_hold is g_cur_monthly_hold%rowtype;
type t_tbl_monthly_hold    is table of t_rec_monthly_hold index by binary_integer;
-- << ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
---------------------------------------------------------------
-- �����������
procedure writeprotocol(cmess in varchar2)
is
  pragma autonomous_transaction;
begin
  insert into ubrr_data.ubrr_sbs_new_log (username, sessionid, log_date, message)
  values (user, userenv('SessionID'), sysdate, substr(cmess,1,2000));  -- ubrr 28.03.2019 ������� �.�. [19-61113] ���: �������� �������� �� SMS-�������������� �� ��������� �� ������������ ����� ������� �� ������� 2019 ����
  commit;
end writeprotocol;

-->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
---------------------------------------------------------------
-- ����������� � ��������� : 0 ��� 1
procedure writeprotocol( cmess in varchar2
                        ,p_log in pls_integer ) -- �������� � ��� ��� ���
is
  pragma autonomous_transaction;
begin
  if ( p_log=1 ) then
     insert into ubrr_data.ubrr_sbs_new_log (username, sessionid, log_date, message)
     values (user, userenv('SessionID'), sysdate, substr(cmess,1,2000));  -- ubrr 28.03.2019 ������� �.�. [19-61113] ���: �������� �������� �� SMS-�������������� �� ��������� �� ������������ ����� ������� �� ������� 2019 ����

     commit;
  end if;
end writeprotocol;
--<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������


-- >> ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
--------------------------------------------------------
function get_userid( p_usr varchar2 default null )
return number
is
  v_res usr.iusrid%type;
begin
  select iusrid
    into v_res
    from usr
   where cusrlogname = nvl(p_usr, user);
  return v_res;
exception
  when no_data_found then
    return null;
end get_userid;
-- << ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����

--------------------------------------------------------
-- ����������� ��� �� ����� ����� ��� c ������������
-- �� ��� ������������� � select (����� ����� ��������)
-- ���� 131 ��� ���  �� �����, �� ���������� �������� p_otd
-- ���� 131 ��� ���� �� �����, �� ��� �� ������ �� null
--                    ����� ���������� ���
function mvz_gac( p_acc     in acc.caccacc%type
                 ,p_cur     in acc.cacccur%type
                 ,p_otd     in acc.iaccotd%type
                 ,p_TypeCom in varchar2
                 ,p_idsmr   in varchar2
                 ,p_log     in pls_integer default 0 )
return number
is
  l_cmvz number;
begin
   begin
     select s.cmvz
       into l_cmvz
       from ( select t.cmvz
                    ,row_number() over ( partition by g.cgacacc order by g.igacnum ) rn
                from gac g
                left join ubrr_comm_gacmvz_tarif t
                  on g.igaccat = t.icat
                 and g.igacnum = t.inum
               where g.cgacacc = p_acc
                 and g.cgaccur = p_cur
                 and g.igaccat = 131
                 and g.idsmr   = p_idsmr
            ) s
        where s.rn=1;  -- ������ �� ����_�������, ��� ��� � ubrr_comm_gacmvz_tarif ��� �����������

     if ( l_cmvz is null and p_log=1 ) then
        WriteProtocol('(ubrr_bnkserv_calc_new_lib.mvz_gac) '||' ���� '       ||p_acc    ||';'||
                                                              '��� �������� '||p_TypeCom||';'||
                                                              'p_idsmr '     ||p_idsmr  ||';'||
                                                              ' �� ���������  ��� !!! (error)');
     end if;
   exception when no_data_found then
        l_cmvz := p_otd; -- �� ����� ��� 131 ���
   end;
   return l_cmvz;
end mvz_gac;

---------------------------------------------------------------
-- ��������� ����� �������� �� ��������
-- ���������� �� ubrr_bnkserv_calc_new
-- � ��� ���������� ���� ������
  function GetTarifId( p_Acc       in acc.caccacc%type
                      ,p_Cur       in acc.cacccur%type
                      ,p_Otd       in acc.iaccotd%type
                      ,p_TypeCom   in varchar2
                      ,p_WithCat   in number
                      ,p_BankIdSmr in varchar2
                      ,p_dater     in date )
  return number
  IS
    vId NUMBER;
    l_dater date := p_dater; -- 25.05.2021 ������ �.�.  DKBPA-760
  BEGIN
    -->> 25.05.2021 ������ �.�.  DKBPA-760
    if pref.Get_Global_Preference('UBRR_BNKSERV_CALC_NEW_LIB.SETTING_SECOND_TIME') is not null then
        l_dater := trunc(p_dater)+ 86398/86400;
    end if;
    --<< 25.05.2021 ������ �.�.  DKBPA-760
    IF p_WithCat=1 THEN
      SELECT nvl(max(c.Id),0)
      INTO vId
      FROM ubrr_data.ubrr_rko_tarif c,
           ubrr_data.ubrr_rko_tarif_otdsum o
      WHERE c.parent_idsmr = p_BankIdSmr  -->><<-- ubrr 23.09.2016 �������� �.�. 16-2222 ���������� �������� ������
        AND c.com_type     = p_TypeCom
        AND c.cat IS NOT NULL
        AND c.Id           = o.id_com
        AND o.otd          = p_Otd
        AND (c.cat, c.grp, c.Prior_Com) = (select cat
                                                 ,grp
                                                 ,prior_com
                                             from (select prior_com
                                                         ,c.cat
                                                         ,c.grp
                                                         ,row_number() over (order by prior_com desc, c.id) rn
                                                     from ubrr_data.ubrr_rko_tarif c,
                                                          ubrr_data.ubrr_rko_tarif_otdsum o,
                                                          xxi.au_attach_obg au
                                                    where c.parent_idsmr = p_BankIdSmr  -->><<-- ubrr 23.09.2016 �������� �.�. 16-2222 ���������� �������� ������
                                                      and c.com_type     = p_TypeCom
                                                      and c.cat is not null
                                                      and c.id           = o.id_com
                                                      and o.otd          = p_otd
                                                      and au.caccacc     = p_acc
                                                      and au.cacccur     = p_cur
                                                      and i_table        = 304
                                                      and d_create      <= l_dater /*p_dater*/ -- 25.05.2021 ������ �.�.  DKBPA-760
                                                      and c_type in ('I', 'U')
                                                      and au.c_newdata = (c.cat)||'/'||(c.grp)
                                                      and nvl(au.c_olddata,'-') != au.c_newdata
                                                      and Add_months(d_create,
                                                                     case when c.cat = 112 and c.grp = 1006 then 3
                                                                          when c.cat = 112 and c.grp = 1007 then 6
                                                                          when c.cat = 112 and c.grp = 1008 then 12
                                                                          when c.cat = 112 and c.grp = 1009 then 18
                                                                          when c.cat = 112 and c.grp = 1016 then 24 -- 07.03.2017 �������� �.�.  [17-166] https://redmine.lan.ubrr.ru/issues/40971
                                                                          when c.cat = 112 and c.grp = 1010 then 12
                                                                          else 1000
                                                                     end) > l_dater /*p_dater*/ -- 25.05.2021 ������ �.�.  DKBPA-760
                                                      and not exists (select 1
                                                                        from xxi.au_attach_obg au1
                                                                       where au1.caccacc   = au.caccacc
                                                                         and au1.cacccur   = au.cacccur
                                                                         and i_table       = 304
                                                                         and au1.d_create <= l_dater /*p_dater*/ -- 25.05.2021 ������ �.�.  DKBPA-760
                                                                         and au1.d_create  > au.d_create
                                                                         and au1.c_type in ('D', 'U')
                                                                         and au1.c_olddata = au.c_newdata
                                                                         and nvl(au1.c_newdata, '-') != au1.c_olddata
                                                                     )
                                                  )
                                           where rn = 1
                                          );
    ELSE
      SELECT nvl(max(c.Id),0)
      INTO vId
      FROM ubrr_data.ubrr_rko_tarif c,
           ubrr_data.ubrr_rko_tarif_otdsum o
      WHERE c.parent_idsmr = p_BankIdSmr  -->><<-- ubrr 23.09.2016 �������� �.�. 16-2222 ���������� �������� ������
        AND c.com_type     = p_TypeCom
        AND c.cat IS NULL
        AND c.Id           = o.id_com
        AND o.otd          = p_Otd
        AND Prior_Com = ( SELECT max(Prior_com)
                            FROM ubrr_data.ubrr_rko_tarif c,
                                 ubrr_data.ubrr_rko_tarif_otdsum o
                            WHERE c.parent_idsmr = p_BankIdSmr  -->><<-- ubrr 23.09.2016 �������� �.�. 16-2222 ���������� �������� ������
                              AND c.com_type     = p_TypeCom
                              AND c.cat IS NULL
                              AND c.Id           = o.id_com
                              AND o.otd          = p_Otd
                        );

      -->> 07.11.2017 ubrr korolkov 17-1071
      if p_BankIdsmr = '1' and vId = 0 and
         p_TypeCom in ( 'PES9_PE','PE9_PE','PE6_PE','PES6_PE', -->><<-- 22.06.2018 ������ �.�. [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                        'R_LIGHT', -->><<-- 25.10.2018 �������� [18-56613] �� "������ ������" (�� ���� �� "��������") ��� ��� � 01.11.18
                        'R_IB_LT', -->><<-- 02.10.2018 �������� [18-592.2] ���. ������� �������� �� ���������
                        'PP9', 'PE9', 'PES9', 'PP6', 'PE6', 'PES6', '017', '017_N', '018', '018_N', 'PP3', 'PP6_NTK', '017_NTK', '018_NTK'
                        ,'BESP' -- ubrr 06.03.2019 ������� �.�. [18-58177.2] ���. ����������� (������ �������� ��������)
                        ,'SENCASH' -->><<-- 17.02.2021 ������ �.�. DKBPA-42 ��������� ������� �� ��������������
                      ) -- 02.02.2018 ubrr korolkov #47689#note-114
      then
        select max(id) keep (dense_rank last order by prior_com)
          into vId
          from ubrr_data.ubrr_rko_tarif
         where parent_idsmr = p_BankIdSmr
           and com_type     = p_TypeCom
           and cat is null;
      end if;
      --<< 07.11.2017 ubrr korolkov 17-1071
    END IF;
    RETURN nvl(vId, 0);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
-->> 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    when others then
       raise_application_error(-20006
                              ,'error in '  ||$$plsql_unit||'.GetTarifId ['||
                              'p_Acc='      ||p_Acc       ||';'||
                              'p_Cur='      ||p_Cur       ||';'||
                              'p_Otd='      ||p_Otd       ||';'||
                              'p_TypeCom='  ||p_TypeCom   ||';'||
                              'p_WithCat='  ||p_WithCat   ||';'||
                              'p_BankIdSmr='||p_BankIdSmr ||';'||
                              'p_dater='    ||to_char(p_dater,'dd.mm.yyyy') ||';'||
                              ']'||sqlerrm
                              );
--<< 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
  end GetTarifId;

-----------------------------------------------------------------------------
-- ������ ��� ���� ubrr_bnkserv_calc_new.GetSumComiss
  function getsumcomiss( p_TrnNum      in trn.itrnnum%type
                        ,p_TrnAnum     in trn.itrnanum%type
                        ,p_Acc         in acc.caccacc%type
                        ,p_Cur         in acc.cacccur%type
                        ,p_Otd         in acc.iaccotd%type
                        ,p_TypeCom     in varchar2
                        ,p_SumTrn      in number
                        ,p_SumBefo     in number default null
                        ,p_g_tarif_id  in out integer
                        ,p_mtarif      in out number  -- ���������� � ��������� ��� UpdateAccComiss
                        ,p_mtarifPrc   in out number  -- ���������� � ��������� ��� UpdateAccComiss
                        ,p_BankIdSmr   in varchar2
                        ,p_dater       in date )
  return number
  IS
    vId        NUMBER;
    vSumCom    NUMBER;
    vSumCom1   NUMBER;
    vSum       NUMBER;
    vPerc      NUMBER;
    vMin       NUMBER;
    vMax       NUMBER;
    vSumBefo   NUMBER := NVL(p_SumBefo,0);
    vLowB      NUMBER;
    vHighB     NUMBER;
    vSumTrn    NUMBER := p_SumTrn;
    vSum1      NUMBER;
    vCalcField ubrr_data.ubrr_rko_tarif.calc_field%TYPE; -->><<-- ubrr 30.01.2017 �������� �.�.  [16-3223]   #39858  ���������� ������ �� "������������" (���)
-->> �������� �.�. 17-452 https://redmine.lan.ubrr.ru/issues/42479
    vMinOtd    NUMBER;
    vMaxOtd    NUMBER;
    vHasMinOtd BOOLEAN := FALSE;
    vHasMaxOtd BOOLEAN := FALSE;
--<< �������� �.�. 17-452 https://redmine.lan.ubrr.ru/issues/42479
    l_step     varchar2(4):='000';  -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
  BEGIN
    p_g_tarif_id := null; -- 21.02.2018 ubrr korolkov 18-12.1
    vSumCom := 0;
    vId := GetTarifId (p_Acc, p_Cur, p_Otd, p_TypeCom, 1, p_BankIdSmr, p_dater);

    l_step:='010'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    IF vId = 0 THEN
      vId := GetTarifId (p_Acc, p_Cur, p_Otd, p_TypeCom, 0, p_BankIdSmr, p_dater);
    END IF;

    l_step:='020'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    IF vId = 0 THEN
      WriteProtocol(case when p_TrnNum is not null then '��� �������� TrnNum = '||p_TrnNum else '' end ||'��� �������� '||p_TypeCom||' ���� '||p_Acc||' ��������� '||p_Otd||' ��� �������� '||p_TypeCom||' �� ����������� �����/������� ��������');
      RETURN NULL; -->><<-- ubrr 20.10.2016 �������� �.�. 16-2222 ��� ������������� �� ������������ �����
    END IF;

    p_g_tarif_id := vId; -- 21.02.2018 ubrr korolkov 18-12.1
    p_mtarif     := 0;
    p_mtarifPrc  := 0;

    l_step:='030'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    LOOP
      -->> ubrr 30.01.2017 �������� �.�.  [16-3223]   #39858  ���������� ������ �� "������������" (���)
      l_step:='040'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
      SELECT case when summ IS NULL AND perc IS NULL AND calc_field IS NULL THEN summ_def ELSE summ END,
             case when summ IS NULL AND perc IS NULL AND calc_field IS NULL THEN perc_def ELSE perc END,
             -->>11.07.2019 �������� [19-62974] II ���� ���.����.�����. ��������������� ������� ����� ����� �� ���
             /*case
                when gc_is_vuz = 1 then -- 07.11.2017 ubrr korolkov 17-1071
                   case when summ IS NULL AND perc IS NULL AND calc_field IS NULL THEN calc_field_def ELSE calc_field END
             -->> 07.11.2017 ubrr korolkov 17-1071
                else
                   case when calc_field is null then calc_field_def else calc_field end
             end,*/
             case when calc_field is null then calc_field_def else calc_field end,
             --<<11.07.2019 �������� [19-62974] II ���� ���.����.�����. ��������������� ������� ����� ����� �� ���
             --<< 07.11.2017 ubrr korolkov 17-1071
             NVL(case when summ IS NULL AND perc IS NULL AND calc_field IS NULL THEN min_sum_def ELSE min_sum END,0),
             NVL(case when summ IS NULL AND perc IS NULL AND calc_field IS NULL THEN max_sum_def ELSE max_sum END, 999999999999),
             low_border
            ,high_border
            ,min_sum
            ,max_sum           -- �������� �.�. 17-452 https://redmine.lan.ubrr.ru/issues/42479
        INTO vSum
            ,vPerc
            ,vCalcField
            ,vMin
            ,vMax
            ,vLowB
            ,vHighB
            ,vMinOtd
            ,vMaxOtd       --�������� �.�. 17-452 https://redmine.lan.ubrr.ru/issues/42479
      --<< ubrr 30.01.2017 �������� �.�.  [16-3223]   #39858  ���������� ������ �� "������������" (���)
        FROM ( SELECT c.summ_def, c.perc_def, c.min_sum min_sum_def, c.max_sum max_sum_def
                     ,o.min_sum
                     ,o.max_sum
                     ,o.summ
                     ,o.perc
                     ,c.calc_field calc_field_def
                     ,o.calc_field  -->><<-- ubrr 30.01.2017 �������� �.�.  [16-3223]   #39858  ���������� ������ �� "������������" (���)
                     ,NVL(o.high_border,99999999999) high_border
                     ,nvl(lag(high_border) over (partition by o.otd order by high_border),0)+0.01 low_border
                 FROM ubrr_data.ubrr_rko_tarif c,
                      ubrr_data.ubrr_rko_tarif_otdsum o
                WHERE c.Id=vId
                  AND c.Id = o.id_com
                  AND o.otd = p_Otd
                  AND p_SumTrn between nvl(min_sum_oper, p_SumTrn) and nvl(max_sum_oper, p_SumTrn) -->><<-- ubrr 18.01.2017 [16-3100.1] #39518 ��������� ���������� �������� �� �������� �����
             )
       WHERE NVL(vSumBefo,0)+0.01 between low_border and high_border;

    l_step:='050'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
-->> �������� �.�. 17-452 https://redmine.lan.ubrr.ru/issues/42479
      IF vMinOtd is not NULL THEN
        vHasMinOtd := TRUE;
      END IF;
      IF vMaxOtd is not NULL THEN
        vHasMaxOtd := TRUE;
      END IF;

    l_step:='060'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
--<<�������� �.�. 17-452 https://redmine.lan.ubrr.ru/issues/42479
      IF vSumBefo+vSumTrn<=vHighB THEN
        vSum1   := vSumTrn;
        vSumTrn := 0;
      ELSE
        vSum1    := vHighB  - vSumBefo;
        vSumTrn  := vSumTrn - vSum1;
        vSumBefo := vSumBefo+vSum1;
      END IF;

      -->> ubrr 30.01.2017 �������� �.�.  [16-3223]   #39858  ���������� ������ �� "������������" (���)
    l_step:='070'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
      IF vCalcField is not null then
        DECLARE
          cursor_name NUMBER;
          rs NUMBER;
        BEGIN
          l_step:='080'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
          cursor_name := DBMS_SQL.OPEN_CURSOR;
          DBMS_SQL.PARSE(cursor_name, vCalcField, DBMS_SQL.NATIVE);
          IF INSTR(lower(vCalcField), ':acc')>0       THEN DBMS_SQL.BIND_VARIABLE(cursor_name, 'acc'      , p_Acc);       END IF;
          IF INSTR(lower(vCalcField), ':ddate')>0     THEN DBMS_SQL.BIND_VARIABLE(cursor_name, 'ddate'    , p_dater);     END IF;
          IF INSTR(lower(vCalcField), ':itrnnum')>0   THEN DBMS_SQL.BIND_VARIABLE(cursor_name, 'itrnnum'  , p_TrnNum);    END IF;
          IF INSTR(lower(vCalcField), ':itrnanum')>0  THEN DBMS_SQL.BIND_VARIABLE(cursor_name, 'itrnanum' , p_TrnANum);   END IF;
          IF INSTR(lower(vCalcField), ':bankidsmr')>0 THEN DBMS_SQL.BIND_VARIABLE(cursor_name, 'BankIdSmr', p_BankIdSmr); END IF;
          IF INSTR(lower(vCalcField), ':mtrnsum')>0   THEN DBMS_SQL.BIND_VARIABLE(cursor_name, 'mtrnsum'  , p_SumTrn);    END IF;
          IF INSTR(lower(vCalcField), ':msumbefo')>0  THEN DBMS_SQL.BIND_VARIABLE(cursor_name, 'msumbefo' , p_SumBefo);   END IF;
          IF INSTR(lower(vCalcField), ':iotdnum')>0   THEN DBMS_SQL.BIND_VARIABLE(cursor_name, 'iotdnum'  , p_Otd);       END IF;

          dbms_sql.define_column( cursor_name, 1, vSumCom1 );
          rs := DBMS_SQL.EXECUTE_AND_FETCH(cursor_name);

          dbms_sql.column_value( cursor_name, 1, vSumCom1 );
          vSumCom := vSumCom + vSumCom1;

          DBMS_SQL.CLOSE_CURSOR(cursor_name);
        EXCEPTION
          WHEN OTHERS THEN
            DBMS_SQL.CLOSE_CURSOR(cursor_name);
            dbms_output.put_line(SQLErrm);

            WriteProtocol(case when p_TrnNum is not null then '��� �������� TrnNum = '||p_TrnNum else '' end ||'��� �������� '||p_TypeCom||' ���� '||p_Acc||' ��������� '||p_Otd||'Id �������� '||vId||' ������ ���������� calc_field');
            RETURN NULL;
        END;
      --<< ubrr 30.01.2017 �������� �.�.  [16-3223]   #39858  ���������� ������ �� "������������" (���)
      ELSIF nvl(vPerc,0) != 0 THEN   -->><<-- ubrr 25.11.2016 �������� �.�. 16-2222.2 ���������� ��������� null
        l_step:='090'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
        vSumCom1 := vSum1*vPerc/100;
        vSumCom1 := GREATEST(vSumCom1, vMin);
        IF vMax>0 THEN
          vSumCom1 := LEAST(vSumCom1, vMax);
        END IF;
        vSumCom := vSumCom+vSumCom1;
        IF nvl(p_mtarifprc,-1)=0 AND nvl(p_mtarif,-1)=0 THEN
          p_mtarifprc := vPerc;
        ELSE
          p_mtarifprc := NULL;
        END IF;
      ELSE
        l_step:='100'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
        vSumCom := vSumCom+nvl(vSum,0);  -->><<-- ubrr 25.11.2016 �������� �.�. 16-2222.2 ���������� ��������� null
        IF nvl(p_mtarifprc,-1)=0 AND nvl(p_mtarif,-1)=0 THEN
          p_mTarif := nvl(vSum,0);  -->><<-- ubrr 25.11.2016 �������� �.�. 16-2222.2 ���������� ��������� null
        ELSE
          p_mtarif := NULL;
        END IF;
      END IF; -- IF vCalcField is not null
      IF vSumTrn=0 THEN
        EXIT;
      END IF;
    END LOOP;
    -->> �������� �.�. 17-452 https://redmine.lan.ubrr.ru/issues/42479
    l_step:='110'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    IF NOT vHasMinOtd or NOT vHasMaxOtd THEN
      SELECT min_sum
            ,max_sum
        INTO vMin
            ,vMax
        FROM ubrr_data.ubrr_rko_tarif c
       WHERE c.Id=vId;

      IF NOT vHasMinOtd and nvl(vMin,0)>0 THEN
        vSumCom := GREATEST(vSumCom, vMin);
      END IF;
      IF NOT vHasMaxOtd and nvl(vMax,0)>0 THEN
        vSumCom := LEAST(vSumCom, vMax);
      END IF;
    END IF;
    --<< �������� �.�. 17-452 https://redmine.lan.ubrr.ru/issues/42479

    RETURN ROUND(vSumCom,2);
-->> 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    exception when others then
       -- >> 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
       writeprotocol('Error in '  ||$$plsql_unit||'.GetSumComiss ['||
                              'p_TrnNum='   ||p_TrnNum    ||';'||
                              'p_TrnAnum='  ||p_TrnAnum   ||';'||
                              'p_Acc='      ||p_Acc       ||';'||
                              'p_Cur='      ||p_Cur       ||';'||
                              'p_Otd='      ||p_Otd       ||';'||
                              'p_TypeCom='  ||p_TypeCom   ||';'||
                              'p_SumTrn='   ||p_SumTrn    ||';'||
                              'p_SumBefo='  ||p_SumBefo   ||';'||
                              'vSumBefo='   ||vSumBefo    ||';'||
                              'p_BankIdSmr='||p_BankIdSmr ||';'||
                              'p_dater='    ||to_char(p_dater,'dd.mm.yyyy') ||';'||
                              'vId='        ||vId         ||';'||
                              '](l_step='   ||l_step||')'||
                              dbms_utility.format_error_backtrace || ' ' ||
                              sqlerrm
                    );
       return null;
       -- << 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
--<< 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
  end getsumcomiss;

-----------------------------------------------------------------------------
-->>09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
function GetSumComiss_Uniq( p_TrnNum      in trn.itrnnum%type
                           ,p_TrnAnum     in trn.itrnanum%type
                           ,p_Acc         in acc.caccacc%type
                           ,p_Cur         in acc.cacccur%type
                           ,p_Otd         in acc.iaccotd%type
                           ,p_TypeCom     in varchar2
                           ,p_SumTrn      in number
                           ,p_SumBefo     in number default null
                           ,p_g_tarif_id  in out integer
                           ,p_mtarif      in out number  -- ���������� � ��������� ��� UpdateAccComiss
                           ,p_mtarifPrc   in out number  -- ���������� � ��������� ��� UpdateAccComiss
                           ,p_BankIdSmr   in varchar2
                           ,p_dater       in date )
  return number
  IS

  cursor cur_acc is
  select iaccotd
    from acc
   where caccacc = p_Acc
     and cacccur = p_Cur;

  vId        NUMBER;
  vSumCom    NUMBER;
  vSumCom1   NUMBER;
  vSum       NUMBER;
  vPerc      NUMBER;
  vMin       NUMBER;
  vMax       NUMBER;
  vSumBefo   NUMBER := NVL(p_SumBefo,0);
  vLowB      NUMBER;
  vHighB     NUMBER;
  vSumTrn    NUMBER := NVL(p_SumTrn,0);
  vSum1      NUMBER;
  vCalcField UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.CALC_FIELD%TYPE;

  vMinOtd    NUMBER;
  vMaxOtd    NUMBER;
  vHasMinOtd BOOLEAN := FALSE;
  vHasMaxOtd BOOLEAN := FALSE;

  l_step     varchar2(4):='000';
  l_acc_otd      acc.iaccotd%type;
  l_count_loop   NUMBER := 0;

BEGIN

  if p_Otd is null then
    open cur_acc;
    fetch cur_acc into l_acc_otd;
    close cur_acc;
  else
    l_acc_otd := p_Otd;
  end if;

  p_g_tarif_id := null;
  vSumCom := 0;

  IF ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_id_check = 'Y' THEN
    vId := GetTarifId (p_Acc, p_Cur, l_acc_otd, p_TypeCom, 1, p_BankIdSmr, p_dater);

    l_step:='010';
    IF vId = 0 THEN
      vId := GetTarifId (p_Acc, p_Cur, l_acc_otd, p_TypeCom, 0, p_BankIdSmr, p_dater);
    END IF;

    l_step:='020';
    IF vId = 0 THEN
      WriteProtocol(case when p_TrnNum is not null then '��� �������� TrnNum = '||p_TrnNum else '' end ||'��� �������� '||p_TypeCom||' ���� '||p_Acc||' ��������� '||l_acc_otd||' ��� �������� '||p_TypeCom||' �� ����������� �����/������� �������� � UBRR_BNKSERV_CALC_NEW_LIB.GetSumComiss_Uniq');
      RETURN NULL;
    END IF;
  END IF;

  p_g_tarif_id := vId;
  p_mtarif     := 0;
  p_mtarifPrc  := 0;

  l_step:='030';
  LOOP

    l_step:='040';

    SELECT case when summ IS NULL AND perc IS NULL AND calc_field IS NULL THEN summ_def ELSE summ END,
           case when summ IS NULL AND perc IS NULL AND calc_field IS NULL THEN perc_def ELSE perc END,
           calc_field,
           NVL(case when summ IS NULL AND perc IS NULL AND calc_field IS NULL THEN min_sum_def ELSE min_sum END, 0),
           NVL(case when summ IS NULL AND perc IS NULL AND calc_field IS NULL THEN max_sum_def ELSE max_sum END, 999999999999),
           low_border,
           high_border,
           min_sum,
           max_sum
      INTO vSum,
           vPerc,
           vCalcField,
           vMin,
           vMax,
           vLowB,
           vHighB,
           vMinOtd,
           vMaxOtd
      FROM (
            SELECT c.summ_def,
                   c.perc_def,
                   c.min_sum min_sum_def,
                   c.max_sum max_sum_def,
                   o.min_summ min_sum,
                   o.max_summ max_sum,
                   o.summ,
                   o.perc,
                   c.calc_field,
                   coalesce(o.high_border,99999999999) high_border,
                   coalesce(lag(high_border) over (partition by o.uuac_id order by high_border),0)+ 0.01 low_border
               FROM UBRR_DATA.UBRR_UNIQUE_TARIF_ACC a,
                    UBRR_DATA.UBRR_UNIQUE_ACC_COMMS c,
                    UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM o
              WHERE a.cacc = p_Acc
                AND p_dater between a.DOPENTARIF and a.DCANCELTARIF
                AND a.idsmr = SYS_CONTEXT ('B21','IDSmr')
                AND a.status = 'N'
                AND a.uuta_id = c.uuta_id
                AND c.com_type = p_TypeCom
                AND c.daily like ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_day
                AND c.uuac_id = o.uuac_id(+)
                AND coalesce(p_SumTrn,0) between coalesce(o.min_summ_oper, coalesce(p_SumTrn,0)) and coalesce(o.max_summ_oper, coalesce(p_SumTrn,0))
           )
     WHERE coalesce(vSumBefo,0)+0.01 between low_border and high_border;

    l_step:='050';
    IF vMinOtd is not NULL THEN
      vHasMinOtd := TRUE;
    END IF;
    IF vMaxOtd is not NULL THEN
      vHasMaxOtd := TRUE;
    END IF;

    l_step:='060';
    IF vSumBefo+vSumTrn<=vHighB THEN
      vSum1   := vSumTrn;
      vSumTrn := 0;
    ELSE
      vSum1    := vHighB  - vSumBefo;
      vSumTrn  := vSumTrn - vSum1;
      vSumBefo := vSumBefo + vSum1;
    END IF;

    l_step:='070';
    IF vCalcField is not null then

      DECLARE
        cursor_name NUMBER;
        rs NUMBER;
      BEGIN
        l_step:='080';
        cursor_name := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(cursor_name, vCalcField, DBMS_SQL.NATIVE);
        IF INSTR(lower(vCalcField), ':acc')>0       THEN DBMS_SQL.BIND_VARIABLE(cursor_name, 'acc'      , p_Acc);       END IF;
        IF INSTR(lower(vCalcField), ':ddate')>0     THEN DBMS_SQL.BIND_VARIABLE(cursor_name, 'ddate'    , p_dater);     END IF;
        IF INSTR(lower(vCalcField), ':itrnnum')>0   THEN DBMS_SQL.BIND_VARIABLE(cursor_name, 'itrnnum'  , p_TrnNum);    END IF;
        IF INSTR(lower(vCalcField), ':itrnanum')>0  THEN DBMS_SQL.BIND_VARIABLE(cursor_name, 'itrnanum' , p_TrnANum);   END IF;
        IF INSTR(lower(vCalcField), ':bankidsmr')>0 THEN DBMS_SQL.BIND_VARIABLE(cursor_name, 'BankIdSmr', p_BankIdSmr); END IF;
        IF INSTR(lower(vCalcField), ':mtrnsum')>0   THEN DBMS_SQL.BIND_VARIABLE(cursor_name, 'mtrnsum'  , p_SumTrn);    END IF;
        IF INSTR(lower(vCalcField), ':msumbefo')>0  THEN DBMS_SQL.BIND_VARIABLE(cursor_name, 'msumbefo' , p_SumBefo);   END IF;
        IF INSTR(lower(vCalcField), ':iotdnum')>0   THEN DBMS_SQL.BIND_VARIABLE(cursor_name, 'iotdnum'  , l_acc_otd);       END IF;

        dbms_sql.define_column( cursor_name, 1, vSumCom1 );
        rs := DBMS_SQL.EXECUTE_AND_FETCH(cursor_name);

        dbms_sql.column_value( cursor_name, 1, vSumCom1 );
        vSumCom := vSumCom + vSumCom1;

        DBMS_SQL.CLOSE_CURSOR(cursor_name);
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_SQL.CLOSE_CURSOR(cursor_name);
          dbms_output.put_line(SQLErrm);

          WriteProtocol(case when p_TrnNum is not null then '��� �������� TrnNum = '||p_TrnNum else '' end ||'��� �������� '||p_TypeCom||' ���� '||p_Acc||' ��������� '||l_acc_otd||'Id �������� '||vId||' ������ ���������� calc_field � UBRR_BNKSERV_CALC_NEW_LIB.GetSumComiss_Uniq');
          RETURN NULL;
      END;

    ELSIF nvl(vPerc,0) != 0 THEN

      l_step:='090';
      vSumCom1 := vSum1*vPerc/100;
      vSumCom1 := GREATEST(vSumCom1, vMin);
      IF vMax>0 THEN
        vSumCom1 := LEAST(vSumCom1, vMax);
      END IF;
      vSumCom := vSumCom+vSumCom1;
      IF nvl(p_mtarifprc,-1) = 0 AND nvl(p_mtarif,-1) = 0 THEN
        p_mtarifprc := vPerc;
      ELSE
        p_mtarifprc := NULL;
      END IF;

    ELSE

      l_step:='100';
      vSumCom := vSumCom+nvl(vSum,0);
      IF nvl(p_mtarifprc,-1) = 0 AND nvl(p_mtarif,-1) = 0 THEN
        p_mTarif := nvl(vSum,0);
      ELSE
        p_mtarif := NULL;
      END IF;
    END IF;

    IF vSumTrn = 0 THEN
      EXIT;
    END IF;

    IF l_count_loop = 1000 THEN
      EXIT;
    END IF;

  END LOOP;

  l_step:='110';
  IF NOT vHasMinOtd or NOT vHasMaxOtd THEN
    SELECT min_sum
          ,max_sum
      INTO vMin
          ,vMax
      FROM UBRR_DATA.UBRR_UNIQUE_TARIF_ACC a,
           UBRR_DATA.UBRR_UNIQUE_ACC_COMMS c
     WHERE a.cacc = p_Acc
       AND p_dater between a.DOPENTARIF and a.DCANCELTARIF
       AND a.idsmr = SYS_CONTEXT ('B21','IDSmr')
       AND a.status = 'N'
       AND a.uuta_id = c.uuta_id
       AND c.com_type = p_TypeCom
       AND c.daily like ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_day;

    IF NOT vHasMinOtd and nvl(vMin,0)>0 THEN
      vSumCom := GREATEST(vSumCom, vMin);
    END IF;

    IF NOT vHasMaxOtd and nvl(vMax,0)>0 THEN
      vSumCom := LEAST(vSumCom, vMax);
    END IF;
  END IF;

  RETURN ROUND(vSumCom,2);

exception
  when others then
   writeprotocol('Error in '  ||$$plsql_unit||'.GetSumComiss_Uniq ['||
                          'p_TrnNum='   ||p_TrnNum    ||';'||
                          'p_TrnAnum='  ||p_TrnAnum   ||';'||
                          'p_Acc='      ||p_Acc       ||';'||
                          'p_Cur='      ||p_Cur       ||';'||
                          'l_acc_otd='  ||l_acc_otd       ||';'||
                          'p_TypeCom='  ||p_TypeCom   ||';'||
                          'p_SumTrn='   ||p_SumTrn    ||';'||
                          'p_SumBefo='  ||p_SumBefo   ||';'||
                          'vSumBefo='   ||vSumBefo    ||';'||
                          'p_BankIdSmr='||p_BankIdSmr ||';'||
                          'p_dater='    ||to_char(p_dater,'dd.mm.yyyy') ||';'||
                          'vId='        ||vId         ||';'||
                          '](l_step='   ||l_step||')'||
                          dbms_utility.format_error_backtrace || ' ' ||
                          sqlerrm
                );
   return null;
end GetSumComiss_Uniq;
--<<09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��

----------------------------------------------------------------------
-- ����������� ������� �������� �2 ��� �1 ������ ������
function have_kartoteka( p_caccacc   in varchar2
                        ,p_cacccur   in varchar2
                        ,p_date_tran in date )
return boolean
is
   l_cnt pls_integer:= 0;
begin
    select count(1)
      into l_cnt
      from dual
     where exists ( select 1
                      from trc t
                     where t.ctrcaccd   = p_caccacc
                       and t.ctrccur    = p_cacccur
                       and t.ctrcstate  = '2'
                       and t.mtrcleft   > 0
                       and t.dtrccreate <= add_months(p_date_tran,-1)
                  );
    -- >> 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
    if l_cnt = 0 then  -- ��� �2 ������ ������, �������� ������� � �1 ���������������� ����������
       select count(1)
         into l_cnt
         from dual
        where exists( select 1
                        from trc c
                            ,acc ac
                       where c.ctrcaccd = ac.caccacc
                         and c.ctrccur  = ac.cacccur
                         and c.ctrcaccd       = p_caccacc
                         and c.ctrccur        = p_cacccur
                         and c.ctrcstate      = '1'
                         and c.mtrcleft       > 0
                         and c.dtrccreate     <= add_months(p_date_tran,-1)
                         and exists( select 1
                                       from trn t
                                           ,acc an
                                      where t.ctrnaccd = an.caccacc
                                        and t.ctrncur  = an.cacccur
                                        --and t.dtrntrn_trunc <= p_date_tran  -- ��������� �� ������ : ������� ������ ������
                                        and t.itrnnumanc     = c.itrcnum
                                        and t.ctrnaccd  like '90901%'
                                        and an.iacccus = ac.iacccus -- ������ 90901 ������� ��� � � p_caccacc
                                   )
                    );
    end if;
    -- << 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
    return ( l_cnt=1 );
end have_kartoteka;

----------------------------------------------------------------------------
-- ����������� ����� �������� ������� �� ������� �����
-- ���������� �� ubrr_bnkserv_calc_new
  procedure AnalizeClient( p_Client     in cus.icusnum%TYPE
                          ,p_dat_beg    in date
                          ,p_dat_end    in date
                          ,p_dtran      in date
                          ,p_calc_table in pls_integer default gc_calc_table_sbs_new )
  IS
    ost_vr    Number;
    ost_rr    Number;
    ost_vp    Number;
    deb_dark  Number;
    cred_dark Number;
    AccR      acc%ROWTYPE;
    IsBlock   BOOLEAN := FALSE;
    type t_tAcc Is record ( caccacc    acc.caccacc%TYPE
                           ,cacccur    acc.cacccur%TYPE
                           ,FreeRestR  number
                           ,NewAcc     acc.caccacc%TYPE
                           ,NewCur     acc.cacccur%TYPE
                           ,IsBlocked  BOOLEAN
                           ,SumCom     number
                           ,RowIdSBS   ROWID
                           ,ComTypeSBS ubrr_rko_com_types.com_type%type ); -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
    type t_tAcc_Table is Table of t_tAcc index by binary_integer;
    tAccList t_tAcc_Table;

    vSumAr       NUMBER           ;
    vNum         NUMBER  :=0      ;
    vNewNum      NUMBER           ;
    vHaveFreeAcc BOOLEAN := FALSE ;
    vSumCom      NUMBER  :=0      ;
    l_com_type   ubrr_rko_com_types.com_type%type;  -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
    vRowID       ROWID            ;
    vRest1       NUMBER           ;
    vHasKrt      NUMBER           ;
    vNeedAcc     VARCHAR2(20)     ;
    TekStat      VARCHAR2(1)      ;
    l_cnt        integer          ; --10.11.17 �������� �.�. [17-1447] ���: �������� �������� ����������� �������� �� ������� ����� (���)
    l_step       varchar2(4):='000';
    l_idx        pls_integer;  -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
    -- >> 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
    procedure get_rowdata_from_calc_table( p_date       in  date default null
                                          ,p_acc        in  varchar2
                                          ,p_cur        in  acc.cacccur%type
                                          ,p_rowid      out rowid
                                          ,p_sum        out number
                                          ,p_com_type   out varchar2
                                          ,p_calc_table in  pls_integer default gc_calc_table_sbs_new )
    is
    begin
       if ( p_calc_table = gc_calc_table_sbs ) then
          ---------------------------------------------
          begin
              select a.msbstoll_sum
                    ,rowid
                    ,a.CSBSDO
                into p_sum
                    ,p_rowid
                    ,p_com_type
                from sbs a
               where (  a.cSBSDO like 'R_EKV__'
                     or a.cSBSDO like 'RKB_'
                     or a.cSBSDO like 'REB_'
                     or a.cSBSDO in ('RKO','REO','R_EXP','REB_PE') )
                 and a.csbsacc      = p_acc
                 and a.csbscur      = p_cur
                 and a.idsmr        = sys_context('B21','IdSmr')
                 and a.csbspayfrom_cur is null  -- TRN,TRC,ERC, null
                 and a.msbstoll_sum > 0;
          exception
                when no_data_found then
                  p_sum      := 0;
                  p_rowid    := null;
                  p_com_type := null;
          end;
       else ---------------------------------------------
          begin
              select mSBSsumcom
                    ,rowid
                    ,csbstypecom
                into p_sum
                    ,p_rowid
                    ,p_com_type
                from ubrr_data.ubrr_sbs_new
               where dSBSDate   = p_date
                 and IdSmr      = sys_context('B21','IDSMR')
                 and cSBSTypeCom in ('RKO', 'RKB')
                 and cSBSaccd   = p_acc
                 and cSBScurd   = p_cur
                 and ISBSTRNNUM is null
                 and mSBSSumCom > 0;
          exception
                when no_data_found then
                  p_sum      := 0;
                  p_rowid    := null;
                  p_com_type := null;
          end;
      end if;
    end get_rowdata_from_calc_table;
    -- ���������� � sbs(new)
    procedure update_calc_table_sumstat( p_rowid      in rowid
                                        ,p_sum        in number
                                        ,p_str        in varchar2
                                        ,p_com_type   in varchar2    default null
                                        ,p_calc_table in pls_integer default gc_calc_table_sbs_new )
    is
    begin
       if ( p_calc_table = gc_calc_table_sbs ) then
          update sbs b
             set b.MSBSTOLL_SUM = p_sum
                ,b.CSBSDO = b.CSBSDO||' '||p_str  -- ����� p_com_type ������������
           where rowid = p_rowid;
       else
          update ubrr_data.ubrr_sbs_new s
             set s.mSBSsumcom = p_sum
                ,s.cSBSstat   = p_str
           where rowid = p_rowid;
       end if;
    end update_calc_table_sumstat;
    -- ���������� � sbs(new) acc_zam
    procedure update_calc_table_acczam( p_rowid      in rowid
                                       ,p_acc_zam    in varchar2
                                       ,p_cur_zam    in acc.cacccur%type
                                       ,p_calc_table in pls_integer default gc_calc_table_sbs_new )
    is
    begin
       if ( p_calc_table = gc_calc_table_sbs ) then
           update xxi."sbs"
              set CSBSACC_ZAM = p_acc_zam
                 ,CSBSCUR_ZAM = p_cur_zam
           where rowid = p_rowid;
       else
           update ubrr_data.ubrr_sbs_new s
              set cSBSaccd_zam = p_acc_zam
                 ,cSBScurd_zam = p_cur_zam
           where rowid = p_rowid;
       end if;
    end update_calc_table_acczam; -- << 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
  BEGIN   --------------------------- AnalizeClient ----------------------------
    FOR RR IN
      (select caccacc
             ,cacccur
             ,iaccbs2
             ,caccprizn
             ,caccap
       from acc
       where iacccus = p_client
         and acc.cacccur = 'RUR'
         and acc.cACCprizn <> '�'
         and (substr(acc.caccacc,1,3) in ('401','402','403','404','405', '406', '407')
              or acc.iaccbs2 in (40802, 40807, 40821)--, 42309)
              or acc.caccacc in (select acc from ubrr_rvk_acc_wr w, ubrr_smr s where w.cusnum = acc.iacccus and w.calc_type = 2 and w.idsmr = s.idsmr))
         and not exists (select 1
                          from gac
                         where cgacacc = acc.cACCacc
                           and igaccat = 112
                           and igacnum = 1014  -- ��� �� �������
                           and exists (select 1
                                         from xxi.au_attach_obg au
                                        where au.caccacc = acc.cACCacc
                                          and au.cacccur = acc.cACCcur
                                          and i_table = 304
                                          and d_create <= p_dat_end
                                          and au.c_newdata = '112/1014'))
         and not exists (select 1
                          from gac
                         where cgacacc = acc.cACCacc
                           and igaccat = 112
                           and igacnum = 10)
         and not exists (select 1
                          from gac
                         where cgacacc = acc.cACCacc
                           and igaccat = 333
                           and igacnum = 2)
       order by decode(cacccur, 'RUR', '1', '2')
    )LOOP
      /*IF vHaveFreeAcc AND rr.cacccur!='RUR' THEN --���� �������������� �������� ���� - �������� �� �������
        exit;
      END IF;*/
      IsBlock := FALSE;
      -- >> 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
      l_step:='010';
      get_rowdata_from_calc_table( p_date       => p_dat_end
                                  ,p_acc        => rr.caccacc
                                  ,p_cur        => rr.caccCur
                                  ,p_rowid      => vRowID
                                  ,p_sum        => vSumCom
                                  ,p_com_type   => l_com_type
                                  ,p_calc_table => p_calc_table );
      -- << 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���

      l_step:='020'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
      IF RR.iaccbs2 in (42309, 40821) THEN  --�� ������ 40821 � 42309 �������� �� ������, ������� ��� ����� ��� �������������
        IsBlock := TRUE;
      ELSE
        -->> 10.11.17 �������� �.�. [17-1447] ���: �������� �������� ����������� �������� �� ������� ����� (���)
        /*
        IF rr.caccprizn IN ('�','�','�') then
          IsBlock := TRUE;
          TekStat := rr.caccprizn;
          FOR RR1 IN (SELECT * FROM ach
                      where cachacc = rr.caccacc
                        and cachcur = rr.caccCur
                      order by dachdate desc
          ) LOOP
            IF NVL(RR1.cachbase, '$') NOT LIKE '***%' then
              EXIT;
            END IF;
            TekStat := NVL(RR1.cachflag, '$');
            IF TekStat = '�' then
              IsBlock := FALSE;
              EXIT;
            END IF;
          END LOOP;
        END IF;
        */
        IF rr.caccprizn IN ('�','�') then
           IsBlock := TRUE;
        END IF;

        -- � - ������������� ������ ���� ���� ������������ ��������������� ���
        l_step:='030'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
        IF rr.caccprizn IN ('�') then
          select sign(count(1))
          into l_cnt
          from dual
          where exists (
              select null
              from ach h
              where cachacc = rr.caccacc and cachcur = rr.cacccur
                and h.cachflag <> '�'  -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
                and -- ������� ��������������� ���
                  ( regexp_like (upper(nvl(cachbase,'$')),'(.*(��|��(�|�)|�\.).*\d{1,}.*|(^\d{1,}.*)(|((�|N).*\d{1,}))).*(��|JN)\s*\d{2}(,|\.|\/|\\)\d{2}(,|\.|\/|\\)\d.*')
                    or regexp_like (upper(nvl(cachbase,'$')),'(�����(\.|\s)|�����������).*���')
                    or upper(nvl(cachbase,'$')) like '%���%'
                    or upper(nvl(cachbase,'$')) like '% ���%'
                    or upper(nvl(cachbase,'$')) like '��� ��%'
                    or upper(nvl(cachbase,'$')) like '%����%'
                  )
                and not upper(nvl(cachbase,'$')) like '%���%' and not upper(nvl(cachbase,'$')) like '%CDR%'
                and not upper(nvl(cachbase,'$')) like '%���%'
                and not regexp_like (upper(nvl(cachbase,'$')),'\d{4}-\d{2}\/\d{6}')
                -- ��������� ������� ������ ���
                and not regexp_like (upper(nvl(cachbase,'$')),'(���.*(|(�|N)).*\d{1,}.*(��|JN))|((�|J)�����)')
              );
          IF l_cnt = 1 THEN
            IsBlock := TRUE;
          END IF;
        END IF;
        --<<  10.11.17 �������� �.�. [17-1447] ���: �������� �������� ����������� �������� �� ������� ����� (���)
      END IF;

      l_step:='040'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
      IF IsBlock AND vRowID IS NULL THEN  -- ���� ������������/��������� � ��� �������� �� ����
        CONTINUE;
      END IF;
      /*IF NOT IsBlock THEN  -- �� ������������, �������� ������������ ����� � ���������������
        SELECT Count(*)
        INTO vHasKrt
        FROM acc_over_sum
        where caosacc = rr.caccacc
          and caoscur = rr.caccCur
          and daosdelete is null
          and caoscomment not like '***%'
          and (caossumtype = 'O' and maossumma<0 or caossumtype = 'B' and maossumma>0);
        IF vHasKrt>0 THEN
          isBlock := TRUE;
        END IF;
      END IF;*/

      l_step:='050'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
      IF NOT IsBlock THEN  -- �� ������������, �������� ���������
      -- >> 19.09.2018 ubrr rizanov [18-251] ���: ����� ���������� �� �������� �� ������� � ������ �� ("���������")
        IF ubrr_bnkserv_calc_new_lib.have_kartoteka( p_caccacc   => rr.caccacc   -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
                                                    ,p_cacccur   => rr.caccCur
                                                    ,p_date_tran => p_dTran
                                                   ) THEN   -- ���� �2 ��� �1 ������ ������
         -- << 19.09.2018 ubrr rizanov [18-251] ���: ����� ���������� �� �������� �� ������� � ������ �� ("���������")
          isBlock := TRUE;
        END IF;
      END IF;
      IF NOT IsBlock THEN
        vHaveFreeAcc := TRUE;
      END IF;

      l_step:='060'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
      vSumAr := 0;
      ost_rr := 0;
      IF NOT IsBlock then  -- � ��������������� ������ �������� �� ������, ������� �� �����
        SELECT nvl(sum(-maossumma),0)
        INTO vSumAr
        FROM acc_over_sum
        where caosacc = rr.caccacc
          and caoscur = rr.caccCur
          and daosdelete is null
          and caossumtype = 'O' and maossumma<0;
        SELECT vSumAr+nvl(sum(maossumma),0)
        INTO vSumAr
        FROM acc_over_sum
        where caosacc = rr.caccacc
          and caoscur = rr.caccCur
          and daosdelete is null
          and caossumtype = 'B';
        UTIL_DM2.Acc_Ost2(0, RR.caccacc, rr.cacccur, p_dtran,
                          ost_vr, ost_rr, ost_vp, deb_dark, cred_dark);
        IF rr.caccap='�' THEN
          ost_vr := -ost_vr;
          ost_rr := -ost_rr;
          ost_vp := -ost_vp;
        END IF;
      END IF;
      l_step:='070'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
      vNum :=vNum+1;
      tAccList(vNum).caccacc   := rr.caccacc;
      tAccList(vNum).cacccur   := rr.cacccur;
      tAccList(vNum).FreeRestR := ost_rr - vSumAr - vSumCom;
      tAccList(vNum).SumCom    := vSumCom;
      tAccList(vNum).RowIDSBS  := vRowID;
      tAccList(vNum).ComTypeSBS:= l_com_type;
      tAccList(vNum).IsBlocked := isBlock;
    END LOOP;

    -- >> 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
    l_step:='080';
    IF NOT vHaveFreeAcc THEN  --��� ��������� ������
      l_idx:= tAccList.first;
      while (l_idx is not null)
      loop
        IF tAccList(l_idx).SumCom > 0 Then
          l_step:='090';
          update_calc_table_sumstat( p_rowid      => tacclist(l_idx).rowidsbs
                                    ,p_sum        => 0
                                    ,p_str        => '��� �� ������ ���������� �����. �������� �� �������������'
                                    ,p_com_type   => tacclist(l_idx).ComTypeSBS
                                    ,p_calc_table => p_calc_table );

        END IF;
        l_idx:=tAccList.next(l_idx);
      end loop;
    -- << 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
    ELSE
       l_step:='100'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
       FOR i In tAccList.first..tAccList.last Loop  --��������� ��������� ���� ��� ��������
         -- >> 19.09.2018 ubrr rizanov [18-251] ���: ����� ���������� �� �������� �� ������� � ������ �� ("���������")
         if ( ubrr_bnkserv_calc_new_lib.have_kartoteka( p_caccacc   => tAccList(i).caccacc -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
                                                       ,p_cacccur   => tAccList(i).cacccur
                                                       ,p_date_tran => p_dtran ) ) then
              tAccList(i).SumCom := 0;
              l_step:='110'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
              update_calc_table_sumstat( p_rowid      => tacclist(i).rowidsbs  -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
                                        ,p_sum        => 0
                                        ,p_str        => '���� ��������� ����� ������ �����. �������� �� �������������'
                                        ,p_com_type   => tacclist(i).ComTypeSBS
                                        ,p_calc_table => p_calc_table );
         end if;
         -- << 19.09.2018 ubrr rizanov [18-251] ���: ����� ���������� �� �������� �� ������� � ������ �� ("���������")
         l_step:='120'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
         IF tAccList(i).SumCom > 0 and (tAccList(i).FreeRestR<0 or tAccList(i).IsBlocked) Then
           vNewNum := 0;
           vRest1 := 0;
           if tAccList(i).caccacc like '42309%' then
             vNeedAcc := ubrr_rko.f_otheracc(tAccList(i).caccacc, tAccList(i).cacccur,2);
             if vNeedAcc is Null then    -- ��� ����� �������� ��� 42309
               tAccList(i).SumCom := 0;
               l_step:='130'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
               update_calc_table_sumstat( p_rowid     => tacclist(i).rowidsbs  -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
                                        ,p_sum        => 0
                                        ,p_str        => '��� ����� �������� ��� 42309. �������� �� �������������'
                                        ,p_com_type   => tacclist(i).ComTypeSBS
                                        ,p_calc_table => p_calc_table );
             end if;
           end if;
           l_step:='140'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
           For j In tAccList.first..tAccList.last Loop
             if j=i then continue; end if;
             if tAccList(i).caccacc like '42309%' and vNeedAcc = tAccList(j).caccacc then
               if tAccList(j).IsBlocked then
                 tAccList(i).SumCom := 0;
                 l_step:='150'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
                 update_calc_table_sumstat( p_rowid      => tacclist(i).rowidsbs  -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
                                           ,p_sum        => 0
                                           ,p_str        => '���� �������� ��� 42309 �������������/���������. �������� �� �������������'
                                           ,p_com_type   => tacclist(i).ComTypeSBS
                                           ,p_calc_table => p_calc_table );
                 vNewNum := 0;
               else
                 vNewNum := j;
                 vRest1 := tAccList(j).FreeRestR;
               end if;
               EXIT;
             end if;
             l_step:='160'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
             if tAccList(i).caccacc not like '42309%' then
               if tAccList(j).FreeRestR>vRest1 and not tAccList(j).IsBlocked and tAccList(j).FreeRestR>tAccList(i).SumCom then
                 vNewNum := j;
                 vRest1 := tAccList(j).FreeRestR;
               end if;
             end if;
           end loop;
           l_step:='170'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
           IF vNewNum = 0 AND tAccList(i).caccacc like '42309%' THEN
             update_calc_table_sumstat( p_rowid      => tacclist(i).rowidsbs  -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
                                       ,p_sum        => 0
                                       ,p_str        => '���� �������� ��� 42309 �� ������ ���� �������������/���������. �������� �� �������������'
                                       ,p_com_type   => tacclist(i).ComTypeSBS
                                       ,p_calc_table => p_calc_table );
             tAccList(i).SumCom := 0;
           END IF;

           l_step:='180'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
           if vNewNum>0 then -- ���� ����� ���� � ��������, ����������� ������� �����
             tAccList(vNewNum).FreeRestR := tAccList(vNewNum).FreeRestR - tAccList(i).SumCom;
             l_step:='190'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
             update_calc_table_acczam( p_rowid      => tacclist(i).rowidsbs  -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
                                      ,p_acc_zam    => tAccList(vNewNum).caccacc
                                      ,p_cur_zam    => tAccList(vNewNum).cacccur
                                      ,p_calc_table => p_calc_table );
             tAccList(i).SumCom := 0;
           end if;
         END IF;
       END LOOP;
       -- ���� �� ������ ����� ���� ��� �������� �� �������, �� �� ��������������� ������ ��������� �� ��������� ����
       l_step:='200'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
       FOR i In tAccList.first..tAccList.last Loop
         IF tAccList(i).SumCom > 0 and tAccList(i).IsBlocked Then
           vNewNum := 0;
           vRest1 := -99999999999;
           l_step:='210'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
           For j In tAccList.first..tAccList.last Loop    -- ������ ���������������� ���� � ������������ ��������
             if j=i then continue; end if;
             if tAccList(j).FreeRestR>vRest1 and not tAccList(j).IsBlocked then
               vNewNum := j;
               vRest1 := tAccList(j).FreeRestR;
             end if;
           end loop;
           l_step:='220'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
           tAccList(vNewNum).FreeRestR := tAccList(vNewNum).FreeRestR - tAccList(i).SumCom;
           update_calc_table_acczam( p_rowid      => tacclist(i).rowidsbs  -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
                                    ,p_acc_zam    => tAccList(vNewNum).caccacc
                                    ,p_cur_zam    => tAccList(vNewNum).cacccur
                                    ,p_calc_table => p_calc_table );
           tAccList(i).SumCom := 0;
         END IF;
       END LOOP;
    END IF;

    l_step:='300'; -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���

    COMMIT;
  -- >> 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
  exception when others then
       writeprotocol('Error in '    ||$$plsql_unit||'.AnalizeClient ['||
                     'p_Client='    ||p_Client                        ||';'||
                     'p_dat_beg='   ||to_char(p_dat_beg,'dd.mm.yyyy') ||';'||
                     'p_dat_end='   ||to_char(p_dat_end,'dd.mm.yyyy') ||';'||
                     'p_dtran='     ||to_char(p_dtran  ,'dd.mm.yyyy') ||';'||
                     'p_calc_table='||p_calc_table                    ||';'||
                     '](l_step='    ||l_step||')'||
                     dbms_utility.format_error_backtrace || ' ' ||sqlerrm );
       raise_application_error(-20006,'Error in '||$$plsql_unit||'.AnalizeClient (l_step='||l_step||') '||sqlerrm);
  -- << 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
  END AnalizeClient;

------------------------------------------------------------------------------
  function Analize_Accounts_For_RKO ( portion_date1 in date
                                     ,portion_date2 in date
                                     ,dtran         in date    -- ���� �������� ��������
                                     ,p_ls          in varchar2
                                     ,p_calc_table  in pls_integer default gc_calc_table_sbs_new )
  return number
  is
     l_ret number;
  begin
    -- >> 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
    WriteProtocol('�������� Analize_Accounts_For_RKO ['||
                  'portion_date1='||to_char(portion_date1,'dd.mm.yyyy')||';'||
                  'portion_date2='||to_char(portion_date2,'dd.mm.yyyy')||';'||
                  'dtran='        ||to_char(dtran,'dd.mm.yyyy')        ||';'||
                  'p_ls='         ||p_ls                               ||';'||
                  'p_calc_table=' ||p_calc_table                       ||';');
    if ( p_calc_table = gc_calc_table_sbs ) then
       -----------------------------------------------------------------------------------------
       -- ���� �� ������ ������� � ������ ����������� �������� ����
       for rec in ( select distinct iacccus
                      from acc
                     where (caccacc, cacccur) IN ( select csbsacc
                                                         ,csbscur
                                                     from sbs a
                                                    where (  a.cSBSDO like 'R_EKV__'
                                                          or a.cSBSDO like 'RKB_'
                                                          or a.cSBSDO like 'REB_'
                                                          or a.cSBSDO in ('RKO','REO','R_EXP','REB_PE') )
                                                      and a.idsmr = sys_context('B21','IdSmr')
                                                      and a.csbspayfrom_cur is null  -- TRN,TRC,ERC, null
                                                      and a.msbstoll_sum > 0
                                                      and a.csbsacc like p_ls )
                  )
       loop
           AnalizeClient( p_Client     => rec.iacccus
                         ,p_dat_beg    => portion_date1
                         ,p_dat_end    => portion_date2
                         ,p_dtran      => dtran
                         ,p_calc_table => p_calc_table );
       end loop;

       select count(1)
         into l_ret
         from sbs a
        where (  a.cSBSDO like 'R_EKV__'
              or a.cSBSDO like 'RKB_'
              or a.cSBSDO like 'REB_'
              or a.cSBSDO in ('RKO','REO','R_EXP','REB_PE') )
          and a.idsmr = sys_context('B21','IdSmr')
          and a.csbspayfrom_cur is null  -- TRN,TRC,ERC, null
          and a.msbstoll_sum > 0
          and a.csbsacc like p_ls;

    else -----------------------------------------------------------------------------------------
       -- << 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
       for rr in ( select distinct iacccus
                     from acc
                    where (caccacc, cacccur) IN ( SELECT cSBSaccd, cSBScurd
                                                    FROM ubrr_data.ubrr_sbs_new a
                                                   where dSBSDate = portion_date2
                                                     and a.cSBSTypeCom IN ('RKO', 'RKB')
                                                     and a.idSmr = SYS_CONTEXT('B21','IdSmr')
                                                     and ISBSTRNNUM IS NULL
                                                     and a.mSBSSumCom>0
                                                     and a.csbsaccd like p_ls )
                 )
       loop
           AnalizeClient(rr.iacccus, portion_date1, portion_date2, dtran, p_calc_table); -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
       end loop;

       select count(1)
         into l_ret
         from ubrr_data.ubrr_sbs_new a
        where dSBSDate  = portion_date2
          and a.cSBSTypeCom IN ('RKO', 'RKB') -->><<-- ubrr 23.09.2016 �������� �.�. 16-2222 ��������� ����� ����������� ��������
          and a.idSmr   = SYS_CONTEXT('B21','IdSmr')
          and ISBSTRNNUM IS NULL
          and a.mSBSSumCom>0
          and a.csbsaccd like p_ls;
    end if;

    WriteProtocol('����� ������� ������ �������� ��������� �������� �� ���: '||l_ret);

    return l_ret;
  end Analize_Accounts_For_RKO;

------------------------------------------------------------------------------------
-->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
-- �������� �������� ���������� ��������� � trn � sbs_new
-- �� ���� ���������, �� �������� ����� ��������
-- p_nid - id � sbs_new
function strattrib_trn_sbs_one( p_nsbsid in number )
return varchar2
is
  l_ndoc  number;
  l_nsum  number;
  l_ddate date;
begin
  select t.itrndocnum
        ,t.mtrnsum
        ,t.dtrndoc
    into l_ndoc
        ,l_nsum
        ,l_ddate
    from xxi."trn"    t
        ,ubrr_trn_sbs s
   where s.isbsid          = p_nsbsid
     and s.itrnsbs_trnnum  = t.itrnnum
     and s.itrnsbs_trnanum = t.itrnanum
     and rownum = 1;  -- ����������� ubrr_trn_sbs ��������� ����� ����. ��� ��� ������ isbsid

  return '���� -'            ||to_char(l_ddate,'dd.mm.yyyy')             ||' '||
         '����� - '          ||to_char(l_nsum,'FM999G999G999G999G990D00')||' '||
         '����� ��������� - '||l_ndoc;

  exception when no_data_found then
     return null;

end strattrib_trn_sbs_one;
--<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������

-- >> ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
------------------------------------------------------------------------------------
--  ����������� �������� �� SBS_NEW
-- p_test=0 - �� ������� �������� ����� (�������� ����� ���������������� � �������)
  function Register( p_regdate             in  date
                    ,p_TypeCom             in  number
                    ,p_Mess                out varchar2
                    ,p_portion_date1       in  date   default null
                    ,p_portion_date2       in  date   default null
                    ,p_ls                  in  varchar2
                    ,p_mode_available_rest in boolean default false  -- ubrr 21.02.2019 ������� �.�. [17-1790] ���: ��������� �� ��� ��� ������� ������������ ���������
                    ,p_mode_hold           in boolean default false  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                    ,p_test                in number default 0
                   )
  return number is
    type t_type_cur is ref cursor;
    l_cur         t_type_cur;
    l_rec_sbs_new t_rec_sbs_new;

    l_regres      t_rec_register_result;
    l_common_res  t_rec_register_result;
    l_commit      number:=0;
    acc_1         varchar2(25) := nvl(p_ls, gc_ls); -->><<--14.10.2019 �������� https://redmine.lan.ubrr.ru/issues/67609

    l_regdate     date := p_regdate;  -- ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
  begin
    WriteProtocol('������ ������ ubrr_bnkserv_calc_new_lib.Register');

    l_common_res.l_trn_cnt := 0;
    l_common_res.l_trc_cnt := 0;
    l_common_res.l_err_cnt := 0;

    if not nvl(p_mode_hold,false)  then
       -- ������� ������ �������� (��� ����������� �� ���������� ����������)
       open l_cur for select a.*  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                        from ubrr_data.ubrr_sbs_new a
                       where dSBSDate            = p_portion_date2
                         and a.iSBSTypeCom       = p_TypeCom
                         and a.idSmr             = SYS_CONTEXT('B21','IdSmr')
                         and ISBSTRNNUM IS NULL
                         and nvl(a.mSBSSumCom,0) > 0  -->><<-- ubrr 21.10.2016 �������� �.�. 16-2222.2 ��� ���������������� ����
                         and a.ihold             = gc_sbs_hold_no
                         and (  (     p_TypeCom <> ubrr_xxi5.ubrr_bnkserv_krc.g_icom_type_krs_mng -->>> ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���
                                  and a.csbsaccd like acc_1 ) -->><<--14.10.2019 �������� https://redmine.lan.ubrr.ru/issues/67609
                                or
                                (     p_TypeCom = ubrr_xxi5.ubrr_bnkserv_krc.g_icom_type_krs_mng -- ������� ���
                                  and a.csbsaccd_zam like acc_1 ) -->><<--14.10.2019 �������� https://redmine.lan.ubrr.ru/issues/67609
                             ) --<<< ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���
                         and a.csbsaccc is not null
                         and a.csbsstat is null;  -->> 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
    else
       -- ����������� �� ���������� ����������
       open l_cur for select a.*  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                        from ubrr_data.ubrr_sbs_new a
                       where dSBSDate            = p_portion_date2
                         and a.idSmr             = sys_context('B21','IdSmr')
                         and ISBSTRNNUM IS NULL
                         and nvl(a.mSBSSumCom,0) > 0  -->><<-- ubrr 21.10.2016 �������� �.�. 16-2222.2 ��� ���������������� ����
                         and a.ihold             = gc_sbs_hold_created
                         and (  (     a.iSBSTypeCom <> ubrr_xxi5.ubrr_bnkserv_krc.g_icom_type_krs_mng -->>> ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���
                                  and a.csbsaccd like acc_1 ) -->><<--14.10.2019 �������� https://redmine.lan.ubrr.ru/issues/67609
                                or
                                (     a.iSBSTypeCom = ubrr_xxi5.ubrr_bnkserv_krc.g_icom_type_krs_mng -- ������� ���
                                  and a.csbsaccd_zam like acc_1 ) -->><<--14.10.2019 �������� https://redmine.lan.ubrr.ru/issues/67609
                             ) --<<< ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���
                         and a.csbsaccc is not null
                         and a.csbsstat is null;  -->> 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
    end if;

    loop
       fetch l_cur into l_rec_sbs_new;
       exit when l_cur%notfound;

       -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
       -- ���� ��� �������� "�� �������", �� ���� ���_�� �������� ����� ��� ���� ���_�� ��������� ���������
       -- ������� ��� ��������� � l_rec_sbs_new.dsbsdatereg
       if ( comm_freq_is_timer(l_rec_sbs_new.csbstypecom) ) then
           l_regdate := l_rec_sbs_new.dsbsdatereg;
       end if;
       --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������

       l_regres:=Register_single( p_regdate             => l_regdate   --ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                                 ,p_TypeCom             => l_rec_sbs_new.iSBSTYPECOM
                                 ,p_Mess                => p_Mess
                                 ,p_portion_date1       => p_portion_date1
                                 ,p_portion_date2       => p_portion_date2
                                 ,p_ls                  => acc_1 -->><<--14.10.2019 �������� https://redmine.lan.ubrr.ru/issues/67609
                                 ,p_mode_available_rest => p_mode_available_rest
                                 ,p_mode_hold           => p_mode_hold
                                 ,p_sbs_new             => l_rec_sbs_new
                                 ,p_test                => p_test );

       if ( l_rec_sbs_new.ihold = gc_sbs_hold_created ) then
          -- ��������� �������� ��� ����_���������� � ����������� ����� �����������
          -- �� ������ : ��������� ������ '���������� � �����������'
          null;
--          update ubrr_sbs_new s
--             set s.CSBSSTAT = case when l_regres.l_trn_cnt >0 and l_regres.l_trn_cnt =0 then gc_csbsstat_pass
--                                   when l_regres.l_trc_cnt >0 and l_regres.l_trn_cnt =0 then gc_csbsstat_file2
--                              else s.CSBSSTAT
--                              end
--           where s.id in ( select s1.id
--                             from ubrr_sbs_new s1
--                            where s1.dsbsdate   >=  p_portion_date1
--                              and s1.dsbsdate   <= (p_portion_date2 + 86399/86400)
--                              and s1.idsmr       = sys_context('B21','IdSmr')
--                              and s1.csbstypecom =  l_rec_sbs_new.csbstypecom
--                              and s1.csbsaccd    =  l_rec_sbs_new.csbsaccd
--                              and s1.csbscurd    =  l_rec_sbs_new.csbscurd
--                              and s1.ihold       =  gc_sbs_hold2month
--                              and s1.isbstrnnum  =  l_rec_sbs_new.id  -- ���������� ����. ��������� � ����.
--                         );

       end if;

       l_common_res.l_trn_cnt := l_common_res.l_trn_cnt + l_regres.l_trn_cnt;
       l_common_res.l_trc_cnt := l_common_res.l_trc_cnt + l_regres.l_trc_cnt;
       l_common_res.l_err_cnt := l_common_res.l_err_cnt + l_regres.l_err_cnt;

       l_commit := l_commit + 1;
       if mod(l_commit,100) = 0 then
          commit;
       end if;
    end loop;
    close l_cur;

    commit;

    WriteProtocol('��������� ������ ubrr_bnkserv_calc_new_lib.Register '||
                  'trn_cnt='||l_common_res.l_trn_cnt  ||';'||
                  'trc_cnt='||l_common_res.l_trc_cnt  ||';'||
                  'err_cnt='||l_common_res.l_err_cnt  ||';' );

    if ( l_common_res.l_err_cnt<>0 ) then
       WriteProtocol('������ ��� ����������� ���������� ('||l_common_res.l_err_cnt||' ��.) !!!. �������� ������� ubrr_sbs_new ');
    end if;
    return (l_common_res.l_trn_cnt + l_common_res.l_trc_cnt);
  exception
    when others then
      rollback;
      WriteProtocol('������ ����������� ����������: '||dbms_utility.format_error_backtrace || ' ' ||sqlerrm); -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
      p_Mess := '������ ����������� ����������: '||SQLErrm;
      return - 1;

  end Register;
------------------------------------------------------------------------------------
--  ����������� �������� �� SBS_NEW
-- p_test=0 - �� ������� �������� ����� (�������� ����� ���������������� � �������)
  function Register_single( p_regdate             in  date
                           ,p_TypeCom             in  number
                           ,p_Mess                out varchar2
                           ,p_portion_date1       in  date   default null
                           ,p_portion_date2       in  date   default null
                           ,p_ls                  in  varchar2
                           ,p_mode_available_rest in boolean default false  -- ubrr 21.02.2019 ������� �.�. [17-1790] ���: ��������� �� ��� ��� ������� ������������ ���������
                           ,p_mode_hold           in boolean default false  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                           ,p_sbs_new             in t_rec_sbs_new
                           ,p_test                in number default 0
                          )
  return t_rec_register_result is
    lc_idsmr_vuz  constant smr.idsmr%type := ubrr_util.vuzb_idsmr;
    rvDocument    UBRR_ZAA_COMMS.rtDocument;
    rvRetDoc      UBRR_ZAA_COMMS.rtRetDoc;
    Succ_Proc_Cnt number;
    Card_Proc_Cnt number;
    Err_Proc_Cnt  number;
    vcPrimAcc     varchar2(25);
    vAccName      xxi."acc".caccname%type;
    v_PrevIdSmr   ubrr_data.ubrr_ulfl_tab_acc_coms.idsmr%type;
    cPurpDog      VARCHAR2(100);
    cPurpDog1     VARCHAR2(100);
    vRegUser      xxi.usr.cusrlogname%type;
    vRegUser1     xxi.usr.cusrlogname%type;  -->><<-- ubrr 23.09.2016 �������� �.�. 16-2222 ��������� ������������ ��� ��������
    cAccSio       acc.caccsio%TYPE;
    dACClastoper  acc.dACClastoper%TYPE;
    cCommTP       varchar2(100);
    --vPack         varchar2(255);
    Dummy         number;
    -->> ������ UBRR 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������
    ---- ���������� ��� ����������� �������������� ������:  -----
    s_idsmr       smr.idsmr%type := SYS_CONTEXT('B21','IdSmr'); -- ��� ����. IDSMR
    d_idsmr       smr.idsmr%type := SYS_CONTEXT('B21','IdSmr'); -- IDSMR ������   (select idsmr from xxi."acc" a where a.caccacc = x.CSBSACCD and a.caccprizn <> '�') idsmr_cassa              ; ���������� ���� �������
    c_idsmr       smr.idsmr%type := SYS_CONTEXT('B21','IdSmr'); -- IDSMR �������  (select idsmr from xxi."acc" a where a.caccacc = x.CSBSACCC and a.caccprizn <> '�') idsmr_cli_account        ; �������� ���� ��������
    mfr_text_err  varchar2(512);
    --<< ����� UBRR 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������
    l_rec_register_result t_rec_register_result;
    l_bankidsmr varchar2(3);
    l_exc_no_found_406_407_408 exception;
    --------------- za_datu_za_period
    function za_datu_za_period
    return varchar2
    is
    begin
        if ( p_mode_hold ) then
           return '�� ������ � ' || to_char(p_portion_date1,'DD.MM.YYYY') ||
                          ' �� ' || to_char(p_portion_date2,'DD.MM.YYYY') || ' �.';
        else
           return '�� '||to_char(p_sbs_new.dSBSDate,'DD.MM.YYYY')||' �.';
        end if;
    end za_datu_za_period;

    -->>22.01.2021  ������� �.�.     DKBPA-139 ���.���������� ��������. ����������� ���������� �������� �� ����� ����
    function get_cModule(p_csbstypecom in ubrr_data.ubrr_sbs_new.csbstypecom%type,
                         p_ihold       in ubrr_data.ubrr_sbs_new.ihold%type)
    return varchar2
    is
    begin
        if p_ihold = 2 then
           return 'ubrr_sbs_new.�����������';
        else
           return 'ubrr_sbs_new.'|| ubrr_rko_tarif_pkg.get_tarif_freq(p_csbstypecom);
        end if;
    end get_cModule;
    --<<22.01.2021  ������� �.�.     DKBPA-139 ���.���������� ��������. ����������� ���������� �������� �� ����� ����

  begin   ---------- Register_single ------------
    l_bankidsmr   := ubrr_util.GetBankIdSmr;
    Succ_Proc_Cnt := 0;
    Card_Proc_Cnt := 0;
    Err_Proc_Cnt  := 0;
    -->> ubrr 23.09.2016 �������� �.�. 16-2222 ��������� ������������ ��� ��������
    vRegUser := ni_action.fGetAdmUser(ubrr_get_context);
    vRegUser1 := case when l_bankidsmr = '16' then 'T_VUZDAYCOM' else vRegUser end;
    --<< ubrr 23.09.2016 �������� �.�. 16-2222 ��������� ������������ ��� ��������
    begin
        rvDocument         := null;
        -->>22.01.2021  ������� �.�.     DKBPA-139 ���.���������� ��������. ����������� ���������� �������� �� ����� ����
        /*rvDocument.cModule := 'ubrr_sbs_new.'
                              || ubrr_rko_tarif_pkg.get_tarif_freq(p_sbs_new.csbstypecom); -- 07.11.2017 ubrr korolkov 17-1071
        */
        rvDocument.cModule := get_cModule(p_sbs_new.csbstypecom,p_sbs_new.ihold);
        --<<22.01.2021  ������� �.�.     DKBPA-139 ���.���������� ��������. ����������� ���������� �������� �� ����� ����
        rvDocument.cAccD   := p_sbs_new.CSBSACCD;
        rvDocument.cCurD   := p_sbs_new.CSBSCURD;
        rvDocument.cAccC   := p_sbs_new.cSBSAccC;
        rvDocument.cCurC   := 'RUR';
        rvDocument.dTran   := p_regdate;
        rvDocument.dComm   := p_sbs_new.dSBSDate;
        rvDocument.iDocNum := p_sbs_new.ISBSDOCNUM;
        rvDocument.iBatNum := p_sbs_new.ISBSBATNUM;
        rvDocument.mSumD   := p_sbs_new.mSBSsumCom;
        rvDocument.iBo1    := 25;
        rvDocument.iBo2    := 5;
        rvDocument.cType   := 'TC';
        rvDocument.lmode_available_rest := nvl(p_mode_available_rest,false); -- ubrr 25.02.2019 ������� �.�. [17-1790] ���: ��������� �� ��� ��� ������� ������������ ���������
        vcPrimAcc          := '';
        
        rvDocument.iParent := p_sbs_new.itrnnum; --19.07.2021  ������� �.�.     DKBPA-1571   �� ��������. �������� �������� � ������ "������"

-->> 01.02.2019 ������� �.�.  [19-58770] ��������� ���� ������� ����������� �������
        if p_sbs_new.csbstypecom in ('AI1', 'AI3', 'AI6', 'AI12', 'BK1', 'BK3', 'BK6', 'BK12'
                            ,'PK3','PK6','PK12' -- >> ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                            ,'REB_PE' -- 13.07.2021  ������� �.�.     DKBPA-1652
                            ) then
          rvDocument.cType := 'T';
        end if;
--<< 01.02.2019 ������� �.�.  [19-58770] ��������� ���� ������� ����������� �������

        IF p_sbs_new.cSBSPack is NOT NULL
           -->> 07.11.2017 ubrr korolkov 17-1071
           AND ( p_sbs_new.idsmr = lc_idsmr_vuz
                OR
                (p_sbs_new.idsmr != lc_idsmr_vuz AND p_sbs_new.csbstypecom not in ('PP9', 'PE9', 'PES9', 'PP6', 'PE6', 'PES6', '017',
                                                                   'PES9_PE','PE9_PE','PE6_PE','PES6_PE', -->><<--  22.06.2018 ������ �.�. [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                                                                   'R_LIGHT', -->><<-- 25.10.2018 �������� [18-56613] �� "������ ������" (�� ���� �� "��������") ��� ��� � 01.11.18
                                                                   'R_IB_LT', -->><<-- 19.11.2018 �������� [18-592.2] ��������
                                                                   '017_N', '018', '018_N', 'PP3', 'PP6_NTK', '017_NTK', '018_NTK',
                                                                   'UL_FL', 'IP_DOH',
                                                                   'UL_FL_VB', 'IP_DOH_VB' -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
                                                                  ))
               ) -- 21.02.2018 ubrr korolkov 18-12.1
           and ( p_sbs_new.csbstypecom not in ('INC') ) -- ���������� �� idsmr   --ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
           --<< 07.11.2017 ubrr korolkov 17-1071
        THEN
          cCommTP := ' �� '||p_sbs_new.cSBSPack;
        ELSE
          cCommTP := NULL;
        END IF;

        IF rvDocument.cAccD like '40821%' THEN
          BEGIN
            vcPrimAcc := rvDocument.cAccD; -- ���� 40821% �������� � ����������
            select caccacc
              into rvDocument.cAccD
              from acc
             where (caccacc like '406%' or caccacc like '407%' or caccacc like '408%')
               and caccacc not like '40821%'
               and caccprizn <> '�'
               and     not exists (select 1
                                   from gac
                                   where cgacacc = caccacc
                                     and igaccat = 333
                                     and igacnum = 2)
              -->> ubrr 14.06.2017 sevastyanov 17-71 ��� ������ �������� �������� �� ��������� �� �������� �� ����������
               and     not exists (select 1
                                   from gac
                                   where cgacacc = caccacc
                                     and igaccat = 333
                                     and igacnum = 4)
                --<< ubrr 14.06.2017 sevastyanov 17-71 ��� ������ �������� �������� �� ��������� �� �������� �� ����������
               and iacccus =
                   (select iacccus from acc where caccacc = rvDocument.cAccD)
               and cacccur =
                   (select cacccur from acc where caccacc = rvDocument.cAccD)
               and rownum = 1;
          EXCEPTION
            WHEN No_Data_Found THEN
              rvDocument.mSumD := 0;
              UPDATE ubrr_data.ubrr_sbs_new
              SET cSBSStat =  '������: ����������� 406% ��� 407% ��� 408%'
              WHERE id = p_sbs_new.id; -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����

              raise l_exc_no_found_406_407_408; -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
          END;
        END IF;
        -- ������������ ����������, ���.����.�������� �� ������ ����� �������� �������� �� ����������
        if rvDocument.cAccD like '42309%' then
          vcPrimAcc        := rvDocument.cAccD;
          rvDocument.cAccD := UBRR_XXI5."UBRR_RKO".f_otheracc(rvDocument.cAccD,
                                                              rvDocument.cCurD,
                                                              2);
        end if;

        BEGIN
            SELECT ACC.cACCname, CUS.cCUSnumnal, acc.cAccSio, dACClastoper
            INTO rvDocument.cNameC, rvDocument.cInnC, cAccSio, dACClastoper
            FROM ACC, CUS
            WHERE ACC.cACCacc = rvDocument.cAccC
            AND ACC.cACCcur = rvDocument.cCurC
            AND CUS.iCUSnum = ACC.iACCcus;
        EXCEPTION
            WHEN No_Data_Found then
                rvDocument.cNameC := NULL;
                rvDocument.cInnC := NULL;
                cAccSio := NULL;
                dACClastoper:=NULL;
                IF p_sbs_new.cSBSTypeCom LIKE '%_FL'
                   or p_sbs_new.cSBSTypeCom LIKE '%_FL_VB'       -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
                THEN  -- �������� �� ������� � ������ ��
                  rvDocument.cNameC:='�������� �� ������� ��-�� ';
                END IF;
        END;

        IF p_sbs_new.iSBSTypeCom = 3 THEN  -- �������� �� ������� � ������ �� -->><<-- ubrr 28.10.2016 �������� �.�. 16-2222.2 ������� �� �� ��������� Id ��������, � �� ��������
            if vcPrimAcc is not null then
                rvDocument.cPurp := rvDocument.cNameC || '�� ����� (' || vcPrimAcc || ') '||za_datu_za_period();
            else
                rvDocument.cPurp := rvDocument.cNameC || ' '|| za_datu_za_period();
            end if;

            if substr(p_sbs_new.CSBSACCD, 1, 8) = '40807810' then
                rvDocument.cPurp := '{VO80050}' || rvDocument.cPurp;
            end if;

            BEGIN
                -->>> 09.01.2018 ����� �.�. [17-913.2]
                if rvDocument.iBO1 = 25 then
                    cPurpDog := ' ' || ubrr_zaa_comms.Get_LinkToContract(p_Account => nvl(vcPrimAcc, rvDocument.cAccD),
                                                                         p_IdSmr   => p_sbs_new.idsmr);
                else
                --<<< 09.01.2018 ����� �.�. [17-913.2]
                    select ' ����.�. ' ||
                           decode(nump, 225, '2.2.5 ���. ', 32, '3.2 ���.', 1023, '2.3. ������ ��������, ������� � �������� ������ ') ||
                           case when nump not in (32, 1023) then '� ' || caccsio || ' �� ' ||to_char(dacclastoper, 'DD.MM.YYYY')
                                              else ''
                           end
                    INTO cPurpDog
                    from (select acc.caccsio,
                                 acc.dacclastoper,
                                 min(gac.igacnum) nump
                            from acc, gac
                           where caccacc = p_sbs_new.CSBSACCD
                             and cgacacc = caccacc
                             and ((igaccat = 170 and igacnum = 225) or
                                 (igaccat = 172 and igacnum = 32) or
                                 (igaccat = 170 and igacnum = 1023))
                           group by acc.caccsio, acc.dacclastoper);
                end if; -- 09.01.2018 ����� �.�. [17-913.2]
            EXCEPTION
                WHEN OTHERS THEN
                    cPurpDog := '';
            END;

            rvDocument.cPurp   := rvDocument.cPurp || cPurpDog;
            rvDocument.cAccept := '� ��������';
            rvDocument.cPurp := rvDocument.cPurp || cCommTP || chr(10) || ' ��� �� ����������';

            xxi.triggers.setuser(vRegUser);
            abr.triggers.setuser(vRegUser);
            access_2.cur_user_id := get_userid(vRegUser);

            IF p_test = 0 THEN
                rvRetDoc := ubrr_zaa_comms.Register(rvDocument);
            ELSE
                rvRetDoc := null;
                rvRetDoc.cResult := 'OK';
            END IF;

            xxi.triggers.setuser(null);
            abr.triggers.setuser(null);
            access_2.cur_user_id := get_userid();

            /* -- 26.02.2018 ubrr korolkov 17-913.2
            -->>> 09.01.2018 ����� �.�. [17-913.2]
            if  rvRetDoc.cResult = 'OK' and rvDocument.iBO1 = 25 then
              addCategoryAndGroup(rvDocument.cAccD, rvDocument.cCurD, 172, 32);
            end if;
            --<<< 09.01.2018 ����� �.�. [17-913.2]
            */ -- 26.02.2018 ubrr korolkov 17-913.2

            if rvRetDoc.cResult <> 'OK' then
                --���� �� ����������������
                UPDATE ubrr_data.ubrr_sbs_new
                SET cSBSStat = '������: ' || rvRetDoc.cResult,
                    cSBSAccD_Zam = case when rvDocument.cAccD = p_sbs_new.CSBSACCD then cSBSAccD_Zam else rvDocument.cAccD end -->><<-- ubrr 07.02.2017 �������� �.�. 16-3223 ������������ ����� ��������
                WHERE id = p_sbs_new.id; -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                Err_Proc_Cnt := Err_Proc_Cnt + 1;
            elsif rvRetDoc.cPlace = 'TRN' then
                ----->> ������� ������������
                update xxi."trn"
                set cTrnIdAffirm = vRegUser1, cTrnIdOpen = vRegUser   -->><< ubrr 23.09.2016 �������� �.�. 16-2222 ��������� ������������ ��� ��������
                where iTrnNum = rvRetDoc.iNum
                and iTrnAnum = rvRetDoc.iANum;
                -----<< ������� ������������

                UPDATE ubrr_data.ubrr_sbs_new
                set ISBSTRNNUM = rvRetDoc.iNum,
                    CSBSSTAT   = '���������',
                    ISBSTRNTRC = 1,
                    cSBSAccD_Zam = case when rvDocument.cAccD = p_sbs_new.CSBSACCD then cSBSAccD_Zam else rvDocument.cAccD end -->><<-- ubrr 07.02.2017 �������� �.�. 16-3223 ������������ ����� ��������
                WHERE id = p_sbs_new.id;  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                Succ_Proc_Cnt := Succ_Proc_Cnt + 1;
            elsif rvRetDoc.cPlace = 'TRC' then
                ----->> ������� ������������
                update xxi."trn"
                set cTrnIdAffirm = vRegUser1, cTrnIdOpen = vRegUser   -->><< ubrr 23.09.2016 �������� �.�. 16-2222 ��������� ������������ ��� ��������
                where iTrnNum = rvRetDoc.iNum;
                -----<< ������� ������������

                UPDATE ubrr_data.ubrr_sbs_new
                set ISBSTRNNUM = rvRetDoc.iCardNum,
                    CSBSSTAT   = '���������� � ��������� 2',
                    ISBSTRNTRC = 2,
                    cSBSAccD_Zam = case when rvDocument.cAccD = p_sbs_new.CSBSACCD then cSBSAccD_Zam else rvDocument.cAccD end -->><<-- ubrr 07.02.2017 �������� �.�. 16-3223 ������������ ����� ��������
                WHERE id = p_sbs_new.id;     -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                Card_Proc_Cnt := Card_Proc_Cnt + 1;
            end if;
        ELSIF p_sbs_new.iSBSTypeCom = 4 THEN  -- �������� �� �� -->><<-- ubrr 28.10.2016 �������� �.�. 16-2222.2 ������� �� �� ��������� Id ��������, � �� ��������
            rvDocument.cPurp := ' '||za_datu_za_period;

            IF p_sbs_new.cSBSTypeCom='ZPL' THEN
                rvDocument.iBo2 := 2;
            END IF;

            BEGIN
            -->>> 09.01.2018 ����� �.�. [17-913.2]
            if rvDocument.iBO1 = 25 then
                cPurpDog := ' ' || ubrr_zaa_comms.Get_LinkToContract(p_Account => nvl(vcPrimAcc, rvDocument.cAccD),
                                                                     p_IdSmr   => p_sbs_new.idsmr);
            else
            --<<< 09.01.2018 ����� �.�. [17-913.2]
            select ' ����.�. '||
                   decode(nump, 225, '2.2.5 ���. ', 32, '3.2 ���.', 1023, '2.3. ������ ��������, ������� � �������� ������ ') ||
                   case when nump not in (32, 1023) then '� ' || caccsio || ' �� ' ||to_char(dacclastoper, 'DD.MM.YYYY')
                                      else ''
                   end
            INTO cPurpDog
            from(
               select acc.caccsio, acc.dacclastoper, min(gac.igacnum) nump
               from acc, gac
               where caccacc=rvDocument.cAccD and cgacacc=caccacc
                    and ((igaccat=170 and igacnum=225)
                          or
                          (igaccat=172 and igacnum=32)
                          or
                          (igaccat=170 and igacnum=1023)
                        )
               group by acc.caccsio, acc.dacclastoper
            );
            end if; -- 09.01.2018 ����� �.�. [17-913.2]
            EXCEPTION
                WHEN OTHERS THEN
                    cPurpDog:='';
            END;

            rvDocument.cAccept:='� ��������';

            if vcPrimAcc is not null then
                rvDocument.cPurp := rvDocument.cPurp|| ' �� ����� '||vcPrimAcc;
            end if;

            rvDocument.cPurp := rvDocument.cPurp ||cPurpDog;
            rvDocument.cPurp := rvDocument.cNameC||rvDocument.cPurp || cCommTP || chr(10) || ' ��� �� ����������';
            rvDocument.cCurC := 'RUR';

            IF substr(rvDocument.cAccD,1,5) in ('40807','40813','40814','40815') THEN
                rvDocument.cPurp := '{VO80050}'||rvDocument.cPurp; -- 31.10.2012 ubrr korolkov https://redmine.lan.ubrr.ru/issues/5828 VO99020 -> VO80050
            END IF;

            -->> ubrr 23.09.2016 �������� �.�. 16-2222 ��������� ������������ ��� ��������
             xxi.triggers.setuser(vRegUser);
             abr.triggers.setuser(vRegUser);
             access_2.cur_user_id := get_userid(vRegUser);   --<< ubrr 23.09.2016 �������� �.�. 16-2222 ��������� ������������ ��� ��������

            IF p_test = 0 THEN
                -->> ������ UBRR 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������
                ---- ������������� ������������� �������� ��� ������� �� �������� ���
                if p_sbs_new.cSBSTypeCom in ('VZN44', 'VZN') then
                    mfr_text_err  := '';
                    begin
                        select idsmr into d_idsmr from xxi."acc" a where a.caccacc = rvDocument.cAccD /*r.CSBSACCD/**/ and a.caccprizn <> '�';
                        select idsmr into c_idsmr from xxi."acc" a where a.caccacc = p_sbs_new.CSBSACCC and a.caccprizn <> '�';
                    exception
                        when others then
                            d_idsmr := s_idsmr;
                            c_idsmr := s_idsmr;
                    end;

                    if c_idsmr != d_idsmr then
                        rvRetDoc := ubrr_zaa_comms.Register_MFR(rvDocument, d_idsmr, c_idsmr, p_regdate, mfr_text_err);
                    else
                        -- C����� ��� ������������� ������������� �������
                        rvRetDoc := ubrr_zaa_comms.Register(rvDocument);
                    end if;
                --<<--- ������������� ������������� ������� ��� ��� ��������----<< (���.) UBRR ����������� �.�.
                else
                    -- C����� ��� ������������� ������������� �������
                    rvRetDoc := ubrr_zaa_comms.Register(rvDocument);
                end if;
                --<< ����� UBRR 10.03.2017 ����������� �.�. 16-3100.2 ���: �������� �� �������� ��� ����� ���������
            ELSE
                rvRetDoc := null;
                rvRetDoc.cResult := 'OK';
            END IF;

            -->>  ubrr 23.09.2016 �������� �.�. 16-2222 ������� ������������
            xxi.triggers.setuser(null);
            abr.triggers.setuser(null);
            access_2.cur_user_id := get_userid();
            --<<  ubrr 23.09.2016 �������� �.�. 16-2222 ������� ������������

            if rvRetDoc.cResult = 'OK' then

                /* -- 26.02.2018 ubrr korolkov 17-913.2
                -->>> 09.01.2018 ����� �.�. [17-913.2]
                if rvDocument.iBO1 = 25 then
                    addCategoryAndGroup(rvDocument.cAccD, rvDocument.cCurD, 172, 32);
                end if;
                --<<< 09.01.2018 ����� �.�. [17-913.2]
                */ -- 26.02.2018 ubrr korolkov 17-913.2

                if rvRetDoc.cPlace = 'TRN' then
                    Succ_Proc_Cnt := Succ_Proc_Cnt + 1;
                    -->> ubrr 23.09.2016 �������� �.�. 16-2222 ������� ������������
                    update xxi."trn"
                    set cTrnIdAffirm = vRegUser1, cTrnIdOpen = vRegUser
                    where iTrnNum = rvRetDoc.iNum
                    and iTrnAnum = rvRetDoc.iANum;
                    --<< ubrr 23.09.2016 �������� �.�. 16-2222 ������� ������������

                    UPDATE ubrr_data.ubrr_sbs_new
                    set ISBSTRNNUM = rvRetDoc.iNum,
                        CSBSSTAT   = '���������',
                        ISBSTRNTRC = 1,
                        MFR_ERR    = substr(mfr_text_err, 1, 255), -- UBRR 10.03.2017 ����������� �.�. 16-3100.2 ���: �������� �� �������� ��� ����� ���������
                        cSBSAccD_Zam = case when rvDocument.cAccD = p_sbs_new.CSBSACCD then cSBSAccD_Zam else rvDocument.cAccD end -->><<-- ubrr 07.02.2017 �������� �.�. 16-3223 ������������ ����� ��������
                    WHERE id = p_sbs_new.id; -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                elsif rvRetDoc.cPlace = 'TRC' then
                    Card_Proc_Cnt := Card_Proc_Cnt + 1;
                    -->>  ubrr 23.09.2016 �������� �.�. 16-2222 ������� ������������
                    update xxi."trn"
                    set cTrnIdAffirm = vRegUser1, cTrnIdOpen = vRegUser
                    where iTrnNum = rvRetDoc.iNum;
                    --<<  ubrr 23.09.2016 �������� �.�. 16-2222 ������� ������������

                    UPDATE ubrr_data.ubrr_sbs_new
                    set ISBSTRNNUM = rvRetDoc.iCardNum,
                        CSBSSTAT   = '���������� � ��������� 2',
                        ISBSTRNTRC = 2,
                        MFR_ERR    = substr(mfr_text_err, 1, 255), -- UBRR 10.03.2017 ����������� �.�. 16-3100.2 ���: �������� �� �������� ��� ����� ���������
                        cSBSAccD_Zam = case when rvDocument.cAccD = p_sbs_new.CSBSACCD then cSBSAccD_Zam else rvDocument.cAccD end -->><<-- ubrr 07.02.2017 �������� �.�. 16-3223 ������������ ����� ��������
                    WHERE id = p_sbs_new.id;  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                end if;
            else
                UPDATE ubrr_data.ubrr_sbs_new
                SET cSBSStat = '������: ' || rvRetDoc.cResult,
                    MFR_ERR  = substr(mfr_text_err, 1, 255), -- UBRR 10.03.2017 ����������� �.�. 16-3100.2 ���: �������� �� �������� ��� ����� ���������
                    cSBSAccD_Zam = case when rvDocument.cAccD = p_sbs_new.CSBSACCD then cSBSAccD_Zam else rvDocument.cAccD end -->><<-- ubrr 07.02.2017 �������� �.�. 16-3223 ������������ ����� ��������
                WHERE id = p_sbs_new.id;  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                Err_Proc_Cnt := Err_Proc_Cnt + 1;
            end if;
        ELSE   -- �������� �� ������� � �������� �� ������� ����� � ���
            IF substr(rvDocument.cAccD,1,5) not in ('40804','40805') THEN
                BEGIN
                -->>> 09.01.2018 ����� �.�. [17-913.2]
                    if rvDocument.iBO1 = 25 then
                        cPurpDog := ' ' || ubrr_zaa_comms.Get_LinkToContract(p_Account => nvl(vcPrimAcc, rvDocument.cAccD),
                                                                             p_IdSmr   => p_sbs_new.idsmr);
                    else
                    --<<< 09.01.2018 ����� �.�. [17-913.2]
                        select ' c���.�. '||
                               decode(nump, 225, '2.2.5 ���. ', 32, '3.2 ���.', 1023, '2.3. ������ ��������, ������� � �������� ������ ') ||
                               case when nump not in (32, 1023) then '� ' || caccsio || ' �� ' ||to_char(dacclastoper, 'DD.MM.YYYY')
                                                  else ''
                               end
                        INTO cPurpDog
                        from(
                           select acc.caccsio, acc.dacclastoper, min(gac.igacnum) nump
                           from acc, gac
                           where caccacc=rvDocument.cAccD and cgacacc=caccacc
                             and ((igaccat=170 and igacnum=225)
                                      or
                                      (igaccat=172 and igacnum=32)
                                      or
                                      (igaccat=170 and igacnum=1023)
                                    )
                           group by acc.caccsio, acc.dacclastoper
                        );
                    end if; -- 09.01.2018 ����� �.�. [17-913.2]
                    cPurpDog1:='';
                EXCEPTION
                    WHEN OTHERS THEN
                        cPurpDog:='';
                        cPurpDog1:=' �������� �������� N '||cACCsio||' �� '||to_char(dACClastoper,'DD.MM.YYYY');
                END;

                -->>19.07.2021  ������� �.�.     DKBPA-1571   �� ��������. �������� �������� � ������ "������"
                IF p_sbs_new.itrnnum is not null and p_sbs_new.itrnanum is not null THEN
                   
                   --�������� �������� �������� ��� � ���������, ��������� ��������, �������� ��������
                   Set_Last_Itrcnum(card.get_last_num);
                   Set_Check_Online_Trc('N');  
                                     
                   rvDocument.cPurp := cPurpDog1 ||', �� ��������: '||ubrr_xxi5.ubrr_bnkserv_online_comiss.get_attrib_trn(par_itrnnum => p_sbs_new.itrnnum, par_itrnanum => p_sbs_new.itrnanum)||',';   
                ELSE
                --<<19.07.2021  ������� �.�.     DKBPA-1571   �� ��������. �������� �������� � ������ "������"
                  
                  -->>-- ubrr 28.10.2016 �������� �.�. 16-2222.2 ������� �� �� ��������� Id ��������, � �� ��������
                  IF     p_sbs_new.iSBSTypeCom > 100
                     and p_sbs_new.iSBSTypeCom <= 1000  --ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                  THEN -->><<--  ubrr 23.09.2016 �������� �.�. 16-2222 �������� �� ������ "��������"
                      -- �����������
                      -->>03.03.2021  ������� �.�.     DKBPA-264 ��� ��: ������� ����� � ����������� �� ���-�� ���� ��� �������� �����
                      /*rvDocument.cPurp := cPurpDog1 || ' �� ������ � ' || to_char(p_portion_date1,'DD.MM.YYYY') ||
                                                                ' �� ' || to_char(p_portion_date2,'DD.MM.YYYY') || ' �.'; */
                      if p_sbs_new.iSBSTypeCom = 101 then
                        rvDocument.cPurp := cPurpDog1 ||' �� '||replace(to_char(p_portion_date1,'month RRRR','NLS_DATE_LANGUAGE = RUSSIAN'),'  ',' ')||' �.';
                      else
                        rvDocument.cPurp := cPurpDog1 || ' �� ������ � ' || to_char(p_portion_date1,'DD.MM.YYYY') ||
                                                                  ' �� ' || to_char(p_portion_date2,'DD.MM.YYYY') || ' �.';
                      end if;
                      --<<03.03.2021  ������� �.�.     DKBPA-264 ��� ��: ������� ����� � ����������� �� ���-�� ���� ��� �������� �����
                      -->>12.11.2018 �������� [18-592.2] ���. ������� �������� �� ���������
                      if p_sbs_new.cSBSTypeCom = 'R_IB_LT' then
                          if p_sbs_new.cComment is not null then
                              rvDocument.cPurp := rvDocument.cPurp || ' � ���������� ������: ' || p_sbs_new.cComment || ',';
                          else
                              rvDocument.cPurp := rvDocument.cPurp || ' � ���������� ������: 0,';
                          end if;
                      end if;
                      --<<12.11.2018 �������� [18-592.2] ���. ������� �������� �� ���������
                  elsif p_sbs_new.iSBSTypeCom <= 100  then--ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                      -- ����������
                      -->> 15.06.2018 ubrr korolkov
                      if p_sbs_new.csbstypecom = 'PP6_NTK' and g_purp_ntk = 1 then
                          rvDocument.cPurp := cPurpDog1 || ' �� ������ � ' || to_char(p_portion_date1,'DD.MM.YYYY') ||
                                                                    ' �� ' || to_char(p_portion_date2,'DD.MM.YYYY') || ' �.';
                      else
                      --<< 15.06.2018 ubrr korolkov
                          rvDocument.cPurp := cPurpDog1||' '||za_datu_za_period();
                      end if;
                      IF p_sbs_new.iSBSTypeCom IN (1,2) THEN
                          -->> 28.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                          if    (    p_sbs_new.CSBSTYPECOM='PE6_PE'
                                  or ( p_sbs_new.CSBSTYPECOM='PE6' and p_sbs_new.idsmr = lc_idsmr_vuz ) -- 04.03.2020  ������� �.�. [20-71832]   ���: ��������� ������ "������" (���)
                                )
                             and p_sbs_new.MSBSTARIF>0 then
                             rvDocument.cPurp := rvDocument.cPurp || '� ���-�� ���� : '||to_char(trunc((p_sbs_new.MSBSSUMCOM/p_sbs_new.MSBSTARIF)));
                          else
                          --<< 28.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                             rvDocument.cPurp := rvDocument.cPurp || '� ���-�� ���� : '||LTRIM(p_sbs_new.iSBSCountPays);
                          end if; -->><< 28.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                      END IF;
                  else  -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                      -- �� �������
                      rvDocument.cPurp := cPurpDog1 ||',�� ��������: '||strattrib_trn_sbs_one(p_sbs_new.id); --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                  END IF;
                  --<<-- ubrr 28.10.2016 �������� �.�. 16-2222.2 ������� �� �� ��������� Id ��������, � �� ��������
                
                END IF; --19.07.2021  ������� �.�.     DKBPA-1571   �� ��������. �������� �������� � ������ "������"

                if vcPrimAcc is not null then
                    rvDocument.cPurp := rvDocument.cPurp ||' �� ����� '|| vcPrimAcc;
                end if;

                -->>> ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���
                if ( p_sbs_new.iSBSTypeCom = ubrr_xxi5.ubrr_bnkserv_krc.g_icom_type_krs_mng ) then
                   rvDocument.cPurp := rvDocument.cNameC || ubrr_bnkserv_krc.purpose_krc_mng( p_idsmr  => p_sbs_new.idsmr
                                                                                             ,p_acc    => p_sbs_new.csbsaccd
                                                                                             ,p_cur    => p_sbs_new.csbscurd
                                                                                             ,p_date1  => p_portion_date1
                                                                                             ,p_date2  => p_portion_date2 )
                                     || chr(10) || ' ��� �� ����������';
                else
                   rvDocument.cPurp := rvDocument.cPurp ||cPurpDog;
                   rvDocument.cPurp := rvDocument.cNameC||rvDocument.cPurp || cCommTP || chr(10) || ' ��� �� ����������';
                end if;
                -->>> ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���

                rvDocument.cAccept:='� ��������';

                IF substr(rvDocument.cAccD,1,5) in ('40807','40813','40814','40815') THEN
                    rvDocument.cPurp := '{VO80050}'||rvDocument.cPurp; -- 31.10.2012 ubrr korolkov https://redmine.lan.ubrr.ru/issues/5828 VO99020 -> VO80050
                END IF;

                -->>  ubrr 23.09.2016 �������� �.�. 16-2222 ������� ������������
                IF    p_TypeCom <= 100
                   or p_TypeCom  > 1000--ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                THEN
                    xxi.triggers.setuser(vRegUser);
                    abr.triggers.setuser(vRegUser);
                    access_2.cur_user_id := get_userid(vRegUser);
                END IF;

                IF p_test = 0 THEN
                    rvRetDoc := ubrr_zaa_comms.Register(rvDocument);
                ELSE
                    rvRetDoc := null;
                    rvRetDoc.cResult := 'OK';
                END IF;

                IF    p_TypeCom<=100
                   or p_TypeCom > 1000--ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                THEN
                    xxi.triggers.setuser(null);
                    abr.triggers.setuser(null);
                    access_2.cur_user_id := get_userid();
                END IF;
                --<<  ubrr 23.09.2016 �������� �.�. 16-2222 ������� ������������

                if rvRetDoc.cResult = 'OK' then

                    /* -- 26.02.2018 ubrr korolkov 17-913.2
                    -->>> 09.01.2018 ����� �.�. [17-913.2]
                    if  rvDocument.iBO1 = 25 then
                        addCategoryAndGroup(rvDocument.cAccD, rvDocument.cCurD, 172, 32);
                    end if;
                    --<<< 09.01.2018 ����� �.�. [17-913.2]
                    */ -- 26.02.2018 ubrr korolkov 17-913.2

                    if rvRetDoc.cPlace = 'TRN' then
                      Succ_Proc_Cnt := Succ_Proc_Cnt+1;
                      begin
                       IF p_sbs_new.cSBSTypeCom in ('PP9','PP3','PP3E')  THEN
                         insert into gtr (igtrtrnnum, igtrtrnanum, igtrcat, igtrnum)
                         values (rvRetDoc.iNum, rvRetDoc.iANum, 114, 4);
                       ELSIF p_sbs_new.cSBSTypeCom in ('PP6')  THEN
                         insert into gtr (igtrtrnnum, igtrtrnanum, igtrcat, igtrnum)
                         values (rvRetDoc.iNum, rvRetDoc.iANum, 114, 5);
                       ELSIF p_sbs_new.cSBSTypeCom in ('017')  THEN
                         insert into gtr (igtrtrnnum, igtrtrnanum, igtrcat, igtrnum)
                         values (rvRetDoc.iNum, rvRetDoc.iANum, 114, 6);
                       ELSIF p_sbs_new.cSBSTypeCom in ('R_SMS')  THEN
                         insert into gtr (igtrtrnnum, igtrtrnanum, igtrcat, igtrnum)
                         values (rvRetDoc.iNum, rvRetDoc.iANum, 114, 2);
                       ELSIF p_sbs_new.cSBSTypeCom = 'RKO' THEN --���
                         insert into gtr (igtrtrnnum, igtrtrnanum, igtrcat, igtrnum)
                         values (rvRetDoc.iNum, rvRetDoc.iANum, 114, 1);
                       ELSIF p_sbs_new.cSBSTypeCom = 'RKB' THEN --��� � ���
                         insert into gtr (igtrtrnnum, igtrtrnanum, igtrcat, igtrnum)
                         values (rvRetDoc.iNum, rvRetDoc.iANum, 114, 2);
                       END IF;
                      exception
                        when OTHERS then
                          WriteProtocol('������ �������� ��������� � ��������� ������: ['||rvRetDoc.iNum||']['||rvRetDoc.iANum||']: '||sqlerrm);
                      end;
                      IF   p_TypeCom<=100
                        or p_TypeCom > 1000--ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                      THEN
                        -->>  ubrr 23.09.2016 �������� �.�. 16-2222 ������� ������������
                        update xxi."trn"
                           set cTrnIdAffirm = vRegUser1, cTrnIdOpen = vRegUser
                         where iTrnNum = rvRetDoc.iNum
                           and iTrnAnum = rvRetDoc.iANum;
                        --<<  ubrr 23.09.2016 �������� �.�. 16-2222 ������� ������������
                      END IF;
                      UPDATE ubrr_data.ubrr_sbs_new
                      set ISBSTRNNUM = rvRetDoc.iNum,
                           CSBSSTAT   = '���������',
                           ISBSTRNTRC    = 1
                          ,cSBSAccD_Zam = case when rvDocument.cAccD = p_sbs_new.CSBSACCD then cSBSAccD_Zam else rvDocument.cAccD end -->><<-- ubrr 07.02.2017 �������� �.�. 16-3223 ������������ ����� ��������
                      WHERE id = p_sbs_new.id;  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                    elsif rvRetDoc.cPlace = 'TRC' then
                      Card_Proc_Cnt := Card_Proc_Cnt + 1;
                      IF   p_TypeCom<=100
                        or p_TypeCom > 1000--ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                      THEN
                        -->>  ubrr 23.09.2016 �������� �.�. 16-2222 ������� ������������
                        update xxi."trn"
                         set cTrnIdAffirm = vRegUser1, cTrnIdOpen = vRegUser
                        where iTrnNum = rvRetDoc.iNum;
                        --<<  ubrr 23.09.2016 �������� �.�. 16-2222 ������� ������������
                      END IF;
                      UPDATE ubrr_data.ubrr_sbs_new
                      set ISBSTRNNUM = rvRetDoc.iCardNum,
                         CSBSSTAT   = '���������� � ��������� 2',
                         ISBSTRNTRC    = 2
                        ,cSBSAccD_Zam = case when rvDocument.cAccD = p_sbs_new.CSBSACCD then cSBSAccD_Zam else rvDocument.cAccD end -->><<-- ubrr 07.02.2017 �������� �.�. 16-3223 ������������ ����� ��������
                      WHERE id = p_sbs_new.id;  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                    
                      -->>19.07.2021  ������� �.�.     DKBPA-1571   �� ��������. �������� �������� � ������ "������"
                      IF p_sbs_new.itrnnum is not null and p_sbs_new.itrnanum is not null THEN
                        if iLast_Itrcnum <> 0 and iLast_Itrcnum <> rvRetDoc.iCardNum then
                          Set_Check_Online_Trc('Y');
                        end if;  
                      END IF;
                      --<<19.07.2021  ������� �.�.     DKBPA-1571   �� ��������. �������� �������� � ������ "������"                
                    end if;
                else
                    UPDATE ubrr_data.ubrr_sbs_new
                    SET cSBSStat = '������: ' || rvRetDoc.cResult
                       ,cSBSAccD_Zam = case when rvDocument.cAccD = p_sbs_new.CSBSACCD then cSBSAccD_Zam else rvDocument.cAccD end -->><<-- ubrr 07.02.2017 �������� �.�. 16-3223 ������������ ����� ��������
                    WHERE id = p_sbs_new.id;  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                    Err_Proc_Cnt := Err_Proc_Cnt + 1;
                end if;
            END IF;
        end if;

      exception
       when l_exc_no_found_406_407_408 then
            null; -- ��������� ����. ����� ��� �������������
        when others then
            UPDATE ubrr_data.ubrr_sbs_new
            SET cSBSStat =  '������,' || dbms_utility.format_error_stack ||
                            chr(10) || dbms_utility.format_error_backtrace
            WHERE id = p_sbs_new.id;  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
            Err_Proc_Cnt := Err_Proc_Cnt + 1;
      end;

    l_rec_register_result.l_trn_cnt := nvl(Succ_Proc_Cnt,0);
    l_rec_register_result.l_trc_cnt := nvl(Card_Proc_Cnt,0);
    l_rec_register_result.l_err_cnt := nvl(Err_Proc_Cnt ,0);

    return l_rec_register_result;
  end Register_single;
-- << ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����

-- ��������� ������ �� �������� p_hold (ubrr_sbs_new.ihold)
function stat4hold(p_hold in number)
return varchar2
is
begin
  case when ( p_hold = gc_sbs_hold2month )
          then return gc_csbsstat_hold_monthly;
       else return null;
  end case;
end stat4hold;

-- >> ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
-- ���������� ������� ��� ������� ������ � ubrr_sbs_new
procedure process_rec_monthly_hold( p_idx              in pls_integer
                                   ,p_sbsdate          in date
                                   ,p_dtran            in date
                                   ,p_rec_monthly_hold in t_rec_monthly_hold
                                   ,p_tbl_sbs_new      in out nocopy t_tbl_sbs_new
                                   ,p_idsmr            in varchar2 )
is
begin
  p_tbl_sbs_new(p_idx).id            := ubrr_sbs_new_id_seq.nextval      ;
  p_tbl_sbs_new(p_idx).DSBSDATE      := p_sbsdate                        ;
  p_tbl_sbs_new(p_idx).ISBSTYPECOM   := p_rec_monthly_hold.ISBSTYPECOM   ;
  p_tbl_sbs_new(p_idx).CSBSTYPECOM   := p_rec_monthly_hold.CSBSTYPECOM   ;
  p_tbl_sbs_new(p_idx).CSBSACCD      := p_rec_monthly_hold.CSBSACCD      ;
  p_tbl_sbs_new(p_idx).CSBSCURD      := p_rec_monthly_hold.CSBSCURD      ;
  p_tbl_sbs_new(p_idx).CSBSACCD_ZAM  := p_rec_monthly_hold.CSBSACCD_ZAM  ;
  p_tbl_sbs_new(p_idx).CSBSCURD_ZAM  := p_rec_monthly_hold.CSBSCURD_ZAM  ;
  p_tbl_sbs_new(p_idx).CSBSACCC      := p_rec_monthly_hold.CSBSACCC      ;
  p_tbl_sbs_new(p_idx).CSBSCURC      := p_rec_monthly_hold.CSBSCURC      ;
  p_tbl_sbs_new(p_idx).MSBSSUMPAYS   := p_rec_monthly_hold.MSBSSUMPAYS   ;
  p_tbl_sbs_new(p_idx).ISBSCOUNTPAYS := p_rec_monthly_hold.ISBSCOUNTPAYS ;
  p_tbl_sbs_new(p_idx).MSBSSUMCOM    := p_rec_monthly_hold.MSBSSUMCOM    ;
  p_tbl_sbs_new(p_idx).ISBSTRNNUM    := null                             ;
  p_tbl_sbs_new(p_idx).CSBSSTAT      := null                             ;
  p_tbl_sbs_new(p_idx).ISBSTRNTRC    := 0                                ;
  p_tbl_sbs_new(p_idx).ISBSOTDNUM    := p_rec_monthly_hold.ISBSOTDNUM    ;
  p_tbl_sbs_new(p_idx).ISBSDOCNUM    := null                             ;
  p_tbl_sbs_new(p_idx).ISBSBATNUM    := p_rec_monthly_hold.ISBSBATNUM    ;
  p_tbl_sbs_new(p_idx).DSBSSYSDATE   := sysdate()                        ;
  p_tbl_sbs_new(p_idx).IDSMR         := p_idsmr                          ;
  p_tbl_sbs_new(p_idx).DSBSDATEREG   := p_dtran                          ;
  p_tbl_sbs_new(p_idx).CSBSPACK      := p_rec_monthly_hold.CSBSPACK      ;
  p_tbl_sbs_new(p_idx).MSBSTARIF     := 0                                ;
  p_tbl_sbs_new(p_idx).MSBSTARIFPRC  := 0                                ;
  p_tbl_sbs_new(p_idx).MSBSSUMBEFO   := p_rec_monthly_hold.MSBSSUMBEFO   ;
  p_tbl_sbs_new(p_idx).IDSMR_TO      := p_rec_monthly_hold.IDSMR_TO      ;
  p_tbl_sbs_new(p_idx).MFR_ERR       := null                             ;
  p_tbl_sbs_new(p_idx).TARIF_ID      := p_rec_monthly_hold.TARIF_ID      ;
  p_tbl_sbs_new(p_idx).CCOMMENT      := '���������� ������������ � �����������' ;  --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
  p_tbl_sbs_new(p_idx).IHOLD         := gc_sbs_hold_created              ;


  -- �������� ����_���������� � ����.
  if ( p_rec_monthly_hold.list_daily_id is not null) then
      update ubrr_sbs_new s
         set s.ISBSTRNNUM  = p_tbl_sbs_new(p_idx).id
            ,s.DSBSDATEREG = p_dtran                     -- ���� ����������� ����������_����������
           -- ,s.CSBSSTAT   = gc_csbsstat_hold_monthly   -- ������ ������� ����� � UpdateAcc
       where s.id in ( select column_value
                         from table(p_rec_monthly_hold.list_daily_id) );
  end if;

end process_rec_monthly_hold;

-----------------------------------------------------------------------------------
-- ������������ � SBS_NEW ����������� �������� �� ���������� ����������
-- ���������� ���������� ��������� � ubrr_sbs_new
-- ����������� ��������� � ubrr_sbs_new ��� �����,���
procedure create_monthly_comm_from_hold( p_portion_date1 in date
                                        ,p_portion_date2 in date
                                        ,p_dtran         in date     -- ���� ������� ��������
                                        ,p_ls            in varchar2 default gc_ls )
is
   lc_idsmr                   number := sys_context('B21', 'IDSMR');

   l_tbl_monthly_hold         t_tbl_monthly_hold;
   l_tbl_sbs_new              t_tbl_sbs_new;
   l_idx                      pls_integer;
   l_list_id                  ubrr_integer_tab;
   l_ls                       varchar2(50);
   l_msg                      varchar2(32767):=$$plsql_unit||'.create_monthly_comm_from_hold';
   l_exc_parameters_incorrect exception;
begin
   l_msg := l_msg || ' ['||
           'p_portion_date1='||to_char(p_portion_date1,'dd.mm.yyyy')||';'||
           'p_portion_date2='||to_char(p_portion_date2,'dd.mm.yyyy')||';'||
           'p_dtran='        ||to_char(p_dtran,'dd.mm.yyyy')        ||';'||
           'p_ls='           ||nvl(p_ls,'null')                     ||';'||
           '] ';
   if ( p_portion_date1 is null or
        p_portion_date2 is null or
        p_dtran         is null
       ) then
       raise l_exc_parameters_incorrect;
   end if;

  writeprotocol('������ ������������ ����������� �������� �� ���������� ���������� �� ������� '||sys_context('B21','IDSMR'));

  l_ls := nvl( trim(p_ls),gc_ls );

 -- ��������� �������� �����_����., ������� ��������� � �����. ����_����.
 -- ��� �������� ��� �������� ����_����. �������� �� ����� ubrr_bnkserv_everyday.fmb
 update ubrr_sbs_new s1
   set s1.isbstrnnum  = null
      ,s1.dsbsdatereg = s1.dsbsdate
 where s1.dsbsdate   >=  p_portion_date1
   and s1.dsbsdate   <= (p_portion_date2 + 86399/86400)
   and s1.idsmr       = sys_context('B21','IdSmr')
   and s1.csbsaccd    like l_ls
   and s1.csbscurd    = 'RUR'
   and s1.isbstrnnum is not null
   and s1.ihold       = gc_sbs_hold2month
   and not exists ( select 1
                      from ubrr_sbs_new s2
                     where s2.id = s1.isbstrnnum );

  -- �������� ������������� ����� � �� ����������� ����������� ��������
  -- ������ ����. ��� ��������
  select s.id
    bulk collect into l_list_id
    from ubrr_sbs_new s
   where s.idsmr       = lc_idsmr
     and s.dsbsdate    = p_portion_date2
     and s.ihold       = gc_sbs_hold_created
     and s.isbstrnnum is null
     and s.csbsaccd like l_ls;

  -- ������� �������� ����.
  update ubrr_sbs_new s
     set s.isbstrnnum  = null
        ,s.dsbsdatereg = s.dsbsdate
   where s.isbstrnnum  in ( select column_value
                              from table( l_list_id ) )
     -- ������� ��������� ��� ���������� ������
     and s.dsbsdate    >=  p_portion_date1
     and s.dsbsdate    <= (p_portion_date2 + 86399/86400)
     and s.idsmr       = sys_context('B21','IdSmr')
     and s.csbsaccd    like l_ls
     and s.csbscurd    = 'RUR'
     and s.ihold       = gc_sbs_hold2month;

  -- �������� ����.
  delete from ubrr_sbs_new s
   where s.id in ( select column_value
                     from table( l_list_id ) );

  l_list_id.delete;

  dbms_transaction.commit;

  open g_cur_monthly_hold( p_portion_date1 => p_portion_date1
                          ,p_portion_date2 => p_portion_date2
                          ,p_ls            => l_ls
                          ,p_idsmr         => lc_idsmr );
  loop
    l_tbl_monthly_hold.delete();

    fetch g_cur_monthly_hold
       bulk collect into l_tbl_monthly_hold limit gc_limit_bulk_monthly_hold;

    l_idx:= l_tbl_monthly_hold.first;
    while l_idx is not null
    loop
       process_rec_monthly_hold( p_idx               => l_idx
                                ,p_sbsdate           => p_portion_date2
                                ,p_rec_monthly_hold  => l_tbl_monthly_hold(l_idx)
                                ,p_tbl_sbs_new       => l_tbl_sbs_new
                                ,p_dtran             => p_dtran
                                ,p_idsmr             => lc_idsmr );
       l_idx:=l_tbl_monthly_hold.next(l_idx);
    end loop;

    forall l_idx in indices of l_tbl_sbs_new
      insert into ubrr_sbs_new values l_tbl_sbs_new(l_idx);

    l_tbl_sbs_new.delete();
    exit when l_tbl_monthly_hold.count < gc_limit_bulk_monthly_hold;
  end loop;

  close g_cur_monthly_hold;

  l_tbl_monthly_hold.delete();
  l_tbl_sbs_new.delete();

  dbms_transaction.commit;

  writeprotocol('��������� ������������ ����������� �������� �� ���������� ���������� �� ������� '||sys_context('B21','IDSMR'));
exception
     when l_exc_parameters_incorrect then
          raise_application_error(-20005, l_msg||' - ������������ ������� ���������');
     when others then
          raise_application_error( -20010, 'Error in '||l_msg||' '||dbms_utility.format_error_backtrace || ' ' ||sqlerrm );
end create_monthly_comm_from_hold;

----------------------------------------------------------------------
-- �������� ����������� �� ���������� ����������
-- ���������� � trn/trc
function process_monthly_comm_from_hold( p_dtran          in  date
                                        ,p_portion_date1  in  date     default null
                                        ,p_portion_date2  in  date     default null
                                        ,p_ls             in  varchar2 default gc_ls
                                        ,p_test           in  number   default 0
                                        ,p_Mess           out varchar2 )
return number
is
  l_ret number;
  acc_1 varchar2(25) := nvl(p_ls, gc_ls); -->><<--14.10.2019 �������� https://redmine.lan.ubrr.ru/issues/67609
begin
   writeprotocol('������ ��������� �������� ������������ � �����������');
   -- �������� ����������� �� ���������� ����������
   ubrr_bnkserv_calc_new_lib.create_monthly_comm_from_hold( p_portion_date1 => p_portion_date1
                                                           ,p_portion_date2 => p_portion_date2
                                                           ,p_dtran         => p_dtran
                                                           ,p_ls            => acc_1 );   -->><<--14.10.2019 �������� https://redmine.lan.ubrr.ru/issues/67609

   l_ret := ubrr_bnkserv_calc_new_lib.Register( p_regdate             => p_dtran
                                               ,p_TypeCom             => null
                                               ,p_Mess                => p_Mess
                                               ,p_portion_date1       => p_portion_date1
                                               ,p_portion_date2       => p_portion_date2
                                               ,p_ls                  => acc_1 -->><<--14.10.2019 �������� https://redmine.lan.ubrr.ru/issues/67609
                                               ,p_mode_available_rest => true
                                               ,p_mode_hold           => true
                                               ,p_test                => p_test );

   writeprotocol('��������� ��������� �������� ������������ � ����������� ('||l_ret||')');
   return l_ret;
end process_monthly_comm_from_hold;

----------------------------------------------------------------------
-- �������� ����������� �� ���������� ����������
-- ���������� � trn/trc
procedure process_monthly_comm_from_hold( p_dtran          in  date
                                         ,p_portion_date1  in  date     default null
                                         ,p_portion_date2  in  date     default null
                                         ,p_ls             in  varchar2 default gc_ls
                                         ,p_test           in  number   default 0
                                         ,p_Mess           out varchar2 )
is
  l_ret number;
begin
   l_ret := process_monthly_comm_from_hold( p_dtran         => p_dtran
                                           ,p_portion_date1 => p_portion_date1
                                           ,p_portion_date2 => p_portion_date2
                                           ,p_ls            => nvl(p_ls, gc_ls) -->><<--14.10.2019 �������� https://redmine.lan.ubrr.ru/issues/67609
                                           ,p_test          => p_test
                                           ,p_Mess          => p_Mess );

   p_Mess:=p_Mess||'������������ � �����������: ' ||l_ret||chr(10);  -- ��� ������������� � ubrr_bnkserv_calc_new.RegEveryMonthsComiss
end process_monthly_comm_from_hold;

-- << ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����

-->>15.10.2019 �������� [19-62184] �������� �� ��� ��� �������� �-�� "����" https://redmine.lan.ubrr.ru/issues/67214#note-2
--���������� �� ��������� �������
procedure fill_trn_old_new(p_d1 in date, p_d2 in date) is
  nv_cnt  number;
  dv_d1   date := p_d1;
  dv_d2   date := p_d2;
begin
  writeprotocol('ubrr_trn_old_new: ���������� ������� � '||dv_d1||' �� '||dv_d2);

  insert into ubrr_data.ubrr_trn_old_new(itrnnum, itrnanum, dtrntran, dtrncreate, ctrnaccd, ctrncur, ctrnaccc, ctrncurc, mtrnsum, mtrnrsum, mtrnsumc, itrntype, itrnsop,
                                         itrnbatnum, itrndocnum, dtrndoc, dtrnval, dtrnshadow, ctrnmfoo, ctrncoracco, ctrnclient_inn, ctrnclient_kpp, ctrnclient_name,
                                         itrnsbcodea, ctrnmfoa, ctrncoracca, ctrnbnamea, ctrnacca, ctrninna, ctrnkppa, ctrnowna, ctrnpurp, itrnnumanc, itrnanumanc,
                                         itrncocode, ctrnstate1, ctrnstate2, ctrnstate3, ctrnstate4, ctrnstate5, ctrnstate8, ctrntext1, ctrntext2, ctrntext3, ctrntext4,
                                         itrnpriority, ctrnvo, ctrndway, ctrnref, ctrnzakob, itrnpnum, itrnba2d, itrnba2c, itrnbnkid, itrnsubsys, itrnsscreg, ctrnidopen,
                                         ctrnidaffirm, ctrnctrl_type, ctrnemptytran, ctrndnvproc, ctrnclient_acc, idsmr, ctrnaccd_fake, ctrnaccc_fake, ctrnalias,
                                         ctrnideditc, ctrnideditd, ctrnstate6, ctrnstate7, ctrnstate9, ctrnstate0, ctrntext5, ctrnvychet, itrnkodalias, itrnkol,
                                         itrntek_num, dtrntrn_trunc, idsmr_old)
  select t.itrnnum, t.itrnanum, t.dtrntran, t.dtrncreate, t.ctrnaccd, t.ctrncur, t.ctrnaccc, t.ctrncurc, t.mtrnsum, t.mtrnrsum, t.mtrnsumc, t.itrntype,  t.itrnsop,
         t.itrnbatnum, t.itrndocnum, t.dtrndoc, t.dtrnval, t.dtrnshadow, t.ctrnmfoo, t.ctrncoracco, t.ctrnclient_inn, t.ctrnclient_kpp, t.ctrnclient_name, t.itrnsbcodea,
         t.ctrnmfoa, t.ctrncoracca, t.ctrnbnamea, t.ctrnacca, t.ctrninna, t.ctrnkppa, t.ctrnowna, t.ctrnpurp, t.itrnnumanc, t.itrnanumanc, t.itrncocode,
         t.ctrnstate1, t.ctrnstate2, t.ctrnstate3, t.ctrnstate4, t.ctrnstate5, t.ctrnstate8, t.ctrntext1, t.ctrntext2, t.ctrntext3, t.ctrntext4,
         t.itrnpriority, t.ctrnvo, t.ctrndway, t.ctrnref, t.ctrnzakob, t.itrnpnum, t.itrnba2d, t.itrnba2c, t.itrnbnkid, t.itrnsubsys, t.itrnsscreg,
         t.ctrnidopen, t.ctrnidaffirm, t.ctrnctrl_type, t.ctrnemptytran, t.ctrndnvproc, t.ctrnclient_acc, t.idsmr, t.ctrnaccd_fake, t.ctrnaccc_fake,
         t.ctrnalias, t.ctrnideditc, t.ctrnideditd, t.ctrnstate6, t.ctrnstate7, t.ctrnstate9, t.ctrnstate0, t.ctrntext5,
         t.ctrnvychet, t.itrnkodalias, t.itrnkol, t.itrntek_num, t.dtrntrn_trunc,  null idsmr_old
    from v_trn_part_current t
   where t.dtrntran >= dv_d1 and t.dtrntran < dv_d2 + 1
     and (t.itrnbatnum != 6666 or t.itrnbatnum is null);
  nv_cnt := sql%rowcount;
  commit;
  writeprotocol('ubrr_trn_old_new: ��������� '|| nv_cnt ||' �������');

  if xxi.pref.get_Preference('UBRR_ACC_MATCHING.ACTIVE')='Y' and SYS_CONTEXT('B21','IDSmr')='1' then
  begin
    writeprotocol('ubrr_trn_old_new: ���������� ������� ���. ����������');

    insert into ubrr_data.ubrr_trn_old_new(itrnnum, itrnanum, dtrntran, dtrncreate, ctrnaccd, ctrncur, ctrnaccc, ctrncurc, mtrnsum, mtrnrsum, mtrnsumc, itrntype, itrnsop,
                                           itrnbatnum, itrndocnum, dtrndoc, dtrnval, dtrnshadow, ctrnmfoo, ctrncoracco, ctrnclient_inn, ctrnclient_kpp, ctrnclient_name,
                                           itrnsbcodea, ctrnmfoa, ctrncoracca, ctrnbnamea, ctrnacca, ctrninna, ctrnkppa, ctrnowna, ctrnpurp, itrnnumanc, itrnanumanc,
                                           itrncocode, ctrnstate1, ctrnstate2, ctrnstate3, ctrnstate4, ctrnstate5, ctrnstate8, ctrntext1, ctrntext2, ctrntext3, ctrntext4,
                                            itrnpriority, ctrnvo, ctrndway, ctrnref, ctrnzakob, itrnpnum, itrnba2d, itrnba2c, itrnbnkid, itrnsubsys, itrnsscreg, ctrnidopen,
                                           ctrnidaffirm, ctrnctrl_type, ctrnemptytran, ctrndnvproc, ctrnclient_acc, idsmr, ctrnaccd_fake, ctrnaccc_fake, ctrnalias,
                                           ctrnideditc, ctrnideditd, ctrnstate6, ctrnstate7, ctrnstate9, ctrnstate0, ctrntext5, ctrnvychet, itrnkodalias, itrnkol,
                                           itrntek_num, dtrntrn_trunc, idsmr_old, icusnum_d, iaccotd_d, iaccotd_c, caccmail_d)
    select t2.itrnnum, t2.itrnanum, t2.dtrntran, t2.dtrncreate,
           --t2.ctrnaccd,
           nvl((select nvl(m1.caccacc_new, m1.caccacc_go_new) cacc from ubrr_data.ubrr_acc_matching m1 where m1.caccacc_old = t2.ctrnaccd and m1.idsmr=t2.idsmr), t2.ctrnaccd) ctrnaccD,
           t2.ctrncur,
           --t2.ctrnaccc,
           nvl((select nvl(m1.caccacc_new, m1.caccacc_go_new) cacc from ubrr_data.ubrr_acc_matching m1 where m1.caccacc_old = t2.ctrnaccc and m1.idsmr=t2.idsmr), t2.ctrnaccc) ctrnaccC,
           t2.ctrncurc,
           t2.mtrnsum, t2.mtrnrsum, t2.mtrnsumc, t2.itrntype,  t2.itrnsop,
           t2.itrnbatnum, t2.itrndocnum, t2.dtrndoc, t2.dtrnval, t2.dtrnshadow, t2.ctrnmfoo, t2.ctrncoracco, t2.ctrnclient_inn, t2.ctrnclient_kpp, t2.ctrnclient_name,
           t2.itrnsbcodea, t2.ctrnmfoa, t2.ctrncoracca, t2.ctrnbnamea, t2.ctrnacca, t2.ctrninna, t2.ctrnkppa, t2.ctrnowna, t2.ctrnpurp, t2.itrnnumanc, t2.itrnanumanc,
           t2.itrncocode, t2.ctrnstate1, t2.ctrnstate2, t2.ctrnstate3, t2.ctrnstate4, t2.ctrnstate5, t2.ctrnstate8, t2.ctrntext1, t2.ctrntext2, t2.ctrntext3, t2.ctrntext4,
           t2.itrnpriority, t2.ctrnvo, t2.ctrndway, t2.ctrnref, t2.ctrnzakob, t2.itrnpnum, t2.itrnba2d, t2.itrnba2c, t2.itrnbnkid, t2.itrnsubsys, t2.itrnsscreg,
           t2.ctrnidopen, t2.ctrnidaffirm, t2.ctrnctrl_type, t2.ctrnemptytran, t2.ctrndnvproc, t2.ctrnclient_acc, '1' idsmr,
           t2.ctrnaccd_fake, t2.ctrnaccc_fake,
           t2.ctrnalias, t2.ctrnideditc, t2.ctrnideditd, t2.ctrnstate6, t2.ctrnstate7, t2.ctrnstate9, t2.ctrnstate0, t2.ctrntext5,
           t2.ctrnvychet, t2.itrnkodalias, t2.itrnkol, t2.itrntek_num, t2.dtrntrn_trunc, /*'8'*/ idsmr idsmr_old, --14.02.2020  �������� [20-71606]
           (select iacccus from xxi."acc" a where a.caccacc = t2.ctrnaccd and a.idsmr = t2.idsmr) icusnum_d,
           (select m.iaccotd from ubrr_data.ubrr_acc_matching m where m.caccacc_old = t2.ctrnaccD and m.idsmr=t2.idsmr) iaccotd_d,
           (select m.iaccotd_new from ubrr_data.ubrr_acc_matching m where m.caccacc_go_new = t2.ctrnaccC and m.idsmr=t2.idsmr) iaccotd_c,
           (select caccmail from xxi."acc" a where a.caccacc = t2.ctrnaccd and a.idsmr = t2.idsmr) caccmail_d
      from xxi."trn" PARTITION (TRN_PART_CURRENT) t2
     where t2.dtrntran >= dv_d1 and t2.dtrntran < dv_d2 + 1
       and (t2.itrnbatnum != 6666 or t2.itrnbatnum is null)
       and (t2.ctrnaccD in (select m.caccacc_old from ubrr_data.ubrr_acc_matching m where m.caccacc_old is not null and m.idsmr=t2.idsmr and m.mrk_openacc=1 and m.idsmr in ('8',
                                  '5','6','13', --02.03.2020 �������� [19-69558.2] �������� �������� �������������, ���������, �������������
                                  '4','9','15', --14.02.2020  �������� [20-71606] -->><<--02.12.2019 �������� [19-62184] ����������� ������ dup_val_on_index: ORA-00001: unique constraint (UBRR_DATA.P_TRN_OLD_NEW_NUM) 09.12.2019 https://redmine.lan.ubrr.ru/issues/69720
                                  '11','14',
                                  '7' ,'12','10')) -- 28.05.2020 UBRR Lazarev [20-74342] https://redmine.lan.ubrr.ru/issues/74342
            or t2.ctrnaccC in (select m.caccacc_old from ubrr_data.ubrr_acc_matching m where m.caccacc_old is not null and m.idsmr=t2.idsmr and m.mrk_openacc=1 and m.idsmr in ('8',
                                  '5','6','13', --02.03.2020 �������� [19-69558.2] �������� �������� �������������, ���������, �������������
                                  '4','9','15', --14.02.2020  �������� [20-71606] -->><<--02.12.2019 �������� [19-62184] ����������� ������ dup_val_on_index: ORA-00001: unique constraint (UBRR_DATA.P_TRN_OLD_NEW_NUM) 09.12.2019 https://redmine.lan.ubrr.ru/issues/69720
                                  '11','14',
                                  '7' ,'12','10'))) -- 28.05.2020 UBRR Lazarev [20-74342] https://redmine.lan.ubrr.ru/issues/74342
       ;
    nv_cnt := sql%rowcount;
    commit;

    writeprotocol('ubrr_trn_old_new: ��������� ���. ���������� '|| nv_cnt ||' �������');

  exception
    when dup_val_on_index then
      rollback;
      writeprotocol('ubrr_trn_old_new rollback dup_val_on_index: '||dbms_utility.format_error_stack || chr(10) || dbms_utility.format_error_backtrace);
      dbms_output.put_line('ubrr_trn_old_new rollback dup_val_on_index: '||dbms_utility.format_error_stack || chr(10) || dbms_utility.format_error_backtrace);
    when others then
      rollback;
      writeprotocol('ubrr_trn_old_new rollback unknown error: '||dbms_utility.format_error_stack || chr(10) || dbms_utility.format_error_backtrace);
      dbms_output.put_line('ubrr_trn_old_new rollback unknown error: '||dbms_utility.format_error_stack || chr(10) || dbms_utility.format_error_backtrace);
  end;

  end if;

  writeprotocol('ubrr_trn_old_new: ������� ���������');
exception
  when others then
    writeprotocol('ubrr_trn_old_new main idsmr='||SYS_CONTEXT('B21', 'IDSmr')||' unknown error: '||dbms_utility.format_error_stack || chr(10) || dbms_utility.format_error_backtrace);
end fill_trn_old_new;
--<<15.10.2019 �������� [19-62184] �������� �� ��� ��� �������� �-�� "����" https://redmine.lan.ubrr.ru/issues/67214#note-2

-->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
--------------------------------------------------------------------------------
-- �������� ���� ����������. ��� �������� INC
-- ������� ���������� ubrr_bnkserv_calc_new.fill_sbsnew_inc
function doc_is_inc( p_ntrnnum  in number
                    ,p_ntrnanum in number )
return boolean
is
  l_cidsmr smr.idsmr%type := sys_context('b21', 'idsmr');
  l_cnt    pls_integer;
  l_bret   boolean:=false;
  l_ctrnacca_tofk xxi.ups.cupsvalue%type := nvl(PREF.Get_Preference('UBRR_CHECK_PAY_BUDGET.FILL_SBSNEW_INC.CTRNACCA'),'03100|032.1|032.2'); --12.03.2021  ������� �.�.    [DKBPA-402]   ���: ����. ��������� ���������� �� �� ����� ���� (���)
begin
  select count(1)
    into l_cnt
    from dual
   where exists ( select 1
                    from xxi.v_trn_part_current t
                        ,acc a
                    where a.caccacc = t.ctrnaccc
                      and a.cacccur = t.ctrncurc
                      and a.caccprizn <> '�'
                      and t.ctrnaccc like gc_ls     -- ����������
                      and t.ctrncurc = 'RUR'
                      and t.itrnnum  = p_ntrnnum
                      and t.itrnanum = p_ntrnanum
                      -- �����������
                      and (  -- ���������������� (����������������)
                            (  (     t.ctrnmfoa is null
                                  or t.ctrnmfoa in ( select f.cfilmfo
                                                       from xxi."fil" f
                                                      where f.idsmr = l_cidsmr )
                               )
                               and
                               (    t.ctrnaccd like '407%'
                                 or t.ctrnaccd like '408%'
                                 or t.ctrnaccd like '20202%'
                                 or t.ctrnaccd like '20208%'
                                 or (     (    t.ctrnaccd like '303%'
                                            or t.ctrnaccd like '30223%'
                                            or t.ctrnaccd like '30232%'
                                            or t.ctrnaccd like '30233%'
                                            or t.ctrnaccd like '47416%'
                                          )
                                      and t.ctrnacca not like '401%'
                                      and t.ctrnacca not like '402%'
                                      and t.ctrnacca not like '403%'
                                    )
                               )
                            )
                            or
                            -- ������������� ��� �������������
                            (     t.ctrnmfoa not in ( select f.cfilmfo
                                                        from xxi."fil" f
                                                       where f.idsmr = l_cidsmr )
                              and t.ctrnacca not like '401%'
                              and t.ctrnacca not like '402%'
                              and t.ctrnacca not like '403%'
                            )
                          )
                      and not regexp_like(t.ctrnacca,'^('||l_ctrnacca_tofk||')') --12.03.2021  ������� �.�.    [DKBPA-402]   ���: ����. ��������� ���������� �� �� ����� ���� (���)
                );
    l_bret := (l_cnt=1);
  return l_bret;
end doc_is_inc;

-------------------------------------------------------------------------
-- �������� id �������� ��������� ��������� ��� ������ �������� ubrr_sbs_new
procedure get_link_trnnum_from_comm( p_nid   in  number
                                    ,p_nnum  out number
                                    ,p_nanum out number )
is
begin
  select st.itrnsbs_trnnum
        ,st.itrnsbs_trnanum
    into p_nnum
        ,p_nanum
    from ubrr_sbs_new s
        ,ubrr_trn_sbs st
   where s.id   = st.isbsid
     and s.id   = p_nid
     and rownum = 1;
exception when no_data_found then
          null;
end get_link_trnnum_from_comm;

--------------------------------------------------------------------------------
-- �������� id ���������-��������
-- �� id ��������� ��������� � ���� ��������
-- ��������� ��� �������� ���� INC (���� �������� �������� -���� �������� � ������)
procedure get_id_comm_doc( p_nnum       in  number
                          ,p_nanum      in  number
                          ,p_ctypecom   in  varchar2
                          ,p_isbstrnnum out number
                          ,p_csbsstat   out varchar2 )
is
begin
   select s.isbstrnnum
         ,s.csbsstat
     into p_isbstrnnum
         ,p_csbsstat
     from ubrr_trn_sbs t
         ,ubrr_sbs_new s
    where t.itrnsbs_trnnum  = p_nnum
      and t.itrnsbs_trnanum = p_nanum
      and t.isbsid          = s.id
      and s.csbstypecom     = p_ctypecom
      and s.isbstrnnum is not null
      and rownum            = 1;
exception
         when no_data_found then
              null;
end get_id_comm_doc;

--------------------------------------------------------------------------------
-- �������� ��������� �������� ��������� �������� �� id
-- ��������� ��� �������� ���� INC (���� ��������-���� �������� � ������)
procedure get_attrib_comm_doc( p_isbstrnnum in  number
                              ,p_csbsstat   in  varchar2
                              ,p_ddoc       out date
                              ,p_idocnum    out number
                              ,p_caccd      out varchar2
                              ,p_caccc      out varchar2
                              ,p_msum       out number
                              ,p_trntrc     out varchar2 )
is
begin
   if ( p_isbstrnnum is not null ) then
       -- ������ ��������-��������
       begin
          if lower(p_csbsstat) like '���������%' then
             select t.dtrndoc
                   ,t.itrndocnum
                   ,t.ctrnaccd
                   ,t.ctrnaccc
                   ,t.mtrnsum
                   ,'TRN'
               into p_ddoc
                   ,p_idocnum
                   ,p_caccd
                   ,p_caccc
                   ,p_msum
                   ,p_trntrc
               from xxi."trn" t
              where t.itrnnum  = p_isbstrnnum
                and t.itrnanum = 0;
          elsif lower(p_csbsstat) like '���������� � ���������%' then
             select tc.dtrcdoc
                   ,tc.itrcdocnum
                   ,tc.ctrcaccd
                   ,tc.ctrcaccc
                   ,tc.mtrcsum
                   ,'TRC'
               into p_ddoc
                   ,p_idocnum
                   ,p_caccd
                   ,p_caccc
                   ,p_msum
                   ,p_trntrc
               from xxi."trc" tc
              where tc.itrcnum  = p_isbstrnnum
                and tc.itrcanum = 0;
          end if;
       exception when no_data_found then
          null;
       end;
    end if;
end get_attrib_comm_doc;

--------------------------------------------------------------------------------
-- ��������� ������� ���������-��������
-- ��������� ��� �������� ���� INC (���� ��������-���� �������� � ������)
function msg_check_doc_inc( p_ntrnnum  in number
                           ,p_ntrnanum in number )
return varchar2
is
  l_isbstrnnum  ubrr_sbs_new.isbstrnnum%type;
  l_csbsstat    ubrr_sbs_new.csbsstat%type;

  l_ddoc        xxi.trn.dtrndoc%type;
  l_idocnum     xxi.trn.itrndocnum%type;
  l_caccd       xxi.trn.ctrnaccd%type;
  l_caccc       xxi.trn.ctrnaccc%type;
  l_nsum        xxi.trn.mtrnsum%type;
  l_trntrc      varchar2(3);

  l_cret        varchar2(2000);
begin
   if ( nvl(pref.get_preference( gc_pref_rework_link_commiss ),'0')='1' ) then
      if doc_is_inc( p_ntrnnum  => p_ntrnnum
                    ,p_ntrnanum => p_ntrnanum ) then
         -- �������� id ���������-��������
         get_id_comm_doc( p_nnum       => p_ntrnnum
                         ,p_nanum      => p_ntrnanum
                         ,p_ctypecom   => 'INC'
                         ,p_isbstrnnum => l_isbstrnnum
                         ,p_csbsstat   => l_csbsstat );
         -- �������� �������� ���������-��������
         get_attrib_comm_doc( p_isbstrnnum => l_isbstrnnum
                             ,p_csbsstat   => l_csbsstat
                             ,p_ddoc       => l_ddoc
                             ,p_idocnum    => l_idocnum
                             ,p_caccd      => l_caccd
                             ,p_caccc      => l_caccc
                             ,p_msum       => l_nsum
                             ,p_trntrc     => l_trntrc );

         if ( l_trntrc is not null) then
            l_cret := '�� ��������� ���� �������������� �������� � '|| case when l_trntrc='TRN' then '�������' else '���������' end || ' '||
                      '���� - '           ||to_char(l_ddoc,'dd.mm.yyyy')||','||
                      '����� ��������� - '||l_idocnum                   ||','||
                      '���� ������ - '    ||l_caccd                     ||','||
                      '���� ������� - '   ||l_caccc                     ||','||
                      '����� - '          ||trim(to_char(l_nsum,'FM999G999G999G999G990D00'))
                    ;
         end if;
      end if;
   end if;

   return l_cret;
end msg_check_doc_inc;

-------------------------------------------------------------------------
-- ���������� ������ ������� �������� �� �������
function f_pref_run_timer_commiss
return boolean
is
begin
  return ( nvl(pref.get_preference(gc_pref_run_timer_commiss),'0')='1' );
end f_pref_run_timer_commiss;

-------------------------------------------------------------------------
-- �������� ������������� ������� �� ����������� ���� ��������
function comm_freq( p_com_type in varchar2 )
return varchar2
is
  l_cret ubrr_rko_com_types.freq%type;
begin
  select t.freq
    into l_cret
    from ubrr_rko_com_types t
   where t.com_type = p_com_type;

   return l_cret;
exception when no_data_found then
      return null;   -- ����� �������� ��� �������������� �������� ����������� � �����������
end comm_freq;

-------------------------------------------------------------------------
-- �������� �������� ��������� "�� �������"
function comm_freq_is_timer( p_com_type in varchar2 )
return boolean
is
begin
  return ( comm_freq( p_com_type )=gc_comm_freq_timer );
end comm_freq_is_timer;

-------------------------------------------------------------------------
-- ���� ����������� ��������� ��������� ��� ����������� ������ SBS_NEW
function datereg_trn_from_link_comm( p_nid in number )
return date
is
  l_nnum  number;
  l_nanum number;
  l_dret  date;
begin
  get_link_trnnum_from_comm( p_nid   => p_nid
                            ,p_nnum  => l_nnum
                            ,p_nanum => l_nanum );

  select t.dtrntran
    into l_dret
    from xxi."trn" t
   where t.itrnnum  = l_nnum
     and t.itrnanum = l_nanum;

  return l_dret;
exception when no_data_found then
          return null;
end datereg_trn_from_link_comm;

------------------------------------------------------------------
-- ������� ������� ������� �������� �� �������
function enable_run_calc_timer_commis
return boolean
is
  l_pref_hh24  ups.cupsvalue%type;
  l_ddate_from date;
  l_bret       boolean       := false;
  l_cmsg       varchar2(4000):= $$plsql_unit||'.enable_run_calc_timer_commis';
begin

  -- ������� ���������� ��������� �������, ������� � �������� ����� ����������� ������ ��������
  -- � ������� hh24:mi
  l_pref_hh24 := pref.get_preference( gc_pref_from_hh_timer_commiss );
  if l_pref_hh24 is null then
     return false;
  end if;

  l_ddate_from := to_date( to_char( sysdate,'dd.mm.yyyy' )||' '||l_pref_hh24,'dd.mm.yyyy hh24:mi' );

  if ( sysdate >= l_ddate_from ) then
     l_bret := true;
  end if;

  return l_bret;
exception when others then
  l_cmsg := l_cmsg||'[l_pref_hh24='||l_pref_hh24||']';
  writeprotocol( 'Error '|| l_cmsg ||':'||dbms_utility.format_error_stack || chr(10) || dbms_utility.format_error_backtrace );
  return false;
end enable_run_calc_timer_commis;

--<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������

-->> 11.02.2021  ������ �.�.      �DKBPA-245 ��������� ������ ���������� �������� �� ������� ������ - �����
/*
��������� ����� ������ ���������� �������� �� �������� ������� UPS
*/
function get_free_limit( p_iobgcat obg.iobgcat%type,
                         p_iobgnum obg.iobgnum%type,
                         p_caccacc xxi.au_attach_obg.caccacc%type,
                         p_ndef_lim number default 100 ) return number
is
  nv_ret    number := p_ndef_lim;
  dv_max_au date;
  dv_lim_date   date   := ubrr_pref.Get_Date_Preference( pref.c_universuser,'UBRR_BUSINESS_FREE_LIMIT_DATE' );
  nv_free_lim_cnt   number := nvl( ubrr_pref.Get_Num_Preference(pref.c_universuser,'UBRR_BUSINESS_FREE_LIMIT'), p_ndef_lim);
begin

  select trunc(MAX(D_CREATE)) into dv_max_au
  from xxi.au_attach_obg
  where CACCACC = p_caccacc and
      c_newdata = to_char(p_iobgcat)||'/'||to_char(p_iobgnum);

  if dv_max_au>=dv_lim_date then
    nv_ret := nv_free_lim_cnt;
    dbms_output.put_line('>= nv_ret='||nv_ret);
  else
    dbms_output.put_line('ELSE  nv_ret='||nv_ret);
  end if;

  return nv_ret;

end;
--<< 11.02.2021  ������ �.�.      �DKBPA-245 ��������� ������ ���������� �������� �� ������� ������ - �����

-->>03.03.2021  ������� �.�.     DKBPA-264 ��� ��: ������� ����� � ����������� �� ���-�� ���� ��� �������� �����
-- ������ ���������� ����� �������� � ����������� �� ���-�� ���� ��� �������� �����
FUNCTION Get_Sum_First_Month(par_acc       in xxi.acc.CACCACC%type,
                             par_cur       in xxi.acc.CACCCUR%type,
                             par_datbeg    in date,
                             par_datend    in date,
                             par_sum       in number
                            )
  RETURN NUMBER
  IS

  cursor cur_acc_dat(p_acc xxi.acc.CACCACC%type,p_cur xxi.acc.CACCCUR%type,p_datbeg date, p_datend date) is
  select acc.DACCOPEN
    from acc
   where acc.CACCACC = p_acc
     and acc.CACCCUR = p_cur
     and acc.DACCOPEN between p_datbeg and p_datend;
   rec_acc_dat   cur_acc_dat%rowtype;

   l_mm_beg      number := extract(month from par_datbeg);
   l_yy_beg      number := extract(year from par_datbeg);
   l_dd_end      number := extract(day from par_datend);
   l_mm_end      number := extract(month from par_datend);
   l_yy_end      number := extract(year from par_datend);
   l_dd_open     number := 0;
   l_enable      xxi.ups.cupsvalue%type := nvl(PREF.Get_Preference('UBRR_BNKSERV_CALC_NEW_LIB.CALC_SUM_FIRST_MONTH.ENABLE'),'N');
   e_return      exception;
BEGIN

  --�������� ��������� ����������
  if l_enable <> 'Y' then
    raise e_return;
  end if;

  --���� ���� �� �������, �� ������ ����� ������� ���������� � ���������
  if par_datbeg is null or par_datend  is null then
    raise e_return;
  end if;

  --���� ����� ����������, �� ������ ����� ������� ���������� � ���������
  if l_mm_beg <> l_mm_end or l_yy_beg <> l_yy_end then
    raise e_return;
  end if;

  open cur_acc_dat(par_acc,par_cur,par_datbeg,par_datend);
  fetch cur_acc_dat into rec_acc_dat.daccopen;
  --���� �� ����� ������ ��� ���� ������ � ��������� �������, �� ������ ����� ������� ���������� � ���������
  if cur_acc_dat%notfound then
    raise e_return;
  end if;
  close cur_acc_dat;

  if rec_acc_dat.daccopen is null then
    --���� ���� �������� �����, �� ������ ����� ������� ���������� � ���������
    raise e_return;
  else
    l_dd_open := extract(day from rec_acc_dat.daccopen);
  end if;

  return round((par_sum/l_dd_end)*((l_dd_end-l_dd_open)+1),2) ;

EXCEPTION
 when OTHERS then
   if cur_acc_dat%isopen then close cur_acc_dat; end if;
   return par_sum;
END Get_Sum_First_Month;

-- �������� ����������� ����� �������� � ����������� �� ���-�� ���� ��� �������� �����
PROCEDURE Calc_Sum_First_Month(portion_date1  in date,
                               portion_date2  in date,
                               par_ls         in varchar2
                              )
  IS

  type t_tsbs Is record (
                         RowIdSBS        ROWID
                         );
  type t_tsbs_Table is Table of t_tsbs index by binary_integer;
  tsbsList t_tsbs_Table;

  cursor cur_sbs(p_date1 date,p_date2 date,p_ls varchar2,p_list_typecom varchar2) is
  select rowid
    from sbs
   where sbs.csbsacc like p_ls
     and sbs.MSBSTOLL_SUM > 0
     and regexp_like(sbs.csbsdo,'^('||p_list_typecom||')')
     and exists(select 1
                  from acc
                 where acc.CACCACC = sbs.csbsacc
                   and acc.DACCOPEN between p_date1 and p_date2
                );
  ln_list_typecom  xxi.ups.cupsvalue%type := nvl(PREF.Get_Preference('UBRR_BNKSERV_CALC_NEW_LIB.CALC_SUM_FIRST_MONTH.TYPECOM_UBRR'),'RKBK|RKBP|RKO|R_EXP|REB_PE|R_LIGHT') ;
BEGIN

  WriteProtocol('�������� UBRR_BNKSERV_CALC_NEW_LIB.Calc_Sum_First_Month ['||
                'portion_date1=' ||to_char(portion_date1,'dd.mm.yyyy') ||';'||
                'portion_date2=' ||to_char(portion_date2,'dd.mm.yyyy') ||';'||
                'par_ls='        ||par_ls         ||';'
                );

  --�������� ����������� �������� �� ������ ����� � ������
  open cur_sbs(portion_date1,portion_date2,par_ls,ln_list_typecom);
  fetch cur_sbs bulk collect into tsbsList;
  close cur_sbs;

  if tsbsList.count > 0 then
    forall idx in tsbsList.first .. tsbsList.last
      --������� �����
      update sbs
         set sbs.msbstoll_sum = ubrr_xxi5.ubrr_bnkserv_calc_new_lib.get_sum_first_month(par_acc    => sbs.csbsacc,
                                                                                        par_cur    => sbs.csbscur,
                                                                                        par_datbeg => portion_date1,
                                                                                        par_datend => portion_date2,
                                                                                        par_sum    => sbs.msbstoll_sum
                                                                                        )
       where rowid = tsbsList(idx).RowIdSBS;
  end if;

  WriteProtocol('��������� UBRR_BNKSERV_CALC_NEW_LIB.Calc_Sum_First_Month ���-�� ������� '||tsbsList.count);

EXCEPTION
  when OTHERS then
       writeprotocol('Error in ' ||$$plsql_unit||'.Calc_Sum_First_Month ['||
                              'portion_date1=' ||to_char(portion_date1,'dd.mm.yyyy') ||';'||
                              'portion_date2=' ||to_char(portion_date2,'dd.mm.yyyy') ||';'||
                              'par_ls='        ||par_ls         ||';'||
                              ']'||
                              dbms_utility.format_error_backtrace || chr(10) || dbms_utility.format_error_backtrace
                    );
END Calc_Sum_First_Month;
--<<03.03.2021  ������� �.�.     DKBPA-264 ��� ��: ������� ����� � ����������� �� ���-�� ���� ��� �������� �����

-->>19.07.2021  ������� �.�.     DKBPA-1571   �� ��������. �������� �������� � ������ "������"
--������ ��������� ���������� �������� ������ � �������, ������������� ��������� ��� ��������� ��������
FUNCTION Get_Last_Itrcnum
  RETURN NUMBER
  IS
BEGIN
  RETURN iLast_Itrcnum;
END Get_Last_Itrcnum;

--�������� ��������� �������� ������ � �������, ������������� ��������� ��� ��������� ��������
PROCEDURE Set_Last_Itrcnum ( par_Itrcnum IN NUMBER )
  IS
BEGIN
  iLast_Itrcnum := par_Itrcnum;
END Set_Last_Itrcnum;

--���������� �������, �������� � ��������� �� ������
PROCEDURE Set_Check_Online_Trc( par_Check_Trc IN VARCHAR2 )
  IS
BEGIN
  gc_Check_Online_Trc := par_Check_Trc;
END Set_Check_Online_Trc;
--<<19.07.2021  ������� �.�.     DKBPA-1571   �� ��������. �������� �������� � ������ "������"

end ubrr_bnkserv_calc_new_lib;
/
