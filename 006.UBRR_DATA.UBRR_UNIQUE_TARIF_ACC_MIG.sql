declare 
  g_error       varchar2(4000);
  g_user_errror exception;
  
  type t_tab_unique_tarif is table of UBRR_DATA.UBRR_UNIQUE_TARIF%rowtype index by pls_integer;
  g_tab_unique_tarif      t_tab_unique_tarif;
  
  
  l_uuta_id  UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.UUTA_ID%type;
  
  --отключаем триггеры аудита
  procedure disable_trigger_au
    is
  begin
    execute immediate 'alter trigger UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AR_I_TRG disable';
    execute immediate 'alter trigger UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_AR_I_TRG disable';
    execute immediate 'alter trigger UBRR_DATA.UBRR_UNIQUE_ACC_COMMSS_ARI_TRG disable';
    commit; 
  end;
  
  --включаем триггеры аудита
  procedure enable_trigger_au
    is
  begin
    execute immediate 'alter trigger UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AR_I_TRG enable';
    execute immediate 'alter trigger UBRR_DATA.UBRR_UNIQUE_ACC_COMMS_AR_I_TRG enable';
    execute immediate 'alter trigger UBRR_DATA.UBRR_UNIQUE_ACC_COMMSS_ARI_TRG enable'; 
    commit;
  end;   

  --данные для конвертации
  procedure reference_data
    is
    cursor cur_data is 
    select  a.*
     from UBRR_DATA.UBRR_UNIQUE_TARIF a
    --where a.cacc in ('40702810162450000661','40702810062130000735') 
    order by a.idsmr;
  begin
    open cur_data;
    fetch cur_data bulk collect into g_tab_unique_tarif;
    close cur_data;                
  exception
    when others then
      rollback;
      g_error := 'reference_data exception others '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end reference_data;
  
  --вернем тип комиссии по наименование поля, типы комиссий UBRR_DATA.UBRR_RKO_COM_TYPES.COM_TYPE
  function get_com_type(p_com_type        IN UBRR_DATA.UBRR_RKO_COM_TYPES.COM_TYPE%type
                        )
    return UBRR_DATA.UBRR_RKO_COM_TYPES.COM_TYPE%type
    is
    l_com_type    UBRR_DATA.UBRR_RKO_COM_TYPES.COM_TYPE%type := ''; 
  
    cursor cur_com_type is 
    select com_type
      from
    (
    with r as ( select 'SENCASH' as COM_TYPE, 'Комиссия за самоинкассацию' as NAME_COM , 'COMS' as CLMN from dual union all
                select 'RKBK'    as COM_TYPE, 'Комиссия за ведение счета без выписки (электронно)' as NAME_COM , 'COMACCWOUTEXTRACTE' as CLMN from dual union all
                select 'RKBP'    as COM_TYPE, 'Комиссия за ведение счета с выпиской (электронно)' as NAME_COM , 'COMACCWEXTRACTE' as CLMN from dual union all
                select 'RKO'     as COM_TYPE, 'Комиссия за ведение счета с выпиской (бумага)' as NAME_COM , 'COMACCP' as CLMN from dual union all
                select 'PP6'     as COM_TYPE, 'Комиссия межбанк платежи до 17-00' as NAME_COM , 'COMINBNKDAY' as CLMN from dual union all
                select '017'     as COM_TYPE, 'Комиссия межбанк платежи после 17-00' as NAME_COM , 'COMINBNKAF17' as CLMN from dual union all
                select '018'     as COM_TYPE, 'Комиссия межбанк платежи после 18-00' as NAME_COM , 'COMINBNKAF18' as CLMN from dual union all
                select 'PP9'     as COM_TYPE, 'Комиссия межбанк платежи бумага' as NAME_COM , 'COMINBNKP' as CLMN from dual union all
                --select 'PP3E'    as COM_TYPE, 'Комиссия внутрибанк платежи (электронно)' as NAME_COM , 'COMVNBNKE' as CLMN from dual union all
                select 'PP3'     as COM_TYPE, 'Комиссия внутрибанк платежи (бумага)' as NAME_COM , 'COMVNBNKP' as CLMN from dual
                )
       select a.com_type from r
    left join UBRR_DATA.UBRR_RKO_COM_TYPES a
           on r.COM_TYPE = a.com_type
        where r.CLMN = p_com_type 
    );
    
  begin
    
    open cur_com_type;
    fetch cur_com_type into l_com_type; 
    close cur_com_type;   
    return l_com_type;
  end;     

  --добавим аудит
  procedure add_au(p_aud_table     in ubrr_data.ubrr_unique_tarif_acc_aud.aud_table%type,
                   p_aud_table_id  in ubrr_data.ubrr_unique_tarif_acc_aud.aud_table_id%type,
                   p_field         in ubrr_data.ubrr_unique_tarif_acc_aud.field%type,
                   p_cacc          in UBRR_DATA.UBRR_UNIQUE_TARIF_AUD.CACC%type,
                   p_clmn          in UBRR_DATA.UBRR_UNIQUE_TARIF_AUD.CLMN%type,
                   p_dopentarif    in UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.DOPENTARIF%type,
                   p_dcanceltarif  in UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.DCANCELTARIF%type
                   )
    is
    
    type l_au_rectemp  is record (USERCHANGE      UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.USERCHANGE%type,
                                  DATECHANGE      UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.DATECHANGE%type,
                                  OLD_VL          UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.OLD_VL%type,
                                  NEW_VL          UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD.NEW_VL%type
                                  );
                                         
    type l_au_tabtemp is table of l_au_rectemp;
    l_au_temp    l_au_tabtemp;
    
    cursor cur_userid(p_user   usr.cusrlogname%type) is
    select iusrid 
      from usr
      where cusrlogname = coalesce(p_user,user);
      
    l_ubrr_unique_tarif_acc_aud    UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD%rowtype := null;
    l_iusrid                       usr.iusrid%type;
  
  begin    
    
    l_ubrr_unique_tarif_acc_aud.aud_table := p_aud_table;
    l_ubrr_unique_tarif_acc_aud.aud_table_id  := p_aud_table_id;
    l_ubrr_unique_tarif_acc_aud.field := p_field;
    l_ubrr_unique_tarif_acc_aud.oper := 'U';
               
    execute immediate 'select a.userchange,
                              a.datechange,
                              a.vl vl_old,
                              coalesce((select b.vl 
                                          from UBRR_DATA.UBRR_UNIQUE_TARIF_AUD b
                                         where b.cacc = a.cacc
                                           and b.clmn = a.clmn
                                           and b.datechange = (select min(d.datechange)
                                                                from UBRR_DATA.UBRR_UNIQUE_TARIF_AUD d
                                                               where d.cacc = a.cacc
                                                                 and d.clmn = a.clmn
                                                                 and d.datechange > a.datechange)),
                                        (select '||case when p_clmn in ('DCANCELTARIF','DOPENTARIF') then 'to_char(d.'||p_clmn||',''dd.mm.yyyy'')' else 'to_char(d.'||p_clmn||')'end ||'
                                              from UBRR_DATA.UBRR_UNIQUE_TARIF d
                                             where d.cacc =  a.cacc
                                               and d.DOPENTARIF = :dopentarif
                                               and d.DCANCELTARIF = :dcanceltarif
                                             )
                              ) vl_new
                        from UBRR_DATA.UBRR_UNIQUE_TARIF_AUD a
                       where a.cacc = :acc
                         and a.clmn = :clmn
                      order by a.datechange' 
        bulk collect into l_au_temp
        using p_dopentarif,p_dcanceltarif,p_cacc,p_clmn;
    
    if l_au_temp.count > 0 then  
    
      for i in l_au_temp.first .. l_au_temp.last                               
        loop 
          
          open cur_userid(l_au_temp(i).USERCHANGE);
          fetch cur_userid into l_iusrid;
          close cur_userid;
          
          l_ubrr_unique_tarif_acc_aud.iusrid := l_iusrid;
          l_ubrr_unique_tarif_acc_aud.userchange := coalesce(l_au_temp(i).USERCHANGE,user);      
          l_ubrr_unique_tarif_acc_aud.old_vl := l_au_temp(i).OLD_VL;
          l_ubrr_unique_tarif_acc_aud.new_vl := l_au_temp(i).NEW_VL;
          l_ubrr_unique_tarif_acc_aud.datechange := l_au_temp(i).DATECHANGE;
          
          insert into UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_AUD
              values l_ubrr_unique_tarif_acc_aud;
       
        end loop;
    end if;  
  exception
    when dup_val_on_index then
      g_error := 'exception add_au dup_val_on_index '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      raise;
    when others then
      g_error := 'exception add_au others '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      raise;
  end;
  --
  
  --добавим в UBRR_DATA.UBRR_UNIQUE_TARIF_ACC
  function add_tarif_acc(p_cacc           in UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.CACC%type,
                         p_dopentarif     in UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.DOPENTARIF%type,
                         p_dcanceltarif   in UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.DCANCELTARIF%type,
                         p_idsmr          in UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.IDSMR%type
                        )
    return UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.UUTA_ID%type
    is
    l_id  UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.UUTA_ID%type;
  begin
      
    insert into UBRR_DATA.UBRR_UNIQUE_TARIF_ACC(CACC,
                                                DOPENTARIF,
                                                DCANCELTARIF,
                                                IDSMR
                                                )
                                         values(p_cacc,
                                                p_dopentarif,
                                                p_dcanceltarif,
                                                p_idsmr
                                                )
                                   returning UUTA_ID into l_id;
    return l_id;
  exception
    when dup_val_on_index then
      g_error := 'exception add_tarif_acc dup_val_on_index '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      return 0;
    when others then
      g_error := 'exception add_tarif_acc others '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      return 0;    
  end;
  --
  
  --добавим в UBRR_DATA.UBRR_UNIQUE_ACC_COMMS
  procedure add_acc_comms(p_uuta_id        in UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.UUTA_ID%type,
                          p_cacc           in UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.CACC%type,
                          p_dopentarif     in UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.DOPENTARIF%type,
                          p_dcanceltarif   in UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.DCANCELTARIF%type,
                          p_daily          in UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.DAILY%type,
                          p_idsmr          in UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.IDSMR%type,
                          p_field          in ubrr_data.ubrr_unique_tarif_acc_aud.field%type,
                          p_clmn           in UBRR_DATA.UBRR_UNIQUE_TARIF_AUD.CLMN%type
                         )
    is
    
    type l_acc_comms_rectemp  is record (CACC      UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.CACC%type,
                                         SUMM_DEF  UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.SUMM_DEF%type
                                         );
                                         
    type l_acc_comms_tabtemp is table of l_acc_comms_rectemp;
    l_tab_temp    l_acc_comms_tabtemp;                                
    
    l_uuac_id     UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.UUAC_ID%type;
    l_com_type    UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.COM_TYPE%type  := '';
    l_daily       UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.DAILY%type;
  begin
      
    execute immediate 'select a.cacc,
                              a.'||p_clmn||'
                         from UBRR_DATA.UBRR_UNIQUE_TARIF a
                        where a.cacc = :acc
                          and a.dopentarif = :dopentarif
                          and a.dcanceltarif = :dcanceltarif
                          and (a.'||p_clmn||' >= 0
                               or 
                               exists (select 1 from UBRR_DATA.UBRR_UNIQUE_TARIF_AUD b
                                       where b.cacc =  a.cacc
                                         and b.clmn = '''||p_clmn||''')
                              )'
        bulk collect into l_tab_temp
        using p_cacc,p_dopentarif,p_dcanceltarif;
    
    if l_tab_temp.count > 0 then  
      for i in l_tab_temp.first .. l_tab_temp.last
        loop
          
          --найдем тип комиссии
          l_com_type := get_com_type(p_com_type     => p_clmn);
          
          IF l_com_type in ('RKBP','RKBK','RKO') THEN
            l_daily := 'N';
          ELSIF l_com_type in ('SENCASH') THEN
            l_daily := 'Y';            
          ELSE
            l_daily := p_daily; 
          END IF;  
          
          if l_com_type is null then
            g_error := 'Ошибка, не найдет  l_com_type  для p_clmn = '||p_clmn||' по счету '|| l_tab_temp(i).CACC;
            raise g_user_errror;     
          end if;
          
          insert into UBRR_DATA.UBRR_UNIQUE_ACC_COMMS(UUTA_ID,
                                                      CACC,
                                                      COM_TYPE,
                                                      DAILY,
                                                      SUMM_DEF,
                                                      IDSMR
                                                      )
                                               values(p_uuta_id,
                                                      l_tab_temp(i).CACC,
                                                      l_com_type,
                                                      l_daily,
                                                      l_tab_temp(i).SUMM_DEF,
                                                      p_idsmr
                                                      )
                                         returning UUAC_ID  into l_uuac_id;                              
          
          if nvl(l_uuac_id, 0) = 0 then
            g_error := 'Ошибка при добавление в UBRR_UNIQUE_ACC_COMMS по счету '|| l_tab_temp(i).CACC||' l_uuac_id = '||l_uuac_id;
            raise g_user_errror;
          end if;
           
          --добавим аудит p_clmn 
          add_au(p_aud_table      => 'UBRR_UNIQUE_ACC_COMMS',
                 p_aud_table_id   => l_uuac_id,
                 p_field          => p_field,
                 p_cacc           => p_cacc,
                 p_clmn           => p_clmn,
                 p_dopentarif     => p_dopentarif,
                 p_dcanceltarif   => p_dcanceltarif
                );
          --добавим аудит DAILY
          add_au(p_aud_table      => 'UBRR_UNIQUE_ACC_COMMS',
                 p_aud_table_id   => l_uuac_id,
                 p_field          => 'DAILY',
                 p_cacc           => p_cacc,
                 p_clmn           => 'DAILY',
                 p_dopentarif     => p_dopentarif,
                 p_dcanceltarif   => p_dcanceltarif
                );         
      end loop;
    end if;     
  exception
    when dup_val_on_index then
      g_error := g_error||' exception add_acc_comms dup_val_on_index '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      raise;
    when others then
      g_error := g_error||' exception add_acc_comms others '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace; 
      raise;
  end;      
  --
  
begin
  --берем все данные таблицы 
  reference_data;
  
  if g_tab_unique_tarif.count = 0 then
    g_error := 'Нет данных';
    raise g_user_errror;
  end if;
  
  --отключаем трраггер аудита
  disable_trigger_au;
    
  for idx in g_tab_unique_tarif.first .. g_tab_unique_tarif.last
    loop
      
      --добавим данные по счету и периоду в UBRR_UNIQUE_TARIF_ACC
      l_uuta_id := add_tarif_acc(p_cacc           => g_tab_unique_tarif(idx).CACC,
                                 p_dopentarif     => g_tab_unique_tarif(idx).DOPENTARIF,
                                 p_dcanceltarif   => g_tab_unique_tarif(idx).DCANCELTARIF,
                                 p_idsmr          => g_tab_unique_tarif(idx).IDSMR
                                );
      
      if nvl(l_uuta_id, 0) = 0 then
        g_error := 'Ошибка при добавление в UBRR_UNIQUE_TARIF_ACC по счету '|| g_tab_unique_tarif(idx).CACC||' l_uuta_id = '||l_uuta_id;
        raise g_user_errror;
      end if;
       
      --добавим аудит для UBRR_UNIQUE_TARIF_ACC                      
      add_au(p_aud_table      => 'UBRR_UNIQUE_TARIF_ACC',
             p_aud_table_id   => l_uuta_id,
             p_field          => 'DOPENTARIF',
             p_cacc           => g_tab_unique_tarif(idx).CACC,
             p_clmn           => 'DOPENTARIF',
             p_dopentarif     => g_tab_unique_tarif(idx).DOPENTARIF,
             p_dcanceltarif   => g_tab_unique_tarif(idx).DCANCELTARIF
             );
      add_au(p_aud_table      => 'UBRR_UNIQUE_TARIF_ACC',
             p_aud_table_id   => l_uuta_id,
             p_field          => 'DCANCELTARIF',
             p_cacc           => g_tab_unique_tarif(idx).CACC,
             p_clmn           => 'DCANCELTARIF',
             p_dopentarif     => g_tab_unique_tarif(idx).DOPENTARIF,
             p_dcanceltarif   => g_tab_unique_tarif(idx).DCANCELTARIF
             );                                    
      
      --добавим в UBRR_DATA.UBRR_UNIQUE_ACC_COMMS --COMS
      add_acc_comms(p_uuta_id        => l_uuta_id,
                    p_cacc           => g_tab_unique_tarif(idx).CACC,
                    p_dopentarif     => g_tab_unique_tarif(idx).DOPENTARIF,
                    p_dcanceltarif   => g_tab_unique_tarif(idx).DCANCELTARIF,
                    p_daily          => g_tab_unique_tarif(idx).DAILY,
                    p_idsmr          => g_tab_unique_tarif(idx).IDSMR,
                    p_field          => 'SUMM_DEF',
                    p_clmn           => 'COMS'
                    );  
      --добавим в UBRR_DATA.UBRR_UNIQUE_ACC_COMMS --COMVNBNKP
      add_acc_comms(p_uuta_id        => l_uuta_id,
                    p_cacc           => g_tab_unique_tarif(idx).CACC,
                    p_dopentarif     => g_tab_unique_tarif(idx).DOPENTARIF,
                    p_dcanceltarif   => g_tab_unique_tarif(idx).DCANCELTARIF,
                    p_daily          => g_tab_unique_tarif(idx).DAILY,
                    p_idsmr          => g_tab_unique_tarif(idx).IDSMR,
                    p_field          => 'SUMM_DEF',
                    p_clmn           => 'COMVNBNKP'
                    );                                         
      /*
      --добавим в UBRR_DATA.UBRR_UNIQUE_ACC_COMMS --COMVNBNKE
      add_acc_comms(p_uuta_id        => l_uuta_id,
                    p_cacc           => g_tab_unique_tarif(idx).CACC,
                    p_dopentarif     => g_tab_unique_tarif(idx).DOPENTARIF,
                    p_dcanceltarif   => g_tab_unique_tarif(idx).DCANCELTARIF,
                    p_daily          => g_tab_unique_tarif(idx).DAILY,
                    p_idsmr          => g_tab_unique_tarif(idx).IDSMR,
                    p_field          => 'SUMM_DEF',
                    p_clmn           => 'COMVNBNKE'
                    ); 
       */
       
      --добавим в UBRR_DATA.UBRR_UNIQUE_ACC_COMMS --COMINBNKP
      add_acc_comms(p_uuta_id        => l_uuta_id,
                    p_cacc           => g_tab_unique_tarif(idx).CACC,
                    p_dopentarif     => g_tab_unique_tarif(idx).DOPENTARIF,
                    p_dcanceltarif   => g_tab_unique_tarif(idx).DCANCELTARIF,
                    p_daily          => g_tab_unique_tarif(idx).DAILY,
                    p_idsmr          => g_tab_unique_tarif(idx).IDSMR,
                    p_field          => 'SUMM_DEF',
                    p_clmn           => 'COMINBNKP'
                    ); 
      --добавим в UBRR_DATA.UBRR_UNIQUE_ACC_COMMS --COMINBNKDAY
      add_acc_comms(p_uuta_id        => l_uuta_id,
                    p_cacc           => g_tab_unique_tarif(idx).CACC,
                    p_dopentarif     => g_tab_unique_tarif(idx).DOPENTARIF,
                    p_dcanceltarif   => g_tab_unique_tarif(idx).DCANCELTARIF,
                    p_daily          => g_tab_unique_tarif(idx).DAILY,
                    p_idsmr          => g_tab_unique_tarif(idx).IDSMR,
                    p_field          => 'SUMM_DEF',
                    p_clmn           => 'COMINBNKDAY'
                    );
      --добавим в UBRR_DATA.UBRR_UNIQUE_ACC_COMMS --COMINBNKAF18
      add_acc_comms(p_uuta_id        => l_uuta_id,
                    p_cacc           => g_tab_unique_tarif(idx).CACC,
                    p_dopentarif     => g_tab_unique_tarif(idx).DOPENTARIF,
                    p_dcanceltarif   => g_tab_unique_tarif(idx).DCANCELTARIF,
                    p_daily          => g_tab_unique_tarif(idx).DAILY,
                    p_idsmr          => g_tab_unique_tarif(idx).IDSMR,
                    p_field          => 'SUMM_DEF',
                    p_clmn           => 'COMINBNKAF18'
                    );
      --добавим в UBRR_DATA.UBRR_UNIQUE_ACC_COMMS --COMINBNKAF17
      add_acc_comms(p_uuta_id        => l_uuta_id,
                    p_cacc           => g_tab_unique_tarif(idx).CACC,
                    p_dopentarif     => g_tab_unique_tarif(idx).DOPENTARIF,
                    p_dcanceltarif   => g_tab_unique_tarif(idx).DCANCELTARIF,
                    p_daily          => g_tab_unique_tarif(idx).DAILY,
                    p_idsmr          => g_tab_unique_tarif(idx).IDSMR,
                    p_field          => 'SUMM_DEF',
                    p_clmn           => 'COMINBNKAF17'
                    );                    
      --добавим в UBRR_DATA.UBRR_UNIQUE_ACC_COMMS --COMACCWOUTEXTRACTE
      add_acc_comms(p_uuta_id        => l_uuta_id,
                    p_cacc           => g_tab_unique_tarif(idx).CACC,
                    p_dopentarif     => g_tab_unique_tarif(idx).DOPENTARIF,
                    p_dcanceltarif   => g_tab_unique_tarif(idx).DCANCELTARIF,
                    p_daily          => g_tab_unique_tarif(idx).DAILY,
                    p_idsmr          => g_tab_unique_tarif(idx).IDSMR,
                    p_field          => 'SUMM_DEF',
                    p_clmn           => 'COMACCWOUTEXTRACTE'
                    ); 
      --добавим в UBRR_DATA.UBRR_UNIQUE_ACC_COMMS --COMACCWEXTRACTE
      add_acc_comms(p_uuta_id        => l_uuta_id,
                    p_cacc           => g_tab_unique_tarif(idx).CACC,
                    p_dopentarif     => g_tab_unique_tarif(idx).DOPENTARIF,
                    p_dcanceltarif   => g_tab_unique_tarif(idx).DCANCELTARIF,
                    p_daily          => g_tab_unique_tarif(idx).DAILY,
                    p_idsmr          => g_tab_unique_tarif(idx).IDSMR,
                    p_field          => 'SUMM_DEF',
                    p_clmn           => 'COMACCWEXTRACTE'
                    );       
      --добавим в UBRR_DATA.UBRR_UNIQUE_ACC_COMMS --COMACCP
      add_acc_comms(p_uuta_id        => l_uuta_id,
                    p_cacc           => g_tab_unique_tarif(idx).CACC,
                    p_dopentarif     => g_tab_unique_tarif(idx).DOPENTARIF,
                    p_dcanceltarif   => g_tab_unique_tarif(idx).DCANCELTARIF,
                    p_daily          => g_tab_unique_tarif(idx).DAILY,
                    p_idsmr          => g_tab_unique_tarif(idx).IDSMR,
                    p_field          => 'SUMM_DEF',
                    p_clmn           => 'COMACCP'
                    );                 
    end loop;
  
  commit;
   
  --включаем трраггер аудита
  enable_trigger_au;
        
exception
  when others then
    rollback;
    --включаем трраггер аудита
    enable_trigger_au;
    
    if g_error is null then
      g_error := 'exception others '||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    end if;

     ubrr_xxi5.ubrr_logging_pack.log(cpmessage  =>g_error,
                                     cpcomment => '20-73382\sql\uodb\006.UBRR_DATA.UBRR_UNIQUE_TARIF_ACC_MIG.sql'
                                     );    
end;
/
