-ifndef(_POLISH).
-define(_POLISH, true).

-include_lib("nitrogen/include/wf.hrl").


-define(AUTH(FunCall), 
        case {wf:session(authenticated),
              lists:member(wf:user(), polish:get_acl())} of
            {true,true} -> polish:setup_user_info(), FunCall;
            _           -> wf:redirect("/login")
        end).

-endif.
