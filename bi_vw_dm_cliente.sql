create or replace view custom.bi_vw_dm_cliente as
select to_char(a.cod_cliente) cliente, a.razao_social nomecliente, a.socio_responsavel, b.nome nome_socio_responsavel,
       b.escritorio escritorio_socio_resp, g.nome nome_esc_socio_resp, b.setor grupo_socio_resp, h.nome nome_grupo_socio_resp,
       nvl(c.grecdescricao, a.razao_social) grupoempresa, clicsituacao situacao, trunc(a.cliddataabertura) data_abertura, a.cliddataencerramento data_encerramento,
       nvl(d.descricao, 'Não Definido') ramo_atividade, nvl(e.sigla, 'ND') sigla_escritorio, nvl(e.nome, 'Não Definido') nome_escritorio,
       nvl(f.sigla, 'ND') sigla_escritorio_originador, nvl(f.nome, 'Não Definido') nome_escritorio_originador,
       decode(a.cod_cliente, '1002', 'S', 'N') ociosidade,
       a.resp_cobranca sigla_resp_cobranca -- Coluna inserida por ASKDATA em 06/10/2025 para atender aos indicadores do BI Posição de Faturamento
  from rcr.cliente a, rcr.advogado b, rcr.grupoemp c, ssjr.cad_ramoatividade d, rcr.escritorio e, rcr.escritorio f,
       rcr.escritorio g, rcr.setor h
 where a.socio_responsavel = b.cod_advg
   and a.grencodigo = c.grencodigo (+)
   and a.id_ramoatividade = d.id_ramoatividade (+)
   and a.orgncodig = e.orgncodig (+)
   and a.escr_originador = f.orgncodig (+)
   and b.escritorio = g.sigla
   and b.escritorio = h.escritorio
   and b.setor = h.sigla;
