BEGIN
set@num=(select reportdb.func_agg_first_success_loan_repay_user(idate));
set@num1=(select reportdb.func_zhima_feedback(idate));
return 1;
END