pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "painterro" # @1.2.87
pin "sortablejs" # @1.15.2

pin "scribo", to: "scribo/application.js", preload: false

pin_all_from Scribo::Engine.root.join("app/javascript/scribo/controllers"), under: "scribo/controllers", to: "scribo/controllers", preload: false
