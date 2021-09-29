-- Create table
create table UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD
(
  AUD_ID             NUMBER not null,
  AUD_TABLE          VARCHAR2(50),
  AUD_TABLE_ID       NUMBER,
  IUSRID             NUMBER,
  USERCHANGE         VARCHAR2(50) default USER,
  FIELD              VARCHAR2(200),
  OLD_VL             VARCHAR2(50),
  NEW_VL             VARCHAR2(50),
  OPER	             CHAR(1),			
  DATECHANGE         DATE default sysdate
)
tablespace USERS
;
-- Add comments to the table 
comment on table UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD
  is 'Таблица аудита (RM 20-73382)';     
-- Add comments to the columns
comment on column UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.AUD_ID
  is 'id записи';
comment on column UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.AUD_TABLE
  is 'Таблица по которой пишется аудит';
comment on column UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.AUD_TABLE_ID
  is 'ID записи таблица по которой пишется аудит';
comment on column UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.IUSRID
  is 'Идентификатор пользователяи';
comment on column UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.USERCHANGE
  is 'Пользователя';
comment on column UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.FIELD
  is 'Изменяемое поле';
comment on column UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.OLD_VL
  is 'Старое значение';  
comment on column UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.NEW_VL
  is 'Новое значение';
comment on column UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.OPER
  is 'Тип действия(I,U,D)';   
comment on column UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.DATECHANGE
  is 'Дата изменения';    
-- Create/Recreate indexes 
create index UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD1_IDX on UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD (AUD_TABLE,AUD_TABLE_ID)
  tablespace INDEXES
;
create index UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD2_IDX on UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD (AUD_TABLE)
  tablespace INDEXES
;     
-- Create sequence 
create sequence UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD_SEQ
minvalue 1
maxvalue 9999999999999999999999999999
start with 1
increment by 1
nocache;   
 -- Create the synonym 
create or replace public synonym UBRR_UNIQUE_TARIF_ACC_AUD for UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD;
-- Grant/Revoke object privileges 
grant select, insert, update, delete on UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD to ODB;
/
CREATE OR REPLACE TRIGGER UBRR_DATA.UBRR_UNIQUE_TARIF_ACAUD_TRG 
BEFORE INSERT
ON UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
BEGIN
    IF  :NEW.AUD_ID IS NULL THEN
       :NEW.AUD_ID := UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD_SEQ.nextval;
    END IF;
END UBRR_UNIQUE_TARIF_ACAUD_TRG;
/
create or replace trigger UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AR_I_TRG
    after insert or update or delete
    on UBRR_DATA.UBRR_UNIQUE_TARIF_ACC
    referencing new as new old as old
    for each row
declare
  l_uname   constant UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.USERCHANGE%type := user;
  l_mdate   constant UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.DATECHANGE%type := sysdate;

  type t_tab_au is table of UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD%rowtype index by pls_integer;
  l_tab_au            t_tab_au;
  
  cursor cur_userid(p_user   usr.cusrlogname%type) is
  select iusrid 
    from usr
    where cusrlogname = coalesce(p_user,user);
    
  l_uuta_id     UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.UUTA_ID%type; 
  l_iusrid      UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.IUSRID%type;
  
  function n2v(p in number)
      return varchar2
  is
  begin
      return to_char(p, 'FM9999999999999990D00', 'NLS_NUMERIC_CHARACTERS = ''. ''');
  end;

  function d2v(p in date)
      return varchar2
  is
  begin
      return to_char(p, 'dd.mm.yyyy');
  end;  

  procedure add_au(p_field       in varchar2,
                   p_old_value   in varchar2,
                   p_new_value   in varchar2,
                   p_oper        in varchar2,
                   p_check       in boolean default false
                   )
   is
   idx   pls_integer := l_tab_au.count + 1;
  begin
      if not p_check or (p_check and nvl(p_old_value, '#') != nvl(p_new_value, '#')) then     
        l_tab_au(idx).aud_table    := 'UBRR_UNIQUE_TARIF_ACC';
        l_tab_au(idx).aud_table_id := l_uuta_id;
        l_tab_au(idx).iusrid       := l_iusrid;
        l_tab_au(idx).userchange   := l_uname;         
        l_tab_au(idx).field        := p_field;
        l_tab_au(idx).old_vl       := p_old_value;
        l_tab_au(idx).new_vl       := p_new_value;
        l_tab_au(idx).oper         := p_oper;
        l_tab_au(idx).datechange   := l_mdate;
      end if;
  end add_au;

begin
  
  open cur_userid(l_uname);
  fetch cur_userid into l_iusrid;
  close cur_userid;
          
  if deleting then
      l_uuta_id := :old.uuta_id;
  else
      l_uuta_id := :new.uuta_id;
  end if;

  if inserting then
      add_au('CACC', :old.cacc, :new.cacc, 'I');
      add_au('DOPENTARIF', d2v(:old.dopentarif), d2v(:new.dopentarif), 'I');
      add_au('DCANCELTARIF', d2v(:old.dcanceltarif), d2v(:new.dcanceltarif), 'I');
      add_au('STATUS', :old.status, :new.status, 'I');
  elsif updating then
      add_au('CACC', :old.cacc, :new.cacc, 'U', true);
      add_au('DOPENTARIF', d2v(:old.dopentarif), d2v(:new.dopentarif), 'U', true);
      add_au('DCANCELTARIF', d2v(:old.dcanceltarif), d2v(:new.dcanceltarif), 'U', true);
      add_au('STATUS', :old.status, :new.status, 'U', true);
  elsif deleting then
      add_au('CACC', :old.cacc, :new.cacc, 'D');
      add_au('DOPENTARIF', d2v(:old.dopentarif), d2v(:new.dopentarif), 'D');
      add_au('DCANCELTARIF', d2v(:old.dcanceltarif), d2v(:new.dcanceltarif), 'D');
      add_au('STATUS', :old.status, :new.status, 'D');      
  end if;

  if l_tab_au.count > 0 then
      forall idx in l_tab_au.first .. l_tab_au.last
          insert into UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD
          values l_tab_au(idx);
  end if;
end UBRR_UNIQUE_TARIF_ACC_AR_I_TRG;
/
create or replace trigger UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_AR_I_TRG
    after insert or update or delete
    on UBRR_DATA.UBRR_UNIQUE_ACC_COMMS
    referencing new as new old as old
    for each row
declare
  l_uname   constant UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.USERCHANGE%type := user;
  l_mdate   constant UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.DATECHANGE%type := sysdate;

  type t_tab_au is table of UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD%rowtype index by pls_integer;
  l_tab_au            t_tab_au;
  
  cursor cur_userid(p_user   usr.cusrlogname%type) is
  select iusrid 
    from usr
    where cusrlogname = coalesce(p_user,user);
    
  l_uuac_id     UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.UUAC_ID%type; 
  l_iusrid      UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.IUSRID%type;
  
  function n2v(p in number)
      return varchar2
  is
  begin
      return to_char(p, 'FM9999999999999990D00', 'NLS_NUMERIC_CHARACTERS = ''. ''');
  end;

  function d2v(p in date)
      return varchar2
  is
  begin
      return to_char(p, 'dd.mm.yyyy');
  end;  

  procedure add_au(p_field       in varchar2,
                   p_old_value   in varchar2,
                   p_new_value   in varchar2,
                   p_oper        in varchar2,
                   p_check       in boolean default false
                   )
   is
   idx   pls_integer := l_tab_au.count + 1;
  begin
      if not p_check or (p_check and nvl(p_old_value, '#') != nvl(p_new_value, '#')) then     
        l_tab_au(idx).aud_table    := 'UBRR_UNIQUE_ACC_COMMS';
        l_tab_au(idx).aud_table_id := l_uuac_id;
        l_tab_au(idx).iusrid       := l_iusrid;
        l_tab_au(idx).userchange   := l_uname;         
        l_tab_au(idx).field        := p_field;
        l_tab_au(idx).old_vl       := p_old_value;
        l_tab_au(idx).new_vl       := p_new_value;
        l_tab_au(idx).oper         := p_oper;
        l_tab_au(idx).datechange   := l_mdate;
      end if;
  end add_au;

begin
  
  open cur_userid(l_uname);
  fetch cur_userid into l_iusrid;
  close cur_userid;
          
  if deleting then
      l_uuac_id := :old.uuac_id;
  else
      l_uuac_id := :new.uuac_id;
  end if;

  if inserting then
      add_au('CACC', :old.cacc, :new.cacc, 'I');
      add_au('COM_TYPE', :old.com_type, :new.com_type, 'I');
      add_au('DAILY', :old.daily, :new.daily, 'I');
      add_au('SUMM_DEF', n2v(:old.summ_def), n2v(:new.summ_def), 'I');
      add_au('PERC_DEF', n2v(:old.perc_def), n2v(:new.perc_def), 'I');
      add_au('MIN_SUM', n2v(:old.min_sum), n2v(:new.min_sum), 'I');
      add_au('MAX_SUM', n2v(:old.max_sum), n2v(:new.max_sum), 'I'); 
  elsif updating then
      add_au('CACC', :old.cacc, :new.cacc, 'U', true);
      add_au('COM_TYPE', :old.com_type, :new.com_type, 'U', true);
      add_au('DAILY', :old.daily, :new.daily, 'U', true);
      add_au('SUMM_DEF',  n2v(:old.summ_def), n2v(:new.summ_def), 'U', true);
      add_au('PERC_DEF', n2v(:old.perc_def), n2v(:new.perc_def), 'U', true);
      add_au('MIN_SUM', n2v(:old.min_sum), n2v(:new.min_sum), 'U', true);
      add_au('MAX_SUM', n2v(:old.max_sum), n2v(:new.max_sum), 'U', true);
  elsif deleting then
      add_au('CACC', :old.cacc, :new.cacc, 'D');
      add_au('COM_TYPE', :old.com_type, :new.com_type, 'D');
      add_au('DAILY', :old.daily, :new.daily, 'D');
      add_au('SUMM_DEF',  n2v(:old.summ_def), n2v(:new.summ_def), 'D');
      add_au('PERC_DEF', n2v(:old.perc_def), n2v(:new.perc_def), 'D');
      add_au('MIN_SUM', n2v(:old.min_sum), n2v(:new.min_sum), 'D');
      add_au('MAX_SUM', n2v(:old.max_sum), n2v(:new.max_sum), 'D');  
  end if;

  if l_tab_au.count > 0 then
      forall idx in l_tab_au.first .. l_tab_au.last
          insert into UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD
          values l_tab_au(idx);
  end if;
end UBRR_UNIQUE_ACC_COMMS_AR_I_TRG;
/
create or replace trigger UBRR_DATA.UBRR_UNIQUE_ACC_COMMSS_ARI_TRG
    after insert or update or delete
    on UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM
    referencing new as new old as old
    for each row
declare
  l_uname   constant UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.USERCHANGE%type := user;
  l_mdate   constant UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.DATECHANGE%type := sysdate;

  type t_tab_au is table of UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD%rowtype index by pls_integer;
  l_tab_au            t_tab_au;
  
  cursor cur_userid(p_user   usr.cusrlogname%type) is
  select iusrid 
    from usr
    where cusrlogname = coalesce(p_user,user);
    
  l_uuacs_id    UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM.UUACS_ID%type; 
  l_iusrid      UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.IUSRID%type;
  
  function n2v(p in number)
      return varchar2
  is
  begin
      return to_char(p, 'FM9999999999999990D00', 'NLS_NUMERIC_CHARACTERS = ''. ''');
  end;

  function d2v(p in date)
      return varchar2
  is
  begin
      return to_char(p, 'dd.mm.yyyy');
  end;  

  procedure add_au(p_field       in varchar2,
                   p_old_value   in varchar2,
                   p_new_value   in varchar2,
                   p_oper        in varchar2,
                   p_check       in boolean default false
                   )
   is
   idx   pls_integer := l_tab_au.count + 1;
  begin
      if not p_check or (p_check and nvl(p_old_value, '#') != nvl(p_new_value, '#')) then     
        l_tab_au(idx).aud_table    := 'UBRR_UNIQUE_ACC_COMMS_SUMM';
        l_tab_au(idx).aud_table_id := l_uuacs_id;
        l_tab_au(idx).iusrid       := l_iusrid;
        l_tab_au(idx).userchange   := l_uname;         
        l_tab_au(idx).field        := p_field;
        l_tab_au(idx).old_vl       := p_old_value;
        l_tab_au(idx).new_vl       := p_new_value;
        l_tab_au(idx).oper         := p_oper;
        l_tab_au(idx).datechange   := l_mdate;
      end if;
  end add_au;

begin
  
  open cur_userid(l_uname);
  fetch cur_userid into l_iusrid;
  close cur_userid;
          
  if deleting then
      l_uuacs_id := :old.uuacs_id;
  else
      l_uuacs_id := :new.uuacs_id;
  end if;

  if inserting then
      add_au('SUMM', n2v(:old.summ), n2v(:new.summ), 'I');
      add_au('PERC', n2v(:old.perc), n2v(:new.perc), 'I');
      add_au('MIN_SUMM', n2v(:old.min_summ), n2v(:new.min_summ), 'I');
      add_au('MAX_SUMM', n2v(:old.max_summ), n2v(:new.max_summ), 'I');       
      add_au('HIGH_BORDER', n2v(:old.high_border), n2v(:new.high_border), 'I');
      add_au('MIN_SUMM_OPER', n2v(:old.min_summ_oper), n2v(:new.min_summ_oper), 'I');
      add_au('MAX_SUMM_OPER', n2v(:old.max_summ_oper), n2v(:new.max_summ_oper), 'I');       
  elsif updating then
      add_au('SUMM', n2v(:old.summ), n2v(:new.summ), 'U', true);
      add_au('PERC', n2v(:old.perc), n2v(:new.perc), 'U', true);
      add_au('MIN_SUMM', n2v(:old.min_summ), n2v(:new.min_summ), 'U', true);
      add_au('MAX_SUMM', n2v(:old.max_summ), n2v(:new.max_summ), 'U', true);
      add_au('HIGH_BORDER', n2v(:old.high_border), n2v(:new.high_border), 'U', true);
      add_au('MIN_SUMM_OPER', n2v(:old.min_summ_oper), n2v(:new.min_summ_oper), 'U', true);
      add_au('MAX_SUMM_OPER', n2v(:old.max_summ_oper), n2v(:new.max_summ_oper), 'U', true);                        
  elsif deleting then
      add_au('SUMM', n2v(:old.summ), n2v(:new.summ), 'D');
      add_au('PERC', n2v(:old.perc), n2v(:new.perc), 'D');
      add_au('MIN_SUMM', n2v(:old.min_summ), n2v(:new.min_summ), 'D');
      add_au('MAX_SUMM', n2v(:old.max_summ), n2v(:new.max_summ), 'D');
      add_au('HIGH_BORDER', n2v(:old.high_border), n2v(:new.high_border), 'D');
      add_au('MIN_SUMM_OPER', n2v(:old.min_summ_oper), n2v(:new.min_summ_oper), 'D');
      add_au('MAX_SUMM_OPER', n2v(:old.max_summ_oper), n2v(:new.max_summ_oper), 'D');                        
  end if;

  if l_tab_au.count > 0 then
      forall idx in l_tab_au.first .. l_tab_au.last
          insert into UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD
          values l_tab_au(idx);
  end if;
end UBRR_UNIQUE_ACC_COMMSS_ARI_TRG;
/
