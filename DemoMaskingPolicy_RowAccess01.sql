-- criar de roles para a Demo Data Masking
USE ROLE useradmin;
CREATE ROLE itc_admin;
CREATE ROLE marketing;
CREATE ROLE it;
CREATE ROLE infosec;
CREATE ROLE executive;

-- permissões de acesso ao warehouse
USE ROLE accountadmin;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE itc_admin;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE marketing;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE it;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE executive;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE infosec;

-- criar Objetos
USE ROLE sysadmin;
CREATE DATABASE REYNHOLM_IND_DATA;
GRANT OWNERSHIP ON DATABASE REYNHOLM_IND_DATA TO ROLE itc_admin;
GRANT ROLE itc_admin TO USER JacquelineQuissi;
GRANT ROLE marketing TO USER JacquelineQuissi;
GRANT ROLE it TO USER JacquelineQuissi;
GRANT ROLE executive TO USER JacquelineQuissi;
GRANT ROLE infosec TO USER JacquelineQuissi;


USE ROLE itc_admin;
CREATE SCHEMA REYNHOLM_IND_DATA.BASEMENT WITH MANAGED ACCESS;



-- Tabela para a Demo (sample data in the TPCDS)
-- obs: as colunas C_BIRTH_COUNTRYe OPTIN serão preenchidas aleatoriamente com um dos três valores.
create table CUSTOMERS as (
    SELECT 
        a.C_SALUTATION,
        a.C_FIRST_NAME,
        a.C_LAST_NAME,
            CASE UNIFORM(1,3,RANDOM()) 
                WHEN 1 THEN 'UK' 
                WHEN 2 THEN 'US' 
                ELSE 'FRANCE' 
            END AS C_BIRTH_COUNTRY,
        a.C_EMAIL_ADDRESS,
        b.CD_GENDER,
        b.CD_CREDIT_RATING,
            CASE UNIFORM(1,3,RANDOM()) 
                WHEN 1 THEN 'YES' 
                WHEN 2 THEN 'NO' 
                ELSE NULL 
            END AS OPTIN
    FROM 
        SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER a,
        SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER_DEMOGRAPHICS b
    WHERE
        a.C_CUSTOMER_SK = b.CD_DEMO_SK and 
        a.C_SALUTATION is not null and
        a.C_FIRST_NAME is not null and
        a.C_LAST_NAME is not null and
        a.C_BIRTH_COUNTRY is not null and
        a.C_EMAIL_ADDRESS is not null and 
        b.CD_GENDER is not null and
        b.CD_CREDIT_RATING is not null
    LIMIT 200 )
;


-- grants dos objetos para as roles 
--database
grant usage on database REYNHOLM_IND_DATA to role itc_admin;
grant usage on database REYNHOLM_IND_DATA to role marketing;
grant usage on database REYNHOLM_IND_DATA to role it;
grant usage on database REYNHOLM_IND_DATA to role executive;
grant usage on database REYNHOLM_IND_DATA to role infosec;
--schema
grant usage on schema REYNHOLM_IND_DATA.BASEMENT to role itc_admin;
grant usage on schema REYNHOLM_IND_DATA.BASEMENT to role marketing;
grant usage on schema REYNHOLM_IND_DATA.BASEMENT to role it;
grant usage on schema REYNHOLM_IND_DATA.BASEMENT to role executive;
grant usage on schema REYNHOLM_IND_DATA.BASEMENT to role infosec;
--table
grant select on table REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS to role marketing;
grant select on table REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS to role it;
grant select on table REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS to role executive;
grant select on table REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS to role itc_admin;
grant select on table REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS to role infosec;


--tabela Mapping
create table REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING (
  role_name varchar,
  national_letter varchar,
  allowed varchar
);

--grants para a role infosec 
grant CREATE ROW ACCESS POLICY on schema REYNHOLM_IND_DATA.BASEMENT to role infosec;
grant create masking policy on schema REYNHOLM_IND_DATA.BASEMENT to role infosec;
grant select on table REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING to role infosec;
grant insert on table REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING to role infosec;

use role infosec;
/* ROW_ACCESS_MAPPING-tabela de mapeamento: Esta tabela define quais linhas na tabela customers as roles podem ver.*/
insert into REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING
  values
  ('ACCOUTADMIN',    '',        'FALSE'),
  ('ITC_ADMIN',      '',        'FALSE'),
  ('MARKETING',      'UK',      'TRUE'),
  ('IT',             'FRANCE',  'TRUE'),
  ('INFOSEC',        '',        'FALSE'),
  ('EXECUTIVE',      'FRANCE',  'TRUE'),
  ('EXECUTIVE',      'UK',      'TRUE'),
  ('EXECUTIVE',      'US',      'TRUE');

SELECT * FROM  REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING;
