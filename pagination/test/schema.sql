select  sys_context('userenv', 'current_schema') as l_schema_name
from dual;

GRANT EXECUTE ON DBMS_SQL TO l_schema_name;

CREATE OR REPLACE TYPE t_str_coll is table of varchar2(4000);
CREATE OR REPLACE TYPE t_str_num AS OBJECT ( str VARCHAR2(4000), num NUMBER);
CREATE OR REPLACE TYPE t_str_num_coll IS TABLE OF t_str_num;

-- Create table
create table  EMPLOYEES
(
  employee_id    NUMBER(6) not null,
  first_name     VARCHAR2(20),
  last_name      VARCHAR2(25),
  email          VARCHAR2(25),
  phone_number   VARCHAR2(20),
  hire_date      DATE,
  job_id         VARCHAR2(10),
  salary         NUMBER(8,2),
  commission_pct NUMBER(2,2),
  manager_id     NUMBER(6),
  department_id  NUMBER(4)
)
-- Create/Recreate primary, unique and foreign key constraints 
alter table  EMPLOYEES
  add constraint EMP_EMP_ID_PK primary key (EMPLOYEE_ID);