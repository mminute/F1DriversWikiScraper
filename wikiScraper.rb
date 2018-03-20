require 'nokogiri'
require 'open-uri'
require_relative './utils/MatchDate'
require_relative './utils/MatchSeasons'
require_relative './utils/RemoveNotes'
require_relative './utils/ReplaceOddCharacters'

class WikiScraper
    attr_reader :doc, :directory

    def initialize(file_name)
        html = File.read(file_name)
        @doc = Nokogiri::HTML(html)
        @directory = File.dirname(file_name)
    end

    def scrape_index
        driver_data = []
        driver_table = doc.css('table.wikitable')[1]
        drivers = driver_table.css('tr')
        drivers[1..-2].each_with_index { |driver, idx|
            data = driver.css('td')

            driver_info = {
                name: remove_notes(data[0].css('a').text),
                wikiLink: data[0].css('a')[0].attributes['href'].value,
                country: data[1].text.gsub(/\u00A0/, ''),
                seasons: match_seasons(data[2].text),
                championships: remove_notes(data[3].text.gsub(/\n/, ',')),
                entries: remove_notes(data[4].text),
                starts: remove_notes(data[5].text),
                poles: remove_notes(data[6].text),
                wins: remove_notes(data[7].text),
                podiums: remove_notes(data[8].text),
                fastest_laps: remove_notes(data[9].text),
                points: remove_notes(data[10].text),
            }

            driver_data.push(driver_info)
        }

        driver_data
    end

    def get_driver_html
        drivers = scrape_index()
        drivers.map { |driver|
            destination = directory + '/drivers/' + driver[:name].gsub(' ', '') + '.html'

            if File.exist?(destination)
                html = File.read(destination)
            else
                html = open('https://en.wikipedia.org' + driver[:wikiLink]).read
                IO.write(destination, html)
            end

            driver.merge({html: html})
        }
    end

    def build_drivers
        drivers = get_driver_html()

        drivers.map { |driver|
            additional_info = {}
            driver_page = Nokogiri::HTML(driver[:html])

            begin
                rows = driver_page.css('table.vcard')[0].css('tr')

                born = rows.select { |row|
                    row.text.match('Born')
                }

                born_info = born[0].text
                additional_info[:dob] = match_date(born_info)
                additional_info[:pob] = born_info.split(/\n/)[-1]

                died = rows.select { |row|
                    row.text.match('Died')
                }

                if died.length > 0
                    died_info = died[0].text
                    additional_info[:pod] = match_date(died_info)
                    additional_info[:dod] = died_info.split(/\n/)[-1] 
                end

                additional_info[:primaryKey] = replace_odd_chars(driver[:name].downcase.strip.gsub(/\s+/, '-'))

                driver.merge(additional_info).tap { |drv|
                    drv.delete(:html)
                }
            rescue
               p "Failed! #{driver[:name]}"
               {}
            end
        }.reject!(&:empty?)
    end
end
