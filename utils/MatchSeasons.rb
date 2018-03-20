def match_seasons(date_string)
    season_range_regex = /\d{4}\–\d{4}/
    year_regex = /\d{4}/

    active_seasons = []

    season_ranges = date_string.scan(season_range_regex)

    all_yrs_in_ranges = season_ranges.map { |rng|
        yrs = rng.scan(year_regex)
        start_yr, end_yr = yrs[0].to_i, yrs[1].to_i

        years_in_range = []

        for range_year in (start_yr..end_yr)
            years_in_range.push(range_year.to_s)
        end

        years_in_range
    }.flatten

    # FIND INDIVIDUAL SEASONS NOT COVERED IN SEASON RANGES
    single_years = date_string.scan(year_regex)

    single_years.each { |yr|
        if !all_yrs_in_ranges.include?(yr)
            all_yrs_in_ranges.push(yr)
        end
    }

    all_yrs_in_ranges.sort
end