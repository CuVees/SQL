SELECT case when trade_time >=date('2017-08-01') and trade_time<date('2017-09-01') then 8
            when trade_time >=date('2017-09-01') and trade_time<date('2017-10-01') then 9
            when trade_time >=date('2017-10-01') and trade_time<date('2017-11-01') then 10
						else 11
       END as '月份',
       sum(trade_amount) as '提现成功总金额'
from licaidb.tblc_user_account_trade
where trade_way=2 and trade_status=1
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
DATE_FORMAT(trade_time,'%Y-%m') as '月份',
       sum(trade_amount) as '提现成功总金额'
from licaidb.tblc_user_account_trade
where trade_way=2 and trade_status=1
GROUP BY 1
ORDER BY 1 DESC;