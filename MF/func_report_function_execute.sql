BEGIN
#set@num=(select reportdb.func_agg_first_success_loan_repay_user(idate));
#set@num1=(select reportdb.func_zhima_feedback(idate));
set@num3=(select reportdb.func_report_risk_management_passing_rate(idate));
set@num4=(select reportdb.func_report_partner_effect(idate));
#set@num5=(select reportdb.func_report_old_user_re_cast(idate));
set@num6=(select reportdb.func_report_overdue_order_day(idate));
set@num7=(select reportdb.func_report_recovery_order_rate(idate));
set@num8=(select reportdb.func_report_jiedai_funnel(idate));
set@num9=(select reportdb.func_report_order_count(idate));
RETURN 1; 
END
 