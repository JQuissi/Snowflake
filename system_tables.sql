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




