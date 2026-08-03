import type { IncomingEntry, IncomingRow } from "@/types/entries";

/** Stands in for SendNUIMessage, which only exists inside the game client. */
export function SendNUIMessage(message: unknown) {
  window.postMessage(message, "*");
}

/** A scenario row: its columns alone, or the whole row when it needs a position. */
type DevRow = IncomingEntry[] | IncomingRow;

/**
 * Scenarios are written as plain arrays of columns, exactly like the legacy Lua
 * format, and wrapped here into the `{ columns }` rows the NUI now expects.
 */
function newInput(rows: DevRow[]) {
  SendNUIMessage({
    event: "newInput",
    data: {
      rows: rows.map((row) => (Array.isArray(row) ? { columns: row } : row)),
    },
  });
}

export interface DevScenario {
  id: string;
  label: string;
  run: () => void;
}

const confirmRow: IncomingEntry[] = [
  {
    type: "button",
    id: "confirm",
    value: "Confirm",
    icon: "/assets/ui/tick.png",
    class: "success",
  },
  {
    type: "button",
    id: "close",
    value: "Close",
    class: "flat",
    ignoreRequired: true,
  },
];

const selectOptions = [
  { value: 1, label: "Option 1" },
  { value: 2, label: "Option 2" },
  { value: 3, label: "Option 3" },
];

/** Every scenario is triggered by hand from the debug panel, never on load. */
export const scenarios: DevScenario[] = [
  {
    id: "all",
    label: "All types",
    run: () =>
      newInput([
        {
          position: "header",
          columns: [{ type: "title", value: "Enter the horse's price" }],
        },
        {
          position: "header",
          columns: [
            { type: "description", value: "A description for the panel" },
          ],
        },
        [
          { type: "label", value: "Name:", target: "name", width: 10 },
          {
            type: "text",
            id: "name",
            placeholder: "A text input",
            required: true,
          },
        ],
        [
          { type: "label", value: "Amount:", target: "amount", width: 10 },
          {
            type: "number",
            id: "amount",
            placeholder: "A number input",
            min: 0,
            max: 10,
            step: 0.01,
          },
        ],
        [
          { type: "label", value: "Birthday:", target: "birthday", width: 10 },
          {
            type: "date",
            id: "birthday",
            placeholder: "Select a date",
            yearRange: [1800, 1900],
            format: "dd/MM/yyyy",
          },
        ],
        [
          { type: "label", value: "Choice:", target: "choice", width: 10 },
          {
            type: "select",
            id: "choice",
            placeholder: "A select input",
            options: selectOptions,
          },
        ],
        [{ type: "price", id: "price", allowOR: true, required: true }],
        { position: "footer", columns: confirmRow },
      ]),
  },
  {
    id: "text",
    label: "Text",
    run: () =>
      newInput([
        [{ type: "title", value: "Text input" }],
        [
          {
            type: "text",
            id: "name",
            placeholder: "Type something",
            required: true,
          },
        ],
        confirmRow,
      ]),
  },
  {
    id: "number",
    label: "Number",
    run: () =>
      newInput([
        [{ type: "title", value: "Number input" }],
        [
          {
            type: "number",
            id: "amount",
            placeholder: "0 to 10",
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
    id: "date",
    label: "Date",
    run: () =>
      newInput([
        [{ type: "title", value: "Date input" }],
        [
          { type: "label", value: "Birthday:", target: "birthday", width: 20 },
          {
            type: "date",
            id: "birthday",
            placeholder: "Select a date",
            yearRange: [1800, 1900],
            format: "dd/MM/yyyy",
            required: true,
          },
        ],
        confirmRow,
      ]),
  },
  {
    id: "select",
    label: "Select",
    run: () =>
      newInput([
        [{ type: "title", value: "Select input" }],
        [
          {
            type: "select",
            id: "choice",
            placeholder: "Pick one",
            options: selectOptions,
            required: true,
          },
        ],
        [
          {
            type: "select",
            id: "preset",
            value: selectOptions[1],
            options: selectOptions,
          },
        ],
        confirmRow,
      ]),
  },
  {
    id: "price-or",
    label: "Price (OR)",
    run: () =>
      newInput([
        [{ type: "title", value: "Price with alternatives" }],
        [{ type: "price", id: "price", allowOR: true, required: true }],
        confirmRow,
      ]),
  },
  {
    id: "price-flat",
    label: "Price (flat value)",
    run: () =>
      newInput([
        [{ type: "title", value: "Price seeded with a flat Lua table" }],
        [
          {
            type: "price",
            id: "price",
            // Shape produced by a Lua mixed table: named keys plus numeric ones.
            value: { 1: { item: "horse_license", keep: true }, money: 10 },
            allowOR: false,
            required: true,
          },
        ],
        confirmRow,
      ]),
  },
  {
    id: "price-limited",
    label: "Price (money/gold only)",
    run: () =>
      newInput([
        [{ type: "title", value: "Restricted cost types" }],
        [
          {
            type: "price",
            id: "price",
            options: ["money", "gold"],
            value: { costs: [{ money: 25 }] },
            allowOR: true,
          },
        ],
        confirmRow,
      ]),
  },
  {
    id: "required",
    label: "Required fields",
    run: () =>
      newInput([
        [{ type: "title", value: "Everything is required" }],
        [
          {
            type: "text",
            id: "name",
            placeholder: "Required text",
            required: true,
          },
        ],
        [
          {
            type: "number",
            id: "amount",
            placeholder: "Required number",
            required: true,
          },
        ],
        [
          {
            type: "select",
            id: "choice",
            placeholder: "Required select",
            options: selectOptions,
            required: true,
          },
        ],
        confirmRow,
      ]),
  },
  {
    id: "buttons",
    label: "Buttons & widths",
    run: () =>
      newInput([
        [{ type: "title", value: "Widths and classes" }],
        [
          { type: "text", id: "left", placeholder: "width 70", width: 70 },
          {
            type: "text",
            id: "right",
            placeholder: "width 200px",
            width: "200px",
          },
        ],
        [
          {
            type: "description",
            value:
              "The row below mixes <b>button</b> and the legacy <b>action</b> type.",
            style: { color: "#f0c674" },
          },
        ],
        [
          {
            type: "button",
            id: "confirm",
            value: "Confirm",
            icon: "/assets/ui/tick.png",
            class: "success",
          },
          { type: "action", id: "delete", value: "Delete", class: "danger" },
          { type: "button", id: "warning", value: "Review", class: "warning" },
          { type: "button", id: "muted", value: "Details", class: "muted" },
          { type: "button", id: "flat", value: "Close", class: "flat" },
          {
            type: "button",
            id: "legacy-close",
            value: "Legacy green",
            class: "bg-green",
            ignoreRequired: true,
          },
        ],
      ]),
  },
  {
    id: "no-button",
    label: "No button (global Enter)",
    run: () =>
      newInput([
        [{ type: "title", value: "Press Enter with no field focused" }],
        [
          {
            type: "description",
            value: "There is no button, so Enter submits the panel.",
          },
        ],
        [{ type: "text", id: "name", placeholder: "Optional" }],
      ]),
  },
  {
    id: "button-styles",
    label: "Button styles",
    run: () =>
      newInput([
        [{ type: "title", value: "Button styles" }],
        [
          {
            type: "description",
            value:
              "Every built-in button style, including the legacy background classes.",
          },
        ],
        [{ type: "button", id: "default", value: "Default" }],
        [
          {
            type: "button",
            id: "success",
            value: "Success",
            icon: "/assets/ui/tick.png",
            class: "success",
          },
          {
            type: "button",
            id: "danger",
            value: "Danger",
            icon: "/assets/ui/trash.png",
            class: "danger",
          },
        ],
        [
          { type: "button", id: "warning", value: "Warning", class: "warning" },
          { type: "button", id: "muted", value: "Muted", class: "muted" },
          { type: "button", id: "flat", value: "Flat", class: "flat" },
        ],
        [
          {
            type: "button",
            id: "legacy-red",
            value: "Legacy red",
            class: "bg-red",
          },
          {
            type: "button",
            id: "legacy-green",
            value: "Legacy green",
            class: "bg-green",
          },
        ],
      ]),
  },
  {
    id: "positions",
    label: "Header / content / footer",
    // Long enough to hit --modal-max-height: only the middle zone may scroll,
    // the title and the buttons stay pinned.
    run: () =>
      newInput([
        {
          position: "header",
          columns: [{ type: "title", value: "Pick your horses" }],
        },
        {
          position: "header",
          columns: [
            {
              type: "description",
              value: "The title and the buttons stay put while this list scrolls.",
            },
          ],
        },
        ...Array.from({ length: 15 }, (_, index) => ({
          columns: [
            {
              type: "label" as const,
              value: `Horse ${index + 1}:`,
              target: `horse${index}`,
              width: 15,
            },
            {
              type: "text" as const,
              id: `horse${index}`,
              placeholder: "A name",
            },
          ],
        })),
        { position: "footer", columns: confirmRow },
      ]),
  },
  {
    id: "rows-without-columns",
    label: "Rows without columns",
    // Posted raw, bypassing newInput: the Lua parser normalizes the legacy
    // format before it ever reaches here, so a row missing its `columns` only
    // happens when something sends to the NUI directly. It must render an empty
    // row rather than throw.
    run: () =>
      SendNUIMessage({
        event: "newInput",
        data: {
          rows: [
            { columns: [{ type: "title", value: "Rows without columns" }] },
            [{ type: "description", value: "Legacy row, dropped silently." }],
            { columns: {} },
            {},
            {
              columns: [
                { type: "text", id: "name", placeholder: "Still focusable" },
              ],
            },
            { columns: [{ type: "button", id: "confirm", value: "Confirm" }] },
          ],
        },
      }),
  },
];
