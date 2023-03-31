export async function _login(username, password) {
  const response = await fetch("/api/login", {
    method: "POST",
    headers: {
      "Content-Type": 'application/json'
    },
    body: JSON.stringify({ username, password })
  })


  const { token, err } = await response.json()
  if (err) {
    throw new Error(err.message)
  }
  return token
}

export async function _register(username, password) {
  const response = await fetch("/api/register", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ username, password })
  })
  const { token, err } = await response.json()
  if (err) {
    throw new Error(err.message)
  }
  return token
}

export async function _fetch_email_data(token, query, page, limit) {
  const response = await fetch(`/api/email/data?query=${query}&page=${page}&limit=${limit}`, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
      'Authorization': `Bearer ${token}`
    },
  })
  const { data, err } = await response.json()
  if (err) {
    throw new Error(err.message)
  }
  return data
}

export async function _send_emails(token, data) {
  const response = await fetch(`/api/email/send`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({ data })
  })
  const { success, err } = await response.json()

  if (err) {
    throw new Error(err.message)
  }
  return success
}

export async function _test_email(token, data) {
  const response = await fetch(`/api/email/test`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({ data })
  })
  const { success, err } = await response.json()

  if (err) {
    throw new Error(err.message)
  }
  return success
}

export async function _fetch_email_history(token) {
  const response = await fetch(`/api/email/history`, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
      'Authorization': `Bearer ${token}`
    }
  })
  const { data, err } = await response.json()

  if (err) {
    throw new Error(err.message)
  }
  return data
}

export async function _fetch_email_tasks(token) {
  const response = await fetch(`/api/email/tasks`, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
      'Authorization': `Bearer ${token}`
    }
  })
  const { data, err } = await response.json()

  if (err) {
    throw new Error(err.message)
  }
  return data
}

export async function _fetch_email_templates(token) {
  const response = await fetch('/api/email/template/names', {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
      'Authorization': `Bearer ${token}`
    }
  })
  const { data, err } = await response.json()
  if (err) {
    throw new Error(err.message)
  }
  return data
}

export async function _save_email_template(token, name, subject, template_data) {
  const response = await fetch('/api/email/template', {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({ name, subject, template_data })
  })
  const { data, err } = await response.json()
  if (err) {
    throw new Error(err.message)
  }
  return data
}

export async function _delete_email_template(token, name) {
  const response = await fetch('/api/email/template/delete', {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({ name })
  })
  const { data, err } = await response.json()
  if (err) {
    throw new Error(err.message)
  }
  return data
}

export async function _load_email_template(token, name) {
  const response = await fetch('/api/email/template', {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({ name })
  })
  const { data, err } = await response.json()
  if (err) {
    throw new Error(err.message)
  }
  return data
}