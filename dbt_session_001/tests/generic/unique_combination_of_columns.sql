{#
    Generic test: the combination of the given columns must be unique.
    Used to prove a model has exactly one row per declared grain.

        data_tests:
          - unique_combination_of_columns:
              arguments:
                combination_of_columns: ['admission_month', 'unit_name']

    Returns one row per duplicated combination.
#}

{% test unique_combination_of_columns(model, combination_of_columns) %}

select
    {{ combination_of_columns | join(', ') }},
    count(*) as duplicate_rows
from {{ model }}
group by {{ combination_of_columns | join(', ') }}
having count(*) > 1

{% endtest %}
