create table Persona (
    nom varchar(30) not null constraint pers_pk primary key,
    fechanac date
);
create table Pelicula (
    titulo varchar(40) not null constraint pel_pk primary key,
    estreno date,
	lema varchar(60)
);

CREATE TABLE Actua
    (
        nom varchar(30) NOT NULL,
        titulo varchar(40)  NOT NULL,
        primary key(nom,titulo),
        foreign key(nom) references Persona(nom) on delete cascade,
        foreign key(titulo) references Pelicula(titulo) on delete cascade      
    );
CREATE TABLE Dirige
    (
        nom varchar(30) NOT NULL,
        titulo varchar(40)  NOT NULL,
        primary key(nom,titulo),
        foreign key(nom) references Persona(nom) on delete cascade,
        foreign key(titulo) references Pelicula(titulo) on delete cascade      
    );

create table Sigue (
    seguido varchar(30) not null,
    seguidor varchar(30) not null,
	primary key(seguido,seguidor),
	foreign key(seguido) references Persona(nom) on delete cascade,
    foreign key(seguidor) references Persona(nom) on delete cascade
);

insert into Persona values
        ('Keanu Reeves','1964-03-23'),
        ('Carrie-Anne Moss','1967-03-29'),
        ('Hugo Weaving','1960-03-30'),
        ('Emil Eifrem','1978-10-20'),
		('Al Pacino','1940-10-20'),
		('Charlize Theron','1975-10-20'),
		('Lilly Wachowski','1967-05-27'),
		('Taylor Hackford','1944-08-13'),
		('Paul Blythe','2009-12-13');
insert into Pelicula values
        ('The Matrix','1990-09-13','Welcome to the Real World'),
        ('The Matrix Revolutions','2003-04-19','Everything that has a beginning has an end'),
        ('The Devils Advocate','1997-08-30','Evil has its winning ways');
		
Insert into Actua values
     ('Keanu Reeves','The Matrix'),
     ('Hugo Weaving','The Matrix'),
	 ('Emil Eifrem','The Matrix'),
	 ('Al Pacino','The Matrix'),
	 ('Keanu Reeves','The Matrix Revolutions'),
	 ('Lilly Wachowski','The Matrix Revolutions'),
	 ('Al Pacino','The Matrix Revolutions'),
	 ('Keanu Reeves','The Devils Advocate'),
	 ('Al Pacino','The Devils Advocate');

Insert into Dirige values
     ('Carrie-Anne Moss','The Matrix'),
     ('Hugo Weaving','The Matrix'),
	 ('Keanu Reeves','The Matrix Revolutions'),
	 ('Carrie-Anne Moss','The Matrix Revolutions'),
	 ('Carrie-Anne Moss','The Devils Advocate'),
	 ('Taylor Hackford','The Devils Advocate');
Insert into Sigue values
     ('Keanu Reeves','Hugo Weaving'),
     ('Keanu Reeves','Al Pacino'),
	 ('Emil Eifrem','Lilly Wachowski'),
	 ('Keanu Reeves','Paul Blythe'),
	 ('Al Pacino','Keanu Reeves');


-- 1. Personas (nombre) que han actuado en más de una película estrenada en el año 1990

select a.nom
from actua a 
join pelicula p2 on p2.titulo = a.titulo
where p2.estreno between '1990-01-01' and '1990-12-31'
group by a.nom
having count(distinct a.titulo) > 1

--2. Películas (título y lema) en las que han actuado solamente personas que nacieron antes del 1970

select titulo, lema
from pelicula natural join (
	select titulo
	from actua 
	
	except 
	
	select a.titulo
	from actua a 
	join persona p on p.nom = a.nom
	where fechanac > '1970-01-01'
)

--3. Personas (todos los datos) que han actuado en todas las películas dirigidas por Carrie-Anne Moss.
	

-- Seleccionar todas las personas que han actuado en todas las películas dirigidas por Carrie-Anne Moss
SELECT p.nom
FROM persona p
WHERE NOT EXISTS (
    -- Subconsulta para encontrar todas las películas dirigidas por Carrie-Anne Moss
    SELECT d.titulo
    FROM dirige d
    WHERE d.nom = 'Carrie-Anne Moss'
    AND NOT EXISTS (
        -- Subconsulta para verificar si la persona ha actuado en cada película
        SELECT *
        FROM actua a
        WHERE a.nom = p.nom
        AND a.titulo = d.titulo
    )
);

select p.nom
	from persona p
	where not exists(
	select *
	from dirige d 
	where d.nom = 'Keanu Reeves'
	and not exists (
	select *
	from actua a 
	where a.nom = p.nom
	and a.titulo = d.titulo
	)
)


-- 4. Obtener el título y fecha de estreno de las películas dirigidas por Keanu Reeves.
select p.titulo, p.estreno 
from pelicula p 
join dirige d on d.titulo = p.titulo
where d.nom = 'Keanu Reeves';

--5. Personas (todos los datos) que han actuado y/o dirigido en las mismas Películas en las que actuó Keanu Reeves.

select nom 
	from actua a
	where a.nom != kr
	and a.titulo in(
	select a.titulo
	from actua a
	where a.nom = 'Keanu Reeves' 
)
union
select nom
from dirige d
where d.titulo in (
	select a.titulo
	from actua a
	where a.nom = 'Keanu Reeves'
)

--6. Personas (nombre) que han actuado en las películas The Matrix y The Matrix Revolutions.

select a.nom 
from actua a<
where a.titulo = 'The Matrix'
intersect 
select a.nom 
from actua a
where a.titulo = 'The Matrix Revolutions'


--7. Persona/s (todos los datos) que ha/n dirigido más películas
	select d.nom,count(*) as maximo_peli
	from dirige d
	group by d.nom
having count(*) = (
	select count(*) as maximo_peli
	from dirige
	group by nom
	order by maximo_peli desc
	limit 1
	)



--8. Nombre de la persona junto a la cantidad de películas que ha dirigido.


select nom, count(*)
from dirige 
group by nom


--9. Personas (todos sus datos) que han participado actuando y dirigiendo la misma película.


select distinct p.*
from persona p
join actua a on a.nom = p.nom
join dirige d on p.nom = d.nom and a.titulo = d.titulo;


--10. .Título de la película junto a la cantidad de personas que participaron actuando y/o dirigiendo

select a.titulo, count(*)
from actua a
join dirige d on d.titulo = a.titulo
group by (a.titulo)


-- Título de la película junto a la cantidad total de personas que participaron actuando o dirigiendo
SELECT titulo, COUNT(nom) AS cantidad_personas
FROM (
    SELECT titulo, nom FROM actua
    UNION ALL
    SELECT titulo, nom FROM dirige
) AS combined
GROUP BY titulo;


