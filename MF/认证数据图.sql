SELECT
  UNIX_TIMESTAMP(create_time) as time_sec,
  count(uid) as value,
  '实名人数' as metric
FROM bmdb.tb_shiming_record
WHERE $__timeFilter(create_time)
GROUP BY metric,date(create_time)
ORDER BY time_sec  asc




SELECT
  UNIX_TIMESTAMP(create_time) as time_sec,
  count(uid) as value,
  '个人信息' as metric
FROM bmdb.tb_personal_info
WHERE $__timeFilter(create_time) 
GROUP BY metric,date(create_time)
ORDER BY time_sec  asc






SELECT
  UNIX_TIMESTAMP(mobile_time) as time_sec,
  count(user_id) as value,
  '运营商认证' as metric
FROM bmdb.tb_user_task
WHERE $__timeFilter(mobile_time) and is_mobile=1
GROUP BY metric,date(mobile_time)
ORDER BY time_sec  asc







SELECT
  UNIX_TIMESTAMP(liveness_time) as time_sec,
  count(user_id) as value,
  '人脸认证' as metric
FROM bmdb.tb_user_task
WHERE $__timeFilter(liveness_time) and is_liveness=1
GROUP BY metric,date(liveness_time)
ORDER BY time_sec  asc







SELECT
UNIX_TIMESTAMP(create_time) as time_sec,
count(id) as value,
'芝麻认证' as metric
FROM bmdb.tb_zhima_credit 
WHERE $__timeFilter(create_time)
GROUP BY metric,date(create_time) 
ORDER BY time_sec  asc





SELECT
UNIX_TIMESTAMP(create_time) as time_sec,
count(uid) as value,
'银行卡认证' as metric
FROM bmdb.tb_userbank_record 
WHERE $__timeFilter(create_time)
GROUP BY metric,date(create_time)
ORDER BY time_sec  asc




SELECT
UNIX_TIMESTAMP(created) as time_sec,
count(user_id) as value,
'通讯录认证' as metric
FROM bmdb.tb_user_addresslist 
WHERE $__timeFilter(created)
GROUP BY metric,date(created)
ORDER BY time_sec  asc



SELECT
UNIX_TIMESTAMP(create_time) as time_sec,
count(uid) as value,
'紧急联系人' as metric
FROM bmdb.tb_urgency 
WHERE $__timeFilter(create_time)
GROUP BY metric,date(create_time)
ORDER BY time_sec  asc