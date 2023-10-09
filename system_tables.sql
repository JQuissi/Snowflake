select 
    query_id
    , query_text 
    , database_name
    , schema_name
    , query_type
    , user_name
    , role_name
    , execution_status    
    , start_time
    , end_time
    , execution_time
from SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE user_name IS NOT NULL
    AND query_type = 'SELECT'
order by start_time desc;


--------------------------------------------------------------------

-- - acesso de tabelas
with temp_access_hist as (
  select       
    query_start_time
    , user_name
    , value:"objectDomain"::string as object_type
    , value:"objectName"::string as table_view_name
    , direct_objects_accessed
  from snowflake.account_usage.access_history,
  lateral flatten(
    input => to_variant(DIRECT_OBJECTS_ACCESSED)
  )
)
select
    *
from temp_access_hist
where object_type = 'View' or object_type = 'Table'
ORDER BY 1 desc;

------------------------------------------------------
--mapear todos os usuários, roles e privilégios da conta SF

SELECT
  u.user_id 
  , u.name AS user_name
  --, u. deleted_on 
  , u.login_name
  , u.display_name
  , u.first_name
  , u.last_name
  , u.email
  , u.disabled  
  , r.role_id
  --, r.deleted_on
  , r.name AS role_name
  --, gr.grantee_name as role_name
  , gr.granted_on as object_type  
  , gr.table_catalog AS database_name
  , gr.table_schema
  , gr.name as object_name  
  , gr.privilege
  , gr.grant_option
  --, gr.deleted_on 
  --, gu.CREATED_ON
  --, gu.DELETED_ON 
  --, gu.ROLE as role_name
  --, gu.GRANTEE_NAME as user_name  
FROM
  SNOWFLAKE.ACCOUNT_USAGE.USERS as u
LEFT JOIN
  SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS as gu ON u.name = gu.GRANTEE_NAME
LEFT JOIN
  SNOWFLAKE.ACCOUNT_USAGE.ROLES r ON r.name = gu.ROLE
LEFT JOIN
  SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES gr ON gr.grantee_name = r.name
WHERE u. deleted_on IS NULL
AND r.deleted_on IS NULL
AND gr.deleted_on IS NULL
AND gu.DELETED_ON IS NULL
ORDER BY
    r.role_id
    , u.user_id;


