SELECT
  UNIX_TIMESTAMP(arrive_time) as time_sec,
  sum(actual_balance) as value,
  '放款金额' as metric
FROM bmdb.tb_credit_record
WHERE $__timeFilter(arrive_time) and  status in(3,5,6,7,8)
GROUP BY metric,date(arrive_time)
ORDER BY time_sec asc





SELECT
  UNIX_TIMESTAMP(create_time) as time_sec,
  sum(actual_fee) as value,
  '还款金额' as metric
FROM bmdb.tb_repayment_record
WHERE $__timeFilter(create_time) 
GROUP BY metric,date(create_time)
ORDER BY time_sec asc
