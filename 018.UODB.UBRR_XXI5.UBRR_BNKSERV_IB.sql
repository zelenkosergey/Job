CREATE OR REPLACE PROCEDURE UBRR_XXI5."UBRR_BNKSERV_IB" ( portion_date1 in date
                                                         ,portion_date2 in date
                                                         ,dtran         in date
                                                         ,ls            in varchar2 default null ) IS
/*************************************************** HISTORY *****************************************************\
   ����          �����          id        ��������
----------  ---------------  --------- ------------------------------------------------------------------------------
18.05.2011  ��������� �.�.              �� "�������������" https://redmine.lan.ubrr.ru/issues/2793
23.11.2011  ��������� �.�.              ����� ������ ( 112/35 - ���������;
                                                       112/36 - �������� 30;
                                                       112/37 - �������� 60;
                                                       112/38 - ��� ��������;
                                                       112/39 - ��������;
                                                       112/40 - ��� ��������(�������� ������� ��������) )
                                                       https://redmine.lan.ubrr.ru/issues/3905
28.12.2011  ���������� �.�.             ��������� ����� ���, ���������/������ - 333/2
16.05.2012  ��������� �.�.              �� "�������� 100" https://redmine.lan.ubrr.ru/issues/4849
08.06.2012  ��������� �.�.              ��������� ������� 01.06.2012 https://redmine.lan.ubrr.ru/issues/4936
27.06.2012  ��������� �.�.              ������ ����� �� ������� ��������:
                                            ������������� ������ �� �������� �������� ��� �� "�������� 30"
                                            ������������� ������ �� �������� �������� ��� �� "�������� 100"
                                            ������������� ������ �� �������� �������� ��� �� <�������� 60>
                                            ������������� ������ �� �������� �������� ��� �� <��������>
                                            ���������������� ������ �� �������� �������� ��� �������: 112/35 - ���������,
                                                                                                      112/35 - ����-����� - ����� UBRR Pashevich A. #12-1224 ������� ������ ������
                                                                                                      112/36 - �������� 30,
                                                                                                      112/37 - �������� 60,
                                                                                                      112/38 - ��� ��������,
                                                                                                      112/39 - ��������,
                                                                                                      112/40 - ��� ��������
                                            ���������������� ������ �� �������� �������� ��� ������ "�������� 100"
                                            ���������� �������� ������� �����: � 17-00 � �� 18-00 � ���������������� ������
                                                                               � 18-00 � �� 20-00 � ���������������� ������
                                                                               � 20-00 � �� 22-00 � ���������������� ������
                                            --
                                            �������� ������ ������ � Y:\#For_Update
12.07.2012  ��������� �.�.              ��������� ������� � 01.07.2012 https://redmine.lan.ubrr.ru/issues/5118
23.08.2012  ��������� �.�.              ����� ����� "������-��������", ������ ��� ��� https://redmine.lan.ubrr.ru/issues/5420
25.03.2013  ������� �.�.                �������� ������ ������������
04.04.2013  ������� �.�.                ��������� ������� , ����������� �������, �� ������ �� �����������
                                            "��������� �������������� �������� ��� ������� ��������"
                                            �������������� ��������� � ��������� ��������� ubrr_xxi5.ubrr_unq_comms
08.05.2013  ������� �.�.                ������� ������� RKO ����� �� �����������
19.08.2013  ������� �.�.                ����� �������������
24.05.2013  ������� �.�.                ��������� ������� �� 01.07.2013 �.
11.10.2013  ������� �.�.                https://redmine.lan.ubrr.ru/issues/8201
                                            �������� ���� "�������������"
                                            �������� � �������� ���� "�������������" (�������� �����) �����
                                            ���������� ������������� �������� - 4000 ��., �.�. �� 4000 �������� �������� �� ���������,
                                            ������� � 4001 �������-�������� �� ������������� ������ �� ���������.
14.11.2013  ������� �.�.                ���������� ����� �� 6474,6471,6473 �� 01.11.2013 �.
25.10.2013  ��������� �.�.  12-1657     (#9707) �������� ���� "����������� � ����������� ������"(112/59)
11.12.2013  y.metalnikov@i-sys.ruf
                            12-2172     ��� ���������� �� ������������ �������� �� ������� ����� � �� ������������� ��������.(112/40)
                                            https://redmine.lan.ubrr.ru/issues/11232
20.12.2013  ��������� �.�.  12-2288     (#11418) ��������� ����������� �������� �������� �������, �� 855 �� (�������� �� ��������)
29.01.2014  ������� �.�.                ��������� ������� �� 01.01.2014 �. ������������ � 7006-4596 �� 11.12.2013
20.03.2014  ������� �.�.                ���������� ����� �� 6480,6490,6491,6481,6482,6484,6486,6487 �� 17.03.2014 �.
12.03.2014  ������� �.�.                ��������� ����� 42309 https://redmine.lan.ubrr.ru/issues/11596
06.05.2014  ������� �.�.    14-406      �������� ���� "��� ������"
09.06.2014  ������� �.�. ���������� ����� �� 6488,6497.
                            14-992      ���: ������������� ������������ �������� �� ������ "����-����� �������"
                            14-959      A��: ��������� �������� � ����������� �� ������� �� ����������
30.10.2014  Pashevich AO                ���������� ������ �� ��/������  + ��������
21.01.2015  ������� �.�.                ��������� ������� �� 01.01.2014 �. ������������ � 7006-4289 �� 09.12.2014 �.
16.12.2014  Pashevich           14-1344 AO ���: ��������� �������� �� �� ������ �� ������ ������������ ����
18.02.2015  ����������� �. �.   12-2313 �������� ���� "���������" https://redmine.lan.ubrr.ru/issues/11831
02.02.2015  ����������� �. �.   12-2313 �������� ���� "���������" https://redmine.lan.ubrr.ru/issues/11831, ���������
06.04.2015  ubrr �������� �.�.  15-42   ���. �������� �� ������� ����� �����-Pro Online
07.04.2015  ubrr �������� �.�.  15-231  �� "������ ���������"
08.04.2015  ubrr �������� �.�.  15-223  �� "��� � ���", �� "��� � ��� �������"
09.04.2015  ubrr �������� �.�.  15-279  �� "����������"
06.05.2015  ubrr �������� �.�.  15-42   ���.����. https://redmine.lan.ubrr.ru/issues/19917#note-36
26.05.2015  ubrr korolkov       15-453  ������-�������� 3,6,12
30.04.2015  ����������� �.�.    [15-44] ���: �������� ����� �� ���-��������������
29.06.2015  �������� �.�.       [15-613] �� �������������-1 https://redmine.lan.ubrr.ru/issues/23046
07.07.2015  ������� �.�.          ���������� ����� �� 6483 �� 01.07.2015 �.
20.07.2015  ������� �.�.           ��������� ������� �� 01.07.2015 �. ������������ � 7006-1990 �� �� 08.06.2015 �.
27.07.2015  �������� �.�.        15-830 ���: �� ��� ������ � ���
04.08.2015  ������� �.�.         ���������� ������  �� �������  ��������� ,�������� -�������� �� ������� �/� � ������ <������> � �������������� ������� ���������� ������� ��� �������������� ������� � ���������� � �������� ����
22.08.2015  �������� �.�.        [15-841] ���: �������� ��������. ������ ��� � 03.08.15
01.09.2015  �������� �.�.        [15-921] ���: ������� ����� ���������
30.09.2015  Ubrr ��karova L.U. [15-1101] ���: �� ��������� ��� ���
09.11.2015  Ubrr Pinaev  ���������� ��  ITRNNUM https://redmine.lan.ubrr.ru/issues/25034
22.01.2016 Ubrr ��karova L.U. [15-1644] ���: ��������� �� "���������", "���������-��� ������!"
25.01.2016  ������� �.�.           ��������� ������� �� 01.01.2016 �. ������������ � 7006-3351 �� 10.12.2015 �.
03.02.2016  ������� �.�.          ����������� ��������� ����� ���������������� �������  6491,6483,6250,6245,6204,6242
15.02.2016  ������� �.�.         ����������� ��������� ����� ��������������  �������  6245,6204,6242
11.03.2016 �������� �.�.         15-1221.1 ���: ��������� �� "������ +" (����) #25313
06.04.2016 ������� �.�        ������������ �� 19.02.2016 � 7006-222 (������ ��� )
19.04.2016 ������� �.�        ������������ �� 15.03.2016 � 7006-355 � 01.04.2016 ������ SMS-��������
05.05.2016 �������� �.�.   [16-1808.2.3.5.4.3.2]  #29736  ��� ���
10.07.2016 �������� �.�.   16-2143.2 "����-�����+"
18.07.2016 ������� �.�        ������������  ��  16.06.2016  � 7006-936 ��������� ������� �� 01.07.2016 �
21.07.2016 ubrr Ma������ �.�. 16-2340 ������-�������� ���
07.09.2016 ubrr Ma������ �.�. 16-2451 ���: ����� ����� �������� � ��� � ���
24.09.2016 ubrr Ma������ �.�. 16-2653 ���: ���/�� 112/94 ��� ������ ����� "������-��������"
19.10.2016 ubrr Ma������ �.�. 16-2790 ���: �������� ���������/������ 112/93 �� ������ "����-�����+", ������ IB-Pro
25.10.2016 ������� �.�   ���������� ����� �� 6489-������ ��� 6472, �� 6265- ������ ��� � 6253 (������ �� ����)
03.12.2016 �������� �.�.      16-2817 ��� �����������: ���������� �������� �������� (#38446)
17.01.2017 ������� �.�  ������������  ��  19.12.2016  � 7006-2097 ��������� ������� �� 01.01.2017 � , �� 19.12.2016 � 7006-2096 (���)
09.02.2017 ������� �.�   ����������  �� 6257 - ������ ��� 6237 (����������� ������)
18.04.2017 ������� �.�   ����������  �� 6485 ���������� ���.��������.������������  �� 27.03.2017 � 7006-466
24.05.2017 �������� �.�. [14-985.18] ������������ �������� �������� �� ���������� �������� �� � ��
25.05.2017 ������� �.�  ������������ � 7006-574 �� 13.04.2017  ��������� ������� �� 01.05.2017 �  ��� =0
13.06.2017 �������� �.�.  �������������� ��������� ������� �� ���� ����� ��������, ����� ������� ���������  https://redmine.lan.ubrr.ru/issues/43726
21.07.2017 �. ������� �.�  ������������ � � 7006-931 �� 09.06.2017  ��������� ������� �� 01.07.2017 �
19.01.2018 ������� �.�  ������������ �� 15.12.2017 � 7006-2358  ��������� ������� �� 01.01.2018 �
29.10.2018 ��������      [18-592.2] ��� ������� �������� �� ���������
27.12.2018 ��������      [15-43] ���: ����� ����� ����� � ��������� ������� �� ����� ��������
01.02.2019 ������� �.�.  [19-58770] ��������� ���� ������� ����������� �������
31.05.2019 ������� �.�.  [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
23.10.2019 ��������      [19-62184] ����������: ����������� �� PRO + �����. � ������ �� ���
06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������
13.12.2019 ������� �.�.  [69650]     ����� �������� ���� - �������� �� ����������
23.01.2020 ��������      [19-64846]  ���: ����������� �� ��������� ������ � �� + ���� ������ "������������ ��-���" �� ������� �����
31.08.2020 ������� �.�.  [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
09.09.2020 ������� �.�.  [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
\*************************************************** HISTORY *****************************************************/

    d1       date := portion_date1; -- ��������� ���� � ������ ���������
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
    -->> UBRR �������� �.�. 15-279
    cg_112_75   varchar2(6) := '112/75';
    --<< UBRR �������� �.�. 15-279
     -- UBRR Pashevich AO 14-992
    l_cidsmr    smr.idsmr%type := sys_context ('B21', 'IDSmr');  -- ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������
    -->>28.01.2020 �������� [19-64846]
    dg_date_start constant date := to_date('01.01.1990', 'dd.mm.rrrr');
    dg_date_end   constant date := to_date('01.01.4000', 'dd.mm.rrrr');
    --<<28.01.2020 �������� [19-64846]
BEGIN
   DELETE FROM SBS    where csbsdo ='R_IB';
    DBMS_TRANSACTION.COMMIT;
/*     where csbsdo in ('UAB','PP9','PE9','PP6','PE6','PP3','PP1',
                      'RKO','REO','RKB','REB','RKS','016','017',
                      '018','045','INF')*/

    select -1*ismrtimeshift/60
      into ivTime
      from smr;

    -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������
    -->>19.09.2019 �������� [19-62974] IV ���� - �������� ������� ���/�� ����.��������
    declare
      vErr  varchar2(2000);
    begin
      ubrr_bnkserv_calc_new_proc.fill_rko_acc_catgr( p_cerr           => vErr
                                                    ,p_dportion_date2 => d2        -- ��������� ���� - ��������� ������� ���, �� ������� ��������� ��������  
                                                    ,p_dtran          => dtran     -- ����, � ������� ����������� ��������� ��������
                                                    ,p_cls            => ls );
      
      if vErr is not null then
        ubrr_bnkserv_calc_new_lib.writeprotocol('UBRR_BNKSERV_IB : ������ ������� ��_�� ������ � ubrr_bnkserv_calc_new_proc.fill_rko_acc_catgr');
        return;
      end if;
    end;
    --<<19.09.2019 �������� [19-62974] IV ���� - �������� ������� ���/�� ����.��������
    -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������    

-->>--ubrr �������� �.�. 15-42 ���. �������� �� ������� ����� �����-Pro Online
   INSERT INTO SBS
   ( cSBSpayfrom_acc,cSBSacc, cSBScur, mSBStoll_sum, cSBSdo ,iSBSdebdoc,mSBSdebob,iSBScreddoc,mSBScredob)
   (select to_char(sysdate,'HH24:MI:SS'), acc,ctrncur,/*400*/500,'R_IB', sum(cd),sum(md),sum(cc),sum(mc) --- 19.01.2018 ������� �.�  ������������ �� 15.12.2017 � 7006-2358
      from (
             select /*+ index( trn I_TRN_OLD_NEW_DAC )*/ -->><<--23.10.2019 �������� [19-62184] ������ I_TRN_ACCD_CUR_DTRN_TYPE �� I_TRN_OLD_NEW_DAC
                    ctrnaccd acc,ctrncur,count(1) c,iaccotd,count(1) cd,sum(mtrnsum) md ,0 cc,0 mc, caccmail
             from acc,
                  /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn -->><<--23.10.2019 �������� [19-62184] ����������: ����������� �� PRO + �����. � ������ �� ���
             where
               -- ubrr katyuhin >>>
                   acc.caccacc LIKE acc_1
               and acc.cacccur = 'RUR'
               and acc.caccprizn <> '�'
               -->> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������
               -->>18.09.2019 �������� [19-62974] IV ����
               and exists (select 1
                             from ubrr_rko_acc_catgr r
                            where r.cacc     = cTRNaccd
                              and r.ccur     = ctrncur
                              and r.i_catnum = 105
                              and r.i_grpnum = 2
                              and r.idsmr    = l_cidsmr
                              )
               --<<18.09.2019 �������� [19-62974] IV ����
               -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������               
               and trn.CTRNIDOPEN='IBANK2'
               and not exists (select 1
                             from sbs
                            where csbsdo = 'R_IB'
                              and csbsacc= acc.caccacc
               )
               and acc.iaccbs2 NOT IN (40813, 40817, 40818, 40820
                                      -- UBRR Pashevich A. 12-101
                                      ,42309,40810,40811,40812,40823,40824 -->><<-- ubrr 12.07.2016 �������� �.�. #30780
                                      -- UBRR Pashevich A. 12-101
                                      )
                           -- ubrr katyuhin <<<
               and trn.ctrnaccd = acc.cACCacc
               and trn.ctrncur = acc.cACCcur
               and dtrntran between d1 and d2+86399/86400
               -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������               
               -->>18.09.2019 �������� [19-62974] IV ����
               and not exists (select 1
                                 from ubrr_rko_acc_catgr r
                                where r.cacc = acc.cACCacc
                                  and r.ccur = acc.cACCcur
                                  and r.i_catnum = 112
                                  and r.i_grpnum in (-->><<--23.01.2020 �������� [19-64846] ������ ���/�� https://redmine.lan.ubrr.ru/issues/70705#note-3
                                                     94,                  -- 24.09.2016 ubrr Ma������ �.�. 16-2653 ���: ���/�� 112/94 ��� ������ ����� "������-��������"
                                                     57,71,               -- 29.06.2015  �������� �.�.       [15-613] �� �������������-1
                                                     10,                  -- 19.10.2016 ubrr Ma������ �.�. 16-2790  ������ IB-Pro                          
                                                     67                   -- 18.09.2019 �������� [19-62974] IV ����
                                                    ,45                   -- ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.�������� ���                                                     
                                                    )
                                  and r.idsmr    = l_cidsmr                                                                                      
                              )
               --<<18.09.2019 �������� [19-62974] IV ����
               -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������               
-->> 01.02.2019 ������� �.�.  [19-58770] ��������� ���� ������� ����������� �������
                -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������
               -->>18.09.2019 �������� [19-62974] IV ����
               and not exists (select 1
                                 from ubrr_rko_acc_catgr r
                                where r.cacc     = acc.cACCacc
                                  and r.ccur     = acc.cACCcur
                                  and r.i_catnum = 114
                                  and r.i_grpnum = 16
                                  and r.idsmr    = l_cidsmr                                  
                              )
               --<<18.09.2019 �������� [19-62974] IV ����
                -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������               
--<< 01.02.2019 ������� �.�.  [19-58770] ��������� ���� ������� ����������� �������
 -->> UBRR �������� �.�. 15-279
    and not exists ( select 1
                          from au_attach_obg a1
                            where     caccacc =acc.CACCACC  and cacccur = acc.CACCCUR
                                  and c_newdata = cg_112_75
                                  and d1 between trunc(d_create,'mm') and last_day(add_months (d_create,5))
                                  and exists ( -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������
                                              select 1
                                                from ubrr_rko_acc_catgr r
                                               where r.cacc     = a1.cACCacc
                                                 and r.ccur     = a1.cACCcur
                                                 and r.i_catnum = 112
                                                 and r.i_grpnum = 75
                                                 and r.idsmr    = l_cidsmr -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������                                                   
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
                -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������                         
               -->>18.09.2019 �������� [19-62974] IV ����
               and not exists (select 1
                                 from ubrr_rko_acc_catgr r
                                where r.cacc     = acc.cACCacc
                                  and r.ccur     = acc.cACCcur
                                  and r.i_catnum = 112
                                  and r.i_grpnum in (6,8)
                                  and r.idsmr    = l_cidsmr                                     
                              )
               --<<18.09.2019 �������� [19-62974] IV ����
               -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������
               -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
               and not exists ( select 1
                                  from ubrr_rko_acc_catgr   r
                                      ,ubrr_rko_exinc_catgr e 
                                 where r.i_catnum   = e.icat
                                   and r.i_grpnum   = e.igrp
                                   and e.ccom_type  = 'R_IB'
                                   and e.exinc      = 0
                                   and r.cacc       = acc.caccacc
                                   and r.ccur       = acc.cACCcur                                 
                                   -->>23.01.2020 �������� [19-64846]
                                   and (select trunc(max(au.d_create))
                                          from xxi.au_attach_obg au
                                         where au.caccacc = r.cacc
                                           and au.cacccur = r.ccur
                                           and au.i_table = 304
                                           and au.c_newdata = e.icat||'/'||e.igrp
                                           and trunc(au.d_create) <= r.d_date) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end)
                                   --<<23.01.2020 �������� [19-64846]
                              )              
               --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������                              
               -->>31.08.2020 ������� �.�.  [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� 
               and not exists (select 1 from UBRR_UNIQUE_TARIF_ACC uutc,
                                             UBRR_UNIQUE_ACC_COMMS uuac 
                                       where caccacc = uutc.cacc 
                                         and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF 
                                         and l_cidsmr = uutc.idsmr
                                         and uutc.status = 'N'
                                         and uutc.uuta_id = uuac.uuta_id
                                         and uuac.com_type = 'R_IB')
               --<<31.08.2020 ������� �.�.  [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� 
             group by ctrnaccd,ctrncur,iACCotd, caccmail
           )
group by acc,ctrncur,iaccotd, caccmail);
DBMS_TRANSACTION.COMMIT;
--<<--ubrr �������� �.�. 15-42 ���. �������� �� ������� ����� �����-Pro Online

-->>--ubrr �������� �.�. 15-42 ���. �������� �� ������� ����� �����-Pro ��� ������
   INSERT INTO SBS
   ( cSBSpayfrom_acc,cSBSacc, cSBScur, mSBStoll_sum, cSBSdo ,iSBSdebdoc,mSBSdebob,iSBScreddoc,mSBScredob)
   (select to_char(sysdate,'HH24:MI:SS'), acc,ctrncur,/*400*/500,'R_IB',sum(cd),sum(md),sum(cc),sum(mc) --- 19.01.2018 ������� �.�  ������������ �� 15.12.2017 � 7006-2358
      from (
             select /*+ index( trn I_TRN_OLD_NEW_DAC )*/ -->><<--23.10.2019 �������� [19-62184] ������ I_TRN_ACCD_CUR_DTRN_TYPE �� I_TRN_OLD_NEW_DAC
                    ctrnaccd acc,ctrncur,count(1) c,iaccotd,count(1) cd,sum(mtrnsum) md ,0 cc,0 mc, caccmail
             from acc,
                  /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn -->><<--23.10.2019 �������� [19-62184] ����������: ����������� �� PRO + �����. � ������ �� ���
             where     acc.caccacc LIKE acc_1
                   and acc.cacccur = 'RUR'
               and acc.caccprizn <> '�'
               -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������               
               -->>18.09.2019 �������� [19-62974] IV ����
               and exists (select 1
                             from ubrr_rko_acc_catgr r
                            where r.cacc     = cTRNaccd
                              and r.ccur     = ctrncur
                              and r.i_catnum = 105
                              and r.i_grpnum = 2
                              and r.idsmr    = l_cidsmr                              
                          )
               --<<18.09.2019 �������� [19-62974] IV ����
               -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������               
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
               -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������                
               -->>18.09.2019 �������� [19-62974] IV ����
               and exists (select 1
                             from ubrr_rko_acc_catgr r
                            where r.cacc     = acc.caccacc
                              and r.ccur     = acc.cacccur
                              and r.i_catnum = 112
                              and r.i_grpnum = 67
                              and r.idsmr    = l_cidsmr                              
                          )
               --<<18.09.2019 �������� [19-62974] IV ����
               -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������               
                -->> 26.05.2015 ubrr korolkov 15-453
                -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������                
               -->>18.09.2019 �������� [19-62974] IV ����
                and not exists (select 1
                                  from ubrr_rko_acc_catgr r
                                 where r.cacc     = acc.cACCacc
                                   and r.ccur     = acc.cACCcur
                                   and r.i_catnum = 112
                                   and r.i_grpnum in (-->><<--23.01.2020 �������� [19-64846] ������ ���/�� https://redmine.lan.ubrr.ru/issues/70705#note-3
                                                      94,                 -- 24.09.2016 ubrr Ma������ �.�. 16-2653 ���: ���/�� 112/94 ��� ������ ����� "������-��������"
                                                      57,71,              -- 29.06.2015  �������� �.�.       [15-613] �� �������������-1
                                                      10)                 -- 19.10.2016 ubrr Ma������ �.�. 16-2790  ������ IB-Pro
                                   and r.idsmr    = l_cidsmr                                                  
                               )
               --<<18.09.2019 �������� [19-62974] IV ����
               -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������   
               -->>31.08.2020 ������� �.�.  [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� 
               and not exists (select 1 from UBRR_UNIQUE_TARIF_ACC uutc,
                                             UBRR_UNIQUE_ACC_COMMS uuac 
                                       where caccacc = uutc.cacc 
                                         and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF 
                                         and l_cidsmr = uutc.idsmr
                                         and uutc.status = 'N'
                                         and uutc.uuta_id = uuac.uuta_id
                                         and uuac.com_type = 'R_IB')
               --<<31.08.2020 ������� �.�.  [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��                                         
-->> 01.02.2019 ������� �.�.  [19-58770] ��������� ���� ������� ����������� �������
               -- ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������
               -->>18.09.2019 �������� [19-62974] IV ����
               and not exists (select 1
                                  from ubrr_rko_acc_catgr r
                                 where r.cacc     = acc.cACCacc
                                   and r.ccur     = acc.cACCcur
                                   and r.i_catnum = 114
                                   and r.i_grpnum = 16
                                   and r.idsmr    = l_cidsmr                                   
                              )
               --<<18.09.2019 �������� [19-62974] IV ����
               -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������
               -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
               and not exists ( select 1
                                  from ubrr_rko_acc_catgr   r
                                      ,ubrr_rko_exinc_catgr e 
                                 where r.i_catnum   = e.icat
                                   and r.i_grpnum   = e.igrp
                                   and e.ccom_type  = 'R_IB'
                                   and e.exinc      = 0
                                   and r.cacc       = acc.caccacc
                                   and r.ccur       = acc.cACCcur                                 
                                   -->>23.01.2020 �������� [19-64846]
                                   and (select trunc(max(au.d_create))
                                          from xxi.au_attach_obg au
                                         where au.caccacc = r.cacc
                                           and au.cacccur = r.ccur
                                           and au.i_table = 304
                                           and au.c_newdata = e.icat||'/'||e.igrp
                                           and trunc(au.d_create) <= r.d_date) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end)
                                   --<<23.01.2020 �������� [19-64846]
                              )              
               --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������                              
--<< 01.02.2019 ������� �.�.  [19-58770] ��������� ���� ������� ����������� �������
-- (���.) ����������� �. �. 18.02.2015 12-2313
                --and ubrr_xxi5.ubrr_rko.iseqrexistscatgrlist(ctrnaccd, ctrncur, d1, d2) is null
               and not exists (select 1
                 from sbs
                where csbsdo like 'R_EKV%'
                  and csbsacc = ctrnaccd)
-->>--11.03.2016 15-1221.1 ���: ��������� �� "������ +" (����) #25313 �������� �.�. ���.�����, ���-�� �������

              and not exists (select 1
                                from sbs
                               where csbsdo like 'R_Onl%'
                                 and csbsacc=ctrnaccd)
--<<--11.03.2016 15-1221.1 ���: ��������� �� "������ +" (����) #25313 �������� �.�. ���.�����, ���-�� �������
-- (���.) ����������� �. �. 18.02.2015 12-2313
            group by ctrnaccd,ctrncur,iACCotd, caccmail
)
group by acc,ctrncur,iaccotd, caccmail);
DBMS_TRANSACTION.COMMIT;
--<<--ubrr �������� �.�. 15-42 ���. �������� �� ������� ����� �����-Pro ��� ������
-->>--ubrr �������� �.�. 15-42 ���. �������� �� ������� ����� �����-Pro �� �������
  
  ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif := 'Y';          --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
  ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_day := 'N';      --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
  ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_id_check := 'N'; --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
  
  INSERT INTO SBS
   ( cSBSpayfrom_acc,cSBSacc, cSBScur, mSBStoll_sum, cSBSdo ,iSBSdebdoc,mSBSdebob,iSBScreddoc,mSBScredob)
   (select to_char(sysdate,'HH24:MI:SS'), acc,ctrncur,
           sum(sumcom), --31.08.2020 ������� �.�.  [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� 
          'R_IB',
          sum(cd),sum(md),sum(cc),sum(mc)
      from (
             select /*+ index( trn I_TRN_OLD_NEW_DAC )*/ -->><<--23.10.2019 �������� [19-62184] ������ I_TRN_ACCD_CUR_DTRN_TYPE �� I_TRN_OLD_NEW_DAC
                    ctrnaccd acc,ctrncur,count(1) c,iaccotd,count(1) cd,sum(mtrnsum) md,0 cc,0 mc,caccmail,ubrr_xxi5.UBRR_UNIQ_ACC_SUM(ctrnaccd,ctrncur,iaccotd,d1,'R_IB',sum(mtrnsum),0) sumcom --31.08.2020 ������� �.�.  [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� 
                   from acc,
                  /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn -->><<--23.10.2019 �������� [19-62184] ����������: ����������� �� PRO + �����. � ������ �� ���
             where
               -- ubrr katyuhin >>>
                   acc.caccacc LIKE acc_1
               and acc.cacccur = 'RUR'
               and acc.caccprizn <> '�'
               -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������               
               -->>18.09.2019 �������� [19-62974] IV ����
               and exists (select 1
                             from ubrr_rko_acc_catgr r
                            where r.cacc     = cTRNaccd
                              and r.ccur     = ctrncur
                              and r.i_catnum = 105
                              and r.i_grpnum = 2
                              and r.idsmr    = l_cidsmr                              
                          )
               --<<18.09.2019 �������� [19-62974] IV ����
               -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������               
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
               AND acc.caccacc NOT LIKE '40821________7%' -- 29/12/2011 ���������� �.�. �������� �� 40821 (�����������) �� ��� �� �������
               */--<< 26.05.2015 ubrr korolkov 15-453 #22215#note-3
               -- ubrr katyuhin <<<
               and trn.ctrnaccd = acc.cACCacc
               and trn.ctrncur = acc.cACCcur
               and dtrntran between d1 and d2+86399/86400
               -->>31.08.2020 ������� �.�.  [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� 
               and exists (select 1 from UBRR_UNIQUE_TARIF_ACC uutc,
                                         UBRR_UNIQUE_ACC_COMMS uuac 
                                   where caccacc = uutc.cacc 
                                     and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF
                                     and l_cidsmr = uutc.idsmr
                                     and uutc.status = 'N'
                                     and uutc.uuta_id = uuac.uuta_id
                                     and uuac.com_type = 'R_IB')           
                --<<31.08.2020 ������� �.�.  [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��         
                -->> 26.05.2015 ubrr korolkov 15-453
                -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������                
                -->>19.09.2019 �������� [19-62974] IV ����
                and not exists (select 1
                                  from ubrr_rko_acc_catgr r
                                 where r.cacc = acc.cACCacc
                                   and r.ccur = acc.cACCcur
                                   and r.i_catnum = 112
                                   and r.i_grpnum in (-->><<--23.01.2020 �������� [19-64846] ������ ���/�� https://redmine.lan.ubrr.ru/issues/70705#note-3
                                                      94,                 --24.09.2016 ubrr Ma������ �.�. 16-2653 ���: ���/�� 112/94 ��� ������ ����� "������-��������"
                                                      57,71,              --29.06.2015  �������� �.�.       [15-613] �� �������������-1
                                                      10)                 -- 19.10.2016 ubrr Ma������ �.�. 16-2790  ������ IB-Pro
                                   and r.idsmr    = l_cidsmr                                                  
                               )
                --<<19.09.2019 �������� [19-62974] IV ����
                -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������                
-->> 01.02.2019 ������� �.�.  [19-58770] ��������� ���� ������� ����������� �������
               -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������
               -->>19.09.2019 �������� [19-62974] IV ����
               and not exists (select 1
                                 from ubrr_rko_acc_catgr r
                                where r.cacc     = acc.cACCacc
                                  and r.ccur     = acc.cACCcur
                                  and r.i_catnum = 114
                                  and r.i_grpnum = 16
                                  and r.idsmr    = l_cidsmr                                    
                              )
               --<<19.09.2019 �������� [19-62974] IV ����
               -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������
               -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
               and not exists ( select 1
                                  from ubrr_rko_acc_catgr   r
                                      ,ubrr_rko_exinc_catgr e 
                                 where r.i_catnum   = e.icat
                                   and r.i_grpnum   = e.igrp
                                   and e.ccom_type  = 'R_IB'
                                   and e.exinc      = 0
                                   and r.cacc       = acc.caccacc
                                   and r.ccur       = acc.cACCcur                                 
                                   -->>23.01.2020 �������� [19-64846]
                                   and (select trunc(max(au.d_create))
                                          from xxi.au_attach_obg au
                                         where au.caccacc = r.cacc
                                           and au.cacccur = r.ccur
                                           and au.i_table = 304
                                           and au.c_newdata = e.icat||'/'||e.igrp
                                           and trunc(au.d_create) <= r.d_date) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end)
                                   --<<23.01.2020 �������� [19-64846]
                              )              
               --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������                              
--<< 01.02.2019 ������� �.�.  [19-58770] ��������� ���� ������� ����������� �������
             group by ctrnaccd,ctrncur,iACCotd,caccmail
 )
group by acc,ctrncur,iaccotd, caccmail);
DBMS_TRANSACTION.COMMIT;
  
  ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif := 'N';          --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
  ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif_id_check := 'Y'; --09.09.2020  ������� �.�.     [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� (��������� ������� ����� ��� �������������� �������)
  
--<<--ubrr �������� �.�. 15-42 ���. �������� �� ������� ����� �����-Pro �� �������

-->>--ubrr �������� �.�. 15-42 ���. �������� �� ������� ����� �����-Pro �������������
-->>07.10.2019 �������� [19-62974] IV ���� �� ��������������
/* INSERT INTO SBS
   ( cSBSpayfrom_acc,cSBSacc, cSBScur, mSBStoll_sum, cSBSdo ,iSBSdebdoc,mSBSdebob,iSBScreddoc,mSBScredob)
   (select to_char(sysdate,'HH24:MI:SS'), acc, ctrncur, \*400*\500, 'R_IB', sum(cd), sum(md), sum(cc), sum(mc) --- 19.01.2018 ������� �.�  ������������ �� 15.12.2017 � 7006-2358
      from (select ctrnaccd acc, ctrncur, count(1) c, iaccotd, count(1) cd, sum(mtrnsum) md , 0 cc, 0 mc, caccmail
              from xxi.V_TRN_PART_CURRENT trn, acc a
             where ctrnaccd like acc_1
               and cTRNcur = 'RUR'
               and dtrntran between d1 and d2+86399/86400
               and a.cACCacc = cTRNaccd
               and a.cACCcur = cTRNcur
               and a.cACCprizn <> '�'
               -->>19.09.2019 �������� [19-62974] IV ����
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
               --<<19.09.2019 �������� [19-62974] IV ����
               and trn.CTRNIDOPEN='IBANK2'
               and not exists (select 1
                               from sbs
                               where csbsdo = 'R_IB'
                               and csbsacc= a.caccacc)
-->>--11.03.2016 15-1221.1 ���: ��������� �� "������ +" (����) #25313 �������� �.�. ���.�����, ���-�� �������

              and not exists (select 1
                                from sbs
                               where csbsdo like 'R_Onl%'
                                 and csbsacc=a.caccacc)
               -->>19.09.2019 �������� [19-62974] IV ����
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
               --<<19.09.2019 �������� [19-62974] IV ����
-->> UBRR �������� �.�. 15-42 ���.����. https://redmine.lan.ubrr.ru/issues/19917#note-36
                -->> 26.05.2015 ubrr korolkov 15-453
                -->>19.09.2019 �������� [19-62974] IV ����
                \*and not exists (select 1
                                from gac
                                where cgacacc = a.cACCacc
                                and cgaccur = a.cACCcur
                                and igaccat = 112
                                and igacnum in (78,79,80,
                                99,100,101,102,103, --27.12.2018 �������� [15-43]
                                104,105,106, -- ������  �������  3, 6, 12  -- ubrr 31.05.2019 ������� �.�. [19-59153] ���. ����� �������� � ������ ����� "������-����� 3,6,12"
                                94,--24.09.2016 ubrr Ma������ �.�. 16-2653 ���: ���/�� 112/94 ��� ������ ����� "������-��������"
                                57,71,--29.06.2015  �������� �.�.       [15-613] �� �������������-1
                                10)-- 19.10.2016 ubrr Ma������ �.�. 16-2790  ������ IB-Pro
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
                --<<19.09.2019 �������� [19-62974] IV ����
-->> 01.02.2019 ������� �.�.  [19-58770] ��������� ���� ������� ����������� �������
               -->>19.09.2019 �������� [19-62974] IV ����
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
               --<<19.09.2019 �������� [19-62974] IV ����
--<< 01.02.2019 ������� �.�.  [19-58770] ��������� ���� ������� ����������� �������
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
               and not exists (select 1 from ubrr_unique_tarif where ctrnaccd =cacc and dtrncreate between DOPENTARIF and DCANCELTARIF and SYS_CONTEXT ('B21', 'IDSmr') = idsmr)           -->><<-- ubrr �������� �.�. #29736 ��������� �� ��� ��� ���
            group by ctrnaccd,ctrncur,iACCotd, caccmail)
group by acc,ctrncur,iaccotd, caccmail);
DBMS_TRANSACTION.COMMIT;*/
--<<07.10.2019 �������� [19-62974] IV ���� �� ��������������
--<<--ubrr �������� �.�. 15-42 ���. �������� �� ������� ����� �����-Pro �������������

-->>--ubrr �������� �.�. 15-42 ���. �������� �� ������� ����� �����-Pro ��������-100
 INSERT INTO SBS
   ( cSBSpayfrom_acc,cSBSacc, cSBScur, mSBStoll_sum, cSBSdo ,iSBSdebdoc,mSBSdebob,iSBScreddoc,mSBScredob)
   (select to_char(sysdate,'HH24:MI:SS'), acc, ctrncur,
         /*400*/500,--- 19.01.2018 ������� �.�  ������������ �� 15.12.2017 � 7006-2358
           'R_IB', sum(cd), sum(md), sum(cc), sum(mc)
      from (select ctrnaccd acc, ctrncur, count(1) c, iaccotd, count(1) cd, sum(mtrnsum) md , 0 cc, 0 mc, caccmail
              from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn, acc a -->><<--23.10.2019 �������� [19-62184] ����������: ����������� �� PRO + �����. � ������ �� ���
             where ctrnaccd like acc_1
               and cTRNcur = 'RUR'
               and dtrntran between d1 and d2+86399/86400
               and a.cACCacc = cTRNaccd
               and a.cACCcur = cTRNcur
               and a.cACCprizn <> '�'
               -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������               
               -->>19.09.2019 �������� [19-62974] IV ����
               and exists (select 1
                             from ubrr_rko_acc_catgr r
                            where r.cacc     = cTRNaccd
                              and r.ccur     = ctrncur
                              and r.i_catnum = 105
                              and r.i_grpnum = 2
                          )
               --<<19.09.2019 �������� [19-62974] IV ����
               -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������               
               and trn.CTRNIDOPEN='IBANK2'
               and not exists (select 1
                               from sbs
                               where csbsdo = 'R_IB'
                               and csbsacc= a.caccacc)
               -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������                               
               -->>19.09.2019 �������� [19-62974] IV ����
             and exists (select 1
                           from ubrr_rko_acc_catgr r
                          where r.cacc     = a.cACCacc
                            and r.ccur     = a.cACCcur
                            and r.i_catnum = 112
                            and r.i_grpnum = 45
                           and r.idsmr     = l_cidsmr                               
                        )
            --<<19.09.2019 �������� [19-62974] IV ����
            -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������            
            -->> 26.05.2015 ubrr korolkov 15-453
            -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������            
            -->>19.09.2019 �������� [19-62974] IV ����
            and not exists (select 1
                              from ubrr_rko_acc_catgr r
                             where r.cacc     = a.cACCacc
                               and r.ccur     = a.cACCcur
                               and r.i_catnum = 112
                               and r.i_grpnum in (-->><<--23.01.2020 �������� [19-64846] ������ ���/�� https://redmine.lan.ubrr.ru/issues/70705#note-3
                                                 94,                 -- 24.09.2016 ubrr Ma������ �.�. 16-2653 ���: ���/�� 112/94 ��� ������ ����� "������-��������"
                                                 57,71,              -- 29.06.2015  �������� �.�.       [15-613] �� �������������-1
                                                 10)                 -- 19.10.2016 ubrr Ma������ �.�. 16-2790  ������ IB-Pro
                               and r.idsmr    = l_cidsmr                               
                           )
            --<<19.09.2019 �������� [19-62974] IV ����
            -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������            
            --<< 26.05.2015 ubrr korolkov 15-453
-->> 01.02.2019 ������� �.�.  [19-58770] ��������� ���� ������� ����������� �������
               -->>19.09.2019 �������� [19-62974] IV ����
               -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������               
               and not exists (select 1
                                  from ubrr_rko_acc_catgr r
                                 where cacc       = a.cACCacc
                                   and ccur       = a.cACCcur
                                   and r.i_catnum = 114
                                   and r.i_grpnum = 16
                                   and r.idsmr    = l_cidsmr
                              )
               --<<19.09.2019 �������� [19-62974] IV ����
               -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������
               -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
               and not exists ( select 1
                                  from ubrr_rko_acc_catgr   r
                                      ,ubrr_rko_exinc_catgr e 
                                 where r.i_catnum   = e.icat
                                   and r.i_grpnum   = e.igrp
                                   and e.ccom_type  = 'R_IB'
                                   and e.exinc      = 0
                                   and r.cacc       = a.caccacc
                                   and r.ccur       = a.cACCcur                                 
                                   -->>23.01.2020 �������� [19-64846]
                                   and (select trunc(max(au.d_create))
                                          from xxi.au_attach_obg au
                                         where au.caccacc = r.cacc
                                           and au.cacccur = r.ccur
                                           and au.i_table = 304
                                           and au.c_newdata = e.icat||'/'||e.igrp
                                           and trunc(au.d_create) <= r.d_date) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end)
                                   --<<23.01.2020 �������� [19-64846]
                              )              
               --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������                              
--<< 01.02.2019 ������� �.�.  [19-58770] ��������� ���� ������� ����������� �������
---<<<UBRR Pashevich A. #12-508
               -->>31.08.2020 ������� �.�.  [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� 
               and not exists (select 1 from UBRR_UNIQUE_TARIF_ACC uutc,
                                             UBRR_UNIQUE_ACC_COMMS uuac 
                                       where ctrnaccd = uutc.cacc 
                                         and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF 
                                         and l_cidsmr = uutc.idsmr
                                         and uutc.status = 'N'
                                         and uutc.uuta_id = uuac.uuta_id
                                         and uuac.com_type = 'R_IB')
               --<<31.08.2020 ������� �.�.  [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��        
            group by ctrnaccd,ctrncur,iACCotd, caccmail)
group by acc,ctrncur,iaccotd, caccmail);
--<<--ubrr �������� �.�. 15-42 ���. �������� �� ������� ����� �����-Pro ��������-100


-->>--ubrr �������� �.�. 15-42 ���. �������� �� ������� ����� �����-Pro ������
 INSERT INTO SBS
   ( cSBSpayfrom_acc,cSBSacc, cSBScur, mSBStoll_sum, cSBSdo ,iSBSdebdoc,mSBSdebob,iSBScreddoc,mSBScredob)
   (select to_char(sysdate,'HH24:MI:SS'), acc,ctrncur,
           /*400*/500, --- 19.01.2018 ������� �.�  ������������ �� 15.12.2017 � 7006-2358
            'R_IB',--��� ���������� �� ��������
            sum(cd),sum(md),sum(cc),sum(mc)
       from (select ctrnaccd acc,ctrncur,count(1) c,iaccotd,count(1) cd,sum(mtrnsum) md ,0 cc,0 mc, caccmail
              from /*xxi.V_TRN_PART_CURRENT*/ ubrr_trn_old_new_v trn, acc a -->><<--23.10.2019 �������� [19-62184] ����������: ����������� �� PRO + �����. � ������ �� ���
             where ctrnaccd like acc_1
             and cTRNcur = 'RUR'
             -->> Ubrr ��karova L.U. ��������,������� ������ ���-���, ��� �������� ��������
             -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������             
             -->>19.09.2019 �������� [19-62974] IV ����
             and exists (select 1
                           from ubrr_rko_acc_catgr r
                          where r.cacc     = cTRNaccd
                            and r.ccur     = ctrncur
                            and r.i_catnum = 105
                            and r.i_grpnum = 2
                            and r.idsmr    = l_cidsmr
                        )
             --<<19.09.2019 �������� [19-62974] IV ����
             -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������             
             and trn.CTRNIDOPEN='IBANK2'
             and not exists (select 1
                             from sbs
                             where csbsdo = 'R_IB'
                             and csbsacc= a.caccacc)
             and dtrntran between d1 and d2+86399/86400
                 -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������             
                 -->>19.09.2019 �������� [19-62974] IV ����
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
                                   and r.i_grpnum in (-->><<--23.01.2020 �������� [19-64846] ������ ���/�� https://redmine.lan.ubrr.ru/issues/70705#note-3
                                                      94,                 --24.09.2016 ubrr Ma������ �.�. 16-2653 ���: ���/�� 112/94 ��� ������ ����� "������-��������"
                                                      57,71,              --29.06.2015  �������� �.�.       [15-613] �� �������������-1
                                                      10)                 -- 19.10.2016 ubrr Ma������ �.�. 16-2790  ������ IB-Pro
                                   and r.idsmr    = l_cidsmr                                                      
                               )
                 --<<19.09.2019 �������� [19-62974] IV ����
                 -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������                 
-->> 01.02.2019 ������� �.�.  [19-58770] ��������� ���� ������� ����������� �������
               -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������
               -->>19.09.2019 �������� [19-62974] IV ����
               and not exists (select 1
                                 from ubrr_rko_acc_catgr r
                                where r.cacc     = a.cACCacc
                                  and r.ccur     = a.cACCcur
                                  and r.i_catnum = 114
                                  and r.i_grpnum = 16
                                  and r.idsmr    = l_cidsmr
                              )
               --<<19.09.2019 �������� [19-62974] IV ����
               -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������
               -->>ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������
               and not exists ( select 1
                                  from ubrr_rko_acc_catgr   r
                                      ,ubrr_rko_exinc_catgr e 
                                 where r.i_catnum   = e.icat
                                   and r.i_grpnum   = e.igrp
                                   and e.ccom_type  = 'R_IB'
                                   and e.exinc      = 0
                                   and r.cacc       = a.caccacc
                                   and r.ccur       = a.cACCcur                                 
                                   -->>23.01.2020 �������� [19-64846]
                                   and (select trunc(max(au.d_create))
                                          from xxi.au_attach_obg au
                                         where au.caccacc = r.cacc
                                           and au.cacccur = r.ccur
                                           and au.i_table = 304
                                           and au.c_newdata = e.icat||'/'||e.igrp
                                           and trunc(au.d_create) <= r.d_date) between nvl(e.date_start, dg_date_start) and nvl(e.date_end, dg_date_end)
                                   --<<23.01.2020 �������� [19-64846]
                              )              
               --<<ubrr 13.12.2019  ������� �.�. [69650] ����� �������� ���� - �������� �� ����������                              
--<< 01.02.2019 ������� �.�.  [19-58770] ��������� ���� ������� ����������� �������
                and cACCacc = cTRNaccd
               and cACCcur = cTRNcur
               and cACCprizn <> '�'
---<<<UBRR Pashevich A. #12-508
               -->>31.08.2020 ������� �.�.  [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� 
               and not exists (select 1 from UBRR_UNIQUE_TARIF_ACC uutc,
                                             UBRR_UNIQUE_ACC_COMMS uuac 
                                       where ctrnaccd = uutc.cacc 
                                         and dtrncreate between uutc.DOPENTARIF and uutc.DCANCELTARIF 
                                         and l_cidsmr = uutc.idsmr
                                         and uutc.status = 'N'
                                         and uutc.uuta_id = uuac.uuta_id
                                         and uuac.com_type = 'R_IB')
               --<<31.08.2020 ������� �.�.  [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��         
             group by ctrnaccd,ctrncur,iACCotd, caccmail
                         )
group by acc,ctrncur,iaccotd, caccmail);
DBMS_TRANSACTION.COMMIT;
--<<--ubrr �������� �.�. 15-42 ���. �������� �� ������� ����� �����-Pro ������
---<<< Pashevich A. #12-508

-->>29.10.2018  �������� [18-592.2] ��� ������� �������� �� ���������
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

    WriteProtocol('������� �������� �� ���������. ������');

    for Cr IN (select icusnum, click_count, click_summa
                 from correqts.v_ubrr_kontur_counter@cts
                where click_month between d1 and d2 + 86399/86400)
    loop
        tAccList.delete;

        select *
        bulk collect into tAccList
        from acc a
        where a.IACCCUS=Cr.icusnum
          and a.caccprizn<>'�'
          and a.caccprizn='�'
          and a.caccacc like acc_1
          and a.cacccur = 'RUR'
          -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������          
          -->>19.09.2019 �������� [19-62974] IV ����
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
          --<<19.09.2019 �������� [19-62974] IV ����
          -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������          
        if nvl(tAccList.Count, 0) = 0 then
            select *
            bulk collect into tAccList
            from acc a
            where a.IACCCUS=Cr.icusnum
              and a.caccprizn<>'�'
              and a.caccprizn<>'�'
              and a.caccacc like acc_1
              and a.cacccur = 'RUR'
               -- ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������              
              -->>19.09.2019 �������� [19-62974] IV ����
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
              --<<19.09.2019 �������� [19-62974] IV ����
              -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������              
        end if;
        WriteProtocol('������ ' || Cr.icusnum || ' ���-�� ������ ' || nvl(tAccList.Count, 0));

        if nvl(tAccList.Count, 0) > 0 then
            iAccSel := NULL;
            nOstMax := -99e99;
            -- ������� �� ���������� ������� ������, � ������� �������, ����� �/� � ���������� �������� �� ���� �������
            for i IN tAccList.first .. tAccList.last loop
                WriteProtocol('���� ' || tAccList(i).caccacc || ' ������ '  || tAccList(i).idsmr);

                if tAccList(i).idsmr = iCurIdSmr
                then
                    UTIL_DM2.Acc_Ost2(0, tAccList(i).caccacc, tAccList(i).cacccur, dtran, ost_vr, ost_rr, ost_vp, deb_dark, cred_dark);
                    IF tAccList(i).caccap='�' THEN
                        ost_vr := -ost_vr;
                        ost_rr := -ost_rr;
                        ost_vp := -ost_vp;
                    END IF;
                    WriteProtocol('������� ' || ost_vr);
                    if ost_vr > nOstMax
                    then
                        nOstMax := ost_vr;
                        iAccSel := i;
                    end if;
                end if;
            end loop;

            if iAccSel is not null then
                WriteProtocol('������ ���� ' || tAccList(iAccSel).caccacc  || ' � ����. �������� ' || nOstMax || ' �� ' || to_char(dtran, 'dd.mm.rrrr') || ', � ���-�� ������: ' || Cr.click_count);

                INSERT INTO SBS ( cSBSpayfrom_acc, cSBSacc, cSBScur, mSBStoll_sum, cSBSdo ,iSBSdebdoc,mSBSdebob,iSBScreddoc,mSBScredob)
                    (select to_char(sysdate,'HH24:MI:SS'), tAccList(iAccSel).caccacc, tAccList(iAccSel).cacccur, Cr.click_summa, 'R_IB_LT', 0, 0, 0, 0
                       from acc a
                      where caccacc like tAccList(iAccSel).caccacc
                        and cacccur = 'RUR'
                        and cACCprizn <> '�'
                        and not exists (select 1
                                          from sbs
                                         where csbsdo = 'R_IB_LT'
                                           and csbsacc= a.caccacc)
                            -- >> ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������                                           
                            -->>19.09.2019 �������� [19-62974] IV ����
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
                            --<<19.09.2019 �������� [19-62974] IV ����
                            -- << ubrr 06.11.2019  ������� �.�.  [19-64491] ���������� (���.) ����� ��� ����.��������                            
                       );

                insert into ubrr_data.ubrr_sbs_ext (cSBSacc, cSBSdo, idsmr, icusnum, ccomment)
                     values (tAccList(iAccSel).caccacc, 'R_IB_LT', iCurIdSmr, Cr.icusnum, Cr.click_count);
            end if;
        else
            WriteProtocol('R_IB_LT �� ������ ���� ��� �������� �������� ������ � ' || Cr.icusnum);

            insert into SBS (cSBSpayfrom_acc, cSBSacc, cSBScur, mSBStoll_sum, cSBSdo, iSBSdebdoc, msbsdebob)
            values (to_char(sysdate, 'HH24:MI:SS'), '<�/� �� ������>', 'RUR', 0, 'R_IB_LT �� ������ ���� ��� �������� �������� ������ � ' || Cr.icusnum || ' ' ||  to_char(dtran, 'dd.mm.rrrr hh24:mi:ss'), 0, 0);

            insert into ubrr_data.ubrr_sbs_ext (cSBSdo, idsmr, icusnum) values ('R_IB_LT', iCurIdSmr, Cr.icusnum);
        end if;
    end loop;
    WriteProtocol('������� �������� �� ���������. �����');

    tAccList.delete;

    dbms_transaction.commit;
end;
--<<29.10.2018  �������� [18-592.2] ��� ������� �������� �� ���������

    --�����??
    -- UBRR Pashevich A. 12-101
Begin
 ubrr_rko.SBSchangeacc('',1);
 dbms_transaction.commit;
end;
-- UBRR Pashevich A. 12-101
-- 06.04.2015 ubrr �������� �.�. 15-42 ���. �������� �� ������� ����� �����-Pro Online--
-- ������� ������ ����� ������ � ���� �� �������, ��������� ����
    DECLARE
        CURSOR Cr IS
            SELECT * FROM sbs WHERE csbsdo in ('R_IB', 'R_IB_LT');  -->><<--07.11.2018  �������� [18-592.2] ��� ������� �������� �� ���������
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
                 WHERE csbsdo in ('R_IB', 'R_IB_LT') -->><<--07.11.2018  �������� [18-592.2] ��� ������� �������� �� ���������
                       AND csbsacc IN
                       (SELECT caccacc
                              FROM acc
                             WHERE caccprizn <> '�'
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
