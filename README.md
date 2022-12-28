# Openwheather-Anomalies-

What we are trying to do here is to scrape useful informations to detect anoamlies from : https://home.openweathermap.org, to do so, the openwheather.sh script will perform the following steps: 

- Set the API endpoint and required parameters for the OpenWeatherMap API, and make a request to the API to get the current temperature in Paris.

- Extract the temperature from the API response and print it to the console.

- Insert the temperature into a SQLite database called "temp_db", and retrieve and print all the data from the database.

- Calculate the mean and standard deviation of the temperature data in the "temp_db" database, and use these values to calculate the z-score of the current temperature.

- Check if the z-score is outside the normal range (e.g. -3 to 3). If it is, it sends a message indicating that the current temperature is abnormal and send a message to a Telegram chat with this information. If the z-score is within the normal range, it also sends a message indicating that the current temperature is normal.
