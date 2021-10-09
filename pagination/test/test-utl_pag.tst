PL/SQL Developer Test script 3.0
17
declare
  -- Non-scalar parameters require additional processing 
  p_sort_data t_str_num_coll;
begin
  -- Call the init() function with user who having necessary privileges
  --utl_pag.init(p_schema_name => null);
  
  p_sort_data := t_str_num_coll(
            t_str_num('SALARY', -1), -- -1(negative one) means DESCENDING
            t_str_num('EMPLOYEE_ID', 1)); -- 1(positive one) means ASCENDING,

  -- Call the function
  :result := utl_pag.fetch_paginated_data(p_table_name => 'EMPLOYEES',
                                             p_sort_data => p_sort_data,
                                             p_page_no => 1,
                                             p_page_size => 5);
end;
4
result
1
<Cursor>
116
p_table_name
0
-5
p_page_no
0
-4
p_page_size
0
-4
0
