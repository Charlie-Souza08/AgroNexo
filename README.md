# AgroNexo - Gestão de Fazenda

## 1. Visão Geral

O **AgroNexo** é um sistema de banco de dados relacional projetado para suprir as demandas de governança, rastreabilidade e controle operacional no agronegócio contemporâneo. A gestão de propriedades agrícolas enfrenta com frequência desafios relacionados à dispersão de registros em cadernos de campo, planilhas despadronizadas e ausência de integração entre as etapas de manejo e os resultados produtivos.

A solução visa mitigar gargalos como o desperdício de insumos, o subdimensionamento de frotas agrícolas e a imprecisão no cálculo de custos e produtividade por talhão. Por meio de uma modelagem relacional normalizada, o AgroNexo consolida desde o cadastramento geoespacial das propriedades rurais até o fechamento financeiro e quantitativo das colheitas.

---

## 2. Participantes do Projeto

- Italo Yan Mendes da Silva
- Hellen Verena da Conceição Magalhães
- Charlie 

---

## 3. Escopo do Sistema

O escopo do sistema abrange o ciclo completo de planejamento e execução agrícola em nível de talhão, compreendendo os seguintes módulos e fluxos:

- **Controle Territorial:** Cadastro das propriedades rurais e sua subdivisão física e operacional em talhões produtivos.
- **Gestão de Culturas:** Catalogação das espécies cultivadas e seus ciclos fenológicos em dias.
- **Recursos Humanos e Mecanização:** Controle da equipe de campo com categorização de funções e cadastro de tratores e implementos agrícolas.
- **Gestão de Insumos:** Classificação de materiais (sementes, defensivos e fertilizantes) e monitoramento de custos unitários e unidades de medida.
- **Operações de Campo:** Registro cronológico das atividades agrícolas (preparo de solo, plantio, pulverização, adubação), associando talhão, operador, maquinário e insumos aplicados.
- **Encerramento de Safra e Colheita:** Apontamento da colheita com registro de massa produzida (kg), receita obtida e correlação com a área cultivada.

---

## 4. Dicionário de Entidades e Atributos

Abaixo estão detalhadas as entidades centrais do modelo relacional, suas descrições funcionais, atributos essenciais e seu papel dentro do ciclo de vida agrícola.

### 4.1. Propriedade
- **Descrição Funcional:** Representa a fazenda ou unidade imobiliária rural produtora.
- **Atributos Essenciais:** `id` (Chave Primária), `nome` (Identificação da propriedade), `municipio` (Localização administrativa), `area_total_ha` (Área total contínua em hectares).
- **Papel no Fluxo Agrícola:** Atua como a entidade delimitadora de topo, agregando os talhões sob uma mesma gestão jurídica e territorial.

### 4.2. Talhao
- **Descrição Funcional:** Subdivisão contínua de área produtiva pertencente a uma propriedade rural, utilizada para segregação de manejos e culturas.
- **Atributos Essenciais:** `id` (Chave Primária), `codigo` (Identificador alfanumérico no mapa da fazenda), `area_ha` (Área líquida plantável em hectares), `idPropriedade` (Chave Estrangeira para Propriedade).
- **Papel no Fluxo Agrícola:** Unidade básica de amostragem, aplicação de insumos e mensuração de rendimento agropecuário.

### 4.3. Cultura
- **Descrição Funcional:** Registro taxonômico e agronômico da espécie vegetal explorada comercialmente.
- **Atributos Essenciais:** `id` (Chave Primária), `nome` (Nome comercial/comum da cultura), `ciclo_dias` (Duração estimada do plantio à colheita em dias).
- **Papel no Fluxo Agrícola:** Define as necessidades nutricionais, a época de intervenção e serve de base para o cruzamento de dados com o calendário de operações.

### 4.4. Funcionario
- **Descrição Funcional:** Cadastro do colaborador alocado nas tarefas rurais da propriedade.
- **Atributos Essenciais:** `id` (Chave Primária), `nome` (Nome completo), `cpf` (Documento de identificação com restrição de unicidade), `idCargo` (Chave Estrangeira para CargoFuncionario).
- **Papel no Fluxo Agrícola:** Determina a responsabilidade operacional por cada intervenção agrícola realizada em campo.

### 4.5. Maquina
- **Descrição Funcional:** Cadastro do maquinário agrícola motorizado ou implemento tracionado empregado nas operações.
- **Atributos Essenciais:** `id` (Chave Primária), `modelo` (Identificação do modelo e fabricante), `tipo` (Classificação: trator, colheitadeira, pulverizador), `ano_fabricacao` (Ano de fabricação para depreciação e manutenção).
- **Papel no Fluxo Agrícola:** Rastreia o emprego de mecanização por atividade, viabilizando análises de consumo e alocação de frota.

### 4.6. Insumo
- **Descrição Funcional:** Produto químico, orgânico ou biológico consumido nas lavouras.
- **Atributos Essenciais:** `id` (Chave Primária), `nome` (Nome comercial do produto), `unidade_medida` (Unidade padrão de pesagem ou dosagem: KG, L, SC), `custo_unitario` (Valor unitário de aquisição), `idTipoInsumo` (Chave Estrangeira para TipoInsumo).
- **Papel no Fluxo Agrícola:** Provê os insumos necessários para nutrição e proteção das plantas, constituindo a principal base de custos variáveis operacionais.

### 4.7. AtividadeAgricola
- **Descrição Funcional:** Registro de um evento de manejo executado em um talhão em data determinada.
- **Atributos Essenciais:** `id` (Chave Primária), `data_operacao` (Data da intervenção), `idTalhao` (Chave Estrangeira), `idCultura` (Chave Estrangeira), `idFuncionario` (Chave Estrangeira), `idMaquina` (Chave Estrangeira opcional), `idTipoOperacao` (Chave Estrangeira para TipoOperacao).
- **Papel no Fluxo Agrícola:** Entidade central de auditoria e linha do tempo agronômica, conectando o recurso humano, a máquina, a cultura e a área de cultivo.

### 4.8. AtividadeInsumo
- **Descrição Funcional:** Tabela associativa que detalha o consumo real de insumos alocados a uma atividade de campo.
- **Atributos Essenciais:** `id` (Chave Primária), `idAtividade` (Chave Estrangeira), `idInsumo` (Chave Estrangeira), `quantidade_aplicada` (Massa ou volume aplicado na operação).
- **Papel no Fluxo Agrícola:** Resolve o relacionamento muitos-para-muitos entre operações e materiais, permitindo o cômputo exato da dosagem e a apuração de custos por talhão.

### 4.9. Colheita
- **Descrição Funcional:** Registro do recolhimento da produção agrícola obtida em um talhão ao final do ciclo.
- **Atributos Essenciais:** `id` (Chave Primária), `data_colheita` (Data de encerramento e recolhimento), `quantidade_kg` (Peso líquido colhido em quilogramas), `valor_venda_total` (Valor financeiro bruto comercializado), `idTalhao` (Chave Estrangeira), `idCultura` (Chave Estrangeira).
- **Papel no Fluxo Agrícola:** Fornece as variáveis de saída para cálculo de produtividade física (kg/ha) e retorno econômico (R$/ha).

---

## 5. Regras de Negócio Fundamentais

1. **Dependência Hierárquica Territorial:** Um talhão não pode existir sem estar estritamente associado a uma propriedade cadastrada. A área do talhão deve ser estritamente maior que zero e compatível com os limites da propriedade.
2. **Unicidade de Identificadores Cadastrais:** Não é permitida a duplicação de colaboradores com o mesmo número de CPF, garantindo unicidade no controle de operadores de campo.
3. **Consistência de Intervenção Agrícola:** Toda atividade de campo deve obrigatoriamente referenciar um talhão, uma cultura instalada, um responsável técnico/operacional e um tipo de operação válido. A vinculação de maquinário é facultativa (campo nulo admissível para operações manuais).
4. **Rastreabilidade de Aplicação de Insumos:** O consumo de insumos só pode ser computado caso esteja atrelado a uma atividade agrícola formalmente registrada, sendo obrigatória a especificação de uma quantidade estritamente positiva.
5. **Apontamento de Resultados da Colheita:** O registro de colheita vincula obrigatoriamente o talhão colhido à respectiva cultura, exigindo valores de quantidade colhida e valor de venda não negativos.
6. **Integridade Referencial:** A exclusão de entidades pais (Propriedade, Cultura, Funcionario, Insumo) é bloqueada (`ON DELETE RESTRICT`) caso existam operações ou talhões dependentes, resguardando o histórico operacional da fazenda. A exclusão de uma atividade acarreta a exclusão em cascata (`ON DELETE CASCADE`) dos seus itens de insumos consumidos.
