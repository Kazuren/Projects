import { useEffect } from 'react';
import { navigate } from "@reach/router"

export default function Auth({ location }) {
  useEffect(() => {
    let data = {}

    const query = location.hash.replace('#', '')
    query.split('&').map((param) => {
      const [key, value] = param.split('=')
      data[key] = value
      return data[key]
    })
    
    if (data.access_token) {
      localStorage.setItem('expiration', data.expires_in);
      navigate(`/`, { 
        replace: true, 
        state: { token: data.access_token }
      })
    } else {
      navigate('/', { replace: true })
    }
  }, [location.hash])

  return null
}
