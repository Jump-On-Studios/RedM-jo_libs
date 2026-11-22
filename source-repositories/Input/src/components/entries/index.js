import ButtonEntry from './ButtonEntry.vue';
import DateInput from './DateInput.vue';
import DescriptionEntry from './DescriptionEntry.vue';
import LabelEntry from './LabelEntry.vue';
import NumberInput from './NumberInput.vue';
import PriceInput from './PriceInput.vue';
import SelectInput from './SelectInput.vue';
import TextInput from './TextInput.vue';
import TitleEntry from './TitleEntry.vue';
import TextArea from './TextArea.vue';
/** One component per entry type. `action` is the legacy name of `button`. */
export const ENTRY_COMPONENTS = {
    title: TitleEntry,
    description: DescriptionEntry,
    label: LabelEntry,
    text: TextInput,
    number: NumberInput,
    date: DateInput,
    select: SelectInput,
    price: PriceInput,
    button: ButtonEntry,
    action: ButtonEntry,
    textarea: TextArea,
};
