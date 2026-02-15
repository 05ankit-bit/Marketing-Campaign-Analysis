select *
from dim_campaign;

describe dim_campaign;

alter table dim_campaign
modify column start_date date,
modify column end_date date,
modify column campaign_id text;

select *
from dim_channel;

alter table dim_channel
modify column channel_id text;

select *
from dim_customer;

describe dim_customer;

alter table dim_customer
modify column customer_id text,
modify column signup_date date;

select distinct count(*)
from dim_customer;

select *
from dim_date;

describe dim_date;

alter table dim_date
modify column date_id text,
modify column `date` date,
modify column `month` int,
modify column month_name text,
modify column `quarter` int,
modify column `year` int,
modify column is_weekend text;

select *
from dim_device;

alter table dim_device
modify column device_id int,
modify column device_type text,
modify column operating_system text;

select trim(device_id), trim(device_type), trim(operating_system)
from dim_device;

select state, city
from dim_geography;

update dim_geography
set state = case
	when city = 'Mumbai' then 'Maharashtra'
	when city = 'Delhi' then 'NCR'
    when city = 'Bengaluru' then 'Karnataka'
    when city = 'Pune' then 'Maharashtra'
    when city = 'Hyderabad' then 'Telangana'
    when city = 'Chennai' then 'Tamil Nadu'
    when city = 'Kolkata' then 'West Bengal'
end;

select *
from dim_geography;

select *
from dim_product;

update dim_product
set
	product_id = trim(product_id),
    product_category = trim(product_category),
    product_name = trim(product_name),
    price_band = trim(price_band);

select *
from fact_campaign_performance;

update	fact_campaign_performance
set
	campaign_perf_id = trim(campaign_perf_id),
    date_id = trim(date_id),
    campaign_id = trim(campaign_id),
    geography_id = trim(geography_id),
    impressions = trim(impressions),
    clicks = trim(clicks),
    spend_amount = trim(spend_amount),
    leads_generated = trim(leads_generated),
    conversions = trim(conversions);

select *
from fact_campaign_performance;

select count(*)
from fact_campaign_performance;

select campaign_perf_id, count(*)
from fact_campaign_performance
group by campaign_perf_id
having count(*) > 1;

describe fact_campaign_performance;

alter table fact_campaign_performance
modify column campaign_perf_id text,
modify column date_id text,
modify column campaign_id text,
modify column channel_id text,
modify column geography_id text,
modify column spend_amount float;

update fact_campaign_performance
set 
	clicks = case
    when clicks > impressions then impressions
    else clicks
    end,
    leads_generated = case
    when leads_generated > clicks then clicks
    else leads_generated
    end,
    conversions = case
    when conversions > leads_generated then leads_generated
    else conversions
    end;

select *
from fact_campaign_performance
where leads_generated = clicks;

select date_id, str_to_date(date_id, '%Y%m%d') as date
from fact_campaign_performance;

CREATE TABLE `fact_campaign_performance_copy` (
  `campaign_perf_id` text,
  `date_id` text,
  `campaign_id` text,
  `channel_id` text,
  `geography_id` text,
  `impressions` int DEFAULT NULL,
  `clicks` int DEFAULT NULL,
  `spend_amount` float DEFAULT NULL,
  `leads_generated` int DEFAULT NULL,
  `conversions` int DEFAULT NULL,
  `date` date
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from fact_campaign_performance_copy;
insert into fact_campaign_performance_copy
select *, STR_TO_DATE(date_id, '%Y%m%d') as date
from fact_campaign_performance;

select *
from fact_customer_acquisition;

alter table fact_customer_acquisition
drop column coupon_code;

alter table fact_customer_acquisition
modify column acquisition_id text,
modify column customer_id text,
modify column campaign_id text,
modify column channel_id text,
modify column acquisition_date_id text;

select *, (revenue_amount-discount_amount) as net_revenue1
from fact_customer_revenue;

update fact_customer_revenue
set net_revenue = revenue_amount-discount_amount;

select *, net_revenue- cost_of_goods
from fact_customer_revenue;

update fact_customer_revenue
set gross_margin = net_revenue- cost_of_goods;

select *
from fact_customer_revenue;

select *
from fact_website_funnel;

alter table fact_website_funnel
modify column session_id text,
modify column date_id text,
modify column channel_id text,
modify column device_id text;

update fact_website_funnel
set
	add_to_cart = case
    when add_to_cart > product_views then product_views
    else add_to_cart
    end,
    checkout_started = case
    when checkout_started > add_to_cart then add_to_cart
    else checkout_started
    end,
    purchases = case
    when purchases > checkout_started then checkout_started
    else purchases
    end;

select *
from fact_website_funnel;

select date_id, str_to_date(date_id, '%Y%m%d') as date
from fact_website_funnel;

CREATE TABLE `fact_website_funnel_copy` (
  `session_id` text,
  `date_id` text,
  `channel_id` text,
  `device_id` text,
  `sessions` int DEFAULT NULL,
  `product_views` int DEFAULT NULL,
  `add_to_cart` int DEFAULT NULL,
  `checkout_started` int DEFAULT NULL,
  `purchases` int DEFAULT NULL,
  `date` date 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from fact_website_funnel_copy;

insert into fact_website_funnel_copy
select *, str_to_date(date_id, '%Y%m%d')
from fact_website_funnel;
