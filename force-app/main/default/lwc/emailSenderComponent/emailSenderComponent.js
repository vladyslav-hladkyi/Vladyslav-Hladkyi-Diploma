import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import userId from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import lightningConfirm from 'lightning/confirm';
import getRelatedRecipients from '@salesforce/apex/EmailSenderController.getRelatedRecipients';
import getSearchedRecipients from '@salesforce/apex/EmailSenderController.getSearchedRecipients';
import sendEmailsToRecipients from '@salesforce/apex/EmailSenderController.sendEmailsToRecipients';

export default class EmailSenderComponent extends LightningElement {
    @api recordId;
    @api title = 'Email Sender';
    @api fieldToDisplay = '';
    @api jsonAPINames = '';
    @api contactFilter = '';
    @api junctionFilter = '';
    @api typeOfEmailCopy = 'none';
    @api orgWideAddressId = 'none';
    @api isJunctionUsed = false;
    @track relatedContacts = [];
    @track searchedContacts = [];
    @track recipients = [];
    @track emailsToCopy = [];
    @track emailBody = '';
    @track emailSubject = '';
    @track isSearchLoading = false;
    @track isLoading = true;
    @track areRecipientsExpanded = false;

    @wire(getRecord, { recordId: userId, fields: ['User.Email']}) 
    storeUserEmail({error, data}) {
        if (data) {
            this.emailsToCopy.push({
                type: 'icon',
                label: data.fields.Email.value,
                name: data.fields.Email.value,
                iconName: 'standard:email',
                alternativeText: 'Account'
            });
        } else if (error) {
            console.log('Error while getting user email ', error);
        }
    }

    connectedCallback(){
        this.handleGetRelatedRecipients();
        this.isLoading = false;
    }

    handleItemRecipientRemove(event) {
        this.recipients.splice(event.detail.index, 1);
    }

    handleItemEmailRemove(event){
        this.emailsToCopy.splice(event.detail.index, 1);
    }

    handleChangeEmailSubject(event){
        this.emailSubject = event.target.value;
    }

    handleChangeEmailBody(event){
        this.emailBody = event.target.value;
    }

    handleResetEmail(){
        this.emailSubject = '';
        this.emailBody = '';
    }

    handleHideRecipients(){
        this.areRecipientsExpanded = false;
    }

    handleExpandRecipients(){
        this.areRecipientsExpanded = true;
    }

    handleClearAllContacts(){
        this.recipients = [];
    }

    handleLeftOnlyRelatedContacts(){
        let relatedContactsIds = new Set(this.relatedContacts.map(r => r.id));

        this.recipients = this.recipients.filter(r => relatedContactsIds.has(r.contactId));
    }

    handleSearchBlur(){
        this.refs.searchContactList.handleBlur();
    }

    handleSearchFocus(event){
        if(event.target.value.length > 1) this.refs.searchContactList.handleFocus();
    }

    handleAddRelatedContacts(){
        let recipientIds = new Set(this.recipients.map(r => r.contactId));

        this.relatedContacts.forEach(contact => {
            if(!recipientIds.has(contact.id)) {
                this.recipients.push({
                    type: 'icon',
                    label: contact.label,
                    name: contact.name,
                    iconName: 'standard:contact',
                    alternativeText: 'Contact',
                    contactId: contact.id,
                    contactEmail: contact.email
                });

                recipientIds.add(contact.id);
            }
        })
    }

    handleSelectContact(event){
        let newRecipient = this.searchedContacts.find(c => c.id == event.detail);

        this.recipients.push({
            type: 'icon',
            label: newRecipient.label,
            name: newRecipient.name,
            iconName: 'standard:contact',
            alternativeText: 'Contact',
            contactId: newRecipient.id,
            contactEmail: newRecipient.email
        });
    }

    async handleKeyUpSearch(event){
        if(event.keyCode === 13 ) {
            if(event.target.value.length < 2){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Search Input Should Have Length > 1',
                    variant: 'warning'
                }));

                return;
            }

            try {
                this.isSearchLoading = true;
                this.searchedContacts = await getSearchedRecipients({
                    recordId: this.recordId, 
                    searchText: event.target.value, 
                    contactFilter: this.contactFilter, 
                    fieldToDisplay: this.fieldToDisplay
                });
            } catch(error){
                this.isSearchLoading = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Server Error',
                    variant: 'error',
                    message: error.body.message
                }));
    
                return;
            }

            this.refs.searchContactList.handleFocus();
            this.isSearchLoading = false;
        }
    }

    handleKeyUpEmails(event){
        if(event.keyCode === 13) {
            let input = this.refs.emailsInput;

            if(input.validity.valid){
                let foundDuplicate = this.emailsToCopy.some(e => e.name == input.value);

                if(!foundDuplicate){
                    this.emailsToCopy.push({
                        type: 'icon',
                        label: input.value,
                        name: input.value,
                        iconName: 'standard:email',
                        alternativeText: 'Account'
                    });
                }
                input.value = '';
            }
            else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Email Validation Error',
                    variant: 'warning'
                }));
            }
        }
    }

    async handleSendEmails(){
        if(!this.validateSendingEmail()) return;

        let confirmResult = await lightningConfirm.open({
            label: 'Are you sure you want to send emails?',
            variant: 'header'
        });

        if(!confirmResult) return;
        this.isLoading = true;

        try {
            await sendEmailsToRecipients({
                recordId: this.recordId,
                emailBody: this.emailBody,
                emailSubject: this.emailSubject,
                emailsToCopy: this.emailsToCopy.map(e => e.label),
                recipientsIds: this.recipients.map(r => r.contactId),
                typeOfEmailCopy: this.typeOfEmailCopy,
                orgWideAddressId: this.orgWideAddressId
            });
        } catch(error){
            this.isLoading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error',
                variant: 'error',
                message: error.body.message
            }));

            return;
        }

        this.dispatchEvent(new ShowToastEvent({
            title: 'Emails have been sent!',
            variant: 'success'
        }));

        this.isLoading = false;
        this.recipients = [];
        this.emailsToCopy = [];
        this.emailSubject = [];
        this.searchedContacts = [];
        this.emailBody = '';
    }

    async handleGetRelatedRecipients(){
        try {
            this.relatedContacts = await getRelatedRecipients({
                recordId: this.recordId, 
                jsonNames: this.jsonAPINames,
                isJunctionUsed: this.isJunctionUsed, 
                contactFilter: this.contactFilter,
                junctionFilter: this.junctionFilter, 
                fieldToDisplay: this.fieldToDisplay
            });
        } catch(error){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error',
                variant: 'error',
                message: error.body.message
            }));

            return;
        }

        for(let contact of this.relatedContacts){
            this.recipients.push({
                type: 'icon',
                label: contact.label,
                name: contact.name,
                iconName: 'standard:contact',
                alternativeText: 'Contact',
                contactId: contact.id,
                contactEmail: contact.email
            });
        }
    }

    validateSendingEmail(){
        let validationFlag = true;
        let errorMessage = '';

        if(this.emailSubject == '' || this.emailSubject == null){
            validationFlag = false;
            errorMessage = 'Please enter a email subject'
        }

        if(this.emailBody == '' || this.emailBody == null){
            validationFlag = false;
            errorMessage = 'Please enter a email body'
        }

        if(this.recipients.length == 0 || this.recipients.some(r => r.contactEmail == null)){
            validationFlag = false;
            errorMessage = 'Please add a recipient to your email or check recipient\'s email addresses'
        }

        if(!validationFlag){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Email Validation Error',
                message: errorMessage,
                variant: 'warning'
            }));
        }

        return validationFlag;
    }

    get availableContacts(){
        let recipientIds = new Set(this.recipients.map(r => r.contactId));

        return this.searchedContacts.filter(searchedContact => !recipientIds.has(searchedContact.id))
    }

    get emailCopyIsShown(){
        if(this.typeOfEmailCopy == 'none' ) return false;
        return true;
    }

    get emailCopyPlaceholder(){
        if(this.typeOfEmailCopy == 'cc') return 'Enter Emails For CC'
        if(this.typeOfEmailCopy == 'bcc') return 'Enter Emails For BCC'
        return '';
    }
}