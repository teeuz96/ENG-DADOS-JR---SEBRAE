create or replace view custom.bi_vw_fato_part_mensal as
select
    ano_mes, -- Ano e mês referência
    cliente, -- Código do cliente
    caso, -- Número do caso (pasta)
    tipo_originacao, -- Descrição do tipo de origem (geração do cliente ou caso)
    gerador, -- Código do advogado gerador
    nomegerador, -- Nome do advogado gerador
    escritorio, -- Sigla do escritório
    nomeescritorio, -- Nome do escritório
    grupo, -- Sigla do grupo (setor)
    nomegrupo, -- Nome do grupo (setor)
    percentual -- Percentual de participação do gerador

-- Subconsulta principal que combina dados de geração do cliente e geração do caso
from (
    -- Primeira parte da subconsulta: Geração do Cliente
    select
        a.ano_mes, -- Ano e mês referência
        to_char(a.cod_cliente) cliente, -- Código do cliente convertido para texto
        to_char(b.pasta) caso, -- Número da pasta convertido para texto
        d.descricao tipo_originacao, -- Descrição do tipo de origem
        a.cod_advg gerador, -- Código do advogado gerador
        c.nome nomegerador, -- Nome do advogado gerador
        e.sigla escritorio, -- Sigla do escritório
        e.nome nomeescritorio, -- Nome do escritório
        f.sigla grupo, -- Sigla do grupo (setor)
        f.nome nomegrupo, -- Nome do grupo (setor)
        a.participacao percentual -- Percentual de participação do gerador
    from
        rcr.mv_partcli_anomes a, -- Tabela de participação de clientes por ano/mês
        rcr.pasta b, -- Tabela de pastas
        rcr.mv_advogado_anomes c, -- Tabela de advogados por ano/mês
        rcr.tipooriginacao d, -- Tabela de tipos de origem
        rcr.escritorio e, -- Tabela de escritórios
        rcr.setor f -- Tabela de setores
    where
        a.cod_cliente = b.cod_cliente -- Junção entre a tabela de participação de clientes e a tabela de pastas
        and a.ano_mes = c.ano_mes -- Junção entre a tabela de participação de clientes e a tabela de advogados
        and a.cod_advg = c.cod_advg -- Junção entre a tabela de participação de clientes e a tabela de advogados
        and a.codtipoorig = d.codigo -- Junção com a tabela de tipos de origem
        and c.escritorio = e.sigla -- Junção com a tabela de escritórios
        and c.escritorio = f.escritorio -- Junção com a tabela de setores
        and c.setor = f.sigla -- Junção com a tabela de setores
        and a.codtipoorig = 3 -- Filtra apenas os registros de geração do cliente (tipo de origem 3)
        and a.ano_mes >= '2017-01' -- Filtra os registros a partir de janeiro de 2017

    -- Combina os resultados com a segunda parte da subconsulta: Geração do Caso
    union all
    select
        a.ano_mes, -- Ano e mês referência
        to_char(a.cod_cliente) cliente, -- Código do cliente convertido para texto
        to_char(a.pasta) caso, -- Número da pasta convertido para texto
        c.descricao tipo_originacao, -- Descrição do tipo de origem
        a.cod_advg gerador, -- Código do advogado gerador
        b.nome nomegerador, -- Nome do advogado gerador
        d.sigla escritorio, -- Sigla do escritório
        d.nome nomeescritorio, -- Nome do escritório
        e.sigla grupo, -- Sigla do grupo (setor)
        e.nome nomegrupo, -- Nome do grupo (setor)
        a.participacao percentual -- Percentual de participação do gerador
    from
        rcr.mv_partpas_anomes a, -- Tabela de participação de pastas por ano/mês
        rcr.mv_advogado_anomes b, -- Tabela de advogados por ano/mês
        rcr.tipooriginacao c, -- Tabela de tipos de origem
        rcr.escritorio d, -- Tabela de escritórios
        rcr.setor e -- Tabela de setores
    where
        a.ano_mes = b.ano_mes -- Junção entre a tabela de participação de pastas e a tabela de advogados
        and a.cod_advg = b.cod_advg -- Junção entre a tabela de participação de pastas e a tabela de advogados
        and a.codtipoorig = c.codigo -- Junção com a tabela de tipos de origem
        and b.escritorio = d.sigla -- Junção com a tabela de escritórios
        and b.escritorio = e.escritorio -- Junção com a tabela de setores
        and b.setor = e.sigla -- Junção com a tabela de setores
        and a.codtipoorig = 4 -- Filtra apenas os registros de geração do caso (tipo de origem 4)
        and a.ano_mes >= '2017-01' -- Filtra os registros a partir de janeiro de 2017

    -- Combina os resultados com a terceira parte da subconsulta: Geração Derivada
    union all
    select
        a.ano_mes, -- Ano e mês referência
        to_char(a.cod_cliente) cliente, -- Código do cliente convertido para texto
        to_char(a.pasta) caso, -- Número da pasta convertido para texto
        c.descricao tipo_originacao, -- Descrição do tipo de origem
        a.cod_advg gerador, -- Código do advogado gerador
        b.nome nomegerador, -- Nome do advogado gerador
        d.sigla escritorio, -- Sigla do escritório
        d.nome nomeescritorio, -- Nome do escritório
        e.sigla grupo, -- Sigla do grupo (setor)
        e.nome nomegrupo, -- Nome do grupo (setor)
        a.participacao percentual -- Percentual de participação do gerador
    from
        rcr.mv_partpas_anomes a, -- Tabela de participação de pastas por ano/mês
        rcr.mv_advogado_anomes b, -- Tabela de advogados por ano/mês
        rcr.tipooriginacao c, -- Tabela de tipos de origem
        rcr.escritorio d, -- Tabela de escritórios
        rcr.setor e -- Tabela de setores
    where
        a.ano_mes = b.ano_mes -- Junção entre a tabela de participação de pastas e a tabela de advogados
        and a.cod_advg = b.cod_advg -- Junção entre a tabela de participação de pastas e a tabela de advogados
        and a.codtipoorig = c.codigo -- Junção com a tabela de tipos de origem
        and b.escritorio = d.sigla -- Junção com a tabela de escritórios
        and b.escritorio = e.escritorio -- Junção com a tabela de setores
        and b.setor = e.sigla -- Junção com a tabela de setores
        and a.codtipoorig = 7 -- Filtra apenas os registros de geração derivada (tipo de origem 7)
        and a.ano_mes >= '2017-01' -- Filtra os registros a partir de janeiro de 2017
) x

-- Filtra os resultados para incluir apenas casos que possuem valores na tabela de faturamento
where exists (
    select 1
    from custom.bi_mv_fato_fat_mensal y -- Tabela de faturamento mensal
    where x.ano_mes = y.ano_mes -- Junção pelo ano/mês
      and x.cliente = y.cliente -- Junção pelo cliente
      and x.caso = y.caso -- Junção pelo caso (pasta)

)

-- Combina os resultados com outra consulta semelhante, mas que filtra com base na tabela de custo
union
select
    ano_mes, cliente, caso, tipo_originacao, gerador, nomegerador,
    escritorio, nomeescritorio, grupo, nomegrupo, percentual
from (
    -- Subconsulta idêntica à primeira, mas com filtro na tabela de custo
    select
        a.ano_mes, to_char(a.cod_cliente) cliente, to_char(b.pasta) caso, d.descricao tipo_originacao,
        a.cod_advg gerador, c.nome nomegerador, e.sigla escritorio, e.nome nomeescritorio,
        f.sigla grupo, f.nome nomegrupo, a.participacao percentual
    from
        rcr.mv_partcli_anomes a, rcr.pasta b, rcr.mv_advogado_anomes c, rcr.tipooriginacao d,
        rcr.escritorio e, rcr.setor f
    where
        a.cod_cliente = b.cod_cliente
        and a.ano_mes = c.ano_mes
        and a.cod_advg = c.cod_advg
        and a.codtipoorig = d.codigo
        and c.escritorio = e.sigla
        and c.escritorio = f.escritorio
        and c.setor = f.sigla
        and a.codtipoorig = 3 -- Geração do Cliente
        and a.ano_mes >= '2017-01'
    union all
    select
        a.ano_mes, to_char(a.cod_cliente) cliente, to_char(a.pasta) caso, c.descricao tipo_originacao,
        a.cod_advg gerador, b.nome nomegerador, d.sigla escritorio, d.nome nomeescritorio,
        e.sigla grupo, e.nome nomegrupo, a.participacao percentual
    from
        rcr.mv_partpas_anomes a, rcr.mv_advogado_anomes b, rcr.tipooriginacao c,
        rcr.escritorio d, rcr.setor e
    where
        a.ano_mes = b.ano_mes
        and a.cod_advg = b.cod_advg
        and a.codtipoorig = c.codigo
        and b.escritorio = d.sigla
        and b.escritorio = e.escritorio
        and b.setor = e.sigla
        and a.codtipoorig = 4 -- Geração do Caso
        and a.ano_mes >= '2017-01'
    union all
    --ADICIONADO CODIGO GERACAO DERIVADA 7 - MAT -
    select
        a.ano_mes, to_char(a.cod_cliente) cliente, to_char(a.pasta) caso, c.descricao tipo_originacao,
        a.cod_advg gerador, b.nome nomegerador, d.sigla escritorio, d.nome nomeescritorio,
        e.sigla grupo, e.nome nomegrupo, a.participacao percentual
    from
        rcr.mv_partpas_anomes a, rcr.mv_advogado_anomes b, rcr.tipooriginacao c,
        rcr.escritorio d, rcr.setor e
    where
        a.ano_mes = b.ano_mes
        and a.cod_advg = b.cod_advg
        and a.codtipoorig = c.codigo
        and b.escritorio = d.sigla
        and b.escritorio = e.escritorio
        and b.setor = e.sigla
        and a.codtipoorig = 7 -- Geração Derivada
        and a.ano_mes >= '2017-01'
) x
where exists (
    select 1
    from custom.bi_mv_fato_custohora y -- Tabela de custo por hora
    where x.ano_mes = y.ano_mes -- Junção pelo ano/mês
      and x.cliente = y.cliente -- Junção pelo cliente
      and x.caso = y.caso -- Junção pelo caso (pasta)

);
