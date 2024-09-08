import csv
import pycountry
import geonamescache

# Initialize GeoNamesCache for cities
gc = geonamescache.GeonamesCache()

# Open CSV file for writing
with open('locations.csv', mode='w', newline='') as file:
    writer = csv.writer(file)
    
    # Write header row
    writer.writerow(['country', 'state', 'city', 'abbreviation'])
    
    # Iterate through countries
    for country in pycountry.countries:
        country_abbr = country.alpha_2
        country_name = country.name
        
        # Write country level data with empty state and city columns
        writer.writerow([country_name, '', '', country_abbr])
        
        # Get subdivisions (states, provinces, etc.)
        subdivisions = list(pycountry.subdivisions.get(country_code=country.alpha_2))
        
        for subdivision in subdivisions:
            # Ensure two-letter state abbreviations
            state_name = subdivision.name
            state_abbr = subdivision.code.split('-')[-1][:2]
            
            # Write state level data with empty city column
            writer.writerow([country_name, state_name, '', state_abbr])
            
            # Filter cities by country code
            for city_id, city_data in gc.get_cities().items():
                if city_data['countrycode'] == country.alpha_2:
                    city_name = city_data['name']
                    
                    # Write city level data
                    writer.writerow([country_name, state_name, city_name, city_name])

print("locations.csv created.")
