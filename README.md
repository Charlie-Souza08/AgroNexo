# AgroNexo — Gestão de Fazenda

O **AgroNexo** é um projeto de banco de dados relacional para controle de propriedades rurais, talhões, culturas, funcionários, máquinas, insumos, atividades agrícolas e colheitas. A solução centraliza dados operacionais e permite analisar custos, produtividade, utilização de recursos e rastreabilidade das operações de campo.

## Participantes

- Italo Yan Mendes da Silva
- Hellen Verena da Conceição Magalhães
- Heitor Sales Souza

## Tecnologias

- PostgreSQL
- SQL para definição de dados (DDL)
- SQL para manipulação de dados (DML)
- SQL para consultas relacionais (DQL)

## Organização do repositório

```text
AgroNexo/
├── README.md
└── sql/
    ├── ddl/
    │   └── 01_estrutura.sql
    ├── dml/
    │   └── 02_dados.sql
    └── dql/
        └── 03_consultas_relacionais.sql
```

| Diretório | Conteúdo |
|---|---|
| `sql/ddl` | Criação das tabelas, restrições, relacionamentos e índices. |
| `sql/dml` | Carga determinística dos dados usados na demonstração. |
| `sql/dql` | As 20 consultas relacionais solicitadas no trabalho. |

Os arquivos possuem prefixos numéricos que indicam a ordem de execução.

## Como executar

### Pré-requisito

É necessário ter o PostgreSQL instalado e um banco de dados disponível. O exemplo abaixo considera um banco chamado `agronexo`.

```bash
createdb agronexo
psql -d agronexo -f sql/ddl/01_estrutura.sql
psql -d agronexo -f sql/dml/02_dados.sql
psql -d agronexo -f sql/dql/03_consultas_relacionais.sql
```

Também é possível abrir os arquivos no pgAdmin e executá-los, na mesma ordem, por meio da ferramenta de consulta.

> O arquivo DDL remove e recria as tabelas do projeto. Não deve ser executado em um banco que contenha dados que precisem ser preservados.

## Modelo de dados

O banco é composto pelas seguintes entidades:

| Entidade | Finalidade |
|---|---|
| `Propriedade` | Identifica a unidade rural e sua área total. |
| `Talhao` | Representa uma subdivisão produtiva da propriedade. |
| `Cultura` | Cataloga as culturas e seus ciclos médios. |
| `CargoFuncionario` | Classifica os cargos da equipe de campo. |
| `Funcionario` | Identifica o responsável pelas operações agrícolas. |
| `Maquina` | Mantém os equipamentos utilizados nas atividades. |
| `TipoInsumo` | Classifica fertilizantes, defensivos e sementes. |
| `Insumo` | Registra produtos, unidades de medida e custos. |
| `TipoOperacao` | Classifica os tipos de atividade agrícola. |
| `AtividadeAgricola` | Registra uma operação realizada em um talhão. |
| `AtividadeInsumo` | Relaciona os insumos consumidos por uma atividade. |
| `Colheita` | Registra quantidade produzida e receita de venda. |

### Relacionamentos principais

- Uma propriedade possui um ou mais talhões.
- Um funcionário pertence a um cargo.
- Um insumo pertence a um tipo de insumo.
- Uma atividade está vinculada a talhão, cultura, funcionário e tipo de operação.
- A máquina é opcional em uma atividade, permitindo registrar operações manuais.
- Uma atividade pode consumir vários insumos, e um insumo pode participar de várias atividades.
- Uma colheita relaciona o resultado produtivo a um talhão e a uma cultura.

## Regras de negócio implementadas

- Todas as chaves primárias utilizam `INT` e são informadas explicitamente na carga.
- Áreas, quantidades aplicadas e quantidades colhidas devem ser maiores que zero.
- O valor de venda e o custo unitário não podem ser negativos.
- CPF, código do talhão, nome da cultura e nome do insumo são únicos.
- A unidade de medida do insumo é limitada a `KG`, `L` ou `SC`.
- Uma combinação de atividade e insumo não pode ser repetida.
- A exclusão de uma atividade remove seus itens de insumo em cascata.
- A exclusão de entidades que sustentam o histórico operacional é restringida.
- A exclusão de uma máquina preserva a atividade e define sua referência como nula.
- As chaves estrangeiras usadas nas consultas possuem índices dedicados.

## Massa de dados

A carga DML é determinística: não utiliza valores aleatórios e produz o mesmo cenário a cada execução. Ela contém casos preparados para validar as consultas, incluindo:

- insumos nunca utilizados;
- talhões sem colheita;
- talhões com histórico de múltiplas culturas;
- atividades manuais sem máquina;
- máquinas com mais de dez atividades;
- máquinas sem atividade recente ou nunca utilizadas.

## Consultas relacionais

O arquivo `sql/dql/03_consultas_relacionais.sql` contém:

1. Custo de insumos por cultura.
2. Produtividade física por talhão.
3. Insumos nunca utilizados.
4. Desempenho de máquinas com mais de 10 atividades.
5. Receita bruta por propriedade.
6. Custo de insumos por talhão.
7. Funcionários com maior número de operações.
8. Produtividade média por cultura.
9. Talhões sem colheita.
10. Consumo de sementes por hectare.
11. Gasto com defensivos por propriedade.
12. Rentabilidade estimada por cultura.
13. Máquinas sem atividade nos últimos 30 dias.
14. Quantidade de insumos por tipo de operação.
15. Área plantada por cultura.
16. Custo médio de aplicação por tipo de insumo.
17. Os cinco insumos com maior gasto total.
18. Talhões com histórico de múltiplas culturas.
19. Produtividade financeira por talhão.
20. Relatório de rastreabilidade das atividades.

As consultas demonstram o uso de `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `GROUP BY`, `HAVING`, funções de agregação, expressões de tabela comuns (`WITH`) e ordenação de resultados.

## Nome do repositório

O nome **AgroNexo** foi revisado e mantido porque é curto, descritivo e coerente com o domínio do projeto: a integração das informações operacionais de uma propriedade agrícola.
