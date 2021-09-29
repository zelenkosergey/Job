-- Create table
create global temporary table UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT
(
  nagrid        NUMBER(12,3),
  cchangetype   VARCHAR2(8),
  npart         NUMBER(3) default 0,
  cterm         VARCHAR2(8),
  msum          NUMBER(16,2),
  dgrdate       DATE,
  catribut      VARCHAR2(40),  
  dchangedate   DATE
)
on commit preserve rows;
-- Add comments to the table 
comment on table UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT
  is 'Временная таблица для временого хранения данных из SAP в рамках DKBPA-105 (Репликация АБС:Формат распоряжения. ЗИУ для кредитов по короткой схеме)';
-- Add comments to the columns 
comment on column UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.nagrid
  is 'Номер договора';
comment on column UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.cchangetype
  is 'Тип измененния (GR_REPAY - График гашения, GR_LIMIT - График изменения лимита, CH_ZALOG - Изменение суммы залога)';  
comment on column UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.npart
  is 'Номер части';
comment on column UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.cterm
  is 'Идентификатор условия';
comment on column UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.msum
  is 'Сумма';
comment on column UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.dgrdate
  is 'Дата графика'; 
comment on column UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.catribut
  is 'Номер документа залога';    
comment on column UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.dchangedate
  is 'Дата изменения условия';   
 -- Create the synonym 
create or replace public synonym UBRR_SAP_ZIU_TEMP_GTT for UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT;
-- Grant/Revoke object privileges 
grant select, insert, update, delete, alter on UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT to ODB;  

