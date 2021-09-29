alter table UBRR_DATA.UBRR_RKO_COM_TYPES 
add  
( MODIFY_FREQ_UNIQUE number ,
  TARIF_USED_UNIQUE  number default 0,
  IDSMR_USED         varchar2(100)
);
-- Add comments to the columns 
comment on column UBRR_DATA.UBRR_RKO_COM_TYPES.MODIFY_FREQ_UNIQUE
  is '������� ����������� ��������� ������������� �������� �������� � ���������� �������������� ������� 1-��, 0-���';
-- Add comments to the columns 
comment on column UBRR_DATA.UBRR_RKO_COM_TYPES.TARIF_USED_UNIQUE
  is '������� ������������� ������� ������ ��� �������������� �������� 1-��, 0-���';  
-- Add comments to the columns 
comment on column UBRR_DATA.UBRR_RKO_COM_TYPES.IDSMR_USED
  is '� ����� ����� ������������ ��������, 1 - �����, 16 - ���-���� (��������� ������� ����� �������: 1,16)';    
/  
