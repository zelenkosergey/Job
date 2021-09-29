begin

   merge into UBRR_DATA.UBRR_RKO_COM_TYPES dst
   using (  select 'SENCASH' as COM_TYPE, '�������� �� ��������������' as NAME_COM, '����������' as req, 1 as HOLD from dual union all
            select 'RKBK'    as COM_TYPE, '�������� �� ������� ����� ��� ������� (����������)' as NAME_COM, '�����������' as req, 0 as HOLD from dual union all
            select 'RKBP'    as COM_TYPE, '�������� �� ������� ����� � �������� (����������)' as NAME_COM, '�����������' as req, 0 as HOLD from dual union all
            select 'RKO'     as COM_TYPE, '�������� �� ������� ����� � �������� (������)' as NAME_COM, '����������' as req, 1 as HOLD from dual union all
            select 'PP6'     as COM_TYPE, '�������� ������� ������� �� 17-00' as NAME_COM, '����������' as req, 1 as HOLD from dual union all
            select '017'     as COM_TYPE, '�������� ������� ������� ����� 17-00' as NAME_COM, '����������' as req, 1 as HOLD from dual union all
            select '018'     as COM_TYPE, '�������� ������� ������� ����� 18-00' as NAME_COM, '����������' as req, 1 as HOLD from dual union all
            select 'PP9'     as COM_TYPE, '�������� ������� ������� ������' as NAME_COM, '����������' as req, 1 as HOLD from dual union all
            select 'PP3E'    as COM_TYPE, '�������� ���������� ������� (����������)' as NAME_COM, '����������' as req, 1 as HOLD from dual union all
            select 'PP3'     as COM_TYPE, '�������� ���������� ������� (������)' as NAME_COM, '����������' as req, 1 as HOLD from dual union all
            select 'R_IB'    as COM_TYPE, '�������� �� ������������ ������� "��������-���� ���"' as NAME_COM, '�����������' as req, 0 as HOLD from dual
         ) src
   on (     dst.com_type = src.com_type
      )      
   when matched then
      update set dst.com_name = src.name_com
   when not matched then
      insert (     COM_TYPE,    COM_NAME,   BASE_TYPE,   FREQ,   IHOLD)
      values ( src.com_type,src.name_com,src.com_type,src.req,src.hold);
     
   commit;   
    
exception 
  when others then
     rollback;
end;
/ 
