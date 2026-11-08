-- One row per calendar day, 2024-01-01 to 2026-12-31.
-- Covers encounter dates (2024-2025) and kit expiration dates (up to 2026).
-- Day of week is calculated from a fixed Monday (1900-01-01), so it does not
-- depend on the server's DATEFIRST or language settings.

{% set start_date = '2024-01-01' %}
{% set end_date = '2026-12-31' %}

with

digits as (

    select v from (values (0), (1), (2), (3), (4), (5), (6), (7), (8), (9)) as d(v)

),

numbers as (

    -- 0 .. 9999
    select ones.v + tens.v * 10 + hundreds.v * 100 + thousands.v * 1000 as n
    from digits as ones
    cross join digits as tens
    cross join digits as hundreds
    cross join digits as thousands

),

days as (

    select dateadd(day, n, cast('{{ start_date }}' as date)) as date_day
    from numbers
    where n <= datediff(day, cast('{{ start_date }}' as date), cast('{{ end_date }}' as date))

)

select
    date_day,
    year(date_day)                                          as year_number,
    datepart(quarter, date_day)                             as quarter_number,
    month(date_day)                                         as month_number,
    datename(month, date_day)                               as month_name,
    datefromparts(year(date_day), month(date_day), 1)       as month_start_date,
    datepart(iso_week, date_day)                            as iso_week_number,
    dateadd(day, -(datediff(day, cast('19000101' as date), date_day) % 7), date_day)
                                                            as week_start_date,     -- Monday of the week
    day(date_day)                                           as day_of_month,
    datediff(day, cast('19000101' as date), date_day) % 7 + 1 as day_of_week_iso,   -- 1 = Monday, 7 = Sunday
    datename(weekday, date_day)                             as day_name,
    cast(case when datediff(day, cast('19000101' as date), date_day) % 7 >= 5
              then 1 else 0 end as bit)                     as is_weekend

from days
