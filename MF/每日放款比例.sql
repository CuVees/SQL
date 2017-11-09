SELECT DATE_FORMAT(arrive_time,'%Y-%m-%d') '放款时间',sum(balance) as '放款总额',
       sum(case  WHEN task_status =4 then balance else 0 end ) as '老客放款',
			 sum(case WHEN task_status in (1,2,3) then balance else 0 end ) as '新客放款',
			 (sum(case WHEN task_status =4 then balance else 0 end ))/sum(balance) as '老客放款比例',
       (sum(case WHEN task_status in (1,2,3) then balance else 0 end ))/sum(balance) as '新客放款比例'
from bmdb.tb_credit_record a 
where arrive_time is not null  and $__timeFilter(arrive_time)
GROUP BY 1 
ORDER BY 1 desc