create or replace view custom.bi_vw_dm_disponibilidade as
select ano_mes, prof, nomeprof, escritorio, grupo, categoria, data_entrada, data_saida, horas_dia, agrupamentoprof, dias_uteis, horas_uteis, disponibilidade_real,
       tempos_complementares, (disponibilidade_real-tempos_complementares) disponibilidade_final
  from (
        select a.ano_mes, a.cod_advg prof, a.nome nomeprof, a.escritorio, a.setor grupo, a.categoria, a.data_entrada, a.data_saida, a.horas_dia,
               (case
                 when a.ano_mes >= to_char(a.data_saida, 'yyyy-mm') then
                   nvl(ssjr.cad_fn_campocustomizadovalor('56', a.cod_advg, '107679792'), a.cod_advg)
                 when a.cod_advg like '%1%' then
                   nvl(ssjr.cad_fn_campocustomizadovalor('56', a.cod_advg, '107679792'), a.cod_advg)
                 else
                   a.cod_advg
                end) agrupamentoprof,
               custom.fn_diasuteis (to_date(ano_mes||'-01','yyyy-mm-dd'), last_day(to_date(ano_mes||'-01','yyyy-mm-dd')), a.ano_mes, a.escritorio) dias_uteis,
               custom.fn_diasuteis (to_date(ano_mes||'-01','yyyy-mm-dd'), last_day(to_date(ano_mes||'-01','yyyy-mm-dd')), a.ano_mes, a.escritorio) * a.horas_dia horas_uteis,
               case
                   when custom.fn_diasuteis (to_date(ano_mes||'-01','yyyy-mm-dd'), last_day(to_date(ano_mes||'-01','yyyy-mm-dd')), a.ano_mes, a.escritorio)-
                        custom.fn_advgentrasai (to_date(ano_mes||'-01','yyyy-mm-dd'), last_day(to_date(ano_mes||'-01','yyyy-mm-dd')), a.ano_mes, a.cod_advg,a.escritorio) < 0 then 0
                   else custom.fn_diasuteis (to_date(ano_mes||'-01','yyyy-mm-dd'), last_day(to_date(ano_mes||'-01','yyyy-mm-dd')), a.ano_mes, a.escritorio)-
                        custom.fn_advgentrasai (to_date(ano_mes||'-01','yyyy-mm-dd'), last_day(to_date(ano_mes||'-01','yyyy-mm-dd')), a.ano_mes, a.cod_advg,a.escritorio)
               end * horas_dia disponibilidade_real,
               (select nvl(sum(b.tempo_real/6), 0)
                  from rcr.time_sheet b
                 where cod_cliente = 1
                   and pasta in (3, 4, 5)
                   and a.cod_advg = b.cod_advg
                   and a.ano_mes = b.ano_mes) tempos_complementares
          from rcr.mv_advogado_anomes a
         where a.ano_mes >= '2017-01'
           and a.horas_dia <> 0
       )
  where disponibilidade_real <> 0;
