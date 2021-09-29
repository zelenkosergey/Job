CREATE OR REPLACE PACKAGE BODY UBRR_XXI5.ubrr_trc_auto is

/******************************* HISTORY UBRR *************************************\
   ����             �����        ID          ��������
----------   ---------------    ---------    ---------------------------------------
16.06.2016    ��������� �.�.    [15-1019]    https://redmine.lan.ubrr.ru/issues/30358
                                             ������� ��������� ������
21.11.2016    ��������� �.�.    [15-1019]    ��������� ������ - �� ���� ��� � ��� �����.
19.12.2016    ��������� �.�.    [16-2882]    ��������� ������ �� 37429/#10,#12
16.01.2017    ��������� �.�.    [16-2882]    ����� ������ ���������� � UBRR_TRC_AUTO_UTILS
01.02.2016    ��������� �.�.    [16-2882]    ��������� ������
11.04.2017    �������� �.�.     [oaiir-opt-100] ����������� trcmove
16.05.2017    �������� �.�.     [oaiir-opt-121] ����������� �������, ����������� � ��� �� ����������
04.08.2017    ubrr korolkov     #43987       [IM1305344-001] ���������
17.04.2018    ������� �.�.      17-1180      ���: ���������� ���������� �� �������������� ��������� ��������
07.05.2019    ������ �.�.       [19-59060.2] ���: ��������� ���������� ������ ���� (1�����)
09.01.2019    ������ �.�.       [19-64691]   �������������� ��������� ��������
10.03.2019    ������ �.�.       [19-64691]   �������������� ��������� ��������-����������� ������� ���������
18.11.2020    ������� �.�.      [20-82101.1]  ���: ��������� ������ ���� � 01.01.2021
23.12.2020    ������ �.�.       [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���RM � ������ �������� ��� �������� ���. ������ ����������� ��������
14.01.2020    ������ �.�.       [IM2545087-001] ��������� ������������������ ���������. ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���RM � ������ �������� ��� �������� ���. ������ ����������� ��������
14.01.2021    ������ �.�.       [IM2685764-001] ������� ���������� ���������
01.02.2021    ������� �.�.    [DKBPA-38]    ��� (2 ����) : ��������� ������ ���� � 01.01.2021
*/


--===================================================================
-- �������������� ��������� ���������� ��������
-- ���������� - "�������� ���������", � ������ - ������� � ��������.
-- ���� ��������� ��������� ����������� � ������, ������� �������� ����������
-- ������� ��������� �� ����� ����������.
--===================================================================

/*
��������� �� ������ ������������� ��������������� ������ � ������.

  ubrr_trc_report - ��������� �������, ������ ������ ��� �������,
  ������� ������������ ����� �� ����� ���������� ��������.
  ���� part ��������� � ����� ������ �������� ������ ��� ������ �������

part = 1 - ������ ��� ������ �� �������� �1->�2
part = 2 - ������ ��� ������ �� �������� �2->�1
part = 3 - ������ ��� ������ �� �������� � �2
part = 4 - ������ ��� ������ � �������� � ��������� 2 ���������� ���������
  �� ��������������, �������������� ������. -- ������ �� ������������!

part = 5 - ������ ��� ������, ����������� ��� ������� ������ "��������"
  (��� ��� �� ������� ������ ��� ������ ��������� �� �������,
   ��-�� ���� ��� ����� �������������� ������ � ������������,
   ���������� �������������� ��������� ��������� �������



part = 11 - �������� ������, ���������� �������� ��������
part = 12 - �� ������� ����������� ������������ ����
part = 13 - ������������ ����� > 0
part = 14 - ������ ����� �� ����� '�' ��� '�'
part = 15 - ����� ����� ��������� �� �1 � ������� ������������ ��� ��������� �� �2
part = 16 - ����� �������� �� ������������� ������ (���/�� = 333/2 ��� 333/3)
          ����������� � write_off_acc �� ����������, ����������� � part = 3
part = 17 - ��������
part = 18 - ������������ ��������

part = 991 - ���������� �� ������� ��� �������� �������� (� ��� ���������, � ��� ��������)

part = 1001 - ��������� �� �������� �������� - �� ����� ubrr_report_period_otd
*/

  g_dummy_s varchar2(4000);       -- ���������� - �������� ��� �����
  g_dummy_d date;                 -- ���������� - �������� ��� ���
--  g_err_msg_size number := 4000;  -- ������������ ������ ��������� �� ������

  c_line ubrr_data.ubrr_trc_report.line%type := 0; -- ����� ������
  g_need_mail number := 0;        -- ������� ����������� �������������� ��  e-mail

  -- ���������� ��� ������ � ���������� ��� e-mail
  g_email_msg_length_max     number := 2000;  -- ������������ ����� ���������
  g_email_msg_length_current number := 0;     -- ������� ����� ��������\
  g_email_msg varchar2(2000) := null;         -- ������� ���������


  -- �������� ������������� �������� ��������� ����������
  -- (���� false -  �� �����, �� ����, ���� �� ���������� �����, ������ ��������
  -- � ���, ��� ������ �����)
--  g_need_wait_lock_acrtable boolean := false;
--  g_need_wait_lock_acc boolean := false;

  g_need_wait_lock_acrtable boolean := false; --
  g_need_wait_lock_acc boolean := false; -- 30358/#405

-- ������� ���������� ��� email-��������������
procedure email_msg#clear
is
begin
  g_email_msg_length_current := 0;
  g_email_msg := null;
end;

-- ���������� ������ � email-���������
function email_msg#append(
  p_str varchar2
)
return boolean
is
  l_length number;
begin
  l_length := nvl(length(p_str),0);

  if g_email_msg_length_current + l_length < g_email_msg_length_max then
    g_email_msg_length_current := g_email_msg_length_current + l_length;
    g_email_msg := g_email_msg || p_str;
    return true;
  else
    return false;
  end if;
end;

-- �������� email  (������ � ABRR_MAIL)
procedure email_msg#send(
  p_subject varchar2,
  p_type number default 0
)
is
begin
  -- ��� ����� ��� ������� ���� 0 - "�������������� ����������� ���".
  -- ��� ��������� ���� 0 ������ ������������ �� ����� ������������.
  declare
    l_idsmr smr.idsmr%type := SYS_CONTEXT ('B21', 'IDSmr');
  begin
    if l_idsmr <> 16 and p_type = 0 then
      UBRR_VER4.ubrr_send.send_mail(
        ubrr_xxi5.ubrr_check_dpdoc.GetEmailByLogin(user),  p_subject, g_email_msg);
      return; -- ��� ��� ����� - �������, �������
    end if;
  end;

  -- ���� ����� ������ - ����� ������ �� ubrr_data.v_ubrr_email_writeoff
  for x in (
    select cmailaddr from ubrr_data.v_ubrr_email_writeoff where imailtype = p_type
  )
  loop
    UBRR_VER4.ubrr_send.send_mail(x.cmailaddr,  p_subject, g_email_msg);
  end loop;

/*
      ubrr_send.send_mail('E.Pulnikova@vuzbank.ru',  p_subject, g_email_msg);
      ubrr_send.send_mail('a.shinkareva@vuzbank.ru', p_subject, g_email_msg);
      ubrr_send.send_mail('nbulavkina@vuzbank.ru',   p_subject, g_email_msg);
      ubrr_send.send_mail('oMalkieva@vuzbank.ru',    p_subject, g_email_msg);
      ubrr_send.send_mail('lgladkih@vuzbank.ru',     p_subject, g_email_msg);
*/
end;

-- ��������� ������� � �������� �� email
procedure send_reestr_part(
  p_subject varchar2,
  p_title   varchar2,
  p_part    number
)
is
  e_set_error  exception;
  cursor cr_info is
    select value1, value2 from ubrr_data.ubrr_trc_report where part = p_part;
  ln_info cr_info%rowtype;
begin
  open cr_info; fetch cr_info into ln_info;

  -- ������ � ���� - ���� ����, ��� �������
  if cr_info%found then
    email_msg#clear;
    if not email_msg#append(p_title || chr(10)) then -- ������ �� ������ ����
      raise e_set_error;
    end if;

    while cr_info%found loop
      -- ���� ������ ������ �������� - ���������� ������ � �������� �����
      if not email_msg#append(ln_info.value1 || ' ' || ln_info.value2 || chr(10)) then
        email_msg#send(p_subject);
        email_msg#clear;
        if not email_msg#append(p_title || chr(10)) then
          raise e_set_error;
        end if;
        if not email_msg#append(ln_info.value1 || ' ' || ln_info.value2 || chr(10)) then
          raise e_set_error;
        end if;
      end if;
      fetch cr_info into ln_info;
    end loop;

    -- ���������� ��, ��� ��� �� ���������

    email_msg#send(p_subject);
    email_msg#clear;
  end if;

  close cr_info;
exception
  when e_set_error then
    if cr_info%isopen then close cr_info; end if;
    raise_application_error(-20000,'������ � ubrr_trc_auto.send_reest_part. p_part = '||p_part);
  when others then
    if cr_info%isopen then close cr_info; end if;
    raise_application_error(-20000,dbms_utility.format_error_stack
      || dbms_utility.format_error_backtrace);
end;


/*
         1         2         3         4         5         6         7         8
123456789012345678901234567890123456789012345678901234567890123456789012345678901234
��������  ���� ���-���      � ���-��        ���� ������           ����� �� ������
           12.12.2016        9174610  1234567890123456789012345  9999999999990.99
lpad(rn,8)||'   '||value1 ||'   '|| lpad(value2, 12) ||'  '||lpad(value3,25) || '  ' || lpad(value4, 16)

*/
procedure send_reestr_part16
is
  e_set_error  exception;
  cursor cr_info is
    select
      lpad(rownum,8)||'   '||value1 ||'   '|| lpad(value2, 12)
      ||'  '|| lpad(value3,25) || '  ' || lpad(value4, 16) info
    from
    (
      select value1, value2, value3, value4
      from ubrr_data.ubrr_trc_report where part = 16
      order by value1, value2, value3, value4
    )
    order by value1, value2, value3, value4
    ;
  ln_info cr_info%rowtype;

  cursor cr_info2 is
    select
      lpad(value5,5)||'    ���������� '||lpad(to_char(count(1)), 6) || '    ����� ' ||
      to_char(sum(to_number(value4,'FM9999999999990.99')),'9999999999990.99') info
    from ubrr_data.ubrr_trc_report
    where part = 16
    group by value5
    order by value5
    ;
  ln_info2 cr_info2%rowtype;

  l_title varchar2(256) := '��������  ���� ���-���      � ���-��        ���� ������           ����� �� ������';
  l_subject varchar2(256) := '�������� �� ���';
begin
  open cr_info; fetch cr_info into ln_info;

  -- ������ � ���� - ���� ����, ��� �������
  if cr_info%found then
    email_msg#clear;
    if not email_msg#append(l_title || chr(10)) then -- ������ �� ������ ����
      raise e_set_error;
    end if;

    while cr_info%found loop
      -- ���� ������ ������ �������� - ���������� ������ � �������� �����
      if not email_msg#append(ln_info.info || chr(10)) then
        email_msg#send(l_subject, 1);
        email_msg#clear;
        if not email_msg#append(l_title || chr(10)) then
          raise e_set_error;
        end if;
        if not email_msg#append(ln_info.info || chr(10)) then
          raise e_set_error;
        end if;
      end if;
      fetch cr_info into ln_info;
    end loop;

    -- ��������� ������ � �������.
    if not email_msg#append(chr(10)|| '� ��� ����� �� �������' || chr(10)) then
      email_msg#send(l_subject, 1);
      email_msg#clear;
      if not email_msg#append(chr(10)|| '� ��� ����� �� �������' || chr(10)) then
        raise e_set_error;
      end if;
    end if;

    open cr_info2; fetch cr_info2 into ln_info2;
    while cr_info2%found loop
      -- ���� ������ ������ �������� - ���������� ������ � �������� �����
      if not email_msg#append(ln_info2.info || chr(10)) then
        email_msg#send(l_subject, 1);
        email_msg#clear;
        -- ������������ ������ ��� �� ����������
        --
        if not email_msg#append(ln_info2.info || chr(10)) then
          raise e_set_error;
        end if;
      end if;
      fetch cr_info2 into ln_info2;
    end loop;

    -- ���������� ��, ��� ��� �� ���������
    email_msg#send(l_subject, 1);
    email_msg#clear;
  end if;

  if cr_info%isopen  then close cr_info;  end if;
  if cr_info2%isopen then close cr_info2; end if;

exception
  when e_set_error then
    if cr_info%isopen  then close cr_info;  end if;
    if cr_info2%isopen then close cr_info2; end if;
    raise_application_error(-20000,'������ � ubrr_trc_auto.send_reest_part16');
  when others then
    if cr_info%isopen  then close cr_info;  end if;
    if cr_info2%isopen then close cr_info2; end if;
    raise_application_error(-20000,dbms_utility.format_error_stack
      || dbms_utility.format_error_backtrace);
end;

-- ��������� �������� � �������� �� email
procedure send_reestr
is
  pragma autonomous_transaction;

  l_subject varchar2(50) := '�������������� ��������. ��� ������� �������.';
begin
  if g_need_mail = 1 then
    send_reestr_part(
      p_subject => l_subject,
      p_title  => '�� ��������� ������ ������� �������� ��������:',
      p_part   => 11
    );
    send_reestr_part(
      p_subject => l_subject,
      p_title  => '�� ��������� ������ ������� ������������ ����� � ����������� ������������:',
      p_part   => 12
    );
    send_reestr_part(
      p_subject => l_subject,
      p_title  => '�� ��������� ������ ������� ������������ ����� > 0 :',
      p_part   => 13
    );
    send_reestr_part(
      p_subject => l_subject,
      p_title  => 'C�������� ����� ����� ������ �������� �� "�" ��� "�":',
      p_part   => 14
    );
    send_reestr_part(
      p_subject => l_subject,
      p_title  => 'C�������� ����� ����� ��������� �� �1 � ������� ������������ ��� ��������� �� �2:',
      p_part   => 15
    );
    send_reestr_part16;

    send_reestr_part(
      p_subject => l_subject,
      p_title  => 'C�������� ������� �������� ����������. ��������� ������ ������ ����������.',
      p_part   => 17
    );

    send_reestr_part(
      p_subject => l_subject,
      p_title  => '�� ��������� ������ ������� ������������ ��������:',
      p_part   => 18
    );

  -- p_part

  end if;
  delete from  ubrr_data.ubrr_trc_report where part in (11, 12, 13, 14, 15, 16);
  commit;
end;

-->> 09.01.2019 ������ �.�. [19-64691] �������������� ��������� ��������
procedure add_changes_recv(op_itrcnum  in trc.ITRCNUM%TYPE,
                           op_itrcanum in trc.ITRCANUM%TYPE,
                           op_itrnnum  in trn.ITRNNUM%TYPE,
                           op_itrnanum in trn.ITRNANUM%TYPE) is
begin
  if ubrr_xxi5.ubrr_accmayak_createtrn.check_changes_recv(op_itrcnum, op_itrcanum) then
      insert into ubrr_data.ubrr_trn_changed_rec
      values  (op_itrnnum, op_itrnanum);
  end if;

  -->>01.02.2021    ������� �.�.    [DKBPA-38]    ��� (2 ����) : ��������� ������ ���� � 01.01.2021
  IF NVL(PREF.Get_Preference ('CARD2.WRITEOFF_EDIT'), '0') = '1'  THEN
    insert into ubrr_data.ubrr_trn_changed_rec(itrnnum,
                                               itrnanum
                                               )
                                       values (op_itrnnum,
                                               op_itrnanum
                                               );
  END IF;
  --<<01.02.2021    ������� �.�.    [DKBPA-38]    ��� (2 ����) : ��������� ������ ���� � 01.01.2021

exception when dup_val_on_index then null;
end;


function get_trc_status_str(op_itrnnum  in trn.ITRNNUM%TYPE,
                            op_itrnanum in trn.ITRNANUM%TYPE) return varchar2 is
 cv_ret varchar2(4);
 ivCount    number;
 ivChRec    number := 0;
begin

 select count(1)
    into ivChRec
    from ubrr_data.ubrr_trn_changed_rec
   where ITRNNUM  = op_itrnnum
     and ITRNANUM = op_itrnanum;

  select count(*)
    into ivCount
    from TRN_CARDHISTOR
   where ITRNNUM  = op_itrnnum
     and ITRNANUM = op_itrnanum;

  if ivCount = 0 then
    if ivChRec <> 0 then
       cv_ret:='��';
    end if;
  elsif ivChRec <> 0 then
     cv_ret:= '����';
  else
     cv_ret:= '��';
  end if;

  return cv_ret;

end;

--<< 09.01.2019 ������ �.�. [19-64691] �������������� ��������� ��������

-- ���������� ����������  �� ���� �������� ��� �������
procedure add_info2(
  p_part number,
  p_value1 ubrr_data.ubrr_trc_report.value1%type,
  p_value2 ubrr_data.ubrr_trc_report.value1%type
)
is
begin
  insert into ubrr_data.ubrr_trc_report(line, part, value1, value2)
    values (c_line, p_part, p_value1, p_value2);
  c_line := c_line + 1;
end;

procedure add_error_info(p_err varchar2,
                         op_otd acc.IACCOTD%type default null) -->><<-- 09.01.2019    ������ �.�.       [19-64691]   �������������� ��������� ��������
is
  pragma autonomous_transaction;
begin

  insert into ubrr_data.ubrr_trc_report(line, part, value1,
  value2) -->><<-- 09.01.2019    ������ �.�.       [19-64691]   �������������� ��������� ��������
  values(c_line, 991, replace(substr(p_err, 1, 1024), chr(10),' '),
  to_char(op_otd) ); -->><<-- 09.01.2019    ������ �.�.       [19-64691]   �������������� ��������� ��������
  commit;
  c_line := c_line + 1;
end;

-- ���������� ���������� ��� "������� � �����������" �� ��������� �������
-- ����� ��� ������, ������������ �� ������� ����� ��������� ����������
procedure add_move_info(
  p_part number,
  p_num number,
  p_anum number,
  cp_stat varchar2 default null -->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
)
is
begin
  insert into ubrr_data.ubrr_trc_report(line, part,
    value1, value2, value3, value4, value5, value6, value7,
    value8, value9, value10, value11, value12, value13, value14, value15,
    value18 -->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
    )
  (
    select
      c_line, p_part,
      iTrcType, -- ��1
      iTrcPriority,
      (
        select value_num
        from trc_attr_val
        where inum = iTrcNum
          and ianum = iTrcANum
          and id_attr = UBRR_XXI5.ubrr_ordered.ppo /*999000*/
      ) iAosPrior,
      to_char(dTrcCreate,'dd.mm.rrrr'),
      to_char(dTrcDoc,'dd.mm.rrrr'),
      iTRcDocNum,
      cTrcAccD,
      cTrcClient_Name,
      iAccOtd,
      trim(to_char(mTrcSum,'9999999999990.99')),
      cTrcAccA,
      cTrcOwnA,
      cTrcMfoA,
      cTrcBNameA,
      trim(to_char(mTrcLeft,'9999999999990.99')),
      cp_stat -->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
    from trc t
    join acc a on t.cTrcCur = a.cAccCur and t.cTrcAccD = a.cAccAcc and a.cAccPrizn <> '�'
    where iTrcNum = p_num and iTrcANum = p_anum
  );
  c_line := c_line + 1;
end;

-- ���������� ���������� ��� "������� � ��������" �� ��������� �������
-- ����� ��� ������, ������������ �� ������� ����� �������� ��������;
-- ����� ��� ���������� ����� ������������ ��� ���������� part = 16
procedure add_writeoff_info(
  p_num number,
  p_anum number,
  p_payment number,
  cp_stat varchar2 default null -->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
)
is
begin
--dbms_output.put_line('add_writeoff_info'|| p_num ||' '|| p_anum  ||' '||p_payment);
  insert into ubrr_data.ubrr_trc_report(line, part,
    value1, value2, value3, value4, value5, value6, value7,
    value8, value9, value10, value11, value12, value13, value14,
    value15, value16, value17,
    value18 -->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
    )
  (
    select
      c_line, 3,
      iTrcType, -- ��1
      ---> ��������� �� 06.10.2016. ��������� � ������ ��� �����!!!
      (
        select max(itrnsop)
        from trn
        where itrnnumanc = itrcnum and itrnanumanc = itrcanum and ctrnaccd = ctrcaccd  and rownum = 1
      ) BO2,
      ---< ��������� �� 06.10.2016. ��������� � ������ ��� �����!!!

      iTrcPriority,
      (
        select value_num
        from trc_attr_val
        where inum = iTrcNum
          and ianum = iTrcANum
          and id_attr = UBRR_XXI5.ubrr_ordered.ppo /*999000*/
      ) iAosPrior,
      to_char(dTrcCreate,'dd.mm.rrrr'),
      --to_char(dTrcDoc,'dd.mm.rrrr'),
      iTRcDocNum,
      trim(to_char(mTrcSum,'9999999999990.99')),
      cTrcAccD, -- value7
      cTrcClient_Name,
      iAccOtd,
      cTrcAccA,
      cTrcOwnA,
      cTrcMfoA,
      cTrcBNameA,
      to_char(sysdate,'dd.mm.rrrr') dWriteOff,
      trim(to_char(p_payment,'9999999999990.99')) part_pay,
      trim(to_char(mTrcLeft,'9999999999990.99')
      ),
      cp_stat -->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
    from trc t
    join acc a on t.cTrcCur = a.cAccCur and t.cTrcAccD = a.cAccAcc and a.cAccPrizn <> '�'
    where iTrcNum = p_num and iTrcANum = p_anum
  );
  c_line := c_line + 1;
--dbms_output.put_line('sql%rowcount = '||sql%rowcount);
end;


-- ���������� ��������� ������� ������� ��� ������ ��� ������� ������ "��������"
procedure add_writeoff_unload(
  p_marker_id number
)
is
begin
--dbms_output.put_line('add_writeoff_info'|| p_num ||' '|| p_anum  ||' '||p_payment);
  delete from ubrr_data.ubrr_trc_report where part = 5;

  insert into ubrr_data.ubrr_trc_report(line, part,
    value1, value2, value3, value4, value5, value6, value7,
    value8, value9, value10, value11)
  (
    select
      -1, 5,
      a.caccacc, a.caccname, to_char(u.icus) icus, to_char(a.iaccotd) iaccotd,
      trim(to_char(u.mrest,'9999999999990.99')) mrest,
      (
      select trim(to_char(sum(mTrcLeft),'9999999999990.99'))
      from trc t
      join trn on itrnanum = 0 and itrnnum =
        (
        select max(itrnnum) from trn
        where itrnnumanc = itrcnum and itrnanumanc = itrcanum and substr(ctrnaccd,1,5) = '90901'
        )
      where cTrcState = '1'
        -->> 04.08.2017 ubrr korolkov #43987
        and ctrcstatenc != '0' -- �����������������
        --<< 04.08.2017 ubrr korolkov #43987
        and a.iacccus = (select iacccus from acc where caccacc = ctrnaccd and cacccur = ctrncur)
        and t.ctrcaccd = a.caccacc and t.ctrccur = a.cacccur
      ) mTrcLeft1,

      (
      select trim(to_char(sum(mTrcLeft),'9999999999990.99'))
      from trc t
      where cTrcState = '2'
        -->> 04.08.2017 ubrr korolkov #43987
        and ctrcstatenc != '0' -- �����������������
        --<< 04.08.2017 ubrr korolkov #43987
        and cTrcAccD = a.caccacc
        and cTrcCur = a.cacccur
        and u.ikind <> 1
      ) mTrcLeft2,
      u.cdescription,
      (
      select trim(to_char(sum(mAosSumma),'9999999999990.99'))
      from acc_over_sum
      where cAosSumType = 'B'
        -- ��������� ����� - ������?
        and (upper(cAosComment) like '%���%�%��%' or upper(cAosComment) like '%���%N%��%')
        and cAosStat = '1'
        and cAosAcc = a.caccacc and cAosCur = a.cacccur
      ) aos_b,
      (
      select trim(to_char(abs(sum(mAosSumma)),'9999999999990.99'))
      from acc_over_sum
      where cAosSumType = 'O' and cAosStat = '1'
        --and iAosPrior is null -- !!!
        and cAosAcc = a.caccacc and cAosCur = a.cacccur
        and mAosSumma < 0
      ) aos_�,

      case when exists (
      select null
      from ach h
      where cachacc = a.caccacc and cachcur = a.cacccur and h.idsmr = a.idsmr
        and
            -- ������� ��������������� ���
          ( regexp_like (upper(cachbase),'(.*(��|��(�|�)|�\.).*\d{1,}.*|(^\d{1,}.*)(|((�|N).*\d{1,}))).*(��|JN)\s*\d{2}(,|\.|\/|\\)\d{2}(,|\.|\/|\\)\d.*')
            or regexp_like (upper(cachbase),'(�����(\.|\s)|�����������).*���')
            or upper(cachbase) like '%���%'
            or upper(cachbase) like '% ���%'
            or upper(cachbase) like '��� ��%'
            or upper(cachbase) like '%����%'
          )
        and not upper(cachbase) like '%���%' and not upper(cachbase) like '%CDR%'
        and not upper(cachbase) like '%���%'
        and not regexp_like (upper(cachbase),'\d{4}-\d{2}\/\d{6}')
        -- ��������� ������� ������ ���
        and not regexp_like (upper(cachbase),'(���.*(|(�|N)).*\d{1,}.*(��|JN))|((�|J)�����)')
      )
      then '�������' end   decision
    from ubrr_data.ubrr_trc_writeoff u
    join mrk m on u.rowid = m.rmrkrowid and m.imrkmarkerid = p_marker_id
    join acc a on u.cacc = a.caccacc and a.caccprizn <> '�'
  );
--  c_line := c_line + 1;
--dbms_output.put_line('sql%rowcount = '||sql%rowcount);
end;



-- ��������� ACCESS_2.Is_Account_Enabled
/*
function Is_Account_Enabled(
  account   in   ACC.CACCACC%type,
  currency  in   ACC.cacccur%type,
  accid     in   ACC_DST.access_id%type default 1
)
return number is
  ret     number:=0;
begin
  select count(1) into ret
  from dual
  where  exists(
    select 'x' from xxi."acc" a
    where caccacc=account
      and cacccur=currency
      and
        (
        exists
          (
          select 'x' from  acc_ubs2 -- ������������� ����� ������������
          where access_id = accid
            and plan_num = iaccplannum
            and ba2_num = iaccbs2
          )
        or exists
          (
          select 'x' from  xxi."acc_uacc"
          where access_id = accid
            and acc_num = caccacc
            and acc_cur = cacccur
          )
        )
    );
  return ret;
end;
*/
/*
procedure add_error(
  p_single in out nocopy varchar2,  -- ������ � ����� ���������� �� ������
  p_total  in out nocopy varchar2   -- ������ � ������������ ����������� �� �������
)
is
begin
  if p_single is not null then
    if p_total is not null then
      p_total := substr(p_total || chr(10), 1, g_err_msg_size);
    end if;
    p_total := substr(p_total || p_single, 1, g_err_msg_size);
  end if;
end;
*/


-- 1->2 ������� ��������� �� ��������� 2
procedure move_doc_to_card2(
  p_num  xxi."trc".iTrcNum%type,
  p_anum xxi."trc".iTrcANum%type,
  p_err out varchar2, -- ���������� �� ������ (��� null, ���� ��� ������)
  p_date_oper date,
  cp_stat in out varchar2-->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
)
is
--  l_current_date date := trunc(sysdate);

-- ������ ����������� �������� �� �������� ���� num, anum ���� mTrcLeft
-- �������� ����� ����� ������� ��������� ��������
  CURSOR cTRC IS
    select rowid, dTrcCreate, cTRCAccD, cTRCCur, iTRCDocNum, iTRCType, iTRCWriteOff, iTrcPriority,
      mTrcSum, mTrcRSum, mTrcLeft, mTrcLeft_Rub, cTRCAccC, cTrcACCA, cTrcClient_name, cTrcSumCur,
      DTRCDOC, ITrcNum, ITrcANum,
      cTrcOwnA, cTrcPurp, cTrcMfoA, cTrcMfoO
    from xxi."trc"
    where itrcNUM = p_num
      and itrcANUM = p_anum
    for update of mTrcLeft nowait;

  rTrc cTrc%rowtype;
  l_acc_status varchar2(256);

  iResult number;
  e_Set_Error  EXCEPTION;
  resource_busy exception;
  pragma exception_init (resource_busy,-54);

begin
  savepoint very_beginning;

  -- ���������������� ��� ������������ ���������� - ����� ���������
  open cTRC;
  fetch cTRC into rTRC;
  close cTRC;

  -- ��������� ������ �����
  l_acc_status := IDOC_UTIL.Check_Account (g_dummy_s, rTRC.cTRCAccD, rTRC.ctrcCUR, rTRC.iTrcPriority);
  IF UPPER (l_acc_status ) <> 'ACC_OPEN' THEN
  p_err := '���� '||rTRC.cTRCAccD||' �� �������� ��������.';
    raise e_Set_Error;
  END IF;

  --  ���������� trc.cstatenc ���� ����� ���������� ������� � �������

  declare
    l_cnt number;
  begin
    select count(1) into l_cnt
    from xxi.trc_stat
    where inum = p_num and ianum = p_anum and daction = p_date_oper and rownum = 1;

    if l_cnt = 0 then
      insert into xxi.trc_stat(inum, ianum, daction, cstatenc, cactdesc)
      values (p_num, p_anum, p_date_oper, 1,'�������������� �������');
    else
      update xxi.trc_stat set
        cstatenc = 1, cactdesc = '�������������� �������'
      where inum = p_num and ianum = p_anum and daction = p_date_oper;
    end if;
  exception when others then
    p_err := '���� '||rTRC.cTRCAccD||'. '|| dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || ' ';
    raise e_Set_Error;
  end;

  iResult := CARD.Accept (
     vcERROR_MSG   => p_err,
     iTRC_NUM      => p_num,
     iTRC_ANUM     => p_anum,
     dTODAY        => p_date_oper,
     mPARTLY_SUM   => rTrc.mTrcLeft,
     iWriteOff_Num => nvl(rTrc.iTrcWriteOff,0) +1, -- ��� ��� ����������� �����
     vcACTION      => '2FILE2' -- ��� �� �����
   ); -- 0 - �������, ��� ��� � p_err ����� ���������� ���������� ���� ��� ���������� ������

    -->> 09.01.2019 ������ �.�. [19-64691] �������������� ��������� ��������
    declare
      iTRN_NUM        TRN.itrnNUM%TYPE;
      vRegUser        xxi.usr.cusrlogname%type:= ubrr_auto_trc_job_pkg.get_auto_trc_user(ubrr_get_context);
    begin
      if iResult = 0 then

          iTRN_Num := MO.GetLastDocID;

          if xxi.triggers.getuser is not null and abr.triggers.getuser is not null then

            UPDATE xxi."trn"
                set cTrnIdAffirm = vRegUser, cTrnIdOpen = vRegUser
                where iTrnNum = iTRN_Num
                and iTrnANum = 0;

            cp_stat:=get_trc_status_str(iTRN_Num,0);

         end if;

         add_changes_recv(op_itrcnum=>p_num,
                 op_itrcanum=>p_anum,
                 op_itrnnum=>iTRN_Num,
                 op_itrnanum=>0);

      end if;
    end;
    --<< 09.01.2019 ������ �.�. [19-64691] �������������� ��������� ��������


  if iResult <> 0 then raise e_Set_Error; end if;
  if p_err is not null then p_err := null; end if; -- � ������ ������� ������ ���������

  -- ������ �� �������� �����������
  declare
    is_from_CD number :=-1;
    v_cardmsg  varchar2(250);
  begin
    -- � ������� ������������ ������ ��������� �� ���������� �� ����������� �� �������������..
    -- �� ������������� ����������?
    -- ���� �� ��������
    begin
      select nvl(i_event_type,-1) into is_from_cd
      from ubrr_dm_cd_card_link a
      where nl_trcnum  = p_num and nl_trcanum = p_anum;
    exception when no_data_found then
      is_from_cd := 0;
    end;

    --��������� ��������� ������� � ������� ���������� ��� ��������� 1
    -- TODO �����������, � ���� �� nbalance.get_last_num �������� ����� ?!
    if is_from_cd > 0  then
      update ubrr_dm_cd_card_link a  set
        msum_unpayed = greatest (msum_unpayed - rTrc.mTrcLeft, 0),
        c_writeoff_trnnums = to_char (nbalance.get_last_num ()) || '/0;' || c_writeoff_trnnums
      where nl_trcnum = p_num and nl_trcanum = p_anum;

      -- ��������� ��� ��������� ��������� - ������� � �������
      for r_WOff_msg in (
        select trc.itrcnum
        from
          ubrr_data.ubrr_dm_cd_card_link a,
          xxi."trc" trc,
          ubrr_data.ubrr_dm_VW_cd_card_link v -- �������� ��������� � ���������� ��������
        where a.nl_trcnum =trc.itrcnum
          and a.nl_trcanum=trc.itrcanum
          and trc.ITRCDOCNUM = v.itrcdocnum
          and v.nl_trcnum = p_num
          and v.nl_trcanum = p_anum
          and a.nl_trcnum <> p_num
        )
      loop
        v_cardmsg := '� ��������� ������ �������� � '||rTRC.iTRCDocNum||
          ' �� '||to_char(rTRC.dTrcCreate,'dd.mm.rrrr')||' �� ����� '||rTRC.cTrcAccD||
          '. �� ��������� ���������� ���������, ������������ � ���������� ��������� ������';
          ubrr_send.send_mail('OPOUL@UBRR.RU', '��������� ��������� ��� ������', v_cardmsg);
          exit;
        end loop;
      end if;
    exception when others then
      UBRR_XCARD.Set_Card_Process_Mark(0); -- ��� �� �������
      raise;
    end;
-- END ���-�� �� ������� ����������

  -- ��������� ����������� � ��������, ���� ��� �-�2
  if (rTRC.iTRCType = 25) and (rTRC.cTRCAccC like '111810%') then
    begin
      Ubrr_katpm_utils.SendMessage('CARD_RETIREMENT',
        '(' || to_char(sysdate,'DD.MM.YYYY') || ') ����������� �������� � ��������� 2 �� ����� ' || rTRC.ctrcaccd ||
        ': ' ||rTRC.ctrcclient_name || ' �� ����� '|| to_char(rTrc.mTrcLeft));
    exception
    when others then
      CARD.Set_TrcMessage (p_num, p_anum, '������ ��� ������ Ubrr_katpm_utils.SendMessage: '||sqlerrm);
    end;
  end if;

--    DBMS_SQL_ADD.Commit (); -- � ��� ��� � �� �������! - ��

  /*
  -- ���������� ���������� ���, �� ����������� �����������, �� ���� � �������.
  -- ��� ������������� �������� �������� "��������� ���������� ��������� ���"
  -- � ������� ��������� �� �������� � �������������� � �������.
    Begin
      select itrnnum, itrnanum into litrnnum, litrnanum
      from trn
      where itrnnum = (
        select max (itrnnum) from trn where itrnnumanc = p_num and itrnanumanc = p_anum
        )
        and itrnanum = 0;
      Do_Sign(litrnnum, litrnanum); -- ��������� �� document.fmb
    Exception
      When Others Then Null;
    End;
  */
exception
--    WHEN e_Write_Off THEN      DBMS_SQL_ADD.Rollback;
  WHEN e_Set_Error THEN
    rollback to very_beginning;
    CARD.Set_TrcMessage (p_num, p_anum, p_err);
    UBRR_CD_DEBUG_PKG.write_error('�������������� ��������','rTrcNumANum.Num = '||p_num||chr(10)||
      'rTrcNumANum.ANum' ||p_anum||chr(10)||
      'vcERROR_MSG = '||p_err);
    if p_err is null then p_err := ' ';   end if;
  WHEN resource_busy then
    rollback to very_beginning;
    p_err := '�������� ('||p_num||' '||p_anum||') �������������� ������ �������������. ���������� �������.' || p_err;
  WHEN OTHERS THEN
    rollback to very_beginning;
    UBRR_CD_DEBUG_PKG.write_error('�������������� ��������','rTrcNumANum.Num = '||p_num||chr(10)||
      'rTrcNumANum.ANum' ||p_anum||chr(10)||SQLERRM );
    p_err := SQLERRM;
end;


-- 2->1 ������� ��������� �� ��������� 1
procedure move_doc_to_card1(
  p_num  xxi."trc".iTrcNum%type,
  p_anum xxi."trc".iTrcANum%type,
  p_err out varchar2, -- ���������� �� ������ (��� null, ���� ��� ������)
  p_date_oper date,
  cp_stat in out varchar2 -->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
)
is
  l_result number;
begin


  -- ���������� ������ "�������� ��������������, �������� ���������"
  --  update xxi."trc" set cTrcStateNC = 2 where iTrcNum = p_num and iTrcANum = p_anum;

  --  ���������� trc.cstatenc ���� ����� ���������� ������� � �������
  declare
    l_cnt number;
  begin
    select count(1) into l_cnt
    from xxi.trc_stat
    where inum = p_num and ianum = p_anum and daction = p_date_oper and rownum = 1;

    if l_cnt = 0 then
      insert into xxi.trc_stat(inum, ianum, daction, cstatenc, cactdesc)
      values (p_num, p_anum, p_date_oper, 2,'�������������� �������');
    else
      update xxi.trc_stat set
        cstatenc = 2, cactdesc = '�������������� �������'
      where inum = p_num and ianum = p_anum and daction = p_date_oper;
    end if;
  exception when others then
    p_err := dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || ' ';
    return;
  end;

  l_result := CARD.MoveToCard1 (
    cError => p_err,
    iNum   => p_num,
    iANum  => p_anum,
    dMove  => p_date_oper --UTIL.Current_Date -- ��� �� �����
  );

    -->> 09.01.2019 ������ �.�. [19-64691] �������������� ��������� ��������
  declare
      iTRN_NUM        TRN.itrnNUM%TYPE;
      vRegUser        xxi.usr.cusrlogname%type:= ubrr_auto_trc_job_pkg.get_auto_trc_user(ubrr_get_context);
    begin
      if l_result = 0 then

         iTRN_Num := MO.GetLastDocID;

         if xxi.triggers.getuser is not null and abr.triggers.getuser is not null then

            UPDATE xxi."trn"
                set cTrnIdAffirm = vRegUser, cTrnIdOpen = vRegUser
                where iTrnNum = iTRN_Num
                and iTrnANum = 0;

            cp_stat:=get_trc_status_str(iTRN_Num,0);

         end if;

         add_changes_recv(op_itrcnum=>p_num,
                       op_itrcanum=>p_anum,
                       op_itrnnum=>iTRN_Num,
                       op_itrnanum=>0);

      end if;
    end;
    --<< 09.01.2019 ������ �.�. [19-64691] �������������� ��������� ��������


-- dbms_output.put_line('CARD.MoveToCard1('||p_num||','||p_anum||') l_result = '||l_result||'p_err='|| p_err);

  if l_result = 0 then
    if p_err is not null then p_err := null; end if;
  else
    if p_err is null then
      p_err := '�� ������� �����e��� �������� �� ��������� 1';
    end if;
  end if;

end;


-- 1->2 ������� ���� ���������� ����� � ��������� 1 �� ��������� 2
procedure move_acc_to_card2(
  p_acc  xxi."acc".cAccAcc%type,
  p_acc_cur xxi."acc".cAccCur%type,
  p_cus xxi."acc".iAccCus%type,
  p_err out varchar2, -- ���������� �� ������ (��� null, ���� ��� ������)
  p_date_oper date
)
is
/*
  cursor cr_trc is
    select iTrcNum, iTrcANum
    from xxi."trc" t
    where cTrcState = '1'
      and cTrcAccD = p_acc
      and cTrcCur = p_acc_cur;
*/


/*
����: ����� �� ������� ��� ������ ������  ��� ������ ��� �������� "�1->K2" ���� ������� ���������� �� ��������� 1.
�����: ��� ������ ������ ����������� ������� ���������� �� ��������� 1, ��������������� ��������������� �������.
  �������������� �������: ��� ��������� �� ��������� 1 ������������ ����� ������� ��� ����� ����������� ���������.
  ����� ��� ����� ��������� ���������� ����������� � ���� ��������, � ����� �������� �� ��, ��������������� �����
  90901%, ������ ��������� ��������. ��� ���� ��������, ��������� ��������� ����, ��� ����� - ����� �������.
  ���� ���� ����� ������� �� ����� ����� ���������� ������ ������� ��� ����� ����������� ���������,
  �� ������� ��������� �������������.
����� ������� ������ �����, � ������� �� ��������� 1 ������ ��������� ������ �������, ���������� � ������ �� ������.
*/
  cursor cr_trc is
    select iTrcNum, iTrcANum
    from trc t
    join trn on itrnanum = 0 and itrnnum =
      (
      select max(itrnnum) from trn
      where itrnnumanc = itrcnum and itrnanumanc = itrcanum and substr(ctrnaccd,1,5) = '90901'
      )
    where cTrcState = '1'
      -->> 04.08.2017 ubrr korolkov #43987
      and ctrcstatenc != '0' -- �����������������
      --<< 04.08.2017 ubrr korolkov #43987
      and cTrcAccD = p_acc
      and cTrcCur = p_acc_cur
      and p_cus = (select iacccus from acc where caccacc = ctrnaccd and cacccur = ctrncur)
  ;

  ln_trc cr_trc%rowtype;
  l_err varchar2(4000);
  cv_stat varchar2(4);-->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
begin
  open cr_trc; fetch cr_trc into ln_trc;
  while cr_trc%found loop
    move_doc_to_card2(ln_trc.iTrcNum, ln_trc.iTrcANum, l_err, p_date_oper,
                      cv_stat -->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
    );
    if l_err is null then
      add_move_info(1,ln_trc.iTrcNum, ln_trc.iTrcANum,
                    cv_stat-->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
                    );
    else
      l_err := '�������� ('||ln_trc.iTrcNum||','||ln_trc.iTrcANum||'). ' || l_err;
      p_err := l_err;
      exit;
    end if;

    fetch cr_trc into ln_trc;
  end loop;
  close cr_trc;
  -- ����� �������� �� ��������� 2 ���������� ������ ������� �������� ����������
  -- ����� ����� ����� ��������� �������� ���������� (�� ��� ������� ����)
  -- ���� - �������� ����� ��������� ������
exception when others then
  if cr_trc%isopen then close cr_trc; end if;

  if p_err is null then
    p_err := dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || ' ';
  end if;
end;


-- ��� �����, ��������� ��� ��������� � ��������� 2, �����  ��������� ��������, �� ��������� 1
procedure move_acc_to_card1(
  p_acc  xxi."acc".cAccAcc%type,
  p_acc_cur xxi."acc".cAccCur%type,
  p_err out varchar2, -- ���������� �� ������ (��� null, ���� ��� ������)
  p_date_oper date
)
is
  cursor cr_trc is
    select iTrcNum, iTrcANum
    from trc t
    join trc_attr_val on inum = iTrcNum and ianum = iTrcANum
      and id_attr = UBRR_XXI5.ubrr_ordered.ppo /*999000*/
      and value_num = 5 -- ������ 5-� �������

    where cTrcState = '2'
      -->> 04.08.2017 ubrr korolkov #43987
      and ctrcstatenc != '0' -- �����������������
      --<< 04.08.2017 ubrr korolkov #43987
      and cTrcAccD = p_acc
      and cTrcCur = p_acc_cur
--      and iTrcPriority = 5 -- ������ 5-� �������
      -- ��������� ������� �� �����������
      -- https://redmine.lan.ubrr.ru/issues/30358#note-207
      and substr(cTrcAccA,1,5) <> '40101'
      and not regexp_like(cTrcAccA,'^('||nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.CACCA_NAL'),'03100')||')')  --18.11.2020    ������� �.�.      [20-82101.1]  ���: ��������� ������ ���� � 01.01.2021
      ;
/*
        and (
          not regexp_like(cTrcMfoA, '^\d{6}00[012]')
          or
          not regexp_like(cTrcAccA, '^40(101|302|501\d{8}2|601\d{8}[13]|701\d{8}[13]|503\d{8}4|603\d{8}4|703\d{8}4)')
        )
*/


  ln_trc cr_trc%rowtype;
  l_err varchar2(4000);
  cv_stat varchar2(4);-->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
begin
--dbms_output.put_line('move_acc_to_card1');

  open cr_trc; fetch cr_trc into ln_trc;

  while cr_trc%found loop
    begin
      move_doc_to_card1(ln_trc.iTrcNum, ln_trc.iTrcANum, l_err, p_date_oper,
                        cv_stat-->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
                        );
      if l_err is null then
        add_move_info(2,ln_trc.iTrcNum, ln_trc.iTrcANum,
                      cv_stat-->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
        );
      else
        l_err := '�������� ('||ln_trc.iTrcNum||','||ln_trc.iTrcANum||'). ' || l_err;
        p_err := l_err;
        exit;
      end if;
    exception when others then
      if p_err is null then
        p_err := dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || ' ';
      end if;
    end;

    fetch cr_trc into ln_trc;
  end loop;

  close cr_trc;
exception when others then
  if cr_trc%isopen then close cr_trc; end if;

  if p_err is null then
    p_err := dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || ' ';
  end if;
end;

/*
procedure move_base_to_card(
  p_id_base in xxi."ni_bases".id_base%type,
  p_err out varchar2
)
is
  l_file_type xxi."ni_bases".file_type%type;

  cursor cr_acc is
    select a.caccacc, a.cacccur
    from xxi.ni_acc n
    join xxi."acc" a on n.caccount = a.caccacc and a.caccprizn <> '�'
    where id_base = p_id_base;

  ln_acc cr_acc%rowtype;

  l_err varchar2(4000);
begin
  -- savepoint very_beginning;

  begin
    select file_type into l_file_type from xxi."ni_bases" where id_base = p_id_base;
  exception when no_data_found then
    p_err := '� xxi."ni_bases" ����������� ������ � id_base = ' || p_id_base;
    return;
  end;
--dbms_output.put_line('l_file_type =' || l_file_type);

  if l_file_type = 'P' then -- ��������� ������� � ���������������
--dbms_output.put_line('l_file_type = P');

    open cr_acc; fetch cr_acc into ln_acc;
    begin
      while cr_acc%found loop -- ���� �� ���� ������ �����
        move_acc_to_card1(ln_acc.caccacc, ln_acc.cacccur, l_err);
        add_error(l_err, p_err);
        -- ���������, ��� ������ � ����������� �� �������
        fetch cr_acc into ln_acc;
      end loop;
      close cr_acc;
    exception when others then
      if cr_acc%isopen then close cr_acc; end if;
    end;

  elsif l_file_type = 'O' then -- ��������� ������� �� ������ ���������������
--dbms_output.put_line('l_file_type = O');
    open cr_acc; fetch cr_acc into ln_acc;
    begin
      while cr_acc%found loop -- ���� �� ���� ������ �����
        if get_acc_stopping_count(ln_acc.caccacc) = 0 then -- ���� �� �������� ���������� ��������������� � �����
          savepoint before_moving_to_card2;
          move_acc_to_card2(ln_acc.caccacc, ln_acc.cacccur, l_err); -- �� ��������� ��� ��������� ����� �� ��������� 1 � ��������� 2
          if l_err is not null then rollback to before_moving_to_card2; end if;
          add_error(l_err, p_err);

          -- ���� �� ����������� ������, ���������� ����� � "���������������" ����
          if p_err is null then acc_cache_add(0,ln_acc.caccacc); end if;
        end if;
        fetch cr_acc into ln_acc;
      end loop;
      close cr_acc;
    exception when others then
      if p_err is null then
        p_err := dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || ' ';
      end if;
      if cr_acc%isopen then close cr_acc; end if;
    end;
    -- ��������� �� ���������������� ���� � ��������
    declare
      l_state number; -- 1 - ����� ���������, 0 - �� �����, -1 - ������� �����
      l_acc xxi."acc".caccacc%type;
    begin
      -- ��������� �� ���������������� ���� � �������� (���� ������ ������� ���������������)
      loop
        acc_cache_get(0, l_acc, l_state);
        exit when l_state = -1;
        if l_state = 1 then
          if p_err is null then  acc_cache_add(1, l_acc); end if;
          acc_cache_del(0, l_acc);
        end if;
      end loop;
    end;

  else -- ��� ������
    p_err := '������. ������� ��������� �������� � �����, �� �������������� ������ ����������.';
    null;
  end if;
end;
*/
-- ������� ���������� ����� ����������� 1 � 2 ��� ������, ��������� �� �������
procedure move_selected_to_card(
  p_marker_id in number,
  p_date_oper date
)
is
  -->>-- 23.12.2020 ������ �.�. [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���. ������ ����������� ��������
  resource_busy exception;
  pragma exception_init (resource_busy,-54);
  --<<-- 23.12.2020 ������ �.�. [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���. ������ ����������� ��������

  cursor cr_acc is
    select a.caccacc, a.cacccur, u.icus, substr(u.cdirection, 1, 1) cdirection, m.rmrkrowid
    ,a.IACCOTD -->><<-- 09.01.2019    ������ �.�.       [19-64691]   �������������� ��������� ��������
    from ubrr_data.ubrr_trc_move u
    join mrk m on u.rowid = m.rmrkrowid and m.imrkmarkerid = p_marker_id
    join acc a on u.cacc = a.caccacc and a.caccprizn <> '�';

  ln_acc cr_acc%rowtype;

  l_err varchar2(4000);

  l_idsmr xxi."trn".idsmr%type := SYS_CONTEXT ('B21', 'IDSmr'); -->><<-- 14.01.2020 ������ �.�. [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���
begin
  g_need_mail := 1;


  -- ������� ������� ��� ������� ����������� ��������
  delete from ubrr_data.ubrr_trc_report;  c_line := 0;

  open cr_acc; fetch cr_acc into ln_acc;

  while cr_acc%found loop -- ���� �� ���� ������ �����
    -->>-- 23.12.2020 ������ �.�. [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���. ������ ����������� ��������
    if pref.Get_Universal_Preference('AUTO_TRC_STOP_PROCESS'|| '_' ||l_idsmr,'N') = 'Y' then -->><<-- 14.01.2020 ������ �.�. [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���
        raise resource_busy;
    end if;
    --<<-- 23.12.2020 ������ �.�. [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���. ������ ����������� ��������

    savepoint start_iteration;
    if ln_acc.cdirection = '2' then
      move_acc_to_card1(ln_acc.caccacc, ln_acc.cacccur, l_err, p_date_oper);
    elsif ln_acc.cdirection = '1' then
      move_acc_to_card2(ln_acc.caccacc, ln_acc.cacccur, ln_acc.icus, l_err, p_date_oper); -- �� ��������� ��� ��������� ����� �� ��������� 1 � ��������� 2
    else
      null;
    end if;
    if l_err is not null then
      l_err := '���� '||ln_acc.caccacc||'. '|| l_err;
      add_error_info(l_err
      ,ln_acc.IACCOTD ); -->><<-- 09.01.2019    ������ �.�.       [19-64691]   �������������� ��������� ��������
      rollback to start_iteration;  -- �� ����� - ���� ��� ��������� ��������� ������������ ���� �������� ����� ������
    else
      -- ������ �� ��������� ������� �����, ������� ��������� ������������
      util.MRK_Delete(ln_acc.rmrkrowid, p_marker_id);
      delete from ubrr_data.ubrr_trc_move where cacc = ln_acc.caccacc;
    end if;

    fetch cr_acc into ln_acc;
  end loop;
  close cr_acc;


exception when others then
  add_error_info(dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || ' '
                 ,ln_acc.IACCOTD ); -->><<-- 09.01.2019    ������ �.�.       [19-64691]   �������������� ��������� ��������
  if cr_acc%isopen then close cr_acc; end if;
  -->>-- 23.12.2020 ������ �.�. [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���. ������ ����������� ��������
  if SQLCODE = -54 then
        raise resource_busy;
  end if;
  --<<-- 23.12.2020 ������ �.�. [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���. ������ ����������� ��������
end;



/*
����� ������ ����������� ������� � ��������� �������.
������ ����������� �������� �������, ��� �������� ����������� ��������.
*/
function get_acc_rest(
  p_acc xxi."acc".caccacc%type,
  p_cur xxi."acc".cacccur%type,
  p_date date
)
return number is
  l_stype varchar2(32);
  l_sum number;
  l_unconfirmed_income number;
begin
  l_sum := ACC_INFO.GetDarkRest(p_acc, p_cur, l_stype, p_date);  -- �������� ������� �� ����� p_date

  select nvl(sum(mtrnsum),0) into l_unconfirmed_income
  from trn
  where dtrntran is null and ctrnaccc = p_acc and ctrncur = p_cur;

  return l_sum - l_unconfirmed_income;

--  return ACC_INFO.GetDarkRest(p_acc, p_cur, l_stype, sysdate);  -- �������� ������� �� ����� p_date
end;

-- ��� �� "����������" ������ ������ ����������� ���������, ����� ����� ���� ������� ��������
-- 1-� ���������  2TRN
FUNCTION write_off_doc1(
  p_num  xxi."trc".iTrcNum%type,
  p_anum xxi."trc".iTrcANum%type,
  p_err out varchar2, -- ���������� �� ������ (��� null, ���� ��� ������)
  p_date_oper date,
  p_sum number, -- ���������� � �������� �����
  cp_stat in out varchar2-->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
)
RETURN NUMBER
IS
    --<<UBRR 26.08.2013 ��������� �.�. ����������� ������ ���������
    vcERROR_MSG     varchar2(4000);

    vcACC_STATUS   VARCHAR2 (256);

--    mAccountPP     TRC.mtrcSUM%TYPE;
--    mSUM           TRC.mtrcSUM%TYPE; -- ����� �������
    mREAL_SUM      TRC.mtrcSUM%TYPE;
    nWriteOff_Num  INTEGER;
    mRES_SUM       TRC.mtrcSUM%TYPE := 0;
    ACCEPT_FLAG     number :=0;

    CURSOR cTRC IS
      SELECT
        RowID, dTrcCreate, cTRCAccD, cTRCCur, iTRCDocNum, iTRCType, iTRCWriteOff,
        --iTrcPriority,
        (
        select value_num
        from trc_attr_val
        where inum = iTrcNum
          and ianum = iTrcANum
          and id_attr = UBRR_XXI5.ubrr_ordered.ppo /*999000*/
        ) iTrcPriority,

        mTrcSum, mTrcRSum, mTrcLeft, mTrcLeft_Rub, cTRCAccC, cTrcACCA, cTrcClient_name, cTrcSumCur,
        DTRCDOC, ITrcNum, ITrcANum, -- UBRR ����������� �. �. 10.01.2014 12-2288 ��������� ����������� �������� �������� �������, �� 855 �� (���� ����������� �� ������ � �����������������)
        cTrcOwnA, cTrcPurp, cTrcMfoA, cTrcMfoO,
        CTRCCORACCA,  --18.11.2020  ������� �.�.    [20-82101.1]  ���: ��������� ������ ���� � 01.01.2021
        TRC.CTRCBNAMEA  --01.02.2021  ������� �.�.    [DKBPA-38]    ��� (2 ����) : ��������� ������ ���� � 01.01.2021
      FROM TRC
      WHERE itrcNUM = p_num AND itrcANUM = p_anum
      FOR UPDATE OF mTrcLeft NOWAIT -->><<UBRR 26.08.2013 ��������� �.�. ������� NOWAIT. ����������� ������ ���������
                  ;

    rTrc             cTrc%ROWTYPE;
    iResult          INTEGER;
    vcDummy          VARCHAR2 (250);
    nCur_Rate        NUMBER;

    e_RecAccIsClosed  EXCEPTION;     -->><<-- 07.05.2019  ������ �.�.  [19-59060.2] ���: ��������� ���������� ������ ���� (1�����)
    e_Write_Off      EXCEPTION;
    e_Accept         EXCEPTION;
    eUser            EXCEPTION;
--

    is_from_CD number :=-1;
    v_cardmsg  varchar2(250);

  e_Set_Error  EXCEPTION;
  resource_busy exception; -->><< UBRR 26.08.2013 ��������� �.�. ����������� ������ ���������
  pragma exception_init (resource_busy,-54);

  l_result_kind number;
  l_sum number;
  l_dummy varchar2(4000);

  function get_doc_info return varchar2 is
  begin
    return ' �' || rTrc.iTrcDocNum || ' �� ' || to_char (rTrc.dTrcCreate,'dd.mm.rrrr')||' ';
  end;
BEGIN

  savepoint very_beginning;

  --  ���������� trc.cstatenc ���� ����� ���������� ������� � �������
  declare
    l_cnt number;
  begin
    select count(1) into l_cnt
    from xxi.trc_stat
    where inum = p_num and ianum = p_anum and daction = p_date_oper and rownum = 1;

    if l_cnt = 0 then
      insert into xxi.trc_stat(inum, ianum, daction, cstatenc, cactdesc)
      values (p_num, p_anum, p_date_oper, 1,'�������������� ��������');
    else
      update xxi.trc_stat set
        cstatenc = 1, cactdesc = '�������������� ��������'
      where inum = p_num and ianum = p_anum and daction = p_date_oper;
    end if;
  exception when others then
    p_err := '���� '||rTRC.cTRCAccD||'. '|| dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || ' ';
    raise e_Set_Error;
  end;



  OPEN cTRC;
  FETCH cTRC INTO rTRC;
  CLOSE cTRC;

  ACCEPT_FLAG :=0;--<<��������� �.�. 2010.06.11 ��������� ��������� ������� � ������� ���������� ��� ��������� 1

  mReal_Sum     := rTRC.mTrcLeft;
  nWriteOff_Num := NVL (rTrc.iTrcWriteOff, 0) + 1;
  l_sum := p_sum;

--  IF vcAction = 'ACCEPT' THEN -- TRUE

--  cPlaceDoc := '2TRN';

  vcACC_STATUS := IDOC_UTIL.Check_Account (vcDUMMY, rTRC.cTRCAccD, rTRC.ctrcCUR, rTRC.iTrcPriority);
  IF UPPER (vcACC_STATUS ) NOT in ('ACC_OPEN', 'ACC_PARTLY_BLOCKED') THEN
    p_err := '���� '||rTRC.cTRCAccD||' �� �������� �������� ���� �������� �������������.';
    RAISE e_Write_Off; -- �� ������� - ������ �� ����������� ��������
  END IF;

  -->> 07.05.2019 ������ �.�. [19-59060.2] ���: ��������� ���������� ������ ���� (1�����)
  declare
    l_acc ubrr_data.ubrr_sud_ft_accounts.account_new%type :=
       get_sud_ft_account(p_Mfoa=>rTrc.cTrcMfoA, p_cTrcAccA=>rTrc.cTrcAccA);
  begin
    if l_acc is not null then
      p_err := '���� '||rTRC.cTRCAccD||' �������� � '|| rTrc.Itrcdocnum ||' �� '|| to_char(rTrc.Dtrcdoc, 'dd.mm.yyyy') ||'. '||
      '���� ���������� '|| rTrc.cTrcAccA ||' ������. ' ||
       case when is_acc(l_acc) then '����� ���� ' || l_acc else l_acc end ;
      RAISE e_Write_Off;
    end if;
  end;
  --<< 07.05.2019 ������ �.�. [19-59060.2] ���: ��������� ���������� ������ ���� (1�����)

  -->>18.11.2020  ������� �.�.    [20-82101.1]  ���: ��������� ������ ���� � 01.01.2021
  IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_auto_trc( par_itrcnum       => rTrc.Itrcnum,
                                                              par_itrcanum      => rTrc.Itrcanum,
                                                              par_itrctype      => rTrc.Itrctype,
                                                              par_ctrcaccd      => rTrc.Ctrcaccd,
                                                              par_ctrcmfoa      => rTrc.cTrcMfoA,
                                                              par_ctrccoracca   => rTrc.Ctrccoracca,
                                                              par_ctrcacca      => rTrc.cTrcAccA,
                                                              par_purp          => rTrc.cTrcPurp,
                                                              par_Bnamea        => rTrc.Ctrcbnamea,  --01.02.2021  ������� �.�.    [DKBPA-38]    ��� (2 ����) : ��������� ������ ���� � 01.01.2021
                                                              p_err             => p_err) THEN

    RAISE e_Write_Off;
  END IF;
  --<<18.11.2020  ������� �.�.    [20-82101.1]  ���: ��������� ������ ���� � 01.01.2021

  IF CARD.Check_Pres_On_Card (rTrc.cTrcAccD, rTRC.cTrcCur, vcDummy) THEN
    p_err := vcDummy;
    RAISE e_Write_Off; -- �� ������� - ���������, ��� ���� �������� �� �2 � ����������� ����������
  END IF;

--  mAccountPP := ACC_INFO.GetAccountPP (rTRC.cTRCAccD, rTRC.cTRCCur, dRegister, rTrc.iTrcPriority);

  IF rTrc.cTrcCur != rTrc.cTrcSumCur THEN
    nCur_Rate := RATES.Cross_Rate (rTrc.cTrcCur, rTrc.cTrcSumCur, p_date_oper);
    IF nCur_Rate <= 0 THEN
      p_err := RATES.No_Rate_Msg (rTrc.cTrcCur || '->' || rTrc.cTrcSumCur, p_date_oper);
      RAISE e_Set_Error;
    END IF;

    l_sum := CEIL (l_sum * nCur_Rate * 100) / 100; -- ��������� ����� ��� ���� ������
  END IF;

  mReal_Sum := least(l_sum,mReal_Sum);

  PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 0); -- � ������ ������ �� �����!

                  -->> ubrr korolkov https://redmine.lan.ubrr.ru/issues/3383
  IF rTRC.iTRCType > 0 AND rTRC.iTRCType NOT IN (20, 24) THEN
    /*
    :GLOBAL.Sum_Trn      := NLSFIX.TO_CHAR (mReal_Sum);
    :GLOBAL.WriteOff_Num := nWriteOff_Num;
    UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF', '������ �������������� ��������� ');
    IF Edit (TRUE, rTrcNumANum.Num, rTrcNumANum.ANum, mReal_Sum, rTrc.mTrcLeft, dRegister, rTrc.mTrcSum)
    THEN
      mReal_Sum     := CARD_EDIT.GetFieldByName ('MTRCSUM');
      nWriteOff_Num := CARD_EDIT.GetFieldByName ('ITRCWRITEOFF');
      bCall_Dlg     := FALSE;
      PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', '1');
    ELSE
      UBRR_CD_DEBUG_PKG.write_error('FORM.DOCUMENT.WRITEOFF', '������ ��� �������������� ��������� ');
      RAISE e_Write_Off;
    END IF;
    */
-->>> UBRR  ��������� �.�. 25.03.2016   15-1641.2  ���: 148-�. �������� ���������� ��������� �����.
  -- �������� ��������� �����
    ubrr_xxi5.UBRR_CHECK_TAXDETAILS.check_trc(
      p_form_kind    => 0,   -- ������ ���������,  0 - ������� ��� ������ ������������
      p_itrcnum      => p_num,
      p_itrcanum     => p_anum,
      p_result       => p_err, -- ���������
      p_result_kind  => l_result_kind -- 0 - ok, 1 - warning, 2 - error
    );
    if l_result_kind <> 0 then
     p_err := '�� �������� �������� ��������� �����.';
      RAISE e_Write_Off;
    end if;

--<<< UBRR  ��������� �.�. 25.03.2016   15-1641.2  ���: 148-�. �������� ���������� ��������� �����.

  END IF;
----------------------------------------------------------------------
--
  -->>01.02.2021  ������� �.�.    [DKBPA-38]    ��� (2 ����) : ��������� ������ ���� � 01.01.2021
  IF  ubrr_xxi5.ubrr_change_accounts_tofk.upd_tofk_accounts_auto_trc(par_trc_num  => p_num,
                                                                     par_trc_anum => p_anum) THEN
    PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 1);
  ELSE
    PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 0);
  END IF;
  --<<01.02.2021  ������� �.�.    [DKBPA-38]    ��� (2 ����) : ��������� ������ ���� � 01.01.2021

  iResult := CARD.Accept (l_dummy, p_num, p_anum, p_date_oper, mReal_Sum, nWriteOff_Num, '2TRN');
  if iResult<>0 then
--->>> V.Arslanov 09.08.2016
--    p_err := '������ � CARD.Accept : '||l_dummy;
    p_err := '������ : '||l_dummy;
---<<< V.Arslanov 09.08.2016
    RAISE e_Accept;
  end if;

    -->> 09.01.2019 ������ �.�. [19-64691] �������������� ��������� ��������
    declare
      iTRN_NUM        TRN.itrnNUM%TYPE;
      vRegUser        xxi.usr.cusrlogname%type:= ubrr_auto_trc_job_pkg.get_auto_trc_user(ubrr_get_context);
    begin
      if iResult = 0 then

         iTRN_Num := nvl(IDOC_REG.GetLastDocID, MO.GetLastDocID );

         if xxi.triggers.getuser is not null and abr.triggers.getuser is not null then

            UPDATE xxi."trn"
                set cTrnIdAffirm = vRegUser, cTrnIdOpen = vRegUser
                where iTrnNum = iTRN_Num;

            cp_stat:=get_trc_status_str(iTRN_Num,0);

         end if;

         add_changes_recv(op_itrcnum=>p_num,
                       op_itrcanum=>p_anum,
                       op_itrnnum=>iTRN_Num,
                       op_itrnanum=>0);

      end if;
    end;
    --<< 09.01.2019 ������ �.�. [19-64691] �������������� ��������� ��������


  if iResult=0 then ACCEPT_FLAG:=1; end if; --<<��������� �.�. 2010.06.11 ��������� ��������� ������� � ������� ���������� ��� ��������� 1

--dbms_output.put_line('l_dummy = ' ||l_dummy);
--  IF ACCEPT_FLAG=1 OR :PARAMETER.State = '2' THEN
  declare
    is_doca_loan  number:=0;
    --<<<ubrr ����� �.�. 16.04.2009 � 5041-05/006757 �� 15.04.2009 ������������ �������� �������� ������� �� ������ �������� � ��������
  begin
    begin
      SELECT nvl(I_EVENT_TYPE,-1) into is_from_CD
      FROM ubrr_dm_cd_card_link a
      WHERE nl_trcnum = p_num
        and nl_trcanum = p_anum;
    exception when no_data_found then
      is_from_CD := 0;
    end;

    IF is_doca_loan > 0 THEN
      UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF',
        'iResult := CARD.WriteOff ('||chr(10)||
        vcERROR_MSG||'=>vcERROR_MSG, '||chr(10)||
        p_num||'=>p_num, '||chr(10)||
        p_anum||'=>p_anum, '||chr(10)||
        p_date_oper||'=>p_date_oper, '||chr(10)||
        mREAL_SUM||'=>mREAL_SUM, '||chr(10)||
        nWriteOff_Num||'=>nWriteOff_Num, '||chr(10)||
        'vcACTION=>ACCEPT '||chr(10)||
        ');'
        );
      CARD_EDIT.setFieldByName('CTRCCORACCO', '');

      -->>01.02.2021  ������� �.�.    [DKBPA-38]    ��� (2 ����) : ��������� ������ ���� � 01.01.2021
      IF  ubrr_xxi5.ubrr_change_accounts_tofk.upd_tofk_accounts_auto_trc(par_trc_num  => p_num,
                                                                         par_trc_anum => p_anum) THEN
        PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 1);
      ELSE
        PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 0);
      END IF;
      --<<01.02.2021  ������� �.�.    [DKBPA-38]    ��� (2 ����) : ��������� ������ ���� � 01.01.2021

      iResult := CARD.WriteOff (vcERROR_MSG, p_num, p_anum, p_date_oper, mREAL_SUM, nWriteOff_Num, 'ACCEPT');
--dbms_output.put_line('vcERROR_MSG='||vcERROR_MSG);
      UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF','iResult='||iResult);
    end if; -- is_doca_loan > 0

    --��������� ��������� ������� � ������� ���������� ��� ��������� 1
    if iResult = 0 and is_from_cd > 0 and ACCEPT_FLAG=1  then --1212
      UPDATE ubrr_dm_cd_card_link a SET
        msum_unpayed = greatest (msum_unpayed - mreal_sum, 0),
        c_writeoff_trnnums = to_char (nbalance.get_last_num ()) || '/0;' || c_writeoff_trnnums
      WHERE nl_trcnum = p_num AND nl_trcanum = p_anum;
                  -- ��������� ��� ��������� ���������
      for r_WOff_msg in (
        select trc.itrcnum
        from ubrr_data.ubrr_dm_cd_card_link a, xxi."trc" trc, ubrr_data.ubrr_dm_VW_cd_card_link v
        where a.nl_trcnum =trc.itrcnum
          and a.nl_trcanum=trc.itrcanum
          and trc.ITRCDOCNUM = v.itrcdocnum
          and v.nl_trcnum = p_num
          and v.nl_trcanum = p_anum
          and a.nl_trcnum <> p_num )
      loop
        v_cardmsg := '� ��������� ������ �������� � '||rTRC.iTRCDocNum||
          ' �� '||to_char(rTRC.dTrcCreate,'dd.mm.rrrr')||' �� ����� '||rTRC.cTrcAccD||
          '. �� ��������� ���������� ���������, ������������ � ���������� ��������� ������';
        ubrr_send.send_mail('OPOUL@UBRR.RU', '��������� ��������� ��� ������', v_cardmsg);
        exit;
      end loop;
                  --<< 22.03.2013 ubrr korolkov https://redmine.lan.ubrr.ru/issues/6334
    elsif iResult <> 0 then
      raise eUser;
    end if;  --if  iResult = 0 then 1212
                --<<<ubrr ����� �.�. 16.04.2009 � 5041-05/006757 �� 15.04.2009 ������������ �������� �������� ������� �� ������ �������� � ��������
  exception when others then
    UBRR_XCARD.Set_Card_Process_Mark(0);-->>><<<ubrr ����� �.�. 16.04.2009 � 5041-05/006757 �� 15.04.2009 ������������ �������� �������� ������� �� ������ �������� � ��������
    raise;
  end;

/*
  IF iResult = 0 THEN
    IF mReal_Sum = rTRC.mTRCLeft THEN
    UTIL.MRK_Delete (rTrc.RowID, :LOCAL.MarkerID);
                   -->>>ubrr katyuhin  20071024
                   -- ��������� ����������� � ��������, ���� ��� �-�2
      if (rTRC.iTRCType = 25) and (rTRC.cTRCAccC like '111810%') then
        begin
          Ubrr_katpm_utils.SendMessage('CARD_RETIREMENT',
                                                   '(' || to_char(dREGISTER,'DD.MM.YYYY') || ') ����������� �������� � ��������� 2 �� ����� ' || rTRC.ctrcaccd ||
                                                   ': ' ||rTRC.ctrcclient_name || ' �� ����� '|| to_char(mREAL_SUM));
        exception
          when others then
            CARD.Set_TrcMessage (rTrcNumANum.Num, rTrcNumANum.ANum, '������ ��� ������ Ubrr_katpm_utils.SendMessage: '||sqlerrm);
        end;
      end if;
    ELSE
      CARD.Set_TrcMessage (rTrcNumANum.Num, rTrcNumANum.ANum, vcERROR_MSG);
    END IF;
  ELSE
    RAISE e_Set_Error;
  END IF;
*/

  mRES_SUM := mRES_SUM + mREAL_SUM;
--  DBMS_SQL_ADD.Commit ();


  RETURN mRES_SUM;


EXCEPTION
  -->>-- 14.05.2019 ������ �.�. [19-59060.2] ���: ��������� ���������� ������ ���� (1�����)
  WHEN e_RecAccIsClosed THEN
    rollback to very_beginning;
    if p_err is null then p_err := ' e_RecAccIsClosed ';   end if;
    return -1;
  -->>-- 14.05.2019 ������ �.�. [19-59060.2] ���: ��������� ���������� ������ ���� (1�����)
  WHEN e_Write_Off THEN
    rollback to very_beginning;
    if p_err is null then p_err := ' e_Write_Off ';   end if;
    p_err := '��������' || get_doc_info ||'. '|| p_err;
    return -1;
  WHEN e_Set_Error THEN
    rollback to very_beginning;
    CARD.Set_TrcMessage (p_num, p_anum, p_err);
    UBRR_CD_DEBUG_PKG.write_error('FORM.DOCUMENT.WRITEOFF','p_num = '||p_num||chr(10)||
      'p_anum' ||p_anum||chr(10)||
      'p_err = '||p_err);
    p_err := '��������' || get_doc_info ||'. '|| p_err;
    return -2;
  WHEN resource_busy then
    rollback to very_beginning;
    p_err := '�������� '||get_doc_info||' �������������� ������ �������������. ���������� �������.';
    return -3;
  WHEN eUser THEN
    rollback to very_beginning;
    UBRR_CD_DEBUG_PKG.write_error('FORM.DOCUMENT.WRITEOFF','p_num = '||p_num||chr(10)||
      'p_anum' ||p_anum||chr(10)|| p_err);
-->>> V. Arslanov 09.08.2016
--    p_err := p_err ||' ������ ��� ���������� CARD.WriteOff.';
--<<< V. Arslanov 09.08.2016
-- ���� ��������� �� ������ ���� ������ - ����� ��� ��������
--      if p_err is null then p_err := ' '; end if;
      p_err := '��������' || get_doc_info ||'. '|| p_err;
   return -4;
  when e_Accept then
    rollback to very_beginning;
    if p_err is null then p_err := ' e_Accept ';   end if;
    p_err := '��������' || get_doc_info ||'. '|| p_err;
    return -5;

  WHEN OTHERS THEN
    rollback to very_beginning;
    UBRR_CD_DEBUG_PKG.write_error('FORM.DOCUMENT.WRITEOFF','p_num = '||p_num||chr(10)||
      'p_anum' ||p_anum||chr(10)||SQLERRM );
    p_err := SQLERRM;
    p_err := '��������' || get_doc_info ||'. '|| p_err;
    return -999;

END write_off_doc1;


-- ������� �� ������ ������� WriteOff �� ����� document.fmb
-- ��� �� "����������" ������ ������ ����������� ���������, ����� ����� ���� ������� ��������
FUNCTION write_off_doc2(
  p_num  xxi."trc".iTrcNum%type,
  p_anum xxi."trc".iTrcANum%type,
  p_err out varchar2, -- ���������� �� ������ (��� null, ���� ��� ������)
  p_date_oper date,
  p_sum number, -- ���������� � �������� �����
  cp_stat in out varchar2-->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
)
RETURN NUMBER
IS
--  l_current_date date := trunc(sysdate);

  vcACC_STATUS   VARCHAR2 (256);

  mSUM           TRC.mtrcSUM%TYPE;
  mREAL_SUM      TRC.mtrcSUM%TYPE;
  nWriteOff_Num  INTEGER;
  mRES_SUM       TRC.mtrcSUM%TYPE := 0;

  CURSOR cTRC IS
    SELECT RowID, dTrcCreate, cTRCAccD, cTRCCur, iTRCDocNum, iTRCType, iTRCWriteOff,
    --iTrcPriority,
      (
        select value_num
        from trc_attr_val
        where inum = iTrcNum
          and ianum = iTrcANum
          and id_attr = UBRR_XXI5.ubrr_ordered.ppo /*999000*/
      ) iTrcPriority,

      mTrcSum, mTrcRSum, mTrcLeft, mTrcLeft_Rub, cTRCAccC, cTrcACCA, cTrcClient_name, cTrcSumCur,
      DTRCDOC, ITrcNum, ITrcANum,
      cTrcOwnA, cTrcPurp, cTrcMfoA, cTrcMfoO, itrcsop,  -- 17.04.2018 ������� �.�. 17-1180 ���: ���������� ���������� �� �������������� ��������� ��������
      CTRCCORACCA,  --18.11.2020  ������� �.�.    [20-82101.1]  ���: ��������� ������ ���� � 01.01.2021
      CTRCBNAMEA  --01.02.2021  ������� �.�.    [DKBPA-38]    ��� (2 ����) : ��������� ������ ���� � 01.01.2021
    FROM TRC
    WHERE itrcNUM = p_num
      AND itrcANUM = p_anum
    ORDER BY dtrccreate,iTrcPriority -- 17.04.2018 ������� �.�. 17-1180 ���: ���������� ���������� �� �������������� ��������� ��������
    FOR UPDATE OF mTrcLeft NOWAIT
    ;

  rTrc             cTrc%ROWTYPE;
--  bCall_Dlg        BOOLEAN;
  iResult          INTEGER;

--  mPref_P_Spis     NUMBER := 0;

  vcDummy          VARCHAR2 (250);
  nCur_Rate        NUMBER;

  e_RecAccIsClosed  EXCEPTION;     -->><<-- 07.05.2019    ������ �.�.       [19-59060.2] ���: ��������� ���������� ������ ���� (1�����)
  e_Write_Off      EXCEPTION;
  eUser             EXCEPTION;


  is_from_CD number :=-1;
  cgacacc TRC.ctrcacca%TYPE:='???';
  to_idsmr smr.idsmr%type;
  v_cardmsg  varchar2(250);
  e_Set_Error  EXCEPTION;

  resource_busy exception; -->><< UBRR 26.08.2013 ��������� �.�. ����������� ������ ���������
  pragma exception_init (resource_busy,-54);

  l_result_kind number;

  bPriorChng Boolean:=False;
  vCreatStatus  VARCHAR2(2):=Null;
  iBackTrcPriority Number;

  function get_doc_info return varchar2 is
  begin
    return ' �' || rTrc.iTrcDocNum || ' �� ' || to_char (rTrc.dTrcCreate,'dd.mm.rrrr')||' ';
  end;

BEGIN

  -- ��� ������������� ������ ��� �������� ���������� ��������� ��������� �����
  -- ��� ��������� � ���������� ��������� �� ������ �����������
  savepoint very_beginning;


  OPEN cTRC;
  FETCH cTRC INTO rTRC;
  CLOSE cTRC;

  mReal_Sum     := rTRC.mTrcLeft;
  nWriteOff_Num := nvl(rTrc.iTrcWriteOff, 0) + 1;

  --�������� ���������� �� ����� 40821, �������� �������� �� ������������ 103-��, 161-��
  p_err := ubrr_zaa_abs_util.Check_40821(
    p_Date        => rTrc.dTrcCreate,
    p_OpType     => rTrc.iTrcType,
    p_PayerAcc  => rTrc.cTrcAccD,
    p_RecipAcc  => rTrc.cTrcAccA,
    p_PayerName => rTrc.cTrcClient_name,
    p_RecipName => rTrc.cTrcOwnA,
    p_PayerBik  => rTrc.cTrcMfoO,
    p_RecipBik  => rTrc.cTrcMfoA,
    p_Purp      => rTrc.cTrcPurp);
  if p_err is not null then
    raise e_Set_Error;
  end if;

  -- �� ����, �������� ����� �� ������ ��� �����, � �� ��� ����������, ������� ��� ��� �������
  vcACC_STATUS := IDOC_UTIL.Check_Account (vcDUMMY, rTRC.cTRCAccD, rTRC.ctrcCUR, rTRC.iTrcPriority);
  IF UPPER (vcACC_STATUS ) NOT in ('ACC_OPEN', 'ACC_PARTLY_BLOCKED') THEN
    p_err := '���� '||rTRC.cTRCAccD||' �� �������� �������� ���� �������� �������������.';
    RAISE e_Write_Off; -- �� ������� - ������ �� ����������� ��������
  END IF;

  -->> 07.05.2019 ������ �.�. [19-59060.2] ���: ��������� ���������� ������ ���� (1�����)
  declare
    l_acc ubrr_data.ubrr_sud_ft_accounts.account_new%type :=
       get_sud_ft_account(p_Mfoa=>rTrc.cTrcMfoA, p_cTrcAccA=>rTrc.cTrcAccA);
  begin
    if l_acc is not null then
      p_err := '���� '||rTRC.cTRCAccD||' �������� � '|| rTrc.Itrcdocnum ||' �� '|| to_char(rTrc.Dtrcdoc, 'dd.mm.yyyy') ||'. '||
      '���� ���������� '|| rTrc.cTrcAccA ||' ������. ' ||
       case when is_acc(l_acc) then '����� ���� ' || l_acc else l_acc end ;
    RAISE e_RecAccIsClosed;
    end if;

  end;
  --<< 07.05.2019 ������ �.�. [19-59060.2] ���: ��������� ���������� ������ ���� (1�����)

  -->>18.11.2020  ������� �.�.    [20-82101.1]  ���: ��������� ������ ���� � 01.01.2021
  IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_auto_trc( par_itrcnum       => rTrc.Itrcnum,
                                                              par_itrcanum      => rTrc.Itrcanum,
                                                              par_itrctype      => rTrc.Itrctype,
                                                              par_ctrcaccd      => rTrc.Ctrcaccd,
                                                              par_ctrcmfoa      => rTrc.cTrcMfoA,
                                                              par_ctrccoracca   => rTrc.Ctrccoracca,
                                                              par_ctrcacca      => rTrc.cTrcAccA,
                                                              par_purp          => rTrc.cTrcPurp,
                                                              par_Bnamea        => rTrc.Ctrcbnamea,  --01.02.2021  ������� �.�.    [DKBPA-38]    ��� (2 ����) : ��������� ������ ���� � 01.01.2021
                                                              p_err             => p_err) THEN

    RAISE e_Write_Off;
  END IF;
  --<<18.11.2020  ������� �.�.    [20-82101.1]  ���: ��������� ������ ���� � 01.01.2021

    -->> 17.04.2018    ������� �.�.      17-1180      ���: ���������� ���������� �� �������������� ��������� ��������
  --=================================================================
  -- �������� ���������� ��� �������� ��������.
  -- ���� ��1 23 ��� 26 � ��2 ����� � �������������� ����������� = 4
  -- �� ���������� � �������
  -- *UPD 21.08.2020 UBRR Lazarev*
  -- ���� ��1 23 ��� 26 � ��2 ����� ��� 11 � �������������� ����������� = 4
  --=================================================================
  -->> 21.09.2020 UBRR Lazarev [20-74096] https://redmine.lan.ubrr.ru/issues/74096
  --IF rTRC.itrctype IN (23,26) AND rTRC.itrcsop IS NULL AND rTRC.iTrcPriority IN (1,2,3,4)
    IF rTRC.itrctype IN (23,26) AND (rTRC.itrcsop = 12 or rTRC.itrcsop is null) AND rTRC.iTrcPriority IN (1,2,3,4)
  --<< 21.09.2020 UBRR Lazarev [20-74096] https://redmine.lan.ubrr.ru/issues/74096
    THEN
      p_err := '�������� ('||rTRC.itrcnum||','||rTRC.itrcanum||').���������� ��������� �� �������� ��������.';
      RAISE e_Set_Error;
  END IF;
  --<< 17.04.2018    ������� �.�.      17-1180      ���: ���������� ���������� �� �������������� ��������� ��������
  if NVL(PREF.Get_Preference ('CARD2.RED_BALANCE'), '1') = '1' then -- �������� �� ������� ������
    bPriorChng:=False;
    vCreatStatus:=Null;
    Begin
      Select cCreatStatus
      Into vCreatStatus
      From TRC_DEPT_INFO
      Where INUM=rTRC.ITrcNum And IANUM=rTRC.ITrcANum;
    Exception
      When No_Data_Found Then
        Null;
    End;
    If rTRC.DTRCDOC>=to_date('14.12.2013', 'dd.mm.rrrr') And rTrc.iTrcPriority=5
      And vCreatStatus Is Not Null And (substr(rTrc.CTRCACCA, 1, 3) In ('401', '402', '403', '404')
                                         or regexp_like(rTrc.CTRCACCA,'^('||nvl(PREF.Get_Preference('UBRR_CHECK_PAY_BUDGET.CTRNACCA_NEW'),'03100|03212|03222|03232|03242|03252|03262|03272|03221|03231')||')') --18.11.2020  ������� �.�.    [20-82101.1]  ���: ��������� ������ ���� � 01.01.2021
                                         )
    Then
      iBackTrcPriority:=rTrc.iTrcPriority;
      rTrc.iTrcPriority:=4; -- ���������� ����, ��� ��� ������ �������� ��� ���������� � 3 ��� 4 ������������.
      bPriorChng:=True;
    End If;

     -- 22.07.2016 - ������� ��������� ������
     -- mSum := ACC_INFO.GetAccountPP (rTRC.cTRCAccD, rTRC.ctrcCUR, p_date_oper, rTrc.iTrcPriority) /* - mPref_P_Spis*/;
     mSum := p_sum; -- 22.07.2016 - ������ �����, ���������� � ��������, �������� �����

     If bPriorChng Then
       rTrc.iTrcPriority:=iBackTrcPriority; -- ���������� �������
     End If;

--->>> V.Arslanov 09.08.2016
/*     IF mSum <= 0 THEN
--->>> V.Arslanov 09.08.2016
--       p_err := '�� �������� �������� �� ������� ������.';
       p_err := '����� ���������� ��������� ������� �� �����.';
---<<< V.Arslanov 09.08.2016
       RAISE e_Write_Off;
     END IF;
*/
---<<< V.Arslanov 09.08.2016

     IF rTrc.cTrcCur != rTrc.cTrcSumCur THEN
       nCur_Rate := RATES.Cross_Rate (rTrc.cTrcCur, rTrc.cTrcSumCur, p_date_oper);
       IF nCur_Rate <= 0 THEN
         p_err := RATES.No_Rate_Msg (rTrc.cTrcCur || '->' || rTrc.cTrcSumCur, p_date_oper);
         RAISE e_Set_Error;
       END IF;

       mSum := CEIL (mSum * nCur_Rate * 100) / 100; -- ��������� ����� ��� ���� ������
     END IF;

   ELSE -- ��� �������� �� ������� ������
     --     mSum := rTrc.mTrcLeft;
     -- ���� ���� ���������� �������� �������!
     mSum := p_sum;
   END IF;

  mReal_Sum := LEAST (rTrc.mTrcLeft, mSum);

  -- �������� ��������� �����
  ubrr_xxi5.UBRR_CHECK_TAXDETAILS.check_trc(
    p_form_kind    => 0,   -- ������ ���������,  0 - ������� ��� ������ ������������
    p_itrcnum      => p_num,
    p_itrcanum     => p_anum,
    p_result       => p_err, -- ���������
    p_result_kind  => l_result_kind -- 0 - ok, 1 - warning, 2 - error
  );
  if l_result_kind <> 0 then
--dbms_output.put_line( p_err);
   p_err := '�� �������� �������� ��������� �����.';

    RAISE e_Write_Off;
  end if;

  declare
    cAcc varchar2(20);
--    cWRITE_OFF_EDIT varchar2(1);
    -->>>ubrr ����� �.�. 16.04.2009 � 5041-05/006757 �� 15.04.2009 ������������ �������� �������� ������� �� ������ �������� � ��������
    i_Yes_zbl_acc number:=0;
    is_doca_loan  number:=0;
    --<<<ubrr ����� �.�. 16.04.2009 � 5041-05/006757 �� 15.04.2009 ������������ �������� �������� ������� �� ������ �������� � ��������
  begin
   /* cWRITE_OFF_EDIT := NVL (PREF.Get_Preference ('CARD2.WRITEOFF_EDIT'), '0');
    IF rTRC.iTRCType < 1 THEN
      cWRITE_OFF_EDIT := '0'; -- ��������� ��������� �� �������������
    END IF;
    IF cWRITE_OFF_EDIT = '1' THEN
      cAcc := CARD_EDIT.getFieldByName ('CTRCACCA');
    else
      cAcc := rTRC.ctrcACCA;
    end if;
*/ --- adf �� ����
    PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 0); --adf

    i_Yes_zbl_acc:=ubrr_abrr_btn.Yes_zbl_acc(cAcc);
    is_doca_loan:=-999;
    ubrr_dm_cd2trn.Set_Tansit_Acc(null);--���������� ���� �� ���������
          --������ �� �������� � ��������� �� �������� ���� �� ������ idsmr
    is_doca_loan:=UBRR_DJKO_CD_FILE2.Get_Event_Type(p_num, p_anum);

    begin
      SELECT nvl(I_EVENT_TYPE,-1)
        into is_from_CD
      FROM ubrr_dm_cd_card_link a
      WHERE nl_trcnum =p_num
        and nl_trcanum=p_anum;
    exception when no_data_found then
      is_from_CD := 0;
    end;

    IF is_doca_loan > 0 THEN
      if (i_Yes_zbl_acc = 1 or is_from_CD > 0) then
      --������������ ���������� ��� �������� ������  ��������� �� ��������
        if is_from_CD > 0 and i_Yes_zbl_acc <> 1   then
        --�������� �� ��������, �� ���� ���������� �� ������������
        -- ���������� ������������ ����������� ����
          UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF','���������� ������������ ����������� ����');
          begin
            select distinct NVL(cgacacc, '???'), gac.idsmr
              into cgacacc, to_idsmr
            from xxi.gac gac
            where gac.cgaccur = 'RUR'
              and gac.igaccat = 3
              and gac.igacnum = 104;
          exception when OTHERS then
            cgacacc := '???';
          end;
          if cgacacc = '???' then
            p_err := '������������ ����������� ���� �� �����������.';
            UBRR_CD_DEBUG_PKG.write_error('FORM.DOCUMENT.WRITEOFF', p_err);
            raise eUser;
          else
            UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF','������������ ����������� ���� CGACACC = '||cgacacc);
          end if;
          CARD_EDIT.setFieldByName('CTRCACCA', cgacacc);
          CARD_EDIT.setFieldByName('ITRCTYPE', '11');
        end if;

        if is_from_CD > 0 then --������� � ���, ��� �������� ������ �� ��������
          UBRR_XCARD.Set_Card_Process_Mark(is_from_CD);
        else
          UBRR_XCARD.Set_Card_Process_Mark(null);
        end if;
            --<<<ubrr ����� �.�. 16.04.2009 � 5041-05/006757 �� 15.04.2009 ������������ �������� �������� ������� �� ������ �������� � ��������
        SAVEPOINT sp_WriteOff;
        -- ������������ ���������� ��������� ��� �������
        UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF',' iResult := UBRR_XCARD.Create_zbl ('||chr(10)||
          p_err||'=> p_err,'||chr(10)||
          p_num||'=> p_num,'||chr(10)||
          p_anum||'=> p_anum,'||chr(10)||
          p_date_oper ||'=> p_date_oper ,'||chr(10)||
          mREAL_SUM||'=> mREAL_SUM,'||chr(10)||
          to_idsmr||'=> to_idsmr'||chr(10)||')');

        iResult := UBRR_XCARD.Create_zbl (p_err, p_num, p_anum, p_date_oper, mREAL_SUM, 'WRITEOFF', to_idsmr);
        UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF', 'iResult = '||iResult);

        if iResult = 0 then
          null;
          --commit;
        else
          p_err := '�������� ��������� ��� �������: '||p_err;
          raise eUser;
        end if;
        iResult := UBRR_XCARD.Spisan_zbl(p_err, p_num, p_anum, p_date_oper , mREAL_SUM, nWriteOff_Num, 'WRITEOFF');
        UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF','iResult='||iResult);
        if iResult <> 0 then
          p_err := '������������ �������������� ���������: '||p_err;
          -- 27.08.2013 ��������� �.�. ����� ����� ������� �� ��� ��������� ��� ������ ����� Ubrr_btn � UBRR_XCARD.Create_zbl
          -- ���� �������� ������ raise
          raise eUser;
        end if;
      ELSE  -- ������� ��� : ������������ ���������� ��� �������� ������  ��������� �� ��������
            --UBRR_DBG_WRITE_CARD_INFO ; -- ��� �� �����, �������� �����
        declare
          info varchar2(2000);
        begin
          For r in (select * from ALL_TAB_COLUMNS where table_name = 'TRC' and owner = 'XXI')
          loop
            begin
              info := info || chr(10) || (r.COLUMN_NAME ||' = '||CARD_EDIT.GetFieldByName (r.COLUMN_NAME));
            exception when others then null;
            end;
          end loop;
          UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF', info);
        exception when others then null;
        end;

        UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF',
          'iResult := CARD.WriteOff ('||chr(10)||
          p_err||'=>p_err, '||chr(10)||
          p_num||'=>p_num, '||chr(10)||
          p_anum||'=>p_anum, '||chr(10)||
          p_date_oper ||'=>l_current_date, '||chr(10)||
          mREAL_SUM||'=>mREAL_SUM, '||chr(10)||
          nWriteOff_Num||'=>nWriteOff_Num, '||chr(10)||');'
        );
        CARD_EDIT.setFieldByName('CTRCCORACCO', '');
        ---

        -->>01.02.2021  ������� �.�.    [DKBPA-38]    ��� (2 ����) : ��������� ������ ���� � 01.01.2021
        IF  ubrr_xxi5.ubrr_change_accounts_tofk.upd_tofk_accounts_auto_trc(par_trc_num  => p_num,
                                                                           par_trc_anum => p_anum) THEN
          PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 1);
        ELSE
          PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 0);
        END IF;
        --<<01.02.2021  ������� �.�.    [DKBPA-38]    ��� (2 ����) : ��������� ������ ���� � 01.01.2021

        iResult := CARD.WriteOff (p_err, p_num, p_anum, p_date_oper , mREAL_SUM, nWriteOff_Num, 'WRITEOFF');
        UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF','iResult='||iResult);
      END IF;
    else
      declare
        info varchar2(2000):='';
      begin
        INFo := 'p_num = '||p_num
          || 'p_anum = '||p_anum
          || 'mREAL_SUM = '||mREAL_SUM
          || 'nWriteOff_Num = '||nWriteOff_Num
          || chr(10);
        ubrr_cd_debug_pkg.Write_info('FORM.DOCUMENT.WRITEOFF', info);
      exception when others then null;
      end;
      --UBRR_DBG_WRITE_CARD_INFO ; -- ��� �� �����, �������� �����
      declare
        info varchar2(2000);
      begin
        For r in (select * from ALL_TAB_COLUMNS where table_name = 'TRC' and owner = 'XXI')
        loop
          begin
            info := info || chr(10) || (r.COLUMN_NAME ||' = '||CARD_EDIT.GetFieldByName (r.COLUMN_NAME));
          exception when others then null;
          end;
        end loop;
        UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF', info);
      exception when others then null;
      end;

      CARD_EDIT.SetFieldByName ('CTRCCORACCO', '');
      UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF',
        'iResult := CARD.WriteOff ('||chr(10)||
          p_err||'=>p_err, '||chr(10)||
          p_num||'=>p_num, '||chr(10)||
          p_anum||'=>_anum, '||chr(10)||
          p_date_oper ||'=>l_current_date, '||chr(10)||
          mREAL_SUM||'=>mREAL_SUM, '||chr(10)||
          nWriteOff_Num||'=>nWriteOff_Num, '||chr(10)||');'
      );
-- �� - ������ ����� ��� ��������� � ��� �� �����������;

        -->>01.02.2021  ������� �.�.    [DKBPA-38]    ��� (2 ����) : ��������� ������ ���� � 01.01.2021
        if  ubrr_xxi5.ubrr_change_accounts_tofk.upd_tofk_accounts_auto_trc(par_trc_num  => p_num,
                                                                           par_trc_anum => p_anum) THEN
          PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 1);
        ELSE
          PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 0);
        END IF;
        --<<01.02.2021  ������� �.�.    [DKBPA-38]    ��� (2 ����) : ��������� ������ ���� � 01.01.2021

        iResult := CARD.WriteOff (p_err, p_num, p_anum, p_date_oper , mREAL_SUM, nWriteOff_Num, 'WRITEOFF');

        UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF','iResult='||iResult);
    end if; -- is_doca_loan > 0

    -->> 09.01.2019 ������ �.�. [19-64691] �������������� ��������� ��������
    declare
      iTRN_NUM        TRN.itrnNUM%TYPE;
      vRegUser        xxi.usr.cusrlogname%type:= ubrr_auto_trc_job_pkg.get_auto_trc_user(ubrr_get_context);
    begin
      if iResult = 0 then

        iTRN_Num := nvl(IDOC_REG.GetLastDocID, MO.GetLastDocID );

        if  xxi.triggers.getuser is not null and abr.triggers.getuser is not null then

            UPDATE xxi."trn"
                set cTrnIdAffirm = vRegUser, cTrnIdOpen = vRegUser
                where iTrnNum = iTRN_Num;


            cp_stat:=get_trc_status_str(iTRN_Num,0);

        end if;

        add_changes_recv(op_itrcnum=>p_num,
                       op_itrcanum=>p_anum,
                       op_itrnnum=>iTRN_Num,
                       op_itrnanum=>0);

      end if;
    end;
    --<< 09.01.2019 ������ �.�. [19-64691] �������������� ��������� ��������

    --��������� ��������� ������� � ������� ���������� ��� ��������� 1
    if iResult = 0 and is_from_cd > 0 then --1212
      UPDATE ubrr_dm_cd_card_link a SET
        msum_unpayed = greatest (msum_unpayed - mreal_sum, 0),
        c_writeoff_trnnums = to_char (nbalance.get_last_num ()) || '/0;' || c_writeoff_trnnums
      WHERE nl_trcnum = p_num AND nl_trcanum = p_anum;
                    -- ��������� ��� ��������� ���������
      for r_WOff_msg in (
        select trc.itrcnum
        from ubrr_data.ubrr_dm_cd_card_link a, xxi."trc" trc, ubrr_data.ubrr_dm_VW_cd_card_link v
        where a.nl_trcnum =trc.itrcnum
          and a.nl_trcanum=trc.itrcanum
          and trc.ITRCDOCNUM = v.itrcdocnum
          and v.nl_trcnum = p_num
          and v.nl_trcanum = p_anum
          and a.nl_trcnum <> p_num
      )
      loop
        v_cardmsg := '� ��������� ������ �������� � '||p_num||
          ' �� '||to_char(rTRC.dTrcCreate,'dd.mm.rrrr')||' �� ����� '||rTRC.cTrcAccD||
          '. �� ��������� ���������� ���������, ������������ � ���������� ��������� ������';
          ubrr_send.send_mail('OPOUL@UBRR.RU', '��������� ��������� ��� ������', v_cardmsg);
        exit;
      end loop;
    elsif iResult <> 0 then
      raise eUser;
    end if;
  exception when others then
    UBRR_XCARD.Set_Card_Process_Mark(0);
    raise;
  end;

  IF iResult = 0 THEN
    IF mReal_Sum = rTRC.mTRCLeft THEN
      -- ��������� ����������� � ��������, ���� ��� �-�2
      if (rTRC.iTRCType = 25) and (rTRC.cTRCAccC like '111810%') then
        begin
          Ubrr_katpm_utils.SendMessage('CARD_RETIREMENT',
            '(' || to_char(p_date_oper ,'DD.MM.YYYY') || ') ����������� �������� � ��������� 2 �� ����� ' || rTRC.ctrcaccd ||
            ': ' ||rTRC.ctrcclient_name || ' �� ����� '|| to_char(mREAL_SUM));
        exception
        when others then
          CARD.Set_TrcMessage (p_num, p_anum, '������ ��� ������ Ubrr_katpm_utils.SendMessage: '||sqlerrm);
        end;
      end if;
    ELSE
      CARD.Set_TrcMessage (p_num, p_anum, p_err);
    END IF;
  ELSE
    RAISE e_Set_Error;
  END IF;

  mRES_SUM := mRES_SUM + mREAL_SUM;
--  DBMS_SQL_ADD.Commit ();



  p_err := null;
  RETURN mRES_SUM;


EXCEPTION
  -->>-- 14.05.2019 ������ �.�. [19-59060.2] ���: ��������� ���������� ������ ���� (1�����)
  WHEN e_RecAccIsClosed THEN
    rollback to very_beginning;
    if p_err is null then p_err := ' e_RecAccIsClosed ';   end if;
    return -1;
  -->>-- 14.05.2019 ������ �.�. [19-59060.2] ���: ��������� ���������� ������ ���� (1�����)
  WHEN e_Write_Off THEN
    rollback to very_beginning;
    if p_err is null then p_err := ' e_Write_Off ';   end if;
    p_err := '��������' || get_doc_info ||'. '|| p_err;
    return -1;
  WHEN e_Set_Error THEN
    rollback to very_beginning;
    CARD.Set_TrcMessage (p_num, p_anum, p_err);
    UBRR_CD_DEBUG_PKG.write_error('FORM.DOCUMENT.WRITEOFF','p_num = '||p_num||chr(10)||
      'p_anum' ||p_anum||chr(10)||
      'p_err = '||p_err);
    p_err := '��������' || get_doc_info ||'. '|| p_err;
    return -2;
  WHEN resource_busy then
    rollback to very_beginning;
    p_err := '��������'|| get_doc_info ||' �������������� ������ �������������. ���������� �������.';
    return -3;
  WHEN eUser THEN
    rollback to very_beginning;
    UBRR_CD_DEBUG_PKG.write_error('FORM.DOCUMENT.WRITEOFF','p_num = '||p_num||chr(10)||
      'p_anum' ||p_anum||chr(10)|| p_err);
--->>> V.Arslanov 09.08.2016
--    p_err := p_err ||' ������ ��� ���������� CARD.WriteOff.';
---<<< V.Arslanov 09.08.2016
    if p_err is null then p_err := ' '; end if;
    p_err := '��������' || get_doc_info ||'. '|| p_err;
    return -4;
  WHEN OTHERS THEN
    rollback to very_beginning;
    UBRR_CD_DEBUG_PKG.write_error('FORM.DOCUMENT.WRITEOFF','p_num = '||p_num||chr(10)||
      'p_anum' ||p_anum||chr(10)||SQLERRM );
    p_err := SQLERRM;
    p_err := '��������' || get_doc_info ||'. '|| p_err;
    return -5;
end;

/* �������� �������, �� ����������� ������ �������� */
procedure write_off_acc_check(
  p_acc  xxi."acc".cAccAcc%type,
  p_acc_cur  xxi."acc".cAccCur%type,
  p_cus xxi."acc".iAccCus%type,
  p_date_oper date,
  --p_kind number,      -- 1 - ���� ��������� �� �1, 2-�2, 3- �1 � �2
  p_err out varchar2  -- ���������� �� ������ (��� null, ���� ��� ������)
)
is
  l_cnt number;

begin
  p_err := null;

-- 1. �������� ������� �� ����� �� ��������.
-- �� ���������� ��� ���������� ubrr_data.ubrr_trc_writeoff � ����� �����������
-- ��� ���������� ���������� � ��������� �����.

-- 2. ������� ���������� � �������� ���������� �� ��������.
-- ��� ����������� ��� ���������� ubrr_data.ubrr_trc_writeoff

-- 3. ������� ��������� (������������ ?) ��������
  -->> 10.03.2019    ������ �.�.       [19-64691]   �������������� ��������� ��������-����������� ������� ���������
  select count(1) into l_cnt
  from dual
  where
  exists
  (
  select null from trn
  where ctrnstate1 <> '4'
    and ctrnaccd = p_acc and ctrncur = p_acc_cur
    and DTRNTRAN>=p_date_oper-7
  );
  /*
  select count(1) into l_cnt
  from trn
  where ctrnstate1 <> '4'
    and ctrnaccd = p_acc and ctrncur = p_acc_cur
    and rownum = 1;
  */
  --<< 10.03.2019    ������ �.�.       [19-64691]   �������������� ��������� ��������-����������� ������� ���������

  if l_cnt > 0 then
    add_info2(11, p_acc, p_acc_cur);
    p_err := '�� ����� ' || p_acc || ' ������� �������� ��������.';
    return;
  end if;

-- 4.1. �� ����� ��� ������������ ������������ ���� � ����������� �����������
  select count(1) into l_cnt
  from acc_over_sum
  where cAosSumType = 'O' and cAosStat = '1'
--    and iAosPrior is null -- !!!
    and nvl(iAosPrior, 0) = 0 -- 30358/#463
    and cAosAcc = p_acc and cAosCur = p_acc_cur
    and rownum = 1;

  if l_cnt > 0 then
    add_info2(12, p_acc, p_acc_cur);
    p_err := '�� ����� ' || p_acc || ' ������� ������������ ����� � ����������� �����������.';
    return;
  end if;

-- 4.2. �� ����� ��� ������������ ������������ ���� > 0
  select count(1) into l_cnt
  from acc_over_sum
  where cAosSumType = 'O' and cAosStat = '1'
--    and iAosPrior is not null
--    and nvl(iAosPrior, 0) <> 0 -- 30358/#463
--    ��� ������������� ���� ��������� �� ����� 30533/#171
    and mAosSumma > 0 -- !!!
    and cAosAcc = p_acc and cAosCur = p_acc_cur
    and rownum = 1;

  if l_cnt > 0 then
    add_info2(13, p_acc, p_acc_cur);
    p_err := '�� ����� ' || p_acc || ' ������� ������������ ����� > 0.';
    return;
  end if;

-- 5. ������ ����� '�' ��� '�'
  select count(1) into l_cnt
  from acc
  where caccprizn not in ('�','�')
    and caccacc = p_acc and cacccur = p_acc_cur
    and rownum = 1;

  if l_cnt > 0 then
    add_info2(14, p_acc, p_acc_cur);
    p_err := '���� ' || p_acc || ' ������ ����� ������ "�" ��� "�".';
    return;
  end if;


-- ���������� �� 37429/#10  �. VII. - �� ��������� ��������� �� ��������� � ���������� �� ������

  select
    case when (
      exists (
        select null from xxi.gcs where igcscus = p_cus and igcscat = 300 and igcsnum = 5
      )
    )
    then 1 else 0
    end into l_cnt
  from dual;

  if l_cnt > 0 then
    add_info2(17, p_acc, p_acc_cur);
    p_err := '���� ' || p_acc || '. ������ �������� ���������. ��������� ������ ������ ����������.';
    return;
  end if;

-- ���������� �� 37429/#115  - ���� ���� ����������� ������������ �������� - �� ���������
  select count(1) into l_cnt
  from acc_over_dog
  where caodacc = p_acc and caodcur = p_acc_cur
    and p_date_oper between daodstart and daodend
    and rownum = 1;

  if l_cnt > 0 then
    add_info2(18, p_acc, p_acc_cur);
    p_err := '�� ����� ' || p_acc || ' ������� ������������ ��������.';
    return;
  end if;

  -->> 04.08.2017 ubrr korolkov #43987
  if util.Is_Acc_In_CatGrp(p_acc, p_acc_cur, 998, 1) then
    add_info2(18, p_acc, p_acc_cur);
    p_err := '�� ����� ' || p_acc || ' ����������� ���������/������ 998/1 (�������� �������� ������������� �������)';
    return;
  end if;

  select count(1)
  into l_cnt
  from dual
  where exists(select 1
               from trc
               where cTrcAccD = p_acc
                 and cTRcCur = p_acc_cur
                 and cTrcState = '2'
                 and ctrcstatenc = '0'
                 and mTrcLeft > 0
                 and iTrcPriority < 6);
  if l_cnt > 0 then
    add_info2(18, p_acc, p_acc_cur);
    p_err := '�� ����� ' || p_acc || ' ���� ��������� �� ��������� 2 � ������� "�����������������"';
    return;
  end if;

  select count(1)
  into l_cnt
  from dual
  where exists (select null
                from     trc
                     join
                         trn
                     on itrnanum = 0
                    and itrnnum = (select max(itrnnum)
                                   from trn
                                   where itrnnumanc = itrcnum and itrnanumanc = itrcanum and substr(ctrnaccd, 1, 5) = '90901')
                where ctrcaccd = p_acc
                  and ctrccur = p_acc_cur
                  and ctrcstate = '1'
                  and ctrcstatenc = '0'
                  and mTrcLeft > 0
                  and iTrcPriority < 6
                  and p_cus = (select iacccus
                               from acc
                               where caccacc = ctrnaccd and cacccur = ctrncur));
  if l_cnt > 0 then
    add_info2(18, p_acc, p_acc_cur);
    p_err := '�� ����� ' || p_acc || ' ���� ��������� �� ��������� 1 � ������� "�����������������"';
    return;
  end if;
  --<< 04.08.2017 ubrr korolkov #43987

--select caodacc, caodcur, daodstart, daodend  from acc_over_dog

/*
-- 6. � �2 ���� ��������� � ������������ �������, ��� �������� �� �1
--
-- https://redmine.lan.ubrr.ru/issues/30358#note-352 � �.10 � ������� "������������� .."
-- ��������� ���������� �������� � �2 �������, ������� ��������, �� ������� �������� �� �1,
-- � ����� ���, ���� ��������, ������ �������� � �1 ��� ���������� �� ������ ������

  declare
    l_min1 number;
    l_max2 number;
  begin
    select max(value_num) into l_max2
    from trc t
    join trc_attr_val on inum = iTrcNum
                     and ianum = iTrcANum
                     and id_attr = UBRR_XXI5.ubrr_ordered.ppo --999000
    where cTrcState = '2'
      and cTrcAccD = p_acc
      and cTrcCur = p_acc_cur
      and p_kind = 3; -- �.�. ������� ��������� �� ����� ����������

    select min(value_num) into l_min1
    from trc t
    join trc_attr_val on inum = iTrcNum and ianum = iTrcANum
                     and id_attr = UBRR_XXI5.ubrr_ordered.ppo --999000
    join trn on itrnanum = 0 and itrnnum =
      (
      select max(itrnnum) from trn
      where itrnnumanc = itrcnum and itrnanumanc = itrcanum and substr(ctrnaccd,1,5) = '90901'
      )
    where cTrcState = '1'
      and cTrcAccD = p_acc
      and cTrcCur = p_acc_cur
      and p_cus = (select iacccus from acc where caccacc = ctrnaccd and cacccur = ctrncur)
      and p_kind = 3; -- �.�. ������� ��������� �� ����� ����������

    if l_max2 > l_min1 then
      add_info2(15, p_acc, p_acc_cur);
      p_err := '���� ' || p_acc || ' ����� �������� �� �1 � ������� ����������� ��� �������� �� �2.';
      return;
    end if;
  end;
  */
end;

-- ��������� ACCESS_2.Is_Account_Enabled
-- ����� �� ���������� �� idsmr � �� ������ ������������
function Is_Account_Enabled(
  account   in   ACC.CACCACC%type,
  currency  in   ACC.cacccur%type,
  accid     in   ACC_DST.access_id%type default 1
)
return number is
  ret     number:=0;
begin
  select count(1) into ret
  from dual
  where  exists(
    select 'x' from xxi."acc" a
    where caccacc=account
      and cacccur=currency
      and
        (
        exists
          (
          select 'x' from  acc_ubs2 -- ������������� ����� ������������
          where access_id = accid
            and plan_num = iaccplannum
            and ba2_num = iaccbs2
          )
        or exists
          (
          select 'x' from  xxi."acc_uacc"
          where access_id = accid
            and acc_num = caccacc
            and acc_cur = cacccur
          )
        )
    );
  return ret;
end;


-- �������� � ��������� 2 �, �� ��������� ����������, � ��������� 1
procedure write_off_acc(
  p_acc  xxi."acc".cAccAcc%type,
  p_acc_cur  xxi."acc".cAccCur%type,
  p_cus xxi."acc".iAccCus%type,
  p_kind number,
  p_err out varchar2, -- ���������� �� ������ (��� null, ���� ��� ������)
  p_need_work number,
  p_date_oper date
)
is
  l_accprizn xxi."acc".caccprizn%type;

  cv_stat varchar2(4); -->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)

  -- ��������� ��������� 2
  cursor cr_trc2 is
    select
      (
        select value_num
        from trc_attr_val
        where inum = iTrcNum
          and ianum = iTrcANum
          and id_attr = UBRR_XXI5.ubrr_ordered.ppo /*999000*/
      ) iTrcPriority,
      dTrcCreate, iTrcDocNum,
      iTrcNum, iTrcANum
      ,itrctype,itrcsop,mtrcleft_rub,ABS(MTRCLEFT_RUB-MTRCRSUM) --17.04.2018    ������� �.�.      17-1180      ���: ���������� ���������� �� �������������� ��������� ��������
    from trc t
    where cTrcState = '2'
      -->> 04.08.2017 ubrr korolkov #43987
      and ctrcstatenc != '0' -- �����������������
      --<< 04.08.2017 ubrr korolkov #43987
      and cTrcAccD = p_acc
      and cTrcCur = p_acc_cur
      and p_kind <> 1
    order by 1 nulls first, 2,9 desc;--17.04.2018    ������� �.�.      17-1180      ���: ���������� ���������� �� �������������� ��������� ��������

  ln_trc2 cr_trc2%rowtype;

  -- ��������� ��������� 1 (��������� ����������)
  cursor cr_trc1 is
    select
      (
        select value_num
        from trc_attr_val
        where inum = iTrcNum
          and ianum = iTrcANum
          and id_attr = UBRR_XXI5.ubrr_ordered.ppo /*999000*/
      ) iTrcPriority,
      dTrcCreate, iTrcDocNum,
      iTrcNum, iTrcANum
    from trc t
    join trn on itrnanum = 0 and itrnnum =
      (
      select max(itrnnum) from trn
      where itrnnumanc = itrcnum and itrnanumanc = itrcanum and substr(ctrnaccd,1,5) = '90901'
      )
    where cTrcState = '1'
      -->> 04.08.2017 ubrr korolkov #43987
      and ctrcstatenc != '0' -- �����������������
      --<< 04.08.2017 ubrr korolkov #43987
      and cTrcAccD = p_acc
      and cTrcCur = p_acc_cur
      and p_cus = (select iacccus from acc where caccacc = ctrnaccd and cacccur = ctrncur)
      and p_kind <> 2
      and l_accprizn = '�' -- ��� '�' �� ���������
    order by 1 nulls first, 2;

  ln_trc1 cr_trc1%rowtype;


  cursor cr_limitation is
    select
      ipriority, summ
    from
    (
      select
        -- ������������ ����� � ����������� N ��������� ���������� � �������� �����
        -- ��� ������ ��������� ���������� ����������� N+1.
        d.ipriority + 1 ipriority,
        nvl(abs(sum(mAosSumma)),0)
        +
        decode(d.ipriority, 3,
          (
          select nvl(sum(mAosSumma),0)
          from acc_over_sum
          where cAosSumType = 'B'
            and (upper(cAosComment) like '%���%�%��%' or upper(cAosComment) like '%���%N%��%')
            and cAosStat = '1'
            and cAosAcc = p_acc and cAosCur = p_acc_cur
          )
          , 0
        ) summ
      from (select level ipriority from dual connect by level < 5) d
      left join acc_over_sum aos on d.ipriority = aos.iAosPrior and cAosSumType = 'O'
        and cAosStat = '1' and mAosSumma < 0
        and cAosAcc = p_acc and cAosCur = p_acc_cur
      group by d.ipriority

      union all

      select 1,0 from dual
    )
    order by ipriority;

  ln_limitation cr_limitation%rowtype;

  l_result number;

  l_sum number;         -- ������� �� ������� �������� ��������� � ����������� ����������
  l_rest number;        -- ������� �� ������� �������� ���������

  -- ���������� ��� �������� ���������� � ����� ������������ ��������� �� �1
  l_bad_card1 boolean; -- ������� ��������� � �1, ��������������� ��������� � �2
  l_priority1 number;  -- ��������� ������ ��������� (���� ���� �����)
  l_date_create1 date; -- ���� ����������� ������ ��������� (���� ���� �����)

  -- ��������� ��� ���������� ����������
  l_def_doc_priority number;
--  l_def_doc_date date;

  e_error exception;

  -- ������� ���
  l_krs number;

  procedure close_cursors is
  begin
    if cr_trc1%isopen then close cr_trc1; end if;
    if cr_trc2%isopen then close cr_trc2; end if;
    if cr_limitation%isopen then close cr_limitation; end if;
  end;

  function get_doc1_info return varchar2 is
  begin
    return ' �' || ln_trc1.iTrcDocNum || ' �� ' || to_char (ln_trc1.dTrcCreate,'dd.mm.rrrr') ||' ';
  end;

  function get_doc2_info return varchar2 is
  begin
    return ' �' || ln_trc2.iTrcDocNum || ' �� ' || to_char (ln_trc2.dTrcCreate,'dd.mm.rrrr') ||' ';
  end;

begin
  -- �������� ����������� ��������
  write_off_acc_check(p_acc, p_acc_cur, p_cus, p_date_oper, p_err);

  if p_err is not null then return; end if;

  -- ���� �������� �������� �� �����, �������
  if p_need_work != 1 then return; end if;


  -- ���������, ��������� �� ���� � ���
  select
    case when (
      exists (
        select null from xxi.gac
        where cgacacc = p_acc and cgaccur = p_acc_cur  and igaccat = 333 and igacnum in (2, 3)
      )

/* -- ������� � ����� � 30533/177 -  �/� 333/2|3 �� ������ ������������� � �������
   -- ���� ���������, �� ��� ������ ������������
      or
      exists (
        select null from xxi.gcs where igcscus = p_cus and igcscat = 333 and igcsnum in (2,3)
      )
*/
    )
    then 1 else 0
    end into l_krs
  from dual;



  select min(caccprizn) into l_accprizn from acc where caccacc = p_acc and cacccur = p_acc_cur;

  -- ���������, ���� �� �������� � �1, �������������� (�� �������) ���������� � �2
  l_bad_card1 := false;
  declare
    cursor cr1 is
      select to_number(value_num) as priority, dTrcCreate
      from trc t
      join trc_attr_val on inum = iTrcNum and ianum = iTrcANum
        and id_attr = UBRR_XXI5.ubrr_ordered.ppo --999000
      join trn on itrnanum = 0 and itrnnum =
        (
        select max(itrnnum) from trn
        where itrnnumanc = itrcnum and itrnanumanc = itrcanum and substr(ctrnaccd,1,5) = '90901'
        )
      where cTrcState = '1'
        -->> 04.08.2017 ubrr korolkov #43987
        and ctrcstatenc != '0' -- �����������������
        --<< 04.08.2017 ubrr korolkov #43987
        and cTrcAccD = p_acc
        and cTrcCur = p_acc_cur
        and p_cus = (select iacccus from acc where caccacc = ctrnaccd and cacccur = ctrncur)
        and l_accprizn = '�' -- '�' - �� �����!
        and p_kind = 3 -- �.�. ������� ��������� �� ����� ����������
      order by to_number(value_num), dTrcCreate;

    ln1 cr1%rowtype;

    cursor cr2 is
      select to_number(value_num) as priority, dTrcCreate
      from trc t
      join trc_attr_val on inum = iTrcNum
        and ianum = iTrcANum
        and id_attr = UBRR_XXI5.ubrr_ordered.ppo --999000
      where cTrcState = '2'
        -->> 04.08.2017 ubrr korolkov #43987
        and ctrcstatenc != '0' -- �����������������
        --<< 04.08.2017 ubrr korolkov #43987
        and cTrcAccD = p_acc
        and cTrcCur = p_acc_cur
        and p_kind = 3 -- �.�. ������� ��������� �� ����� ����������
      order by to_number(value_num) desc, dTrcCreate desc;

    ln2 cr2%rowtype;

  begin
    open cr1; fetch cr1 into ln1; close cr1;
    open cr2; fetch cr2 into ln2; close cr2;

    if (ln2.priority > ln1.priority) or
       (ln2.priority = ln1.priority and ln2.dTrcCreate > ln1.dTrcCreate)
    then
      -- ��� ����� ��������, ����� ������ �������� �2 ����� ������ ���������� �1 ����������
      add_info2(15, p_acc, p_acc_cur);
      l_bad_card1    := true;
      l_priority1    := ln1.priority;
      l_date_create1 := ln1.dTrcCreate;
    end if;
  end;

-- ���� � ���������� ��������� ���������� ��� �������� ����� ������� ���������,
-- ���������� ��� ������������ ������ ����������� ����������� ���� ���������
  begin
--    select iPriority, dCreate into l_def_doc_priority, l_def_doc_date
    select iPriority into l_def_doc_priority
    from
      (
      SELECT iPriority, dCreate   -- ��� dCreate ��� dtCreate �����?
      FROM dp_doc d
      WHERE cPayerAcc = p_acc and cCur = p_acc_cur
        and (
          DECODE(iType, -- ��1
            8, Is_Account_Enabled (cRecipAcc, cCurC, 1),
               Is_Account_Enabled (cPayerAcc, cCur, 1)
          ) = 1
          OR NOT EXISTS (
            SELECT NULL FROM ACC
            WHERE cAccAcc = DECODE (iType, 8, cRecipAcc, cPayerAcc)
              AND cAccCur = DECODE (iType, 8, cCurC, cCur)
          )
        )
        and nvl(idDocType,-1) <> '99'
      order by 1,2
      )
    where rownum = 1;

  exception when NO_DATA_FOUND then
    l_def_doc_priority := 999;     -- ������ ������ ������ �������
--    l_def_doc_date := sysdate + 1; -- ����� ����� �� ����������� ���
  end;

  -- �������� ���������, ������������ ������� �������� ���������� �2

  -- � �������� ��������� �����, ���������� � ��������, ����� �������
  l_sum := get_acc_rest(p_acc, p_acc_cur, p_date_oper);  -- ����� �� sysdate?

  if l_sum < 0.001 then return; end if;
  l_rest := l_sum;

  open cr_limitation;  fetch cr_limitation into ln_limitation;

  open cr_trc1;  fetch cr_trc1 into ln_trc1;

  if cr_trc1%found and ln_trc1.itrcpriority is null then
    p_err := '�� �1 ������� ��������'|| get_doc1_info ||'� ����������� �������������� ������������';
    raise e_error;
  end if;

  open cr_trc2;  fetch cr_trc2 into ln_trc2;

  if cr_trc2%found and ln_trc2.itrcpriority is null then
    p_err := '�� �2 ������� ��������'|| get_doc2_info ||'� ����������� �������������� ������������';
    raise e_error;
  end if;

  <<limitation>>
  while cr_limitation%found loop
    l_sum := l_sum - ln_limitation.summ; -- �������� ���������� � �������� �����

    -- ���� ����� ����� �������������, �� ���� ��� ���������, �� �������
    -- ��� �� ���������� 12 (��������, ��� �������)
    if l_sum < 0 then
      if (cr_trc1%found or cr_trc2%found) and l_rest > 0 then
        p_err := '����� ���������� ��������� ������� �� �����.'||
          ' ��������� ������ ������ ����������.';
      end if;
      exit limitation;
    end if;



    while cr_trc2%found and ln_trc2.iTrcPriority = ln_limitation.ipriority and l_sum > 0 loop
      -- ���� ���� �������� �� �1 �������������� ���������� ��������� �� �2
      -- �� ��������� � �2 ���� ����������� ������ ����� ���������� �� �1;
      -- ���� ������ - �������
      if l_bad_card1 and
        (
          (ln_trc2.iTrcPriority > l_priority1) or
          (ln_trc2.iTrcPriority = l_priority1 and ln_trc2.dTrcCreate > l_date_create1)
        )
      then
        exit limitation;
      end if;
      --<< 17.04.2018    ������� �.�.      17-1180      ���: ���������� ���������� �� �������������� ��������� ��������
     --=================================================================
     -- �������� ���������� ��� �������� ��������, ��������� ���������,
     -- ������� �� ���������  � ��������� ���������,� ���������� ������������
     -- � � ����� �����������. ���� ����, �� ����������� ��������� ����.
     --=================================================================
     DECLARE
     lv_ExtResult NUMBER := 0;
     BEGIN
     BEGIN

     SELECT pCount INTO lv_ExtResult
       FROM (SELECT COUNT(*) as pCount,TO_NUMBER (value_num) as value_num,dtrccreate
         FROM trc t
              JOIN trc_attr_val
                  ON     inum = itrcnum
                     AND ianum = itrcanum
                     AND id_attr = ubrr_xxi5.ubrr_ordered.ppo --999000
        WHERE     ctrcstate = '2'    -- ���������
              AND ctrcstatenc != '0' -- �����������������
              AND ctrcaccd = p_acc
              AND ctrccur = p_acc_cur
              AND (mtrcleft_rub > 0 and MTRCRSUM <> MTRCLEFT_RUB)
              AND dtrccreate = ln_trc2.dtrccreate
              GROUP BY TO_NUMBER (value_num),dtrccreate)
              WHERE pCount > 1
               AND TO_NUMBER (value_num) = ln_trc2.iTrcPriority
               AND ROWNUM = 1;
     EXCEPTION
       WHEN NO_DATA_FOUND
         THEN
           lv_ExtResult := 0;
     END;
       IF lv_ExtResult != 0
         THEN
           p_err := '���� '|| p_acc ||'. ���� ��������� � ��������� ���������. ��������� ������ ������ ����������';
           RAISE e_error;
       END IF;
     END;
      --<< 17.04.2018    ������� �.�.      17-1180      ���: ���������� ���������� �� �������������� ��������� ��������
      -- 30358/#361,#366 - ���������� �������� "��������" �������� ���, ��� ����� ����
      if (ln_trc2.iTrcPriority > l_def_doc_priority)
        -- or (ln_trc2.iTrcPriority = l_def_doc_priority and ln_trc2.dTrcCreate > l_def_doc_date)
      then
        p_err := '������� ��������� � ����������. ��������� ������ ������ ���������� ����������.';
        exit limitation;
      end if;


      l_result := write_off_doc2(ln_trc2.iTrcNum, ln_trc2.iTrcANum, p_err, p_date_oper, l_sum,
                                 cv_stat -->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
      );

      if p_err is null and l_result > 0 then
        add_writeoff_info(ln_trc2.iTrcNum, ln_trc2.iTrcANum, l_result,
                          cv_stat -->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
        );
        if l_krs = 1 then
          insert into ubrr_data.ubrr_trc_report(line, part, value1, value2, value3, value4, value5)
          values(c_line, 16, to_char(p_date_oper,'dd.mm.rrrr'), -- 30358/469
            ln_trc2.iTRcDocNum, p_acc, l_result, p_acc_cur);
          c_line := c_line + 1;
        end if;
        l_sum := l_sum - l_result;
        l_rest := l_rest - l_result;
      else
        exit limitation;
      end if;

      fetch cr_trc2 into ln_trc2;
    end loop;

    -- ����:
    --   - �����, ��������� ��� ��������, ����� ����
    --   - ������� �� ����� (� ������ ��������) ������ ����
    --   - �� ���� ������ ��� ��������
    --   - ��� �������� ����������� ��������� �� �2
    -- �� ������ ���������� ���������
    if abs(l_sum) < 0.01 and abs(l_rest) >= 0.01 and cr_trc2%found then
      p_err := '����������� ����������� �� ����� ������, ��� ����������� ���������� ��������� 2.';
      exit limitation;
    end if;


    if not l_bad_card1 then
      -- ��������� �1 ������ �����������, ����� �������� ��������� �2
      while cr_trc1%found and ln_trc1.iTrcPriority = ln_limitation.ipriority  and l_sum > 0 loop

        -- 30358/#361,#366 - ���������� �������� "��������" �������� ���, ��� ����� ����
        if (ln_trc1.iTrcPriority > l_def_doc_priority)
          -- or (ln_trc1.iTrcPriority = l_def_doc_priority and ln_trc1.dTrcCreate > l_def_doc_date)
        then
          p_err := '������� ��������� � ����������. ��������� ������ ������ ���������� ����������.';
          exit limitation;
        end if;

        l_result := write_off_doc1(ln_trc1.iTrcNum, ln_trc1.iTrcANum, p_err, p_date_oper, l_sum,
                                   cv_stat -->><<-- 14.02.2020 ������ �.�.[19-64691] ���: ����������� ��������������� �������� �������� ��������� �������� (������ ������ ���������)
                                   );

        if p_err is null and l_result > 0 then
          add_writeoff_info(ln_trc1.iTrcNum, ln_trc1.iTrcANum, l_result);
          if l_krs = 1 then
            insert into ubrr_data.ubrr_trc_report(line, part, value1, value2, value3, value4, value5)
            values(c_line, 16, to_char(p_date_oper,'dd.mm.rrrr'), -- 30358/469
              ln_trc1.iTRcDocNum, p_acc, l_result, p_acc_cur);
            c_line := c_line + 1;
          end if;

          l_sum := l_sum - l_result;
          l_rest := l_rest - l_result;
        else
          exit limitation;
        end if;

        fetch cr_trc1 into ln_trc1;
      end loop;

      -- ����:
      --   - �����, ��������� ��� ��������, ����� ����
      --   - ������� �� ����� (� ������ ��������) ������ ����
      --   - �� ���� ������ ��� ��������
      --   - ��� �������� ����������� ��������� �� �1
      -- �� ������ ���������� ���������
      if abs(l_sum) < 0.01 and abs(l_rest) >= 0.01 and cr_trc1%found then
        p_err := '����������� ����������� �� ����� ������, ��� ����������� ���������� ��������� 1.';
        exit limitation;
      end if;
    end if;

    fetch cr_limitation into ln_limitation;
  end loop limitation;

  if l_bad_card1 then
    p_err := '���� ' || p_acc || ' ����� �������� �� �1 � ������� ����������� ��� �������� �� �2. '|| p_err;
  end if;

  close_cursors;

--  commit; -- ���� ���������� ��� �� �����, �� ����� ��������� ���������. TODO ��������� ������ �� ������� �����
exception
when e_error then
  close_cursors;
when others then
  close_cursors;
  p_err := dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || ' ';
--  rollback;
end;



procedure del_ubrr_trc_move
is
begin
  delete from ubrr_data.ubrr_trc_move;
end;


procedure fill_ubrr_trc_move
is
    lv_ppo_num number := UBRR_XXI5.ubrr_ordered.get_ppo();  -- 11.04.2017 �������� - �����������
begin

  delete from ubrr_data.ubrr_trc_move;

    -- 16.05.2017 �������� - ����������� >>>
    /* -- old code --
  insert into ubrr_data.ubrr_trc_move(cacc, cname, icus, cdirection)
  (
  select cacc, cname, icus, '1 -> 2'
  from ubrr_data.ubrr_trc_loa
  where cprizn <> '�'  --���� �� ������, �� ��� �������������� - �������� ������
    and not exists(
      select 1 from ach h
      where cachacc = cacc and cachcur = ccur
        and
            -- ������� ��������������� ���
          ( regexp_like (upper(cachbase),'(.*(��|��(�|�)|�\.).*\d{1,}.*|(^\d{1,}.*)(|((�|N).*\d{1,}))).*(��|JN)\s*\d{2}(,|\.|\/|\\)\d{2}(,|\.|\/|\\)\d.*')
            or regexp_like (upper(cachbase),'(�����(\.|\s)|�����������).*���')
            or upper(cachbase) like '%���%'
            or upper(cachbase) like '% ���%'
            or upper(cachbase) like '��� ��%'
            or upper(cachbase) like '%����%'
          )
        and not upper(cachbase) like '%���%' and not upper(cachbase) like '%CDR%'
        and not upper(cachbase) like '%���%'
        and not regexp_like (upper(cachbase),'\d{4}-\d{2}\/\d{6}')
        -- ��������� ������� ������ ���
        and not regexp_like (upper(cachbase),'(���.*(|(�|N)).*\d{1,}.*(��|JN))|((�|J)�����)')
      )

    and not exists (
      select 1
      from acc_over_sum
      where cAosAcc = cacc and cAosCur = ccur
        and  cAosSumType = 'B'  -- and dAosDelete is null
        and cAosStat = '1'
        and
          -- ���
          ( regexp_like (upper(cAosComment),'(.*��(�|�).*\d{1,}.*|(^\d{1,}.*)(|((�|N).*\d{1,}))).*(��|JN)\s*\d{2}(,|\.|\/)\d{2}(,|\.|\/)\d.*')
            or upper(cAosComment) like '%����%'
          )
        and not upper(cAosComment) like '%(���)%'
    ) -- ��� ������������� ���� -- https://redmine.lan.ubrr.ru/issues/30358#note-98

/*
����: ����� �� ������� ��� ������ ������  ��� ������ ��� �������� "�1->K2" ����
������� ���������� �� ��������� 1.
�����: ��� ������ ������ ����������� ������� ���������� �� ��������� 1,
��������������� ��������������� �������.
�������������� �������: ��� ��������� �� ��������� 1 ������������ �����
������� ��� ����� ����������� ���������. ����� ��� ����� ��������� ����������
����������� � ���� ��������, �  ����� �������� �� ��, ��������������� ����� 90901%,
������ ��������� ��������. ��� ���� ��������, ��������� ��������� ����, ��� �����
- ����� �������.
���� ���� ����� ������� �� ����� ����� ���������� ������ ������� ��� �����
����������� ���������, �� ������� ��������� �������������.
����� ������� ������ �����, � ������� �� ��������� 1 ������ ��������� ������
�������, ���������� � ������ �� ������.

��� ��� - ����������� ������� ���� �� ������ ������ ���������!
* /

    and  exists (
      select 1
      from trc
      join trn on itrnanum = 0 and itrnnum =
        (
        select max(itrnnum) from trn
        where itrnnumanc = itrcnum and itrnanumanc = itrcanum and substr(ctrnaccd,1,5) = '90901'
        )
      where ctrcaccd = cacc
        and ctrccur = ccur
        and ctrcstate = '1'
        -->> 04.08.2017 ubrr korolkov #43987
        and ctrcstatenc != '0' -- �����������������
        --<< 04.08.2017 ubrr korolkov #43987
        and icus = (select iacccus from acc where caccacc = ctrnaccd and cacccur = ctrncur)
    ) -- ���� ��������� � �1
  );

    */


    insert into ubrr_data.ubrr_trc_move(cacc, cname, icus, cdirection)
    select /*+ all_rows
               full(tl)
               leading(tl)
           */
           tl.cacc,
           tl.cname,
           tl.icus,
           '1 -> 2'
    from ubrr_data.ubrr_trc_loa tl
    where     tl.cprizn <> '�'  --���� �� ������, �� ��� �������������� - �������� ������
          and not exists(
                            select /*+ no_unnest
                                       index_ss(h P_ACH)
                                       push_subq */
                                   'x'
                            from ach h
                            where     h.cachacc = tl.cacc
                                  and h.cachcur = tl.ccur
                                  and h.CACHFLAG<>'�'-->><<-- 14.01.2021 ������ �.�. [IM2685764-001] ������� ���������� ���������
                                  and -- ������� ��������������� ���
                                  (
                                    regexp_like (upper(h.cachbase),'(.*(��|��(�|�)|�\.).*\d{1,}.*|(^\d{1,}.*)(|((�|N).*\d{1,}))).*(��|JN)\s*\d{2}(,|\.|\/|\\)\d{2}(,|\.|\/|\\)\d.*')
                                    or regexp_like (upper(h.cachbase),'(�����(\.|\s)|�����������).*���')
                                    or upper(h.cachbase) like '%���%'
                                    or upper(h.cachbase) like '% ���%'
                                    or upper(h.cachbase) like '��� ��%'
                                    or upper(h.cachbase) like '%����%'
                                  )
                                  and not upper(h.cachbase) like '%���%'
                                  and not upper(h.cachbase) like '%CDR%'
                                  and not upper(h.cachbase) like '%���%'
                                  and not regexp_like (upper(h.cachbase),'\d{4}-\d{2}\/\d{6}')
                                  -- ��������� ������� ������ ���
                                  and not regexp_like (upper(h.cachbase),'(���.*(|(�|N)).*\d{1,}.*(��|JN))|((�|J)�����)')
                        )
          and not exists (  -- ��� ������������� ����
                            select /*+ no_unnest
                                       index(aos I_ACC_OVER_SUM_ACC_CUR_SUMTYP)
                                       no_push_subq */
                                   'x'
                            from acc_over_sum aos
                            where     aos.cAosAcc = tl.cacc
                                  and aos.cAosCur = tl.ccur
                                  and aos.cAosSumType = 'B'
                                  and aos.cAosStat = '1'
                                  and -- ���
                                  (
                                    regexp_like (upper(aos.cAosComment),'(.*��(�|�).*\d{1,}.*|(^\d{1,}.*)(|((�|N).*\d{1,}))).*(��|JN)\s*\d{2}(,|\.|\/)\d{2}(,|\.|\/)\d.*')
                                    or upper(aos.cAosComment) like '%����%'
                                  )
                                  and not upper(aos.cAosComment) like '%(���)%'
                         )
          /*
          ���� ���� ����� ������� �� ����� ����� ���������� ������ ������� ��� �����
          ����������� ���������, �� ������� ��������� �������������.
          ����� ������� ������ �����, � ������� �� ��������� 1 ������ ��������� ������
          �������, ���������� � ������ �� ������.

          ��� ��� - ����������� ������� ���� �� ������ ������ ���������!
          */
          -- ���� ��������� � �1
          and exists (
                        select /*+ no_unnest
                                   no_push_subq */
                               'x'
                        from trc tc
                        join trn tn on tn.itrnanum = 0
                                   and tn.itrnnum = (
                                                      select
                                                             max(tc2.itrnnum)
                                                      from trn tc2
                                                      where     tc2.itrnnumanc = tc.itrcnum
                                                            and tc2.itrnanumanc = tc.itrcanum
                                                            and substr(ctrnaccd,1,5) = '90901'
                                                    )
                        where tc.ctrcaccd = tl.cacc
                          and tc.ctrccur = tl.ccur
                          and tc.ctrcstate = '1'
                          and tl.icus = (
                                            select acc.iacccus
                                            from acc
                                            where     acc.caccacc = tn.ctrnaccd
                                                  and acc.cacccur = tn.ctrncur
                                                  and rownum < 2
                                        )
                     );
    -- 16.05.2017 �������� - ����������� <<<

    -- 11.04.2017 �������� - ����������� >>>
  insert into ubrr_data.ubrr_trc_move(cacc, cname, icus, cdirection)
    select /*+ all_rows
               full(tl)
               leading(tl)
           */
           tl.cacc,
           tl.cname,
           tl.icus,
           '2 -> 1'
    from ubrr_data.ubrr_trc_loa tl
    where     tl.cprizn <> '�' -- ���������� �������� �����
          and exists (  -- ���� ����������� ��������� 6 ����������� � �2
                        select /*+ push_subq */
                                '1'
                        from trc tr,
                             trc_attr_val tat
                        where     tat.id_attr = lv_ppo_num
                              and tat.inum = tr.iTrcNum
                              and tat.ianum = tr.iTrcANum
                              and tat.value_num = 5 -- ������ 5-� �������
                              and tr.ctrcaccd = tl.cacc
                              and tr.ctrccur = tl.ccur
                              and tr.ctrcstate = '2'
                              -->> 04.08.2017 ubrr korolkov #43987
                              and ctrcstatenc != '0' -- �����������������
                              --<< 04.08.2017 ubrr korolkov #43987
                              -- ��������� ������� �� �����������
                              and substr(tr.cTrcAccA,1,5) <> '40101'
                              and not regexp_like(tr.cTrcAccA,'^('||nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.CACCA_NAL'),'03100')||')')  --18.11.2020    ������� �.�.      [20-82101.1]  ���: ��������� ������ ���� � 01.01.2021
                     )

          and (
                exists( -- ������� ��������������� ���
                        select /*+ no_unnest index_ss(h P_ACH) no_push_subq */
                               '1'
                        from ach h
                        where     h.cachacc = tl.cacc
                              and h.cachcur = tl.ccur
                              and h.CACHFLAG<>'�'-->><<-- 14.01.2021 ������ �.�. [IM2685764-001] ������� ���������� ���������
                              and not upper(h.cachbase) like '%���%'
                              and not upper(h.cachbase) like '%CDR%'
                              and not upper(h.cachbase) like '%���%'
                              and (
                                    upper(h.cachbase) like '%���%'
                                    or
                                    upper(h.cachbase) like '% ���%'
                                    or
                                    upper(h.cachbase) like '��� ��%'
                                    or
                                    upper(h.cachbase) like '%����%'
                                    or
                                    regexp_like (upper(h.cachbase),'(.*(��|��(�|�)|�\.).*\d{1,}.*|(^\d{1,}.*)(|((�|N).*\d{1,}))).*(��|JN)\s*\d{2}(,|\.|\/|\\)\d{2}(,|\.|\/|\\)\d.*')
                                    or
                                    regexp_like (upper(h.cachbase),'(�����(\.|\s)|�����������).*���')
                                  )
                              and not regexp_like (upper(h.cachbase),'\d{4}-\d{2}\/\d{6}')
                              -- ��������� ������� ������ ���
                              and not regexp_like (upper(h.cachbase),'(���.*(|(�|N)).*\d{1,}.*(��|JN))|((�|J)�����)')
                      )
                OR
                exists( -- ��� ���� ������������� �����
                        select /*+ no_unnest index(aos I_ACC_OVER_SUM_ACC_CUR_SUMTYP) no_push_subq */
                               '1'
                        from acc_over_sum aos
                        where     aos.cAosAcc = tl.cacc
                              and aos.cAosCur = tl.ccur
                              and aos.cAosSumType = 'B'
                              and aos.cAosStat = '1'
                              and (
                                    regexp_like (upper(aos.cAosComment),'(.*��(�|�).*\d{1,}.*|(^\d{1,}.*)(|((�|N).*\d{1,}))).*(��|JN)\s*\d{2}(,|\.|\/)\d{2}(,|\.|\/)\d.*')
                                    or
                                    upper(aos.cAosComment) like '%����%'
                                  )
                              and not upper(aos.cAosComment) like '%(���)%'
                      )
              );
    -- 11.04.2017 �������� - ����������� <<<
end;


procedure del_ubrr_trc_writeoff
is
begin
  delete from ubrr_data.ubrr_trc_writeoff;
end;


procedure fill_ubrr_trc_writeoff
is
  cursor cr_acc is
    select cacc, cname, icus, ccur , ikind
    from
      (

      select cacc, cname, icus, ccur , cprizn,
        case when exists(
          select null from trc
          where cTrcState = '2'
            and cTrcAccD = a.cacc
            and cTRcCur = a.ccur
            and mTrcLeft > 0
            and iTrcPriority < 6
        ) then 2 else 0 end
        +
        case when exists( -- ���������� �������� �� �1, ��������� ���������� (�.�. _��_ �������!)
          select null
          from trc
          join trn on itrnanum = 0 and itrnnum =
            (
            select max(itrnnum) from trn
            where itrnnumanc = itrcnum and itrnanumanc = itrcanum and substr(ctrnaccd,1,5) = '90901'
            )
          where ctrcaccd = cacc
            and ctrccur = ccur
            and ctrcstate = '1'
            and  mTrcLeft > 0 -- ����� �� ���� � ���������
            and iTrcPriority < 6
            and icus = (select iacccus from acc where caccacc = ctrnaccd and cacccur = ctrncur)
        ) then 1 else 0 end ikind
      from ubrr_data.ubrr_trc_loa a
      where cPrizn <> '�'
      )
    where ikind > 0
      and not (cPrizn = '�' and ikind = 1) -- 30358/#352 �.7;
    ;

  ln_acc cr_acc%rowtype;
  l_rest number;
begin


  delete from ubrr_data.ubrr_trc_writeoff;

  open cr_acc; fetch cr_acc into ln_acc;
  while cr_acc%found loop
    l_rest := get_acc_rest(ln_acc.cacc, ln_acc.ccur, sysdate);

    if l_rest > 0 then
      insert into ubrr_data.ubrr_trc_writeoff(cacc, cname, icus, mRest, cDescription,
        ikind)
      values(ln_acc.cacc, ln_acc.cname, ln_acc.icus, l_rest, null,
        ln_acc.ikind);
    end if;

    fetch cr_acc into ln_acc;
  end loop;
end;


procedure writeoff_selected(
  p_marker_id number,
  p_need_work number,
  p_need_mail number,
  p_date_oper date
)
is

  cursor cr_acc is
    select a.caccacc, a.cacccur, a.iacccus, m.rmrkrowid, u.ikind, a.iacccheck, a.idsmr
    ,a.IACCOTD -->><<-- 09.01.2019    ������ �.�.       [19-64691]   �������������� ��������� ��������
    from ubrr_data.ubrr_trc_writeoff u
    join mrk m on u.rowid = m.rmrkrowid and m.imrkmarkerid = p_marker_id
    join acc a on u.cacc = a.caccacc and a.caccprizn <> '�'
    order by a.caccacc, a.cacccur;

  ln_acc cr_acc%rowtype;
  l_iAccCheck_saved number;
  l_idsmr xxi."trn".idsmr%type := SYS_CONTEXT ('B21', 'IDSmr');
  l_rest  number;
  l_err   varchar2(4000);
  l_enable boolean :=  triggers_ubrr.AllTriggersEnabled;
  e_acrtable exception;

  -->>-- 23.12.2020 ������ �.�. [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���. ������ ����������� ��������
  resource_busy exception;
  pragma exception_init (resource_busy,-54);
  --<<-- 23.12.2020 ������ �.�. [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���. ������ ����������� ��������

begin
  g_need_mail := p_need_mail;

  -- �������� ������ trun ��� �� ����� ����������� �������� �� ������� ������ - ��� ��� ���������
  -- � ������ ������� ��� ��������� �� ��������

  -- ������� ������� ��� ������� ����������� ��������
  delete from ubrr_data.ubrr_trc_report;  c_line := 0;

  open cr_acc; fetch cr_acc into ln_acc;
  while cr_acc% found loop
    begin

      -->>-- 23.12.2020 ������ �.�. [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���. ������ ����������� ��������
      if pref.Get_Universal_Preference('AUTO_TRC_STOP_PROCESS'|| '_' ||l_idsmr,'N') = 'Y' then -->><<-- 14.01.2020 ������ �.�. [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���
        l_err := '�������������� �������� �����������. � UPS AUTO_TRC_STOP_PROCESS_'||l_idsmr||'=Y';
        raise resource_busy;
      end if;
      --<<-- 23.12.2020 ������ �.�. [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���. ������ ����������� ��������

      -- ���� �������� ���������� �������� - �������
      -- ��-��������, ����� ������� �� ������������� ���������� �� dbms_lock,
      -- � ������� ������� ���� ���, � �� ��� ������� �����
      if not lock_acrtable(
        p_wait => g_need_wait_lock_acrtable,
        p_exclusive => false,
        p_idsmr => l_idsmr
      )
      then
        l_err := '�������� ��������, ��������� � ������ ������ �������� �������� ���������� ��������..';
        raise e_acrtable;
      end if;

      -- ���� �� ������� ��������� ���������� - ��������� � ���������� �����
      if lock_acc(
        p_acc       => ln_acc.caccacc,
        p_cur       => ln_acc.cacccur,
        p_wait      => g_need_wait_lock_acc,
        p_idsmr     => l_idsmr
      )
      then
        -- ���������� ������� �������� iacccheck ����� ����������
        l_iAccCheck_saved := ln_acc.iacccheck;

        -- �������� ������������� iacccheck � 2 - ����� ��������� �������� � ������ trun
        -- ��� ���� �������� ��������� �������
        if l_enable then triggers_ubrr.Set_AllTriggersDisable; end if;

        begin
          update acc set iacccheck = 2
          where caccacc = ln_acc.caccacc and cacccur = ln_acc.cacccur and idsmr = ln_acc.idsmr;
        exception when others then
          if l_enable then triggers_ubrr.Set_AllTriggersEnable; end if;
          raise;
        end;

        if l_enable then triggers_ubrr.Set_AllTriggersEnable; end if;

        -- ������ ��������
        write_off_acc(
          p_acc       => ln_acc.caccacc,
          p_acc_cur   => ln_acc.cacccur,
          p_cus       => ln_acc.iacccus,
          p_kind      => ln_acc.ikind,
          p_err       => l_err,
          p_need_work => p_need_work,
          p_date_oper => p_date_oper
        );

        -- ������������� ������� �������� iacccheck
        -- ��� ���� �������� ��������� �������
        if l_enable then triggers_ubrr.Set_AllTriggersDisable; end if;

        begin
          update acc set iacccheck = l_iAccCheck_saved
          where caccacc = ln_acc.caccacc and cacccur = ln_acc.cacccur and idsmr = ln_acc.idsmr;
        exception when others then
          if l_enable then triggers_ubrr.Set_AllTriggersEnable; end if;
          raise;
        end;

        if l_enable then triggers_ubrr.Set_AllTriggersEnable; end if;
      else
        l_err := '���� �� ���������, ����� ������ �������������. ��������� ��������� ���������.';
      end if;

      if l_err is not null then
        if not regexp_like(l_err, ln_acc.caccacc) then -->><<--15.05.2019 ������ [19-59060.2] ���: ��������� ���������� ������ ���� (1�����)
           l_err := '���� '||ln_acc.caccacc||'. '|| l_err;
        end if; -->><<--15.05.2019 ������ [19-59060.2] ���: ��������� ���������� ������ ���� (1�����)
        add_error_info(l_err
         ,ln_acc.IACCOTD ); -->><<-- 09.01.2019    ������ �.�.       [19-64691]   �������������� ��������� ��������
      end if;


    exception
      -->>-- 23.12.2020 ������ �.�. [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���. ������ ����������� ��������
    when resource_busy then
      raise resource_busy;
      -->>-- 23.12.2020 ������ �.�. [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���. ������ ����������� ��������
    when e_acrtable then
      add_error_info(l_err);
    when others then
      l_err := '���� '||ln_acc.caccacc||'. '|| dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || ' ';
      add_error_info(l_err
       ,ln_acc.IACCOTD ); -->><<-- 09.01.2019    ������ �.�.       [19-64691]   �������������� ��������� ��������
    end;

    -- ����������� �� ������� �������� �������
    l_rest := get_acc_rest(ln_acc.caccacc, ln_acc.cacccur, sysdate);

    -- ������� �� ����� ������� �, ��� �������������, �������� ������� ����������
    update ubrr_data.ubrr_trc_writeoff set
      mRest = l_rest, cDescription = substr(l_err,1,256)
    where cacc = ln_acc.caccacc;

    commit; -- ������� ���������� � ������ � acc � ��������� ������ ���������

    fetch cr_acc into ln_acc;
  end loop;


  close cr_acc;

  send_reestr; -- ��������, ���� ����������, �����, � ������� �������.
  commit;

  g_need_mail := 1;

exception
  -->>-- 23.12.2020 ������ �.�. [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���. ������ ����������� ��������
  when resource_busy then
    add_error_info(l_err);
    if cr_acc%isopen then close cr_acc; end if;
    raise resource_busy;
  --<<-- 23.12.2020 ������ �.�. [IM2545087-001] ���������� �������� �� SAP CRM � ������ �������� ��� �������� ���. ������ ����������� ��������
  when others then
  l_err := dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || ' ';
  add_error_info(l_err
   ,ln_acc.IACCOTD ); -->><<-- 09.01.2019    ������ �.�.       [19-64691]   �������������� ��������� ��������

  if cr_acc%isopen then close cr_acc; end if;
  g_need_mail := 1;
end;

procedure create_acrtable(
  p_idsmr  xxi."trn".idsmr%type default SYS_CONTEXT ('B21', 'IDSmr')
)
is
  pragma autonomous_transaction;
begin
  -- ����� ����� �� ���� ������, ����� ��� ����� ������ ��� �������� � ����� xxi
  execute immediate 'create table xxi.acr_lock_' || p_idsmr || ' ( cnull  char )';
--  execute immediate 'grant update on xxi.acr_lock_' || p_idsmr || ' to ubrr_xxi5';
exception
when others then
  if sqlcode = -00955 then -- name is already used by an exsisting object
    null;
  elsif sqlcode = -01031 then --  insufficient privileges
    raise;
  else
    raise;
  end if;
end create_acrtable;


/*
��������� ��������� ���������� ��� �������� �������� ����� ������� ��������,
������� ��� ������ ������� ��������� �������, ��� � ����������� ������� �� ������ trun,
���������� ��� �������� ��������� ����������.
� ��� ��������������� ���������� ������� LOCK TABLE ACR_LOCK_<IdSmr>
*/

function lock_acrtable(
  p_wait      boolean default false,
  p_exclusive boolean default false,
  p_idsmr     xxi."trn".idsmr%type default SYS_CONTEXT ('B21', 'IDSmr')
)
return boolean
is
  l_wait varchar2(16);
  l_mode varchar2(16);
  l_sql varchar2(256);
begin
  if p_wait      then l_wait := null;        else l_wait := ' nowait'; end if;
  if p_exclusive then l_mode := 'exclusive'; else l_mode := 'share';   end if;

  l_sql := 'lock table xxi.acr_lock_' || p_idsmr || ' in ' || l_mode || ' mode' || l_wait;
  execute immediate l_sql;

  return true;
exception
when others then
  if sqlcode = -00942 then -- table or view does not exists
    create_acrtable(p_idsmr);
    return lock_acrtable(p_wait, p_exclusive, p_idsmr);
  elsif sqlcode = -00054 then -- resource busy
    return false;
  elsif sqlcode = -01031 then --  insufficient privileges
    raise;
  else
    raise;
  end if;
END lock_acrtable;

-- ��������� ���������� �����, ����� ������������� �������� �������� �� ����� � ������ ������
-- (��. ����� trun)
function lock_acc(
  p_acc       xxi."acc".caccacc%type,
  p_cur       xxi."acc".cacccur%type,
  p_wait      boolean default false,
  p_idsmr     xxi."trn".idsmr%type default SYS_CONTEXT ('B21', 'IDSmr')
)
return boolean
is
  l_wait varchar2(16);
  l_sql  varchar2(256);
  type t_acc is ref cursor;
  cr_acc t_acc;
--  l_acc       xxi."acc".caccacc%type,
begin
  if p_wait then l_wait := null; else l_wait := ' nowait'; end if;

  l_sql := 'select caccacc from xxi."acc" where idsmr = :0 and caccacc = :1 and cacccur = :2 '
    || 'for update' || l_wait;

  open cr_acc for l_sql using p_idsmr, p_acc, p_cur;
  close cr_acc;

  return true;
exception
when others then
  if sqlcode = -00054 then -- resource busy
    return false;
  else
    raise;
  end if;
END lock_acc;



-- �����������, �������� �� ������� ���������� ������
function is_full_move(
  p_marker_id in number
)
return boolean
is
  l_cnt_unselected number; -- ���������� ������������ - ���������� ������, ����� ������� �������� ���
begin
  select count(1) into l_cnt_unselected
  from ubrr_data.ubrr_trc_move u
  left join mrk m on u.rowid = m.rmrkrowid and m.imrkmarkerid = p_marker_id
  where m.rmrkrowid is null and rownum = 1;

  return (l_cnt_unselected = 0);
end;


-- ���������� ��������� ������� ������� ������
--
procedure fill_loa16
is
  l_sql varchar2(4000);
  l_cond varchar2(4000) := null;

  l_krs varchar2(1) ;
  l_str_krs varchar2(1024);
  iv_cnt integer; -->><<-- 21.01.2019 ������ �.�. [20-70561] ����������: ��������� ��������� �� ������� ������/���� �������� 440-�
begin

  l_krs := nvl(PREF.Get_Preference ('CARD.KRS'), '2');
  l_str_krs := '
( select null from xxi.gac
  where cgacacc = caccacc and cgaccur = cacccur  and igaccat = 333 and igacnum in (2, 3)
)
'     ;

  if l_krs = '0' then -- �� ���
    l_cond := ' and not exists ' || l_str_krs;
  elsif l_krs = '1' then -- ���
    l_cond := ' and exists ' || l_str_krs;
  else
    null; -- ���� �� ����� ���������, �� �� ����� ���.�������
  end if;

  -->> 21.01.2019 ������ �.�. [20-70561] ����������: ��������� ��������� �� ������� ������/���� �������� 440-�
  select count(1) into iv_cnt from dual
  where exists
  ( select 1
    from ubrr_data.ubrr_trc_params where cparam_name= 'OTD' and cuser = user
  );

  if iv_cnt>0 then
  l_cond := l_cond || ' and iaccotd in (select iparam_value from ubrr_data.ubrr_trc_params '||
        'where cparam_name= ''OTD'' and cuser = ''' || user || ''') ';
  end if;
  --<< 21.01.2019 ������ �.�. [20-70561] ����������: ��������� ��������� �� ������� ������/���� �������� 440-�

  -->> 11.03.2020 ������ �.�. [19-64691] �������������� ��������� �������� Update
  if xxi.triggers.getuser is not null and abr.triggers.getuser is not null then
    l_cond := l_cond ||
      ' and regexp_like(cAccAcc, ''^(401|402|403|404|405|406|407|40802|40807|42309|40821)'') and cAccCur=''RUR'' ';
  end if;
  --<< 11.03.2020 ������ �.�. [19-64691] �������������� ��������� �������� Update

  l_sql := 'INSERT INTO ubrr_data.ubrr_trc_loa(
  cacc, ccur, cname, icus, cprizn, icnt1, icnt2
  )
  (SELECT cAccAcc, cAccCur, cAccName, iAccCus, cAccPrizn, null, null
   FROM ACC
   WHERE cAccPrizn <> ''�'' ' || l_cond ||')';

  delete from ubrr_data.ubrr_trc_loa;
--dbms_output.put_line(l_sql);

  execute immediate l_sql;
end;





-- ��������� ������� ��� ��������� �� ��������� �� ����� ubrr_otd_select
-- TODO 11/11/2016 ��������� �������������. ���� ����� - �� �������
procedure select_default_otd(
  p_marker_otd  number,
  p_default_otd number
)
is
  l_cnt number;
  l_rowid rowid;
begin
  if p_default_otd is not null then
    select count(1) into l_cnt
    from xxi.otd o
    join xxi.mrk m on o.rowid = m.rmrkrowid and m.imrkmarkerid = p_marker_otd
    where rownum = 1;

    if l_cnt = 0 then
      begin
        select max(rowid) into l_rowid from xxi.otd where iotdnum = p_default_otd;
        xxi.util.mrk_insert(l_rowid, p_marker_otd);
        commit;
      exception when others then null;
      end;
    end if;
  end if;
end;

function check_cachbase(
  p_template_kind number,
  p_base varchar2,
  p_msg out varchar2
)
return boolean
is
  l_passed boolean := false;
--  g_dummy_d date;                 -- ���������� - �������� ��� ���

begin
  p_msg := null;

  if p_template_kind = 1 then    -- ���
--    if regexp_like(p_base, '^([*][*][*])?���. � \d+ ��') then
    if regexp_like(p_base, '^([*]{3})?���. � \d+ �� (\d{2}[.]\d{2}[.]\d{4})') then
      -- �������� ������������ ����
      begin
        g_dummy_s := regexp_substr(p_base, '^([*]{3})?���. � \d+ �� (\d{2}[.]\d{2}[.]\d{4})', 1, 1, 'i', 2);
        g_dummy_d := to_date(g_dummy_s,'dd.mm.rrrr');
        l_passed := true;
      exception when others then null;
      end;

      if l_passed then
        return true;
      else
        p_msg := '������������ ������ ����. ��� ���������� ���������� �������� ���� "���������" ������ ����� ��� "���. � <�����> �� <���� � ������� ��.��.����>" ���� "***���. � <�����> �� <���� � ������� ��.��.����>". ��������: "���. � 123456 �� 30.01.2017"';
        return false;
      end if;
    else
      p_msg := '��� ���������� ���������� �������� ���� "���������" ������ ����� ��� "���. � <�����> �� <���� � ������� ��.��.����>" ���� "***���. � <�����> �� <���� � ������� ��.��.����>". ��������: "���. � 123456 �� 30.01.2017"';
      return false;
    end if;
  elsif p_template_kind = 2 then -- ����
    return true;
  else
    return true;
  end if;
end;
-->> 17.04.2018    ������� �.�.      17-1180      ���: ���������� ���������� �� �������������� ��������� ��������
--=================================================================
-- ������� ���������, ���� �� ��������� � "���������� ��������"
-- �� ����� �� �� �������� � ����� ����������� � ���������� ��������
--=================================================================
FUNCTION ChecPostDocByTrc (pTrcAccD IN VARCHAR2) RETURN BOOLEAN
IS
  lv_extPost NUMBER;
BEGIN
  SELECT 1 INTO lv_extPost FROM DUAL
    WHERE EXISTS (SELECT 1 FROM DP_XDOC
                   WHERE CPAYERACC = pTrcAccD
                     AND (iddoctype != 99 OR iddoctype IS NULL));
  RETURN (TRUE);
EXCEPTION
  WHEN NO_DATA_FOUND
    THEN RETURN(FALSE);
  WHEN OTHERS
    THEN RETURN(TRUE);
END;
--<< 17.04.2018    ������� �.�.      17-1180      ���: ���������� ���������� �� �������������� ��������� ��������

-->> 08.05.2019    ������ �.�. [19-59060.2] ���: ��������� ���������� ������ ���� (1�����)
function is_acc(p_acc varchar2) return boolean is
begin
  if regexp_count( nvl(p_acc,'-'), '\d')= length(nvl(p_acc,'-')) then
     return true;
  else
     return false;
  end if;
end;


function get_sud_ft_account(p_Mfoa trc.cTrcMfoA%type, p_cTrcAccA trc.CTRCACCA%type)
  return ubrr_data.ubrr_sud_ft_accounts.account_new%type
is
  l_acc ubrr_data.ubrr_sud_ft_accounts.account_new%type;
begin
  select t.account_new into l_acc
  from ubrr_data.ubrr_sud_ft_accounts t
  where t.bik=p_Mfoa and t.account_old=p_cTrcAccA;

  return l_acc;
exception when NO_DATA_FOUND then
  return(null);
end;
--<< 08.05.2019    ������ �.�. [19-59060.2] ���: ��������� ���������� ������ ���� (1�����)

end;
/
