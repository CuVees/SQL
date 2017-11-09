SELECT
  UNIX_TIMESTAMP(created_time) as time_sec,
  count(id) as value,
  '提交订单数' as metric
FROM bmdb.tb_credit_record
WHERE $__timeFilter(created_time)
GROUP BY metric,date(created_time)
ORDER BY time_sec asc




SELECT
  UNIX_TIMESTAMP(create_time) as time_sec,
  count(credit_id) as value,
  '还款订单数' as metric
FROM bmdb.tb_repayment_record
WHERE $__timeFilter(create_time) 
GROUP BY metric,date(create_time) 
ORDER BY time_sec asc