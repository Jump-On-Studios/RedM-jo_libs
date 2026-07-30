import type { IncomingEntry } from '@/types/entries'

/** Stands in for SendNUIMessage, which only exists inside the game client. */
export function SendNUIMessage(message: unknown) {
  window.postMessage(message, '*')
}

function newInput(rows: IncomingEntry[][]) {
  SendNUIMessage({ event: 'newInput', data: { rows } })
}

export interface DevScenario {
  id: string
  label: string
  run: () => void
}

const confirmRow: IncomingEntry[] = [
  { type: 'button', id: 'confirm', value: 'Confirm', class: 'bg-green' },
  { type: 'button', id: 'close', value: 'X', width: 5, ignoreRequired: true },
]

const selectOptions = [
  { value: 1, label: 'Option 1' },
  { value: 2, label: 'Option 2' },
  { value: 3, label: 'Option 3' },
]

/** Every scenario is triggered by hand from the debug panel, never on load. */
export const scenarios: DevScenario[] = [
  {
    id: 'all',
    label: 'All types',
    run: () =>
      newInput([
        [{ type: 'title', value: "Enter the horse's price" }],
        [{ type: 'description', value: 'A description for the panel' }],
        [
          { type: 'label', value: 'Name:', for: 'name', width: 20 },
          { type: 'text', id: 'name', placeholder: 'A text input', required: true },
        ],
        [
          { type: 'label', value: 'Amount:', for: 'amount', width: 20 },
          {
            type: 'number',
            id: 'amount',
            placeholder: 'A number input',
            min: 0,
            max: 10,
            step: 0.01,
          },
        ],
        [
          { type: 'label', value: 'Birthday:', for: 'birthday', width: 20 },
          {
            type: 'date',
            id: 'birthday',
            placeholder: 'Select a date',
            yearRange: [1800, 1900],
            format: 'dd/MM/yyyy',
          },
        ],
        [
          { type: 'label', value: 'Choice:', for: 'choice', width: 20 },
          {
            type: 'select',
            id: 'choice',
            placeholder: 'A select input',
            options: selectOptions,
          },
        ],
        [{ type: 'price', id: 'price', allowOR: true, required: true }],
        confirmRow,
      ]),
  },
  {
    id: 'text',
    label: 'Text',
    run: () =>
      newInput([
        [{ type: 'title', value: 'Text input' }],
        [{ type: 'text', id: 'name', placeholder: 'Type something', required: true }],
        confirmRow,
      ]),
  },
  {
    id: 'number',
    label: 'Number',
    run: () =>
      newInput([
        [{ type: 'title', value: 'Number input' }],
        [
          {
            type: 'number',
            id: 'amount',
            placeholder: '0 to 10',
            min: 0,
            max: 10,
            step: 0.5,
            required: true,
          },
        ],
        confirmRow,
      ]),
  },
  {
    id: 'date',
    label: 'Date',
    run: () =>
      newInput([
        [{ type: 'title', value: 'Date input' }],
        [
          { type: 'label', value: 'Birthday:', for: 'birthday', width: 20 },
          {
            type: 'date',
            id: 'birthday',
            placeholder: 'Select a date',
            yearRange: [1800, 1900],
            format: 'dd/MM/yyyy',
            required: true,
          },
        ],
        confirmRow,
      ]),
  },
  {
    id: 'select',
    label: 'Select',
    run: () =>
      newInput([
        [{ type: 'title', value: 'Select input' }],
        [
          {
            type: 'select',
            id: 'choice',
            placeholder: 'Pick one',
            options: selectOptions,
            required: true,
          },
        ],
        [
          {
            type: 'select',
            id: 'preset',
            value: selectOptions[1],
            options: selectOptions,
          },
        ],
        confirmRow,
      ]),
  },
  {
    id: 'price-or',
    label: 'Price (OR)',
    run: () =>
      newInput([
        [{ type: 'title', value: 'Price with alternatives' }],
        [{ type: 'price', id: 'price', allowOR: true, required: true }],
        confirmRow,
      ]),
  },
  {
    id: 'price-flat',
    label: 'Price (flat value)',
    run: () =>
      newInput([
        [{ type: 'title', value: 'Price seeded with a flat Lua table' }],
        [
          {
            type: 'price',
            id: 'price',
            // Shape produced by a Lua mixed table: named keys plus numeric ones.
            value: { 1: { item: 'horse_license', keep: true }, money: 10 },
            allowOR: false,
            required: true,
          },
        ],
        confirmRow,
      ]),
  },
  {
    id: 'price-limited',
    label: 'Price (money/gold only)',
    run: () =>
      newInput([
        [{ type: 'title', value: 'Restricted cost types' }],
        [
          {
            type: 'price',
            id: 'price',
            options: ['money', 'gold'],
            value: { costs: [{ money: 25 }] },
            allowOR: true,
          },
        ],
        confirmRow,
      ]),
  },
  {
    id: 'required',
    label: 'Required fields',
    run: () =>
      newInput([
        [{ type: 'title', value: 'Everything is required' }],
        [{ type: 'text', id: 'name', placeholder: 'Required text', required: true }],
        [{ type: 'number', id: 'amount', placeholder: 'Required number', required: true }],
        [
          {
            type: 'select',
            id: 'choice',
            placeholder: 'Required select',
            options: selectOptions,
            required: true,
          },
        ],
        confirmRow,
      ]),
  },
  {
    id: 'buttons',
    label: 'Buttons & widths',
    run: () =>
      newInput([
        [{ type: 'title', value: 'Widths and classes' }],
        [
          { type: 'text', id: 'left', placeholder: 'width 70', width: 70 },
          { type: 'text', id: 'right', placeholder: 'width 200px', width: '200px' },
        ],
        [
          {
            type: 'description',
            value: 'The row below mixes <b>button</b> and the legacy <b>action</b> type.',
            style: { color: '#f0c674' },
          },
        ],
        [
          { type: 'button', id: 'confirm', value: 'Confirm', class: 'bg-green' },
          { type: 'action', id: 'delete', value: 'Delete', class: 'bg-red' },
          { type: 'button', id: 'close', value: 'X', width: 5, ignoreRequired: true },
        ],
      ]),
  },
  {
    id: 'no-button',
    label: 'No button (global Enter)',
    run: () =>
      newInput([
        [{ type: 'title', value: 'Press Enter with no field focused' }],
        [{ type: 'description', value: 'There is no button, so Enter submits the panel.' }],
        [{ type: 'text', id: 'name', placeholder: 'Optional' }],
      ]),
  },
]
