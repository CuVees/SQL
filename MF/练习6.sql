select 
		DATE_FORMAT(t.arrive_time,'%Y%m')放款月,
		sum(t.balance)放款金额,
		sum(case when is_receivable=1 then t.balance else 0 end)应收金额,
		SUM(CASE WHEN is_receivable=1 AND (overdue_cur=0 OR overdue_cur IS NULL) THEN  t.balance ELSE 0 END )正常,
		sum(case when is_receivable=1 and overdue_cur>0 then t.balance else 0 end)逾期,
		sum(case when is_receivable=1 and overdue_cur BETWEEN 1 AND 2 then t.balance else 0 end)/sum(case when is_receivable=1 then t.balance else 0 end) 'D1-D2',
		sum(case when is_receivable=1 and overdue_cur BETWEEN 3 AND 6 then t.balance else 0 end)/sum(case when is_receivable=1 then t.balance else 0 end) 'D3-D6',
		sum(case when is_receivable=1 and overdue_cur BETWEEN 7 AND 14 then t.balance else 0 end)/sum(case when is_receivable=1 then t.balance else 0 end) 'D7-D14',
		sum(case when is_receivable=1 and overdue_cur BETWEEN 15 AND 30 then t.balance else 0 end)/sum(case when is_receivable=1 then t.balance else 0 end) 'D15-D30',
		sum(case when is_receivable=1 and overdue_cur BETWEEN 31 AND 60 then t.balance else 0 end)/sum(case when is_receivable=1 then t.balance else 0 end) 'M1',
		sum(case when is_receivable=1 and overdue_cur BETWEEN 61 AND 90 then t.balance else 0 end)/sum(case when is_receivable=1 then t.balance else 0 end) 'M2',
		sum(case when is_receivable=1 and overdue_cur >90 THEN   t.balance else 0 end)/sum(case when is_receivable=1 then t.balance else 0 end) 'M3+'
from 
(
		SELECT 
				
				cr.balance,
				
				cr.arrive_time,

				case when cr.shouldback_time<now() then 1 when cr.shouldback_time>=now() then 0 else null  end as is_receivable,

				case when  rr.actual_time is null and cr.shouldback_time<now() then DATEDIFF(now(),cr.shouldback_time)else null end as overdue_cur

		from bmdb.tb_credit_record cr 
		left join bmdb.tb_repayment_record rr
		on cr.id=rr.credit_id
		where cr.shouldback_time is not null 
)t
GROUP BY 1 
