import { LightningElement, api, track } from 'lwc';

export default class EmailSenderSearch extends LightningElement {
    @api records = []
    @api iconName = '';
    @track focused = false
 
    get showListbox () { 
        return this.focused && this.records.length > 0
    }

    get comboboxClasses () {
        const classes = ['slds-combobox', 'slds-dropdown-trigger', 'slds-dropdown-trigger_click' ]

        if (this.showListbox) {
            classes.push('slds-is-open')
        }

        return classes.join(' ')
    }

    handleSelectRecord (event) {
        this.focused = false;
        this.dispatchEvent(new CustomEvent('selectrecord', {detail: event.detail}));
    }

    @api
    handleBlur() {
        this.focused = false;
    }

    @api
    handleFocus(){
        this.focused = true;
    }
}