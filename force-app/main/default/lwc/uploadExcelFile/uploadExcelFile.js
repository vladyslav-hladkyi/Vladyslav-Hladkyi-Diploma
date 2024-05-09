/*
 * @description       : 
 * @author            : sergiy.korolivskyi
 * @group             : 
 * @last modified on  : 04-25-2024
 * @last modified by  : vladyslav.hladkyi
*/
import { LightningElement, track, api } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";
import excelFileReader from "@salesforce/resourceUrl/ExcelReaderPlugin"; //Library to read the excel files
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import handleUploadedRecords from '@salesforce/apex/UploadExcelFileController.handleUploadedRecords';
import getAllAvailableMappings from '@salesforce/apex/UploadExcelFileController.getAllAvailableMappings';

let XLS = {};

export default class UploadExcelFile extends LightningElement {
    acceptedFormats = [".xls", ".xlsx"]; //Accepted formats for the excel file
    uploadedFileName = ''; //Store the name of the selected file.
    objFileWorkbook; // Object representing the Excel workbook
    progressBarValue = 0;
    batchSizeOptions = [
        {label: '100', value: '100'}, 
        {label: '200', value: '200'}, 
        {label: '300', value: '300'}, 
        {label: '400', value: '400'}, 
        {label: '500', value: '500'},
        {label: '1000', value: '1000'}
    ]

    @api title = 'Excel File Uploader';
    @track mappingNames = []; // All available mapping names
    @track chosenMappingName = ''; // Current value of mapping name
    @track chosenBathSize = '200'; // Current value of batch size
    @track chosenSheetTabName = ''; // Name of the sheet tab with records 
    @track isLoading = false; //Define state of component loading
    @track isProgressBarVisible = false;

    async connectedCallback() {
        this.mappingNames = await getAllAvailableMappings()

        Promise.all([loadScript(this, excelFileReader)])
        .then(() => {
            XLS = XLSX;
        })
        .catch((error) => {
            console.log("An error occurred while loading static resources");
        });
    }

    handleUploadFinished(event) {
        let uploadedFiles = event.detail.files;

        if (uploadedFiles.length && uploadedFiles != "") {
            this.isLoading = true;
            this.uploadedFileName = uploadedFiles[0].name;
            this.handleProcessExcelFile(uploadedFiles[0]);
        }
    }

    handleProcessExcelFile(file) {
        let objFileReader = new FileReader();

        objFileReader.onload = (event) => {
            let objFileData = event.target.result;

            this.objFileWorkbook = XLS.read(new Uint8Array(objFileData), {type: "array"});
            this.chosenSheetTabName = this.objFileWorkbook.SheetNames[0];
            this.isLoading = false;
        };

        objFileReader.onerror = function (error) {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error while reading the file",
                    message: error.body.message,
                    variant: "error"
                })
            );
        };

        objFileReader.readAsArrayBuffer(file);
    }

    async handleProceed() { 
        if(this.uploadedFileName == ''){
            this.dispatchEvent(
                new ShowToastEvent({ title: "Warning", message: "Upload File before clicking 'Proceed", variant: "warning"})
            ); 
            return; 
        }

        try {
            this.isLoading = true;
            this.isProgressBarVisible = true;

            let objExcelToJSON = XLS.utils.sheet_to_row_object_array(
                this.objFileWorkbook.Sheets[this.chosenSheetTabName]
            );

            //Verify if the file content is not blank
            if (objExcelToJSON.length == 0) {
                this.dispatchEvent(
                    new ShowToastEvent({title: "Error", message: "The chosen file's tab doesn't include data", variant: "error"})
                );

            } else { 
                let countOFRows = objExcelToJSON.length;
                // create records by batches
                while (objExcelToJSON.length > 0) {
                    let partialArray = objExcelToJSON.splice(0, Number(this.chosenBathSize));
                    await handleUploadedRecords({mappingDeveloperName: this.chosenMappingName, uploadedRecords: partialArray})

                    this.progressBarValue += (this.chosenBathSize / countOFRows) * 100;
                }

                this.uploadedFileName = '';
                this.objFileWorkbook = '';
                this.dispatchEvent(
                    new ShowToastEvent({ title: "Success", message: "Records have been uploaded", variant: "success" })
                );     
            }

        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({ title: "Error while creating records", message: error.body.message, variant: "error"})
            );  
        }
        
        this.isLoading = false;
        this.isProgressBarVisible = false;
        this.progressBarValue = 0;
    }

    handleChangeMappingName(event){
        this.chosenMappingName = event.target.value;
    }

    handleChangeBatchSize(event){
        this.chosenBathSize = event.target.value;
    }

    handleChangeSheetTabName(event){
        this.chosenSheetTabName = event.target.value;
    }

    get mappingNameOptions(){
        return this.mappingNames.map(mappingName => ({
            label: mappingName,
            value: mappingName
        }));
    }

    get tabNameOptions(){
        if(this.objFileWorkbook == null || this.objFileWorkbook == '') return [];

        return this.objFileWorkbook.SheetNames.map(tabName => ({
            label: tabName,
            value: tabName
        }));
    }

    get isFileUploadDisabled(){
        return this.chosenMappingName == '' ? true : false;
    }
}