declare
    MENU_TITLE  constant ubrr_tert_menu_tasks.ctmenu_tilte%type := 'Настройка индивидуальных тарифов для комиссий';
    FORM_NAME   constant ubrr_tert_menu_tasks.ctmenu_form%type  := 'UBRR_UNIQUE_TARIF_ACC';
    vTaskId number/* := ubrr_data.s_ubrr_tert_menu_tasks_id.nextval*/;
begin

   select max(ITMENU_ID)+1 
     into vTaskId
     from  ubrr_tert_menu_tasks;     

    insert into ubrr_tert_menu_tasks
         values (vTaskId, MENU_TITLE, 'F:\XXI\ALL_FORM\'||FORM_NAME, null, 'Y', '6.0');
  commit;
    
exception 
  when others then
  rollback;
end;
/
