import axios from 'axios'

export default function Home({ temperature }) {
  return (
    <div>
      <p>The current temperature in Paris is {temperature}°C.</p>
    </div>
  )
}

export async function getServerSideProps() {
  // Set the required parameters for the API request
  const city_id = "2988507"
  const units = "metric"
  const appid = "1eca523f23a0fc70e0dd637eb173cbd6"

  // Make the request to the custom serverless function
  const res = await axios.get(`/api/weather?city_id=${city_id}&units=${units}&appid=${appid}`)

  // Extract the temperature from the response
  const temperature = res.data.temperature

  return {
    props: { temperature }
  }
}
