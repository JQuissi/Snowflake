use role infosec;
--criar row acess policy --1--
create or replace row access policy REYNHOLM_IND_DATA.BASEMENT.makes_no_sense as (C_BIRTH_COUNTRY varchar) returns boolean ->
  case
      -- check for full read access
      when exists ( 
            select 1 from REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING
              where role_name = current_role()
                and allowed = 'TRUE'
                and C_BIRTH_COUNTRY like national_letter
          ) then true    
      else false
  end
;


-- grant para aplicar a política --> role itc_admin;
use role securityadmin;
grant apply on row access policy REYNHOLM_IND_DATA.BASEMENT.makes_no_sense to role itc_admin;

-- aplicar a política em uma tabela 
use role ITC_ADMIN;
alter table REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS add row access policy REYNHOLM_IND_DATA.BASEMENT.makes_no_sense on (C_BIRTH_COUNTRY);
--alter table REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS drop row access policy REYNHOLM_IND_DATA.BASEMENT.makes_no_sense;

use role infosec;
--DROP ROW ACCESS POLICY REYNHOLM_IND_DATA.BASEMENT.makes_no_sense;
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- Criar masking policy --2-- 
use role infosec;
-- conditional masking version 
/*Essa política especifica dois arguntos COL_VALUE e OPTIN*/
create or replace masking policy REYNHOLM_IND_DATA.BASEMENT.hide_optouts as
(col_value varchar, optin string) returns varchar ->
  case
    when optin = 'YES' then col_value
    else '***MASKED***'
  end;
  
-- grant para aplicar a poltica --> role: itc_admin
use role securityadmin;
grant apply on masking policy REYNHOLM_IND_DATA.BASEMENT.hide_optouts to role itc_admin; 

--aplicar o masking na tabela
use role ITC_ADMIN;
alter table REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS modify column C_EMAIL_ADDRESS
    set masking policy REYNHOLM_IND_DATA.BASEMENT.hide_optouts using (C_EMAIL_ADDRESS, OPTIN);

----------------------------------------------------------------------------------------------------------------------
-- Criar masking policy --3-- 
use role infosec;
create or replace masking policy REYNHOLM_IND_DATA.BASEMENT.hide_column_values as
(col_value varchar) returns varchar ->
  case
    when current_role() = 'MARKETING' then col_value
    else '******'
  end;

-- grant para aplicar a poltica --> role: itc_admin
use role securityadmin;
grant apply on masking policy REYNHOLM_IND_DATA.BASEMENT.hide_column_values to role itc_admin; 

--aplicar o masking na tabela
use role ITC_ADMIN;
alter table REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS modify column CD_GENDER set masking policy REYNHOLM_IND_DATA.BASEMENT.HIDE_COLUMN_VALUES;

--alter table REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS modify column CD_GENDER NOT MASKED;
--alter table REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS drop masking policy REYNHOLM_IND_DATA.BASEMENT.HIDE_COLUMN_VALUES;


  
-------------------------------------------------------------------------------------------------------------------------------------
--verificar o data masking
use role marketing;
use role it;
use role executive;
use role itc_admin;
use role infosec;

select * from REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS;


select * from REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING;

USE ROLE ACCOUNTADMIN;
DESCRIBE ROW ACCESS POLICY REYNHOLM_IND_DATA.BASEMENT.makes_no_sense;
DESCRIBE MASKING POLICY REYNHOLM_IND_DATA.BASEMENT.HIDE_COLUMN_VALUES;
DESCRIBE MASKING POLICY REYNHOLM_IND_DATA.BASEMENT.HIDE_OPTOUTS;


use role ITC_ADMIN;
--alter table REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS modify column CD_GENDER UNSET MASKING POLICY;

use role infosec;
--DROP MASKING POLICY REYNHOLM_IND_DATA.BASEMENT.HIDE_COLUMN_VALUES;

SHOW MASKING POLICIES;
SHOW ROW ACCESS POLICIES;
