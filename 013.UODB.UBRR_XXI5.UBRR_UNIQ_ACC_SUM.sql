CREATE OR REPLACE FUNCTION UBRR_XXI5."UBRR_UNIQ_ACC_SUM" (p_acc      IN UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.CACC%type,
                                                            p_Cur      IN acc.cacccur%type,
                                                            p_Otd      IN acc.iaccotd%type,
                                                            p_dtrn     IN UBRR_DATA.UBRR_UNIQUE_TARIF_ACC.DOPENTARIF%type,
                                                            p_com_type IN UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.COM_TYPE%type,
                                                            p_SumTrn   IN number,
                                                            p_SumBefo  IN number default null
                                                            )
  RETURN UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.SUMM_DEF%type
  IS
/*************************************************** HISTORY *****************************************************\
   Дата          Автор          id        Описание
----------  ---------------  --------- ------------------------------------------------------------------------------
31.08.2020   Зеленко С.А.    [20-73382] Индивидуальные тарифы по кассовым операциям, по переводам в пользу ФЛ 
\*************************************************** HISTORY *****************************************************/
  
  cursor cur_com_sum is
  select uuac.summ_def
    from UBRR_UNIQUE_TARIF_ACC uutc,
         UBRR_UNIQUE_ACC_COMMS uuac
   where uutc.cacc = p_acc
     and p_dtrn between uutc.DOPENTARIF and uutc.DCANCELTARIF
     and uutc.idsmr = SYS_CONTEXT ('B21','IDSmr')
     and uutc.status = 'N'
     and uutc.uuta_id = uuac.uuta_id
     and uuac.com_type = p_com_type;
                       
  l_sum         UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.SUMM_DEF%type;
  l_idSmr       UBRR_DATA.UBRR_UNIQUE_ACC_COMMS.IDSMR%type := ubrr_util.GetBankIdSmr;
  l_mtarif      number;
  l_mtarifPrc   number;
  l_tarif_id    ubrr_sbs_new.tarif_id%type; 

BEGIN
    
  IF ubrr_bnkserv_calc_new_lib.gc_sbs_uniq_taif = 'Y' THEN
    l_sum := ubrr_bnkserv_calc_new_lib.getsumcomiss_uniq(p_trnnum     => null,
                                                         p_trnanum    => null,
                                                         p_acc        => p_acc,
                                                         p_cur        => p_Cur,
                                                         p_otd        => p_Otd,
                                                         p_typecom    => p_com_type,
                                                         p_sumtrn     => p_SumTrn,
                                                         p_sumbefo    => p_SumBefo,
                                                         p_g_tarif_id => l_tarif_id,
                                                         p_mtarif     => l_mtarif,
                                                         p_mtarifprc  => l_mtarifPrc,
                                                         p_bankidsmr  => l_idSmr,
                                                         p_dater      => p_dtrn);
  ELSE
    open cur_com_sum;
    fetch cur_com_sum into l_sum;
    close cur_com_sum;
  END IF;                                                       
  
  return nvl(l_sum,0);
END;
/
/
create or replace public synonym UBRR_UNIQ_ACC_SUM for UBRR_XXI5."UBRR_UNIQ_ACC_SUM";
/
grant execute on UBRR_XXI5."UBRR_UNIQ_ACC_SUM" to ODB;
/