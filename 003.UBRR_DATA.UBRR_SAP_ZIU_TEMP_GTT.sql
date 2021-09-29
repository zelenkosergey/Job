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
  is '��������� ������� ��� ��������� �������� ������ �� SAP � ������ DKBPA-105 (���������� ���:������ ������������. ��� ��� �������� �� �������� �����)';
-- Add comments to the columns 
comment on column UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.nagrid
  is '����� ��������';
comment on column UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.cchangetype
  is '��� ���������� (GR_REPAY - ������ �������, GR_LIMIT - ������ ��������� ������, CH_ZALOG - ��������� ����� ������)';  
comment on column UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.npart
  is '����� �����';
comment on column UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.cterm
  is '������������� �������';
comment on column UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.msum
  is '�����';
comment on column UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.dgrdate
  is '���� �������'; 
comment on column UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.catribut
  is '����� ��������� ������';    
comment on column UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT.dchangedate
  is '���� ��������� �������';   
 -- Create the synonym 
create or replace public synonym UBRR_SAP_ZIU_TEMP_GTT for UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT;
-- Grant/Revoke object privileges 
grant select, insert, update, delete, alter on UBRR_DATA.UBRR_SAP_ZIU_TEMP_GTT to ODB;  

