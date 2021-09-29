-- Create table
create table UBRR_DATA.UBRR_SBS_NEW_AUD
(
  AUD_ID             NUMBER not null,
  AUD_ACT            VARCHAR2(1) not null,
  AUD_USER           VARCHAR2(50) default USER,
  AUD_DATE           DATE default sysdate,  
  AUD_ID_SBS_NEW     NUMBER not null,
  AUD_FIELD          VARCHAR2(200),
  AUD_OLD_VL         VARCHAR2(2000),
  AUD_NEW_VL         VARCHAR2(2000)

)
tablespace USERS
;
-- Add comments to the table 
comment on table UBRR_DATA.UBRR_SBS_NEW_AUD
  is 'Аудит таблицы ubrr_data.Ubrr_Sbs_New (DKBPA-1571)';     
-- Add comments to the columns
comment on column UBRR_DATA.UBRR_SBS_NEW_AUD.AUD_ID
  is 'id записи';
comment on column UBRR_DATA.UBRR_SBS_NEW_AUD.AUD_ACT
  is 'Тип действия: I – добавление, D – удаление, U – изменение';
comment on column UBRR_DATA.UBRR_SBS_NEW_AUD.AUD_USER
  is 'Пользователя, кто совершил действие';
comment on column UBRR_DATA.UBRR_SBS_NEW_AUD.AUD_DATE
  is 'Дата изменения';
comment on column UBRR_DATA.UBRR_SBS_NEW_AUD.AUD_ID_SBS_NEW
  is 'ID записи в ubrr_data.Ubrr_Sbs_New';      
comment on column UBRR_DATA.UBRR_SBS_NEW_AUD.AUD_FIELD
  is 'Изменяемое поле';
comment on column UBRR_DATA.UBRR_SBS_NEW_AUD.AUD_OLD_VL
  is 'Старое значение';  
comment on column UBRR_DATA.UBRR_SBS_NEW_AUD.AUD_NEW_VL
  is 'Новое значение'; 

-- Create/Recreate primary, unique and foreign key constraints 
create unique index UBRR_DATA.UBRR_SBS_NEW_AUD_PK on UBRR_DATA.UBRR_SBS_NEW_AUD (AUD_ID)
  tablespace indexes;	
alter table UBRR_DATA.UBRR_SBS_NEW_AUD
  add constraint UBRR_SBS_NEW_AUD_PK primary key (AUD_ID)
  using index UBRR_DATA.UBRR_SBS_NEW_AUD_PK;   
-- Create/Recreate indexes 
create index UBRR_DATA.UBRR_SBS_NEW_AUD1_IDX on UBRR_DATA.UBRR_SBS_NEW_AUD (AUD_ID_SBS_NEW)
  tablespace INDEXES
;
create index UBRR_DATA.UBRR_SBS_NEW_AUD2_IDX on UBRR_DATA.UBRR_SBS_NEW_AUD (AUD_USER,AUD_DATE)
  tablespace INDEXES
;     
-- Create sequence 
create sequence UBRR_DATA.UBRR_SBS_NEW_AUD_SEQ
minvalue 1
maxvalue 9999999999999999999999999999
start with 1
increment by 1
nocache;   
 -- Create the synonym 
create or replace public synonym UBRR_SBS_NEW_AUD for UBRR_DATA.UBRR_SBS_NEW_AUD;
-- Grant/Revoke object privileges 
grant select, insert, update, delete on UBRR_DATA.UBRR_SBS_NEW_AUD to ODB;
/
CREATE OR REPLACE TRIGGER UBRR_DATA.UBRR_SBS_NEW_AUD_BR_TRG 
BEFORE INSERT
ON UBRR_DATA.UBRR_SBS_NEW_AUD
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
BEGIN
    IF  :NEW.AUD_ID IS NULL THEN
       :NEW.AUD_ID := UBRR_DATA.UBRR_SBS_NEW_AUD_SEQ.nextval;
    END IF;
END UBRR_SBS_NEW_AUD_BR_TRG;
/


