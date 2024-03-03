import { Controller } from "@hotwired/stimulus"

/***
 * Editable controller
 *
 * Add: data-controller="editable" on a wrapper, say body.
 * Later you can add say:
 * <dt data-editable-url="{%editable_url%}/location">Locatie</dt>
 *
 * This controller will replace the text inside these sections.
 */
export default class extends Controller {
  static get targets() {
      return []
  }
  connect() {
      return /// DISABLE!
      console.log("editable", this.element)
      const self = this
      document.querySelectorAll('[data-editable-url]').forEach((e) => {
          console.log(e)
          e.setAttribute('contenteditable', 'true')

          e.addEventListener('focus', (event) => {
              console.log("focus")

              let element = event.target

              // You could have multiple focus events
              if (!element.dataset.backupHtml) {
                  element.dataset.backupHtml = element.innerHTML
              }

              fetch(element.getAttribute('data-editable-url'), {
              }).then((response) => {
                  response.json().then(function (data) {
                      console.log(data)
                      element.innerHTML = data['part']['value']
                      element.dataset.oldHtml = element.innerHTML
                  })
              })
          })

          e.addEventListener('blur', self.checkChange.bind(self))
          // e.addEventListener('keyup', self.checkChange.bind(self))
          // e.addEventListener('paste', self.checkChange.bind(self))
          // e.addEventListener('input', self.checkChange.bind(self))

          e.addEventListener('change', (event) => {
              console.log("change triggered")
              let element = event.target

              if (element.innerHTML == element.dataset.backupHtml) {
                  console.log('element', element)
                  return
              }

              let data = { part: { value: element.innerHTML } }
              console.log(data)

              fetch(element.getAttribute('data-editable-url'), {
                  method: 'PUT',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify(data),
              }).then((response) => {
                  let data = response.json()
                  element.dataset.backupHtml = element.innerHTML
              })
          })
      })
  }

  checkChange(event) {
      console.log("blur keyup paste input")
      let element = event.target

      console.log("innerHTML", element.innerHTML)
      console.log("oldHtml", element.dataset.oldHtml)
      console.log("backupHtml", element.dataset.backupHtml)

      if (element.innerHTML == element.dataset.oldHtml) {
          console.log("no change, this is the oldhtml put back backup")
          element.innerHTML = element.dataset.backupHtml
      } else if (element.innerHTML == element.dataset.backupHtml) {
          console.log("no change, this is backup just put back backup, destroy backup")
          element.dataset.backupHtml = null
      } else {
          console.log("change, update, trigger change")
          triggerEvent(element, 'change', {})
      }
  }
}
