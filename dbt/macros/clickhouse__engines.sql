{% macro ch_replacing_merge_tree(pk, ver_col=None, order_by=None, settings=None) -%}
ENGINE = ReplacingMergeTree{% if ver_col %}({{ ver_col }}){% endif %}
ORDER BY {{ order_by or pk }}
{%- if settings %}
SETTINGS {{ settings }}
{%- endif %}
{%- endmacro %}
