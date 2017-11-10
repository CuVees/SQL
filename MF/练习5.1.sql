SELECT
	a.operator,
	a.fengpei_cn,
	b.huishou_cnt,
	b.huishou_amount,
	b.overdue_amount
FROM
	(
		SELECT
			operator,
			operator_id,
			COUNT(DISTINCT credit_id) AS fengpei_cn
		FROM
			tb_overdue_flow_record
		WHERE
			update_time >= '2017-09-01'
		GROUP BY
			1,
			2
	) a
LEFT JOIN (
	SELECT
		t1.operator,
		t1.owner_id,
		COUNT(t1.credit_id) AS huishou_cnt,
		COUNT(DISTINCT t1.credit_id),
		SUM(t2.actual_fee) AS huishou_amount,
		SUM(t2.overdue_fee) AS overdue_amount
	FROM
		(
			SELECT
				s1.operator,
				s1.owner_id,
				s1.credit_id
			FROM
				(
					SELECT
						operator,
						owner_id,
						credit_id
					FROM
						tb_overdue_record
					WHERE
						shouldback_time >= '2017-08-31'
					GROUP BY
						1,
						2,
						3
				) s1
			LEFT JOIN (
				SELECT
					id AS credit_id
				FROM
					tb_credit_record
				WHERE
					STATUS = 7
				AND shouldback_time >= '2017-08-31'
			) s2 ON s1.credit_id = s2.credit_id
			WHERE
				s2.credit_id is NOT NULL
			GROUP BY
				1,
				2,
				3
		) t1
	LEFT JOIN (
		SELECT
			actual_fee,
			overdue_fee,
			credit_id
		FROM
			tb_repayment_record
		WHERE
			normal_time >= '2017-08-31'
		AND normal_time < '2017-09-21'
		GROUP BY
			1,
			2,
			3
	) t2 ON t1.credit_id = t2.credit_id
	GROUP BY
		1,
		2
) b ON a.operator_id = b.owner_id