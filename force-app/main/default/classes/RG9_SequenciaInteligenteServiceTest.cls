@IsTest
public class RG9_SequenciaInteligenteServiceTest {

    @IsTest
    static void testGenerateSequence_FirstRecord() {
        // Cenário: primeiro uso, registro RG9_Reuso__c não existe
        RG9_SequenciaInteligenteService.InputParams req = new RG9_SequenciaInteligenteService.InputParams();
        req.apiNameObject = 'RG9_CasosDaOperacao__c';
        req.apiNameRecType = 'Espolio';
        req.tipoDeCaso = null; // Deve assumir "Principal"
        req.template = 'COP - ';

        Test.startTest();
        List<RG9_SequenciaInteligenteService.OutputParams> result = 
            RG9_SequenciaInteligenteService.generateSequence(new List<RG9_SequenciaInteligenteService.InputParams>{req});
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals('COP - 0000000001', result[0].generatedName);

        // Verifica se o RG9_Reuso__c foi criado
        RG9_Reuso__c cfg = [
            SELECT RG9_Reuso_SequenciaAtual__c, RG9_Reuso_TipoDeCaso__c
            FROM RG9_Reuso__c
            WHERE RG9_Reuso_ApiName_Object__c = 'RG9_CasosDaOperacao__c'
            AND RG9_Reuso_ApiName_RecType__c = 'Espolio'
            LIMIT 1
        ];
        System.assertEquals(1, cfg.RG9_Reuso_SequenciaAtual__c);
        System.assertEquals('Principal', cfg.RG9_Reuso_TipoDeCaso__c);
    }

    @IsTest
    static void testGenerateSequence_Increment() {
        // Cenário: já existe registro RG9_Reuso__c com sequência 1
        RG9_Reuso__c cfg = new RG9_Reuso__c(
            RG9_Reuso_ApiName_Object__c = 'RG9_CasosDaOperacao__c',
            RG9_Reuso_ApiName_RecType__c = 'Espolio',
            RG9_Reuso_TipoDeCaso__c = 'Principal',
            RG9_Reuso_ScopeKey__c = 'RG9_CasosDaOperacao__c|Espolio|Principal',
            RG9_Reuso_SequenciaAtual__c = 1
        );
        insert cfg;

        RG9_SequenciaInteligenteService.InputParams req = new RG9_SequenciaInteligenteService.InputParams();
        req.apiNameObject = 'RG9_CasosDaOperacao__c';
        req.apiNameRecType = 'Espolio';
        req.tipoDeCaso = 'Principal';
        req.template = 'COP - ';

        Test.startTest();
        List<RG9_SequenciaInteligenteService.OutputParams> result =
            RG9_SequenciaInteligenteService.generateSequence(new List<RG9_SequenciaInteligenteService.InputParams>{req});
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals('COP - 0000000002', result[0].generatedName);

        // Verifica se a sequência foi incrementada no registro
        RG9_Reuso__c cfgUpdated = [SELECT RG9_Reuso_SequenciaAtual__c FROM RG9_Reuso__c WHERE Id = :cfg.Id];
        System.assertEquals(2, cfgUpdated.RG9_Reuso_SequenciaAtual__c);
    }

    @IsTest
    static void testGenerateSequence_DifferentPrefix() {
        // Cenário: prefixo diferente e tipoDeCaso definido
        RG9_SequenciaInteligenteService.InputParams req = new RG9_SequenciaInteligenteService.InputParams();
        req.apiNameObject = 'RG9_CasosDaOperacao__c';
        req.apiNameRecType = 'OutroProcesso';
        req.tipoDeCaso = 'Secundário';
        req.template = 'Caso - ';

        Test.startTest();
        List<RG9_SequenciaInteligenteService.OutputParams> result =
            RG9_SequenciaInteligenteService.generateSequence(new List<RG9_SequenciaInteligenteService.InputParams>{req});
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals('Caso - 0000000001', result[0].generatedName);

        RG9_Reuso__c cfg = [SELECT RG9_Reuso_SequenciaAtual__c FROM RG9_Reuso__c
                            WHERE RG9_Reuso_ApiName_Object__c = 'RG9_CasosDaOperacao__c'
                            AND RG9_Reuso_ApiName_RecType__c = 'OutroProcesso'
                            AND RG9_Reuso_TipoDeCaso__c = 'Secundário'
                            LIMIT 1];
        System.assertEquals(1, cfg.RG9_Reuso_SequenciaAtual__c);
    }

    @IsTest
    static void testGenerateSequence_MultipleRequests() {
        // Cenário: várias chamadas em uma lista
        RG9_SequenciaInteligenteService.InputParams req1 = new RG9_SequenciaInteligenteService.InputParams();
        req1.apiNameObject = 'RG9_CasosDaOperacao__c';
        req1.apiNameRecType = 'Espolio';
        req1.tipoDeCaso = null;
        req1.template = 'COP - ';

        RG9_SequenciaInteligenteService.InputParams req2 = new RG9_SequenciaInteligenteService.InputParams();
        req2.apiNameObject = 'RG9_CasosDaOperacao__c';
        req2.apiNameRecType = 'OutroProcesso';
        req2.tipoDeCaso = 'Secundário';
        req2.template = 'Caso - ';

        Test.startTest();
        List<RG9_SequenciaInteligenteService.OutputParams> results =
            RG9_SequenciaInteligenteService.generateSequence(new List<RG9_SequenciaInteligenteService.InputParams>{req1, req2});
        Test.stopTest();

        System.assertEquals(2, results.size());
        System.assertEquals('COP - 0000000001', results[0].generatedName);
        System.assertEquals('Caso - 0000000001', results[1].generatedName);
    }
}
