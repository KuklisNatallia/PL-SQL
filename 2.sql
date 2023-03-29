with total as
(select 
 t.id_department                  as id_department 
,t.code_department                as code_department 
,substr (t.code_department, 1, 1) as code_dep
,t.id_epayment                    as id_epayment
,t.id_user                        as id_user
from ( select 
       ffe.id_epayment     as id_epayment
      ,dd.id_department    as id_department
      ,substr (dd.code_department, 1, 6)  as code_department
      ,substr (ddd.code_department, 1, 6) as code_dep_deb 
      ,ffe.id_user         as id_user

      from 1 ffe
      join 2 fae on ffe.id_epayment = fae.id_epayment
      join 3 dar on dar.id_role = fae.id_role  
      join 4 da on da.id_account = ffe.id_acc__deb
      join 4 daa on daa.id_account = ffe.id_acc__cre
      join 5 ddd on ddd.id_department = da.id_department
      join 5 dd on dd.id_department = daa.id_department 

      where 1=1
      and dar.code_role = 'CI#25' 
      and fae.code_action in ('CI#2', 'CI#3', 'CI#77') 
      and da.iban like 'BY__10%' 
      and to_date (fae.dt_open, 'dd.mm.yyyy') between :p_start_date and :p_end_date
      and dd.code_department != '8'
      and ddd.code_department != '8'
     
      UNION ALL

      select
       fe.id_epayment      as id_epayment
      ,ddd.id_department   as id_department
      ,substr (ddd.code_department, 1, 6) as code_department 
      ,null                as code_dep_deb
      ,fe.id_user          as id_user
    
      from 1 fe
      join 2 fae on fe.id_epayment = fae.id_epayment
      join 3 dar on dar.id_role = fae.id_role
      join 4 da on da.id_account = fe.id_acc__deb
      join 5 ddd on ddd.id_department = da.id_department

      where 1=1
      and dar.code_role = 'CI#25' 
      and fe.dockind in ('1', '2')
      and da.iban not like 'BY__10%' 
      and fae.code_action in ('CI#2', 'CI#3', 'CI#77') 
      and to_date (fae.dt_open, 'dd.mm.yyyy') between :p_start_date and :p_end_date
      and ddd.code_department != '8'
      ) t ),

SDBO as ( 
select
 s.id_dep_client                  as id_department_client
,s.code_dep_client                as code_department_client 
,substr (s.code_dep_client, 1, 1) as code_dep_client
,s.id_dep_user                    as id_department_user
,s.code_dep_user                  as code_department_user
,substr (s.code_dep_user, 1, 1)   as code_dep_user
,s.id_user                        as id_user
,s.id_epayment                    as id_epayment_SDBO
,s.dif                            as dif
from (
      select 
       ddd.id_department   as id_dep_client
      ,substr (ddd.code_department, 1, 6) as code_dep_client 
      ,d.id_department     as id_dep_user
      ,substr (d.code_department, 1, 6)   as code_dep_user
      ,fe.id_user          as id_user
      ,fe.id_epayment      as id_epayment
      ,CASE
        WHEN d.code_department = '7A1' and substr (ddd.code_department, 1, 1) = '1' THEN 0 
        WHEN d.code_department = '7B1' and substr (ddd.code_department, 1, 1) = '2' THEN 0 
        WHEN d.code_department = '7C1' and substr (ddd.code_department, 1, 1) = '3' THEN 0 
        WHEN d.code_department = '7D1' and substr (ddd.code_department, 1, 1) = '4' THEN 0 
        WHEN d.code_department = '7E1' and substr (ddd.code_department, 1, 1) = '5' THEN 0 
        WHEN d.code_department = '7F1' and substr (ddd.code_department, 1, 1) = '6' THEN 0 
        WHEN d.code_department = '7G1' and substr (ddd.code_department, 1, 1) = '7' THEN 0 
        WHEN d.code_department LIKE '8027%' and substr (ddd.code_department, 1, 1) = '8' THEN 0 
         ELSE 1
          END as dif

      from 1 fe
      join 4 da on da.id_account = fe.id_acc__cre
      join 5 ddd on ddd.id_department = da.id_department                                   
      
      join 6 du on fe.id_user = du.id_user 
      join 7 aud on aud.id_user = du.id_user 
                                and fe.dt_open between aud.dt_open and aud.dt_close
      join 8_kind ddrf on ddrf.id_user_dep_ref_kind = aud.id_user_dep_ref_kind and ddrf.ref_kind_code != '10'
      join 5 d on d.id_department = aud.id_department
                                
      where 1=1
      and fe.dockind = '388'
      and fe.doc_status in ('1', '3') 
      and fe.dt_open between :p_start_date and :p_end_date
      and ddd.code_department != '8'
      and d.code_department != '8'
      ) s ),
------------------------------------------------------

Rezult as (
select 
 i.id_department                  as id_department,
 i.code_dep                       as code_dep                                                
,i.code_department                as code_department 
,(i.count_payment)                as count_payment 
,(i.SDBO)                         as SDBO 
,(i.dif)                          as dif 

from (
          select 
           tl.id_department       as id_department
          ,tl.code_department     as code_department
          ,tl.code_dep            as code_dep 
          ,count (tl.id_epayment) as count_payment
          ,null                  as SDBO 
          ,null                  as dif

          from total tl
          group by tl.id_department, tl.code_department, tl.code_dep

          UNION ALL 

          select 
           s.id_department_client    as id_department
          ,s.code_department_client  as code_department 
          ,s.code_dep_client         as code_dep
          ,null                      as count_payment
          ,count(s.id_epayment_SDBO) as SDBO 
          ,SUM(s.dif)                as dif

          from SDBO s
          group by s.id_department_client, s.code_department_client, s.code_dep_client
      ) i
--GROUP BY i.code_dep, i.id_department, i.code_department 
)
----------------------------------------------------
----------------------------------------------------
select 
CASE 
  WHEN GROUPING_ID(r.code_dep, r.code_department) = 1 AND r.code_dep='1'
    THEN DECODE(r.code_department, NULL, 'Итого 1', r.code_department)
  WHEN GROUPING_ID(r.code_dep, r.code_department) = 1 AND r.code_dep='2'
    THEN DECODE(r.code_department, NULL, 'Итого 2', r.code_department)
  WHEN GROUPING_ID(r.code_dep, r.code_department) = 1 AND r.code_dep='3'
    THEN DECODE(r.code_department, NULL, 'Итого 3', r.code_department)
  WHEN GROUPING_ID(r.code_dep, r.code_department) = 1 AND r.code_dep='4'
    THEN DECODE(r.code_department, NULL, 'Итого 4', r.code_department)
  WHEN GROUPING_ID(r.code_dep, r.code_department) = 1 AND r.code_dep='5'
    THEN DECODE(r.code_department, NULL, 'Итого 5', r.code_department)
  WHEN GROUPING_ID(r.code_dep, r.code_department) = 1 AND r.code_dep='6'
    THEN DECODE(r.code_department, NULL, 'Итого 6', r.code_department)
  WHEN GROUPING_ID(r.code_dep, r.code_department) = 1 AND r.code_dep='7'
    THEN DECODE(r.code_department, NULL, 'Итого 7', r.code_department)
  WHEN GROUPING_ID(r.code_dep, r.code_department) = 1 AND r.code_dep='8'
    THEN DECODE(r.code_department, NULL, 'Итого 8', r.code_department) 
  WHEN GROUPING_ID(r.code_dep, r.code_department) = 3
    THEN DECODE(r.code_department, NULL, 'Всего', r.code_department)
  ELSE r.code_department 
      END              as code_department 
,SUM (r.count_payment) as count_payment  
,SUM (r.SDBO)          as SDBO 
,SUM (r.dif)           as dif 
,abs(NVL (SUM (r.count_payment), 0) + NVL (SUM (r.SDBO), 0)) as tot /*Итого (гр.2+гр.3)|Number*/  

from Rezult r
GROUP BY ROLLUP (r.code_dep, r.code_department)  
ORDER BY r.code_dep, r.code_department