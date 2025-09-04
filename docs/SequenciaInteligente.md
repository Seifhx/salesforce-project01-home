# Salesforce - Sequência Inteligente (RG9_SequenciaInteligenteService)

## 1. Introdução
O componente **Sequência Inteligente** tem como objetivo gerar nomes sequenciais customizados para registros de qualquer objeto Salesforce, de forma centralizada e reutilizável.  

- Permite definir **prefixos customizados** e quantidade fixa de dígitos (10 no padrão atual).  
- Mantém o controle da sequência em um registro único do objeto **RG9_Reuso__c**.  
- Pode ser utilizado em qualquer objeto e record type, com ou sem distinção de tipo de caso (Principal ou Secundário).  
- É acionado via **Record-Triggered Flow**, tornando sua implementação rápida e sem necessidade de múltiplas triggers.  

---

## 2. Escopo
- **Objetivo:** Centralizar a lógica de auto-numeração customizável, permitindo reutilização em toda a organização.  
- **Alcance:** Todos os objetos Salesforce que precisem de sequência customizada em seus registros.  
- **Limites:**
  - A quantidade de dígitos fixada em 10.  
  - Cada sequência é única por combinação de objeto, record type e tipo de caso (configurado via `ScopeKey`).  
  - Valores antigos permanecem intactos caso o prefixo seja alterado.  

---

## 3. Casos de Uso
1. **Registro único por record type:**  
   - Cada record type do objeto possui sua sequência própria.  
   - Ex.: `"Espólio"` → `COP - 0000000001`  

2. **Registro unificado por objeto:**  
   - Todos os record types compartilham a mesma sequência.  
   - Ex.: `apiNameRecType = 'Default'` → todos os registros do objeto seguem `COP - 0000000001`, `COP - 0000000002`, ...  

3. **Casos Pai e Secundário:**  
   - Permite diferenciar sequência entre registros principais e filhos (ou secundários) usando o campo `Tipo de Caso`.  
   - Ex.: `Principal` → `COP - 0000000123`  
          `Secundário` → `CasoFilho - 0000000001`  

---

## 4. Inputs (parâmetros do Apex Action no Flow)

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|------------|-----------|
| `apiNameObject` | Text | Sim | API Name do objeto para o qual a sequência será gerada |
| `apiNameRecType` | Text | Sim | API Name do record type. Para unificar sequência por objeto, use `"Default"` |
| `tipoDeCaso` | Text | Não | Picklist: `"Principal"` ou `"Secundário"`. Se não informado, assume `"Principal"` |
| `template` | Text | Sim | Prefixo do registro (ex.: `"COP - "`, `"Caso - "`). Sempre 10 dígitos para a sequência |

---

## 5. Outputs (retorno do método Apex)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `generatedName` | Text | Nome gerado completo, combinando prefixo e sequência zero-padded de 10 dígitos |

---

## 6. Recomendações de Uso
- Sempre criar um **Record-Triggered Flow** que chame o Apex Action ao criar registros.  
- Manter consistência nos **prefixos** e registrar os templates utilizados, para evitar confusão histórica.  
- Para sequências contínuas entre record types, usar `apiNameRecType = 'Default'`.  
- Caso altere o prefixo para registros existentes, lembrar que os registros antigos **não são atualizados automaticamente**.  
- Garantir que os usuários tenham acesso à **classe Apex** e ao **objeto RG9_Reuso__c** via Permission Set.  

---

## 7. Quem Desenvolveu
- **Equipe:** RG9 - Plataforma Ops  
- **Desenvolvedor:** Tauã Gentini Ângelo  
- **Contato:** taua.angelo@wise-otter-5c87va.com  

---

## 8. Patch Notes
| Versão | Data | Descrição |
|--------|------|-----------|
| 1.0 | 2025-09-03 | Primeira versão funcional do `Sequência Inteligente` |
| 1.1 | 2025-09-03 | Adicionado suporte para `Tipo de Caso` opcional (default `"Principal"`) |
| 1.2 | 2025-09-03 | Ajuste no template para fixar 10 dígitos e padLeft correto |
| 1.3 | 2025-09-03 | Correção do ScopeKey e sequência compartilhada por objeto ou record type |
| 1.4 | 2025-09-03 | Classe de teste robusta para cobertura 100% |

---

## 9. Exemplo de Flow de Reuso

### 9.1 Cenário
- Objeto: `RG9_CasosDaOperacao__c`  
- Record type: `"Espólio"`  
- Prefixo: `"COP - "`  
- Tipo de caso: `"Principal"`  

Objetivo: Ao criar um registro, gerar automaticamente o nome sequencial.

### 9.2 Passo a Passo

1. **Criar um Flow do tipo Record-Triggered**
   - Setup → Flow → New Flow → Record-Triggered Flow  
   - Objeto: `RG9_CasosDaOperacao__c`  
   - Trigger: `A record is created`  
   - Configure para executar **Before Save** se quiser atualizar o Name antes do insert ou **After Save** se quiser chamar Apex Action.  

2. **Adicionar Apex Action**
   - Arraste o elemento **Action** para o canvas.  
   - Selecione a classe Apex: `RG9_SequenciaInteligenteService.generateSequence`  
   - Preencha os inputs:  
     | Input | Valor |
     |-------|-------|
     | apiNameObject | `RG9_CasosDaOperacao__c` |
     | apiNameRecType | `Espólio` (ou `"Default"` para todos os record types) |
     | tipoDeCaso | `"Principal"` (opcional) |
     | template | `"COP - "` |

3. **Mapear saída da Apex Action**
   - Output: `generatedName`  
   - Atribua ao campo `Name` do registro criado:  
     ```text
     {!$Record.Name} = {!generatedName}
     ```

4. **Ativar o Flow**
   - Salve e ative.  
   - Todos os novos registros agora terão o nome gerado automaticamente com a sequência correta.

### 9.3 Cenários Alternativos

1. **Sequência compartilhada entre todos os record types**
   - Input `apiNameRecType = "Default"`  
   - Todos os registros do objeto usam a mesma sequência.

2. **Casos filhos ou secundários**
   - Input `tipoDeCaso = "Secundário"`  
   - Permite gerar sequência separada sem criar record type adicional.

3. **Troca de template**
   - Alterar o input `template` no Flow.  
   - Próximos registros seguem a mesma sequência (`lastNumber`), prefixo atualizado.  
   - Registros antigos permanecem com prefixo antigo.

### 9.4 Recomendações visuais

- Sempre documentar no Flow qual **template e tipo de caso** está sendo usado.  
- Criar flows separados por objeto se quiser sequências independentes.  
- Para testes em Sandbox, use prefixos diferentes para não conflitar com produção.
