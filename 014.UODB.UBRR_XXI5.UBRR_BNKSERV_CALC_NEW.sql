CREATE OR REPLACE PACKAGE UBRR_XXI5."UBRR_BNKSERV_CALC_NEW" as
/*************************************************** HISTORY *****************************************************\
   ����          �����          id        ��������
----------  ---------------  ---------  ------------------------------------------------------------------------------
05.05.2016  �������� �.�.    [16-1808.2.3.5.4.3.2]  #29736  ��� ���
23.09.2016  �������� �.�.    [16-2222]  #35311  �������� �� �������� �������� ����� + �������� �� ������ "��������"
06.10.2016  �������� �.�.    [16-2222]  #35311  ���������� �������� �� �������� �������� �����
14.06.2018  ubrr korolkov    [17-1071]  ����������� ������ �� PP6_NTK ������ #50487
03.07.2018  ������� �.�.     [18-465]   #52895  ���: ������� ����� �� ���
01.02.2019  ������� �.�.     [19-58770]   ��������� ���� ������� ����������� �������
25.02.2019  ������� �.�.     [17-1790] ���: ��������� �� ��� ��� ������� ������������ ���������
06.03.2019  ������� �.�.     [18-58177.2] ���. ����������� (������ �������� ��������)
02.07.2019  ��������         [19-61974]   ���: ���������� �������� �� �����������
11.07.2019  ��������         [19-62974] II ���� ���.����.�����. ��������������� ������� ����� ����� �� ���
24.07.2019  ������� �.�.     [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
07.08.2019  ��������         [19-62974]   III ���� ���. ��������������� ������� ����� ����� �� ���
03.08.2019  ������� �.�.     [19-62808]   ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
13.12.2019  ������� �.�.     [69650]    ����� �������� ���� - �������� �� ����������
09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
\*************************************************** HISTORY *****************************************************/
  FUNCTION CalcEveryDayComiss
   (
    p_Date in date, -- ���� �������
    p_TypeCom IN NUMBER,
    /* ��� ��������
      1 - �� ���������� ��������
      2 - �� ���������� �������� ����� 17-00
      4 - �� ���������� �������� � ������ ��
      8 - ��
      �������� ������ ���������� �������� ���������������.
      �������� 1+2+4 = 7
    */
    p_ls in varchar2 default null, -- ���� ��� ������� ��������
    p_RegDate in date default null, -- ���� ����������� ����������
    p_Mess out varchar2

  ) RETURN NUMBER;

  FUNCTION GetSumComiss (
    p_TrnNum IN trn.itrnnum%TYPE,
    p_TrnAnum IN trn.itrnanum%TYPE,
    p_Acc IN acc.caccacc%TYPE,
    p_Cur IN acc.cacccur%TYPE,
    p_Otd IN acc.iaccotd%TYPE,
    p_TypeCom IN VARCHAR2,
    p_SumTrn IN NUMBER,
    p_SumBefo IN NUMBER DEFAULT NULL
   ) RETURN NUMBER;

  FUNCTION GetAccComiss ( p_Acc       IN acc.caccacc%TYPE
                         ,p_Cur       IN acc.cacccur%TYPE
                         ,p_otd_tarif in acc.iaccotd%TYPE default null -- 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���
                         ,p_Otd       IN acc.iaccotd%TYPE
                         ,p_TypeCom   IN VARCHAR2
                         ,p_Pack      OUT VARCHAR2
  ) RETURN VARCHAR2;


  FUNCTION CalcEveryMonthsComiss (p_portion_date1 in date,
                                  p_portion_date2 in date,
                                  p_dtran in date,
                                  p_ls in varchar2 default null,
                                  p_test in number default 0,
                                  p_Mess out varchar2
                                 )
  RETURN NUMBER;

  FUNCTION RegEveryMonthsComiss (p_portion_date1 in date,
                                 p_portion_date2 in date,
                                 p_dtran in date,
                                 p_ls in varchar2 default null,
                                 p_test in number default 0,
                                 p_Mess out varchar2
                                )
  RETURN NUMBER;

  -->> ubrr 06.10.2016 �������� �.�.   [16-2222]  #35311  ���������� �������� �� �������� �������� �����
  FUNCTION CalcEveryDayComissAll_UBRR
   (
    p_Date in date, -- ���� �������
    p_TypeCom IN NUMBER,
    /* ��� ��������
      -->> ���� ��� ����� ��������
      1 - �� ���������� ��������
      2 - �� ���������� �������� ����� 17-00
      4 - �� ���������� �������� � ������ ��
      --<< ���� ��� ����� ��������
      8 - ��
      �������� ������ ���������� �������� ���������������.
      �������� 1+2+4 = 7
    */
    p_ls in varchar2 default null, -- ���� ��� ������� ��������
    p_RegDate in date default null, -- ���� ����������� ����������
    p_Mess out varchar2
  ) RETURN NUMBER;

  FUNCTION CalcEveryDayComissUBRR
   (
    p_Date in date, -- ���� �������
    p_TypeCom IN NUMBER,
    /* ��� ��������
      -->> ���� ��� ����� ��������
      1 - �� ���������� ��������
      2 - �� ���������� �������� ����� 17-00
      4 - �� ���������� �������� � ������ ��
      --<< ���� ��� ����� ��������
      8 - ��
      �������� ������ ���������� �������� ���������������.
      �������� 1+2+4 = 7
    */
    p_ls in varchar2 default null, -- ���� ��� ������� ��������
    p_RegDate in date default null, -- ���� ����������� ����������
    p_Mess out varchar2
  ) RETURN NUMBER;
  --<< ubrr 06.10.2016 �������� �.�.   [16-2222]  #35311  ���������� �������� �� �������� �������� �����

-->>> ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���
-- �������� �� ������� ����� ��� ( for ubrr_data.ubrr_sbs_new )
  function calc_krc_managment_new ( p_portion_date1 in date
                                   ,p_portion_date2 in date
                                   ,p_ls            in varchar2                  -- ���� ��� ������� ��������
                                   ,p_dtran         in date
                                   ,p_mess          in out varchar2
                                   ,p_idsmr         in varchar2
  ) return number;
--<<< ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���

-- >> ubrr 06.03.2019 ������� �.�. [18-58177.2] ���. ����������� (������ �������� ��������)
-- �������� �� �������� ���� � ������ 336 � ������ <=1e8
-- ������������ � ��� ����� � ��� ���
  function insert_besp_commis( p_Date in  date
                              ,p_ls   in  varchar2 default null
                              ,p_Mess out varchar2 )
  return number;
-- << ubrr 06.03.2019 ������� �.�. [18-58177.2] ���. ����������� (������ �������� ��������)

  procedure UpdateAccComiss (
    p_TypeCom in number,
    p_date in date,
    p_regdate in date,
    p_ls in varchar2
   ,p_change_datereg in pls_integer default 1 );  --ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������

  function Register(
    p_regdate in date,
    p_TypeCom in number,
    p_Mess out varchar2,
    p_portion_date1 in date default null,
    p_portion_date2 in date default null,
    p_ls in varchar2,
    p_mode_available_rest in boolean default false, -- ubrr 21.02.2019 ������� �.�. [17-1790] ���: ��������� �� ��� ��� ������� ������������ ���������
    p_mode_hold           in boolean default false  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
    )
  return number;

  procedure set_purp_ntk;

  -->>08.11.2018 �������� [18-592.2] ���. ������� �������� �� ���������. �������� ��������� ������ 114/12
  procedure delete_rb_ib_lt(d1 in date, d2 in date, trndate in date, p_ls in varchar2, verr out varchar2);
  --<<08.11.2018 �������� [18-592.2] ���. ������� �������� �� ���������. �������� ��������� ������ 114/12

-->> 01.02.2019 ������� �.�. [19-58770] ��������� ���� ������� ����������� �������
  -- �� ��������� UBRR_XXI5.UBRR_BNKSERV
  function CalcProlongation -->><<--07.08.2019 �������� [19-62974] III ���� ���
   (
    p_Date in date,                 -- ���� �������
    p_ls in varchar2 default null,  -- ���� ��� ������� ��������
    p_RegDate in date default null, -- ���� ����������� ����������
    p_Mess out varchar2
  ) return number;
--<< 01.02.2019 ������� �.�. [19-58770] ��������� ���� ������� ����������� �������

  -->>02.07.2019 �������� [19-61974] ���: ���������� �������� �� �����������
  function check_exclude_client(pBo1         in trn.itrntype%type,
                                pMfoa        in trn.ctrnmfoa%type,
                                dTran        in trn.dtrntran%type,
                                piTrnNumanc  in trn.itrnnumanc%type,
                                pAcc         in acc.caccacc%type,
                                pPurp        in trn.ctrnpurp%type default null, -- ���������� �������
                                pName        in trn.ctrnowna%type default null -- ������������ ����� ����������
                               ) return number;
  --<<02.07.2019 �������� [19-61974] ���: ���������� �������� �� �����������

  -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
  -- �������� �� ���������� - ���������� ubrr_sbs_new
  function fill_sbsnew_inc( p_date       in  date -- ���� �������
                           ,p_date_begin in  date -- � ����� ���� ����� ��������
                           ,p_cls        in  varchar2 default null
                           ,p_cmess      out varchar2
                           ,p_test       in  pls_integer default 0 )
  return number;

  -- �������� �� ���������� INC - ���������� � �����������
  function calc_inc( p_date     in  date           -- ���� �������
                    ,p_cls      in  varchar2 default null
                    ,p_date_reg in  date           -- ���� ����������� ����������
                    ,p_cmess    out varchar2
                    ,p_test     in  pls_integer default 0 )
  return number;

  -- ������ �������� �� ������� ��� ����� � ���
  -- ��������� ������ �������� � ������� (����� ;)
  function calc_timer_commiss( p_date          in  date                  -- ���� �������
                              ,p_cls           in  varchar2 default null -- ���� ��� ������� ��������
                              ,p_date_reg      in  date     default null -- ���� ����������� ����������
                              ,p_clist_typecom in  varchar2              -- ��������� ������ �������� � �������
                              ,p_cmess         out varchar2
                              ,p_test          in  pls_integer default 0 )
  return number;

  -- ������ �������� �� ������� ��� ����� � ���
  function calc_timer_commiss( p_date        in  date                  -- ���� �������
                              ,p_cls         in  varchar2 default null -- ���� ��� ������� ��������
                              ,p_date_reg    in  date     default null -- ���� ����������� ����������
                              ,p_tbl_typecom in  tblchar20             -- ������ �������� � �������
                              ,p_cmess       out varchar2
                              ,p_test        in  pls_integer default 0 )
  return number;

  -- ������ ������� �� �����
  procedure run_commiss_for_timer( p_idsmr         in number
                                  ,p_date          in date  -- ���� �������
                                  ,p_cls           in varchar2
                                  ,p_date_reg      in date  -- ���� �����������
                                  ,p_clist_typecom in varchar2 default null
                                  ,p_test          in pls_integer default 0 );

  -- �������� ������ �������� � ����� "�� �������"
  -- p_nmain=1 - �����; 16 - ���
  procedure create_jobs_commiss_for_timer( p_nmain in pls_integer );

  --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
  
  -->> 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
  --�������� ���� �� ������ ��� ���������� �������� ������ (������� ������)
  FUNCTION CheckUniqACC(p_acc      IN UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.CACC%type,
                        p_dtrn     IN UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.DOPENTARIF%type,
                        p_com_type IN UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.COM_TYPE%type,
                        p_idsmr    IN UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.IDSMR%type 
                        )
    RETURN NUMBER;
  
  --������ �������� ����������/����������� �����
  FUNCTION GetDayUniqACC(p_acc      IN UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.CACC%type,
                         p_dtrn     IN UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.DOPENTARIF%type,
                         p_com_type IN UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.COM_TYPE%type,
                         p_idsmr    IN UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.IDSMR%type 
                         )
    RETURN UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.DAILY%type;    
  --<< 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)

end;
/
CREATE OR REPLACE PACKAGE BODY UBRR_XXI5."UBRR_BNKSERV_CALC_NEW" as
/*************************************************** HISTORY *****************************************************\
   ����          �����          id        ��������
----------  ---------------  -----------  ------------------------------------------------------------------------------
05.05.2016  �������� �.�.    [16-1808.2.3.5.4.3.2] #29736  ��� ���
23.09.2016  �������� �.�.    [16-2222]    #35311  �������� �� �������� �������� ����� + �������� �� ������ "��������"
06.10.2016  �������� �.�.    [16-2222]    #35311  �������� �� �������� �������� �����
18.10.2016  �������� �.�.    [16-2222.2]  #36740  �������� �� �� ���������� �������� (���)
10.01.2017  �������� �.�.    [16-2222]    #35311  ����������� ������ �� �������� �� ����� ���� �� ��� � �-���������
18.01.2017  �������� �.�.    [16-3100.1]  #39518  ��������� ���������� �������� �� �������� �����
30.01.2017  �������� �.�.    [16-3223]    #39858  ���������� ������ �� "������������" (���)
07.03.2017  �������� �.�.    [17-166]     ���: ���� ����� ����� �� �� "������������", "������������ �������" (���)
                                            https://redmine.lan.ubrr.ru/issues/40971
10.03.2017  ����������� �.�. [16-3100.2]  ���: �������� �� �������� ��� ����� ���������
20.04.2017  �������� �.�.    [17-452]     ���: ������� �� �������� �� ������ �������� https://redmine.lan.ubrr.ru/issues/42479
12.05.2017  ����������� �.�. [16-3100.2]  ���: �������� �� �������� ��� ����� ���������
18.05.2017  ����������� �.�. [16-3100.2]  ���: �������� �� �������� ��� ����� ���������
14.06.2017  ����������� �.�. [17-71]      ���: ������ �������� ��������� �� ��������� �� �������� �� ����������
22.08.2017  �������� �.�.    [17-1031]    ���: �������� ����� ���������� ��� ������� �������� ��� �������� ������� � ������ ��
01.09.2017  �������� �.�.    [17-847]     ���: ������������ �������� �������� �� ��������� ������� # 46295
23.10.2017  ����� �.�.       17-1225      ���: ������������� �������� �� ������� ������� � ������ ��
10.11.2017  �������� �.�.    [17-1447]    ���: �������� �������� ����������� �������� �� ������� ����� (���)
07.11.2017  ubrr korolkov    [17-1071]    ���: ���������� �������� �� �������
09.01.2018  ����� �.�.       [17-913.2]   ���: ���/�� ��� �������� �����
02.02.2018  ubrr korolkov    [17-1071]    ����������� ������ #47689#note-114
16.02.2018  ubrr korolkov    [17-1071]    ����������� ������ PP6
21.02.2018  ubrr korolkov    [18-12.1]    ���: �������������� ������ �� �������� �� ������� � ������ �� ��� ���
26.02.2018  ubrr korolkov    [17-913.2]   ����� ���������� ���/�� 172/32
19.04.2018  ������� �.�.     [18-86]      ���: �������� �� �������
01.06.2018  �������� �.�.    [18-86]      ���: �������� �� ������� - ����������� ������ � ���� �� https://redmine.lan.ubrr.ru/issues/52982
14.06.2018  ubrr korolkov    [17-1071]    ����������� ������ �� PP6_NTK ������ #50487
22.06.2018  ������ �.�.      [18-464]     ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
03.07.2018  ������� �.�.     [18-465]   �������� �� ������� ����� ���
01.08.2018  ������� �.�.     [18-465].2  #52895  ���: ������� ����� �� ���
19.09.2018  ������� �.�.     [18-251]     ���: ����� ���������� �� �������� �� ������� � ������ �� ("���������")
16.10.2018  ��������         [18-56489]   ���: ������� �� ������ �� �� "��������"
23.10.2018  ��������         [18-56613]   �� "������ ������" (�� ���� �� "��������") ��� ��� � 01.11.18
02.11.2018  ��������         [18-592.2]   ���. ������� �������� �� ���������
27.12.2018  ��������         [15-43]      ���: ����� ����� ����� � ��������� ������� �� ����� ��������
29.01.2019  ��������         [18-592.2]   ���. ������� �������� �� ���������
01.02.2019  ������� �.�.     [19-58770]   ��������� ���� ������� ����������� �������
07.02.2019  ������� �.�.     [18-58411]   ���: �� "�����" � ������ "������"
12.02.2019  ������� �.�.     [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
25.02.2019  ������� �.�.     [17-1790]    ���: ��������� �� ��� ��� ������� ������������ ���������
06.03.2019  ������� �.�.     #60267       ������ ��� �������� ���������� ��������. ������� �������� ��������
06.03.2019  ������� �.�.     [18-58177.2] ���. ����������� (������ �������� ��������)
07.03.2019  ������� �.�.     [#60292]     ������ ��� ������������� �������� �������� UL_FL � UL_FL_VB
12.03.2019  ������� �.�.     [19-60337]   ���: ���������� ���� ���������� � �������� �� ���������� � ������ ��
12.03.2019  ��������         [#60496]     ������ ��� �������� �� ���� CTS �������� �� ���������� ��������� ������ https://redmine.lan.ubrr.ru/issues/60496
14.03.2019  ��������         [#60496]     ������ ��� �������� �� ���� CTS �������� �� ���������� ��������� ������ https://redmine.lan.ubrr.ru/issues/60496#note-4
01.04.2019  ������� �.�.     [18-58177.2] ����� ����������: �������� ����.
16.04.2019  ������� �.�.     [18-58177.2] ������ ����� ������ �� ���������
18.04.2019  ������ �.�.      [17-1790]    ����� ����������: ����������� ������� ���������� �������� ��� ������� �� 24:00
31.05.2019  ������� �.�.     [19-59153]   ���. ����� �������� � ������ ����� "������-����� 3,6,12"
07.06.2019  ��������         [19-59153]   ���: ����� �������� � ������ ����� "������-����� 3,6,12" https://redmine.lan.ubrr.ru/issues/62797#note-9
11.06.2019  ��������         [19-62974]   ���. ���������� ��������: ��������������� ������� ����� ����� �� ���
02.07.2019  ��������         [19-61974]   ���: ���������� �������� �� �����������
04.07.2019  ��������         [19-62974]   II ���� ���.����.�����. ��������������� ������� ����� ����� �� ���
24.07.2019  ������� �.�.     [19-62974]   III ���� �����. ��������������� ������� ����� ����� �� ���
01.08.2019  ��������         [19-62974]   III ���� ���. ��������������� ������� ����� ����� �� ���
03.08.2019  ������� �.�.     [19-62808]   ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
14.10.2019  ��������         [19-62184]   ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
13.12.2019  ������� �.�.     [69650]   ����� �������� ���� - �������� �� ����������
16.01.2020  ��������         [20-70655]   ����� ����� "������" ��� ���
22.01.2019  ��������         [19-64846]   ���: ����������� �� ��������� ������ � �� + ���� ������ "������������ ��-���" �� ������� �����
13.02.2020  ��������         [20-71580]   �� "����� ����" ���� �������� �� ���������� �� ����������
14.02.2020  ��������         [20-71606]   ������������� �������� ����������, �-�������������, �����������
26.02.2020  ��������         [20-71832]   ���: ��������� ������ "������" (���)
02.03.2020  ��������         [19-69558.2] �������� �������� �������������, ���������, �������������
04.03.2020  ������� �.�.     [20-71832]   ���: ��������� ������ "������" (���)
13.03.2020  ������� �.�.     [20-72185]   ���/�� 112/101 (������-����� 6") �� ����������������� � �� ��������� ����� ��������� ����� (01.01.2020)
23.03.2020  ������� �.�.     [20-73286]   ���������� ���� ���������� � �������� � ������ ��
09.04.2020  ������� �.�.     [20-73890]   ������ ���/�� 112/102 (������-����� 12") �� �����������������
28.05.2020  UBRR Lazarev     [20-74342]   https://redmine.lan.ubrr.ru/issues/74342
29.05.2020  ������ �.�.      [20-74767] ����������: ���������� �������� �� ���. 114/16 � ������ ������� ������������ 114/16 
02.07.2020  ������ �.�.      [20-74342.1]   ���. �������� �� ���������� ������������� �������� �������������, �������������.
03.07.2020  ������ �.�.      [20-76522]   ������ ��� �������� ������� �� ���������� �� �� "����� ����"
31.08.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
29.09.2020  ������� �.�.     [20-80050]   ����: �� ������������� ���/�� ��� ����� ������
30.09.2020  ������� �.�.     [20-73382.2] �������������� ������ �� �� �������� ��������� �� ������
02.10.2020  ������� �.�.     [20-73382.3] �������������� ������ �� �� �������� ��������� �� ������
06.10.2020  ������� �.�.     [20-74693] ����������: ������� �������� �� ���������� (������� ��������+%%) �� �� ����� ����
\*************************************************** HISTORY *****************************************************/

  gc_is_vuz constant number(1) := ubrr_util.isVuz; -- 07.11.2017 ubrr korolkov 17-1071

  BankIdSmr   varchar2(3);
  dDateR      date;
  mtarif      number;
  mtarifPrc   number;
  itest       number := 0;
  g_tarif_id  ubrr_sbs_new.tarif_id%type; -- 21.02.2018 ubrr korolkov 18-12.1
  -->>28.01.2020 �������� [19-64846]
  dg_date_start constant date := to_date('01.01.1990', 'dd.mm.rrrr');
  dg_date_end   constant date := to_date('01.01.4000', 'dd.mm.rrrr');
  --<<28.01.2020 �������� [19-64846]

-- >> 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���
  procedure writeprotocol(cmess in varchar2)
  is
  begin
    ubrr_bnkserv_calc_new_lib.writeprotocol(cmess);
  end writeprotocol;
-- << 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���

  -->>02.07.2019 �������� [19-61974] ���: ���������� �������� �� �����������
  function check_exclude_client(pBo1         in trn.itrntype%type,
                                pMfoa        in trn.ctrnmfoa%type,
                                dTran        in trn.dtrntran%type,
                                piTrnNumanc  in trn.itrnnumanc%type,
                                pAcc         in acc.caccacc%type,
                                pPurp        in trn.ctrnpurp%type default null, -- ���������� �������
                                pName        in trn.ctrnowna%type default null -- ������������ ����� ����������
                                ) return number
  is
    vtAcc   cusban.accounts;
    vAcc    acc.caccacc%type;
    vPurp   trn.ctrnpurp%type;
    vName   trn.ctrnowna%type;
    vBo1    trn.itrntype%type;
    result  number;
  begin
    if pBo1 = 11 then
      select ctrcacca, ctrcpurp, ctrcowna, itrctype
        into vAcc, vPurp, vName, vBo1
        from trc
       where itrcnum = piTrnNumanc
         and itrcanum = 0;
    else
      vBo1  := pBo1;
      vAcc  := pAcc;
      vPurp := pPurp;
      vName := pName;
    end if;

    cusban.getAccounts(vtAcc, vAcc);
    if vPurp is not null then
      cusban.getAccounts(vtAcc, vPurp);
    end if;
    if vName is not null then
      cusban.getAccounts(vtAcc, vName);
    end if;

    if vtAcc.count > 0 then
      for i in vtAcc.first .. vtAcc.last loop
      begin
        select 1
          into result
          from ubrr_rko_excl_cli e
         where e.bo1 = vBo1
           and e.cmfoa = pMfoa
           and e.crecpacc = vtAcc(i)
           and trunc(dTran) >= e.dstartdate and trunc(dTran) < e.denddate
           and (e.Idsmr is null or e.Idsmr = decode(BankIdSmr, '16', '16', '1'));
      exception
        when no_data_found then
          result := 0;
      end;
      end loop;
    end if;

    return result;
  exception
    when others then
      return 0;
  end;
  --<<02.07.2019 �������� [19-61974] ���: ���������� �������� �� �����������

---------------------------------------------------------------
  --��������� ����� �������� �� ��������
  -- >> 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���
  function GetTarifId ( p_Acc     in acc.caccacc%type
                       ,p_Cur     in acc.cacccur%type
                       ,p_Otd     in acc.iaccotd%type
                       ,p_TypeCom in varchar2
                       ,p_WithCat in number
                      ) return number
  IS
    vId number;
  begin
    return ubrr_bnkserv_calc_new_lib.GetTarifId( p_Acc       => p_Acc
                                                ,p_Cur       => p_Cur
                                                ,p_Otd       => p_Otd
                                                ,p_TypeCom   => p_TypeCom
                                                ,p_WithCat   => p_WithCat
                                                ,p_BankIdSmr => BankIdSmr
                                                ,p_dater     => dDateR );
  end GetTarifId;
  -- << 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���


---------------------------------------------------------------
-- >> 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���
  function GetSumComiss ( p_TrnNum  in trn.itrnnum%type
                         ,p_TrnAnum in trn.itrnanum%type
                         ,p_Acc     in acc.caccacc%type
                         ,p_Cur     in acc.cacccur%type
                         ,p_Otd     in acc.iaccotd%type
                         ,p_TypeCom in varchar2
                         ,p_SumTrn  in number
                         ,p_SumBefo in number default null
                         )
  return number
  is
  begin
      -->> 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
      IF ubrr_bnkserv_calc_new.CheckUniqACC(p_acc => p_Acc, p_dtrn => dDateR, p_com_type => p_TypeCom, p_idsmr => SYS_CONTEXT ('B21','IDSmr')) > 0 and ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif = 'Y' THEN
        return ubrr_bnkserv_calc_new_lib.GetSumComiss_Uniq( p_TrnNum      => p_TrnNum
                                                            ,p_TrnAnum     => p_TrnAnum
                                                            ,p_Acc         => p_Acc
                                                            ,p_Cur         => p_Cur
                                                            ,p_Otd         => p_Otd
                                                            ,p_TypeCom     => p_TypeCom
                                                            ,p_SumTrn      => p_SumTrn
                                                            ,p_SumBefo     => p_SumBefo
                                                            ,p_g_tarif_id  => g_tarif_id
                                                            ,p_mtarif      => mtarif
                                                            ,p_mtarifPrc   => mtarifPrc
                                                            ,p_BankIdSmr   => BankIdSmr
                                                            ,p_dater       => dDateR );
      ELSE
        return ubrr_bnkserv_calc_new_lib.GetSumComiss( p_TrnNum      => p_TrnNum
                                                      ,p_TrnAnum     => p_TrnAnum
                                                      ,p_Acc         => p_Acc
                                                      ,p_Cur         => p_Cur
                                                      ,p_Otd         => p_Otd
                                                      ,p_TypeCom     => p_TypeCom
                                                      ,p_SumTrn      => p_SumTrn
                                                      ,p_SumBefo     => p_SumBefo
                                                      ,p_g_tarif_id  => g_tarif_id
                                                      ,p_mtarif      => mtarif
                                                      ,p_mtarifPrc   => mtarifPrc
                                                      ,p_BankIdSmr   => BankIdSmr
                                                      ,p_dater       => dDateR );
     END IF;
     --<< 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
  end GetSumComiss;
  -- << 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���

  -- ����� ���� ������� ��������
  -- p_otd_tarif ��� ��� ����������� ������ (���������� ��� ���)
  -- p_Otd       ��� ��� ����������� ������
  FUNCTION GetAccComiss ( p_Acc       IN acc.caccacc%TYPE
                         ,p_Cur       IN acc.cacccur%TYPE
                         ,p_otd_tarif in acc.iaccotd%type default null-- 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���
                         ,p_Otd       IN acc.iaccotd%TYPE
                         ,p_TypeCom   IN VARCHAR2
                         ,p_Pack      OUT VARCHAR2
  ) RETURN VARCHAR2
  IS
    vId NUMBER;
    vAccMask VARCHAR2(25);
    IsIP NUMBER;
    -->> 21.02.2018 ubrr korolkov 18-12.1
    lc_ras_cat constant number(3) := 112;
    lc_ras_num constant number(4) := 1017;
    l_cat               obg.iobgcat%type := 0;
    l_num               obg.iobgnum%type := 0;
    --<< 21.02.2018 ubrr korolkov 18-12.1
    l_otd_tarif         acc.iaccotd%type;  -- 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���
  BEGIN
    l_otd_tarif := nvl( p_otd_tarif,p_Otd ); -- 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���
    vAccMask := '';
    vId := GetTarifId (p_Acc, p_Cur, l_otd_tarif, p_TypeCom, 1); -- 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���
    IF vId = 0 THEN
      vId := GetTarifId (p_Acc, p_Cur, l_otd_tarif, p_TypeCom, 0); -- 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���
      p_Pack := case when BankIdSmr = '16' then '�������' -->><<--21.06.2019 �������� [19-62974] �������������� ������� � �������
                     when p_TypeCom in ('PE6', 'PE9', 'PES6', 'PES9') then '������' -- 07.11.2017 ubrr korolkov 17-1071
                     when p_TypeCom in ('PES9_PE','PE9_PE','PE6_PE','PES6_PE') then '������ � 01.07.2018'  -->><<-- 22.06.2018 ������ �.�. [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                     when p_TypeCom in ('R_LIGHT') then '�� "������ ������"' -->><<-- 23.10.2018 �������� [18-56613] �� "������ ������" (�� ���� �� "��������") ��� ��� � 01.11.18
                     else '' end;  -->><<-- ubrr 06.10.2016 �������� �.�. 16-2222 ���������� �������� �����
    ELSE
      BEGIN
        SELECT cOBGName, obg.iobgcat, obg.iobgnum
        INTO p_Pack, l_cat, l_num
        FROM ubrr_data.ubrr_rko_tarif c, obg
        WHERE c.id = vId
          AND obg.iobgcat = c.cat
          AND obg.iobgnum = c.grp;
      EXCEPTION
        WHEN OTHERS THEN
          p_Pack := '???';
      END;
    END IF;
    IF BankIdSmr = '16' THEN  -->><<-- ubrr 06.10.2016 �������� �.�. 16-2222 ���������� �������� �����
      IF upper(p_Pack) not like '%�����%'
         AND NOT (l_cat = lc_ras_cat and l_num = lc_ras_num)-- 21.02.2018 ubrr korolkov 18-12.1
      THEN
        begin
          select cOBGName
          into p_pack
          from xxi.au_attach_obg au,
               obg
          where au.caccacc = p_Acc
            and au.cacccur = p_Cur
            and i_table = 304
            and d_create <= dDateR
            and c_type in ('I', 'U')
            and au.c_newdata like '112/1___'
            and nvl(au.c_olddata,'-') != au.c_newdata
            and obg.iobgcat = 112
            and obg.iobgnum = substr(au.c_newdata,5,4)
            and upper(obg.cobgname) like '%�����%'
            and not exists (select 1
                            from xxi.au_attach_obg au1
                            where au1.caccacc = au.caccacc
                              and au1.cacccur = au.cacccur
                              and i_table = 304
                              and au1.d_create <= dDateR
                              and au1.d_create > au.d_create
                              and au1.c_type in ('D', 'U')
                              and au1.c_olddata = au.c_newdata
                              and nvl(au1.c_newdata, '-') != au1.c_olddata)
            and rownum=1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END ;
      END IF;
      -->> 04.03.2020  ������� �.�. [20-71832]   ���: ��������� ������ "������" (���)
      if ( p_Pack like '����� ������ �%') then
           p_Pack := '����� ������';
      end if;
      --<< 04.03.2020  ������� �.�. [20-71832]   ���: ��������� ������ "������" (���)
    END IF;   -->><<-- ubrr 06.10.2016 �������� �.�. 16-2222 ���������� �������� �����
    IF vId = 0 THEN
      WriteProtocol('��� c���� '||p_Acc||' ��������� '||l_otd_tarif||' ��� �������� '||p_TypeCom||' �� ���������� ���� �������'); -- 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���
      RETURN NULL;
    END IF;

    SELECT NVL(MAX(1), 0)
    INTO IsIP
    FROM ubrr_acc_v -->><< UBRR 12.05.2017 ����������� �.�. (16-3100.2) ���: �������� �� �������� ��� ����� ���������
    WHERE cAccacc = p_Acc
    AND cAccCur = p_Cur
    AND cACCPRIZN != '�' -->><< UBRR 18.05.2017 ����������� �.�. (16-3100.2) ���: �������� �� �������� ��� ����� ���������
    AND EXISTS
          (SELECT 1
           FROM gcs
           WHERE igcscus = iAccCus
             AND igcscat = 15
             AND igcsnum = 4);

    SELECT case when IsIP = 0 THEN nvl(o.com_acc_ur, c.mask_ur)
                              ELSE nvl(o.com_acc_ip, c.mask_ip)
           end
    INTO vAccMask
    FROM ubrr_data.ubrr_rko_tarif c
    left join ubrr_data.ubrr_rko_tarif_otdsum o    -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
      on c.Id  = o.id_com
     and o.otd = p_Otd
    WHERE c.Id = vId
    AND ROWNUM = 1;

    IF vAccMask IS NOT NULL THEN
      IF SUBSTR(vAccMask,11,3)='XXX' THEN
        -->>23.10.2017  ����� �.�.       17-1225  https://redmine.lan.ubrr.ru/issues/47017#note-33
        if p_Otd in (9209, 9211, 9216, 9217, 9219)
          then vAccMask := SUBSTR(vAccMask,1,10)||substr(trim(to_char(p_Otd)),1,1)||substr(trim(to_char(p_Otd)),3,2)||SubSTR(vAccMask,14,7);
          else vAccMask := SUBSTR(vAccMask,1,10)||SUBSTR(trim(to_char(p_Otd)),LENGTH(trim(to_char(p_Otd)))-2, 3)||SubSTR(vAccMask,14,7);
        end if;
        --<< 23.10.2017  ����� �.�.       17-1225 https://redmine.lan.ubrr.ru/issues/47017#note-33
      END IF;
      BEGIN
        SELECT cAccAcc
        INTO vAccMask
        FROM acc
        WHERE caccacc LIKE vAccMask;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          WriteProtocol('��� c���� '||p_Acc||' ��������� '||p_Otd||' ��� �������� '||p_TypeCom||' �� ������ ���� ������� �� ����� '||vAccMask);
          vAccMask := NULL;
      END;
    ELSE
      WriteProtocol('��� c���� '||p_Acc||' ��������� '||p_Otd||' ��� �������� '||p_TypeCom||' �� ������ ���� �������');
    END IF;

    RETURN vAccMask;
  exception
    when others  then
      WriteProtocol('������ ����������� ����� ������� ��������� '||p_Otd_tarif||'|'||p_Otd||' ��� �������� '||p_TypeCom||' �� ������ ���� �������'||SQLErrm);  -- 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���
-->> 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
      WriteProtocol('error in '||$$plsql_unit||'.GetAccComiss ['||
                              'p_Acc='      ||p_Acc      ||';'||
                              'p_Cur='      ||p_Cur      ||';'||
                              'p_Otd_tarif='||p_Otd_tarif||';'|| -- 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���
                              'p_Otd='      ||p_Otd      ||';'||
                              'p_TypeCom='  ||p_TypeCom  ||';'||
                              ']'||sqlerrm);
--<< 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
      Return NULL;
  END GetAccComiss;

---------------------------------------------------------------
  FUNCTION CalcMoneyOrder_Vuz
   (p_Date in date, -- ���� �������
    p_ls in varchar2 default null, -- ���� ��� ������� ��������
    p_Mess out varchar2
  ) RETURN NUMBER IS
    lc_idsmr   constant smr.idsmr%type := sys_context('b21', 'idsmr'); -- 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
    d1       date := p_Date; -- ��������� ���� � ������ ���������
    acc_1    varchar2(25) := nvl(p_ls,'40___810%');
    d2       date := p_Date + 86399/86400; -- ���� ���������
    iCnt     number;
    iRes     number;
    l_step   varchar2(4):='000';  -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
  BEGIN
    DELETE FROM ubrr_data.ubrr_sbs_new
    WHERE IdSmr = SYS_CONTEXT('B21','IdSmr')
      and isbstrnnum is null
      and dSBSDate = p_Date
      and isbstypecom = 1
      and cSBSaccd like acc_1
      and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
      ;
    COMMIT;
    /*
     ������������� ������
    */
    l_step:='010'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    INSERT INTO ubrr_data.ubrr_sbs_new
     (cSBSaccd, cSBScurd, cSBSTypeCom, mSBSsumpays, iSBScountPays, mSBSsumcom, iSBSotdnum, iSBSBatNum, dSBSDate, iSBSTypeCom, dsbsdatereg)
      (select ctrnaccd , ctrncur,
              TypeCom, sum(case when sumcom=0 then 0 else mtrnsum end), sum(sign(sumcom)) , sum(sumcom), iaccotd, batnum, p_Date, 1, p_Date  -->><< ubrr 30.01.2017 �������� �.�.  [16-3223]   #39858  ���� ����� �������� �� ������� = 0, �� ��� �� ������� � ���������� � �����
       from (
       select itrnnum, itrnanum, ctrnaccd , ctrncur, mtrnsum, GetSumComiss(itrnnum,itrnanum,ctrnAccD, ctrncur, a.iaccotd, decode(nvl(iTRNsop,0), 4, 'PP6', 'PP9'), mtrnsum, 0) sumcom,
              decode(nvl(iTRNsop,0), 4, 'PP6', 'PP9') TypeCom
              , iaccotd, to_number(to_char(NVL(iOTDbatnum,70) )||'00') batnum
       from xxi.V_TRN_PART_CURRENT, acc a, otd o
       where ctrnaccd like acc_1
         and ctrncur = 'RUR'
         and dtrntran between d1 and d2
         and (   (    itrntype in (4,11,15,21,22,23)
                  and not (
                             -- itrnpriority in (3,4,5) and -- 01.09.2017 �������� �.�. [17-847] ���: ������������ �������� �������� �� ��������� ������� # 46295
                            substr(ctrnacca,1,3) in ('401', '402', '403', '404')
                           and exists (select 1
                                         from trn_dept_info
                                        where inum = itrnnum
                                          and ianum = itrnanum
                                          and ccreatstatus is not null))
                 )
            )
         and ctrnmfoa not in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr ) -- ���� ������� -> ����������
         and iTRNba2d not in (40813,40817,40818,40820,42309,40810,40811,40812,40823,40824)
         and cACCacc = cTRNaccd
         and cACCcur = cTRNcur
         and cACCprizn <> '�'
         and o.iotdnum = a.iaccotd
         and substr(caccacc,1,3) not in ('401','402','403','404','409')
         and not exists (select 1
                          from gac
                         where cgacacc = a.cACCacc
                           and igaccat = 112
                           and igacnum = 1014)  -- ��� �� �������
         and not exists (select 1
                          from gac
                         where cgacacc = a.cACCacc
                           and igaccat = 333
                           and igacnum = 2)
         and not exists (select 1
                          from gac
                         where cgacacc = a.cACCacc
                           and igaccat = 112
                           and igacnum = 10)
         and not exists (select 1
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
                                          and au.c_newdata like '131%'))
        -- >> 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
         and not exists( select 1
                           from gac
                          where cgacacc = ctrnaccd
                            and igaccat = 112
                            and igacnum in (6, 8, 67, 97, 1018)  --26.02.2020 �������� [20-71832] -- 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                            and exists( select 1
                                          from xxi.au_attach_obg au
                                         where au.caccacc = a.caccacc
                                           and au.cacccur = a.cacccur
                                           and au.i_table = 304
                                           and trunc(au.d_create) <= d2
                                           and (   au.c_newdata    = '112/6'
                                                or au.c_newdata    = '112/8'
                                                or au.c_newdata    = '112/67'
                                                or au.c_newdata    = '112/97' --26.02.2020 �������� [20-71832]
                                                or au.c_newdata    = '112/1018'
                                               )
                                      )
                   )
        -- << 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
        -->>21.06.2019 �������� [19-62974] ���. ���������� ��������: ��������������� ������� ����� ����� �� ���
        and not exists( select 1
                          from gac
                         where cgacacc = ctrnaccd
                           and decode(nvl(iTRNsop,0), 4, 'PP6', 'PP9') = 'PP6'
                           and igaccat = 112
                           and igacnum in (104, 105, 106)
                           and exists( select 1
                                         from xxi.au_attach_obg au
                                        where au.caccacc = a.caccacc
                                          and au.cacccur = a.cacccur
                                          and au.i_table = 304
                                          and trunc(au.d_create) <= d2
                                          and (   au.c_newdata    = '112/104'
                                               or au.c_newdata    = '112/105'
                                               or au.c_newdata    = '112/106')
                                     )
                      )
        --<<21.06.2019 �������� [19-62974] ���. ���������� ��������: ��������������� ������� ����� ����� �� ���
         -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
         and (    decode(nvl(iTRNsop,0), 4, 'PP6', 'PP9') = 'PP9'
               or not exists ( select 1
                                  from gac g
                                      ,ubrr_rko_exinc_catgr e
                                 where g.igaccat   = e.icat
                                   and g.igacnum   = e.igrp
                                   and e.ccom_type = 'PP6'
                                   and e.exinc     = 0
                                   and g.cgacacc   = a.caccacc
                                   and g.cgaccur   = a.cACCcur
                                   and exists (select 1
                                                 from xxi.au_attach_obg au
                                                where au.caccacc = a.caccacc
                                                  and au.cacccur = a.cacccur
                                                  and au.i_table = 304
                                                  and trunc(au.d_create) <= d2
                                                  and au.c_newdata = e.icat||'/'||e.igrp
                                                  and trunc(au.d_create) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end) --<<22.01.2020 �������� [19-64846]
                                              )
                              )
             )
         --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
         -->>03.07.2019 �������� [19-61974] ���: ���������� �������� �� �����������
         and check_exclude_client(itrntype, ctrnmfoa, dtrntran, itrnnumanc, ctrnacca, ctrnpurp, ctrnowna) = 0
         --<<03.07.2019 �������� [19-61974] ���: ���������� �������� �� �����������
         -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
         and not exists (select 1 from UBRR_UNIQUE_TARIF_ACC uutc
                                 where ctrnaccd = uutc.cacc
                                   and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF
                                   and SYS_CONTEXT ('B21', 'IDSmr') = uutc.idsmr
                                   and uutc.status = 'N')
         --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
         and not exists (select 1 from ubrr_data.ubrr_sbs_new where idsmr = a.idsmr and dSBSdate = p_date
                                                                and cSBSaccd = a.caccacc and cSBScurd = a.cacccur
                                                                and cSBSTypeCom = decode(nvl(iTRNsop,0), 4, 'PP6', 'PP9')
                                                                and iSBStrnnum is not null
                                                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                        )
         and exists (select 1 from ubrr_data.ubrr_rko_tarif v, ubrr_data.ubrr_rko_tarif_otdsum o
                     where v.Parent_IdSmr = BankIdSmr and v.com_type = decode(nvl(iTRNsop,0), 4, 'PP6', 'PP9')  -->><<-- ubrr 23.09.2016 �������� �.�. 16-2222 ���������� �������� ������
                       and v.id = o.id_com and o.otd = a.iaccotd)
       )group by ctrnaccd , ctrncur, TypeCom, iaccotd, batnum
       --having sum(sumcom)>0
      );
    l_step:='015'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := SQL%ROWCOUNT;
    WriteProtocol('��������� �������� �� ������������� ������� : '||iCnt);
    iRes:=iCnt;

    /*
     ������������� ������ ��� ������� ���������� ����� � ������ "������"
    */
    l_step:='020'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    -->> 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
    insert into ubrr_data.ubrr_sbs_new(cSBSaccd,
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
                                       MSBSTARIF  --04.03.2020  ������� �.�. [20-71832]   ���: ��������� ������ "������" (���)
                                      )
        (select ctrnaccd,
                ctrncur,
                TypeCom,
                sum(mtrnsum),
                count(1),
                sum(sumcom),
                iaccotd,
                batnum,
                p_Date,
                1,
                p_Date,
                -->> 04.03.2020  ������� �.�. [20-71832]   ���: ��������� ������ "������" (���)
                -- ���_�� ���������� � ������� ������� �������� - ������� ��������� ��������   (���� count(1) )
                count( case when TypeCom = 'PE6' and nvl(sumcom,0) = 0
                                             then null
                            else 1
                       end
                     ) MSBSTARIF
                --<< 04.03.2020  ������� �.�. [20-71832]   ���: ��������� ������ "������" (���)
         from (select ctrnaccd,
                      ctrncur,
                      mtrnsum,
                      GetSumComiss(itrnnum,
                                   itrnanum,
                                   ctrnaccd,
                                   ctrncur,
                                   iaccotd,
                                   TypeCom,
                                   mtrnsum,
                                   0)
                      sumcom,
                      TypeCom,
                      iaccotd,
                      batnum
               from (select itrnnum,
                            itrnanum,
                            ctrnaccd,
                            ctrncur,
                            mtrnsum,
                            case
                                when substr(to_char(itrnbatnum), -2) in ('01', '10', '13')
                                     and -- ������� ��������� � ���������� !
                                     -->> 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                                     ( ( trim( regexp_replace(upper(ctrnpurp), '[[:cntrl:]]') ) like '{VO_____}%!%'
                                         and trim(substr(trim( regexp_replace(ctrnpurp, '[[:cntrl:]]') ),10)) like '!%'
                                       )
                                       or trim( regexp_replace(ctrnpurp, '[[:cntrl:]]') ) like '!%'
                                     )
                                     --<< 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                                   then
                                    case when itrnsop = 4 then 'PES6' else 'PES9' end
                                else
                                    case when itrnsop = 4 then 'PE6' else 'PE9' end
                            end as TypeCom,
                            iaccotd,
                            to_number(to_char(nvl(iOTDbatnum, 70)) || '00') batnum
                     from xxi.v_trn_part_current t,
                          acc a,
                          otd o
                     where t.ctrnaccd like acc_1
                       and t.ctrncur    = 'RUR'
                       and t.dtrntran between d1 and d2
                       and a.caccacc    = t.ctrnaccd
                       and a.cacccur    = t.ctrncur
                       and a.caccprizn <> '�'
                       and a.iaccotd = o.iotdnum
                       and not (    substr(ctrnacca, 1, 3) in ('401', '402', '403', '404')
                                and exists( select 1
                                              from trn_dept_info
                                             where inum  = itrnnum
                                               and ianum = itrnanum
                                               and ccreatstatus is not null
                                          )
                               )
                       -->> ubrr 03.12.2016 �������� �.�. 16-2817 ��� �����������: ���������� �������� ��������
                       and not (     itrntype = 22
                                 and regexp_like(ctrnpurp, '^ *(|! *)0406')
                                 and exists( select 1
                                               from xxi."smr"
                                              where csmrmfo8 = ctrnmfoa
                                           )
                               )
                       --<< ubrr 03.12.2016 �������� �.�. 16-2817 ��� �����������: ���������� �������� ��������
                       and ctrnmfoa not in (select cfilmfo
                                              from xxi."fil"
                                             where idsmr = BankIdSmr)
                       and t.itrnba2d not in (40813, 40817, 40818, 40820, 42309, 40810, 40811, 40812, 40823, 40824)
                       and ( -- ������� ��������
                             (     itrntype in (4, 11, 15, 21, 22, 23)
                               and ( (substr(to_char(itrnbatnum), -2) in ('01', '10', '13') and nvl(substr(ctrnpurp, 1, 1), '(') <> '!')
                                     or
                                     substr(to_char(itrnbatnum), -2) not in ('01', '10', '13')
                                   )
                             )
                             or -- ������� ������
                             (     itrntype = 4
                               and substr(to_char(itrnbatnum), -2) in ('01', '10', '13')
                               and substr(ctrnpurp, 1, 1) = '!'
                             )
                           )
                       -->> 20.09.2017 ubrr korolkov 15-1436
                       and substr(case
                                      when iTrnType in (5, 50, 53, 52, 55, 17, 41, 42, 43, 44) then nvl(cTrnClient_Acc, cTrnAccC)
                                      when cTrnMfoA is null then nvl(cTrnAccA, cTrnAccC)
                                      else cTrnAccA
                                  end,
                                  1,
                                  5) not in ('60309', '60322')
                       --<< 20.09.2017 ubrr korolkov 15-1436
                       and not exists (select 1
                                         from gac
                                        where cgacacc = a.cACCacc
                                          and igaccat = 112
                                          and igacnum = 1014)  -- ��� �� �������
                       and not exists( select 1
                                         from gac
                                        where cgacacc = a.cACCacc
                                          and cgaccur = a.cACCcur
                                          and igaccat = 333
                                          and igacnum = 2
                                     )
                       and not exists (select 1
                                         from gac
                                        where cgacacc = a.cACCacc
                                          and igaccat = 112
                                          and igacnum = 10 )
                       -->>11.06.2019 �������� [19-62974] ���. ���������� ��������: ��������������� ������� ����� ����� �� ���
                       and not exists (select 1
                                         from gac
                                        where cgacacc = a.cACCacc
                                          and igaccat = 112
                                          and igacnum = 45)
                       --<<11.06.2019 �������� [19-62974] ���. ���������� ��������: ��������������� ������� ����� ����� �� ���
                       -->>13.06.2019 �������� [19-62974] ���. ���������� ��������: ��������������� ������� ����� ����� �� ���
                       and not exists(select 1
                                        from gac
                                       where cgacacc = ctrnaccd
                                         and igaccat = 112
                                         and igacnum in (100, 101, 102)
                                         and exists( select 1
                                                       from xxi.au_attach_obg au
                                                      where au.caccacc = a.caccacc
                                                        and au.cacccur = a.cacccur
                                                        and au.i_table = 304
                                                        and trunc(au.d_create) <= d2
                                                        and (   au.c_newdata    = '112/100'
                                                             or au.c_newdata    = '112/101'
                                                             or au.c_newdata    = '112/102')
                                                   )
                                     )
                       --<<13.06.2019 �������� [19-62974] ���. ���������� ��������: ��������������� ������� ����� ����� �� ���
                       -->>14.06.2019 �������� [19-62974] ���. ���������� ��������: ��������������� ������� ����� ����� �� ���
                       and not exists( select 1
                                         from gac
                                        where cgacacc = ctrnaccd
                                          and igaccat = 112
                                          and igacnum in (104, 105, 106)
                                          and exists( select 1
                                                        from xxi.au_attach_obg au
                                                       where au.caccacc = a.caccacc
                                                         and au.cacccur = a.cacccur
                                                         and au.i_table = 304
                                                         and trunc(au.d_create) <= d2
                                                         and (   au.c_newdata    = '112/104'
                                                              or au.c_newdata    = '112/105'
                                                              or au.c_newdata    = '112/106')
                                                    )
                                     )
                       --<<14.06.2019 �������� [19-62974] ���. ���������� ��������: ��������������� ������� ����� ����� �� ���
                       and check_exclude_client(t.itrntype, t.ctrnmfoa, t.dtrntran, t.itrnnumanc, t.ctrnacca, t.ctrnpurp, t.ctrnowna) = 0 -->><<--03.07.2019 �������� [19-61974] ���: ���������� �������� �� �����������
                       and not exists (select 1
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
                                                         and au.c_newdata like '131%')
                                      )
                       -- >> 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                       and exists( select 1
                                     from gac
                                    where cgacacc = ctrnaccd
                                      and igaccat = 112
                                      and igacnum in (6, 8, 67, 97, 1018)  --26.02.2020 �������� [20-71832] -- 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                                      and exists( select 1
                                                    from xxi.au_attach_obg au
                                                   where au.caccacc = a.caccacc
                                                     and au.cacccur = a.cacccur
                                                     and au.i_table = 304
                                                     and trunc(au.d_create) <= d2
                                                     and (   au.c_newdata    = '112/6'
                                                          or au.c_newdata    = '112/8'
                                                          or au.c_newdata    = '112/67'
                                                          or au.c_newdata    = '112/97' --26.02.2020 �������� [20-71832]
                                                          or au.c_newdata    = '112/1018'
                                                         )
                                                )
                                 )
                       -- << 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                       -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                       and not exists(select 1
                                        from UBRR_UNIQUE_TARIF_ACC uutc
                                       where uutc.cacc = t.ctrnaccd
                                         and t.dtrncreate between uutc.dopentarif and uutc.dcanceltarif
                                         and uutc.idsmr = lc_idsmr
                                         and uutc.status = 'N')
                       --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                    ) t1
               where not exists
                             (select 1
                                from ubrr_data.ubrr_sbs_new
                               where idsmr       = lc_idsmr
                                 and dSBSdate    = p_date
                                 and cSBSaccd    = t1.ctrnaccd
                                 and cSBScurd    = t1.ctrncur
                                 and cSBSTypeCom = t1.TypeCom
                                 and iSBStrnnum is not null
                                 and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                             )
                 and exists
                         (select 1
                            from ubrr_data.ubrr_rko_tarif v,
                                 ubrr_data.ubrr_rko_tarif_otdsum o
                           where v.Parent_IdSmr = BankIdSmr
                             and v.com_type     = t1.TypeCom
                             and v.id           = o.id_com
                             and o.otd          = t1.iaccotd
                         )
              )
         group by ctrnaccd, ctrncur, TypeCom, iaccotd, batnum);
    l_step:='025'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := sql%rowcount;
    WriteProtocol('��������� �������� �� ������������� ������� ��� ������� ���������� ����� � ������ "������": ' || iCnt);
    iRes := iRes + iCnt;
    --<<  07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"

    /*
     ������������� ������ -- ������� �������
    */
    l_step:='030'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    INSERT INTO ubrr_data.ubrr_sbs_new
     (cSBSaccd, cSBScurd, cSBSTypeCom, mSBSsumpays, iSBScountPays, mSBSsumcom, iSBSotdnum, iSBSBatNum, dSBSDate, iSBSTypeCom, dsbsdatereg)
      (select ctrnaccd , ctrncur,
              TypeCom, sum(case when sumcom=0 then 0 else mtrnsum end), sum(sign(sumcom)) , sum(sumcom), iaccotd, batnum, p_Date, 1, p_Date  -->><< ubrr 30.01.2017 �������� �.�.  [16-3223]   #39858  ���� ����� �������� �� ������� = 0, �� ��� �� ������� � ���������� � �����
       from (
       select itrnnum, itrnanum, ctrnaccd , ctrncur, mtrnsum, ubrr_xxi5.UBRR_UNIQ_ACC_SUM(ctrnaccd,ctrncur,iaccotd,dtrntran,decode(nvl(iTRNsop,0), 4, 'PP6', 'PP9'),mtrnsum,0) sumcom, -- 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
              decode(nvl(iTRNsop,0), 4, 'PP6', 'PP9') TypeCom
              , iaccotd, to_number(to_char(NVL(iOTDbatnum,70) )||'00') batnum
       from xxi.V_TRN_PART_CURRENT, acc a, otd o
       where ctrnaccd like acc_1
         and ctrncur = 'RUR'
         and dtrntran between d1 and d2
         and (   (    itrntype in (4,11,15,21,22,23)
                  and not (
                             --  itrnpriority in (3,4,5) and -- 01.09.2017 �������� �.�. [17-847] ���: ������������ �������� �������� �� ��������� ������� # 46295
                            substr(ctrnacca,1,3) in ('401', '402', '403', '404')
                           and exists (select 1
                                       from trn_dept_info
                                       where inum = itrnnum
                                         and ianum = itrnanum
                                         and ccreatstatus is not null))
                 )
            )
         and not exists (select 1
                          from gac
                         where cgacacc = a.cACCacc
                           and igaccat = 112
                           and igacnum = 1014)  -- ��� �� �������
         and not exists (select 1
                          from gac
                         where cgacacc = a.cACCacc
                           and igaccat = 333
                           and igacnum = 2)
         and not exists (select 1
                          from gac
                         where cgacacc = a.cACCacc
                           and igaccat = 112
                           and igacnum = 10)
         -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
         and (    decode(nvl(iTRNsop,0), 4, 'PP6', 'PP9') = 'PP9'
               or not exists ( select 1
                                  from gac g
                                      ,ubrr_rko_exinc_catgr e
                                 where g.igaccat   = e.icat
                                   and g.igacnum   = e.igrp
                                   and e.ccom_type = 'PP6'
                                   and e.exinc     = 0
                                   and g.cgacacc   = a.caccacc
                                   and g.cgaccur   = a.cACCcur
                                   and exists (select 1
                                                 from xxi.au_attach_obg au
                                                where au.caccacc = a.caccacc
                                                  and au.cacccur = a.cacccur
                                                  and au.i_table = 304
                                                  and trunc(au.d_create) <= d2
                                                  and au.c_newdata = e.icat||'/'||e.igrp
                                                  and trunc(au.d_create) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end) --<<22.01.2020 �������� [19-64846]
                                              )
                              )
             )
         --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
         and ctrnmfoa not in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr ) -- ���� ������� -> ����������
         and iTRNba2d not in (40813,40817,40818,40820,42309,40810,40811,40812,40823,40824)
         and cACCacc = cTRNaccd
         and cACCcur = cTRNcur
         and cACCprizn <> '�'
         and o.iotdnum = a.iaccotd
         and substr(caccacc,1,3) not in ('401','402','403','404','409')
         -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
         and exists (select 1 from UBRR_UNIQUE_TARIF_ACC uutc,
                                   UBRR_UNIQUE_ACC_COMMS uuac
                             where ctrnaccd = uutc.cacc
                               and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF
                               and SYS_CONTEXT ('B21', 'IDSmr') = uutc.idsmr
                               and uutc.status = 'N'
                               and uutc.uuta_id = uuac.uuta_id
                               and uuac.com_type = 'PP9' )
         --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
         and not exists (select 1 from ubrr_data.ubrr_sbs_new where idsmr = a.idsmr and dSBSdate = p_date
                                                                and cSBSaccd = a.caccacc and cSBScurd = a.cacccur
                                                                and cSBSTypeCom = decode(nvl(iTRNsop,0), 4, 'PP6', 'PP9')
                                                                and iSBStrnnum is not null
                                                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                        )
       )group by ctrnaccd , ctrncur, TypeCom, iaccotd, batnum
       --having sum(sumcom)>0
      );
    l_step:='035'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
     iCnt := SQL%ROWCOUNT;
     WriteProtocol('��������� �������� �� ������������� ������� �� ������� ��������: '||iCnt);
     iRes:=iRes+iCnt;
    /*
     ���������������� ������
    */
    l_step:='040'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    INSERT INTO ubrr_data.ubrr_sbs_new
     (cSBSaccd, cSBScurd, cSBSTypeCom, mSBSsumpays, iSBScountPays, mSBSsumcom, iSBSotdnum, iSBSBatNum, dSBSDate, iSBSTypeCom, dsbsdatereg)
      (select ctrnaccd , ctrncur,
              TypeCom, sum(case when sumcom=0 then 0 else mtrnsum end), sum(sign(sumcom)) , sum(sumcom), iaccotd, batnum, p_Date, 1, p_Date  -->><< ubrr 30.01.2017 �������� �.�.  [16-3223]   #39858  ���� ����� �������� �� ������� = 0, �� ��� �� ������� � ���������� � �����
       from (
       select itrnnum, itrnanum, ctrnaccd , ctrncur, mtrnsum, GetSumComiss(itrnnum,itrnanum,ctrnAccD, ctrncur, a.iaccotd, decode(nvl(iTRNsop,0), 4, 'PP3E', 'PP3'), mtrnsum, 0) sumcom,
              decode(nvl(iTRNsop,0), 4, 'PP3E', 'PP3') TypeCom
              , iaccotd, to_number(to_char(NVL(iOTDbatnum,70) )||'00') batnum
       from xxi.V_TRN_PART_CURRENT, acc a, otd o
       where ctrnaccd like acc_1 and ctrncur = 'RUR'
         and dtrntran between d1 and d2
         and (   (    (   (    itrntype in ( 2,3,14)
                           and itrnpriority not in (3,4))
                           or (    itrntype in (25,28) and nvl(iTRNsop,0) not in (5,7)
                               and itrnpriority not in (3,4)))
                  and (   substr(itrnba2c,1,3) in (303,405,406,407,423,426)
                       or itrnba2c in (40802,40807,40817,40818,40820)))
               or (    itrntype in (4,11,15,21,23)
                   and not (
                                --itrnpriority in (3,4,5) and -- 01.09.2017 �������� �.�. [17-847] ���: ������������ �������� �������� �� ��������� ������� # 46295
                             substr(ctrnacca,1,3) in ('401', '402', '403', '404')
                            and exists (select 1
                                        from trn_dept_info
                                        where inum = itrnnum
                                          and ianum = itrnanum
                                          and ccreatstatus is not null))
                   and ctrnmfoa in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr)))
         and nvl(iTRNsop,0) <> 4 -- �� ����������� ���������� = 0 ������� ���� �������� ������ ��������, ��� �������
         and iTRNba2d not in (40813,40817,40818,40820,42309,40810,40811,40812,40823,40824)
         and cACCacc = cTRNaccd
         and cACCcur = cTRNcur
         and cACCprizn <> '�'
         and o.iotdnum = a.iaccotd
         and not exists (select 1
                          from gac
                         where cgacacc = a.cACCacc
                           and igaccat = 112
                           and igacnum = 1014)  -- ��� �� �������
         and not exists (select 1
                         from gac
                         where cgacacc = a.cACCacc
                           and cgaccur = a.cACCcur
                          and igaccat = 333
                          and igacnum = 2)
         and not exists (select 1
                          from gac
                         where cgacacc = a.cACCacc
                           and igaccat = 112
                           and igacnum = 10)
         and not exists (select 1
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
                                         and au.c_newdata like '131%'))
         and substr(caccacc,1,3) not in ('401','402','403','404','409')
         -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
         and not exists (select 1 from UBRR_UNIQUE_TARIF_ACC uutc
                                 where ctrnaccd = uutc.cacc
                                   and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF
                                   and SYS_CONTEXT ('B21', 'IDSmr') = uutc.idsmr
                                   and uutc.status = 'N')
         --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
         and not exists (select 1 from ubrr_data.ubrr_sbs_new where idsmr = a.idsmr and dSBSdate = p_date
                                                                and cSBSaccd = a.caccacc and cSBScurd = a.cacccur
                                                                and cSBSTypeCom = decode(nvl(iTRNsop,0), 4, 'PP3E', 'PP3')
                                                                and iSBStrnnum is not null
                                                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                        )
         and exists (select 1 from ubrr_data.ubrr_rko_tarif v, ubrr_data.ubrr_rko_tarif_otdsum o
                     where v.Parent_IdSmr = BankIdSmr and v.com_type = decode(nvl(iTRNsop,0), 4, 'PP3E', 'PP3')  -->><<-- ubrr 23.09.2016 �������� �.�. 16-2222 ���������� �������� ������
                       and v.id = o.id_com and o.otd = a.iaccotd)
       )group by ctrnaccd , ctrncur, TypeCom, iaccotd, batnum
       --having sum(sumcom)>0
     );
    l_step:='045'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
     iCnt := SQL%ROWCOUNT;
     WriteProtocol('��������� �������� �� ���������������� ������� : '||iCnt);
     iRes:=iRes+iCnt;


     /*
      ����������
      ������� �������*/
    l_step:='045'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
     INSERT INTO ubrr_data.ubrr_sbs_new
     (cSBSaccd, cSBScurd, cSBSTypeCom, mSBSsumpays, iSBScountPays, mSBSsumcom, iSBSotdnum, iSBSBatNum, dSBSDate, iSBSTypeCom, dsbsdatereg)
      (select ctrnaccd , ctrncur,
              TypeCom, sum(case when sumcom=0 then 0 else mtrnsum end), sum(sign(sumcom)) , sum(sumcom), iaccotd, batnum, p_Date, 1, p_Date  -->><< ubrr 30.01.2017 �������� �.�.  [16-3223]   #39858  ���� ����� �������� �� ������� = 0, �� ��� �� ������� � ���������� � �����
       from (
       select itrnnum, itrnanum, ctrnaccd , ctrncur, mtrnsum, ubrr_xxi5.UBRR_UNIQ_ACC_SUM(ctrnaccd,ctrncur,iaccotd,dtrntran,decode(nvl(iTRNsop,0), 4, 'PP3E', 'PP3'),mtrnsum,0) sumcom,  -- 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
              decode(nvl(iTRNsop,0), 4, 'PP3E', 'PP3') TypeCom
              , iaccotd, to_number(to_char(NVL(iOTDbatnum,70) )||'00') batnum
       from xxi.V_TRN_PART_CURRENT, acc a, otd o
       where     ctrnaccd  like acc_1  and ctrncur = 'RUR'
        and dtrntran between d1 and d2
        and (   (    (   (    itrntype in ( 2,3,14)
                           and itrnpriority not in (3,4))
                           or (    itrntype in (25,28) and nvl(iTRNsop,0) not in (5,7)
                               and itrnpriority not in (3,4)))
                  and (   substr(itrnba2c,1,3) in (303,405,406,407,423,426)
                       or itrnba2c in (40802,40807,40817,40818,40820)))
               or (    itrntype in (4,11,15,21,23)
                   and not (
                               -- itrnpriority in (3,4,5) and -- 01.09.2017 �������� �.�. [17-847] ���: ������������ �������� �������� �� ��������� ������� # 46295
                             substr(ctrnacca,1,3) in ('401', '402', '403', '404')
                            and exists (select 1
                                        from trn_dept_info
                                        where inum = itrnnum
                                          and ianum = itrnanum
                                          and ccreatstatus is not null))
                   and ctrnmfoa in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr)))
         and not (nvl(iTRNsop,0)=4 and itrntype=25)
         and (ctrnaccc like '40702%' or ctrnaccc like '40802%')
         and iTRNba2d not in (40813,40817,40818,40820)
         and cACCacc = cTRNaccd
         and cACCcur = cTRNcur
         and cACCprizn <> '�'
         and o.iotdnum = a.iaccotd
         and not exists (select 1
                          from gac
                         where cgacacc = a.cACCacc
                           and igaccat = 112
                           and igacnum = 1014)  -- ��� �� �������
         and not exists (select 1
                         from gac
                        where cgacacc = ctrnaccC
                          and cgaccur = a.cacccur
                          and igaccat = 333
                          and igacnum = 2)
         and not exists (select 1
                          from gac
                         where cgacacc = a.cACCacc
                           and igaccat = 112
                           and igacnum = 10)
         and substr(caccacc,1,3) not in ('401','402','403','404','409')
         -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
         and exists (select 1 from UBRR_UNIQUE_TARIF_ACC uutc,
                                   UBRR_UNIQUE_ACC_COMMS uuac
                             where ctrnaccd = uutc.cacc
                               and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF
                               and SYS_CONTEXT ('B21', 'IDSmr') = uutc.idsmr
                               and uutc.status = 'N'
                               and uutc.uuta_id = uuac.uuta_id
                               and uuac.com_type = 'PP3E')
         --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
         and not exists (select 1 from ubrr_data.ubrr_sbs_new where idsmr = a.idsmr and dSBSdate = p_date
                                                                and cSBSaccd = a.caccacc and cSBScurd = a.cacccur
                                                                and cSBSTypeCom = decode(nvl(iTRNsop,0), 4, 'PP3E', 'PP3')
                                                                and iSBStrnnum is not null
                                                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                        )
       )group by ctrnaccd , ctrncur, TypeCom, iaccotd, batnum
       --having sum(sumcom)>0
     );
    l_step:='055'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := SQL%ROWCOUNT;
    WriteProtocol('��������� �������� �� ���������������� ������� �� ������� ��������: '||iCnt);
    iRes:=iRes+iCnt;

-- >> ubrr 06.03.2019 ������� �.�. [18-58177.2] ���. ����������� (������ �������� ��������)
    -- �������� ���� �� 100 ���
    iCnt:=insert_besp_commis( p_Date => p_date
                             ,p_ls   => p_ls
                             ,p_Mess => p_mess );
    iRes := iRes + iCnt;
-- << ubrr 06.03.2019 ������� �.�. [18-58177.2] ���. ����������� (������ �������� ��������)

    COMMIT;  -- ubrr 06.03.2019 ������� �.�. [18-58177.2] ���. ����������� (������ �������� ��������)

    RETURN iRes;
  exception
    WHEN OTHERS THEN
      ROLLBACK;
      WriteProtocol('������ ��� ������� �������� �� ��������: (l_step='||l_step||')'||SQLErrm);
      p_Mess := '������ ��� ������� �������� �� ��������: '||SQLErrm;
      RETURN -1;
  END CalcMoneyOrder_Vuz;   -- ubrr 06.03.2019 ������� �.�. [18-58177.2] ���. ����������� (������ �������� ��������)

-->> 07.11.2017 ubrr korolkov 17-1071
function CalcMoneyOrder_Ubrr(p_Date in date, p_ls in varchar2 default null, p_Mess out varchar2)
    return number
is
    lc_idsmr   constant smr.idsmr%type := sys_context('b21', 'idsmr'); -- 07.11.2017 ubrr korolkov 17-1071
    d1                  date := p_Date; -- ��������� ���� � ������ ���������
    acc_1               varchar2(25) := nvl(p_ls, '40___810%');
    d2                  date := p_Date + 86399 / 86400; -- ���� ���������
    iCnt                number;
    iRes                number;

    l_step              varchar2(4):='000';  -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
begin
    delete from ubrr_data.ubrr_sbs_new
     where IdSmr = lc_idsmr and isbstrnnum is null
       and dSBSDate = p_Date
       and isbstypecom = 1
       and cSBSaccd like acc_1
       and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
    ;

    commit;

    /*
     ������������� ������
    */
    l_step:='010'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    insert into ubrr_data.ubrr_sbs_new(cSBSaccd,
                                       cSBScurd,
                                       cSBSTypeCom,
                                       mSBSsumpays,
                                       iSBScountPays,
                                       mSBSsumcom,
                                       iSBSotdnum,
                                       iSBSBatNum,
                                       dSBSDate,
                                       iSBSTypeCom,
                                       dsbsdatereg)
        (select ctrnaccd,
                ctrncur,
                TypeCom,
                sum(case when sumcom = 0 then 0 else mtrnsum end),
                sum(sign(sumcom)),
                --sum(mtrnsum),
                --count(1),
                sum(sumcom),
                iaccotd,
                batnum,
                p_Date,
                1,
                p_Date
         from (select itrnnum,
                      itrnanum,
                      ctrnaccd,
                      ctrncur,
                      mtrnsum,
                      GetSumComiss(itrnnum,
                                   itrnanum,
                                   ctrnAccD,
                                   ctrncur,
                                   a.iaccotd,
                                   decode(nvl(iTRNsop, 0), 4, 'PP6', 'PP9'),
                                   mtrnsum,
                                   0)
                          sumcom,
                      decode(nvl(iTRNsop, 0), 4, 'PP6', 'PP9') TypeCom,
                      iaccotd,
                      to_number(to_char(nvl(iOTDbatnum, 70)) || '00') batnum
               from /*xxi.v_trn_part_current*/ ubrr_trn_old_new_v t, -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                    acc a,
                    otd o
               where a.caccacc = t.ctrnaccd
                 and a.cacccur = t.ctrncur
                 and o.iotdnum = a.iaccotd
                 and t.ctrnaccd like acc_1
                 and t.ctrncur = 'RUR'
                 and t.dtrntran between d1 and d2
                 and ((itrntype in (4, 11, 15, 21, 22, 23)
                   and not (substr(ctrnacca, 1, 3) in ('401', '402', '403', '404')
                        and exists
                                (select 1
                                 from trn_dept_info
                                 where inum = itrnnum and ianum = itrnanum and ccreatstatus is not null))))
                 and not (itrntype = 22
                      and regexp_like(ctrnpurp, '^ *(|! *)0406')
                      and exists
                              (select 1
                               from xxi."smr"
                               where csmrmfo8 = ctrnmfoa))
                 and ctrnmfoa not in (select cfilmfo
                                      from xxi."fil"
                                      where idsmr = BankIdSmr)
                 and itrnba2d not in (40813, 40817, 40818, 40820, 42309, 40810, 40811, 40812, 40823, 40824)
                 and a.caccprizn <> '�'
                 and substr(a.caccacc, 1, 3) not in ('401', '402', '403', '404', '409')
                 and substr(to_char(t.itrnbatnum), 3) not in ('10', '13')
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.caccacc
                                and cgaccur = a.cacccur
                                and igaccat = 333
                                and igacnum = 2)
                 -->> 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = ctrnaccd and igaccat = 112 and igacnum=97
                            and exists
                                    (select 1
                                     from xxi.au_attach_obg au
                                     where au.caccacc = a.caccacc
                                       and au.cacccur = a.cacccur
                                       and au.i_table = 304
                                       and trunc(d_create) <= d2
                                       and (c_newdata = '112/97' or c_newdata = '112/97')))
                 --<< 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.caccacc and cgaccur = a.cacccur and igaccat = 131
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.caccacc
                                           and au.cacccur = a.cacccur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata like '131%'))
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = cACCacc and cgaccur = cACCcur and igaccat = 112 and igacnum in (6, 8, 67, 1018) -- 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg
                                         where cgacacc = caccacc
                                           and cgaccur = cacccur
                                           and trunc(d_create) <= d2
                                           and (c_newdata = '112/6' or c_newdata = '112/8' or c_newdata = '112/67' or c_newdata = '112/1018')))  -- 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc
                                and cgaccur = a.cACCcur
                                and igaccat = 112
                                and igacnum in (73, 74)
                                and exists
                                        (select 1
                                         from gac
                                         where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 333 and igacnum = 4)
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '112/' || gac.igacnum)
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '333/4'))
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = cACCacc
                                and cgaccur = cACCcur
                                and igaccat = 112
                                and ( igacnum in (1, 3, 4, 5, 7, 10, 13, 15, 16, 17, 19, 20, 21, 22, 23, 36, 37, 39, 57)
                                      or (nvl(iTRNsop, 0) != 4 and igacnum in (9, 25, 31 /*, 45*/ ))      -- PP9 -->><<--16.10.2018 �������� [18-56489] ���: ������� �� ������ �� �� "��������"
                                      or (nvl(iTRNsop, 0)  = 4 and igacnum in (24, 31, 40, 50)) ))  -- PP6
                 -->> ���������� ���/�� ��� PP6
                 and ( nvl(iTRNsop, 0) != 4
                       or
                       ( nvl(iTRNsop, 0) = 4
                         -->>07.06.2019 �������� [19-59153] https://redmine.lan.ubrr.ru/issues/62797#note-9
                         and not exists
                                     (select 1
                                      from gac
                                      where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 112
                                        and igacnum in ( -- ����� �� 78,79,80,100,101,102  ����� ������������ � ���� calc_field  ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                                         94
                                        ,99,103 --27.12.2018 �������� [15-43]  ���: ����� ����� ����� � ��������� ������� �� ����� ��������
                                        ,104, 105, 106 -- ������  �������  3, 6, 12  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                                      )
                                        and exists
                                                (select 1
                                                 from xxi.au_attach_obg au
                                                 where au.caccacc = a.cACCacc
                                                   and au.cacccur = a.cACCcur
                                                   and i_table = 304
                                                   and trunc(d_create) <= d2
                                                   and au.c_newdata like '112/' || to_char(gac.igacnum)))
                         --<<07.06.2019 �������� [19-59153] https://redmine.lan.ubrr.ru/issues/62797#note-9
                         and not exists
                                      (select 1
                                       from gac
                                       where cgacacc = cACCacc and cgaccur = cACCcur and igaccat = 112 and igacnum = 70
                                         and exists
                                                 (select 1
                                                  from xxi.au_attach_obg au
                                                  where au.caccacc = gac.CGACACC
                                                    and au.cacccur = gac.CGACCUR
                                                    and i_table = 304
                                                    and d_create <= d2
                                                    and au.c_newdata like '112/70'))
                          and not exists
                                      (select 1
                                       from au_attach_obg a1
                                       where caccacc = a.CACCACC
                                         and cacccur = a.CACCCUR
                                         and c_newdata = '112/72'
                                         and d1 between trunc(d_create, 'mm') and last_day(add_months(d_create, 5))
                                         and exists
                                                 (select 1
                                                  from gac
                                                  where cgacacc = a1.caccacc and gac.CGACCUR = a1.cacccur and igaccat = 112 and igacnum = 72
                                                  union
                                                  select 1
                                                  from au_attach_obg a2
                                                  where a2.caccacc = a1.caccacc
                                                    and a2.cacccur = a1.cacccur
                                                    and a2.i_table = 304
                                                    and a2.c_olddata = '112/72'
                                                    and a2.d_create > last_day(add_months(a1.d_create, 5))))
                          and not exists
                                      (select 1
                                       from au_attach_obg a1
                                       where caccacc = a.CACCACC
                                         and cacccur = a.CACCCUR
                                         and c_newdata = '112/35'
                                         and d1 between trunc(d_create, 'mm') and last_day(add_months(d_create, 2))
                                         and exists
                                                 (select 1
                                                  from gac
                                                  where cgacacc = a1.caccacc and gac.CGACCUR = a1.cacccur and igaccat = 112 and igacnum = 35
                                                  union
                                                  select 1
                                                  from au_attach_obg a2
                                                  where a2.caccacc = a1.caccacc
                                                    and a2.cacccur = a1.cacccur
                                                    and a2.i_table = 304
                                                    and a2.c_olddata = '112/35'
                                                    and a2.d_create > last_day(add_months(a1.d_create, 2))))
                          and not exists
                                      (select 1
                                       from au_attach_obg a1
                                       where caccacc = a.CACCACC
                                         and cacccur = a.CACCCUR
                                         and c_newdata = '112/93'
                                         and d1 between trunc(d_create, 'mm') and last_day(add_months(d_create, 2))
                                         and exists
                                                 (select 1
                                                  from gac
                                                  where cgacacc = a1.caccacc and gac.CGACCUR = a1.cacccur and igaccat = 112 and igacnum = 93
                                                  union
                                                  select 1
                                                  from au_attach_obg a2
                                                  where a2.caccacc = a1.caccacc
                                                    and a2.cacccur = a1.cacccur
                                                    and a2.i_table = 304
                                                    and a2.c_olddata = '112/93'
                                                    and a2.d_create > last_day(add_months(a1.d_create, 2))))
                          and not exists
                                      (select 1
                                       from gac
                                       where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 112 and igacnum = 40
                                         and exists
                                                 (select 1
                                                  from xxi.au_attach_obg au
                                                  where au.caccacc = a.cACCacc
                                                    and au.cacccur = a.cACCcur
                                                    and au.i_table = 304
                                                    and au.d_create <= d2
                                                    and add_months(last_day(au.d_create), 11) > d1
                                                    and au.c_newdata = '112/40'))
                          and not exists
                                      (select 1
                                       from     xxi.au_attach_obg au_s
                                            inner join
                                                xxi.au_attach_obg au_e
                                            on au_e.caccacc = au_s.caccacc
                                           and au_e.cacccur = au_s.cacccur
                                           and au_e.i_table = 304
                                           and au_e.C_OLDDATA = '112/40'
                                       where au_s.caccacc = a.cACCacc
                                         and au_s.cacccur = a.cACCcur
                                         and au_s.i_table = 304
                                         and au_s.d_create <= d2
                                         and au_e.d_create >= d1
                                         and add_months(last_day(au_s.d_create), 11) > d1
                                         and au_s.c_newdata = '112/40')
                          and not exists
                                      (select 1
                                       from xxi.au_attach_obg au
                                       where au.caccacc = a.cACCacc
                                         and au.cacccur = a.cACCcur
                                         and add_months(last_day(d_create), 5) > d1
                                         and i_table = 304
                                         and au.c_newdata = '112/50')
                          and not exists
                                      (select 1
                                       from xxi.au_attach_obg au
                                       where au.caccacc = a.cACCacc
                                         and au.cacccur = a.cACCcur
                                         and d_create > d1
                                         and d_create < d2
                                         and i_table = 304
                                         and au.c_newdata in ('112/36', '112/37', '112/38', '112/40'))
                          and (not exists
                                       (select 1
                                        from xxi.AU_ATTACH_OBG au
                                        where au.caccacc = a.cACCacc
                                          and au.cacccur = a.cACCcur
                                          and d_create <= d2
                                          and i_table = 304
                                          and au.c_newdata = '112/31')) )
                 )
                 --<< PP6
                 -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                 and (    decode(nvl(iTRNsop,0), 4, 'PP6', 'PP9') = 'PP9'
                       or not exists ( select 1
                                          from gac g
                                              ,ubrr_rko_exinc_catgr e
                                         where g.igaccat   = e.icat
                                           and g.igacnum   = e.igrp
                                           and e.ccom_type = 'PP6'
                                           and e.exinc     = 0
                                           and g.cgacacc   = a.caccacc
                                           and g.cgaccur   = a.cACCcur
                                           and exists (select 1
                                                         from xxi.au_attach_obg au
                                                        where au.caccacc = a.caccacc
                                                          and au.cacccur = a.cacccur
                                                          and au.i_table = 304
                                                          and trunc(au.d_create) <= d2
                                                          and au.c_newdata = e.icat||'/'||e.igrp
                                                          and trunc(au.d_create) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end) --<<22.01.2020 �������� [19-64846]
                                                      )
                                      )
                     )
                 --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                 and check_exclude_client(t.itrntype, t.ctrnmfoa, t.dtrntran, t.itrnnumanc, t.ctrnacca, t.ctrnpurp, t.ctrnowna) = 0 -->><<--03.07.2019 �������� [19-61974] ���: ���������� �������� �� �����������
                 -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                         (select 1
                            from UBRR_UNIQUE_TARIF_ACC uutc,
                                 UBRR_UNIQUE_ACC_COMMS uuac
                           where uutc.cacc = t.ctrnaccd
                             and t.dtrncreate between uutc.dopentarif and uutc.dcanceltarif
                             and uutc.idsmr = lc_idsmr
                             and uutc.status = 'N'
                             and uutc.uuta_id = uuac.uuta_id
                             and uuac.com_type in ('PP6','PP9'))
                 --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                             (select 1
                              from ubrr_data.ubrr_sbs_new
                              where idsmr = a.idsmr
                                and dSBSdate = p_date
                                and cSBSaccd = a.caccacc
                                and cSBScurd = a.cacccur
                                and cSBSTypeCom = decode(nvl(iTRNsop, 0), 4, 'PP6', 'PP9')
                                and iSBStrnnum is not null
                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                             )
                 and exists
                         (select 1
                          from ubrr_data.ubrr_rko_tarif v,
                               ubrr_data.ubrr_rko_tarif_otdsum o
                          where v.Parent_IdSmr = BankIdSmr
                            and v.com_type = decode(nvl(iTRNsop, 0), 4, 'PP6', 'PP9')
                            and v.id = o.id_com
                            and o.otd = a.iaccotd))
         group by ctrnaccd, ctrncur, TypeCom, iaccotd, batnum);

    l_step:='015'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := sql%rowcount;
    WriteProtocol('��������� �������� �� ������������� ������� : ' || iCnt);
    iRes := iCnt;


    /*
     ������������� ������ ��� [PP6_NTK]
    */
    l_step:='020'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    insert into ubrr_data.ubrr_sbs_new(cSBSaccd,
                                       cSBScurd,
                                       cSBSTypeCom,
                                       mSBSsumpays,
                                       iSBScountPays,
                                       mSBSsumcom,
                                       iSBSotdnum,
                                       iSBSBatNum,
                                       dSBSDate,
                                       iSBSTypeCom,
                                       dsbsdatereg)
    with s1 as -- >> 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���
    (          select itrnnum
                     ,itrnanum
                     ,ctrnaccd
                     ,ctrncur
                     ,mtrnsum
                     ,'PP6_NTK' TypeCom
                     ,iaccotd
                     ,to_number(to_char(nvl(iOTDbatnum, 70)) || '00') batnum
               from /*xxi.v_trn_part_current*/ ubrr_trn_old_new_v t, -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                    acc a,
                    /* -- 14.06.2018 ubrr korolkov #50487
                    (select g.cgacacc, g.cgaccur
                     from gac g
                     where g.igaccat = 112 and g.igacnum in (45, 81, 82, 83, 84, 85, 67, 86, 87, 88, 89, 90)
                       and exists
                               (select 1
                                from xxi.au_attach_obg au
                                where au.caccacc = g.cGACacc
                                  and au.cacccur = g.cGACcur
                                  and i_table = 304
                                  and d_create <= d2
                                  and au.c_newdata like '112/' || to_char(g.igacnum))) g,
                    */ -- 14.06.2018 ubrr korolkov #50487
                    otd o
               where t.ctrnaccd like acc_1
                 and t.ctrncur = 'RUR'
                 and t.dtrntran between d1 and d2
                 and a.caccacc = t.ctrnaccd
                 and a.cacccur = t.ctrncur
                 and a.caccprizn <> '�'
                 /* -- 14.06.2018 ubrr korolkov #50487
                 and g.cgacacc = a.caccacc
                 and g.cgaccur = a.cacccur
                 */ -- 14.06.2018 ubrr korolkov #50487
                 and o.iotdnum = a.iaccotd
                 and ( -- �������
                      (((itrntype in (4, 11, 15, 21, 22, 23)
                     and not (substr(ctrnacca, 1, 3) in ('401', '402', '403', '404')
                          and exists
                                  (select 1
                                   from trn_dept_info
                                   where inum = itrnnum and ianum = itrnanum and ccreatstatus is not null)))
                    and not (itrntype = 22
                         and regexp_like(ctrnpurp, '^ *(|! *)0406')
                         and exists
                                 (select 1
                                  from xxi."smr"
                                  where csmrmfo8 = ctrnmfoa)))
                   and ctrnmfoa not in (select cfilmfo
                                        from xxi."fil"
                                        where idsmr = ubrr_xxi5.ubrr_util.GetBankIdSmr)
                   and substr(to_char(itrnbatnum), 3) not in ('10', '13'))
                   -- ����������, ������
                   or  ((((itrntype in (2, 3, 14) and itrnpriority not in (3, 4) and nvl(iTRNsop, 0) <> 4)
                       or  (itrntype in (25, 28)
                        and nvl(iTRNsop, 0) not in (5, 7)
                        and nvl(iTRNsop, 0) <> 4  -- 01.06.18 �������� �.�. https://redmine.lan.ubrr.ru/issues/52982
                        and itrnpriority not in (3, 4)
                        and not (itrntype = 25
                             and regexp_like(ctrnpurp, '^ *(|! *)0406')
                             and exists
                                     (select 1
                                      from xxi."smr"
                                      where csmrmfo8 = ctrnmfoa))))
                     and (substr(itrnba2c, 1, 3) in (303, 405, 406, 407, 423, 426) or itrnba2c in (40802, 40807, 40817, 40818, 40820)))
                     or  (itrntype in (4, 11, 15, 21, 23)
                      and not (substr(ctrnacca, 1, 3) in ('401', '402', '403', '404')
                           and exists
                                   (select 1
                                    from trn_dept_info
                                    where inum = itrnnum and ianum = itrnanum and ccreatstatus is not null))
                      and nvl(iTRNsop, 0) <> 4
                      and ctrnmfoa in (select cfilmfo
                                       from xxi."fil"
                                       where idsmr = ubrr_xxi5.ubrr_util.GetBankIdSmr))))
                 and itrnba2d not in (40813, 40817, 40818, 40820, 42309, 40810, 40811, 40812, 40823, 40824)
                 and substr(a.caccacc, 1, 3) not in ('401', '402', '403', '404', '409')
                 and substr(to_char(t.itrnbatnum), 3) not in ('10', '13')
                 and exists
                         (select 1
                          from gac
                          where cgacacc = a.caccacc and cgaccur = a.cacccur and igaccat = 131
                            and exists
                                    (select 1
                                     from xxi.au_attach_obg au
                                     where au.caccacc = a.caccacc
                                       and au.cacccur = a.cacccur
                                       and i_table = 304
                                       and d_create <= d2
                                       and au.c_newdata like '131%'))
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = a.caccacc and cgaccur = a.cacccur and igaccat = 333 and igacnum = 2)
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 112 and igacnum in (36, 37, 38, 39, 40))
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.caccacc and cgaccur = a.CACCCUR and igaccat = 114 and igacnum = 10
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.caccacc
                                           and au.cacccur = a.CACCCUR
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '114/10'))
                 -->> 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = ctrnaccd and igaccat = 112 and igacnum=97
                            and exists
                                    (select 1
                                     from xxi.au_attach_obg au
                                     where au.caccacc = a.caccacc
                                       and au.cacccur = a.cacccur
                                       and au.i_table = 304
                                       and trunc(d_create) <= d2
                                       and (c_newdata = '112/97' or c_newdata = '112/97')))
                 --<< 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                 -- >> 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
                 and not exists( select 1
                                   from gac
                                  where cgacacc = ctrnaccd
                                    and igaccat = 112
                                    and igacnum = 67 -- 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                                    and exists( select 1
                                                  from xxi.au_attach_obg au
                                                 where au.caccacc = a.caccacc
                                                   and au.cacccur = a.cacccur
                                                   and au.i_table = 304
                                                   and trunc(au.d_create) <= d2
                                                   and au.c_newdata    = '112/67'
                                              )
                               )
                 -- << 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
                 -->> 25.10.2018 �������� [18-56613] �� "������ ������" (�� ���� �� "��������") ��� ��� � 01.11.18
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = ctrnaccd and igaccat = 112 and igacnum=98
                            and exists
                                    (select 1
                                     from xxi.au_attach_obg au
                                     where au.caccacc = a.caccacc
                                       and au.cacccur = a.cacccur
                                       and au.i_table = 304
                                       and trunc(d_create) <= d2
                                       and (c_newdata = '112/97' or c_newdata = '112/98')))
                 --<< 25.10.2018 �������� [18-56613] �� "������ ������" (�� ���� �� "��������") ��� ��� � 01.11.18

                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 112 and igacnum = 50
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and add_months(last_day(d_create), 5) > d1
                                           and au.c_newdata = '112/50'))
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 112
                                and igacnum in ( -- ����� �� 78,79,80,100,101,102  ����� ������������ � ���� calc_field  ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                                 94
                                ,99,103 --27.12.2018 �������� [15-43]  ���: ����� ����� ����� � ��������� ������� �� ����� ��������
                              ,104,105,106 -- ������  �������  3, 6, 12  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                              )
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and trunc(d_create) <= d2
                                           and au.c_newdata like '112/' || to_char(gac.igacnum)))
                 -->>03.07.2019 �������� [19-61974] ���: ���������� �������� �� �����������
                 and check_exclude_client(t.itrntype, t.ctrnmfoa, t.dtrntran, t.itrnnumanc, t.ctrnacca, t.ctrnpurp, t.ctrnowna) = 0
                 --<<03.07.2019 �������� [19-61974] ���: ���������� �������� �� �����������
                 -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                 and not exists ( select 1
                                          from gac g
                                              ,ubrr_rko_exinc_catgr e
                                         where g.igaccat   = e.icat
                                           and g.igacnum   = e.igrp
                                           and e.ccom_type = 'PP6_NTK'
                                           and e.exinc     = 0
                                           and g.cgacacc   = a.caccacc
                                           and g.cgaccur   = a.cACCcur
                                           and exists (select 1
                                                         from xxi.au_attach_obg au
                                                        where au.caccacc = a.caccacc
                                                          and au.cacccur = a.cacccur
                                                          and au.i_table = 304
                                                          and trunc(au.d_create) <= d2
                                                          and au.c_newdata = e.icat||'/'||e.igrp
                                                          and trunc(au.d_create) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end) --<<22.01.2020 �������� [19-64846]
                                                      )
                                )
                 --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                 -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                         (select 1
                            from UBRR_UNIQUE_TARIF_ACC uutc,
                                 UBRR_UNIQUE_ACC_COMMS uuac
                           where uutc.cacc = t.ctrnaccd
                             and t.dtrncreate between uutc.dopentarif and uutc.dcanceltarif
                             and uutc.idsmr = lc_idsmr
                             and uutc.status = 'N'
                             and uutc.uuta_id = uuac.uuta_id
                             and uuac.com_type = 'PP6'
                             )
                 --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                             (select 1
                              from ubrr_data.ubrr_sbs_new
                              where idsmr = a.idsmr
                                and dSBSdate = p_date
                                and cSBSaccd = a.caccacc
                                and cSBScurd = a.cacccur
                                and cSBSTypeCom = 'PP6_NTK'
                                and iSBStrnnum is not null
                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                             )
    ) -- s1
    ,s12 as -- ������ iaccotd �� ubrr_comm_gacmvz_tarif.cmvz (131 ���)
    ( select s111.itrnnum
            ,s111.itrnanum
            ,s111.ctrnaccd
            ,s111.ctrncur
            ,s111.mtrnsum
            ,s111.TypeCom
            ,( case when s111.cgacacc is not null then s111.cmvz -- 131 ��� �� ����� ����
                    when s111.cgacacc is null then s111.iaccotd -- 131 ��� �� ����� ���
               end
             ) iaccotd
            ,s111.batnum
       from (  select s1.itrnnum
                     ,s1.itrnanum
                     ,s1.ctrnaccd
                     ,s1.ctrncur
                     ,s1.mtrnsum
                     ,s1.TypeCom
                     ,s1.iaccotd
                     ,s1.batnum
                     ,gs1.cgacacc
                     ,gs1.cmvz
                 from s1
                 left join ( select gg.cgacacc  -- ������: ���� 131 ��� ���
                                   ,gg.cgaccur
                                   ,gg.igaccat
                                   ,gg.cmvz
                                   ,gg.idsmr
                               from ( select g.cgacacc
                                            ,g.cgaccur
                                            ,g.igaccat
                                            ,tar.cmvz
                                            ,g.idsmr
                                            ,row_number() over ( partition by g.cgacacc,g.cgaccur,g.idsmr order by null) rn
                                        from gac g
                                        left join ubrr_comm_gacmvz_tarif tar
                                          on g.igaccat = tar.icat
                                         and g.igacnum = tar.inum
                                       where g.igaccat = 131
                                         and g.idsmr   = BankIdSmr
                                    ) gg
                              where gg.rn =1
                           ) gs1
                 on s1.ctrnaccd = gs1.cgacacc
                and s1.ctrncur  = gs1.cgaccur
            ) s111
    ) -- s12
    ,s2 as
    ( select s12.itrnnum
            ,s12.itrnanum
            ,s12.ctrnaccd
            ,s12.ctrncur
            ,s12.mtrnsum
            ,GetSumComiss( s12.itrnnum
                          ,s12.itrnanum
                          ,s12.ctrnAccD
                          ,s12.ctrncur
                          ,s12.iaccotd
                          ,s12.TypeCom
                          ,s12.mtrnsum
                          ,0 ) sumcom
            ,s12.TypeCom
            ,s12.iaccotd
            ,s12.batnum
        from s12
       where exists( select 1
                       from ubrr_data.ubrr_rko_tarif        v
                           ,ubrr_data.ubrr_rko_tarif_otdsum o
                      where v.Parent_IdSmr = BankIdSmr
                        and v.com_type     = s12.TypeCom
                        and v.id           = o.id_com
                        and o.otd          = s12.iaccotd )
    ) -- s2
    select s2.ctrnaccd
          ,s2.ctrncur
          ,s2.TypeCom
          ,sum(case when s2.sumcom = 0 then 0 else s2.mtrnsum end)
          ,sum(sign(s2.sumcom))
          ,sum(s2.sumcom)
          ,s2.iaccotd
          ,s2.batnum
          ,p_Date
          ,1
          ,p_Date
      from s2
     group by s2.ctrnaccd, s2.ctrncur, s2.TypeCom, s2.iaccotd, s2.batnum; -- << 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���

    l_step:='025'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := sql%rowcount;
    WriteProtocol('��������� �������� �� ������������� ������� ���: ' || iCnt);
    iRes := iRes + iCnt;

    /*
     ������������� ������ -- ������� �������
    */
    l_step:='030'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    insert into ubrr_data.ubrr_sbs_new(cSBSaccd,
                                       cSBScurd,
                                       cSBSTypeCom,
                                       mSBSsumpays,
                                       iSBScountPays,
                                       mSBSsumcom,
                                       iSBSotdnum,
                                       iSBSBatNum,
                                       dSBSDate,
                                       iSBSTypeCom,
                                       dsbsdatereg)
        (select ctrnaccd,
                ctrncur,
                TypeCom,
                /*
                sum(case when sumcom = 0 then 0 else mtrnsum end),
                sum(sign(sumcom)),
                */
                sum(mtrnsum),
                count(1),
                sum(sumcom),
                iaccotd,
                batnum,
                p_Date,
                1,
                p_Date
         from (select itrnnum,
                      itrnanum,
                      ctrnaccd,
                      ctrncur,
                      mtrnsum,
                      GetSumComiss(null,null,ctrnaccd,ctrncur,a.iaccotd,decode(nvl(iTRNsop, 0), 4, 'PP6', 'PP9'),mtrnsum,0) sumcom, --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
                      decode(nvl(iTRNsop, 0), 4, 'PP6', 'PP9') TypeCom,
                      iaccotd,
                      to_number(to_char(nvl(iOTDbatnum, 70)) || '00') batnum
               from /*xxi.v_trn_part_current*/ ubrr_trn_old_new_v t, -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                    acc a,
                    otd o
               where t.ctrnaccd like acc_1
                 and t.ctrncur = 'RUR'
                 and t.dtrntran between d1 and d2
                 and a.caccacc = t.ctrnaccd
                 and a.cacccur = t.ctrncur
                 and a.caccprizn <> '�'
                 and o.iotdnum = a.iaccotd
                 and ((itrntype in (4, 11, 15, 21, 22, 23)
                   and not (substr(ctrnacca, 1, 3) in ('401', '402', '403', '404')
                        and exists
                                (select 1
                                 from trn_dept_info
                                 where inum = itrnnum and ianum = itrnanum and ccreatstatus is not null))))
                 and not (itrntype = 22
                      and regexp_like(ctrnpurp, '^ *(|! *)0406')
                      and exists
                              (select 1
                               from xxi."smr"
                               where csmrmfo8 = ctrnmfoa))
                 and t.ctrnmfoa not in (select cfilmfo
                                        from xxi."fil"
                                        where idsmr = BankIdSmr) -- ���� ������� -> ����������
                 and t.itrnba2d not in (40813, 40817, 40818, 40820, 42309, 40810, 40811, 40812, 40823, 40824)
                 and substr(caccacc, 1, 3) not in ('401', '402', '403', '404', '409')
                 and substr(to_char(itrnbatnum), 3) not in ('10', '13')
                 -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and exists
                         (select 1
                          from UBRR_UNIQUE_TARIF_ACC uutc,
                               UBRR_UNIQUE_ACC_COMMS uuac
                          where uutc.cacc = t.ctrnaccd
                            and t.dtrntran between dopentarif and dcanceltarif
                            and uutc.idsmr = lc_idsmr
                            and uutc.status = 'N'
                            and uutc.uuta_id = uuac.uuta_id
                            and uuac.daily = 'Y'
                            and uuac.com_type = decode(nvl(iTRNsop, 0), 4, 'PP6', 'PP9')
                          )
                 --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 -->> 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = ctrnaccd and igaccat = 112 and igacnum=97
                            and exists
                                    (select 1
                                     from xxi.au_attach_obg au
                                     where au.caccacc = a.caccacc
                                       and au.cacccur = a.cacccur
                                       and au.i_table = 304
                                       and trunc(d_create) <= d2
                                       and (c_newdata = '112/97' or c_newdata = '112/97')))
                 --<< 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.caccacc and cgaccur = a.cacccur and igaccat = 112 and igacnum in (78, 79, 80, 94
                              ,99,100,101,102,103 --27.12.2018 �������� [15-43]  ���: ����� ����� ����� � ��������� ������� �� ����� ��������
                              ,104,105,106 -- ������  �������  3, 6, 12  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                              )
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and trunc(d_create) <= d2
                                           and au.c_newdata like '112/' || to_char(gac.igacnum)))
                 -->>13.06.2019 �������� [19-62974] ���. ���������� ��������: ��������������� ������� ����� ����� �� ���
                 /*and not exists
                             (select 1
                              from gac
                              where cgacacc = a.caccacc and cgaccur = a.cacccur and igaccat = 112 and igacnum = 67
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and trunc(d_create) <= d2
                                           and au.c_newdata like '112/67'))*/
                 --<<13.06.2019 �������� [19-62974] ���. ���������� ��������: ��������������� ������� ����� ����� �� ���
                 -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                 and (    decode(nvl(iTRNsop,0), 4, 'PP6', 'PP9') = 'PP9'
                       or not exists ( select 1
                                          from gac g
                                              ,ubrr_rko_exinc_catgr e
                                         where g.igaccat   = e.icat
                                           and g.igacnum   = e.igrp
                                           and e.ccom_type = 'PP6'
                                           and e.exinc     = 0
                                           and g.cgacacc   = a.caccacc
                                           and g.cgaccur   = a.cACCcur
                                           and exists (select 1
                                                         from xxi.au_attach_obg au
                                                        where au.caccacc = a.caccacc
                                                          and au.cacccur = a.cacccur
                                                          and au.i_table = 304
                                                          and trunc(au.d_create) <= d2
                                                          and au.c_newdata = e.icat||'/'||e.igrp
                                                          and trunc(au.d_create) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end) --<<22.01.2020 �������� [19-64846]
                                                      )
                                      )
                     )
                 --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                 and not exists
                             (select 1
                              from ubrr_data.ubrr_sbs_new
                              where idsmr = a.idsmr
                                and dSBSdate = p_date
                                and cSBSaccd = a.caccacc
                                and cSBScurd = a.cacccur
                                and cSBSTypeCom = decode(nvl(iTRNsop, 0), 4, 'PP6', 'PP9')
                                and iSBStrnnum is not null
                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                             )
            )
         group by ctrnaccd, ctrncur, TypeCom, iaccotd, batnum);

    l_step:='035'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := sql%rowcount;
    WriteProtocol('��������� �������� �� ������������� ������� �� ������� ��������: ' || iCnt);
    iRes := iRes + iCnt;

    -->>-- 22.06.2018 ������ �.�. [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
    /*
     ������������� ������ ��� ������� ���������� ����� � ������ "����� ������ � 01.07.18"
    */
    l_step:='040'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    insert into ubrr_data.ubrr_sbs_new(cSBSaccd,
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
                                       MSBSTARIF)
    -->>16.01.2020 �������� [20-70655]
        with s1 as
         (     select itrnnum,
                      itrnanum,
                      ctrnaccd,
                      ctrncur,
                      mtrnsum,
                      TypeCom,
                      iaccotd,
                      batnum
               from (select itrnnum,
                            itrnanum,
                            ctrnaccd,
                            ctrncur,
                            mtrnsum,
                            case
                                when substr(to_char(itrnbatnum), -2) in ('01', '10', '13') and substr(ctrnpurp, 1, 1) = '!' then
                                    case when itrnsop = 4 or iaccotd = 9216 then 'PES6_PE' else 'PES9_PE' end
                                else
                                    case when itrnsop = 4 or iaccotd = 9216 then 'PE6_PE' else 'PE9_PE' end
                            end
                                as TypeCom,
                            iaccotd,
                            to_number(to_char(nvl(iOTDbatnum, 70)) || '00') batnum
                     from /*xxi.v_trn_part_current*/ ubrr_trn_old_new_v t, -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                          acc a,
                          otd o
                     where t.ctrnaccd like acc_1
                       and t.ctrncur = 'RUR'
                       and t.dtrntran between d1 and d2
                       and a.caccacc = t.ctrnaccd
                       and a.cacccur = t.ctrncur
                       and a.caccprizn <> '�'
                       and a.iaccotd = o.iotdnum
                       and not (substr(ctrnacca, 1, 3) in ('401', '402', '403', '404')
                            and exists
                                    (select 1
                                     from trn_dept_info
                                     where inum = itrnnum and ianum = itrnanum and ccreatstatus is not null))
                       and not (itrntype = 22
                            and regexp_like(ctrnpurp, '^ *(|! *)0406')
                            and exists
                                    (select 1
                                     from xxi."smr"
                                     where csmrmfo8 = ctrnmfoa))
                       and ctrnmfoa not in (select cfilmfo
                                            from xxi."fil"
                                            where idsmr = BankIdSmr)
                       and t.itrnba2d not in (40813, 40817, 40818, 40820, 42309, 40810, 40811, 40812, 40823, 40824)
                       and ( -- ������� ��������
                            (itrntype in (4, 11, 15, 21, 22, 23)
                         and ((substr(to_char(itrnbatnum), -2) in ('01', '10', '13') and nvl(substr(ctrnpurp, 1, 1), '(') <> '!')
                           or  substr(to_char(itrnbatnum), -2) not in ('01', '10', '13')))
                         or -- ������� ������
                           ( itrntype = 4
                         and substr(to_char(itrnbatnum), -2) in ('01', '10', '13')
                         and substr(ctrnpurp, 1, 1) = '!'))
                       and substr(case
                                      when iTrnType in (5, 50, 53, 52, 55, 17, 41, 42, 43, 44) then nvl(cTrnClient_Acc, cTrnAccC)
                                      when cTrnMfoA is null then nvl(cTrnAccA, cTrnAccC)
                                      else cTrnAccA
                                  end,
                                  1,
                                  5) not in
                               ('60309', '60322')
                       and exists
                               (select 1
                                from gac
                                where cgacacc = ctrnaccd and igaccat = 112 and igacnum=97
                                  and exists
                                          (select 1
                                           from xxi.au_attach_obg au
                                           where au.caccacc = a.caccacc
                                             and au.cacccur = a.cacccur
                                             and au.i_table = 304
                                             and trunc(d_create) <= d2
                                             and (c_newdata = '112/97' or c_newdata = '112/97')))
                       and not exists
                                   (select 1
                                    from gac
                                    where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 112
                                      and igacnum in (1, 3, 4, 5, 7, 9, 10, 13, 15, 16, 17, 19, 20, 21, 22, 23, 24, 25, 31, 36, 37, 38, 39, 40, 45, 57))
                       and not exists
                               (select 1
                                from gac
                                where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 333 and igacnum = 2)
                       and not exists
                                   (select 1
                                    from xxi.au_attach_obg au
                                    where au.caccacc = a.cACCacc
                                      and au.cacccur = a.cACCcur
                                      and d_create > d1
                                      and d_create < d2
                                      and i_table = 304
                                      and au.c_newdata in ('112/36', '112/37', '112/45'))
                       and not exists
                                   (select 1
                                    from gac
                                    where cgacacc = a.cACCacc
                                      and cgaccur = a.cACCcur
                                      and igaccat = 112
                                      and igacnum in (78, 79, 80, 94
                                      ,99,100,101,102,103 --27.12.2018 �������� [15-43]  ���: ����� ����� ����� � ��������� ������� �� ����� ��������
                                      ,104,105,106 -- ������  �������  3, 6, 12  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                                      )
                                      and exists
                                              (select 1
                                               from xxi.au_attach_obg au
                                               where au.caccacc = a.cACCacc
                                                 and au.cacccur = a.cACCcur
                                                 and i_table = 304
                                                 and trunc(d_create) <= d2
                                                 and au.c_newdata like '112/' || to_char(gac.igacnum)))
                       -->>23.10.2018 �������� [18-56613] �� "������ ������" (�� ���� �� "��������") ��� ��� � 01.11.18
                       and not exists
                               (select 1
                                from gac
                                where cgacacc = a.cACCacc
                                  and cgaccur = a.cACCcur
                                  and igaccat = 112
                                  and igacnum = 98
                                  and not exists
                                           (select 1
                                            from xxi.au_attach_obg au
                                            where au.caccacc = a.cACCacc
                                              and au.cacccur = a.cACCcur
                                              and d_create > d1
                                              and d_create < d2
                                              and i_table = 304
                                              and au.c_newdata in ('112/98')))
                       --<<23.10.2018 �������� [18-56613] �� "������ ������" (�� ���� �� "��������") ��� ��� � 01.11.18
                       and check_exclude_client(t.itrntype, t.ctrnmfoa, t.dtrntran, t.itrnnumanc, t.ctrnacca, t.ctrnpurp, t.ctrnowna) = 0 -->><<--03.07.2019 �������� [19-61974] ���: ���������� �������� �� �����������
                       -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                       and not exists
                                   (select 1
                                    from UBRR_UNIQUE_TARIF_ACC uutc
                                    where uutc.cacc = t.ctrnaccd
                                      and t.dtrncreate between uutc.dopentarif and uutc.dcanceltarif
                                      and uutc.idsmr = lc_idsmr
                                      and uutc.status = 'N'
                                      )
                        --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                        ) t1
               where not exists
                             (select 1
                              from ubrr_data.ubrr_sbs_new
                              where idsmr = lc_idsmr
                                and dSBSdate = p_date
                                and cSBSaccd = t1.ctrnaccd
                                and cSBScurd = t1.ctrncur
                                and cSBSTypeCom = t1.TypeCom
                                and iSBStrnnum is not null
                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                             )
                 and exists
                         (select 1
                          from ubrr_data.ubrr_rko_tarif v,
                               ubrr_data.ubrr_rko_tarif_otdsum o
                          where v.Parent_IdSmr = BankIdSmr and v.com_type = t1.TypeCom and v.id = o.id_com and o.otd = t1.iaccotd)
         ) -- s1
         ,s12 as -- ������ iaccotd �� ubrr_comm_gacmvz_tarif.cmvz (131 ���)
         ( select s111.itrnnum
                , s111.itrnanum
                , s111.ctrnaccd
                , s111.ctrncur
                , s111.mtrnsum
                , s111.TypeCom
                , ( case when s111.cgacacc is not null then s111.cmvz -- 131 ��� �� ����� ����
                         when s111.cgacacc is null then s111.iaccotd -- 131 ��� �� ����� ���
                    end
                  ) iaccotd
                , s111.batnum
           from (  select s1.itrnnum
                         ,s1.itrnanum
                         ,s1.ctrnaccd
                         ,s1.ctrncur
                         ,s1.mtrnsum
                         ,s1.TypeCom
                         ,s1.iaccotd
                         ,s1.batnum
                         ,gs1.cgacacc
                         ,gs1.cmvz
                     from s1
                     left join ( select gg.cgacacc  -- ������: ���� 131 ��� ���
                                       ,gg.cgaccur
                                       ,gg.igaccat
                                       ,gg.cmvz
                                       ,gg.idsmr
                                   from ( select g.cgacacc
                                                ,g.cgaccur
                                                ,g.igaccat
                                                ,tar.cmvz
                                                ,g.idsmr
                                                ,row_number() over ( partition by g.cgacacc,g.cgaccur,g.idsmr order by null) rn
                                            from gac g
                                            left join ubrr_comm_gacmvz_tarif tar
                                              on g.igaccat = tar.icat
                                             and g.igacnum = tar.inum
                                           where g.igaccat = 131
                                              and g.idsmr   = BankIdSmr
                                        ) gg
                                  where gg.rn = 1
                               ) gs1
                     on s1.ctrnaccd = gs1.cgacacc
                    and s1.ctrncur  = gs1.cgaccur
                ) s111
        ) -- s12
        , s2 as
        ( select s12.itrnnum
                ,s12.itrnanum
                ,s12.ctrnaccd
                ,s12.ctrncur
                ,s12.mtrnsum
                ,GetSumComiss( s12.itrnnum
                              ,s12.itrnanum
                              ,s12.ctrnAccD
                              ,s12.ctrncur
                              ,s12.iaccotd
                              ,s12.TypeCom
                              ,s12.mtrnsum
                              ,0 ) sumcom
                ,s12.TypeCom
                ,s12.iaccotd
                ,s12.batnum
            from s12
           where exists( select 1
                           from ubrr_data.ubrr_rko_tarif        v
                               ,ubrr_data.ubrr_rko_tarif_otdsum o
                           where v.Parent_IdSmr = BankIdSmr
                            and v.com_type     = s12.TypeCom
                            and v.id           = o.id_com
                            and o.otd          = s12.iaccotd )
        ) --s2
         select s2.ctrnaccd
              , s2.ctrncur
              , s2.TypeCom
              , sum(case when s2.sumcom = 0 then 0 else s2.mtrnsum end)
              , count(1)
              , sum(s2.sumcom)
              , s2.iaccotd
              , s2.batnum
              , p_Date
              , 1
              , p_Date
              , sum(sign(s2.sumcom))
          from s2
         group by ctrnaccd, ctrncur, TypeCom, iaccotd, batnum;
    --<<16.01.2020 �������� [20-70655]

    l_step:='045'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := sql%rowcount;
    WriteProtocol('��������� �������� �� ������������� ������� ��� ������� ���������� ����� � ������ "����� ������ � 01.07.18": ' || iCnt);
    iRes := iRes + iCnt;
    --<<-- 22.06.2018 ������ �.�. [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)

    -->> 22.06.2018 �������� [18-56613] �� "������ ������" (�� ���� �� "��������") ��� ��� � 01.11.18
    /*
     ������������� ������ ��� �� "������ ������" [18-56613] [R_LIGHT]
    */
    l_step:='050'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    insert into ubrr_data.ubrr_sbs_new(cSBSaccd,
                                       cSBScurd,
                                       cSBSTypeCom,
                                       mSBSsumpays,
                                       iSBScountPays,
                                       mSBSsumcom,
                                       iSBSotdnum,
                                       iSBSBatNum,
                                       dSBSDate,
                                       iSBSTypeCom,
                                       dsbsdatereg)
    with s1 as      -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
    (          select itrnnum
                     ,itrnanum
                     ,ctrnaccd
                     ,ctrncur
                     ,mtrnsum
                     ,'R_LIGHT' as TypeCom
                     ,iaccotd
                     ,to_number(to_char(nvl(iOTDbatnum, 70)) || '00') batnum
               from /*xxi.v_trn_part_current*/ ubrr_trn_old_new_v t, -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                    acc a,
                    otd o
               where t.ctrnaccd like acc_1
                 and t.ctrncur = 'RUR'
                 and t.dtrntran between d1 and d2
                 and a.caccacc = t.ctrnaccd
                 and a.cacccur = t.ctrncur
                 and a.caccprizn <> '�'
                 and o.iotdnum = a.iaccotd
                 and ( -- �������
                      (((itrntype in (4, 11, 15, 21, 22, 23)
                     and not (substr(ctrnacca, 1, 3) in ('401', '402', '403', '404')
                          and exists
                                  (select 1
                                   from trn_dept_info
                                   where inum = itrnnum and ianum = itrnanum and ccreatstatus is not null)))
                    and not (itrntype = 22
                         and regexp_like(ctrnpurp, '^ *(|! *)0406')
                         and exists
                                 (select 1
                                  from xxi."smr"
                                  where csmrmfo8 = ctrnmfoa)))
                   and ctrnmfoa not in (select cfilmfo
                                        from xxi."fil"
                                        where idsmr = ubrr_xxi5.ubrr_util.GetBankIdSmr)
                   and substr(to_char(itrnbatnum), 3) not in ('10', '13'))
                   -- ����������, ������
                   or  ((((itrntype in (2, 3, 14) and itrnpriority not in (3, 4) and nvl(iTRNsop, 0) <> 4)
                       or  (itrntype in (25, 28)
                        and nvl(iTRNsop, 0) not in (5, 7)
                        and nvl(iTRNsop, 0) <> 4  -- 01.06.18 �������� �.�. https://redmine.lan.ubrr.ru/issues/52982
                        and itrnpriority not in (3, 4)
                        and not (itrntype = 25
                             and regexp_like(ctrnpurp, '^ *(|! *)0406')
                             and exists
                                     (select 1
                                      from xxi."smr"
                                      where csmrmfo8 = ctrnmfoa))))
                     and (substr(itrnba2c, 1, 3) in (303, 405, 406, 407, 423, 426) or itrnba2c in (40802, 40807, 40817, 40818, 40820)))
                     or  (itrntype in (4, 11, 15, 21, 23)
                      and not (substr(ctrnacca, 1, 3) in ('401', '402', '403', '404')
                           and exists
                                   (select 1
                                    from trn_dept_info
                                    where inum = itrnnum and ianum = itrnanum and ccreatstatus is not null))
                      and nvl(iTRNsop, 0) <> 4
                      and ctrnmfoa in (select cfilmfo
                                       from xxi."fil"
                                       where idsmr = ubrr_xxi5.ubrr_util.GetBankIdSmr))))
                 and itrnba2d not in (40813, 40817, 40818, 40820, 42309, 40810, 40811, 40812, 40823, 40824)
                 and substr(a.caccacc, 1, 3) not in ('401', '402', '403', '404', '409')
                 and substr(to_char(t.itrnbatnum), 3) not in ('10', '13')
                 and exists
                         (select 1
                          from gac
                          where cgacacc = a.caccacc and cgaccur = a.cacccur and igaccat = 131
                            and exists
                                    (select 1
                                     from xxi.au_attach_obg au
                                     where au.caccacc = a.caccacc
                                       and au.cacccur = a.cacccur
                                       and i_table = 304
                                       and d_create <= d2
                                       and au.c_newdata like '131%'))
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = a.caccacc and cgaccur = a.cacccur and igaccat = 333 and igacnum = 2)
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 112 and igacnum in (36, 37, 38, 39, 40))
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.caccacc and cgaccur = a.CACCCUR and igaccat = 114 and igacnum = 10
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.caccacc
                                           and au.cacccur = a.CACCCUR
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '114/10'))
                 -->> 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = ctrnaccd and igaccat = 112 and igacnum=97
                            and exists
                                    (select 1
                                     from xxi.au_attach_obg au
                                     where au.caccacc = a.caccacc
                                       and au.cacccur = a.cacccur
                                       and au.i_table = 304
                                       and trunc(d_create) <= d2
                                       and (c_newdata = '112/97' or c_newdata = '112/97')))
                 --<< 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)

                 -->> 25.10.2018 �������� [18-56613] �� "������ ������" (�� ���� �� "��������") ��� ��� � 01.11.18
                 and exists
                         (select 1
                          from gac
                          where cgacacc = ctrnaccd and igaccat = 112 and igacnum=98
                            and exists
                                    (select 1
                                     from xxi.au_attach_obg au
                                     where au.caccacc = a.caccacc
                                       and au.cacccur = a.cacccur
                                       and au.i_table = 304
                                       and trunc(d_create) <= d2
                                       and (c_newdata = '112/97' or c_newdata = '112/98')))
                 --<< 25.10.2018 �������� [18-56613] �� "������ ������" (�� ���� �� "��������") ��� ��� � 01.11.18

                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 112 and igacnum = 50
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and add_months(last_day(d_create), 5) > d1
                                           and au.c_newdata = '112/50'))
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 112 and igacnum in (78, 79, 80, 94
                              ,99,100,101,102,103 --27.12.2018 �������� [15-43]  ���: ����� ����� ����� � ��������� ������� �� ����� ��������
                              ,104,105,106 -- ������  �������  3, 6, 12  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                              )
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and trunc(d_create) <= d2
                                           and au.c_newdata like '112/' || to_char(gac.igacnum)))
                 -->>03.07.2019 �������� [19-61974] ���: ���������� �������� �� �����������
                 -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                 and not exists ( select 1
                                          from gac g
                                              ,ubrr_rko_exinc_catgr e
                                         where g.igaccat   = e.icat
                                           and g.igacnum   = e.igrp
                                           and e.ccom_type = 'R_LIGHT'
                                           and e.exinc     = 0
                                           and g.cgacacc   = a.caccacc
                                           and g.cgaccur   = a.cACCcur
                                           and exists (select 1
                                                         from xxi.au_attach_obg au
                                                        where au.caccacc = a.caccacc
                                                          and au.cacccur = a.cacccur
                                                          and au.i_table = 304
                                                          and trunc(au.d_create) <= d2
                                                          and au.c_newdata = e.icat||'/'||e.igrp
                                                          and trunc(au.d_create) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end) --<<22.01.2020 �������� [19-64846]
                                                      )
                                )
                 --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                 and check_exclude_client(t.itrntype, t.ctrnmfoa, t.dtrntran, t.itrnnumanc, t.ctrnacca, t.ctrnpurp, t.ctrnowna) = 0
                 --<<03.07.2019 �������� [19-61974] ���: ���������� �������� �� �����������
                 -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                         (select 1
                            from UBRR_UNIQUE_TARIF_ACC uutc,
                                 UBRR_UNIQUE_ACC_COMMS uuac
                           where uutc.cacc = t.ctrnaccd
                             and t.dtrncreate between uutc.dopentarif and uutc.dcanceltarif
                             and uutc.idsmr = lc_idsmr
                             and uutc.status = 'N'
                             and uutc.uuta_id = uuac.uuta_id
                             and uuac.com_type = 'PP6'
                             )
                 --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                             (select 1
                              from ubrr_data.ubrr_sbs_new
                              where idsmr = a.idsmr
                                and dSBSdate = p_date
                                and cSBSaccd = a.caccacc
                                and cSBScurd = a.cacccur
                                and cSBSTypeCom = 'R_LIGHT'
                                and iSBStrnnum is not null
                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                             )
    ) -- s1
    ,s12 as -- ������ iaccotd �� ubrr_comm_gacmvz_tarif.cmvz (131 ���)
    ( select s111.itrnnum
            ,s111.itrnanum
            ,s111.ctrnaccd
            ,s111.ctrncur
            ,s111.mtrnsum
            ,s111.TypeCom
            ,( case when s111.cgacacc is not null then s111.cmvz -- 131 ��� �� ����� ����
                    when s111.cgacacc is null then s111.iaccotd -- 131 ��� �� ����� ���
               end
             ) iaccotd
            ,s111.batnum
       from (  select s1.itrnnum
                     ,s1.itrnanum
                     ,s1.ctrnaccd
                     ,s1.ctrncur
                     ,s1.mtrnsum
                     ,s1.TypeCom
                     ,s1.iaccotd
                     ,s1.batnum
                     ,gs1.cgacacc
                     ,gs1.cmvz
                 from s1
                 left join ( select gg.cgacacc  -- ������: ���� 131 ��� ���
                                   ,gg.cgaccur
                                   ,gg.igaccat
                                   ,gg.cmvz
                                   ,gg.idsmr
                               from ( select g.cgacacc
                                            ,g.cgaccur
                                            ,g.igaccat
                                            ,tar.cmvz
                                            ,g.idsmr
                                            ,row_number() over ( partition by g.cgacacc,g.cgaccur,g.idsmr order by null) rn
                                        from gac g
                                        left join ubrr_comm_gacmvz_tarif tar
                                          on g.igaccat = tar.icat
                                         and g.igacnum = tar.inum
                                       where g.igaccat = 131
                                         and g.idsmr   = BankIdSmr
                                    ) gg
                              where gg.rn =1
                           ) gs1
                 on s1.ctrnaccd = gs1.cgacacc
                and s1.ctrncur  = gs1.cgaccur
            ) s111
    ) -- s12
    ,s2 as
    ( select s12.itrnnum
            ,s12.itrnanum
            ,s12.ctrnaccd
            ,s12.ctrncur
            ,s12.mtrnsum
            ,GetSumComiss( s12.itrnnum
                          ,s12.itrnanum
                          ,s12.ctrnAccD
                          ,s12.ctrncur
                          ,s12.iaccotd
                          ,s12.TypeCom
                          ,s12.mtrnsum
                          ,0 ) sumcom
            ,s12.TypeCom
            ,s12.iaccotd
            ,s12.batnum
        from s12
       where exists( select 1
                       from ubrr_data.ubrr_rko_tarif        v
                           ,ubrr_data.ubrr_rko_tarif_otdsum o
                      where v.Parent_IdSmr = BankIdSmr
                        and v.com_type     = s12.TypeCom
                        and v.id           = o.id_com
                        and o.otd          = s12.iaccotd )
    ) -- s2
    select s2.ctrnaccd
          ,s2.ctrncur
          ,s2.TypeCom
          ,sum(case when s2.sumcom = 0 then 0 else s2.mtrnsum end)
          ,sum(sign(s2.sumcom))
          ,sum(s2.sumcom)
          ,s2.iaccotd
          ,s2.batnum
          ,p_Date
          ,1
          ,p_Date
      from s2
     group by s2.ctrnaccd, s2.ctrncur, s2.TypeCom, s2.iaccotd, s2.batnum; -- << 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���
     --<< 25.10.2018 �������� [18-56613] �� "������ ������" (�� ���� �� "��������") ��� ��� � 01.11.18

    l_step:='055'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := sql%rowcount;
    WriteProtocol('��������� �������� �� ������������� ������� ��� ��� ������� ���������� ����� � �� "������ ������" � 01.11.18: ' || iCnt);
    iRes := iRes + iCnt;

    /*
     ������������� ������ ��� ������� ���������� ����� � ������ "������"
    */
    l_step:='060'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    -->> 07.11.2017 ubrr korolkov 17-1071
    insert into ubrr_data.ubrr_sbs_new(cSBSaccd,
                                       cSBScurd,
                                       cSBSTypeCom,
                                       mSBSsumpays,
                                       iSBScountPays,
                                       mSBSsumcom,
                                       iSBSotdnum,
                                       iSBSBatNum,
                                       dSBSDate,
                                       iSBSTypeCom,
                                       dsbsdatereg)
        (select ctrnaccd,
                ctrncur,
                TypeCom,
                /*
                sum(case when sumcom = 0 then 0 else mtrnsum end),
                sum(sign(sumcom)),
                */
                sum(mtrnsum),
                count(1),
                sum(sumcom),
                iaccotd,
                batnum,
                p_Date,
                1,
                p_Date
         from (select ctrnaccd,
                      ctrncur,
                      mtrnsum,
                      GetSumComiss(itrnnum,
                                   itrnanum,
                                   ctrnaccd,
                                   ctrncur,
                                   iaccotd,
                                   TypeCom,
                                   mtrnsum,
                                   0)
                          sumcom,
                      TypeCom,
                      iaccotd,
                      batnum
               from (select itrnnum,
                            itrnanum,
                            ctrnaccd,
                            ctrncur,
                            mtrnsum,
                            case
                                when substr(to_char(itrnbatnum), -2) in ('01', '10', '13')
                                     and -- ������� ��������� � ���������� !
                                     -->> 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                                     ( ( trim( regexp_replace(upper(ctrnpurp), '[[:cntrl:]]') ) like '{VO_____}%!%'
                                         and trim(substr(trim( regexp_replace(ctrnpurp, '[[:cntrl:]]') ),10)) like '!%'
                                       )
                                       or trim( regexp_replace(ctrnpurp, '[[:cntrl:]]') ) like '!%'
                                     )
                                     --<< 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                                   then
                                    case when itrnsop = 4 then 'PES6' else 'PES9' end
                                else
                                    case when itrnsop = 4 then 'PE6' else 'PE9' end
                            end as TypeCom,
                            iaccotd,
                            to_number(to_char(nvl(iOTDbatnum, 70)) || '00') batnum
                     from /*xxi.v_trn_part_current*/ ubrr_trn_old_new_v t, -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                          acc a,
                          otd o
                     where t.ctrnaccd like acc_1
                       and t.ctrncur = 'RUR'
                       and t.dtrntran between d1 and d2
                       and a.caccacc = t.ctrnaccd
                       and a.cacccur = t.ctrncur
                       and a.caccprizn <> '�'
                       and a.iaccotd = o.iotdnum
                       and not (substr(ctrnacca, 1, 3) in ('401', '402', '403', '404')
                            and exists
                                    (select 1
                                     from trn_dept_info
                                     where inum = itrnnum and ianum = itrnanum and ccreatstatus is not null))
                       -->> ubrr 03.12.2016 �������� �.�. 16-2817 ��� �����������: ���������� �������� ��������
                       and not (itrntype = 22
                            and regexp_like(ctrnpurp, '^ *(|! *)0406')
                            and exists
                                    (select 1
                                     from xxi."smr"
                                     where csmrmfo8 = ctrnmfoa))
                       --<< ubrr 03.12.2016 �������� �.�. 16-2817 ��� �����������: ���������� �������� ��������
                       and ctrnmfoa not in (select cfilmfo
                                            from xxi."fil"
                                            where idsmr = BankIdSmr)
                       and t.itrnba2d not in (40813, 40817, 40818, 40820, 42309, 40810, 40811, 40812, 40823, 40824)
                       and ( -- ������� ��������
                            (itrntype in (4, 11, 15, 21, 22, 23)
                         and ((substr(to_char(itrnbatnum), -2) in ('01', '10', '13') and nvl(substr(ctrnpurp, 1, 1), '(') <> '!')
                           or  substr(to_char(itrnbatnum), -2) not in ('01', '10', '13')))
                         or -- ������� ������
                           ( itrntype = 4
                         and substr(to_char(itrnbatnum), -2) in ('01', '10', '13')
                         and substr(ctrnpurp, 1, 1) = '!'))
                       -->> 20.09.2017 ubrr korolkov 15-1436
                       and substr(case
                                      when iTrnType in (5, 50, 53, 52, 55, 17, 41, 42, 43, 44) then nvl(cTrnClient_Acc, cTrnAccC)
                                      when cTrnMfoA is null then nvl(cTrnAccA, cTrnAccC)
                                      else cTrnAccA
                                  end,
                                  1,
                                  5) not in
                               ('60309', '60322')
                       --<< 20.09.2017 ubrr korolkov 15-1436
                       and exists
                               (select 1
                                from gac
                                where cgacacc = ctrnaccd and igaccat = 112 and igacnum in (6, 8, 67, 1018)  -- 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                                  and exists
                                          (select 1
                                           from xxi.au_attach_obg
                                           where cgacacc = caccacc
                                             and cgaccur = cacccur
                                             and trunc(d_create) <= d2
                                             and (c_newdata = '112/6' or c_newdata = '112/8' or c_newdata = '112/67' or c_newdata = '112/1018')))  -- 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                 -->> 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = ctrnaccd and igaccat = 112 and igacnum=97
                            and exists
                                    (select 1
                                     from xxi.au_attach_obg au
                                     where au.caccacc = a.caccacc
                                       and au.cacccur = a.cacccur
                                       and au.i_table = 304
                                       and trunc(d_create) <= d2
                                       and (c_newdata = '112/97' or c_newdata = '112/97')))
                 --<< 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                 -->>23.10.2018 �������� [18-56613] �� "������ ������" (�� ���� �� "��������") ��� ��� � 01.11.18
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = a.cACCacc
                            and cgaccur = a.cACCcur
                            and igaccat = 112
                            and igacnum = 98
                            and exists
                                    (select 1
                                     from xxi.au_attach_obg au
                                     where au.caccacc = a.cACCacc
                                       and au.cacccur = a.cACCcur
                                       and d_create > d1
                                       and d_create < d2
                                       and i_table = 304
                                       and au.c_newdata in ('112/98')))
                 --<<23.10.2018 �������� [18-56613] �� "������ ������" (�� ���� �� "��������") ��� ��� � 01.11.18
                       -->>03.07.2019 �������� [19-61974] ���: ���������� �������� �� �����������
                       and check_exclude_client(t.itrntype, t.ctrnmfoa, t.dtrntran, t.itrnnumanc, t.ctrnacca, t.ctrnpurp, t.ctrnowna) = 0
                       --<<03.07.2019 �������� [19-61974] ���: ���������� �������� �� �����������

                       and not exists
                                   (select 1
                                    from gac
                                    where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 112
                                      and igacnum in (1, 3, 4, 5, 7, 9, 10, 13, 15, 16, 17, 19, 20, 21, 22, 23, 24, 25, 31, 36, 37, 38, 39, 40, 45, 57))
                       and not exists
                               (select 1
                                from gac
                                where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 333 and igacnum = 2)
                       and not exists
                                   (select 1
                                    from xxi.au_attach_obg au
                                    where au.caccacc = a.cACCacc
                                      and au.cacccur = a.cACCcur
                                      and d_create > d1
                                      and d_create < d2
                                      and i_table = 304
                                      and au.c_newdata in ('112/36', '112/37', '112/45'))
                       and not exists
                                   (select 1
                                    from gac
                                    where cgacacc = a.cACCacc
                                      and cgaccur = a.cACCcur
                                      and igaccat = 112
                                      and igacnum in (78, 79, 80, 94
                                      ,99,100,101,102,103 --27.12.2018 �������� [15-43]  ���: ����� ����� ����� � ��������� ������� �� ����� ��������
                                      ,104,105,106 -- ������  �������  3, 6, 12  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                                      )
                                      and exists
                                              (select 1
                                               from xxi.au_attach_obg au
                                               where au.caccacc = a.cACCacc
                                                 and au.cacccur = a.cACCcur
                                                 and i_table = 304
                                                 and trunc(d_create) <= d2
                                                 and au.c_newdata like '112/' || to_char(gac.igacnum)))
                       -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                       and not exists
                                   (select 1
                                     from UBRR_UNIQUE_TARIF_ACC uutc
                                    where uutc.cacc = t.ctrnaccd
                                      and t.dtrncreate between  uutc.dopentarif and  uutc.dcanceltarif
                                      and uutc.idsmr = lc_idsmr
                                      and uutc.status = 'N'
                                      )
                       --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                       ) t1
               where not exists
                             (select 1
                              from ubrr_data.ubrr_sbs_new
                              where idsmr = lc_idsmr
                                and dSBSdate = p_date
                                and cSBSaccd = t1.ctrnaccd
                                and cSBScurd = t1.ctrncur
                                and cSBSTypeCom = t1.TypeCom
                                and iSBStrnnum is not null
                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                             )
                 and exists
                         (select 1
                          from ubrr_data.ubrr_rko_tarif v,
                               ubrr_data.ubrr_rko_tarif_otdsum o
                          where v.Parent_IdSmr = BankIdSmr and v.com_type = t1.TypeCom and v.id = o.id_com and o.otd = t1.iaccotd))
         group by ctrnaccd, ctrncur, TypeCom, iaccotd, batnum);
    --<< 07.11.2017 ubrr korolkov 17-1071
    l_step:='065'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := sql%rowcount;
    WriteProtocol('��������� �������� �� ������������� ������� ��� ������� ���������� ����� � ������ "������": ' || iCnt);
    iRes := iRes + iCnt;

    /*
     ���������������� ������
    */
    l_step:='070'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    insert into ubrr_data.ubrr_sbs_new(cSBSaccd,
                                       cSBScurd,
                                       cSBSTypeCom,
                                       mSBSsumpays,
                                       iSBScountPays,
                                       mSBSsumcom,
                                       iSBSotdnum,
                                       iSBSBatNum,
                                       dSBSDate,
                                       iSBSTypeCom,
                                       dsbsdatereg)
        (select ctrnaccd,
                ctrncur,
                TypeCom,
                /*
                sum(case when sumcom = 0 then 0 else mtrnsum end),
                sum(sign(sumcom)),
                */
                sum(mtrnsum),
                count(1),
                sum(sumcom),
                iaccotd,
                batnum,
                p_Date,
                1,
                p_Date
         from (select itrnnum,
                      itrnanum,
                      ctrnaccd,
                      ctrncur,
                      mtrnsum,
                      GetSumComiss(itrnnum,
                                   itrnanum,
                                   ctrnAccD,
                                   ctrncur,
                                   a.iaccotd,
                                   'PP3',
                                   mtrnsum,
                                   0)
                          sumcom,
                      'PP3' as TypeCom,
                      iaccotd,
                      to_number(to_char(nvl(iOTDbatnum, 70)) || '00') batnum
               from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v t, -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                    acc a,
                    otd o
               where t.ctrnaccd like acc_1
                 and t.ctrncur = 'RUR'
                 and t.dtrntran between d1 and d2
                 and a.caccacc = t.ctrnaccd
                 and a.cacccur = t.ctrncur
                 and a.caccprizn <> '�'
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
                     or  itrnba2c in (40802, 40807, 40817, 40818, 40820)))
                   or  (itrntype in (4, 11, 15, 21, 23)
                    and not (substr(ctrnacca, 1, 3) in ('401', '402', '403', '404')
                         and exists
                                 (select 1
                                  from trn_dept_info
                                  where inum = itrnnum and ianum = itrnanum and ccreatstatus is not null))
                    and nvl(iTRNsop, 0) <> 4
                    and ctrnmfoa in (select cfilmfo
                                     from xxi."fil"
                                     where idsmr = BankIdSmr)
                    and not (itrntype=4 and itrnsop=51 and ctrnpurp like '0450%') )) -->><<--17.09.2019 �������� ����. ����������
                 and iTRNba2d not in (40813, 40817, 40818, 40820, 42309, 40810, 40811, 40812, 40823, 40824)
                 and cACCacc <> '40703810100080000005'
                 and substr(caccacc, 1, 3) not in ('401', '402', '403', '404', '409')
                 and nvl(iTRNsop,0) <> 4  --19.04.2018 ������� �.�. [18-86] ���: �������� �� �������
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = cACCacc and cgaccur = cACCcur and igaccat = 112
                                and igacnum in
                                        (1,
                                         3,
                                         4,
                                         5,
                                         7,
                                         9,
                                         10,
                                         11,
                                         13,
                                         15,
                                         16,
                                         17,
                                         19,
                                         20,
                                         21,
                                         22,
                                         23,
                                         25,
                                         31,
                                         36,
                                         37,
                                         38,
                                         40,
                                         --45,  -->><<--16.10.2018 �������� [18-56489] ���: ������� �� ������ �� �� "��������"
                                         57))
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 333 and igacnum = 2)
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 131
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata like '131%'))
                 -->> 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = ctrnaccd and igaccat = 112 and igacnum=97
                            and exists
                                    (select 1
                                     from xxi.au_attach_obg au
                                     where au.caccacc = a.caccacc
                                       and au.cacccur = a.cacccur
                                       and au.i_table = 304
                                       and trunc(d_create) <= d2
                                       and (c_newdata = '112/97' or c_newdata = '112/97')))
                 --<< 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                 -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                         (select 1
                            from UBRR_UNIQUE_TARIF_ACC uutc,
                                 UBRR_UNIQUE_ACC_COMMS uuac
                           where ctrnaccd = uutc.cacc
                             and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF
                             and lc_idsmr = uutc.idsmr
                             and uutc.status = 'N'
                             and uutc.uuta_id = uuac.uuta_id
                             and uuac.com_type = 'PP3'
                             )
                 --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc
                                and cgaccur = a.cACCcur
                                and igaccat = 112
                                and igacnum in (73, 74)
                                and exists
                                        (select 1
                                         from gac
                                         where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 333 and igacnum = 4)
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata in ('112/73', '112/74'))
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '333/4'))
                 and not exists
                             (select 1
                              from ubrr_data.ubrr_sbs_new
                              where idsmr = a.idsmr
                                and dSBSdate = p_date
                                and cSBSaccd = a.caccacc
                                and cSBScurd = a.cacccur
                                and cSBSTypeCom = 'PP3'
                                and iSBStrnnum is not null
                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                             )
                 and exists
                         (select 1
                          from ubrr_data.ubrr_rko_tarif v,
                               ubrr_data.ubrr_rko_tarif_otdsum o
                          where v.Parent_IdSmr = BankIdSmr and v.com_type = 'PP3' and v.id = o.id_com and o.otd = a.iaccotd))
         group by ctrnaccd, ctrncur, TypeCom, iaccotd, batnum);

    l_step:='075'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := sql%rowcount;
    WriteProtocol('��������� �������� �� ���������������� ������� : ' || iCnt);
    iRes := iRes + iCnt;

    /*
     ����������
     ������� �������
     ����������
    */
    l_step:='080'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    insert into ubrr_data.ubrr_sbs_new(cSBSaccd,
                                       cSBScurd,
                                       cSBSTypeCom,
                                       mSBSsumpays,
                                       iSBScountPays,
                                       mSBSsumcom,
                                       iSBSotdnum,
                                       iSBSBatNum,
                                       dSBSDate,
                                       iSBSTypeCom,
                                       dsbsdatereg)
        (select ctrnaccd,
                ctrncur,
                TypeCom,
                -->> 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
                /*null, -- sum(case when sumcom = 0 then 0 else sumcom end),
                sum(sign(sumcom)),*/
                sum(mtrnsum),
                count(1),
                --<< 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
                sum(sumcom),
                iaccotd,
                batnum,
                p_Date,
                1,
                p_Date
         from (select ctrnaccd,
                      ctrncur,
                      mtrnsum,  -- 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
                      GetSumComiss(null,null,ctrnaccd,ctrncur,iaccotd,'PP3E',mtrnsum, 0) sumcom, --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
                      'PP3E' TypeCom,
                      iaccotd,
                      to_number(to_char(nvl(iotdbatnum, 70)) || '00') batnum
               from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v, -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                    acc a,
                    otd o
               where ctrnaccd like acc_1
                 and ctrncur = 'RUR'
                 and dtrntran between d1 and d2
                 and caccacc = ctrnaccd
                 and cacccur = ctrncur
                 and caccprizn <> '�'
                 and o.iotdnum = a.iaccotd
                 and ((((itrntype in (2, 3, 14) and itrnpriority not in (3, 4) and nvl(iTRNsop, 0) = 4)
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
                     or  itrnba2c in (40802, 40807, 40817, 40818, 40820)))
                   or  (itrntype in (4, 11, 15, 21, 23)
                    and not (substr(ctrnacca, 1, 3) in ('401', '402', '403', '404'))
                    and nvl(iTRNsop, 0) = 4
                    and ctrnmfoa in (select cfilmfo
                                     from xxi."fil"
                                     where idsmr = BankIdSmr)))
                 and itrntype <> 25
                 and (ctrnaccc like '40702%' or ctrnaccc like '40802%')
                 and iTRNba2d not in (40813, 40817, 40818, 40820)
                 and cACCacc <> '40703810100080000005'
                 and substr(caccacc, 1, 3) not in ('401', '402', '403', '404', '409')
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = ctrnaccC and cgaccur = a.cacccur and igaccat = 333 and igacnum = 2)
                 -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and exists
                         (select 1
                          from UBRR_UNIQUE_TARIF_ACC uutc,
                               UBRR_UNIQUE_ACC_COMMS uuac
                          where ctrnaccd = uutc.cacc
                            and dtrncreate between uutc.dopentarif and uutc.dcanceltarif
                            and lc_idsmr = uutc.idsmr
                            and uutc.status = 'N'
                            and uutc.uuta_id = uuac.uuta_id
                            and uuac.daily = 'Y'
                            and uuac.com_type = 'PP3E')
                 --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                             (select 1
                              from ubrr_data.ubrr_sbs_new
                              where idsmr = a.idsmr
                                and dSBSdate = p_date
                                and cSBSaccd = a.caccacc
                                and cSBScurd = a.cacccur
                                and cSBSTypeCom = 'PP3E'
                                and iSBStrnnum is not null
                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                             )
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 112 and igacnum in (78, 79, 80, 94
                              ,99,100,101,102,103 --27.12.2018 �������� [15-43]  ���: ����� ����� ����� � ��������� ������� �� ����� ��������
                              ,104,105,106 -- ������  �������  3, 6, 12  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                              )
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and trunc(d_create) <= d2
                                           and au.c_newdata like '112/' || to_char(gac.igacnum)))
               group by ctrnaccd, ctrncur, iaccotd, iotdbatnum, mtrnsum, GetSumComiss(null,null,ctrnaccd,ctrncur,a.iaccotd,'PP3E',mtrnsum,0) --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
               )
         group by ctrnaccd, ctrncur, TypeCom, iaccotd, batnum);
    
    l_step:='085'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := sql%rowcount;
    WriteProtocol('��������� �������� �� ���������������� ������� (����������) �� ������� ��������: ' || iCnt);
    iRes := iRes + iCnt;

    /*
     ����������
     ������� �������
     �� ������
    */
    l_step:='090'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    insert into ubrr_data.ubrr_sbs_new(cSBSaccd,
                                       cSBScurd,
                                       cSBSTypeCom,
                                       mSBSsumpays,
                                       iSBScountPays,
                                       mSBSsumcom,
                                       iSBSotdnum,
                                       iSBSBatNum,
                                       dSBSDate,
                                       iSBSTypeCom,
                                       dsbsdatereg)
        (select ctrnaccd,
                ctrncur,
                TypeCom,
                -->> 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
                /*null, -- sum(case when sumcom = 0 then 0 else sumcom end),
                sum(sign(sumcom)),*/
                sum(mtrnsum),
                count(1),
                --<< 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
                sum(sumcom),
                iaccotd,
                batnum,
                p_Date,
                1,
                p_Date
         from (select ctrnaccd,
                      ctrncur,
                      mtrnsum,  -- 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
                      GetSumComiss(null,null,ctrnaccd,ctrncur,a.iaccotd,'PP3',mtrnsum,0) sumcom, --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
                      'PP3' TypeCom,
                      iaccotd,
                      to_number(to_char(nvl(iOTDbatnum, 70)) || '00') batnum
               from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v t, -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                    acc a,
                    otd o
               where t.ctrnaccd like acc_1
                 and t.ctrncur = 'RUR'
                 and t.dtrntran between d1 and d2
                 and a.caccacc = t.ctrnaccd
                 and a.cacccur = t.ctrncur
                 and a.caccprizn <> '�'
                 and o.iotdnum = a.iaccotd
                 and ((((itrntype in (2, 3, 14) and itrnpriority not in (3, 4) and nvl(iTRNsop, 0) <> 4)
                     or  (itrntype in (25, 28)
                      and nvl(iTRNsop, 0) not in (5, 7)
                      and itrnpriority not in (3, 4)
                      and nvl(iTRNsop, 0) <> 4  -- 01.06.18 �������� �.�. https://redmine.lan.ubrr.ru/issues/52982
                      and not (itrntype = 25
                           and regexp_like(ctrnpurp, '^ *(|! *)0406')
                           and exists
                                   (select 1
                                    from xxi."smr"
                                    where csmrmfo8 = ctrnmfoa))))
                   and (substr(itrnba2c, 1, 3) in (303, 405, 406, 407, 423, 426)
                     or  itrnba2c in (40802, 40807, 40817, 40818, 40820)))
                   or  (itrntype in (4, 11, 15, 21, 23)
                    and not (substr(ctrnacca, 1, 3) in ('401', '402', '403', '404')
                         and exists
                                 (select 1
                                  from trn_dept_info
                                  where inum = itrnnum and ianum = itrnanum and ccreatstatus is not null))
                    and nvl(iTRNsop, 0) <> 4
                    and ctrnmfoa in (select cfilmfo
                                     from xxi."fil"
                                     where idsmr = ubrr_xxi5.ubrr_util.GetBankIdSmr)
                    and not (itrntype=4 and itrnsop=51 and ctrnpurp like '0450%') )) -->><<--17.09.2019 �������� ����. ����������
                 and iTRNba2d not in (40813, 40817, 40818, 40820, 42309, 40810, 40811, 40812, 40823, 40824)
                 and cACCacc <> '40703810100080000005'
                 and substr(caccacc, 1, 3) not in ('401', '402', '403', '404', '409')
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = ctrnaccC and cgaccur = a.cacccur and igaccat = 333 and igacnum = 2)
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = cACCacc
                                and cgaccur = cACCcur
                                and igaccat = 112
                                and igacnum in (1, 3, 4, 5, 7, 9, 10, 11, 13, 15, 16, 17, 19, 20, 21, 22, 23, 25, 31))
                -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                and exists
                         (select 1
                          from UBRR_UNIQUE_TARIF_ACC uutc,
                               UBRR_UNIQUE_ACC_COMMS uuac
                          where ctrnaccd = uutc.cacc
                            and dtrncreate between uutc.dopentarif and uutc.dcanceltarif
                            and lc_idsmr = uutc.idsmr
                            and uutc.status = 'N'
                            and uutc.uuta_id = uuac.uuta_id
                            and uuac.daily = 'Y'
                            and uuac.com_type = 'PP3')
                 --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                             (select 1
                              from ubrr_data.ubrr_sbs_new
                              where idsmr = a.idsmr
                                and dSBSdate = p_date
                                and cSBSaccd = a.caccacc
                                and cSBScurd = a.cacccur
                                and cSBSTypeCom = 'PP3'
                                and iSBStrnnum is not null
                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                             )
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 112 and igacnum in (78, 79, 80, 94
                              ,99,100,101,102,103 --27.12.2018 �������� [15-43]  ���: ����� ����� ����� � ��������� ������� �� ����� ��������
                              ,104,105,106 -- ������  �������  3, 6, 12  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                              )
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and trunc(d_create) <= d2
                                           and au.c_newdata like '112/' || to_char(gac.igacnum)))
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc
                                and cgaccur = a.cACCcur
                                and igaccat = 112
                                and igacnum in (73, 74)
                                and exists
                                        (select 1
                                         from gac
                                         where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 333 and igacnum = 4)
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata in ('112/73', '112/74'))
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '333/4'))
               group by ctrnaccd, ctrncur, iaccotd, iotdbatnum, mtrnsum, GetSumComiss(null,null,ctrnaccd,ctrncur,a.iaccotd,'PP3',mtrnsum,0) --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
               )
         group by ctrnaccd, ctrncur, TypeCom, iaccotd, batnum);
    
    l_step:='095'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := sql%rowcount;
    WriteProtocol('��������� �������� �� ���������������� ������� �� ������� ��������: ' || iCnt);
    iRes := iRes + iCnt;

-- >> ubrr 06.03.2019 ������� �.�. [18-58177.2] ���. ����������� (������ �������� ��������)
    -- �������� ���� �� 100 ���
    iCnt:=insert_besp_commis( p_Date => p_date
                             ,p_ls   => p_ls
                             ,p_Mess => p_mess );
    iRes := iRes + iCnt;
-- << ubrr 06.03.2019 ������� �.�. [18-58177.2] ���. ����������� (������ �������� ��������)

    commit;

    return iRes;
exception
    when others then
        rollback;
        WriteProtocol('������ ��� ������� �������� �� ��������: (l_step='||l_step||');'|| dbms_utility.format_error_stack || dbms_utility.format_error_backtrace); -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
        p_Mess := '������ ��� ������� �������� �� ��������: (l_step='||');'|| dbms_utility.format_error_stack || dbms_utility.format_error_backtrace; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
        return -1;
end CalcMoneyOrder_Ubrr; -- ubrr 06.03.2019 ������� �.�. [18-58177.2] ���. ����������� (������ �������� ��������)
--<< 07.11.2017 ubrr korolkov 17-1071

  FUNCTION CalcMoneyOrder17_Vuz
   (p_Date in date, -- ���� �������
    p_ls in varchar2 default null, -- ���� ��� ������� ��������
    p_Mess out varchar2
  ) RETURN NUMBER
  IS
    lc_idsmr constant smr.idsmr%type := sys_context ('b21', 'idsmr'); -- 07.11.2017 ubrr korolkov 17-1071
    d1       date := p_Date; -- ��������� ���� � ������ ���������
    acc_1    varchar2(25) := nvl(p_ls,'40___810%');
    d2       date := p_Date + 86399/86400; -- ���� ���������
    iCnt     number;
    iRes     number := 0;
    l_step   varchar2(4):='000';  -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
  BEGIN
    /*
     ���������� �������� ������� �����:
     ����� 17-00 �
     - ������������� ������
    */
    DELETE FROM ubrr_data.ubrr_sbs_new
    WHERE IdSmr = lc_idsmr
      and isbstrnnum is null
      and dSBSDate = p_Date
      and isbstypecom = 2
      and cSBSaccd like acc_1
      and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
      ;
    COMMIT;

    l_step:='010'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    INSERT INTO ubrr_data.ubrr_sbs_new
    (cSBSaccd, cSBScurd, cSBSTypeCom, mSBSsumpays, iSBScountPays, mSBSsumcom, iSBSotdnum, iSBSBatNum, dSBSDate, iSBSTypeCom, dsbsdatereg)
    (select ctrnaccd , ctrncur,
            '017', sum(mtrnsum), count(*), GetSumComiss(NULL,NULL,ctrnAccD, ctrncur, iaccotd, '017', sum(mtrnsum), 0) sumcom,
            iaccotd, batnum, p_Date, 2, p_Date
     from (
        select itrnnum, itrnanum, ctrnaccd , ctrncur, mtrnsum,
               iaccotd, to_number(to_char(NVL(iOTDbatnum,70) )||'00') batnum
        from xxi.V_TRN_PART_CURRENT t, acc a, otd o
        where ctrnaccd like acc_1
        and ctrncur = 'RUR'
        and dtrntran between d1 and d2
        and nvl(iTRNsop,0) = 4
        and (   (    itrntype in (4,11,15,21,22,23)
                 and not (substr(ctrnacca,1,3) in ('401', '402', '403', '404')
                          and exists (select 1
                                      from trn_dept_info
                                      where inum = itrnnum
                                       and ianum = itrnanum
                                       and ccreatstatus is not null))
                )
            )
      and iTRNba2d not in (40813,40817,40818,40820,42309,40810,40811,40812,40823,40824)
      and caccacc = ctrnaccd
      and cacccur = ctrncur
      and cACCprizn <> '�'
      and o.iotdnum = a.iaccotd
      and substr(caccacc,1,3) not in ('401','402','403','404','409')
      and to_char(itrnbatnum) like '__10'
      -->> 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
      and not exists
             (select 1
              from gac
              where cgacacc = ctrnaccd and igaccat = 112 and igacnum=97
                and exists
                        (select 1
                         from xxi.au_attach_obg au
                         where au.caccacc = a.caccacc
                           and au.cacccur = a.cacccur
                           and au.i_table = 304
                           and trunc(d_create) <= d2
                           and (c_newdata = '112/97' or c_newdata = '112/97')))
      --<< 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
      -- >> 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
      and not exists( select 1
                        from gac
                       where cgacacc = ctrnaccd
                         and igaccat = 112
                         and igacnum in (6, 8, 67, 97, 1018)  --26.02.2020 �������� [20-71832] -- 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                         and exists( select 1
                                       from xxi.au_attach_obg au
                                      where au.caccacc = a.caccacc
                                        and au.cacccur = a.cacccur
                                        and au.i_table = 304
                                        and trunc(au.d_create) <= d2
                                        and (   au.c_newdata    = '112/6'
                                             or au.c_newdata    = '112/8'
                                             or au.c_newdata    = '112/67'
                                             or au.c_newdata    = '112/97' --26.02.2020 �������� [20-71832]
                                             or au.c_newdata    = '112/1018'
                                            )
                                   )
                    )
      -- << 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
      and not exists (select 1
                        from gac
                       where cgacacc = cACCacc
                         and cgaccur = cACCcur
                         and igaccat = 131
                         and exists (select 1
                                       from xxi.au_attach_obg au
                                      where au.caccacc = a.cACCacc
                                        and au.cacccur = a.cACCcur
                                        and i_table = 304
                                        and d_create <= d2
                                        and au.c_newdata like '131%'))
      and not exists (select 1
                      from gac
                      where cgacacc = a.caccacc
                      and cgaccur = a.cacccur
                      and (igaccat, igacnum) in ((112, 1014), (333, 2), (112, 10)))
      -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
      and not exists ( select 1
                               from gac g
                                   ,ubrr_rko_exinc_catgr e
                              where g.igaccat   = e.icat
                                and g.igacnum   = e.igrp
                                and e.ccom_type = '017'
                                and e.exinc     = 0
                                and g.cgacacc   = a.caccacc
                                and g.cgaccur   = a.cACCcur
                                and exists (select 1
                                              from xxi.au_attach_obg au
                                             where au.caccacc = a.caccacc
                                               and au.cacccur = a.cacccur
                                               and au.i_table = 304
                                               and trunc(au.d_create) <= d2
                                               and au.c_newdata = e.icat||'/'||e.igrp
                                               and trunc(au.d_create) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end) --<<22.01.2020 �������� [19-64846]
                                           )
                     )
      --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
      -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
      and not exists (select 1
                      from UBRR_UNIQUE_TARIF_ACC uutc
                      where uutc.cacc = t.ctrnaccd
                      and t.dtrncreate between uutc.dopentarif and uutc.dcanceltarif
                      and uutc.idsmr = lc_idsmr
                      and uutc.status = 'N')
      --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
      and not exists (select 1
                      from ubrr_data.ubrr_sbs_new
                      where idsmr = a.idsmr
                      and dSBSdate = p_date
                      and cSBSaccd = a.caccacc
                      and cSBScurd = a.cacccur
                      and cSBSTypeCom = '017'
                      and iSBStrnnum is not null
                      and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                     )
      and exists (select 1
                  from ubrr_data.ubrr_rko_tarif v,
                       ubrr_data.ubrr_rko_tarif_otdsum o
                  where v.Parent_IdSmr = BankIdSmr
                  and v.com_type = '017'  -->><<-- ubrr 23.09.2016 �������� �.�. 16-2222 ���������� �������� ������
                  and v.id = o.id_com
                  and o.otd = a.iaccotd))
    group by ctrnaccd, ctrncur, iaccotd, batnum);

    l_step:='015'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := SQL%ROWCOUNT;
    WriteProtocol('��������� �������� �� ������� ����� 17-00: '||iCnt);
    iRes:=iRes+iCnt;

    /*
      ���������� �������� ������� �����:
      � � 17-00 �
      - ������������� ������
      - ������� �������
    */
    l_step:='020'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    INSERT INTO ubrr_data.ubrr_sbs_new
    (cSBSaccd, cSBScurd, cSBSTypeCom, mSBSsumpays, iSBScountPays, mSBSsumcom, iSBSotdnum, iSBSBatNum, dSBSDate, iSBSTypeCom, dsbsdatereg)
    (select ctrnaccd , ctrncur,
            '017', sum(mtrnsum), count(*), sum(sumcom), iaccotd, batnum, p_Date, 2, p_Date
     from (
        select itrnnum, itrnanum, ctrnaccd , ctrncur, mtrnsum, ubrr_xxi5.UBRR_UNIQ_ACC_SUM(ctrnaccd,ctrncur,iaccotd,d1,'017',mtrnsum,0) sumcom,  -- 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
               iaccotd, to_number(to_char(NVL(iOTDbatnum,70) )||'00') batnum
        from xxi.V_TRN_PART_CURRENT, acc a, otd o
        where ctrnaccd like acc_1
        and ctrncur = 'RUR'
        and dtrntran between d1 and d2
        and nvl(iTRNsop,0) = 4
        and (   (    itrntype in (4,11,15,21,22,23)
                and not (substr(ctrnacca,1,3) in ('401', '402', '403', '404')
                         and exists (select 1
                                       from trn_dept_info
                                     where inum = itrnnum
                                       and ianum = itrnanum
                                       and ccreatstatus is not null))
               )
            )
       and not exists (select 1
                      from gac
                      where cgacacc = a.caccacc
                      and cgaccur = a.cacccur
                      and (igaccat, igacnum) in ((112, 1014), (333, 2), (112, 10)))
       and iTRNba2d not in (40813,40817,40818,40820,42309,40810,40811,40812,40823,40824)
       and caccacc = ctrnaccd
       and cacccur = ctrncur
       and cACCprizn <> '�'
       and o.iotdnum = a.iaccotd
       and substr(caccacc,1,3) not in ('401','402','403','404','409')
       and to_char(itrnbatnum) like '__10'
       -- >> 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
       and not exists( select 1
                         from gac
                        where cgacacc = ctrnaccd
                          and igaccat = 112
                          and igacnum in (6, 8, 67, 97, 1018) --26.02.2020 �������� [20-71832] -- 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                          and exists( select 1
                                        from xxi.au_attach_obg au
                                       where au.caccacc = a.caccacc
                                         and au.cacccur = a.cacccur
                                         and au.i_table = 304
                                         and trunc(au.d_create) <= d2
                                         and (   au.c_newdata    = '112/6'
                                              or au.c_newdata    = '112/8'
                                              or au.c_newdata    = '112/67'
                                              or au.c_newdata    = '112/97' --26.02.2020 �������� [20-71832]
                                              or au.c_newdata    = '112/1018'
                                             )
                                    )
                 )
       -- << 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
      -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
      and not exists ( select 1
                               from gac g
                                   ,ubrr_rko_exinc_catgr e
                              where g.igaccat   = e.icat
                                and g.igacnum   = e.igrp
                                and e.ccom_type = '017'
                                and e.exinc     = 0
                                and g.cgacacc   = a.caccacc
                                and g.cgaccur   = a.cACCcur
                                and exists (select 1
                                              from xxi.au_attach_obg au
                                             where au.caccacc = a.caccacc
                                               and au.cacccur = a.cacccur
                                               and au.i_table = 304
                                               and trunc(au.d_create) <= d2
                                               and au.c_newdata = e.icat||'/'||e.igrp
                                               and trunc(au.d_create) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end) --<<22.01.2020 �������� [19-64846]
                                           )
                     )
      --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
       -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
       and exists (select 1
                     from UBRR_UNIQUE_TARIF_ACC uutc,
                          UBRR_UNIQUE_ACC_COMMS uuac
                    where ctrnaccd = uutc.cacc
                      and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF
                      and uutc.idsmr = lc_idsmr
                      and uutc.status = 'N'
                      and uutc.uuta_id = uuac.uuta_id
                      and uuac.daily = 'Y'
                      and uuac.com_type = '017')
       --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
       and not exists (select 1
                       from ubrr_data.ubrr_sbs_new
                       where idsmr = a.idsmr
                       and dSBSdate = p_date
                       and cSBSaccd = a.caccacc
                       and cSBScurd = a.cacccur
                       and cSBSTypeCom = '017'
                       and iSBStrnnum is not null
                       and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                      )
              )
    group by ctrnaccd,ctrncur,iACCotd, iaccotd, batnum);

    l_step:='030'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := SQL%ROWCOUNT;
    COMMIT;
    WriteProtocol('��������� �������� �� ������� ����� 17-00 �� ������� ��������: '||iCnt);
    iRes:=iRes+iCnt;
    RETURN iRes;
  exception
    WHEN OTHERS THEN
      ROLLBACK;
      WriteProtocol('������ ��� ������� �������� �� �������� ����� 17-00: (l_step='||l_step||')'||SQLErrm);
      p_Mess := '������ ��� ������� �������� �� �������� ����� 17-00: (l_step='||l_step||')'||SQLErrm;
      RETURN -1;
  END;

function CalcMoneyOrder17_Ubrr(p_Date in date, p_ls in varchar2 default null, p_Mess out varchar2)
    return number
is
    lc_idsmr   constant smr.idsmr%type := sys_context('b21', 'idsmr'); -- 07.11.2017 ubrr korolkov 17-1071
    d1                  date := p_Date; -- ��������� ���� � ������ ���������
    acc_1               varchar2(25) := nvl(p_ls, '40___810%');
    d2                  date := p_Date + 86399 / 86400; -- ���� ���������
    iCnt                number;
    iRes                number := 0;
    l_step              varchar2(4):='000';  -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
begin
    delete from ubrr_data.ubrr_sbs_new
     where IdSmr = lc_idsmr
       and isbstrnnum is null
       and dSBSDate = p_Date
       and isbstypecom = 2
       and cSBSaccd like acc_1
       and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
       ;

    commit;

    /*
     ������������� ����� ����� 17-00
    */
    l_step:='010';  -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    insert into ubrr_data.ubrr_sbs_new(cSBSaccd,
                                       cSBScurd,
                                       cSBSTypeCom,
                                       mSBSsumpays,
                                       iSBScountPays,
                                       mSBSsumcom,
                                       iSBSotdnum,
                                       iSBSBatNum,
                                       dSBSDate,
                                       iSBSTypeCom,
                                       dsbsdatereg)
        (select ctrnaccd,
                ctrncur,
                TypeCom,
                /*
                sum(case when sumcom = 0 then 0 else mtrnsum end),
                sum(sign(sumcom)),
                */
                sum(mtrnsum),
                count(1),
                sum(sumcom),
                iaccotd,
                batnum,
                p_Date,
                2,
                p_Date
         from (select itrnnum,
                      itrnanum,
                      ctrnaccd,
                      ctrncur,
                      mtrnsum,
                      GetSumComiss(itrnnum,
                                   itrnanum,
                                   ctrnAccD,
                                   ctrncur,
                                   a.iaccotd,
                                   case when itrnba2d = 42309 then '017_N' else '017' end,
                                   mtrnsum,
                                   0)
                          sumcom,
                      iaccotd,
                      to_number(to_char(nvl(iOTDbatnum, 70)) || '00') batnum,
                      case when itrnba2d = 42309 then '017_N' else '017' end as TypeCom
               from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v t, -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                    acc a,
                    otd o
               where ctrnaccd like acc_1
                 and ctrncur = 'RUR'
                 and dtrntran between d1 and d2
                 and a.caccacc = t.ctrnaccd
                 and a.cacccur = t.ctrncur
                 and a.caccprizn <> '�'
                 and o.iotdnum = a.iaccotd
                 and ((itrntype in (4, 11, 15, 21, 22, 23)
                   and not (substr(ctrnacca, 1, 3) in ('401', '402', '403', '404')
                        and exists
                                (select 1
                                 from trn_dept_info
                                 where inum = itrnnum and ianum = itrnanum and ccreatstatus is not null))))
                 and not (itrntype = 22
                      and regexp_like(ctrnpurp, '^ *(|! *)0406')
                      and exists
                              (select 1
                               from xxi."smr"
                               where csmrmfo8 = ctrnmfoa))
                 and iTRNba2d not in (40813, 40817, 40818, 40820, 42309)
                 and substr(caccacc, 1, 3) not in ('401', '402', '403', '404', '409')
                 and to_char(itrnbatnum) like '__10'
                 -->> 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = ctrnaccd and igaccat = 112 and igacnum=97
                            and exists
                                    (select 1
                                     from xxi.au_attach_obg au
                                     where au.caccacc = a.caccacc
                                       and au.cacccur = a.cacccur
                                       and au.i_table = 304
                                       and trunc(d_create) <= d2
                                       and (c_newdata = '112/97' or c_newdata = '112/97')))
                 --<< 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = cACCacc and cgaccur = cACCcur and igaccat = 112 and igacnum in (6, 8, 67, 1018)  -- 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg
                                         where cgacacc = caccacc
                                           and cgaccur = cacccur
                                           and trunc(d_create) <= d2
                                           and (c_newdata = '112/6' or c_newdata = '112/8' or c_newdata = '112/67' or c_newdata = '112/1018')))  -- 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 114 and igacnum = 10
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '114/10'))
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = a.caccacc and cgaccur = a.cacccur and igaccat = 333 and igacnum = 2)
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = cACCacc and cgaccur = cACCcur and igaccat = 112
                                and igacnum in (1, 3, 4, 5, 7, 9, 10, 13, 15, 16, 17, 19, 20, 21, 22, 23, 24, 25, 36, 37, 38, 39, 40, 57))
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 131
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata like '131%'))
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.caccacc and cgaccur = a.cacccur and igaccat = 112 and igacnum = 70
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata like '112/70'))
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 112 and igacnum in (73, 74)
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '112/' || gac.igacnum)
                                and exists
                                        (select 1
                                         from gac
                                         where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 333 and igacnum = 4)
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '333/4'))
                 and not exists
                             (select 1
                              from xxi.au_attach_obg au
                              where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and d_create >= d1
                                and d_create <= d2
                                and i_table = 304
                                and au.c_newdata in ('112/36', '112/37', '112/38', '112/40'))
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 112 and igacnum = 40
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and au.i_table = 304
                                           and au.d_create <= d2
                                           and add_months(last_day(au.d_create), 11) > d1
                                           and au.c_newdata = '112/40'))
                 and not exists
                             (select 1
                              from     xxi.au_attach_obg au_s
                                   inner join
                                       xxi.au_attach_obg au_e
                                   on au_e.caccacc = au_s.caccacc
                                  and au_e.cacccur = au_s.cacccur
                                  and au_e.i_table = 304
                                  and au_e.c_olddata = '112/40'
                              where au_s.caccacc = a.cACCacc
                                and au_s.cacccur = a.cACCcur
                                and au_s.i_table = 304
                                and au_s.d_create <= d2
                                and au_e.d_create >= d1
                                and add_months(last_day(au_s.d_create), 11) > d1
                                and au_s.c_newdata = '112/40')
                 and not exists
                             (select 1
                              from au_attach_obg a1
                              where caccacc = a.CACCACC
                                and cacccur = a.CACCCUR
                                and c_newdata = '112/72'
                                and d1 between trunc(d_create, 'mm') and last_day(add_months(d_create, 5))
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
                                           and a2.i_table = 304
                                           and a2.c_olddata = '112/72'
                                           and a2.d_create > last_day(add_months(a1.d_create, 5))))
                 and not exists
                             (select 1
                              from au_attach_obg a1
                              where caccacc = a.CACCACC
                                and cacccur = a.CACCCUR
                                and c_newdata = '112/35'
                                and d1 between trunc(d_create, 'mm') and last_day(add_months(d_create, 2))
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
                                           and a2.i_table = 304
                                           and a2.c_olddata = '112/35'
                                           and a2.d_create > last_day(add_months(a1.d_create, 2))))
                 -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                 and not exists ( select 1
                                          from gac g
                                              ,ubrr_rko_exinc_catgr e
                                         where g.igaccat   = e.icat
                                           and g.igacnum   = e.igrp
                                           and e.ccom_type = case when itrnba2d = 42309 then '017_N' else '017' end
                                           and e.exinc     = 0
                                           and g.cgacacc   = a.caccacc
                                           and g.cgaccur   = a.cacccur
                                           and exists (select 1
                                                         from xxi.au_attach_obg au
                                                        where au.caccacc = a.caccacc
                                                          and au.cacccur = a.cacccur
                                                          and au.i_table = 304
                                                          and trunc(au.d_create) <= d2
                                                          and au.c_newdata = e.icat||'/'||e.igrp
                                                          and trunc(au.d_create) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end) --<<22.01.2020 �������� [19-64846]
                                                      )
                                )
                 --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                 -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                         (select 1
                          from UBRR_UNIQUE_TARIF_ACC uutc,
                               UBRR_UNIQUE_ACC_COMMS uuac
                          where ctrnaccd = uutc.cacc and dtrncreate between uutc.dopentarif
                            and uutc.dcanceltarif
                            and uutc.idsmr = lc_idsmr
                            and uutc.status = 'N'
                            and uutc.uuta_id = uuac.uuta_id
                            and uuac.com_type = '017'
                            )
                 --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                             (select 1
                              from ubrr_data.ubrr_sbs_new
                              where idsmr = a.idsmr
                                and dSBSdate = p_date
                                and cSBSaccd = a.caccacc
                                and cSBScurd = a.cacccur
                                and cSBSTypeCom = case when itrnba2d = 42309 then '017_N' else '017' end
                                and iSBStrnnum is not null
                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                             )
                 and exists
                         (select 1
                          from ubrr_data.ubrr_rko_tarif v,
                               ubrr_data.ubrr_rko_tarif_otdsum o
                          where v.Parent_IdSmr = BankIdSmr and v.com_type = case when itrnba2d = 42309 then '017_N' else '017' end
                          and v.id = o.id_com and o.otd = a.iaccotd))
         group by ctrnaccd, ctrncur, typecom, iaccotd, batnum);

    l_step :='015';  -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := sql%rowcount;
    WriteProtocol('��������� �������� �� ������� ����� 17-00: ' || iCnt);
    iRes := iRes + iCnt;

    /*
     ������������� ����� ����� 17-00, 18-00 ��� [ 017_NTK, 018_NTK ]
    */
    l_step :='020';  -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    insert into ubrr_data.ubrr_sbs_new(cSBSaccd,
                                       cSBScurd,
                                       cSBSTypeCom,
                                       mSBSsumpays,
                                       iSBScountPays,
                                       mSBSsumcom,
                                       iSBSotdnum,
                                       iSBSBatNum,
                                       dSBSDate,
                                       iSBSTypeCom,
                                       dsbsdatereg)
    with s1 as -- >> 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���
 (             select itrnnum
                     ,itrnanum
                     ,ctrnaccd
                     ,ctrncur
                     ,mtrnsum
                     ,iaccotd
                     ,to_number(to_char(nvl(iOTDbatnum, 70)) || '00') batnum
                     ,case when substr(itrnbatnum, 3) = '10' then '017_NTK' else '018_NTK' end as TypeCom
               from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v t, -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                    acc a,
                    otd o
               where ctrnaccd like acc_1
                 and ctrncur = 'RUR'
                 and dtrntran between d1 and d2
                 and a.caccacc = t.ctrnaccd
                 and a.cacccur = t.ctrncur
                 and a.caccprizn <> '�'
                 and o.iotdnum = a.iaccotd

                 and ((itrntype in (4, 11, 15, 21, 22, 23)
                   and not (substr(ctrnacca, 1, 3) in ('401', '402', '403', '404')
                        and exists
                                (select 1
                                 from trn_dept_info
                                 where inum = itrnnum and ianum = itrnanum and ccreatstatus is not null))))
                 and not (itrntype = 22
                      and regexp_like(ctrnpurp, '^ *(|! *)0406')
                      and exists
                              (select 1
                               from xxi."smr"
                               where csmrmfo8 = ctrnmfoa))
                 and iTRNba2d not in (40813, 40817, 40818, 40820, 42309, 40810, 40811, 40812, 40823, 40824)
                 and substr(caccacc, 1, 3) not in ('401', '402', '403', '404', '409')
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 114 and igacnum = 10
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '114/10'))
                 and substr(to_char(itrnbatnum), 3) in ('10', '13')
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = a.cACCacc and igaccat = 333 and igacnum = 2)
                 and exists
                         (select 1
                          from gac
                          where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 131
                            and exists
                                    (select 1
                                     from xxi.au_attach_obg au
                                     where au.caccacc = a.cACCacc
                                       and au.cacccur = a.cACCcur
                                       and i_table = 304
                                       and d_create <= d2
                                       and au.c_newdata like '131%'))
                 -->> 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = ctrnaccd and igaccat = 112 and igacnum=97
                            and exists
                                    (select 1
                                     from xxi.au_attach_obg au
                                     where au.caccacc = a.caccacc
                                       and au.cacccur = a.cacccur
                                       and au.i_table = 304
                                       and trunc(d_create) <= d2
                                       and (c_newdata = '112/97' or c_newdata = '112/97')))
                 --<< 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                 -- >> 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
                 and not exists( select 1
                                   from gac
                                  where cgacacc = ctrnaccd
                                    and igaccat = 112
                                    and igacnum = 67 -- 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                                    and exists( select 1
                                                  from xxi.au_attach_obg au
                                                 where au.caccacc = a.caccacc
                                                   and au.cacccur = a.cacccur
                                                   and au.i_table = 304
                                                   and trunc(au.d_create) <= d2
                                                   and au.c_newdata    = '112/67'
                                              )
                               )
                 -- << 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
                 -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                 and not exists ( select 1
                                          from gac g
                                              ,ubrr_rko_exinc_catgr e
                                         where g.igaccat   = e.icat
                                           and g.igacnum   = e.igrp
                                           and e.ccom_type = case when substr(itrnbatnum, 3) = '10' then '017_NTK' else '018_NTK' end
                                           and e.exinc     = 0
                                           and g.cgacacc   = a.caccacc
                                           and g.cgaccur   = a.cACCcur
                                           and exists (select 1
                                                         from xxi.au_attach_obg au
                                                        where au.caccacc = a.caccacc
                                                          and au.cacccur = a.cacccur
                                                          and au.i_table = 304
                                                          and trunc(au.d_create) <= d2
                                                          and au.c_newdata = e.icat||'/'||e.igrp
                                                          and trunc(au.d_create) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end) --<<22.01.2020 �������� [19-64846]
                                                      )
                                )
                 --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                 -->><<--07.06.2019 �������� [19-59153] https://redmine.lan.ubrr.ru/issues/62797#note-9
                 -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                         (select 1
                            from UBRR_UNIQUE_TARIF_ACC uutc,
                                 UBRR_UNIQUE_ACC_COMMS uuac
                           where ctrnaccd = uutc.cacc
                             and dtrncreate between uutc.dopentarif and uutc.dcanceltarif
                             and uutc.idsmr = lc_idsmr
                             and uutc.status = 'N'
                             and uutc.uuta_id = uuac.uuta_id
                             and uuac.com_type in ('017','018')
                             )
                 -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                             (select 1
                              from ubrr_data.ubrr_sbs_new
                              where idsmr = a.idsmr
                                and dSBSdate = p_date
                                and cSBSaccd = a.caccacc
                                and cSBScurd = a.cacccur
                                and cSBSTypeCom = case when substr(itrnbatnum, 3) = '10' then '017_NTK' else '018_NTK' end
                                and iSBStrnnum is not null
                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                             )
 ) -- s1
    ,s12 as -- ������ iaccotd �� ubrr_comm_gacmvz_tarif.cmvz (131 ���)
    ( select s111.itrnnum
            ,s111.itrnanum
            ,s111.ctrnaccd
            ,s111.ctrncur
            ,s111.mtrnsum
            ,s111.TypeCom
            ,( case when s111.cgacacc is not null then s111.cmvz -- 131 ��� �� ����� ����
                    when s111.cgacacc is null then s111.iaccotd -- 131 ��� �� ����� ���
               end
             ) iaccotd
            ,s111.batnum
       from (  select s1.itrnnum
                     ,s1.itrnanum
                     ,s1.ctrnaccd
                     ,s1.ctrncur
                     ,s1.mtrnsum
                     ,s1.TypeCom
                     ,s1.iaccotd
                     ,s1.batnum
                     ,gs1.cgacacc
                     ,gs1.cmvz
                 from s1
                 left join ( select gg.cgacacc  -- ������: ���� 131 ��� ���
                                   ,gg.cgaccur
                                   ,gg.igaccat
                                   ,gg.cmvz
                                   ,gg.idsmr
                               from ( select g.cgacacc
                                            ,g.cgaccur
                                            ,g.igaccat
                                            ,tar.cmvz
                                            ,g.idsmr
                                            ,row_number() over ( partition by g.cgacacc,g.cgaccur,g.idsmr order by null) rn
                                        from gac g
                                        left join ubrr_comm_gacmvz_tarif tar
                                          on g.igaccat = tar.icat
                                         and g.igacnum = tar.inum
                                       where g.igaccat = 131
                                         and g.idsmr   = BankIdSmr
                                    ) gg
                              where gg.rn =1
                           ) gs1
                 on s1.ctrnaccd = gs1.cgacacc
                and s1.ctrncur  = gs1.cgaccur
            ) s111
    ) -- s12
    ,s2 as
    ( select s12.itrnnum
            ,s12.itrnanum
            ,s12.ctrnaccd
            ,s12.ctrncur
            ,s12.mtrnsum
            ,GetSumComiss( s12.itrnnum
                          ,s12.itrnanum
                          ,s12.ctrnAccD
                          ,s12.ctrncur
                          ,s12.iaccotd
                          ,s12.TypeCom
                          ,s12.mtrnsum
                          ,0 ) sumcom
            ,s12.TypeCom
            ,s12.iaccotd
            ,s12.batnum
        from s12
       where exists( select 1
                       from ubrr_data.ubrr_rko_tarif        v
                           ,ubrr_data.ubrr_rko_tarif_otdsum o
                      where v.Parent_IdSmr = BankIdSmr
                        and v.com_type     = s12.TypeCom
                        and v.id           = o.id_com
                        and o.otd          = s12.iaccotd )
    ) -- s2
  select s2.ctrnaccd
        ,s2.ctrncur
        ,s2.TypeCom
        ,sum(s2.mtrnsum)
        ,count(1)
        ,sum(s2.sumcom)
        ,s2.iaccotd
        ,s2.batnum
        ,p_Date
        ,2
        ,p_Date
  from s2
  group by s2.ctrnaccd, s2.ctrncur, s2.typecom, s2.iaccotd, s2.batnum; -- << 24.07.2019 ������� �.�.19-62974 III ���� �����. ��������������� ������� ����� ����� �� ���

    l_step :='025';  -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := sql%rowcount;
    WriteProtocol('��������� �������� �� ������� ����� 17-00, 18-00 ���: ' || iCnt);
    iRes := iRes + iCnt;

    /*
     ������������� ����� ����� 17-00, 18-00, ������� �������
    */
    l_step :='030';  -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    insert into ubrr_data.ubrr_sbs_new(cSBSaccd,
                                       cSBScurd,
                                       cSBSTypeCom,
                                       mSBSsumpays,
                                       iSBScountPays,
                                       mSBSsumcom,
                                       iSBSotdnum,
                                       iSBSBatNum,
                                       dSBSDate,
                                       iSBSTypeCom,
                                       dsbsdatereg)
        (select ctrnaccd,
                ctrncur,
                TypeCom,
                sum(mtrnsum),
                count(*),
                sum(sumcom),
                iaccotd,
                batnum,
                p_Date,
                2,
                p_Date
         from (select itrnnum,
                      itrnanum,
                      ctrnaccd,
                      ctrncur,
                      mtrnsum,
                      GetSumComiss(null,null,ctrnaccd,ctrncur,iaccotd,TypeCom,mtrnsum,0) sumcom, --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
                      iaccotd,
                      batnum,
                      TypeCom
               from (select itrnnum,
                            itrnanum,
                            ctrnaccd,
                            ctrncur,
                            mtrnsum,
                            iaccotd,
                            to_number(to_char(nvl(iOTDbatnum, 70)) || '00') batnum,
                            case when to_char(itrnbatnum) like '__13' then '018' else '017' end TypeCom/*,
                            case when to_char(itrnbatnum) like '__13' then 'COMINBNKAF18' else 'COMINBNKAF17' end ColumnCom*/ -- 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                     from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v t, -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                          acc a,
                          otd o
                     where ctrnaccd like acc_1
                       and ctrncur = 'RUR'
                       and dtrntran between d1 and d2
                       and a.caccacc = t.ctrnaccd
                       and a.cacccur = t.ctrncur
                       and a.caccprizn <> '�'
                       and o.iotdnum = a.iaccotd
                       and ((itrntype in (4, 11, 15, 21, 22, 23)
                         and not (substr(ctrnacca, 1, 3) in ('401', '402', '403', '404')
                              and exists
                                      (select 1
                                       from trn_dept_info
                                       where inum = itrnnum and ianum = itrnanum and ccreatstatus is not null))))
                       and not (itrntype = 22
                            and regexp_like(ctrnpurp, '^ *(|! *)0406')
                            and exists
                                    (select 1
                                     from xxi."smr"
                                     where csmrmfo8 = ctrnmfoa))
                       and iTRNba2d not in (40813, 40817, 40818, 40820, 42309)
                       and substr(caccacc, 1, 3) not in ('401', '402', '403', '404', '409')
                       and (to_char(itrnbatnum) like '__10' or to_char(itrnbatnum) like '__13')
                       -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                       and exists
                               (select 1
                                 from UBRR_UNIQUE_TARIF_ACC uutc,
                                      UBRR_UNIQUE_ACC_COMMS uuac
                                where ctrnaccd = uutc.cacc
                                  and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF
                                  and uutc.idsmr = lc_idsmr
                                  and uutc.status = 'N'
                                  and uutc.uuta_id = uuac.uuta_id
                                  and uuac.daily = 'Y'
                                  and uuac.com_type = case when to_char(itrnbatnum) like '__13' then '018' else '017' end
                                  )
                       --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                       -->> 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                       and not exists
                               (select 1
                                from gac
                                where cgacacc = ctrnaccd and igaccat = 112 and igacnum=97
                                  and exists
                                          (select 1
                                           from xxi.au_attach_obg au
                                           where au.caccacc = a.caccacc
                                             and au.cacccur = a.cacccur
                                             and au.i_table = 304
                                             and trunc(d_create) <= d2
                                             and (c_newdata = '112/97' or c_newdata = '112/97')))
                       --<< 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                       -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                       and not exists ( select 1
                                                from gac g
                                                    ,ubrr_rko_exinc_catgr e
                                               where g.igaccat   = e.icat
                                                 and g.igacnum   = e.igrp
                                                 and e.ccom_type = case when to_char(itrnbatnum) like '__13' then '018' else '017' end
                                                 and e.exinc     = 0
                                                 and g.cgacacc   = a.caccacc
                                                 and g.cgaccur   = a.cACCcur
                                                 and exists (select 1
                                                               from xxi.au_attach_obg au
                                                              where au.caccacc = a.caccacc
                                                                and au.cacccur = a.cacccur
                                                                and au.i_table = 304
                                                                and trunc(au.d_create) <= d2
                                                                and au.c_newdata = e.icat||'/'||e.igrp
                                                                and trunc(au.d_create) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end) --<<22.01.2020 �������� [19-64846]
                                                            )
                                      )
                       --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                       and not exists
                                   (select 1
                                    from ubrr_data.ubrr_sbs_new
                                    where idsmr = a.idsmr
                                      and dSBSdate = p_date
                                      and cSBSaccd = a.caccacc
                                      and cSBScurd = a.cacccur
                                      and cSBSTypeCom = case when to_char(itrnbatnum) like '__13' then '018' else '017' end
                                      and iSBStrnnum is not null
                                      and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                                   )
                          ))
         group by ctrnaccd, ctrncur, TypeCom, iACCotd, iaccotd,
                  batnum);
    
    l_step :='035';  -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := sql%rowcount;
    WriteProtocol('��������� �������� �� ������� ����� 17-00, 18-00 �� ������� ��������: ' || iCnt);
    iRes := iRes + iCnt;

    /*
     ������������� ����� ����� 18-00
    */
    l_step :='040';  -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    insert into ubrr_data.ubrr_sbs_new(cSBSaccd,
                                       cSBScurd,
                                       cSBSTypeCom,
                                       mSBSsumpays,
                                       iSBScountPays,
                                       mSBSsumcom,
                                       iSBSotdnum,
                                       iSBSBatNum,
                                       dSBSDate,
                                       iSBSTypeCom,
                                       dsbsdatereg)
        (select ctrnaccd,
                ctrncur,
                TypeCom,
                /*
                sum(case when sumcom = 0 then 0 else mtrnsum end),
                sum(sign(sumcom)),
                */
                sum(mtrnsum),
                count(1),
                sum(sumcom),
                iaccotd,
                batnum,
                p_Date,
                2,
                p_Date
         from (select itrnnum,
                      itrnanum,
                      ctrnaccd,
                      ctrncur,
                      mtrnsum,
                      iaccotd,
                      to_number(to_char(nvl(iOTDbatnum, 70)) || '00') batnum,
                      GetSumComiss(itrnnum,
                                   itrnanum,
                                   ctrnAccD,
                                   ctrncur,
                                   a.iaccotd,
                                   case when itrnba2d = 42309 then '018_N' else '018' end,
                                   mtrnsum,
                                   0)
                          sumcom,
                      case when itrnba2d = 42309 then '018_N' else '018' end as TypeCom
               from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v t, -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                    acc a,
                    otd o
               where ctrnaccd like acc_1
                 and ctrncur = 'RUR'
                 and dtrntran between d1 and d2
                 and a.caccacc = t.ctrnaccd
                 and a.cacccur = t.ctrncur
                 and a.caccprizn <> '�'
                 and o.iotdnum = a.iaccotd
                 and ((itrntype in (4, 11, 15, 21, 22, 23)
                   and not (substr(ctrnacca, 1, 3) in ('401', '402', '403', '404')
                        and exists
                                (select 1
                                 from trn_dept_info
                                 where inum = itrnnum and ianum = itrnanum and ccreatstatus is not null))))
                 and not (itrntype = 22
                      and regexp_like(ctrnpurp, '^ *(|! *)0406')
                      and exists
                              (select 1
                               from xxi."smr"
                               where csmrmfo8 = ctrnmfoa))
                 and iTRNba2d not in (40813, 40817, 40818, 40820, 42309)
                 and substr(caccacc, 1, 3) not in ('401', '402', '403', '404', '409')
                 and to_char(itrnbatnum) like '__13'
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = cACCacc and cgaccur = cACCcur and igaccat = 112 and igacnum in (9, 57))
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 333 and igacnum = 2)
               -->> 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                     and not exists
                             (select 1
                              from gac
                              where cgacacc = ctrnaccd and igaccat = 112 and igacnum=97
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.caccacc
                                           and au.cacccur = a.cacccur
                                           and au.i_table = 304
                                           and trunc(d_create) <= d2
                                           and (c_newdata = '112/97' or c_newdata = '112/97')))
                 --<< 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc
                                and cgaccur = a.cACCcur
                                and igaccat = 112
                                and igacnum = 73
                                and exists
                                        (select 1
                                         from gac
                                         where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 333 and igacnum = 4)
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '112/73')
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '333/4'))
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc
                                and cgaccur = a.cACCcur
                                and igaccat = 112
                                and igacnum = 74
                                and exists
                                        (select 1
                                         from gac
                                         where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 333 and igacnum = 4)
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '112/74')
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '333/4'))
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 131
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata like '131%'))
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 112 and igacnum in (6, 8, 67, 1018)  -- 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc  = gac.cgacacc/*a.caccacc */ -->><<-- 18.04.2019 ������ �.�. [17-1790] ����� ����������: ����������� ������� ���������� �������� ��� ������� �� 24:00
                                           and au.cacccur  = gac.cgaccur/*a.cacccur*/ -->><<-- 18.04.2019 ������ �.�. [17-1790] ����� ����������: ����������� ������� ���������� �������� ��� ������� �� 24:00
                                           and trunc(d_create) <= d2
                                           and (c_newdata = '112/6' or c_newdata = '112/8' or c_newdata = '112/67' or c_newdata = '112/1018')))  -- 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = cACCacc and cgaccur = cACCcur and igaccat = 112 and igacnum = 70
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = gac.CGACACC
                                           and au.cacccur = gac.CGACCUR
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata like '112/70'))
                 -->><<--07.06.2019 �������� [19-59153] https://redmine.lan.ubrr.ru/issues/62797#note-9
                 -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                 and not exists ( select 1
                                          from gac g
                                              ,ubrr_rko_exinc_catgr e
                                         where g.igaccat   = e.icat
                                           and g.igacnum   = e.igrp
                                           and e.ccom_type = case when itrnba2d = 42309 then '018_N' else '018' end
                                           and e.exinc     = 0
                                           and g.cgacacc   = a.caccacc
                                           and g.cgaccur   = a.cACCcur
                                           and exists (select 1
                                                         from xxi.au_attach_obg au
                                                        where au.caccacc = a.caccacc
                                                          and au.cacccur = a.cacccur
                                                          and au.i_table = 304
                                                          and trunc(au.d_create) <= d2
                                                          and au.c_newdata = e.icat||'/'||e.igrp
                                                          and trunc(au.d_create) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end) --<<22.01.2020 �������� [19-64846]
                                                      )
                                )
                 --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                 -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                         (select 1
                            from UBRR_UNIQUE_TARIF_ACC uutc,
                                 UBRR_UNIQUE_ACC_COMMS uuac
                           where ctrnaccd = uutc.cacc
                           and dtrncreate between uutc.dopentarif and uutc.dcanceltarif
                           and uutc.idsmr = lc_idsmr
                           and uutc.status = 'N'
                           and uutc.uuta_id = uuac.uuta_id
                           and uuac.com_type = '018'
                           )
                 --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                             (select 1
                              from ubrr_data.ubrr_sbs_new
                              where idsmr = a.idsmr
                                and dSBSdate = p_date
                                and cSBSaccd = a.caccacc
                                and cSBScurd = a.cacccur
                                and cSBSTypeCom = case when itrnba2d = 42309 then '018_N' else '018' end
                                and iSBStrnnum is not null
                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                             )
                 and exists
                         (select 1
                          from ubrr_data.ubrr_rko_tarif v,
                               ubrr_data.ubrr_rko_tarif_otdsum o
                          where v.Parent_IdSmr = BankIdSmr and v.com_type = case when itrnba2d = 42309 then '018_N' else '018' end
                          and v.id = o.id_com and o.otd = a.iaccotd))
         group by ctrnaccd, ctrncur, TypeCom, iaccotd, batnum);

    l_step :='045';  -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := sql%rowcount;
    WriteProtocol('��������� �������� �� ������� ����� 18-00: ' || iCnt);
    iRes := iRes + iCnt;

    /*
     ������������� ����� ����� 18-00 ��� ���/�� 114/10
    */
    l_step :='050';  -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    insert into ubrr_data.ubrr_sbs_new(cSBSaccd,
                                       cSBScurd,
                                       cSBSTypeCom,
                                       mSBSsumpays,
                                       iSBScountPays,
                                       mSBSsumcom,
                                       iSBSotdnum,
                                       iSBSBatNum,
                                       dSBSDate,
                                       iSBSTypeCom,
                                       dsbsdatereg)
        (select ctrnaccd,
                ctrncur,
                TypeCom,
                /*
                sum(case when sumcom = 0 then 0 else mtrnsum end),
                sum(sign(sumcom)),
                */
                sum(mtrnsum),
                count(1),
                sum(sumcom),
                iaccotd,
                batnum,
                p_Date,
                2,
                p_Date
         from (select itrnnum,
                      itrnanum,
                      ctrnaccd,
                      ctrncur,
                      mtrnsum,
                      iaccotd,
                      to_number(to_char(nvl(iOTDbatnum, 70)) || '00') batnum,
                      GetSumComiss(itrnnum,
                                   itrnanum,
                                   ctrnAccD,
                                   ctrncur,
                                   a.iaccotd,
                                   decode(substr(to_char(itrnbatnum), 3), '10', '017', '018'),
                                   mtrnsum,
                                   0)
                          sumcom,
                      decode(substr(to_char(itrnbatnum), 3), '10', '017', '018') as TypeCom
               from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v t, -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                    acc a,
                    otd o
               where ctrnaccd like acc_1
                 and ctrncur = 'RUR'
                 and dtrntran between d1 and d2
                 and a.caccacc = t.ctrnaccd
                 and a.cacccur = t.ctrncur
                 and a.caccprizn <> '�'
                 and o.iotdnum = a.iaccotd

                 and ((itrntype in (4, 11, 15, 21, 22, 23)
                   and not (substr(ctrnacca, 1, 3) in ('401', '402', '403', '404')
                        and exists
                                (select 1
                                 from trn_dept_info
                                 where inum = itrnnum and ianum = itrnanum and ccreatstatus is not null))))
                 and not (itrntype = 22
                      and regexp_like(ctrnpurp, '^ *(|! *)0406')
                      and exists
                              (select 1
                               from xxi."smr"
                               where csmrmfo8 = ctrnmfoa))
                 and iTRNba2d not in (40813, 40817, 40818, 40820, 42309, 40810, 40811, 40812, 40823, 40824)
                 and substr(caccacc, 1, 3) not in ('401', '402', '403', '404', '409')
                 and substr(to_char(itrnbatnum), 3) in ('10', '13')
                 and not exists
                         (select 1
                          from gac
                          where cgacacc = a.cACCacc and igaccat = 333 and igacnum = 2)
                 and exists
                         (select 1
                          from gac
                          where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 114 and igacnum = 10
                            and exists
                                    (select 1
                                     from xxi.au_attach_obg au
                                     where au.caccacc = a.cACCacc
                                       and au.cacccur = a.cACCcur
                                       and i_table = 304
                                       and d_create <= d2
                                       and au.c_newdata = '114/10'))
               -->> 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                     and not exists
                             (select 1
                              from gac
                              where cgacacc = ctrnaccd and igaccat = 112 and igacnum=97
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.caccacc
                                           and au.cacccur = a.cacccur
                                           and au.i_table = 304
                                           and trunc(d_create) <= d2
                                           and (c_newdata = '112/97' or c_newdata = '112/97')))
                 --<< 26.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 112
                                and igacnum in
                                        (94,
                                         78,
                                         79,
                                         80,
                                         45,
                                         67,
                                         70,
                                         31,
                                         86,
                                         87,
                                         88,
                                         89,
                                         90,
                                         62,
                                         63,
                                         64,
                                         65,
                                         66,
                                         81,
                                         82,
                                         83,
                                         84,
                                         85
                                         -->>07.06.2019 �������� [19-59153] https://redmine.lan.ubrr.ru/issues/62797#note-9
                                         --99,100,101,102,103 --27.12.2018 �������� [15-43]  ���: ����� ����� ����� � ��������� ������� �� ����� ��������
                                         --,104,105,106 -- ������  �������  3, 6, 12  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                                         --<<07.06.2019 �������� [19-59153] https://redmine.lan.ubrr.ru/issues/62797#note-9
                                         )
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and trunc(d_create) <= d2
                                           and au.c_newdata like '112/' || to_char(gac.igacnum)))
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc
                                and cgaccur = a.cACCcur
                                and igaccat = 112
                                and igacnum = 73
                                and exists
                                        (select 1
                                         from gac
                                         where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 333 and igacnum = 4)
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '112/73')
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '333/4'))
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = a.cACCacc
                                and cgaccur = a.cACCcur
                                and igaccat = 112
                                and igacnum = 74
                                and exists
                                        (select 1
                                         from gac
                                         where cgacacc = a.cACCacc and cgaccur = a.cACCcur and igaccat = 333 and igacnum = 4)
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '112/74')
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg au
                                         where au.caccacc = a.cACCacc
                                           and au.cacccur = a.cACCcur
                                           and i_table = 304
                                           and d_create <= d2
                                           and au.c_newdata = '333/4'))
                 and not exists
                             (select 1
                              from xxi.au_attach_obg au
                              where au.caccacc = a.cACCacc
                                and au.cacccur = a.cACCcur
                                and i_table = 304
                                and au.c_newdata in ('112/36', '112/37', '112/38', '112/40', '112/45')
                                and d_create <= d2
                                and d_create >= d1)
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = cACCacc and cgaccur = cACCcur and igaccat = 112 and igacnum in (6, 8, 67, 1018)  -- 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                                and exists
                                        (select 1
                                         from xxi.au_attach_obg
                                         where cgacacc = caccacc
                                           and cgaccur = cacccur
                                           and trunc(d_create) <= d2
                                           and (c_newdata = '112/6' or c_newdata = '112/8' or c_newdata = '112/67' or c_newdata = '112/1018')))  -- 07.02.2019 ������� �.�. [18-58411] ���: �� "�����" � ������ "������"
                 and not exists
                             (select 1
                              from gac
                              where cgacacc = cACCacc and cgaccur = cACCcur and igaccat = 112
                                and igacnum in
                                        (1,
                                         3,
                                         4,
                                         5,
                                         7,
                                         10,
                                         13,
                                         15,
                                         16,
                                         17,
                                         19,
                                         20,
                                         21,
                                         22,
                                         23,
                                         24,
                                         25,
                                         36,
                                         37,
                                         38,
                                         39,
                                         40,
                                         50,
                                         57))
                 and not exists
                             (select 1
                              from au_attach_obg a1
                              where caccacc = a.CACCACC
                                and cacccur = a.CACCCUR
                                and c_newdata = '112/35'
                                and d1 between trunc(d_create, 'mm') and last_day(add_months(d_create, 2))
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
                                           and a2.i_table = 304
                                           and a2.c_olddata = '112/35'
                                           and a2.d_create > last_day(add_months(a1.d_create, 2))))
                 and not exists
                             (select 1
                              from au_attach_obg a1
                              where caccacc = a.CACCACC
                                and cacccur = a.CACCCUR
                                and c_newdata = '112/93'
                                and d1 between trunc(d_create, 'mm') and last_day(add_months(d_create, 2))
                                and exists
                                        (select 1
                                         from gac
                                         where cgacacc = a1.caccacc
                                           and gac.CGACCUR = a1.cacccur
                                           and igaccat = 112
                                           and igacnum = 93
                                         union
                                         select 1
                                         from au_attach_obg a2
                                         where a2.caccacc = a1.caccacc
                                           and a2.cacccur = a1.cacccur
                                           and a2.i_table = 304
                                           and a2.c_olddata = '112/93'
                                           and a2.d_create > last_day(add_months(a1.d_create, 2))))
                 and not exists
                             (select 1
                              from au_attach_obg a1
                              where caccacc = a.CACCACC
                                and cacccur = a.CACCCUR
                                and c_newdata = '112/72'
                                and d1 between trunc(d_create, 'mm') and last_day(add_months(d_create, 5))
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
                                           and a2.i_table = 304
                                           and a2.c_olddata = '112/72'
                                           and a2.d_create > last_day(add_months(a1.d_create, 5))))
                 -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                 and not exists ( select 1
                                          from gac g
                                              ,ubrr_rko_exinc_catgr e
                                         where g.igaccat   = e.icat
                                           and g.igacnum   = e.igrp
                                           and e.ccom_type = decode(substr(to_char(itrnbatnum), 3), '10', '017', '018')
                                           and e.exinc     = 0
                                           and g.cgacacc   = a.caccacc
                                           and g.cgaccur   = a.cACCcur
                                           and exists (select 1
                                                         from xxi.au_attach_obg au
                                                        where au.caccacc = a.caccacc
                                                          and au.cacccur = a.cacccur
                                                          and au.i_table = 304
                                                          and trunc(au.d_create) <= d2
                                                          and au.c_newdata = e.icat||'/'||e.igrp
                                                          and trunc(au.d_create) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end) --<<22.01.2020 �������� [19-64846]
                                                      )
                                )
      --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                 -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                         (select 1
                            from UBRR_UNIQUE_TARIF_ACC uutc,
                                 UBRR_UNIQUE_ACC_COMMS uuac
                           where ctrnaccd = uutc.cacc
                             and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF
                             and uutc.idsmr = lc_idsmr
                             and uutc.status = 'N'
                             and uutc.uuta_id = uuac.uuta_id
                             and uuac.com_type = '018'
                             )
                 --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                 and not exists
                             (select 1
                              from ubrr_data.ubrr_sbs_new
                              where idsmr = a.idsmr
                                and dSBSdate = p_date
                                and cSBSaccd = a.caccacc
                                and cSBScurd = a.cacccur
                                and cSBSTypeCom = '017'
                                and iSBStrnnum is not null
                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                             )
                 and exists
                         (select 1
                          from ubrr_data.ubrr_rko_tarif v,
                               ubrr_data.ubrr_rko_tarif_otdsum o
                          where v.Parent_IdSmr = BankIdSmr and v.com_type = '017' and v.id = o.id_com and o.otd = a.iaccotd))
         group by ctrnaccd, ctrncur, iaccotd, batnum, TypeCom);

    l_step :='060';  -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    iCnt := sql%rowcount;
    WriteProtocol('��������� �������� �� ������� (114/10) ����� 18-00: ' || iCnt);
    iRes := iRes + iCnt;

    commit;

    return iRes;
exception
    when others then
        rollback;
        WriteProtocol('������ ��� ������� �������� �� �������� ����� 17-00: (l_step='||l_step||')'|| sqlerrm);
        p_Mess := '������ ��� ������� �������� �� �������� ����� 17-00: (l_step='||l_step||')'|| sqlerrm;
        return -1;
end;

  FUNCTION CalcMoneyOrderULFL
   (p_Date in date, -- ���� �������
    p_ls in varchar2 default null, -- ���� ��� ������� ��������
    p_Mess out varchar2)
  RETURN number
  IS
    d1       date := p_Date; -- ��������� ���� � ������ ���������
    acc_1    varchar2(25) := nvl(p_ls,'40___810%');
    d2       date := p_Date + 86399/86400; -- ���� ���������
    iCnt     number;
  BEGIN
    DELETE FROM ubrr_data.ubrr_sbs_new
    WHERE IdSmr = SYS_CONTEXT('B21','IdSmr')
      and isbstrnnum is null
      and dSBSDate = p_Date
      and isbstypecom = 3
      and cSBSaccd like acc_1
      and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
      ;
    COMMIT;

    INSERT INTO ubrr_data.ubrr_sbs_new
      (cSBSaccd, cSBScurd, cSBSTypeCom, mSBSsumpays, iSBScountPays, mSBSsumcom, iSBSotdnum, iSBSBatNum, dSBSDate, iSBSTypeCom, dsbsdatereg, MSBSSUMBEFO)-->><<--23.10.2017  ����� �.�. 17-1225
      ( ------------------ ������������� �� ��  -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
       select ctrnaccd , ctrncur,
              TypeCom, sum(mtrnsum), count(*), GetSumComiss(NULL, NULL, ctrnAccD, ctrncur, iaccotd, typecom, sum(mtrnsum), max(SumBefo)) sumcom,-->><<--23.10.2017  ����� �.�. 17-1225
              iaccotd, 5407, p_Date, 3, p_Date, max(SumBefo)-->><<--23.10.2017  ����� �.�. 17-1225
       from (
        select itrnnum, itrnanum, ctrnaccd , ctrncur, mtrnsum,
              'UL_FL' TypeCom, iaccotd
              -->>23.10.2017  ����� �.�.      17-1225 https://redmine.lan.ubrr.ru/issues/47017#note-47.
              , nvl((select sum(mtrnsum) from V_TRN_PART_CURRENT xm
                              where xm.ctrnaccd = trn.ctrnaccd
                                and xm.ctrncur=trn.ctrncur
                                and xm.dtrntran between trunc(d1, 'MM') and d1 -1/86400
                                and xm.ctrnmfoa  not in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr) --! �� ���� ������� -> ������� �������
                                and ( --!  ���� ����������, ���������� �� ���� ����� ���������� ��������� ������������� ������ 40817%,40820% ,423%,426%
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
                                and lower(xm.CTRNPURP) not like '%��������%'
                                and lower(xm.CTRNPURP) not like '%������%'
                                and lower(xm.CTRNPURP) not like '%�������%'
                                and lower(xm.CTRNPURP) not like '%�/�%'
                                and lower(xm.CTRNPURP) not like '%���%��%'
                                and lower(xm.CTRNPURP) not like '%�����%'
                                and lower(xm.CTRNPURP) not like '%�����������%'
                                and lower(xm.CTRNPURP) not like '%�����%'
                                and lower(xm.CTRNPURP) not like '%�����%'
                                and lower(xm.CTRNPURP) not like '%������%'
                                and lower(xm.CTRNPURP) not like '%�����%'
                                and lower(xm.CTRNPURP) not like '%�������%'
                                and lower(xm.CTRNPURP) not like '%�������%'
                                and lower(xm.CTRNPURP) not like '%���������%'
                                and lower(xm.CTRNPURP) not like '%����%'
                                and lower(xm.CTRNPURP) not like '%��������%'
                                and lower(xm.CTRNPURP) not like '%�������%'
                                and lower(xm.CTRNPURP) not like '%����%'
                                and lower(xm.CTRNPURP) not like '%�����%'
                                and lower(xm.CTRNPURP) not like '%��������%'
                                and lower(xm.CTRNPURP) not like '%���%����%'
                                and lower(xm.CTRNPURP) not like '%�����%���%'
                                and lower(xm.CTRNPURP) not like '%���%�����%'
                                and lower(xm.CTRNPURP) not like '%������%'
                                and lower(xm.CTRNPURP) not like '%�������%'
                                and lower(xm.CTRNPURP) not like '%������������%'
                                and lower(xm.CTRNPURP) not like '%������%'
                                and nvl(regexp_count(lower(xm.CTRNPURP),'����'),0) = nvl(regexp_count(lower(xm.CTRNPURP),'���������'),0) -- 19.09.2018 ubrr rizanov [18-251] ���: ����� ���������� �� �������� �� ������� � ������ �� ("���������")
                                and lower(xm.CTRNPURP) not like '%������%'
                                and lower(xm.CTRNPURP) not like '%������%'
                                and lower(xm.CTRNPURP) not like '%����������%'
                                and lower(xm.CTRNPURP) not like '%������%'
                                and lower(xm.CTRNPURP) not like '%��������%����%'
                                and lower(xm.CTRNPURP) not like '%�����������%'
                                and lower(xm.CTRNPURP) not like '%���%������%'
                                and lower(xm.CTRNPURP) not like '%��%'
                                and lower(xm.CTRNPURP) not like '%��������%'
                                and lower(xm.CTRNPURP) not like '%�������%'
                                and lower(replace(xm.CTRNPURP,' ')) not like '%�/����%'
                                and lower(replace(xm.CTRNPURP,' ')) not like '%�\����%'
                                and lower(xm.CTRNPURP) not like '%�����%��%'
                                and lower(xm.CTRNPURP) not like '%�����������%��%'
                                and lower(xm.CTRNPURP) not like '%������%'
                                and lower(xm.CTRNPURP) not like '%����%'
                                -- >> ubrr 23.03.2020  ������� �.�.  [20-73286] ���������� ���� ���������� � �������� � ������ ��
                                and lower(xm.CTRNPURP) not like '%�����%���%'
                                and lower(xm.CTRNPURP) not like '%�����%�����%'
                                and lower(xm.CTRNPURP) not like '%�����%��������%'
                                -- << ubrr 23.03.2020  ������� �.�.  [20-73286] ���������� ���� ���������� � �������� � ������ ��
                                and lower(replace(xm.CTRNPURP,' ')) not like '%�.��%'
                                and lower(replace(xm.CTRNPURP,' ')) not like '%�\�%'
                                and lower(replace(xm.CTRNPURP,' ')) not like '%����%����%'
                                and lower(replace(xm.CTRNPURP,' ')) not like '%�������%������%'
                                and not exists --���� ����������� �������� ����, ��������, �������� ����� ��������, ������ �� ��������.
                                         (select 1
                                          from ubrr_ulfl_tab_acc_coms c
                                          where c.DCOMDATERAS = d1
                                          and c.ICOMTRNNUM IS NOT NULL
                                          and c.ccomaccd = xm.CTRNACCD)
                                          -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                                          and not exists
                                                    (select 1
                                                     from UBRR_UNIQUE_TARIF_ACC uutc
                                                     where a.caccacc = uutc.cacc
                                                     and xm.dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF
                                                     and SYS_CONTEXT ('B21', 'IDSmr') = uutc.idsmr
                                                     and uutc.status = 'N')
                                          --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                             ),0)
               SumBefo
             --<< 23.10.2017  ����� �.�. 17-1225 https://redmine.lan.ubrr.ru/issues/47017#note-47.
        from xxi.V_TRN_PART_CURRENT trn, acc a, otd o
        where cTRNcur = 'RUR'
        and cACCacc = cTRNaccd
        and cTRNaccd like acc_1
        and cACCacc like acc_1
        and cACCprizn <> '�'
        and o.iotdnum = a.iaccotd
        and dtrntran between d1 and d2
        and ((trn.CTRNACCD like '40%' and
              to_number(substr(trn.CTRNACCD, 3, 1)) between 1 and 7) --! ���� ����������� ������������� ������ 401-407%,40802%, 40807
              or trn.CTRNACCD like '40802%'
              or trn.CTRNACCD like '40807%'
              or trn.CTRNACCD like '40821%')
        and not exists (select 1
                        from gac
                        where cgacacc = a.caccacc
                        and cgaccur = a.cacccur
                        and igaccat = 112
                        and igacnum = 1014)  -- ��� �� �������
        and not exists (select 1
                        from gac
                        where cgacacc = a.caccacc
                        and cgaccur = a.cacccur
                        and igaccat = 112
                        and igacnum = 10)
        and not exists (select /*+ index(GCS P_GCS_CUS_CAT_NUM)*/ 1
                        from gcs
                        where igcsCus = a.IACCCUS
                        and igcscat = 114
                        and igcsnum = 11
                        and exists (select 1
                                    from xxi.au_attach_obg au
                                    where i_num = gcs.igcsCus
                                    and i_table = 303
                                    and d_create <= d2
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
                                    and d_create <= d2
                                    and au.c_newdata like '114/' || to_char(gac.igacnum)))
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
                                    and d_create <= d2
                                    and au.c_newdata like '333/' || to_char(gac.igacnum)))
        and ( --!  ���� ����������, ���������� �� ���� ����� ���������� ��������� ������������� ������ 40817%,40820% ,423%,426%
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
        and ctrnmfoa not in (select cfilmfo from xxi."fil"  where idsmr = BankIdSmr) --! �� ���� ������� -> ������� �������
        and lower(trn.CTRNPURP) not like '%��������%'
        and lower(trn.CTRNPURP) not like '%������%'
        and lower(trn.CTRNPURP) not like '%�������%'
        and lower(trn.CTRNPURP) not like '%�/�%'
        and lower(trn.CTRNPURP) not like '%���%��%'
        and lower(trn.CTRNPURP) not like '%�����%'
        and lower(trn.CTRNPURP) not like '%�����������%'
        and lower(trn.CTRNPURP) not like '%�����%'
        and lower(trn.CTRNPURP) not like '%�����%'
        and lower(trn.CTRNPURP) not like '%������%'
        and lower(trn.CTRNPURP) not like '%�����%'
        and lower(trn.CTRNPURP) not like '%�������%'
        and lower(trn.CTRNPURP) not like '%�������%'
        and lower(trn.CTRNPURP) not like '%���������%'
        and lower(trn.CTRNPURP) not like '%����%'
        and lower(trn.CTRNPURP) not like '%��������%'
        and lower(trn.CTRNPURP) not like '%�������%'
        and lower(trn.CTRNPURP) not like '%����%'
        and lower(trn.CTRNPURP) not like '%�����%'
        and lower(trn.CTRNPURP) not like '%��������%'
        and lower(trn.CTRNPURP) not like '%���%����%'
        and lower(trn.CTRNPURP) not like '%�����%���%'
        and lower(trn.CTRNPURP) not like '%���%�����%'
        and lower(trn.CTRNPURP) not like '%������%'
        and lower(trn.CTRNPURP) not like '%�������%'
        --<< 23.10.2017  ����� �.�. 17-1225 https://redmine.lan.ubrr.ru/issues/47017#note-47.
        /*
        and lower(trn.CTRNPURP) not like '%��������%'
        and lower(trn.CTRNPURP) not like '%��������%'
        and lower(trn.CTRNPURP) not like '%��� �����%'
        and lower(trn.CTRNPURP) not like '%��� �����%'
        */
        -->> 23.10.2017  ����� �.�. 17-1225 https://redmine.lan.ubrr.ru/issues/47017#note-47.
        and lower(trn.CTRNPURP) not like '%������������%'
        /*and lower(trn.CTRNPURP) not like '%���%����%'*/ -->><<-- 23.10.2017  ����� �.�. 17-1225 https://redmine.lan.ubrr.ru/issues/47017#note-47.
        and lower(trn.CTRNPURP) not like '%������%'
        and nvl(regexp_count(lower(trn.CTRNPURP),'����'),0) = nvl(regexp_count(lower(trn.CTRNPURP),'���������'),0) -- 19.09.2018 ubrr rizanov [18-251] ���: ����� ���������� �� �������� �� ������� � ������ �� ("���������")
        and lower(trn.CTRNPURP) not like '%������%'
        and lower(trn.CTRNPURP) not like '%������%'
        and lower(trn.CTRNPURP) not like '%����������%'
        and lower(trn.CTRNPURP) not like '%������%'
        and lower(trn.CTRNPURP) not like '%��������%����%'
        and lower(trn.CTRNPURP) not like '%�����������%'
        and lower(trn.CTRNPURP) not like '%���%������%'
        and lower(trn.CTRNPURP) not like '%��%'
        /*and lower(trn.CTRNPURP) not like '%���%����%'*/ -->><<-- 23.10.2017  ����� �.�. 17-1225 https://redmine.lan.ubrr.ru/issues/47017#note-47.
        and lower(trn.CTRNPURP) not like '%��������%'
        and lower(trn.CTRNPURP) not like '%�������%'
        and lower(replace(trn.CTRNPURP,' ')) not like '%�/����%'
        and lower(replace(trn.CTRNPURP,' ')) not like '%�\����%'
        and lower(trn.CTRNPURP) not like '%�����%��%'
        and lower(trn.CTRNPURP) not like '%�����������%��%'
        and lower(trn.CTRNPURP) not like '%������%'
        and lower(trn.CTRNPURP) not like '%����%'
        -- >> ubrr 23.03.2020  ������� �.�.  [20-73286] ���������� ���� ���������� � �������� � ������ ��
        and lower(trn.CTRNPURP) not like '%�����%���%'
        and lower(trn.CTRNPURP) not like '%�����%�����%'
        and lower(trn.CTRNPURP) not like '%�����%��������%'
        -- << ubrr 23.03.2020  ������� �.�.  [20-73286] ���������� ���� ���������� � �������� � ������ ��
        and lower(replace(trn.CTRNPURP,' ')) not like '%�.��%'
        and lower(replace(trn.CTRNPURP,' ')) not like '%�\�%'
        -->> 22.08.2017  �������� �.�. [17-1031] ���: �������� ����� ���������� ��� ������� �������� ��� �������� ������� � ������ ��
        and lower(replace(trn.CTRNPURP,' ')) not like '%����%����%'
        and lower(replace(trn.CTRNPURP,' ')) not like '%�������%������%'
        --<< 22.08.2017  �������� �.�. [17-1031] ���: �������� ����� ���������� ��� ������� �������� ��� �������� ������� � ������ ��
        and (ITRNTYPE = 4 OR ITRNTYPE = 11 AND EXISTS (select 1
                                                       from trc
                                                       where trc.ITRCNUM = trn.ITRNNUMANC
                                                       and trc.ITRCTYPE = 4))
        and not exists (select 1
                        from ubrr_data.ubrr_sbs_new
                        where idsmr = a.idsmr
                        and dSBSdate = p_date
                        and cSBSaccd = a.caccacc
                        and cSBScurd = a.cacccur
                        and cSBSTypeCom = 'UL_FL'
                        and iSBStrnnum is not null
                        and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                       )
        -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
        and not exists (select 1
                          from UBRR_UNIQUE_TARIF_ACC uutc
                         where a.caccacc = uutc.cacc
                           and trn.dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF
                           and SYS_CONTEXT ('B21', 'IDSmr') = uutc.idsmr
                           and uutc.status = 'N')
        --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
        and exists (select 1
                    from ubrr_data.ubrr_rko_tarif v,
                         ubrr_data.ubrr_rko_tarif_otdsum o
                    where v.Parent_IdSmr = BankIdSmr -->><<-- ubrr 23.09.2016 �������� �.�. 16-2222 ���������� �������� ������
                    and v.com_type = 'UL_FL'
                    and v.id = o.id_com
                    and o.otd = a.iaccotd))
    group by ctrnaccd,ctrncur,iACCotd, TypeCom
    -- having sum(sumcom)>0
    union all -->> 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
   ----------------���������������� �� ��---------------------
select ctrnaccd , ctrncur,
              TypeCom, sum(mtrnsum), count(*), GetSumComiss(NULL, NULL, ctrnAccD, ctrncur, iaccotd, typecom, sum(mtrnsum), max(SumBefo)) sumcom,-->><<--23.10.2017  ����� �.�. 17-1225
              iaccotd, 5407, p_Date, 3, p_Date, max(SumBefo)-->><<--23.10.2017  ����� �.�. 17-1225
       from (
        select itrnnum, itrnanum, ctrnaccd , ctrncur, mtrnsum,
              'UL_FL_VB' TypeCom, iaccotd
              -->>23.10.2017  ����� �.�.      17-1225 https://redmine.lan.ubrr.ru/issues/47017#note-47.
              , nvl((select sum(mtrnsum) from V_TRN_PART_CURRENT xm
                              where xm.ctrnaccd = trn.ctrnaccd
                                and xm.ctrncur=trn.ctrncur
                                and xm.dtrntran between trunc(d1, 'MM') and d1 -1/86400
                                and xm.ctrnmfoa in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr)  --! ���� ������� -> ����������     -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
                                and ( --!  ���� ����������, ���������� �� ���� ����� ���������� ��������� ������������� ������ 40817%,40820% ,423%,426%
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
                                      or xm.ITRNTYPE = 2         -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
                                      OR xm.ITRNTYPE in (11,28)  -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
                                     AND EXISTS( select 1
                                                   from trc
                                                  where trc.ITRCNUM = xm.ITRNNUMANC
                                                    and trc.ITRCTYPE in (2,4) ) -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
                                    )
                                and lower(xm.CTRNPURP) not like '%��������%'
                                and lower(xm.CTRNPURP) not like '%������%'
                                and lower(xm.CTRNPURP) not like '%�������%'
                                and lower(xm.CTRNPURP) not like '%�/�%'
                                and lower(xm.CTRNPURP) not like '%���%��%'
                                and lower(xm.CTRNPURP) not like '%�����%'
                                and lower(xm.CTRNPURP) not like '%�����������%'
                                and lower(xm.CTRNPURP) not like '%�����%'
                                and lower(xm.CTRNPURP) not like '%�����%'
                                and lower(xm.CTRNPURP) not like '%������%'
                                and lower(xm.CTRNPURP) not like '%�����%'
                                and lower(xm.CTRNPURP) not like '%�������%'
                                and lower(xm.CTRNPURP) not like '%�������%'
                                and lower(xm.CTRNPURP) not like '%���������%'
                                and lower(xm.CTRNPURP) not like '%����%'
                                and lower(xm.CTRNPURP) not like '%��������%'
                                and lower(xm.CTRNPURP) not like '%�������%'
                                and lower(xm.CTRNPURP) not like '%����%'
                                and lower(xm.CTRNPURP) not like '%�����%'
                                and lower(xm.CTRNPURP) not like '%��������%'
                                and lower(xm.CTRNPURP) not like '%���%����%'
                                and lower(xm.CTRNPURP) not like '%�����%���%'
                                and lower(xm.CTRNPURP) not like '%���%�����%'
                                and lower(xm.CTRNPURP) not like '%������%'
                                and lower(xm.CTRNPURP) not like '%�������%'
                                and lower(xm.CTRNPURP) not like '%������������%'
                                and lower(xm.CTRNPURP) not like '%������%'
                                and nvl(regexp_count(lower(xm.CTRNPURP),'����'),0) = nvl(regexp_count(lower(xm.CTRNPURP),'���������'),0) -- 19.09.2018 ubrr rizanov [18-251] ���: ����� ���������� �� �������� �� ������� � ������ �� ("���������")
                                and lower(xm.CTRNPURP) not like '%������%'
                                and lower(xm.CTRNPURP) not like '%������%'
                                and lower(xm.CTRNPURP) not like '%����������%'
                                and lower(xm.CTRNPURP) not like '%������%'
                                and lower(xm.CTRNPURP) not like '%��������%����%'
                                and lower(xm.CTRNPURP) not like '%�����������%'
                                and lower(xm.CTRNPURP) not like '%���%������%'
                                and lower(xm.CTRNPURP) not like '%��%'
                                and lower(xm.CTRNPURP) not like '%��������%'
                                and lower(xm.CTRNPURP) not like '%�������%'
                                and lower(replace(xm.CTRNPURP,' ')) not like '%�/����%'
                                and lower(replace(xm.CTRNPURP,' ')) not like '%�\����%'
                                and lower(xm.CTRNPURP) not like '%�����%��%'
                                and lower(xm.CTRNPURP) not like '%�����������%��%'
                                and lower(xm.CTRNPURP) not like '%������%'
                                and lower(xm.CTRNPURP) not like '%����%'
                                -- >> ubrr 23.03.2020  ������� �.�.  [20-73286] ���������� ���� ���������� � �������� � ������ ��
                                and lower(xm.CTRNPURP) not like '%�����%���%'
                                and lower(xm.CTRNPURP) not like '%�����%�����%'
                                and lower(xm.CTRNPURP) not like '%�����%��������%'
                                -- << ubrr 23.03.2020  ������� �.�.  [20-73286] ���������� ���� ���������� � �������� � ������ ��
                                and lower(replace(xm.CTRNPURP,' ')) not like '%�.��%'
                                and lower(replace(xm.CTRNPURP,' ')) not like '%�\�%'
                                and lower(replace(xm.CTRNPURP,' ')) not like '%����%����%'
                                and lower(replace(xm.CTRNPURP,' ')) not like '%�������%������%'
                                and lower(xm.CTRNPURP) not like '%���%����%'              -- 12.03.2019 ������� �.�. [19-60337]   ���: ���������� ���� ���������� � �������� �� ���������� � ������ ��
                                and lower(xm.CTRNPURP) not like '%�����%'                 -- 07.03.2019 ������� �.�. [#60292] ������ ��� ������������� �������� �������� UL_FL � UL_FL_VB
                                and lower(xm.CTRNPURP) not like '%�����%'                 -- 07.03.2019 ������� �.�. [#60292] ������ ��� ������������� �������� �������� UL_FL � UL_FL_VB
                                and not exists --���� ����������� �������� ����, ��������, �������� ����� ��������, ������ �� ��������.
                                         (select 1
                                          from ubrr_ulfl_tab_acc_coms c
                                          where c.DCOMDATERAS = d1
                                          and c.ICOMTRNNUM IS NOT NULL
                                          and c.ccomaccd = xm.CTRNACCD)
                                          -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                                          and not exists
                                                    (select 1
                                                       from UBRR_UNIQUE_TARIF_ACC uutc
                                                      where a.caccacc = uutc.cacc
                                                        and xm.dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF
                                                        and SYS_CONTEXT ('B21', 'IDSmr') = uutc.idsmr
                                                        and uutc.status = 'N')
                                          --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                             ),0)
               SumBefo
             --<< 23.10.2017  ����� �.�. 17-1225 https://redmine.lan.ubrr.ru/issues/47017#note-47.
        from xxi.V_TRN_PART_CURRENT trn, acc a, otd o
        where cTRNcur = 'RUR'
        and cACCacc = cTRNaccd
        and cTRNaccd like acc_1
        and cACCacc like acc_1
        and cACCprizn <> '�'
        and o.iotdnum = a.iaccotd
        and dtrntran between d1 and d2
        and ((trn.CTRNACCD like '40%' and
              to_number(substr(trn.CTRNACCD, 3, 1)) between 1 and 7) --! ���� ����������� ������������� ������ 401-407%,40802%, 40807
              or trn.CTRNACCD like '40802%'
              or trn.CTRNACCD like '40807%'
              or trn.CTRNACCD like '40821%')
        and not exists (select 1
                        from gac
                        where cgacacc = a.caccacc
                        and cgaccur = a.cacccur
                        and igaccat = 112
                        and igacnum = 1014)  -- ��� �� �������
        and not exists (select 1
                        from gac
                        where cgacacc = a.caccacc
                        and cgaccur = a.cacccur
                        and igaccat = 112
                        and igacnum = 10)
        and not exists (select /*+ index(GCS P_GCS_CUS_CAT_NUM)*/ 1
                        from gcs
                        where igcsCus = a.IACCCUS
                        and igcscat = 114
                        and igcsnum = 11
                        and exists (select 1
                                    from xxi.au_attach_obg au
                                    where i_num = gcs.igcsCus
                                    and i_table = 303
                                    and d_create <= d2
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
                                    and d_create <= d2
                                    and au.c_newdata like '114/' || to_char(gac.igacnum)))
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
                                    and d_create <= d2
                                    and au.c_newdata like '333/' || to_char(gac.igacnum)))
        and ( --!  ���� ����������, ���������� �� ���� ����� ���������� ��������� ������������� ������ 40817%,40820% ,423%,426%
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
        and ctrnmfoa in (select cfilmfo from xxi."fil"  where idsmr = BankIdSmr) --! ���� ������� -> ����������     -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
        and lower(trn.CTRNPURP) not like '%��������%'
        and lower(trn.CTRNPURP) not like '%������%'
        and lower(trn.CTRNPURP) not like '%�������%'
        and lower(trn.CTRNPURP) not like '%�/�%'
        and lower(trn.CTRNPURP) not like '%���%��%'
        and lower(trn.CTRNPURP) not like '%�����%'
        and lower(trn.CTRNPURP) not like '%�����������%'
        and lower(trn.CTRNPURP) not like '%�����%'
        and lower(trn.CTRNPURP) not like '%�����%'
        and lower(trn.CTRNPURP) not like '%������%'
        and lower(trn.CTRNPURP) not like '%�����%'
        and lower(trn.CTRNPURP) not like '%�������%'
        and lower(trn.CTRNPURP) not like '%�������%'
        and lower(trn.CTRNPURP) not like '%���������%'
        and lower(trn.CTRNPURP) not like '%����%'
        and lower(trn.CTRNPURP) not like '%��������%'
        and lower(trn.CTRNPURP) not like '%�������%'
        and lower(trn.CTRNPURP) not like '%����%'
        and lower(trn.CTRNPURP) not like '%�����%'
        and lower(trn.CTRNPURP) not like '%��������%'
        and lower(trn.CTRNPURP) not like '%���%����%'
        and lower(trn.CTRNPURP) not like '%�����%���%'
        and lower(trn.CTRNPURP) not like '%���%�����%'
        and lower(trn.CTRNPURP) not like '%������%'
        and lower(trn.CTRNPURP) not like '%�������%'
        --<< 23.10.2017  ����� �.�. 17-1225 https://redmine.lan.ubrr.ru/issues/47017#note-47.
        /*
        and lower(trn.CTRNPURP) not like '%��������%'
        and lower(trn.CTRNPURP) not like '%��������%'
        and lower(trn.CTRNPURP) not like '%��� �����%'
        and lower(trn.CTRNPURP) not like '%��� �����%'
        */
        -->> 23.10.2017  ����� �.�. 17-1225 https://redmine.lan.ubrr.ru/issues/47017#note-47.
        and lower(trn.CTRNPURP) not like '%������������%'
        /*and lower(trn.CTRNPURP) not like '%���%����%'*/ -->><<-- 23.10.2017  ����� �.�. 17-1225 https://redmine.lan.ubrr.ru/issues/47017#note-47.
        and lower(trn.CTRNPURP) not like '%������%'
        and nvl(regexp_count(lower(trn.CTRNPURP),'����'),0) = nvl(regexp_count(lower(trn.CTRNPURP),'���������'),0) -- 19.09.2018 ubrr rizanov [18-251] ���: ����� ���������� �� �������� �� ������� � ������ �� ("���������")
        and lower(trn.CTRNPURP) not like '%������%'
        and lower(trn.CTRNPURP) not like '%������%'
        and lower(trn.CTRNPURP) not like '%����������%'
        and lower(trn.CTRNPURP) not like '%������%'
        and lower(trn.CTRNPURP) not like '%��������%����%'
        and lower(trn.CTRNPURP) not like '%�����������%'
        and lower(trn.CTRNPURP) not like '%���%������%'
        and lower(trn.CTRNPURP) not like '%��%'
        /*and lower(trn.CTRNPURP) not like '%���%����%'*/ -->><<-- 23.10.2017  ����� �.�. 17-1225 https://redmine.lan.ubrr.ru/issues/47017#note-47.
        and lower(trn.CTRNPURP) not like '%��������%'
        and lower(trn.CTRNPURP) not like '%�������%'
        and lower(replace(trn.CTRNPURP,' ')) not like '%�/����%'
        and lower(replace(trn.CTRNPURP,' ')) not like '%�\����%'
        and lower(trn.CTRNPURP) not like '%�����%��%'
        and lower(trn.CTRNPURP) not like '%�����������%��%'
        and lower(trn.CTRNPURP) not like '%������%'
        and lower(trn.CTRNPURP) not like '%����%'
        -- >> ubrr 23.03.2020  ������� �.�.  [20-73286] ���������� ���� ���������� � �������� � ������ ��
        and lower(trn.CTRNPURP) not like '%�����%���%'
        and lower(trn.CTRNPURP) not like '%�����%�����%'
        and lower(trn.CTRNPURP) not like '%�����%��������%'
        -- << ubrr 23.03.2020  ������� �.�.  [20-73286] ���������� ���� ���������� � �������� � ������ ��
        and lower(replace(trn.CTRNPURP,' ')) not like '%�.��%'
        and lower(replace(trn.CTRNPURP,' ')) not like '%�\�%'
        -->> 22.08.2017  �������� �.�. [17-1031] ���: �������� ����� ���������� ��� ������� �������� ��� �������� ������� � ������ ��
        and lower(replace(trn.CTRNPURP,' ')) not like '%����%����%'
        and lower(replace(trn.CTRNPURP,' ')) not like '%�������%������%'
        --<< 22.08.2017  �������� �.�. [17-1031] ���: �������� ����� ���������� ��� ������� �������� ��� �������� ������� � ������ ��
        and lower(trn.CTRNPURP) not like '%���%����%'              -- 12.03.2019 ������� �.�. [19-60337]   ���: ���������� ���� ���������� � �������� �� ���������� � ������ ��
        and lower(trn.CTRNPURP) not like '%�����%'                 -- 07.03.2019 ������� �.�. [#60292] ������ ��� ������������� �������� �������� UL_FL � UL_FL_VB
        and lower(trn.CTRNPURP) not like '%�����%'                 -- 07.03.2019 ������� �.�. [#60292] ������ ��� ������������� �������� �������� UL_FL � UL_FL_VB
        and (    ITRNTYPE = 4
              or ITRNTYPE = 2        -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
              OR ITRNTYPE in (11,28) -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
             AND EXISTS( select 1
                           from trc
                          where trc.ITRCNUM = trn.ITRNNUMANC
                            and trc.ITRCTYPE  in (2,4) ) -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
            )
        and not exists (select 1
                        from ubrr_data.ubrr_sbs_new
                        where idsmr = a.idsmr
                        and dSBSdate = p_date
                        and cSBSaccd = a.caccacc
                        and cSBScurd = a.cacccur
                        and cSBSTypeCom = 'UL_FL_VB'
                        and iSBStrnnum is not null
                        and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                        )
        -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
        and not exists (select 1
                          from UBRR_UNIQUE_TARIF_ACC uutc
                         where a.caccacc = uutc.cacc
                           and trn.dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF
                           and SYS_CONTEXT ('B21', 'IDSmr') = uutc.idsmr
                           and uutc.status = 'N')
        --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
        and exists (select 1
                    from ubrr_data.ubrr_rko_tarif v,
                         ubrr_data.ubrr_rko_tarif_otdsum o
                    where v.Parent_IdSmr = BankIdSmr -->><<-- ubrr 23.09.2016 �������� �.�. 16-2222 ���������� �������� ������
                    and v.com_type = 'UL_FL_VB'
                    and v.id = o.id_com
                    and o.otd = a.iaccotd))
    group by ctrnaccd,ctrncur,iACCotd, TypeCom
    --<< 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
    -- having sum(sumcom)>0
    );

     iCnt := SQL%ROWCOUNT;
     COMMIT;
     WriteProtocol('��������� �������� �� ������� � ������ ��: '||iCnt);
     RETURN iCnt;
  exception
    WHEN OTHERS THEN
      ROLLBACK;
      WriteProtocol('������ ��� ������� �������� �� �������� � ������ ��: '||SQLErrm);
      p_Mess := '������ ��� ������� �������� �� �������� � ������ ��: '||SQLErrm;
      RETURN -1;
  end;

  FUNCTION CalcCashCom
   (p_Date in date, -- ���� �������
    p_ls in varchar2 default null, -- ���� ��� ������� ��������
    p_Mess out varchar2
  ) RETURN number
  IS
    d1       date := p_Date; -- ��������� ���� � ������ ���������
    acc_1       varchar2(25) := nvl(p_ls,'40___810%');
    d2       date := p_Date + 86399/86400; -- ���� ���������
    iCnt     number;
    iCnt1    number;
    l_step   varchar2(4):='000';  -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
  BEGIN
    DELETE FROM ubrr_data.ubrr_sbs_new
    WHERE IdSmr = SYS_CONTEXT('B21','IdSmr')
      and isbstrnnum is null
      and dSBSDate = p_Date
      and isbstypecom = 4
      and cSBSaccd like acc_1
      and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
      ;
    COMMIT;
    l_step:='010'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
    IF BankIdSmr = '16' THEN  -->><<-- ubrr 06.10.2016 �������� �.�. 16-2222 ���������� �������� �����
      l_step:='020'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
      INSERT INTO ubrr_data.ubrr_sbs_new
      (cSBSaccd, cSBScurd, cSBSTypeCom, mSBSsumpays, iSBScountPays, mSBSsumcom, iSBSotdnum, iSBSBatNum, dSBSDate, iSBSTypeCom, mSBSsumbefo, dsbsdatereg)
       (select ctrnaccd , ctrncur, TypeCom,
              sum(mtrnsum), count(*), GetSumComiss(NULL,NULL,ctrnAccD, ctrncur, iaccotd, TypeCom, sum(mtrnsum), Min(SumBefo)),
              iaccotd, batnum, p_Date, 4, Min(SumBefo), p_Date
       from (
         SELECT
              itrnnum, itrnanum, ctrnaccd , ctrncur, mtrnsum, iaccotd, to_number(to_char(NVL(iOTDbatnum,70) )||'00') batnum,
              case when (nvl(x.itrnsop,0) = 5 and x.itrntype = 9) then 'CASS_CRD'
                   when x.itrncocode in (40,41,96,496, 50) then 'CASS_ZP'
                   -->>01.08.2019  �������� [19-62974] III ���� ���. ��������������� ������� ����� ����� �� ���
                   --else 'CASS_OTHER'
                   when (select 1 from gac g where g.igaccat=15 and g.igacnum=4 and g.cgacacc=acc.caccacc) = 1 then 'CASS_OTHER_IP'
                   else 'CASS_OTHER_UR'
                   --<<01.08.2019  �������� [19-62974] III ���� ���. ��������������� ������� ����� ����� �� ���
              end TypeCom,
              case when (nvl(x.itrnsop,0) = 5 and x.itrntype = 9) then 0 -- ��� ������ � ����� ������� �� ����� ������� �� ����
                   when x.itrncocode in (40,41,96,496, 50) then 0 -- ��� �������� ������� �� ����� �� ����
                   else  nvl((select sum(mtrnsum) from /*V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v xm -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                              where xm.ctrnaccd = x.ctrnaccd and xm.ctrncur=x.ctrncur
                                and xm.dtrntran between trunc(d1, 'MM') and d1-1/86400
                                and xm.itrntype in (9,13)
                                and xm.itrncocode not in (40,41,96,496,50)
                                and not (nvl(xm.itrnsop,0) = 5 and xm.itrntype = 9)
                             ),0)
              end SumBefo
                 FROM /*V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v x, acc, otd -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                 WHERE x.dtrntran between d1 and d2
                   and acc.caccacc = x.ctrnaccd
                   and acc.cacccur = x.ctrncur
                   and acc.caccacc like acc_1
                   and iTRNba2d not in (40813,40817,40818,40820,42309,40810,40811,40812,40823,40824)
                   AND acc.cacccur = 'RUR'
                   AND acc.caccprizn <> '�'
                   AND acc.caccacc LIKE '40%'
                   and acc.iaccotd = otd.iotdnum
                   and not exists (select 1
                          from gac
                         where cgacacc = acc.cACCacc
                           and igaccat = 112
                           and igacnum = 1014)  -- ��� �� �������
                  AND not exists (
                             select 'X'
                             from gac
                             where (    (igaccat = 119 AND igacnum IN (2, 3))
                                     OR (igaccat = 112 AND igacnum = 10)
                                     OR (igaccat = 333 AND igacnum = 2) -- ubrr korolkov
                                     OR (igaccat = 112 AND igacnum = 57) -- ubrr korolkov
                                   )
                                  and cgacacc = acc.caccacc
                            )
                   AND exists (
                        select /*+ index(trn I_TRN_ACCD_CUR_DTRN_TYPE)*/
                               'X'
                        from /*xxi.v_trn_part_current*/ ubrr_trn_old_new_v trn -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                        where     trn.ctrnaccd = acc.caccacc
                              AND trn.ctrncur = acc.cacccur
                              AND trn.dtrntran between d1 and d2
                              AND trn.itrntype = 9
                              AND trn.ctrnaccd LIKE '40%'
                      )
                  and x.itrntype in (9,13)
                 -- and not (nvl(x.itrnsop,0) = 5 and x.itrntype = 9)
                  and not exists (select 1 from ubrr_data.ubrr_sbs_new where idsmr = acc.idsmr and dSBSdate = p_date
                                                                and cSBSaccd = acc.caccacc and cSBScurd = acc.cacccur
                                                                and cSBSTypeCom = case when (nvl(x.itrnsop,0) = 5 and x.itrntype = 9) then 'CASS_CRD'
                                                                                       when x.itrncocode in (40,41,96,496, 50) then 'CASS_ZP'
                                                                                       -->>01.08.2019 �������� [19-62974] III ���� ���. ��������������� ������� ����� ����� �� ���
                                                                                       --else 'CASS_OTHER'
                                                                                       when (select 1 from gac g where g.igaccat=15 and g.igacnum=4 and g.cgacacc=acc.caccacc) = 1 then 'CASS_OTHER_IP'
                                                                                       else 'CASS_OTHER_UR'
                                                                                       --<<01.08.2019 �������� [19-62974] III ���� ���. ��������������� ������� ����� ����� �� ���
                                                                                  end
                                                                and iSBStrnnum is not null
                                                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                                 )
                  and exists (select 1 from ubrr_data.ubrr_rko_tarif v, ubrr_data.ubrr_rko_tarif_otdsum o
                               where v.Parent_IdSmr = BankIdSmr and v.com_type IN ('CASS_ZP', /*'CASS_OTHER',*/ 'CASS_CRD', 'CASS_OTHER_IP', 'CASS_OTHER_UR')  -->><<-- ubrr 23.09.2016 �������� �.�. 16-2222 ���������� �������� ������    -->><<-- 01.08.2019 �������� [19-62974] III ���� ���. ����� 'CASS_OTHER'
                                 and v.id = o.id_com and o.otd = acc.iaccotd)
         )x group by ctrnaccd,ctrncur,iACCotd, typeCom, batnum
       --having sum(sumcom)>0
       );
      iCnt1 := SQL%ROWCOUNT;  -->><<-- ubrr 19.10.2016 �������� �.�.   [16-2222]  #35311 ����������� ������ - ����������� ���-�� ����������� �����
      -->> ubrr 06.10.2016 �������� �.�.   [16-2222]  #35311  ���������� �������� �� �������� �������� �����
     ELSE
      -- �������� �� ��, �������� �����
      l_step:='030'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
      INSERT INTO ubrr_data.ubrr_sbs_new
      (cSBSaccd, cSBScurd, cSBSTypeCom, mSBSsumpays, iSBScountPays, mSBSsumcom, iSBSotdnum, iSBSBatNum, dSBSDate, iSBSTypeCom, mSBSsumbefo, dsbsdatereg)
       (select ctrnaccd , ctrncur, 'CASS' typecom,
              sum(mtrnsum) mtrnsum, sum(cntop), sum(sumcom), iaccotd, batnum, p_Date, 4, 0, p_Date

        from
       (select ctrnaccd , ctrncur, TypeCom,
              sum(mtrnsum) mtrnsum, count(*) cntop, GetSumComiss(NULL,NULL,ctrnAccD, ctrncur, iaccotd, TypeCom, sum(mtrnsum), Min(SumBefo)) sumcom,
              iaccotd, batnum
       from (
         SELECT itrnnum, itrnanum, ctrnaccd , ctrncur, mtrnsum, iaccotd, batnum, typecom,
              case when typecom in ('CASS_OTHER_IP', 'CASS_OTHER_UR') then
                         nvl((select sum(mtrnsum) from /*V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v xm -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                              where xm.ctrnaccd = x.ctrnaccd and xm.ctrncur=x.ctrncur
                                and xm.dtrntran between trunc(d1, 'MM') and d1-1/86400
                                and xm.itrntype in (9,13)
                                and xm.itrncocode not in (40,41,96,496,50,42)
                                and not (nvl(xm.itrnsop,0) = 5 and xm.itrntype = 9)
                                and not xm.itrncocode = 60
                             ),0)
                  else 0
              end SumBefo
         from (
         SELECT
              itrnnum, itrnanum, ctrnaccd , ctrncur, mtrnsum, iaccotd, to_number(to_char(NVL(iOTDbatnum,70) )||'00') batnum,
              case
                   when iaccbs2 in (40503,40603,40703) and
                        balance.AccDebTO(trunc(ADD_MONTHS(p_Date, -1), 'MM'), trunc(p_Date, 'MM')-1, ctrnaccd, ctrncur)<=100000 then 'CASS_UNC_100'
                   when x.itrncocode in (40,41,96,496, 50, 42) then 'CASS_ZP'
                   when x.itrncocode in (60) then 'CASS_CB'
                   when iaccbs2 = 40703 and exists
                        (select 1 from ubrr_data.ubrr_rko_tarif v, ubrr_data.ubrr_rko_tarif_otdsum o
                         where v.Parent_IdSmr = BankIdSmr and v.com_type ='CASS_OTHER_PENS'
                           and v.id = o.id_com and o.otd = acc.iaccotd) then 'CASS_OTHER_PENS'
                   when exists(SELECT 1
                               FROM gcs
                               WHERE igcscus = iAccCus
                                 AND igcscat = 15
                                 AND igcsnum = 4
                              ) then 'CASS_OTHER_IP'
                   else 'CASS_OTHER_UR'
              end TypeCom
                 FROM /*V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v x, acc, otd -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                 WHERE x.dtrntran between d1 and d2
                   and acc.caccacc = x.ctrnaccd
                   and acc.cacccur = x.ctrncur
                   and acc.caccacc like acc_1
                   and not (nvl(x.itrnsop,0) = 5 and x.itrntype = 9)
                   and iTRNba2d not in (40813,40817,40818,40820,42309,40810,40811,40812,40823,40824)
                   AND acc.cacccur = 'RUR'
                   AND acc.caccprizn <> '�'
                   AND acc.caccacc LIKE '40%'
                   and acc.iaccotd = otd.iotdnum
                   and not exists (select 1
                          from gac
                         where cgacacc = acc.cACCacc
                           and igaccat = 112
                           and igacnum = 1014)  -- ��� �� �������
                   and not exists (select 1
                          from gac
                         where cgacacc = acc.cACCacc
                           and igaccat = 114
                           and igacnum = 15)       -- �� �� ������� (������)
                  AND not exists (
                             select 'X'
                             from gac
                             where (    (igaccat = 119 AND igacnum IN (2, 3))
                                     OR (igaccat = 112 AND igacnum = 10)
                                     OR (igaccat = 333 AND igacnum = 2) -- ubrr korolkov
                                     OR (igaccat = 112 AND igacnum = 57) -- ubrr korolkov
                                   )
                                  and cgacacc = acc.caccacc
                            )
                   AND exists (
                        select /*+ index(trn I_TRN_ACCD_CUR_DTRN_TYPE)*/
                               'X'
                        from /*xxi.v_trn_part_current*/ ubrr_trn_old_new_v trn -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                        where     trn.ctrnaccd = acc.caccacc
                              AND trn.ctrncur = acc.cacccur
                              AND trn.dtrntran between d1 and d2
                              AND trn.itrntype = 9
                              AND trn.ctrnaccd LIKE '40%'
                      )
                  and x.itrntype in (9,13)
                 -- and not (nvl(x.itrnsop,0) = 5 and x.itrntype = 9)
                  and not exists (select 1 from ubrr_data.ubrr_sbs_new where idsmr = acc.idsmr and dSBSdate = p_date
                                                                and cSBSaccd = acc.caccacc and cSBScurd = acc.cacccur
                                                                and cSBSTypeCom = 'CASS'
                                                                and iSBStrnnum is not null
                                                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                                 )
                  and exists (select 1 from ubrr_data.ubrr_rko_tarif v, ubrr_data.ubrr_rko_tarif_otdsum o
                               where v.Parent_IdSmr = BankIdSmr and v.com_type like 'CASS%'
                                 and v.id = o.id_com and o.otd = acc.iaccotd)
         )x)x group by ctrnaccd,ctrncur,iACCotd, typeCom, batnum
         ) group by ctrnaccd , ctrncur, iaccotd, batnum
       --having sum(sumcom)>0
       );
      iCnt1 := SQL%ROWCOUNT;
     -->>06.08.2019 �������� [19-62974] III ���� ���
     END IF;
      -->> ubrr 21.10.2016 �������� �.�. 16-2222.2 �������� �� ���������� �������� ������
      l_step:='040'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
      INSERT INTO ubrr_data.ubrr_sbs_new
      (cSBSaccd, cSBScurd, cSBSTypeCom, mSBSsumpays, iSBScountPays, mSBSsumcom, iSBSotdnum, iSBSBatNum, dSBSDate, iSBSTypeCom, mSBSsumbefo, dsbsdatereg)
       (select ctrnaccd , ctrncur, TypeCom, sumtrn, cnttrn, sumcom, iaccotd, batnum, p_Date, 4, 0, p_Date
        from(
        select ctrnaccd , ctrncur, TypeCom,
              sum(mtrnsum) sumtrn, count(*) cnttrn, GetSumComiss(NULL,NULL,ctrnAccD, ctrncur, iaccotd, TypeCom, sum(mtrnsum), 0) sumcom,
              iaccotd, batnum, p_Date, 4
       from (
         SELECT
              itrnnum, itrnanum, ctrnaccd , ctrncur, mtrnsum, iaccotd, to_number(to_char(NVL(iOTDbatnum,70) )||'00') batnum,
              case
                   when exists(SELECT 1
                               FROM gcs
                               WHERE igcscus = iAccCus
                                 AND igcscat = 15
                                 AND igcsnum = 4
                              ) then 'CASS_LIM_IP'
                   else 'CASS_LIM_UR'
              end TypeCom
                 FROM /*V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v x, acc, otd -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                 WHERE x.dtrntran between d1 and d2
                   and acc.caccacc = x.ctrnaccd
                   and acc.cacccur = x.ctrncur
                   and acc.caccacc like acc_1
                   and iTRNba2d not in (40813,40817,40818,40820,42309,40810,40811,40812,40823,40824)
                   AND acc.cacccur = 'RUR'
                   AND acc.caccprizn <> '�'
                   AND acc.caccacc LIKE '40%'
                   and acc.iaccotd = otd.iotdnum
                   and not itrncocode in (40,41,96,496, 50, 42) -->><<-- 30.01.2016 �������� �.�. 16-3100.1 ���� ������� 42
                   and not (nvl(x.itrnsop,0) = 5 and x.itrntype = 9)
                   and not exists (select 1
                          from gac
                         where cgacacc = acc.cACCacc
                           and igaccat = 112
                           and igacnum = 1014)  -- ��� �� �������
                   and not exists (select 1
                          from gac
                         where cgacacc = acc.cACCacc
                           and igaccat = 114
                           and igacnum = 15)       -- �� �� ������� (������)
                   AND not exists (
                             select 'X'
                             from gac
                             where (    (igaccat = 119 AND igacnum IN (2, 3))
                                     OR (igaccat = 112 AND igacnum = 10)
                                     OR (igaccat = 333 AND igacnum = 2) -- ubrr korolkov
                                     OR (igaccat = 112 AND igacnum = 57) -- ubrr korolkov
                                   )
                                  and cgacacc = acc.caccacc
                            )
                   AND exists (
                        select /*+ index(trn I_TRN_ACCD_CUR_DTRN_TYPE)*/
                               'X'
                        from /*xxi.v_trn_part_current*/ ubrr_trn_old_new_v trn -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
                        where     trn.ctrnaccd = acc.caccacc
                              AND trn.ctrncur = acc.cacccur
                              AND trn.dtrntran between d1 and d2
                              AND trn.itrntype = 9
                              AND trn.ctrnaccd LIKE '40%'
                      )
                  and x.itrntype in (9,13)
                  and not exists (select 1 from ubrr_data.ubrr_sbs_new where idsmr = acc.idsmr and dSBSdate = p_date
                                                                and cSBSaccd = acc.caccacc and cSBScurd = acc.cacccur
                                                                and cSBSTypeCom IN ('CASS_LIM_IP', 'CASS_LIM_UR')
                                                                and iSBStrnnum is not null
                                                                and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                                 )
                  and exists (select 1 from ubrr_data.ubrr_rko_tarif v, ubrr_data.ubrr_rko_tarif_otdsum o
                               where v.Parent_IdSmr = BankIdSmr and v.com_type IN ('CASS_LIM_IP', 'CASS_LIM_UR')
                                 and v.id = o.id_com and o.otd = acc.iaccotd)
         )x group by ctrnaccd,ctrncur,iACCotd, typeCom, batnum
         )where sumcom>0
       );
       iCnt1 := SQL%ROWCOUNT+iCnt1;
       --<< ubrr 21.10.2016 �������� �.�. 16-2222.2 �������� �� ���������� �������� ������
     --END IF;
     --<<06.08.2019 �������� [19-62974]   III ���� ���
      --<< ubrr 06.10.2016 �������� �.�.   [16-2222]  #35311  ���������� �������� �� �������� �������� �����
     iCnt := iCnt1;
     WriteProtocol('��������� �������� �� ��: '||iCnt1);

      -- ��������� �������� �� ��� ��� ������ ������� �� ����������� � ��������� �������
    l_step:='050'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
     INSERT INTO ubrr_data.ubrr_sbs_new
      (cSBSaccd, cSBScurd, cSBSTypeCom, mSBSsumpays, iSBScountPays, mSBSsumcom, iSBSotdnum, iSBSBatNum, dSBSDate, iSBSTypeCom, dsbsdatereg
       -->> ������ UBRR 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������
       , idsmr_to
       --<< ����� UBRR 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������
      )
      (select ctrnaccc , ctrncurc,
             -->> ubrr 06.10.2016 �������� �.�.   [16-2222]  #35311  ���������� �������� �� �������� �������� �����
              TypeCom, sum(mtrnsum), count(*),
              GetSumComiss(NULL, NULL,ctrnAccc, ctrncurc,
               -->> ������ UBRR 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������
               ---- ����������� �� �������� �� ����������� �������� ����� �������� �� ���
               ---- otd_acc,
                case when count(distinct iaccotd)=1 then min(iaccotd) else otd_acc end,
               --<< ����� UBRR 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������
                TypeCom,
              sum(mtrnsum), 0) sumcom,
              case when count(distinct iaccotd)=1 then min(iaccotd) else otd_acc end otd_acc,
              case when count(distinct iaccotd)=1 then min(to_number(to_char(NVL(iOTDbatnum,70) )||'00')) else to_number(to_char(NVL(otdcbat,70) )||'00') end  batnum,
              p_Date, 4, p_Date
              -->> ������ UBRR 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������
              , MAX(idsmr_to)
              --<< ����� UBRR 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������
             --<< ubrr 06.10.2016 �������� �.�.   [16-2222]  #35311  ���������� �������� �� �������� �������� �����
       from (
         select /*+ index(trn I_TRN_ACCC_CURC_DTRN_TYPE)*/
                ctrnaccc,ctrncurc, mtrnsum,
                -->> ������ UBRR 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������
                null idsmr_to,
                --<< ����� UBRR 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������
                accd.iaccotd, otd.iotdbatnum, otdc.iotdbatnum otdcbat, acc.iaccotd otd_acc, decode(nvl(substr(itrnbatnum ,3,2),99),44,'VZN44','VZN') TypeCom       -->><< ubrr 06.10.2016 �������� �.�.   [16-2222]  #35311  ���������� �������� �� �������� �������� �����
         from acc,
              /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn, -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546
              acc accd, -- ������ � �� ���������, � ������� �����������
              otd
              , otd otdc  -->><< ubrr 06.10.2016 �������� �.�.   [16-2222]  #35311  ���������� �������� �� �������� �������� �����
         where
               ( acc.iaccbs2 BETWEEN 40201 AND 40802 OR acc.iaccbs2 = 40807 OR ctrnaccc LIKE '40821%' )
            and not exists (select 1
                            from gac
                           where cgacacc = acc.cACCacc
                             and igaccat = 112
                             and igacnum = 1014)  -- ��� �� �������
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
           -->> ubrr 06.10.2016 �������� �.�.   [16-2222]  #35311  ���������� �������� �� �������� �������� �����
           and not (BankIdSmr = '1' and
                    (exists (select 1
                             from gac
                             where cgacacc = acc.cACCacc
                               and igaccat = 112
                               and igacnum = 44)    -- ����������� �����������
                     or
                      exists (select 1
                              from gac
                              where cgacacc = acc.cACCacc
                                and igaccat = 114
                                and igacnum = 14)       -- �� �� ������� (��������)
                   )
                  )
           --<< ubrr 06.10.2016 �������� �.�.   [16-2222]  #35311  ���������� �������� �� �������� �������� �����
           -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
           and not exists ( select 1
                                    from gac g
                                        ,ubrr_rko_exinc_catgr e
                                   where g.igaccat   = e.icat
                                     and g.igacnum   = e.igrp
                                     and e.ccom_type = decode(nvl(substr(itrnbatnum ,3,2),99),44,'VZN44','VZN')
                                     and e.exinc     = 0
                                     and g.cgacacc   = acc.caccacc
                                     and g.cgaccur   = acc.cACCcur
                                     -->>22.01.2020 �������� [19-64846]
                                     and exists (select 1
                                                         from xxi.au_attach_obg au
                                                        where au.caccacc = g.cgacacc
                                                          and au.cacccur = g.cgaccur
                                                          and au.i_table = 304
                                                          and au.c_newdata = e.icat||'/'||e.igrp
                                                          and trunc(au.d_create) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end)
                                                      )
                                     --<<22.01.2020 �������� [19-64846]
                          )
           --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
           and acc.cacccur = 'RUR'
           and acc.caccprizn <> '�'
           --and acc.iaccotd NOT IN (6116,6105)  -->><<-- 10.01.2017 �������� �.�.   [16-2222]  #35311  ����������������. ����������� ������ �� �������� �� ����� ���� �� ��� � �-���������
           and acc.caccacc like acc_1
           and iTRNba2c not in (40813,40817,40818,40820,42309,40810,40811,40812,40823,40824)
           and trn.ctrnaccc = acc.caccacc
           and trn.ctrncurc = acc.cacccur
           and trn.ctrnaccd = accd.caccacc
           and trn.ctrncur = accd.cacccur
           and otd.iotdnum=accd.iaccotd
           and otdc.iotdnum=acc.iaccotd  -->><<-- ubrr 06.10.2016 �������� �.�. 16-2222 ���������� �������� �����
           and trn.dtrntran between d1 and d2
           and trn.itrntype = 10
           and trn.itrnba2d in (20202,20207)
           and trn.ctrncur = 'RUR'
           and trn.ctrncurc = 'RUR'
           and ltrim(upper(trn.CTRNPURP)) not like '���������������%'
           and not (nvl(substr(itrnbatnum ,3,2),99)=44 and BankIdSmr = '16')  -->><<-- ubrr 06.10.2016 �������� �.�. 16-2222 ���������� �������� �����
           and not exists (select 1 from ubrr_data.ubrr_sbs_new where idsmr = acc.idsmr and dSBSdate = p_date
                                                                  and cSBSaccd = acc.caccacc and cSBScurd = acc.cacccur
                                                                  and cSBSTypeCom IN ('VZN', 'VZN44')
                                                                  and iSBStrnnum is not null
                                                                  and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                          )
           and exists (select 1 from ubrr_data.ubrr_rko_tarif v, ubrr_data.ubrr_rko_tarif_otdsum o
                       where v.Parent_IdSmr = BankIdSmr and v.com_type = 'VZN'  -->><<-- ubrr 23.09.2016 �������� �.�. 16-2222 ���������� �������� ������
                         and v.id = o.id_com and o.otd = acc.iaccotd)
         -->> ubrr 21.10.2016 �������� �.�. 16-2222.2 �������� �� ����� ��������� ���
         UNION ALL
         select caccacc, cacccur, mtrnsum,
         -->> ������ UBRR 10.03.2017 ����������� �.�. 16-3100.2 ���: �������� �� �������� ��� ����� ���������
          nvl((select max(t.idsmr) from xxi."acc" t where t.caccacc = trn.ctrnaccd and t.caccprizn <> '�'), acc.idsmr) idsmr_to,
         ---------------
         -- ������ 1: --
         ---------------
         -- �� ��� ������� ���� ���� ��(������ ������ �������� � ���� ��(� ���� ������ �����)):
         nvl((select max(t.iaccotd) from xxi."acc" t where t.caccacc = trn.ctrnaccd and t.cacccur = trn.ctrncur and t.caccprizn <> '�'), acc.iaccotd) iaccotd,
         nvl((select max(o.iotdbatnum) from xxi."acc" t, otd o where o.iotdnum=t.iaccotd and t.caccacc = trn.ctrnaccd and t.cacccur = trn.ctrncur and t.caccprizn <> '�'), otd.iotdbatnum) iotdbatnum,
         -- iaccotd     = ��� �� ��� ������� ���� ���� ��(������ ������ �������� � ���� ��(� ���� ������ �����))
         -- iotdbatnum  = ��� �� ��� ������� ���� ���� ��(������ ������ �������� � ���� ��(� ���� ������ �����))
         ---------------
         -- ������ 2: --
         ---------------
         -- �� ��� ������� ���� ���� ����� ������ ��(������ ������ �������� � ������ ������� �����, ��������� � ������������ �����):
         otd.iotdbatnum  otdcbat,
         acc.iaccotd     otd_acc,
         -- otdcbat  =  ��� ������� ���� ���� ����� ������ ��(������ ������ �������� � ������ ������� �����, ��������� � ������������ �����)
         -- otd_acc  =  ��� ������� ���� ���� ����� ������ ��(������ ������ �������� � ������ ������� �����, ��������� � ������������ �����)
         --<< � ����� � ������� https://redmine.lan.ubrr.ru/issues/39457 <<--
         decode(nvl(substr(itrnbatnum ,3,2),99),44,'VZN44','VZN') TypeCom
         from (
            select itrnnum, itrntype, ctrnaccd, ctrnaccc, ctrnpurp, mtrnsum, ctrncur,
                   -- REGEXP_SUBSTR(REGEXP_SUBSTR(ctrnpurp, '���.*40[0-9]{18}'),'40[0-9]{18}') rsacc,
                   REGEXP_SUBSTR(ctrnpurp, '40[0-9]{18}') rsacc, -- [issues/39457]
                   itrnbatnum
            from xxi."trn" PARTITION (TRN_PART_CURRENT) -->><<--14.10.2019 �������� [19-62184] ���������� �������� ����� (����� UBRR_BNKSERV_EVERYDAY) #67546. ����� ������� ����� �� �����.
            where dtrntran between d1 and d2
              and regexp_like(ctrnaccd,  '(20202810|20207810)') and ctrnaccc like  '30301810%' and itrntype in (10) and itrnsop in (162, 165) and REGEXP_LIKE(upper(ctrnpurp), '������.*40[0-9]{18}') -- [issues/39457] ctrnpurp like '%���%' and upper(ctrnpurp) like '%���%������%'
         -- itrntype = ��1 = iTop = rvDocument.iBo1
         -- itrnsop  = ��2 = iSop = rvDocument.iBo2
         --<< ����� UBRR 10.03.2017 ����������� �.�. 16-3100.2 ���: �������� �� �������� ��� ����� ���������
         ) trn, acc, otd
         where BankIdSmr = '1'
           and acc.caccacc = trn.rsacc
           and otd.iotdnum=acc.iaccotd
           and (acc.iaccbs2 BETWEEN 40201 AND 40802 OR acc.iaccbs2 in (40807, 40821) )
           and not exists (select 1
                           from gac
                          where cgacacc = acc.cACCacc
                            and igaccat = 112
                            and igacnum = 1014)  -- ��� �� �������
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
          and not (exists (select 1
                           from gac
                           where cgacacc = acc.cACCacc
                             and igaccat = 112
                             and igacnum = 44)    -- ����������� �����������
                   or
                    exists (select 1
                            from gac
                            where cgacacc = acc.cACCacc
                              and igaccat = 114
                              and igacnum = 14)       -- �� �� ������� (��������)

                 )
          -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
          and not exists ( select 1
                                   from gac g
                                       ,ubrr_rko_exinc_catgr e
                                  where g.igaccat   = e.icat
                                    and g.igacnum   = e.igrp
                                    and e.ccom_type = decode(nvl(substr(itrnbatnum ,3,2),99),44,'VZN44','VZN')
                                    and e.exinc     = 0
                                    and g.cgacacc   = acc.caccacc
                                    and g.cgaccur   = acc.cACCcur
                                    -->>22.01.2020 �������� [19-64846]
                                    and exists (select 1
                                                  from xxi.au_attach_obg au
                                                 where au.caccacc = g.cgacacc
                                                   and au.cacccur = g.cgaccur
                                                   and au.i_table = 304
                                                   and au.c_newdata = e.icat||'/'||e.igrp
                                                   and trunc(au.d_create) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end)
                                                 )
                                    --<<22.01.2020 �������� [19-64846]
                         )
          --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
          and acc.cacccur = 'RUR'
          and acc.caccprizn <> '�'
          and acc.caccacc like acc_1
          and not exists (select 1 from ubrr_data.ubrr_sbs_new where idsmr = acc.idsmr and dSBSdate = p_date
                                                                  and cSBSaccd = acc.caccacc and cSBScurd = acc.cacccur
                                                                  and cSBSTypeCom IN ('VZN', 'VZN44')
                                                                  and iSBStrnnum is not null
                                                                  and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                         )
          and exists (select 1 from ubrr_data.ubrr_rko_tarif v, ubrr_data.ubrr_rko_tarif_otdsum o
                       where v.Parent_IdSmr = BankIdSmr and v.com_type = 'VZN'
                         and v.id = o.id_com and o.otd = acc.iaccotd)
         --<< ubrr 21.10.2016 �������� �.�. 16-2222.2 �������� �� ����� ��������� ���
     )group by ctrnaccc,ctrncurc, otdcbat, otd_acc, TypeCom  -->><< ubrr 06.10.2016 �������� �.�.   [16-2222]  #35311  ���������� �������� �� �������� �������� �����
     --having sum(sumcom)>0
     );
     l_step:='060'; -- 06.03.2019 ������� �.�. #60267 ������ ��� �������� ���������� ��������. ������� �������� ��������
     iCnt1 := SQL%ROWCOUNT;
     iCnt := iCnt + iCnt1;
     WriteProtocol('��������� �������� �� ����� � ���������� ��������: '||iCnt1);
     COMMIT;

     RETURN iCnt;
  exception
    WHEN OTHERS THEN
      ROLLBACK;
      WriteProtocol('������ ��� ������� �������� �� �� � ����� � ���������� ��������: (l_step='||l_step||') '||SQLErrm);
      p_Mess := '������ ��� ������� �������� �� �� � ����� � ���������� ��������: (l_step='||l_step||') '||SQLErrm;
      RETURN -1;
  end CalcCashCom;

-----------------------------------------------------------------------------------------
  function CalcRKOComiss (portion_date1 in date,
                          portion_date2 in date,
                          p_ls in varchar2 default null, -- ���� ��� ������� ��������
                          p_dtran in date,
                          p_Mess out varchar2
  ) RETURN number
  is
    acc_1       varchar2(25) := nvl(p_ls,'40___810%');
    iCnt NUMBER;
  begin
     INSERT INTO ubrr_data.ubrr_sbs_new
      (cSBSaccd, cSBScurd, cSBSTypeCom, mSBSsumpays, iSBScountPays, mSBSsumcom, iSBSotdnum, iSBSBatNum, dSBSDate, iSBSTypeCom, dsbsdatereg)
     select caccacc, cacccur, typecom, 0, 0,
            GetSumComiss(NULL, NULL, caccacc, cacccur, iaccotd, typecom, 0, 0),
            iaccotd, to_number(to_char(NVL(iOTDbatnum,70) )||'00') batnum, portion_date2, 101, p_dtran  -->><<-- ubrr 23.09.2016 �������� �.�. 16-2222 ��������� ����� ����������� ��������
     from (
       select caccacc, cacccur, iaccotd, iotdbatnum,
              case when exists (select 1 from gac
                                where cgacacc = caccacc
                                  and cgaccur = cacccur
                                  and igaccat = 105
                                  and igacnum in (1,2,8,9,11)
                               )
                   then 'RKB'
                   else 'RKO'
              end typecom
       from acc, otd
       where acc.caccacc like acc_1
         and acc.cacccur = 'RUR'
         and acc.cACCprizn <> '�'
         and acc.daccopen<=portion_date2
         and acc.iaccbs2 not in (40813,40817,40818,40820,42309,40810,40811,40812,40823,40824)
         and substr(acc.caccacc,1,3) not in ('401','402','403','404','409')
         and otd.iotdnum = acc.iaccotd
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
                                         and d_create <= portion_date2
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
         -->>04.07.2019 �������� [19-62974] II ���� ���.����.�����. ��������������� ������� ����� ����� �� ���
         and (not exists (select 1
                          from gac g
                         where g.cgacacc = acc.caccacc
                           and g.cgaccur = acc.cacccur
                           and g.igaccat = 112
                           and g.igacnum in (100,101,102, 104,105,106)
                           and exists (select 1
                                         from xxi.au_attach_obg au
                                        where au.caccacc = g.cgacacc
                                          and au.cacccur = g.cgaccur
                                          and au.i_table = 304
                                          and au.d_create <= portion_date2
                                          and au.c_newdata = '112/'||g.igacnum))
         )
         and not exists (select 1
                           from gac
                           where cgacacc = acc.cACCacc
                             and cgaccur = acc.cACCcur
                             and igaccat = 114
                             and igacnum = 16)
         --<<04.07.2019 �������� [19-62974] II ���� ���.����.�����. ��������������� ������� ����� ����� �� ���
         -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
         and not exists ( select 1
                            from gac g
                                ,ubrr_rko_exinc_catgr e
                           where g.igaccat   = e.icat
                             and g.igacnum   = e.igrp
                             and e.ccom_type in ('RKO', 'RKB')
                             and e.exinc     = 0
                             and g.cgacacc   = acc.caccacc
                             and g.cgaccur   = acc.cACCcur
                             and exists (select 1
                                           from xxi.au_attach_obg au
                                          where au.caccacc = acc.caccacc
                                            and au.cacccur = acc.cacccur
                                            and au.i_table = 304
                                            and trunc(au.d_create) <= portion_date2
                                            and au.c_newdata = e.icat||'/'||e.igrp
                                            and trunc(au.d_create) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end) --<<22.01.2020 �������� [19-64846]
                                        )
                        )
         --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
         and exists (select 1 from ubrr_data.ubrr_rko_tarif v, ubrr_data.ubrr_rko_tarif_otdsum o
                     where v.Parent_IdSmr = BankIdSmr and v.com_type IN ('RKO', 'RKB')  -->><<-- ubrr 23.09.2016 �������� �.�. 16-2222 ���������� �������� ������
                       and v.id = o.id_com and o.otd = acc.iaccotd)
         and not exists (select 1 from ubrr_data.ubrr_sbs_new where idsmr = acc.idsmr and dSBSdate = portion_date2
                                                                and cSBSaccd = acc.caccacc and cSBScurd = acc.cacccur
                                                                and cSBSTypeCom in ('RKB', 'RKO')
                                                                and iSBStrnnum is not null)
     );
     iCnt := SQL%ROWCOUNT;
     WriteProtocol('��������� �������� �� ���: '||iCnt);
     COMMIT;
     -- >> 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
     iCnt := ubrr_bnkserv_calc_new_lib.Analize_Accounts_For_RKO( portion_date1 => portion_date1
                                                                ,portion_date2 => portion_date2
                                                                ,dtran         => p_dtran
                                                                ,p_ls          => acc_1
                                                                ,p_calc_table  => ubrr_bnkserv_calc_new_lib.gc_calc_table_sbs_new );
     -- << 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
     RETURN iCnt;
  exception
    WHEN OTHERS THEN
      ROLLBACK;
      WriteProtocol('������ ��� ������� �������� �� ���: '||SQLErrm);
      p_Mess := '������ ��� ������� �������� �� ���: '||SQLErrm;
      RETURN -1;
  end;


  function CalcSmsComiss (portion_date1 in date,
                          portion_date2 in date,
                          p_ls in varchar2 default null, -- ���� ��� ������� ��������
                          p_Dtran in DATE,
                          p_Mess out varchar2
  ) RETURN number
  is
    acc_1       varchar2(25) := nvl(p_ls,'40___810%');
    type t_tAccList Is Table of xxi."acc"%rowtype index by binary_integer;
    tAccList t_tAccList;
    iAccSel Integer;
    nOst Number;
    nOstMax Number;
    dOstDate Date;
    ost_vr Number;
    ost_rr Number;
    ost_vp Number;
    deb_dark Number;
    cred_dark Number;
    iCurIdSmr Number:=ubrr_get_context;
    vSumCom NUMBER;
    iCnt Number := 0;
    viOtdbatnum NUMBER;
  Begin
    delete from ubrr_data.ubrr_sbs_ext e
    where e.csbsdo='R_SMS' and e.idsmr=iCurIdSmr;

    For Cr In (
               Select * From ubrr_data.sms_coms c
               Where ddate between portion_date1 and portion_date2+0.99999
                -- ��������� (�� ����� �����) �� ������ ��������, � ������� ������ ������� "������� ���-���������" - ���/�� 112/77
                and not exists
                    (select '1' from xxi.GCS g
                     where g.igcscus=c.icusnum and g.igcscat=112 and g.igcsnum=77
                           and exists (select '1'
                                        from xxi.AU_ATTACH_OBG o
                                        where o.I_TABLE=303 and o.i_num=c.icusnum
                                            and o.c_newdata='112/77'
                                            and o.d_create<=c.ddate)
                    )
                    -- ��������� (�� ����� �����) �� ������ ��������, � ������� ��������� ������� ����� SMS
                and not exists
                    (select '1' from xxi.GCS g
                     where g.igcscus=c.icusnum and g.igcscat=112 and g.igcsnum=1010
                           and exists (select '1'
                                        from xxi.AU_ATTACH_OBG o
                                        where o.I_TABLE=303 and o.i_num=c.icusnum
                                            and o.c_newdata='112/1010'
                                            and o.d_create<=c.ddate)
                    )
                and not exists (select 1 from ubrr_data.ubrr_sbs_new s, xxi."acc" a where a.iacccus = c.icusnum
                                                                and s.idsmr = a.idsmr and dSBSdate = portion_date2
                                                                and cSBSaccd = a.caccacc and cSBScurd = a.cacccur
                                                                and cSBSTypeCom in ('R_SMS')
                                                                and iSBStrnnum is not null)
    ) Loop
      tAccList.delete;
      dbms_output.put_line( '================');
      dbms_output.put_line( '������ '||Cr.icusnum);

      Begin
        -- ��� �/� ���������� ����, ������� ������������� ����� 40%810%, � ������������ ���/�� 3/36, �� �������� "������".
        Select *
        Bulk Collect Into tAccList
        From ubrr_acc_v a
        Where a.IACCCUS=Cr.icusnum and a.caccprizn<>'�'
          and a.caccacc LIKE acc_1
          and a.cacccur = 'RUR'
          and exists
           (
            select '1' from xxi."gac" ga
            where ga.CGACACC=a.caccacc and ga.CGACCUR=a.cacccur
              and ga.IGACCAT=3 and ga.IGACNUM=36
              and ga.idsmr=a.idsmr
           )
          and not exists (select 1
                          from gac
                         where cgacacc = a.cACCacc
                           and igaccat = 112
                           and igacnum = 1014  -- ��� �� �������
                           and exists (select 1
                                       from xxi.au_attach_obg au
                                       where au.caccacc = a.cACCacc
                                         and au.cacccur = a.cACCcur
                                         and i_table = 304
                                         and d_create <= portion_date2
                                         and au.c_newdata = '112/1014'))
         and not exists (select 1
                          from gac
                         where cgacacc = a.cACCacc
                           and igaccat = 112
                           and igacnum = 10)
            -- ��������� �� ������� ��� �/� ������� , ������� ���������� � ������ <����-�����> � <����-����� ����>(112/32,112/75)
          and not exists
            (
             select '1' from xxi.gac ga
             where ga.CGACACC=a.caccacc and ga.CGACCUR=a.cacccur
               and (
                    ga.IGACCAT=112 and ga.IGACNUM In (35, 72)
                    or
                    ga.IGACCAT=333 and ga.IGACNUM=2
                   )
               and ga.idsmr=a.idsmr
                )
         -->> ubrr 23.09.2016 �������� �.�. 16-2222 �������� �� ������ "��������"
         and not (exists (select 1
                     from gac
                     where cgacacc = a.cACCacc
                       and igaccat = 105
                       and igacnum = 11
                       and exists (select 1
                                   from xxi.au_attach_obg au
                                   where au.caccacc = a.cACCacc
                                     and au.cacccur = a.cACCcur
                                     and i_table = 304
                                     and d_create <= portion_date2
                                     and au.c_newdata = '105/11'))
                   and exists (select 1
                     from gac
                     where cgacacc = a.cACCacc
                       and igaccat = 114
                       and igacnum = 12
                       and exists (select 1
                                   from xxi.au_attach_obg au
                                   where au.caccacc = a.cACCacc
                                     and au.cacccur = a.cACCcur
                                     and i_table = 304
                                     and d_create <= portion_date2
                                     and au.c_newdata = '114/12'))

            )
         --<< ubrr 23.09.2016 �������� �.�. 16-2222 �������� �� ������ "��������"
         -->>04.07.2019 �������� [19-62974] II ���� ���.����.�����. ��������������� ������� ����� ����� �� ���
         and (not exists (select 1
                          from gac g
                         where g.cgacacc = a.caccacc
                           and g.cgaccur = a.cacccur
                           and g.igaccat = 112
                           and g.igacnum in (100,101,102, 104,105,106)
                           and exists (select 1
                                         from xxi.au_attach_obg au
                                        where au.caccacc = g.cgacacc
                                          and au.cacccur = g.cgaccur
                                          and au.i_table = 304
                                          and au.d_create <= portion_date2
                                          and au.c_newdata = '112/'||g.igacnum))
         )
         and not exists (select 1
                           from gac
                           where cgacacc = a.cACCacc
                             and cgaccur = a.cACCcur
                             and igaccat = 114
                             and igacnum = 16)
         --<<04.07.2019 �������� [19-62974] II ���� ���.����.�����. ��������������� ������� ����� ����� �� ���
         -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
         and not exists ( select 1
                            from gac g
                                ,ubrr_rko_exinc_catgr e
                           where g.igaccat   = e.icat
                             and g.igacnum   = e.igrp
                             and e.ccom_type = 'R_SMS'
                             and e.exinc     = 0
                             and g.cgacacc   = a.caccacc
                             and g.cgaccur   = a.cACCcur
                             and exists (select 1
                                           from xxi.au_attach_obg au
                                          where au.caccacc = a.caccacc
                                            and au.cacccur = a.cacccur
                                            and au.i_table = 304
                                            and trunc(au.d_create) <= portion_date2
                                            and au.c_newdata = e.icat||'/'||e.igrp
                                            and trunc(au.d_create) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end) --<<22.01.2020 �������� [19-64846]
                                        )
                        )
         --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
         ;
      Exception
        When No_Data_Found Then
          Null;
      End;
      dbms_output.put_line( '���-�� ������ '||nvl(tAccList.Count, 0));
      if nvl(tAccList.Count, 0)>0 Then
        iAccSel:=Null;
        nOstMax:=-99e99;
        -- ������� �� ���������� ������� ������, � ������� �������, ����� �/� � ���������� �������� �� ���� �������
        For i In tAccList.first..tAccList.last Loop
          dbms_output.put_line( '���� '||tAccList(i).caccacc||' ������ '||tAccList(i).caccprizn||' ������ '||tAccList(i).idsmr);
          If tAccList(i).idsmr=iCurIdSmr Then
            UTIL_DM2.Acc_Ost2(0, tAccList(i).caccacc, 'RUR', p_dtran,
                              ost_vr, ost_rr, ost_vp, deb_dark, cred_dark);
            IF tAccList(i).caccap='�' THEN
              ost_vr := -ost_vr;
              ost_rr := -ost_rr;
              ost_vp := -ost_vp;
            END IF;
            dbms_output.put_line( '������� '||ost_vr);
            If ost_vr>nOstMax Then
              nOstMax:=ost_vr;
              iAccSel:=i;
            End If;
          End If;
        End Loop;

        If iAccSel Is Not Null /*And nOstMax>0*/ Then
          dbms_output.put_line( '������ ���� '||tAccList(iAccSel).caccacc||' � ����. �������� '||nOstMax||' �� '||to_char(p_dtran, 'dd.mm.rrrr'));

          vSumCom := GetSumComiss(NULL,NULL, tAccList(iAccSel).caccacc, 'RUR', tAccList(iAccSel).iaccotd, 'R_SMS', 0, 0);
          IF vSumCom>0 then
            begin
             select iotdbatnum
             into viOtdbatnum
             from otd where iotdnum = tAccList(iAccSel).iaccotd;
            exception
              when others then
                viOtdbatnum:=NULL;
            end;
            INSERT INTO ubrr_data.ubrr_sbs_new
              (cSBSaccd, cSBScurd, cSBSTypeCom, mSBSsumpays, iSBScountPays, mSBSsumcom, iSBSotdnum, iSBSBatNum, dSBSDate, iSBSTypeCom, dsbsdatereg)
            values
              (tAccList(iAccSel).caccacc, 'RUR', 'R_SMS', 0, 1, vSumCom, tAccList(iAccSel).iaccotd, to_number(to_char(NVL(viOTDbatnum,70) )||'00'), portion_date2, 102, p_Dtran);  -->><<-- ubrr 23.09.2016 �������� �.�. 16-2222 ��������� ����� ����������� ��������
            iCnt := iCnt+1;
          END IF;
        END IF;
        tAccList.delete;
      end if;
    end loop;
    WriteProtocol('��������� �������� SMS-��������������: '||iCnt);
    COMMIT;

    RETURN iCnt;
  exception
    WHEN OTHERS THEN
      ROLLBACK;
      WriteProtocol('������ ��� ������� �������� �� SMS-��������������: '||SQLErrm);
      p_Mess := '������ ��� ������� �������� �� SMS-��������������: '||SQLErrm;
      RETURN -1;
  end;

  function CalcClubComiss(portion_date1 in date,
                          portion_date2 in date,
                          p_ls in varchar2 default null, -- ���� ��� ������� ��������
                          p_Dtran in DATE,
                          p_Mess out varchar2
  ) RETURN number
  is
    acc_1       varchar2(25) := nvl(p_ls,'40___810%');
    type t_tAccList Is Table of xxi."acc"%rowtype index by binary_integer;
    tAccList t_tAccList;
    iAccSel Integer;
    iAccSel1 Integer;
    nOst Number;
    nOstMax Number;
    dAccDate Date;
    dAccDate1 Date;
    ost_vr Number;
    ost_rr Number;
    ost_vp Number;
    deb_dark Number;
    cred_dark Number;
    iCurIdSmr Number:=ubrr_get_context;
    vSumCom NUMBER;
    iCnt Number := 0;
    viOtdbatnum NUMBER;
  Begin
    For Cr In (select icusnum, decode(igcsnum, 1011, 'BIZ', 1012, 'BIZP', '-') TypeC, igcsnum -->><<--07.08.2019 �������� [19-62974] III ���� ���.
               from xcus, gcs
               where gcs.igcscus = icusnum
                 and gcs.igcscat = 112
                 and gcs.igcsnum in (1011, 1012) -- ������ � ������-�������
                 and exists (select '1'
                             from xxi.AU_ATTACH_OBG o
                             where o.I_TABLE=303 and o.i_num=xcus.icusnum
                               and o.c_newdata='112/'||igcsnum
                               and o.d_create<=dDateR
                             )
                 and exists (select 1 from acc where iacccus = xcus.icusnum and caccacc like acc_1)
                 and not exists (select 1 from ubrr_data.ubrr_sbs_new s, xxi."acc" a where a.iacccus = xcus.icusnum
                                                                and s.idsmr = a.idsmr and dSBSdate = portion_date2
                                                                and cSBSaccd = a.caccacc and cSBScurd = a.cacccur
                                                                and cSBSTypeCom in decode(igcsnum, 1011, 'BIZ', 1012, 'BIZP', '-')
                                                                and iSBStrnnum is not null)
    ) Loop
      tAccList.delete;
      dbms_output.put_line( '================');
      dbms_output.put_line( '������ '||Cr.icusnum);

      Begin
        Select *
        Bulk Collect Into tAccList
        From ubrr_acc_v a
        Where a.IACCCUS=Cr.icusnum and a.caccprizn<>'�'
          and regexp_like (a.caccacc, '^(401|402|403|404|405|406|407|40802|40807)')
          and a.cacccur = 'RUR'
          and not exists (select 1
                          from gac
                         where cgacacc = a.cACCacc
                           and igaccat = 333
                           and igacnum = 2)
          and not exists (select 1
                          from gac
                         where cgacacc = a.cACCacc
                           and igaccat = 112
                           and igacnum = 1014  -- ��� �� �������
                           and exists (select 1
                                       from xxi.au_attach_obg au
                                       where au.caccacc = a.cACCacc
                                         and au.cacccur = a.cACCcur
                                         and i_table = 304
                                         and d_create <= portion_date2
                                         and au.c_newdata = '112/1014'));
      Exception
        When No_Data_Found Then
          Null;
      End;
      dbms_output.put_line( '���-�� ������ '||nvl(tAccList.Count, 0));
      if nvl(tAccList.Count, 0)>0 Then
        iAccSel:=Null;
        iAccSel1:=Null;
        nOstMax:=0;
        dAccDate := null;
        dAccDate1 := null;
        -- ������� �� ���������� ������� ������, � ������� �������, ����� �/� � ���������� �������� �� ���� �������
        For i In tAccList.first..tAccList.last Loop
          dbms_output.put_line( '���� '||tAccList(i).caccacc||' ������ '||tAccList(i).caccprizn||' ������ '||tAccList(i).idsmr);
          If tAccList(i).idsmr=iCurIdSmr Then
            UTIL_DM2.Acc_Ost2(0, tAccList(i).caccacc, 'RUR', p_dtran,
                               ost_vr, ost_rr, ost_vp, deb_dark, cred_dark);
            IF tAccList(i).caccap='�' THEN
              ost_vr := -ost_vr;
              ost_rr := -ost_rr;
              ost_vp := -ost_vp;
            END IF;
            dbms_output.put_line( '������� '||ost_vr);
            If ost_vr>nOstMax or (ost_vr=nOstMax and nOstMax>0 and (dAccDate is null or tAccList(i).daccopen<dAccDate)) Then
              nOstMax:=ost_vr;
              iAccSel:=i;
            End If;
            if dAccdate is null or dAccDate1>tAccList(i).daccopen then -- ����� ������ �� ����
              iAccSel1 := i;
              dAccDate1 := tAccList(i).daccopen;
            end if;
          End If;
        End Loop;
        iAccSel:=nvl(iAccSel, iAccSel1);

        If iAccSel Is Not Null /*And nOstMax>0*/ Then
          dbms_output.put_line( '������ ���� '||tAccList(iAccSel).caccacc||' � ����. �������� '||nOstMax||' �� '||to_char(p_dtran, 'dd.mm.rrrr'));

          -->>07.08.2019 �������� [19-62974] III ���� ���.
          WriteProtocol('������ ���� '||tAccList(iAccSel).caccacc||' � ����. �������� '||nOstMax||' �� '||to_char(p_dtran, 'dd.mm.rrrr'));
          if not ubrr_bnkserv_calc_new_lib.have_kartoteka( p_caccacc   => tAccList(iAccSel).caccacc
                                                          ,p_cacccur   => tAccList(iAccSel).cacccur
                                                          ,p_date_tran => p_dtran ) --�� ����� ��� ��������� ������ ����� ������
          then
            WriteProtocol('�� ����� '||tAccList(iAccSel).caccacc||' ��� ��������� ������ ����� ������');
          --<<07.08.2019 �������� [19-62974] III ���� ���.
          vSumCom := GetSumComiss(NULL,NULL, tAccList(iAccSel).caccacc, 'RUR', tAccList(iAccSel).iaccotd, Cr.TypeC, 0, 0);
          IF vSumCom>0 then
            begin
             select iotdbatnum
             into viOtdbatnum
             from otd where iotdnum = tAccList(iAccSel).iaccotd;
            exception
              when others then
                viOtdbatnum:=NULL;
            end;
            INSERT INTO ubrr_data.ubrr_sbs_new
              (cSBSaccd, cSBScurd, cSBSTypeCom, mSBSsumpays, iSBScountPays, mSBSsumcom, iSBSotdnum, iSBSBatNum, dSBSDate, iSBSTypeCom, dsbsdatereg)
            values
              (tAccList(iAccSel).caccacc, 'RUR', Cr.TypeC, 0, 1, vSumCom, tAccList(iAccSel).iaccotd, to_number(to_char(NVL(viOTDbatnum,70) )||'00'), portion_date2, 103, p_Dtran);  -->><<-- ubrr 23.09.2016 �������� �.�. 16-2222 ��������� ����� ����������� ��������
            iCnt := iCnt+1;
          END IF;
          -->>07.08.2019 �������� [19-62974] III ���� ���. � 2.2 ��
          else --�� ����� ���� ��������� ������ ����� ������
            declare
              Cnt  number;
            begin
              WriteProtocol('�� ����� '||tAccList(iAccSel).caccacc||' ���� ��������� ������ ����� ������');
              select count(1)
                into Cnt
                from gcs
               where igcscus = Cr.icusnum
                 and igcscat = 112
                 and igcsnum = Cr.igcsnum;
              if Cnt > 0 then
                delete from gcs
                 where igcscus = Cr.icusnum
                   and igcscat = 112
                   and igcsnum = Cr.igcsnum; --������� ��������� ������ �����

                WriteProtocol('�������� ��������� ������ ('||Cr.igcsnum||') ����� � ������� '||Cr.icusnum||'. ������� '||sql%rowcount);--test

                update xxi.au_attach_obg o
                   set o.d_create = last_day(p_Dtran) --��������� ��� ���������� ������
                 where o.i_table = 303
                   and o.c_type = 'D'
                   and o.i_num = Cr.icusnum
                   and o.c_olddata = '112/'||Cr.igcsnum
                   and o.d_create = (select max(o1.d_create)
                                       from xxi.au_attach_obg o1
                                      where o1.i_table = 303
                                        and o1.c_type = 'D'
                                        and o1.i_num = Cr.icusnum
                                        and o1.c_olddata = '112/'||Cr.igcsnum);

                WriteProtocol('�������� ��������� ��� ���������� ������. ��������� '||sql%rowcount);--test

                -->>16.08.2019 �������� [19-62974] III ���� ��� https://redmine.lan.ubrr.ru/issues/63953#note-11 �.1
                for rr in (select a.caccacc, g.igaccat, g.igacnum
                             from acc a, gac g
                            where a.iacccus = Cr.icusnum
                              and a.caccprizn <> '�'
                              and g.cgacacc = a.caccacc
                              and g.igaccat = 112
                              and g.igacnum in (1011, 1012) )
                loop
                  delete from gac
                   where cgacacc = rr.caccacc
                     and igaccat = 112
                     and igacnum = rr.igacnum;

                  WriteProtocol('�������� ��������� ������ ('||rr.igacnum||') ����� � ����� '||rr.caccacc||' ������� '||Cr.icusnum||'. ������� '||sql%rowcount);--test

                  update xxi.au_attach_obg o
                     set o.d_create = last_day(p_Dtran) --��������� ��� ���������� ������
                   where o.i_table = 304
                     and o.c_type = 'D'
                     and o.caccacc = rr.caccacc
                     and o.c_olddata = '112/'||rr.igacnum
                     and o.d_create = (select max(o1.d_create)
                                         from xxi.au_attach_obg o1
                                        where o1.i_table = 304
                                          and o1.c_type = 'D'
                                          and o1.caccacc = rr.caccacc
                                          and o1.c_olddata = '112/'||rr.igacnum);
                  WriteProtocol('�������� ��������� ��� ���������� ������. ��������� '||sql%rowcount);--test
                end loop;
                --<<16.08.2019 �������� [19-62974] III ���� ��� https://redmine.lan.ubrr.ru/issues/63953#note-11 �.1
        END IF;
            end;
          end if;
          --<<07.08.2019 �������� [19-62974] III ���� ���. � 2.2 ��
        END IF;
        tAccList.delete;
      end if;
    end loop;
    WriteProtocol('��������� �������� �� �������������� ����� �� ������� �����: '||iCnt);
    COMMIT;

    RETURN iCnt;
  exception
    WHEN OTHERS THEN
      ROLLBACK;
      WriteProtocol('������ ��� ������� �������� �� �������������� ����� �� ������� �����: '||SQLErrm);
      p_Mess := '������ ��� ������� �������� �� �������������� ����� �� ������� �����: '||SQLErrm;
      RETURN -1;
  end;


  -->> ubrr 23.09.2016 �������� �.�. 16-2222 �������� �� ������ "��������"
  function CalcSvetoforComiss (portion_date1 in date,
                               portion_date2 in date,
                               p_ls in varchar2 default null, -- ���� ��� ������� ��������
                               p_dtran in date,
                               p_Mess out varchar2
  ) RETURN number
  is
    acc_1       varchar2(25) := nvl(p_ls,'40___810%');
    iCnt NUMBER;
    iRes NUMBER; -->><<--08.11.2018 �������� [18-592.2] ���. ������� �������� �� ���������
  begin
     INSERT INTO ubrr_data.ubrr_sbs_new
      (cSBSaccd, cSBScurd, cSBSTypeCom, mSBSsumpays, iSBScountPays, mSBSsumcom, iSBSotdnum, iSBSBatNum, dSBSDate, iSBSTypeCom, dsbsdatereg)
     select caccacc, cacccur, typecom, 0, 0,
            GetSumComiss(NULL, NULL, caccacc, cacccur, iaccotd, typecom, 0, 0),
            iaccotd, to_number(to_char(NVL(iOTDbatnum,70) )||'00') batnum, portion_date2, 104, p_dtran
     from (
       select caccacc, cacccur, iaccotd, iotdbatnum, 'SVET' typecom
       from acc, otd
       where acc.caccacc like acc_1
         and acc.cacccur = 'RUR'
         and acc.cACCprizn <> '�'
         and acc.daccopen<=portion_date2
         and acc.iaccbs2 not in (40813,40817,40818,40820,42309,40810,40811,40812,40823,40824)
         and substr(acc.caccacc,1,3) not in ('401','402','403','404','409')
         and otd.iotdnum = acc.iaccotd
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
                                         and d_create <= portion_date2
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
         and exists (select 1
                     from gac
                     where cgacacc = acc.cACCacc
                       and igaccat = 105
                       and igacnum = 11
                       and exists (select 1
                                   from xxi.au_attach_obg au
                                   where au.caccacc = acc.cACCacc
                                     and au.cacccur = acc.cACCcur
                                     and i_table = 304
                                     and d_create <= portion_date2
                                     and au.c_newdata = '105/11'))
         and exists (select 1
                     from gac
                     where cgacacc = acc.cACCacc
                       and igaccat = 114
                       and igacnum = 12
                       and exists (select 1
                                   from xxi.au_attach_obg au
                                   where au.caccacc = acc.cACCacc
                                     and au.cacccur = acc.cACCcur
                                     and i_table = 304
                                     and d_create <= portion_date2
                                     and au.c_newdata = '114/12'))
         and exists (select 1 from ubrr_data.ubrr_rko_tarif v, ubrr_data.ubrr_rko_tarif_otdsum o
                     where v.Parent_IdSmr = BankIdSmr and v.com_type IN ('SVET')
                       and v.id = o.id_com and o.otd = acc.iaccotd)
         and not exists (select 1 from ubrr_data.ubrr_sbs_new where idsmr = acc.idsmr and dSBSdate = portion_date2
                                                                and cSBSaccd = acc.caccacc and cSBScurd = acc.cacccur
                                                                and cSBSTypeCom in ('SVET')
                                                                and iSBStrnnum is not null)
     );
     iCnt := SQL%ROWCOUNT;
     WriteProtocol('��������� �������� �� ������ "��������": '||iCnt);


    -->>02.11.2018 �������� [18-592.2] ���. ������� �������� �� ���������
    iRes := iCnt;
    declare
        type t_tAccList Is Table of acc%rowtype index by binary_integer;
        tAccList t_tAccList;

        iAccSel    integer;
        --nOst       number;
        nOstMax    number;
        dOstDate   date;
        ost_vr     number;
        ost_rr     number;
        ost_vp     number;
        deb_dark   number;
        cred_dark  number;
        iCurIdSmr  number := ubrr_get_context;
        v          varchar2(100);
    begin
        iCnt := 0;
        WriteProtocol('R_IB_LT ������� �������� �� ���������. ������');

        delete from ubrr_data.ubrr_sbs_new e
         where e.CSBSTYPECOM = 'R_IB_LT'
           -->>29.01.2019 �������� [18-592.2] ���. ������� �������� �� ���������
           and e.isbstrnnum is null
           and e.cSBSaccd like acc_1
           --<<29.01.2019 �������� [18-592.2] ���. ������� �������� �� ���������
           and e.idsmr = iCurIdSmr
           and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
           ;

        for Cr IN (select icusnum, click_count, click_summa
                     from correqts.v_ubrr_kontur_counter@cts
                    where click_month between portion_date1 and portion_date2)
        loop
            tAccList.delete;

            select *
            bulk collect into tAccList
            from acc a
            where a.IACCCUS=Cr.icusnum
              and a.caccprizn <> '�'
              and a.caccprizn  = '�'
              and a.caccacc like acc_1
              and a.cacccur = 'RUR'
              and exists (select 1
                            from gac g
                           where g.cgacacc = a.caccacc
                             and g.cgaccur = a.cacccur
                             and g.igaccat = 3 and g.igacnum = 36
                             and not exists (select 1
                                               from gac g1
                                              where g1.cgacacc = g.cgacacc
                                                and g1.cgaccur = g.cgaccur
                                                and g1.idsmr = g.idsmr
                                                and g1.igaccat = 333 and g1.igacnum = 2));
            if nvl(tAccList.Count, 0) = 0 then
                select *
                bulk collect into tAccList
                from acc a
                where a.IACCCUS=Cr.icusnum
                  and a.caccprizn <> '�'
                  and a.caccprizn <> '�'
                  and a.caccacc like acc_1
                  and a.cacccur = 'RUR'
                  and exists (select 1
                                from gac g
                               where g.cgacacc = a.caccacc
                                 and g.cgaccur = a.cacccur
                                 and g.igaccat = 3 and g.igacnum = 36
                                 and not exists (select 1
                                                   from gac g1
                                                  where g1.cgacacc = g.cgacacc
                                                    and g1.cgaccur = g.cgaccur
                                                    and g1.idsmr = g.idsmr
                                                    and g1.igaccat = 333 and g1.igacnum = 2));
            end if;
            WriteProtocol('R_IB_LT ������ ' || Cr.icusnum || '. ���-�� ������ ' || nvl(tAccList.Count, 0));
            if nvl(tAccList.Count, 0) > 0 then
                iAccSel := NULL;
                nOstMax := -99e99;
                -- ������� �� ���������� ������� ������, � ������� �������, ����� �/� � ���������� �������� �� ���� �������
                for i IN tAccList.first .. tAccList.last loop
                    if tAccList(i).idsmr = iCurIdSmr
                    then
                        UTIL_DM2.Acc_Ost2(0, tAccList(i).caccacc, tAccList(i).cacccur, p_dtran, ost_vr, ost_rr, ost_vp, deb_dark, cred_dark);
                        IF tAccList(i).caccap='�' THEN
                            ost_vr := -ost_vr;
                            ost_rr := -ost_rr;
                            ost_vp := -ost_vp;
                        END IF;
                        if ost_vr > nOstMax then
                            nOstMax := ost_vr;
                            iAccSel := i;
                        end if;
                    end if;
                end loop;

                if iAccSel is not null then
                    WriteProtocol('R_IB_LT ������ ���� ' || tAccList(iAccSel).caccacc || ' � ����. �������� ' || nOstMax || ' �� ' || to_char(p_dtran, 'dd.mm.rrrr') || ', � ���-�� ������: ' || Cr.click_count);

                    insert into ubrr_data.ubrr_sbs_new
                     (cSBSaccd, cSBScurd, cSBSTypeCom, mSBSsumpays, iSBScountPays, mSBSsumcom, mSBSTarif, iSBSotdnum, iSBSBatNum, dSBSDate, iSBSTypeCom, dsbsdatereg, ccomment)
                    select caccacc, cacccur, typecom, 0, 0,
                           Cr.click_summa, --����� ���������
                           0,
                           iaccotd, to_number(to_char(NVL(iOTDbatnum,70) )||'00') batnum, portion_date2, 104, p_dtran, Cr.click_count
                    from (
                      select caccacc, cacccur, iaccotd, iotdbatnum, 'R_IB_LT' typecom
                      from acc, otd
                      where acc.caccacc like tAccList(iAccSel).caccacc
                        and acc.cacccur = 'RUR'
                        and acc.cACCprizn <> '�'
                        and acc.daccopen<=portion_date2
                        and acc.iaccbs2 not in (40813,40817,40818,40820,42309,40810,40811,40812,40823,40824)
                        and substr(acc.caccacc,1,3) not in ('401','402','403','404','409')
                        and otd.iotdnum = acc.iaccotd
                        and not exists (select 1
                                         from gac
                                         where cgacacc = acc.cACCacc
                                           and igaccat = 114
                                           and igacnum = 12
                                           and exists (select 1
                                                       from xxi.au_attach_obg au
                                                       where au.caccacc = acc.cACCacc
                                                         and au.cacccur = acc.cACCcur
                                                         and i_table = 304
                                                         and d_create <= portion_date2
                                                         and au.c_newdata = '114/12'))
                        and not exists (select 1 from ubrr_data.ubrr_sbs_new where idsmr = acc.idsmr and dSBSdate = portion_date2
                                                                               and cSBSaccd = acc.caccacc and cSBScurd = acc.cacccur
                                                                               and cSBSTypeCom in ('R_IB_LT')
                                                                               and iSBStrnnum is not null)
                    );

                    iCnt := iCnt + sql%rowcount;

                end if;
            else
                WriteProtocol('R_IB_LT �� ������ ���� ��� �������� �������� ������ � ' || Cr.icusnum /*|| ' ' ||  to_char(Cr.ddate, 'dd.mm.rrrr hh24:mi:ss')*/);

            end if;
        end loop;
        tAccList.delete;
    end;
    WriteProtocol('R_IB_LT ��������� ������� �������� �� ���������: ' || iCnt);
    iRes := iRes + iCnt;
    --<<02.11.2018 �������� [18-592.2] ���. ������� �������� �� ���������

     COMMIT;

     RETURN iRes /*iCnt*/;  -->><<--08.11.2018 �������� [18-592.2] ���. ������� �������� �� ���������
  exception
    WHEN OTHERS THEN
      ROLLBACK;
      WriteProtocol('������ ��� ������� �������� �� ������ "��������": '||SQLErrm);
      p_Mess := '������ ��� ������� �������� �� ������ "��������": '||SQLErrm;
      RETURN -1;
  end;
  --<< ubrr 23.09.2016 �������� �.�. 16-2222 �������� �� ������ "��������"

-->>> ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���
----------------------------------------------------------
-- ���������� �������� sbs_new, sbs_ext ��� ������� �������� �� ������� ���
  function calc_krc_managment_new ( p_portion_date1 in date
                                   ,p_portion_date2 in date
                                   ,p_ls            in varchar2                  -- ���� ��� ������� ��������
                                   ,p_dtran         in date
                                   ,p_mess          in out nocopy varchar2
                                   ,p_idsmr         in varchar2
  ) return number
is
  l_tbl_krc_rc    ubrr_xxi5.ubrr_bnkserv_krc.t_tbl_krc_rc;
  l_tbl_sbs_new   ubrr_xxi5.ubrr_bnkserv_krc.t_tbl_sbs_new;
  l_tbl_sbs_ext   ubrr_xxi5.ubrr_bnkserv_krc.t_tbl_sbs_ext;

  l_ins_sbs boolean;
  l_idx     number;
  l_cnt_suc number:=0;
  l_cnt_err number:=0;
begin
   ubrr_bnkserv_krc.clear_sbs_ext_krc( p_idsmr => p_idsmr
                                      ,p_ls    => p_ls );

   ubrr_bnkserv_krc.clear_sbs_new_zam( p_idsmr => p_idsmr
                                      ,p_date  => p_portion_date2
                                      ,p_ls    => p_ls );

   dbms_transaction.commit;

   if ubrr_bnkserv_krc.g_cur_list_krc_rc%isopen then
      close ubrr_bnkserv_krc.g_cur_list_krc_rc;
   end if;

   open ubrr_bnkserv_krc.g_cur_list_krc_rc( p_ls, p_portion_date1, p_portion_date2, p_idsmr );
   loop
     l_tbl_krc_rc.delete();

     fetch ubrr_bnkserv_krc.g_cur_list_krc_rc
        bulk collect into l_tbl_krc_rc limit ubrr_xxi5.ubrr_bnkserv_krc.g_limit_bulk;

       l_idx:= l_tbl_krc_rc.first;
       while l_idx is not null
       loop
          ubrr_bnkserv_krc.process_rec_krc_rc( p_idx         => l_idx
                                             , p_tbl_krc_rc  => l_tbl_krc_rc
                                             , p_tbl_sbs_new => l_tbl_sbs_new
                                             , p_tbl_sbs_ext => l_tbl_sbs_ext
                                             , p_date        => p_portion_date2
                                             , p_dtran       => p_dtran
                                             , p_ins_sbs     => l_ins_sbs );

          if ( l_ins_sbs ) then -- ubrr_data.ubrr_sbs_new  ������� � �������
             -- ��������
             l_tbl_sbs_new( l_tbl_sbs_new.count ).msbssumcom := GetSumComiss( p_TrnNum  => null
                                                                             ,p_TrnAnum => null
                                                                             ,p_Acc     => l_tbl_sbs_new( l_tbl_sbs_new.count ).csbsaccd
                                                                             ,p_Cur     => 'RUR'
                                                                             ,p_Otd     => l_tbl_sbs_new( l_tbl_sbs_new.count ).isbsotdnum
                                                                             ,p_TypeCom => ubrr_xxi5.ubrr_bnkserv_krc.g_com_type_krs_mng
                                                                             ,p_SumTrn  => 0
                                                                             ,p_SumBefo => 0);
          end if;

          if (l_ins_sbs) then
              l_cnt_suc := l_cnt_suc + 1;
          end if;
          l_idx:=l_tbl_krc_rc.next(l_idx);
       end loop;

       forall l_idx in indices of l_tbl_sbs_new
         insert into ubrr_data.ubrr_sbs_new values l_tbl_sbs_new(l_idx);

       forall l_idx in indices of l_tbl_sbs_ext
         insert into ubrr_data.ubrr_sbs_ext_krc values l_tbl_sbs_ext(l_idx);

       l_tbl_sbs_new.delete();
       l_tbl_sbs_ext.delete();
       exit when l_tbl_krc_rc.count < ubrr_xxi5.ubrr_bnkserv_krc.g_limit_bulk;
   end loop;

   close ubrr_bnkserv_krc.g_cur_list_krc_rc;
   dbms_transaction.commit;
   l_cnt_err:=ubrr_bnkserv_krc.log_error_not_found_rc( p_idsmr => p_idsmr
                                                      ,p_ls    => p_ls   );
   if l_cnt_err>0 then
      writeprotocol('��� ������� �������� �� ������� ��� ���� �� ��������� �/c ��� ��� : '||l_cnt_err||' ����');
      --ubrr rizanov 01.08.2018 18-465.2 ������ ���������� p_mess � ����� l_cnt_suc := -1;
   end if;

   return l_cnt_suc;

  exception
    when others then
      rollback;
      writeprotocol('������ ��� ������� �������� �� ������� ���: '||sqlerrm);
      p_mess := p_mess||'������ ��� ������� �������� �� ������� ���: '    ||sqlerrm;
      return -1;
  end calc_krc_managment_new;
--<<< ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���


-- >> ubrr 06.03.2019 ������� �.�. [18-58177.2] ���. ����������� (������ �������� ��������)
-- �������� �� �������� ���� � ������ 336 � ������ <=1e8
-- ������������ � ��� ����� � ��� ���
-- �������� ��� �������� <1>
function insert_besp_commis( p_Date in  date
                            ,p_ls   in  varchar2 default null
                            ,p_Mess out varchar2 )
return number
is
  lc_idsmr   constant smr.idsmr%type := sys_context('b21', 'idsmr'); -- 07.11.2017 ubrr korolkov 17-1071
  d1         date         := p_Date; -- ��������� ���� � ������ ���������
  l_acc_1    varchar2(25) := nvl(p_ls, '40___810%');
  d2         date         := p_Date + 86399 / 86400; -- ���� ���������
  l_icnt     number:=0;
  l_ires     number;
  l_bankidsmr varchar2(3);    -- 16.04.2019  ubrr ������� �.�. [18-58177.2] ������ ����� ������ �� ���������
  l_step     varchar2(4):='000';
begin
    l_step:='010';
    WriteProtocol('������ ������ ������ ��� �������� �� ���� �� 100���');
l_bankidsmr := ubrr_util.GetBankIdSmr;   -- 16.04.2019  ubrr ������� �.�. [18-58177.2] ������ ����� ������ �� ���������
    savepoint svp_before_insert_besp;
    insert into ubrr_data.ubrr_sbs_new( cSBSaccd
                                       ,cSBScurd
                                       ,cSBSTypeCom
                                       ,mSBSsumpays
                                       ,iSBScountPays
                                       ,mSBSsumcom
                                       ,iSBSotdnum
                                       ,iSBSBatNum
                                       ,dSBSDate
                                       ,iSBSTypeCom
                                       ,dsbsdatereg )
        (select ctrnaccd
               ,ctrncur
               ,TypeCom
               ,sum(case when sumcom = 0 then 0 else mtrnsum end)
               ,sum(sign(sumcom))
               ,sum(sumcom)
               ,iaccotd
               ,batnum
               ,p_Date
               ,1
               ,p_Date
         from (select itrnnum
                     ,itrnanum
                     ,ctrnaccd
                     ,ctrncur
                     ,mtrnsum
                     ,GetSumComiss( itrnnum
                                   ,itrnanum
                                   ,ctrnAccD
                                   ,ctrncur
                                   ,a.iaccotd
                                   ,'BESP'
                                   ,mtrnsum
                                   ,0) sumcom
                     ,'BESP'           TypeCom
                     ,iaccotd
                     ,to_number(to_char( nvl( iOTDbatnum, 70) ) || '00') batnum
               from xxi.v_trn_part_current t
                   ,xxi.acc a
                   ,otd o
               where a.caccacc = t.ctrnaccd
                 and a.cacccur = t.ctrncur
                 and o.iotdnum = a.iaccotd
                 and t.ctrnaccd like l_acc_1
                 and t.ctrncur = 'RUR'
                 and t.dtrntran between d1 and d2
                 and t.itrnbatnum = 336
                 and t.mtrnsum   <= 1e8
                 -- >> 16.04.2019  ubrr ������� �.�. [18-58177.2] ������ ����� ������ �� ���������
                 -- ������� ��������� ubrr_odb_besp_control.doc_is_besp
                 and t.itrntype = 4
                 and t.ctrndway = 'S'
                 -- ���������� ��/��
                 and (   substr(t.ctrnaccd,1,3) in ( '401','402','403','404','405','406','407' )
                      or substr(t.ctrnaccd,1,5) in ( '40802','40807','42309','40821' )
                     )
                 and not exists( select 1 cnt          -- �������
                                   from xxi."fil" f
                                  where f.cfilmfo = t.ctrnmfoa
                                    and f.idsmr   = l_bankidsmr
                               )
                 and ( t.ctrnacca not like '40101%' )
                 and ( t.ctrnacca not like '40302%' )
                 and ( t.ctrnacca not like '40501________2______' )
                 and ( t.ctrnacca not like '40601________1______' )
                 and ( t.ctrnacca not like '40601________3______' )
                 and ( t.ctrnacca not like '40701________1______' )
                 and ( t.ctrnacca not like '40701________3______' )
                 and ( t.ctrnacca not like '40503________4______' )
                 and ( t.ctrnacca not like '40603________4______' )
                 and ( t.ctrnacca not like '40703________4______' )
                 -- << 16.04.2019  ubrr ������� �.�. [18-58177.2] ������ ����� ������ �� ���������
                 and a.iaccotd not in (9219,9217) -- ubrr 01.04.2019 ������� �.�. [18-58177.2] ����� ����������: �������� ����.
                 -- ubrr_unique_tarif �� �������� ������ �� ���������  -- ubrr 06.03.2019 ������� �.�. [18-58177.2] ���. ����������� (������ �������� ��������)
--                 and not exists( select 1
--                                   from ubrr_unique_tarif
--                                  where cacc  = t.ctrnaccd
--                                    and t.dtrncreate between dopentarif and dcanceltarif
--                                    and idsmr = lc_idsmr )
                 and not exists( select 1
                                   from ubrr_data.ubrr_sbs_new u1
                                  where u1.idsmr       = a.idsmr
                                    and u1.dSBSdate    = p_date
                                    and u1.cSBSaccd    = a.caccacc
                                    and u1.cSBScurd    = a.cacccur
                                    and u1.cSBSTypeCom = 'BESP'
                                    and u1.iSBStrnnum is not null
                                    and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                               )
                 and exists( select 1
                               from ubrr_data.ubrr_rko_tarif        v
                                   ,ubrr_data.ubrr_rko_tarif_otdsum o
                              where v.Parent_IdSmr = BankIdSmr
                                and v.com_type     = 'BESP'
                                and v.id           = o.id_com
                                and o.otd          = a.iaccotd )
               )
         group by ctrnaccd, ctrncur, TypeCom, iaccotd, batnum
        );

    l_step:='020';
    l_icnt := sql%rowcount;
    WriteProtocol('��������� �������� �� ���� �� 100��� : ' || l_icnt);

    return l_icnt;
exception
    when others then
        rollback to svp_before_insert_besp;
        WriteProtocol('������ ��� ������� �������� �� �������� ���� �� 100 ��� : (l_step='||l_step||');'|| dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
        p_Mess := '������ ��� ������� �������� �� �������� ���� �� 100 ��� : (l_step='||');'|| dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
        return 0;
end insert_besp_commis;
-- << ubrr 06.03.2019 ������� �.�. [18-58177.2] ���. ����������� (������ �������� ��������)


  function TurnOffPacket(p_portion_date2 in date, p_ls in varchar2, p_months in number, p_NumCat in number, p_Mess out varchar2)
  return number
  is
  begin
    delete gac
    where igaccat=112 and igacnum=p_numcat
      and cgacacc like p_ls
      and exists (select 1
                  from xxi.au_attach_obg au
                  where au.caccacc = cgacacc
                    and au.cacccur = cgaccur
                    and c_newdata ='112/'||p_numcat
                    and au.c_type = 'I'
                    and au.i_table = 304
                    and add_months(trunc(au.d_create, 'MM'),p_months)-1<=dDateR
                    and not exists (select 1
                                    from xxi.au_attach_obg au1
                                    where au1.caccacc = au.caccacc
                                      and au1.cacccur = au.cacccur
                                      and i_table = 304
                                      and au1.d_create <= dDateR
                                      and au1.d_create > au.d_create
                                      and au1.c_type in ('D', 'U')
                                      and au1.c_olddata = au.c_newdata
                                      and nvl(au1.c_newdata, '-') != au1.c_olddata)
                 );
    COMMIT;
    RETURN 1;
  exception
    WHEN OTHERS THEN
      ROLLBACK;
      WriteProtocol('������ ��� �������� ������ ('||p_NumCat||'): '||SQLErrm);
      p_Mess := '������ ��� �������� ������ ('||p_NumCat||'): '||SQLErrm;
      RETURN -1;
  end;

  function TurnOffPackets(p_portion_date2 in date, p_ls in varchar2, p_Mess out varchar2)
  return number
  is
    vls varchar2(25) := nvl(p_ls, '40___810%');
  begin
    if TurnOffPacket(p_portion_date2, vls, 3, 1006, p_Mess)<1 then
      return -1;
    end if;
    if TurnOffPacket(p_portion_date2, vls, 6, 1007, p_Mess)<1 then
      return -1;
    end if;
    if TurnOffPacket(p_portion_date2, vls, 12, 1008, p_Mess)<1 then
      return -1;
    end if;
    if TurnOffPacket(p_portion_date2, vls, 18, 1009, p_Mess)<1 then
      return -1;
    end if;
    if TurnOffPacket(p_portion_date2, vls, 12, 1010, p_Mess)<1 then
      return -1;
    end if;
-->> 07.03.2017 �������� �.�.  [17-166] https://redmine.lan.ubrr.ru/issues/40971
   if TurnOffPacket(p_portion_date2, vls, 24, 1016, p_Mess)<1 then
      return -1;
    end if;
--<< 07.03.2017 �������� �.�.  [17-166] https://redmine.lan.ubrr.ru/issues/40971
    return 0;
  end;

  procedure UpdateAccComiss ( p_TypeCom in number
                             ,p_date    in date
                             ,p_regdate in date
                             ,p_ls      in varchar2
                             ,p_change_datereg in pls_integer default 1 )  --ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
  is
    Dummy         number;
    AccC          ubrr_data.ubrr_sbs_new.csbsaccc%TYPE;
    vAccOtd       acc.iaccotd%TYPE;  -->><<-- ubrr 21.10.2016 �������� �.�. 16-2222.2 ���� ���� ������� �� ��������� �� ������ � �/�� � ������ ���������, �� ���� ���.���� � ���
    vPack         varchar2(255);
    -->> ������ UBRR 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������
    s_idsmr       smr.idsmr%type := SYS_CONTEXT('B21','IdSmr'); -- ��� ����. IDSMR
    mfr_err       varchar2(255) := '���: ';
    --<< ����� UBRR 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������
    l_acc_otd     acc.iaccotd%type;   -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
    l_ihold       ubrr_sbs_new.ihold%type:=ubrr_bnkserv_calc_new_lib.gc_sbs_hold_no;  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
    l_sbsstat_4hold       varchar2(100);  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
    l_sbsstat_4hold_semicolon varchar2(100);  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
    l_comment      ubrr_sbs_new.ccomment%type := '';  --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
    
    cursor racc(p_DATEC DATE,  p_TypeCom number) is -->><<--23.10.2017  ����� �.�.17-1225
      select a.rowid
            ,a.*
            ,ct.ihold com_types_ihold      -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
        from ubrr_data.ubrr_sbs_new a
        left join ubrr_rko_com_types ct    -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
          on a.csbstypecom = ct.com_type
       where dSBSDate      = p_dateC
         and a.iSBSTypeCom = p_TypeCom
         and a.idSmr       = SYS_CONTEXT('B21','IdSmr')
         and ISBSTRNNUM IS NULL
         --and a.mSBSSumCom>0
         and a.ihold = ubrr_bnkserv_calc_new_lib.gc_sbs_hold_no   -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
         and (  (     p_TypeCom <> ubrr_xxi5.ubrr_bnkserv_krc.g_icom_type_krs_mng -->>> ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���
                  and a.csbsaccd like p_ls )
                or
                (     p_TypeCom = ubrr_xxi5.ubrr_bnkserv_krc.g_icom_type_krs_mng -- ������� ���
                  and a.csbsaccd_zam like p_ls )
             ); --<<< ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���
  begin
    for r in racc(p_date, p_TypeCom) loop -->><<-- 23.10.2017  ����� �.�.       17-1225
      begin
        -- >> ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
        l_ihold         := ubrr_bnkserv_calc_new_lib.gc_sbs_hold_no;
        l_sbsstat_4hold := null;
        l_comment       := ''; --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
        
        -->> 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
        --���������� �������� ���� ������������
        IF ubrr_bnkserv_calc_new.CheckUniqACC(p_acc => r.csbsaccd, p_dtrn => p_date, p_com_type => r.cSBSTypeCom, p_idsmr => r.idsmr) > 0
          and ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif = 'Y' THEN
           l_comment := '�������������� ��������� �������� �� �����';            
        END IF;
        
        -- ����������� � ����������� ������ �����
        IF r.cSBSTypeCom in ('UL_FL','UL_FL_VB','IP_DOH','IP_DOH_VB',
                             'CASS_LIM_IP','CASS_LIM_UR', --30.09.2020  ������� �.�.     [20-73382.2] �������������� ������ �� �� �������� ��������� �� ������
                             'VZN') --02.10.2020  ������� �.�.     [20-73382.3] �������������� ������ �� �� �������� ��������� �� ������
          and ubrr_bnkserv_calc_new.CheckUniqACC(p_acc => r.csbsaccd, p_dtrn => p_date, p_com_type => r.cSBSTypeCom, p_idsmr => r.idsmr) > 0
          and ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif = 'Y'
          and ubrr_bnkserv_calc_new.GetDayUniqACC(p_acc => r.csbsaccd, p_dtrn => p_date, p_com_type => r.cSBSTypeCom, p_idsmr => r.idsmr) = 'N' THEN

           l_ihold := ubrr_bnkserv_calc_new_lib.gc_sbs_hold2month; -- ����������� � �����������
           l_comment := '�������������� ��������� �������� �� ����� � ��������� ����������� ������'; 
           
        END IF;
        --<< 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
                
        if ( r.com_types_ihold = ubrr_bnkserv_calc_new_lib.gc_com_type_hold2month ) then
           if ( ubrr_bnkserv_balance.is_exist_over_dog( p_acc           => r.csbsaccd
                                                       ,p_cur           => r.csbscurd
                                                       ,p_date          => r.dsbsdate
                                                       ,p_idsmr         => r.idsmr
                                                       ,p_advanced_ctrl => 1 ) -- �������� ������� ������, ������,...
              ) then
              l_ihold := ubrr_bnkserv_calc_new_lib.gc_sbs_hold2month; -- ����������� � �����������
              l_comment := '���������� ������������ � ����������� � �������� ����������';   --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
           end if;
        end if;
        -- << ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����

        -- >> 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
        select iaccotd
          into l_acc_otd
          from acc
         where caccacc = r.csbsaccd
           and cacccur = r.csbscurd;
        -- << 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���

        vAccOtd := r.iSBSotdnum;  -->><<-- ubrr 21.10.2016 �������� �.�. 16-2222.2 ���� ���� ������� �� ��������� �� ������ � �/�� � ������ ���������, �� ���� ���.���� � ���

        -- ��� ��� �������� � ubrr_sbs_new.iSBSOtdNum �������� ��� �� �����, � ���_��� ��� ��������� ����� ������.
        -- �� ��� ��������� ������_������ ���������� ���_�����
        Dummy   := GetSumComiss(NULL,NULL,r.cSBSAccD, r.cSBScurd, r.iSBSotdnum, r.cSBSTypeCom, r.mSBSsumpays, r.mSBSSumBefo);
        AccC    := GetAccComiss ( p_Acc       => r.CSBSACCD
                                 ,p_Cur       => r.CSBSCURD
                                 ,p_otd_tarif => r.iSBSOtdNum   -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
                                 ,p_Otd       => (case when r.CSBSTYPECOM in ( 'PP6_NTK','R_LIGHT','017_NTK','018_NTK','RKB' )  -- ��� ����������  �����
                                                        then l_acc_otd
                                                        else r.iSBSOtdNum
                                                  end)          -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
                                 ,p_TypeCom   => r.cSBSTypeCom
                                 ,p_Pack      => vPack );

        -->> 28.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
        if     (    r.CSBSTYPECOM='PE6_PE'
                 or ( r.CSBSTYPECOM='PE6' and r.idsmr = ubrr_util.vuzb_idsmr ) -- ��� ���  -- 04.03.2020  ������� �.�. [20-71832] ���: ��������� ������ "������" (���)
               )
           and r.MSBSTARIF>0 then
            mtarif := r.msbssumcom / r.MSBSTARIF;
        --<< 28.06.2018 ������ [18-464] ��� � [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������)
        -->> 07.11.2017 ubrr korolkov 17-1071
        elsif /*gc_is_vuz = 0 and*/ mtarifPrc = 0 and mtarif = 0 and r.isbscountpays > 0 and r.msbssumcom > 0 then -->><<--04.07.2019 �������� [19-62974] II ���� ���.����.�����. ��������������� ������� ����� ����� �� ���
            mtarif := r.msbssumcom / r.isbscountpays;
        end if;
        --<< 07.11.2017 ubrr korolkov 17-1071

        IF AccC IS NULL THEN
          -->> ������ UBRR 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������
          ---- ���������� ����� �������� ���� � ������ �����
          if r.cSBSTypeCom in ('VZN', 'VZN44') then
            mfr_err := '���: ';
            for idsmr_find in (select idsmr from ubrr_smr/*xxi."smr"*/)
            loop
              -- ������ �������� --
              XXI_CONTEXT.Set_IDSmr(ID_Smr => idsmr_find.Idsmr);
              -- ������ ���� �������� ���� --
              AccC := GetAccComiss ( p_Acc       => r.CSBSACCD
                                    ,p_Cur       => r.CSBSCURD
                                    ,p_otd_tarif => null     -- ��� �� ����������  -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
                                    ,p_Otd       => r.iSBSOtdNum
                                    ,p_TypeCom   => r.cSBSTypeCom
                                    ,p_Pack      => vPack
                                   );
              if Length(replace(AccC, ' ')) > 0 then
                exit;
              end if;
            end loop;
            XXI_CONTEXT.Set_IDSmr(ID_Smr => s_idsmr);
          end if; -- � ������ ���� �� ��� �� ������ �������� ���� �� ��������� ����������� �������� ������� ������� ����� � ��������� ����� ���. �����
          mfr_err := null;
          --<< ����� UBRR 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������

          IF AccC IS NULL THEN
            -->> ubrr 21.10.2016 �������� �.�. 16-2222.2 ���� ���� ������� �� ��������� �� ������ � �/�� � ������ ���������, �� ���� ���.���� � ���
            vAccOtd := l_acc_otd;   -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���

            IF vAccOtd != r.iSBSotdnum THEN
              -->> ������ UBRR 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������
              ---- ��� ������������ ������ ��������� �� ���������� ����� ��������
              Dummy        := GetSumComiss(NULL,NULL,r.cSBSAccD, r.cSBScurd, vAccOtd, r.cSBSTypeCom, r.mSBSsumpays, r.mSBSSumBefo);
              r.mSBSSumCom := nvl(r.mSBSSumCom, Dummy);

              if nvl(r.mSBSSumCom, 0) = 0 then
                r.mSBSSumCom := Dummy;
              end if;
              --<< ����� UBRR 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������
              AccC := GetAccComiss( p_Acc       => r.CSBSACCD
                                   ,p_Cur       => r.CSBSCURD
                                   ,p_otd_tarif => null     -- ��� �� ����������  -- 24.07.2019 ������� �.�. [19-62974] III ���� �����. ��������������� ������� ����� ����� �� ���
                                   ,p_otd       => vAccOtd
                                   ,p_TypeCom   => r.cSBSTypeCom
                                   ,p_Pack      => vPack);
            END IF;
            --<< ubrr 21.10.2016 �������� �.�. 16-2222.2 ���� ���� ������� �� ��������� �� ������ � �/�� � ������ ���������, �� ���� ���.���� � ���
          END IF;
        END IF;

        -- >> ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
        l_sbsstat_4hold := ubrr_bnkserv_calc_new_lib.stat4hold(l_ihold);
        l_sbsstat_4hold_semicolon := case when l_sbsstat_4hold is null then null
                                    else l_sbsstat_4hold||';'
                                 end;
        -- << ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
        IF AccC IS NULL THEN
          IF nvl(r.mSBSSumCom,0)>0 THEN
            UPDATE ubrr_data.ubrr_sbs_new
            SET cSBSAccC = NULL,
                -->> ������ UBRR 10.03.2017 ����������� �.�. 16-3100.2 ���: �������� �� �������� ��� ����� ���������
                cSBSStat = l_sbsstat_4hold_semicolon|| -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                           mfr_err || '������: �� ������ ���� �������',
                --<< ����� UBRR 10.03.2017 ����������� �.�. 16-3100.2 ���: �������� �� �������� ��� ����� ���������
                dSBSdateReg = case when (nvl(p_change_datereg,0)=0) then dSBSdateReg else p_regdate end, --ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                cSBSPack = vPack,
                mSBStarif = mTarif,
                mSBStarifprc = mTarifPrc,
                iSBSotdnum = vAccOtd,   -->><<-- ubrr 21.10.2016 �������� �.�. 16-2222.2 ���� ���� ������� �� ��������� �� ������ � �/�� � ������ ���������, �� ���� ���.���� � ���
                tarif_id = g_tarif_id -- 21.02.2018 ubrr korolkov 18-12.1
               ,ihold    = l_ihold    -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
               ,ccomment = l_comment  --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
            WHERE rowid = r.rowid;
          ELSE
            UPDATE ubrr_data.ubrr_sbs_new
            SET cSBSAccC = NULL,
                -->> ubrr 21.10.2016 �������� �.�. 16-2222.2 �������� ������ � �������
                -->> ������ UBRR 10.03.2017 ����������� �.�. 16-3100.2 ���: �������� �� �������� ��� ����� ���������
                cSBSStat = l_sbsstat_4hold_semicolon||  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                           mfr_err || '������: �� ������ ���� �������'||
                --<< ����� UBRR 10.03.2017 ����������� �.�. 16-3100.2 ���: �������� �� �������� ��� ����� ���������
                           case when r.mSBSSumCom is null then ', ������: ����� �������� �� ����������'
                                else ', ����� �������� �������'
                           end ,
                --<< ubrr 21.10.2016 �������� �.�. 16-2222.2 �������� ������ � �������
                dSBSdateReg = case when (nvl(p_change_datereg,0)=0) then dSBSdateReg else p_regdate end, --ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
                cSBSPack = vPack,
                mSBStarif = mTarif,
                mSBStarifprc = mTarifPrc,
                iSBSotdnum = vAccOtd,   -->><<-- ubrr 21.10.2016 �������� �.�. 16-2222.2 ���� ���� ������� �� ��������� �� ������ � �/�� � ������ ���������, �� ���� ���.���� � ���
                tarif_id = g_tarif_id -- 21.02.2018 ubrr korolkov 18-12.1
               ,ihold    = l_ihold    -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
               ,ccomment = l_comment  --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
            WHERE rowid = r.rowid;
          END IF;
        ELSE
          UPDATE ubrr_data.ubrr_sbs_new
          set cSBSAccC = AccC,
              -->> ubrr 21.10.2016 �������� �.�. 16-2222.2 �������� ������ � �������
              cSBSStat =  CASE WHEN r.mSBSSumCom IS NULL THEN l_sbsstat_4hold_semicolon||'������: ����� �������� �� ����������'
                             WHEN r.mSBSSumCom = 0 THEN l_sbsstat_4hold_semicolon||'����� �������� �������'
                             ELSE l_sbsstat_4hold -- >> ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                         END,
              --<< ubrr 21.10.2016 �������� �.�. 16-2222.2 �������� ������ � �������
              cSBSCurC = 'RUR',
              dSBSdateReg = case when (nvl(p_change_datereg,0)=0) then dSBSdateReg else p_regdate end, --ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
              cSBSPack = vPack,
              mSBStarif = mTarif,
              mSBStarifprc = mTarifPrc,
              iSBSotdnum = vAccOtd,   -->><<-- ubrr 21.10.2016 �������� �.�. 16-2222.2 ���� ���� ������� �� ��������� �� ������ � �/�� � ������ ���������, �� ���� ���.���� � ���
              mSBSSumCom = r.mSBSSumCom, -->><< ubrr 10.03.2017 ����������� �.�. [16-3100.2] ���: �������� �� �������� ��� ����� ���������
              tarif_id = g_tarif_id -- 21.02.2018 ubrr korolkov 18-12.1
             ,ihold    = l_ihold    -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
             ,ccomment = l_comment  --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
          WHERE rowid = r.rowid;
          -->> 07.11.2017 ubrr korolkov 17-1071
          if r.csbsaccd = '40802810463020000001' then
            update ubrr_sbs_new
            set csbsaccd = '40802810063020001206'
            where rowid = r.rowid;
          end if;
          --<< 07.11.2017 ubrr korolkov 17-1071
        END IF;
      exception
        when others then
           UPDATE ubrr_data.ubrr_sbs_new
           SET cSBSStat =  l_sbsstat_4hold_semicolon||  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                           '������,' || dbms_utility.format_error_stack || chr(10) || dbms_utility.format_error_backtrace
           WHERE rowid = r.rowid;
      end;
    end loop;

    commit;

  end UpdateAccComiss;

-- >> ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
-----------------------------------------------------------
--  ����������� ��������
--  �� SBS_NEW
  function Register( p_regdate             in  date
                    ,p_TypeCom             in  number
                    ,p_Mess                out varchar2
                    ,p_portion_date1       in  date   default null
                    ,p_portion_date2       in  date   default null
                    ,p_ls                  in  varchar2
                    ,p_mode_available_rest in boolean default false  -- ubrr 21.02.2019 ������� �.�. [17-1790] ���: ��������� �� ��� ��� ������� ������������ ���������
                    ,p_mode_hold           in boolean default false  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
                   )
  return number is
  begin
      return ubrr_bnkserv_calc_new_lib.Register( p_regdate             => p_regdate
                                                ,p_TypeCom             => p_TypeCom
                                                ,p_Mess                => p_Mess
                                                ,p_portion_date1       => p_portion_date1
                                                ,p_portion_date2       => p_portion_date2
                                                ,p_ls                  => p_ls
                                                ,p_mode_available_rest => p_mode_available_rest
                                                ,p_mode_hold           => p_mode_hold
                                                ,p_test                => itest );
  end Register;
-- << ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����

  FUNCTION CalcEveryDayComiss
   (
    p_Date in date, -- ���� �������
    p_TypeCom IN NUMBER,
    /* ��� ��������
      1 - �� ���������� ��������
      2 - �� ���������� �������� ����� 17-00
      4 - �� ���������� �������� � ������ ��
      8 - ��
      �������� ������ ���������� �������� ���������������.
      �������� 1+2+4 = 7
    */
    p_ls in varchar2 default null, -- ���� ��� ������� ��������
    p_RegDate in date default null, -- ���� ����������� ����������
    p_Mess out varchar2
  ) RETURN NUMBER IS
    IsxContext NUMBER := SYS_CONTEXT('B21', 'IDSMR');
    cursor c_smr is
      select idsmr from ubrr_smr;
    vRes NUMBER;
    vMess VARCHAR2(2000);
    vRes1 NUMBER;
    vRes2 NUMBER := 0;
    vRes2_p NUMBER := 0;
    vDateReg DATE := NVL(p_RegDate, p_Date);
    acc_1    varchar2(25) := nvl(p_ls,'40___810%');
    vrtv     varchar2(2000); -->><<-- 23.10.2017  ����� �.�.       17-1225
  BEGIN
    IF vDateReg <= trunc(CLSDAY.CLOSED_DATE) THEN -->><<-- ubrr 19.10.2016 �������� �.�.   [16-2222]  #35311 �������� ���� �����������, � �� ���� �������
      WriteProtocol('����� ������� �� �������� ���� '||p_date);
      p_Mess := '������ � �������� ��� �� ������������: '||p_Date;
      ROLLBACK;
      RETURN -1;
    END IF;
    --UBRR_XXI_LOGON.Set_Version('XXI');
    delete ubrr_data.ubrr_sbs_new_log
    where sessionID = UserEnv('SessionID');
    commit;
    dDateR := p_Date  + 86399/86400;
    FOR c IN c_smr LOOP
      IF c.IdSmr != SYS_CONTEXT('B21', 'IDSMR') THEN
        XXI_context.Set_idSMR(c.IdSmr);
      END IF;

      WriteProtocol('������ ������� ���������� �������� �� ������� '||c.IdSmr||' p_TypeCom='||p_TypeCom);
      BankIdSmr := ubrr_util.GetBankIdSmr;
      DBMS_TRANSACTION.COMMIT;

      -->> 07.08.2019 �������� [19-62974] III ���� ���
      IF bitand(p_TypeCom,64) = 64 THEN
        WriteProtocol('������ �������������� ������� �� '||to_char(p_Date,'DD.MM.YYYY')||'  �� ����� ������ '||nvl(p_ls, '%'));
        vRes:=CalcProlongation(p_Date, acc_1, vDateReg, vMess);
        WriteProtocol('��������� �������������� ������� �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vRes);
        vRes2 := vRes2 + vRes;
      END IF;
      --<< 07.08.2019 �������� [19-62974] III ���� ���

      IF bitand(p_TypeCom,1) = 1 THEN
        WriteProtocol('������ ������� �������� �� �������� �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%'));
        vRes := CalcMoneyOrder_Vuz(p_Date, acc_1, vMess);
        WriteProtocol('��������� ������� �������� �� �������� �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vRes);
        if vRes > 0 THEN
          vRes2_p := vRes2_p + vRes;
          WriteProtocol('������ ����������� ���������� �� ������������ �������� �� ��������');
          UpdateAccComiss(1, p_Date, vDateReg, acc_1);  -->><<-- ubrr 19.10.2016 �������� �.�.   [16-2222]  #35311 �������� ���� �����������, � �� ���� �������
          vRes1 := Register( p_regdate             => vDateReg
                            ,p_TypeCom             => 1
                            ,p_Mess                => vMess
                            ,p_portion_date1       => p_Date
                            ,p_portion_date2       => p_Date
                            ,p_ls                  => acc_1
                            ,p_mode_available_rest => false); -- ubrr 03.08.2019  ������� �.�. [19-62808]   ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
          vRes2 := vRes2 + vRes1;
          WriteProtocol('��������� ����������� ���������� �� ������������ �������� �� ��������. ���������: '||vRes1);
        end if;
      END IF;

      IF bitand(p_TypeCom,2) = 2 THEN
        WriteProtocol('������ ������� �������� �� �������� ����� 17-00 �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%'));
        vRes := CalcMoneyOrder17_Vuz(p_Date, acc_1, vMess);
        WriteProtocol('��������� ������� �������� �� �������� ����� 17-00 �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vRes);
        if vRes > 0 THEN
          vRes2_p := vRes2_p + vRes;
          WriteProtocol('������ ����������� ���������� �� ������������ �������� �� �������� ����� 17-00');
          UpdateAccComiss(2, p_Date, vDateReg, acc_1);   -->><<-- ubrr 19.10.2016 �������� �.�.   [16-2222]  #35311 �������� ���� �����������, � �� ���� �������
          vRes1 := Register( p_regdate             => vDateReg
                            ,p_TypeCom             => 2
                            ,p_Mess                => vMess
                            ,p_portion_date1       => p_Date
                            ,p_portion_date2       => p_Date
                            ,p_ls                  => acc_1
                            ,p_mode_available_rest => false); -- ubrr 03.08.2019  ������� �.�. [19-62808]   ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
          vRes2 := vRes2 + vRes1;
          WriteProtocol('��������� ����������� ���������� �� ������������ �������� �� �������� ����� 17-00. ���������: '||vRes1);
        end if;
      END IF;

      IF bitand(p_TypeCom,4) = 4 THEN
        WriteProtocol('������ ������� �������� �� �������� � ������ �� �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%'));
        vRes := CalcMoneyOrderULFL(p_Date, acc_1, vMess);
        WriteProtocol('��������� ������� �������� �� �������� � ������ �� �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vRes);
        if vRes > 0 THEN
          vRes2_p := vRes2_p + vRes;
          WriteProtocol('������ ����������� ���������� �� ������������ �������� �� �������� � ������ ��');
          UpdateAccComiss(3, p_Date, vDateReg, acc_1);   -->><<-- ubrr 19.10.2016 �������� �.�.   [16-2222]  #35311 �������� ���� �����������, � �� ���� �������
          vRes1 := Register( p_regdate             => vDateReg
                            ,p_TypeCom             => 3
                            ,p_Mess                => vMess
                            ,p_portion_date1       => p_Date
                            ,p_portion_date2       => p_Date
                            ,p_ls                  => acc_1
                            ,p_mode_available_rest => false); -- ubrr 03.08.2019  ������� �.�.     [19-62808]   ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
          vRes2 := vRes2 + vRes1;
          WriteProtocol('��������� ����������� ���������� �� ������������ �������� �� �������� � ������ ��. ���������: '||vRes1);
        end if;
      END IF;

      IF bitand(p_TypeCom,8) = 8 THEN
        WriteProtocol('������ ������� �������� �� �� �� '||to_char(p_Date,'DD.MM.YYYY')||'  �� ����� ������ '||nvl(p_ls, '%'));
        vRes:=CalcCashCom(p_Date, acc_1, vMess);
        WriteProtocol('��������� ������� �������� �� �� �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vRes);
        if vRes>0 THEN
          vRes2_p := vRes2_p + vRes;
          WriteProtocol('������ ����������� ���������� �� ������������ �������� �� ��');
          UpdateAccComiss(4, p_Date, vDateReg, acc_1);   -->><<-- ubrr 19.10.2016 �������� �.�.   [16-2222]  #35311 �������� ���� �����������, � �� ���� �������
          vRes1 := Register( p_regdate             => vDateReg
                            ,p_TypeCom             => 4
                            ,p_Mess                => vMess
                            ,p_portion_date1       => p_Date
                            ,p_portion_date2       => p_Date
                            ,p_ls                  => acc_1
                            ,p_mode_available_rest => true); -- ��� VZN,VZN44 : ������ ����������_������� �� �� ��������
          vRes2:=vRes2+vRes1;
          WriteProtocol('��������� ����������� ���������� �� ������������ �������� �� ��. ���������: '||vRes1);
        end if;
      END IF;
      -->> 23.10.2017  ����� �.�.       17-1225
      IF bitand(p_TypeCom,32) = 32 THEN
        WriteProtocol('������ ������� �������� �� ��������� ������ �� ������������������� ������������ '||to_char(p_Date,'DD.MM.YYYY')||'  �� ����� ������ '||nvl(p_ls, '%'));
        vrtv := ubrr_xxi5.ubrr_ulfl_comss_ver2.calc_mask_comss_businact(p_Date, p_mask  => acc_1); -- 'IP_DOH'
        -- ismrrr := sys_context('B21', 'IdSmr'); for test
        WriteProtocol('��������� ������� �������� �� ��������� ������ �� ������������������� ������������ '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vRes);
        if vrtv like 'OK%' then
          vRes := to_number (substr (vrtv, 3));
        else
          vRes := -1;
        end if;

        if vRes > 0 then
          vRes2_p := vRes2_p + vRes;
          WriteProtocol('������ ����������� ���������� �� ������������ �������� �� ��������� ������ �� ������������������� ������������');
          UpdateAccComiss(32, p_Date, vDateReg, acc_1);   -->><<-- ubrr 19.10.2016 �������� �.�.   [16-2222]  #35311 �������� ���� �����������, � �� ���� �������
          vRes1 := Register( p_regdate             => vDateReg
                            ,p_TypeCom             => 32
                            ,p_Mess                => vMess
                            ,p_portion_date1       => p_Date
                            ,p_portion_date2       => p_Date
                            ,p_ls                  => acc_1
                            ,p_mode_available_rest => false); -- ubrr 03.08.2019  ������� �.�.     [19-62808]   ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
          vRes2:=vRes2+vRes1;
          WriteProtocol('��������� ����������� ���������� �� ������������ �������� �� ��������� ������ �� ������������������� ������������. ���������: '||vRes1);
        end if;
      END IF;
      --<< 23.10.2017  ����� �.�.       17-1225
      WriteProtocol('��������� ������� ���������� �������� � ����������� ���������� �� ������� '||c.IdSmr);
    END LOOP;
    XXI_context.Set_idSMR(IsxContext);
    commit;
    p_Mess := '��������� ��������: '||vRes2_p;
    RETURN vRes2;
  exception
    when others then
      WriteProtocol('������ ���������� ��������� CalcEveryDayComiss: '||dbms_utility.format_error_backtrace);
      XXI_context.Set_idSMR(IsxContext);
      p_Mess := '������ ���������� ��������� CalcEveryDayComiss: '||dbms_utility.format_error_backtrace;
      RETURN -1;
  END CalcEveryDayComiss; -- ubrr 06.03.2019 ������� �.�. [18-58177.2] ���. ����������� (������ �������� ��������)

  FUNCTION CalcEveryMonthsComiss (p_portion_date1 in date,
                                  p_portion_date2 in date,
                                  p_dtran in date,
                                  p_ls in varchar2 default null,
                                  p_test in number default 0,
                                  p_Mess out varchar2
                                 )
  RETURN NUMBER
  IS
    IsxContext NUMBER := SYS_CONTEXT('B21', 'IDSMR');
    vMess VARCHAR2(2000);
    acc_1    varchar2(25) := nvl(p_ls,'40___810%');
    -->>  ubrr 23.09.2016 �������� �.�. 16-2222 �������� �� ������ "��������", ��������� �� ���������� ������
    vRes_com NUMBER := 0;
  BEGIN
    IF p_dtran <= trunc(CLSDAY.CLOSED_DATE) THEN
      WriteProtocol('����� ������� � ��������� � �������� ��� '||p_dtran);
      p_Mess := '�������� � �������� ��� �� ������������: '||p_Dtran;
      ROLLBACK;
      RETURN -1;
    END IF;
    --delete ubrr_data.ubrr_sbs_new_log
    --where sessionID = UserEnv('SessionID');
    --UBRR_XXI_LOGON.Set_Version('XXI');
    dDateR := p_portion_date2 + 86399/86400;
    WriteProtocol('������ ������� ����������� �������� �� ������� '||SYS_CONTEXT('B21','IDSMR'));
    BankIdSmr := ubrr_util.GetBankIdSmr;
    DELETE FROM ubrr_data.ubrr_sbs_new
    WHERE IdSmr = IsxContext
      AND dSBSDate = p_portion_date2
      AND iSBSTypeCom>100
      AND iSBSTypeCom <> ubrr_xxi5.ubrr_bnkserv_krc.g_icom_type_krs_mng -->>> ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���
      AND iSBStrnnum IS NULL
      AND cSBSAccD like acc_1
      and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created  -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
      ;
    DBMS_TRANSACTION.COMMIT;

    p_Mess := '��������� : ';
    WriteProtocol('������ ������� �������� �� ������� ����� �  '||to_char(p_portion_date1,'DD.MM.YYYY')||' �� '||to_char(p_portion_date2,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%'));
    vRes_com:=CalcRKOComiss (p_portion_date1, p_portion_date2, acc_1, p_dtran, vMess);
    UpdateAccComiss(101, p_portion_date2, p_dtran, acc_1);
    WriteProtocol('��������� ������� �������� �� ������� ����� �  '||to_char(p_portion_date1,'DD.MM.YYYY')||' �� '||to_char(p_portion_date2,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vRes_com);
    p_Mess := p_Mess||'����� �� ��� - '||to_char(vRes_com)||chr(10);

    vRes_com:=0;
    WriteProtocol('������ ������� �������� �� SMS-�������������� �  '||to_char(p_portion_date1,'DD.MM.YYYY')||' �� '||to_char(p_portion_date2,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%'));
    vRes_com:=CalcSmsComiss (p_portion_date1, p_portion_date2, acc_1, p_dtran, vMess);
    UpdateAccComiss(102, p_portion_date2, p_dtran, acc_1);
    WriteProtocol('��������� ������� �������� �� SMS-�������������� �  '||to_char(p_portion_date1,'DD.MM.YYYY')||' �� '||to_char(p_portion_date2,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vRes_com);
    p_Mess := p_Mess||' ����� �� sms-�������������� - '||to_char(vRes_com)||chr(10);

    vRes_com:=0;
    WriteProtocol('������ ������� �������� �� ������� ����� �  '||to_char(p_portion_date1,'DD.MM.YYYY')||' �� '||to_char(p_portion_date2,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%'));
    vRes_com:=CalcClubComiss (p_portion_date1, p_portion_date2, acc_1, p_dtran, vMess);
    UpdateAccComiss(103, p_portion_date2, p_dtran, acc_1);
    WriteProtocol('��������� ������� �������� �� ������� ����� �  '||to_char(p_portion_date1,'DD.MM.YYYY')||' �� '||to_char(p_portion_date2,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vRes_com);
    p_Mess := p_Mess||' ����� �� ������� ����� - '||to_char(vRes_com)||chr(10);

    vRes_com:=0;
    WriteProtocol('������ ������� �������� �� ������ "��������" �  '||to_char(p_portion_date1,'DD.MM.YYYY')||' �� '||to_char(p_portion_date2,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%'));
    vRes_com:=CalcSvetoforComiss (p_portion_date1, p_portion_date2, acc_1, p_dtran, vMess);
    UpdateAccComiss(104, p_portion_date2, p_dtran, acc_1);
    WriteProtocol('��������� ������� �������� �� ������ "��������" �  '||to_char(p_portion_date1,'DD.MM.YYYY')||' �� '||to_char(p_portion_date2,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vRes_com);
    p_Mess := p_Mess||' ����� �� ������ "��������" - '||to_char(vRes_com)||chr(10);

    -->>> ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���
    <<label_krc_mng>>
    vRes_com:=0;
    WriteProtocol('������ ������� �������� �� ������� ����� ��� �  '||to_char(p_portion_date1,'DD.MM.YYYY')||' �� '||to_char(p_portion_date2,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%'));
    if ( gc_is_vuz=1 ) then
        vRes_com:=calc_krc_managment_new ( p_portion_date1 => p_portion_date1
                                          ,p_portion_date2 => p_portion_date2
                                          ,p_ls            => acc_1
                                          ,p_dtran         => p_dtran
                                          ,p_mess          => p_mess
                                          ,p_idsmr         => IsxContext );
        UpdateAccComiss(105, p_portion_date2, p_dtran, acc_1);
    else
        WriteProtocol('������ �������� �������� ������ ��� ���-�����');
    end if;
    WriteProtocol('��������� ������� �������� �� ������� ����� ��� �  '||to_char(p_portion_date1,'DD.MM.YYYY')||' �� '||to_char(p_portion_date2,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vRes_com);
    p_Mess := p_Mess||' ����� �� ������� ����� ��� - '||to_char(vRes_com)||chr(10);
        --<<< ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���

    IF p_test = 0 THEN
      -- ������ ������, ������� ���� ���������
      WriteProtocol('������ ���������� ������� �  '||to_char(p_portion_date1,'DD.MM.YYYY')||' �� '||to_char(p_portion_date2,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%'));
      if TurnOffPackets(p_portion_date2, acc_1, vMess)<0 then
        WriteProtocol('������ ���������� ������� �  '||to_char(p_portion_date1,'DD.MM.YYYY')||' �� '||to_char(p_portion_date2,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%'));
        return -1;
      END IF;
      WriteProtocol('��������� ���������� ������� �  '||to_char(p_portion_date1,'DD.MM.YYYY')||' �� '||to_char(p_portion_date2,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%'));
    END IF;

    p_Mess:=p_Mess||'���������� ?';
    --<<  ubrr 23.09.2016 �������� �.�. 16-2222 �������� �� ������ "��������", ��������� �� ���������� ������
    commit;
    RETURN 1;
  exception
    when others then
      WriteProtocol('������ ���������� ��������� ������� ����������� ��������: '||dbms_utility.format_error_backtrace||sqlerrm); -- ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���
      p_Mess := '������ ���������� ��������� ������� ����������� ��������: '||dbms_utility.format_error_backtrace;
      RETURN -1;
  END;

  FUNCTION RegEveryMonthsComiss (p_portion_date1 in date,
                                 p_portion_date2 in date,
                                 p_dtran in date,
                                 p_ls in varchar2 default null,
                                 p_test in number default 0,
                                 p_Mess out varchar2
                                )
  RETURN NUMBER
  IS
    vMess VARCHAR2(2000);
    acc_1    varchar2(25) := nvl(p_ls,'40___810%');
    vRes_com NUMBER := 0;

  BEGIN
    iTest := p_Test;
    -->>  ubrr 23.09.2016 �������� �.�. 16-2222 �������� �� ������ "��������", ��������� �� ���������� ������

    BankIdSmr := ubrr_util.GetBankIdSmr;

    -- >> ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
    ubrr_bnkserv_calc_new_lib.process_monthly_comm_from_hold( p_dtran          => p_dtran
                                                             ,p_portion_date1  => p_portion_date1
                                                             ,p_portion_date2  => p_portion_date2
                                                             ,p_ls             => p_ls
                                                             ,p_test           => iTest
                                                             ,p_Mess           => vMess );
    -- << ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����

    p_Mess:='������� ������������ �������� ';
    WriteProtocol('������ ����������� ���������� �� ������������ �������� �� ���');
    vRes_com:=Register(p_dtran, 101, vMess, p_portion_date1, p_portion_date2, acc_1);
    WriteProtocol('��������� ����������� ���������� �� ������������ �������� �� ���. ���������: '||vRes_com);
    p_Mess:=p_Mess||'�� ��� ' ||vRes_com||chr(10);

    vRes_com:=0;
    WriteProtocol('������ ����������� ���������� �� ������������ �������� �� SMS');
    vRes_com:=Register(p_dtran, 102, vMess, p_portion_date1, p_portion_date2, acc_1);
    WriteProtocol('��������� ����������� ���������� �� ������������ �������� �� SMS. ���������: '||vRes_com);
    p_Mess:=p_Mess||' �� SMS  ' ||vRes_com||chr(10);

    vRes_com:=0;
    WriteProtocol('������ ����������� ���������� �� ������������ �������� �� ������� �����');
    vRes_com:=Register(p_dtran, 103, vMess, p_portion_date1, p_portion_date2, acc_1);
    WriteProtocol('��������� ����������� ���������� �� ������������ �������� �� ������� �����. ���������: '||vRes_com);
    p_Mess:=p_Mess||' �� ������� ����� ' ||vRes_com||chr(10);

    vRes_com:=0;
    WriteProtocol('������ ����������� ���������� �� ������������ �������� �� ������ "��������"');
    vRes_com:=Register(p_dtran, 104, vMess, p_portion_date1, p_portion_date2, acc_1);
    if iTest = 0 then -->>12.03.2019 �������� [#60496] https://redmine.lan.ubrr.ru/issues/60496
       delete_rb_ib_lt(p_portion_date1, p_portion_date2, p_dtran, acc_1, vMess); -->><<--08.11.2018 �������� [18-592.2] ���. ������� �������� �� ���������.
    end if; --<<12.03.2019 �������� [#60496] https://redmine.lan.ubrr.ru/issues/60496
    WriteProtocol('��������� ����������� ���������� �� ������������ �������� �� ������ "��������". ���������: '||vRes_com);
    p_Mess:=p_Mess||' �� ������ "��������" '||vRes_com||chr(10);

    -->>> ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���
    <<label_krs_mng>>
    vRes_com:=0;
    WriteProtocol('������ ����������� ���������� �� ������������ �������� �� ������� ����� ���');
    vRes_com:=Register(p_dtran, ubrr_xxi5.ubrr_bnkserv_krc.g_icom_type_krs_mng, vMess, p_portion_date1, p_portion_date2, acc_1);
    WriteProtocol('��������� ����������� ���������� �� ������������ �������� �� �� ������� ����� ���". ���������: '||vRes_com);
    p_Mess:=p_Mess||' �� �� ������� ����� ��� '||vRes_com||chr(10);
    --<<< ubrr rizanov 03.07.2018 18-465 �������� �� ������� ����� ���

    p_Mess:=p_Mess||'��������� ���������� ?';
    --<< ubrr 23.09.2016 �������� �.�. 16-2222 �������� �� ������ "��������", ��������� �� ���������� ������

    -->>04.07.2019 �������� [19-62974] II ���� ���.����.�����. ��������������� ������� ����� ����� �� ���
    if p_test = 0 then
        delete from gac
         where igaccat = 114
           and igacnum = 16
           and cgacacc like acc_1;
    end if;
    --<<04.07.2019 �������� [19-62974] II ���� ���.����.�����. ��������������� ������� ����� ����� �� ���
    RETURN 1;
  exception
    when others then
      WriteProtocol('������ ���������� ��������� ����������� ����������� ��������: '||dbms_utility.format_error_backtrace);
      p_Mess := '������ ���������� ��������� ����������� ����������� ��������: '||dbms_utility.format_error_backtrace;
      RETURN -1;
  END;

  -->> ubrr 06.10.2016 �������� �.�.   [16-2222]  #35311  ���������� �������� �� �������� �������� �����
  FUNCTION CalcEveryDayComissAll_UBRR
   (
    p_Date in date, -- ���� �������
    p_TypeCom IN NUMBER,
    /* ��� ��������
      -->> ���� ��� ����� ��������
      1 - �� ���������� ��������
      2 - �� ���������� �������� ����� 17-00
      4 - �� ���������� �������� � ������ ��
      --<< ���� ��� ����� ��������
      8 - ��
      �������� ������ ���������� �������� ���������������.
      �������� 1+2+4 = 7
    */
    p_ls in varchar2 default null, -- ���� ��� ������� ��������
    p_RegDate in date default null, -- ���� ����������� ����������
    p_Mess out varchar2
  ) RETURN NUMBER IS
    cursor c_smr is
      select idsmr from ubrr_smr
      where idsmr not in ('8', -->><<-07.11.2019 �������� [19-62184] "����" https://redmine.lan.ubrr.ru/issues/67214#note-2
           '5','6','13',  -->><<--02.03.2020 �������� [19-69558.2] �������� �������� �������������, ���������, �������������
           '4','9','15', --14.02.2020 �������� [20-71606]
           '11','14',
           '7' ,'12','10') -- 28.05.2020 UBRR Lazarev [20-74342] https://redmine.lan.ubrr.ru/issues/74342
      order by case when idsmr = 1 then 999999 else to_number(idsmr) end;
    vRes NUMBER;
    vMess VARCHAR2(2000);
    vRes1 NUMBER;
    vRes2 NUMBER := 0;
    vRes2_p NUMBER := 0;
    vDateReg DATE := NVL(p_RegDate, p_Date);
    acc_1    varchar2(25) := nvl(p_ls,'40___810%');
    CurSysDate date := NULL;
    v_job_name varchar2(50) := 'XXI.ubrr_everyday_comiss_job_';
    v_TextJob VARCHAR2(1000);
  BEGIN
    /*IF vDateReg <= trunc(CLSDAY.CLOSED_DATE) THEN
      WriteProtocol('����� ������� �� �������� ���� '||p_date);
      p_Mess := '������ � �������� ��� �� ������������: '||p_Date;
      ROLLBACK;
      RETURN -1;
    END IF;*/
    delete ubrr_data.ubrr_sbs_new_log
    where sessionID = UserEnv('SessionID');
    commit;

    -->>06.11.2019 �������� [19-62184] "����" https://redmine.lan.ubrr.ru/issues/67214#note-2
    if xxi.pref.get_Preference('UBRR_ACC_MATCHING.ACTIVE')='Y' then
      declare
        dv_d1       date := first_day(add_months(p_Date, -1));
        dv_d2       date := p_Date;
        cv_context  xxi."smr".idsmr%type := SYS_CONTEXT('B21', 'IDSMR');
      begin
        ubrr_bnkserv_calc_new_lib.writeprotocol('ubrr_trn_old_new: ������ �������');
        execute immediate ('truncate table ubrr_data.ubrr_trn_old_new');
        ubrr_bnkserv_calc_new_lib.writeprotocol('ubrr_trn_old_new: ������� ��������');

        for c in (select idsmr
                    from xxi."smr"
                   where idsmr not in ('8',
                                       '5','6','13', --02.03.2020 �������� [19-69558.2] �������� �������� �������������, ���������, �������������
                                       '4','9','15', --14.02.2020 �������� [20-71606]
                                       '11','14',
                                       '7' ,'12','10') -- 28.05.2020 UBRR Lazarev [20-74342] https://redmine.lan.ubrr.ru/issues/74342
                   order by case when idsmr = 1 then 999999 else to_number(idsmr) end) loop
          xxi_context.Set_idSMR(c.idsmr);
          ubrr_bnkserv_calc_new_lib.fill_trn_old_new(p_d1=>dv_d1, p_d2=>dv_d2);
        end loop;
        xxi_context.Set_idSMR(cv_context);
      end;
    end if;
    --<<06.11.2019 �������� [19-62184] "����" https://redmine.lan.ubrr.ru/issues/67214#note-2

    CurSysDate := sysdate;
    FOR c IN c_smr LOOP
      v_Job_Name := 'ubrr_evday_comiss_'||to_char(c.IdSmr)||'_'||to_char(p_Date, 'YYYYMMDD');
      v_textJob := 'DECLARE vMess VARCHAR2(1000);BEGIN XXI_context.Set_idSMR('||c.idsmr||'); ';
      v_TextJob := v_textJob || 'IF UBRR_XXI5.ubrr_bnkserv_calc_new.CalcEveryDayComissUBRR(p_date=>to_date('''||to_char(p_Date, 'DD.MM.YYYY')||''', ''DD.MM.YYYY''), ';
      v_TextJob := v_TextJob||'p_TypeCom =>'||p_TypeCom||' , p_ls=>'''||acc_1||''', p_RegDate =>to_date('''||to_char(p_RegDate, 'DD.MM.YYYY')||''', ''DD.MM.YYYY''), p_Mess => vMess) = 1 THEN ';
      v_TextJob := v_textJob || 'NULL; END IF; END;';

      CurSysDate := greatest(CurSysDate+1/24/60, sysdate+1/24/60);
      dbms_scheduler.create_job(job_name => v_job_name,
                                job_type => 'PLSQL_BLOCK',
                                job_action => v_TextJob,
                                start_date => CurSysDate,
                                repeat_interval => null,
                                auto_drop => true,
                                enabled => true,
                                comments => '�������������� ���������� ���������� �������� ����� ('||c.idsmr||')');
      WriteProtocol('������ ���� ��� ������� ���������� �������� �� ������� '||c.idsmr||' p_TypeCom='||p_TypeCom);
    END LOOP;
    Return 0;
  exception
    when others then
      WriteProtocol('������ ���������� ��������� CalcEveryDayComissAll_UBRR: '||dbms_utility.format_error_backtrace);
      p_Mess := '������ ���������� ��������� CalcEveryDayComissAll_UBRR: '||dbms_utility.format_error_backtrace;
      RETURN -1;
  END;


  FUNCTION CalcEveryDayComissUBRR
   (
    p_Date in date, -- ���� �������
    p_TypeCom IN NUMBER,
    /* ��� ��������
      -->> ���� ��� ����� ��������
      1 - �� ���������� ��������
      2 - �� ���������� �������� ����� 17-00
      4 - �� ���������� �������� � ������ ��
      --<< ���� ��� ����� ��������
      8 - ��
      �������� ������ ���������� �������� ���������������.
      �������� 1+2+4 = 7
    */
    p_ls in varchar2 default null, -- ���� ��� ������� ��������
    p_RegDate in date default null, -- ���� ����������� ����������
    p_Mess out varchar2
  ) RETURN NUMBER IS
    vRes NUMBER := 0;
    vMess VARCHAR2(2000);
    vRes1 NUMBER := 0;
    vRes2 NUMBER := 0;
    vRes2_p NUMBER := 0;
    vDateReg DATE := NVL(p_RegDate, p_Date);
    acc_1    varchar2(25) := nvl(p_ls,'40___810%');
    vrtv     varchar2(2000); -->><<-- 23.10.2017  ����� �.�.       17-1225
    vRes17  integer; -- 07.11.2017 ubrr korolkov 17-1071
  BEGIN
    delete ubrr_data.ubrr_sbs_new_log
    where sessionID = UserEnv('SessionID');
    commit;
    dDateR := p_Date  + 86399/86400;
    WriteProtocol('������ ������� ���������� �������� �� ������� '||ubrr_get_context()||' p_TypeCom='||p_TypeCom);
    BankIdSmr := ubrr_util.GetBankIdSmr;
    DBMS_TRANSACTION.COMMIT;

-->> 01.02.2019 ������� �.�. [19-58770] ��������� ���� ������� ����������� �������
    IF bitand(p_TypeCom,64) = 64 THEN
      WriteProtocol('������ �������������� ������� �� '||to_char(p_Date,'DD.MM.YYYY')||'  �� ����� ������ '||nvl(p_ls, '%'));
      vRes:=CalcProlongation(p_Date, acc_1, vDateReg, vMess);  -->><<--07.08.2019 �������� [19-62974] III ���� ���
      WriteProtocol('��������� �������������� ������� �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vRes);
      vRes2 := vRes2 + vRes;
    END IF;
--<< 01.02.2019 ������� �.�. [19-58770] ��������� ���� ������� ����������� �������

    IF bitand(p_TypeCom,1) = 1 THEN
      WriteProtocol('������ ������� �������� �� �������� �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%'));

      ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif := 'Y'; --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
      ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_day := 'Y'; --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)

      vRes := CalcMoneyOrder_Ubrr(p_Date, acc_1, vMess);
      WriteProtocol('��������� ������� �������� �� �������� �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vRes);
      -->> 07.11.2017 ubrr korolkov 17-1071
      IF bitand(p_TypeCom,2) = 2 THEN
          WriteProtocol('������ ������� �������� �� �������� ����� 17-00 �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%'));
          vRes17 := CalcMoneyOrder17_Ubrr(p_Date, acc_1, vMess);
          WriteProtocol('��������� ������� �������� �� �������� ����� 17-00 �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||
                        '. ���������: '||vRes17);
      END IF;

        -- UBRR Pashevich A. 12-1566
        Declare
          v_travel  number := 0;
          v_csbsacc varchar2(25);
          v_csbscur varchar2(3);
          v_limit   number:=4000;
          v_tarsum  number;
        Begin
          For i in (Select csbsaccd, csbscurd
                      from ubrr_sbs_new
                     where dsbsdate = p_date
                       and csbstypecom in ('PP6', '017', '018')
                       and idsmr = sys_context('b21','idsmr')
                       and csbsaccd like acc_1
                       and exists (Select 1
                                   From xxi.AU_ATTACH_OBG au
                                   Where au.caccacc = csbsaccd
                                   and au.cacccur = csbscurd
                                   and d_create <= p_Date + 86399 / 86400
                                   and i_table = 304
                                   and au.c_newdata = '112/31')
                     Group by csbsaccd, csbscurd
                    Having sum(isbscountpays) > v_limit)
            Loop
                For u in (Select rowid t, csbsaccd, csbscurd, isbscountpays, msbssumcom
                          From ubrr_sbs_new
                          Where csbsaccd = i.csbsaccd
                          and csbscurd = i.csbscurd
                          and csbstypecom in ('PP6', '017', '018'))
                Loop
                    If v_travel = 0 Then
                        v_tarsum := u.msbssumcom / u.isbscountpays;
                        Update ubrr_sbs_new
                        Set isbscountpays = abs(least(v_limit - csbstypecom, 0)),
                            msbssumcom = abs(least(v_limit - isbscountpays, 0)) * v_tarsum
                        Where rowid = u.t;
                        v_travel := abs(least(v_limit - u.isbscountpays, 0));
                    End If;
                End Loop;
            End Loop;
            commit;
        End;
        -- UBRR Pashevich A. 12-1566
      --<< 07.11.2017 ubrr korolkov 17-1071

      if vRes > 0 THEN
        vRes2_p := vRes2_p + vRes;
        WriteProtocol('������ ����������� ���������� �� ������������ �������� �� ��������');
        UpdateAccComiss(1, p_Date, vDateReg, acc_1);
          vRes1 := Register( p_regdate             => vDateReg
                            ,p_TypeCom             => 1
                            ,p_Mess                => vMess
                            ,p_portion_date1       => p_Date
                            ,p_portion_date2       => p_Date
                            ,p_ls                  => acc_1
                            ,p_mode_available_rest => false); -- ubrr 03.08.2019  ������� �.�. [19-62808]   ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
        vRes2:=vRes2+vRes1;
        WriteProtocol('��������� ����������� ���������� �� ������������ �������� �� ��������. ���������: '||vRes1);
      end if;

      ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif := 'N'; -- 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
      ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_day := 'N'; --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)

    END IF;

    IF bitand(p_TypeCom,2) = 2 THEN

      ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif := 'Y'; --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
      ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_day := 'Y'; --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
          
      if vRes17 is null then -- 07.11.2017 ubrr korolkov 17-1071
          WriteProtocol('������ ������� �������� �� �������� ����� 17-00 �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%'));          
          vRes := CalcMoneyOrder17_Ubrr(p_Date, acc_1, vMess);
          WriteProtocol('��������� ������� �������� �� �������� ����� 17-00 �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vRes);
      end if;
      -->> 07.11.2017 ubrr korolkov 17-1071
      --if vRes > 0 THEN
      if vRes17 > 0 THEN
      --<< 07.11.2017 ubrr korolkov 17-1071
        vRes2_p := vRes2_p + vRes;
        WriteProtocol('������ ����������� ���������� �� ������������ �������� �� �������� ����� 17-00');
        UpdateAccComiss(2, p_Date, vDateReg, acc_1);
        vRes1 := Register( p_regdate             => vDateReg
                          ,p_TypeCom             => 2
                          ,p_Mess                => vMess
                          ,p_portion_date1       => p_Date
                          ,p_portion_date2       => p_Date
                          ,p_ls                  => acc_1
                          ,p_mode_available_rest => false); -- ubrr 03.08.2019  ������� �.�. [19-62808]   ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
        vRes2:=vRes2+vRes1;
        WriteProtocol('��������� ����������� ���������� �� ������������ �������� �� �������� ����� 17-00. ���������: '||vRes1);
      end if;
      
      ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif := 'N'; -- 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
      ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_day := 'N'; --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)

    END IF;

    /*
    IF bitand(p_TypeCom,4) = 4 THEN
      WriteProtocol('������ ������� �������� �� �������� � ������ �� �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%'));
      vRes:=CalcMoneyOrderULFL(p_Date, acc_1, vMess);
      WriteProtocol('��������� ������� �������� �� �������� � ������ �� �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vRes);
      if vRes>0 THEN
        vRes2_p := vRes2_p + vRes;
        WriteProtocol('������ ����������� ���������� �� ������������ �������� �� �������� � ������ ��');
        UpdateAccComiss(3, p_Date, vDateReg, acc_1);
        vRes1:=Register(vDateReg, 3, vMess, p_Date, p_Date, acc_1);
        vRes2:=vRes2+vRes1;
        WriteProtocol('��������� ����������� ���������� �� ������������ �������� �� �������� � ������ ��. ���������: '||vRes1);
      end if;
    END IF;*/
    IF bitand(p_TypeCom,8) = 8 THEN
      WriteProtocol('������ ������� �������� �� �� �� '||to_char(p_Date,'DD.MM.YYYY')||'  �� ����� ������ '||nvl(p_ls, '%'));
      ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_day := '%'; --30.09.2020  ������� �.�.     [20-73382.2] �������������� ������ �� �� �������� ��������� �� ������  
      ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif := 'Y';     --30.09.2020  ������� �.�.     [20-73382.2] �������������� ������ �� �� �������� ��������� �� ������      
      vRes:=CalcCashCom(p_Date, acc_1, vMess);
      WriteProtocol('��������� ������� �������� �� �� �� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vRes);
      if vRes>0 THEN
        vRes2_p := vRes2_p + vRes;
        WriteProtocol('������ ����������� ���������� �� ������������ �������� �� ��');
        UpdateAccComiss(4, p_Date, vDateReg, acc_1);   -->><<-- ubrr 19.10.2016 �������� �.�.   [16-2222]  #35311 �������� ���� �����������, � �� ���� �������
        vRes1 := Register( p_regdate             => vDateReg
                          ,p_TypeCom             => 4
                          ,p_Mess                => vMess
                          ,p_portion_date1       => p_Date
                          ,p_portion_date2       => p_Date
                          ,p_ls                  => acc_1
                          ,p_mode_available_rest => false); -- ubrr 03.08.2019  ������� �.�. [19-62808]   ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
        vRes2:=vRes2+vRes1;
        WriteProtocol('��������� ����������� ���������� �� ������������ �������� �� ��. ���������: '||vRes1);
      end if;
      ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_day := 'N'; --30.09.2020  ������� �.�.     [20-73382.2] �������������� ������ �� �� �������� ��������� �� ������  
      ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif := 'N';     --30.09.2020  ������� �.�.     [20-73382.2] �������������� ������ �� �� �������� ��������� �� ������      
    END IF;
    -->> 23.10.2017  ����� �.�.       17-1225
    IF bitand(p_TypeCom,16) = 16 THEN
        WriteProtocol('������ ������� �������� �� ������� ��-�� '||to_char(p_Date,'DD.MM.YYYY')||'  �� ����� ������ '||nvl(p_ls, '%'));

        ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif := 'Y'; --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
        ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_day := '%'; --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
      
        vrtv := ubrr_xxi5.ubrr_ulfl_comss_ver2.calc_mask_comss(p_Date, p_mask  => acc_1); --'UL_FL'
        -- ismrrr := sys_context('B21', 'IdSmr'); for test
        WriteProtocol('��������� ������� �������� �� ������� ��-�� '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vrtv);
        if vrtv like 'OK%' then
            vRes := to_number (substr (vrtv, 3)); --p_TypeCom := 16;
        else
            vRes := -1;
        end if;

        if vRes>0 THEN
            vRes2_p := vRes2_p + vRes;
            WriteProtocol('������ ����������� ���������� �� ������������ �������� �� ������� ��-��');
            UpdateAccComiss(16, p_Date, vDateReg, acc_1);   -->><<-- ubrr 19.10.2016 �������� �.�.   [16-2222]  #35311 �������� ���� �����������, � �� ���� �������
            vRes1 := Register( p_regdate             => vDateReg
                              ,p_TypeCom             => 16
                              ,p_Mess                => vMess
                              ,p_portion_date1       => p_Date
                              ,p_portion_date2       => p_Date
                              ,p_ls                  => acc_1
                              ,p_mode_available_rest => false); -- ubrr 03.08.2019  ������� �.�. [19-62808]   ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
            vRes2:=vRes2+vRes1;
            WriteProtocol('��������� ����������� ���������� �� ������������ �������� �� ������� ��-��. ���������: '||vRes1);
        end if;

        ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif := 'N'; -- 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
        ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_day := 'N'; --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
        
    END IF;

    IF bitand(p_TypeCom,32) = 32 THEN
        WriteProtocol('������ ������� �������� �� ��������� ������ �� ������������������� ������������ '||to_char(p_Date,'DD.MM.YYYY')||'  �� ����� ������ '||nvl(p_ls, '%'));
        
        ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif := 'Y'; --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
        ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_day := '%'; --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
        
        vrtv := ubrr_xxi5.ubrr_ulfl_comss_ver2.calc_mask_comss_businact(p_Date, p_mask  => acc_1); --'IP_DOH'
        -- ismrrr := sys_context('B21', 'IdSmr'); for test
        WriteProtocol('��������� ������� �������� �� ��������� ������ �� ������������������� ������������ '||to_char(p_Date,'DD.MM.YYYY')||' �� ����� ������ '||nvl(p_ls, '%')||'. ���������: '||vrtv);
        if vrtv like 'OK%' then
            vRes := to_number (substr (vrtv, 3)); -- p_TypeCom := 32;
        else
            vRes := -1;
        end if;

        if vRes>0 THEN
            vRes2_p := vRes2_p + vRes;
            WriteProtocol('������ ����������� ���������� �� ������������ �������� �� ��������� ������ �� ������������������� ������������');
            UpdateAccComiss(32, p_Date, vDateReg, acc_1);   -->><<-- ubrr 19.10.2016 �������� �.�.   [16-2222]  #35311 �������� ���� �����������, � �� ���� �������
            vRes1 := Register( p_regdate             => vDateReg
                              ,p_TypeCom             => 32
                              ,p_Mess                => vMess
                              ,p_portion_date1       => p_Date
                              ,p_portion_date2       => p_Date
                              ,p_ls                  => acc_1
                              ,p_mode_available_rest => false); -- ubrr 03.08.2019  ������� �.�. [19-62808]   ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
            vRes2:=vRes2+vRes1;
            WriteProtocol('��������� ����������� ���������� �� ������������ �������� �� ��������� ������ �� ������������������� ������������. ���������: '||vRes1);
        end if;

        ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif := 'N'; -- 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
        ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_day := 'N'; --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)

    END IF;
    --<< 23.10.2017  ����� �.�.       17-1225

    WriteProtocol('��������� ������� ���������� �������� � ����������� ���������� �� ������� '||ubrr_get_context());
    commit;
    p_Mess := '��������� ��������: '||vRes2_p;
    RETURN vRes2;
  exception
    when others then
      WriteProtocol('������ ���������� ��������� CalcEveryDayComissUBRR: '||dbms_utility.format_error_backtrace);
      p_Mess := '������ ���������� ��������� CalcEveryDayComissUBRR: '||dbms_utility.format_error_backtrace;
      RETURN -1;
  END;
  --<< ubrr 06.10.2016 �������� �.�.   [16-2222]  #35311  ���������� �������� �� �������� �������� �����

    procedure set_purp_ntk
    is
    begin
        ubrr_bnkserv_calc_new_lib.g_purp_ntk := 1; -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
    end;

  -->>08.11.2018 �������� [18-592.2] ���. ������� �������� �� ���������. �������� ��������� ������ 114/12
  procedure delete_rb_ib_lt(d1 in date, d2 in date, trndate in date, p_ls in varchar2, verr out varchar2)
  is
    iCnt   number;
    iRes   number;
    acc_1   varchar2(25) := nvl(p_ls, '40___810%');
  begin
    WriteProtocol('R_IB_LT ������� �������� �� ���������. �������� ������.');

    iCnt := 0;
    iRes := 0;

    for rr in (select t1.idabs, t1.syscreatetime, t1.activate
                  from correqts.sbns_ub_kontur_req@cts t1,
                    (select idabs, max(Syscreatetime) syscreatetime
                       from (select *
                               from (select t.*
                                       from correqts.sbns_ub_kontur_req@cts t,
                                            correqts.sbns_sign@cts s
                                      where t.signcollectionid = s.signcollectionid
                                      union
                                     select t.*
                                       from correqts.sbns_ub_kontur_req@cts t
                                      where t.agreement is null
                                        and t.SIGNCOLLECTIONID is null
                                        and t.state_id is null) m
                             where trunc(m.Syscreatetime) <= d2 -->><<--29.01.2019 �������� [18-592.2] ���. ������� �������� �� ���������
                              order by idabs, Syscreatetime)
                     group by idabs) t2
                where t1.idabs = t2.idabs
                  and t1.syscreatetime = t2.syscreatetime
                 and t1.activate = 0
                 and exists (select 1 from acc a where a.iacccus = t1.idabs and a.caccacc like acc_1)
                 and not exists (select 1 --t1.idabs, t1.syscreatetime, t1.activate
                                   from correqts.sbns_ub_kontur_req@cts tt1,
                                     (select *
                                                from (select t.*
                                                        from correqts.sbns_ub_kontur_req@cts t,
                                                             correqts.sbns_sign@cts s
                                                       where t.signcollectionid = s.signcollectionid
                                                       union
                                                      select t.*
                                                        from correqts.sbns_ub_kontur_req@cts t
                                                       where t.agreement is null
                                                         and t.SIGNCOLLECTIONID is null
                                                         and t.state_id is null) m
                                               where trunc(m.Syscreatetime) > d2 and trunc(m.Syscreatetime) <= trndate -->><<--29.01.2019 �������� [18-592.2] ���. ������� �������� �� ���������
                                                 and m.activate = 1 -->><<--29.01.2019 �������� [18-592.2] ���. ������� �������� �� ���������
                                               order by idabs, Syscreatetime) tt2
                                 where tt1.idabs = t1.idabs
                                   -->>14.03.2019 �������� #60496 https://redmine.lan.ubrr.ru/issues/60496#note-4
                                   and tt1.idabs = tt2.idabs
                                   and tt1.syscreatetime = tt2.syscreatetime
                                   --<<14.03.2019 �������� #60496 https://redmine.lan.ubrr.ru/issues/60496#note-4
                                )
    ) loop
        iCnt := 0;
        for rrr in (select a.caccacc, a.cacccur
                      from acc a
                     where a.iacccus = rr.Idabs
                       and a.caccacc like acc_1
                       and a.caccacc in (select g.cgacacc
                                           from gac g
                                          where g.cgacacc = a.caccacc
                                            and g.cgaccur = a.cacccur
                                            and g.igaccat = 114
                                            and g.igacnum = 12)
                              and exists (select 1
                                          from xxi.au_attach_obg au
                                          where au.caccacc = a.cACCacc
                                            and au.cacccur = a.cACCcur
                                            and i_table = 304
                                            and d_create <= d2
                                            and au.c_newdata = '114/12')
        ) loop
            delete from gac
             where cgacacc = rrr.caccacc
               and cgaccur = rrr.cacccur
               and igaccat = 114
               and igacnum = 12;

            iCnt := iCnt + sql%rowcount;

            update au_attach_obg
               set d_create = add_months(last_day(d_create), -1)
             where i_table = 304
               and caccacc = rrr.caccacc
               and cacccur = rrr.cacccur
               and c_type = 'D'
               and trunc(d_create) = trunc(sysdate)
               and c_olddata = '114/12';
        end loop; --rrr

        if iCnt > 0 then
            WriteProtocol('R_IB_LT ������� �������� �� ���������. ������ ' || rr.Idabs || ', ������� ' || iCnt || ' ������');
        end if;
        iRes := iRes + iCnt;
    end loop; --rr

    commit;
    WriteProtocol('R_IB_LT ������� �������� �� ���������. ������� ' || iRes || ' ������');

    verr := 'OK';
  exception
    when others then
      verr := '������� �������� �� ���������. ������ �������� ������. ' || dbms_utility.format_error_stack || chr(10) || dbms_utility.format_error_backtrace;
      WriteProtocol( verr );
  end delete_rb_ib_lt;
  --<<08.11.2018 �������� [18-592.2] ���. ������� �������� �� ���������. �������� ��������� ������ 114/12



-->> 01.02.2019 ������� �.�. [19-58770] ��������� ���� ������� ����������� �������
  -- �� ��������� UBRR_XXI5.UBRR_BNKSERV
  FUNCTION CalcProlongation -->><<--07.08.2019 �������� [19-62974] III ���� ���
   (
    p_Date in date, -- ���� �������
    p_ls in varchar2 default null, -- ���� ��� ������� ��������
    p_RegDate in date default null, -- ���� ����������� ����������
    p_Mess out varchar2
  ) RETURN NUMBER IS

    type t_tSbs Is record (
            cSBSaccd           ubrr_data.ubrr_sbs_new.cSBSaccd%type,
            cSBScurd           ubrr_data.ubrr_sbs_new.cSBScurd%type,
            mSBSsumcom         ubrr_data.ubrr_sbs_new.mSBSsumcom%type,
            cSBSTypeCom        ubrr_data.ubrr_sbs_new.cSBSTypeCom%type,
            iACCotd            acc.iACCotd%type,
            cACCap             acc.cACCap%type,
            iACCcus            acc.iACCcus%type,
            cACCprizn          acc.cACCprizn%type,
            iSBSBatNum         ubrr_data.ubrr_sbs_new.iSBSbatnum%type,
            cSBSaccc           ubrr_data.ubrr_sbs_new.cSBSaccc%type,
            cSBScurc           ubrr_data.ubrr_sbs_new.cSBScurc%type,
            inum112            number,
            id                 ubrr_data.ubrr_sbs_new.id%type, -- 09.04.2020  ������� �.�.     [20-73890]   ������ ���/�� 112/102 (������-����� 12") �� �����������������
            csbsstat           ubrr_data.ubrr_sbs_new.csbsstat%type
        );
    type t_tSbs_Table is Table of t_tSbs index by binary_integer;

    tSbsList       t_tSbs_Table;
    acc_1          varchar2(25) := NVL(p_ls,'40___810%');
    v_iSBSTypeCom  ubrr_data.ubrr_sbs_new.iSBSTypeCom% type := 64;
    vErr           ubrr_sbs_new.csbsstat%type;                                   -- 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
    lc_name_prol   constant varchar2(50):= '�������� �� ��������������� ������'; -- 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
    cityname       ubrr_data.ubrr_comm_mvz.ccity%type;
    inum112        number;
    inum131        number;
    imvz           number;
    comiss         number;
    v_session_ID   au_session.ID%type;
    vFirstWorkDay  date;
    iCnt           number := 0;
    vRes           number := 0;
    vc_Mask        varchar2(25); -- ����� �����
    vc_acc_ur      varchar2(25);
    vc_acc_ip      varchar2(25);
    vc_ComCode     varchar2(10);
    vn_Count       number;
    l_sqlerrm      varchar2(1000);                                     -- 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
    l_cmsg         varchar2(4000):=$$plsql_unit||'.CalcProlongation';  -- 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
    ov_curr_context  smr.IDSMR%type := ubrr_get_context; -->><<-- 29.05.2020 ������ �.�. [20-74767] ����������: ���������� �������� �� ���. 114/16 � ������ ������� ������������ 114/16    

    -- �� ����� RBS_NEW
    FUNCTION Get_Acc_COMMS (Mask     IN   VARCHAR2) RETURN VARCHAR2 IS
         cvAccount  ACC.cACCacc%TYPE;         -- ����� ���� �������
    BEGIN
      SELECT ACC.cACCacc
        INTO cvAccount
        FROM ACC
        WHERE ACC.cACCacc LIKE  Mask
          AND ACC.cACCcur = 'RUR';
      Return cvAccount;
    EXCEPTION
      WHEN No_Data_Found THEN
        IF SUBSTR(Mask,10,11) like '62__2406243' THEN
          Return '70601810462162406243';
        ELSIF SUBSTR(Mask,10,2) = '62' THEN
          Return '70601810362162101208';
        ELSE
          Return '70601810263012101208';
        END IF;
    END Get_Acc_Comms;


-- >> ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
-------------------------------------------------------
    -- ���������� imvz ��� ubrr_comm_mvz_tarif
    procedure get_cmvz_cond( p_acc in varchar2
                            ,p_cur in varchar2 )
    is
    begin
      begin
        select igacnum
          into inum131
          from gac
          where cgacacc = p_acc --tSbsList(i).cSBSaccd
            and cgaccur = p_cur --tSbsList(i).cSBScurd
            and igaccat = 131;
      exception
        when no_data_found then
          vErr := '������ �� �������'; -->><<--09.08.2019 �������� [IM2235961-001]
      end;

      begin
        select cmvz
          into imvz
          from ubrr_comm_gacmvz_tarif
          where icat = 131
            and inum = inum131;
      exception
        when no_data_found then
          imvz := 0;
      end;

      begin
        select ccity
          into cityname
          from ubrr_comm_mvz
          where cmvz = imvz;
      exception
        when no_data_found then
          cityname := '����� �� ���������';
      end;

      -- 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
--      if cityname = '����� �� ���������' then
--        vErr := '����� �� ���������';
--        imvz := null;
--      elsif cityname = '������ ������' then
--        imvz := 0;
--      end if;
        -- cityname ����� ������������ �� ���������, ������� ������� ����� imvz := 0
        if cityname = '������ ������' then
                imvz := 0;
        end if;
      -- 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
    end get_cmvz_cond;

    ----------------------------------------------------
    function is_exist_cacc_cat( p_acc in varchar2
                               ,p_cur in varchar2
                               ,p_cat in number
                               )
    return boolean
    is
      l_cnt pls_integer;
    begin
       select count(1)
         into l_cnt
         from dual
        where exists( select igacnum
                        from gac
                       where cgacacc = p_acc
                         and cgaccur = p_cur
                         and igaccat = p_cat
                    );
       return (l_cnt=1);
    end is_exist_cacc_cat;

-- >> ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"

    -->> 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
    function msg_error( p_cacc   in varchar2
                       ,p_ccur   in varchar2
                       ,p_num112 in number
                       ,p_imvz   in number )
    return varchar2
    is
      l_cobg_name xxi.obg.cobgname%type;
      l_n131_num  xxi.obg.iobgnum%type;
      l_cstr ubrr_sbs_new.csbsstat%type;
    begin
      l_cstr:=lc_name_prol;

      -- 131 ���
      begin
           select s.igacnum
                 ,s.cobgname
             into l_n131_num
                 ,l_cobg_name
             from ( select g.cgacacc
                          ,g.igacnum
                          ,ob.cobgname
                          ,row_number() over (partition by g.cgacacc order by g.igacnum asc ) rn
                      from xxi."gac" g
                          ,xxi.obg ob
                     where 1=1
                       and ob.iobgcat = g.igaccat
                       and ob.iobgnum = g.igacnum
                       and cgacacc    = p_cacc
                       and cgaccur    = p_ccur
                       and igaccat    = 131
                  ) s
                where s.rn = 1; -- ������ �� ����. �������
      exception when no_data_found
         then null;
      end;
      l_cstr := l_cstr||' [131,'||l_n131_num||' '||l_cobg_name||']' ;

      -- 112 ���
      begin
       select ob.cobgname
         into l_cobg_name
         from xxi.obg ob
        where ob.iobgcat = 112
          and ob.iobgnum = p_num112;
      exception when no_data_found
         then null;
      end;
      l_cstr := l_cstr||' [112,'||p_num112||' '||l_cobg_name||'][imvz='||p_imvz||']' ;

      return l_cstr;
    end msg_error;
    --<< 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������

  begin ------------------CalcProlongation---------------------------   -->><<--07.08.2019 �������� [19-62974] III ���� ���

    -->> 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
     l_cmsg := l_cmsg || ' ['||
            'p_date='      ||to_char(p_date,'dd.mm.yyyy')   ||';'||
            'p_RegDate='   ||to_char(p_RegDate,'dd.mm.yyyy')||';'||
            'acc_1='       ||nvl(acc_1,'null')              ||';'||
            '] ';

     ubrr_bnkserv_calc_new_lib.WriteProtocol('������ '||l_cmsg);
    --<< 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������

    for cDate in (select DDATE
                    from xxi.caliso
                    where CISO = 'RUR'
                      and CTYPE = 'W'
                      and DDATE >= first_day(p_Date)
                    order by DDATE)
    loop
      vFirstWorkDay := cDate.DDATE;
      exit;
    end loop;

    if vFirstWorkDay <> p_Date then
      return 0;
    end if;

    tSbsList.delete;

    triggers_ubrr.Set_AllTriggersDisable;
    delete from gac
      where igaccat = 114
        and igacnum = 16
        and CGACACC like acc_1
-->> 29.09.2020 ������� �.�. [20-80050] ����: �� ������������� ���/�� ��� ����� ������
        and not exists (select 1
                          from xxi.au_attach_obg au
                          where au.I_TABLE = 304
                            and au.D_CREATE = first_day(p_Date) - 1/24/60/60
                            and au.C_TYPE = 'I'
                            and au.C_NEWDATA = '114/16'
                            and au.I_PROGRAM = xxi.auditing.get_id_glossary(correqts.ubrr_tariff_gate.getModuleName)
                            and au.I_ACTION = xxi.auditing.get_id_glossary(correqts.ubrr_tariff_gate.getActionName)
                            and au.CACCACC = CGACACC
                            and au.CACCCUR = CGACCUR)
--<< 29.09.2020 ������� �.�. [20-80050] ����: �� ������������� ���/�� ��� ����� ������
        and IdSmr = ov_curr_context;/*SYS_CONTEXT('B21','IdSmr')*/ -->><<-- 29.05.2020 ������ �.�. [20-74767] ����������: ���������� �������� �� ���. 114/16 � ������ ������� ������������ 114/16    

    insert into gac (CGACCUR, IGACCAT, IGACNUM, CGACACC, IDSMR)
      select au.CACCCUR CGACCUR, substr(au.C_OLDDATA, 1, instr(au.C_OLDDATA, '/') - 1) IGACCAT, substr(au.C_OLDDATA, instr(au.C_OLDDATA, '/') + 1) IGACNUM, au.CACCACC CGACACC, ov_curr_context/*SYS_CONTEXT('B21','IdSmr') */IDSMR -->><<-- 29.05.2020 ������ �.�. [20-74767] ����������: ���������� �������� �� ���. 114/16 � ������ ������� ������������ 114/16    
        from xxi.au_attach_obg au
        where I_TABLE = 304
          and D_CREATE = first_day(p_Date) - 1/24/60/60
          and C_OLDDATA in ('112/78', '112/79', '112/80', '112/99', '112/100', '112/101', '112/102', '112/103'
                           ,'112/104', '112/105', '112/106'  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                           )
          and C_TYPE = 'D'
          and not exists (select 1
                            from gac g
                            where g.CGACCUR = au.CACCCUR
                              and g.IGACCAT = substr(au.C_OLDDATA, 1, instr(au.C_OLDDATA, '/') - 1)
                              and g.IGACNUM = substr(au.C_OLDDATA, instr(au.C_OLDDATA, '/') + 1)
                              and g.CGACACC = au.CACCACC
                              and g.IDSMR =  ov_curr_context/*SYS_CONTEXT('B21','IdSmr')*/) -->><<-- 29.05.2020 ������ �.�. [20-74767] ����������: ���������� �������� �� ���. 114/16 � ������ ������� ������������ 114/16    
          and (CACCCUR, CACCACC) in (select CSBSCURD, CSBSACCD
                                       from ubrr_data.ubrr_sbs_new
                                       where IdSmr = ov_curr_context/*SYS_CONTEXT('B21','IdSmr')*/ -->><<-- 29.05.2020 ������ �.�. [20-74767] ����������: ���������� �������� �� ���. 114/16 � ������ ������� ������������ 114/16    
                                         and isbstrnnum is null
                                         and dSBSDate = p_Date
                                         and isbstypecom = v_iSBSTypeCom
                                         and cSBSaccd like acc_1);
    triggers_ubrr.Set_AllTriggersEnable;

    delete from xxi.au_attach_obg o
      where I_TABLE = 304
        and D_CREATE >= first_day(p_Date) - 1/24/60/60
        and D_CREATE <= sysdate
        and (C_NEWDATA = '114/16'
             or C_OLDDATA = '114/16')
        and CACCACC like acc_1
-->> 29.09.2020 ������� �.�. [20-80050] ����: �� ������������� ���/�� ��� ����� ������
        and nvl(o.I_PROGRAM, 0) <> xxi.auditing.get_id_glossary(correqts.ubrr_tariff_gate.getModuleName)
        and nvl(o.I_ACTION, 0) <> xxi.auditing.get_id_glossary(correqts.ubrr_tariff_gate.getActionName)
--<< 29.09.2020 ������� �.�. [20-80050] ����: �� ������������� ���/�� ��� ����� ������
        and exists (select 1
                      from acc a
                      where a.IdSmr = ov_curr_context/*SYS_CONTEXT('B21','IdSmr')*/ -->><<-- 29.05.2020 ������ �.�. [20-74767] ����������: ���������� �������� �� ���. 114/16 � ������ ������� ������������ 114/16    
                        and a.CACCACC like o.CACCACC
                        and a.CACCCUR like o.CACCCUR);

    delete from xxi.au_attach_obg
      where I_TABLE = 304
        and D_CREATE = first_day(p_Date) - 1/24/60/60
        and C_OLDDATA in ('112/78', '112/79', '112/80', '112/99', '112/100', '112/101', '112/102', '112/103'
                         ,'112/104', '112/105', '112/106'  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                         )
        and C_TYPE = 'D'
        and (CACCCUR, CACCACC) in (select CSBSCURD, CSBSACCD
                                     from ubrr_data.ubrr_sbs_new
                                     where IdSmr = ov_curr_context/*SYS_CONTEXT('B21','IdSmr')*/ -->><<-- 29.05.2020 ������ �.�. [20-74767] ����������: ���������� �������� �� ���. 114/16 � ������ ������� ������������ 114/16    
                                       and isbstrnnum is null
                                       and dSBSDate = p_Date
                                       and isbstypecom = v_iSBSTypeCom
                                       and cSBSaccd like acc_1);

    delete from xxi.au_attach_obg
      where I_TABLE = 304
        and D_CREATE = first_day(p_Date)
        and C_NEWDATA in ('112/78', '112/79', '112/80', '112/99', '112/100', '112/101', '112/102', '112/103'
                         ,'112/104', '112/105', '112/106'  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                         )
        and C_TYPE = 'I'
        and (CACCCUR, CACCACC) in (select CSBSCURD, CSBSACCD
                                     from ubrr_data.ubrr_sbs_new
                                     where IdSmr = ov_curr_context/*SYS_CONTEXT('B21','IdSmr')*/ -->><<-- 29.05.2020 ������ �.�. [20-74767] ����������: ���������� �������� �� ���. 114/16 � ������ ������� ������������ 114/16    
                                       and isbstrnnum is null
                                       and dSBSDate = p_Date
                                       and isbstypecom = v_iSBSTypeCom
                                       and cSBSaccd like acc_1);

    delete from ubrr_data.ubrr_sbs_new
      where IdSmr = ov_curr_context/*SYS_CONTEXT('B21','IdSmr')*/ -->><<-- 29.05.2020 ������ �.�. [20-74767] ����������: ���������� �������� �� ���. 114/16 � ������ ������� ������������ 114/16    
        and isbstrnnum is null
        and dSBSDate = p_Date
        and isbstypecom = v_iSBSTypeCom
        and cSBSaccd like acc_1
        and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
        ;

    commit;

    v_session_ID := auditing.V_ID_SESSION;

    select caccacc, cacccur, 0, 0, iACCotd, cACCap, iACCcus, cACCprizn, to_number(to_char(nvl(o.iOTDbatnum, 70)) || '00') batnum, null, null, null
          , null -- id       -- 09.04.2020  ������� �.�.     [20-73890]   ������ ���/�� 112/102 (������-����� 12") �� �����������������
          , null -- csbsstat -- 09.04.2020  ������� �.�.     [20-73890]   ������ ���/�� 112/102 (������-����� 12") �� �����������������
      Bulk Collect Into tSbsList
      from acc a
           left join otd o on o.IOTDNUM = a.IACCOTD
      where caccacc like acc_1
        and cacccur = 'RUR'
        and cACCprizn <> '�'
        and substr(caccacc,1,3) not in ('401','402','403','404','409')
        and exists (select 1
                      from gac
                      where cgacacc = a.cACCacc
                        and cgaccur = a.cACCcur
                        and igaccat = 112
                        and igacnum in (78, 79, 80, 99, 100, 101, 102, 103
                                       ,104,105,106 -- ������  �������  3, 6, 12  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                                       )
                        and exists (select 1
                                      from xxi.au_attach_obg au
                                      where au.caccacc = a.cACCacc
                                        and au.cacccur = a.cACCcur
                                        and i_table = 304
                                        and add_months(first_day(au.d_create), decode(igacnum,  99, 1,
                                                                                               103, 1,
                                                                                                78, 3,
                                                                                               100, 3,
                                                                                               104, 3, -- ������  �������  3, 6, 12  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                                                                                                79, 6,
                                                                                               101, 6,
                                                                                               105, 6, -- ������  �������  3, 6, 12  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                                                                                                80, 12,
                                                                                               102, 12,
                                                                                               106, 12 -- ������  �������  3, 6, 12  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                                                                                               )
                                                      ) = first_day(p_Date)
                                        and au.c_newdata like '112/'||to_char(gac.igacnum)
                                        and au.d_create = (select max(au1.d_Create)
                                                             from xxi.au_attach_obg au1
                                                             where au1.Caccacc = au.Caccacc
                                                               and au1.Cacccur = au.Cacccur
                                                               and i_table = 304
                                                               and au1.c_type in ('I', 'U')
                                                               and au1.c_newdata like '112/'||to_char(gac.igacnum))
                              )
                   )
-->> 29.09.2020 ������� �.�. [20-80050] ����: �� ������������� ���/�� ��� ����� ������
        and not exists (select 1
                          from gac g
                          where g.CGACACC = a.cACCacc
                            and g.CGACCUR = a.cACCcur
                            and g.IDSMR = a.IDSMR
                            and g.IGACCAT = 114
                            and g.IGACNUM = 16)
--<< 29.09.2020 ������� �.�. [20-80050] ����: �� ������������� ���/�� ��� ����� ������
        -->> 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
        and not exists (select 1 from UBRR_UNIQUE_TARIF_ACC uutc where caccacc = uutc.cacc and p_Date between uutc.DOPENTARIF and uutc.DCANCELTARIF and SYS_CONTEXT ('B21', 'IDSmr') = uutc.idsmr and uutc.status = 'N');
        --<< 31.08.2020 ������� �.�. [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��


    if nvl(tSbsList.count, 0) > 0 then
      for i in tSbsList.first .. tSbsList.last Loop
        vErr := null;

        begin  -- 09.04.2020  ������� �.�.     [20-73890]   ������ ���/�� 112/102 (������-����� 12") �� �����������������

        begin   -- 13.03.2020  ������� �.�. [20-72185] ���/�� 112/101 (������-����� 6") �� ����������������� � �� ��������� ����� ��������� ����� (01.01.2020)
           select g1.igacnum
             into inum112
             from gac g1
             where g1.cgacacc = tSbsList(i).cSBSaccd
               and g1.cgaccur = tSbsList(i).cSBScurd
               and g1.igaccat = 112
               and g1.igacnum in (78,79,80,99,100,101,102,103
                                 ,104,105,106 -- ������  �������  3, 6, 12  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                                 );
        -->> 13.03.2020  ������� �.�. [20-72185] ���/�� 112/101 (������-����� 6") �� ����������������� � �� ��������� ����� ��������� ����� (01.01.2020)
        exception
             when no_data_found then
                vErr := lc_name_prol||': �� ����� �� ������� 112 ���'; -- 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
                comiss := null;
             when too_many_rows then
                vErr := lc_name_prol||': �� ����� 112 ��� ����� �����'; -- 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
                comiss := null;
        end;
        if ( vErr is null ) then
        --<< 13.03.2020  ������� �.�. [20-72185] ���/�� 112/101 (������-����� 6") �� ����������������� � �� ��������� ����� ��������� ����� (01.01.2020)
            if inum112 not in (99,100,101,102) then
               -- >> ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
               if ( inum112 in ( 104,105,106 ) ) then
                  if is_exist_cacc_cat( p_acc => tSbsList(i).cSBSaccd
                                       ,p_cur => tSbsList(i).cSBScurd
                                       ,p_cat => 131 ) then
                     get_cmvz_cond( p_acc => tSbsList(i).cSBSaccd
                                   ,p_cur => tSbsList(i).cSBScurd );
                  else
                     imvz := tSbsList(i).iACCotd;
                  end if;
               else
                  get_cmvz_cond( p_acc => tSbsList(i).cSBSaccd
                                ,p_cur => tSbsList(i).cSBScurd );
               end if;
               -- << ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
            else
              imvz := tSbsList(i).iACCotd;
            end if;

            begin
              select msum, tarif_text, substr(acc_ur, 14, 5), substr(acc_ip, 14, 5),substr(acc_ip, 10, 1)||substr(acc_ip, 19, 2)
                into comiss, tSbsList(i).cSBSTypeCom, vc_acc_ur, vc_acc_ip, vc_ComCode
                from ubrr_comm_mvz_tarif
                where cmvz = imvz
                  and tarif = '112/'||inum112;
            exception
              when no_data_found then
                vErr := msg_error( p_cacc   => tSbsList(i).cSBSaccd
                                  ,p_ccur   => tSbsList(i).cSBScurd
                                  ,p_num112 => inum112
                                  ,p_imvz   => imvz ) ||'�������� � ubrr_comm_mvz_tarif �� �������';
                --vErr := '�������� � ubrr_comm_mvz_tarif �� �������. imvz='||imvz||';inum112='||inum112||';'; -- 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
                comiss := null;
             -->> 13.03.2020  ������� �.�. [20-72185] ���/�� 112/101 (������-����� 6") �� ����������������� � �� ��������� ����� ��������� ����� (01.01.2020)
             when too_many_rows then
                vErr := msg_error( p_cacc   => tSbsList(i).cSBSaccd
                                  ,p_ccur   => tSbsList(i).cSBScurd
                                  ,p_num112 => inum112
                                  ,p_imvz   => imvz ) ||'������� � ubrr_comm_mvz_tarif ������ �����';
                --vErr := '������� � ubrr_comm_mvz_tarif ������ �����. imvz='||imvz||';inum112='||inum112||';'; -- 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
                comiss := null;--<< 13.03.2020  ������� �.�. [20-72185] ���/�� 112/101 (������-����� 6") �� ����������������� � �� ��������� ����� ��������� ����� (01.01.2020)
            end;
        end if; -- << 13.03.2020  ������� �.�. [20-72185] ���/�� 112/101 (������-����� 6") �� ����������������� � �� ��������� ����� ��������� ����� (01.01.2020)

        -->> 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
        tSbsList(i).csbsstat   := vErr;
        tSbsList(i).mSBSsumcom := comiss;
        --<< 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������

        vc_Mask := UBRR_RKO_SYMBOLS.get_new_rko_mask(to_char(tSbsList(i).iACCotd), vc_ComCode, tSbsList(i).cSBSaccd, tSbsList(i).cSBScurd, vc_acc_ur, vc_acc_ip);
        tSbsList(i).cSBSaccc := Get_Acc_COMMS(vc_Mask);
        tSbsList(i).cSBScurc := 'RUR';
        tSbsList(i).inum112 := inum112;

        -->> 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
        exception when others then
          ubrr_bnkserv_calc_new_lib.WriteProtocol('ERROR '||l_cmsg||'cSBSTypeCom='||tSbsList(i).cSBSTypeCom||'; '|| sqlerrm || ' ' || dbms_utility.format_error_backtrace);
          tSbsList(i).csbsstat := substr('ERROR '||l_cmsg||'; '|| sqlerrm || ' ' || dbms_utility.format_error_backtrace, 1,2000);
        end;
        --<< 09.04.2020  ������� �.�.     [20-73890]   ������ ���/�� 112/102 (������-����� 12") �� �����������������

        tSbsList(i).id:=ubrr_sbs_new_id_seq.nextval; -- 09.04.2020  ������� �.�.     [20-73890]   ������ ���/�� 112/102 (������-����� 12") �� �����������������

        insert into ubrr_data.ubrr_sbs_new(cSBSaccd, cSBScurd, cSBSaccc, cSBScurc, cSBSTypeCom, mSBSsumpays, iSBScountPays, mSBSsumcom, iSBSotdnum, iSBSBatNum, dSBSDate, iSBSTypeCom, dsbsdatereg
                                           ,id, csbsstat -- 09.04.2020  ������� �.�.     [20-73890]   ������ ���/�� 112/102 (������-����� 12") �� �����������������
                                          )
          values(tSbsList(i).cSBSaccd,
                 tSbsList(i).cSBScurd,
                 tSbsList(i).cSBSaccc,
                 tSbsList(i).cSBScurc,
                 tSbsList(i).cSBSTypeCom,
                 0,
                 0,
                 tSbsList(i).mSBSsumcom,
                 tSbsList(i).iACCotd,
                 tSbsList(i).iSBSBatNum,
                 p_Date,
                 v_iSBSTypeCom,
                 p_RegDate,
                 tSbsList(i).id,      -- 09.04.2020  ������� �.�.     [20-73890]   ������ ���/�� 112/102 (������-����� 12") �� �����������������
                 tSbsList(i).csbsstat -- 09.04.2020  ������� �.�.     [20-73890]   ������ ���/�� 112/102 (������-����� 12") �� �����������������
                 );

        iCnt := iCnt + 1;

      end loop;
    end if;
    commit;

    if iCnt > 0 then

      vRes := Register(p_RegDate, 64, p_Mess, p_Date, p_Date, acc_1);

      iCnt := 0;
      triggers_ubrr.Set_AllTriggersDisable;
      for i in tSbsList.first .. tSbsList.last loop

        -->> 09.04.2020  ������� �.�.     [20-73890]   ������ ���/�� 112/102 (������-����� 12") �� �����������������
        begin
        if ( tSbsList(i).csbsstat is not null ) then -- �� ����_����� �� ����� ���� ������
           continue;
        end if;
        --<< 09.04.2020  ������� �.�.     [20-73890]   ������ ���/�� 112/102 (������-����� 12") �� �����������������

        select count(1)
          into vn_Count
          from ubrr_data.ubrr_sbs_new
          where IdSmr = ov_curr_context/*SYS_CONTEXT('B21','IdSmr')*/ -->><<-- 29.05.2020 ������ �.�. [20-74767] ����������: ���������� �������� �� ���. 114/16 � ������ ������� ������������ 114/16    
            and isbstrnnum is not null
            and cSBSstat = '���������'
            and cSBSaccd = tSbsList(i).cSBSaccd
            and cSBScurd = tSbsList(i).cSBScurd
            and cSBSaccc = tSbsList(i).cSBSaccc
            and cSBScurc = tSbsList(i).cSBScurc
            and cSBSTypeCom = tSbsList(i).cSBSTypeCom
            and iSBSotdnum = tSbsList(i).iACCotd
            and iSBSBatNum = tSbsList(i).iSBSBatNum
            and dSBSDate = p_Date
            and iSBSTypeCom = v_iSBSTypeCom
            and dsbsdatereg = p_RegDate
            and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold2month -- ubrr 03.08.2019  ������� �.�. [19-62808] ���: ������� �������� �� ������� � ����������� ��� ������� ���������� �� �����
            ;

        if vn_Count > 0 then
          -- ���� ��������� ������� ��������� ������� ��������,
          -- �� ��������� � ����.����� ��������� ������ ���������� ����� � ���������� ������ 1 ������ ���.���,
          insert into xxi.au_attach_obg(I_TABLE, I_NUM, D_CREATE, C_NEWDATA, C_OLDDATA, I_PROGRAM, I_ACTION, C_TYPE, CACCACC, CACCCUR, ID_AU_SESSION)
            select 304, tSbsList(i).iACCcus, first_day(p_Date) - 1/24/60/60, null, '112/' || tSbsList(i).inum112, null, null, 'D', tSbsList(i).cSBSaccd, tSbsList(i).cSBScurd, v_session_ID
              from dual
              where not exists (select 1
                                  from xxi.au_attach_obg
                                  where I_TABLE = 304
                                    and I_NUM = tSbsList(i).iACCcus
                                    and D_CREATE = first_day(p_Date) - 1/24/60/60
                                    and C_OLDDATA = '112/' || tSbsList(i).inum112
                                    and C_TYPE = 'D'
                                    and CACCACC = tSbsList(i).cSBSaccd
                                    and CACCCUR = tSbsList(i).cSBScurd);

          insert into xxi.au_attach_obg(I_TABLE, I_NUM, D_CREATE, C_NEWDATA, C_OLDDATA, I_PROGRAM, I_ACTION, C_TYPE, CACCACC, CACCCUR, ID_AU_SESSION)
            select 304, tSbsList(i).iACCcus, first_day(p_Date), '112/' || tSbsList(i).inum112, null, null, null, 'I', tSbsList(i).cSBSaccd, tSbsList(i).cSBScurd, v_session_ID
              from dual
              where not exists (select 1
                                  from xxi.au_attach_obg
                                  where I_TABLE = 304
                                    and I_NUM = tSbsList(i).iACCcus
                                    and D_CREATE = first_day(p_Date)
                                    and C_NEWDATA = '112/' || tSbsList(i).inum112
                                    and C_TYPE = 'I'
                                    and CACCACC = tSbsList(i).cSBSaccd
                                    and CACCCUR = tSbsList(i).cSBScurd);

          iCnt := iCnt + 1;
        else
          -- ����� �������� �� ���������, ����.����� ��������� ������ ����������� ������ � � ����� ���. ����� ���/�� 114/16.
          delete from gac
            where CGACCUR = tSbsList(i).cSBScurd
              and IGACCAT = 112
              and IGACNUM = tSbsList(i).inum112
              and CGACACC = tSbsList(i).cSBSaccd
              and IDSMR = ov_curr_context/*SYS_CONTEXT('B21','IdSmr')*/; -->><<-- 29.05.2020 ������ �.�. [20-74767] ����������: ���������� �������� �� ���. 114/16 � ������ ������� ������������ 114/16    

          insert into xxi.au_attach_obg(I_TABLE, I_NUM, D_CREATE, C_NEWDATA, C_OLDDATA, I_PROGRAM, I_ACTION, C_TYPE, CACCACC, CACCCUR, ID_AU_SESSION)
            values(304, tSbsList(i).iACCcus, first_day(p_Date) - 1/24/60/60, null, '112/' || tSbsList(i).inum112, null, null, 'D', tSbsList(i).cSBSaccd, tSbsList(i).cSBScurd, v_session_ID);
        end if;

        -- ����� ���/�� 114/16 �.�. ���������� ����.������ ����������� ������
        insert into gac(CGACCUR, IGACCAT, IGACNUM, CGACACC, IDSMR)
        values (tSbsList(i).cSBScurd, 114, 16, tSbsList(i).cSBSaccd, ov_curr_context/*SYS_CONTEXT('B21','IdSmr')*/); -->><<-- 29.05.2020 ������ �.�. [20-74767] ����������: ���������� �������� �� ���. 114/16 � ������ ������� ������������ 114/16    
        
        insert into xxi.au_attach_obg(I_TABLE, I_NUM, D_CREATE, C_NEWDATA, C_OLDDATA, I_PROGRAM, I_ACTION, C_TYPE, CACCACC, CACCCUR, ID_AU_SESSION)
          values(304, tSbsList(i).iACCcus, first_day(p_Date) - 1/24/60/60, '114/16', null, null, null, 'I', tSbsList(i).cSBSaccd, tSbsList(i).cSBScurd, v_session_ID);

        -->> 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
        exception when others then
          l_sqlerrm := substr( sqlerrm || ' ' || dbms_utility.format_error_backtrace, 1,1000);
          ubrr_bnkserv_calc_new_lib.WriteProtocol('ERROR '||l_cmsg||' '||l_sqlerrm);
          update ubrr_data.ubrr_sbs_new n
            set n.csbsstat = substr('ERROR '||l_cmsg||'; '|| l_sqlerrm, 1,2000)
          where n.id = tSbsList(i).id;
        end;
        --<< 09.04.2020  ������� �.�.     [20-73890]   ������ ���/�� 112/102 (������-����� 12") �� �����������������

      end loop;
      triggers_ubrr.Set_AllTriggersEnable;
      commit;
    end if;

    ubrr_bnkserv_calc_new_lib.WriteProtocol('��������� '||l_cmsg); -- 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������

    return iCnt;

  exception
    when others then
      p_Mess := '������ ���������� ��������� CalcProlongation: ' || SQLERRM || ' ' || dbms_utility.format_error_backtrace; -->><<--07.08.2019 �������� [19-62974] III ���� ���
      WriteProtocol(p_Mess);
      rollback;
      triggers_ubrr.Set_AllTriggersEnable;
      RETURN 0;
  end CalcProlongation; -- 09.04.2020  ������� �.�. [20-73890] ������ ���/�� 112/102 (������-����� 12") �� �����������������
--<< 01.02.2019 ������� �.�. [19-58770] ��������� ���� ������� ����������� �������

  -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
  ----------------------------------------------------------------
  -- �������� �� ���������� - ���������� ubrr_sbs_new
  -- ubrr_sbs_new.ISBSTYPECOM = 1001
  -- �������� !!! �����-�� ������� � SELECT ���� � UBRR_BNKSERV_CALC_NEW_LIB.doc_is_inc
  function fill_sbsnew_inc( p_date       in  date -- ���� ������� dd.mm.yyyy
                           ,p_date_begin in  date -- � ����� ���� ����� ��������
                           ,p_cls        in  varchar2 default null
                           ,p_cmess      out varchar2
                           ,p_test       in  pls_integer default 0 )
  return number
  is
    l_ctypecom ubrr_sbs_new.csbstypecom%type := 'INC';
    l_cidsmr   smr.idsmr%type := sys_context('b21', 'idsmr');
    l_cls      varchar2(25)   := nvl(p_cls, ubrr_bnkserv_calc_new_lib.gc_ls);
    l_idx      pls_integer;

    cursor l_cur( p_date     in date
                 ,p_cls      in varchar2
                 ,p_cidsmr   in varchar2
                 ,p_ctypecom in varchar2
                ) is
           select ubrr_data.ubrr_sbs_new_seq.nextval id
                 ,t.ctrnaccc       csbsaccd
                 ,t.ctrncur        csbscurd
                 ,p_ctypecom       csbstypecom
                 ,t.mtrnsum        mSBSsumpays
                 ,1                iSBScountPays
                 ,getsumcomiss( t.itrnnum
                               ,t.itrnanum
                               ,t.ctrnaccc
                               ,t.ctrncur
                               ,a.iaccotd
                               ,p_ctypecom
                               ,t.mtrnsum
                               ,0) mSBSsumcom
                 ,a.iaccotd        iSBSotdnum
                 ,to_number(to_char(nvl(o.iOTDbatnum, 70)) || '00') isbsbatnum
                 ,p_date           dsbsdate
                 ,1001             isbstypecom
                 ,t.dtrntrn_trunc  dsbsdatereg   -- ���� ����������� �������� ������� ��� � ���. ���_��
                 ,0                ihold
                 ,t.itrnnum        itrnsbs_trnnum
                 ,t.itrnanum       itrnsbs_trnanum
           from xxi.v_trn_part_current t
               ,acc a
               ,otd o
           where a.caccacc        = t.ctrnaccc
             and a.cacccur        = t.ctrncurc
             and o.iotdnum        = a.iaccotd
             and o.idsmr          = a.idsmr
             and a.caccprizn     <> '�'
             and t.cTRNstate1    >= 4 -- �� �������� "�������".
             and t.ctrnaccc like l_cls     -- ����������
             and t.ctrncurc       = 'RUR'
             and t.dtrntrn_trunc >= p_date_begin
             and t.dtrntrn_trunc  < p_date + 1
             -- �����������
             and (  -- ���������������� (����������������)
                   (  (     t.ctrnmfoa is null
                         or t.ctrnmfoa in ( select f.cfilmfo
                                              from xxi."fil" f
                                             where f.idsmr = p_cidsmr )
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
                             -->> 06.10.2020  ������� �.�.     [20-74693] ����������: ������� �������� �� ���������� (������� ��������+%%) �� �� ����� ����
                             and not (t.ctrnaccd like '303%' and t.ctrnacca like '454%' and lower(t.ctrnpurp) like '%������%�����%')
                             and not (t.ctrnaccd like '303%' and t.ctrnacca like '452%' and lower(t.ctrnpurp) like '%������%�����%')
                             and not (t.ctrnaccd like '303%' and t.ctrnacca like '420%' and lower(t.ctrnpurp) like '%�������%�������%�����%')
                             and not (t.ctrnaccd like '303%' and t.ctrnacca like '421%' and lower(t.ctrnpurp) like '%�������%�������%�����%')
                             and not (t.ctrnaccd like '303%' and t.ctrnacca like '422%' and lower(t.ctrnpurp) like '%�������%�������%�����%')
                             and not (t.ctrnaccd like '303%' and t.ctrnacca like '47426%' and lower(t.ctrnpurp) like '%����%�������%�������%�����%')
                             --<< 06.10.2020  ������� �.�.     [20-74693] ����������: ������� �������� �� ���������� (������� ��������+%%) �� �� ����� ����                             
                           )
                      )
                   )
                   or
                   -- ������������� ��� �������������
                   (     t.ctrnmfoa not in ( select f.cfilmfo
                                               from xxi."fil" f
                                              where f.idsmr = p_cidsmr )
                     and t.ctrnacca not like '401%'
                     and t.ctrnacca not like '402%'
                     and t.ctrnacca not like '403%'
                   )
                 )
             -->>13.02.2020 �������� [20-71580] �� "����� ����" ���� �������� �� ���������� �� ����������
             and not ((ctrnaccd like '30232%' or ctrnaccd like '30233%') and lower(replace(ctrnpurp, ' ')) like '����%������%')
             and not ( (t.ctrnmfoa is null
                         or t.ctrnmfoa in ( select f.cfilmfo
                                              from xxi."fil" f ) )
                       and  (ctrnacca like '30232%' or ctrnacca like '30233%') and lower(replace(ctrnpurp, ' ')) like '����%������%')
             and not ctrnaccd like '70601%'
             and not ( (t.ctrnmfoa is null
                         or t.ctrnmfoa in ( select f.cfilmfo
                                              from xxi."fil" f ) )
             -->> 03.07.2020  ������ �.�.  [20-76522]                                 
                       and  nvl(t.ctrnacca, '-') like '70601%') 
                      -- and  ctrnacca like '70601%')
             --<< 03.07.2020  ������ �.�.  [20-76522] 
             --<<13.02.2020 �������� [20-71580] �� "����� ����" ���� �������� �� ���������� �� ����������
             -->>26.02.2020 �������� [20-71580] �� "����� ����" ���� �������� �� ���������� �� ����������
             and not exists (select 1
                               from gac
                              where cgacacc = t.ctrnaccc
                                and igaccat   = 333
                                and igacnum   = 2)
             and exists (select 1
                           from gac
                          where cgacacc = t.ctrnaccc
                            and igaccat   = 3
                            and igacnum   = 36)
             --<<26.02.2020 �������� [20-71580] �� "����� ����" ���� �������� �� ���������� �� ����������
             -- >> �������� ������� ������� ��� �� �����
             and exists ( select e1.icat     -- ���� ����������� ������� �� �����, �� sbs_new �� ����������
                                ,e1.igrp
                            from ubrr_rko_exinc_catgr e1
                           where e1.ccom_type = p_ctypecom
                             and e1.exinc     = 1
                        )
             and not exists ( select e2.icat  -- ���� ����������� ��� ���������, �� �������� ��� ��� ��� ��������
                                    ,e2.igrp
                                from ubrr_rko_exinc_catgr e2
                               where e2.ccom_type = p_ctypecom
                                 and e2.exinc     = 1
                              minus
                              select g3.igaccat
                                    ,g3.igacnum
                                from gac g3
                                    ,ubrr_rko_exinc_catgr e3
                               where g3.igaccat   = e3.icat
                                 and g3.igacnum   = e3.igrp
                                 and e3.ccom_type = p_ctypecom
                                 and e3.exinc     = 1
                                 and g3.cgacacc   = t.ctrnaccc
                                 -->>22.01.2020 �������� [19-64846]
                                 and exists (select 1
                                               from xxi.au_attach_obg au
                                              where au.caccacc = g3.cgacacc
                                                and au.cacccur = g3.cgaccur
                                                and au.i_table = 304
                                                and au.c_newdata = e3.icat||'/'||e3.igrp
                                                and trunc(au.d_create) between nvl(e3.date_start, dg_date_start) and nvl(e3.date_end, dg_date_end)  )
                                 --<<22.01.2020 �������� [19-64846]
                            )
             -- << �������� ������� ������� ��� �� �����
             -- >> �������� ������� ����������� ��� �� ������ ��������
             and not exists ( select e4.icat  -- ���� ����������� ��� ���������, �� �������� ��� ��� ��� ��������
                                    ,e4.igrp
                                from ubrr_rko_exinc_catgr e4
                               where e4.ccom_type = p_ctypecom
                                 and e4.exinc     = 1
                              minus
                              select to_number(regexp_substr(au.c_newdata, '^\d+',1)) au_cat
                                    ,to_number(regexp_substr(au.c_newdata, '\d+$',1)) au_grp
                                from xxi.au_attach_obg    au
                                    ,ubrr_rko_exinc_catgr e5
                               where 1=1
                                 and au.c_newdata = e5.icat||'/'||e5.igrp
                                 and au.caccacc   = a.caccacc
                                 and au.cacccur   = a.cacccur
                                 and au.i_table   = 304
                                 and au.d_create <= t.dtrntran
                                 and e5.ccom_type = p_ctypecom
                                 and e5.exinc     = 1
                                 and trunc(au.d_create) between nvl(e5.date_start, dg_date_start) and nvl(e5.date_end, dg_date_end) -->><<--22.01.2020 �������� [19-64846]
                            )
             -- << �������� ������� ����������� ��� �� ������ ��������
             and not exists ( select 1
                            from gac g
                                ,ubrr_rko_exinc_catgr e
                           where g.igaccat   = e.icat
                             and g.igacnum   = e.igrp
                             and e.ccom_type = p_ctypecom
                             and e.exinc     = 0
                             and g.cgacacc   = t.ctrnaccc
                        )
             -- >> �������� ���������� ����������� ��� �� ������ ��������
             and not exists ( select 1
                                from xxi.au_attach_obg    au
                                    ,ubrr_rko_exinc_catgr e5
                               where 1=1
                                 and au.c_newdata = e5.icat||'/'||e5.igrp
                                 and au.caccacc   = a.caccacc
                                 and au.cacccur   = a.cacccur
                                 and au.i_table   = 304
                                 and au.d_create <= t.dtrntran
                                 and e5.ccom_type = p_ctypecom
                                 and e5.exinc     = 0
                                 and trunc(au.d_create) between nvl(e5.date_start, dg_date_start) and nvl(e5.date_end, dg_date_end) -->><<--22.01.2020 �������� [19-64846]
                            )
             -- << �������� ���������� ����������� ��� �� ������ ��������
             and not exists ( select /*+ leading(st,n) */
                                     1                    -- �� ����� ��������� ��� ��� ����� �������� INC
                                from ubrr_trn_sbs st
                                    ,ubrr_sbs_new n
                               where st.isbsid          = n.id
                                 and st.itrnsbs_trnnum  = t.itrnnum
                                 and st.itrnsbs_trnanum = t.itrnanum
                                 and n.csbstypecom      = p_ctypecom
                            )
             -- �� ������������ ubrr_unique_tarif
             and exists ( select 1
                            from ubrr_data.ubrr_rko_tarif        v
                                ,ubrr_data.ubrr_rko_tarif_otdsum os
                           where v.Parent_IdSmr = BankIdSmr
                             and v.com_type     = p_ctypecom
                             and v.id           = os.id_com
                             and os.otd         = a.iaccotd
                       )
             -->> 02.07.2020  ������ �.�.  [20-74342.1]
             and not ( lower(t.ctrnpurp) like'%����� �������� �� ������� ������ ����%' and
                       t.ctrnaccd like '30302%' and
                       t.itrnbatnum = 6666
                        );
             --<< 02.07.2020  ������ �.�.  [20-74342.1]
    -- cursor l_cur

    type t_tbl_sbs is table of l_cur%rowtype index by binary_integer;
    l_tbl_sbs t_tbl_sbs;

    l_g_tarif_id  number;
    l_mtarif      number;
    l_mtarifPrc   number;

    l_cnt         number        := 0;
    l_iret        number        := 0;
    l_cmsg        varchar2(4000):=$$plsql_unit||'.fill_sbsnew_inc';
  begin
     l_cmsg := l_cmsg || ' ['||
            'p_date='      ||to_char(p_date,'dd.mm.yyyy')      ||';'||
            'p_date_begin='||to_char(p_date_begin,'dd.mm.yyyy')||';'||
            'p_cls='       ||nvl(p_cls,'null')                 ||';'||
            'p_test='      ||p_test                            ||';'||
            '] ';

     ubrr_bnkserv_calc_new_lib.WriteProtocol('������ '||l_cmsg, p_test);

     delete from ubrr_data.ubrr_sbs_new
      where IdSmr       = l_cidsmr
        and isbstrnnum is null
        and dSBSDate    = p_Date
        and csbstypecom = l_ctypecom
        and cSBSaccd like l_cls
        and ihold <> ubrr_bnkserv_calc_new_lib.gc_sbs_hold_created ;

     commit;

     open l_cur( p_date     => p_date
                ,p_cls      => p_cls
                ,p_cidsmr   => ubrr_xxi5.ubrr_util.GetBankIdSmr --26.02.2020 �������� [20-71580] ������ l_cidsmr, � xxi."fil" ���� idsmr 1 ��� 16
                ,p_ctypecom => l_ctypecom );

     loop
        l_tbl_sbs.delete();
        fetch l_cur bulk collect into l_tbl_sbs limit 50;
        exit when l_tbl_sbs.count()=0;

        forall l_idx in indices of l_tbl_sbs
          insert into ubrr_data.ubrr_sbs_new( id
                                             ,csbsaccd
                                             ,csbscurd
                                             ,csbstypecom
                                             ,mSBSsumpays
                                             ,iSBScountPays
                                             ,mSBSsumcom
                                             ,iSBSotdnum
                                             ,iSBSBatNum
                                             ,dSBSDate
                                             ,iSBSTypeCom
                                             ,dsbsdatereg
                                             ,ihold )
               values ( l_tbl_sbs(l_idx).id
                       ,l_tbl_sbs(l_idx).csbsaccd
                       ,l_tbl_sbs(l_idx).csbscurd
                       ,l_tbl_sbs(l_idx).csbstypecom
                       ,l_tbl_sbs(l_idx).mSBSsumpays
                       ,l_tbl_sbs(l_idx).iSBScountPays
                       ,l_tbl_sbs(l_idx).mSBSsumcom
                       ,l_tbl_sbs(l_idx).iSBSotdnum
                       ,l_tbl_sbs(l_idx).iSBSBatNum
                       ,l_tbl_sbs(l_idx).dSBSDate
                       ,l_tbl_sbs(l_idx).iSBSTypeCom
                       ,l_tbl_sbs(l_idx).dsbsdatereg
                       ,l_tbl_sbs(l_idx).ihold );

        forall l_idx in indices of l_tbl_sbs
          insert into ubrr_trn_sbs( isbsid
                                   ,itrnsbs_trnnum
                                   ,itrnsbs_trnanum )
            values ( l_tbl_sbs(l_idx).id
                    ,l_tbl_sbs(l_idx).itrnsbs_trnnum
                    ,l_tbl_sbs(l_idx).itrnsbs_trnanum
                   );
        l_cnt := l_cnt + l_tbl_sbs.count();
     end loop;

     l_iret := l_cnt;
     close l_cur;

     commit;

     if l_tbl_sbs is not null then
        l_tbl_sbs.delete;
     end if;

     ubrr_bnkserv_calc_new_lib.WriteProtocol('��������� '||l_cmsg||' �������:'||l_iret, p_test);

     return l_iret;
  exception
    when others then
          if l_cur%isopen then
             close l_cur;
          end if;
          if l_tbl_sbs is not null then
             l_tbl_sbs.delete;
          end if;

          rollback;

        WriteProtocol('������ � '||l_cmsg||' '||dbms_utility.format_error_backtrace || ' ' ||sqlerrm);
        p_cmess := '������ ��� ������� �������� �� ���������� '||l_cmsg||' '||dbms_utility.format_error_backtrace || ' ' ||sqlerrm;
        return -1;
  end fill_sbsnew_inc;

  ----------------------------------------------------------------
  -- �������� �� ���������� INC - ���������� � �����������
  -- ubrr_sbs_new.ISBSTYPECOM = 1001
  -- ����������������
  function calc_inc( p_date     in  date           -- ���� ������� dd.mm.yyyy hh24:mi:ss
                    ,p_cls      in  varchar2 default null
                    ,p_date_reg in  date           -- ���� ����������� ����������
                    ,p_cmess    out varchar2
                    ,p_test     in  pls_integer default 0 )
  return number
  is
    l_date_begin  date;
    l_trunc_pdate date := trunc(p_date);
    l_cidsmr      smr.idsmr%type := sys_context('b21', 'idsmr');
    l_cls         varchar2(25)   := nvl(p_cls, ubrr_bnkserv_calc_new_lib.gc_ls);
    l_iret        number         := 0;
    l_ires        number;
    l_cmsg        varchar2(4000):=$$plsql_unit||'.calc_inc';
  begin
     l_cmsg := l_cmsg || ' ['||
            'p_date='    ||to_char(p_date,'dd.mm.yyyy hh24:mi:ss')||';'||
            'p_cls='     ||nvl(p_cls,'null')                      ||';'||
            'p_date_reg='||to_char(p_date_reg,'dd.mm.yyyy')       ||';'||
            'p_test='    ||p_test                                 ||';'||
            '] ';

     ubrr_bnkserv_calc_new_lib.WriteProtocol('������ '||l_cmsg, p_test);

     l_date_begin := pcaliso.next_workday ( cCur   => 'RUR'
                                           ,dDat   => l_trunc_pdate
                                           ,nDelt  => -1 );     -- ����_����

     if ( l_date_begin <= clsday.closed_date ) then -- ����_�� ������
         l_date_begin := l_trunc_pdate;
     end if;

     l_ires := fill_sbsnew_inc( p_date_begin => l_date_begin
                               ,p_date       => l_trunc_pdate
                               ,p_cls        => l_cls
                               ,p_cmess      => p_cmess
                               ,p_test       => p_test );

     if ( l_ires > 0 ) then
        UpdateAccComiss( p_TypeCom           => 1001
                        ,p_date              => l_trunc_pdate
                        ,p_regdate           => p_date_reg
                        ,p_ls                => p_cls
                        ,p_change_datereg    => 0 );   -- �� �������� � ������� ���� �����������

        l_iret := Register( p_regdate             => p_date_reg
                           ,p_TypeCom             => 1001
                           ,p_Mess                => p_cmess
                           ,p_portion_date1       => l_trunc_pdate
                           ,p_portion_date2       => l_trunc_pdate
                           ,p_ls                  => l_cls
                           ,p_mode_available_rest => false);

     end if;

     ubrr_bnkserv_calc_new_lib.WriteProtocol( '���������� '||l_cmsg||chr(10)||
                                             'l_iret=' ||l_iret ||';'||
                                             'p_cmess='||p_cmess||';'
                                             , p_test);

     return l_iret;
  end calc_inc;

  ----------------------------------------------------------------
  -- ������ �������� �� ������� ��� ����� � ���
  -- ��������� ������ �������� � ������� (����� ;)
  -- ����������������
  function calc_timer_commiss( p_date          in  date                  -- ���� ������� dd.mm.yyyy hh24:mi:ss
                              ,p_cls           in  varchar2 default null -- ���� ��� ������� ��������
                              ,p_date_reg      in  date     default null -- ���� ����������� ����������
                              ,p_clist_typecom in  varchar2              -- ��������� ������ �������� � �������
                              ,p_cmess         out varchar2
                              ,p_test          in  pls_integer default 0 )
  return number
  is
    l_tbl_typecom tblchar20;
  begin
     if ( p_clist_typecom is not null ) then
        select s.melement
          bulk collect into l_tbl_typecom
          from ( select regexp_substr(p_clist_typecom,'[^;]+', 1, level) melement
                   from dual
                   connect by regexp_substr(p_clist_typecom, '[^;]+', 1, level) is not null
               ) s ;
     end if;

     return calc_timer_commiss( p_date        => p_date    --dd.mm.yyyy hh24:mi:ss
                               ,p_cls         => p_cls
                               ,p_date_reg    => p_date_reg
                               ,p_tbl_typecom => l_tbl_typecom
                               ,p_cmess       => p_cmess
                               ,p_test        => p_test );
  end calc_timer_commiss;

  ----------------------------------------------------------------
  -- ������ �������� �� ������� ��� ����� � ���
  -- p_date_reg �� ���������, �� ���� ����������� ������� ��� � ��������� ���������
  -- ����������� �� run_commiss_for_timer (�� �����) � �� ����� ubrr_bnkserv_everyday.fmb
  -- ����������������
  function calc_timer_commiss( p_date        in  date                  -- ���� ������� dd.mm.yyyy hh24:mi:ss
                              ,p_cls         in  varchar2 default null -- ���� ��� ������� ��������
                              ,p_date_reg    in  date     default null -- ���� ����������� ����������
                              ,p_tbl_typecom in  tblchar20             -- ������ �������� � �������
                              ,p_cmess       out varchar2
                              ,p_test        in  pls_integer default 0 )
  return number
  is
    l_tbl_typecom    tblchar20:=tblchar20();
    l_idx            pls_integer;
    l_iret           number;
    l_ires           number;

    l_cname_lock     varchar2(20);
    l_chandle_lock   varchar2(128);
    l_ilock_res_lock integer;

    l_cls            varchar2(25)  := nvl(p_cls, ubrr_bnkserv_calc_new_lib.gc_ls);
    l_date_reg       date;
    l_cmess          varchar2(4000);
    l_cmsg           varchar2(4000):=$$plsql_unit||'.calc_timer_commiss';
  begin
     l_cmsg := l_cmsg || ' ['||
            'p_date='    ||to_char(p_date,'dd.mm.yyyy dd.mm.yyyy hh24:mi:ss')||';'||
            'p_cls='     ||nvl(p_cls,'null')                                 ||';'||
            'p_date_reg='||to_char(p_date_reg,'dd.mm.yyyy')                  ||';'||
            'p_test='    ||p_test                                            ||';'||
            '] ';

     dbms_lock.allocate_unique( lockname   => 'ubrr_bnkserv_calc_new_timer_'||sys_context('b21', 'idsmr')
                               ,lockhandle => l_chandle_lock );

     l_ilock_res_lock:=dbms_lock.request( lockhandle => l_chandle_lock
                                         ,timeout    => 5
                                         ,release_on_commit =>false );
     if l_ilock_res_lock != 0 then
        writeProtocol( l_cmsg ||'('||l_cname_lock||') is already running');
        return 0;
     end if;


    dbms_application_info.set_module('ubrr_bnkserv_calc_new_timer',null);

    if ( pcaliso.is_workday( cCur => 'RUR',
                             dDat => trunc(p_date) )<>0 ) then
        ubrr_bnkserv_calc_new_lib.writeprotocol('calc_timer_commiss : ����� ������� � ��������� ���� '||l_cmsg, p_test);
        if ( p_test=1 ) then
            p_cmess := '������ �������� "�� �������" � ��������� ���� ����������';
        end if;
        return 0;
    end if;

    if ( not ubrr_bnkserv_calc_new_lib.enable_run_calc_timer_commis ) then
        ubrr_bnkserv_calc_new_lib.writeprotocol('�� ����������� ������� ������� ������� �������� '||l_cmsg, p_test);
        if ( p_test=1 ) then
            p_cmess := '�� ����������� ������� ������� ������� ��������';
        end if;
       return 0;
    end if;

     dDateR    := p_date;   --dd.mm.yyyy hh24:mi:ss    -- ���������� ���������� ��� ubrr_bnkserv_calc_new.GetSumComiss,...
     BankIdSmr := ubrr_util.GetBankIdSmr;              -- ���������� ����������

     l_date_reg := trunc( nvl(p_date_reg,p_date) );

     if (    p_tbl_typecom is null
          or p_tbl_typecom.count()=0 ) then
          select t.com_type
            bulk collect into l_tbl_typecom
            from ubrr_rko_com_types t
           where t.freq = '�� �������';
     else
         l_tbl_typecom := p_tbl_typecom;
     end if;

     -- ���������� ���� ��������
     l_idx := l_tbl_typecom.first();
     while l_idx is not null
     loop
         dbms_application_info.set_action('[idsmr='||sys_context('b21', 'idsmr')||']['||l_tbl_typecom(l_idx)||']');

         if l_tbl_typecom(l_idx)='INC' then
            l_ires := calc_inc( p_date     => p_date  -- dd.mm.yyyy hh24:mi:ss
                               ,p_cls      => l_cls
                               ,p_date_reg => l_date_reg
                               ,p_cmess    => p_cmess
                               ,p_test     => p_test );
         end if;

        l_idx  := l_tbl_typecom.next(l_idx);
        l_iret := nvl(l_iret,0) + nvl(l_ires,0);
     end loop;

     if l_tbl_typecom is not null then
        l_tbl_typecom.delete();
     end if;

     dbms_application_info.set_module(null,null);
     l_ilock_res_lock:=dbms_lock.release(l_chandle_lock);

     return l_iret;
  exception when others then
        WriteProtocol('������ � '||l_cmsg||' '||dbms_utility.format_error_backtrace || ' ' ||sqlerrm);
        p_cmess := '������ ��� ������� �������� �� ���������� '||l_cmsg||' '||dbms_utility.format_error_backtrace || ' ' ||sqlerrm;

        if l_tbl_typecom is not null then
           l_tbl_typecom.delete();
        end if;
     dbms_application_info.set_module(null,null);
        l_ilock_res_lock:=dbms_lock.release(l_chandle_lock);
        return -1;
  end calc_timer_commiss;

  -------------------------------------------------------------------------
  -- ������ ������� �� �����
  procedure run_commiss_for_timer( p_idsmr         in number
                                  ,p_date          in date  -- ���� ������� dd.mm.yyyy hh24:mi:ss
                                  ,p_cls           in varchar2
                                  ,p_date_reg      in date  -- ���� �����������
                                  ,p_clist_typecom in varchar2 default null
                                  ,p_test          in pls_integer default 0 )
  is
     l_iret  number;
     l_cmess varchar2(4000);
    l_cmsg   varchar2(4000):=$$plsql_unit||'.run_commiss_for_timer';
  begin
     l_cmsg := l_cmsg || ' ['||
            'p_idsmr='         ||p_idsmr                                 ||';'||
            'p_date='          ||to_char(p_date,'dd.mm.yyyy hh24:mi:ss') ||';'||
            'p_cls='           ||nvl(p_cls,'null')                       ||';'||
            'p_date_reg='      ||to_char(p_date_reg,'dd.mm.yyyy')        ||';'||
            'p_clist_typecom=' ||nvl(p_clist_typecom,'null')             ||';'||
            'p_test='          ||p_test                                  ||';'||
            '] ';
     if (p_idsmr is not null) then
        xxi_context.Set_idSMR( p_idsmr );

        ubrr_bnkserv_calc_new_lib.WriteProtocol('������ '||l_cmsg, p_test);

/*     -- ��� ������� �� ����� , �� ���� ����������� ��������� �� ��������� ���������
        if ( p_date_reg <= trunc(clsday.closed_date) ) then
             ubrr_bnkserv_calc_new_lib.writeprotocol('run_commiss_for_timer : ����� ������� � ������������ �� �������� ���� '||l_cmsg, p_test);
             return;
        end if;
*/
        l_iret := calc_timer_commiss( p_date          => p_date                            -- ���� ������� dd.mm.yyyy hh24:mi:ss
                                     ,p_cls           => p_cls                             -- ���� ��� ������� ��������
                                     ,p_date_reg      => p_date_reg                        -- ���� ����������� ����������
                                     ,p_clist_typecom => p_clist_typecom                   -- ��������� ������ �������� � �������
                                     ,p_cmess         => l_cmess
                                     ,p_test          => p_test );
        if (l_cmess is not null) then
           ubrr_bnkserv_calc_new_lib.WriteProtocol('run_commiss_for_timer calc_timer_commiss(p_idsmr='||p_idsmr||'): '||l_cmess);
        end if;
     else
        ubrr_bnkserv_calc_new_lib.WriteProtocol('Error '||l_cmsg||': ������������ p_idsmr');
     end if;

     ubrr_bnkserv_calc_new_lib.WriteProtocol('��������� '||l_cmsg, p_test);

  exception when others then
      ubrr_bnkserv_calc_new_lib.WriteProtocol('Error '||l_cmsg||
                                              dbms_utility.format_error_stack || chr(10) || dbms_utility.format_error_backtrace);
  end run_commiss_for_timer;


  -------------------------------------------------------------------------
  -- �������� ������ �������� � ����� "�� �������"
  -- ����������� �������� ��� : p_nmain=1 - ����� (XXI); 16 - ��� (T_VUZDAYCOM)
  -- �� ����� XXI.UBRR_TIMER_COMISS_JOB � T_VUZDAYCOM.UBRR_TIMER_COMISS_VUZ_JOB
  procedure create_jobs_commiss_for_timer( p_nmain in pls_integer )
  is
    l_name                  varchar2(100) ;
    l_text                  varchar2(2000);
    l_cls                   varchar2(25)  := ubrr_bnkserv_calc_new_lib.gc_ls;
    l_date                  date          :=trunc(sysdate);
    l_test                  pls_integer   :=0;
    l_start_date            date          ;
    l_pref_run_timer_commis pls_integer   :=0;
    l_cmsg                  varchar2(4000):=$$plsql_unit||'.create_jobs_commiss_for_timer';
  begin
     l_cmsg := l_cmsg || ' ['||
            'p_nmain='||p_nmain||';'||
            '] ';

    if ( ubrr_bnkserv_calc_new_lib.f_pref_run_timer_commiss() ) then -- ��������
       l_pref_run_timer_commis :=1;
    end if;

    if ( nvl(pref.get_preference(ubrr_bnkserv_calc_new_lib.gc_pref_test_timer_commiss),'0')='1' ) then
       l_test :=1;
    end if;

    ubrr_bnkserv_calc_new_lib.WriteProtocol( '������ '||l_cmsg||' '||
                                                'onoff_timer_commis='||l_pref_run_timer_commis, l_test);

    if ( l_pref_run_timer_commis=1 ) then -- ��������
       l_start_date := sysdate;

       if ( p_nmain in ( 1,16 ) ) then
          xxi_context.set_idsmr( p_nmain );
       else
          ubrr_bnkserv_calc_new_lib.WriteProtocol('Error '||l_cmsg||' : ������������ �������� p_nmain');
          return;
       end if;

       for l_rec in ( select s.idsmr
                        from ubrr_smr s
                       where s.idsmr not in ('8',
                          '5','6','13', --02.03.2020 �������� [19-69558.2]
                          '4','9','15', --18.02.2020 �������� [20-71606]
                          '11','14',
                          '7' ,'12','10') -- 28.05.2020 UBRR Lazarev [20-74342] https://redmine.lan.ubrr.ru/issues/74342
                      order by case when s.idsmr = 1 then 999999 else to_number(s.idsmr) end
                    )
       loop
          l_name := 'XXI.UBRR_TIMER_COMMISS_'||to_char(l_rec.idsmr)||'_'||to_char(l_start_date, 'yyyymmdd');
          begin
            l_start_date := greatest(l_start_date+1/24/60/6, sysdate+1/24/60/6); -- ����� 10 ���
            l_text := 'begin ubrr_xxi5.ubrr_bnkserv_calc_new.run_commiss_for_timer(p_idsmr=>'                ||l_rec.idsmr  ||
                                                                                   ',p_date=>to_date('''     ||to_char(l_start_date, 'dd.mm.yyyy hh24:mi:ss')||''', ''dd.mm.yyyy hh24:mi:ss'')'||
                                                                                   ',p_cls=>'''              ||l_cls        ||''''||
                                                                                   ',p_date_reg=>to_date(''' ||to_char(l_date      , 'dd.mm.yyyy')||''', ''dd.mm.yyyy'')'||
                                                                                   ',p_clist_typecom=>null'  ||
                                                                                   ',p_test=>'               ||nvl(l_test,0)||
                                                                                   ' ); end;';

            ubrr_bnkserv_calc_new_lib.WriteProtocol( l_cmsg||
                                                    'l_name=' ||l_name ||';'||
                                                    'l_text=' ||l_text ||';'||
                                                    'l_start_date='||to_char(l_start_date,'dd.mm.yyyy hh24:mi:ss')||';'
                                                    , l_test);

            dbms_scheduler.create_job( job_name        => l_name
                                      ,job_type        => 'PLSQL_BLOCK'
                                      ,job_action      => l_text
                                      ,start_date      => l_start_date
                                      ,repeat_interval => null
                                      ,auto_drop       => true
                                      ,enabled         => true
                                      ,comments        => '�������������� ���������� �������� �� ������� idsmr=('||l_rec.idsmr||')'
                                     );


          exception when others then
               if ( sqlcode = -27477 ) then
                  ubrr_bnkserv_calc_new_lib.WriteProtocol('JOB '||l_name ||' ��� ����������');
               else
                  ubrr_bnkserv_calc_new_lib.WriteProtocol('Error create job in '||l_cmsg||':'||
                                                          dbms_utility.format_error_stack || chr(10) || dbms_utility.format_error_backtrace);
               end if;
          end;
       end loop;
    end if;
  exception when others then
      ubrr_bnkserv_calc_new_lib.WriteProtocol('Error '|| l_cmsg ||' '||
                                               dbms_utility.format_error_stack || chr(10) || dbms_utility.format_error_backtrace);
  end create_jobs_commiss_for_timer;
  --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������

-->> 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
--�������� ���� �� ������ ��� �������������� �������� ������ (������� ������)
FUNCTION CheckUniqACC(p_acc      IN UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.CACC%type,
                      p_dtrn     IN UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.DOPENTARIF%type,
                      p_com_type IN UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.COM_TYPE%type,
                      p_idsmr    IN UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.IDSMR%type
                      )
  RETURN NUMBER
  IS

  cursor cur_com_sum is
  select count(uutc.uuta_id)
    from UBRR_UNIQUE_TARIF_ACC uutc,
         UBRR_UNIQUE_ACC_COMMS uuac
   where uutc.cacc = p_acc
     and p_dtrn between uutc.DOPENTARIF and uutc.DCANCELTARIF
     and uutc.idsmr = p_idsmr
     and uutc.status = 'N'
     and uutc.uuta_id = uuac.uuta_id
     and uuac.com_type = p_com_type
     and uuac.daily like ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_day;

  l_count   number := 0;

BEGIN
  open cur_com_sum;
  fetch cur_com_sum into l_count;
  close cur_com_sum;

  return l_count;
END;

--������ �������� ����������/����������� �����
FUNCTION GetDayUniqACC(p_acc      IN UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.CACC%type,
                       p_dtrn     IN UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.DOPENTARIF%type,
                       p_com_type IN UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.COM_TYPE%type,
                       p_idsmr    IN UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.IDSMR%type
                       )
  RETURN UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.DAILY%type
  IS

  cursor cur_com is
  select uuac.daily
    from UBRR_UNIQUE_TARIF_ACC uutc,
         UBRR_UNIQUE_ACC_COMMS uuac
   where uutc.cacc = p_acc
     and p_dtrn between uutc.DOPENTARIF and uutc.DCANCELTARIF
     and uutc.idsmr = p_idsmr
     and uutc.status = 'N'
     and uutc.uuta_id = uuac.uuta_id
     and uuac.com_type = p_com_type;

  l_daily   UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.DAILY%type;

BEGIN
  open cur_com;
  fetch cur_com into l_daily;
  close cur_com;

  return l_daily;
END;
--<< 09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)

BEGIN
  BankIdSmr := ubrr_util.GetBankIdSmr;
  ubrr_bnkserv_calc_new_lib.g_purp_ntk := 0; -- 14.06.2018 ubrr korolkov #50487 -- 03.08.2019  ������� �.�. [19-62808]
END;
/
