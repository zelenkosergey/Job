CREATE OR REPLACE PACKAGE UBRR_XXI5.ubrr_sap_cd
IS
/******************************* HISTORY UBRR *************************************** * *\
����        �����            ID        ��������
----------  ---------------  --------- ---------------------------------------
08.09.2015   ����� �.�.      [15-997]  #24595 SAP R/3: ��������� ���� E7P, EEP
                                       Send_SMS,AddPart, Clear_SchedPayPrcForAdvance, Add_SchedPayPrc
                                       CreateNewMaturity,Add_SchedLim,Change_AGRSIGNDATE,Change_CrInfo
                                       Change_BKI_REQUEST, Change_LIMIT_EXPIRE_DATE,Change_SMS_AGR
                                       CreateNewZalog, CHANGE_CURATORID
----------  ---------------  --------- ---------------------------------------
10.12.2015  ����� �.�.       [#26420]  ��������� ��������� �������� �������� � ������� cdh
----------  ---------------  --------- ---------------------------------------
28.05.2016  �������� �.�.    [#30540]  ��������� ������� ��� ��������� ���������
----------  ---------------  --------- ---------------------------------------
30.05.2016  ubrr korolkov    [16-1808] 16-1808.2.3.2.4.5 Generate_Annuitet
----------  ---------------  --------- ---------------------------------------
19.07.2016  ubrr korolkov    [16-1808] 16-1808.2.3.2.4.5 Generate_Annuitet, �������� p_tp_correct
----------  ---------------  --------- ---------------------------------------
07.2017     ������� �.�.         [15-1115.1] ������������� �������-��������, ��������� GetBPLimSCG
----------  ---------------  --------- ---------------------------------------
08.10.2018  ������� �.�. #56138 [18-494] ������ ���� 8769
----------  ---------------  --------- ---------------------------------------
08.07.2020  ������ �.�.      [19-59018] ���������� ��� : ���������� �������� ���- E-Mail-����������� ����� � ���
22.03.2021  ������� �.�.     DKBPA-105 ���� 4.1 (���������� ���): ������ ������������. ��� ��� �������� �� �������� �����
\******************************* HISTORY UBRR *****************************************/

  function SetSAPCDContext(cpIDSMR in VARCHAR2 default null) return varchar2;

  -- Abramov A.V. Edition two
  procedure CreateAgr(
    cpNumDog         in     varchar2   -- ���������� ����� ��������
   ,dpSignDate       in     varchar2   -- ���� ���������� ��������
   ,dpStartDate      in     varchar2   -- ���� ��������
   ,dpEndDate        in     varchar2   -- ���� ��������� ��������
   --,dpSignDate       in     date       -- ���� ���������� ��������
   --,dpStartDate      in     date       -- ���� ��������
   --,dpEndDate        in     date       -- ���� ��������� ��������
   ,ipGroup          in     number     -- ����� ������
   ,ipClientNum      in     number     -- ����� �������
   ,cClientName      in     varchar2   -- ������������ �������
   ,�pCur            in     varchar2   -- ������ ��������
   ,mpSum            in     number     -- ����� ��������
   ,ppIntRate        in     number     -- ���������� ������
   ,ppPenyRate       in     number     -- ���� �� ��������
   ,ppPenyType       in     number     -- ��� ����� �� �������� (������� 0, ������� 1)
   ,ppPenyRate2      in     number     -- ���� �� ��������
   ,ppPenyType2      in     number     -- ��� ����� �� �������� (������� 0, ������� 1)
   ,ipPrtf           in     varchar2   -- ��������
   ,cBranch          in     varchar2   -- ���������
   ---->>>>>>Lobik D.A. ubrr 27.12.2005
   ,iLineType        in     number
   ,dpFirstTransDate in     varchar2   -- ���� ������ ������
   --,dFirstTransDate  in     date       -- ���� ������ ������
   ,n_PERCTERMID     in     number     --id ����� ������ %%
   ,mFirstTransSum   in     number     -- ����� ������ ������
   ,iloan_aim        in     number     -- ��� ��� ������� �� ����. CAU
   ,iTurnType        in     number     -- ��� ������� (3 - X-�������, 5 - � ������� ����, 0 - � ����������� ����)
   ,iTurnover        in     number     -- ��������������� �������
   ----<<<<<---Lobik D.A. ubrr 27.12.2005
   ---->>>>>>Lobik D.A. ubrr 14.03.2006
   ,�Acc             in     varchar2   -- ������� ����
   ,�BIC             in     varchar2   -- ��� �����
     ----->>>>>>>>>>>>>>Lobik D.A. ubrr 04.07.2006
   ,is_IN_BKI     in       varchar2   -- �������� �� ������ � ��� (Y-�� N-���)  UBRR Portnyagin D.Y. 19.09.2011
   ,dp_IN_BKI     in       varchar2   -- ���� �������� �� ������ � ��� UBRR Portnyagin D.Y. 19.09.2011
   ,iCR_OUT          in     number     --�������� �������� � ���
   ,dpCR_OUT         in     varchar2   --���� ��������
   --,dCR_OUT          in     date       --���� ��������
   ,cCR_ID           in     varchar2   --��� �������� ��������� �������
     -----<<<<<<<<<<<<Lobik D.A. ubrr 04.07.2006
   ----<<<<<<<Lobik D.A. ubrr 14.03.2006
   -- >>> ����� �.�. 01.11.2011 (11-859)
   ,cpSMS_AGR     in       varchar2   -- �������� �� SMS-��������������
   ,cpSMS_INF     in       varchar2   -- ������� ��� SMS-��������������
   ,cpEMAIL_AGR   in       varchar2   -- �������� �� E-Mail-��������������
   ,cpEMAIL_INF   in       varchar2   -- ����� ��.����� ��� E-Mail-��������������
   -- <<< ����� �.�. 01.11.2011 (11-859)
   -- >>> ����� �.�. 25.09.2014 #16715 [14-528.4]
   ,cpUBRRMAIL    in       varchar2   -- ����� ��.����� �� ������� ����� ��� ���������
   -- <<< ����� �.�. 25.09.2014 #16715 [14-528.4]
   ,iXOverDays       in     number     --��� X-����--->>><<<�����-�������� 24.01.2007
   ,noutAgrid        in out number    -- �������� ����� ��������
   ,cpPunktBASp      in     varchar2   -- (ubrr) Samokaev R.V. --- 13.02.2008 --
   ,cpGrpObsp        in     varchar2   -- (ubrr) Samokaev R.V. --- 13.02.2008 --
   ,cnIsTransh       in     number     -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   ,cpABS            in     varchar2   -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   ,p_ret_day        IN     NUMBER     -- ���� ������� 01-31 ��������� �.�. 19.12.2012
   ,cpRepayment      in     varchar2 default null  -- ������� ������� ������������� 14-528 ����� �.�. 30.06.2014
   ,p_PERCCODE8769   in     NUMBER     -- ������� � ���� 8769 - 08.10.2018 ������� �.�. #56138 [18-494] ������ ���� 8769
   ,cpStatus         out    varchar2   -- ������
   ,cpErrorMsg       out    varchar2   -- ��������� �� ������
                                   );

  procedure AddPart(
    npAgrid      in       number   -- �������� ����� ��������
   ,dpEndDate    in       varchar2 -- ���� ��������
   --,dpEndDate    in       date     -- ���� ��������
   ,ipPart       in       number   -- ����� �����
   ,mpSum        in       number   -- ����� �����
   ,cpABS        in       varchar2 -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
   --,cpErrorMsg   in out   varchar2 -- ��������� �� ������
   ,cpErrorMsg  out       varchar2 -- ��������� �� ������
   --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                                  );

  procedure CreateNewZalog(
    npAgrid      in       number   -- �������� ����� ��������
   ,dpDate       in       varchar2 -- ����
   ,DpDsnDate    in       varchar2 -- ���� �������
   ,iwarrantor   IN       varchar2 --
   ,ipType       in       number   -- ��� ����������� �� ������� czv
   ,ipSubType    in       number   -- ������ ����������� �� ������� czw
   ,ipQuality    in       varchar2 --number   -- ��������� �������� ����������� (������, 1, 2)
   ,�pCur        in       varchar2 -- ������
   ,mpSum        in       number   -- ����� �����
   ,mpQSum       in       number   -- ����� ����� ����� ��������
   ,mpMrktSum    in       number   -- �������� ���������
   ,cNAME        in       varchar2 --------warrantor attributes
   ,cNAMEFULL    in       varchar2
   ,cINN         in       varchar2
   ,cKPP         in       varchar2
   ,cOKVED       in       varchar2
   ,cOKPO        in       varchar2
   ,cOGRN        in       varchar2
   ,cADDR        in       varchar2
   ,cADDR2       in       varchar2
   ,cPERSON      in       varchar2
   ,cPASPTYPE    in       varchar2
   ,cPASPNUM     in       varchar2
   ,cPASPSER     in       varchar2
   ,cPASPPLACE   in       varchar2
   ,dPASPDATE    in       varchar2
   ,cpComment    in       varchar2 -- ���������� � �����������
   ,cpPersname   in       varchar2 --
--> ���� �.�. �������� �� �����������
   ,cpAgrNum     in       varchar2
   ,dpAgrDate    in       varchar2
   ,cpAgrAdrr    in       varchar2
--< ���� �.�. �������� �� �����������
   ,cpABS        in       varchar2 -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
   --,cpErrorMsg   in out   varchar2 -- ��������� �� ������
   ,cpErrorMsg  out       varchar2 -- ��������� �� ������
   --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                                  );
  ---->>>>>>Lobik D.A. ubrr 28.12.2005
  procedure CreateNewMaturity(
    npAgrid      in       number   -- �������� ����� ��������
   ,mpSum        in       number   -- ����� ��������
   ,dpDate       in       varchar2 -- ���� ��������
   -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
   --,cpErrorMsg   in out   varchar2 -- ��������� �� ������
   ,cpErrorMsg  out       varchar2 -- ��������� �� ������
   --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                                  );
  function sap_2_char(ss in varchar2,ii in number)return varchar2;
  ----<<<<<Lobik D.A. ubrr 28.12.2005

  PROCEDURE CreatePart(
   npAgrid          in       number   -- ����� ��������
  ,dpDelivery       in       varchar2 -- ���� ������
  ,ppIntRate        in       number   -- ���������� ������
  ,npSumPart_30d    in       number   -- ����� ����� (�� 30 ����)
  ,npSumPart_90d    in       number   -- ����� ����� (�� 31 �� 90 ����)
  ,npSumPart_180d   in       number   -- ����� ����� (�� 91 �� 180 ����)
  ,npSumPart_1y     in       number   -- ����� ����� (�� 181 ��� �� 1 ����)
  ,npSumPart_3y     in       number   -- ����� ����� (�� 1 ���� �� 3 ���)
  ,npSumPart_ovr3y  in       number   -- ����� ����� (����� 3 ���)
  ,cpABS            in       varchar2 -- (ubrr) Samokaev R.V. --- 22.12.2007 --
  ,npStrNumPart     out      number   -- ����� ��������� �����
  ,npFinNumPart     out      number   -- ����� ��������� �����
  ,cpErrorMsg       out      varchar2 -- ��������� �� ������
                       );

  procedure Add_SchedPayPrc(
    npAgrid      in       number   -- �������� ����� ��������
   ,dpDateClc    in       varchar2 -- ���� ���������� %
   ,dpDatePay    in       varchar2 -- ���� ������ %
   -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
   --,cpErrorMsg   in out   varchar2 -- ��������� �� ������
   ,cpErrorMsg  out       varchar2 -- ��������� �� ������
   --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                       );

  PROCEDURE calc_interval(npAgrid      in     number
                         ,dpFirstNach  in     date
                         ,dpFirstPay   in     date
                         ,spErrMessage in out varchar2);


  procedure Change_CuratorID (npAgrid      in       number,     -- �������� ����� ��������)
                              npCuratorID  in       number,     -- ID ��������
                              -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                              --cpErrorMsg   in out   varchar2 -- ��������� �� ������
                              cpErrorMsg  out       varchar2 -- ��������� �� ������
                              --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                              );

  PROCEDURE Change_CrInfo (ipAgrId in       number,
                           ipCrOut in       number,
                           dpCrOut in       varchar2,
                           --dpCrOut in date,
                           cpBKIId in       varchar2,
                           cpAbs   in       varchar2,
                           -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                           --,cpErrMsg   in out   varchar2 -- ��������� �� ������
                           cpErrMsg  out       varchar2 -- ��������� �� ������
                           --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                           );

  --->>>ubrr ���������� �.�. 2010/03/23 10-301 (����� �.�.)
  ----------------------------------------------------------------------------------------------
  -- ������� ����������� ����. ������ �������� �� ���� (��������� ����������� � ���������� ������ ������������ �����������)
  -- c_IsCorrect = NULL , ���� ����. ����� ��������� ����������
  -- c_IsCorrect = 'X'  , ���� ��� ����������� � ������������ ������� �������

   PROCEDURE Get_AgrID (i_agr       in  NUMBER
                       ,onDate      in  DATE
                       ,i_is_line   in  NUMBER
                       ,n_agrnum    OUT xxi.cda.ncdaagrid%TYPE
                       ,c_IsCorrect OUT char);
  ---<<<ubrr ���������� �.�. 2010/03/23 10-301 (����� �.�.)

  --->>>ubrr �������� �.�. 2010/12/06 10-876
  /* ��� ������ ������� ������ � �������� ������ % �������
     ����� ���������� ������ ����������/������ % ������� � ���� ���������� ��������
     �� ���� ���������� %, ������� <= ������� ������ % �������
  */
   procedure Clear_SchedPayPrcForAdvance(npAgrid                 in     number
                                        ,dSAPDayOfPay            in     varchar2
                                        ,dSAPDayOfPrc            in     varchar2
                                         --��������� ���� ������ ������ ������ %
                                        -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                                        --,cpErrorMsg   in out   varchar2 -- ��������� �� ������
                                        ,cpErrorMsg  out       varchar2 -- ��������� �� ������
                                        --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                                        );
  ---<<<ubrr �������� �.�. 2010/12/06 10-876

  --->>>ubrr �������� �.�. 2011/01/24 11-206.2
  /* �������� ������ � ������� ��������� ������
     (���� ���� 00000000 - ��������� ��� ������ � �������,
      ���� ���� �������� - ����������� ����� ������)
  */
    procedure Add_SchedLim(
       npAgrid      in       number   -- �������� ����� ��������
      ,dpDateLim    in       varchar2 -- ���� ������ ������� ��������� ������
      ,npAmountLim  in       number   -- �������� ������ � ����
      -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
      --,cpErrorMsg   in out   varchar2 -- ��������� �� ������
      ,cpErrorMsg  out       varchar2 -- ��������� �� ������
      --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                       );
  ---<<<ubrr �������� �.�. 2011/01/24 11-206.2

-- ������� �������� �������� �� ������ � ���
 PROCEDURE Change_BKI_REQUEST ( ipAgrId   in number,
                                is_IN_BKI in varchar2,
                                dpCrIn    in varchar2,
                                cpABS     in varchar2,
                                -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                                --cpErrMsg   in out   varchar2 -- ��������� �� ������
                                cpErrMsg  out       varchar2 -- ��������� �� ������
                                --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
       );
--    ��������� �������� SMS
 PROCEDURE Send_SMS
                (
                 cpSMS_Phone IN     varchar2                 --����� �������� ���������� (��������,79226093222)
                ,cpSMS_Body  IN     varchar2                 --����� ��������� �� 1000 ��������
                -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                --,cpErrorMsg  IN OUT varchar2                 -- ��������� �� ������
                --,cpSMS_Time  IN OUT varchar2                 -- ����� �������� ���������
                ,cpErrorMsg OUT varchar2                 -- ��������� �� ������
                ,cpSMS_Time OUT varchar2                 -- ����� �������� ���������
                --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                -->> 08.07.2020 ������ �.� [19-59018] ���������� �������� ���- E-Mail-����������� ����� � ���
                ,npVuz       IN     number default 0
                --<< 08.07.2020 ������ �.� [19-59018] ���������� �������� ���- E-Mail-����������� ����� � ���
                );
-- �������� ����� ����� ������� �������������
 PROCEDURE SEND_MAIL
     (
       Adres        IN      VARCHAR2  -- ����� ���������� ��������� 50
      ,Subject      IN      VARCHAR2  -- ���� ��������� 50
      ,Message      IN      VARCHAR2  -- ���������  2000
      ,cpErrorMsg   IN OUT  varchar2  -- ��������� �� ������
      ,cpEMAIL_Time IN OUT  varchar2  -- ����� �������� ���������
      -->> 08.07.2020 ������ �.� [19-59018] ���������� �������� ���- E-Mail-����������� ����� � ���
      ,npVuz       IN     number default 0
      --<< 08.07.2020 ������ �.� [19-59018] ���������� �������� ���- E-Mail-����������� ����� � ���
      );
-- �������� �������� �� ��������������, �������, e-mail
 PROCEDURE Change_SMS_Agr (ipAgrId     in      number,
                           dpSMS_AGR   in      varchar2,
                           cpSMS_AGR   in      varchar2,
                           cpSMS_INF   in      varchar2,
                           cpEMAIL_AGR in      varchar2,
                           cpEMAIL_INF in      varchar2,
                           -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                           --cpErrMsg   in out   varchar2 -- ��������� �� ������
                           cpErrMsg  out       varchar2 -- ��������� �� ������
                           --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                           );
  --->>>ubrr �������� �.�. 2011/11/15 11-484
  /* ���������� �������� "������������� ������������� ��" ��� �������  */
   procedure Add_Atr_Cus_From_Sap(
       npCus        in       number   -- ����� �������
      ,npIDAtr      in       number   -- ID ��������
      ,�pAtrVal     in       varchar2 -- �������� ��������
      ,dpAtrDate    in       varchar2 -- ���� ������ �������� ��������
      ,cpResult     out      varchar2 -- ��������� �� ������
                                  );
  /* ���������� �������� "�������� ��" ��� ��. ��������  */
   procedure Add_Atr_Gr_From_Sap(
       npAgr        in       number   -- ����� ��. ��������
      ,npIDAtr      in       number   -- ID ��������
      ,�pAtrVal     in       varchar2 -- �������� ��������
      ,cpResult     out      varchar2 -- ��������� �� ������
                                  );
  ---<<<ubrr �������� �.�. 2011/11/15 11-484
  --->>>ubrr �������� �.�. 2013/03/06 12-965
 /* ���� ������������ ���������� �������� */
 PROCEDURE Change_AGRSIGNDATE ( ipAgrId   in number,
                                dpSignDate    in varchar2,
                                cpABS     in varchar2,
                                -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                                --cpErrMsg   in out   varchar2 -- ��������� �� ������
                                cpErrMsg  out       varchar2 -- ��������� �� ������
                                --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
       );
  ---<<<ubrr �������� �.�. 2013/03/06 12-965

--->>>ubrr ����� �.�. 2013/05/07 12-1166
-- ���� ������ ������
 PROCEDURE Change_LIMIT_EXPIRE_DATE ( ipAgrId           in      number,
                                      dpConditionDate   in      varchar2,
                                      dpLimitExpireDate in      varchar2,
                                      cpABS             in      varchar2,
                                      -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                                      --cpErrMsg   in out   varchar2 -- ��������� �� ������
                                      cpErrMsg  out       varchar2 -- ��������� �� ������
                                      --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
       );
---<<<ubrr ����� �.�. 2013/05/07 12-1166

-- >>> ����� �.�. 25.09.2014 #16715 [14-528.4]
-- ����� � ������ E-mail �� ������� ����� ��� ��������� � �������������
 PROCEDURE Get_UBRR_Email_Address   ( ipCusNum          in      number,
                                      cpSAPLogin        in      varchar2,
                                      cpEmailAddress    in out  varchar2,
                                      cpEmailPassword   in out  varchar2,
                                      cpErrMsg          in out  varchar2
       );
-- <<< ����� �.�. 25.09.2014 #16715 [14-528.4]

-- >>> ����� �.�. 26.05.2015 #22087 [15-199]
-- �������� ��� � ��������� ��������
 PROCEDURE Change_PSK ( ipAgrId      in      number,
                        dpDate       in      varchar2,
                        npPSK        in      number,
                        cpInsertOnly in      varchar2,
                        cpErrMsg     in out  varchar2
       );

 FUNCTION Calc_PSK( ipAgrId      in      number ) return number;
-- <<< ����� �.�. 26.05.2015 #22087 [15-199]
-->> ����� �.�. 10.12.2015 #26420 [15-692.1
 PROCEDURE UpdateCDH (ipAgrid  in  number,
                      ipPart   in  number,
                      cpTerm   in  varchar2,
                      cpDate   in  varchar2,
                      cpParam  in  varchar2,
                      cpValue  in  varchar2,
                      cpErrMsg out varchar2
                     );
--<< ����� �.�. 10.12.2015 #26420 [15-692.1

-->> 30.05.2016 ubrr korolkov 16-1808.2.3.2.4.5
procedure Generate_Annuitet(p_cMsg          out varchar2,
                            p_id            in  varchar2,   -- ������������� �������
                            p_StartDate     in  varchar2,   -- ���� ������ ������
                            p_EndDate       in  varchar2,       -- ���� ��������� ������ (��������)
                            p_StartSum      in  number,     -- ����� �������
                            p_Prc           in  number,     -- ���������� ������
                            p_sum_repay     in  number,     -- ����� ���������
                            p_dt            in  varchar2,   -- ���� ������� ��������
                            p_interv        in  number default 0, -- ������
                                                                  --  0 - ���
                                                                  --  1 - �������
                                                                  --  2 - �������
                                                                  --  3 - ���
                            p_fl            in  number default 1, -- ��� ����������� ������
                                                                  --  0 - �� ��� ������ ���� dFirstPay (��� ���������� > ���)
                                                                  --  1 - �� ���������� ��� ���������
                                                                  --  2 - �� ������ ���������� ���� dFirstPay �� ������
                                                                  --  3 - ����� ��������� ���������� ������� ���� �� ������ ���������
                            p_tp_correct    in  NUMBER default 1, -- ��������� ��� ����� �������� ����
                                                                  -- 1 �������� �������� ����������
                            p_only_working_days in number default null, -- ��������� �������� (0 - ���, 1 - ���������)
                            p_AB            in  number default null,  --  0 - � ��������� �����
                                                                      -- -1 - � ��������� �����
                            p_dt2           in  number default null);

procedure CreatePrcSchedule(p_ErrMsg    out varchar2,
                            p_AgrId      in  number);
--<< 30.05.2016 ubrr korolkov 16-1808.2.3.2.4.5
-->> ������� 07.2017 #44404: [15-1115.1] ������������� �������-��������
PROCEDURE GetBPLimSCG ( p_npCus     in      number,
                        p_dpZc      in      varchar2,
                        p_cpDemp    in      number,
                        p_SumLimit  out     number
                     );
--<< ������� 07.2017 #44404: [15-1115.1] ������������� �������-��������

-->>22.03.2021  ������� �.�.     DKBPA-105 ���� 4.1 (���������� ���): ������ ������������. ��� ��� �������� �� �������� �����
-------------------------------------------------------------------------------
-- ��������� ��������� ������� ����������
-------------------------------------------------------------------------------
PROCEDURE ZIU_Calc_Interval(p_Agrid           in     number,
                            p_StartDate       in     date,
                            p_FinishDate      in     date,
                            p_PerctermID      in     number,
                            p_ErrMessage      in out varchar2
                            );

-------------------------------------------------------------------------------
-- ��������� ���������� ������ � ������� ��� ��������� ������� �������
-------------------------------------------------------------------------------
PROCEDURE ZIU_Repayment_Schedule( p_AgrId            in number,      -- ��� ���������� ��������
                                  p_ChangeDate       in varchar2,    -- ���� �������� �������� (���� �)
                                  p_PayAmount        in number,      -- �����
                                  p_PayDate          in varchar2,    -- ����
                                  p_Status           out varchar2,   -- ������
                                  p_ErrorMsg         out varchar2    -- ��������� �� ������
                                );

-------------------------------------------------------------------------------
-- ��������� ���������� ������ � ������� ��� ��������� ������� ��������� ������
-------------------------------------------------------------------------------
PROCEDURE ZIU_Limit_Change_Schedule( p_AgrId            in number,      -- ��� ���������� ��������
                                     p_ChangeDate       in varchar2,    -- ���� �������� �������� (���� �)
                                     p_LimAmount        in number,      -- �����
                                     p_LimDate          in varchar2,    -- ����
                                     p_Status           out varchar2,   -- ������
                                     p_ErrorMsg         out varchar2    -- ��������� �� ������
                                   );

-------------------------------------------------------------------------------
-- ��������� ���������� ������ � ������� ��� �������� �����������
-------------------------------------------------------------------------------
PROCEDURE ZIU_Change_Zalog( p_AgrId            in number,      -- ��� ���������� ��������
                            p_ChangeDate       in varchar2,    -- ���� �������� �������� (���� �)
                            p_Atribut          in varchar2,    -- ����� ��������� ������
                            p_Amount           in number,      -- �����
                            p_Status           out varchar2,   -- ������
                            p_ErrorMsg         out varchar2    -- ��������� �� ������
                          );

-------------------------------------------------------------------------------
-- ��������� �������������� ��������� ������
-------------------------------------------------------------------------------
PROCEDURE ZIU_Settlement_Zalog( p_AgrId            in number,      -- ��� ���������� ��������
                                p_ABS              in varchar2,    -- ������
                                p_ChangeDate       in varchar2,    -- ���� �������� �������� (���� �)
                                p_Status           out varchar2,   -- ������
                                p_ErrorMsg         out varchar2    -- ��������� �� ������
                               );

-------------------------------------------------------------------------------
-- ��������� ��������� ��. ��� ��� �������� �� �������� ����� (��������)
-------------------------------------------------------------------------------
PROCEDURE ZIU_Change_Agr( p_AgrId            in number,      -- ��� ���������� ��������
                          p_ABS              in varchar2,    -- ������
                          p_ChangeDate       in varchar2,    -- ���� �������� �������� (���� �)
                          p_UpdRate          in varchar2,    -- ������� ��������� (���������� ������)
                          p_Rate             in number,      -- ���������� ������
                          p_UpdPenyRate      in varchar2,    -- ������� ��������� (���� �� ��)
                          p_PenyRate         in number,      -- ���� �� ��
                          p_UpdPenyType      in varchar2,    -- ������� ��������� (��� ����� �� ��)
                          p_PenyType         in number,      -- ��� ����� �� �� (������� 0, ������� 1)
                          p_UpdPenyRate2     in varchar2,    -- ������� ��������� (���� �� ��������)
                          p_PenyRate2        in number,      -- ���� �� ��������
                          p_UpdPeny2Type     in varchar2,    -- ������� ��������� (��� ����� �� �������)
                          p_PenyType2        in number,      -- ��� ����� �� �������� (������� 0, ������� 1)
                          p_UpdAmount2       in varchar2,    -- ������� ��������� (����� ������)
                          p_Amount2          in number,      -- ����� ������
                          p_CURR2            in varchar2,    -- ������ ������ (��� �������� � ������� ������� ���������� ��������)
                          p_UpdEndDate       in varchar2,    -- ������� ��������� (���� ��������� ��������)
                          p_EndDate_Old      in varchar2,    -- ���� ��������� �������� (������ ����)
                          p_EndDate_New      in varchar2,    -- ���� ��������� �������� (����� ����)
                          p_PerctermID       in number,      -- id ����� ������ %%
                          p_UpdBicAcc        in varchar2,    -- ������� ��������� (����������)
                          p_caccacc          in varchar2,    -- ������� ����
                          p_BIC              in varchar2,    -- ��� �����
                          p_UpdRepaySch      in varchar2,    -- ������� ��������� (������ �������)
                          p_UpdLimitSch      in varchar2,    -- ������� ��������� (������ ��������� ������)
                          p_CrdType2         in number,      -- ��� ��
                          p_UpdZalog         in varchar2,    -- ������� ��������� (��������� ��������� �����������/ ����������� ����������� ����� 0 )
                          p_Status           out varchar2,   -- ������
                          p_ErrorMsg         out varchar2    -- ��������� �� ������
                         );
--<<22.03.2021  ������� �.�.     DKBPA-105 ���� 4.1 (���������� ���): ������ ������������. ��� ��� �������� �� �������� �����

END;
/
CREATE OR REPLACE PACKAGE BODY UBRR_XXI5.ubrr_sap_cd
IS
/******************************* HISTORY UBRR *****************************************\
����        �����            ID        ��������
----------  ---------------  --------- ---------------------------------------
17.05.2012  �������� �.�.    [XXXXXX]  � ��������� �������� ������� �� SAP WF
                                       ���������������� �� �������� � ������ ���� ���
                                       (����� ������ ����� 12-654)
                                       "������ �������-�������� ������-��� ���.����� (�� <���������> ���������� � ���)"
----------  ---------------  --------- ---------------------------------------
06.02.2012  ����� �.�.       [XXXXXX]  ��� �������� �������� ��������� ������ �������
                                       ��������� � ���������
                                            CreateNewZalog
                                       (����� ����� 12-345)
                                       "��������� ������ �� ����������� (� ������ SAP R3-WF)"
----------  ---------------  --------- ---------------------------------------
22.10.2010  ����� �.�.       [XXXXXX]  ��� ����������� ������ �� ����� �������� ��������� �� ORACLE SAP,
                                       � �������� �� ABAP ����������� Native-SQL:
                                       1. ������� ��������� � ���������:
                                            CreateAgr
                                            AddPart
                                            CreateNewZalog
                                            CreateNewMaturity
                                            CreatePart
                                            Add_SchedPayPrc
                                       2. �������
                                            Change_CrInfo
                                       ���������� � ��������� � ����� �������� ����������
                                       (����� ����� 10-693)
----------  ---------------  --------- ---------------------------------------
06.12.2010  �������� �.�.    [XXXXXX]  ��� ������ ������� ������ � �������� ������ %
                                       ������� ����� ���������� ������
                                       ����������/������ % ������� � ���� ����������
                                       �������� �� ���� ���������� %, ������� <=
                                       ������� ������ % �������
                                       (����� ����� 10-876)
----------  ---------------  --------- ---------------------------------------
21.01.2011  ����� �.�.       [XXXXXX]  ��� �������� ������ ������ ��� �������� ���
                                       ������� ��������� � ���������
                                            CreateAgr
                                       (����� ����� 11-261)
                                       "�������������� ���������� ������ ���������
                                        ���������"
----------  ---------------  --------- ---------------------------------------
24.01.2011  �������� �.�.    [XXXXXX]  �������� ������ � ������� ��������� ������
                                       (���� ���� 00000000 - ��������� ��� ������
                                        � �������,
                                        ���� ���� �������� - ����������� �����
                                        ������)
                                       (����� ����� 11-206.2)
----------  ---------------  --------- ---------------------------------------
01.11.2011  ����� �.�.       [XXXXXX]  �������� �������� �������� SMS � E-mail
                                       (����� ����� 11-859)
----------  ---------------  --------- ---------------------------------------
31.10.2012  ����� �.�.       [XXXXXX]  �������� �������� ����������� ������
                                       ��� �����������
                                       (����� ����� 12-664)
----------  ---------------  --------- ---------------------------------------
12.04.2013  �������� �.�.    [XXXXXX]  ���� ������������ ����������
                                       ���������� ��������
                                       (����� ����� 12-965)
----------  ---------------  --------- ---------------------------------------
12.04.2013  ����� �.�.       [XXXXXX]  ���� ������ ������
                                       (����� ����� 12-1166)
----------  ---------------  --------- ---------------------------------------
11.10.2012  �������� �.�.    [XXXXXX]  ����������� ������ ��-�� "��������� SAP R3 � ����� ��������� ���������
                                       ��������� (���� ����������, ������������� �������� ���. �������
----------  ---------------  --------- ---------------------------------------
30.06.2014  ����� �.�.       [#15003]  �������� ����������� ������� ��� �������� ���������� ��������
                                       (����� ����� 14-528)
----------  ---------------  --------- ---------------------------------------
25.09.2014  ����� �.�.       [#16715]  ��������� E-mail �� ������� ����� ��� ��������� � ������������� ��� ��
                                       �������� E-mail �� ������� ����� ��� ��������� � ������������� ��� ��
                                       ��� �������� ���������� ��������
                                       (����� ����� 14-528.4)
----------  ---------------  --------- ---------------------------------------
26.12.2014  ����� �.�.       [#18689]  ���������� ������ �������������� ������ ��� ����������� ���������� ������
                                       �� ����� �� ������� ������������� � ��������
                                       ��� ������� �������� ������ �� ������ (CreatePart)
----------  ---------------  --------- ---------------------------------------
26.05.2015  ����� �.�.       [#22087]  ��������� ��������� �������� ��� � ��������� �������
                                       � ������� ������� ������ ���� �������������� ������
----------  ---------------  --------- ---------------------------------------
08.09.2015   ����� �.�.      [15-997]  #24595 SAP R/3: ��������� ���� E7P, EEP
                                       Send_SMS, AddPart, Clear_SchedPayPrcForAdvance, Add_SchedPayPrc
                                       CreateNewMaturity, Add_SchedLim,Change_AGRSIGNDATE,Change_CrInfo
                                       Change_BKI_REQUEST, Change_LIMIT_EXPIRE_DATE,Change_SMS_AGR
                                       CreateNewZalog, CHANGE_CURATORID
----------  ---------------  --------- ---------------------------------------
10.12.2015  ����� �.�.       [#26420]  ��������� ��������� �������� �������� � ������� cdh
----------  ---------------  --------- ---------------------------------------
28.05.2016  �������� �.�.    [#30540]  ��������� ������� ��� ��������� ���������
----------  ---------------  --------- ---------------------------------------
30.05.2016  ubrr korolkov    [16-1808] 16-1808.2.3.2.4.5 Generate_Annuitet
----------  ---------------  --------- ---------------------------------------
19.07.2016  ubrr korolkov    [16-1808] 16-1808.2.3.2.4.5 Generate_Annuitet, �������� p_tp_correct
----------  ---------------  --------- ---------------------------------------
28.07.2016  ������ �.�.      [#34714]  C��� �������� ��� ����� �� �������� �� (������)
----------  ---------------  --------- ---------------------------------------
01.08.2016  ����� �.�.       [16-1808] 16-1808.2.3.2.4.5 ���������������� ��������� ��������� �������� � ���
----------  ---------------  --------- ---------------------------------------
07.2017     �������          [15-1115.1] ������������� �������-�������� - ��������� ����������� ���������� ������
----------  ---------------  --------- ---------------------------------------
08.10.2018  ������� �.�. #56138 [18-494] ������ ���� 8769
----------  ---------------  --------- ---------------------------------------
23.10.2019  ������ �.�.      [19-67365] ���������� - TUTDF ������ 6.01 (29.10.19)
----------  ---------------  --------- ---------------------------------------
08.07.2020  ������ �.�.      [19-59018] ���������� ��� : ���������� �������� ���- E-Mail-����������� ����� � ���
22.03.2021  ������� �.�.     DKBPA-105 ���� 4.1 (���������� ���): ������ ������������. ��� ��� �������� �� �������� �����
\******************************* HISTORY UBRR *****************************************/

  g_log_enable xxi.ups.cupsvalue%type := nvl(PREF.Get_Preference('UBRR_XXI5.UBRR_SAP_CD.ZIU_WRITE_LOG.ENABLE'),'N'); --22.03.2021  ������� �.�.     DKBPA-105 ���� 4.1 (���������� ���): ������ ������������. ��� ��� �������� �� �������� �����

  procedure CreateAgr(
    cpNumDog      in       varchar2   -- ���������� ����� ��������
   ,dpSignDate    in       varchar2   -- ���� ���������� ��������
   ,dpStartDate   in       varchar2   -- ���� ��������
   ,dpEndDate     in       varchar2   -- ���� ��������� ��������
   --,dpSignDate    in       date       -- ���� ���������� ��������
   --,dpStartDate   in       date       -- ���� ��������
   --,dpEndDate     in       date       -- ���� ��������� ��������
   ,ipGroup       in       number     -- ����� ������
   ,ipClientNum   in       number     -- ����� �������
   ,cClientName   in       varchar2   -- ������������ �������
   ,�pCur         in       varchar2   -- ������ ��������
   ,mpSum         in       number     -- ����� ��������
   ,ppIntRate     in       number     -- ���������� ������
   ,ppPenyRate    in       number     -- ���� �� ��������
   ,ppPenyType    in       number     -- ��� ����� �� �������� (������� 0, ������� 1)
   ,ppPenyRate2   in       number     -- ���� �� ��������
   ,ppPenyType2   in       number     -- ��� ����� �� �������� (������� 0, ������� 1)
   ,ipPrtf        in       varchar2   -- ��������
   ,cBranch       in       varchar2   -- ���������
   ---->>>>>>Lobik D.A. ubrr 27.12.2005
   ,iLineType     in       number
   ,dpFirstTransDate in    varchar2   -- ���� ������ ������
   --,dFirstTransDate in     date       -- ���� ������ ������
   ,n_PERCTERMID    in     number     --id ����� ������ %%
   ,mFirstTransSum  in     number     -- ����� ������ ������
   ,iloan_aim       in     number     -- ��� ��� ������� �� ����. CAU
   ,iTurnType       in     number     -- ��� ������� (3 - X-�������, 5 - � ������� ����, 0 - � ����������� ����)
   ,iTurnover       in     number     -- ��������������� �������
   ----<<<<<---Lobik D.A. ubrr 27.12.2005
   ---->>>>>>Lobik D.A. ubrr 14.03.2006
   ,�Acc          in       varchar2   -- ������� ����
   ,�BIC          in       varchar2   -- ��� �����
     ----->>>>>>>>>>>>>>Lobik D.A. ubrr 04.07.2006
   ,is_IN_BKI     in       varchar2   -- �������� �� ������ � ��� (Y-�� N-���)  UBRR Portnyagin D.Y. 19.09.2011
   ,dp_IN_BKI     in       varchar2   -- ���� �������� �� ������ � ��� UBRR Portnyagin D.Y. 19.09.2011
   ,iCR_OUT       in       number     --�������� �������� � ���
   ,dpCR_OUT      in       varchar2   --���� ��������
   ,cCR_ID        in       varchar2   --��� �������� ��������� �������
     -----<<<<<<<<<<<<Lobik D.A. ubrr 04.07.2006
   ----<<<<<<<Lobik D.A. ubrr 14.03.2006
   -- >>> ����� �.�. 01.11.2011 (11-859)
   ,cpSMS_AGR     in       varchar2   -- �������� �� SMS-��������������
   ,cpSMS_INF     in       varchar2   -- ������� ��� SMS-��������������
   ,cpEMAIL_AGR   in       varchar2   -- �������� �� E-Mail-��������������
   ,cpEMAIL_INF   in       varchar2   -- ����� ��.����� ��� E-Mail-��������������
   -- <<< ����� �.�. 01.11.2011 (11-859)
   -- >>> ����� �.�. 25.09.2014 #16715 [14-528.4]
   ,cpUBRRMAIL    in       varchar2   -- ����� ��.����� �� ������� ����� ��� ���������
   -- <<< ����� �.�. 25.09.2014 #16715 [14-528.4]
   ,iXOverDays    in       number     --��� X-����--->>><<<�����-�������� 24.01.2007
   ,noutAgrid     in out   number     -- �������� ����� ��������
   ,cpPunktBASp   IN       varchar2   -- (ubrr) Samokaev R.V. --- 13.02.2008 --
   ,cpGrpObsp     in       varchar2   -- (ubrr) Samokaev R.V. --- 13.02.2008 --
   ,cnIsTransh    in       number     -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   ,cpABS         in       varchar2   -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   ,p_ret_day     IN NUMBER -- ���� ������� 01-31 ��������� �.�. 19.12.2012
   ,cpRepayment   in       varchar2   -- ������� ������� ������������� 14-528 ����� �.�. 30.06.2014
   ,p_PERCCODE8769   in    NUMBER     -- ������� � ���� 8769 - 08.10.2018 ������� �.�. #56138 [18-494] ������ ���� 8769
   ,cpStatus      out      varchar2   -- ������
   ,cpErrorMsg    out      varchar2   -- ��������� �� ������
                                   )
  is
   nPenyType    number;
   npAgrid CDA.ncdaagrid%TYPE;
   iCnt         NUMBER:=0;
   ---->>>>>>>Lobik D.A. ubrr 19.04.2006
   d_intcalc cds.dcdsintcalcdate%type;
   d_intpmt cds.dcdsintpmtdate%type;
   ----<<<<<<<Lobik D.A. ubrr 19.04.2006
   vnABS        VARCHAR2(2);-- (ubrr) Samokaev R.V. --- 22.12.2007 --
   vcAcc        VARCHAR2(25);-- (ubrr) Samokaev R.V. --- 22.12.2007 --
   vnGrpObsp    NUMBER;     -- (ubrr) Samokaev R.V. --- 13.02.2008 --

   cIsFOG       NUMBER;     -- (ubrr) Samokaev R.V. --- 19.06.2008 --
   cNameBankFOG VARCHAR2(128);-- (ubrr) Samokaev R.V. --- 19.06.2008 --
   nIDKBNK      NUMBER;     -- (ubrr) Samokaev R.V. --- 19.06.2008 --
   cIsAccSSB    NUMBER;     -- (ubrr) Samokaev R.V. --- 19.06.2008 -- ������� ����� �� ������� ���
   cSetBIC      VARCHAR2(9);-- (ubrr) Samokaev R.V. --- 19.06.2008 -- ��� �� ����������� �������;
   nKodF        NUMBER;
   dvSignDate   date;       -- ���� ���������� ��������
   dvStartDate  date;       -- ���� ��������
   dvEndDate    date;       -- ���� ��������� ��������
   dvCR_OUT     date;       -- ���� �������� �� �������� � ���
   dvFirstTransDate date;   -- ���� ������ ������
   iPrt         NUMBER;
   dvBKI_IN date;
   vCalcMeth    CD_RETS_OUTS_OBOROTS.CALC_METHOD%type := 0;
  begin
--  RAISE_APPLICATION_ERROR(-20001,'ppPenyType='||to_char(ppPenyType));
-- ����� �.�. 22.10.2010 ������� �� ������ �������� �������� � ������� ������ (begin)

  IF nvl(ipPrtf,'0') <> '0' THEN
    BEGIN
        iPrt := to_number(ipPrtf);
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
  END IF;
  -- ��� �������� �� �������� � ����������� ��������� �������
-- �������� �.�. 17.05.2012 � � 12-654 ����� ��������
--  iPrt := null;

  -- ����������� ����
  BEGIN
    select   decode( dpSignDate,      '00000000', null, to_date(dpSignDate,       'YYYYMMDD') ),
             decode( dpStartDate,     '00000000', null, to_date(dpStartDate,      'YYYYMMDD') ),
             decode( dpEndDate,       '00000000', null, to_date(dpEndDate,        'YYYYMMDD') ),
             decode( dpCR_OUT,        '00000000', null, to_date(dpCR_OUT,         'YYYYMMDD') ),
             decode( dpFirstTransDate,'00000000', null, to_date(dpFirstTransDate, 'YYYYMMDD') ),
             decode( dp_IN_BKI ,      '00000000', null, to_date(dp_IN_BKI ,       'YYYYMMDD') )
        into dvSignDate,
             dvStartDate,
             dvEndDate,
             dvCR_OUT,
             dvFirstTransDate,
             dvBKI_IN
        from DUAL;
  EXCEPTION WHEN OTHERS THEN
        dvSignDate := null;
        dvStartDate := null;
        dvEndDate := null;
        dvCR_OUT := null;
        dvFirstTransDate := null;
        dvBKI_IN := null;
  END;
-- ����� �.�. 22.10.2010 ������� �� ������ �������� �������� � ������� ������ (end)

  cpStatus  := 'ERR';

  -- Check Block
  IF dvStartDate >= dvEndDate THEN
    cpErrorMsg    := char_to_sap('���� ��������� ����� ���� ������');
    return;
  END IF;

-- (ubrr) Samokaev R.V. --- 22.12.2007 --(begin)
/*  IF cpABS = '0' THEN vnABS := '1';  END IF;
  IF cpABS = '4' THEN vnABS := '2';  END IF;
--vnABS := '1';
  XXI_CONTEXT.Set_IDSmr (vnABS);
-- (ubrr) Samokaev R.V. --- 22.12.2007 --(end)---*/

-- ���� �.�. 03.02.2009 � 5041-05/001797 ������ cpABS ��� ������� idSmr
  XXI_CONTEXT.Set_IDSmr (cpABS);

  select CSMRMFO8 into cSetBIC from smr;

  -->>>>>>>>>
  --  RAISE_APPLICATION_ERROR(-20001,to_char(noutAgrid)||' CD agreement Number must be entered!');
  if noutAgrid is null or noutAgrid = 0 then
      npAgrid := CD.New_ID(90000);
  else
      npAgrid := noutAgrid;
  end if;
--  RAISE_APPLICATION_ERROR(-20001,to_char(noutAgrid)||' CD agreement Number must be entered!');
  --<<<<<<<<
  LOOP
      BEGIN
-- (ubrr) Samokaev R.V. --- 19.06.2008 --(begin)
-- (ubrr) Samokaev R.V. --- 22.12.2007 --(begin)
--�������� �� ������������� ����� � ������� ���

        select count('x') into cIsFOG from FOG where CFOGMFO8 = �BIC;
        if cIsFOG >0 then
          select CFOGNAME into cNameBankFOG from FOG where CFOGMFO8 = �BIC;
        end if;
        begin
          select NBNK_ID into nIDKBNK from KBNK where CBNK_RBIC = �BIC;
        exception when NO_DATA_FOUND then
          nIDKBNK := null;
        end;

        select count('x') into cIsAccSSB from xxi."acc" where CACCACC = �Acc and CACCCUR = �pCur and IDSMR = 2;
        begin
          select CACCACC into vcACC from ACC where CACCACC = �Acc and CACCCUR = �pCur;
        exception when NO_DATA_FOUND then
          vcACC := null;
        end;

--obuhov.v('SRV2!  - '||�BIC||' - '||�Acc);

        IF �BIC is null or �Acc is null or �BIC = '' or �Acc ='' or �BIC = '0' or �Acc ='0' or �BIC = '000000000' or �Acc ='00000000000000000000' THEN
          nKodF := null;
          vcACC := null;
--obuhov.v('SRV 1');
        ELSIF �BIC is not null and �BIC <> '' and (cIsFOG=0 and nIDKBNK is null) THEN
          nKodF := null;
          vcACC := null;
--obuhov.v('SRV 2');
        ELSIF �BIC = cSetBIC and vcACC is not null THEN
          nKodF := null;
--          vcACC := null;
--obuhov.v('SRV 3');
        ELSIF �BIC = '046577795' and vnABS = '1' and cIsAccSSB >0 THEN
          nKodF := 2903;
          vcACC := null;
--obuhov.v('SRV 4');
        ELSIF nIDKBNK is not null THEN
          nKodF := nIDKBNK;
          vcACC := null;
--obuhov.v('SRV 5');
        ELSIF nIDKBNK is null and �BIC <> '046577795' THEN
          INSERT INTO kbnk (cbnk_rbic, cbnk_name) values (�BIC, cNameBankFOG);
          begin
            select NBNK_ID into nIDKBNK from KBNK where CBNK_RBIC = �BIC;
          exception when NO_DATA_FOUND then
            nIDKBNK := null;
          end;
          nKodF := nIDKBNK;
          vcACC := null;
--obuhov.v('SRV 6');
        ELSE
          nKodF := null;
          vcACC := null;
        END IF;
-- (ubrr) Samokaev R.V. --- 22.12.2007 --(end)
-- (ubrr) Samokaev R.V. --- 19.06.2008 --(end)

        INSERT INTO xxi."cda"
                (ncdaAGRID, dcdaSIGNDATE, dcdaSIGNDATE2, iCDAnumgroup
                ,ccdaagrmnt
                , icdaclient, ccdacuriso, mcdatotal,CCDANORMNAME
                ---->>>>>>Lobik D.A. ubrr 27.12.2005
                ,ICDAISLINE
                ,icdalinetype
                ,icdapurpose
                ----<<<<<Lobik D.A. ubrr 27.12.2005
                ---->>>>>>Lobik D.A. ubrr 14.03.2006 (� �/� �� 09.03.2006 �������� �.�.8,2,7)
                ,ICDACOLLID -- ������ �������������� -->>><<<--ubrr 13/02/2008 �������� �.�.
                ,CCDACOMMSACCEPT
                ,CCDALOANACCEPT
                ,CCDAPERCENTACCEPT
                ,ICDAINTONOVD -->>><<<--ubrr 23/12/2007 �������� �.�.
                ,ICDAFEETYPE
                ,DCDALINEEND
                ,ICDACURRENTTYPE
                ,CCDACURRENTACC
                ----<<<<<Lobik D.A. ubrr 14.03.2006 (� �/� �� 09.03.2006 �������� �.�.8,2,7)
     ----->>>>>>>>>>>>>>Lobik D.A. ubrr 04.07.2006
                ,ccdacrinfo   --�������� �������� � ���
                ,dcdacrinfdate--���� ��������
                ,ccdacrinfocode--��� �������� ��������� �������
     -----<<<<<<<<<<<<Lobik D.A. ubrr 04.07.2006
                ,ICDAFEETYPE4I
                )
        VALUES      (npAgrid, /*dpSignDate*/dvStartDate, dvSignDate
                 , decode(nvl(ipGroup,0),0,9999,ipGroup) --ipGroup
--ubrr---(��������)--- �������� �.�. ---26.12.2007 ---(begin)
--                ,decode(noutAgrid,null,cpNumDog,to_char(npAgrid))
                , decode(nvl(cpNumDog, ''), '', to_char(npAgrid), cpNumDog)
--ubrr---(��������)--- �������� �.�. ---26.12.2007 ---(end)
                , ipClientNum, �pCur, mpSum,char_convert.char_from_sap(cClientName)
                 ---->>>>>>Lobik D.A. ubrr 27.12.2005
                 --� ��������� � sap-� ���� ����� ������ �� ��� � ��������� ������
                ,decode(sign(nvl(iLineType,0)-2),-1,0,1)--������� ��� null � iLineType<2
                ,decode(sign(nvl(iLineType,0)-2),-1,null,--������� ��� null � iLineType<2
                        decode(iLineType,
                               2,2,--���������
                               6,2,--��������� --->>><<<--����� �.�.24.10.2006 �� ������ ��������� �� 23.10.2006 ��.� 6253
                               ---->>>>>>Lobik D.A. ubrr 14.03.2006 (� �/� �� 09.03.2006 �������� �.5)
                               --3,0,--����� � ������� �������������
                               3,4,--���������.����� � ������� �������������
                               --4,1,--����� � ������� ������
                               4,3,--���������.����� � ������� ������
                               ----<<<<<Lobik D.A. ubrr 14.03.2006 (� �/� �� 09.03.2006 �������� �.5)
                               null--������ ����� �� ����������, �.�. ���������� � ����.���.
                              )
                       )
                ,iloan_aim
                ,decode(cpGrpObsp, '+', 1, '?', 2, '-', 3)
                 ----<<<<<Lobik D.A. ubrr 27.12.2005
                ---->>>>>>Lobik D.A. ubrr 14.03.2006 (� �/� �� 09.03.2006 �������� �.�.8,2,7)
--              18.01.2012 ������ �. �/� �������� ����� ��������� ������� �����
                ,char_convert.char_from_sap(cpPunktBASp)
                ,char_convert.char_from_sap(cpPunktBASp)
                ,char_convert.char_from_sap(cpPunktBASp)
/*
--ubrr---(��������)--- �������� �.�. ---13.02.2008 ---(begin)
                ,cpPunktBASp -- (ubrr) Samokaev R.V. --- 13.02.2008 --
--                ,'2.3.2'--����������� ��������� - ��������, �� ��� ������
                ,cpPunktBASp -- (ubrr) Samokaev R.V. --- 13.02.2008 --
                ,cpPunktBASp -- (ubrr) Samokaev R.V. --- 13.02.2008 --
--ubrr---(��������)--- �������� �.�. ---13.02.2008 ---(end)
*/
                , 1 -- ��������� �� ������������ �������� �� ������� ������ -->>><<<--ubrr 23/12/2007 �������� �.�.
                --->>> Lobik-Nekrasov 24.01.2007
                ---,decode(ppPenyRate,null,0,0,0,1)--���� ���� ����, �� ��� �������
                ,decode(ppPenyType,null,1,0,1,0)--���� 0, �� ���
                --<<< Lobik-Nekrasov 24.01.2007
                --->>>--����� �.�.24.10.2006 �� ������ ��������� �� 23.10.2006 ��.� 6253
                --,decode(sign(nvl(iLineType,0)-2),-1,null,dpEndDate)--���� �������� ��� �����
--                ,decode(iLineType,6,null, decode(sign(nvl(iLineType,0)-2),-1,null,dvEndDate))--���� �������� ��� �����
                ---<<<--����� �.�.24.10.2006 �� ������ ��������� �� 23.10.2006 ��.� 6253
                --->>>--�������� �.�. 21.05.2012, ������ c 2006 ��� ��������� ���� ������� 6 (���� � ��� �������)
                ,decode(iLineType,6,dvEndDate, decode(sign(nvl(iLineType,0)-2),-1,null,dvEndDate))--���� �������� ��� �����
                ---<<<--�������� �.�. 21.05.2012, ������ c 2006 ��� ��������� ���� ������� 6 (���� � ��� �������)
                ,0 --ICDACURRENTTYPE
                ,vcACC-- ������� ���� �� ���� �����
                ----<<<<<Lobik D.A. ubrr 14.03.2006 (� �/� �� 09.03.2006 �������� �.�.8,2,7)
                ----->>>>>>>>>>>>>>Lobik D.A. ubrr 04.07.2006
                ,decode(iCR_OUT,1,'1','0')--�������� �������� � ���
                ,decode(iCR_OUT,1,dvCR_OUT,null)--���� ��������
                ,decode(iCR_OUT,1,char_convert.char_from_sap(cCR_ID),null)--��� �������� ��������� �������
                -----<<<<<<<<<<<<Lobik D.A. ubrr 04.07.2006
                ,decode(ppPenyType2,null,1,0,1,0)--���� 0, �� ���
                );

        if  nKodF is not null then
--obuhov.v('SRV insert into CDA_ACC_OUT');
          insert into CDA_ACC_OUT (NADDAGRID, IADDTYPEOUT, NADDTYPE, CADDACC, CADDCURISO, NADDKBNKID)
               values (npAgrid, 2, 2, �Acc, �pCur, nKodF);
        end if;

        EXIT;
       EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
          if noutAgrid is null or noutAgrid = 0 then
              npAgrid := CD.New_ID(90000);
              iCnt := iCnt + 1;
          else
             RAISE_APPLICATION_ERROR(-20001,'Unique agr.num.must be entered,not'||to_char(npAgrid)||'!');
          end if;
       END;
       --
       IF   iCnt > 10 THEN
             RAISE_APPLICATION_ERROR(-20001,'No found free number CD agrid');
       END IF;
  END LOOP;
  --

  --  cBranch  -- ���������
     if nvl(cBranch,'0') <> '0' then
      BEGIN
        select 1
        INTO iCnt
        from otd where iOTDnum = to_number(cBranch) ;

        UPDATE CDA SET ICDABRANCH =  to_number(cBranch)
        WHERE ncdaAGRID = npAgrid;

      EXCEPTION WHEN OTHERS THEN
       Null;
      END;
     end if;

-- create part #1 (CDQ)
--
    INSERT INTO CDQ
                (ncdqAGRID, icdqPART)
    VALUES      (npAgrid, 1);
-- make it 30-days-a-month (CDH)
    INSERT INTO CDH
                (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, icdhIVAL)
    VALUES      (npAgrid, 1, dvStartDate, 'MONTH', 1);

-- make it 360-days-in-a-year one (CDH)
    INSERT INTO CDH
                (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, icdhIVAL)
    VALUES      (npAgrid, 1, dvStartDate, 'YEAR', 366);

-- restforint (CDH)
    INSERT INTO CDH
                (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, icdhIVAL)
    VALUES      (npAgrid, 1, dvStartDate, 'REST', 1);

    INSERT INTO CDH
                (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, icdhIVAL)
    VALUES      (npAgrid, 1, dvStartDate, 'INCTYPE', 2);

    INSERT INTO CDH
                (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, icdhIVAL)
    VALUES      (npAgrid, 1, dvStartDate, 'ROUND', 2);

    if ppIntRate is not null then
      INSERT INTO CDH
                  (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
      VALUES      (npAgrid, 1, dvStartDate, 'INTRATE', ppIntRate);
-->>>ubrr 23/12/2007 �������� �.�.
      INSERT INTO CDH
                  (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
      VALUES      (npAgrid, 1, dvStartDate, 'OVDRATE', ppIntRate);
--<<<ubrr 23/12/2007 �������� �.�.
    end if;
    if nvl(ppPenyRate,0) > 0 then
      INSERT INTO CDH
                  (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
      VALUES      (npAgrid, 1, dvStartDate, 'LOANFINE', ppPenyRate);
    end if;
    if nvl(ppPenyRate2,0) > 0 then
      INSERT INTO CDH
                  (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
      VALUES      (npAgrid, 1, dvStartDate, 'INTFINE', ppPenyRate2);
    end if;

    if iPrt is not null then
      INSERT INTO CDH
                  (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, icdhiVAL)
      VALUES      (npAgrid, 1, dvStartDate, 'PRTF', iPrt);
    end if;

--ubrr---(���������)--- �������� �.�. ---31.07.2008 ---(begin)
    select decode(ppPenyType,null,1,0,1,0) into nPenyType from dual;
    INSERT INTO CDH
                (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, icdhIVAL)
    VALUES      (npAgrid, 1, dvStartDate, 'LFEETYPE', nPenyType);
--ubrr---(���������)--- �������� �.�. ---31.07.2008 ---(end)

    if dvEndDate is not null then
      ---->>>����� �.�. 05.03.2007 �� �/� ��������� �.�. �� 26.02.2007
      ---insert into cdr
      ---            (ncdragrid, icdrpart, dcdrdate, mcdrsum)
      ---values      (npAgrid, 1, dpEndDate, mpSum);
      begin--��� ������ � cdr �� ���� ������ ���������
          iCnt:=0;
          select count(*)
          into iCnt
          from cda
          where cda.ncdaagrid=npAgrid
                and cda.icdaisline=1
                and icdalinetype=2 ---���������
          ;
          if cnIsTransh = 0 then
            if iCnt = 0 then --��� ������� - �� �������� �����������
              insert into cdr
                          (ncdragrid, icdrpart, dcdrdate, mcdrsum)
              values      (npAgrid, 1, dvEndDate, mpSum);
            end if;
          end if;
      exception when others then
              null;
      end;
      ---<<<����� �.�. 05.03.2007 �� �/� ��������� �.�. �� 26.02.2007
    end if;--if dpEndDate is not nul
    --

     -->>> Lobik-Nekrasov 24.01.2007
     ---insert into ubrr_djko_cd_cdaadd2(ncda2agrid, icdalastpercent)
     --- values (npAgrid, 1);
     if nvl(iXOverDays,0)>0 then --X-����������
        INSERT INTO ubrr_djko_cd_cdaadd2
               (ncda2agrid,icdalastpercent,icdaspover,icdafeetype,icdascaseid)
        VALUES (npAgrid   , 1             ,iXOverDays,  1        ,null       );
     else
        insert into ubrr_djko_cd_cdaadd2(ncda2agrid, icdalastpercent)
        values (npAgrid, 1);
     end if;--if nvl(iXOverDays,0)>0 then
     --<<< Lobik-Nekrasov 24.01.2007

    ---->>>>>>Lobik D.A. ubrr 24.03.2006
        --� ubrr_djko_cd_cdaadd2 ��� �������� ��� ncda2agrid
    ----<<<<<<Lobik D.A. ubrr 24.03.2006

    ---->>>>>>Lobik D.A. ubrr 28.12.2005
    --������ ������
    if dvFirstTransDate is not null then
      ---->>>����� �.�. 05.03.2007 �� �/� ��������� �.�. �� 26.02.2007
      ---insert into cdp
      ---            (ncdpagrid, icdppart, dcdpdate       , mcdpsum)
      ---values      (npAgrid  , 1       , dFirstTransDate, mFirstTransSum);
      begin--��� ������ � cdp �� ���� ������ ���������
          iCnt:=0;
          select count(*)
          into iCnt
          from cda
          where cda.ncdaagrid=npAgrid
                and cda.icdaisline=1
                and icdalinetype=2 ---���������
          ;

          if cnIsTransh = 0 then
            if iCnt = 0 then --��� ������� - �� �������� �����������
              insert into cdp
                          (ncdpagrid, icdppart, dcdpdate       , mcdpsum)
              values      (npAgrid  , 1       , dvFirstTransDate, decode(sign(nvl(iLineType,0)-2),-1,mpSum,mFirstTransSum));
            end if;
          end if;
      exception when others then
              null;
      end;
      ---<<<����� �.�. 05.03.2007 �� �/� ��������� �.�. �� 26.02.2007
    end if;

    if iTurnover<>0 and iTurnover is not null
       --�� X-����������
       and nvl(iXOverDays,0)=0 -->>><<<����� �.�. 05.03.2007 �� �/� ��������� �.�. �� 26.02.2007
    then
        -->> 30.05.2016 ubrr korolkov 16-1808.2.3.2.4.5
        if iTurnType = 5 then
            vCalcMeth := ubrr_cd.CM_WORKING_DAYS;
        end if;
        --<< 30.05.2016 ubrr korolkov 16-1808.2.3.2.4.5
        begin
            insert into CD_RETS_OUTS_OBOROTS( ID_REG, OBOROT_DN, CALC_METHOD)
                                      values(npAgrid, iTurnover, vCalcMeth);
        exception  when others then
            null;
        end;
    end if;
    ----<<<<<---Lobik D.A. ubrr 28.12.2005

    ---->>>>>>Lobik D.A. ubrr 14.03.2006 (� �/� �� 09.03.2006 �������� �.3)

--ubrr---(��������)--- �������� �.�. ---13.02.2008 ---(begin)
    --������ �������-�� = ��������������
    if cpGrpObsp = '+' then vnGrpObsp := 1;
     elsif cpGrpObsp = '?' then vnGrpObsp := 2;
     elsif cpGrpObsp = '-' then vnGrpObsp := 3;
    end if;
      CD.Update_History(npAgrid, 1, 'COLLID', dvStartDate, null, null, vnGrpObsp, null);
--ubrr---(��������)--- �������� �.�. ---13.02.2008 ---(end)

    if  nvl(iLineType,0)>0 then--�����
       CD.Update_History(npAgrid, 1, 'LIMIT' , dvStartDate,mpSum, null, null, null);
    end if;

   ---->>>>>>>Lobik D.A. ubrr 19.04.2006
     --������ ���������� %% - �������  ��:
      --      -���������� ������������ ��� ������ ��������� "���� ��������" �
      --      -��������� "���� ��������"

      d_intcalc:=least(last_day(dvStartDate),dvEndDate);
       --"������ ������ %" -
      --   -��� �������� ��������� ������ "���� ������ ���������" ������� 1 - "� ������ �������������� ��������� �������" - ������� ������ ��������� "���� ��������",
      --   -��� ��������� �������� ��������� ������ "���� ������ ���������" - ������� ������� ��:
      --        --10 ����� ���������� ������ �� ������� "���� ��������" �
      --        --��������� "���� ��������"

--->>>> (���)---�������� �.�. --- 19.06.2008 --- (begin)

-->> ��������� �.�. 19.12.2012 ����������� � �������� �������� "���� �������"
      IF p_ret_day > 0 THEN
        cdterms.update_history(AGRID   => npAgrid,
                               PART    => 1,
                               Term    => 'UBRRPDAY',
                               EffDate => dvStartDate,
                               CVAL    => p_ret_day);
      END IF;
--<< ��������� �.�. 19.12.2012

      IF n_PERCTERMID = 1 or n_PERCTERMID = 3 or n_PERCTERMID = 999 then
        if n_PERCTERMID = 1 then
            d_intpmt:=dvEndDate;
        else
            d_intpmt:=least(last_day(dvStartDate)+10,dvEndDate);
        end if;
        calc_interval(npAgrid ,d_intcalc, d_intpmt, cpErrorMsg);
      -->> ��������� �.�. 19.12.2012 ���������� ��������� ��������
      ELSIF n_PERCTERMID = 6 THEN
        ubrr_xxi5.ubrr_cd_interval.init(npAgrid);
        ubrr_xxi5.ubrr_cd_interval.calc_interval (  p_fixed_param              => 0,  -- ������: 0-� ���� ����������
                                                                                      --         1-� ������� ����
                                                    p_interv                   => 0,  -- ��������: 0-�����
                                                                                      --           1-�������
                                                                                      --           2-�������
                                                                                      --           3-���
                                                                                      --           4-������
                                                    p_dt                       => nvl(dvFirstTransDate,dvSignDate), -- ������ ����������
                                                    p_dt2                      => to_date('01'||to_char(add_months(nvl(dvFirstTransDate,dvSignDate),1),'mm.yyyy'),'dd.mm.yyyy'), -- ������ ������
                                                    p_pay_during               => 1, -- �������� � �������  1-�� 0-���          *
                                                    p_work_day                 => 0, -- ������� 1-�� 0-���                      *
                                                    p_num_of_day               => 5, -- ����                                    *
                                                    p_type_rem                 => 9,  -- ��� ����������� ������: 0-�� ������ ������ ����
                                                                                      --                         1-�� ���������� ��� ���������
                                                                                      --                         2-�� ��� ������ ������ ����
                                                                                      --                         9-�� ��� ������ ������ ������
                                                    p_pay_day                  => p_ret_day,
                                                    p_only_working_days        => 1, -- ��������� ��������
                                                    p_ab                       => 1, -- '1'  - � ��������� �����
                                                                                     -- '-1' - � ��������� �����
                                                    p_tp_correct               => 0, -- �������� �������� ���������� 1-�� 0-���
                                                    p_calc_date_last_day       => 0, -- ������� ���� ��������� ���� ������? 1-�� 0-���
                                                    p_is_first_date_last_day   => 0, -- ������� ���� ������� ����������  ��������� ���� ������? 1-�� 0-���
                                                    p_is_first_pay_last_day    => 0  -- ������� ���� ������ ������ ��������� ���� ������? 1-�� 0-���
                                                  );
      --<< ��������� �.�. 19.12.2012 ���������� ��������� ��������
      ELSIF n_PERCTERMID = 8 THEN -- �� ���� ���������
        ubrr_xxi5.ubrr_cd_interval.init(npAgrid);
        ubrr_xxi5.ubrr_cd_interval.calc_interval (  p_fixed_param              => 0,  -- ������: 0-� ���� ����������
                                                                                      --         1-� ������� ����
                                                    p_interv                   => 0,  -- ��������: 0-�����
                                                                                      --           1-�������
                                                                                      --           2-�������
                                                                                      --           3-���
                                                                                      --           4-������
                                                    p_dt                       => nvl(dvFirstTransDate,dvSignDate), -- ������ ����������
                                                    p_dt2                      => to_date('01'||to_char(add_months(nvl(dvFirstTransDate,dvSignDate),1),'mm.yyyy'),'dd.mm.yyyy'), -- ������ ������
                                                    p_pay_during               => 1, -- �������� � �������  1-�� 0-���          *
                                                    p_work_day                 => 0, -- ������� 1-�� 0-���                      *
                                                    p_num_of_day               => 0, -- ����                                    *
                                                    p_type_rem                 => 9,  -- ��� ����������� ������: 0-�� ������ ������ ����
                                                                                      --                         1-�� ���������� ��� ���������
                                                                                      --                         2-�� ��� ������ ������ ����
                                                                                      --                         9-�� ��� ������ ������ ������
                                                    p_pay_day                  => p_ret_day,
                                                    p_only_working_days        => 1, -- ��������� ��������
                                                    p_ab                       => 1, -- '1'  - � ��������� �����
                                                                                     -- '-1' - � ��������� �����
                                                    p_tp_correct               => 1, -- �������� �������� ���������� 1-�� 0-���
                                                    p_calc_date_last_day       => 0, -- ������� ���� ��������� ���� ������? 1-�� 0-���
                                                    p_is_first_date_last_day   => 0, -- ������� ���� ������� ����������  ��������� ���� ������? 1-�� 0-���
                                                    p_is_first_pay_last_day    => 0  -- ������� ���� ������ ������ ��������� ���� ������? 1-�� 0-���
                                                  );
      END IF;
---<<<< (���)---�������� �.�. --- 19.06.2008 --- (end)

   ----<<<<<<<Lobik D.A. ubrr 19.04.2006
    ----<<<<<Lobik D.A. ubrr 14.03.2006 (� �/� �� 09.03.2006 �������� �.3)
-->> ����� �.�. 04.10.2011
-- ������� �������� �������� �� �������� � ���
    if iCR_OUT = 1 then
       INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , CCDHCVAL)
       VALUES      (npAgrid
                  , 1
                  , dvCR_OUT
                  , 'CDCRINF'
                  , char_convert.char_from_sap(cCR_ID)
       );
    end if;
--<< ����� �.�. 04.10.2011
-->> ����� �.�. 01.08.2016 �������� �������� � ��� ������������� ������; ���� ��� ���� ��������, �� � ���� ����������
    INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , ICDHIVAL)
       VALUES      (npAgrid
                  , 1
                  , nvl(dvCR_OUT, dvStartDate)
                  , 'AGR_NBKI'
                  , 1
       );

    INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , ICDHIVAL)
       VALUES      (npAgrid
                  , 1
                  , nvl(dvCR_OUT, dvStartDate)
                  , 'AGR_OKB'
                  , 0
       );

    INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , ICDHIVAL)
       VALUES      (npAgrid
                  , 1
                  , nvl(dvCR_OUT, dvStartDate)
                  , 'AGR_EQV'
                  , 0
       );
--<< ����� �.�. 01.08.2016 �������� �������� � ��� ������������� ������; ���� ��� ���� ��������, �� � ���� ����������

-->> Portnyagin D.Y. 19.09.2011
-- ������� �������� �������� �� ������ � ���
    if dvBKI_IN is not null AND is_IN_BKI is not null then
       INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , CCDHCVAL)
       VALUES      (npAgrid
                  , 1
                  , dvBKI_IN
                  , 'UBRR_BKI'
                  , is_IN_BKI
       );
    end if;
--<< Portnyagin D.Y. 19.09.2011
  -- >>> ����� �.�. 01.11.2011 (11-859)
    if cpSMS_AGR = 'Y' then
      begin
       INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , ICDHIVAL)
       VALUES      (npAgrid
                  , 1
                  , dvStartDate
                  , 'UBRRSMSA'
                  ,1
       );
       INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , CCDHCVAL)
       VALUES      (npAgrid
                  , 1
                  , dvStartDate
                  , 'UBRR_SMS'
                  , char_convert.char_from_sap(cpSMS_INF)
       );
      end;
    else
       INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , ICDHIVAL)
       VALUES      (npAgrid
                  , 1
                  , dvStartDate
                  , 'UBRRSMSA'
                  ,0
       );
    end if;
    if cpEMAIL_AGR = 'Y' then
      begin
       INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , ICDHIVAL)
       VALUES      (npAgrid
                  , 1
                  , dvStartDate
                  , 'UBRREMLA'
                  ,1
       );
       INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , CCDHCVAL)
       VALUES      (npAgrid
                  , 1
                  , dvStartDate
                  , 'UBRR_EML'
                  , char_convert.char_from_sap(cpEMAIL_INF)
       );
      end;
    else
       INSERT INTO CDH(ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , ICDHIVAL)
       VALUES      (npAgrid
                  , 1
                  , dvStartDate
                  , 'UBRREMLA'
                  ,0
       );
    end if;
  -- <<< ����� �.�. 01.11.2011 (11-859)

  -- >>> -- ����� �.�.  31.10.2012  #5017  12-664
    -- ��� ����������� � ���������� �������
    -- ��������� �������� �������� � �������� ��������
    if nvl(iLineType,0) = 6 then
      INSERT INTO CDH( ncdhAGRID
                     , icdhPART
                     , dcdhDATE
                     , ccdhTERM
                     , ICDHIVAL)
       VALUES     ( npAgrid
                  , 1
                  , dvStartDate
                  , 'UBRR_LIM'
                  ,1
                  );
    end if;
  -- <<< -- ����� �.�.  31.10.2012  #5017  12-664

  -- >>> -- ����� �.�.  30.06.2014  #15003  14-528
    if cpRepayment is null or
       char_convert.char_from_sap(cpRepayment) = ''
    then
       null;
    else
        INSERT
            INTO ubrr_data.UBRR_SRR_CDA_PROP_val
            VALUES ( 1
                   , npAgrid
                   , char_convert.char_from_sap(cpRepayment)
                   );
    end if;
  -- <<< -- ����� �.�.  30.06.2014  #15003  14-528
  -- >>> -- ����� �.�.  25.09.2014 #16715 [14-528.4]
    if cpUBRRMAIL is null or cpUBRRMAIL = '' or cpUBRRMAIL = ' '
    then
        null;
    else
        INSERT INTO CDH(ncdhAGRID
                      , icdhPART
                      , dcdhDATE
                      , ccdhTERM
                      , CCDHCVAL)
        VALUES      (npAgrid
                   , 1
                   , dvStartDate
                   , 'UBRRMAIL'
                   , cpUBRRMAIL
       );
    end if;
  -- <<< -- ����� �.�.  25.09.2014 #16715 [14-528.4]
  -->> 08.10.2018 ������� �.�. #56138 [18-494] ������ ���� 8769
  if p_PERCCODE8769 = 0
    then
        null;
    else
        INSERT INTO CDH(ncdhAGRID
                      , icdhPART
                      , dcdhDATE
                      , ccdhTERM
                      , PCDHPVAL)
        VALUES      (npAgrid
                   , 1
                   , dvStartDate
                   , 'CODE8769'
                   , p_PERCCODE8769
       );
    end if;
  --<< 08.10.2018 ������� �.�. #56138 [18-494] ������ ���� 8769
    cpErrorMsg    := char_to_sap('OK');
    noutAgrid := npAgrid;
    cpStatus  := 'OK';

    if n_PERCTERMID = 7 then
        insert into xxi.cda2 ( NCDA2AGRID, NCDA2FLFX_A, NCDA2ANN_A, MCDA2SUM_A, NCDA2INT_A, DCDA2DTF_A,
                               NCDA2DTN_A, NCDA2OWD_A, NCDA2OWDCR_A, DCDA2DTL_A )
                      values ( npAgrid, 1, 1, 0, 0, dvStartDate,
                               nvl( p_ret_day, 0), 1, 1, dvEndDate );
    end if;

    -->> 23.10.2019 ������ �.�. [19-67365] ���������� - TUTDF ������ 6.01 (29.10.19)
    ubrr_bki_uid.save_uid_to_cd(P_agrid => npAgrid);
    --<< 23.10.2019 ������ �.�. [19-67365] ���������� - TUTDF ������ 6.01 (29.10.19)

    return;
  exception
    when others then
      cpStatus  := 'ERR';
      cpErrorMsg    := char_to_sap( dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace());
      return;
  end;

  PROCEDURE CreatePart(
   npAgrid          in       number   -- ����� ��������
   ,dpDelivery      in       varchar2 -- ���� ������
   ,ppIntRate       in       number   -- ���������� ������
   ,npSumPart_30d   in       number   -- ����� ����� (�� 30 ����)
   ,npSumPart_90d   in       number   -- ����� ����� (�� 31 �� 90 ����)
   ,npSumPart_180d  in       number   -- ����� ����� (�� 91 �� 180 ����)
   ,npSumPart_1y    in       number   -- ����� ����� (�� 181 ��� �� 1 ����)
   ,npSumPart_3y    in       number   -- ����� ����� (�� 1 ���� �� 3 ���)
   ,npSumPart_ovr3y in       number   -- ����� ����� (����� 3 ���)
   ,cpABS           in       varchar2 -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   ,npStrNumPart    out      number   -- ����� ��������� �����
   ,npFinNumPart    out      number   -- ����� ��������� �����
   ,cpErrorMsg      out      varchar2 -- ��������� �� ������
                       )
  IS
-- (ubrr) (���) Samokaev R.V. --- 31.07.2007 --(begin)
--    TYPE T_SummOfParts IS VARRAY(5) OF NUMBER;
    TYPE T_SummOfParts IS VARRAY(30) OF NUMBER;
-- (ubrr) (���) Samokaev R.V. --- 31.07.2007 --(end)
    SummOfParts T_SummOfParts := T_SummOfParts();
    cnt         number:=0;
    nPart       number:=0;  -- ������� ������ ������
    vcPenyRate  number;
    vcPenyRate2 number;
    vnABS       varchar2(2);-- (ubrr) Samokaev R.V. --- 22.12.2007 --
    nContext    number;
    dvDelivery  date;
--
  BEGIN

    if cpABS is null then
      cpErrorMsg := char_to_sap('����� ��� = NULL');
      return;
    end if;

-- ����� �.�. 22.10.2010 ������� �� ������ �������� �������� � ������� ������ (begin)
    BEGIN
      select   decode( dpDelivery, '00000000', null, to_date(dpDelivery, 'YYYYMMDD') )
        into dvDelivery
        from DUAL;
    EXCEPTION WHEN OTHERS THEN
        dvDelivery := null;
    END;

    -->> ����� �.�. 26.12.2014 #18689
    if dvDelivery = null then -- ���� �� �������
      cpErrorMsg := char_to_sap('�� ������� ���� ������ ������');
      return;
    end if;
    --<< ����� �.�. 26.12.2014 #18689
-- ����� �.�. 22.10.2010 ������� �� ������ �������� �������� � ������� ������ (end)
/*
-- (ubrr) Samokaev R.V. --- 22.12.2007 --(begin)
  IF cpABS = '0' THEN
    vnABS := '1';
  END IF;
  IF cpABS = '4' THEN
    vnABS := '2';
  END IF;

  XXI_CONTEXT.Set_IDSmr (vnABS);*/
-- (ubrr) Samokaev R.V. --- 22.12.2007 --(end)---

-- ���� �.�. 03.02.2009 � 5041-05/001797 ������ cpABS ��� ������� idSmr
  XXI_CONTEXT.Set_IDSmr (cpABS);

    select count(*)
      into cnt
      from cda
     where cda.ncdaagrid = npAgrid
       and icdaisline = 1
       and icdalinetype in (3, 4); ---������������� ����� � ��� ������ � ������� ������.

    if cnt = 0 then -- ������� �� �������� ������������� ������
      cpErrorMsg := char_to_sap('��� �������� - �� ������������� �����');
      return;
    end if;

    if nvl(npSumPart_30d, 0) != 0 then
      SummOfParts.Extend;
      SummOfParts(SummOfParts.last) := npSumPart_30d;
    end if;
    if nvl(npSumPart_90d, 0) != 0 then
      SummOfParts.Extend;
      SummOfParts(SummOfParts.last) := npSumPart_90d;
    end if;
    if nvl(npSumPart_180d, 0) != 0 then
      SummOfParts.Extend;
      SummOfParts(SummOfParts.last) := npSumPart_180d;
    end if;
    if nvl(npSumPart_1y, 0) != 0 then
      SummOfParts.Extend;
      SummOfParts(SummOfParts.last) := npSumPart_1y;
    end if;
    if nvl(npSumPart_3y, 0) != 0 then
      SummOfParts.Extend;
      SummOfParts(SummOfParts.last) := npSumPart_3y;
    end if;
    if nvl(npSumPart_ovr3y, 0) != 0 then
      SummOfParts.Extend;
      SummOfParts(SummOfParts.last) := npSumPart_ovr3y;
    end if;

    begin
      select nvl(max(ICDPPART), 0) into npStrNumPart from CDP where NCDPAGRID = npAgrid;
    exception when NO_DATA_FOUND then
      npStrNumPart := 0;
    end;
-- ����� �.�. 27.10.2010 ������ ����� �� ��������� �����
    begin
      select PCDHPVAL into vcPenyRate from CDH H
           where H.NCDHAGRID = npAgrid
           and   H.CCDHTERM = 'LOANFINE'
           and   H.ICDHPART = npStrNumPart
           -->> ����� �.�. 26.12.2014 #18689 ������ (����!) ����� ��������� �� ����
           and   H.DCDHDATE = (select max(DCDHDATE) from CDH
                                where NCDHAGRID = H.NCDHAGRID
                                and   CCDHTERM = 'LOANFINE'
                                and   ICDHPART = H.ICDHPART
                                and   DCDHDATE <= dvDelivery);
           --<< ����� �.�. 26.12.2014 #18689 ������ (����!) ����� ��������� �� ����
    exception when NO_DATA_FOUND then
      begin
      select PCDHPVAL into vcPenyRate from CDH H
           where H.NCDHAGRID = npAgrid
           and   H.CCDHTERM = 'LOANFINE'
           and   H.ICDHPART = 1
           -->> ����� �.�. 26.12.2014 #18689 ������ (����!) ����� ��������� �� ����
           and   H.DCDHDATE = (select max(DCDHDATE) from CDH
                                where NCDHAGRID = H.NCDHAGRID
                                and   CCDHTERM = 'LOANFINE'
                                and   ICDHPART = H.ICDHPART
                                and   DCDHDATE <= dvDelivery);
           --<< ����� �.�. 26.12.2014 #18689 ������ (����!) ����� ��������� �� ���������� �� ����
      exception when NO_DATA_FOUND then vcPenyRate := 0;
      end;
    end;
    begin
      select PCDHPVAL into vcPenyRate2 from CDH H
           where H.NCDHAGRID = npAgrid
           and   H.CCDHTERM = 'INTFINE'
           and   H.ICDHPART = npStrNumPart
           -->> ����� �.�. 26.12.2014 #18689 ������ (����!) ����� ��������� �� ����
           and   H.DCDHDATE = (select max(DCDHDATE) from CDH
                                where NCDHAGRID = H.NCDHAGRID
                                and   CCDHTERM = 'INTFINE'
                                and   ICDHPART = H.ICDHPART
                                and   DCDHDATE <= dvDelivery);
           --<< ����� �.�. 26.12.2014 #18689 ������ (����!) ����� ��������� �� ����
    exception when NO_DATA_FOUND then
      begin
      select PCDHPVAL into vcPenyRate2 from CDH H
           where H.NCDHAGRID = npAgrid
           and   H.CCDHTERM = 'INTFINE'
           and   H.ICDHPART = 1
           -->> ����� �.�. 26.12.2014 #18689 ������ (����!) ����� ��������� �� ����
           and   H.DCDHDATE = (select max(DCDHDATE) from CDH
                                where NCDHAGRID = H.NCDHAGRID
                                and   CCDHTERM = 'INTFINE'
                                and   ICDHPART = H.ICDHPART
                                and   DCDHDATE <= dvDelivery);
           --<< ����� �.�. 26.12.2014 #18689 ������ (����!) ����� ��������� �� ���������� �� ����
      exception when NO_DATA_FOUND then vcPenyRate2 := 0;
      end;
    end;
--      obuhov.V('SRV (npStrNumPart)- '||to_char(npStrNumPart));


      npFinNumPart := npStrNumPart+SummOfParts.Count;

    if npStrNumPart = 0 then
      for nPart IN 1..SummOfParts.Count
      loop
        if nPart > 1 then
          insert into CDQ (NCDQAGRID, ICDQPART)
             values (npAgrid, (npStrNumPart+nPart));
          INSERT INTO CDH
                      (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
          VALUES      (npAgrid, (npStrNumPart+nPart), dvDelivery, 'INTRATE', ppIntRate);
          INSERT INTO CDH
                      (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
          VALUES      (npAgrid, (npStrNumPart+nPart), dvDelivery, 'OVDRATE', ppIntRate);
          INSERT INTO CDH
                      (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
          VALUES      (npAgrid, (npStrNumPart+nPart), dvDelivery, 'LOANFINE', vcPenyRate);
          INSERT INTO CDH
                      (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
          VALUES      (npAgrid, (npStrNumPart+nPart), dvDelivery, 'INTFINE', vcPenyRate2);
        end if;
        insert into CDP (NCDPAGRID, ICDPPART, DCDPDATE, MCDPSUM)
           values (npAgrid, (npStrNumPart+nPart), dvDelivery, SummOfParts(nPart));
      end loop;
    else
      for nPart IN 1..SummOfParts.Count
      loop
        insert into CDQ (NCDQAGRID, ICDQPART)
           values (npAgrid, (npStrNumPart+nPart));
        insert into CDP (NCDPAGRID, ICDPPART, DCDPDATE, MCDPSUM)
           values (npAgrid, (npStrNumPart+nPart), dvDelivery, SummOfParts(nPart));
        INSERT INTO CDH
                    (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
        VALUES      (npAgrid, (npStrNumPart+nPart), dvDelivery, 'INTRATE', ppIntRate);
        INSERT INTO CDH
                    (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
        VALUES      (npAgrid, (npStrNumPart+nPart), dvDelivery, 'OVDRATE', ppIntRate);
        INSERT INTO CDH
                    (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
        VALUES      (npAgrid, (npStrNumPart+nPart), dvDelivery, 'LOANFINE', vcPenyRate);
        INSERT INTO CDH
                      (ncdhAGRID, icdhPART, dcdhDATE, ccdhTERM, pcdhPVAL)
        VALUES      (npAgrid, (npStrNumPart+nPart), dvDelivery, 'INTFINE', vcPenyRate2);
      end loop;
  end if;

    npStrNumPart := npStrNumPart+1;

    cpErrorMsg    := char_to_sap('OK');
    return;
  exception
    when others then
      cpErrorMsg    := char_to_sap(sqlerrm);
      return;
  END;


  procedure AddPart(
    npAgrid      in       number   -- �������� ����� ��������
   ,dpEndDate    in       varchar2   -- ���� ��������
   --,dpEndDate    in       date   -- ���� ��������
   ,ipPart       in       number   -- ����� �����
   ,mpSum        in       number   -- ����� �����
   ,cpABS        in       varchar2 -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
   --,cpErrorMsg   in out   varchar2 -- ��������� �� ������
   ,cpErrorMsg  out       varchar2 -- ��������� �� ������
   --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                                  )
  is
    cnt         number:=0;-->>><<<����� �.�. 05.03.2007 �� �/� ��������� �.�. �� 26.02.2007
    vnABS       varchar2(2);-- (ubrr) Samokaev R.V. --- 22.12.2007 --
    dvEndDate   date;
  begin

/*-- (ubrr) Samokaev R.V. --- 22.12.2007 --(begin)
    IF cpABS = '0' THEN vnABS := '1';  END IF;
    IF cpABS = '4' THEN vnABS := '2';  END IF;

    XXI_CONTEXT.Set_IDSmr (vnABS);
-- (ubrr) Samokaev R.V. --- 22.12.2007 --(end)---*/
-- ����� �.�. 22.10.2010 ������� �� ������ �������� �������� � ������� ������
  select decode( dpEndDate,
                 '00000000', null,
                 to_date(dpEndDate, 'YYYYMMDD')
               )
    into dvEndDate
    from DUAL;
-- ���� �.�. 03.02.2009 � 5041-05/001797 ������ cpABS ��� ������� idSmr
  XXI_CONTEXT.Set_IDSmr (cpABS);

    ---->>>����� �.�. 05.03.2007 �� �/� ��������� �.�. �� 26.02.2007
    ---insert into cdr
    ---            (ncdragrid, icdrpart, dcdrdate, mcdrsum)
    ---values      (npAgrid, ipPart, dpEndDate, mpSum);

    begin--��� ������ � cdr �� ���� ������ ���������
        select count(*)
        into cnt
        from cda
        where cda.ncdaagrid=npAgrid
              and cda.icdaisline=1
              and icdalinetype=2 ---���������
        ;
        if cnt = 0 then --��� ������� - �� �������� �����������
            insert into cdr
                        (ncdragrid, icdrpart, dcdrdate, mcdrsum)
            values      (npAgrid, ipPart, dvEndDate, mpSum);
        end if;
    exception when others then
            null;
    end;
    ---<<<����� �.�. 05.03.2007 �� �/� ��������� �.�. �� 26.02.2007
    cpErrorMsg    := char_to_sap('OK');
    return;
  exception
    when others then
      cpErrorMsg    := char_to_sap( sqlerrm);
      return;
  end;

  function sap_2_char(ss in varchar2,ii in number)return varchar2
  is
  ret varchar2(4000):=ss;
  begin
/*       return(
              replace(
                      substr(ltrim(rtrim(char_convert.char_from_sap(ss))),1,ii)
                      ,lpad('0',ii,'0')
                      ,to_char(null)
              )
             );
*/
       ret:=substr(ltrim(rtrim(char_convert.char_from_sap(ss))),1,ii);
       if instr(ret,'0',1,length(ret))=0 then
           return(ret);
       else
           return(null);
       end if;
  end;

  procedure CreateNewZalog(
    npAgrid      in       number   -- �������� ����� ��������
   ,dpDate       in       varchar2 -- ����
   ,DpDsnDate    in       varchar2 -- ���� �������
   ,iwarrantor   IN       varchar2 --
   ,ipType       in       number   -- ��� ����������� �� ������� czv
   ,ipSubType    in       number   -- ������ ����������� �� ������� czw
   ,ipQuality    in       varchar2 -- number   -- ��������� �������� ����������� (������, 1, 2)
   ,�pCur        in       varchar2 -- ������
   ,mpSum        in       number   -- ����� �����
   ,mpQSum       in       number   -- ����� ����� ����� ��������------->>>>><<<<<<<---
   ,mpMrktSum    in       number   -- �������� ���������
   ,cNAME        in       varchar2 --------warrantor attributes
   ,cNAMEFULL    in       varchar2
   ,cINN         in       varchar2
   ,cKPP         in       varchar2
   ,cOKVED       in       varchar2
   ,cOKPO        in       varchar2
   ,cOGRN        in       varchar2
   ,cADDR        in       varchar2
   ,cADDR2       in       varchar2
   ,cPERSON      in       varchar2
   ,cPASPTYPE    in       varchar2
   ,cPASPNUM     in       varchar2
   ,cPASPSER     in       varchar2
   ,cPASPPLACE   in       varchar2
   ,dPASPDATE    in       varchar2
   ,cpComment    in       varchar2 -- ���������� � �����������
   ,cpPersname   in       varchar2 --
--> ���� �.�. �������� �� �����������
   ,cpAgrNum     in       varchar2
   ,dpAgrDate    in       varchar2
   ,cpAgrAdrr    in       varchar2
--< ���� �.�. �������� �� �����������
   ,cpABS        in       varchar2 -- (ubrr) Samokaev R.V. --- 22.12.2007 --
   -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
   --,cpErrorMsg   in out   varchar2 -- ��������� �� ������
   ,cpErrorMsg  out       varchar2 -- ��������� �� ������
   --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                                  )
  is
    IDCZO       number;
    IDCZH       number;
    IDCZHOPERATOR CZH.CCZHOPERATOR%TYPE;
    i_pType CZO.NCZOCZV%TYPE;
    i_pSubType CZO.NCZOCZW%TYPE;
    iipQuality  number;
    iiwarrantor number;
    num_cus     number := 0;
    d_PASPDATE  date :=null;
    vnABS       varchar2(2);-- (ubrr) Samokaev R.V. --- 22.12.2007 --
    ivCdhDocId  number;
    ivCdhType   number;
    ivCdhSchema number;
    dvDate      date;
    dvAgrDate   date;
    dvDsnDate   date;

  begin
    --->>>>>>>>>>>>>>
-- ����� �.�. 22.10.2010 ������� �� ������ �������� �������� � ������� ������ (begin)
  -- ����������� ����
    BEGIN
      select   decode( dpDate,    '00000000', null, to_date(dpDate,    'YYYYMMDD') ),
               decode( dpAgrDate, '00000000', null, to_date(dpAgrDate, 'YYYYMMDD') ),
               decode( dpDsnDate, '00000000', null, to_date(dpDsnDate, 'YYYYMMDD') )
        into dvDate,
             dvAgrDate,
             dvDsnDate
        from DUAL;
    EXCEPTION WHEN OTHERS THEN
        dvDate    := null;
        dvAgrDate := null;
        dvDsnDate := null;
    END;
-- ����� �.�. 22.10.2010 ������� �� ������ �������� �������� � ������� ������ (end)
    iipQuality :=to_number(ltrim(rtrim(ipQuality)));
-- (ubrr) Samokaev R.V. --- 13.02.2008 --(begin)---
    if ipType in (-1,2) then -- 1=��������� � 2=��������������
--    if ipType in (1,2) then -- 1=��������� � 2=��������������
-- (ubrr) Samokaev R.V. --- 13.02.2008 --(end)---
        iiwarrantor:=to_number(ltrim(rtrim(iwarrantor)));
        ivCdhType := 4;
        ivCdhSchema := 10;
    else-- 1=���������
        iiwarrantor:=null;
        ivCdhType := 5;
        ivCdhSchema := 9;
    end if;
    --<<<<<<<<<<<<<<<<
   begin
    select  iabsczv, iabsczw into i_pType, i_pSubType FROM ubrr_cd_sap_zalog
    where ISAPTYPE = ipType AND ISAPSUBTYPE = ipSubType ;
   exception  when others then
      cpErrorMsg    := char_to_sap('�������� ���������� ������ ����� ������� SAP <=> ABS');
      return;
    end;

/*-- (ubrr) Samokaev R.V. --- 22.12.2007 --(begin)---
  IF cpABS = '0' THEN vnABS := '1';  END IF;
  IF cpABS = '4' THEN vnABS := '2';  END IF;
--vnABS := '1';
  XXI_CONTEXT.Set_IDSmr (vnABS);
-- (ubrr) Samokaev R.V. --- 22.12.2007 --(end)---*/
-- ���� �.�. 03.02.2009 � 5041-05/001797 ������ cpABS ��� ������� idSmr
  XXI_CONTEXT.Set_IDSmr (cpABS);

    -- � ����� CDZO
    select S_CZO.nextval
    into   IDCZO
    from   sys.dual;
    --------->>>>>>>>>>>>>>
    num_cus:=null;
    if 1=0 then --iiwarrantor is not null and iiwarrantor<>0 then
        begin --��������� ����������-������� � ������ �����������

            SELECT S_CPOZ.NEXTVAL INTO num_cus FROM SYS.DUAL ;
/*            insert into CPOZ
            SELECT num_cus,null,null,null,null,null,null,null,null,null,null,null,
                   user, null,null,null,null,null,
                   0, null,null,null,null,null,null,null,null,null,
                   0,null,null,null,null,null,null,null,null,null,null,null,null,
                     null,null,null,null,null,null,null,null,null,null,null,null,
                   iiwarrantor
            FROM dual
            where not exists (select '*'
                              from cpoz
                              where icpozcusnum is not null
                                    and icpozcusnum=iiwarrantor
                             );
*/
           INSERT INTO cpoz (icpo   ,ccpozidopen,icpozcusnum,ncpozfwt)
           VALUES           (num_cus,       user,iiwarrantor,       0);
        exception when others then
           begin--������, ���� ������ ��� ������� ��� ����������
              select icpo
              into num_cus
              from cpoz
              where icpozcusnum=iiwarrantor and icpozcusnum is not null;
           exception when others then
              num_cus:=null;
           end;
        end;
    elsif iiwarrantor is not null and iiwarrantor<>0 then
        begin--����� ����, ���� ������ ��� ������� ��� ����������
           select icpo
           into num_cus
           from cpoz
           where icpozcusnum=iiwarrantor and icpozcusnum is not null;
        exception when others then
            begin--��������� ������ ����������-������� � ������ �����������
               SELECT S_CPOZ.NEXTVAL INTO num_cus FROM SYS.DUAL ;

               INSERT INTO cpoz (icpo   ,ccpozidopen,icpozcusnum,ncpozfwt)
               VALUES           (num_cus,       user,iiwarrantor,       0);
            exception when others then
               num_cus:=null;
            end;
        end;
    elsif iiwarrantor is not null and iiwarrantor=0 then--����������-��������
        num_cus:=null;
        begin--����� ����, ������ � ���� cNAMEFULL ��� ������� ��� ����������
           select icpo
           into num_cus
           from cpoz
           where upper(ltrim(rtrim(CCPONAME)))=upper(ltrim(rtrim(sap_2_char(cNAMEFULL,255))))
                 and ltrim(rtrim(CCPONAME)) is not null
                 and rownum=1;
        exception when others then
           num_cus:=null;
        end;
        if num_cus is null then--������� � ���� cNAMEFULL ��� � �����������
            if ltrim(rtrim(dPASPDATE))='00000000'then
              d_PASPDATE:=null;
            else
              d_PASPDATE:=to_date(ltrim(rtrim(dPASPDATE)),'YYYYMMDD');
            end if;
            SELECT S_CPOZ.NEXTVAL INTO num_cus FROM SYS.DUAL ;
            INSERT INTO  CPOZ
                  ( ICPO , CCPOZFLAG , CCPOZREZ , DCPOZOPEN , DCPOZEDIT
                   , NCPOZOKPO , CCPOZADDR , CCPOZPHONE1 , CCPOZPHONE2 , CCPOZPHONE3--2
                  , CCPOZFAMILY1 , CCPOZFAMILY2 , CCPOZIDOPEN , CCPONAME , CCPOZPRIM--3
                  , NCPOZTAXNUM , CCPOZNUMNAL , CCPOZENAME , NCPOZOTD , CCPOZCOATO
                  , CCPOZADDR_PHIS , CCPOZKSIVA , CCPOZIND , NCPOZOKONX , CCPOZKFC
                  , CCPOZFULLDOC , CCPOZCOUNTRY1 , CCPOZCOUNTRY2 , NCPOZFWT , CCPOZEMAIL
                  , CCPOZFAX , CCPOZWWW , CCPOZSOOGU , CCPOZKOPF , CCPOZPASSP_NUM
                  , CCPOZPASSP_SER , DCPOZPASSP , CCPOZPASSP_PLACE , CCPOZCLSB , CCPOZADDR_IND
                  , CCPOZADDR_CITY , CCPOZADDR_PUNCT , CCPOZADDR_STREET , CCPOZADDR_DOM , CCPOZADDR_KORP
                  , CCPOZADDR_KV , CCPOZADDR_PHIS_IND , CCPOZADDR_PHIS_CITY , CCPOZADDR_PHIS_PUNCT , CCPOZADDR_PHIS_STREET
                  , CCPOZADDR_PHIS_DOM , CCPOZADDR_PHIS_KORP , CCPOZADDR_PHIS_KV , ICPOZCUSNUM
                  )
             VALUES(num_cus,null,null,to_date(null),to_date(null)
                    ,sap_2_char(cOKPO,9),sap_2_char(cADDR,256),null,null,null--2
                    ,sap_2_char(cPERSON,255),null,user,sap_2_char(cNAMEFULL,255)--3
                      ,sap_2_char(cNAME,132)--3
                    ,null,sap_2_char(cINN,13),null,0,null--4
                    ,sap_2_char(cADDR2,256),null,null,null,null--5
                    ,null,null,null,0,null--6
                    ,null,null,null,null,sap_2_char(cPASPNUM,20)--7
                    ,sap_2_char(cPASPSER,10),d_PASPDATE--to_date(ltrim(rtrim(dPASPDATE)) ,'YYYYMMDD')--8
                      ,sap_2_char(cPASPPLACE,100),null,null--8
                    ,null,null,null,null,null
                    ,null,null,null,null,null
                    ,null,null,null,to_number(null)
                   );
        else--������ � ���� cNAMEFULL ��� ������� ��� ����������
            --������� ��� ������
            update CPOZ
            set
                    NCPOZOKPO=sap_2_char(cOKPO,9)
                  , CCPOZADDR=sap_2_char(cADDR,256)--2
                  , CCPOZFAMILY1=sap_2_char(cPERSON,255)
                  , CCPOZIDOPEN=user
                  , CCPOZPRIM=sap_2_char(cNAME,132)--3
                  , CCPOZNUMNAL=sap_2_char(cINN,13)
                  , NCPOZOTD=0 --4
                  , CCPOZADDR_PHIS=sap_2_char(cADDR2,256)--5
                  , NCPOZFWT =0 --6
                  , CCPOZPASSP_NUM=sap_2_char(cPASPNUM,20)--7
                  , CCPOZPASSP_SER=sap_2_char(cPASPSER,10)
                  , DCPOZPASSP=d_PASPDATE
                  , CCPOZPASSP_PLACE=sap_2_char(cPASPPLACE,100)--8
            where ICPO=num_cus;
        end if;--if num_cus=null then
/*
    ,cKPP        IN VARCHAR2
    ,cOKVED      IN VARCHAR2
    ,cOKPO       IN VARCHAR2
    ,cOGRN       IN VARCHAR2
    ,cPASPTYPE   IN VARCHAR2
*/                   null;
    end if;

--> ���� �.�. �������� �� �����������
    INSERT INTO cdh_doc
           (NCDHAGRID,ICDHTYPE,CCDHATRIBUT,DCDHREG,CCDHSHEMA,CCDHCOMM)
    VALUES (npAgrid, ivCdhType, char_convert.char_from_sap(cpAgrNum), dvAgrDate, ivCdhSchema, char_convert.char_from_sap(cpAgrAdrr))
    RETURNING icdhid into ivCdhDocId;
--< ���� �.�. �������� �� �����������

    ----------<<<<<<<<<<<<<<<<<<<
    INSERT INTO CZO
                (ICZO, CCZOSCHET, NCZOAGRID, NCZOMAKRO
                , CCZOCOMMENT
                ,NCZOPEREOCENKA, NCZOPORUCH, NCZOCZV, NCZOCZW, CCZOCUR
                ,ICZOAUTOCORR, NCZOIDDOC, PCZOCOEFF, CCZOSECURACC
                ,NCZOCOEFFCORR
                ,NCZOZLG  -->>>><<<<--(���������) Samokaev R.V. --- 23.04.2008
                )--decode(iiwarrantor,0,null,iiwarrantor)
    VALUES      (IDCZO, null, npAgrid, null
-- (ubrr) (���������) Samokaev R.V. --- 13.02.2008 --(begin)--- ��� ��������� ������������� ����� ��� � �����������
--                 ,decode(ipType,1 --����� ������ � ����������� �� ������ ��������� �. �� 22.03.06
--                                  ,substr(char_convert.char_from_sap(cpPersname)||' ('||char_convert.char_from_sap(cpComment)||')',1,1024)
                                  ,char_convert.char_from_sap( cpComment)
--                        )
-- (ubrr) (���������) Samokaev R.V. --- 13.02.2008 --(end)---

                ,null
-- (ubrr) (��������) Samokaev R.V. --- 23.04.2008 --(begin)--- ��� ��������� ������������� � ����������� �� �����������
                ,decode(ipType,2,num_cus,null)
--                num_cus
-- (ubrr) (��������) Samokaev R.V. --- 23.04.2008 --(end)---
                ,i_pType, i_pSubType, �pCur--->><<--
                ,null, ivCdhDocId, null, null
                ,null
-- (ubrr) (���������) Samokaev R.V. --- 23.04.2008 --(begin)--- ��� ��������� ������������� � ����������� �� �����������
                ,decode(ipType,1,iwarrantor,null)
-- (ubrr) (���������) Samokaev R.V. --- 23.04.2008 --(end)---
                );


    -->> 23.10.2019 ������ �.�. [19-67365] ���������� - TUTDF ������ 6.01 (29.10.19)
    if i_pType = 225 then
    ubrr_bki_uid.SAVE_CZOPORUCH_UID(
        OP_NCZOAGRID  => npAgrid,
        OP_NCZOPORUCH => num_cus);
    end if;
    -->> 23.10.2019 ������ �.�. [19-67365] ���������� - TUTDF ������ 6.01 (29.10.19)

    CDUTIL_ZO.Set_CZO_IPARAM(IDCZO, 'QUALITY', ipQuality, dvDate);

    SELECT S_CZH.nextval
    into   IDCZH
    from   sys.dual;

    SELECT USER
    INTO   IDCZHOPERATOR
    FROM   DUAL;

    INSERT INTO CZH
                (ICZH, CCZHOPERATOR, DCZHDATE, NCZHSUMMA, CCZHCOMMENT
                ,NCZHCZO, MCZHSUMLIQUID)
    VALUES      (IDCZH, IDCZHOPERATOR, dvDate, mpSum, '����� �����������'
                ,IDCZO, decode(mpQSum,0,mpSum,mpQSum));--->>>>>>><<<<<--

-- >>> ����� �.�. 06.02.2012 (12-345)
    if mpMrktSum is not null and mpMrktSum > 0 then
        insert into CZHM
                    ( NCZHMCZO, DCZHMDATE, MCZHMSUM, NCZHMBS )
        values      ( IDCZO,    dvDsnDate, mpMrktSum, 0 );

    end if;
-- <<< ����� �.�. 06.02.2012 (12-345)
    cpErrorMsg    := char_to_sap('OK');

    return;
  exception when others then
      cpErrorMsg    := char_to_sap('�: '||to_char(npAgrid)||to_char(iiwarrantor)||'-'||to_char(num_cus)|| sqlerrm);
--    cpErrorMsg    := char_to_sap(sqlerrm);
      return;
  end;


  ---->>>>>>Lobik D.A. ubrr 28.12.2005
  procedure CreateNewMaturity(
    npAgrid      in       number   -- �������� ����� ��������
   ,mpSum        in       number   -- ����� ��������
   ,dpDate       in       varchar2 -- ���� ��������
   -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
   --,cpErrorMsg   in out   varchar2 -- ��������� �� ������
   ,cpErrorMsg  out       varchar2 -- ��������� �� ������
   --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                                  )
  is
     cnt number:=0;-->>><<<����� �.�. 05.03.2007 �� �/� ��������� �.�. �� 26.02.2007
     dvDate date;
  begin
    ---->>>����� �.�. 05.03.2007 �� �/� ��������� �.�. �� 26.02.2007
    /*
      --if mpSum<0 then
         --delete from cdr where ncdragrid=npAgrid;
      --else
         --��� ������ ������ ��� ����� ���� ����������
         insert into cdr
         select npAgrid,1,dpDate,mpSum
         from dual
         where not exists (select '*'
                           from cdr
                           where ncdragrid=npAgrid
                                 and icdrpart=1
                                 and dcdrdate=dpDate
                          );
         --������ ����� ����� ����������� ��������
         update cdr
         set mcdrsum=mpSum
         where ncdragrid=npAgrid
               and icdrpart=1
               and dcdrdate=dpDate;
    */
-- ����� �.�. 22.10.2010 ������� �� ������ �������� �������� � ������� ������ (begin)
    BEGIN
      select   decode( dpDate, '00000000', null, to_date(dpDate, 'YYYYMMDD') )
        into dvDate
        from DUAL;
    EXCEPTION WHEN OTHERS THEN
        dvDate := null;
    END;
-- ����� �.�. 22.10.2010 ������� �� ������ �������� �������� � ������� ������ (end)
    begin--��� ������ � cdr �� ���� ������ ���������
        select count(*)
        into cnt
        from cda
        where cda.ncdaagrid=npAgrid
              and cda.icdaisline=1
              and icdalinetype=2 ---���������
        ;
        if cnt = 0 then --��� ������� - �� �������� �����������
             --if mpSum<0 then
                --delete from cdr where ncdragrid=npAgrid;
             --else
             --��� ������ ������ ��� ����� ���� ����������
             insert into cdr
--             select npAgrid,1,dpDate,mpSum
             select npAgrid,1,dvDate,mpSum,dvDate
             from dual
             where not exists (select '*'
                               from cdr
                               where ncdragrid=npAgrid
                                     and icdrpart=1
                                     and dcdrdate=dvDate
                              );
             --������ ����� ����� ����������� ��������
             update cdr
             set mcdrsum=mpSum
             where ncdragrid=npAgrid
                   and icdrpart=1
                   and dcdrdate=dvDate;
           /*--��� ������,��. ����
             insert into cdr
                         (ncdragrid, icdrpart, dcdrdate, mcdrsum)
             values      (npAgrid  ,        1,   dpDate, mpSum);
          */
          --end if;
        end if;--if cnt = 0
    exception when others then
            null;
    end;
    ---<<<����� �.�. 05.03.2007 �� �/� ��������� �.�. �� 26.02.2007

      cpErrorMsg    := char_to_sap('OK');
      return;
  exception
    when others then
      cpErrorMsg    := char_to_sap('CreateNewMaturity: ' || sqlerrm);
      return;
  end;--CreateNewMaturity
  ----<<<<<Lobik D.A. ubrr 28.12.2005

  procedure Add_SchedPayPrc(
    npAgrid      in       number   -- �������� ����� ��������
   ,dpDateClc    in       varchar2 -- ���� ���������� %
   ,dpDatePay    in       varchar2 -- ���� ������ %
   -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
   --,cpErrorMsg   in out   varchar2 -- ��������� �� ������
   ,cpErrorMsg  out       varchar2 -- ��������� �� ������
   --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                                  )
  is
      cnt       number:=0;
      dvDateClc date;
      dvDatePay date;
  begin
-- ����� �.�. 22.10.2010 ������� �� ������ �������� �������� � ������� ������ (begin)
  -- ����������� ����
    BEGIN
      select   decode( dpDateClc, '00000000', null, to_date(dpDateClc, 'YYYYMMDD') ),
               decode( dpDatePay, '00000000', null, to_date(dpDatePay, 'YYYYMMDD') )
        into dvDateClc,
             dvDatePay
        from DUAL;
    EXCEPTION WHEN OTHERS THEN
        dvDateClc := null;
        dvDatePay := null;
    END;
-- ����� �.�. 22.10.2010 ������� �� ������ �������� �������� � ������� ������ (end)
    select count(*) into cnt from CDS
     where NCDSAGRID = npAgrid and DCDSINTCALCDATE = dvDateClc;
    if cnt = 0 then
     insert into CDS (NCDSAGRID, DCDSINTCALCDATE, DCDSINTPMTDATE)
     values (npAgrid, dvDateClc, dvDatePay);
    end if;
    cpErrorMsg := char_to_sap('OK');
    return;
  exception
    when others then
      cpErrorMsg    := char_to_sap( sqlerrm);
      return;
  end;


  PROCEDURE calc_interval(npAgrid      in     number
                         ,dpFirstNach  in     date
                         ,dpFirstPay   in     date
                         ,spErrMessage in out varchar2)
  is

    LSdate      date :=CD.get_LSdate;--������� ����
    dStart      date; --���� ������ ��������� (������� ���� ������ ��������)
    dFinish     date;
    tpDayOff    number:=1; -- ���� ����������� ����
                            --  0 - �� ���������
                            --  -1 - �������� �� �����
                            --  1 - �������� �� �����
    isCorDayOff number:=0; -- ��������� ��� ����� �������� ����
--

    dFirstN     date := dpFirstNach;
    dFirstPay   date := dpFirstPay;

    nn          number := 1;
    nnmax       number := 500;
    rm          number := 0;
    rd          number := 0;
    rdm         number := 0;
    rdc         number := 0;
    rm_N        number := 0;
    rd_N        number := 0;
    rdm_N       number := 0;
    rdc_N       number := 0;
    sm          number;
    dFirst      date;
    dFirst_N    date;
    dPay        date;
    dPay_N      date;

    Date_Choice number;
    Yes_No_Comm varchar2(100);

    FUNCTION getdPay(dFirst_F date, rd_F number,sm_F number,rdc_F number, rm_F number,rdm_F number)
    RETURN date IS
         dPay_F date;
         last_day_month date;
    BEGIN
                dPay_F := ADD_MONTHS(dFirst_F,rm_F)+rdm_F-1;
                last_day_month := LAST_DAY(ADD_MONTHS(dFirst_F,rm_F));
                if dPay_F > last_day_month then
                   dPay_F := last_day_month;
                end if;
        RETURN  dPay_F;
    END;-- getdPay()

  begin

    BEGIN
      Select dcdvENDDATE into dFinish from vcda where ncdvAGRID=npAgrid;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       dFinish := NULL;
    END;


  BEGIN
    Select dcdvSIGNDATE into dStart from vcda where ncdvAGRID=npAgrid;
    EXCEPTION
    WHEN OTHERS THEN
      dStart:=null;
  END;

  Date_Choice := 0;
  delete from cds where NCDSAGRID=npAgrid and DCDSINTCALCDATE>=dStart /*or DCDSINTPMTDATE>=dStart) �������, ��� ��������� ��������� ������� ������ �� ���� ����������!*/;

  nn  := 1;

  dFirst := TRUNC(dFirstPay,'MON');
  dFirst_N := TRUNC(dFirstN,'MON');
  sm := 1;

  rd  := dFirstPay-dFirst - 10*rdc;
  rm  := TRUNC(MONTHS_BETWEEN(dFirstPay,dFirst));
  rdm := to_number(to_char(dFirstPay,'DD'));

  rd_N  := dFirstN-dFirst_N - 10*rdc_N;
  rm_N  := TRUNC(MONTHS_BETWEEN(dFirstN, dFirst_N));
  rdm_N := to_number(to_char(dFirstN,'DD'));

--dbms_output.put_line('1');
--dbms_output.put_line(dFirstN);

  IF (dFirstN = LAST_DAY(dFirstN)) AND (rdm_N < 31) THEN
--       Yes_No_Comm := '������� ���� ������� ���������� '||to_char(dFirstN,'DD.MM.YYYY')||' ��������� ���� ������?';
    rdm_N := 31;
  END IF;
--       Yes_No_Comm := '������� ���� ������ ������ '||to_Char(dFirstPay,'DD.MM.YYYY')||' ��������� ���� ������?';
  IF (dFirstPay = LAST_DAY(dFirstPay)) AND (rdm < 31) THEN
    rdm := 31;
  END IF;

  <<loop_Pay>>
    LOOP
      dPay := getdPay(dFirst,rd,sm,rdc,rm,rdm);
      dPay_N := getdPay(dFirst_N,rd_N,sm,rdc_N,rm_N,rdm_N);

      dFirstN:=dPay_N;
      dFirstPay := dPay;
--dbms_output.put_line('2');
--dbms_output.put_line(dFirstN);
      WHILE not DJ_DATE.Is_Working_Day(dFirstPay) LOOP dFirstPay:=dFirstPay+1; END LOOP;

      if dFinish <= dFirstPay then
        dFirstPay := dFinish;
      end if;
      if dFinish <= dFirstN then
        dFirstN := dFinish;
      end if;

--dbms_output.put_line('3');
--dbms_output.put_line(dFirstN);

      IF isCorDayOff=1 THEN dFirstN:=dFirstPay; END IF;
--msg(to_char(dPay)||' '||cc||' to->'||to_char(dFirstN)||' pay->'||to_char(dFirstPay));

      IF dFirstN>=dStart and dFirstPay>=dStart THEN
        INSERT INTO cds (ncdsAGRID, dcdsINTCALCDATE, dcdsINTPMTDATE)
          VALUES ( npAgrid, dFirstN, dFirstPay);
      END IF;

      IF dFirstN>=dFinish /*OR dFirstPay>=dFinish*/ THEN
        EXIT;
      END IF;
        -- ��� �����
      IF nn >= nnmax THEN
        spErrMessage :='���������� �� ����������� �� ���������� �������� (>500)!';
        EXIT;
      ELSE
        nn:=nn+1;
           dFirst := ADD_MONTHS(dFirst,sm);
           dFirst_N := ADD_MONTHS(dFirst_N,sm);
      END IF;

    END LOOP;-- loop_Pay;

  exception
    when others then
      null;
  end;

--��������� �.�. ������� �������� �������� �� ������ � ���
 PROCEDURE Change_BKI_REQUEST ( ipAgrId   in number,
                                is_IN_BKI in varchar2,
                                dpCrIn    in varchar2,
                                cpABS     in varchar2,
                                -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                                --cpErrMsg   in out   varchar2 -- ��������� �� ������
                                cpErrMsg  out       varchar2 -- ��������� �� ������
                                --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
 )
 is
    cvLastIdSmr  smr.idsmr%type;
    cvErrMsg     varchar2(1024):='OK';
    dvCrIn       date;
    LOCKED EXCEPTION;
    PRAGMA EXCEPTION_INIT(LOCKED, -54);
 begin
   cvLastIdSmr := ubrr_get_context;
   XXI_CONTEXT.Set_IDSmr (cpABS);
   begin
       select decode( dpCrIn , '00000000', null, to_date(dpCrIn , 'YYYYMMDD') )
        into dvCrIn
        from dual;
   exception when others then
       dvCrIn := null;
   end;
   begin
      if dvCrIn is not null then
         cdterms.Update_History(ipAgrId, 1, 'UBRR_BKI', dvCrIn, null, null, null, is_IN_BKI);
      else
         delete cdh
          where ncdhAGRID=ipAgrId
            AND icdhPART=1
            AND ccdhTERM='UBRR_BKI';
      end if;
   exception
   when no_data_found then
      cvErrMsg := '������� �'||ipAgrId||' �� ���������';
   when locked then
      cvErrMsg:= '������� �'||ipAgrId||' ������������';
   end;
   XXI_CONTEXT.Set_IDSmr (cvLastIdSmr);
   cpErrMsg := char_to_sap(cvErrMsg);
 exception when others then
   cpErrMsg := char_to_sap(sqlerrm);
   return;
 end;

-- ���� �.�. �������� ������� �� ���
  PROCEDURE Change_CrInfo (ipAgrId  in      number,
                           ipCrOut  in      number,
                           dpCrOut  in      varchar2,
                          --dpCrOut   in      date,
                           cpBKIId  in      varchar2,
                           cpAbs    in      varchar2,
                           -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                           --,cpErrMsg   in out   varchar2 -- ��������� �� ������
                           cpErrMsg  out       varchar2 -- ��������� �� ������
                           --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                           )
  is
    ivExists     number;
    cvIdSmr      varchar2(3);
    cvLastIdSmr  varchar2(3);
    cvErrMsg     varchar2(1024):='OK';
    cvBKIId      varchar2(32);
    cvCrOut      varchar2(1);
    dvCrOut      date;
    LOCKED EXCEPTION;
    PRAGMA EXCEPTION_INIT(LOCKED, -54);
  begin
/*    if cpABS = '0' THEN
       cvIdSmr := '1';
    elsif cpABS = '4' THEN
       cvIdSmr := '2';
    END IF;*/

    if ipCrOut = 1 then
        cvCrOut := '1';
        -- ����� �.�. 22.10.2010 ������� �� ������ �������� �������� � ������� ������
        --dvCrOut := dpCrOut;
        dvCrOut := to_date(dpCrOut, 'YYYYMMDD');
        cvBKIId := char_convert.char_from_sap(cpBKIId);
    else
        cvCrOut := '0';
        dvCrOut := NULL;
        cvBKIId := NULL;
    end if;

    cvLastIdSmr := ubrr_get_context;
-- ���� �.�. 03.02.2009 � 5041-05/001797 ������ cpABS ��� ������� idSmr
    XXI_CONTEXT.Set_IDSmr (cpABS);

    begin
        select 1
          into ivExists
          from cda
         where ncdaagrid = ipAgrId
         FOR UPDATE NOWAIT;
        update cda
           set ccdacrinfo = cvCrOut, --�������� �������� � ���
               dcdacrinfdate = dvCrOut, --���� ��������
               ccdacrinfocode = cvBKIId --��� �������� ��������� �������
         where ncdaagrid = ipAgrId;
        if dvCrOut is not null then
            cdterms.Update_History(ipAgrId, 1, 'CDCRINF' , dvCrOut, null, null, null, cvBKIId);
        else
            delete cdh
             where ncdhAGRID=ipAgrId
               AND icdhPART=1
               AND ccdhTERM in ('CDCRINF'); --, 'AGR_NBKI', 'AGR_OKB', 'AGR_EQV'); -->><< ����� �.�. 01.08.2016
        end if;
-->> ����� �.�. 01.08.2016 ����� ������ ���� ������ ���
        begin
            select 1
                into ivExists
                from xxi.cdh
                where ncdhagrid = ipAgrId
                and   ccdhterm = 'AGR_NBKI';
        exception when no_data_found then
            cdterms.Update_History(ipAgrId, 1, 'AGR_NBKI', dvCrOut, null, null, 1,    null);
        end;
        begin
            select 1
                into ivExists
                from xxi.cdh
                where ncdhagrid = ipAgrId
                and   ccdhterm = 'AGR_OKB';
        exception when no_data_found then
            cdterms.Update_History(ipAgrId, 1, 'AGR_OKB', dvCrOut, null, null, 1,    null);
        end;
        begin
            select 1
                into ivExists
                from xxi.cdh
                where ncdhagrid = ipAgrId
                and   ccdhterm = 'AGR_EQV';
        exception when no_data_found then
            cdterms.Update_History(ipAgrId, 1, 'AGR_EQV', dvCrOut, null, null, 1,    null);
        end;
--<< ����� �.�. 01.08.2016 ����� ������ ���� ������ ���
    exception when no_data_found then
        cvErrMsg := '������� �'||ipAgrId||' �� ���������';
              when locked then
        cvErrMsg := '������� �'||ipAgrId||' ������������';
    end;
    XXI_CONTEXT.Set_IDSmr (cvLastIdSmr);
    cpErrMsg := char_to_sap(cvErrMsg);
    return;
  exception when others then
    cpErrMsg := char_to_sap(sqlerrm);
    return;
  end;

--����� �. �������� �������������� �� ������� �������
  procedure Change_CuratorID (npAgrid      in       number,     -- �������� ����� ��������)
                              npCuratorID  in       number,     -- ID ��������
                              -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                              --cpErrorMsg   in out   varchar2 -- ��������� �� ������
                              cpErrorMsg  out       varchar2 -- ��������� �� ������
                              --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                              )
  is
      cnt number:=0;
  begin
    update xxi."cda" set   NCDACURATORID = npCuratorID
                     where NCDAAGRID     = npAgrid;
    commit;
    cpErrorMsg := char_to_sap('OK');
    return;
  exception when others then
    cpErrorMsg    := char_to_sap(sqlerrm);
    return;
  end;

  --->>>ubrr ���������� �.�. 2010/03/23 10-301 (����� �.�.)
  ----------------------------------------------------------------------------------------------
  -- ������� ����������� ����. ������ �������� �� ���� (��������� ����������� � ���������� ������ ������������ �����������)
  -- c_IsCorrect = NULL , ���� ����. ����� ��������� ����������
  -- c_IsCorrect = 'X'  , ���� ��� ����������� � ������������ ������� �������

   PROCEDURE Get_AgrID (i_agr       in  number,
                        onDate      in  date,
                        i_is_line   in  number,
                        n_agrnum    OUT xxi.cda.ncdaagrid%type,
                        c_IsCorrect OUT char)
   IS
      --n_pcdhpval xxi.cdh.pcdhpval%type:=0;
      v_i    PLS_INTEGER := 0;
   BEGIN
     c_IsCorrect := NULL;
     n_agrnum := 0;
     FOR r_cdh IN (
        SELECT a.ncdaagrid, a.icdastatus,
                    sign(nvl(cdbalance.get_cursaldo (a.ncdaagrid,
                                               1, -- �������� �������������
                                               NULL, --IPART
                                               NULL,
                                               onDate -- �� ����
                                              ),0)
                       + nvl(cdbalance.get_cursaldo (a.ncdaagrid,
                                               5, -- ������������ �������������
                                               NULL,--IPART
                                               NULL,
                                               onDate -- �� ����
                                              ),0)
                  )
              debt,
              sign((
              select nvl(sum(decode(icdetype,65,mcdesum,66,-mcdesum)),0)
                from cde
               where cde.icdetype in (65,66)
                 and cde.ncdeagrid = a.ncdaagrid
                 and cde.dcdedate <= onDate)
               )
               lim,
                    (select nvl(pcdhpval,0)
                from   xxi.cdh
                where      ncdhagrid = a.ncdaagrid
                       --and icdhpart  = i_tranche
                       and ccdhterm  = 'INTRATE'
                       and dcdhdate  =(select max(h.dcdhdate)
                                       from xxi.cdh h
                                       where h.ncdhagrid=a.ncdaagrid
                                           --and h.icdhpart = i_tranche
                                           and h.ccdhterm = 'INTRATE'
                                           and h.dcdhdate <= onDate
                                    )
                    and rownum=1) pcdhpval

        FROM xxi."cda" a
        WHERE --trunc(a.ncdaagrid) = trunc(i_agr)
              a.ncdaagrid BETWEEN trunc(i_agr) AND trunc(i_agr)+0.99
          AND a.icdastatus = 2 -- ������ ������������� �����������
          AND a.icdaisline between nvl(i_is_line, 0) and 1
        ORDER BY debt desc, lim desc, ncdaagrid desc
     ) LOOP
        IF v_i = 0 THEN
          n_agrnum := r_cdh.ncdaagrid;
          v_i := v_i + 1;
          EXIT;
        END IF;
     END LOOP;

     IF v_i = 0 THEN
       c_IsCorrect := 'X'; -- ��� ����������� �������
     END IF;

   EXCEPTION
      WHEN others THEN
          c_IsCorrect := NULL;
          n_agrnum := -1;
   END Get_AgrID;
  ---<<<ubrr ���������� �.�. 2010/03/23 10-301 (����� �.�.)

  --->>>ubrr �������� �.�. 2010/12/06 10-876
  /* ��� ������ ������� ������ � �������� ������ % �������
     ����� ���������� ������ ����������/������ % ������� � ���� ���������� ��������
     �� ���� ���������� %, ������� <= ������� ������ % �������
  */
   procedure Clear_SchedPayPrcForAdvance(npAgrid                 in     number
                                        ,dSAPDayOfPay            in     varchar2
                                        --���� ������ ������ %
                                        ,dSAPDayOfPrc            in     varchar2
                                        --���� ���������� % ������� (��)
                                        -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                                        --,cpErrorMsg   in out   varchar2 -- ��������� �� ������
                                        ,cpErrorMsg  out       varchar2 -- ��������� �� ������
                                        --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                                        )
   IS
    dDayOfPay           date; --���� ������ ������ %
    dDayOfPrc           date; --���� ���������� % ������� (��)
   BEGIN
    BEGIN
      select   decode( dSAPDayOfPrc, '00000000', null, to_date(dSAPDayOfPrc, 'YYYYMMDD') )
        into dDayOfPrc
        from DUAL;
     EXCEPTION WHEN OTHERS THEN
       dDayOfPrc := null;
    END;
    BEGIN
      select   decode( dSAPDayOfPay, '00000000', null, to_date(dSAPDayOfPay, 'YYYYMMDD') )
        into dDayOfPay
        from DUAL;
     EXCEPTION WHEN OTHERS THEN
       dDayOfPay := null;
    END;
     BEGIN
       update CDS
           SET DCDSINTPMTDATE =  dDayOfPay
           where NCDSAGRID = npAgrid
             and DCDSINTCALCDATE <= dDayOfPrc
       ;
       cpErrorMsg := char_to_sap('OK');
       return;
      EXCEPTION
       WHEN NO_DATA_FOUND THEN
        cpErrorMsg := char_to_sap('OK');
     END;

    exception
     when others then
      cpErrorMsg    := char_to_sap( sqlerrm);
      return;

   END Clear_SchedPayPrcForAdvance;
  ---<<<ubrr �������� �.�. 2010/12/06 10-876

  --->>>ubrr �������� �.�. 2011/01/24 11-206.2
  /* �������� ������ � ������� ��������� ������
     (���� ���� 00000000 - ��������� ��� ������ � �������,
      ���� ���� �������� - ����������� ����� ������)
  */
   procedure Add_SchedLim(
       npAgrid      in       number   -- �������� ����� ��������
      ,dpDateLim    in       varchar2 -- ���� ������ ������� ��������� ������
      ,npAmountLim  in       number   -- �������� ������ � ����
      -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
      --,cpErrorMsg   in out   varchar2 -- ��������� �� ������
      ,cpErrorMsg  out       varchar2 -- ��������� �� ������
      --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                       )
   IS
    dDayOfLim           date; --���� ������ ������� ��������� ������
   BEGIN
     if dpDateLim = '00000000' then
--     ������ ��� ������ ���� 'LIMIT'
       BEGIN
         delete CDH where ncdhagrid = npAgrid and icdhpart = 1 and ccdhterm = 'LIMIT';

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             cpErrorMsg := char_to_sap('OK');
       END;
       cpErrorMsg := char_to_sap('OK');
     else
--     ������� ����� ������ ���� 'LIMIT'
       BEGIN
         select   decode( dpDateLim, '00000000', null, to_date(dpDateLim, 'YYYYMMDD') )
           into dDayOfLim
           from DUAL;
        EXCEPTION WHEN OTHERS THEN
          dDayOfLim := null;
       END;

       CD.Update_History(npAgrid, 1, 'LIMIT' , dDayOfLim, npAmountLim, null, null, null);

       cpErrorMsg := char_to_sap('OK');
     end if;

     exception
       when others then
         cpErrorMsg    := char_to_sap( sqlerrm);
         return;
   END Add_SchedLim;
  ---<<<ubrr �������� �.�. 2011/01/24 11-206.2
  -- >>> ����� �.�. 01.11.2011 (11-859)
  --    ��������� �������� SMS
   PROCEDURE Send_SMS
                (
                 cpSMS_Phone IN     varchar2                 --����� �������� ���������� (��������,79226093222)
                ,cpSMS_Body  IN     varchar2                 --����� ��������� �� 1000 ��������
                -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                --,cpErrorMsg  IN OUT varchar2                 -- ��������� �� ������
                --,cpSMS_Time  IN OUT varchar2                 -- ����� �������� ���������
                ,cpErrorMsg OUT varchar2                 -- ��������� �� ������
                ,cpSMS_Time OUT varchar2                 -- ����� �������� ���������
                --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                -->> 08.07.2020 ������ �.� [19-59018] ���������� �������� ���- E-Mail-����������� ����� � ���
                ,npVuz       IN     number default 0
                --<< 08.07.2020 ������ �.� [19-59018] ���������� �������� ���- E-Mail-����������� ����� � ���
                )
   IS
        cvSMS_Body  VARCHAR2(1000);
        cvSMS_Time  ubrr_shm_tab_sms.DSMS_CREATE%type;
   BEGIN
        cvSMS_Body := sap_2_char(cpSMS_Body,1000);
        begin
            -->> 08.07.2020 ������ �.� [19-59018] ���������� �������� ���- E-Mail-����������� ����� � ���
            if npVuz = 1 then
               UBRR_SEND.Send_SMS(cpSMS_Phone,cvSMS_Body,9);
            else
                UBRR_SEND.Send_SMS(cpSMS_Phone,cvSMS_Body);
            end if;
            --UBRR_SEND.Send_SMS(cpSMS_Phone,cvSMS_Body);
            --<< 08.07.2020 ������ �.� [19-59018] ���������� �������� ���- E-Mail-����������� ����� � ���
            begin
                select DSMS_CREATE into cvSMS_Time
                    from ubrr_shm_tab_sms
                    where CSMS_PHONE = cpSMS_Phone
                      and CSMS_BODY  = cvSMS_Body
                      and CSMS_USER  = 'T_SAPLINK';
            exception
                when others then
                    cpErrorMsg := char_to_sap('SMS �� ��������');
                    cpSMS_Time := to_char(sysdate,'HH24MISS');
                    return;
            end;
            cpErrorMsg := char_to_sap('OK');
            cpSMS_Time := to_char(cvSMS_Time,'HH24MISS');
        exception
            when others then
                cpErrorMsg := char_to_sap( sqlerrm);
                cpSMS_Time := to_char(sysdate,'HH24MISS');
        end;
   END Send_SMS;
-- �������� ����� ����� ������� �������������
   PROCEDURE SEND_MAIL
     (
       Adres        IN      VARCHAR2  -- ����� ���������� ��������� 50
      ,Subject      IN      VARCHAR2  -- ���� ��������� 50
      ,Message      IN      VARCHAR2  -- ���������  2000
      ,cpErrorMsg   IN OUT  varchar2  -- ��������� �� ������
      ,cpEMAIL_Time IN OUT  varchar2  -- ����� �������� ���������
      -->> 08.07.2020 ������ �.� [19-59018] ���������� �������� ���- E-Mail-����������� ����� � ���
      ,npVuz       IN     number default 0
      --<< 08.07.2020 ������ �.� [19-59018] ���������� �������� ���- E-Mail-����������� ����� � ���
      )
   IS
        cvMAIL_Adres    VARCHAR2(50);
        cvMAIL_Subject  VARCHAR2(50);
        cvMAIL_Body     VARCHAR2(2000);
        cvMAIL_Time    ABRR_MAIL.DDAT%type;
   BEGIN
        cvMAIL_Adres    := sap_2_char(Adres,   50  );
        cvMAIL_Subject  := sap_2_char(Subject, 50  );
        cvMAIL_Body     := sap_2_char(Message, 2000);
        begin
             -->> 08.07.2020 ������ �.� [19-59018] ���������� �������� ���- E-Mail-����������� ����� � ���
            if npVuz = 1 then
                UBRR_SEND.SET_VUZ(1);
            else
                UBRR_SEND.SET_VUZ(null);
            end if;
            --<< 08.07.2020 ������ �.� [19-59018] ���������� �������� ���- E-Mail-����������� ����� � ���
            UBRR_SEND.Send_MAIL(cvMAIL_Adres,cvMAIL_Subject, cvMAIL_Body);
            begin
                select DDAT into cvMAIL_Time
                    from ABRR_MAIL
                    where C_MAIL    = cvMAIL_Adres
                      and C_SUBJECT = cvMAIL_Subject
                      and CMSG      = cvMAIL_Body
                      and CUSR      = 'T_SAPLINK';
            exception
                when others then
                    cpErrorMsg   := char_to_sap('��������� �� ��������');
                    cpEMAIL_Time := to_char(sysdate,'HH24MISS');
                    return;
            end;
            cpErrorMsg   := char_to_sap('OK');
            cpEMAIL_Time := to_char(cvMAIL_Time,'HH24MISS');
        exception
            when others then
                cpErrorMsg   := char_to_sap( sqlerrm);
                cpEMAIL_Time := to_char(sysdate,'HH24MISS');
        end;
   END SEND_MAIL;
   PROCEDURE Change_SMS_Agr (ipAgrId     in      number,
                             dpSMS_AGR   in      varchar2,
                             cpSMS_AGR   in      varchar2,
                             cpSMS_INF   in      varchar2,
                             cpEMAIL_AGR in      varchar2,
                             cpEMAIL_INF in      varchar2,
                             -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                             --cpErrMsg   in out   varchar2 -- ��������� �� ������
                             cpErrMsg  out       varchar2 -- ��������� �� ������
                             --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                             )
   IS
        cvSMS_AGR   number;
        cvSMS_INF   varchar2(11);
        cvEMAIL_AGR number;
        cvEMAIL_INF varchar2(50);
        dvSMS_AGR   date;
   BEGIN
        cpErrMsg := char_to_sap( 'OK' );
-- ������� �������� �� SMS-��������������
        begin
            select icdhival, dcdhDATE into cvSMS_AGR, dvSMS_AGR from cdh
                where ncdhAGRID = ipAgrId
                  and icdhPART  = 1
                  and ccdhTERM  = 'UBRRSMSA'
                  and rownum    = 1
            order by dcdhDATE desc;
        exception when others then
            cvSMS_AGR := null;
            dvSMS_AGR := null;
        end;
        if cvSMS_AGR is null then
                   INSERT INTO CDH(ncdhAGRID
                                 , icdhPART
                                 , dcdhDATE
                                 , ccdhTERM
                                 , ICDHIVAL)
                       VALUES ( ipAgrid
                              , 1
                              , to_date(dpSMS_AGR, 'YYYYMMDD')
                              , 'UBRRSMSA'
                              , decode(cpSMS_AGR, 'Y', 1, 0)
                               );
        else
          if ( nvl(cvSMS_AGR, 2) = 1 and cpSMS_AGR = 'N' )
                or
             ( nvl(cvSMS_AGR, 2) = 0 and cpSMS_AGR = 'Y' ) then
            begin
                if to_char(nvl(dvSMS_AGR, to_date('01.01.0001', 'DD.MM.YYYY')), 'YYYYMMDD') <> dpSMS_AGR then
                   INSERT INTO CDH(ncdhAGRID
                                 , icdhPART
                                 , dcdhDATE
                                 , ccdhTERM
                                 , ICDHIVAL)
                       VALUES ( ipAgrid
                              , 1
                              , to_date(dpSMS_AGR, 'YYYYMMDD')
                              , 'UBRRSMSA'
                              , decode(cpSMS_AGR, 'Y', 1, 0)
                               );
                else
                   UPDATE cdh SET ICDHIVAL = decode(cpSMS_AGR, 'Y', 1, 0)
                        WHERE ncdhAGRID = ipAgrid
                          AND icdhPART  = 1
                          AND dcdhDATE  = dvSMS_AGR
                          AND ccdhTERM  = 'UBRRSMSA';
                end if;
            EXCEPTION WHEN OTHERS THEN
               cpErrMsg := char_to_sap( sqlerrm);
               return;
            end;
          end if;
        end if;
-- ������� ��� SMS-��������������
        begin
            select ccdhcval, dcdhDATE into cvSMS_INF, dvSMS_AGR from cdh
                where ncdhAGRID = ipAgrId
                  and icdhPART  = 1
                  and ccdhTERM  = 'UBRR_SMS'
                  and rownum    = 1
            order by dcdhDATE desc;
        exception when others then
            cvSMS_INF := null;
            dvSMS_AGR := null;
        end;
        if dvSMS_AGR is null then
                   INSERT INTO CDH(ncdhAGRID
                                 , icdhPART
                                 , dcdhDATE
                                 , ccdhTERM
                                 , CCDHCVAL)
                       VALUES ( ipAgrid
                              , 1
                              , to_date(dpSMS_AGR, 'YYYYMMDD')
                              , 'UBRR_SMS'
                              , char_convert.char_from_sap(cpSMS_INF)
                               );
        else
          if nvl(cvSMS_INF,'') <> char_convert.char_from_sap(cpSMS_INF) then
            begin
                if to_char(nvl(dvSMS_AGR, to_date('01.01.0001', 'DD.MM.YYYY')), 'YYYYMMDD') <> dpSMS_AGR then
                   INSERT INTO CDH(ncdhAGRID
                                 , icdhPART
                                 , dcdhDATE
                                 , ccdhTERM
                                 , CCDHCVAL)
                       VALUES ( ipAgrid
                              , 1
                              , to_date(dpSMS_AGR, 'YYYYMMDD')
                              , 'UBRR_SMS'
                              , char_convert.char_from_sap(cpSMS_INF)
                               );
                else
                   UPDATE cdh SET CCDHCVAL = char_convert.char_from_sap(cpSMS_INF)
                        WHERE ncdhAGRID = ipAgrid
                          AND icdhPART  = 1
                          AND dcdhDATE  = dvSMS_AGR
                          AND ccdhTERM  = 'UBRR_SMS';
                end if;
            EXCEPTION WHEN OTHERS THEN
               cpErrMsg := char_to_sap( sqlerrm);
               return;
            end;
          end if;
        end if;
-- ������� �������� �� E-mail-��������������
        begin
            select icdhival, dcdhDATE into cvEMAIL_AGR, dvSMS_AGR from cdh
                where ncdhAGRID = ipAgrId
                  and icdhPART  = 1
                  and ccdhTERM  = 'UBRREMLA'
                  and rownum    = 1
            order by dcdhDATE desc;
        exception when others then
            cvEMAIL_AGR := null;
            dvSMS_AGR := null;
        end;
        if cvEMAIL_AGR is null then
                   INSERT INTO CDH(ncdhAGRID
                                 , icdhPART
                                 , dcdhDATE
                                 , ccdhTERM
                                 , ICDHIVAL)
                       VALUES ( ipAgrid
                              , 1
                              , to_date(dpSMS_AGR, 'YYYYMMDD')
                              , 'UBRREMLA'
                              ,decode(cpEMAIL_AGR, 'Y', 1, 0)
                               );
        else
          if ( nvl(cvEMAIL_AGR, 2) = 1 and cpEMAIL_AGR = 'N' )
                or
             ( nvl(cvEMAIL_AGR, 2) = 0 and cpEMAIL_AGR = 'Y' )
          then
            begin
                if to_char(nvl(dvSMS_AGR, to_date('01.01.0001', 'DD.MM.YYYY')), 'YYYYMMDD') <> dpSMS_AGR then
                   INSERT INTO CDH(ncdhAGRID
                                 , icdhPART
                                 , dcdhDATE
                                 , ccdhTERM
                                 , ICDHIVAL)
                       VALUES ( ipAgrid
                              , 1
                              , to_date(dpSMS_AGR, 'YYYYMMDD')
                              , 'UBRREMLA'
                              ,decode(cpEMAIL_AGR, 'Y', 1, 0)
                               );
                else
                   UPDATE cdh SET ICDHIVAL = decode(cpEMAIL_AGR, 'Y', 1, 0)
                        WHERE ncdhAGRID = ipAgrid
                          AND icdhPART  = 1
                          AND dcdhDATE  = dvSMS_AGR
                          AND ccdhTERM  = 'UBRREMLA';
                end if;
            EXCEPTION WHEN OTHERS THEN
               cpErrMsg := char_to_sap( sqlerrm);
               return;
            end;
          end if;
        end if;
-- ����� ��.����� ��� E-mail-��������������
        begin
            select ccdhcval, dcdhDATE into cvEMAIL_INF, dvSMS_AGR from cdh
                where ncdhAGRID = ipAgrId
                  and icdhPART  = 1
                  and ccdhTERM  = 'UBRR_EML'
                  and rownum    = 1
            order by dcdhDATE desc;
        exception when others then
            cvEMAIL_INF := null;
            dvSMS_AGR := null;
        end;
        if dvSMS_AGR is null then
                   INSERT INTO CDH(ncdhAGRID
                                 , icdhPART
                                 , dcdhDATE
                                 , ccdhTERM
                                 , CCDHCVAL)
                       VALUES ( ipAgrid
                              , 1
                              , to_date(dpSMS_AGR, 'YYYYMMDD')
                              , 'UBRR_EML'
                              , char_convert.char_from_sap(cpEMAIL_INF)
                               );
        else
          if nvl(cvEMAIL_INF,'') <> char_convert.char_from_sap(cpEMAIL_INF) then
            begin
                if to_char(nvl(dvSMS_AGR, to_date('01.01.0001', 'DD.MM.YYYY')), 'YYYYMMDD') <> dpSMS_AGR then
                   INSERT INTO CDH(ncdhAGRID
                                 , icdhPART
                                 , dcdhDATE
                                 , ccdhTERM
                                 , CCDHCVAL)
                       VALUES ( ipAgrid
                              , 1
                              , to_date(dpSMS_AGR, 'YYYYMMDD')
                              , 'UBRR_EML'
                              , char_convert.char_from_sap(cpEMAIL_INF)
                               );
                else
                   UPDATE cdh SET CCDHCVAL = char_convert.char_from_sap(cpEMAIL_INF)
                        WHERE ncdhAGRID = ipAgrid
                          AND icdhPART  = 1
                          AND dcdhDATE  = dvSMS_AGR
                          AND ccdhTERM  = 'UBRR_EML';
                end if;
            EXCEPTION WHEN OTHERS THEN
               cpErrMsg := char_to_sap( sqlerrm);
               return;
            end;
          end if;
        end if;
   END Change_SMS_Agr;
-- >>> ����� �.�. 01.11.2011 (11-859)
  --->>>ubrr �������� �.�. 2011/11/15 11-484
  /* ���������� �������� "������������� ������������� ��" ��� �������  */
   procedure Add_Atr_Cus_From_Sap(
       npCus        in       number   -- ����� �������
      ,npIDAtr      in       number   -- ID ��������
      ,�pAtrVal     in       varchar2 -- �������� ��������
      ,dpAtrDate    in       varchar2 -- ���� ������ �������� ��������
      ,cpResult     out      varchar2 -- ��������� �� ������
                                  )
   IS
     cvATR    VARCHAR2(50);
   BEGIN
     BEGIN
       cpResult := char_to_sap(
         ubrr_xxi5.atr_util.add_atr_cus(npCus,npIDAtr,char_convert.char_from_sap(�pAtrVal),to_date(dpAtrDate,'YYYYMMDD'))
       )
      ;
      EXCEPTION WHEN OTHERS THEN
       cpResult := char_to_sap( sqlerrm);
       return;
     END;
   END Add_Atr_Cus_From_Sap;
  /* ���������� �������� "�������� ��" ��� ��. ��������  */
   procedure Add_Atr_Gr_From_Sap(
       npAgr        in       number   -- ����� ��. ��������
      ,npIDAtr      in       number   -- ID ��������
      ,�pAtrVal     in       varchar2 -- �������� ��������
      ,cpResult     out      varchar2 -- ��������� �� ������
                                  )
   IS
   BEGIN
     BEGIN
       cpResult := char_to_sap( ubrr_xxi5.atr_util.add_atr_gr(npAgr,npIDAtr,char_convert.char_from_sap(�pAtrVal)) );
      EXCEPTION WHEN OTHERS THEN
       cpResult := char_to_sap( sqlerrm);
       return;
     END;
   END Add_Atr_Gr_From_Sap;
  ---<<<ubrr �������� �.�. 2011/11/15 11-484
  --->>>ubrr �������� �.�. 2013/03/06 12-965
-- ���� ������������ ���������� ��������
  PROCEDURE Change_AGRSIGNDATE ( ipAgrId   in number,
                                dpSignDate    in varchar2,
                                cpABS     in varchar2,
                                -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                                --cpErrMsg   in out   varchar2 -- ��������� �� ������
                                cpErrMsg  out       varchar2 -- ��������� �� ������
                                --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                               )
 is
    cvLastIdSmr  smr.idsmr%type;
    LOCKED EXCEPTION;
    PRAGMA EXCEPTION_INIT(LOCKED, -54);
 begin
   cpErrMsg :=char_to_sap('OK');
   cvLastIdSmr := ubrr_get_context;
   XXI_CONTEXT.Set_IDSmr (cpABS);
   update xxi."cda"
         set DCDASIGNDATE2 = decode( dpSignDate , '00000000', null, to_date(dpSignDate , 'YYYYMMDD') )
         where NCDAAGRID = ipAgrId
         ;
   XXI_CONTEXT.Set_IDSmr (cvLastIdSmr);
 exception
   when locked then
      cpErrMsg:= char_to_sap('������� �'||ipAgrId||' ������������');
   when others then
      cpErrMsg := char_to_sap(sqlerrm);
   return;
 end;
  ---<<<ubrr �������� �.�. 2013/03/06 12-965

  --->>>ubrr ����� �.�. 2013/05/07 12-1166
 PROCEDURE Change_LIMIT_EXPIRE_DATE ( ipAgrId           in      number,
                                      dpConditionDate   in      varchar2,
                                      dpLimitExpireDate in      varchar2,
                                      cpABS             in      varchar2,
                                      -->>>ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
                                      --cpErrMsg   in out   varchar2 -- ��������� �� ������
                                      cpErrMsg  out       varchar2 -- ��������� �� ������
                                      --<<<ubrr ����� �.�.08.09.2015 #24595 [15-997] SAP R/3: ��������� ���� E7P, EEP
)
 is
    cvLastIdSmr         smr.idsmr%type;
    cvErrMsg            varchar2(1024):='OK';
    dvConditionDate     date;
    dvLimitExpireDate   varchar2(10);
    LOCKED EXCEPTION;
    PRAGMA EXCEPTION_INIT(LOCKED, -54);
 begin
   cvLastIdSmr := ubrr_get_context;
   XXI_CONTEXT.Set_IDSmr (cpABS);
   begin
       select decode( dpConditionDate , '00000000', null, to_date(dpConditionDate , 'YYYYMMDD') )
        into dvConditionDate
        from dual;
   exception when others then
       dvConditionDate := null;
   end;
   begin
       select decode( dpLimitExpireDate ,
                      '00000000', null,
                      to_char( to_date(dpLimitExpireDate , 'YYYYMMDD'), 'DD.MM.YYYY' )
                    )
        into dvLimitExpireDate
        from dual;
   exception when others then
       dvConditionDate := null;
   end;
   begin
      if dvConditionDate is not null and dvLimitExpireDate is not null then
         cdterms.Update_History(ipAgrId, 1, 'DLIMEXP', dvConditionDate, null, null, null, dvLimitExpireDate);
      else
         delete cdh
          where ncdhAGRID=ipAgrId
            AND icdhPART=1
            AND ccdhTERM='DLIMEXP';
      end if;
   exception
   when no_data_found then
      cvErrMsg := '������� �'||ipAgrId||' �� ���������';
   when locked then
      cvErrMsg:= '������� �'||ipAgrId||' ������������';
   end;
   XXI_CONTEXT.Set_IDSmr (cvLastIdSmr);
   cpErrMsg := char_to_sap(cvErrMsg);
 exception when others then
   XXI_CONTEXT.Set_IDSmr (cvLastIdSmr);
   cpErrMsg := char_to_sap(sqlerrm);
   return;
 end;
  ---<<<ubrr ����� �.�. 2013/05/07 12-1166

-- >>> ����� �.�. 25.09.2014 #16715 [14-528.4]
-- ����� � ������ E-mail �� ������� ����� ��� ��������� � �������������
 PROCEDURE Get_UBRR_Email_Address   ( ipCusNum          in      number,
                                      cpSAPLogin        in      varchar2,
                                      cpEmailAddress    in out  varchar2,
                                      cpEmailPassword   in out  varchar2,
                                      cpErrMsg          in out  varchar2
)
is
    cvPartnerNum    UBRR_CRM.ubrr_crm_buh_clients_set.partner%type;
    cvErrMsg        varchar2(100) := '';
begin
    cpEmailAddress  := '';
    cpEmailPassword := '';
    cpErrMsg        := ''; --char_to_sap('OK');
    -- >>> ����� ������ �� � CRM
    begin
        select    partner
            into  cvPartnerNum
            from  UBRR_CRM.ubrr_crm_buh_clients_set
            where clientid = to_char(ipCusNum)
              and rownum   = 1;
    exception
        when NO_DATA_FOUND then
            cpErrMsg        := char_to_sap('01-'||sqlerrm);
            return;
    end;
    -- <<< ����� ������ �� � CRM

    -- >>> ����� ������������ E-mail
    begin
       select distinct
            EMAIL,
            PSWD
          into
            cpEmailAddress,
            cpEmailPassword
          from ubrr_crm_bp_email@uvkl.world
         where partner = cvPartnerNum;
    exception
        when NO_DATA_FOUND then
            cpEmailAddress := '';
        when others        then
            cpErrMsg        := char_to_sap(sqlerrm);
            return;
    end;
    -- <<< ����� ������������ E-mail

    if cpEmailAddress = '' or cpEmailAddress is null then
    -- >>> E-mail �� ������. ���� ��� �������
        begin
            ubrr_crm_bp_email_sign.Set_usr@uvkl.world(
                                    cpSAPLogin );
            ubrr_crm_bp_email_sign.Ins_Email@uvkl.world(
                                    pPartner  => cvPartnerNum,
                                    pSignStat => 1,
                                    pDate     => trunc(sysdate),
                                    pErr      => cvErrMsg );
            if cvErrMsg is not null and cvErrMsg != '' then
                cpErrMsg := '02-01-'||cvErrMsg;
            end if;
            ubrr_crm_bp_email_sign.Open_Email@uvkl.world(
                                    pPartner  => cvPartnerNum,
                                    pErr      => cvErrMsg );
            if cvErrMsg is not null and cvErrMsg != '' then
                if cpErrMsg is not null and cpErrMsg != '' then
                    cpErrMsg := cpErrMsg||' 02-02-'||cvErrMsg;
                else
                    cpErrMsg := '02-02-'||cvErrMsg;
                end if;
            end if;
            commit;
            select distinct
                EMAIL,
                PSWD
              into
                cpEmailAddress,
                cpEmailPassword
              from ubrr_crm_bp_email@uvkl.world
             where partner = cvPartnerNum;
        exception
            when others then
                cpErrMsg := char_to_sap('02-'||sqlerrm);
                return;
        end;
    -- <<< E-mail �� ������. ���� ��� �������
    end if;
    cpEmailPassword := char_to_sap(cpEmailPassword);
    if cpErrMsg != '' then
        cpErrMsg        := char_to_sap(cpErrMsg);
    else
        cpErrMsg        := char_to_sap('OK');
    end if;
end;  --Get_UBRR_Email_Address
-- <<< ����� �.�. 25.09.2014 #16715 [14-528.4]

-- >>> ����� �.�. 26.05.2015 #22087 [15-199]
-- �������� ��� � ��������� ��������
 PROCEDURE Change_PSK ( ipAgrId      in      number,
                        dpDate       in      varchar2,
                        npPSK        in      number,
                        cpInsertOnly in      varchar2,
                        cpErrMsg     in out  varchar2
       )
is
    dvPSKDate   date;
    ivPSKCounts number := 0;
begin
    select count(*)
     into ivPSKCounts
     from xxi."cda"
     where ncdaagrid = ipAgrId;
    if ivPSKCounts = 0 then
        cpErrMsg        := char_to_sap('������� ������ ����� ��������');
        return;
    end if;
    begin
       select decode( dpDate ,
                      '00000000', null,
                      to_date(dpDate , 'YYYYMMDD')
                    )
        into dvPSKDate
        from dual;
    exception when others then
       dvPSKDate := null;
    end;
    if dvPSKDate = null then
        cpErrMsg        := char_to_sap('�� ������� ���� ���');
        return;
    end if;
    begin
        select count(*)
         into ivPSKCounts
         from xxi.cdh
         where ncdhagrid = ipAgrId
         and   icdhpart  = 1
         and   ccdhterm = 'UBRRPSK';
    exception when others then
        ivPSKCounts := 0;
    end;
    if cpInsertOnly = 'X' and ivPSKCounts != 0 then
        cpErrMsg        := char_to_sap('��� ��� ������� � ��������');
        return;
    elsif ivPSKCounts != 0 then
        begin
            select count(*)
             into ivPSKCounts
             from xxi.cdh
             where ncdhagrid = ipAgrId
             and   icdhpart  = 1
             and   ccdhterm = 'UBRRPSK'
             and   dcdhdate  = dvPSKDate;
        exception when others then
            ivPSKCounts := 0;
        end;
    end if;
    if ivPSKCounts = 0 then
        insert into xxi.cdh (
         NCDHagrid,
         ICDHpart,
         CCDHterm,
         DCDHdate,
         MCDHmval,
         PCDHpval,
         ICDHival,
         CCDHcval )
        values (
         ipAgrId,
         1,
         'UBRRPSK',
         dvPSKDate,
         null,
         npPSK,
         null,
         null );
    else
        update xxi.cdh
         set PCDHpval = npPSK
         where ncdhagrid = ipAgrId
         and   icdhpart  = 1
         and   ccdhterm  = 'UBRRPSK'
         and   dcdhdate  = dvPSKDate;
    end if;
    cpErrMsg        := char_to_sap('OK');
end;


FUNCTION Calc_PSK( ipAgrId      in      number ) return number
is
    dv_EmissionDate date;
    nv_EmissionSumm xxi.cdp.MCDPSUM%type; -->><< 28.07.2016 ������ �.�. #34714;
    nv_PSK_SUM_new  number;
    nv_PSK_SUM_old  number;
    nv_shift_value  number(5,4);
    nv_psk_accuracy number(5,4);
    nv_psk_diff     number;
    nv_psk          number;
    nv_psk_shift    number;
    nv_psk_new      number;
    iv_idsmr        xxi."cda".idsmr%type;
    iv_curr_idsmr   xxi."cda".idsmr%type;
    nv_ret          number(10,3);
    FUNCTION Calc_PSK_Summ( npPercent in number, dpEmissiondate date) return number
    is
        CURSOR Grafic is
            select dat,smpay from (
                select
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
                   group by  dog, dat
                   )
                   where dog = ipAgrId
                   order by dat;
        nv_ret          number;
        iv_e_k          number(2,0);
        iv_q_k          number(6,0);
        nv_Percent      number(10,10);
        dv_EmissionDate date;
        nv_EmissionSumm xxi.cdp.MCDPSUM%type; -->><< 28.07.2016 ������ �.�. #34714;
        iv_Payment_Day  number(2,0);
        iv_Emission_Day number(2,0);
    begin
        nv_ret := 0;
        nv_Percent := npPercent / (12 * 100);
        select to_number(to_char(dpEmissionDate,'DD'))
         into iv_Emission_Day
         from dual;
        for Payment in Grafic
        loop
            select to_number(to_char(Payment.dat,'DD'))
             into iv_Payment_Day
             from dual;
            if iv_Payment_Day >= iv_Emission_Day then
                iv_e_k := iv_Payment_Day - iv_Emission_Day;
                iv_q_k := MONTHS_BETWEEN(Payment.dat, dpEmissionDate);
            else
                iv_e_k := iv_Payment_Day - iv_Emission_Day + 30;
                iv_q_k := MONTHS_BETWEEN(Payment.dat, dpEmissionDate) - 1;
            end if;
            nv_ret := nv_ret + Payment.smpay / ( ( 1 + ( 12 * iv_e_k * nv_Percent / 365 ) ) * power( 1 + nv_percent, iv_q_k ) );
        end loop;
        return nv_ret;
    end;

begin
    select dcdpdate, mcdpsum
     into  dv_EmissionDate, nv_EmissionSumm
     from  cdp
     where ncdpagrid = ipAgrId;
    nv_shift_value  := 1 / 100;
    nv_psk_accuracy := 1 / 1000;
    select CDREP_UTIL.GET_INTRATE( ncdaagrid, dcdastarted ), idsmr
     into nv_psk, iv_idsmr
     from xxi."cda"
     where ncdaagrid = ipAgrId;
    loop
        nv_psk_shift   := nv_psk + nv_shift_value;
        nv_PSK_SUM_old := Calc_PSK_Summ( nv_psk,       dv_EmissionDate );
        nv_PSK_SUM_new := Calc_PSK_Summ( nv_psk_shift, dv_EmissionDate );
        nv_psk_new     := nv_psk + nv_shift_value * ( ( nv_EmissionSumm - nv_PSK_SUM_old ) / ( nv_PSK_SUM_new - nv_PSK_SUM_old ) );
        nv_psk_diff    := nv_psk_new - nv_psk;
        nv_psk         := nv_psk_new;
        exit when abs(nv_psk_diff) < nv_psk_accuracy;
    end loop;
    nv_ret := nv_psk;
    return nv_ret;
end Calc_PSK;
-- <<< ����� �.�. 26.05.2015 #22087 [15-199]
-->> ����� �.�. 10.12.2015 #26420 [15-692.1]
PROCEDURE UpdateCDH (ipAgrid  in  number,
                     ipPart   in  number,
                     cpTerm   in  varchar2,
                     cpDate   in  varchar2,
                     cpParam  in  varchar2,
                     cpValue  in  varchar2,
                     cpErrMsg out varchar2
                     )
is
begin
    case cpParam
        when 'MVAL' then
            cdterms.Update_History(ipAgrid,
                                   ipPart,
                                   cpTerm,
                                   to_date(cpDate,'YYYYMMDD'),
                                   to_number(cpValue),
                                   null,
                                   null,
                                   null);
        when 'PVAL' then
            cdterms.Update_History(ipAgrid,
                                   ipPart,
                                   cpTerm,
                                   to_date(cpDate,'YYYYMMDD'),
                                   null,
                                   to_number(cpValue),
                                   null,
                                   null);
        when 'IVAL' then
            cdterms.Update_History(ipAgrid,
                                   ipPart,
                                   cpTerm,
                                   to_date(cpDate,'YYYYMMDD'),
                                   null,
                                   null,
                                   to_number(cpValue),
                                   null);
        when 'CVAL' then
            cdterms.Update_History(ipAgrid,
                                   ipPart,
                                   cpTerm,
                                   to_date(cpDate,'YYYYMMDD'),
                                   null,
                                   null,
                                   null,
                                   cpValue);
    end case;
    cpErrMsg := char_to_sap('OK');
exception
    when others then
     cpErrMsg := char_to_sap(sqlerrm);
end UpdateCDH;
--<< ����� �.�. 10.12.2015 #26420 [15-692.1


function SetSAPCDContext(cpIDSMR in VARCHAR2 default null) return varchar2
  is
       ret varchar2(32767):='';
begin
  xxi_context.Set_IDSmr ( cpIDSMR );
  return UBRR_XXI5.ubrr_get_context;
  exception when others then
      return null;--'error SetSAPCDContext:'||sqlerrm;
end; --SetSAPCDContext

-->> 30.05.2016 ubrr korolkov 16-1808.2.3.2.4.5
procedure Generate_Annuitet(p_cMsg          out varchar2,
                            p_id            in  varchar2,   -- ������������� �������
                            p_StartDate     in  varchar2,   -- ���� ������ ������
                            p_EndDate       in  varchar2,   -- ���� ��������� ������ (��������)
                            p_StartSum      in  number,     -- ����� �������
                            p_Prc           in  number,     -- ���������� ������
                            p_sum_repay     in  number,     -- ����� ���������
                            p_dt            in  varchar2,   -- ���� ������� ��������
                            p_interv        in  number default 0, -- ������
                                                                  --  0 - ���
                                                                  --  1 - �������
                                                                  --  2 - �������
                                                                  --  3 - ���
                            p_fl            in  number default 1, -- ��� ����������� ������
                                                                  --  0 - �� ��� ������ ���� dFirstPay (��� ���������� > ���)
                                                                  --  1 - �� ���������� ��� ���������
                                                                  --  2 - �� ������ ���������� ���� dFirstPay �� ������
                                                                  --  3 - ����� ��������� ���������� ������� ���� �� ������ ���������
                            p_tp_correct    in  NUMBER default 1, -- ��������� ��� ����� �������� ����
                                                                  -- 1 �������� �������� ����������
                            p_only_working_days in number default null, -- ��������� �������� (0 - ���, 1 - ���������)
                            p_AB            in  number default null,  --  0 - � ��������� �����
                                                                      -- -1 - � ��������� �����
                            p_dt2           in  number default null)
is
    vErrMsg     varchar2(2000);
    vStartDate  date;
    vEndDate    date;
    vDt         date;
begin
    vStartDate := to_date(p_StartDate,'YYYYMMDD');
    vEndDate := to_date(p_EndDate,'YYYYMMDD');
    vDt := to_date(p_dt,'YYYYMMDD');

    ubrr_cdterms3.Generate_Annuitet(vErrMsg,
                                    p_id,
                                    vStartdate,
                                    vEndDate,
                                    p_StartSum,
                                    p_Prc,
                                    p_sum_repay,
                                    vDt,
                                    p_interv,
                                    p_fl,
                                    p_tp_correct,
                                    p_ONLY_WORKING_DAYS,
                                    p_AB,
                                    p_dt2);
    commit;
    p_cMsg := char_to_sap(vErrMsg);
end Generate_Annuitet;
--
-- ������� ������ ���������� ��������� �� ��������� ������� ������� ��
--
procedure CreatePrcSchedule(p_ErrMsg    out varchar2,
                            p_AgrId      in  number)
is
    vAgrId      xxi."cda".ncdaagrid%type;
    vStatus     xxi."cda".icdastatus%type;
    vIsLine     xxi."cda".icdaisline%type;
    v_CDR_Count number;
    v_ann_summ  xxi."cda".mcdatotal%type;
begin
    p_ErrMsg := 'OK';
    begin
        select ncdaagrid, icdastatus, icdaisline
        into vAgrId, vStatus, vIsLine
        from xxi."cda"
        where ncdaagrid = p_AgrId;
    exception
        when no_data_found then
            p_ErrMsg := '������� � ������� ' || to_char(p_AgrId) || '�� ������';
    end;

    if vAgrId is not null then
        if vStatus <> 0 then
            p_ErrMsg := '������� ������ ���� � ������� "��������"';
        elsif vIsLine <> 0 then
            p_ErrMsg := '������� ������ ���� �������';
        else
            delete from cds where ncdsagrid = vAgrId;

            insert into cds
                select ncdragrid, dcdrdate, dcdrdate
                from cdr
                where ncdragrid = vAgrId;
        end if;
    end if;

    begin
        select ncda2agrid
        into vAgrId
        from xxi.cda2
        where ncda2agrid = p_AgrId;
    exception
        when no_data_found then
            vAgrId := null;
    end;
    if  vAgrId is not null then
        select count(*) into v_CDR_Count from xxi.cdr where ncdragrid = vAgrId;
        delete FROM V_CDI WHERE V_CDI.NCDIAGRID = vAgrId;
        CDinterest.recalc_interest(vAgrId, 'T', Do_Commit => FALSE, Generate_Details => FALSE);
        for payment in ( select smPay, count(*) smCounts from
                         (select  a.dat dat,
                                  sum(a.smPay)  smPay
                          from (   SELECT   part,
                                            dat,
                                            MAX(dFrom) dtFrom,
                                            MAX(dTo) dtTo,
                                            SUM(smPayL) smPayL,
                                            SUM(smPayI) smPayI,
                                            SUM(smPayL+smPayI) smPay
                                   FROM (      select  NCDRAGRID dog,
                                                       ICDRPART part,
                                                       DCDRDATE dat,
                                                       to_date(null) dFrom,
                                                       to_date(null) dTo,
                                                       MCDRSUM smPayL,
                                                       0 smPayI
                                               from cdr
                                               where NCDRAGRID = vAgrId
                                               and   DCDRDATE > sysdate
                                               and   DCDRDATE < (select max(dcdrdate) from xxi.cdr where ncdragrid = vAgrId)
                                               union
                                               select  NCDIAGRID dog ,
                                                       ICDIPART part,
                                                       DCDIPMTDUE dat,
                                                       DCDIFROM dFrom,
                                                       DCDITO dTo,
                                                       0 smPayL,
                                                       (MCDITOTAL-decode(MCDIPAYED,null,0,MCDIPAYED)) smPayI
                                               from v_cdi
                                               where NCDIAGRID = vAgrId
                                               and   DCDIPMTDUE > sysdate
                                               and   DCDIPMTDUE < (select max(dcdrdate) from xxi.cdr where ncdragrid = vAgrId))
                                   GROUP BY part, dat ) a
                          group by  dat)
                         group by smPay
                         order by smCounts)

        loop
            if payment.smCounts/(v_CDR_Count-1) > 0.8 then
                --dbms_output.put_line('�������: '||cr.ncdaagrid||' ����� ������� '||payment.smPay||' ����������� '||payment.smCounts||' ��� �� '||to_char(v_CDR_Count-1));
                v_ann_summ := payment.smPay;
            end if;
        end loop;
        update xxi.cda2
            set MCDA2SUM_A   = v_ann_summ
            where NCDA2AGRID = vAgrId;
    end if;
    p_ErrMsg := char_to_sap(p_ErrMsg);

exception
    when others then
        p_ErrMsg := char_to_sap(dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
end CreatePrcSchedule;
--<< 30.05.2016 ubrr korolkov 16-1808.2.3.2.4.5
-->> ������� 07.2017 #44404: [15-1115.1] ������������� �������-��������
PROCEDURE GetBPLimSCG ( p_npCus     in      number,
                        p_dpZc      in      varchar2,
                        p_cpDemp    in      number,
                        p_SumLimit  out     number
                     )
is
begin
    IF p_cpDemp = 1 then
      BEGIN
        SELECT sum(decode(iaccbs2, 91319, restf(caccacc,cacccur,to_date(p_dpZc,'YYYYMMDD'),idsmr),91315, -restf(caccacc,cacccur,to_date(p_dpZc,'YYYYMMDD'),idsmr)
                        )
                 )
                 INTO p_SumLimit
        FROM xxi."acc" w
        WHERE w.IACCCUS =  9188971
          and w.caccprizn = '�'
          and w.iaccbs2 in (91315,91319)
          and upper(w.caccsio) like '%�%';
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       p_SumLimit := 0;
     END;
    ELSE
      BEGIN
        SELECT sum(decode(iaccbs2, 91319, restf(caccacc,cacccur,to_date(p_dpZc,'YYYYMMDD'),idsmr),91315, -restf(caccacc,cacccur,to_date(p_dpZc,'YYYYMMDD'),idsmr)
                         )
                  )
               INTO p_SumLimit
        FROM xxi."acc" w
        WHERE w.IACCCUS =  9188971
          and w.caccprizn = '�'
          and w.iaccbs2 in (91315,91319)
          and w.caccsio is not null;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        p_SumLimit := 0;
      END;
    END IF;
end GetBPLimSCG;
--<< ������� 07.2017 #44404: [15-1115.1] ������������� �������-��������

-->>22.03.2021  ������� �.�.     DKBPA-105 ���� 4.1 (���������� ���): ������ ������������. ��� ��� �������� �� �������� �����
-------------------------------------------------------------------------------
-- ��������� �����������
-------------------------------------------------------------------------------
PROCEDURE ZIU_Write_Log(p_cmess in varchar2)
  is
  pragma autonomous_transaction;
BEGIN
  if g_log_enable = 'Y' then
    insert into UBRR_DATA.UBRR_SAP_ZIU_LOG(message)
                    values (substr(p_cmess,1,2000));
    commit;
  end if;
END;

-------------------------------------------------------------------------------
-- ��������� ��������� ������� ���������� (��������)
-------------------------------------------------------------------------------
PROCEDURE ZIU_Calc_Interval_O(p_Agrid      in     number,
                              p_start      in     date,
                              p_finish     in     date,
                              p_perctermid in     number
                             )
  IS

  dStart      date := p_start; --���� ������ ��������� (������� ���� ������ ��������)
  dFinish     date := p_finish;

  tpDayOff    number:=1; -- ���� ����������� ����
                          --  0 - �� ���������
                          --  -1 - �������� �� �����
                          --  1 - �������� �� �����
  isCorDayOff number:=0; -- ��������� ��� ����� �������� ����

  dFirstN     date;
  dFirstPay   date;
  nn          number := 1;
  nnmax       number := 500;
  rm          number := 0;
  rd          number := 0;
  rdm         number := 0;
  rdc         number := 0;
  rm_N        number := 0;
  rd_N        number := 0;
  rdm_N       number := 0;
  rdc_N       number := 0;
  sm          number;
  dFirst      date;
  dFirst_N    date;
  dPay        date;
  dPay_N      date;

  FUNCTION getdPay(dFirst_F date, rd_F number,sm_F number,rdc_F number, rm_F number,rdm_F number)
  RETURN date IS
    dPay_F date;
    last_day_month date;
  BEGIN
    dPay_F := ADD_MONTHS(dFirst_F,rm_F)+rdm_F-1;
    last_day_month := LAST_DAY(ADD_MONTHS(dFirst_F,rm_F));
    if dPay_F > last_day_month then
       dPay_F := last_day_month;
    end if;
    RETURN  dPay_F;
  END;

BEGIN

  dFirstN  := least(last_day(dStart),dFinish);

  if p_perctermid = 1 then
    dFirstPay:=dFinish;
  else
    dFirstPay:=least(last_day(dStart)+10,dFinish);
  end if;

  delete from cds
     where NCDSAGRID=p_Agrid
       and DCDSINTCALCDATE>=dStart;

  nn  := 1;

  dFirst := TRUNC(dFirstPay,'MON');
  dFirst_N := TRUNC(dFirstN,'MON');
  sm := 1;

  rd  := dFirstPay-dFirst - 10*rdc;
  rm  := TRUNC(MONTHS_BETWEEN(dFirstPay,dFirst));
  rdm := to_number(to_char(dFirstPay,'DD'));

  rd_N  := dFirstN-dFirst_N - 10*rdc_N;
  rm_N  := TRUNC(MONTHS_BETWEEN(dFirstN, dFirst_N));
  rdm_N := to_number(to_char(dFirstN,'DD'));

  IF (dFirstN = LAST_DAY(dFirstN)) AND (rdm_N < 31) THEN
    rdm_N := 31;
  END IF;

  IF (dFirstPay = LAST_DAY(dFirstPay)) AND (rdm < 31) THEN
    rdm := 31;
  END IF;

  <<loop_Pay>>
    LOOP
      dPay := getdPay(dFirst,rd,sm,rdc,rm,rdm);
      dPay_N := getdPay(dFirst_N,rd_N,sm,rdc_N,rm_N,rdm_N);

      dFirstN:=dPay_N;
      dFirstPay := dPay;

      WHILE not DJ_DATE.Is_Working_Day(dFirstPay) LOOP dFirstPay:=dFirstPay+1; END LOOP;

      if dFinish <= dFirstPay then
        dFirstPay := dFinish;
      end if;
      if dFinish <= dFirstN then
        dFirstN := dFinish;
      end if;


      IF isCorDayOff=1 THEN dFirstN:=dFirstPay; END IF;

      IF dFirstN>=dStart and dFirstPay>=dStart THEN
        INSERT INTO cds (ncdsAGRID, dcdsINTCALCDATE, dcdsINTPMTDATE)
          VALUES ( p_Agrid, dFirstN, dFirstPay);
      END IF;

      IF dFirstN>=dFinish THEN
        EXIT;
      END IF;

      -- ��� �����
      IF nn >= nnmax THEN
        EXIT;
      ELSE
        nn:=nn+1;
           dFirst := ADD_MONTHS(dFirst,sm);
           dFirst_N := ADD_MONTHS(dFirst_N,sm);
      END IF;

    END LOOP;-- loop_Pay;
END;

-------------------------------------------------------------------------------
-- ��������� ��������� ������� ���������� (���������)
-------------------------------------------------------------------------------
PROCEDURE ZIU_Calc_Interval( p_Agrid       in number,
                             P_DT          IN DATE,   -- ������ ����������
                             P_DT2         IN DATE,   -- ������ ������
                             P_TYPE_REM    IN NUMBER DEFAULT 0, -- ��� ����������� ������: 0-�� ������ ������ ����
                                                      --                         1-�� ���������� ��� ���������
                                                      --                         2-�� ��� ������ ������ ����
                                                      --                         9-�� ��� ������ ������ ������
                             P_PAY_DAY     IN NUMBER, -- ���� ������
                             P_INTERV      IN NUMBER, -- ��������: 0-�����
                                                      --           1-�������
                                                      --           2-�������
                                                      --           3-���
                                                      --           4-������
                             P_FIXED_PARAM IN NUMBER, -- ������: 0-� ���� ����������
                                                      --         1-� ������� ����
                             P_ONLY_WORKING_DAYS IN NUMBER, -- ��������� ��������
                             P_AB          IN NUMBER, -- '1'  - � ��������� �����
                                                      -- '-1' - � ��������� �����
                             P_TP_CORRECT  IN NUMBER, -- �������� �������� ���������� 1-�� 0-���
                             P_PAY_DURING  IN NUMBER, -- �������� � �������  1-�� 0-���          *
                             P_WORK_DAY    IN NUMBER, -- ������� 1-�� 0-���                      *
                             P_NUM_OF_DAY  IN NUMBER, -- ����                                    *
                             P_CALC_DATE_LAST_DAY         IN NUMBER DEFAULT 0, -- ������� ���� ��������� ���� ������? 1-�� 0-���
                             P_IS_FIRST_DATE_LAST_DAY     IN NUMBER DEFAULT 0, -- ������� ���� ������� ����������  ��������� ���� ������? 1-�� 0-���
                             P_IS_FIRST_PAY_LAST_DAY      IN NUMBER DEFAULT 0,  -- ������� ���� ������ ������ ��������� ���� ������? 1-�� 0-���
                             P_TO_CALENDAR IN NUMBER DEFAULT 0,  -- �������� ������� ���������� 1-�� 0-���
                             P_TO_DATE     IN DATE DEFAULT NULL,  -- ���������� ������ �� ����   -->><< 11.11.2013 ��������� �.�. 12-1990 ��������� �������� ������� ��� ����������� ����� ��������� ��������
                             P_FIXED_DATE  IN DATE DEFAULT NULL
                            )
  IS
    --Agrid       number := p_Agrid;
    dStart      date;  --���� ������ ��������� (������� ���� ������ ��������)

    dFirstN     date := P_DT;
    dFirstPay   date := P_DT2;
    dFinish     date;

    tpDayOff    number:=0; -- ���� ����������� ����
                        --  0 - �� ���������
                        -- -1 - �������� �� �����
                        --  1 - �������� �� �����
    isCorDayOff number:=0; -- ��������� ��� ����� �������� ����
                        -- 0 �������� ���� ����������, ��� ����
                        -- 1 �������� �������� ����������
--
    nn  number := 1;
    nnmax  number := 1000;
    rm  number := 0;
    rd  number := 0;
    rdm number := 0;
    rdc  number := 0;
    rm_N  number := 0;
    rd_N  number := 0;
    rdm_N number := 0;
    rdc_N  number := 0;
    sm  number;
    dFirst  date;
    dFirst_N  date;
    dPay    date;
    dPay_N  date;
    V_PAY_DAY NUMBER;
    i_days_plus NUMBER;

    FUNCTION getdPay(dFirst_F date, rd_F number,sm_F number,rdc_F number, rm_F number,rdm_F number)
    RETURN date IS
         dPay_F date;
         last_day_month date;
    BEGIN

        IF P_INTERV in (0,1,2,3) THEN -- ��������� -- ������� -- ������� -- ���
            IF P_TYPE_REM = 0 THEN   -- 0 - �� ������ �� ������ ���������� ���� dFirstPay
                dPay_F := dFirst_F + rd_F;
            ELSIF P_TYPE_REM = 9 THEN
                  begin
                    dPay_F := to_date(to_char(V_PAY_DAY)||'.'||to_char(dFirst_F, 'MM.YYYY'), 'DD.MM.YYYY');
                  EXCEPTION WHEN OTHERS THEN
                    dPay_F := LAST_DAY(dFirst_F) + 1;
                  END;

            ELSIF P_TYPE_REM=1 THEN   --  1 - �� ���������� ��� ���������
                dPay_F := ADD_MONTHS(dFirst_F,sm_F)-1;
            ELSIF P_TYPE_REM=2 THEN   --  2 - �� ��� ������ ���� dFirstPay (��� ���������� > ���)
                dPay_F := ADD_MONTHS(dFirst_F,rm_F)+rdm_F-1;
                last_day_month := LAST_DAY(ADD_MONTHS(dFirst_F,rm_F));
                if dPay_F > last_day_month then
                   dPay_F := last_day_month;
                end if;
            END IF;
        ELSIF P_INTERV=4 THEN -- ������
            IF P_TYPE_REM in (0,2) THEN   --  0 - �� ������ �� ������ ���������� ���� dFirstPay
                dPay_F := dFirst_F + 10*rdc_F+ rd_F;
            ELSIF   P_TYPE_REM=1 THEN   --  1 - �� ���������� ��� ���������
                if rdc_F=2 then   dPay_F := LAST_DAY(dFirst_F);
                else            dPay_F := dFirst_F + 10*(rdc_F+1)-1;
                end if;
            END IF;
        END IF;
        RETURN  dPay_F;
    END getdPay;

BEGIN

  IF P_TYPE_REM=9 THEN
    IF P_PAY_DAY IS NOT NULL THEN
      V_PAY_DAY:= P_PAY_DAY;
    ELSE
      V_PAY_DAY:= nvl(ubrr_xxi5.ubrr_cd_interval.get_pay_day(p_Agrid),10); --���� �� ������ ����, �� ��������� 10 �����
    END IF;

    IF  EXTRACT(DAY FROM last_day(dFirstPay)) < V_PAY_DAY THEN
      i_days_plus := V_PAY_DAY - EXTRACT(DAY FROM last_day(dFirstPay));
      dFirstPay := last_day(dFirstPay)+1;
    ELSE
      i_days_plus := 0;
      dFirstPay := to_date(to_char(V_PAY_DAY)||'.'||to_char(dFirstPay, 'MM.YYYY'), 'DD.MM.YYYY');
    END IF;
  END IF;

  dFinish := trunc(P_TO_DATE);

  IF dFinish IS NULL THEN
    raise_application_error(-20000,'ZIU_Calc_Interval. �� ���������� ���� ���������.');
  END IF;

  IF P_FIXED_PARAM=1 THEN
    dStart := trunc(P_FIXED_DATE);
  else
      BEGIN
        SELECT dcdvSIGNDATE into dStart from vcda where ncdvAGRID=p_Agrid;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          dStart := NULL;
      END;
  END IF;

  IF dStart IS NULL THEN
    raise_application_error(-20000,'ZIU_Calc_Interval. �� ���������� ���� ������.');
  END IF;

  IF (P_ONLY_WORKING_DAYS=1) THEN
    tpDayOff := P_AB;
    isCorDayOff := P_TP_CORRECT;
  END IF;

  DELETE FROM cds
    WHERE NCDSAGRID=p_Agrid
      AND DCDSINTCALCDATE>=dStart;

  nn  := 1;

  IF P_INTERV=0 THEN -- ���������
    IF i_days_plus > 0 THEN  --25.01.2013
      dFirst := TRUNC(add_months(dFirstPay,-1),'MON');
    ELSE
      dFirst := TRUNC(dFirstPay,'MON');
    END if;
    dFirst_N := TRUNC(dFirstN,'MON');
    sm := 1;
  ELSIF P_INTERV=1 THEN -- �������
    dFirst := TRUNC(dFirstPay,'Q');
    dFirst_N := TRUNC(dFirstN,'Q');
    sm := 3;
  ELSIF P_INTERV=2 THEN -- �������
    dFirst := TRUNC(dFirstPay,'Y');
    dFirst_N := TRUNC(dFirstN,'Y');
    IF months_between(dFirstPay, dFirst) > 6 THEN
        dFirst := add_months(dFirst, 6);
    END IF;
    IF months_between(dFirstN, dFirst_N) > 6 THEN
        dFirst_N := add_months(dFirst_N, 6);
    END IF;
    sm := 6;
  ELSIF P_INTERV=3 THEN -- ���
    dFirst := TRUNC(dFirstPay,'Y');
    dFirst_N := TRUNC(dFirstN,'Y');
    sm := 12;
  ELSIF P_INTERV=4 THEN -- ������
    dFirst := TRUNC(dFirstPay,'MON');
    dFirst_N := TRUNC(dFirstN,'MON');
    IF      dFirstPay >= (dFirst+20) THEN  rdc := 2;
    ELSIF   dFirstPay >= (dFirst+10) THEN  rdc := 1;
    ELSE    rdc := 0;
    END IF;
    IF      dFirstN >= (dFirst_N+20) THEN  rdc_N := 2;
    ELSIF   dFirstN >= (dFirst_N+10) THEN  rdc_N := 1;
    ELSE    rdc_N := 0;
    END IF;
    sm := 1;
  END IF;

  rd  := (dFirstPay - dFirst - 10*rdc);
  rm  := TRUNC(MONTHS_BETWEEN(dFirstPay,dFirst));
  rdm := to_number(to_char(dFirstPay,'DD'));

  rd_N  := dFirstN-dFirst_N - 10*rdc_N;
  rm_N  := TRUNC(MONTHS_BETWEEN(dFirstN,dFirst_N));
  rdm_N := to_number(to_char(dFirstN,'DD'));

  IF (P_TYPE_REM =2) THEN
    IF    ((dFirstPay = LAST_DAY(dFirstPay))
      AND (rdm < 31))
      AND ((dFirstN = LAST_DAY(dFirstN))
      AND (rdm_N < 31))
    THEN

      IF P_CALC_DATE_LAST_DAY = 1 THEN
        rdm := 31;
        rdm_N := 31;
      END IF;

    END IF;

    IF (dFirstN = LAST_DAY(dFirstN)) AND (rdm_N < 31) THEN
      IF P_IS_FIRST_DATE_LAST_DAY = 1 THEN rdm_N := 31; END IF;
    END IF;
    IF (P_PAY_DURING = 0) AND (dFirstPay = LAST_DAY(dFirstPay)) AND (rdm < 31) THEN
      IF P_IS_FIRST_PAY_LAST_DAY = 1 THEN rdm := 31; END IF;
    END IF;
  END IF;
  <<loop_Pay>>
  LOOP
    dPay := getdPay(dFirst,rd,sm,rdc,rm,rdm);
    dPay_N := getdPay(dFirst_N,rd_N,sm,rdc_N,rm_N,rdm_N);

    dFirstN := dPay_N;
    dFirstPay := dPay;

    IF (P_PAY_DURING = 1) AND (P_NUM_OF_DAY > 0) THEN
      IF P_WORK_DAY = 1 THEN
        IF P_TYPE_REM=9 THEN
          NULL;

        ELSE
          dFirstPay:=DJ_DATE.Add_Working_Days(dFirstN,P_NUM_OF_DAY);
        END IF;
      ELSE

        IF P_TYPE_REM=9 THEN
            NULL;
        ELSE
          dFirstPay:=dFirstN + P_NUM_OF_DAY;
        END IF;

      END IF;
    END IF;

    IF tpDayOff=-1 THEN --  �������� �� �����
        WHILE not DJ_DATE.Is_Working_Day(dFirstPay) LOOP dFirstPay:=dFirstPay-1; END LOOP;
    ELSIF tpDayOff=1 THEN --  �������� �� �����
        WHILE not DJ_DATE.Is_Working_Day(dFirstPay) LOOP dFirstPay:=dFirstPay+1; END LOOP;
    END IF;

    IF P_TYPE_REM=9 THEN
      IF (P_PAY_DURING = 1) AND (P_NUM_OF_DAY > 0) THEN
        IF P_WORK_DAY = 1 THEN
          dFirstN   := DJ_DATE.Add_Working_Days(dFirstPay,-P_NUM_OF_DAY);
        ELSE
          dFirstN :=dFirstPay - P_NUM_OF_DAY;
        END IF;
      END IF;
    END IF;

    if dFinish <= dFirstPay then
       dFirstPay := dFinish;
       IF P_TYPE_REM=9 THEN
          dFirstN := dFinish;
       END IF;
    end if;
    if dFinish <= dFirstN then
       dFirstN := dFinish;
    end if;

    IF isCorDayOff=1 THEN dFirstN:=dFirstPay; END IF;

    IF dFirstN>=dStart and dFirstPay>=dStart THEN
       INSERT INTO cds (ncdsAGRID, dcdsINTCALCDATE, dcdsINTPMTDATE)
                VALUES ( p_Agrid, dFirstN, dFirstPay);
    END IF;

    IF dFirstN>=dFinish /*OR dFirstPay>=dFinish*/ THEN
      EXIT;
    END IF;
    -- ��� �����
    IF nn >= nnmax THEN
        EXIT;
    ELSE
        nn:=nn+1;
        IF P_INTERV in (0,1,2,3) THEN -- ��������� -- ������� -- ������� -- ���
              dFirst := ADD_MONTHS(dFirst,sm);
              dFirst_N := ADD_MONTHS(dFirst_N,sm);
        ELSIF P_INTERV=4 THEN -- ������
            IF rdc=2 THEN
              dFirst := ADD_MONTHS(dFirst,sm);
              rdc:=0;
            ELSE
              rdc:=rdc+1;
            END IF;
            IF rdc_N=2 THEN
              dFirst_N := ADD_MONTHS(dFirst_N,sm);
              rdc_N:=0;
            ELSE
              rdc_N:=rdc_N+1;
            END IF;
        END IF;
    END IF;
  END LOOP;
END ZIU_Calc_Interval;

-------------------------------------------------------------------------------
-- ��������� ��������� ������� ����������
-------------------------------------------------------------------------------
PROCEDURE ZIU_Calc_Interval(p_Agrid           in     number,
                            p_StartDate       in     date,
                            p_FinishDate      in     date,
                            p_PerctermID      in     number,
                            p_ErrMessage      in out varchar2
                            )
  is

BEGIN
  ZIU_Write_Log('Start ZIU_Calc_Interval(p_AgrId'        ||' => '||p_AgrId||','||
                                        'p_StartDate'    ||' => '||p_StartDate||','||
                                        'p_PerctermID'   ||' => '||p_PerctermID||','||
                                        'p_FinishDate'   ||' => '||p_FinishDate||')');

  IF p_PerctermID = 1 or p_PerctermID = 3 THEN
    ZIU_Calc_Interval_O(p_Agrid      => p_Agrid,
                        p_start      => p_StartDate,
                        p_finish     => p_FinishDate,
                        p_perctermid => p_PerctermID
                        );

  ELSIF p_PerctermID = 8 THEN -- �� ���� ���������
    ZIU_calc_interval ( p_Agrid                    => p_Agrid,
                        p_fixed_param              => 1,  -- ������: 0-� ���� ����������
                                                          --         1-� ������� ����
                        p_interv                   => 0,  -- ��������: 0-�����
                                                          --           1-�������
                                                          --           2-�������
                                                          --           3-���
                                                          --           4-������
                        p_dt                       => p_StartDate, -- ������ ����������
                        p_dt2                      => to_date('01'||to_char(/*add_months(*/p_StartDate/*,1)*/,'mm.yyyy'),'dd.mm.yyyy'), -- ������ ������
                        p_pay_during               => 1, -- �������� � �������  1-�� 0-���          *
                        p_work_day                 => 0, -- ������� 1-�� 0-���                      *
                        p_num_of_day               => 0, -- ����                                    *
                        p_type_rem                 => 9,  -- ��� ����������� ������: 0-�� ������ ������ ����
                                                          --                         1-�� ���������� ��� ���������
                                                          --                         2-�� ��� ������ ������ ����
                                                          --                         9-�� ��� ������ ������ ������
                        p_pay_day                  => '',
                        p_only_working_days        => 1, -- ��������� �������� (0 - ���, 1 - ���������)
                        p_ab                       => 1, -- '1'  - � ��������� �����
                                                         -- '-1' - � ��������� �����
                        p_tp_correct               => 1, -- �������� �������� ���������� 1-�� 0-���
                        p_calc_date_last_day       => 0, -- ������� ���� ��������� ���� ������? 1-�� 0-���
                        p_is_first_date_last_day   => 0, -- ������� ���� ������� ����������  ��������� ���� ������? 1-�� 0-���
                        p_is_first_pay_last_day    => 0, -- ������� ���� ������ ������ ��������� ���� ������? 1-�� 0-���
                        p_to_date                  => p_FinishDate,
                        P_FIXED_DATE               => p_StartDate
                      );
  ELSIF p_PerctermID = 6 THEN
    ZIU_calc_interval ( p_Agrid                    => p_Agrid,
                        p_fixed_param              => 1,  -- ������: 0-� ���� ����������
                                                          --         1-� ������� ����
                        p_interv                   => 0,  -- ��������: 0-�����
                                                          --           1-�������
                                                          --           2-�������
                                                          --           3-���
                                                          --           4-������
                        p_dt                       => p_StartDate, -- ������ ����������
                        p_dt2                      => to_date('01'||to_char(/*add_months(*/p_StartDate/*,1)*/,'mm.yyyy'),'dd.mm.yyyy'), -- ������ ������
                        p_pay_during               => 1, -- �������� � �������  1-�� 0-���          *
                        p_work_day                 => 0, -- ������� 1-�� 0-���                      *
                        p_num_of_day               => 5, -- ����                                    *
                        p_type_rem                 => 9,  -- ��� ����������� ������: 0-�� ������ ������ ����
                                                          --                         1-�� ���������� ��� ���������
                                                          --                         2-�� ��� ������ ������ ����
                                                          --                         9-�� ��� ������ ������ ������
                        p_pay_day                  => '',
                        p_only_working_days        => 1, -- ��������� �������� (0 - ���, 1 - ���������)
                        p_ab                       => 1, -- '1'  - � ��������� �����
                                                         -- '-1' - � ��������� �����
                        p_tp_correct               => 0, -- �������� �������� ���������� 1-�� 0-���
                        p_calc_date_last_day       => 0, -- ������� ���� ��������� ���� ������? 1-�� 0-���
                        p_is_first_date_last_day   => 0, -- ������� ���� ������� ����������  ��������� ���� ������? 1-�� 0-���
                        p_is_first_pay_last_day    => 0, -- ������� ���� ������ ������ ��������� ���� ������? 1-�� 0-���
                        p_to_date                  => p_FinishDate,
                        P_FIXED_DATE               => p_StartDate
                      );
  END IF;

  ZIU_Write_Log('End ZIU_Calc_Interval ��');

EXCEPTION
  WHEN OTHERS THEN
    ZIU_Write_Log('EXCEPTION ZIU_Calc_Interval '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    p_ErrMessage := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
END;

-------------------------------------------------------------------------------
-- ��������� ���������� ������ � ������� ��� ��������� ������� �������
-------------------------------------------------------------------------------
PROCEDURE ZIU_Repayment_Schedule( p_AgrId            in number,      -- ��� ���������� ��������
                                  p_ChangeDate       in varchar2,    -- ���� �������� �������� (���� �)
                                  p_PayAmount        in number,      -- �����
                                  p_PayDate          in varchar2,    -- ����
                                  p_Status           out varchar2,   -- ������
                                  p_ErrorMsg         out varchar2    -- ��������� �� ������
                                )
  is

  l_ChangeDate               date;
  l_PayDate                  date;
  l_ubrr_sap_ziu_temp_gtt    UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT%rowtype;

BEGIN
  ZIU_Write_Log('Start ZIU_Repayment_Schedule(p_AgrId'        ||' => '||p_AgrId||','||
                                              'p_ChangeDate'  ||' => '||p_ChangeDate||','||
                                              'p_PayAmount'   ||' => '||p_PayAmount||','||
                                              'p_PayDate'     ||' => '||p_PayDate||')');
  p_Status := char_to_sap('OK');

  --����������� ���� ���������
  begin
     select decode(p_ChangeDate ,'00000000',null,to_date(p_ChangeDate , 'YYYYMMDD')),
            decode(p_PayDate    ,'00000000',null,to_date(p_PayDate    , 'YYYYMMDD'))
      into l_ChangeDate,
           l_PayDate
      from dual;
  exception
    when others then
     l_ChangeDate := null;
     l_PayDate := null;
  end;

  if l_ChangeDate is not null and l_PayDate is not null then

    l_ubrr_sap_ziu_temp_gtt.nagrid      := p_AgrId;
    l_ubrr_sap_ziu_temp_gtt.cchangetype := 'GR_REPAY';
    l_ubrr_sap_ziu_temp_gtt.npart       := 1;
    l_ubrr_sap_ziu_temp_gtt.cterm       := '';
    l_ubrr_sap_ziu_temp_gtt.msum        := p_PayAmount;
    l_ubrr_sap_ziu_temp_gtt.dgrdate     := l_PayDate;
    l_ubrr_sap_ziu_temp_gtt.catribut    := '';
    l_ubrr_sap_ziu_temp_gtt.dchangedate := l_ChangeDate;

    insert into UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT
         values l_ubrr_sap_ziu_temp_gtt;

  else
    raise_application_error(-20000,'ZIU_Repayment_Schedule. �������� ������ ��� YYYYMMDD ��� ������ ��������.');
  end if;

  ZIU_Write_Log('End ZIU_Repayment_Schedule ��');

EXCEPTION
  WHEN OTHERS THEN
    ZIU_Write_Log('EXCEPTION ZIU_Repayment_Schedule '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    p_Status   := char_to_sap('ERR');
    p_ErrorMsg := char_to_sap(TS.To_2000 ('������:'||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace));
END;

-------------------------------------------------------------------------------
-- ��������� ���������� ������ � ������� ��� ��������� ������� ��������� ������
-------------------------------------------------------------------------------
PROCEDURE ZIU_Limit_Change_Schedule( p_AgrId            in number,      -- ��� ���������� ��������
                                     p_ChangeDate       in varchar2,    -- ���� �������� �������� (���� �)
                                     p_LimAmount        in number,      -- �����
                                     p_LimDate          in varchar2,    -- ����
                                     p_Status           out varchar2,   -- ������
                                     p_ErrorMsg         out varchar2    -- ��������� �� ������
                                   )
 is

  l_ChangeDate               date;
  l_LimDate                  date;
  l_ubrr_sap_ziu_temp_gtt    UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT%rowtype;

BEGIN
  ZIU_Write_Log('Start ZIU_Limit_Change_Schedule(p_AgrId'       ||' => '||p_AgrId||','||
                                                'p_ChangeDate'  ||' => '||p_ChangeDate||','||
                                                'p_LimAmount'   ||' => '||p_LimAmount||','||
                                                'p_LimDate'     ||' => '||p_LimDate||')');
  p_Status := char_to_sap('OK');

  --����������� ���� ���������
  begin
     select decode(p_ChangeDate ,'00000000',null,to_date(p_ChangeDate , 'YYYYMMDD')),
            decode(p_LimDate    ,'00000000',null,to_date(p_LimDate    , 'YYYYMMDD'))
      into l_ChangeDate,
           l_LimDate
      from dual;
  exception
    when others then
     l_ChangeDate := null;
     l_LimDate := null;
  end;

  if l_ChangeDate is not null and p_LimDate is not null then

    l_ubrr_sap_ziu_temp_gtt.nagrid      := p_AgrId;
    l_ubrr_sap_ziu_temp_gtt.cchangetype := 'GR_LIMIT';
    l_ubrr_sap_ziu_temp_gtt.npart       := 1;
    l_ubrr_sap_ziu_temp_gtt.cterm       := 'LIMIT';
    l_ubrr_sap_ziu_temp_gtt.msum        := p_LimAmount;
    l_ubrr_sap_ziu_temp_gtt.dgrdate     := l_LimDate;
    l_ubrr_sap_ziu_temp_gtt.catribut    := '';
    l_ubrr_sap_ziu_temp_gtt.dchangedate := l_ChangeDate;

    insert into UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT
         values l_ubrr_sap_ziu_temp_gtt;

  else
    raise_application_error(-20000,'ZIU_Limit_Change_Schedule. �������� ������ ��� YYYYMMDD ��� ������ ��������.');
  end if;

  ZIU_Write_Log('End ZIU_Limit_Change_Schedule ��');

EXCEPTION
  WHEN OTHERS THEN
    ZIU_Write_Log('EXCEPTION ZIU_Limit_Change_Schedule '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    p_Status   := char_to_sap('ERR');
    p_ErrorMsg := char_to_sap(TS.To_2000 ('������:'||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace));
END;

-------------------------------------------------------------------------------
-- ��������� ���������� ������ � ������� ��� �������� �����������
-------------------------------------------------------------------------------
PROCEDURE ZIU_Change_Zalog( p_AgrId            in number,      -- ��� ���������� ��������
                            p_ChangeDate       in varchar2,    -- ���� �������� �������� (���� �)
                            p_Atribut          in varchar2,    -- ����� ��������� ������
                            p_Amount           in number,      -- �����
                            p_Status           out varchar2,   -- ������
                            p_ErrorMsg         out varchar2    -- ��������� �� ������
                          )
 is

  l_ChangeDate               date;
  l_ubrr_sap_ziu_temp_gtt    UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT%rowtype;

BEGIN
  ZIU_Write_Log('Start ZIU_Change_Zalog(p_AgrId'       ||' => '||p_AgrId||','||
                                       'p_ChangeDate'  ||' => '||p_ChangeDate||','||
                                       'p_Atribut'     ||' => '||p_Atribut||','||
                                       'p_Amount'      ||' => '||p_Amount||')');
  p_Status := char_to_sap('OK');

  --����������� ���� ���������
  begin
     select decode(p_ChangeDate ,'00000000',null,to_date(p_ChangeDate , 'YYYYMMDD'))
      into l_ChangeDate
      from dual;
  exception
    when others then
     l_ChangeDate := null;
  end;

  if l_ChangeDate is not null then

    l_ubrr_sap_ziu_temp_gtt.nagrid      := p_AgrId;
    l_ubrr_sap_ziu_temp_gtt.cchangetype := 'CH_ZALOG';
    l_ubrr_sap_ziu_temp_gtt.npart       := '';
    l_ubrr_sap_ziu_temp_gtt.cterm       := '';
    l_ubrr_sap_ziu_temp_gtt.msum        := p_Amount;
    l_ubrr_sap_ziu_temp_gtt.dgrdate     := '';
    l_ubrr_sap_ziu_temp_gtt.catribut    := char_convert.char_from_sap(p_Atribut);
    l_ubrr_sap_ziu_temp_gtt.dchangedate := l_ChangeDate;

    insert into UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT
         values l_ubrr_sap_ziu_temp_gtt;

  else
    raise_application_error(-20000,'ZIU_Change_Zalog. �������� ������ ���� ��������� YYYYMMDD ��� ������ ��������.');
  end if;

  ZIU_Write_Log('End ZIU_Change_Zalog ��');

EXCEPTION
  WHEN OTHERS THEN
    ZIU_Write_Log('EXCEPTION ZIU_Change_Zalog '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    p_Status   := char_to_sap('ERR');
    p_ErrorMsg := char_to_sap(TS.To_2000 ('������:'||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace));
END;

-------------------------------------------------------------------------------
-- ��������� ������� ��������� ������
-------------------------------------------------------------------------------
PROCEDURE ZIU_Clear_ubrr_sap_ziu_temp
  is
BEGIN
  delete from UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT;
END;

-------------------------------------------------------------------------------
-- ��������� ������� ��������� ������, �������������� ��������� ������
-------------------------------------------------------------------------------
PROCEDURE ZIU_Clear_Temp_Zalog( p_AgrId            in number,      -- ��� ���������� ��������
                                p_session          in varchar2     -- ������ ������������
                               )
  is
  pragma autonomous_transaction;
BEGIN
  CDENV.Clear_Temp_Table('CD1');
  CDENV.Clear_Temp_Table('CDT');
  CDENV.Clear_Temp_Table('CDD');
  CDENV.Clear_Temp_Table('CDTC');
  CDENV.Clear_Temp_Table('CDT_CDTC');

  delete from CD1 where CD1.NCD1AGRID = p_AgrId and CD1.CCD1SESSION = p_session;
  delete from CDD where CDD.NCDDAGRID = p_AgrId and CDD.CCDDSESSIONID = p_session;
  delete from CDT where CDT.NCDTAGRID = p_AgrId and CDT.CCDTSESSIONID = p_session;
  delete from CDTC where CDTC.NCDTAGRID = p_AgrId and CDTC.CCDTSESSIONID = p_session;
  delete from CDT_CDTC where CDT_CDTC.CCDTSESSIONID = p_session;

  CD2TRN.Del_AllDocTun;
  dbms_sql_add.commit;
END;

-------------------------------------------------------------------------------
-- ��������� �������������� ��������� ������
-------------------------------------------------------------------------------
PROCEDURE ZIU_Settlement_Zalog( p_AgrId            in number,      -- ��� ���������� ��������
                                p_ABS              in varchar2,    -- ������
                                p_ChangeDate       in varchar2,    -- ���� �������� �������� (���� �)
                                p_Status           out varchar2,   -- ������
                                p_ErrorMsg         out varchar2    -- ��������� �� ������
                               )
  is

  cursor cur_czh(par_AgrId in xxi."czo".NCZOAGRID%type, par_ddate in xxi.czh.dczhdate%type) is
  select count(t.iczh)
    from xxi.czh t
   where t.NCZHCZO in (select a.ICZO
                         from  xxi."czo" a
                        where a.NCZOAGRID  = par_AgrId
                     )
     and t.dczhdate = par_ddate;

  cursor cur_sap(par_sesion in varchar2) is
  select TS.To_2000 (LISTAGG(aa.ccapmessage, ' ') WITHIN GROUP (ORDER BY aa.ICAPID desc) )
    from CAP aa
   where aa.ccapsessionid = par_sesion
     and aa.ccaplevel = 'E'
  order by aa.ICAPID desc;

  l_session       varchar2(64) := UserEnv('SESSIONID');
  l_CurrentIdsmr  smr.idsmr%type := ubrr_get_context; --��������� ������
  l_StMsg         VARCHAR2(20);
  l_CountErr      NUMBER := 0;
  l_CountAcs      NUMBER := 0;
  l_ErrMsg        VARCHAR2 (2000);
  l_ChangeDate    date;
  l_operdate      date;
  l_count_czh     NUMBER := 0;

  l_RegUser       xxi.usr.cusrlogname%type;

  function get_userid( p_usr varchar2 default null )
  return number
  is
    v_res usr.iusrid%type;
  begin
    select iusrid
      into v_res
      from usr
     where cusrlogname = coalesce(p_usr, user);
    return v_res;
  exception
    when no_data_found then
      return null;
  end get_userid;

BEGIN
  ZIU_Write_Log('Start ZIU_Settlement_Zalog(p_AgrId'       ||' => '||p_AgrId||','||
                                           'p_ABS'         ||' => '||p_ABS||','||
                                           'p_ChangeDate'  ||' => '||p_ChangeDate||')');

  p_Status := char_to_sap('OK');

  --����������� ���� ���������
  begin
     select decode(p_ChangeDate ,'00000000',null,to_date(p_ChangeDate , 'YYYYMMDD'))
      into l_ChangeDate
      from dual;
  exception
    when others then
     l_ChangeDate := null;
  end;

  if l_ChangeDate is null then
    raise_application_error(-20000,'ZIU_Settlement_Zalog. �������� ������ ���� �������� ��������� YYYYMMDD ��� ������ ��������.');
  end if;

  --���� ������� ������ �� ����� ���������� � ���������� ������������
  if l_CurrentIdsmr <> p_ABS then
    XXI_CONTEXT.Set_IDSmr (p_ABS);
  end if;

  open cur_czh(p_AgrId,l_ChangeDate);
  fetch cur_czh into l_count_czh;
  close cur_czh;

  if l_count_czh > 0 then

    -- ������� ��������� ������, �������������� ��������� ������
    ZIU_Clear_Temp_Zalog(p_AgrId    => p_AgrId,
                         p_session  => l_session
                         );

    l_ErrMsg := cdenv.test_lock_cd1 (p_AgrId);
    IF l_ErrMsg = 'OK' THEN
      l_ErrMsg := cdenv.test_lock_cdd (p_AgrId);
    END IF;

    IF l_ErrMsg != 'OK' THEN
       raise_application_error(-20000,'ZIU_Settlement_Zalog. ������� '||p_AgrId||' ��� ������������ ��� ������������ �����������������! �������������� ������������� ' || l_ErrMsg);
    ELSE

      INSERT INTO CD1(ncd1AGRID,CCD1SESSION)
               VALUES(p_AgrId,l_session);

      IF PREF.Get_Preference(USER,'Type_Set_CDTdate_from_LSdate')='TRUE' THEN
        l_operdate := CD.get_LSdate;
      ELSE
        l_operdate := l_ChangeDate/*TRUNC(SYSDATE)*/;
      END IF;

      --����������� ������
      cdevents.recalc_cdd_one(agrid    => p_AgrId,
                              evdate   => l_ChangeDate,
                              typemask => '61#62#161#162#'
                              );


      cd2trn.set_acc_cur(null);
      cd2trn.Set_Cur_KBNK(NULL);
      cd2trn.Set_Acc_Out_Cur(NULL);

      --������� ������ � ������� �����
      begin
        update CDD t
           set t.ccddMARKED = 1,
               t.mcddevtsum = t.mcddsum
         where t.ncddagrid = p_AgrId
           and t.ccddsessionid = l_session
           --������ �� ��� ������ � ����, �� � ��������
           and exists(select 1
                        from  xxi.czh tt, xxi."czo" a
                       where tt.NCZHCZO = a.ICZO
                         and a.NCZOAGRID  = t.ncddagrid
                         and tt.nczhczo = t.ncddczo
                         and tt.dczhdate = l_ChangeDate
                     );
      exception
        when NO_DATA_FOUND then
          raise_application_error(-20000,'ZIU_Settlement_Zalog. �� �������� '||p_AgrId||' ��� ������������� ������ ������ ��� ���������� (������� CDD)');
      end;

      l_RegUser := ni_action.fGetAdmUser(ubrr_get_context);

      xxi.triggers.setuser(l_RegUser);
      abr.triggers.setuser(l_RegUser);
      access_2.cur_user_id := get_userid(l_RegUser);

      --���������� ��������� �����������������
      l_StMsg := cd2trn.populate_cdt(errmsg         => l_ErrMsg,
                                     docdate        => l_operdate,
                                     regdate        => l_operdate,
                                     valdate        => l_operdate,
                                     flag_procedure => 'SWIFT'
                                     );
      if l_StMsg != 'OK' then

        if l_ErrMsg is null then
          open cur_sap(l_session);
          fetch cur_sap into l_ErrMsg;
          close cur_sap;
        end if;

        raise_application_error(-20000,'ZIU_Settlement_Zalog. CD2TRN.Populate_CDT ErrMsg = '||l_ErrMsg);
      end if;

      --��������� �������� � ��������
      l_CountErr := CD2TRN.CDT2TRN(outmsg =>l_ErrMsg,
                                   outcnt =>l_CountAcs
                                   );

      xxi.triggers.setuser(null);
      abr.triggers.setuser(null);
      access_2.cur_user_id := get_userid();

      if l_CountErr <> 0 then
        raise_application_error(-20000,'ZIU_Settlement_Zalog. CD2TRN.CDT2TRN OutMESSAGE = '||l_ErrMsg);
      end if;

      CDCOMPL.Init_Tab;

      -- ������� ��������� ������, �������������� ��������� ������
      ZIU_Clear_Temp_Zalog(p_AgrId    => p_AgrId,
                           p_session  => l_session
                           );
    END IF;

  end if;

  --�������� � ������ ������
  if l_CurrentIdsmr <> ubrr_get_context then
    XXI_CONTEXT.Set_IDSmr(l_CurrentIdsmr);
  end if;

  ZIU_Write_Log('End ZIU_Settlement_Zalog ��');

EXCEPTION
  WHEN OTHERS THEN
    ZIU_Write_Log('EXCEPTION ZIU_Settlement_Zalog '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    p_Status   := char_to_sap('ERR');
    p_ErrorMsg := char_to_sap(TS.To_2000 ('������ �������������� ��������� ������ :'||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace));

    xxi.triggers.setuser(null);
    abr.triggers.setuser(null);
    access_2.cur_user_id := get_userid();

    -- ������� ��������� ������, �������������� ��������� ������
    ZIU_Clear_Temp_Zalog(p_AgrId    => p_AgrId,
                         p_session  => l_session
                         );
END;

-------------------------------------------------------------------------------
-- ��������� ��������� ��. ��� ��� �������� �� �������� ����� (��������)
-------------------------------------------------------------------------------
PROCEDURE ZIU_Change_Agr( p_AgrId            in number,      -- ��� ���������� ��������
                          p_ABS              in varchar2,    -- ������
                          p_ChangeDate       in varchar2,    -- ���� �������� �������� (���� �)
                          p_UpdRate          in varchar2,    -- ������� ��������� (���������� ������)
                          p_Rate             in number,      -- ���������� ������
                          p_UpdPenyRate      in varchar2,    -- ������� ��������� (���� �� ��)
                          p_PenyRate         in number,      -- ���� �� ��
                          p_UpdPenyType      in varchar2,    -- ������� ��������� (��� ����� �� ��)
                          p_PenyType         in number,      -- ��� ����� �� �� (������� 0, ������� 1)
                          p_UpdPenyRate2     in varchar2,    -- ������� ��������� (���� �� ��������)
                          p_PenyRate2        in number,      -- ���� �� ��������
                          p_UpdPeny2Type     in varchar2,    -- ������� ��������� (��� ����� �� �������)
                          p_PenyType2        in number,      -- ��� ����� �� �������� (������� 0, ������� 1)
                          p_UpdAmount2       in varchar2,    -- ������� ��������� (����� ������)
                          p_Amount2          in number,      -- ����� ������
                          p_CURR2            in varchar2,    -- ������ ������ (��� �������� � ������� ������� ���������� ��������)
                          p_UpdEndDate       in varchar2,    -- ������� ��������� (���� ��������� ��������)
                          p_EndDate_Old      in varchar2,    -- ���� ��������� �������� (������ ����)
                          p_EndDate_New      in varchar2,    -- ���� ��������� �������� (����� ����)
                          p_PerctermID       in number,      -- id ����� ������ %%
                          p_UpdBicAcc        in varchar2,    -- ������� ��������� (����������)
                          p_caccacc          in varchar2,    -- ������� ����
                          p_BIC              in varchar2,    -- ��� �����
                          p_UpdRepaySch      in varchar2,    -- ������� ��������� (������ �������)
                          p_UpdLimitSch      in varchar2,    -- ������� ��������� (������ ��������� ������)
                          p_CrdType2         in number,      -- ��� ��
                          p_UpdZalog         in varchar2,    -- ������� ��������� (��������� ��������� �����������/ ����������� ����������� ����� 0 )
                          p_Status           out varchar2,   -- ������
                          p_ErrorMsg         out varchar2    -- ��������� �� ������
                         )
  IS

  cursor cur_cda(par_AgrId in xxi.cda.NCDAAGRID%type) is
  select a.*
    from xxi.cda a
   where a.NCDAAGRID = par_AgrId;

  cursor cur_cdh(par_AgrId      in xxi.cdh.ncdhagrid%type,
                 par_ChangeDate in xxi.cdh.dcdhdate%type,
                 par_term       in varchar2) is
  select a.*
    from xxi.cdh a
   where a.ncdhagrid = par_AgrId
     and regexp_like(a.ccdhterm,'^('||par_term||')')
     and a.dcdhdate > par_ChangeDate;

  cursor cur_gr_temp(par_AgrId         in UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.NAGRID%type,
                     par_changedate    in UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.DCHANGEDATE%type,
                     par_changetype    in UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.CCHANGETYPE%type) is
  select t.*
    from UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT t
   where t.nagrid = par_AgrId
     and t.dchangedate = par_changedate
     and t.cchangetype = par_changetype;

  cursor cur_doc_zalog(par_AgrId      in xxi.cdh_doc.ncdhagrid%type,
                       par_Atribut    in xxi.cdh_doc.ccdhatribut%type) is
  select a.icdhid,
         count(a.ccdhatribut) over (order by a.ncdhagrid ) as kol
    from xxi.cdh_doc a
   where a.ncdhagrid = par_AgrId
     and a.ccdhatribut = par_Atribut;

  cursor cur_czh_zalog(par_AgrId      in xxi.cdh_doc.ncdhagrid%type,
                       par_IdDOC      in xxi."czo".NCZOIDDOC%type) is
  select *
    from  xxi.czh
   where NCZHCZO in (select a.ICZO from  xxi."czo" a
                      where a.NCZOAGRID  = par_AgrId
                        and a.NCZOIDDOC  = par_IdDOC
                     );

  LOCKED_AGR      EXCEPTION;
  PRAGMA          EXCEPTION_INIT(LOCKED_AGR, -54);

  type t_tbl_gr_temp is table of cur_gr_temp%rowtype index by binary_integer;
  l_tbl_gr_temp   t_tbl_gr_temp;

  l_rec_cda       cur_cda%rowtype;
  l_rec_cdh       cur_cdh%rowtype;
  l_rec_doc_zalog cur_doc_zalog%rowtype;
  l_rec_czh_zalog cur_czh_zalog%rowtype;

  l_CurrentIdsmr  smr.idsmr%type := ubrr_get_context; --��������� ������
  l_CurrentDate   date := TRUNC(sysdate);
  l_ChangeDate    date;
  l_EndDate_New   date;
  l_EndDate_Old   date;
  l_KodF          number;
  l_cACC          varchar2(25);
  l_IDKBNK        number;
  l_NameBankFOG   varchar2(128);
  l_IsFOG         number;
  l_IsAccSSB      NUMBER;
  l_CurrentBIC    xxi.smr.CSMRMFO8%type;
  l_errmessage    varchar2(2000);
  l_prmessage     varchar2(2000);

  --
  procedure set_errormsg(par_ErrorMsg in varchar2)
    is
  begin
    ZIU_Write_Log('ZIU_Change_Agr ��������������: '||par_ErrorMsg);
    if l_prmessage is null then
      l_prmessage := par_ErrorMsg ;
    else
      l_prmessage := TS.To_2000(l_prmessage ||'#'|| par_ErrorMsg);
    end if;
  end;

  procedure close_cursor
    is
  begin
    if cur_cda%isopen then close cur_cda; end if;
    if cur_cdh%isopen then close cur_cdh; end if;
    if cur_gr_temp%isopen then close cur_gr_temp; end if;
    if cur_doc_zalog%isopen then close cur_doc_zalog; end if;
    if cur_czh_zalog%isopen then close cur_czh_zalog; end if;
  end;

BEGIN
  ZIU_Write_Log('Start ZIU_Change_Agr(p_AgrId'        ||' => '||p_AgrId||','||
                                     'p_ABS'          ||' => '||p_ABS||','||
                                     'p_ChangeDate'   ||' => '||p_ChangeDate||','||
                                     'p_UpdRate'      ||' => '||p_UpdRate||','||
                                     'p_Rate'         ||' => '||p_Rate||','||
                                     'p_UpdPenyRate'  ||' => '||p_UpdPenyRate||','||
                                     'p_PenyRate'     ||' => '||p_PenyRate||','||
                                     'p_UpdPenyType'  ||' => '||p_UpdPenyType||','||
                                     'p_PenyType'     ||' => '||p_PenyType||','||
                                     'p_UpdPenyRate2' ||' => '||p_UpdPenyRate2||','||
                                     'p_PenyRate2'    ||' => '||p_PenyRate2||','||
                                     'p_UpdPeny2Type' ||' => '||p_UpdPeny2Type||','||
                                     'p_PenyType2'    ||' => '||p_PenyType2||','||
                                     'p_UpdAmount2'   ||' => '||p_UpdAmount2||','||
                                     'p_Amount2'      ||' => '||p_Amount2||','||
                                     'p_CURR2'        ||' => '||p_CURR2||','||
                                     'p_UpdEndDate'   ||' => '||p_UpdEndDate||','||
                                     'p_EndDate_Old'  ||' => '||p_EndDate_Old||','||
                                     'p_EndDate_New'  ||' => '||p_EndDate_New||','||
                                     'p_PerctermID'   ||' => '||p_PerctermID||','||
                                     'p_UpdBicAcc'    ||' => '||p_UpdBicAcc||','||
                                     'p_caccacc'      ||' => '||p_caccacc||','||
                                     'p_BIC'          ||' => '||p_BIC||','||
                                     'p_UpdRepaySch'  ||' => '||p_UpdRepaySch||','||
                                     'p_UpdLimitSch'  ||' => '||p_UpdLimitSch||','||
                                     'p_CrdType2'     ||' => '||p_CrdType2||','||
                                     'p_UpdZalog'     ||' => '||p_UpdZalog||')');
  p_Status := char_to_sap('OK');

  --���� ������� ������ �� ����� ���������� � ���������� ������������
  if l_CurrentIdsmr <> p_ABS then
    XXI_CONTEXT.Set_IDSmr (p_ABS);
  end if;

  select CSMRMFO8
    into l_CurrentBIC
    from smr;

  --����������� ���� ���������
  begin
     select decode(p_ChangeDate ,'00000000',null,to_date(p_ChangeDate , 'YYYYMMDD'))
      into l_ChangeDate
      from dual;
  exception
    when others then
     l_ChangeDate := null;
  end;

  if l_ChangeDate is null then
    raise_application_error(-20000,'ZIU_Change_Agr. �������� ������ ���� �������� ��������� YYYYMMDD ��� ������ ��������.');
  end if;

  --������� ��� ����� ������� ����
  open cur_cda(p_AgrId);
  fetch cur_cda into l_rec_cda;
  if cur_cda%notfound then
    raise_application_error(-20000,'ZIU_Change_Agr. ������� c �'||p_AgrId||' �� ������');
  end if;
  close cur_cda;

 /* ----------------------------------------
  if 1=1 \*�������� ���� �������� ������ �� SAP ������ �� ������ *\  then
    raise_application_error (-20000,'����������� ��������!!!');
  end if;
  ----------------------------------------*/

  IF (upper(p_UpdRate) = 'X' or upper(p_UpdPenyRate) = 'X' or upper(p_UpdPenyType) = 'X' or upper(p_UpdPenyRate2) = 'X' or upper(p_UpdPeny2Type) = 'X') THEN

    --6.1.13.3.2.  ���������� % ������
    if upper(p_UpdRate) = 'X' then

      cd.update_history(agrid   => l_rec_cda.ncdaagrid,
                        part    => null,
                        term    => 'INTRATE',
                        effdate => l_ChangeDate,
                        mval    => null,
                        pval    => p_Rate,
                        ival    => null,
                        cval    => null
                        );

      cd.update_history(agrid   => l_rec_cda.ncdaagrid,
                        part    => null,
                        term    => 'OVDRATE',
                        effdate => l_ChangeDate,
                        mval    => null,
                        pval    => p_Rate,
                        ival    => null,
                        cval    => null
                        );

      if l_ChangeDate > l_CurrentDate then
        set_errormsg('���������� ������ ����������� ������� ����� '|| to_char(l_ChangeDate,'DD.MM.YYYY') ||'.' );
      end if;

      l_rec_cdh := null;
      open cur_cdh(l_rec_cda.ncdaagrid,l_ChangeDate,'INTRATE|OVDRATE');
      fetch cur_cdh into l_rec_cdh;
      close cur_cdh;

      if l_rec_cdh.ncdhagrid is not null then
        set_errormsg('� �� ���� ������������� ����� % ������ � ������ > '|| to_char(l_ChangeDate,'DD.MM.YYYY') ||', ��������� ������������� �� ��������.' );
      end if;
    end if;

    --6.1.13.3.3.  ���������� ��� � % ���� �� �� � %
    --���� �� ��
    if upper(p_UpdPenyRate) = 'X' then
      cd.update_history(agrid   => l_rec_cda.ncdaagrid,
                        part    => null,
                        term    => 'LOANFINE',
                        effdate => l_ChangeDate,
                        mval    => null,
                        pval    => p_PenyRate,
                        ival    => null,
                        cval    => null
                        );

    end if;
    --��� ����� �� ��
    if upper(p_UpdPenyType) = 'X' then
      cd.update_history(agrid   => l_rec_cda.ncdaagrid,
                        part    => 1,
                        term    => 'LFEETYPE',
                        effdate => l_ChangeDate,
                        mval    => null,
                        pval    => null,
                        ival    => (case when p_PenyType = 0 then 1 else 0 end), --���� 0, �� ���,
                        cval    => null
                        );
    end if;

    --���� �� ��������
    if upper(p_UpdPenyRate2) = 'X' then
      cd.update_history(agrid   => l_rec_cda.ncdaagrid,
                        part    => null,
                        term    => 'INTFINE',
                        effdate => l_ChangeDate,
                        mval    => null,
                        pval    => p_PenyRate2,
                        ival    => null,
                        cval    => null
                        );
    end if;
    --��� ����� �� ��������
    if upper(p_UpdPeny2Type) = 'X' then
      begin
        update xxi.cda a
           set a.ICDAFEETYPE4I = decode(p_PenyType2,0,1,0) --���� 0, �� ���
         where a.NCDAAGRID = l_rec_cda.ncdaagrid;
      end;
    end if;

    if l_ChangeDate > l_CurrentDate and (upper(p_UpdPenyRate) = 'X' or upper(p_UpdPenyType) = 'X' or upper(p_UpdPenyRate2) = 'X' or upper(p_UpdPeny2Type) = 'X') then
      set_errormsg('���������� ����/��� ���� ����������� ������� ����� '|| to_char(l_ChangeDate,'DD.MM.YYYY') ||'.' );
    end if;

    l_rec_cdh := null;
    open cur_cdh(l_rec_cda.ncdaagrid,l_ChangeDate,'LOANFINE|LFEETYPE|INTFINE');
    fetch cur_cdh into l_rec_cdh;
    close cur_cdh;

    if l_rec_cdh.ncdhagrid is not null and (upper(p_UpdPenyRate) = 'X' or upper(p_UpdPenyType) = 'X' or upper(p_UpdPenyRate2) = 'X') then
      set_errormsg('� �� ���� ������������� ����� % ������/��� ���� � ������ > '|| to_char(l_ChangeDate,'DD.MM.YYYY') ||', ��������� ������������� �� ��������.' );
    end if;

  END IF;

  --6.1.13.3.4.  ���������� �����/������
  IF upper(p_UpdAmount2) = 'X' THEN

    if l_rec_cda.ccdacuriso = p_CURR2 then

      update xxi.cda a
         set a.MCDATOTAL = p_Amount2
       where a.NCDAAGRID = l_rec_cda.ncdaagrid;

      --���� ��� ������� ��������� (� ����������/������������ �������) - �� ������������� �������� ��� ���� � ��� ������ ��������� ������
      If p_CrdType2 in (2,6) then
        --������� ������ ������
        delete from xxi.cdh a
         where a.ccdhterm = 'LIMIT'
           and a.ncdhagrid = l_rec_cda.ncdaagrid
           and a.dcdhdate >= l_ChangeDate
           and a.icdhpart = 1;

        --������� ������ LIMIT � �����
        cd.update_history(agrid   => l_rec_cda.ncdaagrid,
                          part    => 1,
                          term    => 'LIMIT',
                          effdate => l_ChangeDate,
                          mval    => p_Amount2,
                          pval    => null,
                          ival    => null,
                          cval    => null
                          );
      end if;

    else
      set_errormsg('���������� ������ �� � ����������� ��������� �����/������ �������� �������.' );
    end if;
  END IF;

  --6.1.13.3.5.  ���������� ���� ��������� ��������
  IF upper(p_UpdEndDate) = 'X' and p_CrdType2 in (3,4,2,6) THEN

    --����������� ���� ���������
    begin
       select decode(p_EndDate_New ,'00000000',null,to_date(p_EndDate_New , 'YYYYMMDD')),
              decode(p_EndDate_Old ,'00000000',null,to_date(p_EndDate_Old , 'YYYYMMDD'))
         into l_EndDate_New,
              l_EndDate_Old
         from dual;
    exception
      when others then
       l_EndDate_New := null;
       l_EndDate_Old := null;
    end;

    if l_EndDate_New is not null or l_EndDate_Old is not null then

      --6.1.13.3.5.2.  ���� ������ ���� ��������� < ����� ���� ���������
      if l_EndDate_Old < l_EndDate_New and p_CrdType2 in (2,6) then
        if p_PerctermID = 999 then
          set_errormsg('���� ������ % �� ����. ������� � ����������� ��������� ������� ���������� � ������ % �������.' );
        else
          ZIU_Calc_Interval(p_agrid      => l_rec_cda.ncdaagrid,
                            p_startdate  => trunc(l_EndDate_Old,'MONTH'),
                            p_finishdate => l_EndDate_New,
                            p_PerctermID => p_PerctermID,
                            p_errmessage => l_errmessage
                           );
          if l_errmessage is not null then
            raise_application_error(-20000,l_errmessage);
          end if;
        end if;
      end if;

      --6.1.13.3.5.3.  ���� ������ ���� ��������� >  ����� ���� ���������
      if l_EndDate_Old > l_EndDate_New and p_CrdType2 in (2,6)  then
        set_errormsg('���� �� ����������� � ����������� �������������� ������ ���������� � ������ % �������.' );
      end if;

      update xxi.cda a
         set a.dcdalineend = l_EndDate_New
       where a.NCDAAGRID = l_rec_cda.ncdaagrid;
    else
      raise_application_error(-20000,'ZIU_Change_Agr. �������� ������ ������/����� ���� ��������� �������� YYYYMMDD ��� ������ ��������.');
    end if;
  END IF;

  --6.1.13.3.9.  ���������� ��������� ����������
  IF upper(p_UpdBicAcc) = 'X' THEN

    select count('x')
      into l_IsFOG
      from FOG
     where CFOGMFO8 = p_BIC;
    if l_IsFOG >0 then
      select CFOGNAME
        into l_NameBankFOG
        from FOG
       where CFOGMFO8 = p_BIC;
    end if;

    begin
      select NBNK_ID
        into l_IDKBNK
        from KBNK
       where CBNK_RBIC = p_BIC;
    exception
      when NO_DATA_FOUND then
      l_IDKBNK := null;
    end;

    select count('x')
      into l_IsAccSSB
      from xxi."acc"
     where CACCACC = p_caccacc
       and CACCCUR = l_rec_cda.ccdacuriso
       and IDSMR = '2';
    begin
      select CACCACC
        into l_cACC
        from ACC
       where CACCACC = p_caccacc and CACCCUR = l_rec_cda.ccdacuriso;
    exception
      when NO_DATA_FOUND then
       l_cACC := null;
    end;

    IF p_BIC is null or p_caccacc is null or p_BIC = '' or p_caccacc = '' or p_BIC = '0' or p_caccacc ='0' or p_BIC = '000000000' or p_caccacc ='00000000000000000000' THEN
      l_KodF := null;
      l_cACC := null;
    ELSIF p_BIC is not null and p_BIC <> '' and (l_IsFOG=0 and l_IDKBNK is null) THEN
      l_KodF := null;
      l_cACC := null;
    ELSIF p_BIC = l_CurrentBIC and l_cACC is not null THEN
      l_KodF := null;
    ELSIF p_BIC = '046577795' and p_ABS = '1' and l_IsAccSSB >0 THEN
      l_KodF := 2903;
      l_cACC := null;
    ELSIF l_IDKBNK is not null THEN
      l_KodF := l_IDKBNK;
      l_cACC := null;
    ELSIF l_IDKBNK is null and p_BIC <> '046577795' THEN
      insert into kbnk (cbnk_rbic, cbnk_name)
                values (p_BIC, l_NameBankFOG)
             returning NBNK_ID into l_IDKBNK;
      l_KodF := l_IDKBNK;
      l_cACC := null;
    ELSE
      l_KodF := null;
      l_cACC := null;
    END IF;

    update xxi.cda a
       set a.CCDACURRENTACC = l_cACC
     where a.ncdaagrid = l_rec_cda.ncdaagrid;

    if l_KodF is not null then

      --������� ��� ������� ����� �������� �. 6.1.13.3.9.1
      delete from CDA_ACC_OUT t
        where t.naddagrid = l_rec_cda.ncdaagrid;

      BEGIN
        insert into CDA_ACC_OUT (NADDAGRID,
                                 IADDTYPEOUT,
                                 NADDTYPE,
                                 CADDACC,
                                 CADDCURISO,
                                 NADDKBNKID)
                        values (l_rec_cda.ncdaagrid,
                                2,
                                2,
                                p_caccacc,
                                l_rec_cda.ccdacuriso,
                                l_KodF);

      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          null;
      END;
    end if;
  END IF;

  --6.1.13.3.6.  ���������� ������ �������
  IF upper(p_UpdRepaySch) = 'X' and p_CrdType2 in ( 1 ) THEN

    --������� ������ ������
    delete from xxi.cdr a
      where a.ncdragrid = l_rec_cda.ncdaagrid
        and a.dcdrdate >= l_ChangeDate
        and a.icdrpart = 1;

    l_tbl_gr_temp.delete;

    --������� �����
    --������ �������� �� ��������� �������
    open cur_gr_temp(l_rec_cda.ncdaagrid,l_ChangeDate,'GR_REPAY');
    fetch cur_gr_temp bulk collect into l_tbl_gr_temp;
    close cur_gr_temp;

    if l_tbl_gr_temp.count() = 0  then
      raise_application_error(-20000,'ZIU_Change_Agr. ���������� ������� ������� ������� �������, �� ��� ����� ������ ��� ������ ��.');
    end if;

    for i in l_tbl_gr_temp.first .. l_tbl_gr_temp.last
      loop
        --������� �� ����������� ������� �� ��� ������ �����
        if l_tbl_gr_temp(i).dgrdate >= l_ChangeDate then
          BEGIN
            insert into xxi.cdr( ncdragrid,
                                 icdrpart,
                                 dcdrdate,
                                 mcdrsum,
                                 dcdrlatest
                                )
                         values( l_tbl_gr_temp(i).nagrid,
                                 l_tbl_gr_temp(i).npart,
                                 l_tbl_gr_temp(i).dgrdate,
                                 l_tbl_gr_temp(i).msum,
                                 l_tbl_gr_temp(i).dgrdate
                                );
          EXCEPTION
             WHEN DUP_VAL_ON_INDEX THEN
               raise_application_error(-20000,'ZIU_Change_Agr. ��� ������� ������� ������� �������� ����������� ������������ ��� ������� ��.');
          END;
        end if;
      end loop;

  END IF;

  --6.1.13.3.7.  ���������� ������ ��������� ������
  IF upper(p_UpdLimitSch) = 'X' and p_CrdType2 in (3, 4, 2, 6) THEN

    --������� ������ ������
    delete from xxi.cdh a
     where a.ccdhterm = 'LIMIT'
       and a.ncdhagrid = l_rec_cda.ncdaagrid
       and a.dcdhdate >= l_ChangeDate
       and a.icdhpart = 1;

    l_tbl_gr_temp.delete;

    --������� �����
    --������ �������� �� ��������� �������
    open cur_gr_temp(l_rec_cda.ncdaagrid,l_ChangeDate,'GR_LIMIT');
    fetch cur_gr_temp bulk collect into l_tbl_gr_temp;
    close cur_gr_temp;

    if l_tbl_gr_temp.count() = 0  then
      raise_application_error (-20000,'ZIU_Change_Agr. ���������� ������� ������� ������� ��������� ������, �� ��� ����� ������ ��� ������ ��.');
    end if;

    for i in l_tbl_gr_temp.first .. l_tbl_gr_temp.last
      loop
        --������� �� ����������� ������� �� ��� ������ �����
        if l_tbl_gr_temp(i).dgrdate >= l_ChangeDate then
          cd.update_history(agrid   => l_tbl_gr_temp(i).nagrid,
                            part    => l_tbl_gr_temp(i).npart,
                            term    => l_tbl_gr_temp(i).cterm,
                            effdate => l_tbl_gr_temp(i).dgrdate,
                            mval    => l_tbl_gr_temp(i).msum,
                            pval    => null,
                            ival    => null,
                            cval    => null
                            );
        end if;
      end loop;

  END IF;

  --6.1.13.3.8.  ���������� �������� �����������
  IF upper(p_UpdZalog) = 'X' THEN

    l_tbl_gr_temp.delete;

    --������ �������� �� ��������� �������
    open cur_gr_temp(l_rec_cda.ncdaagrid,l_ChangeDate,'CH_ZALOG');
    fetch cur_gr_temp bulk collect into l_tbl_gr_temp;
    close cur_gr_temp;

    if l_tbl_gr_temp.count() = 0  then
      raise_application_error (-20000,'ZIU_Change_Agr. ���������� ������� ������� �����������, �� ��� ������ ��� ������ ��.');
    end if;

    for i in l_tbl_gr_temp.first .. l_tbl_gr_temp.last
      loop

        --6.1.13.3.8.1. ���� ���������� ��������� ��������� l_tbl_gr_temp(i).msum > 0
        --6.1.13.3.8.2. ���� ������������ �������� ��������� ����������� (����� 0) l_tbl_gr_temp(i).msum = 0
        l_rec_doc_zalog := null;

        open cur_doc_zalog(l_tbl_gr_temp(i).nagrid,l_tbl_gr_temp(i).catribut);
        fetch cur_doc_zalog into l_rec_doc_zalog;
        close cur_doc_zalog;

        if l_rec_doc_zalog.kol = 1 then

          open cur_czh_zalog(l_tbl_gr_temp(i).nagrid,l_rec_doc_zalog.icdhid);
          fetch cur_czh_zalog into l_rec_czh_zalog;
          close cur_czh_zalog;

          SELECT S_CZH.nextval
            into l_rec_czh_zalog.iczh
            from sys.dual;

          l_rec_czh_zalog.cczhoperator := USER;
          l_rec_czh_zalog.nczhsumma := l_tbl_gr_temp(i).msum;
          l_rec_czh_zalog.mczhsumliquid := l_tbl_gr_temp(i).msum;
          l_rec_czh_zalog.dczhdate := l_ChangeDate;

          --���� ���� � ���� ���������
          delete from xxi.czh a
              where a.nczhczo = l_rec_czh_zalog.nczhczo
                and a.dczhdate = l_rec_czh_zalog.dczhdate;

          --������� �����
          insert into xxi.czh (ICZH,
                               NCZHCZO,
                               DCZHDATE,
                               NCZHSUMMA,
                               CCZHOPERATOR,
                               CCZHCOMMENT,
                               MCZHSUMLIQUID,
                               NCZHDOCID,
                               CCZHCURLIQUID
                               )
                       values (l_rec_czh_zalog.iczh,
                               l_rec_czh_zalog.nczhczo,
                               l_rec_czh_zalog.dczhdate,
                               l_rec_czh_zalog.nczhsumma,
                               l_rec_czh_zalog.cczhoperator,
                               decode(l_rec_czh_zalog.nczhsumma,0,'�������� ����� ������','��������� ��������� �����������'),
                               l_rec_czh_zalog.mczhsumliquid,
                               l_rec_czh_zalog.nczhdocid,
                               l_rec_czh_zalog.cczhcurliquid
                               );

        else
          set_errormsg('� �� '||l_tbl_gr_temp(i).nagrid||' � ��� �� ������ ��� �� ������������ ������� ����������� � ��. ������� '||l_tbl_gr_temp(i).catribut||' � ����������� �� ���� ��������� �������.' );
        end if;

      end loop;

  END IF;

  --������ ��������������
  if l_prmessage is not null then
    p_ErrorMsg := char_to_sap(l_prmessage);
  end if;

  --�������� � ������ ������
  if l_CurrentIdsmr <> ubrr_get_context then
    XXI_CONTEXT.Set_IDSmr(l_CurrentIdsmr);
  end if;

  --������� �������
  ZIU_Clear_ubrr_sap_ziu_temp;

  ZIU_Write_Log('End ZIU_Change_Agr '||utl_raw.cast_to_varchar2(p_status));

EXCEPTION
  WHEN LOCKED_AGR THEN
    dbms_transaction.rollback;
    ZIU_Write_Log('EXCEPTION ZIU_Change_Agr '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    p_Status   := char_to_sap('ERR');
    p_ErrorMsg := char_to_sap('������ : ZIU_Change_Agr. ������� �'||p_AgrId||' ������������');
    close_cursor;
    --������� �������
    ZIU_Clear_ubrr_sap_ziu_temp;
  WHEN OTHERS THEN
    dbms_transaction.rollback;
    ZIU_Write_Log('EXCEPTION ZIU_Change_Agr '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    p_Status   := char_to_sap('ERR');
    p_ErrorMsg := char_to_sap(TS.To_2000 ('������ : '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace));
    close_cursor;
    --������� �������
    ZIU_Clear_ubrr_sap_ziu_temp;
END;
--<<22.03.2021  ������� �.�.     DKBPA-105 ���� 4.1 (���������� ���): ������ ������������. ��� ��� �������� �� �������� �����

END;
/
