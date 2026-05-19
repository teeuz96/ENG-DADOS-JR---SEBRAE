create or replace view custom.bi_vw_dm_custohora as
select ano_mes, ano_gerencial, categoria, subcategoria, disponibilidade,
       (impostos_venda*100) impostos_venda, round(custo_direto_hora, 2) custo_direto_hora,
       round(comissao_desp_ncob*100, 5) comissao_desp_ncob, round(despesa_hora, 5) despesa_hora,
       round(ocupacao_hora, 5) ocupacao_hora, round(resultado_financeiro*100, 5) resultado_financeiro,
       (impostos_renda*100) impostos_renda
  from custom.bi_db_custohora;
