CREATE TABLE publish_db.operating_revenue_2_072022 AS 
SELECT region, 
       country, 
       status, 
       information_provider, 
       type_of_entity, 
       listed_delisted_unlisted, 
       standardised_legal_form, 
       actuals_vs_modelled, 
       count(DISTINCT bvd_id_number) total_unique_records, 
            count(DISTINCT if(operating_revenue_turnover_ IS NOT NULL, bvd_id_number_industry, NULL)) total_unique_records_industry, 
                 current_date() AS record_created_as 
FROM 
  (SELECT c.county_in_us_or_canada_ AS region, 
          c.country, 
          l.status, 
          l.information_provider, 
          l.type_of_entity, 
          l.listed_delisted_unlisted, 
          l.standardised_legal_form, 
          c.bvd_id_number, 
          i.bvd_id_number AS bvd_id_number_industry, 
          i.operating_revenue_turnover_, 
          if(lower(i.estimated_operating_revenue)="yes" 
          AND operating_revenue_original_range_value IS NULL   
            and operating_revenue_turnover_ is not null, "Operating revenue estimates from IP",  
          if(lower(i.estimated_operating_revenue) = "no" 
             AND operating_revenue_original_range_value IS NOT NULL   
              and operating_revenue_turnover_ is not null, "Operating revenue estimates based on ranges",  
             if(lower(i.estimated_operating_revenue) = "no" 
                AND operating_revenue_original_range_value IS NULL   
                and operating_revenue_turnover_ is not null, "Operating revenue actual value", "N/A"))) AS actuals_vs_modelled 
   FROM db_firmographics__monthly_2eacbf16.contact_info c 
   INNER JOIN db_firmographics__monthly_2eacbf16.legal_info l ON c.bvd_id_number = l.bvd_id_number 
   LEFT JOIN 
     (SELECT t.bvd_id_number, 
             t.operating_revenue_turnover_, 
             t.estimated_operating_revenue, 
             t.operating_revenue_original_range_value 
      FROM db_detailed_financials__monthly_cfe88059.industry_global_financials_and_ratios t 
      INNER JOIN 
        (SELECT bvd_id_number, 
                max(closing_date) AS MaxDate 
         FROM db_detailed_financials__monthly_cfe88059.industry_global_financials_and_ratios 
         GROUP BY bvd_id_number) tmp ON t.bvd_id_number = tmp.bvd_id_number 
      AND t.closing_date = tmp.MaxDate) i ON c.bvd_id_number = i.bvd_id_number) tmp1 
GROUP BY region, 
         country, 
         status, 
         information_provider, 
         type_of_entity, 
         listed_delisted_unlisted, 
         standardised_legal_form, 
         actuals_vs_modelled 