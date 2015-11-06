
ats2erlcml_cml_channel()       -> 'Elixir.Channel':channel().
ats2erlcml_cml_spawn(F)        -> spawn(?MODULE, ats2erlpre_cloref0_app, [F]).
ats2erlcml_cml_recv(Chan)      -> 'Elixir.Channel':channel_recv(Chan).
ats2erlcml_cml_send(Chan, Msg) -> 'Elixir.Channel':channel_send(Chan, Msg).
