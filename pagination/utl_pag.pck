CREATE OR REPLACE PACKAGE utl_pag AS
    
    -- Author  : EGASIMOV
    -- Created : 09-Oct-21 02:47:16 AM
    -- Purpose : Some Utility functionalities which uses dynmamic sql on the behalf
         
    function fetch_paginated_data(
        p_table_name in varchar2,
        p_sort_data in t_str_num_coll,
        p_page_no in number,
        p_page_size in number
    ) return sys_refcursor;
    
    -- Initialization
    procedure init(p_schema_name in varchar2);
    
END utl_pag;
/
CREATE OR REPLACE PACKAGE BODY utl_pag AS

    --   
    function fetch_paginated_data(
        p_table_name in varchar2,
        p_sort_data in t_str_num_coll,
        p_page_no in number,
        p_page_size in number
    ) return sys_refcursor
        is
        l_object_name     varchar2(50);
        l_object_type     varchar2(50);
        l_object_owner    varchar2(50);
        l_columns         t_str_coll;
        l_cursor          integer;                        -- holds cursor ID
        l_dot_position    integer;                        -- represents position of '.'(dot) in string
        l_sqlQuery        varchar2(4000);                 -- dynamic sql
        l_query_sort_part varchar2(4000);                 -- sorting part of sql
        l_ignore          integer;                        
        l_result          SYS_REFCURSOR;
    begin
      
        --pre conditions should be checked
        if p_table_name is null or length(p_table_name) = 0 then
            raise_application_error(-20001, 'Table(or view) name should be provided : ' || p_table_name);
        end if;

        if p_page_no < 1 then
            raise_application_error(-20001, 'Invalid page number provided');
        end if;

        l_dot_position := instr(p_table_name, '.', 1, 1);

        if l_dot_position > 0 then
            l_object_owner := upper(substr(p_table_name, 1, l_dot_position - 1));
            l_object_name := upper(substr(p_table_name, l_dot_position + 1));
        elsif (l_dot_position = 0) then
            l_object_owner := upper(sys_context('userenv', 'current_schema'));
            l_object_name := upper(p_table_name);
            /*else
                raise_application_error(-20001, 'Invalid table name : ' || p_table_name || '  ' || l_dot_position);
            */end if;

        begin
            select t.OBJECT_TYPE
            into
                l_object_type
            from "PUBLIC".all_objects t
            where t.object_name = l_object_name
              and t.OWNER = l_object_owner;
        exception
            when NO_DATA_FOUND
                then
                    raise_application_error(-20001, 'Table or view { ' || p_table_name || ' } does not exist in schema: { ' || l_object_owner || ' }');
            when others
                then
                    -- Normally we would call another procedure, declared with PRAGMA
                    -- AUTONOMOUS_TRANSACTION, to insert information about errors.
                    raise_application_error(-20001, 'DBMS ERROR ' || SQLCODE || ':' || SQLERRM);
        end;

        if p_sort_data.count = 0 then
            raise_application_error(-20001, 'Sorting data(COLUMN_NAME, SORT_TYPE) informTion should be provided');
        end if;

        l_query_sort_part := 'ORDER BY ';
        for curr in (
            select upper(t.STR)      as COL_NAME,
                   case
                       when t.NUM = 1
                           then ' ASC '
                       else
                           ' DESC '
                       end           as SORT_BY

            from table(p_sort_data) t
            )
            loop
                l_query_sort_part := l_query_sort_part || curr.COL_NAME || ' ' || curr.SORT_BY || ' ,';
            end loop;

        l_query_sort_part := substr(l_query_sort_part, 1, length(l_query_sort_part) - 1); -- remove last symbol

        l_sqlQuery :=
                    'SELECT t.*  
                     FROM (  
                     SELECT e.*, ROW_NUMBER() over ( :sort_part ) rn
                     FROM :object_owner.:object_name e 
                     ) t 
                    WHERE t.rn > ( :p_page_no - 1) * :p_page_size 
                    AND t.rn <= :p_page_no * :p_page_size ';

        l_cursor := DBMS_SQL.OPEN_CURSOR;

        l_sqlQuery := replace(l_sqlQuery, ':sort_part', l_query_sort_part);
        l_sqlQuery := replace(l_sqlQuery, ':object_owner', l_object_owner);
        l_sqlQuery := replace(l_sqlQuery, ':object_name', l_object_name);
        l_sqlQuery := replace(l_sqlQuery, ':p_page_no', p_page_no);
        l_sqlQuery := replace(l_sqlQuery, ':p_page_size', p_page_size);

        --raise_application_error(-20001, 'sql: ' || l_sqlQuery);

        DBMS_SQL.PARSE(l_cursor, l_sqlQuery, DBMS_SQL.NATIVE);

       /*     
        DBMS_SQL.BIND_VARIABLE(l_cursor, ':sort_part', l_query_sort_part);
        DBMS_SQL.BIND_VARIABLE(l_cursor, ':object_owner', l_object_owner);
        DBMS_SQL.BIND_VARIABLE(l_cursor, ':object_name', l_object_name);
        DBMS_SQL.BIND_VARIABLE(l_cursor, ':p_page_no', p_page_no);
        DBMS_SQL.BIND_VARIABLE(l_cursor, ':p_page_size', p_page_size);
       */

        l_ignore := DBMS_SQL.EXECUTE(l_cursor);

        l_result := DBMS_SQL.TO_REFCURSOR(l_cursor);

        --DBMS_SQL.CLOSE_CURSOR(l_cursor);
        return l_result;
    end;

    --
    procedure init(p_schema_name in varchar2) is
      l_schema_name              varchar2(50);
    begin
      
      l_schema_name := upper(nvl(p_schema_name, sys_context('userenv', 'current_schema')));
    
      execute immediate 'GRANT EXECUTE ON DBMS_SQL TO ' || l_schema_name;

      execute immediate 'CREATE OR REPLACE TYPE '|| l_schema_name || '.t_str_coll is table of varchar2(4000)';
      execute immediate 'CREATE OR REPLACE TYPE '|| l_schema_name || '.t_str_num AS OBJECT ( str VARCHAR2(4000), num NUMBER)';
      execute immediate 'CREATE OR REPLACE TYPE '|| l_schema_name || '.t_str_num_coll IS TABLE OF t_str_num';
    
    end init;


END utl_pag;
/
