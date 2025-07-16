public with sharing class HomeWelcomeController {
    @AuraEnabled(cacheable=true)
    public static String getUserName() {
        return [SELECT Name FROM User WHERE Id = :UserInfo.getUserId()].Name;
    }
}