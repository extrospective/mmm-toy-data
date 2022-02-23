
# user input
#
# plan spend for next 365 days
tv_plan_spend =  5000000
fb_plan_spend = 2000000
  
  
  
# 
# Read in rds which was saved by robyn_save() and has an embedded selected model
#
plot_folder = 'e:/repo/robyn-mmm/output'
filename = paste0(plot_folder,"/","mmm_2022_02_22.RDS")
tv_hist_spend = 1810935
fb_hist_spend = 1797576

#
# derive values
#
total_plan_spend = tv_plan_spend + fb_plan_spend
compute_target = c(tv_plan_spend / tv_hist_spend, fb_plan_spend/fb_hist_spend)
print(compute_target)
expected_optm_spend_unit_delta = c(tv_plan_spend / tv_hist_spend - 1, fb_plan_spend/fb_hist_spend - 1)
print(paste('Expected optm spend unit delta in ouptut', expected_optm_spend_unit_delta))

#
# Invoke allocator with min and max constraining optimizer; generates csv and png file
#

AllocatorCollect <- robyn_allocator(
  robyn_object = filename,
  scenario = "max_response_expected_spend",
  channel_constr_low = compute_target,
  channel_constr_up = compute_target,
  expected_spend = total_plan_spend,
  expected_spend_days = 365
)  

