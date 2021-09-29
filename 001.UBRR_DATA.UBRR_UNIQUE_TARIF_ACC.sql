-- Create table
create table UBRR_DATA.UBRR_UNIQUE_TARIF_ACC
(
  UUTA_ID            NUMBER not null,
  CACC               VARCHAR2(25) not null,
  DOPENTARIF         DATE,
  DCANCELTARIF       DATE,
  IDSMR              VARCHAR2(3) default SYS_CONTEXT ('B21', 'IDSMR'),
  STATUS             VARCHAR2(1) default 'N'
)
tablespace USERS
;
-- Add comments to the table 
comment on table UBRR_DATA.UBRR_UNIQUE_TARIF_ACC
  is 'Таблица счетов по периодам для настройки тарифов (RM 20-73382)';  
-- Add comments to the columns 
comment on column UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.UUTA_ID
  is 'id записи';
comment on column UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.CACC
  is 'Расчетный счет клиента';
comment on column UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.DOPENTARIF
  is 'Начало действия тарифа';
comment on column UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.DCANCELTARIF
  is 'Окончание действия тарифа';
comment on column UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.IDSMR
  is 'Филиал';
comment on column UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.STATUS
  is 'Признак удаления записи (Y/N)';  
-- Create/Recreate primary, unique and foreign key constraints 
alter table UBRR_DATA.UBRR_UNIQUE_TARIF_ACC
  add constraint UBRR_UNIQUE_TARIF_ACC_PK primary key (UUTA_ID)
  using index 
  tablespace INDEXES
;
-- Create/Recreate indexes 
create index UBRR_DATA.UBRR_UNIQUE_TARIF_ACC1_IDX on UBRR_DATA.UBRR_UNIQUE_TARIF_ACC (IDSMR,STATUS)
  tablespace INDEXES
;
-- Create/Recreate indexes 
create index UBRR_DATA.UBRR_UNIQUE_TARIF_ACC2_IDX on UBRR_DATA.UBRR_UNIQUE_TARIF_ACC (CACC,DOPENTARIF,DCANCELTARIF)
  tablespace INDEXES
;    
-- Create/Recreate indexes 
create index UBRR_DATA.UBRR_UNIQUE_TARIF_ACC3_IDX on UBRR_DATA.UBRR_UNIQUE_TARIF_ACC (IDSMR,STATUS,DCANCELTARIF)
  tablespace INDEXES
;  
-- Create sequence 
create sequence UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_SEQ
minvalue 1
maxvalue 9999999999999999999999999999
start with 1
increment by 1
nocache; 
 -- Create the synonym 
create or replace public synonym UBRR_UNIQUE_TARIF_ACC for UBRR_DATA.UBRR_UNIQUE_TARIF_ACC; 
-- Grant/Revoke object privileges 
grant select, insert, update, delete on UBRR_DATA.UBRR_UNIQUE_TARIF_ACC to ODB;
/
CREATE OR REPLACE TRIGGER UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_BR_I_TRG 
BEFORE INSERT
ON UBRR_DATA.UBRR_UNIQUE_TARIF_ACC
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
BEGIN
    IF  :NEW.UUTA_ID IS NULL THEN
       :NEW.UUTA_ID := UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_SEQ.nextval;
    END IF;
END UBRR_UNIQUE_TARIF_ACC_BR_I_TRG;
/
