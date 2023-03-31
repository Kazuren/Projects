import { useEffect } from 'react';
import { navigate } from "@reach/router"
import { connect } from 'react-redux'
import { fetchUser, updateToken, fetchBot, addBot } from '../actions'

function Auth({ location, updateToken, fetchUser, fetchBot, addBot }) {
  useEffect(() => {
    let data = {}

    const query = location.hash.replace('#', '')
    query.split('&').map((param) => {
      const [key, value] = param.split('=')
      data[key] = value
      return data[key]
    })
    updateToken(data.access_token)

    async function login(token) {
      if (await fetchBot(token)) {
        navigate('/dashboard', { replace: true })
        return
      }
      if (await addBot(token)) { 
        navigate('/dashboard', { replace: true }) 
        return 
      }

      navigate('/', { replace: true })
    }

    if (data.access_token) {
      login(data.access_token)
    }
    else {
      navigate('/', { replace: true })
    }
  }, [location.hash, addBot, fetchBot, fetchUser, updateToken])

  return null
}

const mapStateToProps = state => ({
})

export default connect(mapStateToProps, { fetchUser, updateToken, fetchBot, addBot })(Auth)
