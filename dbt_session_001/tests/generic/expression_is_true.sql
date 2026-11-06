{#
    Generic test: fails for every row where the SQL expression is false.

    Model level  (business rule across columns):
        data_tests:
          - expression_is_true:
              arguments:
                expression: "admitted_at < discharged_at"

    Column level (the column name is put in front of the expression):
        - name: age
          data_tests:
            - expression_is_true:
                arguments:
                  expression: "between 0 and 120"

    Rows where the expression evaluates to NULL are not counted as failures;
    use not_null to catch missing values.
#}

{% test expression_is_true(model, expression, column_name=None) %}

select *
from {{ model }}
where not ({% if column_name %}{{ column_name }} {% endif %}{{ expression }})

{% endtest %}
