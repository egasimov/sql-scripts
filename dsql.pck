create or replace package dsql is

  -- Author  : EGASIMOV
  -- Created : 02-Apr-20 12:47:16 PM
  -- Purpose : Dynamic SQL 

  -- Public function and procedure declarations
  function <FunctionName>(<Parameter> <Datatype>) return <Datatype>; */
  PROCEDURE print_rec(rec in DBMS_SQL.DESC_REC);
  function getInfoAboutTable (p_table_name in varchar2) return NUMBER;
  procedure getINFO;

  FUNCTION getInfoAsClob(p_view_name in varchar2) return clob;
end dsql;
/
create or replace package body dsql is

  -- Initialization

 PROCEDURE print_rec(rec in DBMS_SQL.DESC_REC ) IS
  BEGIN
    DBMS_OUTPUT.ENABLE(1000000); 
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('col_type            =    '
                         || rec.col_type);
    DBMS_OUTPUT.PUT_LINE('col_maxlen          =    '
                         || rec.col_max_len);
    DBMS_OUTPUT.PUT_LINE('col_name            =    '
                         || rec.col_name);
    DBMS_OUTPUT.PUT_LINE('col_name_len        =    '
                         || rec.col_name_len);
    DBMS_OUTPUT.PUT_LINE('col_schema_name     =    '
                         || rec.col_schema_name);
    DBMS_OUTPUT.PUT_LINE('col_schema_name_len =    '
                         || rec.col_schema_name_len);
    DBMS_OUTPUT.PUT_LINE('col_precision       =    '
                         || rec.col_precision);
    DBMS_OUTPUT.PUT_LINE('col_scale           =    '
                         || rec.col_scale);
    DBMS_OUTPUT.PUT('col_null_ok         =    ');
    IF (rec.col_null_ok) THEN
      DBMS_OUTPUT.PUT_LINE('true');
    ELSE
      DBMS_OUTPUT.PUT_LINE('false');
    END IF;
  END;
  
  procedure getColNameAndType(rec in DBMS_SQL.DESC_REC  , p_coll_name out varchar2 , p_coll_type out  number)
    is
    begin
       p_coll_name :=rec.col_name;
       p_coll_type :=rec.col_type;

    end;
  

  
  procedure getINFO IS   
    cid          NUMBER;   
    l_sql        VARCHAR2 (2000) := 'SELECT * FROM HR.COUNTRIES';   
    fdb          NUMBER;   
    l_varchar2   VARCHAR2 (4000);   
    l_number     NUMBER;  
    l_cnt        NUMBER;  
    l_ret        NUMBER;  
    l_date       DATE;   
    l_tab        DBMS_SQL.desc_tab;  
  BEGIN
    
     cid := DBMS_SQL.OPEN_CURSOR;   
     DBMS_SQL.PARSE (cid, l_sql, DBMS_SQL.native);  
     DBMS_SQL.DESCRIBE_COLUMNS (cid, l_cnt, l_tab);
       -- fetch rows   
     FOR i IN 1 .. l_cnt LOOP   
        
      DBMS_OUTPUT.put_line (l_tab(i).col_name);  
        
      IF (l_tab (i).col_type = 1) THEN                         
        -- data type VARCHAR2 THEN   
        DBMS_SQL.define_column (cid, i, l_varchar2, 4000);  
        DBMS_OUTPUT.put_line (l_varchar2);   
      ELSIF (l_tab (i).col_type = 2)  THEN                       
        -- data type NUMBER THEN   
        DBMS_SQL.define_column (cid, i, l_number);   
        DBMS_OUTPUT.put_line (TO_CHar(l_number));  
      ELSIF (l_tab (i).col_type = 12)  THEN  
         -- data type DATE THEN   
        DBMS_SQL.define_column (cid, i, l_date);  
      ELSE  
        DBMS_SQL.define_column (cid, i, l_varchar2, 4000);  
      END IF;   
     END LOOP;    
  
     fdb := DBMS_SQL.execute (cid);     
       
     WHILE (DBMS_SQL.fetch_rows (cid) > 0) LOOP   
         FOR j IN 1..l_cnt LOOP  
              IF (l_tab(j).col_type = 1) THEN                         
                -- data type VARCHAR2 THEN   
                DBMS_SQL.COLUMN_VALUE(cid, j, l_varchar2);  
                DBMS_OUTPUT.put_line (l_varchar2);   
              ELSIF (l_tab (j).col_type = 2)  THEN                       
                -- data type NUMBER THEN   
                DBMS_SQL.COLUMN_VALUE(cid, j, l_number);   
                DBMS_OUTPUT.put_line (To_Char(l_number));  
              ELSIF (l_tab (j).col_type = 12)  THEN  
                 -- data type DATE THEN   
                DBMS_SQL.COLUMN_VALUE(cid, j, l_date);  
                DBMS_OUTPUT.put_line (l_date);  
              ELSE  
                DBMS_SQL.COLUMN_VALUE(cid, j, l_varchar2);  
                DBMS_OUTPUT.put_line (l_varchar2);  
              END IF;  
         END LOOP;  
     END LOOP;  
       
     DBMS_SQL.CLOSE_CURSOR(cid);    
  
  
  END;

  
  FUNCTION getInfoAsClob(p_view_name in varchar2) return clob
    IS
    cid          NUMBER;   
    l_sql        VARCHAR2 (2000);   
    fdb          NUMBER;   
    l_varchar2   VARCHAR2 (4000);   
    l_number     NUMBER;  
    l_cnt        NUMBER;  
    l_ret        NUMBER;  
    l_date       DATE;   
    l_tab        DBMS_SQL.desc_tab;  
    L_ret_val    clob;
    l_str_text   varchar2(2000 char):='';
    l_length     number:=25;
  BEGIN
      
     dbms_lob.createtemporary(l_ret_val, TRUE, dbms_lob.session);
     
     l_sql:='SELECT * FROM ' || p_view_name ;
     
     
     cid := DBMS_SQL.OPEN_CURSOR;   
     DBMS_SQL.PARSE (cid, l_sql, DBMS_SQL.native); 
     DBMS_SQL.DESCRIBE_COLUMNS (cid, l_cnt, l_tab);
     
       -- fetch rows   
     FOR i IN 1 .. l_cnt LOOP   
        
      DBMS_OUTPUT.put_line (l_tab(i).col_name);  
      l_str_text:= l_str_text || l_tab(i).col_name || rpad(' ',l_length - length(l_tab(i).col_name),' ') ;
        
      IF (l_tab (i).col_type = 1) THEN                         
        -- data type VARCHAR2 THEN   
        DBMS_SQL.define_column (cid, i, l_varchar2, 4000);  
        DBMS_OUTPUT.put_line (l_varchar2);   
      ELSIF (l_tab (i).col_type = 2)  THEN                       
        -- data type NUMBER THEN   
        DBMS_SQL.define_column (cid, i, l_number);   
        DBMS_OUTPUT.put_line (TO_CHar(l_number));  
      ELSIF (l_tab (i).col_type = 12)  THEN  
         -- data type DATE THEN   
        DBMS_SQL.define_column (cid, i, l_date);  
      ELSE  
        DBMS_SQL.define_column (cid, i, l_varchar2, 4000);  
      END IF;   
     END LOOP;    
     
     dbms_lob.append(l_ret_val,l_str_text || chr(13));
     l_str_text:=null;
     fdb := DBMS_SQL.execute (cid);     
       
     WHILE (DBMS_SQL.fetch_rows (cid) > 0) LOOP
         l_str_text:='';   
         FOR j IN 1..l_cnt LOOP  
              IF (l_tab(j).col_type = 1) THEN                         
                -- data type VARCHAR2 THEN   
                DBMS_SQL.COLUMN_VALUE(cid, j, l_varchar2);  
                DBMS_OUTPUT.put_line (l_varchar2); 
                l_str_text:=l_str_text || l_varchar2;
                l_str_text:=l_str_text|| rpad(' ',l_length - length(l_varchar2),' ') ;   
              ELSIF (l_tab (j).col_type = 2)  THEN                       
                -- data type NUMBER THEN   
                DBMS_SQL.COLUMN_VALUE(cid, j, l_number);   
                DBMS_OUTPUT.put_line (To_Char(l_number));  
                l_str_text:=l_str_text || To_Char(l_number);
                l_str_text:=l_str_text||rpad(' ',l_length - length(To_Char(l_number)),' ') ;   

              ELSIF (l_tab (j).col_type = 12)  THEN  
                 -- data type DATE THEN   
                DBMS_SQL.COLUMN_VALUE(cid, j, l_date);  
                DBMS_OUTPUT.put_line (l_date);  
                l_str_text:=l_str_text || l_date;
                l_str_text:=l_str_text|| rpad(' ',l_length - length(l_date),' ') ;   

              ELSE  
                DBMS_SQL.COLUMN_VALUE(cid, j, l_varchar2);  
                DBMS_OUTPUT.put_line (l_varchar2);  
                l_str_text:=l_str_text || l_varchar2;
                l_str_text:=l_str_text|| rpad(' ',l_length - length(l_varchar2),' ') ;   

              END IF;  
         END LOOP;
         dbms_lob.append(l_ret_val,l_str_text||chr(13));  
     END LOOP;  
       
     DBMS_SQL.CLOSE_CURSOR(cid);    
  
     return l_ret_val;
  END;
   
end dsql;
/
