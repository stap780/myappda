import { Controller } from "@hotwired/stimulus"
import { patch } from "@rails/request.js"
import Sortable from "sortablejs"


export default class extends Controller {
  static targets = [ 'position', 'hposition' ]
  connect() {
  //console.log('this.element', this.element)
  //const url = this.element.srcElement.dataset.sortUrl;
    this.sortable = new Sortable(this.element, {
      handle: '.js-sort-handle',
      onEnd: async (e) => {
        // console.log('e', e)
        // console.log('e.item.dataset', e.item.dataset)
        try {
          this.disable()
          //const url = e.srcElement.dataset.sortUrl;
          const url = e.item.dataset.sortUrl;
          const resp = await patch(url, {
            body: JSON.stringify({
              "sort_item_id": e.item.dataset.sortItemId,
              "new_position": e.newIndex + 1,
              "old_position": e.oldIndex + 1,
            })
          })

          if(!resp.ok) {
            this.updatePositions();
            throw new Error(`Cannot sort on server: ${resp.statusCode}`)
          }
          // this is for images that not have product id
          // if(!resp.ok) {
          //   this.updatePositions()
          // }

          this.updatePositions()
          this.dispatch('move', { detail: { content: 'Item sort' } })
        } catch(e) {
          console.error(e)
        } finally {
          this.enable()
        }
      }
    })
  }

  disable() {
    this.sortable.option('disabled', true)
    this.sortable.el.classList.add('opacity-50')
  }

  enable() {
    this.sortable.option('disabled', false)
    this.sortable.el.classList.remove('opacity-50')
  }

  updatePositions() {
    this.positionTargets.forEach((position, index) => {
      console.log('index',index)
      position.innerText = index + 1
    })
    this.hpositionTargets.forEach((position, index) => {
      position.value = index + 1
    })
  }
}