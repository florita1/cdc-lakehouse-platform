{{ config(
  materialized='table',
  engine='ReplacingMergeTree(_lsn)',
  order_by='(id)'
) }}

-- empty SELECT just to emit the exact DDL; ingestion writes the rows
select
    toUInt64(0)  as id,
    ''           as name,
    ''           as email,
    toUInt8(0)   as is_deleted,
    toUInt8(0)   as _op,
    toUInt64(0)  as _lsn,
    toDateTime(0) as _ts
    where 1 = 0
