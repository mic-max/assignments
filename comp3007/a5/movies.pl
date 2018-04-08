actor(jonny, depp, gender(male)).
actor(bruce, willis, gender(male)).
actor(glenn, close, gender(female)).
actor(orlando, bloom, gender(male)).
actor(jennifer, lawrence, gender(female)).
actor(sean, bean, gender(male)).
actor(angelina, jolie, gender(female)).
actor(keira, knightley, gender(female)).
actor(benedict, cumberbatch, gender(male)).
actor(james,mcavoy, gender(male)).
actor(robin, williams, gender(male)).
actor(emilia, clarke, gender(female)).
actor(ryan, reynolds, gender(male)).
actor(chris, pratt, gender(male)).
actor(ryan, gosling, gender(male)).
actor(robin,wright, gender(female)).
actor(karen, gillan, gender(female)).
actor(kirsten, dunst, gender(female)).
actor(dwayne, johnson, gender(male)).
actor(jack, black, gender(male)).
actor(tobey, maguire, gender(male)).
actor(keanu, reeves, gender(male)).

movie(year(2003), title([pirates,of,the,carribean]), cast([actor(jonny, depp), actor(keira, knightley), actor(orlando, bloom)])).
movie(year(2014), title([guardians, of, the, galaxy]), cast([actor(chris, pratt), actor(karen,gillan) ])).
movie(year(1988), title([die,hard]), cast([actor(bruce, willis)])).
movie(year(2001), title([lord,of,the,rings]), cast([actor(orlando, bloom), actor(sean, bean)])).
movie(year(2016), title([xmen, apocalypse]), cast([actor(jennifer,lawrence), actor(james, mcavoy)])).
movie(year(2014), title([the,imitation,game]), cast([actor(benedict, cumberbatch), actor(keira, knightley)])).
movie(year(2012), title([the,hunger,games]), cast([actor(jennifer,lawrence)])).
movie(year(2016), title([deadpool]), cast([actor(ryan, reynolds)])).
movie(year(1995), title([jumanji]), cast([actor(robin, williams), actor(kirsten, dunst)])).
movie(year(2017), title([jumanji,welcome,to,the,jungle]), cast([actor(dwayne,johnson),actor(karen,gillan),actor(jack,black)])).
movie(year(2003), title([spider,man]), cast([actor(tobey, maguire), actor(kirsten,dunst)])).
movie(year(2017), title([blade,runner,2049]), cast([actor(ryan,gosling), actor(robin,wright)])).

% Helper function. Checks if an actor is in the cast of a movie.
in_cast(First, Last):- movie(_, _, cast(Cast)), member(actor(First, Last), Cast).

/* Prolog Queries

% a) What movies were released before 2012?
movie(year(Year), Title, _), Year < 2012.
%

% b) What are the names of the female actors?
actor(First, Last, gender(female)).
%

% c) in what movies is jennifer lawrence a member of the cast
movie(_, Title, cast(Cast)), member(actor(jennifer, lawrence), Cast).
%

% d) What movies contain both the words "of" and "the" in the title (in no particular order)
movie(_, title(Title), _), member(of, Title), member(the, Title).
%

% e) What movies star an actor with the first name "Robin"?
movie(_, Title, cast(Cast)), member(actor(robin, _), Cast).
%

% f) What movies share one or more common actor?
movie(_, Title1, cast(Cast1)), movie(_, Title2, cast(Cast2)), Title1 \= Title2, Actor = actor(orlando, bloom), member(Actor, Cast1), member(Actor, Cast2).
%

% g) Who has worked with Orlando Bloom in a movie?
movie(_, Title, cast(Cast)), Bloom = actor(orlando, bloom), member(Bloom, Cast), member(Actor, Cast), Actor \= Bloom.
%

% h) What is the title of the oldest movie?
movie(year(Year1), Title1, _), \+ (movie(year(Year2), Title2, _), Title1 \= Title2, Year1 > Year2).
%

%i) What actors are not in the cast of any movie?
actor(First, Last, _), not(in_cast(First, Last)).
%

*/
