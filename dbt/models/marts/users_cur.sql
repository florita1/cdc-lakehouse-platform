{{ config(
  materialized='table',
  engine=adapter.dispatch('ch_replacing_merge_tree')('id', ver_col='_lsn', order_by='(id)')
) }}

select
    toUInt64(0)  as id,
    ''           as name,
    ''           as email,
    toUInt8(0)   as is_deleted,
    toUInt8(0)   as _op,
    toUInt64(0)  as _lsn,
    toDateTime(0) as _ts
    where 1 = 0
