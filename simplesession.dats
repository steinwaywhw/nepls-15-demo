#define ATS_DYNLOADFLAG 0

%{^
%%
-module(simplesession).
%%
-compile(nowarn_unused_vars).
-compile(nowarn_unused_function).
-compile(export_all).
%%
-include("$PATSHOMERELOC/contrib/libatscc/libatscc2erl/libatscc2erl_all.hrl").
-include("$PATSHOMERELOC/contrib/libatscc/libatscc2erl/Session/mylibats2erl_all.hrl").
%%
%}


#include "contrib/libatscc/libatscc2erl/staloadall.hats"
staload "contrib/libatscc/libatscc2erl/Session/SATS/basis.sats"
staload UN = "prelude/SATS/unsafe.sats"
//staload "contrib/libatscc/libatscc2erl/Session/SATS/co-sslist.sats"


symintr send 
symintr recv 
symintr unroll 

overload send with chanpos_send 
overload send with channeg_recv 
overload recv with chanpos_recv 
overload recv with channeg_send

abstype rpt (a:vt@ype)
extern fun unroll_pos {a:vt@ype} (!chanpos (rpt a) >> chanpos (chsnd a :: rpt a)): void //= "%mac#"
extern fun unroll_neg {a:vt@ype} (!channeg (rpt a) >> channeg (chsnd a :: rpt a)): void 
overload unroll with unroll_pos 
overload unroll with unroll_neg

implement unroll_pos {a} (ch) = () where {
	prval _ = $UN.castview2void (ch)
}

implement unroll_neg {a} (ch) = () where {
	prval _ = $UN.castview2void (ch)
}


(* ***** Sieve ***** *)

extern fun counter (n: int): channeg (rpt int)
extern fun filter (channeg (rpt int), p: int): channeg (rpt int)
extern fun primes (): channeg (rpt int)
extern fun sieve (): void 


implement counter (n) = let 

	fun loop (ch: chanpos (rpt int), n: int): void = let
		val _ = unroll ch
		val _ = send (ch, n)
	in 
		loop (ch, n+1)
	end

in 
	channeg_create (llam (ch) => loop (ch, n))
end 

implement filter (ch, p) = let 

	fun loop (chout: chanpos (rpt int), chin: channeg (rpt int), p: int): void = let 
		val _ = unroll chin 
		val num = recv chin 
		val _ = if num mod p > 0 then (unroll chout; send (chout, num))
	in 
		loop (chout, chin, p)
	end 

in 
	channeg_create (llam chout => loop (chout, ch, p))
end 

implement primes () = let 
	
	fun loop (chout: chanpos (rpt int), chin: channeg (rpt int)): void = let 
		val _ = unroll chin 
		val p = recv chin
		val _ = unroll chout 
		val _ = send (chout, p)
	in 
		loop (chout, filter (chin, p))
	end

in 
	channeg_create (llam chout => loop (chout, counter 2))
end 

implement sieve () = let 
	
	fun loop (ch: channeg (rpt int)): void = let 
		val _ = unroll ch 
		val p = recv ch 
		val _ = println! p 
		val _ = $extfcall (int, "io:get_line", "")
	in 
		loop ch
	end

in 
	loop (primes ())
end 

extern fun main0_erl (): void = "mac#"
implement main0_erl () = () where {
	val _ = sieve ()

}


 
