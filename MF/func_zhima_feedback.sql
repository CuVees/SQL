BEGIN 
#############参数######
set @stat=(SELECT max(inserttime) FROM bmdb.tb_zhima_feedback where DATEDIFF(now(),inserttime)=1);
####更新数据######
UPDATE bmdb.tb_credit_record a 
SET a.actual_time=(SELECT  actual_time FROM bmdb.tb_repayment_record b WHERE a.id=b.credit_id)
WHERE a.id IN (SELECT credit_id FROM bmdb.tb_repayment_record) AND a.actual_time IS NULL AND a.shouldback_time IS NOT NULL;
######################
#UPDATE bmdb.tb_credit_record set cre_update_time=DATE_ADD(now(),INTERVAL -1 day ) where status=6;
#######################
delete from bmdb.tb_zhima_feedback where day_key=idate ;
insert into bmdb.tb_zhima_feedback (day_key,credit_id,user_credentials_type,user_credentials_no ,user_name,order_no,biz_type,pay_month,gmt_ovd_date,order_status,create_amt,overdue_days,overdue_amt,gmt_pay,memo)
SELECT
a.day_key                                                                                                                                        as day_key
,a.id                                                                                                                                            as credit_id
,'0'                                                                                                                                             as user_credentials_type
,ucase(a.dentity_card)                                                                                                                           as user_credentials_no
,a.name                                                                                                                                          as user_name
,a.order_no                                                                                                                                      as order_no
,'1'                                                                                                                                             as biz_type
,(case when a.status in (5,6,7,8) then 'O'  when a.status in(2,3) then '0' else null end)                                                        as pay_month
,(case when a.status=12 then a.created_time when a.status in(2,4) and a.audit_time is not null then a.audit_time  
 when a.status in(2,4) and a.audit_time is null then a.created_time when a.status in(5,6,7,8) then a.shouldback_time 
 when a.status=3 then a.arrive_time end)                                                                                                         as gmt_ovd_date
,(case when a.status=4 then '01' when a.status=12 then '02' when a.status in(2,3,5,6,7,8) then '04' end)                                         as order_status
,a.balance                                                                                                                                       as create_amt
,(case when a.status in(6,8) then datediff(now(),a.shouldback_time) when a.status in(2,3,5,7) then '0' else null end)                            as overdue_days
,(case when a.status in(2,3,5,7) then '0' when a.status in(6,8) then a.actual_amount else null end)                                              as overdue_amt
,(case when a.status in(5,7) then date(a.actual_time) else null end)   
,''                                                                                                                                              as memo
FROM
(
SELECT
date_sub(CURRENT_DATE,INTERVAL 1 day) as day_key
,id
,name
,dentity_card
,order_no
,status
,created_time
,audit_time
,shouldback_time
,balance 
,actual_time
,(balance+profit+overdue_fee-overdue_fee_derate-deduction_fee) as actual_amount
,arrive_time
from bmdb.tb_credit_record  where  status in(3,4,5,6,7,8,12) and cre_update_time>=@stat and cre_update_time<date_add(@stat,INTERVAL 1 day)
and order_no not in(
'201710201016257804',
'201710201016063911',
'201710201017362902',
'201710201016206559',
'201710201016253964',
'201710201016182193',
'201710201017265907',
'201710201017268241',
'201710201016525756',
'201710201017450033',
'201710201017322964',
'201710201016444789',
'201710201017161163',
'201710201017122340',
'201710201015193447',
'201710201015376380',
'201710201015289001',
'201710201015260095',
'201710201015370917',
'201710200952411164',
'201710200952378448',
'201710200952586759',
'201710200953009122',
'201710200953394999',
'201710200952338132',
'201710200953171413',
'201710200954246630',
'201710200953227077',
'201710200953008307',
'201710200952467141',
'201710200953156121',
'201710200954132456',
'201710200952191589',
'201710200953151480',
'201710200953599476',
'201710200952237365',
'201710200953341557',
'201710200954034041',
'201710200953160322',
'201710200937590193',
'201710200938571919',
'201710200938304846',
'201710200937573812',
'201710200938493647',
'201710200938130123',
'201710200938257647',
'201710200939008763',
'201710200932324737',
'201710200931345971',
'201710200931171417',
'201710200932300664',
'201710200931553145',
'201710200932141216',
'201710200931575462',
'201710200931317537',
'201710200932019309',
'201710200932109127',
'201710200932074983',
'201710200932140096',
'201710200932455382',
'201710200932171694',
'201710200931178731',
'201710200932190877',
'201710200932134360',
'201710200931216922',
'201710200931589081',
'201710200931131111',
'201710191652292078',
'201710191654516416',
'201710191655441806',
'201710191655301998',
'201710191652583231',
'201710191653455753',
'201710191655488107',
'201710191655591784',
'201710191657038730',
'201710191656185431',
'201710191653556454',
'201710191655379231',
'201710191656493882',
'201710191654236890',
'201710191653006633',
'201710191654366425',
'201710191656258054',
'201710191656324895',
'201710191656503955',
'201710191656288705',
'201710231752298432')
group by 1,2,2,4,5,6,7,8,9,10,11,12,13
)a;
####备份数据######
#INSERT into reportdb.tb_zhima_feedback SELECT * from bmdb.tb_zhima_feedback;
  RETURN 1;  
END