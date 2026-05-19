create or replace view custom.bi_vw_fato_fat_mensal as
select ano_mes, cliente, caso, prof, escritorio, grupo, categoria, gestor_caso, escritorio_gestor_caso, grupo_gestor_caso,
       sum(qtd_horas_debitadas) qtd_horas_debitadas, sum(qtd_horas_antes_wo) qtd_horas_antes_wo,
       sum(qtd_horas_wo) qtd_horas_wo, sum(qtd_horas_depois_wo) qtd_horas_depois_wo,
       sum(qtd_horas_cortadas) qtd_horas_cortadas, sum(qtd_horas_faturadas) qtd_horas_faturadas,
       sum(vl_fat_tab_caso) vl_fat_tab_caso, sum(vl_fat_tab_padrao) vl_fat_tab_padrao, sum(vl_fat_tab_aux) vl_fat_tab_aux,
       sum(vl_corte_tab_caso) vl_corte_tab_caso, sum(vl_corte_tab_padrao) vl_corte_tab_padrao, sum(vl_corte_tab_aux) vl_corte_tab_aux,
       sum(vl_wo_tab_caso) vl_wo_tab_caso, sum(vl_wo_tab_padrao) vl_wo_tab_padrao, sum(vl_wo_tab_aux) vl_wo_tab_aux,
       sum(vl_fat_dc_tab_caso) vl_fat_dc_tab_caso, sum(vl_fat_dc_tab_padrao) vl_fat_dc_tab_padrao, sum(vl_fat_dc_tab_aux) vl_fat_dc_tab_aux,
       sum(vl_faturado) vl_faturado, sum(vl_impostos_venda) vl_impostos_venda, sum(vl_comissao_desp_ncob) vl_comissao_desp_ncob,
       sum(vl_resultado_financeiro) vl_resultado_financeiro, sum(vl_impostos_renda) vl_impostos_renda
  from (
        -- Base de Horas Faturadas
        select a.ano_mes, to_char(a.cod_cliente) cliente, to_char(a.pasta) caso, a.cod_advg prof, b.escritorio, b.setor grupo, b.categoria,
               nvl(c.cod_advg, 'ESC') gestor_caso, nvl(c.escritorio, 'SP') escritorio_gestor_caso, nvl(c.setor, 'GER') grupo_gestor_caso,
               round(sum(a.tempo_debit/6) * (nvl(c.participacao, 100)/100), 5) qtd_horas_debitadas,
               round(sum(a.tempo_real/6+a.tempo_realwo/6) * (nvl(c.participacao, 100)/100), 5) qtd_horas_antes_wo,
               round(sum(a.tempo_realwo/6) * (nvl(c.participacao, 100)/100), 5) qtd_horas_wo,
               round(sum(a.tempo_real/6) * (nvl(c.participacao, 100)/100), 5) qtd_horas_depois_wo,
               round(sum(a.aprimoramento/6) * (nvl(c.participacao, 100)/100), 5) qtd_horas_cortadas,
               round(sum(a.tempo_fatu/6) * (nvl(c.participacao, 100)/100), 5) qtd_horas_faturadas,
               round(sum(a.valorcaso+a.valorcasowo) * (nvl(c.participacao, 100)/100), 5) vl_fat_tab_caso,
               round(sum(a.valorpadrao+a.valorpawo) * (nvl(c.participacao, 100)/100), 5) vl_fat_tab_padrao,
               round(sum(a.valoraux+a.valorauxwo) * (nvl(c.participacao, 100)/100), 5) vl_fat_tab_aux,
               round(sum(a.valorcasocorte) * (nvl(c.participacao, 100)/100), 5) vl_corte_tab_caso,
               round(sum(a.valorpacorte) * (nvl(c.participacao, 100)/100), 5) vl_corte_tab_padrao,
               round(sum(a.valorauxcorte) * (nvl(c.participacao, 100)/100), 5) vl_corte_tab_aux,
               round(sum(a.valorcasowo) * (nvl(c.participacao, 100)/100), 5) vl_wo_tab_caso,
               round(sum(a.valorpawo) * (nvl(c.participacao, 100)/100), 5) vl_wo_tab_padrao,
               round(sum(a.valorauxwo) * (nvl(c.participacao, 100)/100), 5) vl_wo_tab_aux,
               0 vl_fat_dc_tab_caso, 0 vl_fat_dc_tab_padrao, 0 vl_fat_dc_tab_aux,
               0 vl_faturado, 0 vl_impostos_venda, 0 vl_comissao_desp_ncob,
               0 vl_resultado_financeiro, 0 vl_impostos_renda
          from custom.bi_mv_base_horas_fat a, rcr.mv_advogado_anomes b,
               (select c.ano_mes, c.cod_cliente, c.pasta, c.cod_advg, d.escritorio, d.setor, c.participacao
                  from rcr.mv_partpas_anomes c, rcr.mv_advogado_anomes d
                 where c.ano_mes = d.ano_mes
                   and c.cod_advg = d.cod_advg
                   and c.codtipoorig = 6) c
         where a.ano_mes = b.ano_mes
           and a.cod_advg = b.cod_advg
           and a.ano_mes = c.ano_mes (+)
           and a.cod_cliente = c.cod_cliente (+)
           and a.pasta = c.pasta (+)
           and a.ano_mes >= '2017-01' -- Data de Corte
         group by a.ano_mes, a.cod_cliente, a.pasta, a.cod_advg, b.escritorio, b.setor, b.categoria, nvl(c.cod_advg, 'ESC'),
            c.escritorio, c.setor, nvl(c.participacao, 100)
        union all
        -- Base de Horas com Desconto Comercial (DC)
        select a.ano_mes, to_char(a.cod_cliente) cliente, to_char(a.pasta) caso, a.cod_advg prof, b.escritorio, b.setor grupo, b.categoria,
               nvl(c.cod_advg, 'ESC') gestor_caso, nvl(c.escritorio, 'SP') escritorio_gestor_caso, nvl(c.setor, 'GER') grupo_gestor_caso,
               0 qtd_horas_debitadas, 0 qtd_horas_antes_wo, 0 qtd_horas_wo, 0 qtd_horas_depois_wo,
               0 qtd_horas_cortadas, 0 qtd_horas_faturadas,
               0 vl_fat_tab_caso, 0 vl_fat_tab_padrao, 0 vl_fat_tab_aux,
               0 vl_corte_tab_caso, 0 vl_corte_tab_padrao, 0 vl_corte_tab_aux,
               0 vl_wo_tab_caso, 0 vl_wo_tab_padrao, 0 vl_wo_tab_aux,
               round(sum(a.valorcaso+a.valorcasowo) * (nvl(c.participacao, 100)/100), 5) vl_fat_dc_tab_caso,
               round(sum(a.valorpadrao+a.valorpawo) * (nvl(c.participacao, 100)/100), 5) vl_fat_dc_tab_padrao,
               round(sum(a.valoraux+a.valorauxwo) * (nvl(c.participacao, 100)/100), 5) vl_fat_dc_tab_aux,
               0 vl_faturado, 0 vl_impostos_venda, 0 vl_comissao_desp_ncob, 0 vl_resultado_financeiro, 0 vl_impostos_renda
          from custom.bi_mv_base_horas_dc a, rcr.mv_advogado_anomes b,
               (select c.ano_mes, c.cod_cliente, c.pasta, c.cod_advg, d.escritorio, d.setor, c.participacao
                  from rcr.mv_partpas_anomes c, rcr.mv_advogado_anomes d
                 where c.ano_mes = d.ano_mes
                   and c.cod_advg = d.cod_advg
                   and c.codtipoorig = 6) c
         where a.ano_mes = b.ano_mes
           and a.cod_advg = b.cod_advg
           and a.ano_mes = c.ano_mes (+)
           and a.cod_cliente = c.cod_cliente (+)
           and a.pasta = c.pasta (+)
           and a.ano_mes >= '2017-01' -- Data de Corte
         group by a.ano_mes, a.cod_cliente, a.pasta, a.cod_advg, b.escritorio, b.setor, b.categoria, nvl(c.cod_advg, 'ESC'),
            c.escritorio, c.setor, nvl(c.participacao, 100)
        union all
        -- Valores não alocados (Faturamento)
        select a.ano_mes, to_char(a.cod_cliente) cliente, to_char(a.pasta) caso, a.cod_advg prof, nvl(c.escritorio, 'SP') escritorio, nvl(c.setor, 'GER') grupo, 'ADM' categoria,
               nvl(c.cod_advg, 'ESC') gestor_caso, nvl(c.escritorio, 'SP') escritorio_gestor_caso, nvl(c.setor, 'GER') grupo_gestor_caso,
               0 qtd_horas_debitadas, 0 qtd_horas_antes_wo, 0 qtd_horas_wo, 0 qtd_horas_depois_wo,
               0 qtd_horas_cortadas, 0 qtd_horas_faturadas, 0 vl_fat_tab_caso, 0 vl_fat_tab_padrao, 0 vl_fat_tab_aux,
               0 vl_corte_tab_caso, 0 vl_corte_tab_padrao, 0 vl_corte_tab_aux,
               0 vl_wo_tab_caso, 0 vl_wo_tab_padrao, 0 vl_wo_tab_aux,
               0 vl_fat_dc_tab_caso, 0 vl_fat_dc_tab_padrao, 0 vl_fat_dc_tab_aux,
               round(sum(a.valor) * (nvl(c.participacao, 100)/100), 5) vl_faturado,
               round(sum(a.valor) * (nvl(c.participacao, 100)/100) * b.impostos_venda, 5) vl_impostos_venda,
               round(sum(a.valor) * (nvl(c.participacao, 100)/100) * b.comissao_desp_ncob, 5) vl_comissao_desp_ncob,
               round(sum(a.valor) * (nvl(c.participacao, 100)/100) * b.resultado_financeiro, 5) vl_resultado_financeiro,
               round(sum(a.valor) * (nvl(c.participacao, 100)/100) * b.impostos_renda, 5) vl_impostos_renda
          from rcr.fat_alocacao a,
               (select a.ano_mes, b.categ_advg categoria, a.impostos_venda/100 impostos_venda, a.comissao_desp_ncob/100 comissao_desp_ncob,
                       a.resultado_financeiro/100 resultado_financeiro, a.impostos_renda/100 impostos_renda
                  from custom.bi_db_custohora a, rcr.catadvg b
                 where a.categoria = b.descricao
                   and b.status = 'A') b,
               (select c.ano_mes, c.cod_cliente, c.pasta, c.cod_advg, d.escritorio, d.setor, d.categoria, c.participacao
                  from rcr.mv_partpas_anomes c, rcr.mv_advogado_anomes d
                 where c.ano_mes = d.ano_mes
                   and c.cod_advg = d.cod_advg
                   and c.codtipoorig = 6) c
         where a.ano_mes = c.ano_mes (+)
           and a.cod_cliente = c.cod_cliente (+)
           and a.pasta = c.pasta (+)
           and a.ano_mes = b.ano_mes
           and nvl(c.categoria, 'ADM') = b.categoria
           and a.cod_advg = 'ESC' -- Movimentar valores não alocados para o gestor do caso
           and a.ano_mes >= '2017-01' -- Data de Corte
         group by a.ano_mes, a.cod_cliente, a.pasta, a.cod_advg, nvl(c.cod_advg, 'ESC'), nvl(c.escritorio, 'SP'),
           nvl(c.setor, 'GER'), nvl(c.participacao, 100), b.impostos_venda, b.comissao_desp_ncob,
           b.resultado_financeiro, b.impostos_renda
        union all
        -- Valores alocados (Faturamento)
        select a.ano_mes, to_char(a.cod_cliente) cliente, to_char(a.pasta) caso, a.cod_advg prof, b.escritorio, b.setor grupo, b.categoria,
               nvl(c.cod_advg, 'ESC') gestor_caso, nvl(c.escritorio, 'SP') escritorio_gestor_caso, nvl(c.setor, 'GER') grupo_gestor_caso,
               0 qtd_horas_debitadas, 0 qtd_horas_antes_wo, 0 qtd_horas_wo, 0 qtd_horas_depois_wo,
               0 qtd_horas_cortadas, 0 qtd_horas_faturadas, 0 vl_fat_tab_caso, 0 vl_fat_tab_padrao, 0 vl_fat_tab_aux,
               0 vl_corte_tab_caso, 0 vl_corte_tab_padrao, 0 vl_corte_tab_aux,
               0 vl_wo_tab_caso, 0 vl_wo_tab_padrao, 0 vl_wo_tab_aux,
               0 vl_fat_dc_tab_caso, 0 vl_fat_dc_tab_padrao, 0 vl_fat_dc_tab_aux,
               round(sum(a.valor) * (nvl(c.participacao, 100)/100), 5) vl_faturado,
               round(sum(a.valor) * (nvl(c.participacao, 100)/100) * d.impostos_venda, 5) vl_impostos_venda,
               round(sum(a.valor) * (nvl(c.participacao, 100)/100) * d.comissao_desp_ncob, 5) vl_comissao_desp_ncob,
               round(sum(a.valor) * (nvl(c.participacao, 100)/100) * d.resultado_financeiro, 5) vl_resultado_financeiro,
               round(sum(a.valor) * (nvl(c.participacao, 100)/100) * d.impostos_renda, 5) vl_impostos_renda
          from rcr.fat_alocacao a, rcr.mv_advogado_anomes b,
               (select c.ano_mes, c.cod_cliente, c.pasta, c.cod_advg, d.escritorio, d.setor, c.participacao
                  from rcr.mv_partpas_anomes c, rcr.mv_advogado_anomes d
                 where c.ano_mes = d.ano_mes
                   and c.cod_advg = d.cod_advg
                   and c.codtipoorig = 6) c,
               (select a.ano_mes, b.categ_advg categoria, a.impostos_venda/100 impostos_venda, a.comissao_desp_ncob/100 comissao_desp_ncob,
                       a.resultado_financeiro/100 resultado_financeiro, a.impostos_renda/100 impostos_renda
                  from custom.bi_db_custohora a, rcr.catadvg b
                 where a.categoria = b.descricao
                   and b.status = 'A') d
         where a.ano_mes = b.ano_mes
           and a.cod_advg = b.cod_advg
           and a.ano_mes = c.ano_mes (+)
           and a.cod_cliente = c.cod_cliente (+)
           and a.pasta = c.pasta (+)
           and a.ano_mes = d.ano_mes
           and b.categoria = d.categoria
           and a.cod_advg <> 'ESC'
           and a.ano_mes >= '2017-01' -- Data de Corte
         group by a.ano_mes, a.cod_cliente, a.pasta, a.cod_advg, b.escritorio, b.setor, b.categoria, nvl(c.cod_advg, 'ESC'),
            c.escritorio, c.setor, nvl(c.participacao, 100), d.impostos_venda, d.comissao_desp_ncob, d.resultado_financeiro, d.impostos_renda
     )
 group by ano_mes, cliente, caso, prof, escritorio, grupo, categoria, gestor_caso, escritorio_gestor_caso, grupo_gestor_caso;
