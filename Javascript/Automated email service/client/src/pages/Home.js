import React, { useEffect } from 'react'
import Helmet from "react-helmet"
import {
  Container, Typography
} from '@mui/material'
import { connect } from 'react-redux'
import { navigate } from "@gatsbyjs/reach-router"
import Navbar from '../components/Navbar'

function Home(props) {
  const { token } = props

  useEffect(() => {
    if (!token) {
      navigate('/login', { replace: true })
    }
  }, [token])

  return (
    <>
      <Helmet>
        <title>Automaton</title>
        <link rel="icon" href="/favicon.ico" />
      </Helmet>
      <Container
        sx={{
          display: "flex",
          flexFlow: "column",
          height: "100vh",
          justifyContent: 'center',
          alignItems: 'center'
        }}
      >
        <Typography>Use the navigation bar to navigate to the service you want</Typography>
        <Navbar value={null} />
      </Container>
    </>
  )
}

const mapStateToProps = state => ({
  token: state.token.value
})

export default connect(mapStateToProps, {})(Home)