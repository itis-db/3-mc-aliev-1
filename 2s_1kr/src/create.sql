create extension if not exists pg_trgm;

create table author (
    author_id   integer generated always as identity primary key,
    first_name  text not null,
    last_name   text not null,
    bio         text
);

create table publisher (
    publisher_id integer generated always as identity primary key,
    name         text not null,
    address      text
);

create table genre (
    genre_id integer generated always as identity primary key,
    name     text not null unique
);

create table tag (
    tag_id integer generated always as identity primary key,
    name   text not null unique
);

create table book (
    book_id        integer generated always as identity primary key,
    title          text not null,
    description    text,
    pub_year       integer check (pub_year between 1500 and extract(year from current_date)),
    isbn           text unique,
    author_id      integer not null,
    publisher_id   integer not null,
    genre_id       integer not null,
    search_vector  tsvector generated always as (
        to_tsvector('russian',
                    coalesce(title,'') || ' ' || coalesce(description,'')
        )
        ) stored,
    constraint fk_book_author    foreign key (author_id)    references author(author_id)    on delete restrict,
    constraint fk_book_publisher foreign key (publisher_id) references publisher(publisher_id) on delete restrict,
    constraint fk_book_genre    foreign key (genre_id)     references genre(genre_id)     on delete restrict
);

create table book_tag (
    book_id integer not null,
    tag_id  integer not null,
    primary key (book_id, tag_id),
    constraint fk_bt_book foreign key (book_id) references book(book_id) on delete cascade,
    constraint fk_bt_tag  foreign key (tag_id)  references tag(tag_id)   on delete cascade
);

create index idx_book_author_fk      on book (author_id);
create index idx_book_publisher_fk   on book (publisher_id);
create index idx_book_genre_fk       on book (genre_id);
create index idx_bt_tag_fk           on book_tag (tag_id);
create index idx_bt_book_fk          on book_tag (book_id);

create index idx_book_search_vector_gin
    on book using gin (search_vector);

create index idx_book_title_trgm
    on book using gin (title gin_trgm_ops);

create index idx_book_desc_trgm
    on book using gin (description gin_trgm_ops);