import { LightningElement, api } from 'lwc';

export default class EmailSenderSearchItem extends LightningElement {
    @api record
    @api iconName;

    handleMouseDown(event){    
        this.dispatchEvent(new CustomEvent('selectrecord', {detail: this.record.id}));  
    }
}