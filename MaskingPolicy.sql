--mascaramento dinâmico de dados
SELECT * FROM RAW.JAFFLE_SHOP.CUSTOMERS;
SELECT * FROM RAW.JAFFLE_SHOP.ORDERS;
SELECT * FROM RAW.STRIPE.PAYMENT;

USE ROLE useradmin;
CREATE ROLE ANALYST;

--permissões
USE ROLE accountadmin;
GRANT USAGE ON WAREHOUSE compute_wh TO ROLE ANALYST;
GRANT USAGE ON DATABASE RAW TO ROLE ANALYST;
GRANT USAGE ON SCHEMA RAW.JAFFLE_SHOP TO ROLE ANALYST;
GRANT SELECT ON TABLE RAW.JAFFLE_SHOP.CUSTOMERS TO ROLE ANALYST;

USE ROLE accountadmin;
GRANT USAGE ON WAREHOUSE compute_wh TO ROLE public ;
GRANT USAGE ON DATABASE RAW TO ROLE public;
GRANT USAGE ON SCHEMA RAW.JAFFLE_SHOP TO ROLE public;
GRANT SELECT ON TABLE RAW.JAFFLE_SHOP.CUSTOMERS TO ROLE public;

GRANT USAGE ON DATABASE DBT TO ROLE public;
GRANT USAGE ON SCHEMA DBT.PUBLIC TO ROLE public;
GRANT SELECT ON TABLE DBT.PUBLIC.STG_CUSTOMERS TO ROLE public;

USE ROLE useradmin;
GRANT ROLE ANALYST TO USER jacquelinequissi;

---- ## Etapa 1: Conceder privilégios de política de mascaramento para role personalizada ## ----
/*
Um responsável por segurança ou privacidade deve servir como administrador da política de mascaramento (ou seja, função personalizada: MASKING_ADMIN) e ter os privilégios de definir, gerenciar e aplicar políticas de mascaramento às colunas.
*/
--Crie uma função personalizada de administrador de políticas de mascaramento.
use role useradmin;
CREATE ROLE masking_admin;

USE ROLE accountadmin;
GRANT USAGE ON SCHEMA RAW.JAFFLE_SHOP TO ROLE masking_admin;

--Conceda privilégios à função masking_admin:
use role securityadmin;
GRANT CREATE MASKING POLICY on SCHEMA  RAW.JAFFLE_SHOP to ROLE masking_admin;

--SHOW GRANTS TO ROLE securityadmin;
USE ROLE accountadmin;
GRANT APPLY MASKING POLICY on ACCOUNT to ROLE masking_admin;

---- ## Etapa 2: Conceder a função personalizada a um usuário ## ----
--Conceda a função personalizada MASKING_ADMIN a um usuário que serve como responsável por segurança ou privacidade.
use role securityadmin;
GRANT ROLE masking_admin TO USER jacquelinequissi;

---- ## Etapa 3: Criar uma política de mascaramento ---- ##
--Usando a função MASKING_ADMIN, crie uma política de mascaramento e aplique-a a uma coluna.
USE ROLE MASKING_ADMIN;
--A operação em uma política de mascaramento também requer o privilégio USAGE no banco de dados pai e no esquema.
USE SCHEMA RAW.JAFFLE_SHOP;
CREATE OR REPLACE MASKING POLICY name_mask AS (val string) RETURNS string ->
  CASE
    WHEN CURRENT_ROLE() IN ('ANALYST') THEN val
    ELSE '*********'
  END;

DESC MASKING POLICY name_mask;
SHOW MASKING POLICIES;

---- ## Etapa 4: Aplicar uma política de mascaramento a uma coluna de tabela ou exibição ---- ##
-- apply masking policy to a table column
USE ROLE masking_admin;
ALTER TABLE RAW.JAFFLE_SHOP.CUSTOMERS MODIFY COLUMN FIRST_NAME SET MASKING POLICY name_mask;

--remover a plolitica do campo da tabela 
--ALTER TABLE RAW.JAFFLE_SHOP.CUSTOMERS MODIFY COLUMN FIRST_NAME UNSET MASKING POLICY;



---- ## Etapa 5: Consultar dados no Snowflake ## ----
-- using the ANALYST role
USE ROLE analyst;
SELECT * FROM RAW.JAFFLE_SHOP.CUSTOMERS; -- should see plain text value

-- using the PUBLIC role
USE ROLE public;
SELECT * FROM RAW.JAFFLE_SHOP.CUSTOMERS; -- should see full data mask

SELECT * FROM DBT.PUBLIC.STG_CUSTOMERS; -- masking aplicado na view

--https://docs.snowflake.com/pt/sql-reference/sql/alter-table-column
