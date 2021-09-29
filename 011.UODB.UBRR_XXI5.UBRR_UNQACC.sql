CREATE OR REPLACE Function UBRR_XXI5.Ubrr_UnQAcc(acc_ varchar2, dat_ date ) Return number Is
/*************************************************** HISTORY *****************************************************\
   Дата          Автор          id        Описание
----------  ---------------  --------- ------------------------------------------------------------------------------
            Pashevich A. 12-508 крупные клиенты
31.08.2020  Зеленко С.А.    [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ
\*************************************************** HISTORY *****************************************************/
  
  cursor cur_count_acc is 
  Select count(uutc.uuta_id)
   From UBRR_UNIQUE_TARIF_ACC uutc,
        UBRR_UNIQUE_ACC_COMMS uuac 
   Where uutc.cAcc = acc_  
     and dat_ between uutc.dopentarif and uutc.dcanceltarif 
     and uutc.status = 'N'
     and uutc.uuta_id = uuac.uuta_id
     and uuac.daily = 'Y'
     and uuac.com_type = 'SENCASH';  
  
  unQ_ number;
Begin
  
  open cur_count_acc;
  fetch cur_count_acc into unQ_;
  close cur_count_acc;
  
  Return unQ_;
End Ubrr_UnQAcc;
/
