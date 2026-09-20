{% macro get_raw_model(source_ref, load_timestamp='loaded_at') %}

    {{
        config(
            materialized='incremental'
        )
    }}

    {% set load_start = var('load_start') %}
    {% set load_end = var('load_end') %}

    select *, '{{ run_started_at }}'::timestamp as dbt_loaded_at, '{{ invocation_id }}' as dbt_batch_id
    from {{ source_ref }}
    {% if is_incremental() %}

        {% if load_start %}

            where {{ load_timestamp }} >= '{{ load_start }}'::timestamp

        {% else %}

            where loaded_at > (
                select max({{ load_timestamp }})
                from {{ this }}
            )

        {% endif %}

        {% if load_end %}

            and load_timestamp < '{{ load_end }}'::timestamp

        {% endif %}

    {% endif %}

{% endmacro %}