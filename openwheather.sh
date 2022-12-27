#!/bin/bash

# Set the API endpoint and the required parameters
endpoint="https://api.openweathermap.org/data/2.5/weather"
city_id="2988507" # Specify the city id for Paris
units="metric" # Specify the units to use (in this case metric units)
appid="1eca523f23a0fc70e0dd637eb173cbd6" 

# Make the API request
response=$(curl "$endpoint?id=$city_id&units=$units&appid=$appid")

# Extract the data from the response
data=$(echo $response | jq '.')

# Extract the temperature from the data
temperature=$(echo $data | jq '.main.temp' | awk '{printf "%d\n", $1 + 0.5}')
echo "The current temperature in Paris is $temperature°C."

# Insert the temperature into the database
sqlite3 temp_db "INSERT INTO temperatures (temperature, date) VALUES ($temperature, datetime('now'));"

# Retrieve and print all the data from the database
results=$(sqlite3 temp_db "SELECT * FROM temperatures")
echo " id | temperature |         date        |"
echo "----|-------------|---------------------|"
while read -r line; do
    echo "$line" | awk -F '|' '{ printf "%-3s | %-12s | %s |\n", $1, $2, $3 }'
done <<< "$results"

# Calculate the mean and standard deviation of the temperature data in the database
mean=$(sqlite3 temp_db "SELECT AVG(temperature) FROM temperatures")
stddev=$(sqlite3 temp_db "SELECT STDEV(temperature) FROM temperatures")

# Calculate the z-score of the current temperature
zscore=$(awk -v temperature=$temperature -v mean=$mean -v stddev=$stddev 'BEGIN {print (temperature - mean) / stddev}')

# Check if the z-score is outside the normal range (e.g. -3 to 3)
if (( $(awk -v zscore=$zscore 'BEGIN {print (zscore < -3)}') )) || (( $(awk -v zscore=$zscore 'BEGIN {print (zscore > 3)}') )); then
    # Calculate the number of standard deviations away from the mean
    num_stddev=$(awk -v zscore=$zscore 'BEGIN {printf "%.2f", zscore}')
    # Print a message indicating that the current temperature is abnormal
    echo "The current temperature in Paris is abnormal ($temperature°C). It is $num_stddev standard deviations away from the mean."
    # Send a message to a Telegram chat with this information
    curl --data chat_id="YOUR_CHAT_ID" --data-urlencode "text=The current temperature in Paris is abnormal ($temperature°C). It is $num_stddev standard deviations away from the mean." "https://api.telegram.org/botYOUR_API_KEY/sendMessage?parse_mode=HTML"
else
    # Print a message indicating that the current temperature is normal
    echo "The current temperature in Paris is normal ($temperature°C)."
fi

