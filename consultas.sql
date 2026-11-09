create view biblioteca_detalhada as
select
    c.id_conta,
    c.username,
    j.id_jogo,
    j.titulo,
    j.preco,
    d.nomed as desenvolvedora,
    b.horas_jogadas,
    b.ultima_sessao
from biblioteca b
join conta c on b.id_conta = c.id_conta
join jogo j on b.id_jogo = j.id_jogo
join desenvolvedora d on j.id_desenvolvedora = d.id_desenvolvedora;


-- =====================================================================
-- INSTÂNCIAS DE TESTE
-- =====================================================================
-- Um único conjunto de dados, montado para cobrir os casos de todas as
-- consultas. Cada consulta abaixo indica quais instâncias testam quais
-- casos e qual é o resultado esperado.

insert into conta values
    (1, 'ana',   'ana@email.com',   'senha1', '2000-05-10', 'Brasil',   50.00),
    (2, 'bruno', 'bruno@email.com', 'senha2', '1998-11-22', 'Brasil',   10.00),
    (3, 'carla', 'carla@email.com', 'senha3', '2001-02-14', 'Portugal',  0.00),
    (4, 'diego', 'diego@email.com', 'senha4', '1995-07-30', 'Argentina', 5.50),
    (5, 'eva',   'eva@email.com',   'senha5', '2003-09-01', 'Brasil',    0.00),
    (6, 'fabio', 'fabio@email.com', 'senha6', '1999-12-25', 'Portugal', 100.00);
-- fabio: conta nova, sem jogos e sem pedidos

insert into amizade values
    (1, 2, 'aceita'),
    (1, 3, 'aceita'),
    (4, 1, 'aceita'),    -- ana é destinatária: testa os dois sentidos
    (2, 4, 'pendente'),  -- bruno e diego têm jogo em comum, mas não são amigos
    (5, 1, 'recusada'),
    (3, 5, 'aceita'),    -- carla e eva são amigas sem jogos em comum
    (6, 2, 'pendente');

insert into desenvolvedora values
    (1, 'Valve',      'EUA'),
    (2, 'CD Projekt', 'Polônia'),
    (3, 'Supergiant', 'EUA'),
    (4, 'Aquiris',    'Brasil');

insert into genero values
    (1, 'Ação'),
    (2, 'RPG'),
    (3, 'FPS'),
    (4, 'Indie'),
    (5, 'Corrida'),
    (6, 'Estratégia');  -- gênero sem nenhum jogo

insert into jogo values
    (1, 1, 'Half-Life 2',         29.99),
    (2, 1, 'Counter-Strike 2',     0.00),  -- gratuito: está em bibliotecas sem pedido
    (3, 1, 'Portal 2',            19.99),
    (4, 2, 'The Witcher 3',       79.99),
    (5, 2, 'Cyberpunk 2077',     199.90),
    (6, 3, 'Hades',               47.49),
    (7, 4, 'Horizon Chase Turbo', 37.99),
    (8, 4, 'Ballistic Overkill',  47.49);  -- ninguém possui; empata em preço com Hades

insert into jogo_genero values
    (1, 1), (1, 3),
    (2, 1), (2, 3),
    (3, 1),
    (4, 1), (4, 2),
    (5, 1), (5, 2), (5, 3),
    (6, 1), (6, 2), (6, 4),
    (7, 4), (7, 5),
    (8, 3), (8, 4);

insert into pedido values
    (1, 1, '2026-01-10'),
    (2, 1, '2026-02-05'),
    (3, 2, '2026-01-15'),
    (4, 2, '2026-03-01'),
    (5, 3, '2026-02-20'),
    (6, 3, '2026-02-21'),
    (7, 4, '2026-03-10'),
    (8, 5, '2026-01-05'),
    (9, 1, '2026-03-15');

insert into item_pedido values
    -- (id_pedido, id_jogo, preco_pago)
    (1, 4,  79.99),
    (2, 6,  47.49),
    (3, 5, 199.90),
    (4, 4,  79.99),
    (5, 6,  47.49),
    (6, 3,  19.99),
    (7, 1,  29.99),
    (8, 7,  37.99),
    (9, 1,  29.99);

insert into biblioteca values
    -- (id_conta, id_jogo, horas_jogadas, ultima_sessao)
    (1, 4, 120.50, '2026-01-10'),
    (1, 6,  45.00, '2026-02-05'),
    (1, 1,   0.00, null),          -- comprou e nunca jogou
    (1, 2, 300.00, '2025-12-01'),
    (2, 5,  80.00, '2026-01-15'),
    (2, 4,  15.00, '2026-03-01'),
    (2, 2, 500.00, '2025-11-20'),
    (3, 6,  60.00, '2026-02-20'),
    (3, 3,  10.00, '2026-02-21'),
    (4, 1,   2.50, '2026-03-10'),
    (4, 2,   0.00, null),
    (5, 7,  33.00, '2026-01-05');

insert into avaliacao values
    (4, 1, 5, 'Obra-prima',                 '2026-02-01'),
    (6, 1, 5, 'Viciante',                   '2026-03-01'),
    (2, 1, 3, null,                         '2026-01-10'),
    (5, 2, 3, 'Muitos bugs no lançamento',  '2026-02-10'),
    (4, 2, 4, null,                         '2026-03-20'),
    (2, 2, 4, 'Clássico',                   '2025-12-15'),
    (6, 3, 4, null,                         '2026-03-05'),
    (3, 3, 5, 'Genial',                     '2026-03-01'),
    (1, 4, 1, 'Não gostei',                 '2026-03-11'),
    (7, 5, 5, 'Orgulho nacional',           '2026-02-01');
-- avaliacao referencia biblioteca: só é possível avaliar um jogo que se possui


-- =====================================================================
-- CONSULTAS
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Popularidade de cada gênero: número de jogadores distintos e total
--    de horas jogadas nos jogos do gênero.
--    Recursos: VISÃO + GROUP BY + LEFT JOIN
--    Tabelas: genero, jogo_genero, biblioteca_detalhada
--
--    Casos testados:
--    - jogos com vários gêneros contam em cada um deles (Cyberpunk 2077
--      entra em Ação, RPG e FPS);
--    - Estratégia não tem jogos e aparece com 0;
--    - Ballistic Overkill (FPS, Indie) não tem donos e não soma nada.
--
--    Resultado esperado:
--      genero     | jogadores | total_horas
--      Ação       |     4     |   1133.00
--      FPS        |     3     |    882.50
--      RPG        |     3     |    320.50
--      Indie      |     3     |    138.00
--      Corrida    |     1     |     33.00
--      Estratégia |     0     |      0.00
-- ---------------------------------------------------------------------
select g.nomeg                              as genero,
       count(distinct v.id_conta)           as jogadores,
       coalesce(sum(v.horas_jogadas), 0.00) as total_horas
from genero g
left join jogo_genero jg on jg.id_genero = g.id_genero
left join biblioteca_detalhada v on v.id_jogo = jg.id_jogo
group by g.id_genero, g.nomeg
order by total_horas desc;


-- ---------------------------------------------------------------------
-- 2. Desenvolvedoras bem avaliadas: com pelo menos 2 avaliações nos seus
--    jogos e nota média de no mínimo 4.
--    Recursos: GROUP BY + HAVING
--    Tabelas: desenvolvedora, jogo, avaliacao
--
--    Casos testados:
--    - CD Projekt: 3 avaliações, média exatamente 4.00 (limite) -> entra;
--    - Valve: 4 avaliações, mas média 3.25 -> sai pela média;
--    - Supergiant: 2 avaliações (limite da quantidade), média 4.50 -> entra;
--    - Aquiris: média 5, mas só 1 avaliação -> sai pela quantidade.
--
--    Resultado esperado:
--      desenvolvedora | avaliacoes | nota_media
--      Supergiant     |     2      |    4.50
--      CD Projekt     |     3      |    4.00
-- ---------------------------------------------------------------------
select d.nomed                 as desenvolvedora,
       count(*)                as avaliacoes,
       round(avg(a.nota), 2)   as nota_media
from desenvolvedora d
join jogo j      on j.id_desenvolvedora = d.id_desenvolvedora
join avaliacao a on a.id_jogo = j.id_jogo
group by d.id_desenvolvedora, d.nomed
having count(*) >= 2 and avg(a.nota) >= 4
order by nota_media desc;


-- ---------------------------------------------------------------------
-- 3. Faturamento da loja por país: quantas contas compraram, quantos
--    pedidos foram feitos e o valor total gasto.
--    Recursos: GROUP BY com várias totalizações
--    Tabelas: conta, pedido, item_pedido, jogo
--    (o valor usa o preço atual do jogo, pois item_pedido não guarda o
--    preço pago)
--
--    Casos testados:
--    - Brasil tem 3 compradores (ana com 3 pedidos, bruno com 2, eva com 1);
--    - Portugal tem 2 contas, mas fabio nunca comprou -> conta 1 comprador;
--    - Counter-Strike 2 é gratuito e não gera pedido, então não entra.
--
--    Resultado esperado:
--      pais      | compradores | pedidos | total_gasto
--      Brasil    |      3      |    6    |   475.35
--      Portugal  |      1      |    2    |    67.48
--      Argentina |      1      |    1    |    29.99
-- ---------------------------------------------------------------------
select c.pais,
       count(distinct c.id_conta)  as compradores,
       count(distinct p.id_pedido) as pedidos,
       sum(j.preco)                as total_gasto
from conta c
join pedido p       on p.id_conta = c.id_conta
join item_pedido ip on ip.id_pedido = p.id_pedido
join jogo j         on j.id_jogo = ip.id_jogo
group by c.pais
order by total_gasto desc;


-- ---------------------------------------------------------------------
-- 4. Recomendações para a conta 'ana': jogos que seus amigos possuem e
--    que ela ainda não tem, com quanto o amigo jogou.
--    Recursos: VISÃO + autorrelacionamento de amizade + anti-join
--              (LEFT JOIN ... IS NULL)
--    Tabelas: conta, amizade, biblioteca_detalhada, biblioteca
--
--    Casos testados:
--    - amizades nos dois sentidos: ana -> bruno, ana -> carla e
--      diego -> ana;
--    - eva não entra: a amizade com ana foi recusada;
--    - jogos que ana já tem (Witcher, Hades, Half-Life 2, CS2) são
--      descartados, por isso diego não recomenda nada.
--
--    Resultado esperado:
--      amigo | titulo         | desenvolvedora | horas_do_amigo | preco
--      bruno | Cyberpunk 2077 | CD Projekt     |     80.00      | 199.90
--      carla | Portal 2       | Valve          |     10.00      |  19.99
-- ---------------------------------------------------------------------
select v.username      as amigo,
       v.titulo,
       v.desenvolvedora,
       v.horas_jogadas as horas_do_amigo,
       v.preco
from conta c
join amizade a on a.status = 'aceita'
              and c.id_conta in (a.id_solicitante, a.id_destinatario)
join biblioteca_detalhada v
     on v.id_conta = case when a.id_solicitante = c.id_conta
                          then a.id_destinatario
                          else a.id_solicitante end
left join biblioteca b on b.id_conta = c.id_conta
                      and b.id_jogo = v.id_jogo
where c.username = 'ana'
  and b.id_jogo is null
order by v.horas_jogadas desc;


-- ---------------------------------------------------------------------
-- 5. Jogadores dedicados: contas que jogaram um jogo por mais horas do
--    que a média de horas de todos os donos daquele jogo.
--    Recursos: SUBCONSULTA correlacionada com agregação (a média é
--              recalculada para cada jogo; não há equivalente só com JOINs)
--    Tabelas: conta, biblioteca, jogo
--
--    Casos testados:
--    - CS2 (média 266.67): ana e bruno acima, diego (0 h) abaixo;
--    - Portal 2, Cyberpunk e Horizon têm um único dono, que fica igual à
--      média e não entra (a comparação é estrita);
--    - Half-Life 2: diego (2.5 h) acima de ana (0 h).
--
--    Resultado esperado:
--      username | titulo           | horas_jogadas | media_do_jogo
--      ana      | Counter-Strike 2 |    300.00     |    266.67
--      bruno    | Counter-Strike 2 |    500.00     |    266.67
--      carla    | Hades            |     60.00     |     52.50
--      diego    | Half-Life 2      |      2.50     |      1.25
--      ana      | The Witcher 3    |    120.50     |     67.75
-- ---------------------------------------------------------------------
select c.username,
       j.titulo,
       b.horas_jogadas,
       (select round(avg(b2.horas_jogadas), 2)
          from biblioteca b2
         where b2.id_jogo = b.id_jogo) as media_do_jogo
from biblioteca b
join conta c on c.id_conta = b.id_conta
join jogo j  on j.id_jogo = b.id_jogo
where b.horas_jogadas > (select avg(b2.horas_jogadas)
                           from biblioteca b2
                          where b2.id_jogo = b.id_jogo)
order by j.titulo, c.username;


-- ---------------------------------------------------------------------
-- 6. Jogo mais caro de cada gênero (todos, em caso de empate).
--    Recursos: SUBCONSULTA correlacionada com MAX (o máximo depende do
--              gênero da linha externa)
--    Tabelas: genero, jogo_genero, jogo
--
--    Casos testados:
--    - empate em Indie: Hades e Ballistic Overkill custam 47.49 e os
--      dois aparecem;
--    - Corrida tem um único jogo;
--    - Estratégia não tem jogos e não aparece.
--
--    Resultado esperado:
--      genero  | titulo              | preco
--      Ação    | Cyberpunk 2077      | 199.90
--      Corrida | Horizon Chase Turbo |  37.99
--      FPS     | Cyberpunk 2077      | 199.90
--      Indie   | Ballistic Overkill  |  47.49
--      Indie   | Hades               |  47.49
--      RPG     | Cyberpunk 2077      | 199.90
-- ---------------------------------------------------------------------
select g.nomeg as genero,
       j.titulo,
       j.preco
from genero g
join jogo_genero jg on jg.id_genero = g.id_genero
join jogo j         on j.id_jogo = jg.id_jogo
where j.preco = (select max(j2.preco)
                   from jogo j2
                   join jogo_genero jg2 on jg2.id_jogo = j2.id_jogo
                  where jg2.id_genero = g.id_genero)
order by g.nomeg, j.titulo;


-- ---------------------------------------------------------------------
-- 7. Colecionadores: contas que possuem TODOS os jogos de uma
--    desenvolvedora.
--    Recursos: consulta do tipo TODOS, pela diferença vazia
--              (jogos da desenvolvedora EXCEPT jogos da conta = vazio)
--    Tabelas: conta, desenvolvedora, jogo, biblioteca
--
--    Casos testados:
--    - bruno tem Witcher 3 e Cyberpunk -> todos os da CD Projekt;
--    - ana tem só Witcher 3 -> não completa CD Projekt;
--    - ana tem Half-Life 2 e CS2, mas não Portal 2 -> não completa Valve;
--    - eva tem Horizon, mas não Ballistic Overkill -> não completa Aquiris;
--    - fabio não tem jogos e não aparece.
--
--    Resultado esperado:
--      username | desenvolvedora
--      ana      | Supergiant
--      bruno    | CD Projekt
--      carla    | Supergiant
-- ---------------------------------------------------------------------
select c.username,
       d.nomed as desenvolvedora
from conta c
cross join desenvolvedora d
where not exists (
        select j.id_jogo
          from jogo j
         where j.id_desenvolvedora = d.id_desenvolvedora
        except
        select b.id_jogo
          from biblioteca b
         where b.id_conta = c.id_conta
      )
order by c.username, d.nomed;


-- ---------------------------------------------------------------------
-- 8. Amigos com jogos em comum: para cada amizade aceita, quantos e
--    quais jogos os dois possuem.
--    Recursos: GROUP BY + agregação de texto (string_agg) + duas
--              instâncias de conta e de biblioteca
--    Tabelas: amizade, conta, biblioteca, jogo
--
--    Casos testados:
--    - bruno e diego têm CS2 em comum, mas o pedido está pendente -> não
--      aparecem;
--    - carla e eva são amigas sem jogos em comum -> não aparecem;
--    - empate em 2 jogos entre ana/bruno e diego/ana.
--
--    Resultado esperado:
--      conta_1 | conta_2 | jogos_em_comum | titulos
--      ana     | bruno   |       2        | Counter-Strike 2, The Witcher 3
--      diego   | ana     |       2        | Counter-Strike 2, Half-Life 2
--      ana     | carla   |       1        | Hades
-- ---------------------------------------------------------------------
select c1.username as conta_1,
       c2.username as conta_2,
       count(*)    as jogos_em_comum,
       string_agg(j.titulo, ', ' order by j.titulo) as titulos
from amizade a
join conta c1      on c1.id_conta = a.id_solicitante
join conta c2      on c2.id_conta = a.id_destinatario
join biblioteca b1 on b1.id_conta = a.id_solicitante
join biblioteca b2 on b2.id_conta = a.id_destinatario
                  and b2.id_jogo = b1.id_jogo
join jogo j        on j.id_jogo = b1.id_jogo
where a.status = 'aceita'
group by a.id_solicitante, a.id_destinatario, c1.username, c2.username
order by jogos_em_comum desc, conta_1;


-- ---------------------------------------------------------------------
-- 9. Avaliações pouco confiáveis: feitas por quem não possui o jogo ou
--    jogou menos de 20 horas.
--    Recursos: LEFT JOIN para detectar a ausência na biblioteca + CASE
--    Tabelas: avaliacao, conta, jogo, biblioteca
--
--    Casos testados:
--    - diego, carla e bruno jogaram menos de 20 h;
--    - eva (33 h) e as demais avaliações ficam de fora;
--    - como avaliacao referencia biblioteca, o caso "não possui o jogo"
--      não ocorre com dados válidos; o LEFT JOIN o mantém como proteção.
--
--    Resultado esperado:
--      username | titulo        | nota | horas_jogadas | situacao
--      diego    | Half-Life 2   |  1   |      2.50     | jogou pouco
--      carla    | Portal 2      |  5   |     10.00     | jogou pouco
--      bruno    | The Witcher 3 |  4   |     15.00     | jogou pouco
-- ---------------------------------------------------------------------
select c.username,
       j.titulo,
       a.nota,
       b.horas_jogadas,
       case when b.id_conta is null then 'não possui o jogo'
            else 'jogou pouco' end as situacao
from avaliacao a
join conta c on c.id_conta = a.id_conta
join jogo j  on j.id_jogo = a.id_jogo
left join biblioteca b on b.id_conta = a.id_conta
                      and b.id_jogo = a.id_jogo
where b.id_conta is null
   or b.horas_jogadas < 20
order by b.horas_jogadas nulls first;


-- ---------------------------------------------------------------------
-- 10. Histórico de atividades da conta 'bruno': compras e avaliações em
--     uma única linha do tempo, da mais recente para a mais antiga.
--     Recursos: UNION ALL de duas consultas com estruturas diferentes
--     Tabelas: conta, pedido, item_pedido, jogo, avaliacao
--
--     Casos testados:
--     - Cyberpunk e Witcher aparecem duas vezes (compra e avaliação);
--     - CS2 é gratuito: aparece só a avaliação, sem compra;
--     - atividades de outras contas ficam de fora.
--
--     Resultado esperado:
--       data       | atividade | titulo           | detalhe
--       2026-03-20 | avaliação | The Witcher 3    | nota 4
--       2026-03-01 | compra    | The Witcher 3    | R$ 79.99
--       2026-02-10 | avaliação | Cyberpunk 2077   | nota 3
--       2026-01-15 | compra    | Cyberpunk 2077   | R$ 199.90
--       2025-12-15 | avaliação | Counter-Strike 2 | nota 4
-- ---------------------------------------------------------------------
select p.data_pedido   as data,
       'compra'        as atividade,
       j.titulo,
       'R$ ' || j.preco as detalhe
from conta c
join pedido p       on p.id_conta = c.id_conta
join item_pedido ip on ip.id_pedido = p.id_pedido
join jogo j         on j.id_jogo = ip.id_jogo
where c.username = 'bruno'

union all

select a.data_avaliacao,
       'avaliação',
       j.titulo,
       'nota ' || a.nota
from conta c
join avaliacao a on a.id_conta = c.id_conta
join jogo j      on j.id_jogo = a.id_jogo
where c.username = 'bruno'

order by data desc;
