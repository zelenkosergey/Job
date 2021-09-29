CREATE OR REPLACE PACKAGE BODY UBRR_XXI5."UBRR_ULFL_COMSS_VER2" is
  /******************************* HISTORY UBRR ***************************************************************\
        ����        �����            ID        ��������
    ----------  ---------------  ---------  --------------------------------------------------------------------
    20.10.2015  ubrr pinaev      15-995     ���: �������� �� ������� �� - �� � % https://redmine.lan.ubrr.ru/issues/25034
    13.11.2015  ubrr korolkov    15-1059.3  #25673 446-�. ��������� ������������ �������
    09.12.2015  ubrr pinaev      15-995     ������ #26464 https://redmine.lan.ubrr.ru/issues/26464
    19.02.2016  ������ �.�.      #28454     ���: �������� �� ������� �� - �� � %. ���������� ��������.
    10.03.2016  ������ �.�.      [15-1547]  ���: �������� � ������ �� - ������������ ���/�� https://redmine.lan.ubrr.ru/issues/29103
    18.03.2016  �������� �.�.    [15-1726]  ���: ���������� �� ������� ����� �������� � ������ �� https://redmine.lan.ubrr.ru/issues/27519
    05.05.2016  �������� �.�.    [16-1808.2.3.5.4.3.2]  #29736  ��� ���
    16.06.2016  ������ �.�.      [16-2126]  ��������� ������������ ������� 446-� (����� �����)
    11.07.2016  �������� �.�.    #33232     ��� ��� ����� �������� � ������������ ��������
    23.05.2017  ����������� �.�. [17-71]    ���: ������ �������� ��������� �� ��������� �� �������� �� ����������
    22.08.2017  �������� �.�.    [17-1031]  ���: �������� ����� ���������� ��� ������� �������� ��� �������� ������� � ������ ��
    23.10.2017  ����� �.�.       17-1225    ���: ������������� �������� �� ������� ������� � ������ ��
    04.12.2017  ����� �.�.                  https://redmine.lan.ubrr.ru/issues/47017#note-69
    09.01.2018  ����� �.�.       [17-913.2] ���: ���/�� ��� �������� �����
    21.02.2018  ubrr korolkov    [18-12.1]  ���: �������������� ������ �� �������� �� ������� � ������ �� ��� ���
    19.09.2018  ������� �.�.     [18-251]   ���: ����� ���������� �� �������� �� ������� � ������ �� ("���������")
    12.02.2019  ������� �.�.     [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
    07.03.2019  ������� �.�.     [#60292] ������ ��� ������������� �������� �������� UL_FL � UL_FL_VB            
    12.03.2019  ������� �.�.     [19-60337]   ���: ���������� ���� ���������� � �������� �� ���������� � ������ ��
    07.11.2019  ��������         [19-62184] ���������� �������� �����
    23.03.2020  ������� �.�.     [20-73286]   ���������� ���� ���������� � �������� � ������ ��
    09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��     
  \******************************* HISTORY UBRR ***************************************************************/

    cg_is_vuz   constant number(1)   := ubrr_util.isVuz; -- 07.11.2017 ubrr korolkov 17-1071
    cg_autab    constant number(3)   := 304;
    cg_112_72   constant varchar2(6) := '112/72';
    cg_112_35   constant varchar2(6) := '112/35';

    /*
    �������� ���������� ���
    */
    cursor get_calcTrn(p_d1 DATE, p_d2 DATE, p_mask varchar2, BankIdSmr number) -->><<--04.12.2017 ����� �.�. https://redmine.lan.ubrr.ru/issues/47017#note-69
    is
    ------------------ ������������� �� ��  -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��    
    select trn.ITRNNUM,
           ctrnaccd,
           ctrncur,
           mtrnsum,
           a.CACCPRIZN,
           a.IDSMR,
           a.iaccotd
            -->>23.10.2017  ����� �.�.       17-1225   ������� ����� �������� � ������ ������, ������� �� �����.
           , nvl((select sum(mtrnsum)
                  from /*V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v xm -->><<--07.11.2019 �������� [19-62184] ���������� �������� �����
                  where xm.ctrnaccd = trn.ctrnaccd
                  and xm.ctrncur=trn.ctrncur
                  and xm.dtrntran between trunc(p_d1, 'MM') and p_d1 -1/86400
                  and xm.ctrnmfoa  not in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr) --! �� ���� ������� -> ������� ������� -->><<--04.12.2017 ����� �.�. https://redmine.lan.ubrr.ru/issues/47017#note-69
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
                               where c.DCOMDATERAS = p_d1
                               and c.ICOMTRNNUM IS NOT NULL
                               and c.ccomaccd = xm.CTRNACCD)
                  -->>09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                  /*and not exists
                              (select 1
                               from ubrr_unique_tarif
                               where a.caccacc = cacc
                               and xm.dtrncreate between DOPENTARIF and DCANCELTARIF
                               and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)*/
                  --<<09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��             
               ),0)
               SumBefo,
               to_number(to_char(NVL(o.iOTDbatnum,70) )||'00') batnum,
               'UL_FL' ctypecom  -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
              --<<23.10.2017  ����� �.�.       17-1225    ������� ����� �������� � ������ ������, ������� �� �����.
    from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn, acc a, otd o -->><<--23.10.2017  ����� �.�.       17-1225   �������    otd - ��� batnum (����� �����) -->><<--07.11.2019 �������� [19-62184] ���������� �������� �����
    where cTRNcur = 'RUR'
    and a.iaccotd = o.iotdnum    -->><<--23.10.2017  ����� �.�.       17-1225   �������    otd - ��� batnum (����� �����)
    and cACCacc = cTRNaccd
    and cTRNaccd like p_mask
    and cACCacc  like p_mask
    and cACCprizn <> '�'
    and dtrntran between p_d1 and p_d2
    and ((trn.CTRNACCD like '40%' and
          to_number(substr(trn.CTRNACCD, 3, 1)) between 1 and 7) --! ���� ����������� ������������� ������ 401-407%,40802%, 40807
          or trn.CTRNACCD like '40802%'
          or trn.CTRNACCD like '40807%'
          or trn.CTRNACCD like '40821%' -- UBRR ����������� �. �. 23.05.2017 [17-71] ���: ������ �������� ��������� �� ��������� �� �������� �� ����������
        )
    -->>-- 10.03.2016  ������ �.�.      [15-1547]  ���: �������� � ������ �� - ������������ ���/��  https://redmine.lan.ubrr.ru/issues/29103
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
    --<<-- 10.03.2016  ������ �.�.      [15-1547]  ���: �������� � ������ �� - ������������ ���/��  https://redmine.lan.ubrr.ru/issues/29103
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
                                    70, -->><<-- 10.03.2016  ������ �.�.      [15-1547]  ���: �������� � ������ �� - ������������ ���/��
                                    71) -->><<-- 18.03.2016  �������� �.�.     [15-1726]  ���: �������� � ������ �� - ������������ ���/�� )
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
    and ctrnmfoa not in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr) --! �� ���� ������� -> ������� ������� -->><<--04.12.2017 ����� �.�. https://redmine.lan.ubrr.ru/issues/47017#note-69
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
    and lower(trn.CTRNPURP) not like '%��c��%' -- 07.11.2017 ubrr korolkov 17-1071 ��������� "c"
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
    -->> 23.10.2017 ����� �.�. 17-1225   �� ��
    /*
    and lower(trn.CTRNPURP) not like '%��������%'
    and lower(trn.CTRNPURP) not like '%��������%'
    and lower(trn.CTRNPURP) not like '%��� �����%'
    and lower(trn.CTRNPURP) not like '%��� �����%'
    */
    --<< 23.10.2017 ����� �.�. 17-1225    �� ��
    and lower(trn.CTRNPURP) not like '%������������%'
    /*and lower(trn.CTRNPURP) not like '%���%����%'*/ -->><<--  23.10.2017 ����� �.�. 17-1225    �� ��
    and lower(trn.CTRNPURP) not like '%������%'
    and nvl(regexp_count(lower(trn.CTRNPURP),'����'),0) = nvl(regexp_count(lower(trn.CTRNPURP),'���������'),0) -- 19.09.2018 ubrr rizanov [18-251] ���: ����� ���������� �� �������� �� ������� � ������ �� ("���������")               
    -->> 09.12.2015  ubrr pinaev      15-995     ���������� ���������� https://redmine.lan.ubrr.ru/issues/26464
    and lower(trn.CTRNPURP) not like '%������%'
    and lower(trn.CTRNPURP) not like '%������%'
    and lower(trn.CTRNPURP) not like '%����������%'
    and lower(trn.CTRNPURP) not like '%������%'
    and lower(trn.CTRNPURP) not like '%��������%����%'
    and lower(trn.CTRNPURP) not like '%�����������%'
    and lower(trn.CTRNPURP) not like '%���%������%'
    and lower(trn.CTRNPURP) not like '%��%'
    /*and lower(trn.CTRNPURP) not like '%���%����%'*/-->><<--  23.10.2017 ����� �.�. 17-1225  �� ��
    --<< 09.12.2015  ubrr pinaev      15-995     ���������� ���������� #26464 https://redmine.lan.ubrr.ru/issues/26464
    -->> 19.02.2016 ������ �.�.   #28454 ���: �������� �� ������� �� - �� � %. ���������� ��������.
    and lower(trn.CTRNPURP) not like '%��������%'
    and lower(trn.CTRNPURP) not like '%�������%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�/����%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�\����%'
    and lower(trn.CTRNPURP) not like '%�����%��%'
    and lower(trn.CTRNPURP) not like '%�����������%��%'
    --<< 19.02.2016 ������ �.�.   #28454 ���: �������� �� ������� �� - �� � %. ���������� ��������.
    -->> ubrr korolkov
    and lower(trn.CTRNPURP) not like '%������%'
    and lower(trn.CTRNPURP) not like '%����%'
    -- >> ubrr 23.03.2020  ������� �.�.  [20-73286] ���������� ���� ���������� � �������� � ������ ��
    and lower(trn.CTRNPURP) not like '%�����%���%'                                
    and lower(trn.CTRNPURP) not like '%�����%�����%'
    and lower(trn.CTRNPURP) not like '%�����%��������%'                                                                
    -- << ubrr 23.03.2020  ������� �.�.  [20-73286] ���������� ���� ���������� � �������� � ������ ��
    and lower(replace(trn.CTRNPURP,' ')) not like '%�.��%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�\�%'
    --<< ubrr korolkov
    -->> 22.08.2017  �������� �.�. [17-1031] ���: �������� ����� ���������� ��� ������� �������� ��� �������� ������� � ������ ��
    and lower(replace(trn.CTRNPURP,' ')) not like '%����%����%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�������%������%'
    --<< 22.08.2017  �������� �.�. [17-1031] ���: �������� ����� ���������� ��� ������� �������� ��� �������� ������� � ������ ��
    and (ITRNTYPE = 4 OR ITRNTYPE = 11 AND EXISTS (select 1
                                                   from trc
                                                   where trc.ITRCNUM = trn.ITRNNUMANC
                                                   and trc.ITRCTYPE = 4))
    and not exists --���� ����������� �������� ����, ��������, �������� ����� ��������, ������ �� ��������.
                (select 1
                 from ubrr_ulfl_tab_acc_coms c
                 where c.DCOMDATERAS = p_d1
                 and c.ICOMTRNNUM IS NOT NULL
                 and c.ccomaccd = trn.CTRNACCD)
    /*
    ��������� ��������, ��������������� �� ���.������� (����� ���������  �������� ��� ������.��������)
    */
    -->>09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
   /* and not exists (select 1
                    from ubrr_unique_tarif
                    where a.caccacc = cacc
                    and trn.dtrncreate between DOPENTARIF and DCANCELTARIF
                    and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)*/            -->><<-- ubrr �������� �.�. #29736 ��������� �� ��� ��� ���
    --<<09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��                
    -->>23.10.2017 ����� �.�. 17-1225  �� ��
    and not exists (select 1
                    from ubrr_data.ubrr_sbs_new
                    where idsmr = a.idsmr
                    and dSBSdate = p_d1
                    and cSBSaccd = a.caccacc
                    and cSBScurd = a.cacccur
                    and cSBSTypeCom = 'UL_FL'
                    and iSBStrnnum is not null)
    --<<23.10.2017 ����� �.�. 17-1225  �� ��
    union all -->> 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
    ----------------���������������� �� ��---------------------
    select trn.ITRNNUM,
           ctrnaccd,
           ctrncur,
           mtrnsum,
           a.CACCPRIZN,
           a.IDSMR,
           a.iaccotd
            -->>23.10.2017  ����� �.�.       17-1225   ������� ����� �������� � ������ ������, ������� �� �����.
           , nvl((select sum(mtrnsum)
                  from /*V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v xm -->><<--07.11.2019 �������� [19-62184] ���������� �������� �����
                  where xm.ctrnaccd = trn.ctrnaccd
                  and xm.ctrncur=trn.ctrncur
                  and xm.dtrntran between trunc(p_d1, 'MM') and p_d1 -1/86400
                  and xm.ctrnmfoa  in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr) --! ���� ������� -> ����������     -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
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
                        or xm.ITRNTYPE = 2          -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
                        OR xm.ITRNTYPE in (11,28)   -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ �� 
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
                  and lower(replace(xm.CTRNPURP,' ')) not like '%�.��%'
                  and lower(replace(xm.CTRNPURP,' ')) not like '%�\�%'
                  and lower(replace(xm.CTRNPURP,' ')) not like '%����%����%'
                  and lower(replace(xm.CTRNPURP,' ')) not like '%�������%������%'
                  and lower(xm.CTRNPURP) not like '%���%����%'              -- 12.03.2019 ������� �.�. [19-60337]   ���: ���������� ���� ���������� � �������� �� ���������� � ������ ��                                                       
                  and lower(xm.CTRNPURP) not like '%�����%'    -- 07.03.2019 ������� �.�. [#60292] ������ ��� ������������� �������� �������� UL_FL � UL_FL_VB                  
                  and lower(xm.CTRNPURP) not like '%�����%'    -- 07.03.2019 ������� �.�. [#60292] ������ ��� ������������� �������� �������� UL_FL � UL_FL_VB
                  -- >> ubrr 23.03.2020  ������� �.�.  [20-73286] ���������� ���� ���������� � �������� � ������ ��
                  and lower(xm.CTRNPURP) not like '%�����%���%'                                
                  and lower(xm.CTRNPURP) not like '%�����%�����%'
                  and lower(xm.CTRNPURP) not like '%�����%��������%'                                                                
                  -- << ubrr 23.03.2020  ������� �.�.  [20-73286] ���������� ���� ���������� � �������� � ������ ��
                  and not exists --���� ����������� �������� ����, ��������, �������� ����� ��������, ������ �� ��������.
                              (select 1
                               from ubrr_ulfl_tab_acc_coms c
                               where c.DCOMDATERAS = p_d1
                               and c.ICOMTRNNUM IS NOT NULL
                               and c.ccomaccd = xm.CTRNACCD)
                  -->>09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                  /*and not exists
                              (select 1
                               from ubrr_unique_tarif
                               where a.caccacc = cacc
                               and xm.dtrncreate between DOPENTARIF and DCANCELTARIF
                               and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)*/
                  --<<09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��             
               ),0)
               SumBefo,
               to_number(to_char(NVL(o.iOTDbatnum,70) )||'00') batnum,
               'UL_FL_VB' ctypecom  -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
              --<<23.10.2017  ����� �.�.       17-1225    ������� ����� �������� � ������ ������, ������� �� �����.
    from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn, acc a, otd o -->><<--23.10.2017  ����� �.�.       17-1225   �������    otd - ��� batnum (����� �����)-->><<--07.11.2019 �������� [19-62184] ���������� �������� �����
    where cTRNcur = 'RUR'
    and a.iaccotd = o.iotdnum    -->><<--23.10.2017  ����� �.�.       17-1225   �������    otd - ��� batnum (����� �����)
    and cACCacc = cTRNaccd
    and cTRNaccd like p_mask
    and cACCacc  like p_mask
    and cACCprizn <> '�'
    and dtrntran between p_d1 and p_d2
    and ((trn.CTRNACCD like '40%' and
          to_number(substr(trn.CTRNACCD, 3, 1)) between 1 and 7) --! ���� ����������� ������������� ������ 401-407%,40802%, 40807
          or trn.CTRNACCD like '40802%'
          or trn.CTRNACCD like '40807%'
          or trn.CTRNACCD like '40821%' -- UBRR ����������� �. �. 23.05.2017 [17-71] ���: ������ �������� ��������� �� ��������� �� �������� �� ����������
        )
    -->>-- 10.03.2016  ������ �.�.      [15-1547]  ���: �������� � ������ �� - ������������ ���/��  https://redmine.lan.ubrr.ru/issues/29103
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
    --<<-- 10.03.2016  ������ �.�.      [15-1547]  ���: �������� � ������ �� - ������������ ���/��  https://redmine.lan.ubrr.ru/issues/29103
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
                                    70, -->><<-- 10.03.2016  ������ �.�.      [15-1547]  ���: �������� � ������ �� - ������������ ���/��
                                    71) -->><<-- 18.03.2016  �������� �.�.     [15-1726]  ���: �������� � ������ �� - ������������ ���/�� )
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
    and ctrnmfoa in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr) --! ���� ������� -> ���������� ������� -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
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
    and lower(trn.CTRNPURP) not like '%��c��%' -- 07.11.2017 ubrr korolkov 17-1071 ��������� "c"
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
    -->> 23.10.2017 ����� �.�. 17-1225   �� ��
    /*
    and lower(trn.CTRNPURP) not like '%��������%'
    and lower(trn.CTRNPURP) not like '%��������%'
    and lower(trn.CTRNPURP) not like '%��� �����%'
    and lower(trn.CTRNPURP) not like '%��� �����%'
    */
    --<< 23.10.2017 ����� �.�. 17-1225    �� ��
    and lower(trn.CTRNPURP) not like '%������������%'
    /*and lower(trn.CTRNPURP) not like '%���%����%'*/ -->><<--  23.10.2017 ����� �.�. 17-1225    �� ��
    and lower(trn.CTRNPURP) not like '%������%'
    and nvl(regexp_count(lower(trn.CTRNPURP),'����'),0) = nvl(regexp_count(lower(trn.CTRNPURP),'���������'),0) -- 19.09.2018 ubrr rizanov [18-251] ���: ����� ���������� �� �������� �� ������� � ������ �� ("���������")               
    -->> 09.12.2015  ubrr pinaev      15-995     ���������� ���������� https://redmine.lan.ubrr.ru/issues/26464
    and lower(trn.CTRNPURP) not like '%������%'
    and lower(trn.CTRNPURP) not like '%������%'
    and lower(trn.CTRNPURP) not like '%����������%'
    and lower(trn.CTRNPURP) not like '%������%'
    and lower(trn.CTRNPURP) not like '%��������%����%'
    and lower(trn.CTRNPURP) not like '%�����������%'
    and lower(trn.CTRNPURP) not like '%���%������%'
    and lower(trn.CTRNPURP) not like '%��%'
    /*and lower(trn.CTRNPURP) not like '%���%����%'*/-->><<--  23.10.2017 ����� �.�. 17-1225  �� ��
    --<< 09.12.2015  ubrr pinaev      15-995     ���������� ���������� #26464 https://redmine.lan.ubrr.ru/issues/26464
    -->> 19.02.2016 ������ �.�.   #28454 ���: �������� �� ������� �� - �� � %. ���������� ��������.
    and lower(trn.CTRNPURP) not like '%��������%'
    and lower(trn.CTRNPURP) not like '%�������%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�/����%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�\����%'
    and lower(trn.CTRNPURP) not like '%�����%��%'
    and lower(trn.CTRNPURP) not like '%�����������%��%'
    --<< 19.02.2016 ������ �.�.   #28454 ���: �������� �� ������� �� - �� � %. ���������� ��������.
    -->> ubrr korolkov
    and lower(trn.CTRNPURP) not like '%������%'
    and lower(trn.CTRNPURP) not like '%����%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�.��%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�\�%'
    --<< ubrr korolkov
    -->> 22.08.2017  �������� �.�. [17-1031] ���: �������� ����� ���������� ��� ������� �������� ��� �������� ������� � ������ ��
    and lower(replace(trn.CTRNPURP,' ')) not like '%����%����%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�������%������%'
    --<< 22.08.2017  �������� �.�. [17-1031] ���: �������� ����� ���������� ��� ������� �������� ��� �������� ������� � ������ ��
    and lower(trn.CTRNPURP) not like '%���%����%'              -- 12.03.2019 ������� �.�. [19-60337]   ���: ���������� ���� ���������� � �������� �� ���������� � ������ ��    
    and lower(trn.CTRNPURP) not like '%�����%'    -- 07.03.2019 ������� �.�. [#60292] ������ ��� ������������� �������� �������� UL_FL � UL_FL_VB                  
    and lower(trn.CTRNPURP) not like '%�����%'    -- 07.03.2019 ������� �.�. [#60292] ������ ��� ������������� �������� �������� UL_FL � UL_FL_VB
    -- >> ubrr 23.03.2020  ������� �.�.  [20-73286] ���������� ���� ���������� � �������� � ������ ��
    and lower(trn.CTRNPURP) not like '%�����%���%'                                
    and lower(trn.CTRNPURP) not like '%�����%�����%'
    and lower(trn.CTRNPURP) not like '%�����%��������%'                                                                
    -- << ubrr 23.03.2020  ������� �.�.  [20-73286] ���������� ���� ���������� � �������� � ������ ��
    and (ITRNTYPE = 4 OR
           ITRNTYPE = 2 or                            -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��     
           ITRNTYPE in (11,28) AND EXISTS (select 1   -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
                                             from trc
                                            where trc.ITRCNUM = trn.ITRNNUMANC
                                              and trc.ITRCTYPE in (2,4) ) -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
        )                                              
    and not exists --���� ����������� �������� ����, ��������, �������� ����� ��������, ������ �� ��������.
                (select 1
                 from ubrr_ulfl_tab_acc_coms c
                 where c.DCOMDATERAS = p_d1
                 and c.ICOMTRNNUM IS NOT NULL
                 and c.ccomaccd = trn.CTRNACCD)
    /*
    ��������� ��������, ��������������� �� ���.������� (����� ���������  �������� ��� ������.��������)
    */
    -->>09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
    /*and not exists (select 1
                    from ubrr_unique_tarif
                    where a.caccacc = cacc
                    and trn.dtrncreate between DOPENTARIF and DCANCELTARIF
                    and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)   */         -->><<-- ubrr �������� �.�. #29736 ��������� �� ��� ��� ���
    --<<09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��                
    -->>23.10.2017 ����� �.�. 17-1225  �� ��
    and not exists (select 1
                    from ubrr_data.ubrr_sbs_new
                    where idsmr = a.idsmr
                    and dSBSdate = p_d1
                    and cSBSaccd = a.caccacc
                    and cSBScurd = a.cacccur
                    and cSBSTypeCom = 'UL_FL_VB'
                    and iSBStrnnum is not null)
    --<<23.10.2017 ����� �.�. 17-1225  �� ��
    --<< 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��        
    ;

    -->> 23.10.2017 ����� �.�. 17-1225  �� ��
    cursor get_calcTrn_business_activity(p_d1 DATE, p_d2 DATE, p_mask varchar2, BankIdSmr number)
    is
     ------------------ ������������� �� ��(��)  -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
    select trn.ITRNNUM,
           ctrnaccd,
           ctrncur,
           mtrnsum,
           a.CACCPRIZN,
           a.IDSMR,
           a.iaccotd
            -->>23.10.2017  ����� �.�.       17-1225  ������� �������� ������� ������, ������� �� �����.
           , nvl( (select sum(mtrnsum) from /*V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v xm -->><<--07.11.2019 �������� [19-62184] ���������� �������� �����
                   where xm.ctrnaccd = trn.ctrnaccd
                     and xm.ctrncur=trn.ctrncur
                     and xm.dtrntran between trunc(p_d1, 'MM') and p_d1 -1/86400
                     and xm.ctrnmfoa  not in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr)
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
                     and (xm.ITRNTYPE = 4 OR xm.ITRNTYPE = 11 AND EXISTS (select 1
                                                                          from trc
                                                                          where trc.ITRCNUM = xm.ITRNNUMANC
                                                                          and trc.ITRCTYPE = 4))
                     and (lower(xm.CTRNPURP) not like '%��������%'
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
                     and lower(xm.CTRNPURP) not like '%������%'
                     and lower(xm.CTRNPURP) not like '%����%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%�.��%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%�\�%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%����%����%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%�������%������%' )
                     and (   lower(xm.ctrnpurp) LIKE '%�����%��%'
                          OR lower(xm.ctrnpurp) LIKE '%�����������%��%'
                          OR lower(xm.ctrnpurp) LIKE '%������������%')
                     and (ITRNTYPE = 4 OR ITRNTYPE = 11 AND EXISTS (select 1
                                                                    from trc
                                                                    where trc.ITRCNUM = xm.ITRNNUMANC
                                                                    and trc.ITRCTYPE = 4))
                     and not exists --���� ����������� �������� ����, ��������, �������� ����� ��������, ������ �� ��������.
                                 (select 1
                                  from ubrr_ulfl_tab_acc_coms c
                                  where c.DCOMDATERAS = p_d1
                                  and c.ICOMTRNNUM IS NOT NULL
                                  and c.ccomaccd = xm.CTRNACCD)
                     /*
                      ��������� ��������, ��������������� �� ���.������� (����� ���������  �������� ��� ������.��������)
                     */
                     -->>09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                     /*and not exists (select 1
                                     from ubrr_unique_tarif
                                     where a.caccacc = cacc
                                     and xm.dtrncreate between DOPENTARIF and DCANCELTARIF
                                     and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)*/
                     --><<09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��                
           ) , 0)   SumBefo,
           to_number(to_char(NVL(o.iOTDbatnum,70) )||'00') batnum,
          'IP_DOH' ctypecom  -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
           --<<23.10.2017  ����� �.�.       17-1225
    from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn, acc a, otd o -->><<--23.10.2017  ����� �.�.       17-1225 -->><<--07.11.2019 �������� [19-62184] ���������� �������� �����
    where cTRNcur = 'RUR'
    and a.iaccotd = o.iotdnum
    and cACCacc = cTRNaccd
    and cTRNaccd like p_mask
    and cACCacc  like p_mask
    and cACCprizn <> '�'
    and dtrntran between p_d1 and p_d2
    AND trn.ctrnaccd LIKE '40802%'
    /*
       and ((trn.CTRNACCD like '40%' and
           to_number(substr(trn.CTRNACCD, 3, 1)) between 1 and 7) --! ���� ����������� ������������� ������ 401-407%,40802%, 40807
           or trn.CTRNACCD like '40802%' or trn.CTRNACCD like '40807%' or
           trn.CTRNACCD like '42309%' or
    -- (���.) UBRR ����������� �. �. 23.05.2017 [17-71] ���: ������ �������� ��������� �� ��������� �� �������� �� ����������
           trn.CTRNACCD like '40821%'
           --trn.CTRNACCD like '40821________7______' or
           --trn.CTRNACCD like '40821________8______'
           )
    */
    -- (���.) UBRR ����������� �. �. 23.05.2017 [17-71] ���: ������ �������� ��������� �� ��������� �� �������� �� ����������
    -->>-- 10.03.2016  ������ �.�.      [15-1547]  ���: �������� � ������ �� - ������������ ���/��  https://redmine.lan.ubrr.ru/issues/29103
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
    --<<-- 10.03.2016  ������ �.�.      [15-1547]  ���: �������� � ������ �� - ������������ ���/��  https://redmine.lan.ubrr.ru/issues/29103
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
                                    70, -->><<-- 10.03.2016  ������ �.�.      [15-1547]  ���: �������� � ������ �� - ������������ ���/��
                                    71) -->><<-- 18.03.2016  �������� �.�.     [15-1726]  ���: �������� � ������ �� - ������������ ���/�� )
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
    and ctrnmfoa not in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr) --! �� ���� ������� -> ������� �������
    and (lower(trn.CTRNPURP) not like '%��������%'
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
    -->> 23.10.2017 ����� �.�. 17-1225
    /*
    and lower(trn.CTRNPURP) not like '%��������%'
    and lower(trn.CTRNPURP) not like '%��������%'
    and lower(trn.CTRNPURP) not like '%��� �����%'
    and lower(trn.CTRNPURP) not like '%��� �����%'
    */
    --<< 23.10.2017 ����� �.�. 17-1225
    -- and lower(trn.CTRNPURP) not like '%������������%'
    /*and lower(trn.CTRNPURP) not like '%���%����%'*/ -->><<--  23.10.2017 ����� �.�. 17-1225
    and lower(trn.CTRNPURP) not like '%������%'
    and nvl(regexp_count(lower(trn.CTRNPURP),'����'),0) = nvl(regexp_count(lower(trn.CTRNPURP),'���������'),0) -- 19.09.2018 ubrr rizanov [18-251] ���: ����� ���������� �� �������� �� ������� � ������ �� ("���������")              
    -->> 09.12.2015  ubrr pinaev      15-995     ���������� ���������� https://redmine.lan.ubrr.ru/issues/26464
    and lower(trn.CTRNPURP) not like '%������%'
    and lower(trn.CTRNPURP) not like '%������%'
    and lower(trn.CTRNPURP) not like '%����������%'
    and lower(trn.CTRNPURP) not like '%������%'
    and lower(trn.CTRNPURP) not like '%��������%����%'
    and lower(trn.CTRNPURP) not like '%�����������%'
    and lower(trn.CTRNPURP) not like '%���%������%'
    and lower(trn.CTRNPURP) not like '%��%'
    /*and lower(trn.CTRNPURP) not like '%���%����%'*/-->><<--  23.10.2017 ����� �.�. 17-1225
    --<< 09.12.2015  ubrr pinaev      15-995     ���������� ���������� #26464 https://redmine.lan.ubrr.ru/issues/26464
    -->> 19.02.2016 ������ �.�.   #28454 ���: �������� �� ������� �� - �� � %. ���������� ��������.
    and lower(trn.CTRNPURP) not like '%��������%'
    and lower(trn.CTRNPURP) not like '%�������%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�/����%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�\����%'
    --and lower(trn.CTRNPURP) not like '%�����%��%'
    --and lower(trn.CTRNPURP) not like '%�����������%��%'
    --<< 19.02.2016 ������ �.�.   #28454 ���: �������� �� ������� �� - �� � %. ���������� ��������.
    -->> ubrr korolkov
    and lower(trn.CTRNPURP) not like '%������%'
    and lower(trn.CTRNPURP) not like '%����%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�.��%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�\�%'
    --<< ubrr korolkov
    -->> 22.08.2017  �������� �.�. [17-1031] ���: �������� ����� ���������� ��� ������� �������� ��� �������� ������� � ������ ��
    and lower(replace(trn.CTRNPURP,' ')) not like '%����%����%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�������%������%' )
    --<< 22.08.2017  �������� �.�. [17-1031] ���: �������� ����� ���������� ��� ������� �������� ��� �������� ������� � ������ ��
    -->> 23.10.2017 ����� �.�. 17-1225
    and (   lower(trn.ctrnpurp) LIKE '%�����%��%'
         or lower(trn.ctrnpurp) LIKE '%�����������%��%'
         or lower(trn.ctrnpurp) LIKE '%������������%')
    --<< 23.10.2017 ����� �.�. 17-1225
    and (ITRNTYPE = 4 OR ITRNTYPE = 11 AND EXISTS (select 1
                                                   from trc
                                                   where trc.ITRCNUM = trn.ITRNNUMANC
                                                   and trc.ITRCTYPE = 4))
    and not exists --���� ����������� �������� ����, ��������, �������� ����� ��������, ������ �� ��������.
                  (select 1
                   from ubrr_ulfl_tab_acc_coms c
                   where c.DCOMDATERAS = p_d1
                   and c.ICOMTRNNUM IS NOT NULL
                   and c.ccomaccd = trn.CTRNACCD)
    /*
     ��������� ��������, ��������������� �� ���.������� (����� ���������  �������� ��� ������.��������)
    */
    -->>09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
    /*and not exists (select 1
                    from ubrr_unique_tarif
                    where a.caccacc = cacc
                    and trn.dtrncreate between DOPENTARIF and DCANCELTARIF
                    and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)*/
    --<<09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��                
    and not exists (select 1
                    from ubrr_data.ubrr_sbs_new
                    where idsmr = a.idsmr
                    and dSBSdate = p_d1
                    and cSBSaccd = a.caccacc
                    and cSBScurd = a.cacccur
                    and cSBSTypeCom = 'IP_DOH'
                    and iSBStrnnum is not null)
 union all  -->> 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
 ------------------ ���������������� �� ��(��)----------------------- 
    select trn.ITRNNUM,
           ctrnaccd,
           ctrncur,
           mtrnsum,
           a.CACCPRIZN,
           a.IDSMR,
           a.iaccotd
            -->>23.10.2017  ����� �.�.       17-1225  ������� �������� ������� ������, ������� �� �����.
           , nvl( (select sum(mtrnsum) from /*V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v xm -->><<--07.11.2019 �������� [19-62184] ���������� �������� �����
                   where xm.ctrnaccd = trn.ctrnaccd
                     and xm.ctrncur=trn.ctrncur
                     and xm.dtrntran between trunc(p_d1, 'MM') and p_d1 -1/86400
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
                           OR xm.ITRNTYPE in (11,28) -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
                          AND EXISTS( select 1
                                        from trc
                                       where trc.ITRCNUM = xm.ITRNNUMANC
                                         and trc.ITRCTYPE in (2,4) ) -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
                         )
                     and (lower(xm.CTRNPURP) not like '%��������%'
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
                     and lower(xm.CTRNPURP) not like '%������%'
                     and lower(xm.CTRNPURP) not like '%����%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%�.��%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%�\�%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%����%����%'
                     and lower(replace(xm.CTRNPURP,' ')) not like '%�������%������%' )
                     and (   lower(xm.ctrnpurp) LIKE '%�����%��%'
                          OR lower(xm.ctrnpurp) LIKE '%�����������%��%'
                          OR lower(xm.ctrnpurp) LIKE '%������������%')
                     and (    xm.ITRNTYPE = 4
                           or xm.ITRNTYPE = 2         -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
                           OR xm.ITRNTYPE in (11,28) -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
                          AND EXISTS( select 1
                                        from trc
                                       where trc.ITRCNUM = xm.ITRNNUMANC
                                         and trc.ITRCTYPE in (2,4) ) -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
                         )
                     and not exists --���� ����������� �������� ����, ��������, �������� ����� ��������, ������ �� ��������.
                                 (select 1
                                  from ubrr_ulfl_tab_acc_coms c
                                  where c.DCOMDATERAS = p_d1
                                  and c.ICOMTRNNUM IS NOT NULL
                                  and c.ccomaccd = xm.CTRNACCD)
                     /*
                      ��������� ��������, ��������������� �� ���.������� (����� ���������  �������� ��� ������.��������)
                     */
                     -->>09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                     /*and not exists (select 1
                                     from ubrr_unique_tarif
                                     where a.caccacc = cacc
                                     and xm.dtrncreate between DOPENTARIF and DCANCELTARIF
                                     and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)*/
                     --<<09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��                
           ) , 0)   SumBefo,
           to_number(to_char(NVL(o.iOTDbatnum,70) )||'00') batnum,
          'IP_DOH_VB' ctypecom  -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
           --<<23.10.2017  ����� �.�.       17-1225
    from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn, acc a, otd o -->><<--23.10.2017  ����� �.�.       17-1225 -->><<--07.11.2019 �������� [19-62184] ���������� �������� �����
    where cTRNcur = 'RUR'
    and a.iaccotd = o.iotdnum
    and cACCacc = cTRNaccd
    and cTRNaccd like p_mask
    and cACCacc  like p_mask
    and cACCprizn <> '�'
    and dtrntran between p_d1 and p_d2
    AND trn.ctrnaccd LIKE '40802%'
    /*
       and ((trn.CTRNACCD like '40%' and
           to_number(substr(trn.CTRNACCD, 3, 1)) between 1 and 7) --! ���� ����������� ������������� ������ 401-407%,40802%, 40807
           or trn.CTRNACCD like '40802%' or trn.CTRNACCD like '40807%' or
           trn.CTRNACCD like '42309%' or
    -- (���.) UBRR ����������� �. �. 23.05.2017 [17-71] ���: ������ �������� ��������� �� ��������� �� �������� �� ����������
           trn.CTRNACCD like '40821%'
           --trn.CTRNACCD like '40821________7______' or
           --trn.CTRNACCD like '40821________8______'
           )
    */
    -- (���.) UBRR ����������� �. �. 23.05.2017 [17-71] ���: ������ �������� ��������� �� ��������� �� �������� �� ����������
    -->>-- 10.03.2016  ������ �.�.      [15-1547]  ���: �������� � ������ �� - ������������ ���/��  https://redmine.lan.ubrr.ru/issues/29103
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
    --<<-- 10.03.2016  ������ �.�.      [15-1547]  ���: �������� � ������ �� - ������������ ���/��  https://redmine.lan.ubrr.ru/issues/29103
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
                                    70, -->><<-- 10.03.2016  ������ �.�.      [15-1547]  ���: �������� � ������ �� - ������������ ���/��
                                    71) -->><<-- 18.03.2016  �������� �.�.     [15-1726]  ���: �������� � ������ �� - ������������ ���/�� )
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
    and ctrnmfoa in (select cfilmfo from xxi."fil" where idsmr = BankIdSmr) --! ���� ������� -> ���������� �������  -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
    and (lower(trn.CTRNPURP) not like '%��������%'
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
    -->> 23.10.2017 ����� �.�. 17-1225
    /*
    and lower(trn.CTRNPURP) not like '%��������%'
    and lower(trn.CTRNPURP) not like '%��������%'
    and lower(trn.CTRNPURP) not like '%��� �����%'
    and lower(trn.CTRNPURP) not like '%��� �����%'
    */
    --<< 23.10.2017 ����� �.�. 17-1225
    -- and lower(trn.CTRNPURP) not like '%������������%'
    /*and lower(trn.CTRNPURP) not like '%���%����%'*/ -->><<--  23.10.2017 ����� �.�. 17-1225
    and lower(trn.CTRNPURP) not like '%������%'
    and nvl(regexp_count(lower(trn.CTRNPURP),'����'),0) = nvl(regexp_count(lower(trn.CTRNPURP),'���������'),0) -- 19.09.2018 ubrr rizanov [18-251] ���: ����� ���������� �� �������� �� ������� � ������ �� ("���������")              
    -->> 09.12.2015  ubrr pinaev      15-995     ���������� ���������� https://redmine.lan.ubrr.ru/issues/26464
    and lower(trn.CTRNPURP) not like '%������%'
    and lower(trn.CTRNPURP) not like '%������%'
    and lower(trn.CTRNPURP) not like '%����������%'
    and lower(trn.CTRNPURP) not like '%������%'
    and lower(trn.CTRNPURP) not like '%��������%����%'
    and lower(trn.CTRNPURP) not like '%�����������%'
    and lower(trn.CTRNPURP) not like '%���%������%'
    and lower(trn.CTRNPURP) not like '%��%'
    /*and lower(trn.CTRNPURP) not like '%���%����%'*/-->><<--  23.10.2017 ����� �.�. 17-1225
    --<< 09.12.2015  ubrr pinaev      15-995     ���������� ���������� #26464 https://redmine.lan.ubrr.ru/issues/26464
    -->> 19.02.2016 ������ �.�.   #28454 ���: �������� �� ������� �� - �� � %. ���������� ��������.
    and lower(trn.CTRNPURP) not like '%��������%'
    and lower(trn.CTRNPURP) not like '%�������%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�/����%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�\����%'
    --and lower(trn.CTRNPURP) not like '%�����%��%'
    --and lower(trn.CTRNPURP) not like '%�����������%��%'
    --<< 19.02.2016 ������ �.�.   #28454 ���: �������� �� ������� �� - �� � %. ���������� ��������.
    -->> ubrr korolkov
    and lower(trn.CTRNPURP) not like '%������%'
    and lower(trn.CTRNPURP) not like '%����%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�.��%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�\�%'
    --<< ubrr korolkov
    -->> 22.08.2017  �������� �.�. [17-1031] ���: �������� ����� ���������� ��� ������� �������� ��� �������� ������� � ������ ��
    and lower(replace(trn.CTRNPURP,' ')) not like '%����%����%'
    and lower(replace(trn.CTRNPURP,' ')) not like '%�������%������%' )
    --<< 22.08.2017  �������� �.�. [17-1031] ���: �������� ����� ���������� ��� ������� �������� ��� �������� ������� � ������ ��
    -->> 23.10.2017 ����� �.�. 17-1225
    and (   lower(trn.ctrnpurp) LIKE '%�����%��%'
         or lower(trn.ctrnpurp) LIKE '%�����������%��%'
         or lower(trn.ctrnpurp) LIKE '%������������%')
    --<< 23.10.2017 ����� �.�. 17-1225
    and (    ITRNTYPE = 4
          or ITRNTYPE = 2      -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
          OR ITRNTYPE in (11,28) 
         AND EXISTS( select 1
                       from trc
                      where trc.ITRCNUM = trn.ITRNNUMANC
                        and trc.ITRCTYPE in (2,4) ) -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
        )                                                   
    and not exists --���� ����������� �������� ����, ��������, �������� ����� ��������, ������ �� ��������.
                  (select 1
                   from ubrr_ulfl_tab_acc_coms c
                   where c.DCOMDATERAS = p_d1
                   and c.ICOMTRNNUM IS NOT NULL
                   and c.ccomaccd = trn.CTRNACCD)
    /*
     ��������� ��������, ��������������� �� ���.������� (����� ���������  �������� ��� ������.��������)
    */
    -->>09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
    /*and not exists (select 1
                    from ubrr_unique_tarif
                    where a.caccacc = cacc
                    and trn.dtrncreate between DOPENTARIF and DCANCELTARIF
                    and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)*/
    --<<09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��                
    and not exists (select 1
                    from ubrr_data.ubrr_sbs_new
                    where idsmr = a.idsmr
                    and dSBSdate = p_d1
                    and cSBSaccd = a.caccacc
                    and cSBScurd = a.cacccur
                    and cSBSTypeCom = 'IP_DOH_VB'
                    and iSBStrnnum is not null)
  --<< 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��                                         
 ;
    -->><<--  23.10.2017 ����� �.�. 17-1225  �� ��

    -- ��������� ������� ���������� ����� � ���������
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
                  and au.d_create <= p_d2 -- ������ �� ������� ��� ����� �������
                  and add_months(last_day(au.d_create), 11) > p_d1 -- ���� ���� ������� �������� �� ����� ��� 11 ������� ����� �� ������ �������
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
  ���. ������������� ������ � ����������� ���� ��� �� "�������� 100"
  ����� ���� �� ��������� "UBRR_XXI5"."UBRR_BNKSERV"
  ������ 2872
  */

--  ��� ���� �������� ������� �� ��� � ���
  cursor express100_cur(d1 date, d2 date, acc_1 varchar2) IS
    select ITRNNUM
      from (select ITRNNUM,
                   ctrnaccd,
                   ctrncur,
                   iACCotd,
                   ROW_NUMBER() over(partition by ctrnaccd, ctrncur, iACCotd order by ITRNNUM) rn
              from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v, acc a -->><<--07.11.2019 �������� [19-62184] ���������� �������� �����
              -->> 08.12.2015 ������ 15-995 https://redmine.lan.ubrr.ru/issues/26464 ������ #26464
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
                --<< 08.12.2015 ������ 15-995 https://redmine.lan.ubrr.ru/issues/26464 ������ #26464
             where ctrnaccd like acc_1
             -->> 08.12.2015 ������ 15-995 https://redmine.lan.ubrr.ru/issues/26464 ������ #26464
               and a.caccacc = g.cgacacc -- ���������� ������ ���� ��� ������ � �� ��������
               --<< 08.12.2015 ������ 15-995 https://redmine.lan.ubrr.ru/issues/26464 ������ #26464
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
               and cACCprizn <> '�'
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
                -->>23.10.2017  ����� �.�.       17-1225  ������� ����������� ����� (�� ������� ����� ��� ���� ��������, ��� ��������� �� �������� ����� � ���������� 112\81-85)
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
                  -->>23.10.2017  ����� �.�.       17-1225 ������� ����������� ����� (�� ������� ����� ��� ���� ��������, ��� ��������� �� �������� ����� � ���������� 112\81-85)
               and not exists
             (select 1
                      from ubrr_unique_tarif
                     where ctrnaccd = cacc
                       and dtrncreate between DOPENTARIF and DCANCELTARIF
                       and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)           -->><<-- ubrr �������� �.�. #29736 ��������� �� ��� ��� ���
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
  ������ 30 �������� ��� ��������. ���
  ������ 3209 UBRR_BNKSERV
  */
  cursor ntk_cur(d1 date, d2 date, acc_1 varchar2) IS
    select ITRNNUM
      from (select ITRNNUM,
                   ctrnaccd,
                   ctrncur,
                   iACCotd,
                   g.cgacacc,
                   ROW_NUMBER() over(partition by ctrnaccd, ctrncur, iACCotd order by ITRNNUM) rn
              from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v, -->><<--07.11.2019 �������� [19-62184] ���������� �������� �����
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
               and ( -- �������
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
                   -- ����������, ������
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
               and cACCprizn <> '�'
               and a.caccacc = g.cgacacc
               -->> 08.12.2015 ������ 15-995 https://redmine.lan.ubrr.ru/issues/26464 ������ #26464
               /*(+)*/ -- �� ����� ���������� �����, �� ������� ��������� � �� ��������
               --<< 08.12.2015 ������ 15-995 https://redmine.lan.ubrr.ru/issues/26464 ������ #26464
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
                       and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)           -->><<-- ubrr �������� �.�. #29736 ��������� �� ��� ��� ���
         )
     WHERE
      -->> 09.12.2015  ubrr pinaev      15-995     ������ #26464 https://redmine.lan.ubrr.ru/issues/26464
        /* cgacacc is null
        or cgacacc is not null and */
        --<<  09.12.2015  ubrr pinaev      15-995     ������ #26464 https://redmine.lan.ubrr.ru/issues/26464
        rn <= 30;

  TYPE t_Rec_ntk IS TABLE OF ntk_cur%ROWTYPE INDEX BY PLS_INTEGER;

  ----------------------------------- ������� � ��������� -----------------------------------------------------------------
  function is_special_grp_condition_true(p_cTRNaccd varchar2,
                                         p_cacccur  varchar2,
                                         p_d1       date,
                                         p_d2       date) return integer is
    iFlag integer;
    vRes  t_Rec_specAcc;
  begin
    -- ��� ����� ���������� ���/��
    open specAcc(p_cTRNaccd, p_cacccur, p_d1, p_d2);
    fetch specAcc
      into vRes;
    if specAcc%notfound then
      iFlag := 1; --  ��� ������� ��� � ���������� ��� ������ ����� ����, �����. ������ ����� TRN
    else
      iFlag := 0; -- ������� �� �����������, �������� ������ � ������ ������������, �� ����� ������ TRN
    end if;
    close specAcc;
    return(iFlag);
  end is_special_grp_condition_true;

  /*
  ���� itrnnum �������� � ������ 30 ��������, �� ������� �� ��������� ��������, ���������� 1, ����� - 0
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
  ������ 30 �������� ��� Ntk
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
  ���� ����� ������� � �����, ��������� ��������
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
          --������������� �����
          return l_lim(i).srate;
        end if;
        if l_lim(i).prate is not null then
          --������� �� �����
          return round(l_lim(i).prate * p_sum / 100, 2);
        end if;
      end if;
    END LOOP;
    return - 1;
  end get_comss_sum;

  /*
  ��������� ����� �� ������� UBRR_ULFL_COMSS_SCALE
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
  ������� �� TRN ���������� � ��������� ��������
  ����������� �� ����� ubrr_ulfl_acc_coms
  */
function calc_mask_comss(p_date date, p_mask varchar2)
    return varchar2
is
    vErr         varchar2(2000);
    IBO1         NUMBER;
    IBO2         NUMBER;
    cvcomstat    VARCHAR2(2000);
    -- iScale       integer; ->><<--23.10.2017  ����� �.�. 17-1225 �� ������������  � ������� ��������
    nComSum      number;
    --CMASK        VARCHAR2(20);
    --Caccc        VARCHAR2(20);
    --Ccurc        VARCHAR2(3);
    iCnt         integer;
    iAllCnt      integer;
    d2           date;
    iSessionId   number;
    --c_express100 t_Rec_express100; -->><<--23.10.2017  ����� �.�. 17-1225 ��� ����������
    -- c_ntk        t_Rec_ntk;       -->><<--23.10.2017  ����� �.�. 17-1225 ��� ����������
    cComm        varchar2(200);
    vCusNum      number;
    ismrrr       number(5);
    -->><<--23.10.2017  ����� �.�. 17-1225 �� ������������   � ������� ��������
    /*
    cursor c_smr is
    select idsmr from ubrr_smr;     -->><<-- ubrr �������� �.�. #29736 ��������� �� ��� ��� ���
    */
    -->><<--23.10.2017  ����� �.�. 17-1225 �� ������������  � ������� ��������
BEGIN
    vErr    := 'OK';
    iBO1    := 25;
    iBO2    := 5;
    d2      := /*ADD_MONTHS(p_date, 1) - 1 / 24 / 60 / 60;*/  p_date+ 86399/86400;-->><<--23.10.2017  ����� �.�. 17-1225   �������, �� ��
    iAllCnt := 0;

    -->>23.10.2017  ����� �.�.       17-1225  ������� ������� ������� ������� ����
    /*
    delete from ubrr_ulfl_tab_acc_coms
    where DCOMDATERAS = p_date
    and ICOMTRNNUM IS NULL
    and ccomaccd like p_mask;
    */
    --<<23.10.2017  ����� �.�.       17-1225   ������� ������� ������� ������� ����

    execute immediate 'truncate table UBRR_DATA.UBRR_ULFL_TEMP';
    execute immediate 'truncate table UBRR_DATA.UBRR_ULFL_TRACE';
    -->>23.10.2017  ����� �.�. 17-1225 �� ������������
    /*
    for c in c_smr loop
    XXI_CONTEXT.Set_IDSmr(c.idsmr);
    */
    -->>23.10.2017  ����� �.�. 17-1225 �� ������������

    ismrrr := ubrr_xxi5.ubrr_util.GetBankIdSmr;-->><<--04.12.2017 ����� �.�. https://redmine.lan.ubrr.ru/issues/47017#note-69 --sys_context('B21', 'IdSmr'); --���������� �����������

    select UBRR_DATA.UBRR_ULFL_SESSION_SEQ.NEXTVAL
    into iSessionId
    from dual;

    INSERT INTO UBRR_DATA.UBRR_ULFL_TRACE
    VALUES (sysdate, 'Begin of idsmr=' || ismrrr || '  iSessionId=' || iSessionId);
    commit;
      -->>23.10.2017  ����� �.�. 17-1225 ��� ����������
      /*
      -- ������ ��� �������� �������� 100 �� ������� �� ��������� ��������
      open express100_cur(trunc (p_date, 'MM'), d2, p_mask); -->><<--23.10.2017  ����� �.�. 17-1225 https://redmine.lan.ubrr.ru/issues/47017#note-14
      fetch express100_cur BULK COLLECT
        into c_express100;
      close express100_cur;
      cComm := '������� express100: count=' || to_char(c_express100.count);
      INSERT INTO UBRR_DATA.UBRR_ULFL_TRACE VALUES (sysdate, cComm);
      commit;

      -- ������ ��� �������� ��� �� ������� �� ��������� ��������
      open ntk_cur(trunc (p_date, 'MM'), d2, p_mask); -->><<--23.10.2017  ����� �.�. 17-1225 https://redmine.lan.ubrr.ru/issues/47017#note-14
      fetch ntk_cur BULK COLLECT
        into c_ntk;
      close ntk_cur;

      cComm := '������� ���: count=' || to_char(c_ntk.count);
      INSERT INTO UBRR_DATA.UBRR_ULFL_TRACE VALUES (sysdate, cComm);
      commit;
      */
      --<<23.10.2017  ����� �.�. 17-1225 ��� ����������
      -->> 09.12.2015  ubrr pinaev      15-995     ������ #26464 https://redmine.lan.ubrr.ru/issues/26464

    iCnt :=0;
    --<< 09.12.2015  ubrr pinaev      15-995     ������ #26464 https://redmine.lan.ubrr.ru/issues/26464
    for rec_temp in get_calcTrn(p_date, d2, p_mask, ismrrr) loop
        if is_special_grp_condition_true(rec_temp.ctrnaccd, 'RUR', p_date, d2) = 1
           -->>23.10.2017  ����� �.�. 17-1225 ��� ����������
           /*and
           is_free_express100_trn(c_express100, rec_temp.itrnnum) = 0 and
           is_free_ntk_trn(c_ntk, rec_temp.itrnnum) = 0 */
           -->>23.10.2017  ����� �.�. 17-1225 ��� ����������
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
                    rec_temp.ctypecom -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
                    ); -->><<--23.10.2017  ����� �.�.       17-1225  ������� ����   (������� � ����� � �������)
            commit;
            -->> 09.12.2015  ubrr pinaev      15-995     ������ #26464 https://redmine.lan.ubrr.ru/issues/26464
            iCnt := iCnt+1;
            --<< 09.12.2015  ubrr pinaev      15-995     ������ #26464 https://redmine.lan.ubrr.ru/issues/26464
        end if;
    end loop;

    -->> 09.12.2015  ubrr pinaev      15-995     ������ #26464 https://redmine.lan.ubrr.ru/issues/26464
    cComm := '��������� �������� trn � UBRR_ULFL_TEMP count=' || iCnt;
    --<< 09.12.2015  ubrr pinaev      15-995     ������ #26464 https://redmine.lan.ubrr.ru/issues/26464

    INSERT INTO UBRR_DATA.UBRR_ULFL_TRACE VALUES (sysdate, cComm);
    commit;

    for rec in (select ctrnaccd,
                       ctrncur,
                       sum(mtrnsum) mtrnsum,
                       CACCPRIZN,
                       IDSMR,
                       iaccotd,
                       -->>23.10.2017  ����� �.�. 17-1225 ������� ����
                       count(*) cnt,
                       max(Sumbefo) Sumbefo,
                       batnum,
                       ctypecom  -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ �� 
                       -->>23.10.2017  ����� �.�. 17-1225 ������� ����
                from UBRR_ULFL_TEMP
                where id = iSessionId
                group by ctrnaccd, ctrncur, CACCPRIZN, IDSMR, iaccotd, batnum
                        ,ctypecom -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
               )
    loop
        /* iScale := get_comss_scale(rec.IDSMR, rec.iaccotd, rec.mtrnsum); -- ������ �����*/ -->><<--23.10.2017  ����� �.�. 17-1225 ����� ������ �� ����� ������� �������� � ����� ����
        /*
        � ���������� � ������������ ��������� ����������� ��������� �����, ���������� ������������� ����� ��������� �����
        ��� �������� ��������, � ������������ � �������� ��-���������� (������� ���� �� �����������) � ������� ���� ������� ��/��
        (���������� �� ������� ���/��  15/4 �� �������, ������� XXI.GCS). ��� ���������� ��������� �� ���� ������ ���� �������� ��� �� ����� ������� ��������� ����� ��������� �����, ��������� ����.
        */
        -->>--  16.06.2016  ������ �.�.      [16-2126] ��������� ������������ ������� 446-� (����� �����)
        /*select count(*)
          into iCnt
          from acc a, gcs g
         where a.IACCCUS = g.igcscus
           and a.caccacc = rec.ctrnaccd
           and g.igcscat = 15
           and g.igcsnum = 4;

        if iCnt > 0 then
          -- ��
          CMask := '70601810_' || rec.iaccotd || '2102320';
        else
          -- ��
          CMask := '70601810_' || rec.iaccotd || '2102320';
        end if;
        */
        --CMask := UBRR_RKO_SYMBOLS.get_new_rko_mask(to_char(rec.iaccotd), '320', rec.ctrnaccd, rec.ctrncur, '27402','27403');
        --<<--  16.06.2016  ������ �.�.      [16-2126] ��������� ������������ ������� 446-� (����� �����)

        nComSum   := 0;
        cvcomstat := '�����';

        /* -- 21.02.2018 ubrr korolkov 18-12.1
        begin
          select caccacc, CACCCUR
            into caccc, ccurc
            from acc
           where caccacc like Cmask
             and IACCOTD = rec.iaccotd
          --   and CACCPRIZN = '�'
             and rownum = 1;
            -->>--  16.06.2016  ������ �.�.      [16-2126] ��������� ������������ ������� 446-� (����� �����)

            -->> 13.11.2015 ubrr korolkov 15-1059.3
            /*vCusNum := acc_info.Get_CusNum(rec.cTrnAccD, rec.cTrnCur);
            cAccC := ubrr_zaa_comms.Get_Acc446pFromOld(vCusNum, cAccC, cCurC);
            if cAccC is null then
                raise no_data_found;
            end if;* /
            --<< 13.11.2015 ubrr korolkov 15-1059.3
            --<<--  16.06.2016  ������ �.�.      [16-2126] ��������� ������������ ������� 446-� (����� �����)
        exception
          when no_data_found then
            caccc     := '00000000000000000000';
            ccurc     := 'RUR';
            cvcomstat := '������ - ���� ��� �������� �������� �� ���������';
        end;
        */ -- 21.02.2018 ubrr korolkov 18-12.1

        -->>23.10.2017  ����� �.�. 17-1225 �� ������������, ������� � ����� ��������� �   ubrr_xxi5.ubrr_bnkserv_calc_new.getsumcomiss
        /*
        if iScale > 0 then
          nComSum := get_comss_sum(rec.mtrnsum, iScale); -- ��������� ����� ��������
        else
          if instr(cvcomstat, '������') > 0 then
            cvcomstat := '������ - ����� �������� �� ����������.' ||
                         cvcomstat;
          else
            cvcomstat := '������ - ����� �������� �� ����������.';
          end if;
        end if;
        */
        --<<23.10.2017  ����� �.�. 17-1225  �� ������������, ������� � ����� ��������� �   ubrr_xxi5.ubrr_bnkserv_calc_new.getsumcomiss
        -->>23.10.2017  ����� �.�. 17-1225
        --������� ������� �������
        DELETE FROM ubrr_data.ubrr_sbs_new
        WHERE idsmr = sys_context('B21', 'IdSmr')
        AND isbstrnnum IS NULL
        AND dsbsdate = p_date
        AND isbstypecom = 16
        and csbstypecom = rec.ctypecom  -- 07.03.2019  ������� �.�. [#60292] ������ ��� ������������� �������� �������� UL_FL � UL_FL_VB
        AND csbsaccd LIKE rec.ctrnaccd;

        --��������� ����� ��������
        ncomsum := ubrr_xxi5.ubrr_bnkserv_calc_new.getsumcomiss(NULL,
                                                                NULL,
                                                                rec.ctrnaccd,
                                                                rec.ctrncur,
                                                                rec.iaccotd,
                                                                rec.ctypecom,  --'UL_FL',  -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
                                                                rec.mtrnsum,
                                                                rec.sumbefo);
        -->>23.10.2017  ����� �.�. 17-1225
        if nComSum >= 0 /*or iScale = -1*/ then -->><<--23.10.2017  ����� �.�. 17-1225 ����� ��� ������ �� �����
            iAllCnt := iAllCnt + 1;
            -->>23.10.2017  ����� �.�. 17-1225 ������ ������� �����
            INSERT INTO ubrr_data.ubrr_sbs_new
                (csbsaccd, csbscurd, csbstypecom, msbssumpays, isbscountpays, msbssumcom, isbsotdnum, isbsbatnum, dsbsdate, isbstypecom, dsbsdatereg, MSBSSUMBEFO)
            VALUES
                (rec.ctrnaccd, rec.ctrncur
                , rec.ctypecom -- 'UL_FL' /*TypeCom*/ -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ �� 
                , rec.mtrnsum, rec.cnt, ncomsum, rec.iaccotd, rec.batnum, p_date, 16, p_date, rec.sumbefo);
            --<<23.10.2017  ����� �.�. 17-1225 ������ ������� �����
        end if;
    end loop;

    cComm := 'End of idsmr=' || ismrrr;
    INSERT INTO UBRR_DATA.UBRR_ULFL_TRACE VALUES (sysdate, cComm);
    commit;

    --end loop; -->><<--23.10.2017  ����� �.�. 17-1225 �� ������������
    if iAllCnt > 0 then
        return vErr || iAllCnt;-->><<--23.10.2017  ����� �.�. 17-1225 ������� iAllCnt ��� �������� ���-�� ����� (����� ��� ������ ubrr_bnkserv_everyday.fmx)
    else
        return '���������� �������� �� �������';
    end if;

exception
    when others then
        vErr := '�� ������� ���������� ������: ' || dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
        return vErr;
end calc_mask_comss;


  -->>23.10.2017  ����� �.�. 17-1225  ���: ������������� �������� �� ������� ������� � ������ ��
  --������� �������� ��� ��������� ������ �� ������������������� ������������
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
          ctypecom varchar2(20) -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
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
          ctypecom  ubrr_data.ubrr_ulfl_temp_ba.ctypecom%TYPE -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��             
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
      --������� ��������� ������ �� ������� ������
      EXECUTE IMMEDIATE 'truncate table UBRR_DATA.UBRR_ULFL_TEMP_BA';
      EXECUTE IMMEDIATE 'truncate table UBRR_DATA.UBRR_ULFL_TRACE_BA';

      ismrrr := ubrr_xxi5.ubrr_util.GetBankIdSmr;-->><<--04.12.2017 ����� �.�. https://redmine.lan.ubrr.ru/issues/47017#note-69 --sys_context('B21', 'IdSmr'); --���������� �����������

      SELECT ubrr_data.ubrr_ulfl_session_seq.nextval
       INTO isessionid
      FROM dual;

      INSERT INTO ubrr_data.ubrr_ulfl_trace_ba
      VALUES
          (SYSDATE, 'Begin of idsmr=' || ismrrr || '  iSessionId=' || isessionid);
      COMMIT;
      /*
      -- ������ ��� �������� �������� 100 �� ������� �� ��������� ��������
      OPEN express100_cur(trunc (p_date, 'MM'), d2, p_mask);
      FETCH express100_cur BULK COLLECT
          INTO c_express100;
      CLOSE express100_cur;
      --������� � ���
      cComm := '������� express100_v2: count=' || to_char(c_express100.count);
      INSERT INTO ubrr_data.ubrr_ulfl_trace_ba VALUES (SYSDATE, ccomm);
      COMMIT;

       -- ������ ��� �������� ��� �� ������� �� ��������� ��������
      open ntk_cur(trunc (p_date, 'MM'), d2, p_mask);
      fetch ntk_cur BULK COLLECT
        into c_ntk;
      close ntk_cur;
       --������� � ���
      cComm := '������� ���_v2: count=' || to_char(c_ntk.count);
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
              ulfl(ids).ctypecom   := rec_temp.ctypecom; -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��             
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

        ccomm := '��������� �������� trn � UBRR_ULFL_TEMP_ba count=' || ids;

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
             ctypecom -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��             
        BULK COLLECT INTO ulfl_t
        FROM ubrr_ulfl_temp_ba
        WHERE id = isessionid
        GROUP BY ctrnaccd, ctrncur, caccprizn, idsmr, iaccotd, batnum
                ,ctypecom; -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��

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
          cvcomstat := '�����';

          BEGIN
              SELECT caccacc, cacccur
              INTO caccc, ccurc
              FROM acc
              WHERE caccacc LIKE cmask
                    AND iaccotd = ulfl_t(i).iaccotd
                   --   and CACCPRIZN = '�'
                    AND rownum = 1;
          EXCEPTION
              WHEN no_data_found THEN
                  caccc     := '00000000000000000000';
                  ccurc     := 'RUR';
                  cvcomstat := '������ - ���� ��� �������� �������� �� ���������';
          END;
          */ -- 21.02.2018 ubrr korolkov 18-12.1

          --������� ������� �������
          DELETE FROM ubrr_data.ubrr_sbs_new
          WHERE idsmr = sys_context('B21', 'IdSmr')
                AND isbstrnnum IS NULL
                AND dsbsdate = p_date
                AND isbstypecom = 32
                and csbstypecom = ulfl_t(i).ctypecom  -- 07.03.2019  ������� �.�. [#60292] ������ ��� ������������� �������� �������� UL_FL � UL_FL_VB                
                AND csbsaccd LIKE ulfl_t(i).ctrnaccd;

          --��������� ����� ��������
          ncomsum := ubrr_xxi5.ubrr_bnkserv_calc_new.getsumcomiss(NULL,
                                                                  NULL,
                                                                  ulfl_t(i).ctrnaccd,
                                                                  ulfl_t  (i).ctrncur,
                                                                  ulfl_t  (i).iaccotd,
                                                                  ulfl_t  (i).ctypecom, --'IP_DOH',  --�������� ���� ��������. -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
                                                                  ulfl_t  (i).mtrnsum,
                                                                  ulfl_t  (i).sumbefo);

          IF ncomsum >= 0
          THEN
              iallcnt := iallcnt + 1;
              ids := ids + 1;
              in_sbs(ids).c_csbsaccd      := ulfl_t(i).ctrnaccd;
              in_sbs(ids).c_csbscurd      := ulfl_t(i).ctrncur;
              in_sbs(ids).c_csbstypecom   := ulfl_t(i).ctypecom; -- 'IP_DOH' /*TypeCom*/;  --�������� ���� ��������. -- 12.02.2019 ������� �.�. [18-57910.2] ���: ��������� �������� �� ���������������� ������� � ������ ��
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
          RETURN '���������� �������� �� �������';
        END IF;
      ELSE
        RETURN '���������� �������� �� �������';
      END IF;

  EXCEPTION
    WHEN OTHERS THEN
      verr := '�� ������� ���������� ������: ' || dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
      RETURN verr;
  END calc_mask_comss_businact;
  --<<23.10.2017  ����� �.�. 17-1225 ���: ������������� �������� �� ������� ������� � ������ ��

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
  ����������� ��������
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

-- (���.) UBRR ����������� �. �. 23.05.2017 [17-71] ���: ������ �������� ��������� �� ��������� �� �������� �� ����������
        IF rvDocument.cAccD like '40821%'
           --(rvDocument.cAccD like '40821________7______' or
           --rvDocument.cAccD like '40821________8______')
        THEN
          BEGIN
            vcPrimAcc := rvDocument.cAccD; -- ���� 40821% �������� � ����������
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
-- (���.) UBRR ����������� �. �. 23.05.2017 [17-71] ���: ������ �������� ��������� �� ��������� �� �������� �� ����������
               and caccprizn <> '�'
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
                     cComStat = '����������� 406% ��� 407% ��� 408%'
               where rowid = r.rowid;
              continue;
          END;
        END IF;

        -- ������������ ����������, ���.����.�������� �� ������ ����� �������� �������� �� ����������
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
            vAccName := '�������� �� ������� ��-�� ';
        end;

        -- � ���������� ������� ������ �� ���� �������� �������� (���� ��, �� �������� �������������� �������), ��������� ������ �����,����� ������������ �������� ������� ����� (�.�. ���� 40821,42309),
        if vcPrimAcc is not null then
          rvDocument.cPurp := vAccName || '�� ����� (' || vcPrimAcc ||
                              ') �� ������ � ' ||
                              to_char(r.dcomdateras, 'dd.mm.yyyy') ||
                              ' �� ' || to_char(add_months(r.dcomdateras, 1) - 1,
                                                'dd.mm.yyyy') || ' �.';
        else
          rvDocument.cPurp := vAccName || ' �� ������ � ' ||
                              to_char(r.dcomdateras, 'dd.mm.yyyy') ||
                              ' �� ' || to_char(add_months(r.dcomdateras, 1) - 1,
                                                'dd.mm.yyyy') || ' �.';
        end if;

        if substr(r.CCOMACCD, 1, 8) = '40807810' then
          rvDocument.cPurp := '{VO80050}' || rvDocument.cPurp;
        end if;

        BEGIN
          -->>> 09.01.2018  ����� �.�.       [17-913.2] ���: ���/�� ��� �������� �����
          if rvDocument.iBO1 = 25 then
            cPurpDog := ' ' || ubrr_xxi5.ubrr_zaa_comms.Get_LinkToContract(p_Account => nvl(vcPrimAcc, r.CCOMACCD),
                                                                           p_IdSmr   => r.idsmr);
          else
          --<<< 09.01.2018  ����� �.�.       [17-913.2] ���: ���/�� ��� �������� �����
          select ' ����.�. ' ||
           -->> ubrr 11.07.2016 �������� �.�. #33232 ��� ��� ����� �������� � ������������ ��������
                decode(nump, 225, '2.2.5 ���. ', 32, '3.2 ���.', 1023, '2.3. ������ ��������, ������� � �������� ������ ') ||
                case when nump not in (32, 1023) then '� ' || caccsio || ' �� ' ||to_char(dacclastoper, 'DD.MM.YYYY')
                     else ''
                end
          --<< ubrr 11.07.2016 �������� �.�. #33232
            INTO cPurpDog
            from (select acc.caccsio,
                         acc.dacclastoper,
                         min(gac.igacnum) nump
                    from acc, gac
                   where caccacc = r.CCOMACCD
                     and cgacacc = caccacc
                     and ((igaccat = 170 and igacnum in (225, 1023)) or -->><<-- ubrr 11.07.2016 �������� �.�. #33232 ��� ��� ����� �������� � ������������ ��������
                         (igaccat = 172 and igacnum = 32))
                   group by acc.caccsio, acc.dacclastoper);
           end if; --  09.01.2018  ����� �.�.       [17-913.2] ���: ���/�� ��� �������� �����
        EXCEPTION
          WHEN OTHERS THEN
            cPurpDog := '';
        END;
        rvDocument.cPurp   := rvDocument.cPurp || cPurpDog;
        rvDocument.cAccept := '� ��������';
        If instr(upper(rvDocument.cPurp), ' ���.') = 0  and Instr(upper(rvDocument.cPurp), ' ������ ��������')=0 Then
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
              rvDocument.cPurp := rvDocument.cPurp || ' ���. ' || vCACCSIO ||
                                  ' �� ' || vDACCLASTOPER;
            End If;
          Exception
            When Others Then
              Null;
          End;
        End If;

        rvDocument.cPurp := rvDocument.cPurp || chr(10) ||
                            ' ��� �� ����������';
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
          --���� �� ����������������
          UPDATE ubrr_ulfl_tab_acc_coms
             set CCOMSTAT = '������: ' || rvRetDoc.cResult
           where CCOMACCD = r.CCOMACCD
             and DCOMDATERAS = r.DCOMDATERAS;
          Err_Proc_Cnt := Err_Proc_Cnt + 1;
        elsif rvRetDoc.cPlace = 'TRN' then
          ----->> ������� ������������
          update xxi."trn"
             set cTrnIdAffirm = vRegUser, cTrnIdOpen = vRegUser
           where iTrnNum = rvRetDoc.iNum
             and iTrnAnum = rvRetDoc.iANum;
          -----<< ������� ������������

          UPDATE ubrr_ulfl_tab_acc_coms
             set ICOMTRNNUM = rvRetDoc.iNum,
                 CCOMSTAT   = '���������',
                 MCOMSUMREG = rvDocument.mSumD,
                 ITRNTRC    = 1
           where CCOMACCD = r.CCOMACCD
             and DCOMDATERAS = r.DCOMDATERAS;
          Succ_Proc_Cnt := Succ_Proc_Cnt + 1;

        elsif rvRetDoc.cPlace = 'TRC' then
          ----->> ������� ������������
          update xxi."trn"
             set cTrnIdAffirm = vRegUser, cTrnIdOpen = vRegUser
           where iTrnNum = rvRetDoc.iNum;
          -----<< ������� ������������
          UPDATE ubrr_ulfl_tab_acc_coms
             set ICOMTRNNUM = rvRetDoc.iCardNum,
                 CCOMSTAT   = '���������� � ��������� 2',
                 MCOMSUMREG = rvDocument.mSumD,
                 ITRNTRC    = 2
           where CCOMACCD = r.CCOMACCD
             and DCOMDATERAS = r.DCOMDATERAS;
          Card_Proc_Cnt := Card_Proc_Cnt + 1;
        end if;
        /* -- 26.02.2018 ubrr korolkov 17-913.2
        -->>> 09.01.2018  ����� �.�.       [17-913.2] ���: ���/�� ��� �������� �����
        if rvRetDoc.cResult = 'OK' and rvDocument.iBO1 = 25 then
            begin
                insert into gac (CGACCUR, IGACCAT, IGACNUM, CGACACC, IDSMR)
                values (rvDocument.cCurD, 172, 32, rvDocument.cAccD, r.idsmr);
            exception when others then
                null;
            end;
        end if;
        --<<< 09.01.2018  ����� �.�.       [17-913.2] ���: ���/�� ��� �������� �����
        */ -- 26.02.2018 ubrr korolkov 17-913.2
      exception
        when others then
          update UBRR_ULFL_TAB_ACC_COMS
             set CCOMSTAT = '������,' || dbms_utility.format_error_stack ||
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
