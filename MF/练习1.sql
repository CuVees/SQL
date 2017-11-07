SELECT * 
FROM 
(
  (
  SELECT dt 放款日期
        ,product_id 产品类型
        ,miaosu 类型描述
        ,SUM(fangkuan) 放款金额
        ,SUM(yingshou) 应收金额
        ,SUM(shishou) 实收金额
        ,SUM(yuqi) 逾期费
        ,GROUP_CONCAT(CONCAT(manager_name,cnt) SEPARATOR ','
  ) 放款人 
  FROM
  (
    SELECT 
        DATE_FORMAT(cr.arrive_time,'%Y%m%d') dt
        ,product_id
        ,manager_name
        ,(CASE WHEN cr.product_id = 1 THEN '500-7天'  
               WHEN product_id = 2 THEN '500-14天' 
               WHEN product_id = 3 THEN '1000-7天'  
               WHEN product_id = 4 THEN '1000-14天' 
          END) AS miaosu
        ,SUM(cr.actual_balance) AS fangkuan
        ,SUM(cr.balance+cr.profit) yingshou
        ,SUM(rr.actual_fee) AS shishou
        ,SUM(CASE WHEN cr.`status` = 7 THEN cr.overdue_fee 
             END) AS yuqi
        ,COUNT(*) cnt
    FROM 
        tb_credit_record cr 
    LEFT JOIN 
        tb_repayment_record rr ON cr.id = rr.credit_id 
    WHERE arrive_time>='2017-05-01' AND arrive_time<'2017-07-26' AND cr.product_id IN (1,2,3,4) 
    GROUP BY 1,2,3
  ) t GROUP BY 1,2 ORDER BY 1,2
)
UNION ALL
(
SELECT 
    DATE_FORMAT(cr.arrive_time,'%Y%m%d') dt
    ,product_id,(CASE WHEN cr.product_id = 1 THEN '500-7天'  WHEN product_id = 2 THEN '500-14天' WHEN product_id = 3 THEN '1000-7天'  WHEN product_id = 4 THEN '1000-14天' END)AS miaosu
    ,SUM(cr.actual_balance) AS fangkuan
    ,SUM(cr.balance+cr.profit) yingshou
    ,SUM(rr.actual_fee) AS shishou
    ,SUM(CASE WHEN cr.`status` = 7 THEN cr.overdue_fee END) AS yuqi
    ,manager_name
FROM 
    tb_credit_record cr 
LEFT JOIN 
    tb_repayment_record rr 
ON cr.id = rr.credit_id 
WHERE arrive_time>='2017-05-01' AND arrive_time<'2017-07-26' AND cr.product_id IN (1,2,3,4)
GROUP BY dt,product_id,manager_name)
) t
ORDER BY 1,2,3,4 DESC,8 DESC
