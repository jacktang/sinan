%% -*- mode: Erlang; fill-column: 80; comment-column: 75; -*-
%%%-------------------------------------------------------------------
%%%---------------------------------------------------------------------------
%%% @author Eric Merritt <ericbmerritt@gmail.com>
%%% @doc
%%%   Runs the 'test' function on all modules in an application
%%%   if that function exits.
%%% @end
%%% @copyright (C) 2007-2011 Erlware
%%%---------------------------------------------------------------------------
-module(sin_task_eunit).

-behaviour(sin_task).

-include_lib("sinan/include/sinan.hrl").

%% API
-export([description/0, do_task/2]).

-define(TASK, eunit).
-define(DEPS, [build]).

%%====================================================================
%% API
%%====================================================================

%% @doc provides a description of this task
-spec description() ->  sin_task:task_description().
description() ->

    Desc = "This command runs all eunit tests available in the
        project. ",

    #task{name = ?TASK,
          task_impl = ?MODULE,
          bare = false,
          deps = ?DEPS,
          example = "eunit",
          desc = Desc,
          short_desc = "Runs all of the existing eunit unit tests in the project",
          opts = []}.

%% @doc run all tests for all modules in the system
do_task(_Config, State0) ->
    lists:foldl(fun(#app{name=AppName, modules=Modules}, State1) ->
                   io:format("Eunit testing app ~p~n", [AppName]),
                   case Modules == undefined orelse length(Modules) =< 0 of
                       true ->
                           ec_talk:say("No modules defined for ~p.",
                                       [AppName]),
                           State1;
                       false ->
                           run_module_tests(Modules),
                           State1
                   end
                end, State0, sin_state:get_value(project_apps, State0)).

%%====================================================================
%%% Internal functions
%%====================================================================

%% @doc Run tests for each module that has a test/0 function
-spec run_module_tests([sin_file_info:mod()]) -> ok.
run_module_tests(AllModules) ->
    lists:foreach(
      fun(#module{name=Name, tags=Tags}) ->
              case sets:is_element(eunit, Tags) of
                  true ->
                      ec_talk:say("testing ~p", [Name]),
                      eunit:test(Name);
                  _ ->
                      ok
              end
      end, AllModules).
