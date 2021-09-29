-- Create table
create table UBRR_DATA.UBRR_BNKSERV_ONLINE_COMISS_LOG
(
  ID          NUMBER not null,
  USERNAME    VARCHAR2(30) default user not null,
  SESSIONID   NUMBER default userenv('SessionID') not null,
  DATELOG     DATE default sysdate not null,
  MESSAGE     VARCHAR2(2000),
  IDSMR       VARCHAR2(3) default SYS_CONTEXT ('B21', 'IDSmr')
)
tablespace USERS;
-- Add comments to the table 
comment on table UBRR_DATA.UBRR_BNKSERV_ONLINE_COMISS_LOG
  is 'Логирование расчета онлайн комиссий';
-- Add comments to the columns 
comment on column UBRR_DATA.UBRR_BNKSERV_ONLINE_COMISS_LOG.id
  is 'Id';
comment on column UBRR_DATA.UBRR_BNKSERV_ONLINE_COMISS_LOG.USERNAME
  is 'Пользователь';
comment on column UBRR_DATA.UBRR_BNKSERV_ONLINE_COMISS_LOG.SESSIONID
  is 'ID Сессии';
comment on column UBRR_DATA.UBRR_BNKSERV_ONLINE_COMISS_LOG.DATELOG
  is 'Дата логирования';
comment on column UBRR_DATA.UBRR_BNKSERV_ONLINE_COMISS_LOG.MESSAGE
  is 'Сообщение';
comment on column UBRR_DATA.UBRR_BNKSERV_ONLINE_COMISS_LOG.IDSMR
  is 'IDSMR';
  
-- Create/Recreate indexes 
create index UBRR_DATA.UBRR_BNKSERV_ONLINELOG_IDX on UBRR_DATA.UBRR_BNKSERV_ONLINE_COMISS_LOG (IDSMR, DATELOG)
  tablespace INDEXES;

-- Create sequence 
create sequence UBRR_DATA.UBRR_BNKSERV_ONLINELOG_SEQ
minvalue 1
maxvalue 9999999999999999999999999999
start with 1
increment by 1
nocache;   
 -- Create the synonym 
create or replace public synonym UBRR_BNKSERV_ONLINE_COMISS_LOG for UBRR_DATA.UBRR_BNKSERV_ONLINE_COMISS_LOG;
-- Grant/Revoke object privileges 
grant select, insert, update, delete on UBRR_DATA.UBRR_BNKSERV_ONLINE_COMISS_LOG to ODB;
/
CREATE OR REPLACE TRIGGER UBRR_DATA.UBRR_BNKSERV_ONLINELOG_BR_TRG 
BEFORE INSERT
ON UBRR_DATA.UBRR_BNKSERV_ONLINE_COMISS_LOG
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
BEGIN
    IF  :NEW.ID IS NULL THEN
       :NEW.ID := UBRR_DATA.UBRR_BNKSERV_ONLINELOG_SEQ.nextval;
    END IF;
END UBRR_BNKSERV_ONLINELOG_BR_TRG;
/
