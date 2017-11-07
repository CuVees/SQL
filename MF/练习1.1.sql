select * 
from
(
	(
	 	select 
	 		dt 放款日期,
	 		product_id 产品描述,
	 		miaoshu 描述,
	 		sum(fangkuan) 放款金额,
	 		sum(yingshou) 应收金额,
	 		sum(shishou) 实收金额,
	 		sum(yuqi) 逾期,
	 		group_concat(concat(manager_name,cnt) separator ',') 放款人
	 	from
	 	(
	 		select 
	 			DATE_FORMAT(cr.arrive_time,'%Y%m%d') dt,
	 			product_id,
	 			manager_name,
	 			(case when cr.product_id=1 then '500-7天'
	 				  when cr.product_id=2 then '500-14天'
	 				  when cr.product_id=3 then '1000-7天'
	 				  when cr.product_id=4 then '1000-14天'
	 			 end) as miaoshu,
	 			sum(cr.actual_balance) as fangkuan,
	 			sum(cr.balance+cr.profit) as yingshou,
	 			sum(rr.actual_fee) as shishou,
	 			sum(case when cr.status=7 then cr.overdue_fee end) as yuqi,
	 			count(*) cnt
	 		from 
	 			tb_credit_record cr
	 		left join
	 		  	tb_repayment_record rr 
	 		on
	 			cr.id=rr.credit_id
	 		where 
	 			arrive_time>='2017-05-01' and arrive_time<='2017-07-26' and product_id in (1,2,3,4)
	 		group by 1,2,3
	 	) t 
	 	group by 1,2
	 	order by 1,2
	 )
 	union all
 	(
 		select 
 			DATE_FORMAT(cr.arrive_time,'%Y%m%d') dt,
 			product_id,
 			(case when cr.product_id=1 then '500-7天'
	 			  when cr.product_id=2 then '500-14天'
	 			  when cr.product_id=3 then '1000-7天'
	 			  when cr.product_id=4 then '1000-14天'
	 		end) as miaoshu,
	 		sum(cr.actual_balance) as fangkuan,
	 		sum(cr.balance+cr.profit) as yingshou,
	 		sum(rr.actual_fee) as shishou,
	 		sum(case when cr.status=7 then cr.overdue_fee end) as yuqi,
	 		manager_name
	 	from 
	 	  	tb_credit_record cr
	 	left join
	 	  	tb_repayment_record rr
	 	on
	 		cr.id=rr.id
	 	WHERE 
	 		arrive_time>='2017-05-01' AND arrive_time<'2017-07-26' AND cr.product_id IN (1,2,3,4)
	 	GROUP BY 
	 		dt,product_id,manager_name

 	) 
) t
order BY 
	1,2,3,4 DESC,8 DESC