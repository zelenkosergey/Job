-- загрузка новых отчетов, курсоров, отчетов-курсоров
declare
begin  
   ----------------------------------------------------------------
   -- создание записи нового отчета
   merge into xxi.AP_REPORT_TYPE r
   using (select 1000006 report_type_id
                 ,'Отчет по индивидуальным комиссиям' report_type_name  
            from dual
          ) n
    on (     r.report_type_id = n.report_type_id
       )
    when matched then
        update set r.report_type_name    = n.report_type_name
    when not matched then
        insert  ( report_type_id
                 ,report_type_name )                                                                                                                
         values ( n.report_type_id
                 ,n.report_type_name );
   ----------------------------------------------------------------      
   -- создание записи нового отчета
   merge into xxi.ap_report_cat r
   using (select 1 report_id
                 ,1000006 report_type_id
                 ,'Отчет по индивидуальным комиссиям, общий.' report_name  
                 ,'xxi\apmaket_1000006_1_ubrr.xlt' report_ufs
                 ,1 copies
                 ,-3 report_viewer
                 ,null report_comment
                 ,'N' edit_param
                 ,'N' oem_data
                 ,null report_file
            from dual
          ) n
    on (     r.report_id      = n.report_id
         and r.report_type_id = n.report_type_id
       )
    when matched then
        update set r.report_name    = n.report_name
                  ,r.report_ufs     = n.report_ufs                                      
                  ,r.copies         = n.copies
                  ,r.report_viewer  = n.report_viewer
                  ,r.report_comment = n.report_comment
                  ,r.edit_param     = n.edit_param
                  ,r.oem_data       = n.oem_data
                  ,r.report_file    = n.report_file
    when not matched then
        insert  ( report_id
                 ,report_type_id
                 ,report_name
                 ,report_ufs                                      
                 ,copies
                 ,report_viewer
                 ,report_comment
                 ,edit_param
                 ,oem_data
                 ,report_file )                                                                                                                
         values ( n.report_id
                 ,n.report_type_id
                 ,n.report_name
                 ,n.report_ufs                                      
                 ,n.copies
                 ,n.report_viewer
                 ,n.report_comment
                 ,n.edit_param
                 ,n.oem_data
                 ,n.report_file );
   ----------------------------------------------------------------
   --создание и наполнение текстом новых курсоров
   merge into xxi.ap_cursor_type r
   using ( 
           select 100000601 cursor_id 
                  ,'Заголовок отчета'     cursor_name
                  ,'SELECT to_char(SYSDATE,''DD.MM.RRRR HH24:MI:SS''), 
                           UTIL_DM2.Get_User_Name(USER),
                           s.CSMRNAME,
                           s.CSMRADDR
                    FROM smr s' cursor_text         
           from dual
           union all
           select 100000602 cursor_id 
                  ,'Таблица данных'     cursor_name
                  ,'select a.cacc,
                           a.dopentarif,
                           a.dcanceltarif,
                           (select d.com_name from UBRR_DATA.UBRR_RKO_COM_TYPES d where d.com_type = b.com_type) com_name,
                                   decode(b.daily,''N'',''Ежемесячные'',''Y'',''Ежедневные'',null) period,
                                   a.uuta_id
                              from UBRR_DATA.UBRR_UNIQUE_TARIF_ACC      a,
                                   UBRR_DATA.UBRR_UNIQUE_ACC_COMMS      b
                             where a.uuta_id = b.uuta_id(+)
                               and a.idsmr = sys_context(''B21'', ''IDSmr'')
                               and (
                                (:p1 = ''E'' and a.status = ''N'' and a.DCANCELTARIF >= trunc(sysdate))
                                or
                                (:p1 = ''A'' and a.status = ''N'' and a.DCANCELTARIF < trunc(sysdate))
                                or
                                (:p1 = ''Y'' and a.status = :p1)
                                or
                                (:p1 = ''V'')
                                )
                            order by a.cacc, a.dopentarif, a.dcanceltarif' cursor_text         
           from dual          
         ) n    
   on ( r.cursor_id = n.cursor_id )
   when matched then
      update set r.cursor_name = n.cursor_name
                ,r.cursor_text = n.cursor_text
   when not matched then
      insert ( cursor_id, cursor_name, cursor_text )
      values ( n.cursor_id, n.cursor_name, n.cursor_text);
   ----------------------------------------------------------------   
   -- создание связки новый_отчет-новый_курсор
   merge into xxi.ap_cursor_role r
   using ( select 1000006       report_type_id
                  ,1            report_id
                  ,1            cursor_num
                  ,100000601    cursor_id                         
                  ,'N'          use_sort
                  ,null         cursor_loop
                  ,'N'          use_reset
                  ,'N'          use_resume
              from dual
           union all
           select 1000006       report_type_id
                  ,1            report_id
                  ,2            cursor_num
                  ,100000602    cursor_id                         
                  ,'N'          use_sort
                  ,null         cursor_loop
                  ,'N'          use_reset
                  ,'N'          use_resume
              from dual                          
         ) n
    on (     r.report_type_id = n.report_type_id
         and r.report_id      = n.report_id
         and r.cursor_num     = n.cursor_num
       )                                    
    when matched then
      update set r.cursor_id   = n.cursor_id
                ,r.use_sort    = n.use_sort           
                ,r.cursor_loop = n.cursor_loop
                ,r.use_reset   = n.use_reset
                ,r.use_resume  = n.use_resume
    when not matched then
       insert( report_type_id, report_id, cursor_num, cursor_id, use_sort, cursor_loop, use_reset, use_resume )
        values( n.report_type_id, n.report_id, n.cursor_num, n.cursor_id, n.use_sort, n.cursor_loop, n.use_reset, n.use_resume );         
   ----------------------------------------------------------------
   -- выдача прав пользователям на тип отчета
   merge into xxi.ap_user_report_role dst
   using (select usr.iusrid user_id,
                 xxi.ap_report_cat.report_type_id
            from dba_role_privs, dba_users, usr 
          left join xxi.ap_report_cat
              on xxi.ap_report_cat.report_type_id = 1000006 
             and xxi.ap_report_cat.report_id = 1 
           where dba_role_privs.GRANTED_ROLE like 'UBRR_UNIQUE_TARIF%'
             and dba_role_privs.GRANTEE = dba_users.username
             and dba_users.username = usr.cusrlogname
             and dba_users.account_status = 'OPEN'
          ) src      
   on (     dst.report_type_id = src.report_type_id
        and dst.user_id        = src.user_id
      )     
   when not matched then
    insert( report_type_id
           ,user_id  
          )  
    values( src.report_type_id
           ,src.user_id
          );              
   ----------------------------------------------------------------
   -- выдача прав пользователям на отчет
   merge into xxi.ap_user_report_cat_role dst
   using (select usr.iusrid user_id,
                 xxi.ap_report_cat.report_type_id,
                 xxi.ap_report_cat.report_id
            from dba_role_privs, dba_users, usr 
          left join xxi.ap_report_cat
              on xxi.ap_report_cat.report_type_id = 1000006 
             and xxi.ap_report_cat.report_id = 1 
           where dba_role_privs.GRANTED_ROLE like 'UBRR_UNIQUE_TARIF%'
             and dba_role_privs.GRANTEE = dba_users.username
             and dba_users.username = usr.cusrlogname
             and dba_users.account_status = 'OPEN'
          ) src      
   on (     dst.report_type_id = src.report_type_id
        and dst.report_id      = src.report_id
        and dst.user_id        = src.user_id
      )     
   when not matched then
    insert( report_type_id
           ,report_id
           ,user_id  
          )  
    values( src.report_type_id
           ,src.report_id
           ,src.user_id
          );              
   ---------------------------------------------------------------- 
   -- добавление общие пользовательские настройки
   merge into xxi.AP_User_SetUp dst
   using (select usr.iusrid user_id
            from dba_role_privs, dba_users, usr 
           where dba_role_privs.GRANTED_ROLE like 'UBRR_UNIQUE_TARIF%'
             and dba_role_privs.GRANTEE = dba_users.username
             and dba_users.username = usr.cusrlogname
             and dba_users.account_status = 'OPEN'
          ) src      
   on (  dst.user_id        = src.user_id
      )     
   when not matched then
    insert( USER_ID, 
            GENERATE_TYPE, 
            USE_OUT_DIR, 
            USE_CONVERTATION, 
            USE_SETUP, 
            PRINTER_ID, 
            COPIES
          )  
    values( src.user_id,
            'D',
            'T',
            'N',
            'Y',
            -1,
            1	
          );              
   ---------------------------------------------------------------- 
   
   commit;                
   
exception
 when dup_val_on_index then
  rollback;
  ubrr_xxi5.ubrr_logging_pack.log(cpmessage  =>'Error :'||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace,
                                  cpcomment  => '20-73382\sql\uodb\009.XXI.ap_report_cat.sql'
                                 );    
 when others then
  rollback;
  ubrr_xxi5.ubrr_logging_pack.log(cpmessage  =>'Error :'||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace,
                                  cpcomment  => '20-73382\sql\uodb\009.XXI.ap_report_cat.sql'
                                 );    
end;
/
