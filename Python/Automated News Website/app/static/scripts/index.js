//events - a super-basic Javascript (publish subscribe) pattern
let events = {
  events: {},
  on: function (eventName, fn) {
    this.events[eventName] = this.events[eventName] || [];
    this.events[eventName].push(fn);
  },
  off: function(eventName, fn) {
    if (this.events[eventName]) {
      for (let i = 0; i < this.events[eventName].length; i++) {
        if (this.events[eventName][i] === fn) {
          this.events[eventName].splice(i, 1);
          break;
        }
      };
    }
  },
  emit: function (eventName, data) {
    if (this.events[eventName]) {
      this.events[eventName].forEach(function(fn) {
        fn(data);
      });
    }
  }
};

(function (){
  let body = document.querySelector('body')
  let nightmode_switch = document.querySelector('.nightmode-switch')

  if (localStorage.getItem('nightmode') == null) {
    localStorage.setItem('nightmode', JSON.stringify(false))
  }
  let nightmode = localStorage.getItem('nightmode');

  if (JSON.parse(nightmode) === true) {
    body.classList.add('nightmode');
    nightmode_switch.classList.add('on');
  }
  else {
    nightmode_switch.classList.add('off');
  }

  nightmode_switch.addEventListener('click', function(e) {
    if(body.classList.contains('nightmode')) {
      nightmode_switch.classList.remove('on');
      nightmode_switch.classList.add('off');
      body.classList.remove('nightmode');
      localStorage.setItem('nightmode', JSON.stringify(false))
    }
    else {
      nightmode_switch.classList.remove('off');
      nightmode_switch.classList.add('on');
      body.classList.add('nightmode');
      localStorage.setItem('nightmode', JSON.stringify(true))
    }
  });
})();
(function (){
  let body = document.querySelector('body');
  let btn = document.querySelector('#modal_opener');
  let modal = document.querySelector('.modal');

  function attachModalListeners(modalElm) {
    modalElm.querySelector('.close_modal').addEventListener('click', toggleModal);
    modalElm.querySelector('.overlay').addEventListener('click', toggleModal);
  }

  function detachModalListeners(modalElm) {
    modalElm.querySelector('.close_modal').removeEventListener('click', toggleModal);
    modalElm.querySelector('.overlay').removeEventListener('click', toggleModal);
  }

  function toggleModal() {
    let currentState = modal.style.display;

    // If modal is visible, hide it. Else, display it.
    if (currentState === 'none') {
      modal.style.display = 'block';
      body.classList.add('overflow-hidden')
      attachModalListeners(modal);
    } else {
      body.classList.remove('overflow-hidden')
      modal.style.display = 'none';
      detachModalListeners(modal);  
    }
  }

  if(btn)
    btn.addEventListener('click', toggleModal);
})();


(function () {
  const elements = document.querySelectorAll('.searchable');
  const search_lists = document.querySelectorAll('.searchable_list');
  if (elements.length !== search_lists.length ) {
    console.log('This error should never pop up so I am amazed it did')
  }
  else {
    for(let i = 0; i < search_lists.length; i++) {
      const search = elements[i]
      const list = search_lists[i]
      const list_items = list.children

      const items = [];
      for(let j = 0; j < list_items.length; j++) {
        const item = list_items[j];
        items.push(item)
      }
      search.addEventListener('input', function(e) {
        events.emit("inputChanged", search.value);
        _render(find(items, search.value), list);
      });
      search.addEventListener('keydown', function(e) {
        if (e.which == 13 || e.keyCode == 13) 
          e.preventDefault();
      });
    }
  }
  function find(items, text) {
    text = text.split(' ');
    return items.filter(function(item) {
      return text.every(function(el) {
        return item.innerText.toLowerCase().indexOf(el.toLowerCase()) > -1;
      });
    });
  }
  function _render(items, list) {
    list.innerHTML = '';
    for(let i = 0; i < items.length; i++) {
      list.append(items[i]);
    }
  }
})();

(function () {
  let categories = document.querySelector('#categories')
  let sources = document.querySelector('#sources')
  let categories_ = []
  if(categories !== undefined && categories !== null) {
    categories = categories.children
    for(let i = 0; i < categories.length; i++) {
      const input = categories[i].children[0];
      categories_.push(input)
  
      input.addEventListener('click', function(e) {
        if (input.value === 'all') {
          for(let i = 0; i < categories_.length; i++) {
            categories_[i].checked = input.checked;
          }
        }
        else if (categories_[0].checked) { // categories_[0] = ALL
          categories_[0].checked = false;
        }
        else if (!categories_[0].checked) {
          let failed = false;
          for(let i = 1; i < categories_.length; i++) { // skip categories_[0] (the all checkbox)
            if (!categories_[i].checked) {
              failed = true
            }
          }
          if (!failed) {
            categories_[0].checked = true;
          }
        }
      })
    }
  }
  if(sources !== undefined && sources !== null) {
    sources = sources.children
    // Open new request
    const request = new XMLHttpRequest();
    request.open('GET', `/api/sources/`);

    request.onload = () => {
      const sources_ = JSON.parse(request.responseText);
      let checked = []
      for(let i = 0; i < sources.length; i++) {
        const input = sources[i].children[0];
        const label = sources[i].children[1];

        const source = sources_.find(source => source.id === input.value);
    
        label.innerHTML = label.innerHTML + ` (${source.article_count})`;
      }
    };

    // Add start and end points to request data.
    const data = new FormData();

    // Send request.
    request.send(data);

    return false;
  }
})();

(function () {
  // Get the GET parameters from the filter form to pass to the search form
  let url_string = window.location.href;
  let url = new URL(url_string);
  let sources = url.searchParams.getAll("sources");
  let categories = url.searchParams.getAll("categories");
  let publication_date = url.searchParams.get("publication_date");
  
  let form = document.querySelector('.search-form')
  
  for(let i = 0; i < sources.length; i++) {
    form.innerHTML += `<input name="sources" type="hidden" value="${sources[i]}">`
  }
  for(let i = 0; i < categories.length; i++) {
    form.innerHTML += `<input name="categories" type="hidden" value="${categories[i]}">`
  }
  if(publication_date) {
    form.innerHTML += `<input name="publication_date" type="hidden" value="${publication_date}">`
  }

  let icon = document.querySelector('.search-icon');
  if(icon != null) {
    icon.addEventListener('click', function(e) {
      form.submit();
    });
  }
})();
