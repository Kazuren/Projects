import React from 'react';
import Helmet from "react-helmet";
import Navbar from '../components/home/Navbar'
import { Container } from '@material-ui/core';

export default function Home(props) {
  return (
    <>
      <Helmet>
        <title>Modderino</title>
        <link rel="icon" href="/favicon.ico" />
      </Helmet>
      <Container maxWidth={false} disableGutters={true}>
        <Navbar logo="KazuBot" />
      </Container>
    </>
  )
}
