%%% @author Jordi Chacon <jordi.chacon@klarna.com>
%%% @copyright (C) 2010, Jordi Chacon
-module(languages_resource_SUITE).
-compile(export_all).
-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").
-include_lib("../include/polish.hrl").

suite() ->
    [].

all() ->
    [http_get_languages,
     http_get_language,
     http_bad_method_languages,
     http_bad_method_language,
     http_not_existent_language].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% I N I T S
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init_per_suite(Config) ->
    polish_test_lib:start_polish_for_test(),
    Config.

init_per_testcase(_TestCase, Config) ->
    Config.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% E N D S
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end_per_suite(_Config) ->
    ok.

end_per_testcase(_TestCase, _Config) ->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% T E S T   C A S E S
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
http_get_languages(_Config) ->
    {Code, ResponseJSON} = polish_test_lib:send_http_request(
			     get, "/languages", ?JSON),
    ?assertEqual(?OK, Code),
    Response = mochijson2:decode(ResponseJSON),
    ?assertEqual(3, length(Response)),
    URL = polish_utils:build_url() ++ "/languages",
    [{_,Ca}, {_,En}, {_,Es}] = Response,
    polish_test_lib:assert_fields_from_response(
      [{"url", URL++"/ca"}, {"name", "Catalan"}], Ca),
    polish_test_lib:assert_fields_from_response(
      [{"url", URL++"/en"}, {"name", "English"}], En),
    polish_test_lib:assert_fields_from_response(
      [{"url", URL++"/es"}, {"name", "Spanish"}], Es),
    ok.

http_get_language(_Config) ->
    {Code, ResponseJSON} = polish_test_lib:send_http_request(
			     get, "/languages/ca", ?JSON),
    ?assertEqual(?OK, Code),
    {struct, Response} = mochijson2:decode(ResponseJSON),
    polish_test_lib:assert_fields_from_response(
      [{"total", 5}, {"untrans", 1}], Response),
    ok.

http_bad_method_languages(_Config) ->
    {Code1, _} = polish_test_lib:send_http_request(delete, "/languages", ?JSON),
    ?assertEqual(?BAD_METHOD, Code1),
    {Code2, _} = polish_test_lib:send_http_request(put,"/languages", "", ?JSON),
    ?assertEqual(?BAD_METHOD, Code2),
    {Code3, _} = polish_test_lib:send_http_request(post,"/languages","", ?JSON),
    ?assertEqual(?BAD_METHOD, Code3),
    ok.

http_bad_method_language(_Config) ->
    {Code1, _} = polish_test_lib:send_http_request(
		   delete, "/languages/ca", ?JSON),
    ?assertEqual(?BAD_METHOD, Code1),
    {Code2, _} = polish_test_lib:send_http_request(
		   put, "/languages/ca", ?JSON),
    ?assertEqual(?BAD_METHOD, Code2),
    {Code3, _} = polish_test_lib:send_http_request(
		   post, "/languages/ca", ?JSON),
    ?assertEqual(?BAD_METHOD, Code3),
    ok.

http_not_existent_language(_Config) ->
    {Code, _} = polish_test_lib:send_http_request(get, "/languages/nn", ?JSON),
    ?assertEqual(?NOT_FOUND, Code),
    ok.