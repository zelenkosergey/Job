alter table UBRR_DATA.UBRR_SBS_NEW add 
(ITRNNUM    number,
 ITRNANUM   number);
/
-- Add comments to the columns
comment on column UBRR_DATA.UBRR_SBS_NEW.ITRNNUM
  is 'Номер ITRNNUM в TRN родительской проводки, с которой берём комиссию';
comment on column UBRR_DATA.UBRR_SBS_NEW.ITRNANUM
  is 'Номер ITRNANUM в TRN родительской проводки, с которой берём комиссию';
/  
create index UBRR_DATA.UBRR_SBS_NEW_I4 on UBRR_DATA.UBRR_SBS_NEW (ITRNNUM,ITRNANUM)
  tablespace INDEXES;   
/
create or replace trigger UBRR_DATA.UBRR_SBS_NEW_AUD_AR_TRG
  after insert or update or delete
  on UBRR_DATA.UBRR_SBS_NEW
  referencing new as new old as old
  for each row
declare
  l_id      UBRR_DATA.UBRR_SBS_NEW.ID%type; 
  l_user    constant UBRR_DATA.UBRR_SBS_NEW_AUD.AUD_USER%type := user;
  l_mdate   constant UBRR_DATA.UBRR_SBS_NEW_AUD.AUD_DATE%type := sysdate;
  
  type t_tab_au is table of UBRR_DATA.UBRR_SBS_NEW_AUD%rowtype index by pls_integer;
  l_tab_au            t_tab_au;

  function n2v(p in number)
      return varchar2
  is
  begin
      return to_char(p, 'FM9999999999999990D00', 'NLS_NUMERIC_CHARACTERS = ''. ''');
  end;

  function d2v(p in date)
      return varchar2
  is
  begin
      return to_char(p, 'dd.mm.yyyy');
  end;  

  procedure add_au(p_field       in varchar2,
                   p_old_value   in varchar2,
                   p_new_value   in varchar2,
                   p_act         in varchar2,
                   p_check       in boolean default false
                   )
   is
   idx   pls_integer := l_tab_au.count + 1;
  begin
      if not p_check or (p_check and nvl(p_old_value, '#') != nvl(p_new_value, '#')) then  
        l_tab_au(idx).aud_act         := p_act;
        l_tab_au(idx).aud_user        := l_user;         
        l_tab_au(idx).aud_date        := l_mdate;
        l_tab_au(idx).aud_id_sbs_new  := l_id;
        l_tab_au(idx).aud_field       := p_field;
        l_tab_au(idx).aud_old_vl      := p_old_value;
        l_tab_au(idx).aud_new_vl      := p_new_value;
      end if;
  end add_au;

begin
          
  if deleting then
      l_id := :old.id;
  else
      l_id := :new.id;
  end if;

/*  if inserting then
    add_au('IHOLD', n2v(:OLD.IHOLD), n2v(:NEW.IHOLD), 'I');
    add_au('ID', n2v(:OLD.ID), n2v(:NEW.ID), 'I');
    add_au('ITRNNUM', n2v(:OLD.ITRNNUM), n2v(:NEW.ITRNNUM), 'I');
    add_au('ITRNANUM', n2v(:OLD.ITRNANUM), n2v(:NEW.ITRNANUM), 'I');
    add_au('CCOMMENT', :OLD.CCOMMENT, :NEW.CCOMMENT, 'I');
    add_au('IDSMR_TO', :OLD.IDSMR_TO, :NEW.IDSMR_TO, 'I');
    add_au('MFR_ERR', :OLD.MFR_ERR, :NEW.MFR_ERR, 'I');
    add_au('TARIF_ID', n2v(:OLD.TARIF_ID), n2v(:NEW.TARIF_ID), 'I');
    add_au('DSBSDATEREG', d2v(:OLD.DSBSDATEREG), d2v(:NEW.DSBSDATEREG), 'I');
    add_au('CSBSPACK', :OLD.CSBSPACK, :NEW.CSBSPACK, 'I');
    add_au('MSBSTARIF', n2v(:OLD.MSBSTARIF), n2v(:NEW.MSBSTARIF), 'I');
    add_au('MSBSTARIFPRC', n2v(:OLD.MSBSTARIFPRC), n2v(:NEW.MSBSTARIFPRC), 'I');
    add_au('MSBSSUMBEFO', n2v(:OLD.MSBSSUMBEFO), n2v(:NEW.MSBSSUMBEFO), 'I');
    add_au('DSBSDATE', d2v(:OLD.DSBSDATE), d2v(:NEW.DSBSDATE), 'I');
    add_au('ISBSTYPECOM', n2v(:OLD.ISBSTYPECOM), n2v(:NEW.ISBSTYPECOM), 'I');
    add_au('CSBSTYPECOM', :OLD.CSBSTYPECOM, :NEW.CSBSTYPECOM, 'I');
    add_au('CSBSACCD', :OLD.CSBSACCD, :NEW.CSBSACCD, 'I');
    add_au('CSBSCURD', :OLD.CSBSCURD, :NEW.CSBSCURD, 'I');
    add_au('CSBSACCD_ZAM', :OLD.CSBSACCD_ZAM, :NEW.CSBSACCD_ZAM, 'I');
    add_au('CSBSCURD_ZAM', :OLD.CSBSCURD_ZAM, :NEW.CSBSCURD_ZAM, 'I');
    add_au('CSBSACCC', :OLD.CSBSACCC, :NEW.CSBSACCC, 'I');
    add_au('CSBSCURC', :OLD.CSBSCURC, :NEW.CSBSCURC, 'I');
    add_au('MSBSSUMPAYS', n2v(:OLD.MSBSSUMPAYS), n2v(:NEW.MSBSSUMPAYS), 'I');
    add_au('ISBSCOUNTPAYS', n2v(:OLD.ISBSCOUNTPAYS), n2v(:NEW.ISBSCOUNTPAYS), 'I');
    add_au('MSBSSUMCOM', n2v(:OLD.MSBSSUMCOM), n2v(:NEW.MSBSSUMCOM), 'I');
    add_au('ISBSTRNNUM', n2v(:OLD.ISBSTRNNUM), n2v(:NEW.ISBSTRNNUM), 'I');
    add_au('CSBSSTAT', :OLD.CSBSSTAT, :NEW.CSBSSTAT, 'I');
    add_au('ISBSTRNTRC', n2v(:OLD.ISBSTRNTRC), n2v(:NEW.ISBSTRNTRC), 'I');
    add_au('ISBSOTDNUM', n2v(:OLD.ISBSOTDNUM), n2v(:NEW.ISBSOTDNUM), 'I');
    add_au('ISBSDOCNUM', n2v(:OLD.ISBSDOCNUM), n2v(:NEW.ISBSDOCNUM), 'I');
    add_au('ISBSBATNUM', n2v(:OLD.ISBSBATNUM), n2v(:NEW.ISBSBATNUM), 'I');
    add_au('DSBSSYSDATE', d2v(:OLD.DSBSSYSDATE), d2v(:NEW.DSBSSYSDATE), 'I');
    add_au('IDSMR', :OLD.IDSMR, :NEW.IDSMR, 'I');
  end if;
  
  if updating then
    add_au('IHOLD', n2v(:OLD.IHOLD), n2v(:NEW.IHOLD), 'U', true);
    add_au('ID', n2v(:OLD.ID), n2v(:NEW.ID), 'U', true);
    add_au('ITRNNUM', n2v(:OLD.ITRNNUM), n2v(:NEW.ITRNNUM), 'U', true);
    add_au('ITRNANUM', n2v(:OLD.ITRNANUM), n2v(:NEW.ITRNANUM), 'U', true);
    add_au('CCOMMENT', :OLD.CCOMMENT, :NEW.CCOMMENT, 'U', true);
    add_au('IDSMR_TO', :OLD.IDSMR_TO, :NEW.IDSMR_TO, 'U', true);
    add_au('MFR_ERR', :OLD.MFR_ERR, :NEW.MFR_ERR, 'U', true);
    add_au('TARIF_ID', n2v(:OLD.TARIF_ID), n2v(:NEW.TARIF_ID), 'U', true);
    add_au('DSBSDATEREG', d2v(:OLD.DSBSDATEREG), d2v(:NEW.DSBSDATEREG), 'U', true);
    add_au('CSBSPACK', :OLD.CSBSPACK, :NEW.CSBSPACK, 'U', true);
    add_au('MSBSTARIF', n2v(:OLD.MSBSTARIF), n2v(:NEW.MSBSTARIF), 'U', true);
    add_au('MSBSTARIFPRC', n2v(:OLD.MSBSTARIFPRC), n2v(:NEW.MSBSTARIFPRC), 'U', true);
    add_au('MSBSSUMBEFO', n2v(:OLD.MSBSSUMBEFO), n2v(:NEW.MSBSSUMBEFO), 'U', true);
    add_au('DSBSDATE', d2v(:OLD.DSBSDATE), d2v(:NEW.DSBSDATE), 'U', true);
    add_au('ISBSTYPECOM', n2v(:OLD.ISBSTYPECOM), n2v(:NEW.ISBSTYPECOM), 'U', true);
    add_au('CSBSTYPECOM', :OLD.CSBSTYPECOM, :NEW.CSBSTYPECOM, 'U', true);
    add_au('CSBSACCD', :OLD.CSBSACCD, :NEW.CSBSACCD, 'U', true);
    add_au('CSBSCURD', :OLD.CSBSCURD, :NEW.CSBSCURD, 'U', true);
    add_au('CSBSACCD_ZAM', :OLD.CSBSACCD_ZAM, :NEW.CSBSACCD_ZAM, 'U', true);
    add_au('CSBSCURD_ZAM', :OLD.CSBSCURD_ZAM, :NEW.CSBSCURD_ZAM, 'U', true);
    add_au('CSBSACCC', :OLD.CSBSACCC, :NEW.CSBSACCC, 'U', true);
    add_au('CSBSCURC', :OLD.CSBSCURC, :NEW.CSBSCURC, 'U', true);
    add_au('MSBSSUMPAYS', n2v(:OLD.MSBSSUMPAYS), n2v(:NEW.MSBSSUMPAYS), 'U', true);
    add_au('ISBSCOUNTPAYS', n2v(:OLD.ISBSCOUNTPAYS), n2v(:NEW.ISBSCOUNTPAYS), 'U', true);
    add_au('MSBSSUMCOM', n2v(:OLD.MSBSSUMCOM), n2v(:NEW.MSBSSUMCOM), 'U', true);
    add_au('ISBSTRNNUM', n2v(:OLD.ISBSTRNNUM), n2v(:NEW.ISBSTRNNUM), 'U', true);
    add_au('CSBSSTAT', :OLD.CSBSSTAT, :NEW.CSBSSTAT, 'U', true);
    add_au('ISBSTRNTRC', n2v(:OLD.ISBSTRNTRC), n2v(:NEW.ISBSTRNTRC), 'U', true);
    add_au('ISBSOTDNUM', n2v(:OLD.ISBSOTDNUM), n2v(:NEW.ISBSOTDNUM), 'U', true);
    add_au('ISBSDOCNUM', n2v(:OLD.ISBSDOCNUM), n2v(:NEW.ISBSDOCNUM), 'U', true);
    add_au('ISBSBATNUM', n2v(:OLD.ISBSBATNUM), n2v(:NEW.ISBSBATNUM), 'U', true);
    add_au('DSBSSYSDATE', d2v(:OLD.DSBSSYSDATE), d2v(:NEW.DSBSSYSDATE), 'U', true);
    add_au('IDSMR', :OLD.IDSMR, :NEW.IDSMR, 'U', true);
  end if;*/
  
  if deleting then
    add_au('IHOLD', n2v(:OLD.IHOLD), n2v(:NEW.IHOLD), 'D');
    add_au('ID', n2v(:OLD.ID), n2v(:NEW.ID), 'D');
    add_au('ITRNNUM', n2v(:OLD.ITRNNUM), n2v(:NEW.ITRNNUM), 'D');
    add_au('ITRNANUM', n2v(:OLD.ITRNANUM), n2v(:NEW.ITRNANUM), 'D');
    add_au('CCOMMENT', :OLD.CCOMMENT, :NEW.CCOMMENT, 'D');
    add_au('IDSMR_TO', :OLD.IDSMR_TO, :NEW.IDSMR_TO, 'D');
    add_au('MFR_ERR', :OLD.MFR_ERR, :NEW.MFR_ERR, 'D');
    add_au('TARIF_ID', n2v(:OLD.TARIF_ID), n2v(:NEW.TARIF_ID), 'D');
    add_au('DSBSDATEREG', d2v(:OLD.DSBSDATEREG), d2v(:NEW.DSBSDATEREG), 'D');
    add_au('CSBSPACK', :OLD.CSBSPACK, :NEW.CSBSPACK, 'D');
    add_au('MSBSTARIF', n2v(:OLD.MSBSTARIF), n2v(:NEW.MSBSTARIF), 'D');
    add_au('MSBSTARIFPRC', n2v(:OLD.MSBSTARIFPRC), n2v(:NEW.MSBSTARIFPRC), 'D');
    add_au('MSBSSUMBEFO', n2v(:OLD.MSBSSUMBEFO), n2v(:NEW.MSBSSUMBEFO), 'D');
    add_au('DSBSDATE', d2v(:OLD.DSBSDATE), d2v(:NEW.DSBSDATE), 'D');
    add_au('ISBSTYPECOM', n2v(:OLD.ISBSTYPECOM), n2v(:NEW.ISBSTYPECOM), 'D');
    add_au('CSBSTYPECOM', :OLD.CSBSTYPECOM, :NEW.CSBSTYPECOM, 'D');
    add_au('CSBSACCD', :OLD.CSBSACCD, :NEW.CSBSACCD, 'D');
    add_au('CSBSCURD', :OLD.CSBSCURD, :NEW.CSBSCURD, 'D');
    add_au('CSBSACCD_ZAM', :OLD.CSBSACCD_ZAM, :NEW.CSBSACCD_ZAM, 'D');
    add_au('CSBSCURD_ZAM', :OLD.CSBSCURD_ZAM, :NEW.CSBSCURD_ZAM, 'D');
    add_au('CSBSACCC', :OLD.CSBSACCC, :NEW.CSBSACCC, 'D');
    add_au('CSBSCURC', :OLD.CSBSCURC, :NEW.CSBSCURC, 'D');
    add_au('MSBSSUMPAYS', n2v(:OLD.MSBSSUMPAYS), n2v(:NEW.MSBSSUMPAYS), 'D');
    add_au('ISBSCOUNTPAYS', n2v(:OLD.ISBSCOUNTPAYS), n2v(:NEW.ISBSCOUNTPAYS), 'D');
    add_au('MSBSSUMCOM', n2v(:OLD.MSBSSUMCOM), n2v(:NEW.MSBSSUMCOM), 'D');
    add_au('ISBSTRNNUM', n2v(:OLD.ISBSTRNNUM), n2v(:NEW.ISBSTRNNUM), 'D');
    add_au('CSBSSTAT', :OLD.CSBSSTAT, :NEW.CSBSSTAT, 'D');
    add_au('ISBSTRNTRC', n2v(:OLD.ISBSTRNTRC), n2v(:NEW.ISBSTRNTRC), 'D');
    add_au('ISBSOTDNUM', n2v(:OLD.ISBSOTDNUM), n2v(:NEW.ISBSOTDNUM), 'D');
    add_au('ISBSDOCNUM', n2v(:OLD.ISBSDOCNUM), n2v(:NEW.ISBSDOCNUM), 'D');
    add_au('ISBSBATNUM', n2v(:OLD.ISBSBATNUM), n2v(:NEW.ISBSBATNUM), 'D');
    add_au('DSBSSYSDATE', d2v(:OLD.DSBSSYSDATE), d2v(:NEW.DSBSSYSDATE), 'D');
    add_au('IDSMR', :OLD.IDSMR, :NEW.IDSMR, 'D');
  end if;

  if l_tab_au.count > 0 then
      forall idx in l_tab_au.first .. l_tab_au.last
          insert into UBRR_DATA.UBRR_SBS_NEW_AUD
          values l_tab_au(idx);
  end if;
end UBRR_SBS_NEW_AUD_AR_TRG;
/
