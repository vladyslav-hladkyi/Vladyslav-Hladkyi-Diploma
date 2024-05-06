public with sharing class EmailSenderOrgWideAddressPicklist extends VisualEditor.DynamicPickList{
    public override VisualEditor.DataRow getDefaultValue(){
        return new VisualEditor.DataRow('None', 'none');
    }

    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows picklist = new VisualEditor.DynamicPickListRows();        
        picklist.addRow(new VisualEditor.DataRow('None', 'none'));


        for(OrgWideEmailAddress address : [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress]){
            picklist.addRow(new VisualEditor.DataRow(address.Address, (String)address.Id));
        }

        return picklist;
    }
}