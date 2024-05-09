/**
 * @description       : 
 * @author            : vladyslav.hladkyi
 * @group             : 
 * @last modified on  : 05-06-2024
 * @last modified by  : vladyslav.hladkyi
**/
public with sharing class UploadExcelFileTranformationHelper implements Callable {

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