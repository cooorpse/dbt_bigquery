
{{ config(
  materialized='table',
  partition_by = {'field': 'created_on', 'data_type': 'timestamp', 'granularity': 'day'},
  cluster_by   = ['priority']
) }}

select
  incident_number,
  category,
  priority,
  state,
  created_on,
  updated_on,
  resolved_at,
  due_at,
  duration_hours,
  safe_divide(duration_hours, 24) as duration_days,
  met_sla,

  -- buckets por prioridade
  case
    when priority <= 2 then 'High'
    when priority = 3 then 'Medium'
    else 'Low'
  end as priority_bucket,

  -- buckets de aging
  case
    when resolved_at is null then 'Unresolved'
    when duration_hours <= 4  then '0-4h'
    when duration_hours <= 24 then '4-24h'
    when duration_hours <= 72 then '1-3d'
    else '3d+'
  end as aging_bucket,

from {{ ref('stg_sn_incidents') }}
