# ENG-DADOS-JR---SEBRAE
# DATA ENGINEERING FOR DATA ANALYSIS

# 📊 Dashboard de Lucratividade Jurídica

> **Case de Portfólio (versão anonimizada)**
>
> Este projeto apresenta um dashboard executivo desenvolvido em Power BI para análise de lucratividade de um escritório jurídico. A solução consolida indicadores financeiros e operacionais em uma única visão gerencial.
>
> Todos os dados, nomes e valores foram substituídos por informações fictícias para preservar a confidencialidade, mantendo a estrutura analítica e as regras de negócio da solução original.

---

## 🎯 Objetivo do Projeto

Disponibilizar uma visão integrada para acompanhar:

- Faturamento e evolução histórica;
- Custos, despesas e impostos;
- Lucro teórico e margem de lucro;
- Desempenho por cliente, cluster e categoria;
- Impacto de descontos e cortes;
- Indicadores operacionais de produtividade.

---

## 🏗️ Arquitetura da Solução

```text
ERP Jurídico (Sisjuri)
        ↓
Consultas SQL e Views Analíticas
        ↓
Modelagem Dimensional (Star Schema)
        ↓
Power BI (DAX + Visualizações)
        ↓
Dashboard Executivo



