import React, { useState } from 'react';
import { Box, Button, TextField, Grid } from '@mui/material';
import { connect } from 'react-redux'

function DomainSearchBar(props) {
  const [query, setQuery] = useState("")
  const [page, setPage] = useState(1)
  const [limit, setLimit] = useState(10)

  function handleQueryChange(e) {
    setQuery(e.target.value)
  }
  function handlePageChange(e) {
    const value = e.target.value
    if (isNaN(parseInt(value))) {
      setPage("")
    } else {
      setPage(Math.min(parseInt(value), 100))
    }
  }
  function handleLimitChange(e) {
    const value = e.target.value
    if (isNaN(parseInt(value))) {
      setLimit("")
    } else {
      setLimit(Math.min(parseInt(value), 100))
    }
  }
  function handleSubmit(event) {
    props.handleSubmit(event, query, page, limit)
  }
  return (
    <Box
      component="form"
      noValidate
      onSubmit={handleSubmit}
      sx={{
        width: '100%',
        maxWidth: '640px'
      }}
    >
      <Grid container columnSpacing={1}>
        <Grid item xs={12}>
          <TextField
            margin="normal"
            required
            fullWidth
            id="query"
            label="Query"
            name="query"
            autoComplete="off"
            autoFocus
            onChange={handleQueryChange}
            value={query}
          />
        </Grid>
        <Grid item xs={6}>
          <TextField
            margin="normal"
            required
            fullWidth
            id="page"
            label="Page"
            name="page"
            autoComplete="off"
            autoFocus
            onChange={handlePageChange}
            value={page}
          />
        </Grid>
        <Grid item xs={6}>
          <TextField
            margin="normal"
            required
            fullWidth
            id="limit"
            label="Limit"
            name="limit"
            autoComplete="off"
            autoFocus
            onChange={handleLimitChange}
            value={limit}
          />
        </Grid>
      </Grid>
      <Button
        type="submit"
        fullWidth
        variant="contained"
        sx={{ mt: 2 }}
      >
        Search
      </Button>
    </Box>
  )
}

const mapStateToProps = state => ({})

export default connect(mapStateToProps, {})(DomainSearchBar)