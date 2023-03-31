const API_ADDRESS = process.env.REACT_APP_API_IP_ADDRESS
const CLIENT_ID = process.env.REACT_APP_CLIENT_ID

export async function _fetchLogs(token, year, month, day) {
  const options = {
    method: 'GET',
    headers: {
      'Client-ID': CLIENT_ID,
      'Authorization': `OAuth ${token}`
    }
  }
  if (day) {
    const response = await fetch(`${API_ADDRESS}/api/logs/${year}/${month}/${day}`, options)
    const text = await response.text()

    return text
  } else if (month) {
    const response = await fetch(`${API_ADDRESS}/api/logs/${year}/${month}`, options)
    
    const { dirents, success } = await response.json()
    if (!success) {
      throw new Error('Get logs failed')
    }


    return dirents
  
  } else if (year) {
    const response = await fetch(`${API_ADDRESS}/api/logs/${year}`, options)

    const { dirents, success } = await response.json()

    if (!success) {
      throw new Error('Get logs failed')
    }


    return dirents
  } else {
    const response = await fetch(`${API_ADDRESS}/api/logs`, options)

    const { dirents, success } = await response.json()
    if (!success) {
      throw new Error('Get logs failed')
    }
    return dirents
  }
}

export async function _fetchLogYears(token) {
  const options = {
    method: 'GET',
    headers: {
      'Client-ID': CLIENT_ID,
      'Authorization': `OAuth ${token}`
    }
  }

  const response = await fetch(`${API_ADDRESS}/api/logs`, options)
  const { dirents, success } = await response.json()
  if (!success) {
    throw new Error('Get logs failed')
  }
  return dirents
}

export async function _fetchLogMonths(token, year) {
  const options = {
    method: 'GET',
    headers: {
      'Client-ID': CLIENT_ID,
      'Authorization': `OAuth ${token}`
    }
  }

  const response = await fetch(`${API_ADDRESS}/api/logs/${year}`, options)
  const { dirents, success } = await response.json()
  if (!success) {
    throw new Error('Get logs failed')
  }
  return dirents
}

export async function _fetchLogDays(token, year, month) {
  const options = {
    method: 'GET',
    headers: {
      'Client-ID': CLIENT_ID,
      'Authorization': `OAuth ${token}`
    }
  }

  const response = await fetch(`${API_ADDRESS}/api/logs/${year}/${month}`, options)
  const { dirents, success } = await response.json()
  if (!success) {
    throw new Error('Get logs failed')
  }
  const files = dirents.map(file => {
    return file.split('.')[0]
  })
  return files
}

export async function _fetchLogFile(token, year, month, day) {
  const options = {
    method: 'GET',
    headers: {
      'Client-ID': CLIENT_ID,
      'Authorization': `OAuth ${token}`
    }
  }
  const response = await fetch(`${API_ADDRESS}/api/logs/${year}/${month}/${day}`, options)

  const text = await response.text()
  return text
}

export async function _joinChannel(token) {
  const response = await fetch(`${API_ADDRESS}/api/bot/join`, {
    method: 'PUT',
    headers: {
      'Client-ID': CLIENT_ID,
      'Authorization': `OAuth ${token}`
    }
  })
  const { bot, success } = await response.json()
  if (!success) {
    throw new Error('Join channel failed')
  }

  return bot
}

export async function _partChannel(token) {
  const response = await fetch(`${API_ADDRESS}/api/bot/part`, {
    method: 'PUT',
    headers: {
      'Client-ID': CLIENT_ID,
      'Authorization': `OAuth ${token}`
    }
  })
  const { bot, success } = await response.json()
  if (!success) {
    throw new Error('Part channel failed')
  }

  return bot
}

export async function _updateBot(token, update) {
  const response = await fetch(`${API_ADDRESS}/api/bot`, {
    method: 'PUT',
    headers: {
      'Client-ID': '3t4vcu7m9ggdmjszt5n74ls692rj7v',
      'Content-Type': 'application/json',
      'Authorization': `OAuth ${token}`
    },
    body: JSON.stringify(update)
  })
  const { bot, success } = await response.json()
  if (!success) {
    throw new Error('Bot not Found')
  }

  return bot
}

export async function getUser(token) {
  const response = await fetch('https://api.twitch.tv/helix/users', {
    method: 'GET',
    headers: {
      'Accept': 'application/vnd.twitchtv.v5+json',
      'Client-ID': CLIENT_ID,
      'Authorization': `Bearer ${token}`
    }
  })
  const data = await response.json()
  if (data.error) {
    throw new Error(`${data.error}: ${data.message}`)
  }
  return data.data[0]
}

export async function getBot(token) {
  const response = await fetch(`${API_ADDRESS}/api/bot`, {
    method: 'GET',
    headers: {
      'Client-ID': CLIENT_ID,
      'Authorization': `OAuth ${token}`
    }
  })
  const { bot, success } = await response.json()
  if (!success) {
    throw new Error('Bot not Found')
  }

  return bot
}

export async function createBot(token) {
  const response = await fetch(`${API_ADDRESS}/api/bot`, {
    method: 'POST',
    headers: {
      'Client-ID': CLIENT_ID,
      'Content-Type': 'application/json',
      'Authorization': `OAuth ${token}`
    }
  })
  const { bot, success } = await response.json()
  if (!success) {
    throw new Error('Bot already exists')
  }

  return bot
}

// COMMANDS
export async function _fetchCommands(token) {
  const response = await fetch(`${API_ADDRESS}/api/commands`, {
    method: 'GET',
    headers: {
      'Client-ID': CLIENT_ID,
      'Authorization': `OAuth ${token}`
    }
  })
  const { commands, success } = await response.json()
  if (!success) {
    throw new Error('Fetching commands failed')
  }
  return commands
}

export async function _createCommand(token, options) {
  const response = await fetch(`${API_ADDRESS}/api/commands`, {
    method: 'POST',
    headers: {
      'Client-ID': CLIENT_ID,
      'Content-Type': 'application/json',
      'Authorization': `OAuth ${token}`
    },
    body: JSON.stringify(options)
  })
  const { command, success } = await response.json()
  if (!success) {
    throw new Error('Creating command failed')
  }
  return command
}

export async function _deleteCommands(token, ids) {
  const response = await fetch(`${API_ADDRESS}/api/commands`, {
    method: 'DELETE',
    headers: {
      'Client-ID': CLIENT_ID,
      'Content-Type': 'application/json',
      'Authorization': `OAuth ${token}`
    },
    body: JSON.stringify({ids: ids})
  })
  const { command_ids, success } = await response.json()
  if (!success) {
    throw new Error('Deleting commands failed')
  }

  return command_ids
}

export async function _editCommand(token, id, options) {
  const response = await fetch(`${API_ADDRESS}/api/commands/${id}`, {
    method: 'PUT',
    headers: {
      'Client-ID': CLIENT_ID,
      'Content-Type': 'application/json',
      'Authorization': `OAuth ${token}`
    },
    body: JSON.stringify(options)
  })
  const { command, success } = await response.json()
  if (!success) {
    throw new Error('Edit command failed')
  }

  return command
}

// TIMERS

export async function _fetchTimers(token) {
  const response = await fetch(`${API_ADDRESS}/api/timers`, {
    method: 'GET',
    headers: {
      'Client-ID': CLIENT_ID,
      'Authorization': `OAuth ${token}`
    }
  })
  const { timers, success } = await response.json()
  if (!success) {
    throw new Error('Fetching timers failed')
  }
  return timers
}

export async function _createTimer(token, options) {
  const response = await fetch(`${API_ADDRESS}/api/timers`, {
    method: 'POST',
    headers: {
      'Client-ID': CLIENT_ID,
      'Content-Type': 'application/json',
      'Authorization': `OAuth ${token}`
    },
    body: JSON.stringify(options)
  })
  const { timer, success } = await response.json()
  if (!success) {
    throw new Error('Creating timer failed')
  }
  return timer
}

export async function _deleteTimers(token, ids) {
  const response = await fetch(`${API_ADDRESS}/api/timers`, {
    method: 'DELETE',
    headers: {
      'Client-ID': CLIENT_ID,
      'Content-Type': 'application/json',
      'Authorization': `OAuth ${token}`
    },
    body: JSON.stringify({ids: ids})
  })
  const { timer_ids, success } = await response.json()
  if (!success) {
    throw new Error('Deleting timers failed')
  }

  return timer_ids
}

export async function _editTimer(token, id, options) {
  const response = await fetch(`${API_ADDRESS}/api/timers/${id}`, {
    method: 'PUT',
    headers: {
      'Client-ID': CLIENT_ID,
      'Content-Type': 'application/json',
      'Authorization': `OAuth ${token}`
    },
    body: JSON.stringify(options)
  })
  const { timer, success } = await response.json()
  if (!success) {
    throw new Error('Edit timer failed')
  }

  return timer
}

// FILTERS

export async function _fetchFilters(token) {
  const response = await fetch(`${API_ADDRESS}/api/filters`, {
    method: 'GET',
    headers: {
      'Client-ID': CLIENT_ID,
      'Authorization': `OAuth ${token}`
    }
  })
  const { filters, success } = await response.json()
  if (!success) {
    throw new Error('Fetching filters failed')
  }
  return filters
}

export async function _editFilter(token, id, options) {
  try {
    const response = await fetch(`${API_ADDRESS}/api/filters/${id}`, {
      method: 'PUT',
      headers: {
        'Client-ID': CLIENT_ID,
        'Content-Type': 'application/json',
        'Authorization': `OAuth ${token}`
      },
      body: JSON.stringify(options)
    })
    
    const { filter, success } = await response.json()
    if (!success) {
      throw new Error('Edit filter failed')
    }
  
    return filter
  }
  catch (err) {
    throw new Error(err.message)
    //throw new Error('NetworkError when attempting to fetch resource')
  }
}
