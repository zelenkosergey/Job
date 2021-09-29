CREATE OR REPLACE PACKAGE BODY UBRR_XXI5."UBRR_UNQ_COMMS_P" as

PROCEDURE ubrr_unq_comms (
    ptrn        number   ,
    acc_1       VARCHAR2 ,
    d1          DATE     ,
    d2          DATE     ,
    dtrn        DATE DEFAULT NULL,
    crmes   OUT VARCHAR2 ,
    cnt_    OUT NUMBER)
IS
/*************************************************** HISTORY *****************************************************\
   ����          �����          id        ��������
----------  ---------------  --------- ------------------------------------------------------------------------------
             Pashevich A.   ������� �������
                            ������  ��� �������, ������ ����� ����� �� ������
03.07.2013   Pashevich A.   ������������ �������� ����� ������� �� ����� ������� � ���� ����������� �� � ����� � ������ ���������
16.07.2013   Pashevich A.   ������ �������� �� �������������� � �������� ������ (Insert in SBS) ��� ������������ ��������
                                                                ���������� - Insert in SBS  + ������������ ��������
05.05.2016   �������� �.�.  [16-1808.2.3.5.4.3.2]  #29736  ��� ���
05.04.2018   ������ �.�.  [17-895] ���: �������� �������� �� �������������� �� ���
31.08.2020   ������� �.�.   [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� 
\*************************************************** HISTORY *****************************************************/   

    -- gccidsmrinitial   CONSTANT acc.idsmr%TYPE := SYS_CONTEXT ('B21', 'IDSMR');
    dcsysdate         CONSTANT DATE := SYSDATE;
    dccommdate        CONSTANT DATE := TRUNC (dcsysdate) - 1;
    -->>-- 05.04.2018 ������ [17-895] ���: �������� �������� �� �������������� �� ���
    AddPref           VARCHAR2(3) := case when ubrr_util.getbankIdSmr = 1 then '' else ubrr_util.getbankIdSmr  end; 
    --<<-- 05.04.2018 ������ [17-895] ���: �������� �������� �� �������������� �� ���
    lc_idsmr          smr.idsmr%type := sys_context ('B21', 'IDSmr'); --31.08.2020   ������� �.�.   [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
    -- Ubrr Pashevich A. 16.07.2013 �������� �� "������" ���������� XXI5
    -- ����������� ������������� ��� ������� �������������
    PROCEDURE setotis
    IS
        cvotis   xxi.usr.cusrlogname%TYPE;
    BEGIN
      null;
/*      IF SYS_CONTEXT ('b21', 'idsmr') = '1'
        THEN
            cvotis := 'T_SENCASH';
        ELSE
            BEGIN
                SELECT cusrlogname
                  INTO cvotis
                  FROM usr
                 WHERE cusrlogname LIKE 'T\____\_SENCASH' ESCAPE '\'
                       AND idsmr = SYS_CONTEXT ('b21', 'idsmr');
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;
        END IF;
        xxi.triggers.setuser (cvotis);
        abr.triggers.setuser (cvotis);*/
    END;
    -- Ubrr Pashevich A. 16.07.2013 �������� �� "������" ���������� XXI5
    -- ����������� ������������� ��� ������� �������������

    PROCEDURE setups (cppref VARCHAR2, cpvalue VARCHAR2)
    IS
    BEGIN
        UPDATE ups
           SET cupsvalue = cpvalue
         WHERE cupsuser = 'ALL$' AND cupspref = cppref;
    END;
BEGIN
       crmes := 'NULL';
    DECLARE
        v_acc_1                   varchar2(20)    ;
        ivaccotd                  acc.iaccotd%TYPE;
        cvotdname                 otd.cotdname%TYPE;
        cvaccsio                  acc.caccsio%TYPE;
        dvacclastoper             acc.dacclastoper%TYPE;
        rvtrn                     xxi."trn"%ROWTYPE;
        rvdocument                ubrr_zaa_comms.rtdocument;
        rvretdoc                  ubrr_zaa_comms.rtretdoc;
        rvcomm                    ubrr_data.ubrr_sencash_comm_trn%ROWTYPE;
        cccommsaccmask   CONSTANT xxi.ups.cupsvalue%TYPE
            := pref.get_preference ('ALL$', 'UBRR_SENCASH|COMMS_ACC_MASK') ;
        cvaccmask                 acc.caccacc%TYPE;
        bvnewaccount              BOOLEAN;
        rvbvbacc                  ts.t_account;
        dvaccopen                 DATE;
        CURSOR c_comm
        IS
            SELECT icard_objectuid,
                   -- Ubrr Pashevich A. 16.07.2013 ������ �� ���������� �� ����������� ������
                   --                              � SBS ������� ���������� ���� +
                   --                              ����� �� ���������� ����������� ������
                   COUNT (distinct tr.dtrncreate) * unq.coms sumcoms,
                   COUNT (DISTINCT tr.dtrncreate) pcount,
                   unq.coms cm,
                   -- Ubrr Pashevich A. 16.07.2013
                   -- rowid ��������� �������� � ���, �� ��� ����� ���������� ���� � �������� ����� ��������
                   MAX (tr.ROWID)
                   KEEP (DENSE_RANK LAST ORDER BY tr.itrnnum, tr.itrnanum)
                       trnrowid
              FROM ubrr_data.ubrr_sencash_trn t,
                   ubrr_data.ubrr_sencash_file_record r,
                   -->>31.08.2020   ������� �.�.   [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ �� 
                   (select uutc.cacc,
                           uuac.summ_def coms,
                           uutc.dopentarif,
                           uutc.dcanceltarif
                      from UBRR_UNIQUE_TARIF_ACC uutc,
                           UBRR_UNIQUE_ACC_COMMS uuac
                     where uutc.idsmr = lc_idsmr 
                       and uutc.status = 'N'
                       and uutc.uuta_id = uuac.uuta_id
                       and uuac.daily = 'Y'
                       and uuac.com_type = 'SENCASH') unq,
                     --<<31.08.2020   ������� �.�.   [20-73382] �������������� ������ �� �������� ���������, �� ��������� � ������ ��
                     -- Ubrr Pashevich A. 16.07.2013 ������� ������ ������ �� �������, �� ������ ������� ������
                     trn tr
                     -- Ubrr Pashevich A. 16.07.2013 ������� ������ ������ �� �������, �� ������ ������� ������
--                   xxi."trn" tr
             WHERE     t.dtrndoc BETWEEN d1 AND d2
                   AND tr.ctrnaccc LIKE v_acc_1---acc_1
                   AND t.ctrnaccc LIKE '4%'
                   AND r.ifile_id = t.ifile_id
                   AND r.irecord_num = t.irecord_num
                   AND tr.itrnnum = t.itrnnum
                   AND tr.itrnanum = t.itrnanum
                   AND r.icard_objectuid IS NOT NULL
                   -- Ubrr Pashevich A. 16.07.2013
                   -- ���� ������ ������ �� ��� �������,
                   -- ����� � ����� ���������,
                   -- �� � �� ��������� ��-����� �� ��������� �� ��
                   -- ��� ����������� ��� ���������� ���������
                   -- Ubrr Pashevich A. 16.07.2013
                   -- ��� �� ����� �������� � ���� �����
                   /*AND NOT EXISTS
                               (SELECT 1
                                  FROM ubrr_data.ubrr_sencash_comm_trn c
                                 WHERE c.icard_objectuid = r.icard_objectuid
                                       AND c.dtrndoc_comm = t.dtrndoc
                                       AND (c.itrnnum_comm IS NOT NULL
                                            OR c.itrcnum_comm IS NOT NULL))*/
                   AND tr.ctrnaccc = unq.cacc
                   AND t.dtrndoc BETWEEN unq.dopentarif AND unq.dcanceltarif
            GROUP BY icard_objectuid, unq.coms;
    BEGIN
-- Pashevich A . ������ �����
        v_acc_1 := nvl(trim(acc_1),'%');
-- Pashevich A . ������ �����
        crmes := 'NULL';
        cnt_ := 0;

        FOR rcomm IN c_comm
        LOOP
            BEGIN
                SELECT *
                  INTO rvtrn
                      -- Ubrr Pashevich A. 16.07.2013 ������� ������ ������ �� �������, �� ������ ������� ������
                  FROM /*xxi."trn"*/trn
                      -- Ubrr Pashevich A. 16.07.2013 ������� ������ ������ �� �������, �� ������ ������� ������
                 WHERE ROWID = rcomm.trnrowid;
                -- Ubrr Pashevich A. 16.07.2013. �������� �� ������, ��������� ��� ,
                --                               �� �������� ���� ������
                /*IF rvtrn.idsmr != SYS_CONTEXT ('B21', 'IDSMR')
                THEN
                    xxi_context.set_idsmr (rvtrn.idsmr);
                END IF;*/
                -- Ubrr Pashevich A. 16.07.2013

                rvcomm := NULL;
                rvcomm.dtrndoc_comm := rvtrn.dtrndoc;
                rvcomm.icard_objectuid := rcomm.icard_objectuid;

                SELECT iaccotd,
                       cotdname,
                       caccsio,
                       dacclastoper,
                       TO_NUMBER (TO_CHAR (NVL (iotdbatnum, 70)) || '00')
                  INTO ivaccotd,
                       cvotdname,
                       cvaccsio,
                       dvacclastoper,
                       rvdocument.ibatnum
                  FROM acc, otd
                 WHERE     caccacc = rvtrn.ctrnaccc
                       AND cacccur = rvtrn.ctrncurc
                       AND iotdnum = iaccotd;

                ---rvDocument.cModule := 'UBRR_SENCASH_PKG';
                rvdocument.caccd := rvtrn.ctrnaccc;
                rvdocument.ccurd := rvtrn.ctrncurc;
                
                -->>-- 05.04.2018 ������ �.�. [17-895] ���: �������� �������� �� �������������� �� ���
                declare
                       vCode varchar2(3);
                       vSymbUl varchar2(5);
                       vSymbIp varchar2(5);
                begin
                       vCode := pref.get_preference('ALL$'||AddPref,'UBRR_SENCASH|COMMS_CODE');
                       vSymbUl := pref.get_preference('ALL$'||AddPref,'UBRR_SENCASH|COMMS_SYMB|UL');
                       vSymbIp := pref.get_preference('ALL$'||AddPref,'UBRR_SENCASH|COMMS_SYMB|IP');
                       cvaccmask :=
                       UBRR_RKO_SYMBOLS.get_new_rko_mask(to_char(ivAccOtd), vCode, rvTrn.cTrnAccC,rvTrn.cTrnCurC,vSymbUl,vSymbIp);
                end;
                 --cvaccmask := REPLACE (cccommsaccmask, '#OTD#', ivaccotd);
                --<<-- 05.04.2018 ������ �.�. [17-895] ���: �������� �������� �� �������������� �� ���

                BEGIN
                    SELECT caccacc, cacccur, caccname
                      INTO rvdocument.caccc,
                           rvdocument.ccurc,
                           rvdocument.cnamec
                      FROM acc
                     WHERE caccacc LIKE cvaccmask
                           AND cacccur = rvtrn.ctrncurc;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        crmes :=
                            '�� ������� ���������� ���� 70601 ��� �������� �� ��������';
                END;

                rvdocument.msumd := rcomm.sumcoms; -->><<-- 05.04.2018 ������ �.�. [17-895] ���: �������� �������� �� �������������� �� ���
                rvdocument.msumc := rcomm.sumcoms;
                rvdocument.dtran := dtrn;
                rvdocument.dcomm := TRUNC (rvtrn.dtrndoc);
                rvdocument.cpurp :=
                       rvdocument.cnamec
                -->>-- 06.04.2018 ������ [17-895] ���: �������� �������� �� �������������� �� ���                       
                     || '��  '
/*                    || '�  ' */
                    || TO_CHAR (d1, 'dd.mm.yyyy')
/*                    || ' �� '
                    || TO_CHAR (d2, 'dd.mm.yyyy')
                    || ', ����� '
                    || ubrr_zaa_pmnu.uid2wpan(rcomm.icard_objectuid)
*/                    
                --<<-- 06.04.2018 ������ [17-895] ���: �������� �������� �� �������������� �� ���                       
                    || ' �� ���. '
                    || cvaccsio
                    || ' �� '
                    || TO_CHAR (dvacclastoper, 'dd.mm.yyyy')
                    || CHR (10)
                    || '��� �� ����������'
                    ;
                rvdocument.ibo1 := 25;
                rvdocument.ibo2 := 115;
                rvdocument.idocnum :=
                    idoc_util.get_nextautonum (rvdocument.ibo1,
                                               rvdocument.dtran);
                rvdocument.ctype := 'T';
                setotis;

                -- Ubrr Pashevich A. 16.07.2013 ��������� SBS
                INSERT INTO sbs (csbsacc,
                                 csbscur,
                                 msbstoll_sum,
                                 csbspayfrom_acc,
                                 csbsdo,
                                 msbscomm,
                                 isbsdebdoc,
                                 idsmr)
                VALUES (rvdocument.caccd,
                        rvdocument.ccurd,
                        rvdocument.msumc,
                        rvdocument.caccc,
                        'SEN',
                        rcomm.cm,
                        rcomm.pcount,
                        rvtrn.idsmr);
                dbms_sql_add.commit;
                
              -- Ubrr Pashevich A. 16.07.2013
            IF ptrn = 0
             THEN
                rvretdoc := ubrr_zaa_comms.register (rvdocument);
                -->> Podkidyshev 2013-02-19
                -- https://redmine.lan.ubrr.ru/issues/6279
                -- https://redmine.lan.ubrr.ru/issues/6492
                IF rvretdoc.cresult LIKE
                       '���������� ���������� �� ���������:%'
                THEN
                    rvdocument.ctype := 'TC';
                    -- ���� ������� ������������ � ����������� �����,
                    -- ��� ��� �� ����� ���� ������ ���� �����, � ���� ��,
                    -- ���������������� T_SENCASH ������������ ��� �������� ������ �����
                    -- � � �������� �������� ������� ������������, ��� �����������
                    setotis;
                    rvbvbacc :=
                        card.get_bvbaccount (rvretdoc.cresult,
                                             bvnewaccount,
                                             rvdocument.dcomm,
                                             rvdocument.caccd,
                                             rvdocument.ccurd,
                                             '2',
                                             rvdocument.ccurd);

                    IF NOT bvnewaccount
                    THEN
                        SELECT daccopen
                          INTO dvaccopen
                          FROM acc
                         WHERE caccacc = rvbvbacc.cacc
                               AND cacccur = rvbvbacc.ccur;
                        -- ���� �������� ����� ���� ������, ��� ��� ������� ������ ��������������
                        IF dvaccopen > rvdocument.dcomm
                        THEN
                          
                            UPDATE acc
                               SET daccopen = rvdocument.dcomm
                             WHERE caccacc = rvbvbacc.cacc
                                   AND cacccur = rvbvbacc.ccur;
                        END IF;
                    END IF;

                    setotis;

                    rvbvbacc :=
                        card.get_bvbaccount (rvretdoc.cresult,
                                             bvnewaccount,
                                             rvdocument.dcomm,
                                             rvdocument.caccd,
                                             rvdocument.ccurd,
                                             '0',
                                             rvdocument.ccurd);

                    IF NOT bvnewaccount
                    THEN
                        SELECT daccopen
                          INTO dvaccopen
                          FROM acc
                         WHERE caccacc = rvbvbacc.cacc
                               AND cacccur = rvbvbacc.ccur;

                        -- ���� �������� ����� ���� ������, ��� ��� ������� ������ ��������������
                        IF dvaccopen > rvdocument.dcomm
                        THEN
                            UPDATE acc
                               SET daccopen = rvdocument.dcomm
                             WHERE caccacc = rvbvbacc.cacc
                                   AND cacccur = rvbvbacc.ccur;
                        END IF;
                    END IF;

                    setotis;
                    rvretdoc := ubrr_zaa_comms.register (rvdocument);
                    
                END IF;

                --<< Podkidyshev 2013-02-19
                IF rvretdoc.cresult != 'OK'
                THEN
                    crmes := rvretdoc.cresult;
                END IF;

             --   dbms_output.put_line('rvdocument.caccd='||rvdocument.caccd);
             --   dbms_output.put_line('rvdocument.ctype='||rvdocument.ctype);                    

                IF rvretdoc.cresult = 'OK'
                THEN
                   -->>-- 06.04.2018 ������ [17-895] ���: �������� �������� �� �������������� �� ���     
                   Update sbs
                    Set csbspayfrom_cur = decode(rvdocument.ctype, 'T', 'TRN', 'TRC') 
                    Where csbsacc = rvdocument.caccd;                  
                   --<<-- 06.04.2018 ������ [17-895] ���: �������� �������� �� �������������� �� ���      
                    cnt_ := cnt_ + 1;
                END IF;

                rvcomm.itrnnum_comm := rvretdoc.inum;
                rvcomm.itrnanum_comm := rvretdoc.ianum;
                rvcomm.itrcnum_comm := rvretdoc.icardnum;

                IF crmes = 'NULL'
                THEN
                    crmes := 'OK';
                END IF;
                
        Else
          rvretdoc.cresult:=null;
        end if;
            EXCEPTION
                WHEN OTHERS
                THEN
                    crmes := 'Error';
                    rvcomm.itrnnum_comm := NULL;
                    rvcomm.itrnanum_comm := NULL;
                    rvcomm.itrcnum_comm := NULL;
            END;
/*        begin
          insert into ubrr_data.ubrr_sencash_comm_trn values rvComm;
        /*exception
          when dup_val_on_index then
          -- ����� ������������� ��������
            update ubrr_data.ubrr_sencash_comm_trn
               set itrnnum_comm  = rvComm.itrnnum_comm,
                   itrnanum_comm = rvComm.itrnanum_comm,
                   itrcnum_comm  = rvComm.itrcnum_comm,
                   ierror_id     = rvComm.ierror_id
             where dtrndoc_comm    = rvComm.dtrndoc_comm
               and icard_objectuid = rvComm.icard_objectuid;
        end;*/
        END LOOP;
        -- Ubrr Pashevich A. 16.07.2013
  -->>-- 06.04.2018 ������ [17-895] ���: �������� �������� �� �������������� �� ���     
/*
        Update sbs
         Set csbspayfrom_cur = case when rvdocument.ctype<>'TRC' then 'TRC' else rvdocument.ctype end
          Where csbsacc = rvdocument.caccd;
*/          
  --<<-- 06.04.2018 ������ [17-895] ���: �������� �������� �� �������������� �� ���     
        -- Ubrr Pashevich A. 16.07.2013
--     End If;
        -- Ubrr Pashevich A. 16.07.2013
        -- �������� �� ������
        -- ��� ������������ �� �����������,
        -- ���������� ���� �������� �� �����

        -- xxi_context.set_idsmr (gccidsmrinitial);
        -- xxi.triggers.setuser (NULL);
        -- abr.triggers.setuser (NULL);
    EXCEPTION
        WHEN OTHERS
        THEN
        -- Ubrr Pashevich A. 16.07.2013
        -- �������� �� ������
        -- ��� ������������ �� �����������,
        -- ���������� ���� �������� �� �����
          --  xxi_context.set_idsmr (gccidsmrinitial);
          --  xxi.triggers.setuser (NULL);
          --  abr.triggers.setuser (NULL);
            crmes := ubrr_geterror ();
            ubrr_info.send_info_to_many (
                '�������� �� ��������������. ������.',
                crmes,
                'SENCASH_ERROR');
    END;
/*  --- Pashevich A. 03.06.2013
    ---�� ���������  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    setups ('UBRR_SENCASH|LAST_COMMS_RESULT', crmes);
    setups ('UBRR_SENCASH|LAST_COMMS_DATE',
            TO_CHAR (dccommdate, 'dd.mm.yyyy'));
    ubrr_info.send_info_to_many (
        '�������� �� ��������������',
        TO_CHAR (dccommdate, 'dd.mm.yyyy') || ':' || crmes,
        'SENCASH_SUCCESS');*/
END;



end;
/
