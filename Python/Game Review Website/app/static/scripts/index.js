moment.updateLocale('en', {
  relativeTime : {
      future: "in %s",
      past: "%s ago",
      s  : 'a few seconds',
      ss : '%d seconds',
      m:  "a minute",
      mm: "%d minutes",
      h:  "an hour",
      hh: "%d hours",
      d:  "a day",
      dd: "%d days",
      M:  "a month",
      MM: "%d months",
      y:  "a year",
      yy: "%d years"
  }
});

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
document.addEventListener('click', event => {
  const element = event.target;
  
  if(element.classList.contains("category")) {
		event.preventDefault();
    let category_id = element.dataset.id;
    let game_slug = element.dataset.game;
    
    // Open new request to upvote
    const request = new XMLHttpRequest();
    request.open('POST', `/games/${game_slug}/upvote/${category_id}/`);

    request.onload = () => {
      const data = JSON.parse(request.responseText);
      if (element.classList.contains('btn-outline-primary')) {
        element.classList.remove('btn-outline-primary');
        element.classList.add('btn-primary');
        element.querySelector('.count').innerHTML = Number(element.querySelector('.count').innerHTML) + 1;
      }
      else {
        element.classList.remove('btn-primary');
        element.classList.add('btn-outline-primary');
        element.querySelector('.count').innerHTML = Number(element.querySelector('.count').innerHTML) - 1;
      }
      
    };

    // Add start and end points to request data.
    const data = new FormData();

    // Send request.
    request.send(data);

    return false;
	}
	else if(element.classList.contains('add-category-button')) {
		event.preventDefault();
		return false;
	}
});

jQuery(document).ready(function($) {
  $(function () {
    $('[data-toggle="popover"]').popover()
  });
  (function () {
    const reviews = document.querySelectorAll('.review');
    for(let i = 0; i < reviews.length; i++) {
      let review = reviews[i];
      let review_id = review.dataset.id;
      let votes = review.querySelector('.review-votes')
      let count = review.querySelector('.vote-count');
      let upvote = review.querySelector('.up-arrow');
      let downvote = review.querySelector('.down-arrow');
      let upvoting = null;
      let downvoting = null;
      let timeout = 0;
      if (upvote.classList.contains('upvote')) {
        upvote.addEventListener('click', e => {
          if (upvoting) {
            clearTimeout(upvoting);
            if (downvoting) {
              clearTimeout(downvoting);
            }
          }
          if (votes.classList.contains('upvoted')) {
            votes.classList.remove('upvoted');
            count.innerHTML = Number(count.innerHTML) - 1;
          }
          else {
            votes.classList.add('upvoted');
            if (votes.classList.contains('downvoted')) {
              votes.classList.remove('downvoted')
              count.innerHTML = Number(count.innerHTML) + 2;
            }
            else {
              count.innerHTML = Number(count.innerHTML) + 1;
            }
          }
          upvoting = setTimeout(function () {
            // Open new request to upvote
            const request = new XMLHttpRequest();
            request.open('POST', `/games/upvote/${review_id}/`);
    
            request.onload = () => {
              const data = JSON.parse(request.responseText);
              if (data.success) {
                if (data.upvoted) {
                  if (!(votes.classList.contains('upvoted'))) {
                    votes.classList.add('upvoted');
                    if (votes.classList.contains('downvoted')) {
                      votes.classList.remove('downvoted')
                      count.innerHTML = Number(count.innerHTML) + 2;
                    }
                    else {
                      count.innerHTML = Number(count.innerHTML) + 1;
                    }
                  }
                }
                else {
                  if (votes.classList.contains('upvoted')) {
                    votes.classList.remove('upvoted');
                    count.innerHTML = Number(count.innerHTML) - 1;
                  }
                }
              }
            };
    
            // Add start and end points to request data.
            const data = new FormData();
    
            // Send request.
            request.send(data);

            timeout += 50;

          }, timeout)
          
        });
      }
      if (downvote.classList.contains('downvote')) {
        downvote.addEventListener('click', e => {
          if (downvoting) {
            clearTimeout(downvoting);
            if (upvoting) {
              clearTimeout(upvoting);
            }
          }
          if (votes.classList.contains('downvoted')) {
            votes.classList.remove('downvoted');
            count.innerHTML = Number(count.innerHTML) + 1;
          }
          else {
            votes.classList.add('downvoted');
            if (votes.classList.contains('upvoted')) {
              votes.classList.remove('upvoted');
              count.innerHTML = Number(count.innerHTML) - 2;
            }
            else {
              count.innerHTML = Number(count.innerHTML) - 1;
            }
          }
          downvoting = setTimeout(function () {
            // Open new request to downvote
            const request = new XMLHttpRequest();
            request.open('POST', `/games/downvote/${review_id}/`);
    
            request.onload = () => {
              const data = JSON.parse(request.responseText);
              if(data.success) {
                if (data.downvoted) {
                  if (!(votes.classList.contains('downvoted'))) {
                    votes.classList.add('downvoted');

                    if (votes.classList.contains('upvoted')) {
                      votes.classList.remove('upvoted');
                      count.innerHTML = Number(count.innerHTML) - 2;
                    }
                    else {
                      count.innerHTML = Number(count.innerHTML) - 1;
                    }
                  }
                }
                else {
                  if (votes.classList.contains('downvoted')) {
                    votes.classList.remove('downvoted');
                    count.innerHTML = Number(count.innerHTML) + 1;
                  }
                }
              }
            };
    
            // Add start and end points to request data.
            const data = new FormData();
    
            // Send request.
            request.send(data);

            timeout += 50;

          }, timeout)
          
        });
      }
    }
  })();
	(function () {
		const dropdown = document.querySelectorAll('.user-dropdown')
    for(let i = 0; i < dropdown.length; i++) {
      const dropdown_list = dropdown[i].querySelector('.user-dropdown-list');
      document.addEventListener('click', function(e) {
        if (e.target !== dropdown[i] && e.target !== dropdown_list) {
          if (dropdown_list.classList.contains('active')) {
            dropdown[i].classList.remove('active');
            dropdown_list.classList.remove('active');
          }
        }
      })
      dropdown[i].addEventListener('click', function(e) {
        if (dropdown_list.classList.contains('active')) {
          dropdown[i].classList.remove('active');
          dropdown_list.classList.remove('active');
        }
        else {
          dropdown[i].classList.add('active');
          dropdown_list.classList.add('active');
        }
      })
    }
  })();
  (function () {
    let message_counts = document.querySelectorAll('.message-count')
    var since = 0;
    
    if(message_counts.length > 0) {
      setInterval(function() {
        // Open new request
        const request = new XMLHttpRequest();
        request.open('GET', `/user/notifications/?since=${since}/`);
  
        request.onload = () => {
          const notifications = JSON.parse(request.responseText);

          for (let i = 0; i < notifications.length; i++) {
            const notification = notifications[i];
            if (notification.name === 'unread_message_count') {
              set_message_count(notification.data);
            }
            else if (notification.name === 'task_progress') {
              set_task_progress(notification.data.task_id, notification.data.progress);
            }
            since = notification.timestamp;
          }
        };
  
        // Add start and end points to request data.
        const data = new FormData();
  
        // Send request.
        request.send(data);
  
        return false;
      }, 10000);
    }
    function set_message_count(n) {
      for(let i = 0; i < message_counts.length; i++) {
        message_counts[i].innerHTML = n;
        if(n > 0) {
          if(message_counts[i].classList.contains('d-none')) {
            message_counts[i].classList.remove('d-none');
          }
        }
        else {
          if(!(message_counts[i].classList.contains('d-none'))) {
            message_counts[i].classList.add('d-none');
          }
        }
      }
    }
    function set_task_progress(task_id, progress) {
      let task_progress = document.querySelector(`#task-${task_id}-progress`);
      if (task_progress !== 'undefined' && task_progress !== null) {
        task_progress.innerHTML = progress + "%";
        if (progress === 100) {
          task_progress.innerHTML = "Complete";
        }
      }
    }
  })();
	(function () {
		const inputs = document.querySelectorAll('.delete-review-input');
		const buttons = document.querySelectorAll('.delete-review-button');
		if (inputs.length !== buttons.length ) {
			console.log('This error should never pop up so I am amazed it did')
		}
		else {
			for (let i = 0; i < inputs.length; i++) {
				
				const input = inputs[i]
				const button = buttons[i]
				button.disabled = true;
				input.addEventListener('input', function(e) {
					if(input.value === "DELETE") {
						if (button.classList.contains('disabled')) {
							button.classList.remove('disabled');
							button.disabled = false;
						}
					}
					else {
						if (!(button.classList.contains('disabled'))) {
							button.classList.add('disabled');
							button.disabled = true;
						}
					}
				});
			}
		}
	})();
	/*
	(function () {
		const revisions = document.querySelectorAll('.revision');
		for(let i = 0; i < revisions.length; i++) {
			let old_body = revisions[i].querySelector('.revision-old-body').innerHTML
			let old_rating = revisions[i].querySelector('.revision-old-rating').innerHTML
			let new_body = revisions[i].querySelector('.revision-new-body').innerHTML
			let new_rating = revisions[i].querySelector('.revision-new-rating').innerHTML
			let body_output = htmldiff(old_body, new_body);
			let rating_output = htmldiff(old_rating, new_rating);
			revisions[i].querySelector('.revision-body').innerHTML = body_output;
			revisions[i].querySelector('.revision-rating').innerHTML = rating_output;

		}
  })();
  */
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
});

// tinyMCE 
tinymce.init({
	selector: '#editor',
  theme: 'modern',
  menubar: false,
  plugins: "link"
});

// jQuery Bar Rating
$(function() {
  
  let current_rating = document.querySelector('.current-rating');
  let current_rating_value = current_rating.querySelector('.value');
  let current_rating_intvalue = parseFloat(current_rating_value.innerHTML);
  let your_rating = document.querySelector('.your-rating');
  let your_rating_value = your_rating.querySelector('.value');
  let your_rating_intvalue = parseFloat(your_rating_value.innerHTML);
  let clear_rating = document.querySelector('.clear-rating');

  let edit_page = document.querySelector('.edit-page');

  clear_rating.addEventListener('click', function (event) {
    event.preventDefault();
    $('#star-rating').barrating('clear');
  })
  $('#star-rating').barrating({
    theme: 'fontawesome-stars-o',
    initialRating: (current_rating_intvalue != 0) ? current_rating_intvalue : null,
    deselectable: false,
    onSelect: function(value, text, event) {
      if (typeof(event) !== 'undefined') {
        // rating was selected by a user
        if (!(current_rating.classList.contains('d-none'))) {
          current_rating.classList.add('d-none')
        }
        if (your_rating.classList.contains('d-none')) {
          your_rating.classList.remove('d-none')
        }
        your_rating_value.innerHTML = event.target.dataset.ratingValue

      } else {
        // rating was selected programmatically
        // by calling `set` method
        if (!(current_rating.classList.contains('d-none'))) {
          current_rating.classList.add('d-none')
        }
        if (your_rating.classList.contains('d-none')) {
          your_rating.classList.remove('d-none')
        }
        your_rating_value.innerHTML = event.target.dataset.ratingValue
      }
    },
    onClear: function(value, text) {
      if (current_rating.classList.contains('d-none')) {
        current_rating.classList.remove('d-none')
      }
      if (!(your_rating.classList.contains('d-none'))) {
        your_rating.classList.add('d-none')
      }
    }
  });
  if(edit_page !== 'undefined' && edit_page !== null) {
    $('#star-rating').barrating('set', your_rating_intvalue);
  }
});
