create or replace view custom.bi_vw_dm_caso as
select
    a.ano_mes, -- Ano e mês referência
    to_char(a.cod_cliente) cliente, -- Código do cliente convertido para texto
    to_char(a.pasta) caso, -- Número da pasta convertido para texto
    b.titulo nomecaso, -- Título do caso
    b.situacao, -- Situação do caso
    trunc(b.data_abertura) data_abertura, -- Data de abertura do caso, truncada para remover a hora
    trunc(b.data_encerramento) data_encerramento, -- Data de encerramento do caso, truncada para remover a hora
    nvl(c.sigla, 'ND') area, -- Sigla da área, ou 'ND' se for nula
    nvl(c.nome, 'Não Definido') nomearea, -- Nome da área, ou 'Não Definido' se for nulo
    nvl(d.sigla, 'ND') subarea, -- Sigla da subárea, ou 'ND' se for nula
    nvl(d.descricao, 'Não Definido') nomesubarea, -- Descrição da subárea, ou 'Não Definido' se for nula
    a.socio_responsavel, -- Código do sócio responsável
    e.nome nome_socio_responsavel, -- Nome do sócio responsável
    f.sigla sigla_esc_soc_resp, -- Sigla do escritório do sócio responsável
    f.nome nome_esc_soc_resp, -- Nome do escritório do sócio responsável
    nvl(b.descpadrao, 0) desconto_padrao, -- Desconto padrão, ou 0 se for nulo
    h.tabela, -- Tabela de honorários
    h.observacao nometabela, -- Nome da tabela de honorários
    nvl(i.descricao, 'ND') tipo_honorario, -- Descrição do tipo de honorário, ou 'ND' se for nula
    nvl(j.gestores_caso, 'ND') gestores_caso, -- Lista de gestores do caso, ou 'ND' se for nula
    nvl(k.geradores_caso, 'ND') geradores_caso, -- Lista de geradores do caso, ou 'ND' se for nula
    nvl(l.geradores_cliente, 'ND') geradores_cliente, -- Lista de geradores do cliente, ou 'ND' se for nula
    nvl(m.geracao_derivada, 'ND') geracao_derivada -- Lista de geradores de caso novo, ou 'ND' se for nula -- MAT

-- Tabelas principais e subconsultas
from
    rcr.mv_pasta_anomes a, -- Tabela de pastas por ano/mês
    rcr.pasta b, -- Tabela de pastas
    rcr.area c, -- Tabela de áreas
    ssjr.cad_subarea d, -- Tabela de subáreas
    rcr.mv_advogado_anomes e, -- Tabela de advogados por ano/mês
    rcr.escritorio f, -- Tabela de escritórios
    rcr.setor g, -- Tabela de setores
    rcr.tabhonor h, -- Tabela de honorários
    ssjr.cad_tipohonorario i, -- Tabela de tipos de honorários

    -- Subconsulta para obter os gestores do caso
    (select
        ano_mes,
        cod_cliente cliente,
        pasta caso,
        listagg(cod_advg, '/') within group (order by ano_mes, cod_cliente, cod_advg) gestores_caso
     from rcr.mv_partpas_anomes
     where codtipoorig = 6 -- Filtra por tipo de origem 6 (gestores)
       and ano_mes >= '2017-01' -- Filtra por ano/mês a partir de julho de 2024
     group by ano_mes, cod_cliente, pasta) j, -- Agrupa por ano/mês, cliente e pasta

    -- Subconsulta para obter os geradores do caso
    (select
        ano_mes,
        cod_cliente cliente,
        pasta caso,
        listagg(cod_advg, '/') within group (order by ano_mes, cod_cliente, cod_advg) geradores_caso
     from rcr.mv_partpas_anomes
     where codtipoorig = 4 -- Filtra por tipo de origem 4 (geradores)
       and ano_mes >= '2017-01' -- Filtra por ano/mês a partir de julho de 2024
     group by ano_mes, cod_cliente, pasta) k, -- Agrupa por ano/mês, cliente e pasta

    -- Subconsulta para obter os geradores do cliente
    (select
        ano_mes,
        cod_cliente cliente,
        listagg(cod_advg, '/') within group (order by ano_mes, cod_cliente, cod_advg) geradores_cliente
     from rcr.mv_partcli_anomes
     where codtipoorig = 3 -- Filtra por tipo de origem 3 (geradores do cliente)
       and ano_mes >= '2017-01' -- Filtra por ano/mês a partir de julho de 2024
     group by ano_mes, cod_cliente) l, -- Agrupa por ano/mês e cliente

--ADICIONADO POR MAT--
    -- Subconsulta para obter geracao_derivada
    (select
        ano_mes,
        cod_cliente cliente,
        pasta caso,
        listagg(cod_advg, '/') within group (order by ano_mes, cod_cliente, cod_advg) geracao_derivada
     from rcr.mv_partpas_anomes
     where codtipoorig = 7 -- Filtra por tipo de origem 7 (geradores derivados)
       and ano_mes >= '2017-01' -- Filtra por ano/mês a partir de julho de 2024
     group by ano_mes, cod_cliente, pasta) m -- Agrupa por ano/mês, cliente e pasta

-- Condições de junção (JOIN) entre as tabelas
where
    a.cod_cliente = b.cod_cliente -- Junção entre a tabela de pastas por ano/mês e a tabela de pastas
    and a.pasta = b.pasta -- Junção entre a tabela de pastas por ano/mês e a tabela de pastas
    and a.id_area = c.sigla (+) -- Junção externa com a tabela de áreas (LEFT JOIN)
    and a.tipo = c.tipo (+) -- Junção externa com a tabela de áreas (LEFT JOIN)
    and a.id_subarea = d.id_subarea (+) -- Junção externa com a tabela de subáreas (LEFT JOIN)
    and a.ano_mes = e.ano_mes -- Junção com a tabela de advogados por ano/mês
    and a.socio_responsavel = e.cod_advg -- Junção com a tabela de advogados por ano/mês
    and e.escritorio = f.sigla -- Junção com a tabela de escritórios
    and e.escritorio = g.escritorio -- Junção com a tabela de setores
    and e.setor = g.sigla -- Junção com a tabela de setores
    and a.tabela = h.tabela -- Junção com a tabela de honorários
    and b.id_tipohonorario = i.id_tipohonorario (+) -- Junção externa com a tabela de tipos de honorários (LEFT JOIN)
    and a.ano_mes = j.ano_mes (+) -- Junção externa com a subconsulta de gestores do caso (LEFT JOIN)
    and a.cod_cliente = j.cliente (+) -- Junção externa com a subconsulta de gestores do caso (LEFT JOIN)
    and a.pasta = j.caso (+) -- Junção externa com a subconsulta de gestores do caso (LEFT JOIN)
    and a.ano_mes = k.ano_mes (+) -- Junção externa com a subconsulta de geradores do caso (LEFT JOIN)
    and a.cod_cliente = k.cliente (+) -- Junção externa com a subconsulta de geradores do caso (LEFT JOIN)
    and a.pasta = k.caso (+) -- Junção externa com a subconsulta de geradores do caso (LEFT JOIN)
    and a.ano_mes = l.ano_mes (+) -- Junção externa com a subconsulta de geradores do cliente (LEFT JOIN)
    and a.cod_cliente = l.cliente (+) -- Junção externa com a subconsulta de geradores do cliente (LEFT JOIN)
--TESTE MAT--
    and a.ano_mes = m.ano_mes (+) -- Junção externa com a subconsulta de geradores derivados do caso (LEFT JOIN)
    and a.cod_cliente = m.cliente (+) -- Junção externa com a subconsulta de geradores derivados do caso (LEFT JOIN)
    and a.pasta = m.caso (+) -- Junção externa com a subconsulta de geradores derivados do caso (LEFT JOIN)
    and a.ano_mes >= '2017-01';
