CREATE OR REPLACE FUNCTION getInfoAsClob(p_view_name in varchar2) return clob
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
