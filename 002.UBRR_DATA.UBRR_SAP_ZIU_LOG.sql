-- Create table
create table UBRR_DATA.UBRR_SAP_ZIU_LOG
(
  id        NUMBER not null,
  creatdate DATE default sysdate,  
  username  VARCHAR2(30) default user not null,
  sessionid NUMBER default userenv('SessionID') not null,
  message   VARCHAR2(2000)
)
tablespace USERS;
-- Add comments to the table 
comment on table UBRR_DATA.UBRR_SAP_ZIU_LOG
  is 'Логирование изменения КД. (DKBPA-105 ЗИУ для кредитов по короткой схеме)';
-- Add comments to the columns 
comment on column UBRR_DATA.UBRR_SAP_ZIU_LOG.id
  is 'Id';
comment on column UBRR_DATA.UBRR_SAP_ZIU_LOG.creatdate
  is 'Дата создания лога';  
comment on column UBRR_DATA.UBRR_SAP_ZIU_LOG.username
  is 'Пользователь';
comment on column UBRR_DATA.UBRR_SAP_ZIU_LOG.sessionid
  is 'ID Сессии';
comment on column UBRR_DATA.UBRR_SAP_ZIU_LOG.message
  is 'Сообщение';
/ 
-- Create/Recreate primary, unique and foreign key constraints 
create unique index UBRR_DATA.UBRR_SAP_ZIU_LOG_PK on UBRR_DATA.UBRR_SAP_ZIU_LOG(ID)
  tablespace INDEXES;	
alter table UBRR_DATA.UBRR_SAP_ZIU_LOG
  add constraint UBRR_SAP_ZIU_LOG_PK primary key (ID)
  using index UBRR_DATA.UBRR_SAP_ZIU_LOG_PK; 
-- Create/Recreate indexes 
create index UBRR_DATA.UBRR_SAP_ZIU_LOG_IDX on UBRR_DATA.UBRR_SAP_ZIU_LOG(CREATDATE)
  tablespace INDEXES;
/  
-- Grant/Revoke object privileges 
grant select, insert, update, delete on UBRR_DATA.UBRR_SAP_ZIU_LOG to ODB;
/
-- Create sequence 
create sequence UBRR_DATA.UBRR_SAP_ZIU_LOG_SEQ
minvalue 1
maxvalue 999999999999999999
start with 1
increment by 1
nocache;

/
CREATE OR REPLACE TRIGGER UBRR_DATA.UBRR_SAP_ZIU_LOG_TBI
 BEFORE
  INSERT
 ON ubrr_data.UBRR_SAP_ZIU_LOG
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
DECLARE
BEGIN
  IF :NEW.ID IS NULL THEN
     :NEW.ID := UBRR_DATA.UBRR_SAP_ZIU_LOG_SEQ.NEXTVAL;
  END IF;
END UBRR_SAP_ZIU_LOG_TBI;
/
