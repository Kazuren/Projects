const jwt = require('jsonwebtoken')
const User = require('../models/user')
const EmailHistory = require('../models/emailHistory')
const EmailTask = require('../models/emailTask')
const EmailToken = require('../models/emailToken')
const EmailTemplate = require('../models/emailTemplate')
const axios = require('axios')
const ejs = require('ejs')
const fs = require('fs')
const path = require("path");
const he = require('he');

const { promisify } = require('util')
const { google } = require('googleapis')
const { createMimeMessage } = require('mimetext')

const { compile } = require('html-to-text');
const convert = compile();


const readFileAsync = promisify(fs.readFile);


async function authenticateGmail(token) {
  const content = await readFileAsync(path.resolve(__dirname, '../client_secret.json'));
  const credentials = JSON.parse(content); // credential

  // authentication
  const clientSecret = credentials.installed.client_secret;
  const clientId = credentials.installed.client_id;
  const redirectUrl = credentials.installed.redirect_uris[0];
  const oauth2Client = new google.auth.OAuth2(clientId, clientSecret, redirectUrl);
  oauth2Client.on('tokens', (tokens) => {
    if (tokens.refresh_token) {
      // store the refresh_token in my database!
      console.log("Store this refresh token to the database: " + tokens.refresh_token);
    }
    console.log("Access token: " + tokens.access_token);
  });

  oauth2Client.setCredentials(token);
  return google.gmail({ version: 'v1', auth: oauth2Client })
}


function createMessage(sender, emails, subject, data, template) {
  const rendered_html = ejs.render(template, {
    ...data,
    company: {
      ...data.company,
      domain: addhttps(data.company.domain.replace('http://', 'https://'))
    }
  }, {
    openDelimiter: "{",
    closeDelimiter: "}"
  })
  const html = he.decode(rendered_html)
  const text = convert(html)
  const message = createMimeMessage()
  message.setSender(sender)
  message.setTo(emails)
  message.setSubject(he.decode(subject))
  message.setMessage('text/html', html)
  message.setMessage('text/plain', text)
  return message
}

async function sendMessage(service, message) {
  // Access the gmail via API
  const response = await service.users.messages.send({
    userId: 'me',
    requestBody: {
      raw: message.asEncoded()
    }
  });

  return response.data
}

function addhttps(url) {
  if (!/^(?:f|ht)tps?\:\/\//.test(url)) {
    url = "https://" + url;
  }
  return url;
}


function delay(t, val) {
  return new Promise(function (resolve) {
    setTimeout(function () {
      resolve(val);
    }, t);
  });
}

function getRandomIntInclusive(min, max) {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min + 1) + min); //The maximum is inclusive and the minimum is inclusive
}


async function getSnovioAccessToken() {
  const response = await axios.post(
    'https://api.snov.io/v1/oauth/access_token',
    {
      grant_type: 'client_credentials',
      client_id: process.env.SNOVIO_USER_ID,
      client_secret: process.env.SNOVIO_API_SECRET
    }
  )
  return response.data.access_token
}

async function fetchDomainEmailCount(access_token, domain) {
  const response = await axios.post(
    'https://api.snov.io/v1/get-domain-emails-count',
    {
      domain: domain
    },
    {
      headers: {
        'Authorization': `Bearer ${access_token}`
      }
    }
  )
  return response.data.result
}

async function fetchDomainCompanyInfo(access_token, domain, type, positions) {
  let response;
  try {
    response = await axios.get(
      'https://api.snov.io/v2/domain-emails-with-info',
      {
        params: {
          domain: domain,
          type: type,
          limit: 10,
          lastId: 0,
          positions: positions
        },
        headers: {
          'Authorization': `Bearer ${access_token}`
        }
      }
    )
    return response.data
  } catch (err) {
    console.log(err.response.data)
    console.log(err.response.status)
    console.log(err.response.headers)
    // hopefully when it's a 400+ status it returns null here
    return null
  }
}

async function fetchDomainInfo(domain) {
  const access_token = await getSnovioAccessToken()
  //  const email_count = await fetchDomainEmailCount(access_token, domain)

  //  let positions;
  let info;

  info = await fetchDomainCompanyInfo(access_token, domain, 'personal', ["CEO", "Chief Executive Officer", "Owner"])
  if (info != null && info?.emails?.length !== 0) { return info }
  info = await fetchDomainCompanyInfo(access_token, domain, 'personal', ["CEO", "Chief Executive Officer", "Owner", "Marketing"])
  if (info != null && info?.emails?.length !== 0) { return info }
  info = await fetchDomainCompanyInfo(access_token, domain, 'generic')
  return info
}

function fetchFakeDomainInfo(domain) {
  return {
    success: true,
    domain: domain,
    webmail: false,
    result: 84,
    lastId: 1823487525,
    limit: 100,
    companyName: "Octagon &amp &amp; LLC (LLC)",
    emails: [
      {
        email: "kazurendev@gmail.com",
        firstName: "Ben",
        lastName: "Gillespie",
        position: "Senior Account Executive",
        sourcePage: "https://www.linkedin.com/pub/ben-gillespie/7/73/809",
        companyName: "Octagon",
        type: "prospect",
        status: "verified"
      },
      {
        email: "alexandrosgramma@gmail.com",
        firstName: "Ben",
        lastName: "Gillespie",
        position: "Senior &amp; Account Executive",
        sourcePage: "https://www.linkedin.com/pub/ben-gillespie/7/73/809",
        companyName: "",
        type: "prospect",
        status: "verified"
      },
      {
        email: "alexandrosgramma1@gmail.com",
        firstName: "Ben",
        lastName: "Gillespie",
        position: "Senior &amp Account Executive",
        sourcePage: "https://www.linkedin.com/pub/ben-gillespie/7/73/809",
        companyName: "",
        type: "prospect",
        status: "verified"
      },
      {
        email: "alexandrosgramma2@gmail.com",
        firstName: "Ben",
        lastName: "Gillespie",
        sourcePage: "https://www.linkedin.com/pub/ben-gillespie/7/73/809",
        companyName: "Octagon",
        type: "prospect",
        status: "verified"
      }
    ]
  }
}

const user_login = async (req, res, next) => {
  try {
    // Get user input
    const { username, password } = req.body

    // Validate user input
    if (!username || !password) {
      return res.status(404).json({ err: { message: "Wrong username or password!" } })
    }

    const user = await User.findOne({ username }).exec()
    if (!user) {
      return res.status(404).json({ err: { message: "Wrong username or password!" } })
    }
    const match = await user.comparePassword(password)
    if (!match) {
      return res.status(404).json({ err: { message: "Wrong username or password!" } })
    }

    const token = jwt.sign(
      { user_id: user._id, username },
      process.env.JWT_PRIVATE_KEY,
      {
        expiresIn: "8h",
      }
    );

    user.token = token

    user.save()

    // generate jwt token and return it
    return res.status(200).json({ token: user.token })
  } catch (err) {
    return res.status(403).json({ err: { message: `Error code: ${err.code}` } })
  }
}

const user_register = async (req, res, next) => {
  try {
    // Get user input
    const { username, password } = req.body

    // Validate user input
    if (!username || !password) {
      return res.status(400).json({ err: { message: "All input is required!" } })
    }


    // Check if user already exists
    const oldUser = await User.findOne({ username }).exec()

    if (oldUser) {
      return res.status(409).json({ err: { message: "User already exists!" } })
    }

    const user = new User({
      username: username,
      password: password
    })

    const token = jwt.sign(
      { user_id: user._id, username },
      process.env.JWT_PRIVATE_KEY,
      {
        expiresIn: "8h",
      }
    );
    user.token = token

    await user.save()

    return res.status(200).json({ token: user.token })
  }
  catch (err) {
    return res.status(403).json({ err: { message: `Error code: ${err.code}` } })
  }
}


const email_data = async (req, res, next) => {
  const blacklist = [
    "instagram.com",
    "quora.com",
    "indeed.com",
    "pinterest.com",
    "linkedin.com",
    "facebook.com",
    "salary.com",
    "youtube.com",
    "revlocal.com",
    "simplilearn.com",
    "topagency.com",
    "simplyhired.com",
    "eventbrite.com",
    "monster.com",
    "uclaextension.com",
    "brightlocal.com",
    "agencylist.org",
    "internships.com",
    "craigslist.com",
    "upwork.com",
    "ziprecruiter.com",
    "goodfirms.co",
    "bestseocompanies.com",
    "seoblog.com",
    "expertise.com",
    "thehoth.com ",
    "yelp.com",
    "m.yelp.com",
    "gotchseo.com",
    "ignitevisibility.com",
    "designrush.com",
    "insigniaseo.com",
    "findtoptenranks.com",
    "glassdoor.com",
    "digitalmarketingcommunity.com",
    "curvearro.com",
    "serp.co",
    "clutch.co",
    "moz.com",
    "theedigital.com",
    "houstonwebdesignagency.com",
    "dnovogroup.com",
    "astoundz.com",
    "clearsolid.com",
    "vezadigital.com",
    "bigeyeagency.com",
    "firstpagedigital.sg",
    "contractor2020.com",
    "realtimemarketing.com",
    "stikkymedia.com",
    "bold.com.sa",
    "pearanalytics.com",
    "kwsmdigital.com",
    "dentalmarketingguy.com",
    "getfoundfast.com",
    "roofingcontractormarketing.com",
    "proits-it.com",
    "nextlevel.sg",
    "jemsu.com",
    "straightnorth.com",
    "profitlabs.net",
    "smdigitalpartners.com",
    "summerdigital.ca",
    "primidigital.com",
    "comradeweb.com",
    "pxmediainc.com",
    "victoriousseo.com",
  ]
  req.setTimeout(0)
  try {
    const { query } = req.query
    const page = Number(req.query.page)
    const limit = Number(req.query.limit)
    const response = await axios.get(
      'https://serpapi.com/search',
      {
        params: {
          api_key: process.env.SERP_API_KEY,
          q: query,
          engine: "google",
          gl: "us",
          hl: "en",
          google_domain: "google.com",
          start: (page - 1) * 10,
          num: limit,
        }
      })
    const results = response.data.organic_results

    const data = { query: query, companies: [] }
    let id = 1
    for (const result of results) {
      const link = result.link

      // if link in blacklist skip
      const url = new URL(link);
      //const hostname = url.hostname.replace(/.+\/\/|www.|\..+/g, '') // remove the top level domain part (com|org|xyz|gr) etc
      const hostname = url.hostname
      const blacklisted = blacklist.some(domain => hostname.includes(domain))
      if (blacklisted) {
        continue
      }
      const regex1 = /(^|\s)\(LLC\)(?=\s|$)/gm
      const regex2 = /(^|\s)LLC(?=\s|$)/gm
      const info = await fetchDomainInfo(link)
      if (info == null) {
        continue
      }
      const name = info.companyName.replace(regex1, "").replace(regex2, "")
      const domain = link// info.domain

      const history = await EmailHistory.findOne({ domain: domain }).lean().exec()

      const emails = info.emails.map(email => {
        const sentBefore = !history ? false : history.emails.includes(email.email)
        return {
          address: email.email, sentBefore, position: email.position || ""
        }
      })
      data.companies.push({
        id,
        name,
        emails,
        domain,
        page: page + Math.floor((result.position - 1) / 10)
      })
      id++
    }
    return res.status(200).json({ data: data })
  } catch (err) {
    console.log(err)
    return res.status(400).json({ err: { message: err.message } })
  }
}

/*
  TODO LIST
  1. optimize rendering in React when we check an email or accept/reject a company
  possibly use redux
  2. make rejected/accepted companies 1 table and add a checkbox to the left to
  accept/reject it and it opens up like an accordion and it has checkboxes on the emails inside
  and the company checkbox can have an indeterminate state if not all are checked
  (check my kazubot web app on github)
*/




async function sendEmailsTask(data, template, subject, gmails) {
  const task = new EmailTask({
    query: data.query,
    status: "pending",
  })
  await task.save()

  const length = gmails.length
  let email_index = 0

  try {
    for (const company of data.companies) {
      if (company.emails.length === 0) {
        continue
      }
      const msg = createMessage(
        gmails[email_index].email,
        company.emails,
        company.name !== "" ? `${company.name} - ${subject}` : subject,
        {
          query: data.query,
          company,
          hits: data.hits,
          first: data.first,
          reading_volume: data.reading_volume
        },
        template
      )

      await sendMessage(gmails[email_index].service, msg)

      const found = await EmailHistory.findOne({ domain: company.domain }).exec()
      if (!found) {
        const history = new EmailHistory({
          name: company.name,
          domain: company.domain,
          emails: company.emails,
          page: company.page
        })
        await history.save()
      } else {
        await found.updateOne(
          { $addToSet: { emails: { $each: company.emails } } },
        ).exec()
      }
      email_index++
      if (email_index >= length) {
        email_index = 0
      }
      await delay(getRandomIntInclusive(10000, 20000)); // Wait 10 to 20 seconds per email
    }
    task.updateOne({
      status: "completed"
    }).exec()
  } catch (err) {
    task.updateOne({
      status: "error",
      error: err.message
    }).exec()
  }
}

const email_send = async (req, res, next) => {
  try {
    const { data } = req.body
    const email_tokens = await EmailToken.find({}, '-_id').lean().exec()
    const gmails = []

    // authenticate all our registered gmail accounts
    for (email_token of email_tokens) {
      try {
        const gmail = await authenticateGmail(email_token.token)
        gmails.push({ service: gmail, email: email_token.email })
      } catch (err) {
        throw new Error(`Failed to authenticate: ${email_token.email}. ${err.message}`)
      }
    }
    const template = await EmailTemplate.findOne({ loaded: true }, '-_id').lean().exec()
    if (!template) {
      throw new Error('Failed to find a loaded template')
    }
    const template_data = fs.readFileSync(`server/templates/${template.name}.ejs`, { encoding: 'utf-8' });
    sendEmailsTask(data, template_data, template.subject, gmails)

    return res.status(200).json({ success: true })
  } catch (err) {
    console.log(err)
    return res.status(400).json({ err: { message: err.message } })
  }
}

const email_test = async (req, res, next) => {
  try {
    const email_tokens = await EmailToken.find({}, '-_id').lean().exec()
    const gmail = await authenticateGmail(email_tokens[0].token)

    const { data } = req.body

    const template = await EmailTemplate.findOne({ loaded: true }, '-_id').lean().exec()
    if (!template) {
      throw new Error('Failed to find a loaded template')
    }
    const template_data = fs.readFileSync(`server/templates/${template.name}.ejs`, { encoding: 'utf-8' });

    const msg = createMessage(
      email_tokens[0].email,
      data.company.emails,
      data.company.name !== "" ? `${data.company.name} - ${template.subject}` : template.subject,
      {
        query: data.query,
        company: data.company,
        hits: data.hits,
        first: data.first,
        reading_volume: data.reading_volume
      },
      template_data
    )
    await sendMessage(gmail, msg)

    return res.status(200).json({ success: true })
  } catch (err) {
    console.log(err)
    return res.status(400).json({ err: { message: err.message } })
  }
}

const email_history = async (req, res, next) => {
  try {
    const data = await EmailHistory.find({}, '-_id').lean().exec()
    return res.status(200).json({ data: data })
  } catch (err) {
    console.log(err)
    return res.status(400).json({ err: { message: err.message } })
  }
}

const email_tasks = async (req, res, next) => {
  try {
    const data = await EmailTask.find({ status: { $ne: 'completed' } }, '-_id').lean().exec()
    return res.status(200).json({ data: data })
  } catch (err) {
    console.log(err)
    return res.status(400).json({ err: { message: err.message } })
  }
}

const email_save_template = async (req, res, next) => {
  try {
    const { name, subject, template_data } = req.body
    // Validate user input
    if (!name) {
      return res.status(400).json({ err: { message: "Please input a name!" } })
    }
    if (!subject) {
      return res.status(400).json({ err: { message: "Please input a subject!" } })
    }
    // TODO make this more secure, right now we're susceptible to a filesystem attack
    // https://nodejs.org/en/knowledge/file-system/security/introduction/
    fs.writeFileSync(`server/templates/${name}.ejs`, template_data)

    const found = await EmailTemplate.findOne({ name: name }).exec()
    await EmailTemplate.updateMany({}, { loaded: false })
    if (!found) {
      const template = new EmailTemplate({
        name: name,
        subject: subject,
        loaded: true
      })
      await template.save()
    } else {
      await found.updateOne({
        loaded: true,
        subject: subject
      }).exec()
    }

    return res.status(200).json({ data: { loaded: true, name: name, subject: subject, template: template_data } })
  } catch (err) {
    console.log(err)
    return res.status(400).json({ err: { message: err.message } })
  }
}

const email_delete_template = async (req, res, next) => {
  try {
    const { name } = req.body
    await EmailTemplate.deleteOne({ name: name }).exec()
    fs.unlinkSync(`server/templates/${name}.ejs`)
    return res.status(200).json({ data: { name: name } })
  } catch (err) {
    console.log(err)
    return res.status(400).json({ err: { message: err.message } })
  }
}

const email_load_template = async (req, res, next) => {
  try {
    const { name } = req.body
    const template = await EmailTemplate.findOne({ name: name }).exec()
    if (!template) { throw new Error('Template not found!') }
    await EmailTemplate.updateMany({}, { loaded: false })
    await template.updateOne({
      loaded: true
    }).exec()
    data = fs.readFileSync(`server/templates/${name}.ejs`, { encoding: 'utf-8' })

    return res.status(200).json({ data: { loaded: true, name: name, subject: template.subject, template: data } })
  } catch (err) {
    console.log(err)
    return res.status(400).json({ err: { message: err.message } })
  }
}

const email_get_template_names = async (req, res, next) => {
  try {
    const templates = await EmailTemplate.find({}, '-_id').lean().exec()
    // const templates = fs.readdirSync('server/templates/').map(template => {
    //   const loaded = template_path === template
    //   return { loaded: loaded, name: template }
    // })
    return res.status(200).json({ data: templates })
  } catch (err) {
    console.log(err)
    return res.status(400).json({ err: { message: err.message } })
  }
}

module.exports = {
  user_login,
  user_register,
  email_data,
  email_send,
  email_test,
  email_history,
  email_tasks,
  email_save_template,
  email_delete_template,
  email_load_template,
  email_get_template_names
}
