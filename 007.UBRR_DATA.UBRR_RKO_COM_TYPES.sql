alter table UBRR_DATA.UBRR_RKO_COM_TYPES 
add  
( MODIFY_FREQ_UNIQUE number ,
  TARIF_USED_UNIQUE  number default 0,
  IDSMR_USED         varchar2(100)
);
-- Add comments to the columns 
comment on column UBRR_DATA.UBRR_RKO_COM_TYPES.MODIFY_FREQ_UNIQUE
  is 'Признак возможности изменения периодичности взимания комиссии в настройках индивидуальных тарифов 1-Да, 0-Нет';
-- Add comments to the columns 
comment on column UBRR_DATA.UBRR_RKO_COM_TYPES.TARIF_USED_UNIQUE
  is 'Признак использования данного тарифа для индивидуальных настроек 1-Да, 0-Нет';  
-- Add comments to the columns 
comment on column UBRR_DATA.UBRR_RKO_COM_TYPES.IDSMR_USED
  is 'В каком банке используется комиссия, 1 - УБРиР, 16 - ВУЗ-банк (Указываем филиалы через запятую: 1,16)';    
/  
