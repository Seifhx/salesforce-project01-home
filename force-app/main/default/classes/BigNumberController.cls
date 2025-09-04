public with sharing class BigNumberController {
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getRecordCountBySubJornada() {
        return [
            SELECT Sub_Jornada__c subJornada, COUNT(Id) total
            FROM RG9_CasosDaOperacao__c
            GROUP BY Sub_Jornada__c
        ];
    }
}
