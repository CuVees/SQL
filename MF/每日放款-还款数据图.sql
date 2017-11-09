SELECT 
DATE_FORMAT(t1.day_key,'%Y-%m-%d') as  '日期'
,t1.fk_cnt as '放款笔数_总'
,t1.fk_cnt_14 as '放款笔数_14天'
,t1.fk_cnt_7 as '放款笔数_7天'
,t1.fk_amount as '放款金额'
,t2.repay_cnt as '还款笔数'
,t2.repay_amount as '还款金额'
from 
(
SELECT date(arrive_time) as day_key
,COALESCE(count(id),0) as fk_cnt
,COALESCE(count(case when cycle=7 then id ELSE null end),0) as fk_cnt_7
,COALESCE(count(case when cycle=14 then id ELSE null end),0) as fk_cnt_14
,COALESCE(sum(actual_balance),0) as fk_amount
from bmdb.tb_credit_record where  $__timeFilter(arrive_time)
GROUP BY 1
)t1 left JOIN
(
SELECT date(actual_time) as day_key
,COALESCE(count(credit_id),0) as repay_cnt
,COALESCE(sum(actual_fee),0) as repay_amount
from bmdb.tb_repayment_record where $__timeFilter(actual_time)
GROUP BY 1
)t2 on t1.day_key=t2.day_key
GROUP BY 1
ORDER BY 1 desc 