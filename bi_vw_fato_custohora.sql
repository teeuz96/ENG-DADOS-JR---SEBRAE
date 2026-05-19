create or replace view custom.bi_vw_fato_custohora as
select a.ano_mes, a.ano_gerencial, c.cod_advg prof, c.escritorio, c.setor grupo, to_char(d.cod_cliente) cliente, to_char(d.pasta) caso,
       nvl(e.cod_advg, 'ESC') gestor_caso, nvl(e.escritorio, 'SP') escritorio_gestor_caso, nvl(e.setor, 'GER') grupo_gestor_caso,
       b.categ_advg cod_categoria, a.categoria, a.subcategoria, a.disponibilidade, f.disponibilidade_real, f.horas_uteis,
       (f.disponibilidade_real/f.horas_uteis)*100 perc_disponibilidade,
       round(nvl(d.tempo_total, 0), 5) tempo_total,
       round(nvl(d.tempo_trab, 0) * (nvl(e.participacao, 100)/100), 5) tempo_trab,
       0 tempo_ocioso,
       round(nvl(d.tempo_trab, 0) * (nvl(e.participacao, 100)/100), 5) tempo_alocado,
       round(a.custo_direto_hora, 5) custo_direto_hora,
       round((a.custo_direto_hora * nvl(d.tempo_trab, 0)) * (nvl(e.participacao, 100)/100),5) custo_direto,
       round(a.despesa_hora, 5) despesa_hora,
       round((a.despesa_hora * nvl(d.tempo_trab, 0)) * (nvl(e.participacao, 100)/100),5) despesa,
       round(a.ocupacao_hora, 5) ocupacao_hora,
       round((a.ocupacao_hora * nvl(d.tempo_trab, 0)) * (nvl(e.participacao, 100)/100),5) ocupacao,
       a.situacao
  from custom.bi_db_custohora a, rcr.catadvg b, rcr.mv_advogado_anomes c,
       (select ano_mes, cod_advg, cod_cliente, pasta, sum(tempo_real/6) tempo_trab,
               sum(sum(tempo_real/6)) over (partition by ano_mes, cod_advg) tempo_total
          from rcr.time_sheet
         where ano_mes >= '2017-01'
           and cod_cliente >= 1000 -- Não serão considerados clientes com numeração igual ou inferior à 999 --adiocionado MATHEUS
         group by ano_mes, cod_advg, cod_cliente, pasta
        having sum(tempo_real) <> 0) d,
       (select c.ano_mes, c.cod_cliente, c.pasta, c.cod_advg, d.escritorio, d.setor, c.participacao
          from rcr.mv_partpas_anomes c, rcr.mv_advogado_anomes d
         where c.ano_mes = d.ano_mes
           and c.cod_advg = d.cod_advg
           and c.codtipoorig = 6) e,
       custom.bi_mv_dm_disponibilidade f
 where a.categoria = b.descricao
   and a.ano_mes = c.ano_mes
   and b.categ_advg = c.categoria
   and c.ano_mes = d.ano_mes (+)
   and c.cod_advg = d.cod_advg (+)
   and d.ano_mes = e.ano_mes (+)
   and d.cod_cliente = e.cod_cliente (+)
   and d.pasta = e.pasta (+)
   and a.ano_mes = f.ano_mes
   and c.cod_advg = f.prof
   and b.status = 'A' -- Apenas categorias ativas
   and d.tempo_total <> 0
   and f.disponibilidade_real <> 0
union all
select a.ano_mes, a.ano_gerencial, c.cod_advg prof, c.escritorio, c.setor grupo, to_char(e.cod_cliente) cliente, to_char(e.pasta) caso,
       nvl(f.cod_advg, 'ESC') gestor_caso, nvl(f.escritorio, 'SP') escritorio_gestor_caso, nvl(f.setor, 'GER') grupo_gestor_caso,
       b.categ_advg cod_categoria, a.categoria, a.subcategoria, a.disponibilidade, g.disponibilidade_real, g.horas_uteis,
       (g.disponibilidade_real/g.horas_uteis)*100 perc_disponibilidade,
       round(nvl(d.tempo_total, 0), 5) tempo_total,
       0 tempo_trab,
       round(decode(g.horas_uteis, g.disponibilidade_real, a.disponibilidade, least(g.disponibilidade_real, a.disponibilidade))-nvl(d.tempo_total, 0), 5) tempo_ocioso,
       round(decode(g.horas_uteis, g.disponibilidade_real, a.disponibilidade, least(g.disponibilidade_real, a.disponibilidade))-nvl(d.tempo_total, 0), 5) tempo_alocado,
       round(a.custo_direto_hora, 5) custo_direto_hora,
       round((a.custo_direto_hora * (decode(g.horas_uteis, g.disponibilidade_real, a.disponibilidade, least(g.disponibilidade_real, a.disponibilidade))-nvl(d.tempo_total, 0))) * (nvl(f.participacao, 100)/100),5) custo_direto,
       round(a.despesa_hora, 5) despesa_hora,
       round((a.despesa_hora * (decode(g.horas_uteis, g.disponibilidade_real, a.disponibilidade, least(g.disponibilidade_real, a.disponibilidade))-nvl(d.tempo_total, 0))) * (nvl(f.participacao, 100)/100),5) despesa,
       round(a.ocupacao_hora, 5) ocupacao_hora,
       round((a.ocupacao_hora * (decode(g.horas_uteis, g.disponibilidade_real, a.disponibilidade, least(g.disponibilidade_real, a.disponibilidade))-nvl(d.tempo_total, 0))) * (nvl(f.participacao, 100)/100),5) ocupacao,
       a.situacao
  from custom.bi_db_custohora a, rcr.catadvg b, rcr.mv_advogado_anomes c,
       (select ano_mes, cod_advg, sum(sum(tempo_real/6)) over (partition by ano_mes, cod_advg) tempo_total
          from rcr.time_sheet
         where ano_mes >= '2017-01'
           and cod_cliente >= 1000 -- Não serão considerados clientes com numeração igual ou inferior à 999
         group by ano_mes, cod_advg
        having sum(tempo_real) <> 0) d, rcr.pasta e,
       (select c.ano_mes, c.cod_cliente, c.pasta, c.cod_advg, d.escritorio, d.setor, c.participacao
          from rcr.mv_partpas_anomes c, rcr.mv_advogado_anomes d
         where c.ano_mes = d.ano_mes
           and c.cod_advg = d.cod_advg
           and c.codtipoorig = 6) f,
       custom.bi_mv_dm_disponibilidade g
 where a.categoria = b.descricao
   and a.ano_mes = c.ano_mes
   and b.categ_advg = c.categoria
   and c.ano_mes = d.ano_mes (+)
   and c.cod_advg = d.cod_advg (+)
   and a.ano_mes = f.ano_mes (+)
   and e.cod_cliente = f.cod_cliente
   and e.pasta = f.pasta
   and a.ano_mes = g.ano_mes
   and c.cod_advg = g.prof
   and b.status = 'A' -- Apenas categorias ativas
   and e.cod_cliente = '1002' and e.pasta = '1' -- 1002/1 - Cliente/Caso de Ociosidade
   and g.disponibilidade_real <> 0;
