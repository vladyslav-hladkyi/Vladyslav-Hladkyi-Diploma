/**
 * @description       : 
 * @author            : vladyslav.hladkyi
 * @group             : 
 * @last modified on  : 04-25-2024
 * @last modified by  : vladyslav.hladkyi
**/
public with sharing class UploadMIFTranformationHelper implements Callable {

    public Object call(String action, Map<String, Object> args) {
        switch on action {
            when 'numberToBoolean' {
                return this.numberToBoolean(String.valueOf(args.get('columnName')), (Map<String, Object>)args.get('row'));
            }
            when 'characterToBoolean' {
                return this.characterToBoolean(String.valueOf(args.get('columnName')), (Map<String, Object>)args.get('row'));
            }
            when 'parseDate' {
                return this.parseDate(String.valueOf(args.get('columnName')), (Map<String, Object>)args.get('row'));
            }
            when 'parseNumber' {
                return this.parseNumber(String.valueOf(args.get('columnName')), (Map<String, Object>)args.get('row'));
            }
            when 'validateEmail' {
                return this.validateEmail(String.valueOf(args.get('columnName')), (Map<String, Object>)args.get('row'));
            }
            when 'getEmergencyContactRelation' {
                return this.getEmergencyContactRelation(String.valueOf(args.get('columnName')), (Map<String, Object>)args.get('row'));
            }
            when 'getGender' {
                return this.getGender(String.valueOf(args.get('columnName')), (Map<String, Object>)args.get('row'));
            }
            when 'normalizeLanguage' {
                return this.normalizeLanguage(String.valueOf(args.get('columnName')), (Map<String, Object>)args.get('row'));
            }
            when 'combineResidentialStreets' {
                return this.combineResidentialStreets(String.valueOf(args.get('columnName')), (Map<String, Object>)args.get('row'));
            }
            when 'combineMailingStreets' {
                return this.combineMailingStreets(String.valueOf(args.get('columnName')), (Map<String, Object>)args.get('row'));
            }
            when 'handleECMTransitionFrom' {
                return this.handleECMTransitionFrom(String.valueOf(args.get('columnName')), (Map<String, Object>)args.get('row'));
            }
            when 'handleFileReportingStartDate' {
                return this.handleFileReportingStartDate(String.valueOf(args.get('columnName')), (Map<String, Object>)args.get('row'));
            }
            when 'handleFileReportingEndDate' {
                return this.handleFileReportingEndDate(String.valueOf(args.get('columnName')), (Map<String, Object>)args.get('row'));
            }
            when else {
                throw new CallableHelperException('Method not implemented');
            }
        }
    }

    // it's for fields that can have '1' or '0' values and represent boolean values
    Boolean numberToBoolean(String columnName, Map<String, Object> row){
        return String.valueOf(row.get(columnName)) == '1' ? true : false;
    }

    // it's for fields that can have 'Y' or 'N' values and represent boolean values
    Boolean characterToBoolean(String columnName, Map<String, Object> row){
        return String.valueOf(row.get(columnName)) == 'Y' ? true : false;
    }

    Decimal parseNumber(String columnName, Map<String, Object> row) {
        return !String.isBlank(String.valueOf(row.get(columnName))) ? Decimal.valueOf(String.valueOf(row.get(columnName))) : null;
    }

    Date handleFileReportingStartDate(String columnName, Map<String, Object> row){
        String stringDate = !String.isBlank(String.valueOf(row.get(columnName))) ? String.valueOf(row.get(columnName)).substringBefore('.') : '';

        return stringToDate(stringDate);
    }

    Date handleFileReportingEndDate(String columnName, Map<String, Object> row){
        String stringDate = !String.isBlank(String.valueOf(row.get(columnName))) ? String.valueOf(row.get(columnName)).substringAfter('.') : '';

        return stringToDate(stringDate);
    }

    String combineResidentialStreets(String columnName, Map<String, Object> row){
        String secondAddress = String.valueOf(row.get('Member Residential Address Line 2'));
        
        return String.valueOf(row.get(columnName)) + (String.isBlank(secondAddress) ? '' : '\n' + secondAddress);
    }

    String combineMailingStreets(String columnName, Map<String, Object> row){
        String secondAddress = String.valueOf(row.get('Member Mailing Address Line 2'));

        return String.valueOf(row.get(columnName)) + (String.isBlank(secondAddress) ? '' : '\n' + secondAddress);
    }

    String getGender(String columnName, Map<String, Object> row){
        switch on String.valueOf(row.get(columnName)) {
            when 'M' {return 'Male';}
            when 'F' {return 'Female';}
            when else {return String.valueOf(row.get(columnName));}
        }
    }

    //columnName should be equal to 'Member Transitioned from Health Homes Program'
    String handleECMTransitionFrom(String columnName, Map<String, Object> row){
        if(String.valueOf(row.get(columnName)) == '1'){
            return 'Health Homes Program';
        }
        if(String.valueOf(row.get('Member Transitioned from Whole Person Care Pilot')) == '1'){
            return 'Whole Person Care Pilot';
        }

        return null;
    }

    String normalizeLanguage(String columnName, Map<String, Object> row) {
        String language = String.valueOf(row.get(columnName));

        if (String.isBlank(language)) {
            return null;
        }
        
        if (language.contains(';')) {
            return language.substringBefore(';');
        } 
        else if (language.contains(',')) {
            return language.substringBefore(',');
        }

        return language;
    }

    String getEmergencyContactRelation(String columnName, Map<String, Object> row) {
        switch on String.valueOf(row.get(columnName)) {
            when '1' {return 'Spouse';}
            when '2' {return 'Partner';}
            when '3' {return 'Parent';}
            when '4' {return 'Sibling';}
            when '5' {return 'Legal Guardian';}
            when '6' {return 'Grandparent';}
            when '7' {return 'Child';}
            when '8' {return 'Other Family Member';}
            when '9' {return 'Friend';}
            when '10' {return 'Other';}
            when else {return '';}
        }
    }

    Date parseDate(String columnName, Map<String, Object> row) {
        String stringDate = String.valueOf(row.get(columnName));

        return stringToDate(stringDate);
    }

    String validateEmail(String columnName, Map<String, Object> row) {
        String email = String.valueOf(row.get(columnName));
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 

        if (String.isBlank(email)) {
            return null;
        }

	    Pattern MyPattern = Pattern.compile(emailRegex);
	    Matcher MyMatcher = MyPattern.matcher(email);

        if(MyMatcher.matches()){
            return email;
        }
        else {
            return null;
        }
    }

    Date stringToDate(String stringDate){
        if (String.isBlank(stringDate)) {
            return null;
        }
        if (stringDate.contains('/')) {
            Integer month = Integer.valueOf(stringDate.substringBefore('/'));
            Integer day = Integer.valueOf(stringDate.substringBetween('/'));
            Integer year = Integer.valueOf(stringDate.substringAfterLast ('/'));
            return Date.newinstance(year, month, day);
        }
        if (stringDate.contains('.')) {
            Integer day = Integer.valueOf(stringDate.substringBefore('.'));
            Integer month = Integer.valueOf(stringDate.substringBetween('.'));
            Integer year = Integer.valueOf(stringDate.substringAfterLast ('.'));
            return Date.newinstance(year, month, day);
        }
        if (stringDate.contains('-')) {
            return Date.parse(stringDate);
        }

        return null;
    }

    public class CallableHelperException extends Exception {}
}