import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        setTimeout(() => {
            this.dismiss()
        }, 3000)
    }

    dismiss() {
        this.element.style.transition = 'opacity 0.3s ease-out, transform 0.3s ease-out'
        this.element.style.opacity = '0'
        this.element.style.transform = 'translateY(-20px)'
        setTimeout(() => this.element.remove(), 300)
    }
}
