public with sharing class EmailSenderEmailCopyPicklist extends VisualEditor.DynamicPickList {
    public override VisualEditor.DataRow getDefaultValue(){
        return new VisualEditor.DataRow('None', 'none');
    }

    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows picklist = new VisualEditor.DynamicPickListRows();

        picklist.addRow(new VisualEditor.DataRow('None', 'none'));
        picklist.addRow(new VisualEditor.DataRow('CC', 'cc'));
        picklist.addRow(new VisualEditor.DataRow('BCC', 'bcc'));

        return picklist;
    }
}