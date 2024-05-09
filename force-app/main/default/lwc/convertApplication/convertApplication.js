import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { RefreshEvent } from 'lightning/refresh';
import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue, notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import CONTACT_FIELD from "@salesforce/schema/Application__c.Contact__c";
import createContact from '@salesforce/apex/ConvertApplicationController.createContact';

export default class ConvertApplication extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: "$recordId", fields: [CONTACT_FIELD] })
    application;

    handleCloseWindow(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    async handleConvertRecord(){
        await createContact({recordId: this.recordId});

        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Record created!",
              variant: "success",
            })
        );
    }

    get isApplicationConverted(){
        if(getFieldValue(this.application.data, CONTACT_FIELD) != null 
            && getFieldValue(this.application.data, CONTACT_FIELD) != ''){
            return true;
        }

        return false;
    }
}