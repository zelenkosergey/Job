-- Create table
create table UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM
(
  UUACS_ID           NUMBER not null,
  UUAC_ID            NUMBER not null, 
  SUMM               NUMBER(15,2),
  PERC	             NUMBER(15,2),
  MIN_SUMM	         NUMBER(15,2),
  MAX_SUMM	         NUMBER(15,2),  
  HIGH_BORDER	       NUMBER(15,2),
  MIN_SUMM_OPER	     NUMBER(15,2),
  MAX_SUMM_OPER	     NUMBER(15,2),  
  IDSMR              VARCHAR2(3) default SYS_CONTEXT ('B21', 'IDSMR')
)
tablespace USERS
;
-- Add comments to the table 
comment on table UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM
  is 'Таблица дополнительной настройки сумм и границ для процентов для тарифа по счету (RM 20-73382)';      
-- Add comments to the columns 
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM.UUACS_ID
  is 'id записи';
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM.UUAC_ID
  is 'id записи UBRR_DATA.UBRR_UNIQUE_ACC_COMMS';  
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM.SUMM
  is 'Сумма комиссии при границе суммы';
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM.PERC
  is 'Процент комиссии при границе суммы';
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM.MIN_SUMM
  is 'Минимальная сумма комиссии';
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM.MAX_SUMM
  is 'Максимальная сумма комиссии';  
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM.HIGH_BORDER
  is 'Граница суммы при границе суммы';
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM.MIN_SUMM_OPER
  is 'Минимальная сумма операций';
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM.MAX_SUMM_OPER
  is 'Максимальная сумма операций';  
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM.IDSMR
  is 'Филиал';    
-- Create/Recreate primary, unique and foreign key constraints 
alter table UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM
  add constraint UBRR_UNIQUE_ACC_COMMS_S_PK primary key (UUACS_ID)
  using index 
  tablespace INDEXES
;
alter table UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM
  add constraint UBRR_UNIQUE_ACC_COMMSSUUAC_FK foreign key (UUAC_ID) 
  references UBRR_DATA.UBRR_UNIQUE_ACC_COMMS (UUAC_ID); 
-- Create/Recreate indexes 
create index UBRR_DATA.UBRR_UNIQUE_ACC_COMMSS1_IDX on UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM (IDSMR)
  tablespace INDEXES
;
create index UBRR_DATA.UBRR_UNIQUE_ACC_COMMSSFK1_IDX on UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM (UUAC_ID)
  tablespace INDEXES
;  
-- Create sequence 
create sequence UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM_SEQ
minvalue 1
maxvalue 9999999999999999999999999999
start with 1
increment by 1
nocache;
 -- Create the synonym 
create or replace public synonym UBRR_UNIQUE_ACC_COMMS_SUMM for UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM;
-- Grant/Revoke object privileges 
grant select, insert, update, delete on UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM to ODB;
/
CREATE OR REPLACE TRIGGER UBRR_DATA.UBRR_UNIQUE_ACC_COMMSS_BRI_TRG 
BEFORE INSERT
ON UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
BEGIN
    IF  :NEW.UUACS_ID IS NULL THEN
       :NEW.UUACS_ID := UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SUMM_SEQ.nextval;
    END IF;
END UBRR_UNIQUE_ACC_COMMSS_BRI_TRG;
/
