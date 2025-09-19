
{{ config(materialized='view') }}

with base as (
  select *
  from {{ source('staging', 'sn_incidents') }}
),

deduplicate as (
  select * except(rn)
  from (
    select 
      *,
      row_number() over (
        partition by number
        order by sys_updated_on desc nulls last
      ) as rn
    from base
  )
  where rn = 1
),

normalize as (
  select
    sla_business_percentage as sla_percentage,
    sys_id as ID,
    number as incident_number,
    short_description,
    state,
    category,
    caller_id,
    opened_by,
    sys_created_on created_on,
    sys_updated_on as updated_on,
    resolved_at,
    cast(
        case
            when priority like '%1%' then 1
            when priority like '%2%' then 2
            when priority like '%3%' then 3
            when priority like '%4%' then 4
            when priority like '%5%' then 5
            else null
        end as int64
    ) as priority,
  from deduplicate
),

with_targets as (
  select n.*, t.target_hours
  from normalize n
  left join {{ ref('priority_targets') }} t
  using (priority)
),

metrics as (
  select
    *,
    timestamp_add(created_on, interval target_hours hour) as due_at,
    timestamp_diff(resolved_at, created_on, hour) as duration_hours,
    case
      when resolved_at is null then null
      when timestamp_diff(resolved_at, created_on, hour) <= coalesce(target_hours, 72) then true
      else false
    end as met_sla
  from with_targets
)

select * from metrics
