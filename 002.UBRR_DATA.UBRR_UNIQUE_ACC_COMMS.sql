-- Create table
create table UBRR_DATA.UBRR_UNIQUE_ACC_COMMS
(
  UUAC_ID            NUMBER not null,
  UUTA_ID            NUMBER not null,                                                    
  CACC               VARCHAR2(25) not null,  
  COM_TYPE           VARCHAR2(20) not null,               
  DAILY              VARCHAR2(1) default 'N',
  SUMM_DEF	         NUMBER(15,2),
  PERC_DEF	         NUMBER(15,2),
  MIN_SUM	           NUMBER(15,2),
  MAX_SUM	           NUMBER(15,2),
  CALC_FIELD	       VARCHAR2(4000),
  IDSMR              VARCHAR2(3) default SYS_CONTEXT ('B21', 'IDSMR')
)
tablespace USERS
;
-- Add comments to the table 
comment on table UBRR_DATA.UBRR_UNIQUE_ACC_COMMS
  is 'Таблица настройки суммы по умолчанию и периодичности ежед./ежем. для тарифа по счету (RM 20-73382)';    
-- Add comments to the columns 
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.UUAC_ID
  is 'id записи';
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.UUTA_ID
  is 'id записи UBRR_DATA.UBRR_UNIQUE_TARIF_ACC';  
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.CACC
  is 'Расчетный счет клиента';
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.COM_TYPE
  is 'id комиссии';
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.DAILY
  is 'Ежедневные. (Y/N)';
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.SUMM_DEF
  is 'Сумма комиссии по умолчанию';
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.PERC_DEF
  is 'Процент комиссии по умолчанию';
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.MIN_SUM
  is 'Минимальная сумма комиссии';
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.MAX_SUM
  is 'Максимальная сумма комиссии';
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.CALC_FIELD
  is 'Поле для указания условий SQL - запроса';
comment on column UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.IDSMR
  is 'Филиал';  
-- Create/Recreate primary, unique and foreign key constraints 
alter table UBRR_DATA.UBRR_UNIQUE_ACC_COMMS
  add constraint UBRR_UNIQUE_ACC_COMMS_PK primary key (UUAC_ID)
  using index 
  tablespace INDEXES
;
alter table UBRR_DATA.UBRR_UNIQUE_ACC_COMMS
  add constraint UBRR_UNIQUE_ACC_COMMS_UUAC_FK foreign key (UUTA_ID) 
  references UBRR_DATA.UBRR_UNIQUE_TARIF_ACC (UUTA_ID);
alter table UBRR_DATA.UBRR_UNIQUE_ACC_COMMS
  add constraint UBRR_UNIQUE_ACC_COMMS_CT_FK foreign key (COM_TYPE) 
  references UBRR_DATA.UBRR_RKO_COM_TYPES (COM_TYPE);  
-- Create/Recreate indexes 
create index UBRR_DATA.UBRR_UNIQUE_ACC_COMMSFK1_IDX on UBRR_DATA.UBRR_UNIQUE_ACC_COMMS (UUTA_ID)
  tablespace INDEXES
;
create index UBRR_DATA.UBRR_UNIQUE_ACC_COMMSFK2_IDX on UBRR_DATA.UBRR_UNIQUE_ACC_COMMS (COM_TYPE)
  tablespace INDEXES
;  
create index UBRR_DATA.UBRR_UNIQUE_ACC_COMMS1_IDX on UBRR_DATA.UBRR_UNIQUE_ACC_COMMS (IDSMR)
  tablespace INDEXES
;
create index UBRR_DATA.UBRR_UNIQUE_ACC_COMMS2_IDX on UBRR_DATA.UBRR_UNIQUE_ACC_COMMS (CACC)
  tablespace INDEXES
; 
-- Create sequence 
create sequence UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SEQ
minvalue 1
maxvalue 9999999999999999999999999999
start with 1
increment by 1
nocache;
 -- Create the synonym 
create or replace public synonym UBRR_UNIQUE_ACC_COMMS for UBRR_DATA.UBRR_UNIQUE_ACC_COMMS; 
-- Grant/Revoke object privileges 
grant select, insert, update, delete on UBRR_DATA.UBRR_UNIQUE_ACC_COMMS to ODB;
/
CREATE OR REPLACE TRIGGER UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_BR_I_TRG 
BEFORE INSERT
ON UBRR_DATA.UBRR_UNIQUE_ACC_COMMS
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
BEGIN
    IF  :NEW.UUAC_ID IS NULL THEN
       :NEW.UUAC_ID := UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_SEQ.nextval;
    END IF;
END UBRR_UNIQUE_ACC_COMMS_BR_I_TRG;
/
create or replace trigger ubrr_data.UBRR_UNIQUE_TARIF_ACC2_ARI_TRG
    after insert or update or delete
    on UBRR_DATA.UBRR_UNIQUE_TARIF_ACC
    referencing new as new old as old
    for each row
declare
begin
  if updating then
    IF :old.cacc <> :new.cacc then
      update UBRR_DATA.UBRR_UNIQUE_ACC_COMMS
         set UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.CACC = :new.cacc
       where UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.UUTA_ID = :new.uuta_id;
     END IF;    
  end if;
end UBRR_UNIQUE_TARIF_ACC2_ARI_TRG;
/
