public with sharing class RG9_SequenciaInteligenteService {

    // Classe de input para invocable method (Flow)
    public class InputParams {
        @InvocableVariable(required=true)
        public String apiNameObject;     // Ex.: 'RG9_CasosDaOperacao__c'

        @InvocableVariable(required=true)
        public String apiNameRecType;    // Ex.: 'Espolio'

        @InvocableVariable(required=false)
        public String tipoDeCaso;        // Opcional → default "Principal"

        @InvocableVariable(required=true)
        public String template;          // Apenas prefixo, ex.: "COP - "
    }

    // Classe de output para invocable method (Flow)
    public class OutputParams {
        @InvocableVariable
        public String generatedName;
    }

    @InvocableMethod(label='Gerar Sequência Inteligente'
                     description='Gera um número sequencial com prefixo fixo e 10 dígitos, controlado por Objeto + RecordType + Tipo de Caso.')
    public static List<OutputParams> generateSequence(List<InputParams> requests) {
        List<OutputParams> results = new List<OutputParams>();

        for (InputParams req : requests) {
            if (String.isBlank(req.apiNameObject) || String.isBlank(req.apiNameRecType)) {
                throw new AuraHandledException('apiNameObject e apiNameRecType são obrigatórios.');
            }
            if (String.isBlank(req.template)) {
                throw new AuraHandledException('template é obrigatório. Ex.: "COP - "');
            }

            String tipo = String.isBlank(req.tipoDeCaso) ? 'Principal' : req.tipoDeCaso.trim();
            String scopeKey = req.apiNameObject + '|' + req.apiNameRecType + '|' + tipo;

            // Tenta buscar o registro de reuso com lock
            RG9_Reuso__c cfg = trySelectConfigForUpdate(req.apiNameObject, req.apiNameRecType, tipo);

            // Se não existir, cria o registro inicial com Sequência Atual = 0
            if (cfg == null) {
                cfg = new RG9_Reuso__c(
                    RG9_Reuso_ApiName_Object__c   = req.apiNameObject,
                    RG9_Reuso_ApiName_RecType__c  = req.apiNameRecType,
                    RG9_Reuso_TipoDeCaso__c       = tipo,
                    RG9_Reuso_ScopeKey__c         = scopeKey,
                    RG9_Reuso_SequenciaAtual__c   = 0
                );
                try {
                    insert cfg;
                } catch (DmlException e) {
                    // Se outra transação inseriu ao mesmo tempo (unique key), reconsulta com lock
                    cfg = trySelectConfigForUpdate(req.apiNameObject, req.apiNameRecType, tipo);
                    if (cfg == null) {
                        throw e;
                    }
                }
            }

            // Incrementa a sequência
            Long nextNumber = (cfg.RG9_Reuso_SequenciaAtual__c == null ? 0 
                                : cfg.RG9_Reuso_SequenciaAtual__c.longValue()) + 1;
            cfg.RG9_Reuso_SequenciaAtual__c = nextNumber;
            update cfg;

            // Converte o número para string
            String numberStr = String.valueOf(nextNumber);

            // Garante 10 dígitos preenchendo com zeros à esquerda
            Integer zerosToAdd = 10 - numberStr.length();
            String zeros = '';
            for (Integer i = 0; i < zerosToAdd; i++) {
                zeros += '0';
            }
            numberStr = zeros + numberStr;

            // Concatena com o prefixo
            String finalName = req.template + numberStr;


            OutputParams out = new OutputParams();
            out.generatedName = finalName;
            results.add(out);
        }

        return results;
    }

    // --- Helper: seleciona registro RG9_Reuso__c com FOR UPDATE ---
    private static RG9_Reuso__c trySelectConfigForUpdate(String objApi, String rtApi, String tipo) {
        List<RG9_Reuso__c> rows = [
            SELECT Id, RG9_Reuso_SequenciaAtual__c
            FROM RG9_Reuso__c
            WHERE RG9_Reuso_ApiName_Object__c  = :objApi
              AND RG9_Reuso_ApiName_RecType__c = :rtApi
              AND RG9_Reuso_TipoDeCaso__c      = :tipo
            LIMIT 1
            FOR UPDATE
        ];
        return rows.isEmpty() ? null : rows[0];
    }
}
