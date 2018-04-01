require_relative './utils/MatchSeasons'
require_relative './utils/WriteJSObject'
require_relative './wikiScraper.rb'
require 'open-uri'

# GET THE LIST OF DRIVERS
driver_index = open('https://en.wikipedia.org/wiki/List_of_Formula_One_drivers').read
IO.write(Dir.getwd + '/html/driverIndex.html', driver_index)

scraper = WikiScraper.new(Dir.getwd + '/html/driverIndex.html')

# DOWNLOAD THE WIKI PAGE FOR EACH DRIVER AND BUILD DRIVER DATA OBJECT
drivers = scraper.build_drivers
# CONFIRMED THAT THERE ARE NO DUPLICATE KEYS 

# TODO: Write data to a file
drivers_by_last_season = {}

drivers.each { |driver|
    if drivers_by_last_season[driver[:seasons].last]
        drivers_by_last_season[driver[:seasons].last].push(driver)
    else
        drivers_by_last_season[driver[:seasons].last] = [driver]
    end
}

sorted_seasons = drivers_by_last_season.sort_by {|season, drvr| season }.reverse

sorted_drivers_by_last_season = {}

sorted_seasons.each { |season, drvs|
    sorted_drivers_by_last_season[season] = drvs
}

write_to_file = '['

sorted_drivers_by_last_season.each { |yr, season_drivers|
    write_to_file = write_to_file + "\n  // #{yr}"

    season_drivers.each { |dr|
        write_to_file = write_to_file + "\n" + "  #{write_js_object(dr)}"
    }
}

write_to_file = write_to_file + "\n]"

IO.write(Dir.getwd + '/formattedData/drivers.js', write_to_file)
