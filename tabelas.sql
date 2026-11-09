-- DDL --- STEAM
--
--
-- MODELAGEM DA PLATAFORMA DE JOGOS STEAM, COM:
-- LOJA DE JOGOS
-- SISTEMA DE AMIZADE
-- BIBLIOTECA
-- SISTEMA DE AVALIAÇÃO DE JOGOS
--
-- O sistema de atribuição de gênero permite filtrar a loja por gênero.
-- Contas podem ser deletadas. Quando forem, qualquer coisa atrelada a elas é deletada junto.
-- Jogos e desenvolvedoras não podem ser deletadas, por isso não têm cláusulas 'on delete'.


create table conta(
    id_conta int primary key,
    username varchar(20) not null,
    email varchar(40) not null unique,
    senha varchar(20) not null,
    data_nascimento date not null,
    pais varchar(40) not null,
    saldo decimal(10,2) not null default 0
            check (saldo >= 0)
);
-- representa uma conta de um usuário.

create table amizade(
    id_solicitante int not null,
    id_destinatario int not null,
    status  varchar(10) not null default 'pendente',
            check (status in ('pendente', 'aceita', 'recusada')),
    check (id_solicitante != id_destinatario),
    primary key (id_solicitante, id_destinatario),
    foreign key (id_solicitante) references conta(id_conta) on delete cascade,
    foreign key (id_destinatario) references conta(id_conta) on delete cascade
);
--modela na verdade um pedido de amizade, amizades existentes podem ser filtradas a partir de amizade.status == 'aceita'
--se uma conta é deletada, amizades relacionadas a ela também são deletadas

create table desenvolvedora(
    id_desenvolvedora int not null primary key,
    nomed varchar(50) not null unique,
    pais varchar(50) not null
);
--simplificação da relação desenvolvedora/publicadora
--jogos e desenvolvedoras não poderão ser deletadas, por isso não têm cascade

create table genero(
    id_genero int primary key,
    nomeg varchar(30) not null unique
);
-- tabela lista os generos de jogos. São associados a jogos na tabela jogo_genero.

create table jogo(
    id_jogo int primary key,
    id_desenvolvedora int not null,
    titulo varchar(50) not null unique,
    preco decimal(10,2) not null
            check (preco >= 0), 
    foreign key (id_desenvolvedora) references desenvolvedora(id_desenvolvedora)
);
-- mantemos somente jogos na loja por simplicidade, podendo focar nas outras features do modelo. 

create table jogo_genero(
    id_jogo int not null,
    id_genero int not null,
    primary key (id_jogo, id_genero),
    foreign key (id_jogo) references jogo(id_jogo) on delete cascade,
    foreign key (id_genero) references genero(id_genero) on delete cascade
);
--tabela garante que um dado jogo pode ter mais de um genero, e que um gênero pode ter mais de um jogo

create table pedido(
    id_pedido int primary key,
    id_conta int not null,
    data_pedido date not null,
    foreign key (id_conta) references conta(id_conta) on delete cascade
);
--não incluída forma de pagamento, assumimos que todas as compras serão usando saldo

create table item_pedido(
    id_pedido int not null,
    id_jogo int not null,
    preco_pago decimal(10,2) not null
            check (preco_pago >= 0),
    primary key (id_pedido, id_jogo),
    foreign key (id_pedido) references pedido(id_pedido) on delete cascade,
    foreign key (id_jogo) references jogo(id_jogo)
);
-- representa os itens comprados em um pedido relacionando. cada elemento é um jogo que pertence a um pedido de uma conta. 
-- pode-se ver todos os itens de um pedido selecionando a com id_conta e id_pedido.

create table biblioteca(
    id_conta int not null,
    id_jogo int not null,
    horas_jogadas decimal(10,2) not null default 0
               check (horas_jogadas >= 0),
    ultima_sessao date default null
            check (ultima_sessao is null or ultima_sessao <= current_date),
    primary key (id_conta, id_jogo),
    foreign key (id_conta) references conta(id_conta) on delete cascade,
    foreign key (id_jogo) references jogo(id_jogo) on delete cascade
);
-- cada elemento da tabela representa um item da biblioteca de um usuário. 

create table avaliacao(
    id_jogo int not null,
    id_conta int not null,
    nota    int not null
            check (nota in (1, 2, 3, 4, 5)),
    comentario varchar(255),
    data_avaliacao date not null,
    primary key (id_jogo, id_conta),
    foreign key (id_conta, id_jogo) references biblioteca(id_conta, id_jogo) on delete cascade
);
-- uma avaliação relaciona uma conta e um jogo, cada conta pode avaliar um jogo apenas uma vez, mas um jogo pode ter várias avaliações
