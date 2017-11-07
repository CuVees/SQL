BEGIN  

delete from reportdb.report_liquidation_repay_record where day_key=idate ;

insert into reportdb.report_liquidation_repay_record(day_key,order_no,name,dentity_card,shouldback_time,actual_time,balance,cycle,actual_balance,

	                   fee,profit,actual_repay_amont,overdue_fee,overdue_fee_derate,deduction_fee,actual_overdue_fee,actual_fee,repay_type,uid,credit_id)

select 

date(t2.create_time) as day_key

,(case when t3.credit_id is not null then t3.serials_number else t1.order_no end)as order_no

,t1.name

,t1.dentity_card

,t1.shouldback_time

,t2.actual_time

,t1.balance

,t1.cycle

,t1.actual_balance

,t1.fee

,t1.profit

,sum(t1.profit+t1.balance) as actual_repay_amont

,t1.overdue_fee

,t1.overdue_fee_derate

,t1.deduction_fee

,t2.overdue_fee  as actual_overdue_fee 

,t2.actual_fee

,(case when t3.credit_id is  not null then 'initiative'

 when t3.credit_id is   null and t1.already_repay<>0 then 'line_down'

 else 'Withhold' end ) as repay_type

,t1.uid as uid

,t1.id  as credit_id

from 

	(

		select 

		distinct

		create_time

		,credit_id

		,normal_time

		,actual_time

		,actual_fee

		,overdue_fee

		from bmdb.tb_repayment_record  where create_time>=idate and create_time<date_add(idate,INTERVAL 1 DAY)	

	)t2 left join

	(

		select 

		distinct

		id

		,uid

		,created_time

		,order_no

		,name

		,dentity_card

		,shouldback_time

		,balance

		,cycle

		,actual_balance

		,fee

		,profit

		,overdue_fee

		,overdue_fee_derate 

		,deduction_fee

		,already_repay

		from bmdb.tb_credit_record  where status in(5,7)

	)t1 on t1.id=t2.credit_id left join

	(

		select 

		distinct

		credit_id

		,serials_number

		from bmdb.tb_credit_transactional where status=1

	)t3 on t2.credit_id=t3.credit_id

	group by 1,2,3,4,5,6,7,8,9,11,13,14,15,16,17,18,19,20;

  RETURN 1;  

END