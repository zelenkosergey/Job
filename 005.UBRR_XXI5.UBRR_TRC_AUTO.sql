CREATE OR REPLACE PACKAGE BODY UBRR_XXI5.ubrr_trc_auto is

/******************************* HISTORY UBRR *************************************\
   Дата             Автор        ID          Описание
----------   ---------------    ---------    ---------------------------------------
16.06.2016    Емельянов В.К.    [15-1019]    https://redmine.lan.ubrr.ru/issues/30358
                                             Создана начальная версия
21.11.2016    Емельянов В.К.    [15-1019]    Очередная версия - на этот раз и для УБРиР.
19.12.2016    Емельянов В.К.    [16-2882]    Очередная версия по 37429/#10,#12
16.01.2017    Емельянов В.К.    [16-2882]    Часть пакета перенесена в UBRR_TRC_AUTO_UTILS
01.02.2016    Емельянов В.К.    [16-2882]    Очередная версия
11.04.2017    Вахрушев М.А.     [oaiir-opt-100] Оптимизация trcmove
16.05.2017    Вахрушев М.А.     [oaiir-opt-121] Оптимизация селекта, попадающего в топ на экземпляре
04.08.2017    ubrr korolkov     #43987       [IM1305344-001] Картотека
17.04.2018    Киселев А.А.      17-1180      АБС: Исключение инкассовых из автоматической обработки картотек
07.05.2019    Пинаев Д.Е.       [19-59060.2] АБС: Изменение банковских счетов ТОФК (1часть)
09.01.2019    Пинаев Д.Е.       [19-64691]   Автоматическая обработка картотек
10.03.2019    Пинаев Д.Е.       [19-64691]   Автоматическая обработка картотек-оптимизация старого алгоритма
18.11.2020    Зеленко С.А.      [20-82101.1]  АБС: Изменение счетов ТОФК с 01.01.2021
23.12.2020    Пинаев Д.Е.       [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дняRM и других системах при закрытии дня. Анализ оптимизации процесса
14.01.2020    Пинаев Д.Е.       [IM2545087-001] Добавлена балансозависимость доработки. Замедление операций на SAP CRM и других системах при закрытии дняRM и других системах при закрытии дня. Анализ оптимизации процесса
14.01.2021    Пинаев Д.Е.       [IM2685764-001] Перенос документов картотеки
01.02.2021    Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
*/


--===================================================================
-- Автоматическая обработка документов картотек
-- Фактически - "массовая обработка", а именно - перенос и списание.
-- Плюс добавлены процедуры относящиеся к формам, которые заказчик потребовал
-- попутно поправить во время разработки.
--===================================================================

/*
Замечание по поводу использования вспомогательных таблиц в пакете.

  ubrr_trc_report - временная таблица, хранит данные для отчетов,
  которые отображаются сразу же после выполнения операции.
  Поле part позволяет в одной сессии собирать данные для разных отчетов

part = 1 - данные для отчета по переносу К1->К2
part = 2 - данные для отчета по переносу К2->К1
part = 3 - данные для отчета по списанию с К2
part = 4 - данные для отчета о списании с Картотеки 2 инкассовых поручений
  по Постановлениям, Исполнительным листам. -- сейчас не используется!

part = 5 - данные для отчета, вызываемого при нажатии кнопки "Выгрузка"
  (так как на клиенте запрос для отчета выполнить не удается,
   из-за того что плохо поддерживается работа с подзапросами,
   приходится предварительно заполнять временную таблицу



part = 11 - перечень счетов, содержащих плановые списания
part = 12 - не указана очередность овердрафтных сумм
part = 13 - овердрафтные суммы > 0
part = 14 - статус счета не равен 'О' или 'Ч'
part = 15 - счета имеют документы на К1 с меньшей очередностью чем документы на К2
part = 16 - отчет списаний по корпоративным счетам (кат/гр = 333/2 или 333/3)
          заполняется в write_off_acc по информации, сохраненной в part = 3
part = 17 - банкроты
part = 18 - овердрафтные договора

part = 991 - информация об ошибках для массовых операций (и для переносов, и для списаний)

part = 1001 - документы на бумажном носителе - из формы ubrr_report_period_otd
*/

  g_dummy_s varchar2(4000);       -- переменная - заглушка для строк
  g_dummy_d date;                 -- переменная - заглушка для дат
--  g_err_msg_size number := 4000;  -- максимальный размер сообщения об ошибке

  c_line ubrr_data.ubrr_trc_report.line%type := 0; -- номер строки
  g_need_mail number := 0;        -- признак возможности информирования по  e-mail

  -- переменные для работы с сообщением для e-mail
  g_email_msg_length_max     number := 2000;  -- максимальная длина сообщения
  g_email_msg_length_current number := 0;     -- текущая длина сообщени\
  g_email_msg varchar2(2000) := null;         -- текущее сообщения


  -- признаки необходимости ожидания установки блокировки
  -- (если false -  не ждать, то есть, если не получилось сразу, просто сообщать
  -- о том, что ресурс занят)
--  g_need_wait_lock_acrtable boolean := false;
--  g_need_wait_lock_acc boolean := false;

  g_need_wait_lock_acrtable boolean := false; --
  g_need_wait_lock_acc boolean := false; -- 30358/#405

-- очистка переменных для email-информирования
procedure email_msg#clear
is
begin
  g_email_msg_length_current := 0;
  g_email_msg := null;
end;

-- добавление текста к email-сообщению
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

-- отправка email  (запись в ABRR_MAIL)
procedure email_msg#send(
  p_subject varchar2,
  p_type number default 0
)
is
begin
  -- Для УБРиР нет адресов типа 0 - "Информирование сотрудников УОР".
  -- Все сообщения типа 0 лолжны отправляться на адрес пользователя.
  declare
    l_idsmr smr.idsmr%type := SYS_CONTEXT ('B21', 'IDSmr');
  begin
    if l_idsmr <> 16 and p_type = 0 then
      UBRR_VER4.ubrr_send.send_mail(
        ubrr_xxi5.ubrr_check_dpdoc.GetEmailByLogin(user),  p_subject, g_email_msg);
      return; -- все что нужно - сделано, выходим
    end if;
  end;

  -- если дошли досюда - берем адреса из ubrr_data.v_ubrr_email_writeoff
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

-- обработка реестра и отправка по email
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

  -- захожу в цикл - если есть, что послать
  if cr_info%found then
    email_msg#clear;
    if not email_msg#append(p_title || chr(10)) then -- такого не должно быть
      raise e_set_error;
    end if;

    while cr_info%found loop
      -- если нельзя ничего добавить - отправляем письмо и начинаем новое
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

    -- отправляем то, что еще не отправили

    email_msg#send(p_subject);
    email_msg#clear;
  end if;

  close cr_info;
exception
  when e_set_error then
    if cr_info%isopen then close cr_info; end if;
    raise_application_error(-20000,'Ошибка в ubrr_trc_auto.send_reest_part. p_part = '||p_part);
  when others then
    if cr_info%isopen then close cr_info; end if;
    raise_application_error(-20000,dbms_utility.format_error_stack
      || dbms_utility.format_error_backtrace);
end;


/*
         1         2         3         4         5         6         7         8
123456789012345678901234567890123456789012345678901234567890123456789012345678901234
Документ  Дата рег-ции      № док-та        Счет дебета           Сумма по дебету
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
      lpad(value5,5)||'    документов '||lpad(to_char(count(1)), 6) || '    сумма ' ||
      to_char(sum(to_number(value4,'FM9999999999990.99')),'9999999999990.99') info
    from ubrr_data.ubrr_trc_report
    where part = 16
    group by value5
    order by value5
    ;
  ln_info2 cr_info2%rowtype;

  l_title varchar2(256) := 'Документ  Дата рег-ции      № док-та        Счет дебета           Сумма по дебету';
  l_subject varchar2(256) := 'Списание по КРС';
begin
  open cr_info; fetch cr_info into ln_info;

  -- захожу в цикл - если есть, что послать
  if cr_info%found then
    email_msg#clear;
    if not email_msg#append(l_title || chr(10)) then -- такого не должно быть
      raise e_set_error;
    end if;

    while cr_info%found loop
      -- если нельзя ничего добавить - отправляем письмо и начинаем новое
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

    -- Добавляем строки с итогами.
    if not email_msg#append(chr(10)|| 'в том числе по валютам' || chr(10)) then
      email_msg#send(l_subject, 1);
      email_msg#clear;
      if not email_msg#append(chr(10)|| 'в том числе по валютам' || chr(10)) then
        raise e_set_error;
      end if;
    end if;

    open cr_info2; fetch cr_info2 into ln_info2;
    while cr_info2%found loop
      -- если нельзя ничего добавить - отправляем письмо и начинаем новое
      if not email_msg#append(ln_info2.info || chr(10)) then
        email_msg#send(l_subject, 1);
        email_msg#clear;
        -- подзаголовок второй раз не отправляем
        --
        if not email_msg#append(ln_info2.info || chr(10)) then
          raise e_set_error;
        end if;
      end if;
      fetch cr_info2 into ln_info2;
    end loop;

    -- отправляем то, что еще не отправили
    email_msg#send(l_subject, 1);
    email_msg#clear;
  end if;

  if cr_info%isopen  then close cr_info;  end if;
  if cr_info2%isopen then close cr_info2; end if;

exception
  when e_set_error then
    if cr_info%isopen  then close cr_info;  end if;
    if cr_info2%isopen then close cr_info2; end if;
    raise_application_error(-20000,'Ошибка в ubrr_trc_auto.send_reest_part16');
  when others then
    if cr_info%isopen  then close cr_info;  end if;
    if cr_info2%isopen then close cr_info2; end if;
    raise_application_error(-20000,dbms_utility.format_error_stack
      || dbms_utility.format_error_backtrace);
end;

-- обработка реестров и отправка по email
procedure send_reestr
is
  pragma autonomous_transaction;

  l_subject varchar2(50) := 'Автоматическое списание. Для ручного разбора.';
begin
  if g_need_mail = 1 then
    send_reestr_part(
      p_subject => l_subject,
      p_title  => 'По следующим счетам имеются плановые списания:',
      p_part   => 11
    );
    send_reestr_part(
      p_subject => l_subject,
      p_title  => 'По следующим счетам имеются овердрафтные суммы с неуказанной очередностью:',
      p_part   => 12
    );
    send_reestr_part(
      p_subject => l_subject,
      p_title  => 'По следующим счетам имеются овердрафтные суммы > 0 :',
      p_part   => 13
    );
    send_reestr_part(
      p_subject => l_subject,
      p_title  => 'Cледующие счета имеют статус отличный от "О" или "Ч":',
      p_part   => 14
    );
    send_reestr_part(
      p_subject => l_subject,
      p_title  => 'Cледующие счета имеют документы на К1 с меньшей очередностью чем документы на К2:',
      p_part   => 15
    );
    send_reestr_part16;

    send_reestr_part(
      p_subject => l_subject,
      p_title  => 'Cледующие клиенты являются банкротами. Необходим ручной разбор документов.',
      p_part   => 17
    );

    send_reestr_part(
      p_subject => l_subject,
      p_title  => 'По следующим счетам имеются овердрафтные договора:',
      p_part   => 18
    );

  -- p_part

  end if;
  delete from  ubrr_data.ubrr_trc_report where part in (11, 12, 13, 14, 15, 16);
  commit;
end;

-->> 09.01.2019 Пинаев Д.Е. [19-64691] Автоматическая обработка картотек
procedure add_changes_recv(op_itrcnum  in trc.ITRCNUM%TYPE,
                           op_itrcanum in trc.ITRCANUM%TYPE,
                           op_itrnnum  in trn.ITRNNUM%TYPE,
                           op_itrnanum in trn.ITRNANUM%TYPE) is
begin
  if ubrr_xxi5.ubrr_accmayak_createtrn.check_changes_recv(op_itrcnum, op_itrcanum) then
      insert into ubrr_data.ubrr_trn_changed_rec
      values  (op_itrnnum, op_itrnanum);
  end if;

  -->>01.02.2021    Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
  IF NVL(PREF.Get_Preference ('CARD2.WRITEOFF_EDIT'), '0') = '1'  THEN
    insert into ubrr_data.ubrr_trn_changed_rec(itrnnum,
                                               itrnanum
                                               )
                                       values (op_itrnnum,
                                               op_itrnanum
                                               );
  END IF;
  --<<01.02.2021    Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

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
       cv_ret:='ИР';
    end if;
  elsif ivChRec <> 0 then
     cv_ret:= 'ИРЧИ';
  else
     cv_ret:= 'ЧИ';
  end if;

  return cv_ret;

end;

--<< 09.01.2019 Пинаев Д.Е. [19-64691] Автоматическая обработка картотек

-- добавление информации  из двух значений для реестра
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
                         op_otd acc.IACCOTD%type default null) -->><<-- 09.01.2019    Пинаев Д.Е.       [19-64691]   Автоматическая обработка картотек
is
  pragma autonomous_transaction;
begin

  insert into ubrr_data.ubrr_trc_report(line, part, value1,
  value2) -->><<-- 09.01.2019    Пинаев Д.Е.       [19-64691]   Автоматическая обработка картотек
  values(c_line, 991, replace(substr(p_err, 1, 1024), chr(10),' '),
  to_char(op_otd) ); -->><<-- 09.01.2019    Пинаев Д.Е.       [19-64691]   Автоматическая обработка картотек
  commit;
  c_line := c_line + 1;
end;

-- добавление информации для "реестра о перемещении" во временную таблицу
-- нужно для отчета, показываемом на клиенте после переносов документов
procedure add_move_info(
  p_part number,
  p_num number,
  p_anum number,
  cp_stat varchar2 default null -->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
)
is
begin
  insert into ubrr_data.ubrr_trc_report(line, part,
    value1, value2, value3, value4, value5, value6, value7,
    value8, value9, value10, value11, value12, value13, value14, value15,
    value18 -->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
    )
  (
    select
      c_line, p_part,
      iTrcType, -- БО1
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
      cp_stat -->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
    from trc t
    join acc a on t.cTrcCur = a.cAccCur and t.cTrcAccD = a.cAccAcc and a.cAccPrizn <> 'З'
    where iTrcNum = p_num and iTrcANum = p_anum
  );
  c_line := c_line + 1;
end;

-- добавление информации для "реестра о списании" во временную таблицу
-- нужно для отчета, показываемом на клиенте после массовыз списаний;
-- также эта информация может использована для заполнения part = 16
procedure add_writeoff_info(
  p_num number,
  p_anum number,
  p_payment number,
  cp_stat varchar2 default null -->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
)
is
begin
--dbms_output.put_line('add_writeoff_info'|| p_num ||' '|| p_anum  ||' '||p_payment);
  insert into ubrr_data.ubrr_trc_report(line, part,
    value1, value2, value3, value4, value5, value6, value7,
    value8, value9, value10, value11, value12, value13, value14,
    value15, value16, value17,
    value18 -->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
    )
  (
    select
      c_line, 3,
      iTrcType, -- БО1
      ---> изменение от 06.10.2016. Перенести в версию для УБРиР!!!
      (
        select max(itrnsop)
        from trn
        where itrnnumanc = itrcnum and itrnanumanc = itrcanum and ctrnaccd = ctrcaccd  and rownum = 1
      ) BO2,
      ---< изменение от 06.10.2016. Перенести в версию для УБРиР!!!

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
      cp_stat -->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
    from trc t
    join acc a on t.cTrcCur = a.cAccCur and t.cTrcAccD = a.cAccAcc and a.cAccPrizn <> 'З'
    where iTrcNum = p_num and iTrcANum = p_anum
  );
  c_line := c_line + 1;
--dbms_output.put_line('sql%rowcount = '||sql%rowcount);
end;


-- заполнение временной таблицы данными для отчета при нажатии кнопки "Выгрузка"
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
        and ctrcstatenc != '0' -- Неотконтролирован
        --<< 04.08.2017 ubrr korolkov #43987
        and a.iacccus = (select iacccus from acc where caccacc = ctrnaccd and cacccur = ctrncur)
        and t.ctrcaccd = a.caccacc and t.ctrccur = a.cacccur
      ) mTrcLeft1,

      (
      select trim(to_char(sum(mTrcLeft),'9999999999990.99'))
      from trc t
      where cTrcState = '2'
        -->> 04.08.2017 ubrr korolkov #43987
        and ctrcstatenc != '0' -- Неотконтролирован
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
        -- следующее нужно - почему?
        and (upper(cAosComment) like '%РЕШ%№%ОТ%' or upper(cAosComment) like '%РЕШ%N%ОТ%')
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
      ) aos_о,

      case when exists (
      select null
      from ach h
      where cachacc = a.caccacc and cachcur = a.cacccur and h.idsmr = a.idsmr
        and
            -- наличие приостановления ФНС
          ( regexp_like (upper(cachbase),'(.*(БЛ|РЕ(Ш|Щ)|Р\.).*\d{1,}.*|(^\d{1,}.*)(|((№|N).*\d{1,}))).*(ОТ|JN)\s*\d{2}(,|\.|\/|\\)\d{2}(,|\.|\/|\\)\d.*')
            or regexp_like (upper(cachbase),'(ПРЕДП(\.|\s)|ПРЕДПИСАНИЕ).*ГНИ')
            or upper(cachbase) like '%ФНС%'
            or upper(cachbase) like '% ГНИ%'
            or upper(cachbase) like 'ГНИ ПО%'
            or upper(cachbase) like '%ИМНС%'
          )
        and not upper(cachbase) like '%СВК%' and not upper(cachbase) like '%CDR%'
        and not upper(cachbase) like '%УФМ%'
        and not regexp_like (upper(cachbase),'\d{4}-\d{2}\/\d{6}')
        -- отрицание условия отмены ФНС
        and not regexp_like (upper(cachbase),'(ОТМ.*(|(№|N)).*\d{1,}.*(ОТ|JN))|((О|J)ТМЕНА)')
      )
      then 'Имеется' end   decision
    from ubrr_data.ubrr_trc_writeoff u
    join mrk m on u.rowid = m.rmrkrowid and m.imrkmarkerid = p_marker_id
    join acc a on u.cacc = a.caccacc and a.caccprizn <> 'З'
  );
--  c_line := c_line + 1;
--dbms_output.put_line('sql%rowcount = '||sql%rowcount);
end;



-- переделка ACCESS_2.Is_Account_Enabled
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
          select 'x' from  acc_ubs2 -- синтетические счета пользователя
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
  p_single in out nocopy varchar2,  -- строка с одним сообщением об ошибке
  p_total  in out nocopy varchar2   -- строка с накопленными сообщениями об ошибках
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


-- 1->2 Перенос документа на Картотеку 2
procedure move_doc_to_card2(
  p_num  xxi."trc".iTrcNum%type,
  p_anum xxi."trc".iTrcANum%type,
  p_err out varchar2, -- информация об ошибке (или null, если нет ошибки)
  p_date_oper date,
  cp_stat in out varchar2-->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
)
is
--  l_current_date date := trunc(sysdate);

-- курсор блокирующий документ по заданной паре num, anum поле mTrcLeft
-- вероятно имеет смысл снаружи процедуры вызывать
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

  -- предположительно тут производится блокировка - нужно проверить
  open cTRC;
  fetch cTRC into rTRC;
  close cTRC;

  -- проверили статус счета
  l_acc_status := IDOC_UTIL.Check_Account (g_dummy_s, rTRC.cTRCAccD, rTRC.ctrcCUR, rTRC.iTrcPriority);
  IF UPPER (l_acc_status ) <> 'ACC_OPEN' THEN
  p_err := 'Счет '||rTRC.cTRCAccD||' не является открытым.';
    raise e_Set_Error;
  END IF;

  --  обновление trc.cstatenc идет через обновление истории и триггер

  declare
    l_cnt number;
  begin
    select count(1) into l_cnt
    from xxi.trc_stat
    where inum = p_num and ianum = p_anum and daction = p_date_oper and rownum = 1;

    if l_cnt = 0 then
      insert into xxi.trc_stat(inum, ianum, daction, cstatenc, cactdesc)
      values (p_num, p_anum, p_date_oper, 1,'Автоматический перенос');
    else
      update xxi.trc_stat set
        cstatenc = 1, cactdesc = 'Автоматический перенос'
      where inum = p_num and ianum = p_anum and daction = p_date_oper;
    end if;
  exception when others then
    p_err := 'Счет '||rTRC.cTRCAccD||'. '|| dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || ' ';
    raise e_Set_Error;
  end;

  iResult := CARD.Accept (
     vcERROR_MSG   => p_err,
     iTRC_NUM      => p_num,
     iTRC_ANUM     => p_anum,
     dTODAY        => p_date_oper,
     mPARTLY_SUM   => rTrc.mTrcLeft,
     iWriteOff_Num => nvl(rTrc.iTrcWriteOff,0) +1, -- тут уже увеличенный номер
     vcACTION      => '2FILE2' -- это из формы
   ); -- 0 - успешно, при это в p_err может выводиться информация даже при отсутствии ошибки

    -->> 09.01.2019 Пинаев Д.Е. [19-64691] Автоматическая обработка картотек
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
    --<< 09.01.2019 Пинаев Д.Е. [19-64691] Автоматическая обработка картотек


  if iResult <> 0 then raise e_Set_Error; end if;
  if p_err is not null then p_err := null; end if; -- в других пакетах другие конвенции

  -- работа со связными документами
  declare
    is_from_CD number :=-1;
    v_cardmsg  varchar2(250);
  begin
    -- у таблицы уникальность номера документа ни триггерами ни проверяется ни констрейнтами..
    -- он действительно уникальный?
    -- ищем ИД действия
    begin
      select nvl(i_event_type,-1) into is_from_cd
      from ubrr_dm_cd_card_link a
      where nl_trcnum  = p_num and nl_trcanum = p_anum;
    exception when no_data_found then
      is_from_cd := 0;
    end;

    --Добавляем изменение статуса у связных документов для картотеки 1
    -- TODO разобраться, с чего бы nbalance.get_last_num непустым будет ?!
    if is_from_cd > 0  then
      update ubrr_dm_cd_card_link a  set
        msum_unpayed = greatest (msum_unpayed - rTrc.mTrcLeft, 0),
        c_writeoff_trnnums = to_char (nbalance.get_last_num ()) || '/0;' || c_writeoff_trnnums
      where nl_trcnum = p_num and nl_trcanum = p_anum;

      -- Сообщение про связанные документы - содрано с клиента
      for r_WOff_msg in (
        select trc.itrcnum
        from
          ubrr_data.ubrr_dm_cd_card_link a,
          xxi."trc" trc,
          ubrr_data.ubrr_dm_VW_cd_card_link v -- документ поставлен в нескольких картотек
        where a.nl_trcnum =trc.itrcnum
          and a.nl_trcanum=trc.itrcanum
          and trc.ITRCDOCNUM = v.itrcdocnum
          and v.nl_trcnum = p_num
          and v.nl_trcanum = p_anum
          and a.nl_trcnum <> p_num
        )
      loop
        v_cardmsg := 'С картотеки списан документ № '||rTRC.iTRCDocNum||
          ' от '||to_char(rTRC.dTrcCreate,'dd.mm.rrrr')||' по счету '||rTRC.cTrcAccD||
          '. На картотеке существуют документы, выставленные к нескольким расчетным счетам';
          ubrr_send.send_mail('OPOUL@UBRR.RU', 'Документы Картотеки для отзыва', v_cardmsg);
          exit;
        end loop;
      end if;
    exception when others then
      UBRR_XCARD.Set_Card_Process_Mark(0); -- так на клиенте
      raise;
    end;
-- END что-то по связным документам

  -- Формируем уведомление о списании, если это И-К2
  if (rTRC.iTRCType = 25) and (rTRC.cTRCAccC like '111810%') then
    begin
      Ubrr_katpm_utils.SendMessage('CARD_RETIREMENT',
        '(' || to_char(sysdate,'DD.MM.YYYY') || ') Произведено списание с Картотеки 2 со счета ' || rTRC.ctrcaccd ||
        ': ' ||rTRC.ctrcclient_name || ' на сумму '|| to_char(rTrc.mTrcLeft));
    exception
    when others then
      CARD.Set_TrcMessage (p_num, p_anum, 'Ошибка при вызове Ubrr_katpm_utils.SendMessage: '||sqlerrm);
    end;
  end if;

--    DBMS_SQL_ADD.Commit (); -- а вот тут я бы подумал! - ВЕ

  /*
  -- Подписание документов ЭЦП, не требовалось техзаданием, но было в клиенте.
  -- При необходимости добавить параметр "Выполнять подписание документа ЭЦП"
  -- и сделать доработки по аналогии с реализованными в клиенте.
    Begin
      select itrnnum, itrnanum into litrnnum, litrnanum
      from trn
      where itrnnum = (
        select max (itrnnum) from trn where itrnnumanc = p_num and itrnanumanc = p_anum
        )
        and itrnanum = 0;
      Do_Sign(litrnnum, litrnanum); -- процедура из document.fmb
    Exception
      When Others Then Null;
    End;
  */
exception
--    WHEN e_Write_Off THEN      DBMS_SQL_ADD.Rollback;
  WHEN e_Set_Error THEN
    rollback to very_beginning;
    CARD.Set_TrcMessage (p_num, p_anum, p_err);
    UBRR_CD_DEBUG_PKG.write_error('Автоматическое списание','rTrcNumANum.Num = '||p_num||chr(10)||
      'rTrcNumANum.ANum' ||p_anum||chr(10)||
      'vcERROR_MSG = '||p_err);
    if p_err is null then p_err := ' ';   end if;
  WHEN resource_busy then
    rollback to very_beginning;
    p_err := 'Документ ('||p_num||' '||p_anum||') обрабатывается другим пользователем. Попробуйте позднее.' || p_err;
  WHEN OTHERS THEN
    rollback to very_beginning;
    UBRR_CD_DEBUG_PKG.write_error('Автоматическое списание','rTrcNumANum.Num = '||p_num||chr(10)||
      'rTrcNumANum.ANum' ||p_anum||chr(10)||SQLERRM );
    p_err := SQLERRM;
end;


-- 2->1 Перенос документа на Картотеку 1
procedure move_doc_to_card1(
  p_num  xxi."trc".iTrcNum%type,
  p_anum xxi."trc".iTrcANum%type,
  p_err out varchar2, -- информация об ошибке (или null, если нет ошибки)
  p_date_oper date,
  cp_stat in out varchar2 -->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
)
is
  l_result number;
begin


  -- Установили статус "Действия приостановлено, списание запрещено"
  --  update xxi."trc" set cTrcStateNC = 2 where iTrcNum = p_num and iTrcANum = p_anum;

  --  обновление trc.cstatenc идет через обновление истории и триггер
  declare
    l_cnt number;
  begin
    select count(1) into l_cnt
    from xxi.trc_stat
    where inum = p_num and ianum = p_anum and daction = p_date_oper and rownum = 1;

    if l_cnt = 0 then
      insert into xxi.trc_stat(inum, ianum, daction, cstatenc, cactdesc)
      values (p_num, p_anum, p_date_oper, 2,'Автоматический перенос');
    else
      update xxi.trc_stat set
        cstatenc = 2, cactdesc = 'Автоматический перенос'
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
    dMove  => p_date_oper --UTIL.Current_Date -- так на форме
  );

    -->> 09.01.2019 Пинаев Д.Е. [19-64691] Автоматическая обработка картотек
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
    --<< 09.01.2019 Пинаев Д.Е. [19-64691] Автоматическая обработка картотек


-- dbms_output.put_line('CARD.MoveToCard1('||p_num||','||p_anum||') l_result = '||l_result||'p_err='|| p_err);

  if l_result = 0 then
    if p_err is not null then p_err := null; end if;
  else
    if p_err is null then
      p_err := 'Не удалось перенeсти документ на картотеку 1';
    end if;
  end if;

end;


-- 1->2 Перенос всех документов счета с Картотеки 1 на Картотеку 2
procedure move_acc_to_card2(
  p_acc  xxi."acc".cAccAcc%type,
  p_acc_cur xxi."acc".cAccCur%type,
  p_cus xxi."acc".iAccCus%type,
  p_err out varchar2, -- информация об ошибке (или null, если нет ошибки)
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
Было: одним из условий для выбора счетов  для списка для переноса "К1->K2" было наличие документов на Картотеке 1.
Стало: для выбора счетов проверяется наличие документов на картотеке 1, удовлетворяющих дополнительному условию.
  Дополнительное условие: для документа на картотеке 1 определяется номер клиента для счета плательщика документа.
  Также для этого документа выбираются относящиеся к нему проводки, и среди проводок со ДТ, удовлетворяющих маске
  90901%, ищется последняя проводка. Для этой проводки, находится дебитовый счет, для счета - номер клиента.
  Если этот номер клиента на равен ранее найденному номеру клиента для счета плательщика документа,
  то условие считается невыполненным.
Таким образом теперь счета, у которых на Картотеке 1 только документы ждущие акцепта, выбираться в список не должны.
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
      and ctrcstatenc != '0' -- Неотконтролирован
      --<< 04.08.2017 ubrr korolkov #43987
      and cTrcAccD = p_acc
      and cTrcCur = p_acc_cur
      and p_cus = (select iacccus from acc where caccacc = ctrnaccd and cacccur = ctrncur)
  ;

  ln_trc cr_trc%rowtype;
  l_err varchar2(4000);
  cv_stat varchar2(4);-->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
begin
  open cr_trc; fetch cr_trc into ln_trc;
  while cr_trc%found loop
    move_doc_to_card2(ln_trc.iTrcNum, ln_trc.iTrcANum, l_err, p_date_oper,
                      cv_stat -->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
    );
    if l_err is null then
      add_move_info(1,ln_trc.iTrcNum, ln_trc.iTrcANum,
                    cv_stat-->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
                    );
    else
      l_err := 'Документ ('||ln_trc.iTrcNum||','||ln_trc.iTrcANum||'). ' || l_err;
      p_err := l_err;
      exit;
    end if;

    fetch cr_trc into ln_trc;
  end loop;
  close cr_trc;
  -- после переноса на Картотеку 2 необходимо делать попытку списания документов
  -- здесь будет вызов процедуры списания документов (ну или уровнем выше)
  -- либо - списание будет отдельным этапом
exception when others then
  if cr_trc%isopen then close cr_trc; end if;

  if p_err is null then
    p_err := dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || ' ';
  end if;
end;


-- для счета, переносим все документы с Картотеки 2, кроме  налоговых платежей, на Картотеку 1
procedure move_acc_to_card1(
  p_acc  xxi."acc".cAccAcc%type,
  p_acc_cur xxi."acc".cAccCur%type,
  p_err out varchar2, -- информация об ошибке (или null, если нет ошибки)
  p_date_oper date
)
is
  cursor cr_trc is
    select iTrcNum, iTrcANum
    from trc t
    join trc_attr_val on inum = iTrcNum and ianum = iTrcANum
      and id_attr = UBRR_XXI5.ubrr_ordered.ppo /*999000*/
      and value_num = 5 -- только 5-я очередь

    where cTrcState = '2'
      -->> 04.08.2017 ubrr korolkov #43987
      and ctrcstatenc != '0' -- Неотконтролирован
      --<< 04.08.2017 ubrr korolkov #43987
      and cTrcAccD = p_acc
      and cTrcCur = p_acc_cur
--      and iTrcPriority = 5 -- только 5-я очередь
      -- налоговые платежи не переносятся
      -- https://redmine.lan.ubrr.ru/issues/30358#note-207
      and substr(cTrcAccA,1,5) <> '40101'
      and not regexp_like(cTrcAccA,'^('||nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.CACCA_NAL'),'03100')||')')  --18.11.2020    Зеленко С.А.      [20-82101.1]  АБС: Изменение счетов ТОФК с 01.01.2021
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
  cv_stat varchar2(4);-->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
begin
--dbms_output.put_line('move_acc_to_card1');

  open cr_trc; fetch cr_trc into ln_trc;

  while cr_trc%found loop
    begin
      move_doc_to_card1(ln_trc.iTrcNum, ln_trc.iTrcANum, l_err, p_date_oper,
                        cv_stat-->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
                        );
      if l_err is null then
        add_move_info(2,ln_trc.iTrcNum, ln_trc.iTrcANum,
                      cv_stat-->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
        );
      else
        l_err := 'Документ ('||ln_trc.iTrcNum||','||ln_trc.iTrcANum||'). ' || l_err;
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
    join xxi."acc" a on n.caccount = a.caccacc and a.caccprizn <> 'З'
    where id_base = p_id_base;

  ln_acc cr_acc%rowtype;

  l_err varchar2(4000);
begin
  -- savepoint very_beginning;

  begin
    select file_type into l_file_type from xxi."ni_bases" where id_base = p_id_base;
  exception when no_data_found then
    p_err := 'В xxi."ni_bases" отсутствует запись с id_base = ' || p_id_base;
    return;
  end;
--dbms_output.put_line('l_file_type =' || l_file_type);

  if l_file_type = 'P' then -- обработка решения о приостановлении
--dbms_output.put_line('l_file_type = P');

    open cr_acc; fetch cr_acc into ln_acc;
    begin
      while cr_acc%found loop -- цикл по всем счетам файла
        move_acc_to_card1(ln_acc.caccacc, ln_acc.cacccur, l_err);
        add_error(l_err, p_err);
        -- непонятно, что делать с сообщениями об ошибках
        fetch cr_acc into ln_acc;
      end loop;
      close cr_acc;
    exception when others then
      if cr_acc%isopen then close cr_acc; end if;
    end;

  elsif l_file_type = 'O' then -- обработка решения об отмене приостановления
--dbms_output.put_line('l_file_type = O');
    open cr_acc; fetch cr_acc into ln_acc;
    begin
      while cr_acc%found loop -- цикл по всем счетам файла
        if get_acc_stopping_count(ln_acc.caccacc) = 0 then -- если не осталось актуальных приостановлений у счета
          savepoint before_moving_to_card2;
          move_acc_to_card2(ln_acc.caccacc, ln_acc.cacccur, l_err); -- то переносим все документы счета из картотеки 1 в картотеку 2
          if l_err is not null then rollback to before_moving_to_card2; end if;
          add_error(l_err, p_err);

          -- пока не встретились ощибки, запоминаем счета в "предварительном" кэше
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
    -- переносим из предварительного кэша в основной
    declare
      l_state number; -- 1 - нужна обработка, 0 - не нужна, -1 - очередь пуста
      l_acc xxi."acc".caccacc%type;
    begin
      -- переносим из предварительного кэша в основной (либо просто очищаем предварительный)
      loop
        acc_cache_get(0, l_acc, l_state);
        exit when l_state = -1;
        if l_state = 1 then
          if p_err is null then  acc_cache_add(1, l_acc); end if;
          acc_cache_del(0, l_acc);
        end if;
      end loop;
    end;

  else -- это ошибка
    p_err := 'Ошибка. Попытка обработки загрузки с типом, не поддерживаемым данной процедурой.';
    null;
  end if;
end;
*/
-- Перенос документов между картотеками 1 и 2 для счетов, выбранных на клиенте
procedure move_selected_to_card(
  p_marker_id in number,
  p_date_oper date
)
is
  -->>-- 23.12.2020 Пинаев Д.Е. [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дня. Анализ оптимизации процесса
  resource_busy exception;
  pragma exception_init (resource_busy,-54);
  --<<-- 23.12.2020 Пинаев Д.Е. [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дня. Анализ оптимизации процесса

  cursor cr_acc is
    select a.caccacc, a.cacccur, u.icus, substr(u.cdirection, 1, 1) cdirection, m.rmrkrowid
    ,a.IACCOTD -->><<-- 09.01.2019    Пинаев Д.Е.       [19-64691]   Автоматическая обработка картотек
    from ubrr_data.ubrr_trc_move u
    join mrk m on u.rowid = m.rmrkrowid and m.imrkmarkerid = p_marker_id
    join acc a on u.cacc = a.caccacc and a.caccprizn <> 'З';

  ln_acc cr_acc%rowtype;

  l_err varchar2(4000);

  l_idsmr xxi."trn".idsmr%type := SYS_CONTEXT ('B21', 'IDSmr'); -->><<-- 14.01.2020 Пинаев Д.Е. [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дня
begin
  g_need_mail := 1;


  -- очищаем таблицу для реестра результатов операций
  delete from ubrr_data.ubrr_trc_report;  c_line := 0;

  open cr_acc; fetch cr_acc into ln_acc;

  while cr_acc%found loop -- цикл по всем счетам файла
    -->>-- 23.12.2020 Пинаев Д.Е. [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дня. Анализ оптимизации процесса
    if pref.Get_Universal_Preference('AUTO_TRC_STOP_PROCESS'|| '_' ||l_idsmr,'N') = 'Y' then -->><<-- 14.01.2020 Пинаев Д.Е. [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дня
        raise resource_busy;
    end if;
    --<<-- 23.12.2020 Пинаев Д.Е. [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дня. Анализ оптимизации процесса

    savepoint start_iteration;
    if ln_acc.cdirection = '2' then
      move_acc_to_card1(ln_acc.caccacc, ln_acc.cacccur, l_err, p_date_oper);
    elsif ln_acc.cdirection = '1' then
      move_acc_to_card2(ln_acc.caccacc, ln_acc.cacccur, ln_acc.icus, l_err, p_date_oper); -- то переносим все документы счета из картотеки 1 в картотеку 2
    else
      null;
    end if;
    if l_err is not null then
      l_err := 'Счет '||ln_acc.caccacc||'. '|| l_err;
      add_error_info(l_err
      ,ln_acc.IACCOTD ); -->><<-- 09.01.2019    Пинаев Д.Е.       [19-64691]   Автоматическая обработка картотек
      rollback to start_iteration;  -- по счету - либо все документы корректно обработались либо алгоритм нужно менять
    else
      -- удалим из временной таблицы счета, которые нормально обработались
      util.MRK_Delete(ln_acc.rmrkrowid, p_marker_id);
      delete from ubrr_data.ubrr_trc_move where cacc = ln_acc.caccacc;
    end if;

    fetch cr_acc into ln_acc;
  end loop;
  close cr_acc;


exception when others then
  add_error_info(dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || ' '
                 ,ln_acc.IACCOTD ); -->><<-- 09.01.2019    Пинаев Д.Е.       [19-64691]   Автоматическая обработка картотек
  if cr_acc%isopen then close cr_acc; end if;
  -->>-- 23.12.2020 Пинаев Д.Е. [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дня. Анализ оптимизации процесса
  if SQLCODE = -54 then
        raise resource_busy;
  end if;
  --<<-- 23.12.2020 Пинаев Д.Е. [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дня. Анализ оптимизации процесса
end;



/*
Вынес способ определения остатка в отдельную функцию.
Сейчас учитывается плановый остаток, как критерий возможности списания.
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
  l_sum := ACC_INFO.GetDarkRest(p_acc, p_cur, l_stype, p_date);  -- плановый остаток на вечер p_date

  select nvl(sum(mtrnsum),0) into l_unconfirmed_income
  from trn
  where dtrntran is null and ctrnaccc = p_acc and ctrncur = p_cur;

  return l_sum - l_unconfirmed_income;

--  return ACC_INFO.GetDarkRest(p_acc, p_cur, l_stype, sysdate);  -- плановый остаток на вечер p_date
end;

-- Код не "причесывал" просто сделал минимальные переделки, чтобы можно было списать документ
-- 1-я картотека  2TRN
FUNCTION write_off_doc1(
  p_num  xxi."trc".iTrcNum%type,
  p_anum xxi."trc".iTrcANum%type,
  p_err out varchar2, -- информация об ошибке (или null, если нет ошибки)
  p_date_oper date,
  p_sum number, -- допустимая к списанию сумма
  cp_stat in out varchar2-->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
)
RETURN NUMBER
IS
    --<<UBRR 26.08.2013 Портнягин Д.Ю. Оптимизация работы картотеки
    vcERROR_MSG     varchar2(4000);

    vcACC_STATUS   VARCHAR2 (256);

--    mAccountPP     TRC.mtrcSUM%TYPE;
--    mSUM           TRC.mtrcSUM%TYPE; -- Сумма остатка
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
        DTRCDOC, ITrcNum, ITrcANum, -- UBRR Новолодский А. Ю. 10.01.2014 12-2288 изменение очередности списания денежных средств, ст 855 ГК (Учет очередности по счетам с приостановлениями)
        cTrcOwnA, cTrcPurp, cTrcMfoA, cTrcMfoO,
        CTRCCORACCA,  --18.11.2020  Зеленко С.А.    [20-82101.1]  АБС: Изменение счетов ТОФК с 01.01.2021
        TRC.CTRCBNAMEA  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
      FROM TRC
      WHERE itrcNUM = p_num AND itrcANUM = p_anum
      FOR UPDATE OF mTrcLeft NOWAIT -->><<UBRR 26.08.2013 Портнягин Д.Ю. Добавил NOWAIT. Оптимизация работы картотеки
                  ;

    rTrc             cTrc%ROWTYPE;
    iResult          INTEGER;
    vcDummy          VARCHAR2 (250);
    nCur_Rate        NUMBER;

    e_RecAccIsClosed  EXCEPTION;     -->><<-- 07.05.2019  Пинаев Д.Е.  [19-59060.2] АБС: Изменение банковских счетов ТОФК (1часть)
    e_Write_Off      EXCEPTION;
    e_Accept         EXCEPTION;
    eUser            EXCEPTION;
--

    is_from_CD number :=-1;
    v_cardmsg  varchar2(250);

  e_Set_Error  EXCEPTION;
  resource_busy exception; -->><< UBRR 26.08.2013 Портнягин Д.Ю. Оптимизация работы картотеки
  pragma exception_init (resource_busy,-54);

  l_result_kind number;
  l_sum number;
  l_dummy varchar2(4000);

  function get_doc_info return varchar2 is
  begin
    return ' №' || rTrc.iTrcDocNum || ' от ' || to_char (rTrc.dTrcCreate,'dd.mm.rrrr')||' ';
  end;
BEGIN

  savepoint very_beginning;

  --  обновление trc.cstatenc идет через обновление истории и триггер
  declare
    l_cnt number;
  begin
    select count(1) into l_cnt
    from xxi.trc_stat
    where inum = p_num and ianum = p_anum and daction = p_date_oper and rownum = 1;

    if l_cnt = 0 then
      insert into xxi.trc_stat(inum, ianum, daction, cstatenc, cactdesc)
      values (p_num, p_anum, p_date_oper, 1,'Автоматическое списание');
    else
      update xxi.trc_stat set
        cstatenc = 1, cactdesc = 'Автоматическое списание'
      where inum = p_num and ianum = p_anum and daction = p_date_oper;
    end if;
  exception when others then
    p_err := 'Счет '||rTRC.cTRCAccD||'. '|| dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || ' ';
    raise e_Set_Error;
  end;



  OPEN cTRC;
  FETCH cTRC INTO rTRC;
  CLOSE cTRC;

  ACCEPT_FLAG :=0;--<<Измоденов И.А. 2010.06.11 Добавляем изменение статуса у связных документов для картотеки 1

  mReal_Sum     := rTRC.mTrcLeft;
  nWriteOff_Num := NVL (rTrc.iTrcWriteOff, 0) + 1;
  l_sum := p_sum;

--  IF vcAction = 'ACCEPT' THEN -- TRUE

--  cPlaceDoc := '2TRN';

  vcACC_STATUS := IDOC_UTIL.Check_Account (vcDUMMY, rTRC.cTRCAccD, rTRC.ctrcCUR, rTRC.iTrcPriority);
  IF UPPER (vcACC_STATUS ) NOT in ('ACC_OPEN', 'ACC_PARTLY_BLOCKED') THEN
    p_err := 'Счет '||rTRC.cTRCAccD||' не является открытым либо частично блокированным.';
    RAISE e_Write_Off; -- на клиенте - запрос на продолжение операции
  END IF;

  -->> 07.05.2019 Пинаев Д.Е. [19-59060.2] АБС: Изменение банковских счетов ТОФК (1часть)
  declare
    l_acc ubrr_data.ubrr_sud_ft_accounts.account_new%type :=
       get_sud_ft_account(p_Mfoa=>rTrc.cTrcMfoA, p_cTrcAccA=>rTrc.cTrcAccA);
  begin
    if l_acc is not null then
      p_err := 'Счет '||rTRC.cTRCAccD||' Документ № '|| rTrc.Itrcdocnum ||' от '|| to_char(rTrc.Dtrcdoc, 'dd.mm.yyyy') ||'. '||
      'Счет получателя '|| rTrc.cTrcAccA ||' закрыт. ' ||
       case when is_acc(l_acc) then 'Новый счет ' || l_acc else l_acc end ;
      RAISE e_Write_Off;
    end if;
  end;
  --<< 07.05.2019 Пинаев Д.Е. [19-59060.2] АБС: Изменение банковских счетов ТОФК (1часть)

  -->>18.11.2020  Зеленко С.А.    [20-82101.1]  АБС: Изменение счетов ТОФК с 01.01.2021
  IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_auto_trc( par_itrcnum       => rTrc.Itrcnum,
                                                              par_itrcanum      => rTrc.Itrcanum,
                                                              par_itrctype      => rTrc.Itrctype,
                                                              par_ctrcaccd      => rTrc.Ctrcaccd,
                                                              par_ctrcmfoa      => rTrc.cTrcMfoA,
                                                              par_ctrccoracca   => rTrc.Ctrccoracca,
                                                              par_ctrcacca      => rTrc.cTrcAccA,
                                                              par_purp          => rTrc.cTrcPurp,
                                                              par_Bnamea        => rTrc.Ctrcbnamea,  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
                                                              p_err             => p_err) THEN

    RAISE e_Write_Off;
  END IF;
  --<<18.11.2020  Зеленко С.А.    [20-82101.1]  АБС: Изменение счетов ТОФК с 01.01.2021

  IF CARD.Check_Pres_On_Card (rTrc.cTrcAccD, rTRC.cTrcCur, vcDummy) THEN
    p_err := vcDummy;
    RAISE e_Write_Off; -- на клиенте - сообщение, что есть документ на К2 и предложение продолжить
  END IF;

--  mAccountPP := ACC_INFO.GetAccountPP (rTRC.cTRCAccD, rTRC.cTRCCur, dRegister, rTrc.iTrcPriority);

  IF rTrc.cTrcCur != rTrc.cTrcSumCur THEN
    nCur_Rate := RATES.Cross_Rate (rTrc.cTrcCur, rTrc.cTrcSumCur, p_date_oper);
    IF nCur_Rate <= 0 THEN
      p_err := RATES.No_Rate_Msg (rTrc.cTrcCur || '->' || rTrc.cTrcSumCur, p_date_oper);
      RAISE e_Set_Error;
    END IF;

    l_sum := CEIL (l_sum * nCur_Rate * 100) / 100; -- вточности ровно или чуть больше
  END IF;

  mReal_Sum := least(l_sum,mReal_Sum);

  PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 0); -- в памяти ничего не храню!

                  -->> ubrr korolkov https://redmine.lan.ubrr.ru/issues/3383
  IF rTRC.iTRCType > 0 AND rTRC.iTRCType NOT IN (20, 24) THEN
    /*
    :GLOBAL.Sum_Trn      := NLSFIX.TO_CHAR (mReal_Sum);
    :GLOBAL.WriteOff_Num := nWriteOff_Num;
    UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF', 'Запуск редактирования документа ');
    IF Edit (TRUE, rTrcNumANum.Num, rTrcNumANum.ANum, mReal_Sum, rTrc.mTrcLeft, dRegister, rTrc.mTrcSum)
    THEN
      mReal_Sum     := CARD_EDIT.GetFieldByName ('MTRCSUM');
      nWriteOff_Num := CARD_EDIT.GetFieldByName ('ITRCWRITEOFF');
      bCall_Dlg     := FALSE;
      PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', '1');
    ELSE
      UBRR_CD_DEBUG_PKG.write_error('FORM.DOCUMENT.WRITEOFF', 'Ошибка при редактировании документа ');
      RAISE e_Write_Off;
    END IF;
    */
-->>> UBRR  Емельянов В.К. 25.03.2016   15-1641.2  АБС: 148-н. Контроль заполнения бюджетных полей.
  -- проверка бюджетных полей
    ubrr_xxi5.UBRR_CHECK_TAXDETAILS.check_trc(
      p_form_kind    => 0,   -- способ обработки,  0 - считать все ошибки критическими
      p_itrcnum      => p_num,
      p_itrcanum     => p_anum,
      p_result       => p_err, -- сообщение
      p_result_kind  => l_result_kind -- 0 - ok, 1 - warning, 2 - error
    );
    if l_result_kind <> 0 then
     p_err := 'Не пройдена проверка бюджетных полей.';
      RAISE e_Write_Off;
    end if;

--<<< UBRR  Емельянов В.К. 25.03.2016   15-1641.2  АБС: 148-н. Контроль заполнения бюджетных полей.

  END IF;
----------------------------------------------------------------------
--
  -->>01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
  IF  ubrr_xxi5.ubrr_change_accounts_tofk.upd_tofk_accounts_auto_trc(par_trc_num  => p_num,
                                                                     par_trc_anum => p_anum) THEN
    PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 1);
  ELSE
    PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 0);
  END IF;
  --<<01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

  iResult := CARD.Accept (l_dummy, p_num, p_anum, p_date_oper, mReal_Sum, nWriteOff_Num, '2TRN');
  if iResult<>0 then
--->>> V.Arslanov 09.08.2016
--    p_err := 'Ошибка в CARD.Accept : '||l_dummy;
    p_err := 'Ошибка : '||l_dummy;
---<<< V.Arslanov 09.08.2016
    RAISE e_Accept;
  end if;

    -->> 09.01.2019 Пинаев Д.Е. [19-64691] Автоматическая обработка картотек
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
    --<< 09.01.2019 Пинаев Д.Е. [19-64691] Автоматическая обработка картотек


  if iResult=0 then ACCEPT_FLAG:=1; end if; --<<Измоденов И.А. 2010.06.11 Добавляем изменение статуса у связных документов для картотеки 1

--dbms_output.put_line('l_dummy = ' ||l_dummy);
--  IF ACCEPT_FLAG=1 OR :PARAMETER.State = '2' THEN
  declare
    is_doca_loan  number:=0;
    --<<<ubrr Лобик Д.А. 16.04.2009 № 5041-05/006757 от 15.04.2009 Безакцептное списание денежных средств со счетов клиентов в филиалах
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

      -->>01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
      IF  ubrr_xxi5.ubrr_change_accounts_tofk.upd_tofk_accounts_auto_trc(par_trc_num  => p_num,
                                                                         par_trc_anum => p_anum) THEN
        PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 1);
      ELSE
        PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 0);
      END IF;
      --<<01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

      iResult := CARD.WriteOff (vcERROR_MSG, p_num, p_anum, p_date_oper, mREAL_SUM, nWriteOff_Num, 'ACCEPT');
--dbms_output.put_line('vcERROR_MSG='||vcERROR_MSG);
      UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF','iResult='||iResult);
    end if; -- is_doca_loan > 0

    --Добавляем изменение статуса у связных документов для картотеки 1
    if iResult = 0 and is_from_cd > 0 and ACCEPT_FLAG=1  then --1212
      UPDATE ubrr_dm_cd_card_link a SET
        msum_unpayed = greatest (msum_unpayed - mreal_sum, 0),
        c_writeoff_trnnums = to_char (nbalance.get_last_num ()) || '/0;' || c_writeoff_trnnums
      WHERE nl_trcnum = p_num AND nl_trcanum = p_anum;
                  -- Сообщение про связанные документы
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
        v_cardmsg := 'С картотеки списан документ № '||rTRC.iTRCDocNum||
          ' от '||to_char(rTRC.dTrcCreate,'dd.mm.rrrr')||' по счету '||rTRC.cTrcAccD||
          '. На картотеке существуют документы, выставленные к нескольким расчетным счетам';
        ubrr_send.send_mail('OPOUL@UBRR.RU', 'Документы Картотеки для отзыва', v_cardmsg);
        exit;
      end loop;
                  --<< 22.03.2013 ubrr korolkov https://redmine.lan.ubrr.ru/issues/6334
    elsif iResult <> 0 then
      raise eUser;
    end if;  --if  iResult = 0 then 1212
                --<<<ubrr Лобик Д.А. 16.04.2009 № 5041-05/006757 от 15.04.2009 Безакцептное списание денежных средств со счетов клиентов в филиалах
  exception when others then
    UBRR_XCARD.Set_Card_Process_Mark(0);-->>><<<ubrr Лобик Д.А. 16.04.2009 № 5041-05/006757 от 15.04.2009 Безакцептное списание денежных средств со счетов клиентов в филиалах
    raise;
  end;

/*
  IF iResult = 0 THEN
    IF mReal_Sum = rTRC.mTRCLeft THEN
    UTIL.MRK_Delete (rTrc.RowID, :LOCAL.MarkerID);
                   -->>>ubrr katyuhin  20071024
                   -- Формируем уведомление о списании, если это И-К2
      if (rTRC.iTRCType = 25) and (rTRC.cTRCAccC like '111810%') then
        begin
          Ubrr_katpm_utils.SendMessage('CARD_RETIREMENT',
                                                   '(' || to_char(dREGISTER,'DD.MM.YYYY') || ') Произведено списание с Картотеки 2 со счета ' || rTRC.ctrcaccd ||
                                                   ': ' ||rTRC.ctrcclient_name || ' на сумму '|| to_char(mREAL_SUM));
        exception
          when others then
            CARD.Set_TrcMessage (rTrcNumANum.Num, rTrcNumANum.ANum, 'Ошибка при вызове Ubrr_katpm_utils.SendMessage: '||sqlerrm);
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
  -->>-- 14.05.2019 Пинаев Д.Е. [19-59060.2] АБС: Изменение банковских счетов ТОФК (1часть)
  WHEN e_RecAccIsClosed THEN
    rollback to very_beginning;
    if p_err is null then p_err := ' e_RecAccIsClosed ';   end if;
    return -1;
  -->>-- 14.05.2019 Пинаев Д.Е. [19-59060.2] АБС: Изменение банковских счетов ТОФК (1часть)
  WHEN e_Write_Off THEN
    rollback to very_beginning;
    if p_err is null then p_err := ' e_Write_Off ';   end if;
    p_err := 'Документ' || get_doc_info ||'. '|| p_err;
    return -1;
  WHEN e_Set_Error THEN
    rollback to very_beginning;
    CARD.Set_TrcMessage (p_num, p_anum, p_err);
    UBRR_CD_DEBUG_PKG.write_error('FORM.DOCUMENT.WRITEOFF','p_num = '||p_num||chr(10)||
      'p_anum' ||p_anum||chr(10)||
      'p_err = '||p_err);
    p_err := 'Документ' || get_doc_info ||'. '|| p_err;
    return -2;
  WHEN resource_busy then
    rollback to very_beginning;
    p_err := 'Документ '||get_doc_info||' обрабатывается другим пользователем. Попробуйте позднее.';
    return -3;
  WHEN eUser THEN
    rollback to very_beginning;
    UBRR_CD_DEBUG_PKG.write_error('FORM.DOCUMENT.WRITEOFF','p_num = '||p_num||chr(10)||
      'p_anum' ||p_anum||chr(10)|| p_err);
-->>> V. Arslanov 09.08.2016
--    p_err := p_err ||' Ошибка при выполнении CARD.WriteOff.';
--<<< V. Arslanov 09.08.2016
-- Если сообщение об ошибке было пустым - делаю его непустым
--      if p_err is null then p_err := ' '; end if;
      p_err := 'Документ' || get_doc_info ||'. '|| p_err;
   return -4;
  when e_Accept then
    rollback to very_beginning;
    if p_err is null then p_err := ' e_Accept ';   end if;
    p_err := 'Документ' || get_doc_info ||'. '|| p_err;
    return -5;

  WHEN OTHERS THEN
    rollback to very_beginning;
    UBRR_CD_DEBUG_PKG.write_error('FORM.DOCUMENT.WRITEOFF','p_num = '||p_num||chr(10)||
      'p_anum' ||p_anum||chr(10)||SQLERRM );
    p_err := SQLERRM;
    p_err := 'Документ' || get_doc_info ||'. '|| p_err;
    return -999;

END write_off_doc1;


-- Сделано на основе функции WriteOff из формы document.fmb
-- Код не "причесывал" просто сделал минимальные переделки, чтобы можно было списать документ
FUNCTION write_off_doc2(
  p_num  xxi."trc".iTrcNum%type,
  p_anum xxi."trc".iTrcANum%type,
  p_err out varchar2, -- информация об ошибке (или null, если нет ошибки)
  p_date_oper date,
  p_sum number, -- допустимая к списанию сумма
  cp_stat in out varchar2-->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
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
      cTrcOwnA, cTrcPurp, cTrcMfoA, cTrcMfoO, itrcsop,  -- 17.04.2018 Киселев А.А. 17-1180 АБС: Исключение инкассовых из автоматической обработки картотек
      CTRCCORACCA,  --18.11.2020  Зеленко С.А.    [20-82101.1]  АБС: Изменение счетов ТОФК с 01.01.2021
      CTRCBNAMEA  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
    FROM TRC
    WHERE itrcNUM = p_num
      AND itrcANUM = p_anum
    ORDER BY dtrccreate,iTrcPriority -- 17.04.2018 Киселев А.А. 17-1180 АБС: Исключение инкассовых из автоматической обработки картотек
    FOR UPDATE OF mTrcLeft NOWAIT
    ;

  rTrc             cTrc%ROWTYPE;
--  bCall_Dlg        BOOLEAN;
  iResult          INTEGER;

--  mPref_P_Spis     NUMBER := 0;

  vcDummy          VARCHAR2 (250);
  nCur_Rate        NUMBER;

  e_RecAccIsClosed  EXCEPTION;     -->><<-- 07.05.2019    Пинаев Д.Е.       [19-59060.2] АБС: Изменение банковских счетов ТОФК (1часть)
  e_Write_Off      EXCEPTION;
  eUser             EXCEPTION;


  is_from_CD number :=-1;
  cgacacc TRC.ctrcacca%TYPE:='???';
  to_idsmr smr.idsmr%type;
  v_cardmsg  varchar2(250);
  e_Set_Error  EXCEPTION;

  resource_busy exception; -->><< UBRR 26.08.2013 Портнягин Д.Ю. Оптимизация работы картотеки
  pragma exception_init (resource_busy,-54);

  l_result_kind number;

  bPriorChng Boolean:=False;
  vCreatStatus  VARCHAR2(2):=Null;
  iBackTrcPriority Number;

  function get_doc_info return varchar2 is
  begin
    return ' №' || rTrc.iTrcDocNum || ' от ' || to_char (rTrc.dTrcCreate,'dd.mm.rrrr')||' ';
  end;

BEGIN

  -- при возникновении ошибки при списании очередного документа картотеки счета
  -- уже списанные в транзакции документы не должны рулбачиться
  savepoint very_beginning;


  OPEN cTRC;
  FETCH cTRC INTO rTRC;
  CLOSE cTRC;

  mReal_Sum     := rTRC.mTrcLeft;
  nWriteOff_Num := nvl(rTrc.iTrcWriteOff, 0) + 1;

  --Контроль зачислений на счета 40821, согласно проверке на соответствие 103-ФЗ, 161-ФЗ
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

  -- по идее, проверку лучше бы делать для счета, а не его документов, впрочем тут без разницы
  vcACC_STATUS := IDOC_UTIL.Check_Account (vcDUMMY, rTRC.cTRCAccD, rTRC.ctrcCUR, rTRC.iTrcPriority);
  IF UPPER (vcACC_STATUS ) NOT in ('ACC_OPEN', 'ACC_PARTLY_BLOCKED') THEN
    p_err := 'Счет '||rTRC.cTRCAccD||' не является открытым либо частично блокированным.';
    RAISE e_Write_Off; -- на клиенте - запрос на продолжение операции
  END IF;

  -->> 07.05.2019 Пинаев Д.Е. [19-59060.2] АБС: Изменение банковских счетов ТОФК (1часть)
  declare
    l_acc ubrr_data.ubrr_sud_ft_accounts.account_new%type :=
       get_sud_ft_account(p_Mfoa=>rTrc.cTrcMfoA, p_cTrcAccA=>rTrc.cTrcAccA);
  begin
    if l_acc is not null then
      p_err := 'Счет '||rTRC.cTRCAccD||' Документ № '|| rTrc.Itrcdocnum ||' от '|| to_char(rTrc.Dtrcdoc, 'dd.mm.yyyy') ||'. '||
      'Счет получателя '|| rTrc.cTrcAccA ||' закрыт. ' ||
       case when is_acc(l_acc) then 'Новый счет ' || l_acc else l_acc end ;
    RAISE e_RecAccIsClosed;
    end if;

  end;
  --<< 07.05.2019 Пинаев Д.Е. [19-59060.2] АБС: Изменение банковских счетов ТОФК (1часть)

  -->>18.11.2020  Зеленко С.А.    [20-82101.1]  АБС: Изменение счетов ТОФК с 01.01.2021
  IF ubrr_xxi5.ubrr_change_accounts_tofk.check_tofk_auto_trc( par_itrcnum       => rTrc.Itrcnum,
                                                              par_itrcanum      => rTrc.Itrcanum,
                                                              par_itrctype      => rTrc.Itrctype,
                                                              par_ctrcaccd      => rTrc.Ctrcaccd,
                                                              par_ctrcmfoa      => rTrc.cTrcMfoA,
                                                              par_ctrccoracca   => rTrc.Ctrccoracca,
                                                              par_ctrcacca      => rTrc.cTrcAccA,
                                                              par_purp          => rTrc.cTrcPurp,
                                                              par_Bnamea        => rTrc.Ctrcbnamea,  --01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
                                                              p_err             => p_err) THEN

    RAISE e_Write_Off;
  END IF;
  --<<18.11.2020  Зеленко С.А.    [20-82101.1]  АБС: Изменение счетов ТОФК с 01.01.2021

    -->> 17.04.2018    Киселев А.А.      17-1180      АБС: Исключение инкассовых из автоматической обработки картотек
  --=================================================================
  -- Проверка документов при массовом списании.
  -- Если БО1 23 или 26 и БО2 Пусто и Подтвержденная очередность = 4
  -- То выкидываем с ошибкой
  -- *UPD 21.08.2020 UBRR Lazarev*
  -- Если БО1 23 или 26 и БО2 Пусто или 11 и Подтвержденная очередность = 4
  --=================================================================
  -->> 21.09.2020 UBRR Lazarev [20-74096] https://redmine.lan.ubrr.ru/issues/74096
  --IF rTRC.itrctype IN (23,26) AND rTRC.itrcsop IS NULL AND rTRC.iTrcPriority IN (1,2,3,4)
    IF rTRC.itrctype IN (23,26) AND (rTRC.itrcsop = 12 or rTRC.itrcsop is null) AND rTRC.iTrcPriority IN (1,2,3,4)
  --<< 21.09.2020 UBRR Lazarev [20-74096] https://redmine.lan.ubrr.ru/issues/74096
    THEN
      p_err := 'Документ ('||rTRC.itrcnum||','||rTRC.itrcanum||').Инкассовое поручение на бумажном носителе.';
      RAISE e_Set_Error;
  END IF;
  --<< 17.04.2018    Киселев А.А.      17-1180      АБС: Исключение инкассовых из автоматической обработки картотек
  if NVL(PREF.Get_Preference ('CARD2.RED_BALANCE'), '1') = '1' then -- контроль на красное сальдо
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
                                         or regexp_like(rTrc.CTRCACCA,'^('||nvl(PREF.Get_Preference('UBRR_CHECK_PAY_BUDGET.CTRNACCA_NEW'),'03100|03212|03222|03232|03242|03252|03262|03272|03221|03231')||')') --18.11.2020  Зеленко С.А.    [20-82101.1]  АБС: Изменение счетов ТОФК с 01.01.2021
                                         )
    Then
      iBackTrcPriority:=rTrc.iTrcPriority;
      rTrc.iTrcPriority:=4; -- аналогично тому, как это сейчас возможно для документов с 3 или 4 очередностью.
      bPriorChng:=True;
    End If;

     -- 22.07.2016 - заменил следующую строку
     -- mSum := ACC_INFO.GetAccountPP (rTRC.cTRCAccD, rTRC.ctrcCUR, p_date_oper, rTrc.iTrcPriority) /* - mPref_P_Spis*/;
     mSum := p_sum; -- 22.07.2016 - теперь сумму, допустимую к списанию, передаем извне

     If bPriorChng Then
       rTrc.iTrcPriority:=iBackTrcPriority; -- возвращаем обратно
     End If;

--->>> V.Arslanov 09.08.2016
/*     IF mSum <= 0 THEN
--->>> V.Arslanov 09.08.2016
--       p_err := 'Не пройдена проверка на красное сальдо.';
       p_err := 'Сумма блокировки превышает остаток по счету.';
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

       mSum := CEIL (mSum * nCur_Rate * 100) / 100; -- вточности ровно или чуть больше
     END IF;

   ELSE -- нет контроля на красное сальдо
     --     mSum := rTrc.mTrcLeft;
     -- зато есть требования текущего задания!
     mSum := p_sum;
   END IF;

  mReal_Sum := LEAST (rTrc.mTrcLeft, mSum);

  -- проверка бюджетных полей
  ubrr_xxi5.UBRR_CHECK_TAXDETAILS.check_trc(
    p_form_kind    => 0,   -- способ обработки,  0 - считать все ошибки критическими
    p_itrcnum      => p_num,
    p_itrcanum     => p_anum,
    p_result       => p_err, -- сообщение
    p_result_kind  => l_result_kind -- 0 - ok, 1 - warning, 2 - error
  );
  if l_result_kind <> 0 then
--dbms_output.put_line( p_err);
   p_err := 'Не пройдена проверка бюджетных полей.';

    RAISE e_Write_Off;
  end if;

  declare
    cAcc varchar2(20);
--    cWRITE_OFF_EDIT varchar2(1);
    -->>>ubrr Лобик Д.А. 16.04.2009 № 5041-05/006757 от 15.04.2009 Безакцептное списание денежных средств со счетов клиентов в филиалах
    i_Yes_zbl_acc number:=0;
    is_doca_loan  number:=0;
    --<<<ubrr Лобик Д.А. 16.04.2009 № 5041-05/006757 от 15.04.2009 Безакцептное списание денежных средств со счетов клиентов в филиалах
  begin
   /* cWRITE_OFF_EDIT := NVL (PREF.Get_Preference ('CARD2.WRITEOFF_EDIT'), '0');
    IF rTRC.iTRCType < 1 THEN
      cWRITE_OFF_EDIT := '0'; -- служебные документы не редактируются
    END IF;
    IF cWRITE_OFF_EDIT = '1' THEN
      cAcc := CARD_EDIT.getFieldByName ('CTRCACCA');
    else
      cAcc := rTRC.ctrcACCA;
    end if;
*/ --- adf не надо
    PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 0); --adf

    i_Yes_zbl_acc:=ubrr_abrr_btn.Yes_zbl_acc(cAcc);
    is_doca_loan:=-999;
    ubrr_dm_cd2trn.Set_Tansit_Acc(null);--транзитный счет по умолчанию
          --пришел ли документ в картотеку из кредитов того же самого idsmr
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
      --забалансовый получатель или документ пришел  картотеку из кредитов
        if is_from_CD > 0 and i_Yes_zbl_acc <> 1   then
        --документ из кредитов, но пока получатель не забалансовый
        -- Определяем забалансовый технический счет
          UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF','Определяем забалансовый технический счет');
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
            p_err := 'Забалансовый технический счет не определился.';
            UBRR_CD_DEBUG_PKG.write_error('FORM.DOCUMENT.WRITEOFF', p_err);
            raise eUser;
          else
            UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF','Забалансовый технический счет CGACACC = '||cgacacc);
          end if;
          CARD_EDIT.setFieldByName('CTRCACCA', cgacacc);
          CARD_EDIT.setFieldByName('ITRCTYPE', '11');
        end if;

        if is_from_CD > 0 then --отметка о том, что документ пришел из кредитов
          UBRR_XCARD.Set_Card_Process_Mark(is_from_CD);
        else
          UBRR_XCARD.Set_Card_Process_Mark(null);
        end if;
            --<<<ubrr Лобик Д.А. 16.04.2009 № 5041-05/006757 от 15.04.2009 Безакцептное списание денежных средств со счетов клиентов в филиалах
        SAVEPOINT sp_WriteOff;
        -- Формирование приходного документа для разбора
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
          p_err := 'Создание документа для разбора: '||p_err;
          raise eUser;
        end if;
        iResult := UBRR_XCARD.Spisan_zbl(p_err, p_num, p_anum, p_date_oper , mREAL_SUM, nWriteOff_Num, 'WRITEOFF');
        UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF','iResult='||iResult);
        if iResult <> 0 then
          p_err := 'Формирование внебалансового документа: '||p_err;
          -- 27.08.2013 Портнягин Д.Ю. Здесь нужно удалять то что создалось при работе формы Ubrr_btn и UBRR_XCARD.Create_zbl
          -- пока оставляю только raise
          raise eUser;
        end if;
      ELSE  -- неверно что : забалансовый получатель или документ пришел  картотеку из кредитов
            --UBRR_DBG_WRITE_CARD_INFO ; -- это на форме, переношу текст
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

        -->>01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
        IF  ubrr_xxi5.ubrr_change_accounts_tofk.upd_tofk_accounts_auto_trc(par_trc_num  => p_num,
                                                                           par_trc_anum => p_anum) THEN
          PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 1);
        ELSE
          PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 0);
        END IF;
        --<<01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

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
      --UBRR_DBG_WRITE_CARD_INFO ; -- это на форме, переношу текст
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
-- ВЕ - Похоже здесь все проверено и что то списывается;

        -->>01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021
        if  ubrr_xxi5.ubrr_change_accounts_tofk.upd_tofk_accounts_auto_trc(par_trc_num  => p_num,
                                                                           par_trc_anum => p_anum) THEN
          PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 1);
        ELSE
          PREF.Set_Preference ('CARD2.WRITEOFF_EDIT', 0);
        END IF;
        --<<01.02.2021  Зеленко С.А.    [DKBPA-38]    АБС (2 ЭТАП) : Изменение счетов ТОФК с 01.01.2021

        iResult := CARD.WriteOff (p_err, p_num, p_anum, p_date_oper , mREAL_SUM, nWriteOff_Num, 'WRITEOFF');

        UBRR_CD_DEBUG_PKG.write_info('FORM.DOCUMENT.WRITEOFF','iResult='||iResult);
    end if; -- is_doca_loan > 0

    -->> 09.01.2019 Пинаев Д.Е. [19-64691] Автоматическая обработка картотек
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
    --<< 09.01.2019 Пинаев Д.Е. [19-64691] Автоматическая обработка картотек

    --Добавляем изменение статуса у связных документов для картотеки 1
    if iResult = 0 and is_from_cd > 0 then --1212
      UPDATE ubrr_dm_cd_card_link a SET
        msum_unpayed = greatest (msum_unpayed - mreal_sum, 0),
        c_writeoff_trnnums = to_char (nbalance.get_last_num ()) || '/0;' || c_writeoff_trnnums
      WHERE nl_trcnum = p_num AND nl_trcanum = p_anum;
                    -- Сообщение про связанные документы
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
        v_cardmsg := 'С картотеки списан документ № '||p_num||
          ' от '||to_char(rTRC.dTrcCreate,'dd.mm.rrrr')||' по счету '||rTRC.cTrcAccD||
          '. На картотеке существуют документы, выставленные к нескольким расчетным счетам';
          ubrr_send.send_mail('OPOUL@UBRR.RU', 'Документы Картотеки для отзыва', v_cardmsg);
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
      -- Формируем уведомление о списании, если это И-К2
      if (rTRC.iTRCType = 25) and (rTRC.cTRCAccC like '111810%') then
        begin
          Ubrr_katpm_utils.SendMessage('CARD_RETIREMENT',
            '(' || to_char(p_date_oper ,'DD.MM.YYYY') || ') Произведено списание с Картотеки 2 со счета ' || rTRC.ctrcaccd ||
            ': ' ||rTRC.ctrcclient_name || ' на сумму '|| to_char(mREAL_SUM));
        exception
        when others then
          CARD.Set_TrcMessage (p_num, p_anum, 'Ошибка при вызове Ubrr_katpm_utils.SendMessage: '||sqlerrm);
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
  -->>-- 14.05.2019 Пинаев Д.Е. [19-59060.2] АБС: Изменение банковских счетов ТОФК (1часть)
  WHEN e_RecAccIsClosed THEN
    rollback to very_beginning;
    if p_err is null then p_err := ' e_RecAccIsClosed ';   end if;
    return -1;
  -->>-- 14.05.2019 Пинаев Д.Е. [19-59060.2] АБС: Изменение банковских счетов ТОФК (1часть)
  WHEN e_Write_Off THEN
    rollback to very_beginning;
    if p_err is null then p_err := ' e_Write_Off ';   end if;
    p_err := 'Документ' || get_doc_info ||'. '|| p_err;
    return -1;
  WHEN e_Set_Error THEN
    rollback to very_beginning;
    CARD.Set_TrcMessage (p_num, p_anum, p_err);
    UBRR_CD_DEBUG_PKG.write_error('FORM.DOCUMENT.WRITEOFF','p_num = '||p_num||chr(10)||
      'p_anum' ||p_anum||chr(10)||
      'p_err = '||p_err);
    p_err := 'Документ' || get_doc_info ||'. '|| p_err;
    return -2;
  WHEN resource_busy then
    rollback to very_beginning;
    p_err := 'Документ'|| get_doc_info ||' обрабатывается другим пользователем. Попробуйте позднее.';
    return -3;
  WHEN eUser THEN
    rollback to very_beginning;
    UBRR_CD_DEBUG_PKG.write_error('FORM.DOCUMENT.WRITEOFF','p_num = '||p_num||chr(10)||
      'p_anum' ||p_anum||chr(10)|| p_err);
--->>> V.Arslanov 09.08.2016
--    p_err := p_err ||' Ошибка при выполнении CARD.WriteOff.';
---<<< V.Arslanov 09.08.2016
    if p_err is null then p_err := ' '; end if;
    p_err := 'Документ' || get_doc_info ||'. '|| p_err;
    return -4;
  WHEN OTHERS THEN
    rollback to very_beginning;
    UBRR_CD_DEBUG_PKG.write_error('FORM.DOCUMENT.WRITEOFF','p_num = '||p_num||chr(10)||
      'p_anum' ||p_anum||chr(10)||SQLERRM );
    p_err := SQLERRM;
    p_err := 'Документ' || get_doc_info ||'. '|| p_err;
    return -5;
end;

/* проверка условий, не позволяющих начать списания */
procedure write_off_acc_check(
  p_acc  xxi."acc".cAccAcc%type,
  p_acc_cur  xxi."acc".cAccCur%type,
  p_cus xxi."acc".iAccCus%type,
  p_date_oper date,
  --p_kind number,      -- 1 - есть документы на К1, 2-К2, 3- К1 и К2
  p_err out varchar2  -- информация об ошибке (или null, если нет ошибки)
)
is
  l_cnt number;

begin
  p_err := null;

-- 1. Реальный остаток на счете не проверяю.
-- Он проверялся при заполнении ubrr_data.ubrr_trc_writeoff и будет проверяться
-- при вычислении допустимой к списаниию сумме.

-- 2. Наличие подходящих к списанию документов не проверяю.
-- Это проверялось при заполнении ubrr_data.ubrr_trc_writeoff

-- 3. наличие планового (планируемого ?) списания
  -->> 10.03.2019    Пинаев Д.Е.       [19-64691]   Автоматическая обработка картотек-оптимизация старого алгоритма
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
  --<< 10.03.2019    Пинаев Д.Е.       [19-64691]   Автоматическая обработка картотек-оптимизация старого алгоритма

  if l_cnt > 0 then
    add_info2(11, p_acc, p_acc_cur);
    p_err := 'По счету ' || p_acc || ' имеются плановые списания.';
    return;
  end if;

-- 4.1. по счету нет неотмененных овердрафтных сумм с неуказанным приоритетом
  select count(1) into l_cnt
  from acc_over_sum
  where cAosSumType = 'O' and cAosStat = '1'
--    and iAosPrior is null -- !!!
    and nvl(iAosPrior, 0) = 0 -- 30358/#463
    and cAosAcc = p_acc and cAosCur = p_acc_cur
    and rownum = 1;

  if l_cnt > 0 then
    add_info2(12, p_acc, p_acc_cur);
    p_err := 'По счету ' || p_acc || ' имеются овердрафтные суммы с неуказанным приоритетом.';
    return;
  end if;

-- 4.2. по счету нет неотмененных овердрафтных сумм > 0
  select count(1) into l_cnt
  from acc_over_sum
  where cAosSumType = 'O' and cAosStat = '1'
--    and iAosPrior is not null
--    and nvl(iAosPrior, 0) <> 0 -- 30358/#463
--    для положительных сумм приоритет не важен 30533/#171
    and mAosSumma > 0 -- !!!
    and cAosAcc = p_acc and cAosCur = p_acc_cur
    and rownum = 1;

  if l_cnt > 0 then
    add_info2(13, p_acc, p_acc_cur);
    p_err := 'По счету ' || p_acc || ' имеются овердрафтные суммы > 0.';
    return;
  end if;

-- 5. статус счета 'О' или 'Ч'
  select count(1) into l_cnt
  from acc
  where caccprizn not in ('О','Ч')
    and caccacc = p_acc and cacccur = p_acc_cur
    and rownum = 1;

  if l_cnt > 0 then
    add_info2(14, p_acc, p_acc_cur);
    p_err := 'Счет ' || p_acc || ' должен иметь статус "О" или "Ч".';
    return;
  end if;


-- Требования из 37429/#10  п. VII. - по банкротам документы не списывать а отправлять на разбор

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
    p_err := 'Счет ' || p_acc || '. Клиент является банкротом. Необходим ручной разбор документов.';
    return;
  end if;

-- Требования из 37429/#115  - если есть действующие овердрафтные договора - не списывать
  select count(1) into l_cnt
  from acc_over_dog
  where caodacc = p_acc and caodcur = p_acc_cur
    and p_date_oper between daodstart and daodend
    and rownum = 1;

  if l_cnt > 0 then
    add_info2(18, p_acc, p_acc_cur);
    p_err := 'По счету ' || p_acc || ' имеются овердрафтные договора.';
    return;
  end if;

  -->> 04.08.2017 ubrr korolkov #43987
  if util.Is_Acc_In_CatGrp(p_acc, p_acc_cur, 998, 1) then
    add_info2(18, p_acc, p_acc_cur);
    p_err := 'По счету ' || p_acc || ' установлена категория/группа 998/1 (контроль целевого использования кредита)';
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
    p_err := 'По счету ' || p_acc || ' есть документы на картотеке 2 в статусе "Неотконтролирован"';
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
    p_err := 'По счету ' || p_acc || ' есть документы на картотеке 1 в статусе "Неотконтролирован"';
    return;
  end if;
  --<< 04.08.2017 ubrr korolkov #43987

--select caodacc, caodcur, daodstart, daodend  from acc_over_dog

/*
-- 6. в К2 есть документы с очередностью большей, чем документ из К1
--
-- https://redmine.lan.ubrr.ru/issues/30358#note-352 в п.10 в разделе "Дополнительно .."
-- появилось требование списание с К2 столько, сколько возможно, не обращая внимания на К1,
-- а затем уже, если возможно, делать списание с К1 или отправлять на ручной разбор

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
      and p_kind = 3; -- т.е. имеются документы на обеих картотеках

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
      and p_kind = 3; -- т.е. имеются документы на обеих картотеках

    if l_max2 > l_min1 then
      add_info2(15, p_acc, p_acc_cur);
      p_err := 'Счет ' || p_acc || ' имеет документ на К1 с меньшей очередность чем документ на К2.';
      return;
    end if;
  end;
  */
end;

-- переделка ACCESS_2.Is_Account_Enabled
-- отказ от фильтрации по idsmr и по правам пользователя
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
          select 'x' from  acc_ubs2 -- синтетические счета пользователя
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


-- списание с Картотеки 2 и, по последней постановке, с Картотеки 1
procedure write_off_acc(
  p_acc  xxi."acc".cAccAcc%type,
  p_acc_cur  xxi."acc".cAccCur%type,
  p_cus xxi."acc".iAccCus%type,
  p_kind number,
  p_err out varchar2, -- информация об ошибке (или null, если нет ошибки)
  p_need_work number,
  p_date_oper date
)
is
  l_accprizn xxi."acc".caccprizn%type;

  cv_stat varchar2(4); -->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)

  -- документы картотеки 2
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
      ,itrctype,itrcsop,mtrcleft_rub,ABS(MTRCLEFT_RUB-MTRCRSUM) --17.04.2018    Киселев А.А.      17-1180      АБС: Исключение инкассовых из автоматической обработки картотек
    from trc t
    where cTrcState = '2'
      -->> 04.08.2017 ubrr korolkov #43987
      and ctrcstatenc != '0' -- Неотконтролирован
      --<< 04.08.2017 ubrr korolkov #43987
      and cTrcAccD = p_acc
      and cTrcCur = p_acc_cur
      and p_kind <> 1
    order by 1 nulls first, 2,9 desc;--17.04.2018    Киселев А.А.      17-1180      АБС: Исключение инкассовых из автоматической обработки картотек

  ln_trc2 cr_trc2%rowtype;

  -- документы картотеки 1 (ожидающие разрешения)
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
      and ctrcstatenc != '0' -- Неотконтролирован
      --<< 04.08.2017 ubrr korolkov #43987
      and cTrcAccD = p_acc
      and cTrcCur = p_acc_cur
      and p_cus = (select iacccus from acc where caccacc = ctrnaccd and cacccur = ctrncur)
      and p_kind <> 2
      and l_accprizn = 'О' -- для 'Ч' не списываем
    order by 1 nulls first, 2;

  ln_trc1 cr_trc1%rowtype;


  cursor cr_limitation is
    select
      ipriority, summ
    from
    (
      select
        -- овердрафтные суммы с приоритетом N уменьшают допустимую к списанию сумму
        -- при начале обработке документов очередности N+1.
        d.ipriority + 1 ipriority,
        nvl(abs(sum(mAosSumma)),0)
        +
        decode(d.ipriority, 3,
          (
          select nvl(sum(mAosSumma),0)
          from acc_over_sum
          where cAosSumType = 'B'
            and (upper(cAosComment) like '%РЕШ%№%ОТ%' or upper(cAosComment) like '%РЕШ%N%ОТ%')
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

  l_sum number;         -- остаток за вычетом списаний процедуры и ограничений блокировок
  l_rest number;        -- остаток за вычетом списаний процедуры

  -- переменные для хранения информации о самом приоритетном документе из К1
  l_bad_card1 boolean; -- наличие документа в К1, предшествующего документа в К2
  l_priority1 number;  -- приоритет такого документа (если есть такой)
  l_date_create1 date; -- дата регистрации такого документа (если есть такой)

  -- переменые для отложенных документов
  l_def_doc_priority number;
--  l_def_doc_date date;

  e_error exception;

  -- признак КРС
  l_krs number;

  procedure close_cursors is
  begin
    if cr_trc1%isopen then close cr_trc1; end if;
    if cr_trc2%isopen then close cr_trc2; end if;
    if cr_limitation%isopen then close cr_limitation; end if;
  end;

  function get_doc1_info return varchar2 is
  begin
    return ' №' || ln_trc1.iTrcDocNum || ' от ' || to_char (ln_trc1.dTrcCreate,'dd.mm.rrrr') ||' ';
  end;

  function get_doc2_info return varchar2 is
  begin
    return ' №' || ln_trc2.iTrcDocNum || ' от ' || to_char (ln_trc2.dTrcCreate,'dd.mm.rrrr') ||' ';
  end;

begin
  -- проверки возможности списания
  write_off_acc_check(p_acc, p_acc_cur, p_cus, p_date_oper, p_err);

  if p_err is not null then return; end if;

  -- если реальное списание не нужно, выходим
  if p_need_work != 1 then return; end if;


  -- определим, относится ли счет к КРС
  select
    case when (
      exists (
        select null from xxi.gac
        where cgacacc = p_acc and cgaccur = p_acc_cur  and igaccat = 333 and igacnum in (2, 3)
      )

/* -- удалено в связи с 30533/177 -  к/г 333/2|3 не должна привязываться к клиенту
   -- если привязана, то это ошибка пользователя
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

  -- определим, есть ли документ в К1, предшествующий (по очереди) документам в К2
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
        and ctrcstatenc != '0' -- Неотконтролирован
        --<< 04.08.2017 ubrr korolkov #43987
        and cTrcAccD = p_acc
        and cTrcCur = p_acc_cur
        and p_cus = (select iacccus from acc where caccacc = ctrnaccd and cacccur = ctrncur)
        and l_accprizn = 'О' -- 'Ч' - не берем!
        and p_kind = 3 -- т.е. имеются документы на обеих картотеках
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
        and ctrcstatenc != '0' -- Неотконтролирован
        --<< 04.08.2017 ubrr korolkov #43987
        and cTrcAccD = p_acc
        and cTrcCur = p_acc_cur
        and p_kind = 3 -- т.е. имеются документы на обеих картотеках
      order by to_number(value_num) desc, dTrcCreate desc;

    ln2 cr2%rowtype;

  begin
    open cr1; fetch cr1 into ln1; close cr1;
    open cr2; fetch cr2 into ln2; close cr2;

    if (ln2.priority > ln1.priority) or
       (ln2.priority = ln1.priority and ln2.dTrcCreate > ln1.dTrcCreate)
    then
      -- тут можно сообщить, какой именно документ К2 каким именно документов К1 тормозится
      add_info2(15, p_acc, p_acc_cur);
      l_bad_card1    := true;
      l_priority1    := ln1.priority;
      l_date_create1 := ln1.dTrcCreate;
    end if;
  end;

-- Если в отложенных платежных документах для текущего счета имеются документы,
-- определить для минимального номера очередности минимальную дату документа
  begin
--    select iPriority, dCreate into l_def_doc_priority, l_def_doc_date
    select iPriority into l_def_doc_priority
    from
      (
      SELECT iPriority, dCreate   -- или dCreate или dtCreate брать?
      FROM dp_doc d
      WHERE cPayerAcc = p_acc and cCur = p_acc_cur
        and (
          DECODE(iType, -- БО1
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
    l_def_doc_priority := 999;     -- больше любого номера очереди
--    l_def_doc_date := sysdate + 1; -- позже любой из наступивших дат
  end;

  -- проверки закончены, производится попытка списания документов К2

  -- в качестве начальной суммы, допустимой к списанию, берем остаток
  l_sum := get_acc_rest(p_acc, p_acc_cur, p_date_oper);  -- точно не sysdate?

  if l_sum < 0.001 then return; end if;
  l_rest := l_sum;

  open cr_limitation;  fetch cr_limitation into ln_limitation;

  open cr_trc1;  fetch cr_trc1 into ln_trc1;

  if cr_trc1%found and ln_trc1.itrcpriority is null then
    p_err := 'На К1 имеется документ'|| get_doc1_info ||'с неуказанной подтвержденной очередностью';
    raise e_error;
  end if;

  open cr_trc2;  fetch cr_trc2 into ln_trc2;

  if cr_trc2%found and ln_trc2.itrcpriority is null then
    p_err := 'На К2 имеется документ'|| get_doc2_info ||'с неуказанной подтвержденной очередностью';
    raise e_error;
  end if;

  <<limitation>>
  while cr_limitation%found loop
    l_sum := l_sum - ln_limitation.summ; -- изменили допустимую к списанию сумму

    -- если сумма стала отрицательной, но есть еще документы, то выходим
    -- это по допусловию 12 (возможно, его отменят)
    if l_sum < 0 then
      if (cr_trc1%found or cr_trc2%found) and l_rest > 0 then
        p_err := 'Сумма блокировки превышает остаток по счету.'||
          ' Необходим ручной анализ документов.';
      end if;
      exit limitation;
    end if;



    while cr_trc2%found and ln_trc2.iTrcPriority = ln_limitation.ipriority and l_sum > 0 loop
      -- если есть документ на К1 предшествующий некоторому документу из К2
      -- то списываем с К2 пока очередность меньше таких документов из К1;
      -- если больше - выходим
      if l_bad_card1 and
        (
          (ln_trc2.iTrcPriority > l_priority1) or
          (ln_trc2.iTrcPriority = l_priority1 and ln_trc2.dTrcCreate > l_date_create1)
        )
      then
        exit limitation;
      end if;
      --<< 17.04.2018    Киселев А.А.      17-1180      АБС: Исключение инкассовых из автоматической обработки картотек
     --=================================================================
     -- Проверка документов при массовом списании, требуется проверить,
     -- имеются ли документы  с частичным списанием,с одинаковой очередностью
     -- и с датой регистрации. Если есть, то отрбасываем полностью счет.
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
        WHERE     ctrcstate = '2'    -- Картотека
              AND ctrcstatenc != '0' -- Неотконтролирован
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
           p_err := 'Счет '|| p_acc ||'. Есть документы с частичным списанием. Необходим ручной анализ документов';
           RAISE e_error;
       END IF;
     END;
      --<< 17.04.2018    Киселев А.А.      17-1180      АБС: Исключение инкассовых из автоматической обработки картотек
      -- 30358/#361,#366 - отложенный документ "тормозит" списание тех, что после него
      if (ln_trc2.iTrcPriority > l_def_doc_priority)
        -- or (ln_trc2.iTrcPriority = l_def_doc_priority and ln_trc2.dTrcCreate > l_def_doc_date)
      then
        p_err := 'Имеются документы в отложенных. Необходим ручной разбор отложенных документов.';
        exit limitation;
      end if;


      l_result := write_off_doc2(ln_trc2.iTrcNum, ln_trc2.iTrcANum, p_err, p_date_oper, l_sum,
                                 cv_stat -->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
      );

      if p_err is null and l_result > 0 then
        add_writeoff_info(ln_trc2.iTrcNum, ln_trc2.iTrcANum, l_result,
                          cv_stat -->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
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

    -- Если:
    --   - сумма, свободная для списания, равна нулю
    --   - остаток на счете (с учетом списаний) больше нуля
    --   - не было ошибок при списании
    --   - еше остались несписанные документы на К2
    -- То выдаем поясняющее сообшение
    if abs(l_sum) < 0.01 and abs(l_rest) >= 0.01 and cr_trc2%found then
      p_err := 'Очередность ограничения по счету больше, чем очередность документов картотеки 2.';
      exit limitation;
    end if;


    if not l_bad_card1 then
      -- документы К1 начнут списываться, когда кончатся документы К2
      while cr_trc1%found and ln_trc1.iTrcPriority = ln_limitation.ipriority  and l_sum > 0 loop

        -- 30358/#361,#366 - отложенный документ "тормозит" списание тех, что после него
        if (ln_trc1.iTrcPriority > l_def_doc_priority)
          -- or (ln_trc1.iTrcPriority = l_def_doc_priority and ln_trc1.dTrcCreate > l_def_doc_date)
        then
          p_err := 'Имеются документы в отложенных. Необходим ручной разбор отложенных документов.';
          exit limitation;
        end if;

        l_result := write_off_doc1(ln_trc1.iTrcNum, ln_trc1.iTrcANum, p_err, p_date_oper, l_sum,
                                   cv_stat -->><<-- 14.02.2020 Пинаев Д.Е.[19-64691] АБС: Организация автоматического процесса массовой обработки картотек (замена ручной обработки)
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

      -- Если:
      --   - сумма, свободная для списания, равна нулю
      --   - остаток на счете (с учетом списаний) больше нуля
      --   - не было ошибок при списании
      --   - еше остались несписанные документы на К1
      -- То выдаем поясняющее сообшение
      if abs(l_sum) < 0.01 and abs(l_rest) >= 0.01 and cr_trc1%found then
        p_err := 'Очередность ограничения по счету больше, чем очередность документов картотеки 1.';
        exit limitation;
      end if;
    end if;

    fetch cr_limitation into ln_limitation;
  end loop limitation;

  if l_bad_card1 then
    p_err := 'Счет ' || p_acc || ' имеет документ на К1 с меньшей очередность чем документ на К2. '|| p_err;
  end if;

  close_cursors;

--  commit; -- если обработали все по счету, то можно сохранить изменения. TODO перенести коммит на уровень вверх
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
    lv_ppo_num number := UBRR_XXI5.ubrr_ordered.get_ppo();  -- 11.04.2017 Вахрушев - оптимизация
begin

  delete from ubrr_data.ubrr_trc_move;

    -- 16.05.2017 Вахрушев - оптимизация >>>
    /* -- old code --
  insert into ubrr_data.ubrr_trc_move(cacc, cname, icus, cdirection)
  (
  select cacc, cname, icus, '1 -> 2'
  from ubrr_data.ubrr_trc_loa
  where cprizn <> 'З'  --Счет не закрыт, то что незаблокирован - отдельно поищем
    and not exists(
      select 1 from ach h
      where cachacc = cacc and cachcur = ccur
        and
            -- наличие приостановления ФНС
          ( regexp_like (upper(cachbase),'(.*(БЛ|РЕ(Ш|Щ)|Р\.).*\d{1,}.*|(^\d{1,}.*)(|((№|N).*\d{1,}))).*(ОТ|JN)\s*\d{2}(,|\.|\/|\\)\d{2}(,|\.|\/|\\)\d.*')
            or regexp_like (upper(cachbase),'(ПРЕДП(\.|\s)|ПРЕДПИСАНИЕ).*ГНИ')
            or upper(cachbase) like '%ФНС%'
            or upper(cachbase) like '% ГНИ%'
            or upper(cachbase) like 'ГНИ ПО%'
            or upper(cachbase) like '%ИМНС%'
          )
        and not upper(cachbase) like '%СВК%' and not upper(cachbase) like '%CDR%'
        and not upper(cachbase) like '%УФМ%'
        and not regexp_like (upper(cachbase),'\d{4}-\d{2}\/\d{6}')
        -- отрицание условия отмены ФНС
        and not regexp_like (upper(cachbase),'(ОТМ.*(|(№|N)).*\d{1,}.*(ОТ|JN))|((О|J)ТМЕНА)')
      )

    and not exists (
      select 1
      from acc_over_sum
      where cAosAcc = cacc and cAosCur = ccur
        and  cAosSumType = 'B'  -- and dAosDelete is null
        and cAosStat = '1'
        and
          -- ФНС
          ( regexp_like (upper(cAosComment),'(.*РЕ(Ш|Щ).*\d{1,}.*|(^\d{1,}.*)(|((№|N).*\d{1,}))).*(ОТ|JN)\s*\d{2}(,|\.|\/)\d{2}(,|\.|\/)\d.*')
            or upper(cAosComment) like '%ИФНС%'
          )
        and not upper(cAosComment) like '%(ФТС)%'
    ) -- Нет блокированных сумм -- https://redmine.lan.ubrr.ru/issues/30358#note-98

/*
Было: одним из условий для выбора счетов  для списка для переноса "К1->K2" было
наличие документов на Картотеке 1.
Стало: для выбора счетов проверяется наличие документов на картотеке 1,
удовлетворяющих дополнительному условию.
Дополнительное условие: для документа на картотеке 1 определяется номер
клиента для счета плательщика документа. Также для этого документа выбираются
относящиеся к нему проводки, и  среди проводок со ДТ, удовлетворяющих маске 90901%,
ищется последняя проводка. Для этой проводки, находится дебитовый счет, для счета
- номер клиента.
Если этот номер клиента не равен ранее найденному номеру клиента для счета
плательщика документа, то условие считается невыполненным.
Таким образом теперь счета, у которых на Картотеке 1 только документы ждущие
акцепта, выбираться в список не должны.

Еще раз - проверяется наличие хотя бы одного такого документа!
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
        and ctrcstatenc != '0' -- Неотконтролирован
        --<< 04.08.2017 ubrr korolkov #43987
        and icus = (select iacccus from acc where caccacc = ctrnaccd and cacccur = ctrncur)
    ) -- Есть документы в К1
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
    where     tl.cprizn <> 'З'  --Счет не закрыт, то что незаблокирован - отдельно поищем
          and not exists(
                            select /*+ no_unnest
                                       index_ss(h P_ACH)
                                       push_subq */
                                   'x'
                            from ach h
                            where     h.cachacc = tl.cacc
                                  and h.cachcur = tl.ccur
                                  and h.CACHFLAG<>'О'-->><<-- 14.01.2021 Пинаев Д.Е. [IM2685764-001] Перенос документов картотеки
                                  and -- наличие приостановления ФНС
                                  (
                                    regexp_like (upper(h.cachbase),'(.*(БЛ|РЕ(Ш|Щ)|Р\.).*\d{1,}.*|(^\d{1,}.*)(|((№|N).*\d{1,}))).*(ОТ|JN)\s*\d{2}(,|\.|\/|\\)\d{2}(,|\.|\/|\\)\d.*')
                                    or regexp_like (upper(h.cachbase),'(ПРЕДП(\.|\s)|ПРЕДПИСАНИЕ).*ГНИ')
                                    or upper(h.cachbase) like '%ФНС%'
                                    or upper(h.cachbase) like '% ГНИ%'
                                    or upper(h.cachbase) like 'ГНИ ПО%'
                                    or upper(h.cachbase) like '%ИМНС%'
                                  )
                                  and not upper(h.cachbase) like '%СВК%'
                                  and not upper(h.cachbase) like '%CDR%'
                                  and not upper(h.cachbase) like '%УФМ%'
                                  and not regexp_like (upper(h.cachbase),'\d{4}-\d{2}\/\d{6}')
                                  -- отрицание условия отмены ФНС
                                  and not regexp_like (upper(h.cachbase),'(ОТМ.*(|(№|N)).*\d{1,}.*(ОТ|JN))|((О|J)ТМЕНА)')
                        )
          and not exists (  -- Нет блокированных сумм
                            select /*+ no_unnest
                                       index(aos I_ACC_OVER_SUM_ACC_CUR_SUMTYP)
                                       no_push_subq */
                                   'x'
                            from acc_over_sum aos
                            where     aos.cAosAcc = tl.cacc
                                  and aos.cAosCur = tl.ccur
                                  and aos.cAosSumType = 'B'
                                  and aos.cAosStat = '1'
                                  and -- ФНС
                                  (
                                    regexp_like (upper(aos.cAosComment),'(.*РЕ(Ш|Щ).*\d{1,}.*|(^\d{1,}.*)(|((№|N).*\d{1,}))).*(ОТ|JN)\s*\d{2}(,|\.|\/)\d{2}(,|\.|\/)\d.*')
                                    or upper(aos.cAosComment) like '%ИФНС%'
                                  )
                                  and not upper(aos.cAosComment) like '%(ФТС)%'
                         )
          /*
          Если этот номер клиента не равен ранее найденному номеру клиента для счета
          плательщика документа, то условие считается невыполненным.
          Таким образом теперь счета, у которых на Картотеке 1 только документы ждущие
          акцепта, выбираться в список не должны.

          Еще раз - проверяется наличие хотя бы одного такого документа!
          */
          -- Есть документы в К1
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
    -- 16.05.2017 Вахрушев - оптимизация <<<

    -- 11.04.2017 Вахрушев - оптимизация >>>
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
    where     tl.cprizn <> 'З' -- игнорируем закрытые счета
          and exists (  -- Есть неналоговые документы 6 очередности в К2
                        select /*+ push_subq */
                                '1'
                        from trc tr,
                             trc_attr_val tat
                        where     tat.id_attr = lv_ppo_num
                              and tat.inum = tr.iTrcNum
                              and tat.ianum = tr.iTrcANum
                              and tat.value_num = 5 -- только 5-я очередь
                              and tr.ctrcaccd = tl.cacc
                              and tr.ctrccur = tl.ccur
                              and tr.ctrcstate = '2'
                              -->> 04.08.2017 ubrr korolkov #43987
                              and ctrcstatenc != '0' -- Неотконтролирован
                              --<< 04.08.2017 ubrr korolkov #43987
                              -- налоговые платежи не переносятся
                              and substr(tr.cTrcAccA,1,5) <> '40101'
                              and not regexp_like(tr.cTrcAccA,'^('||nvl(PREF.Get_Preference('UBRR_CHANGE_ACCOUNTS_TOFK.CACCA_NAL'),'03100')||')')  --18.11.2020    Зеленко С.А.      [20-82101.1]  АБС: Изменение счетов ТОФК с 01.01.2021
                     )

          and (
                exists( -- наличие приостановления ФНС
                        select /*+ no_unnest index_ss(h P_ACH) no_push_subq */
                               '1'
                        from ach h
                        where     h.cachacc = tl.cacc
                              and h.cachcur = tl.ccur
                              and h.CACHFLAG<>'О'-->><<-- 14.01.2021 Пинаев Д.Е. [IM2685764-001] Перенос документов картотеки
                              and not upper(h.cachbase) like '%СВК%'
                              and not upper(h.cachbase) like '%CDR%'
                              and not upper(h.cachbase) like '%УФМ%'
                              and (
                                    upper(h.cachbase) like '%ФНС%'
                                    or
                                    upper(h.cachbase) like '% ГНИ%'
                                    or
                                    upper(h.cachbase) like 'ГНИ ПО%'
                                    or
                                    upper(h.cachbase) like '%ИМНС%'
                                    or
                                    regexp_like (upper(h.cachbase),'(.*(БЛ|РЕ(Ш|Щ)|Р\.).*\d{1,}.*|(^\d{1,}.*)(|((№|N).*\d{1,}))).*(ОТ|JN)\s*\d{2}(,|\.|\/|\\)\d{2}(,|\.|\/|\\)\d.*')
                                    or
                                    regexp_like (upper(h.cachbase),'(ПРЕДП(\.|\s)|ПРЕДПИСАНИЕ).*ГНИ')
                                  )
                              and not regexp_like (upper(h.cachbase),'\d{4}-\d{2}\/\d{6}')
                              -- отрицание условия отмены ФНС
                              and not regexp_like (upper(h.cachbase),'(ОТМ.*(|(№|N)).*\d{1,}.*(ОТ|JN))|((О|J)ТМЕНА)')
                      )
                OR
                exists( -- Или есть блокированные суммы
                        select /*+ no_unnest index(aos I_ACC_OVER_SUM_ACC_CUR_SUMTYP) no_push_subq */
                               '1'
                        from acc_over_sum aos
                        where     aos.cAosAcc = tl.cacc
                              and aos.cAosCur = tl.ccur
                              and aos.cAosSumType = 'B'
                              and aos.cAosStat = '1'
                              and (
                                    regexp_like (upper(aos.cAosComment),'(.*РЕ(Ш|Щ).*\d{1,}.*|(^\d{1,}.*)(|((№|N).*\d{1,}))).*(ОТ|JN)\s*\d{2}(,|\.|\/)\d{2}(,|\.|\/)\d.*')
                                    or
                                    upper(aos.cAosComment) like '%ИФНС%'
                                  )
                              and not upper(aos.cAosComment) like '%(ФТС)%'
                      )
              );
    -- 11.04.2017 Вахрушев - оптимизация <<<
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
        case when exists( -- существует документ на К1, ожидающий разрешения (т.е. _не_ акцепта!)
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
            and  mTrcLeft > 0 -- этого не было в переносах
            and iTrcPriority < 6
            and icus = (select iacccus from acc where caccacc = ctrnaccd and cacccur = ctrncur)
        ) then 1 else 0 end ikind
      from ubrr_data.ubrr_trc_loa a
      where cPrizn <> 'З'
      )
    where ikind > 0
      and not (cPrizn = 'Ч' and ikind = 1) -- 30358/#352 п.7;
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
    ,a.IACCOTD -->><<-- 09.01.2019    Пинаев Д.Е.       [19-64691]   Автоматическая обработка картотек
    from ubrr_data.ubrr_trc_writeoff u
    join mrk m on u.rowid = m.rmrkrowid and m.imrkmarkerid = p_marker_id
    join acc a on u.cacc = a.caccacc and a.caccprizn <> 'З'
    order by a.caccacc, a.cacccur;

  ln_acc cr_acc%rowtype;
  l_iAccCheck_saved number;
  l_idsmr xxi."trn".idsmr%type := SYS_CONTEXT ('B21', 'IDSmr');
  l_rest  number;
  l_err   varchar2(4000);
  l_enable boolean :=  triggers_ubrr.AllTriggersEnabled;
  e_acrtable exception;

  -->>-- 23.12.2020 Пинаев Д.Е. [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дня. Анализ оптимизации процесса
  resource_busy exception;
  pragma exception_init (resource_busy,-54);
  --<<-- 23.12.2020 Пинаев Д.Е. [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дня. Анализ оптимизации процесса

begin
  g_need_mail := p_need_mail;

  -- сообщаем пакету trun что не нужно производить проверку на красное сальдо - все уже проверено
  -- в других сессиях это изменение не скажется

  -- очищаем таблицу для реестра результатов операций
  delete from ubrr_data.ubrr_trc_report;  c_line := 0;

  open cr_acc; fetch cr_acc into ln_acc;
  while cr_acc% found loop
    begin

      -->>-- 23.12.2020 Пинаев Д.Е. [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дня. Анализ оптимизации процесса
      if pref.Get_Universal_Preference('AUTO_TRC_STOP_PROCESS'|| '_' ||l_idsmr,'N') = 'Y' then -->><<-- 14.01.2020 Пинаев Д.Е. [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дня
        l_err := 'Автоматическое списание остановлено. В UPS AUTO_TRC_STOP_PROCESS_'||l_idsmr||'=Y';
        raise resource_busy;
      end if;
      --<<-- 23.12.2020 Пинаев Д.Е. [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дня. Анализ оптимизации процесса

      -- если массовый перерасчет остатков - выходим
      -- по-хорошему, нужно перейти на использование блокировок из dbms_lock,
      -- и ставить таковую один раз, а не для каждого счета
      if not lock_acrtable(
        p_wait => g_need_wait_lock_acrtable,
        p_exclusive => false,
        p_idsmr => l_idsmr
      )
      then
        l_err := 'Списание прервано, поскольку в другой сессии работает массовый перерасчет оборотов..';
        raise e_acrtable;
      end if;

      -- если не удалось поставить блокировку - переходим к следующему счету
      if lock_acc(
        p_acc       => ln_acc.caccacc,
        p_cur       => ln_acc.cacccur,
        p_wait      => g_need_wait_lock_acc,
        p_idsmr     => l_idsmr
      )
      then
        -- запоминаем текущее значение iacccheck перед изменением
        l_iAccCheck_saved := ln_acc.iacccheck;

        -- временно устанавливаем iacccheck в 2 - чтобы отключить проверки в пакете trun
        -- при этом временно отключаем триггер
        if l_enable then triggers_ubrr.Set_AllTriggersDisable; end if;

        begin
          update acc set iacccheck = 2
          where caccacc = ln_acc.caccacc and cacccur = ln_acc.cacccur and idsmr = ln_acc.idsmr;
        exception when others then
          if l_enable then triggers_ubrr.Set_AllTriggersEnable; end if;
          raise;
        end;

        if l_enable then triggers_ubrr.Set_AllTriggersEnable; end if;

        -- делаем списание
        write_off_acc(
          p_acc       => ln_acc.caccacc,
          p_acc_cur   => ln_acc.cacccur,
          p_cus       => ln_acc.iacccus,
          p_kind      => ln_acc.ikind,
          p_err       => l_err,
          p_need_work => p_need_work,
          p_date_oper => p_date_oper
        );

        -- устанавливаем прежнее значение iacccheck
        -- при этом временно отключаем триггер
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
        l_err := 'Счет не обработан, занят другим пользователем. Требуется повторная обработка.';
      end if;

      if l_err is not null then
        if not regexp_like(l_err, ln_acc.caccacc) then -->><<--15.05.2019 Пинаев [19-59060.2] АБС: Изменение банковских счетов ТОФК (1часть)
           l_err := 'Счет '||ln_acc.caccacc||'. '|| l_err;
        end if; -->><<--15.05.2019 Пинаев [19-59060.2] АБС: Изменение банковских счетов ТОФК (1часть)
        add_error_info(l_err
         ,ln_acc.IACCOTD ); -->><<-- 09.01.2019    Пинаев Д.Е.       [19-64691]   Автоматическая обработка картотек
      end if;


    exception
      -->>-- 23.12.2020 Пинаев Д.Е. [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дня. Анализ оптимизации процесса
    when resource_busy then
      raise resource_busy;
      -->>-- 23.12.2020 Пинаев Д.Е. [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дня. Анализ оптимизации процесса
    when e_acrtable then
      add_error_info(l_err);
    when others then
      l_err := 'Счет '||ln_acc.caccacc||'. '|| dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || ' ';
      add_error_info(l_err
       ,ln_acc.IACCOTD ); -->><<-- 09.01.2019    Пинаев Д.Е.       [19-64691]   Автоматическая обработка картотек
    end;

    -- перевыведем на клиенте значение остатка
    l_rest := get_acc_rest(ln_acc.caccacc, ln_acc.cacccur, sysdate);

    -- выведем на экран остаток и, при необходимости, описание причины несписания
    update ubrr_data.ubrr_trc_writeoff set
      mRest = l_rest, cDescription = substr(l_err,1,256)
    where cacc = ln_acc.caccacc;

    commit; -- снимаем блокировку с записи в acc и сохраняем прочие изменения

    fetch cr_acc into ln_acc;
  end loop;


  close cr_acc;

  send_reestr; -- рассылка, если необходимо, писем, и очистка таблицы.
  commit;

  g_need_mail := 1;

exception
  -->>-- 23.12.2020 Пинаев Д.Е. [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дня. Анализ оптимизации процесса
  when resource_busy then
    add_error_info(l_err);
    if cr_acc%isopen then close cr_acc; end if;
    raise resource_busy;
  --<<-- 23.12.2020 Пинаев Д.Е. [IM2545087-001] Замедление операций на SAP CRM и других системах при закрытии дня. Анализ оптимизации процесса
  when others then
  l_err := dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || ' ';
  add_error_info(l_err
   ,ln_acc.IACCOTD ); -->><<-- 09.01.2019    Пинаев Д.Е.       [19-64691]   Автоматическая обработка картотек

  if cr_acc%isopen then close cr_acc; end if;
  g_need_mail := 1;
end;

procedure create_acrtable(
  p_idsmr  xxi."trn".idsmr%type default SYS_CONTEXT ('B21', 'IDSmr')
)
is
  pragma autonomous_transaction;
begin
  -- чтобы здесь не было ошибки, нужно или права додать или перенсти в схему xxi
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
Следующая процедура вызывается при массовом списании перед началом процесса,
поэтому нет смысла хранить парсенные курсоры, как в одноименной функции из пакета trun,
вызываемой для списания одиночных документов.
В ней устанавливается блокировка таблицы LOCK TABLE ACR_LOCK_<IdSmr>
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

-- установка блокировок нужна, чтобы предотвратить пересчет оборотов по счету в другой сессии
-- (см. пакет trun)
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



-- определение, является ли перенос документов полным
function is_full_move(
  p_marker_id in number
)
return boolean
is
  l_cnt_unselected number; -- количество неотмеченных - достаточно одного, чтобы перенос неполным был
begin
  select count(1) into l_cnt_unselected
  from ubrr_data.ubrr_trc_move u
  left join mrk m on u.rowid = m.rmrkrowid and m.imrkmarkerid = p_marker_id
  where m.rmrkrowid is null and rownum = 1;

  return (l_cnt_unselected = 0);
end;


-- заполнение временной таблицы списком счетов
--
procedure fill_loa16
is
  l_sql varchar2(4000);
  l_cond varchar2(4000) := null;

  l_krs varchar2(1) ;
  l_str_krs varchar2(1024);
  iv_cnt integer; -->><<-- 21.01.2019 Пинаев Д.Е. [20-70561] РАЗРАБОТКА: Доработка поручений на продажу валюты/драг металлов 440-П
begin

  l_krs := nvl(PREF.Get_Preference ('CARD.KRS'), '2');
  l_str_krs := '
( select null from xxi.gac
  where cgacacc = caccacc and cgaccur = cacccur  and igaccat = 333 and igacnum in (2, 3)
)
'     ;

  if l_krs = '0' then -- не КРС
    l_cond := ' and not exists ' || l_str_krs;
  elsif l_krs = '1' then -- КРС
    l_cond := ' and exists ' || l_str_krs;
  else
    null; -- если не нужно разделять, то не нужно доп.условие
  end if;

  -->> 21.01.2019 Пинаев Д.Е. [20-70561] РАЗРАБОТКА: Доработка поручений на продажу валюты/драг металлов 440-П
  select count(1) into iv_cnt from dual
  where exists
  ( select 1
    from ubrr_data.ubrr_trc_params where cparam_name= 'OTD' and cuser = user
  );

  if iv_cnt>0 then
  l_cond := l_cond || ' and iaccotd in (select iparam_value from ubrr_data.ubrr_trc_params '||
        'where cparam_name= ''OTD'' and cuser = ''' || user || ''') ';
  end if;
  --<< 21.01.2019 Пинаев Д.Е. [20-70561] РАЗРАБОТКА: Доработка поручений на продажу валюты/драг металлов 440-П

  -->> 11.03.2020 Пинаев Д.Е. [19-64691] Автоматическая обработка картотек Update
  if xxi.triggers.getuser is not null and abr.triggers.getuser is not null then
    l_cond := l_cond ||
      ' and regexp_like(cAccAcc, ''^(401|402|403|404|405|406|407|40802|40807|42309|40821)'') and cAccCur=''RUR'' ';
  end if;
  --<< 11.03.2020 Пинаев Д.Е. [19-64691] Автоматическая обработка картотек Update

  l_sql := 'INSERT INTO ubrr_data.ubrr_trc_loa(
  cacc, ccur, cname, icus, cprizn, icnt1, icnt2
  )
  (SELECT cAccAcc, cAccCur, cAccName, iAccCus, cAccPrizn, null, null
   FROM ACC
   WHERE cAccPrizn <> ''З'' ' || l_cond ||')';

  delete from ubrr_data.ubrr_trc_loa;
--dbms_output.put_line(l_sql);

  execute immediate l_sql;
end;





-- установка отметки для отделения по умолчанию на форме ubrr_otd_select
-- TODO 11/11/2016 Проверить необходимость. Если нужно - то удалить
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
--  g_dummy_d date;                 -- переменная - заглушка для дат

begin
  p_msg := null;

  if p_template_kind = 1 then    -- ФНС
--    if regexp_like(p_base, '^([*][*][*])?Реш. № \d+ от') then
    if regexp_like(p_base, '^([*]{3})?Реш. № \d+ от (\d{2}[.]\d{2}[.]\d{4})') then
      -- проверим правильность даты
      begin
        g_dummy_s := regexp_substr(p_base, '^([*]{3})?Реш. № \d+ от (\d{2}[.]\d{2}[.]\d{4})', 1, 1, 'i', 2);
        g_dummy_d := to_date(g_dummy_s,'dd.mm.rrrr');
        l_passed := true;
      exception when others then null;
      end;

      if l_passed then
        return true;
      else
        p_msg := 'Неправильный формат даты. Для выбранного инициатора значение поля "Основание" должно иметь вид "Реш. № <число> от <дата в формате ДД.ММ.ГГГГ>" либо "***Реш. № <число> от <дата в формате ДД.ММ.ГГГГ>". Например: "Реш. № 123456 от 30.01.2017"';
        return false;
      end if;
    else
      p_msg := 'Для выбранного инициатора значение поля "Основание" должно иметь вид "Реш. № <число> от <дата в формате ДД.ММ.ГГГГ>" либо "***Реш. № <число> от <дата в формате ДД.ММ.ГГГГ>". Например: "Реш. № 123456 от 30.01.2017"';
      return false;
    end if;
  elsif p_template_kind = 2 then -- банк
    return true;
  else
    return true;
  end if;
end;
-->> 17.04.2018    Киселев А.А.      17-1180      АБС: Исключение инкассовых из автоматической обработки картотек
--=================================================================
-- Функция проверяет, есть ли документы в "Отложенных платежах"
-- по Счету Дт из Картотек и Счета плательщика в Отложенных платежах
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
--<< 17.04.2018    Киселев А.А.      17-1180      АБС: Исключение инкассовых из автоматической обработки картотек

-->> 08.05.2019    Пинаев Д.Е. [19-59060.2] АБС: Изменение банковских счетов ТОФК (1часть)
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
--<< 08.05.2019    Пинаев Д.Е. [19-59060.2] АБС: Изменение банковских счетов ТОФК (1часть)

end;
/
