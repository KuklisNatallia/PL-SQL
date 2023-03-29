SELECT 
ds.id_subject    as id_subject ,
nt.GET_SUB_IND_VALUE(ds.id_subject, 'T', to_date (:p_dt)) as Tnom_ ,
substr (ds.code_subject, 6, 3)                            as code_ , 
regexp_substr (pp.pn, '[^ ]+', 1, 1)                      as sur_ ,
regexp_substr (pp.pn, '[^ ]+', 1, 2)                      as name_ ,
regexp_substr (pp.pn, '[^ ]+', 1, 3)  			  as sec_name_ ,
pp.sex                                                    as sex , 
pp.birth_dt                                               as birth_dt ,
nt.GET_SUB_IND_VALUE(ds.id_subject, 'CAPA', to_date (:p_dt)) as CAP ,
nt.GET_SUB_IND_VALUE(ds.id_subject, 'ID', to_date (:p_dt))  as ID,
nt.GET_SUB_IND_VALUE_VALUE(ds.id_subject, 'COD_', to_date (:p_dt)) as COD_,
CASE
  WHEN (nt.GET_SUB_IND_VALUE(ds.id_subject, 'IsClose', to_date (:p_dt)) = '0')
     and (ds.id_ in (select sc.id_ 
                            from 1 sc 
                            join 2 dscc on dscc.id_s_cat_val =sc.id_s_cat_val
                            where to_date (:p_dt) between sc.dt_open and sc.dt_close
                            and dscc.id_s_cat_val = 34) )
   THEN '2'  
 ELSE nt.GET_SUB_IND_VALUE(ds.id_subject, 'IsClose', to_date (:p_dt)) 
   END as IsClose , 
i.dt_open                                          as dt_open ,
NVL (to_date (i1.value, 'YYYYMMDD'), '01.01.3001') as dt_close 
from 1 ds
join 3 pp on pp.id_subject = ds.id_subject
join 4 s on ds.id_system = s.id_system and s.system_code = '1' 
join 5 i on i.id_subject = pp.id_subject 
                                and i.id_typeattr = (select t.id_typeattr from 7 t where code = 'DT_OPEN_S')
left 6 i1 on i1.id_subject = pp.id_subject 
                                and i1.id_typeattr = (select tt.id_typeattr from 8 tt where code = 'DT_CLOSE_S')

where 1=1
