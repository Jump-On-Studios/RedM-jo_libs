if (import.meta.env.DEV) {

  setTimeout(() => {
    window.postMessage({
      event: 'newInput',
      data: {
        rows: [
          [
            { type: "title", value: "Enter the horse's name" },
          ],
          [
            { type: "description", value: "The description" }
          ],
          [
            { type: "label", value: "Birthday:" },
            { type: "date", id: "birthday", placeholder: "Select a date", yearRange: [1800, 1900], value: '', format: 'dd/MM/yyyy', required: true }
          ],
          [
            { type: "text", id: 'input', value: undefined, placeholder: "A text input", required: true }
          ],
          [
            { type: "number", value: undefined, placeholder: "A number input", min: 0, max: 10, step: 0.01, required: true },
          ],
          [
            { type: "action", value: "Confirm", id: "confirm", }, { type: "action", class: "bg-green", value: "Delete", id: 'delete', ignoreRequired: true }, { type: "action", id: "close", value: "X", width: 5, ignoreRequired: true }
          ],
        ]
      }
    })
  }, 1000);

}