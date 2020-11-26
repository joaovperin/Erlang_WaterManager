-module(water_manager).

-author("joaovperin").

-version("1.0").

-export([main/1]).

%
% Returns the rest time for a molecule (in ms)
%
% FOR TESTING PURPOSES ONLY! DO NOT CHANGE THAT IN PRODUCTION!
% IT MAY CHANGE HOW THE REALITY LOOKS AND HOW THE TIME PASSES.
%
% Seriously. Do not change that.
molecule_rest_time() -> 1000.

% Code starts here.
main(Args) ->
    [SpawnTime | _] = Args,
    io:fwrite("Molecule Spawn time: ~p~n", [SpawnTime]),
    Server_PID = server_loop(),
    client_loop(Server_PID, list_to_integer(SpawnTime)).

%%%%%%%%%%%%%%
% Client Code.
client_loop(Server_PID, MoleculeSpawnTime) ->
    timer:sleep(MoleculeSpawnTime),
    spawn(fun () -> spawn_molecule(Server_PID) end),
    client_loop(Server_PID, MoleculeSpawnTime).

% Spawn a new molecule
spawn_molecule(Server_PID) ->
    MoleculeName = molecule_name(rand:uniform() / 1.3),
    Self_PID = self(),
    % RestTime between 10 and 30
    RestTime = 10 + trunc(rand:uniform() * 20),
    io:fwrite("...a wild Molecule (~p) appears! That's "
              "~p. It may evolve in ~p seconds.~n",
              [Self_PID, MoleculeName, RestTime]),
    process_molecule(Server_PID, MoleculeName, RestTime).

% Determine molecule name
molecule_name(Value) when Value > 5.0e-1 -> oxygen;
molecule_name(Value) when Value < 5.0e-1 -> hydrogen.

% Process the molecule
process_molecule(Server_PID, MoleculeName, 0) ->
    Self_PID = self(),
    io:fwrite("~n+++ Congratulations! Your ~p Molecule "
              "(~p) is ready to evolve! Ops, to merge*~n",
              [MoleculeName, Self_PID]),
    Server_PID ! {MoleculeName, Self_PID};
process_molecule(Server_PID, MoleculeName, RestTime) ->
    % TODO: Implement molecule mutations here (instead of just sleeping)
    timer:sleep(molecule_rest_time()),
    process_molecule(Server_PID,
                     MoleculeName,
                     RestTime - 1).

%%%%%%%%%%%%%%
% Server Code.

% Start the server loop
server_loop() ->
    spawn(fun () -> server_loop([], []) end).

% Server loop method
server_loop(OList, HList) ->
    % Try to create water from ready molecules and print the result snapshot
    {NewOList, NewHList} = create_water(OList, HList),
    io:fwrite("~n*** List Snapshot:~nOxygen:~w~nHydrogen:~w~n",
              [NewOList, NewHList]),
    % Await until a molecule is ready
    receive
        {oxygen, ClientPID} ->
            NextList = NewOList ++ [ClientPID],
            server_loop(NextList, NewHList);
        {hydrogen, ClientPID} ->
            NextHList = NewHList ++ [ClientPID],
            server_loop(NewOList, NextHList)
    end.

% Create water and get remainder lists
create_water([O | OxyList], [H1, H2 | HydroList]) ->
    io:fwrite("~n--- Creating water from Oxygen~w+Hydrogen[~"
              "w,~w]~n",
              [O, H1, H2]),
    {OxyList, HydroList};
% If cannot make pairs, just return the list
create_water(O, H) -> {O, H}.
